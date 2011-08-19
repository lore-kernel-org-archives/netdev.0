From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 23/75] cxgb4: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:26:55 +0100
Message-ID: <1313760467-8598-23-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/cxgb4/sge.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
index 56adf44..f1813b5 100644
--- a/drivers/net/cxgb4/sge.c
+++ b/drivers/net/cxgb4/sge.c
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
@@ -1409,13 +1409,14 @@ int cxgb4_ofld_send(struct net_device *dev, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(cxgb4_ofld_send);
 
-static inline void copy_frags(struct skb_shared_info *ssi,
+static inline void copy_frags(struct sk_buff *skb,
 			      const struct pkt_gl *gl, unsigned int offset)
 {
+	struct skb_shared_info *ssi = skb_shinfo(skb);
 	unsigned int n;
 
 	/* usually there's just one frag */
-	ssi->frags[0].page = gl->frags[0].page;
+	skb_frag_set_page(skb, 0, gl->frags[0].page);
 	ssi->frags[0].page_offset = gl->frags[0].page_offset + offset;
 	ssi->frags[0].size = gl->frags[0].size - offset;
 	ssi->nr_frags = gl->nfrags;
@@ -1459,7 +1460,7 @@ struct sk_buff *cxgb4_pktgl_to_skb(const struct pkt_gl *gl,
 		__skb_put(skb, pull_len);
 		skb_copy_to_linear_data(skb, gl->va, pull_len);
 
-		copy_frags(skb_shinfo(skb), gl, pull_len);
+		copy_frags(skb, gl, pull_len);
 		skb->len = gl->tot_len;
 		skb->data_len = skb->len - pull_len;
 		skb->truesize += skb->data_len;
@@ -1522,7 +1523,7 @@ static void do_gro(struct sge_eth_rxq *rxq, const struct pkt_gl *gl,
 		return;
 	}
 
-	copy_frags(skb_shinfo(skb), gl, RX_PKT_PAD);
+	copy_frags(skb, gl, RX_PKT_PAD);
 	skb->len = gl->tot_len - RX_PKT_PAD;
 	skb->data_len = skb->len;
 	skb->truesize += skb->data_len;
@@ -1735,6 +1736,7 @@ static int process_responses(struct sge_rspq *q, int budget)
 
 			si.va = page_address(si.frags[0].page) +
 				si.frags[0].page_offset;
+
 			prefetch(si.va);
 
 			si.nfrags = frags + 1;
-- 
1.7.2.5
