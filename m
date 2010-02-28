From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 5/13] bridge: Split may_deliver/deliver_clone out of br_flood
Date: Sun, 28 Feb 2010 13:41:43 +0800
Message-ID: <E1NlbuR-000213-US@gondolin.me.apana.org.au>
References: <20100228054012.GA7583@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42746 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751449Ab0B1Flq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 00:41:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bridge: Split may_deliver/deliver_clone out of br_flood

This patch moves the main loop body in br_flood into the function
may_deliver.  The code that clones an skb and delivers it is moved
into the deliver_clone function.

This allows this to be reused by the future multicast forward
function.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/bridge/br_forward.c |   69 ++++++++++++++++++++++++++++++++----------------
 1 file changed, 46 insertions(+), 23 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 2e1cb43..86cd071 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -11,6 +11,7 @@
  *	2 of the License, or (at your option) any later version.
  */
 
+#include <linux/err.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
@@ -103,6 +104,44 @@ void br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 	kfree_skb(skb);
 }
 
+static int deliver_clone(struct net_bridge_port *prev, struct sk_buff *skb,
+			 void (*__packet_hook)(const struct net_bridge_port *p,
+					       struct sk_buff *skb))
+{
+	skb = skb_clone(skb, GFP_ATOMIC);
+	if (!skb) {
+		struct net_device *dev = BR_INPUT_SKB_CB(skb)->brdev;
+
+		dev->stats.tx_dropped++;
+		return -ENOMEM;
+	}
+
+	__packet_hook(prev, skb);
+	return 0;
+}
+
+static struct net_bridge_port *maybe_deliver(
+	struct net_bridge_port *prev, struct net_bridge_port *p,
+	struct sk_buff *skb,
+	void (*__packet_hook)(const struct net_bridge_port *p,
+			      struct sk_buff *skb))
+{
+	int err;
+
+	if (!should_deliver(p, skb))
+		return prev;
+
+	if (!prev)
+		goto out;
+
+	err = deliver_clone(prev, skb, __packet_hook);
+	if (err)
+		return ERR_PTR(err);
+
+out:
+	return p;
+}
+
 /* called under bridge lock */
 static void br_flood(struct net_bridge *br, struct sk_buff *skb,
 		     struct sk_buff *skb0,
@@ -111,38 +150,22 @@ static void br_flood(struct net_bridge *br, struct sk_buff *skb,
 {
 	struct net_bridge_port *p;
 	struct net_bridge_port *prev;
-	struct net_device *dev = BR_INPUT_SKB_CB(skb)->brdev;
 
 	prev = NULL;
 
 	list_for_each_entry_rcu(p, &br->port_list, list) {
-		if (should_deliver(p, skb)) {
-			if (prev != NULL) {
-				struct sk_buff *skb2;
-
-				if ((skb2 = skb_clone(skb, GFP_ATOMIC)) == NULL) {
-					dev->stats.tx_dropped++;
-					goto out;
-				}
-
-				__packet_hook(prev, skb2);
-			}
-
-			prev = p;
-		}
+		prev = maybe_deliver(prev, p, skb, __packet_hook);
+		if (IS_ERR(prev))
+			goto out;
 	}
 
 	if (!prev)
 		goto out;
 
-	if (skb0) {
-		skb = skb_clone(skb, GFP_ATOMIC);
-		if (!skb) {
-			dev->stats.tx_dropped++;
-			goto out;
-		}
-	}
-	__packet_hook(prev, skb);
+	if (skb0)
+		deliver_clone(prev, skb, __packet_hook);
+	else
+		__packet_hook(prev, skb);
 	return;
 
 out:
