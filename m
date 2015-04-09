From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 1/4] cxgb3/4/4vf: Update drivers to use dma_rmb/wmb
 where appropriate
Date: Wed, 08 Apr 2015 18:49:29 -0700
Message-ID: <20150409014929.4434.56993.stgit@ahduyck-vm-fedora22>
References: <20150409014001.4434.85280.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Santosh Raspatur <santosh@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	Hariprasad S <hariprasad@chelsio.com>, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41765 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753811AbbDIBtf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 21:49:35 -0400
In-Reply-To: <20150409014001.4434.85280.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the Chelsio Ethernet drivers to use the dma_rmb/wmb calls instead of
the full barriers in order to improve performance.

Cc: Santosh Raspatur <santosh@chelsio.com>
Cc: Hariprasad S <hariprasad@chelsio.com>
Cc: Casey Leedom <leedom@chelsio.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/chelsio/cxgb3/sge.c   |   20 ++++++++++----------
 drivers/net/ethernet/chelsio/cxgb4/sge.c   |    4 ++--
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c |    4 ++--
 3 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/sge.c b/drivers/net/ethernet/chelsio/cxgb3/sge.c
index d6aa602f168d..e4b5b057f417 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/sge.c
@@ -422,7 +422,7 @@ static inline int add_one_rx_buf(void *va, unsigned int len,
 
 	d->addr_lo = cpu_to_be32(mapping);
 	d->addr_hi = cpu_to_be32((u64) mapping >> 32);
-	wmb();
+	dma_wmb();
 	d->len_gen = cpu_to_be32(V_FLD_GEN1(gen));
 	d->gen2 = cpu_to_be32(V_FLD_GEN2(gen));
 	return 0;
@@ -433,7 +433,7 @@ static inline int add_one_rx_chunk(dma_addr_t mapping, struct rx_desc *d,
 {
 	d->addr_lo = cpu_to_be32(mapping);
 	d->addr_hi = cpu_to_be32((u64) mapping >> 32);
-	wmb();
+	dma_wmb();
 	d->len_gen = cpu_to_be32(V_FLD_GEN1(gen));
 	d->gen2 = cpu_to_be32(V_FLD_GEN2(gen));
 	return 0;
@@ -579,7 +579,7 @@ static void recycle_rx_buf(struct adapter *adap, struct sge_fl *q,
 	q->sdesc[q->pidx] = q->sdesc[idx];
 	to->addr_lo = from->addr_lo;	/* already big endian */
 	to->addr_hi = from->addr_hi;	/* likewise */
-	wmb();
+	dma_wmb();
 	to->len_gen = cpu_to_be32(V_FLD_GEN1(q->gen));
 	to->gen2 = cpu_to_be32(V_FLD_GEN2(q->gen));
 
@@ -1068,7 +1068,7 @@ static void write_wr_hdr_sgl(unsigned int ndesc, struct sk_buff *skb,
 		sd->eop = 1;
 		wrp->wr_hi = htonl(F_WR_SOP | F_WR_EOP | V_WR_DATATYPE(1) |
 				   V_WR_SGLSFLT(flits)) | wr_hi;
-		wmb();
+		dma_wmb();
 		wrp->wr_lo = htonl(V_WR_LEN(flits + sgl_flits) |
 				   V_WR_GEN(gen)) | wr_lo;
 		wr_gen2(d, gen);
@@ -1114,7 +1114,7 @@ static void write_wr_hdr_sgl(unsigned int ndesc, struct sk_buff *skb,
 		}
 		sd->eop = 1;
 		wrp->wr_hi |= htonl(F_WR_EOP);
-		wmb();
+		dma_wmb();
 		wp->wr_lo = htonl(V_WR_LEN(WR_FLITS) | V_WR_GEN(ogen)) | wr_lo;
 		wr_gen2((struct tx_desc *)wp, ogen);
 		WARN_ON(ndesc != 0);
@@ -1184,7 +1184,7 @@ static void write_tx_pkt_wr(struct adapter *adap, struct sk_buff *skb,
 			cpl->wr.wr_hi = htonl(V_WR_BCNTLFLT(skb->len & 7) |
 					      V_WR_OP(FW_WROPCODE_TUNNEL_TX_PKT)
 					      | F_WR_SOP | F_WR_EOP | compl);
-			wmb();
+			dma_wmb();
 			cpl->wr.wr_lo = htonl(V_WR_LEN(flits) | V_WR_GEN(gen) |
 					      V_WR_TID(q->token));
 			wr_gen2(d, gen);
@@ -1342,7 +1342,7 @@ static inline void write_imm(struct tx_desc *d, struct sk_buff *skb,
 
 	to->wr_hi = from->wr_hi | htonl(F_WR_SOP | F_WR_EOP |
 					V_WR_BCNTLFLT(len & 7));
-	wmb();
+	dma_wmb();
 	to->wr_lo = from->wr_lo | htonl(V_WR_GEN(gen) |
 					V_WR_LEN((len + 7) / 8));
 	wr_gen2(d, gen);
@@ -2271,7 +2271,7 @@ static int process_responses(struct adapter *adap, struct sge_qset *qs,
 		u32 len, flags;
 		__be32 rss_hi, rss_lo;
 
-		rmb();
+		dma_rmb();
 		eth = r->rss_hdr.opcode == CPL_RX_PKT;
 		rss_hi = *(const __be32 *)r;
 		rss_lo = r->rss_hdr.rss_hash_val;
@@ -2488,7 +2488,7 @@ static int process_pure_responses(struct adapter *adap, struct sge_qset *qs,
 		}
 		if (!is_new_response(r, q))
 			break;
-		rmb();
+		dma_rmb();
 	} while (is_pure_response(r));
 
 	if (sleeping)
@@ -2523,7 +2523,7 @@ static inline int handle_responses(struct adapter *adap, struct sge_rspq *q)
 
 	if (!is_new_response(r, q))
 		return -1;
-	rmb();
+	dma_rmb();
 	if (is_pure_response(r) && process_pure_responses(adap, qs, r) == 0) {
 		t3_write_reg(adap, A_SG_GTS, V_RSPQ(q->cntxt_id) |
 			     V_NEWTIMER(q->holdoff_tmr) | V_NEWINDEX(q->cidx));
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index c438f3895c40..e622214e2eca 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1968,7 +1968,7 @@ static int process_responses(struct sge_rspq *q, int budget)
 		if (!is_new_response(rc, q))
 			break;
 
-		rmb();
+		dma_rmb();
 		rsp_type = RSPD_TYPE(rc->type_gen);
 		if (likely(rsp_type == RSP_TYPE_FLBUF)) {
 			struct page_frag *fp;
@@ -2160,7 +2160,7 @@ static unsigned int process_intrq(struct adapter *adap)
 		if (!is_new_response(rc, q))
 			break;
 
-		rmb();
+		dma_rmb();
 		if (RSPD_TYPE(rc->type_gen) == RSP_TYPE_INTR) {
 			unsigned int qid = ntohl(rc->pldbuflen_qid);
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 7715982230e5..482f6de6817d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -1751,7 +1751,7 @@ static int process_responses(struct sge_rspq *rspq, int budget)
 		 * Figure out what kind of response we've received from the
 		 * SGE.
 		 */
-		rmb();
+		dma_rmb();
 		rsp_type = RSPD_TYPE(rc->type_gen);
 		if (likely(rsp_type == RSP_TYPE_FLBUF)) {
 			struct page_frag *fp;
@@ -1935,7 +1935,7 @@ static unsigned int process_intrq(struct adapter *adapter)
 		 * error and go on to the next response message.  This should
 		 * never happen ...
 		 */
-		rmb();
+		dma_rmb();
 		if (unlikely(RSPD_TYPE(rc->type_gen) != RSP_TYPE_INTR)) {
 			dev_err(adapter->pdev_dev,
 				"Unexpected INTRQ response type %d\n",
