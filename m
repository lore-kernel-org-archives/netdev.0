From: Jason Wang <jasowang@redhat.com>
Subject: Re: The ubufs->refcount maybe be subtracted twice when tun_get_user
 failed
Date: Wed, 30 Nov 2016 10:53:47 +0800
Message-ID: <fad5d47a-96ee-1afc-b10c-cb2a6d5dc784@redhat.com>
References: <34EFBCA9F01B0748BEB6B629CE643AE60B0A553E@szxeml561-mbx.china.huawei.com>
 <30e4c704-70b4-d318-68bd-742eb5f9bfc7@redhat.com>
 <34EFBCA9F01B0748BEB6B629CE643AE60B0A5826@szxeml561-mbx.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: caihe <caihe@huawei.com>
To: wangyunjian <wangyunjian@huawei.com>,
        "mst@redhat.com" <mst@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57744 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752044AbcK3Cxw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Nov 2016 21:53:52 -0500
In-Reply-To: <34EFBCA9F01B0748BEB6B629CE643AE60B0A5826@szxeml561-mbx.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016年11月29日 21:27, wangyunjian wrote:
> Sorry, I didn't describe it clearly. In fact, the second subtraction happens in the function handle_tx,
> when tun_get_user fails and zcopy_used is ture. Fllowing the steps:

I get your meaning. Thanks for the reporting. Will post patches (since 
macvtap has similar issue).


>
> static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>                                    void *msg_control, struct iov_iter *from,
>                                    int noblock) {
>             ...
>
>             if (zerocopy)
>                       err = zerocopy_sg_from_iter(skb, from);
>             else {
>                       err = skb_copy_datagram_from_iter(skb, 0, from, len);
>                       if (!err && msg_control) {
>                                struct ubuf_info *uarg = msg_control;
>                                uarg->callback(uarg, false);                       --> step 1, the ubufs->refcount is subtracted frist.
>                       }
>             }
>
>             if (err) {
>                       this_cpu_inc(tun->pcpu_stats->rx_dropped);
>                       kfree_skb(skb);
>                       return -EFAULT;
>             }
>
>             err = virtio_net_hdr_to_skb(skb, &gso, tun_is_little_endian(tun));
>             if (err) {
>                       this_cpu_inc(tun->pcpu_stats->rx_frame_errors);
>                       kfree_skb(skb);
>                       return -EINVAL;                                         -->step 2, return err.
>             }
> }
>
> static void handle_tx(struct vhost_net *net)
> {
> 	...
> 	/* TODO: Check specific error and bomb out unless ENOBUFS? */
> 	err = sock->ops->sendmsg(sock, &msg, len);
> 	if (unlikely(err < 0)) {
> 		if (zcopy_used) {
> 			vhost_net_ubuf_put(ubufs);                                        --> step 3, the ubufs->refcount will be subtracted twice, when sendmsg execution err.
> 			nvq->upend_idx = ((unsigned)nvq->upend_idx - 1)
> 				% UIO_MAXIOV;
> 		}
> 		vhost_discard_vq_desc(vq, 1);
> 		break;
> 	}
> 	...
> }
>
> -----Original Message-----
