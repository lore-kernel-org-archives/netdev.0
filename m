From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch 2/2 v2 -next] cxgb4: clean up a type issue
Date: Wed, 8 Oct 2014 16:44:34 +0300
Message-ID: <20141008134434.GB12036@mwanda>
References: <20141003.154629.555967384624529643.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Hariprasad S <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:24833 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756138AbaJHNo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 09:44:58 -0400
Content-Disposition: inline
In-Reply-To: <20141003.154629.555967384624529643.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tx_desc struct holds 8 __be64 values.  The original code in
ring_tx_db() took a tx_desc pointer then casted it to an int pointer and
then casted it to a u64 pointer.  It was confusing and triggered some
static checker warnings.

I have changed the cxgb_pio_copy() function to only take tx_desc
pointers.  This isn't really a loss of flexibility because anything else
was buggy to begin with.

I also removed the casting on the destination pointer since that was
unnecessary and a bit messy.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
v2: More cleanups as suggested by David Laight.
    Update cxgb_pio_copy() comments.

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index e8e90ce..fab4c84 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -850,13 +850,14 @@ static void write_sgl(const struct sk_buff *skb, struct sge_txq *q,
 		*end = 0;
 }
 
-/* This function copies 64 byte coalesced work request to
- * memory mapped BAR2 space(user space writes).
- * For coalesced WR SGE, fetches data from the FIFO instead of from Host.
+/* This function copies a tx_desc struct to memory mapped BAR2 space(user space
+ * writes). For coalesced WR SGE, fetches data from the FIFO instead of from
+ * Host.
  */
-static void cxgb_pio_copy(u64 __iomem *dst, u64 *src)
+static void cxgb_pio_copy(u64 __iomem *dst, struct tx_desc *desc)
 {
-	int count = 8;
+	int count = sizeof(*desc) / sizeof(u64);
+	u64 *src = (u64 *)desc;
 
 	while (count) {
 		writeq(*src, dst);
@@ -914,12 +915,9 @@ static inline void ring_tx_db(struct adapter *adap, struct sge_txq *q, int n)
 			int index = (q->pidx
 				     ? (q->pidx - 1)
 				     : (q->size - 1));
-			unsigned int *wr = (unsigned int *)&q->desc[index];
 
-			cxgb_pio_copy((u64 __iomem *)
-				      (adap->bar2 + q->udb +
-				       SGE_UDB_WCDOORBELL),
-				      (u64 *)wr);
+			cxgb_pio_copy(adap->bar2 + q->udb + SGE_UDB_WCDOORBELL,
+				      q->desc + index);
 		} else {
 			writel(val,  adap->bar2 + q->udb + SGE_UDB_KDOORBELL);
 		}
