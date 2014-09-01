From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/9] net: Create xmit_one() helper for dev_hard_start_xmit()
Date: Mon, 01 Sep 2014 15:24:44 -0700 (PDT)
Message-ID: <20140901.152444.1620902244307728314.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44723 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529AbaIAWYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 18:24:45 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id E844F58FF4D
	for <netdev@vger.kernel.org>; Mon,  1 Sep 2014 15:24:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hopefully making the code a bit easier to read and digest.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dev.c | 35 +++++++++++++++++++----------------
 1 file changed, 19 insertions(+), 16 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6392ada..0fde7d2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2599,11 +2599,27 @@ netdev_features_t netif_skb_features(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(netif_skb_features);
 
+static int xmit_one(struct sk_buff *skb, struct net_device *dev,
+		    struct netdev_queue *txq)
+{
+	unsigned int len;
+	int rc;
+
+	if (!list_empty(&ptype_all))
+		dev_queue_xmit_nit(skb, dev);
+
+	len = skb->len;
+	trace_net_dev_start_xmit(skb, dev);
+	rc = netdev_start_xmit(skb, dev, txq);
+	trace_net_dev_xmit(skb, rc, dev, len);
+
+	return rc;
+}
+
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq)
 {
 	int rc = NETDEV_TX_OK;
-	unsigned int skb_len;
 
 	if (likely(!skb->next)) {
 		netdev_features_t features;
@@ -2661,14 +2677,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			}
 		}
 
-		if (!list_empty(&ptype_all))
-			dev_queue_xmit_nit(skb, dev);
-
-		skb_len = skb->len;
-		trace_net_dev_start_xmit(skb, dev);
-		rc = netdev_start_xmit(skb, dev, txq);
-		trace_net_dev_xmit(skb, rc, dev, skb_len);
-		return rc;
+		return xmit_one(skb, dev, txq);
 	}
 
 gso:
@@ -2678,13 +2687,7 @@ gso:
 		skb->next = nskb->next;
 		nskb->next = NULL;
 
-		if (!list_empty(&ptype_all))
-			dev_queue_xmit_nit(nskb, dev);
-
-		skb_len = nskb->len;
-		trace_net_dev_start_xmit(nskb, dev);
-		rc = netdev_start_xmit(nskb, dev, txq);
-		trace_net_dev_xmit(nskb, rc, dev, skb_len);
+		rc = xmit_one(nskb, dev, txq);
 		if (unlikely(rc != NETDEV_TX_OK)) {
 			if (rc & ~NETDEV_TX_MASK)
 				goto out_kfree_gso_skb;
-- 
1.7.11.7
