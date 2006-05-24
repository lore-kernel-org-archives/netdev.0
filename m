From: Stephen Hemminger <shemminger@osdl.org>
Subject: [patch 1/3] bridge: optimize conditional in forward path
Date: Wed, 24 May 2006 10:12:17 -0700
Message-ID: <20060524171347.582697000@localhost.localdomain>
References: <20060524171216.706750000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:50359 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932417AbWEXRPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 13:15:20 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=bridge-forward-opt.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Small optimizations of bridge forwarding path.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- br.orig/net/bridge/br_forward.c
+++ br/net/bridge/br_forward.c
@@ -20,14 +20,11 @@
 #include <linux/netfilter_bridge.h>
 #include "br_private.h"
 
+/* Don't forward packets to originating port or forwarding diasabled */
 static inline int should_deliver(const struct net_bridge_port *p, 
 				 const struct sk_buff *skb)
 {
-	if (skb->dev == p->dev ||
-	    p->state != BR_STATE_FORWARDING)
-		return 0;
-
-	return 1;
+	return (skb->dev != p->dev && p->state == BR_STATE_FORWARDING);
 }
 
 static inline unsigned packet_length(const struct sk_buff *skb)
@@ -55,10 +52,9 @@ int br_dev_queue_push_xmit(struct sk_buf
 
 int br_forward_finish(struct sk_buff *skb)
 {
-	NF_HOOK(PF_BRIDGE, NF_BR_POST_ROUTING, skb, NULL, skb->dev,
-			br_dev_queue_push_xmit);
+	return NF_HOOK(PF_BRIDGE, NF_BR_POST_ROUTING, skb, NULL, skb->dev,
+		       br_dev_queue_push_xmit);
 
-	return 0;
 }
 
 static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)

--

