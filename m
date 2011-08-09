From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net 2/5] bnx2x: fix select_queue when FCoE is disabled
Date: Tue, 9 Aug 2011 16:08:55 +0300
Message-ID: <1312895335.21856.1.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Vladislav Zolotarov" <vladz@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3438 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751998Ab1HINON (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Aug 2011 09:14:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Zolotarov <vladz@broadcom.com>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |   30 +++++++++++++++++++++++++-----
 1 files changed, 25 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 64df0ef..37e5790 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -1405,10 +1405,9 @@ void bnx2x_netif_stop(struct bnx2x *bp, int disable_hw)
 u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
 	struct bnx2x *bp = netdev_priv(dev);
+
 #ifdef BCM_CNIC
-	if (NO_FCOE(bp))
-		return skb_tx_hash(dev, skb);
-	else {
+	if (!NO_FCOE(bp)) {
 		struct ethhdr *hdr = (struct ethhdr *)skb->data;
 		u16 ether_type = ntohs(hdr->h_proto);
 
@@ -1425,8 +1424,7 @@ u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb)
 			return bnx2x_fcoe_tx(bp, txq_index);
 	}
 #endif
-	/* Select a none-FCoE queue:  if FCoE is enabled, exclude FCoE L2 ring
-	 */
+	/* select a non-FCoE queue */
 	return __skb_tx_hash(dev, skb, BNX2X_NUM_ETH_QUEUES(bp));
 }
 
@@ -1449,6 +1447,28 @@ void bnx2x_set_num_queues(struct bnx2x *bp)
 	bp->num_queues += NON_ETH_CONTEXT_USE;
 }
 
+/**
+ * bnx2x_set_real_num_queues - configure netdev->real_num_[tx,rx]_queues
+ *
+ * @bp:		Driver handle
+ *
+ * We currently support for at most 16 Tx queues for each CoS thus we will
+ * allocate a multiple of 16 for ETH L2 rings according to the value of the
+ * bp->max_cos.
+ *
+ * If there is an FCoE L2 queue the appropriate Tx queue will have the next
+ * index after all ETH L2 indices.
+ *
+ * If the actual number of Tx queues (for each CoS) is less than 16 then there
+ * will be the holes at the end of each group of 16 ETh L2 indices (0..15,
+ * 16..31,...) with indicies that are not coupled with any real Tx queue.
+ *
+ * The proper configuration of skb->queue_mapping is handled by
+ * bnx2x_select_queue() and __skb_tx_hash().
+ *
+ * bnx2x_setup_tc() takes care of the proper TC mappings so that __skb_tx_hash()
+ * will return a proper Tx index if TC is enabled (netdev->num_tc > 0).
+ */
 static inline int bnx2x_set_real_num_queues(struct bnx2x *bp)
 {
 	int rc, tx, rx;
-- 
1.7.2.2




