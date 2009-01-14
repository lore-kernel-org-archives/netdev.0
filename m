From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 03/34]bnx2x: Missing memory barriers
Date: Wed, 14 Jan 2009 18:42:47 +0200
Message-ID: <1231951368.11301.124.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2393 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762379AbZANQni (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:43:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While working on IA64, it became clear that the following memory barriers are
missing

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   28 ++++++++++++++++++++++++++--
 1 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index b8bc1a5..5a0a285 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1368,11 +1368,23 @@ static inline void bnx2x_update_rx_prod(struct bnx2x *bp,
 	rx_prods.cqe_prod = rx_comp_prod;
 	rx_prods.sge_prod = rx_sge_prod;
 
+	/*
+	 * Make sure that the BD and SGE data is updated before updating the
+	 * producers since FW might read the BD/SGE right after the producer
+	 * is updated.
+	 * This is only applicable for weak-ordered memory model archs such
+	 * as IA-64. The following barrier is also mandatory since FW will
+	 * assumes BDs must have buffers.
+	 */
+	wmb();
+
 	for (i = 0; i < sizeof(struct tstorm_eth_rx_producers)/4; i++)
 		REG_WR(bp, BAR_TSTRORM_INTMEM +
 		       TSTORM_RX_PRODS_OFFSET(BP_PORT(bp), FP_CL_ID(fp)) + i*4,
 		       ((u32 *)&rx_prods)[i]);
 
+	mmiowb(); /* keep prod updates ordered */
+
 	DP(NETIF_MSG_RX_STATUS,
 	   "Wrote: bd_prod %u  cqe_prod %u  sge_prod %u\n",
 	   bd_prod, rx_comp_prod, rx_sge_prod);
@@ -1593,7 +1605,6 @@ next_cqe:
 	/* Update producers */
 	bnx2x_update_rx_prod(bp, fp, bd_prod_fw, sw_comp_prod,
 			     fp->rx_sge_prod);
-	mmiowb(); /* keep prod updates ordered */
 
 	fp->rx_pkt += rx_pkt;
 	fp->rx_calls++;
@@ -8740,6 +8751,8 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 	tx_bd->general_data = ((UNICAST_ADDRESS <<
 				ETH_TX_BD_ETH_ADDR_TYPE_SHIFT) | 1);
 
+	wmb();
+
 	fp->hw_tx_prods->bds_prod =
 		cpu_to_le16(le16_to_cpu(fp->hw_tx_prods->bds_prod) + 1);
 	mb(); /* FW restriction: must not reorder writing nbd and packets */
@@ -8791,7 +8804,6 @@ test_loopback_rx_exit:
 	/* Update producers */
 	bnx2x_update_rx_prod(bp, fp, fp->rx_bd_prod, fp->rx_comp_prod,
 			     fp->rx_sge_prod);
-	mmiowb(); /* keep prod updates ordered */
 
 test_loopback_exit:
 	bp->link_params.loopback_mode = LOOPBACK_NONE;
@@ -9722,6 +9734,15 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	DP(NETIF_MSG_TX_QUEUED, "doorbell: nbd %d  bd %u\n", nbd, bd_prod);
 
+	/*
+	 * Make sure that the BD data is updated before updating the producer
+	 * since FW might read the BD right after the producer is updated.
+	 * This is only applicable for weak-ordered memory model archs such
+	 * as IA-64. The following barrier is also mandatory since FW will
+	 * assumes packets must have BDs.
+	 */
+	wmb();
+
 	fp->hw_tx_prods->bds_prod =
 		cpu_to_le16(le16_to_cpu(fp->hw_tx_prods->bds_prod) + nbd);
 	mb(); /* FW restriction: must not reorder writing nbd and packets */
@@ -9735,6 +9756,9 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->trans_start = jiffies;
 
 	if (unlikely(bnx2x_tx_avail(fp) < MAX_SKB_FRAGS + 3)) {
+		/* We want bnx2x_tx_int to "see" the updated tx_bd_prod
+		   if we put Tx into XOFF state. */
+		smp_mb();
 		netif_stop_queue(dev);
 		bp->eth_stats.driver_xoff++;
 		if (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3)
-- 
1.5.4.3




