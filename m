From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 6/9] cxgb3 - fix interaction with pktgen
Date: Fri, 16 Nov 2007 11:22:05 -0800
Message-ID: <20071116192205.31115.1659.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com,
	wenxiong@us.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:18109 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757951AbXKPTWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 14:22:10 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Do not use skb->cb to stash unmap info,
save the info to the descriptor state.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/sge.c |   82 +++++++++++++++++++++++------------------------
 1 files changed, 40 insertions(+), 42 deletions(-)

diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index c15e43a..7b13d8a 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -91,6 +91,10 @@ struct rx_desc {
 
 struct tx_sw_desc {		/* SW state per Tx descriptor */
 	struct sk_buff *skb;
+	u8 eop;       /* set if last descriptor for packet */
+	u8 addr_idx;  /* buffer index of first SGL entry in descriptor */
+	u8 fragidx;   /* first page fragment associated with descriptor */
+	s8 sflit;     /* start flit of first SGL entry in descriptor */
 };
 
 struct rx_sw_desc {                /* SW state per Rx descriptor */
@@ -109,13 +113,6 @@ struct rsp_desc {		/* response queue descriptor */
 	u8 intr_gen;
 };
 
-struct unmap_info {		/* packet unmapping info, overlays skb->cb */
-	int sflit;		/* start flit of first SGL entry in Tx descriptor */
-	u16 fragidx;		/* first page fragment in current Tx descriptor */
-	u16 addr_idx;		/* buffer index of first SGL entry in descriptor */
-	u32 len;		/* mapped length of skb main body */
-};
-
 /*
  * Holds unmapping information for Tx packets that need deferred unmapping.
  * This structure lives at skb->head and must be allocated by callers.
@@ -209,32 +206,36 @@ static inline int need_skb_unmap(void)
  *
  *	Unmap the main body of an sk_buff and its page fragments, if any.
  *	Because of the fairly complicated structure of our SGLs and the desire
- *	to conserve space for metadata, we keep the information necessary to
- *	unmap an sk_buff partly in the sk_buff itself (in its cb), and partly
- *	in the Tx descriptors (the physical addresses of the various data
- *	buffers).  The send functions initialize the state in skb->cb so we
- *	can unmap the buffers held in the first Tx descriptor here, and we
- *	have enough information at this point to update the state for the next
- *	Tx descriptor.
+ *	to conserve space for metadata, the information necessary to unmap an
+ *	sk_buff is spread across the sk_buff itself (buffer lengths), the HW Tx
+ *	descriptors (the physical addresses of the various data buffers), and
+ *	the SW descriptor state (assorted indices).  The send functions
+ *	initialize the indices for the first packet descriptor so we can unmap
+ *	the buffers held in the first Tx descriptor here, and we have enough
+ *	information at this point to set the state for the next Tx descriptor.
+ *
+ *	Note that it is possible to clean up the first descriptor of a packet
+ *	before the send routines have written the next descriptors, but this
+ *	race does not cause any problem.  We just end up writing the unmapping
+ *	info for the descriptor first.
  */
 static inline void unmap_skb(struct sk_buff *skb, struct sge_txq *q,
 			     unsigned int cidx, struct pci_dev *pdev)
 {
 	const struct sg_ent *sgp;
-	struct unmap_info *ui = (struct unmap_info *)skb->cb;
-	int nfrags, frag_idx, curflit, j = ui->addr_idx;
+	struct tx_sw_desc *d = &q->sdesc[cidx];
+	int nfrags, frag_idx, curflit, j = d->addr_idx;
 
-	sgp = (struct sg_ent *)&q->desc[cidx].flit[ui->sflit];
+	sgp = (struct sg_ent *)&q->desc[cidx].flit[d->sflit];
+	frag_idx = d->fragidx;
 
-	if (ui->len) {
-		pci_unmap_single(pdev, be64_to_cpu(sgp->addr[0]), ui->len,
-				 PCI_DMA_TODEVICE);
-		ui->len = 0;	/* so we know for next descriptor for this skb */
+	if (frag_idx == 0 && skb_headlen(skb)) {
+		pci_unmap_single(pdev, be64_to_cpu(sgp->addr[0]),
+				 skb_headlen(skb), PCI_DMA_TODEVICE);
 		j = 1;
 	}
 
-	frag_idx = ui->fragidx;
-	curflit = ui->sflit + 1 + j;
+	curflit = d->sflit + 1 + j;
 	nfrags = skb_shinfo(skb)->nr_frags;
 
 	while (frag_idx < nfrags && curflit < WR_FLITS) {
@@ -250,10 +251,11 @@ static inline void unmap_skb(struct sk_buff *skb, struct sge_txq *q,
 		frag_idx++;
 	}
 
-	if (frag_idx < nfrags) {	/* SGL continues into next Tx descriptor */
-		ui->fragidx = frag_idx;
-		ui->addr_idx = j;
-		ui->sflit = curflit - WR_FLITS - j;	/* sflit can be -1 */
+	if (frag_idx < nfrags) {   /* SGL continues into next Tx descriptor */
+		d = cidx + 1 == q->size ? q->sdesc : d + 1;
+		d->fragidx = frag_idx;
+		d->addr_idx = j;
+		d->sflit = curflit - WR_FLITS - j; /* sflit can be -1 */
 	}
 }
 
@@ -281,7 +283,7 @@ static void free_tx_desc(struct adapter *adapter, struct sge_txq *q,
 		if (d->skb) {	/* an SGL is present */
 			if (need_unmap)
 				unmap_skb(d->skb, q, cidx, pdev);
-			if (d->skb->priority == cidx)
+			if (d->eop)
 				kfree_skb(d->skb);
 		}
 		++d;
@@ -912,15 +914,13 @@ static void write_wr_hdr_sgl(unsigned int ndesc, struct sk_buff *skb,
 
 	sd->skb = skb;
 	if (need_skb_unmap()) {
-		struct unmap_info *ui = (struct unmap_info *)skb->cb;
-
-		ui->fragidx = 0;
-		ui->addr_idx = 0;
-		ui->sflit = flits;
+		sd->fragidx = 0;
+		sd->addr_idx = 0;
+		sd->sflit = flits;
 	}
 
 	if (likely(ndesc == 1)) {
-		skb->priority = pidx;
+		sd->eop = 1;
 		wrp->wr_hi = htonl(F_WR_SOP | F_WR_EOP | V_WR_DATATYPE(1) |
 				   V_WR_SGLSFLT(flits)) | wr_hi;
 		wmb();
@@ -948,6 +948,7 @@ static void write_wr_hdr_sgl(unsigned int ndesc, struct sk_buff *skb,
 
 			fp += avail;
 			d++;
+			sd->eop = 0;
 			sd++;
 			if (++pidx == q->size) {
 				pidx = 0;
@@ -966,7 +967,7 @@ static void write_wr_hdr_sgl(unsigned int ndesc, struct sk_buff *skb,
 			wr_gen2(d, gen);
 			flits = 1;
 		}
-		skb->priority = pidx;
+		sd->eop = 1;
 		wrp->wr_hi |= htonl(F_WR_EOP);
 		wmb();
 		wp->wr_lo = htonl(V_WR_LEN(WR_FLITS) | V_WR_GEN(ogen)) | wr_lo;
@@ -1051,8 +1052,6 @@ static void write_tx_pkt_wr(struct adapter *adap, struct sk_buff *skb,
 
 	sgp = ndesc == 1 ? (struct sg_ent *)&d->flit[flits] : sgl;
 	sgl_flits = make_sgl(skb, sgp, skb->data, skb_headlen(skb), adap->pdev);
-	if (need_skb_unmap())
-		((struct unmap_info *)skb->cb)->len = skb_headlen(skb);
 
 	write_wr_hdr_sgl(ndesc, skb, d, pidx, q, sgl, flits, sgl_flits, gen,
 			 htonl(V_WR_OP(FW_WROPCODE_TUNNEL_TX_PKT) | compl),
@@ -1380,13 +1379,14 @@ static void deferred_unmap_destructor(struct sk_buff *skb)
 	const dma_addr_t *p;
 	const struct skb_shared_info *si;
 	const struct deferred_unmap_info *dui;
-	const struct unmap_info *ui = (struct unmap_info *)skb->cb;
 
 	dui = (struct deferred_unmap_info *)skb->head;
 	p = dui->addr;
 
-	if (ui->len)
-		pci_unmap_single(dui->pdev, *p++, ui->len, PCI_DMA_TODEVICE);
+	if (skb->tail - skb->transport_header)
+		pci_unmap_single(dui->pdev, *p++,
+				 skb->tail - skb->transport_header,
+				 PCI_DMA_TODEVICE);
 
 	si = skb_shinfo(skb);
 	for (i = 0; i < si->nr_frags; i++)
@@ -1451,8 +1451,6 @@ static void write_ofld_wr(struct adapter *adap, struct sk_buff *skb,
 	if (need_skb_unmap()) {
 		setup_deferred_unmapping(skb, adap->pdev, sgp, sgl_flits);
 		skb->destructor = deferred_unmap_destructor;
-		((struct unmap_info *)skb->cb)->len = (skb->tail -
-						       skb->transport_header);
 	}
 
 	write_wr_hdr_sgl(ndesc, skb, d, pidx, q, sgl, flits, sgl_flits,
