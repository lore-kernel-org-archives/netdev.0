From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 1/2] bnx2x: Fix fastpath structures when memory
 allocation fails
Date: Thu, 10 Jan 2013 16:53:39 +0200
Message-ID: <1357829620-17890-2-git-send-email-yuvalmin@broadcom.com>
References: <1357829620-17890-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3157 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751847Ab3AJPv3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2013 10:51:29 -0500
In-Reply-To: <1357829620-17890-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When allocating Tx queues, if for some reason
(e.g., lack of memory) allocation fails, driver will incorrectly
calculate the pointers of the various queues.

This patch repositions all pointers in such a case to point at
sequential structures in memory, allowing the bnx2x macros to
be used correctly when accessing them.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   30 +++++++++++++++++++++-
 1 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 01588b6..f771ddf 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -80,12 +80,37 @@ static inline void bnx2x_move_fp(struct bnx2x *bp, int from, int to)
 		new_txdata_index = new_max_eth_txqs + FCOE_TXQ_IDX_OFFSET;
 	}
 
-	memcpy(&bp->bnx2x_txq[old_txdata_index],
-	       &bp->bnx2x_txq[new_txdata_index],
+	memcpy(&bp->bnx2x_txq[new_txdata_index],
+	       &bp->bnx2x_txq[old_txdata_index],
 	       sizeof(struct bnx2x_fp_txdata));
 	to_fp->txdata_ptr[0] = &bp->bnx2x_txq[new_txdata_index];
 }
 
+/**
+ * bnx2x_shrink_eth_fp - guarantees fastpath structures stay intact
+ *
+ * @bp:	driver handle
+ * @delta:	number of eth queues which were not allocated
+ */
+static void bnx2x_shrink_eth_fp(struct bnx2x *bp, int delta)
+{
+	int i, cos, old_eth_num = BNX2X_NUM_ETH_QUEUES(bp);
+
+	/* Queue pointer cannot be re-set on an fp-basis, as moving pointer
+	 * backward along the array could cause memory to be overriden
+	 */
+	for (cos = 1; cos < bp->max_cos; cos++) {
+		for (i = 0; i < old_eth_num - delta; i++) {
+			struct bnx2x_fastpath *fp = &bp->fp[i];
+			int new_idx = cos * (old_eth_num - delta) + i;
+
+			memcpy(&bp->bnx2x_txq[new_idx], fp->txdata_ptr[cos],
+			       sizeof(struct bnx2x_fp_txdata));
+			fp->txdata_ptr[cos] = &bp->bnx2x_txq[new_idx];
+		}
+	}
+}
+
 int load_count[2][3] = { {0} }; /* per-path: 0-common, 1-port0, 2-port1 */
 
 /* free skb in the packet ring at pos idx
@@ -3863,6 +3888,7 @@ int bnx2x_alloc_fp_mem(struct bnx2x *bp)
 		int delta = BNX2X_NUM_ETH_QUEUES(bp) - i;
 
 		WARN_ON(delta < 0);
+		bnx2x_shrink_eth_fp(bp, delta);
 		if (CNIC_SUPPORT(bp))
 			/* move non eth FPs next to last eth FP
 			 * must be done in that order
-- 
1.7.1
