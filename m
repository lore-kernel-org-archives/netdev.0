From: Ang Way Chuang <wcang@nav6.org>
Subject: [PATCH] NET: Proper handling of IPv6 header in tun driver when TUN_NO_PI
 is set
Date: Fri, 06 Jun 2008 18:49:17 +0800
Message-ID: <4849162D.7000401@nav6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Maxim Krasnyansky <maxk@qualcomm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nav6.org ([219.93.2.80]:41254 "EHLO nav6.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752362AbYFFLS2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jun 2008 07:18:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By default, tun.c running in TUN_TUN_DEV mode will set the protocol of 
packet to IPv4 if TUN_NO_PI is set. My program failed to work when I 
assumed that the driver will check the first nibble of packet, determine 
IP version and set the appropriate protocol.

The test for this change was conducted on 2.6.24.7 kernel. But the diff 
is produced using git commit
c3b25b32e8bef526cca748e1ba023c6bdd705a99. I couldn't test it on kernel 
version greater than 2.6.25 due to out of tree driver failing to 
compile. But tun_get_user doesn't change that much between 2.6.24 and 
2.6.26, so it should work, I hope :-D. This patch is trivial because 
this problem can also be fixed by not using TUN_NO_PI.

Signed-off-by: Ang Way Chuang <wcang@nav6.org>
---

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 0ce07a3..77964bc 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -313,6 +313,21 @@ static __inline__ ssize_t tun_get_user(struct 
tun_struct *tun, struct iovec *iv,

         switch (tun->flags & TUN_TYPE_MASK) {
         case TUN_TUN_DEV:
+               if (tun->flags & TUN_NO_PI) {
+                       switch (skb->data[0] & 0xf0) {
+                       case 0x40:
+                               pi.proto = __constant_htons(ETH_P_IP);
+                               break;
+                       case 0x60:
+                               pi.proto = __constant_htons(ETH_P_IPV6);
+                               break;
+                       default:
+                               tun->dev->stats.rx_dropped++;
+                               kfree_skb(skb);
+                               return -EINVAL;
+                       }
+               }
+
                 skb_reset_mac_header(skb);
                 skb->protocol = pi.proto;
                 skb->dev = tun->dev;

--
