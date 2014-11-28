From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: tun issue after e0b46d0ee9c: tun: Use iovec iterators
Date: Fri, 28 Nov 2014 17:25:27 -0200
Message-ID: <5478CC27.9040705@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33886 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750968AbaK1TZd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Nov 2014 14:25:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I saw there are tun updates on Dave's queue but none seemed to handle this.

I can't use current net-next (799d2fff1858004526ad75d66a5dd8a5cce6ad40) on a 
kvm hypervisor because tun got clogged somehow. Bisected down to:

commit e0b46d0ee9c240c7430a47e9b0365674d4a04522
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Fri Nov 7 21:22:23 2014 +0800

     tun: Use iovec iterators

     This patch removes the use of skb_copy_datagram_const_iovec in
     favour of the iovec iterator-based skb_copy_datagram_iter.


tun interface, host drops 1 incoming packets from guest, shown at ip -s l l, 
and keeps like that forever. netstat -s didn't mention any checksum issue

12: vnet0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master 
virbr0 state UNKNOWN mode DEFAULT group default qlen 500
     link/ether fe:54:00:10:3f:06 brd ff:ff:ff:ff:ff:ff
     RX: bytes  packets  errors  dropped overrun mcast
     0          0        0       1       0       0
     TX: bytes  packets  errors  dropped carrier collsns
     2704       51       0       0       0       0

And tap interfaces go counting dropped++ every time:

20: tap0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master 
virbr0 state UNKNOWN mode DEFAULT group default qlen 500
     link/ether fe:97:a4:a6:14:65 brd ff:ff:ff:ff:ff:ff
     RX: bytes  packets  errors  dropped overrun mcast
     0          0        0       16      0       0
     TX: bytes  packets  errors  dropped carrier collsns
     1456       28       0       0       0       0


traffic capture on guest shows incoming and outgoing packets just fine, while 
on host, it shows no incoming packets at all.

Tested with virtio_net and e1000.

With:

tun.c tun_get_user():
         if (zerocopy)
                 err = zerocopy_sg_from_iter(skb, from);
         else {
                 err = skb_copy_datagram_from_iter(skb, 0, from, len); <- fails
                 if (!err && msg_control) {
                         struct ubuf_info *uarg = msg_control;
                         uarg->callback(uarg, false);
                 }
         }

         if (err) {
                 tun->dev->stats.rx_dropped++;
                 kfree_skb(skb);
                 pr_err("%d %d %d %p\n", __LINE__, zerocopy, err, msg_control);
                 return -EFAULT;
         }

And net/core/datagram.c, skb_copy_datagram_from_iter():
         if (copy > 0) {
                 int ret;
                 if (copy > len)
                         copy = len;
                 ret = copy_from_iter(skb->data + offset, copy, from);
                 if (ret != copy) {
                         pr_err("%d ret=%d copy=%d offset=%d len=%d\n", 
__LINE__, ret, copy, offset, len);
                         goto fault;
                 }


I get, for tun interfaces:
[   75.435552] 506 ret=80 copy=90 offset=0 len=90
[   75.435563] tun: 1124 0 -14           (null)
[   75.499528] 506 ret=80 copy=90 offset=0 len=90
[   75.499540] tun: 1124 0 -14           (null)

These were 1 drop on 1 interface each

And for tap interfaces:
[  301.982639] 506 ret=80 copy=90 offset=0 len=90
[  301.982649] tun: 1124 0 -14           (null)
[  301.988625] 506 ret=80 copy=90 offset=0 len=90
[  301.988635] tun: 1124 0 -14           (null)
[  301.994762] 506 ret=80 copy=90 offset=0 len=90
[  301.994773] tun: 1124 0 -14           (null)
[  302.229962] 506 ret=332 copy=342 offset=0 len=342
[  302.229972] tun: 1124 0 -14           (null)
[  302.230621] 506 ret=332 copy=342 offset=0 len=342
[  302.230627] tun: 1124 0 -14           (null)
[  302.239065] 506 ret=332 copy=342 offset=0 len=342
[  302.239071] tun: 1124 0 -14           (null)

It's returning 10 bytes less than the expected... ideas?

I can provide more info if needed, it's easy to reproduce in here.

Thanks,
Marcelo
