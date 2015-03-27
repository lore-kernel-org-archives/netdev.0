From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net] cxgb4vf: Fix sparse warnings
Date: Fri, 27 Mar 2015 11:01:18 +0530
Message-ID: <1427434278-3582-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	swise@opengridcomputing.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:22054 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751483AbbC0FZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 01:25:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes sparse warnings introduced in commit e85c9a7abfa407ed ("cxgb4/cxgb4vf: Add
code to calculate T5 BAR2 Offsets for SGE Queue Registers") and
df64e4d38c904dd3 ("cxgb4/cxgb4vf: Use new interfaces to calculate BAR2 SGE Queue
Register addresses") and few old ones

sparse warnings:
>> drivers/net/ethernet/chelsio/cxgb4vf/sge.c:1006:48: sparse: cast removes
>> address space of expression
>> drivers/net/ethernet/chelsio/cxgb4vf/sge.c:1006:48: sparse: incorrect type in
>> initializer (different address space)
>> drivers/net/ethernet/chelsio/cxgb4vf/sge.c:1020:40: sparse: incorrect type in
>> argument 1 (different base types)

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c     |   12 ++++++++----
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c |    6 +++---
 2 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 5ba14b3..7715982 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -1004,7 +1004,7 @@ static inline void ring_tx_db(struct adapter *adapter, struct sge_txq *tq,
 					      ? (tq->pidx - 1)
 					      : (tq->size - 1));
 			__be64 *src = (__be64 *)&tq->desc[index];
-			__be64 __iomem *dst = (__be64 *)(tq->bar2_addr +
+			__be64 __iomem *dst = (__be64 __iomem *)(tq->bar2_addr +
 							 SGE_UDB_WCDOORBELL);
 			unsigned int count = EQ_UNIT / sizeof(__be64);
 
@@ -1018,7 +1018,11 @@ static inline void ring_tx_db(struct adapter *adapter, struct sge_txq *tq,
 			 * DMA.
 			 */
 			while (count) {
-				writeq(*src, dst);
+				/* the (__force u64) is because the compiler
+				 * doesn't understand the endian swizzling
+				 * going on
+				 */
+				writeq((__force u64)*src, dst);
 				src++;
 				dst++;
 				count--;
@@ -1252,8 +1256,8 @@ int t4vf_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	BUG_ON(DIV_ROUND_UP(ETHTXQ_MAX_HDR, TXD_PER_EQ_UNIT) > 1);
 	wr = (void *)&txq->q.desc[txq->q.pidx];
 	wr->equiq_to_len16 = cpu_to_be32(wr_mid);
-	wr->r3[0] = cpu_to_be64(0);
-	wr->r3[1] = cpu_to_be64(0);
+	wr->r3[0] = cpu_to_be32(0);
+	wr->r3[1] = cpu_to_be32(0);
 	skb_copy_from_linear_data(skb, (void *)wr->ethmacdst, fw_hdr_copy_len);
 	end = (u64 *)wr + flits;
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index c21e2e9..966ee90 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -210,10 +210,10 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 
 			if (rpl) {
 				/* request bit in high-order BE word */
-				WARN_ON((be32_to_cpu(*(const u32 *)cmd)
+				WARN_ON((be32_to_cpu(*(const __be32 *)cmd)
 					 & FW_CMD_REQUEST_F) == 0);
 				get_mbox_rpl(adapter, rpl, size, mbox_data);
-				WARN_ON((be32_to_cpu(*(u32 *)rpl)
+				WARN_ON((be32_to_cpu(*(__be32 *)rpl)
 					 & FW_CMD_REQUEST_F) != 0);
 			}
 			t4_write_reg(adapter, mbox_ctl,
@@ -484,7 +484,7 @@ int t4_bar2_sge_qregs(struct adapter *adapter,
 	 *  o The BAR2 Queue ID.
 	 *  o The BAR2 Queue ID Offset into the BAR2 page.
 	 */
-	bar2_page_offset = ((qid >> qpp_shift) << page_shift);
+	bar2_page_offset = ((u64)(qid >> qpp_shift) << page_shift);
 	bar2_qid = qid & qpp_mask;
 	bar2_qid_offset = bar2_qid * SGE_UDB_SIZE;
 
-- 
1.7.1
