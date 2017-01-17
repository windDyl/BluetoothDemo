//
//  ViewController.m
//  BluetoothDemo
//
//  Created by Ethank on 16/7/25.
//  Copyright © 2016年 DY. All rights reserved.
//

#import "ViewController.h"
#import <GameKit/GameKit.h>

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,GKPeerPickerControllerDelegate>
/**
 *  连接
 */
- (IBAction)connect:(id)sender;
/**
 *  选择图片
 */
- (IBAction)selectedPhoto:(id)sender;
/**
 *  发送
 */
- (IBAction)send:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
/**
 *  会话
 */
@property (nonatomic, strong) GKSession *session;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
/**
 *  连接
 */
- (IBAction)connect:(id)sender {
    GKPeerPickerController *peerPC = [[GKPeerPickerController alloc] init];
    peerPC.delegate = self;
    [peerPC show];
}
/**
 *  选择图片
 */
- (IBAction)selectedPhoto:(id)sender {
    //创建图片选择控制器
    UIImagePickerController *imageP = [[UIImagePickerController alloc] init];
    //判断图库是否可用
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        //判断打开图库的类型
        imageP.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        imageP.delegate = self;
        //打开图片选择控制器
        [self presentViewController:imageP animated:YES completion:nil];
    }
    
}
/**
 *  发送
 */
- (IBAction)send:(id)sender {
    // 利用session发送图片数据即可
    // 1.取出customImageView上得图片, 转换为二进制
    UIImage *image =  self.imageView.image;
    NSData *data = UIImagePNGRepresentation(image);
    
    /*
     GKSendDataReliable, 数据安全的发送模式, 慢
     GKSendDataUnreliable, 数据不安全的发送模式, 快
     */
    
    /*
     data: 需要发送的数据
     DataReliable: 是否安全的发送数据(发送数据的模式)
     error: 是否监听发送错误
     */
    [self.session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
}

#pragma mark - GKPeerPickerControllerDelegate
// 4.实现dialing方法
/**
 *  当蓝牙设备连接成功就会调用
 *
 *  @param picker  触发时间的控制器
 *  @param peerID  连接蓝牙设备的ID
 *  @param session 连接蓝牙的会话(可用通讯), 以后只要拿到session就可以传输数据
 */
- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
    NSLog(@"%@", peerID);
    // 1.保存会话
    self.session = session;
    
    // 2.设置监听接收传递过来的数据
    /*
     Handler: 谁来处理接收到得数据
     withContext: 传递数据
     */
    [self.session setDataReceiveHandler:self withContext:nil];
    
    
    // 2.关闭显示蓝牙设备控制器
    [picker dismiss];
}
/**
 *  接收到其它设备传递过来的数据就会调用
 *
 *  @param data    传递过来的数据
 *  @param peer    传递数据设备的ID
 *  @param session 会话
 *  @param context 注册监听时传递的数据
 */
- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
    //    NSLog(@"%s", __func__);
    // 1.将传递过来的数据转换为图片(注意: 因为发送的时图片, 所以才需要转换为图片)
    UIImage *image = [UIImage imageWithData:data];
    self.imageView.image = image;
}


- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
    
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //    NSLog(@"%@", info);
    self.imageView.image = info[UIImagePickerControllerOriginalImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
