From: wangyunjian <wangyunjian@huawei.com>
Subject: The ubufs->refcount maybe be subtracted twice when tun_get_user
 failed
Date: Tue, 29 Nov 2016 09:30:19 +0000
Message-ID: <34EFBCA9F01B0748BEB6B629CE643AE60B0A553E@szxeml561-mbx.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: caihe <caihe@huawei.com>
To: "mst@redhat.com" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:42153 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754838AbcK2JbR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 04:31:17 -0500
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In function tun_get_user , the ubufs->refcount may be subtracted twice, when msg_control is true and zerocopy is false.

About the below code:

static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
                                void *msg_control, struct iov_iter *from,
                                int noblock)
{
         ...

         if (zerocopy)
                   err = zerocopy_sg_from_iter(skb, from);
         else {
                   err = skb_copy_datagram_from_iter(skb, 0, from, len);
                   if (!err && msg_control) {
                            struct ubuf_info *uarg = msg_control;
                            uarg->callback(uarg, false);                       --> the ubufs->refcount is subtracted frist.
                   }
         }

         if (err) {
                   this_cpu_inc(tun->pcpu_stats->rx_dropped);
                   kfree_skb(skb);
                   return -EFAULT;
         }

         err = virtio_net_hdr_to_skb(skb, &gso, tun_is_little_endian(tun));
         if (err) {
                   this_cpu_inc(tun->pcpu_stats->rx_frame_errors);
                   kfree_skb(skb);
                   return -EINVAL;                                   -->here, the ubufs->refcount will be subtracted twice, when virtio_net_hdr_to_skb execution err.
         }

switch (tun->flags & TUN_TYPE_MASK) {
         case IFF_TUN:
                   if (tun->flags & IFF_NO_PI) {
                            switch (skb->data[0] & 0xf0) {
                            case 0x40:
                                     pi.proto = htons(ETH_P_IP);
                                     break;
                            case 0x60:
                                     pi.proto = htons(ETH_P_IPV6);
                                     break;
                            default:
                                     this_cpu_inc(tun->pcpu_stats->rx_dropped);
                                     kfree_skb(skb);
                                     return -EINVAL;                          --> this will also be subtracted twice.
                            }
                   }

                   skb_reset_mac_header(skb);
                   skb->protocol = pi.proto;
                   skb->dev = tun->dev;
                   break;
         case IFF_TAP:
                   skb->protocol = eth_type_trans(skb, tun->dev);
                   break;
         }
		...
}
