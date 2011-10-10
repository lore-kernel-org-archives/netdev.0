From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 4/9] cxgb4vf: convert to SKB paged frag API.
Date: Mon, 10 Oct 2011 12:11:36 +0100
Message-ID: <1318245101-16890-4-git-send-email-ian.campbell@citrix.com>
References: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:47504 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753688Ab1JJLLr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Oct 2011 07:11:47 -0400
In-Reply-To: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Casey Leedom <leedom@chelsio.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h |    2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c     |   80 ++++++++++--------------
 2 files changed, 35 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h b/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
index 594334d..a9f2e34 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
@@ -144,7 +144,7 @@ struct sge_fl {
  * An ingress packet gather list.
  */
 struct pkt_gl {
-	skb_frag_t frags[MAX_SKB_FRAGS];
+	struct subpage frags[MAX_SKB_FRAGS];
 	void *va;			/* virtual address of first byte */
 	unsigned int nfrags;		/* # of fragments */
 	unsigned int tot_len;		/* total length of fragments */
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index cffb328..27f3134 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -296,8 +296,8 @@ static int map_skb(struct device *dev, const struct sk_buff *skb,
 	si = skb_shinfo(skb);
 	end = &si->frags[si->nr_frags];
 	for (fp = si->frags; fp < end; fp++) {
-		*++addr = dma_map_page(dev, fp->page, fp->page_offset, fp->size,
-				       DMA_TO_DEVICE);
+		*++addr = skb_frag_dma_map(dev, fp, 0, fp->size,
+					   DMA_TO_DEVICE);
 		if (dma_mapping_error(dev, *addr))
 			goto unwind;
 	}
@@ -1357,6 +1357,35 @@ out_free:
 }
 
 /**
+ *	copy_frags - copy fragments from gather list into skb_shared_info
+ *	@si: destination skb shared info structure
+ *	@gl: source internal packet gather list
+ *	@offset: packet start offset in first page
+ *
+ *	Copy an internal packet gather list into a Linux skb_shared_info
+ *	structure.
+ */
+static inline void copy_frags(struct sk_buff *skb,
+			      const struct pkt_gl *gl,
+			      unsigned int offset)
+{
+	int i;
+
+	/* usually there's just one frag */
+	__skb_fill_page_desc(skb, 0, gl->frags[0].page,
+			     gl->frags[0].page_offset + offset,
+			     gl->frags[0].size - offset);
+	skb_shinfo(skb)->nr_frags = gl->nfrags;
+	for (i = 1; i < gl->nfrags; i++)
+		__skb_fill_page_desc(skb, i, gl->frags[i].page,
+				     gl->frags[i].page_offset,
+				     gl->frags[i].size);
+
+	/* get a reference to the last page, we don't own it */
+	get_page(gl->frags[gl->nfrags - 1].page);
+}
+
+/**
  *	t4vf_pktgl_to_skb - build an sk_buff from a packet gather list
  *	@gl: the gather list
  *	@skb_len: size of sk_buff main body if it carries fragments
@@ -1369,7 +1398,6 @@ struct sk_buff *t4vf_pktgl_to_skb(const struct pkt_gl *gl,
 				  unsigned int skb_len, unsigned int pull_len)
 {
 	struct sk_buff *skb;
-	struct skb_shared_info *ssi;
 
 	/*
 	 * If the ingress packet is small enough, allocate an skb large enough
@@ -1396,21 +1424,10 @@ struct sk_buff *t4vf_pktgl_to_skb(const struct pkt_gl *gl,
 		__skb_put(skb, pull_len);
 		skb_copy_to_linear_data(skb, gl->va, pull_len);
 
-		ssi = skb_shinfo(skb);
-		ssi->frags[0].page = gl->frags[0].page;
-		ssi->frags[0].page_offset = gl->frags[0].page_offset + pull_len;
-		ssi->frags[0].size = gl->frags[0].size - pull_len;
-		if (gl->nfrags > 1)
-			memcpy(&ssi->frags[1], &gl->frags[1],
-			       (gl->nfrags-1) * sizeof(skb_frag_t));
-		ssi->nr_frags = gl->nfrags;
-
+		copy_frags(skb, gl, pull_len);
 		skb->len = gl->tot_len;
 		skb->data_len = skb->len - pull_len;
 		skb->truesize += skb->data_len;
-
-		/* Get a reference for the last page, we don't own it */
-		get_page(gl->frags[gl->nfrags - 1].page);
 	}
 
 out:
@@ -1434,35 +1451,6 @@ void t4vf_pktgl_free(const struct pkt_gl *gl)
 }
 
 /**
- *	copy_frags - copy fragments from gather list into skb_shared_info
- *	@si: destination skb shared info structure
- *	@gl: source internal packet gather list
- *	@offset: packet start offset in first page
- *
- *	Copy an internal packet gather list into a Linux skb_shared_info
- *	structure.
- */
-static inline void copy_frags(struct skb_shared_info *si,
-			      const struct pkt_gl *gl,
-			      unsigned int offset)
-{
-	unsigned int n;
-
-	/* usually there's just one frag */
-	si->frags[0].page = gl->frags[0].page;
-	si->frags[0].page_offset = gl->frags[0].page_offset + offset;
-	si->frags[0].size = gl->frags[0].size - offset;
-	si->nr_frags = gl->nfrags;
-
-	n = gl->nfrags - 1;
-	if (n)
-		memcpy(&si->frags[1], &gl->frags[1], n * sizeof(skb_frag_t));
-
-	/* get a reference to the last page, we don't own it */
-	get_page(gl->frags[n].page);
-}
-
-/**
  *	do_gro - perform Generic Receive Offload ingress packet processing
  *	@rxq: ingress RX Ethernet Queue
  *	@gl: gather list for ingress packet
@@ -1484,7 +1472,7 @@ static void do_gro(struct sge_eth_rxq *rxq, const struct pkt_gl *gl,
 		return;
 	}
 
-	copy_frags(skb_shinfo(skb), gl, PKTSHIFT);
+	copy_frags(skb, gl, PKTSHIFT);
 	skb->len = gl->tot_len - PKTSHIFT;
 	skb->data_len = skb->len;
 	skb->truesize += skb->data_len;
@@ -1667,7 +1655,7 @@ int process_responses(struct sge_rspq *rspq, int budget)
 		rmb();
 		rsp_type = RSPD_TYPE(rc->type_gen);
 		if (likely(rsp_type == RSP_TYPE_FLBUF)) {
-			skb_frag_t *fp;
+			struct subpage *fp;
 			struct pkt_gl gl;
 			const struct rx_sw_desc *sdesc;
 			u32 bufsz, frag;
-- 
1.7.2.5
