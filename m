From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 3/9] cxgb4: convert to SKB paged frag API.
Date: Mon, 10 Oct 2011 12:11:35 +0100
Message-ID: <1318245101-16890-3-git-send-email-ian.campbell@citrix.com>
References: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:44685 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753634Ab1JJLLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 07:11:46 -0400
In-Reply-To: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c   |   33 ++++++++++++++-------------
 2 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 223a7f7..209cd69 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -326,7 +326,7 @@ struct sge_fl {                     /* SGE free-buffer queue state */
 
 /* A packet gather list */
 struct pkt_gl {
-	skb_frag_t frags[MAX_SKB_FRAGS];
+	struct subpage frags[MAX_SKB_FRAGS];
 	void *va;                         /* virtual address of first byte */
 	unsigned int nfrags;              /* # of fragments */
 	unsigned int tot_len;             /* total length of fragments */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 56adf44..0100c4c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -215,8 +215,8 @@ static int map_skb(struct device *dev, const struct sk_buff *skb,
 	end = &si->frags[si->nr_frags];
 
 	for (fp = si->frags; fp < end; fp++) {
-		*++addr = dma_map_page(dev, fp->page, fp->page_offset, fp->size,
-				       DMA_TO_DEVICE);
+		*++addr = skb_frag_dma_map(dev, fp, 0, fp->size,
+					   DMA_TO_DEVICE);
 		if (dma_mapping_error(dev, *addr))
 			goto unwind;
 	}
@@ -1409,22 +1409,23 @@ int cxgb4_ofld_send(struct net_device *dev, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(cxgb4_ofld_send);
 
-static inline void copy_frags(struct skb_shared_info *ssi,
+static inline void copy_frags(struct sk_buff *skb,
 			      const struct pkt_gl *gl, unsigned int offset)
 {
-	unsigned int n;
+	int i;
 
 	/* usually there's just one frag */
-	ssi->frags[0].page = gl->frags[0].page;
-	ssi->frags[0].page_offset = gl->frags[0].page_offset + offset;
-	ssi->frags[0].size = gl->frags[0].size - offset;
-	ssi->nr_frags = gl->nfrags;
-	n = gl->nfrags - 1;
-	if (n)
-		memcpy(&ssi->frags[1], &gl->frags[1], n * sizeof(skb_frag_t));
+	__skb_fill_page_desc(skb, 0, gl->frags[0].page,
+			     gl->frags[0].page_offset + offset,
+			     gl->frags[0].size - offset);
+	skb_shinfo(skb)->nr_frags = gl->nfrags;
+	for (i = 1; i < gl->nfrags; i++)
+		__skb_fill_page_desc(skb, i, gl->frags[i].page,
+				     gl->frags[i].page_offset,
+				     gl->frags[i].size);
 
 	/* get a reference to the last page, we don't own it */
-	get_page(gl->frags[n].page);
+	get_page(gl->frags[gl->nfrags - 1].page);
 }
 
 /**
@@ -1459,7 +1460,7 @@ struct sk_buff *cxgb4_pktgl_to_skb(const struct pkt_gl *gl,
 		__skb_put(skb, pull_len);
 		skb_copy_to_linear_data(skb, gl->va, pull_len);
 
-		copy_frags(skb_shinfo(skb), gl, pull_len);
+		copy_frags(skb, gl, pull_len);
 		skb->len = gl->tot_len;
 		skb->data_len = skb->len - pull_len;
 		skb->truesize += skb->data_len;
@@ -1478,7 +1479,7 @@ EXPORT_SYMBOL(cxgb4_pktgl_to_skb);
 static void t4_pktgl_free(const struct pkt_gl *gl)
 {
 	int n;
-	const skb_frag_t *p;
+	const struct subpage *p;
 
 	for (p = gl->frags, n = gl->nfrags - 1; n--; p++)
 		put_page(p->page);
@@ -1522,7 +1523,7 @@ static void do_gro(struct sge_eth_rxq *rxq, const struct pkt_gl *gl,
 		return;
 	}
 
-	copy_frags(skb_shinfo(skb), gl, RX_PKT_PAD);
+	copy_frags(skb, gl, RX_PKT_PAD);
 	skb->len = gl->tot_len - RX_PKT_PAD;
 	skb->data_len = skb->len;
 	skb->truesize += skb->data_len;
@@ -1698,7 +1699,7 @@ static int process_responses(struct sge_rspq *q, int budget)
 		rmb();
 		rsp_type = RSPD_TYPE(rc->type_gen);
 		if (likely(rsp_type == RSP_TYPE_FLBUF)) {
-			skb_frag_t *fp;
+			struct subpage *fp;
 			struct pkt_gl si;
 			const struct rx_sw_desc *rsd;
 			u32 len = ntohl(rc->pldbuflen_qid), bufsz, frags;
-- 
1.7.2.5
