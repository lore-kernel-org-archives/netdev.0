From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/9] net: Separate out SKB validation logic from transmit
 path.
Date: Mon, 01 Sep 2014 15:25:04 -0700 (PDT)
Message-ID: <20140901.152504.2255127391025184987.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44737 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529AbaIAWZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 18:25:04 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 7B543590920
	for <netdev@vger.kernel.org>; Mon,  1 Sep 2014 15:25:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


dev_hard_start_xmit() does two things, it first validates and
canonicalizes the SKB, then it actually sends it.

Make a set of helper functions for doing the first part.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dev.c | 125 ++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 71 insertions(+), 54 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6d82194..704a543 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2644,80 +2644,97 @@ out:
 	return skb;
 }
 
-int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
-			struct netdev_queue *txq)
+struct sk_buff *validate_xmit_vlan(struct sk_buff *skb, netdev_features_t features)
 {
-	int rc = NETDEV_TX_OK;
+	if (vlan_tx_tag_present(skb) &&
+	    !vlan_hw_offload_capable(features, skb->vlan_proto)) {
+		skb = __vlan_put_tag(skb, skb->vlan_proto,
+				     vlan_tx_tag_get(skb));
+		if (skb)
+			skb->vlan_tci = 0;
+	}
+	return skb;
+}
 
-	if (likely(!skb->next)) {
-		netdev_features_t features;
+static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device *dev)
+{
+	netdev_features_t features;
 
-		/*
-		 * If device doesn't need skb->dst, release it right now while
-		 * its hot in this cpu cache
-		 */
-		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
-			skb_dst_drop(skb);
+	if (skb->next)
+		return skb;
 
-		features = netif_skb_features(skb);
+	/* If device doesn't need skb->dst, release it right now while
+	 * its hot in this cpu cache
+	 */
+	if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
+		skb_dst_drop(skb);
 
-		if (vlan_tx_tag_present(skb) &&
-		    !vlan_hw_offload_capable(features, skb->vlan_proto)) {
-			skb = __vlan_put_tag(skb, skb->vlan_proto,
-					     vlan_tx_tag_get(skb));
-			if (unlikely(!skb))
-				goto out;
+	features = netif_skb_features(skb);
+	skb = validate_xmit_vlan(skb, features);
+	if (unlikely(!skb))
+		goto out_null;
 
-			skb->vlan_tci = 0;
-		}
+	/* If encapsulation offload request, verify we are testing
+	 * hardware encapsulation features instead of standard
+	 * features for the netdev
+	 */
+	if (skb->encapsulation)
+		features &= dev->hw_enc_features;
 
-		/* If encapsulation offload request, verify we are testing
-		 * hardware encapsulation features instead of standard
-		 * features for the netdev
-		 */
-		if (skb->encapsulation)
-			features &= dev->hw_enc_features;
+	if (netif_needs_gso(skb, features)) {
+		if (unlikely(dev_gso_segment(skb, features)))
+			goto out_kfree_skb;
+	} else {
+		if (skb_needs_linearize(skb, features) &&
+		    __skb_linearize(skb))
+			goto out_kfree_skb;
 
-		if (netif_needs_gso(skb, features)) {
-			if (unlikely(dev_gso_segment(skb, features)))
-				goto out_kfree_skb;
-			if (skb->next)
-				goto gso;
-		} else {
-			if (skb_needs_linearize(skb, features) &&
-			    __skb_linearize(skb))
+		/* If packet is not checksummed and device does not
+		 * support checksumming for this protocol, complete
+		 * checksumming here.
+		 */
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			if (skb->encapsulation)
+				skb_set_inner_transport_header(skb,
+							       skb_checksum_start_offset(skb));
+			else
+				skb_set_transport_header(skb,
+							 skb_checksum_start_offset(skb));
+			if (!(features & NETIF_F_ALL_CSUM) &&
+			    skb_checksum_help(skb))
 				goto out_kfree_skb;
-
-			/* If packet is not checksummed and device does not
-			 * support checksumming for this protocol, complete
-			 * checksumming here.
-			 */
-			if (skb->ip_summed == CHECKSUM_PARTIAL) {
-				if (skb->encapsulation)
-					skb_set_inner_transport_header(skb,
-						skb_checksum_start_offset(skb));
-				else
-					skb_set_transport_header(skb,
-						skb_checksum_start_offset(skb));
-				if (!(features & NETIF_F_ALL_CSUM) &&
-				     skb_checksum_help(skb))
-					goto out_kfree_skb;
-			}
 		}
+	}
+
+	return skb;
+
+out_kfree_skb:
+	kfree_skb(skb);
+out_null:
+	return NULL;
+}
+
+int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
+			struct netdev_queue *txq)
+{
+	int rc = NETDEV_TX_OK;
+
+	skb = validate_xmit_skb(skb, dev);
+	if (!skb)
+		return rc;
 
+	if (likely(!skb->next))
 		return xmit_one(skb, dev, txq, false);
-	}
 
-gso:
 	skb->next = xmit_list(skb->next, dev, txq, &rc);
 	if (likely(skb->next == NULL)) {
 		skb->destructor = DEV_GSO_CB(skb)->destructor;
 		consume_skb(skb);
 		return rc;
 	}
-out_kfree_skb:
+
 	kfree_skb(skb);
-out:
+
 	return rc;
 }
 EXPORT_SYMBOL_GPL(dev_hard_start_xmit);
-- 
1.7.11.7
