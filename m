From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/9] net: Move main gso loop out of dev_hard_start_xmit()
 into helper.
Date: Mon, 01 Sep 2014 15:24:50 -0700 (PDT)
Message-ID: <20140901.152450.815155429225102019.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529AbaIAWYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 18:24:50 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 71DD9590970
	for <netdev@vger.kernel.org>; Mon,  1 Sep 2014 15:24:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There is a slight policy change happening here as well.

The previous code would drop the entire rest of the GSO skb if any of
them got, for example, a congestion notification.

That makes no sense, anything NET_XMIT_MASK and below is something
like congestion or policing.  And in the congestion case it doesn't
even mean the packet was actually dropped.

Just continue until dev_xmit_complete() evaluates to false.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dev.c | 48 +++++++++++++++++++++++++++++-------------------
 1 file changed, 29 insertions(+), 19 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 0fde7d2..ab7bb80 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2616,6 +2616,34 @@ static int xmit_one(struct sk_buff *skb, struct net_device *dev,
 	return rc;
 }
 
+static struct sk_buff *xmit_list(struct sk_buff *first, struct net_device *dev,
+				 struct netdev_queue *txq, int *ret)
+{
+	struct sk_buff *skb = first;
+	int rc = NETDEV_TX_OK;
+
+	while (skb) {
+		struct sk_buff *next = skb->next;
+
+		skb->next = NULL;
+		rc = xmit_one(skb, dev, txq);
+		if (unlikely(!dev_xmit_complete(rc))) {
+			skb->next = next;
+			goto out;
+		}
+
+		skb = next;
+		if (netif_xmit_stopped(txq) && skb) {
+			rc = NETDEV_TX_BUSY;
+			break;
+		}
+	}
+
+out:
+	*ret = rc;
+	return skb;
+}
+
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq)
 {
@@ -2681,25 +2709,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 	}
 
 gso:
-	do {
-		struct sk_buff *nskb = skb->next;
-
-		skb->next = nskb->next;
-		nskb->next = NULL;
-
-		rc = xmit_one(nskb, dev, txq);
-		if (unlikely(rc != NETDEV_TX_OK)) {
-			if (rc & ~NETDEV_TX_MASK)
-				goto out_kfree_gso_skb;
-			nskb->next = skb->next;
-			skb->next = nskb;
-			return rc;
-		}
-		if (unlikely(netif_xmit_stopped(txq) && skb->next))
-			return NETDEV_TX_BUSY;
-	} while (skb->next);
-
-out_kfree_gso_skb:
+	skb->next = xmit_list(skb->next, dev, txq, &rc);
 	if (likely(skb->next == NULL)) {
 		skb->destructor = DEV_GSO_CB(skb)->destructor;
 		consume_skb(skb);
-- 
1.7.11.7
