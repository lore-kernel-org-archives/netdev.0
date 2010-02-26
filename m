From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/13] bridge: Avoid unnecessary clone on forward path
Date: Fri, 26 Feb 2010 23:35:08 +0800
Message-ID: <E1Nl2Dc-0006vE-4S@gondolin.me.apana.org.au>
References: <20100226153410.GA26419@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52508 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965046Ab0BZPfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 10:35:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bridge: Avoid unnecessary clone on forward path

When the packet is delivered to the local bridge device we may
end up cloning it unnecessarily if no bridge port can receive
the packet in br_flood.

This patch avoids this by moving the skb_clone into br_flood.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/bridge/br_forward.c |   33 ++++++++++++++++++++++-----------
 net/bridge/br_input.c   |    5 +----
 net/bridge/br_private.h |    3 ++-
 3 files changed, 25 insertions(+), 16 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index bc1704a..6cd50c6 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -105,8 +105,9 @@ void br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 
 /* called under bridge lock */
 static void br_flood(struct net_bridge *br, struct sk_buff *skb,
-	void (*__packet_hook)(const struct net_bridge_port *p,
-			      struct sk_buff *skb))
+		     struct sk_buff *skb0,
+		     void (*__packet_hook)(const struct net_bridge_port *p,
+					   struct sk_buff *skb))
 {
 	struct net_bridge_port *p;
 	struct net_bridge_port *prev;
@@ -120,8 +121,7 @@ static void br_flood(struct net_bridge *br, struct sk_buff *skb,
 
 				if ((skb2 = skb_clone(skb, GFP_ATOMIC)) == NULL) {
 					br->dev->stats.tx_dropped++;
-					kfree_skb(skb);
-					return;
+					goto out;
 				}
 
 				__packet_hook(prev, skb2);
@@ -131,23 +131,34 @@ static void br_flood(struct net_bridge *br, struct sk_buff *skb,
 		}
 	}
 
-	if (prev != NULL) {
-		__packet_hook(prev, skb);
-		return;
+	if (!prev)
+		goto out;
+
+	if (skb0) {
+		skb = skb_clone(skb, GFP_ATOMIC);
+		if (!skb) {
+			br->dev->stats.tx_dropped++;
+			goto out;
+		}
 	}
+	__packet_hook(prev, skb);
+	return;
 
-	kfree_skb(skb);
+out:
+	if (!skb0)
+		kfree_skb(skb);
 }
 
 
 /* called with rcu_read_lock */
 void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb)
 {
-	br_flood(br, skb, __br_deliver);
+	br_flood(br, skb, NULL, __br_deliver);
 }
 
 /* called under bridge lock */
-void br_flood_forward(struct net_bridge *br, struct sk_buff *skb)
+void br_flood_forward(struct net_bridge *br, struct sk_buff *skb,
+		      struct sk_buff *skb2)
 {
-	br_flood(br, skb, __br_forward);
+	br_flood(br, skb, skb2, __br_forward);
 }
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index be5ab8d..edfdaef 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -72,14 +72,11 @@ int br_handle_frame_finish(struct sk_buff *skb)
 		skb = NULL;
 	}
 
-	if (skb2 == skb)
-		skb2 = skb_clone(skb, GFP_ATOMIC);
-
 	if (skb) {
 		if (dst)
 			br_forward(dst->dst, skb);
 		else
-			br_flood_forward(br, skb);
+			br_flood_forward(br, skb, skb2);
 	}
 
 	if (skb2)
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index a38d738..7b0aed5 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -181,7 +181,8 @@ extern void br_forward(const struct net_bridge_port *to,
 		struct sk_buff *skb);
 extern int br_forward_finish(struct sk_buff *skb);
 extern void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb);
-extern void br_flood_forward(struct net_bridge *br, struct sk_buff *skb);
+extern void br_flood_forward(struct net_bridge *br, struct sk_buff *skb,
+			     struct sk_buff *skb2);
 
 /* br_if.c */
 extern void br_port_carrier_check(struct net_bridge_port *p);
