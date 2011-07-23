From: xeb@mail.ru
Subject: [PATCH net-2.6 v2] gre: fix improper error handling
Date: Sat, 23 Jul 2011 10:49:40 +0400
Message-ID: <201107231049.40603.xeb@mail.ru>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_E8mKOiayJpGgTDg"
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp17.mail.ru ([94.100.176.154]:34709 "EHLO smtp17.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750857Ab1GWGto (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2011 02:49:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_E8mKOiayJpGgTDg
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit

Fix improper protocol err_handler, current implementation is fully
unapplicable and may cause kernel crash due to double kfree_skb.

Signed-off-by: Dmitry Kozlov <xeb@mail.ru>
---

--Boundary-00=_E8mKOiayJpGgTDg
Content-Type: text/plain;
  charset="iso-8859-15";
  name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="patch"

 net/ipv4/gre.c |   21 ++++++---------------
 1 files changed, 6 insertions(+), 15 deletions(-)
 
diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
index 9dbe108..dbfc21d 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -15,6 +15,7 @@
 #include <linux/kmod.h>
 #include <linux/skbuff.h>
 #include <linux/in.h>
+#include <linux/ip.h>
 #include <linux/netdevice.h>
 #include <linux/spinlock.h>
 #include <net/protocol.h>
@@ -96,27 +97,17 @@ drop:
 static void gre_err(struct sk_buff *skb, u32 info)
 {
 	const struct gre_protocol *proto;
-	u8 ver;
-
-	if (!pskb_may_pull(skb, 12))
-		goto drop;
+	const struct iphdr *iph = (const struct iphdr *)skb->data;
+	u8 ver = skb->data[(iph->ihl<<2) + 1]&0x7f;
 
-	ver = skb->data[1]&0x7f;
 	if (ver >= GREPROTO_MAX)
-		goto drop;
+		return;
 
 	rcu_read_lock();
 	proto = rcu_dereference(gre_proto[ver]);
-	if (!proto || !proto->err_handler)
-		goto drop_unlock;
-	proto->err_handler(skb, info);
-	rcu_read_unlock();
-	return;
-
-drop_unlock:
+	if (proto && proto->err_handler)
+		proto->err_handler(skb, info);
 	rcu_read_unlock();
-drop:
-	kfree_skb(skb);
 }
 
 static const struct net_protocol net_gre_protocol = {

--Boundary-00=_E8mKOiayJpGgTDg--
