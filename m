From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net] bna: fix Rx data corruption with VLAN stripping enabled and MTU > 4096
Date: Fri, 15 Jan 2016 13:45:28 +0100
Message-ID: <1452861928-17069-1-git-send-email-ivecera@redhat.com>
Cc: Rasesh Mody <rasesh.mody@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38807 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753108AbcAOMpe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jan 2016 07:45:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The multi-buffer Rx mode implemented in the past introduced
a regression that causes a data corruption for received VLAN
traffic when VLAN tag stripping is enabled. This mode is supported
only be newer chipsets (1860) and is enabled when MTU > 4096.

When this mode is enabled Rx queue contains buffers with fixed size
2048 bytes. Any incoming packet larger than 2048 is divided into
multiple buffers that are attached as skb frags in polling routine.

The driver assumes that all buffers associated with a packet except
the last one is fully used (e.g. packet with size 5000 are divided
into 3 buffers 2048 + 2048 + 904 bytes) and ignores true size reported
in completions. This assumption is usually true but not when VLAN
packet is received and VLAN tag stripping is enabled. In this case
the first buffer is 2044 bytes long but as the driver always assumes
2048 bytes then 4 extra random bytes are included between the first
and the second frag. Additionally the driver sets checksum as correct
so the packet is properly processed by the core.

The driver needs to check the size of used space in each Rx buffer
reported by FW and not blindly use the fixed value.

Cc: Rasesh Mody <rasesh.mody@qlogic.com>
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c | 37 +++++++++++++++++++++------------
 1 file changed, 24 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 21a0cfc..771cc26 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -542,39 +542,50 @@ bnad_cq_drop_packet(struct bnad *bnad, struct bna_rcb *rcb,
 }
 
 static void
-bnad_cq_setup_skb_frags(struct bna_rcb *rcb, struct sk_buff *skb,
-			u32 sop_ci, u32 nvecs, u32 last_fraglen)
+bnad_cq_setup_skb_frags(struct bna_ccb *ccb, struct sk_buff *skb, u32 nvecs)
 {
+	struct bna_rcb *rcb;
 	struct bnad *bnad;
-	u32 ci, vec, len, totlen = 0;
 	struct bnad_rx_unmap_q *unmap_q;
-	struct bnad_rx_unmap *unmap;
+	struct bna_cq_entry *cq, *cmpl;
+	u32 ci, pi, totlen = 0;
+
+	cq = ccb->sw_q;
+	pi = ccb->producer_index;
+	cmpl = &cq[pi];
 
+	rcb = bna_is_small_rxq(cmpl->rxq_id) ? ccb->rcb[1] : ccb->rcb[0];
 	unmap_q = rcb->unmap_q;
 	bnad = rcb->bnad;
+	ci = rcb->consumer_index;
 
 	/* prefetch header */
-	prefetch(page_address(unmap_q->unmap[sop_ci].page) +
-			unmap_q->unmap[sop_ci].page_offset);
+	prefetch(page_address(unmap_q->unmap[ci].page) +
+		 unmap_q->unmap[ci].page_offset);
+
+	while (nvecs--) {
+		struct bnad_rx_unmap *unmap;
+		u32 len;
 
-	for (vec = 1, ci = sop_ci; vec <= nvecs; vec++) {
 		unmap = &unmap_q->unmap[ci];
 		BNA_QE_INDX_INC(ci, rcb->q_depth);
 
 		dma_unmap_page(&bnad->pcidev->dev,
-				dma_unmap_addr(&unmap->vector, dma_addr),
-				unmap->vector.len, DMA_FROM_DEVICE);
+			       dma_unmap_addr(&unmap->vector, dma_addr),
+			       unmap->vector.len, DMA_FROM_DEVICE);
 
-		len = (vec == nvecs) ?
-			last_fraglen : unmap->vector.len;
+		len = ntohs(cmpl->length);
 		skb->truesize += unmap->vector.len;
 		totlen += len;
 
 		skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
-				unmap->page, unmap->page_offset, len);
+				   unmap->page, unmap->page_offset, len);
 
 		unmap->page = NULL;
 		unmap->vector.len = 0;
+
+		BNA_QE_INDX_INC(pi, ccb->q_depth);
+		cmpl = &cq[pi];
 	}
 
 	skb->len += totlen;
@@ -704,7 +715,7 @@ bnad_cq_process(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 		if (BNAD_RXBUF_IS_SK_BUFF(unmap_q->type))
 			bnad_cq_setup_skb(bnad, skb, unmap, len);
 		else
-			bnad_cq_setup_skb_frags(rcb, skb, sop_ci, nvecs, len);
+			bnad_cq_setup_skb_frags(ccb, skb, nvecs);
 
 		rcb->rxq->rx_packets++;
 		rcb->rxq->rx_bytes += totlen;
-- 
2.4.10
