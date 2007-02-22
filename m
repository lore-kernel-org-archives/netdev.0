From: divy@chelsio.com
Subject: [PATCH 4/7 RESEND] cxgb3 - Unmap offload packets when they are freed
Date: Thu, 22 Feb 2007 03:59:36 -0800
Message-ID: <20070222115936.10037.90224.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:17605 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161172AbXBVL7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 06:59:39 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Offload packets may be DMAed long after their SGE Tx descriptors are done
so they must remain mapped until they are freed rather than until their
descriptors are freed.  Unmap such packets through an skb destructor.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/sge.c |   63 ++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 61 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 3f2cf8a..822a598 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -105,6 +105,15 @@ struct unmap_info {		/* packet unmapping
 };
 
 /*
+ * Holds unmapping information for Tx packets that need deferred unmapping.
+ * This structure lives at skb->head and must be allocated by callers.
+ */
+struct deferred_unmap_info {
+	struct pci_dev *pdev;
+	dma_addr_t addr[MAX_SKB_FRAGS + 1];
+};
+
+/*
  * Maps a number of flits to the number of Tx descriptors that can hold them.
  * The formula is
  *
@@ -252,10 +261,13 @@ static void free_tx_desc(struct adapter
 	struct pci_dev *pdev = adapter->pdev;
 	unsigned int cidx = q->cidx;
 
+	const int need_unmap = need_skb_unmap() &&
+			       q->cntxt_id >= FW_TUNNEL_SGEEC_START;
+
 	d = &q->sdesc[cidx];
 	while (n--) {
 		if (d->skb) {	/* an SGL is present */
-			if (need_skb_unmap())
+			if (need_unmap)
 				unmap_skb(d->skb, q, cidx, pdev);
 			if (d->skb->priority == cidx)
 				kfree_skb(d->skb);
@@ -1227,6 +1239,50 @@ int t3_mgmt_tx(struct adapter *adap, str
 }
 
 /**
+ *	deferred_unmap_destructor - unmap a packet when it is freed
+ *	@skb: the packet
+ *
+ *	This is the packet destructor used for Tx packets that need to remain
+ *	mapped until they are freed rather than until their Tx descriptors are
+ *	freed.
+ */
+static void deferred_unmap_destructor(struct sk_buff *skb)
+{
+	int i;
+	const dma_addr_t *p;
+	const struct skb_shared_info *si;
+	const struct deferred_unmap_info *dui;
+	const struct unmap_info *ui = (struct unmap_info *)skb->cb;
+
+	dui = (struct deferred_unmap_info *)skb->head;
+	p = dui->addr;
+
+	if (ui->len)
+		pci_unmap_single(dui->pdev, *p++, ui->len, PCI_DMA_TODEVICE);
+
+	si = skb_shinfo(skb);
+	for (i = 0; i < si->nr_frags; i++)
+		pci_unmap_page(dui->pdev, *p++, si->frags[i].size,
+			       PCI_DMA_TODEVICE);
+}
+
+static void setup_deferred_unmapping(struct sk_buff *skb, struct pci_dev *pdev,
+				     const struct sg_ent *sgl, int sgl_flits)
+{
+	dma_addr_t *p;
+	struct deferred_unmap_info *dui;
+
+	dui = (struct deferred_unmap_info *)skb->head;
+	dui->pdev = pdev;
+	for (p = dui->addr; sgl_flits >= 3; sgl++, sgl_flits -= 3) {
+		*p++ = be64_to_cpu(sgl->addr[0]);
+		*p++ = be64_to_cpu(sgl->addr[1]);
+	}
+	if (sgl_flits)
+		*p = be64_to_cpu(sgl->addr[0]);
+}
+
+/**
  *	write_ofld_wr - write an offload work request
  *	@adap: the adapter
  *	@skb: the packet to send
@@ -1262,8 +1318,11 @@ static void write_ofld_wr(struct adapter
 	sgp = ndesc == 1 ? (struct sg_ent *)&d->flit[flits] : sgl;
 	sgl_flits = make_sgl(skb, sgp, skb->h.raw, skb->tail - skb->h.raw,
 			     adap->pdev);
-	if (need_skb_unmap())
+	if (need_skb_unmap()) {
+		setup_deferred_unmapping(skb, adap->pdev, sgp, sgl_flits);
+		skb->destructor = deferred_unmap_destructor;
 		((struct unmap_info *)skb->cb)->len = skb->tail - skb->h.raw;
+	}
 
 	write_wr_hdr_sgl(ndesc, skb, d, pidx, q, sgl, flits, sgl_flits,
 			 gen, from->wr_hi, from->wr_lo);
