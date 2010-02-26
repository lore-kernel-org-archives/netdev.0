From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 9/13] bridge: Add multicast data-path hooks
Date: Fri, 26 Feb 2010 23:35:14 +0800
Message-ID: <E1Nl2Di-0006wJ-JB@gondolin.me.apana.org.au>
References: <20100226153410.GA26419@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52525 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965144Ab0BZPfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 10:35:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bridge: Add multicast data-path hooks

This patch finally hooks up the multicast snooping module to the
data path.  In particular, all multicast packets passing through
the bridge are fed into the module and switched by it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/bridge/br_device.c |   15 ++++++++++++---
 net/bridge/br_input.c  |   18 +++++++++++++++++-
 2 files changed, 29 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 91dffe7..eb7062d 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -25,6 +25,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct net_bridge *br = netdev_priv(dev);
 	const unsigned char *dest = skb->data;
 	struct net_bridge_fdb_entry *dst;
+	struct net_bridge_mdb_entry *mdst;
 
 	BR_INPUT_SKB_CB(skb)->brdev = dev;
 
@@ -34,13 +35,21 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb_reset_mac_header(skb);
 	skb_pull(skb, ETH_HLEN);
 
-	if (dest[0] & 1)
-		br_flood_deliver(br, skb);
-	else if ((dst = __br_fdb_get(br, dest)) != NULL)
+	if (dest[0] & 1) {
+		if (br_multicast_rcv(br, NULL, skb))
+			goto out;
+
+		mdst = br_mdb_get(br, skb);
+		if (mdst || BR_INPUT_SKB_CB(skb)->mrouters_only)
+			br_multicast_deliver(mdst, skb);
+		else
+			br_flood_deliver(br, skb);
+	} else if ((dst = __br_fdb_get(br, dest)) != NULL)
 		br_deliver(dst->dst, skb);
 	else
 		br_flood_deliver(br, skb);
 
+out:
 	return NETDEV_TX_OK;
 }
 
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index edfdaef..53b3985 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -41,6 +41,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	struct net_bridge_port *p = rcu_dereference(skb->dev->br_port);
 	struct net_bridge *br;
 	struct net_bridge_fdb_entry *dst;
+	struct net_bridge_mdb_entry *mdst;
 	struct sk_buff *skb2;
 
 	if (!p || p->state == BR_STATE_DISABLED)
@@ -50,6 +51,10 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	br = p->br;
 	br_fdb_update(br, p, eth_hdr(skb)->h_source);
 
+	if (is_multicast_ether_addr(dest) &&
+	    br_multicast_rcv(br, p, skb))
+		goto drop;
+
 	if (p->state == BR_STATE_LEARNING)
 		goto drop;
 
@@ -64,8 +69,19 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	dst = NULL;
 
 	if (is_multicast_ether_addr(dest)) {
+		mdst = br_mdb_get(br, skb);
+		if (mdst || BR_INPUT_SKB_CB(skb)->mrouters_only) {
+			if ((mdst && !hlist_unhashed(&mdst->mglist)) ||
+			    br_multicast_is_router(br))
+				skb2 = skb;
+			br_multicast_forward(mdst, skb, skb2);
+			skb = NULL;
+			if (!skb2)
+				goto out;
+		} else
+			skb2 = skb;
+
 		br->dev->stats.multicast++;
-		skb2 = skb;
 	} else if ((dst = __br_fdb_get(br, dest)) && dst->is_local) {
 		skb2 = skb;
 		/* Do not forward the packet since it's local. */
