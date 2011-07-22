From: Dmitry Kozlov <xeb@mail.ru>
Subject: [PATCH net-2.6] gre: fix improper error handling
Date: Fri, 22 Jul 2011 13:26:10 +0400
Message-ID: <201107221326.10597.xeb@mail.ru>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback8.mail.ru ([94.100.176.136]:60531 "EHLO
	fallback8.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752922Ab1GVJff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 05:35:35 -0400
Received: from smtp12.mail.ru (smtp12.mail.ru [94.100.176.89])
	by fallback8.mail.ru (mPOP.Fallback_MX) with ESMTP id CDA4713C2873
	for <netdev@vger.kernel.org>; Fri, 22 Jul 2011 13:26:40 +0400 (MSD)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix improper protocol err_handler, current implementation is fully 
unapplicable and may cause kernel crash due to double kfree_skb.

Signed-off-by: Dmitry Kozlov <xeb@mail.ru>
--
 net/ipv4/gre.c |   23 +++++++----------------
 1 files changed, 7 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
index c6933f2..a8126fe 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -15,6 +15,7 @@
 #include <linux/kmod.h>
 #include <linux/skbuff.h>
 #include <linux/in.h>
+#include <linux/ip.h>
 #include <linux/netdevice.h>
 #include <linux/version.h>
 #include <linux/spinlock.h>
@@ -97,27 +98,17 @@ drop:
 static void gre_err(struct sk_buff *skb, u32 info)
 {
        const struct gre_protocol *proto;
-       u8 ver;
-
-       if (!pskb_may_pull(skb, 12))
-               goto drop;
-
-       ver = skb->data[1]&0x7f;
+       const struct iphdr *iph = (const struct iphdr *)skb->data;
+       u8 ver = skb->data[(iph->ihl<<2) + 1]&0x7f;
+
        if (ver >= GREPROTO_MAX)
-               goto drop;
+               return;
 
        rcu_read_lock();
        proto = rcu_dereference(gre_proto[ver]);
-       if (!proto || !proto->err_handler)
-               goto drop_unlock;
-       proto->err_handler(skb, info);
-       rcu_read_unlock();
-       return;
-
-drop_unlock:
+       if (proto && proto->err_handler)
+           proto->err_handler(skb, info);
        rcu_read_unlock();
-drop:
-       kfree_skb(skb);
 }
 
 static const struct net_protocol net_gre_protocol = {
