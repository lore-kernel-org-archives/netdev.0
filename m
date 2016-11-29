From: Jason Wang <jasowang@redhat.com>
Subject: Re: The ubufs->refcount maybe be subtracted twice when tun_get_user
 failed
Date: Tue, 29 Nov 2016 18:06:37 +0800
Message-ID: <30e4c704-70b4-d318-68bd-742eb5f9bfc7@redhat.com>
References: <34EFBCA9F01B0748BEB6B629CE643AE60B0A553E@szxeml561-mbx.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: caihe <caihe@huawei.com>
To: wangyunjian <wangyunjian@huawei.com>,
        "mst@redhat.com" <mst@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41056 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756584AbcK2KGl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Nov 2016 05:06:41 -0500
In-Reply-To: <34EFBCA9F01B0748BEB6B629CE643AE60B0A553E@szxeml561-mbx.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016年11月29日 17:30, wangyunjian wrote:
> In function tun_get_user , the ubufs->refcount may be subtracted twice, when msg_control is true and zerocopy is false.
>
> About the below code:
>
> static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>                                  void *msg_control, struct iov_iter *from,
>                                  int noblock)
> {
>           ...
>
>           if (zerocopy)
>                     err = zerocopy_sg_from_iter(skb, from);
>           else {
>                     err = skb_copy_datagram_from_iter(skb, 0, from, len);
>                     if (!err && msg_control) {
>                              struct ubuf_info *uarg = msg_control;
>                              uarg->callback(uarg, false);                       --> the ubufs->refcount is subtracted frist.
>                     }
>           }
>
>           if (err) {
>                     this_cpu_inc(tun->pcpu_stats->rx_dropped);
>                     kfree_skb(skb);
>                     return -EFAULT;
>           }
>
>           err = virtio_net_hdr_to_skb(skb, &gso, tun_is_little_endian(tun));
>           if (err) {
>                     this_cpu_inc(tun->pcpu_stats->rx_frame_errors);
>                     kfree_skb(skb);
>                     return -EINVAL;                                   -->here, the ubufs->refcount will be subtracted twice, when virtio_net_hdr_to_skb execution err.
>           }

Just make sure I understand the problem. Since we don't set 
SKBTX_DEV_ZEROCOPY here if zerocopy is false, callback won't be even 
trigged in skb_release_data(). So we are in fact safe here?

Thanks

> switch (tun->flags & TUN_TYPE_MASK) {
>           case IFF_TUN:
>                     if (tun->flags & IFF_NO_PI) {
>                              switch (skb->data[0] & 0xf0) {
>                              case 0x40:
>                                       pi.proto = htons(ETH_P_IP);
>                                       break;
>                              case 0x60:
>                                       pi.proto = htons(ETH_P_IPV6);
>                                       break;
>                              default:
>                                       this_cpu_inc(tun->pcpu_stats->rx_dropped);
>                                       kfree_skb(skb);
>                                       return -EINVAL;                          --> this will also be subtracted twice.
>                              }
>                     }
>
>                     skb_reset_mac_header(skb);
>                     skb->protocol = pi.proto;
>                     skb->dev = tun->dev;
>                     break;
>           case IFF_TAP:
>                     skb->protocol = eth_type_trans(skb, tun->dev);
>                     break;
>           }
> 		...
> }
