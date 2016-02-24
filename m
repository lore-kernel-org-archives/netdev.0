From: f6bvp <f6bvp@free.fr>
Subject: [Patch] rose_route_frame() NULL pointer dereference kernel panic
Date: Wed, 24 Feb 2016 17:53:11 +0100
Message-ID: <56CDDFF7.2040609@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle <ralf@linux-mips.org>, "'f6bvp'" <f6bvp@free.fr>,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shiva144.upmc.fr ([134.157.0.144]:60583 "EHLO shiva.upmc.fr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753149AbcBXRAh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 12:00:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Patch] Null pointer in rose_route_frame()

Bug appears when setting a second IP to ethernet device without adding
a route and a gateway:

/sbin/ifconfig enp4s0:1 44.168.19.22 netmask 255.255.255.240

If a route and a gateway are not added for subnet, and if
ax25ipd configuration includes a destination address in this subnet,
then a comparison of destinations address performed by ax25cmp()
called by rose_route_frame() is facing a null pointer and a kernel
panic occurs.

Attached is the report of kernel panic followed by a report of
successful patched function.

Bernard

==================================
6,756,516974441,-;NET: Registered protocol family 3
6,757,516978403,-;mkiss: AX.25 Multikiss, Hans Albas PE1AYX
6,758,516979388,-;mkiss: ax0: crc mode is auto.
6,759,516979945,-;IPv6: ADDRCONF(NETDEV_CHANGE): ax0: link becomes ready
6,760,519023446,-;NET: Registered protocol family 11
6,761,522043100,-;mkiss: ax0: Trying crc-smack
6,762,522044882,-;mkiss: ax0: Trying crc-flexnet
1,763,522044973,c;BUG: unable to handle kernel
4,764,522044974,+;NULL pointer dereference
4,765,522044975,+; at 0000000000000017
1,766,522044976,c;IP:
4,767,522044986,+; [<ffffffffc05ad0a9>] ax25cmp+0x19/0x60 [ax25]
4,768,522044987,c;PGD 3cd61067
4,769,522044987,+;PUD 35ac0067
4,770,522044988,+;PMD 0
4,771,522044989,+;
4,772,522044990,c;Oops: 0000 [#1]
4,773,522044991,+;SMP
4,774,522044991,+;
4,775,522044994,c;Modules linked in:
4,776,522044995,+; rose
4,777,522044996,+; mkiss
4,778,522044996,+; ax25
4,779,522044997,+; netconsole
4,846,522045047,+;
4,847,522045050,-;CPU: 1 PID: 11873 Comm: ax25ipd Not tainted 4.4.1 #2
4,848,522045051,-;Hardware name:                  /D975XBX2, BIOS 
BX97520J.86A.2797.2007.1008.1941 10/08/2007
4,849,522045053,-;task: ffff880037beb500 ti: ffff880034320000 task.ti: 
ffff880034320000
4,850,522045055,c;RIP: 0010:[<ffffffffc05ad0a9>]
4,851,522045058,+; [<ffffffffc05ad0a9>] ax25cmp+0x19/0x60 [ax25]
4,852,522045059,-;RSP: 0018:ffff880034323938  EFLAGS: 00010246
4,876,522045080,+;
4,877,522045081,-;Call Trace:
4,878,522045088,-; [<ffffffffc05cde6c>] rose_route_frame+0x9c/0x670 [rose]
4,879,522045094,-; [<ffffffff810aef90>] ? __init_waitqueue_head+0x10/0x20
4,971,522045204,+;
0,978,522045215,-;Kernel panic - not syncing: Fatal exception in interrupt
0,979,522045763,-;Kernel Offset: disabled
0,980,522045763,c;Rebooting in 30 seconds..

After patch is applied :
6,767,4251903518,-;NET: Registered protocol family 3
6,768,4251907330,-;mkiss: AX.25 Multikiss, Hans Albas PE1AYX
6,769,4251908399,-;mkiss: ax0: crc mode is auto.
6,770,4251909044,-;IPv6: ADDRCONF(NETDEV_CHANGE): ax0: link becomes ready
6,771,4253957114,-;NET: Registered protocol family 11
6,772,4256972259,-;mkiss: ax0: Trying crc-smack
6,773,4256974292,-;mkiss: ax0: Trying crc-flexnet
4,774,4256974372,-;Null ax25 destination !
4,775,4256978218,-;Null ax25 destination !
4,776,4266975133,-;Null ax25 destination !
4,777,4267007092,-;Null ax25 destination !
4,778,4287007148,-;Null ax25 destination !

diff --git a/net/rose/rose_route.c b/net/rose/rose_route.c
index 0fc76d8..254e528 100644
--- a/net/rose/rose_route.c
+++ b/net/rose/rose_route.c
@@ -863,6 +863,11 @@ int rose_route_frame(struct sk_buff *skb, ax25_cb 
*ax25)
         int res = 0;
         char buf[11];

+       if (ax25 == NULL) {
+               printk("Null ax25 destination !\n");
+               return res;
+       }
+
         if (skb->len < ROSE_MIN_LEN)
                 return res;
         frametype = skb->data[2];

Signed-off-by: Bernard Pidoux <f6bvp@free.fr>
