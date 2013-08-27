From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 2/5] bnx2x: Fix move FP memory deallocations
Date: Wed, 28 Aug 2013 01:13:01 +0300
Message-ID: <1377641584-2939-3-git-send-email-yuvalmin@broadcom.com>
References: <1377641584-2939-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3463 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753843Ab3H0WNT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 18:13:19 -0400
In-Reply-To: <1377641584-2939-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If driver will fail to allocate all queues, it will shrink the number of
queues and move the storage queue to its correct place (i.e., the last
queue among the newly supported number).

When changing the pointers of the new location of the FCoE queue, we need
to pay special attention to the aggregations pointer - that memory is allocated
during probe and released upon driver removal. Current implementation has 2
pointers pointing to the same chunk of allocated memory, meaning upon removal
there will be two kfree() of the same chunk while the other won't be released.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index f2d1ff1..26b4dfc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -53,6 +53,7 @@ static inline void bnx2x_move_fp(struct bnx2x *bp, int from, int to)
 	struct bnx2x_fp_stats *to_fp_stats = &bp->fp_stats[to];
 	int old_max_eth_txqs, new_max_eth_txqs;
 	int old_txdata_index = 0, new_txdata_index = 0;
+	struct bnx2x_agg_info *old_tpa_info = to_fp->tpa_info;
 
 	/* Copy the NAPI object as it has been already initialized */
 	from_fp->napi = to_fp->napi;
@@ -61,6 +62,11 @@ static inline void bnx2x_move_fp(struct bnx2x *bp, int from, int to)
 	memcpy(to_fp, from_fp, sizeof(*to_fp));
 	to_fp->index = to;
 
+	/* Retain the tpa_info of the original `to' version as we don't want
+	 * 2 FPs to contain the same tpa_info pointer.
+	 */
+	to_fp->tpa_info = old_tpa_info;
+
 	/* move sp_objs contents as well, as their indices match fp ones */
 	memcpy(to_sp_objs, from_sp_objs, sizeof(*to_sp_objs));
 
-- 
1.8.1.227.g44fe835
