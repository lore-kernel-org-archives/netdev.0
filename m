From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/2] bnx2x: Support for RX queue weights
Date: Fri, 11 Feb 2011 16:00:53 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1102111552350.2790@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, eilong@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:36517 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758081Ab1BLAA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 19:00:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Apply relative weights to populate the RSS indirection table.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/bnx2x/bnx2x_main.c |   76 +++++++++++++++++++++++++++++++++++----
 1 files changed, 68 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index c238c4d..3fb83ee 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -4257,18 +4257,65 @@ static void bnx2x_init_eq_ring(struct bnx2x *bp)
 static void bnx2x_init_ind_table(struct bnx2x *bp)
 {
 	int func = BP_FUNC(bp);
-	int i;
+	int i, j, num_queues, slots;
+	int index = 0, max_weight_queue = 0;
+	u32 weight, max_weight = 0;
+	u64 frac = 0, sum = 0;
 
 	if (bp->multi_mode == ETH_RSS_MODE_DISABLED)
 		return;
 
-	DP(NETIF_MSG_IFUP,
-	   "Initializing indirection table  multi_mode %d\n", bp->multi_mode);
-	for (i = 0; i < TSTORM_INDIRECTION_TABLE_SIZE; i++)
-		REG_WR8(bp, BAR_TSTRORM_INTMEM +
-			TSTORM_INDIRECTION_TABLE_OFFSET(func) + i,
-			bp->fp->cl_id + (i % (bp->num_queues -
-				NONE_ETH_CONTEXT_USE)));
+	num_queues = bp->num_queues - NONE_ETH_CONTEXT_USE;
+	for (i = 0; i < num_queues; i++)
+		sum += netdev_rxq_weight(bp->dev, i);
+
+	if (!sum) {
+		/* All weights zero.  Just apply equal weighting */
+		for (i = 0; i < TSTORM_INDIRECTION_TABLE_SIZE; i++)
+			REG_WR8(bp, BAR_TSTRORM_INTMEM +
+			    TSTORM_INDIRECTION_TABLE_OFFSET(func) + i,
+			    bp->fp->cl_id + (i % (bp->num_queues -
+			    NONE_ETH_CONTEXT_USE)));
+	} else {
+		/*
+		 * For each queue, compute number of slots to allocate
+		 * based on the relative weights.  This is essentially:
+		 *
+		 * num_slots = (weight / sum_of_weights) * table_size + frac
+		 *
+		 * frac is the fraction carried over from the previous
+		 * queue's calculation.  At the end if there's any fraction
+		 * remaining, the queue with highest weight is assigned to the
+		 * last slot.
+		 *
+		 * This algorithm should result in all slots always being
+		 * set.  Note that this recomputes the whole table after
+		 * each weight change, this should not be an issue if this
+		 * operation is fairly rare.
+		 */
+		for (i = 0; i < bp->num_queues; i++) {
+			weight = netdev_rxq_weight(bp->dev, i);
+			if (weight > max_weight) {
+				max_weight = weight;
+				max_weight_queue = i;
+			}
+			frac = (((u64)weight << 32) / sum) *
+			    TSTORM_INDIRECTION_TABLE_SIZE + frac;
+			slots = frac >> 32;
+			frac -= (u64)slots << 32;
+			for (j = 0; j < slots; j++, index++)
+				REG_WR8(bp, BAR_TSTRORM_INTMEM +
+					TSTORM_INDIRECTION_TABLE_OFFSET(func) +
+					index, bp->fp->cl_id + i);
+		}
+		if (frac) {
+			REG_WR8(bp, BAR_TSTRORM_INTMEM +
+				TSTORM_INDIRECTION_TABLE_OFFSET(func) + index,
+				bp->fp->cl_id + max_weight_queue);
+			index++;
+		}
+		BUG_ON(index != TSTORM_INDIRECTION_TABLE_SIZE);
+	}
 }
 
 void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
@@ -9278,6 +9325,16 @@ static void poll_bnx2x(struct net_device *dev)
 }
 #endif
 
+#ifdef CONFIG_RPS
+void bnx2x_set_rxq_weight(struct net_device *dev, u16 rxq, u32 weight)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+
+	/* Reinitialize the whole table */
+	bnx2x_init_ind_table(bp);
+}
+#endif
+
 static const struct net_device_ops bnx2x_netdev_ops = {
 	.ndo_open		= bnx2x_open,
 	.ndo_stop		= bnx2x_close,
@@ -9292,6 +9349,9 @@ static const struct net_device_ops bnx2x_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= poll_bnx2x,
 #endif
+#ifdef CONFIG_RPS
+	.ndo_set_rxq_weight	= bnx2x_set_rxq_weight,
+#endif
 };
 
 static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
-- 
1.7.3.1

