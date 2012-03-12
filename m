From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next 8/8] bnx2x: code doesn't use stats for allocating Rx
 BDs
Date: Mon, 12 Mar 2012 14:53:14 -0400
Message-ID: <1331578394-1153-9-git-send-email-yuvalmin@broadcom.com>
References: <1331578394-1153-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1168 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754697Ab2CLL7h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 07:59:37 -0400
In-Reply-To: <1331578394-1153-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Previously, allocation used queue statistics directly in its calcualtion.
This change causes these calculations to be summed into the statistics,
without being affected by them.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 33aa7de..85a1c5d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -1143,7 +1143,7 @@ static inline int bnx2x_alloc_rx_bds(struct bnx2x_fastpath *fp,
 {
 	struct bnx2x *bp = fp->bp;
 	u16 ring_prod, cqe_ring_prod;
-	int i;
+	int i, failure_cnt = 0;
 
 	fp->rx_comp_cons = 0;
 	cqe_ring_prod = ring_prod = 0;
@@ -1153,18 +1153,17 @@ static inline int bnx2x_alloc_rx_bds(struct bnx2x_fastpath *fp,
 	 */
 	for (i = 0; i < rx_ring_size; i++) {
 		if (bnx2x_alloc_rx_data(bp, fp, ring_prod) < 0) {
-			fp->eth_q_stats.rx_skb_alloc_failed++;
+			failure_cnt++;
 			continue;
 		}
 		ring_prod = NEXT_RX_IDX(ring_prod);
 		cqe_ring_prod = NEXT_RCQ_IDX(cqe_ring_prod);
-		WARN_ON(ring_prod <= (i - fp->eth_q_stats.rx_skb_alloc_failed));
+		WARN_ON(ring_prod <= (i - failure_cnt));
 	}
 
-	if (fp->eth_q_stats.rx_skb_alloc_failed)
-		BNX2X_ERR("was only able to allocate "
-			  "%d rx skbs on queue[%d]\n",
-			  (i - fp->eth_q_stats.rx_skb_alloc_failed), fp->index);
+	if (failure_cnt)
+		BNX2X_ERR("was only able to allocate %d rx skbs on queue[%d]\n",
+			  i - failure_cnt, fp->index);
 
 	fp->rx_bd_prod = ring_prod;
 	/* Limit the CQE producer by the CQE ring size */
@@ -1172,7 +1171,9 @@ static inline int bnx2x_alloc_rx_bds(struct bnx2x_fastpath *fp,
 			       cqe_ring_prod);
 	fp->rx_pkt = fp->rx_calls = 0;
 
-	return i - fp->eth_q_stats.rx_skb_alloc_failed;
+	fp->eth_q_stats.rx_skb_alloc_failed += failure_cnt;
+
+	return i - failure_cnt;
 }
 
 /* Statistics ID are global per chip/path, while Client IDs for E1x are per
-- 
1.7.9.rc2
