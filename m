From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 5/7] cxgb4: Deal with wrap-around of queue for Work request
Date: Tue,  8 Dec 2015 10:09:15 +0530
Message-ID: <1449549557-16023-6-git-send-email-hariprasad@chelsio.com>
References: <1449549557-16023-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:47068 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756124AbbLHEiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 23:38:19 -0500
In-Reply-To: <1449549557-16023-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The WR headers  may not fit within one descriptor.
So we need to deal with wrap-around here.

Based on original patch by Pranjal Joshi <pjoshi@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c | 57 +++++++++++++++++++++++++++++---
 1 file changed, 53 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index e1ff7d8..c72fe1e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1029,6 +1029,30 @@ static void inline_tx_skb(const struct sk_buff *skb, const struct sge_txq *q,
 		*p = 0;
 }
 
+static void *inline_tx_skb_header(const struct sk_buff *skb,
+				  const struct sge_txq *q,  void *pos,
+				  int length)
+{
+	u64 *p;
+	int left = (void *)q->stat - pos;
+
+	if (likely(length <= left)) {
+		memcpy(pos, skb->data, length);
+		pos += length;
+	} else {
+		memcpy(pos, skb->data, left);
+		memcpy(q->desc, skb->data + left, length - left);
+		pos = (void *)q->desc + (length - left);
+	}
+	/* 0-pad to multiple of 16 */
+	p = PTR_ALIGN(pos, 8);
+	if ((uintptr_t)p & 8) {
+		*p = 0;
+		return p + 1;
+	}
+	return p;
+}
+
 /*
  * Figure out what HW csum a packet wants and return the appropriate control
  * bits.
@@ -1561,9 +1585,11 @@ static void ofldtxq_stop(struct sge_ofld_txq *q, struct sk_buff *skb)
  */
 static void service_ofldq(struct sge_ofld_txq *q)
 {
-	u64 *pos;
+	u64 *pos, *before, *end;
 	int credits;
 	struct sk_buff *skb;
+	struct sge_txq *txq;
+	unsigned int left;
 	unsigned int written = 0;
 	unsigned int flits, ndesc;
 
@@ -1607,9 +1633,32 @@ static void service_ofldq(struct sge_ofld_txq *q)
 		} else {
 			int last_desc, hdr_len = skb_transport_offset(skb);
 
-			memcpy(pos, skb->data, hdr_len);
-			write_sgl(skb, &q->q, (void *)pos + hdr_len,
-				  pos + flits, hdr_len,
+			/* The WR headers  may not fit within one descriptor.
+			 * So we need to deal with wrap-around here.
+			 */
+			before = (u64 *)pos;
+			end = (u64 *)pos + flits;
+			txq = &q->q;
+			pos = (void *)inline_tx_skb_header(skb, &q->q,
+							   (void *)pos,
+							   hdr_len);
+			if (before > (u64 *)pos) {
+				left = (u8 *)end - (u8 *)txq->stat;
+				end = (void *)txq->desc + left;
+			}
+
+			/* If current position is already at the end of the
+			 * ofld queue, reset the current to point to
+			 * start of the queue and update the end ptr as well.
+			 */
+			if (pos == (u64 *)txq->stat) {
+				left = (u8 *)end - (u8 *)txq->stat;
+				end = (void *)txq->desc + left;
+				pos = (void *)txq->desc;
+			}
+
+			write_sgl(skb, &q->q, (void *)pos,
+				  end, hdr_len,
 				  (dma_addr_t *)skb->head);
 #ifdef CONFIG_NEED_DMA_MAP_STATE
 			skb->dev = q->adap->port[0];
-- 
2.3.4
