From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH 04/10] cxgb4vf: fix some errors in Gather List to skb conversion
Date: Wed, 10 Nov 2010 18:04:06 -0800
Message-ID: <1289441052-4925-4-git-send-email-leedom@chelsio.com>
References: <450C6E98-D0D9-42A6-9F15-4DB98647DB04@chelsio.com>
Cc: davem@davemloft.net, Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:22303 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932253Ab0KKCEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 21:04:20 -0500
In-Reply-To: <450C6E98-D0D9-42A6-9F15-4DB98647DB04@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There were some errors in the way that internal Gather Lists were being
translated into skb's.  This also makes the VF Driver look more like the PF
Driver to facilitate easier comarison.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/sge.c |  121 +++++++++++++++++++++++++++-----------------
 1 files changed, 74 insertions(+), 47 deletions(-)

diff --git a/drivers/net/cxgb4vf/sge.c b/drivers/net/cxgb4vf/sge.c
index 1767bda..e0b3d1b 100644
--- a/drivers/net/cxgb4vf/sge.c
+++ b/drivers/net/cxgb4vf/sge.c
@@ -154,13 +154,14 @@ enum {
 	 */
 	RX_COPY_THRES = 256,
 	RX_PULL_LEN = 128,
-};
 
-/*
- * Can't define this in the above enum because PKTSHIFT isn't a constant in
- * the VF Driver ...
- */
-#define RX_PKT_PULL_LEN (RX_PULL_LEN + PKTSHIFT)
+	/*
+	 * Main body length for sk_buffs used for RX Ethernet packets with
+	 * fragments.  Should be >= RX_PULL_LEN but possibly bigger to give
+	 * pskb_may_pull() some room.
+	 */
+	RX_SKB_LEN = 512,
+};
 
 /*
  * Software state per TX descriptor.
@@ -1355,6 +1356,67 @@ out_free:
 }
 
 /**
+ *	t4vf_pktgl_to_skb - build an sk_buff from a packet gather list
+ *	@gl: the gather list
+ *	@skb_len: size of sk_buff main body if it carries fragments
+ *	@pull_len: amount of data to move to the sk_buff's main body
+ *
+ *	Builds an sk_buff from the given packet gather list.  Returns the
+ *	sk_buff or %NULL if sk_buff allocation failed.
+ */
+struct sk_buff *t4vf_pktgl_to_skb(const struct pkt_gl *gl,
+				  unsigned int skb_len, unsigned int pull_len)
+{
+	struct sk_buff *skb;
+	struct skb_shared_info *ssi;
+
+	/*
+	 * If the ingress packet is small enough, allocate an skb large enough
+	 * for all of the data and copy it inline.  Otherwise, allocate an skb
+	 * with enough room to pull in the header and reference the rest of
+	 * the data via the skb fragment list.
+	 *
+	 * Below we rely on RX_COPY_THRES being less than the smallest Rx
+	 * buff!  size, which is expected since buffers are at least
+	 * PAGE_SIZEd.  In this case packets up to RX_COPY_THRES have only one
+	 * fragment.
+	 */
+	if (gl->tot_len <= RX_COPY_THRES) {
+		/* small packets have only one fragment */
+		skb = alloc_skb(gl->tot_len, GFP_ATOMIC);
+		if (unlikely(!skb))
+			goto out;
+		__skb_put(skb, gl->tot_len);
+		skb_copy_to_linear_data(skb, gl->va, gl->tot_len);
+	} else {
+		skb = alloc_skb(skb_len, GFP_ATOMIC);
+		if (unlikely(!skb))
+			goto out;
+		__skb_put(skb, pull_len);
+		skb_copy_to_linear_data(skb, gl->va, pull_len);
+
+		ssi = skb_shinfo(skb);
+		ssi->frags[0].page = gl->frags[0].page;
+		ssi->frags[0].page_offset = gl->frags[0].page_offset + pull_len;
+		ssi->frags[0].size = gl->frags[0].size - pull_len;
+		if (gl->nfrags > 1)
+			memcpy(&ssi->frags[1], &gl->frags[1],
+			       (gl->nfrags-1) * sizeof(skb_frag_t));
+		ssi->nr_frags = gl->nfrags;
+
+		skb->len = gl->tot_len;
+		skb->data_len = skb->len - pull_len;
+		skb->truesize += skb->data_len;
+
+		/* Get a reference for the last page, we don't own it */
+		get_page(gl->frags[gl->nfrags - 1].page);
+	}
+
+out:
+	return skb;
+}
+
+/**
  *	t4vf_pktgl_free - free a packet gather list
  *	@gl: the gather list
  *
@@ -1463,10 +1525,8 @@ int t4vf_ethrx_handler(struct sge_rspq *rspq, const __be64 *rsp,
 {
 	struct sk_buff *skb;
 	struct port_info *pi;
-	struct skb_shared_info *ssi;
 	const struct cpl_rx_pkt *pkt = (void *)&rsp[1];
 	bool csum_ok = pkt->csum_calc && !pkt->err_vec;
-	unsigned int len = be16_to_cpu(pkt->len);
 	struct sge_eth_rxq *rxq = container_of(rspq, struct sge_eth_rxq, rspq);
 
 	/*
@@ -1481,42 +1541,14 @@ int t4vf_ethrx_handler(struct sge_rspq *rspq, const __be64 *rsp,
 	}
 
 	/*
-	 * If the ingress packet is small enough, allocate an skb large enough
-	 * for all of the data and copy it inline.  Otherwise, allocate an skb
-	 * with enough room to pull in the header and reference the rest of
-	 * the data via the skb fragment list.
+	 * Convert the Packet Gather List into an skb.
 	 */
-	if (len <= RX_COPY_THRES) {
-		/* small packets have only one fragment */
-		skb = alloc_skb(gl->frags[0].size, GFP_ATOMIC);
-		if (!skb)
-			goto nomem;
-		__skb_put(skb, gl->frags[0].size);
-		skb_copy_to_linear_data(skb, gl->va, gl->frags[0].size);
-	} else {
-		skb = alloc_skb(RX_PKT_PULL_LEN, GFP_ATOMIC);
-		if (!skb)
-			goto nomem;
-		__skb_put(skb, RX_PKT_PULL_LEN);
-		skb_copy_to_linear_data(skb, gl->va, RX_PKT_PULL_LEN);
-
-		ssi = skb_shinfo(skb);
-		ssi->frags[0].page = gl->frags[0].page;
-		ssi->frags[0].page_offset = (gl->frags[0].page_offset +
-					     RX_PKT_PULL_LEN);
-		ssi->frags[0].size = gl->frags[0].size - RX_PKT_PULL_LEN;
-		if (gl->nfrags > 1)
-			memcpy(&ssi->frags[1], &gl->frags[1],
-			       (gl->nfrags-1) * sizeof(skb_frag_t));
-		ssi->nr_frags = gl->nfrags;
-		skb->len = len + PKTSHIFT;
-		skb->data_len = skb->len - RX_PKT_PULL_LEN;
-		skb->truesize += skb->data_len;
-
-		/* Get a reference for the last page, we don't own it */
-		get_page(gl->frags[gl->nfrags - 1].page);
+	skb = t4vf_pktgl_to_skb(gl, RX_SKB_LEN, RX_PULL_LEN);
+	if (unlikely(!skb)) {
+		t4vf_pktgl_free(gl);
+		rxq->stats.rx_drops++;
+		return 0;
 	}
-
 	__skb_pull(skb, PKTSHIFT);
 	skb->protocol = eth_type_trans(skb, rspq->netdev);
 	skb_record_rx_queue(skb, rspq->idx);
@@ -1552,11 +1584,6 @@ int t4vf_ethrx_handler(struct sge_rspq *rspq, const __be64 *rsp,
 		netif_receive_skb(skb);
 
 	return 0;
-
-nomem:
-	t4vf_pktgl_free(gl);
-	rxq->stats.rx_drops++;
-	return 0;
 }
 
 /**
-- 
1.7.0.4

