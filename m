From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [net-next PATCH] bnx2x: Set RXHASH for LRO packets
Date: Tue, 6 Jul 2010 17:09:43 +0300
Message-ID: <1278425383.22257.4.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Eilon Greenstein" <eilong@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1199 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752766Ab0GFOJz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jul 2010 10:09:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set Toeplitz hash both for LRO and none-LRO skbs.
The first CQE (TPA_START) will contain a hash for an LRO packet.

Current code sets skb->rx_hash for none-LRO skbs only.

 Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
 Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   28 +++++++++++++++++++++-------
 1 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 57ff5b3..a868e4a 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1545,6 +1545,20 @@ static inline void bnx2x_update_rx_prod(struct bnx2x *bp,
 	   fp->index, bd_prod, rx_comp_prod, rx_sge_prod);
 }
 
+/* Set Toeplitz hash value in the skb using the value from the
+ * CQE (calculated by HW).
+ */
+static inline void bnx2x_set_skb_rxhash(struct bnx2x *bp, union eth_rx_cqe *cqe,
+					struct sk_buff *skb)
+{
+	/* Set Toeplitz hash from CQE */
+	if ((bp->dev->features & NETIF_F_RXHASH) &&
+	    (cqe->fast_path_cqe.status_flags &
+	     ETH_FAST_PATH_RX_CQE_RSS_HASH_FLG))
+		skb->rxhash =
+		le32_to_cpu(cqe->fast_path_cqe.rss_hash_result);
+}
+
 static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 {
 	struct bnx2x *bp = fp->bp;
@@ -1582,7 +1596,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 		struct sw_rx_bd *rx_buf = NULL;
 		struct sk_buff *skb;
 		union eth_rx_cqe *cqe;
-		u8 cqe_fp_flags, cqe_fp_status_flags;
+		u8 cqe_fp_flags;
 		u16 len, pad;
 
 		comp_ring_cons = RCQ_BD(sw_comp_cons);
@@ -1598,7 +1612,6 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 
 		cqe = &fp->rx_comp_ring[comp_ring_cons];
 		cqe_fp_flags = cqe->fast_path_cqe.type_error_flags;
-		cqe_fp_status_flags = cqe->fast_path_cqe.status_flags;
 
 		DP(NETIF_MSG_RX_STATUS, "CQE type %x  err %x  status %x"
 		   "  queue %x  vlan %x  len %u\n", CQE_TYPE(cqe_fp_flags),
@@ -1634,6 +1647,10 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 
 					bnx2x_tpa_start(fp, queue, skb,
 							bd_cons, bd_prod);
+
+					/* Set Toeplitz hash for an LRO skb */
+					bnx2x_set_skb_rxhash(bp, cqe, skb);
+
 					goto next_rx;
 				}
 
@@ -1726,11 +1743,8 @@ reuse_rx:
 
 			skb->protocol = eth_type_trans(skb, bp->dev);
 
-			if ((bp->dev->features & NETIF_F_RXHASH) &&
-			    (cqe_fp_status_flags &
-			     ETH_FAST_PATH_RX_CQE_RSS_HASH_FLG))
-				skb->rxhash = le32_to_cpu(
-				    cqe->fast_path_cqe.rss_hash_result);
+			/* Set Toeplitz hash for a none-LRO skb */
+			bnx2x_set_skb_rxhash(bp, cqe, skb);
 
 			skb->ip_summed = CHECKSUM_NONE;
 			if (bp->rx_csum) {
-- 
1.7.0.4




