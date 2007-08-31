From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/7] [BRIDGE]: Kill clone argument to br_flood_*
Date: Fri, 31 Aug 2007 17:11:33 +0800
Message-ID: <E1IR2XN-0007QG-00@gondolin.me.apana.org.au>
References: <20070831090625.GA28175@gondor.apana.org.au>
To: James Chapman <jchapman@katalix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Michal Ostrowski <mostrows@speakeasy.net>,
	Paul Mackerras <paulus@samba.org>,
	Herbert Xu <herbert@gondo
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3597 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756240AbXHaJLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 05:11:36 -0400
Received: from gondolin.me.apana.org.au ([192.168.0.6] ident=mail)
	by arnor.apana.org.au with esmtp (Exim 4.50 #1 (Debian))
	id 1IR2XO-0004RR-6D
	for <netdev@vger.kernel.org>; Fri, 31 Aug 2007 19:11:34 +1000
Received: from herbert by gondolin.me.apana.org.au with local (Exim 3.36 #1 (Debian))
	id 1IR2XN-0007QG-00
	for <netdev@vger.kernel.org>; Fri, 31 Aug 2007 17:11:33 +0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BRIDGE]: Kill clone argument to br_flood_*

The clone argument is only used by one caller and that caller can clone
the packet itself.  This patch moves the clone call into the caller and
kills the clone argument.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/bridge/br_device.c  |    4 ++--
 net/bridge/br_forward.c |   21 +++++----------------
 net/bridge/br_input.c   |   48 ++++++++++++++++++++++--------------------------
 net/bridge/br_private.h |    8 ++------
 4 files changed, 31 insertions(+), 50 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 0eded17..99292e8 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -41,11 +41,11 @@ int br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb_pull(skb, ETH_HLEN);
 
 	if (dest[0] & 1)
-		br_flood_deliver(br, skb, 0);
+		br_flood_deliver(br, skb);
 	else if ((dst = __br_fdb_get(br, dest)) != NULL)
 		br_deliver(dst->dst, skb);
 	else
-		br_flood_deliver(br, skb, 0);
+		br_flood_deliver(br, skb);
 
 	return 0;
 }
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index ada7f49..bdd7c35 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -100,24 +100,13 @@ void br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 }
 
 /* called under bridge lock */
-static void br_flood(struct net_bridge *br, struct sk_buff *skb, int clone,
+static void br_flood(struct net_bridge *br, struct sk_buff *skb,
 	void (*__packet_hook)(const struct net_bridge_port *p,
 			      struct sk_buff *skb))
 {
 	struct net_bridge_port *p;
 	struct net_bridge_port *prev;
 
-	if (clone) {
-		struct sk_buff *skb2;
-
-		if ((skb2 = skb_clone(skb, GFP_ATOMIC)) == NULL) {
-			br->statistics.tx_dropped++;
-			return;
-		}
-
-		skb = skb2;
-	}
-
 	prev = NULL;
 
 	list_for_each_entry_rcu(p, &br->port_list, list) {
@@ -148,13 +137,13 @@ static void br_flood(struct net_bridge *br, struct sk_buff *skb, int clone,
 
 
 /* called with rcu_read_lock */
-void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb, int clone)
+void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb)
 {
-	br_flood(br, skb, clone, __br_deliver);
+	br_flood(br, skb, __br_deliver);
 }
 
 /* called under bridge lock */
-void br_flood_forward(struct net_bridge *br, struct sk_buff *skb, int clone)
+void br_flood_forward(struct net_bridge *br, struct sk_buff *skb)
 {
-	br_flood(br, skb, clone, __br_forward);
+	br_flood(br, skb, __br_forward);
 }
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 5c18595..069a4e1 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -43,7 +43,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	struct net_bridge_port *p = rcu_dereference(skb->dev->br_port);
 	struct net_bridge *br;
 	struct net_bridge_fdb_entry *dst;
-	int passedup = 0;
+	struct sk_buff *skb2;
 
 	if (!p || p->state == BR_STATE_DISABLED)
 		goto drop;
@@ -55,39 +55,35 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	if (p->state == BR_STATE_LEARNING)
 		goto drop;
 
-	if (br->dev->flags & IFF_PROMISC) {
-		struct sk_buff *skb2;
+	/* The packet skb2 goes to the local host (NULL to skip). */
+	skb2 = NULL;
 
-		skb2 = skb_clone(skb, GFP_ATOMIC);
-		if (skb2 != NULL) {
-			passedup = 1;
-			br_pass_frame_up(br, skb2);
-		}
-	}
+	if (br->dev->flags & IFF_PROMISC)
+		skb2 = skb;
+
+	dst = NULL;
 
 	if (is_multicast_ether_addr(dest)) {
 		br->statistics.multicast++;
-		br_flood_forward(br, skb, !passedup);
-		if (!passedup)
-			br_pass_frame_up(br, skb);
-		goto out;
+		skb2 = skb;
+	} else if ((dst = __br_fdb_get(br, dest)) && dst->is_local) {
+		skb2 = skb;
+		/* Do not forward the packet since it's local. */
+		skb = NULL;
 	}
 
-	dst = __br_fdb_get(br, dest);
-	if (dst != NULL && dst->is_local) {
-		if (!passedup)
-			br_pass_frame_up(br, skb);
-		else
-			kfree_skb(skb);
-		goto out;
-	}
+	if (skb2 == skb)
+		skb2 = skb_clone(skb, GFP_ATOMIC);
 
-	if (dst != NULL) {
-		br_forward(dst->dst, skb);
-		goto out;
-	}
+	if (skb2)
+		br_pass_frame_up(br, skb2);
 
-	br_flood_forward(br, skb, 0);
+	if (skb) {
+		if (dst)
+			br_forward(dst->dst, skb);
+		else
+			br_flood_forward(br, skb);
+	}
 
 out:
 	return 0;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 21bf3a9..e6dc6f5 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -170,12 +170,8 @@ extern int br_dev_queue_push_xmit(struct sk_buff *skb);
 extern void br_forward(const struct net_bridge_port *to,
 		struct sk_buff *skb);
 extern int br_forward_finish(struct sk_buff *skb);
-extern void br_flood_deliver(struct net_bridge *br,
-		      struct sk_buff *skb,
-		      int clone);
-extern void br_flood_forward(struct net_bridge *br,
-		      struct sk_buff *skb,
-		      int clone);
+extern void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb);
+extern void br_flood_forward(struct net_bridge *br, struct sk_buff *skb);
 
 /* br_if.c */
 extern void br_port_carrier_check(struct net_bridge_port *p);
