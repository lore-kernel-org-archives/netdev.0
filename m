From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 3/3] net: mvneta: Introduce a software TSO implementation
Date: Thu, 10 Apr 2014 19:58:02 -0300
Message-ID: <1397170682-19138-4-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1397170682-19138-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Willy Tarreau <w@1wt.eu>, Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Simon Guinot <sguinot@lacie.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:42479 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759191AbaDJW6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 18:58:51 -0400
In-Reply-To: <1397170682-19138-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit implements a software TSO which reduces the CPU
usage significantly while retaining the outbound throughput
at line rate.

Tested on a Plat'home Openblocks AX/3 board acting as iperf client (tx).
The CPU usage shows a substantial CPU usage drop, between 15%-25%.

Other tests performed by Willy Tarreau show performance improvements:
Willy reported that "[..] turning the TSO flag on immediately increases the
HTTP request rate from 1680 to 1820 per second (30 kB objects)".

Tested-by: Willy Tarreau <w@1wt.eu>
Signed-off-by: Simon Guinot <sguinot@lacie.com>
Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 207 +++++++++++++++++++++++++++++++++-
 1 file changed, 206 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index e5bd3ca..cd6b998 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -244,6 +244,9 @@
 
 #define MVNETA_TX_MTU_MAX		0x3ffff
 
+/* TSO header size */
+#define TSO_HEADER_SIZE 128
+
 /* Max number of Rx descriptors */
 #define MVNETA_MAX_RXD 128
 
@@ -413,6 +416,12 @@ struct mvneta_tx_queue {
 
 	/* Index of the next TX DMA descriptor to process */
 	int next_desc_to_proc;
+
+	/* DMA buffers for TSO headers */
+	char *tso_hdrs;
+
+	/* DMA address of TSO headers */
+	dma_addr_t tso_hdrs_phys;
 };
 
 struct mvneta_rx_queue {
@@ -1519,6 +1528,181 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 	return rx_done;
 }
 
+static inline void
+mvneta_tso_build_hdr(struct net_device *dev, struct mvneta_tx_queue *txq,
+		     struct sk_buff *skb, int hdr_len, int size,
+		     u32 tcp_seq, u16 ip_id, bool is_last)
+{
+	struct mvneta_port *pp = netdev_priv(dev);
+	struct mvneta_tx_desc *tx_desc;
+	struct iphdr *iph;
+	struct tcphdr *tcph;
+	char *mac;
+	int mac_hdr_len = skb_network_offset(skb);
+
+	mac = txq->tso_hdrs + txq->txq_put_index * TSO_HEADER_SIZE;
+	memcpy(mac, skb->data, hdr_len);
+
+	iph = (struct iphdr *)(mac + mac_hdr_len);
+	iph->id = htons(ip_id);
+	iph->tot_len = htons(size + hdr_len - mac_hdr_len);
+
+	tcph = (struct tcphdr *)(mac + skb_transport_offset(skb));
+	tcph->seq = htonl(tcp_seq);
+
+	if (!is_last) {
+		/* Clear all special flags for not last packet */
+		tcph->psh = 0;
+		tcph->fin = 0;
+		tcph->rst = 0;
+	}
+
+	txq->tx_skb[txq->txq_put_index] = NULL;
+	tx_desc = mvneta_txq_next_desc_get(txq);
+	tx_desc->data_size = hdr_len;
+	tx_desc->command = mvneta_skb_tx_csum(pp, skb);
+	tx_desc->command |= MVNETA_TXD_F_DESC;
+	tx_desc->buf_phys_addr = txq->tso_hdrs_phys +
+				 txq->txq_put_index * TSO_HEADER_SIZE;
+	mvneta_txq_inc_put(txq);
+}
+
+static inline int
+mvneta_tso_build_data(struct net_device *dev, struct mvneta_tx_queue *txq,
+		      struct sk_buff *skb, char *frag_ptr, int frag_size,
+		      int data_left, bool is_last)
+{
+	int size;
+	struct mvneta_tx_desc *tx_desc;
+
+	size = (frag_size < data_left) ? frag_size : data_left;
+
+	tx_desc = mvneta_txq_next_desc_get(txq);
+	tx_desc->data_size = size;
+	tx_desc->buf_phys_addr = dma_map_single(dev->dev.parent, frag_ptr,
+						size, DMA_TO_DEVICE);
+	if (unlikely(dma_mapping_error(dev->dev.parent,
+		     tx_desc->buf_phys_addr))) {
+		mvneta_txq_desc_put(txq);
+		return 0;
+	}
+
+	tx_desc->command = 0;
+	txq->tx_skb[txq->txq_put_index] = NULL;
+
+	if (size == data_left) {
+		/* last descriptor in the TCP packet */
+		tx_desc->command = MVNETA_TXD_L_DESC;
+
+		/* last descriptor in SKB */
+		if (is_last)
+			txq->tx_skb[txq->txq_put_index] = skb;
+	}
+	mvneta_txq_inc_put(txq);
+	return size;
+}
+
+static int mvneta_tx_tso(struct sk_buff *skb, struct net_device *dev,
+			 struct mvneta_tx_queue *txq)
+{
+	int total_len, hdr_len, size, frag_size, data_left;
+	int desc_count;
+	u16 ip_id;
+	u32 tcp_seq;
+	skb_frag_t *frag;
+	int frag_idx = 0;
+	char *frag_ptr;
+	const struct tcphdr *th = tcp_hdr(skb);
+	struct mvneta_port *pp = netdev_priv(dev);
+	int i;
+
+	/* Calculate expected number of TX descriptors */
+	desc_count = skb_shinfo(skb)->gso_segs * 2 + skb_shinfo(skb)->nr_frags;
+	if ((txq->count + desc_count) >= txq->size)
+		return 0;
+
+	total_len = skb->len;
+	hdr_len = (skb_transport_offset(skb) + tcp_hdrlen(skb));
+
+	total_len -= hdr_len;
+	ip_id = ntohs(ip_hdr(skb)->id);
+	tcp_seq = ntohl(th->seq);
+
+	frag_size = skb_headlen(skb);
+	frag_ptr = skb->data;
+
+	if (frag_size < hdr_len)
+		return 0;
+
+	frag_size -= hdr_len;
+	frag_ptr += hdr_len;
+	if (frag_size == 0) {
+		frag = &skb_shinfo(skb)->frags[frag_idx];
+
+		/* Move to next segment */
+		frag_size = frag->size;
+		frag_ptr = page_address(frag->page.p) + frag->page_offset;
+		frag_idx++;
+	}
+	desc_count = 0;
+
+	while (total_len > 0) {
+		data_left = (skb_shinfo(skb)->gso_size < total_len) ?
+				skb_shinfo(skb)->gso_size : total_len;
+		desc_count++;
+		total_len -= data_left;
+
+		/* prepare packet headers: MAC + IP + TCP */
+		mvneta_tso_build_hdr(dev, txq, skb, hdr_len, data_left,
+				     tcp_seq, ip_id, total_len == 0);
+		ip_id++;
+
+		while (data_left > 0) {
+			desc_count++;
+
+			size = mvneta_tso_build_data(dev, txq, skb,
+						     frag_ptr, frag_size,
+						     data_left, total_len == 0);
+			if (size == 0)
+				goto err_release;
+
+			data_left -= size;
+			tcp_seq += size;
+
+			frag_size -= size;
+			frag_ptr += size;
+
+			if ((frag_size == 0) &&
+			    (frag_idx < skb_shinfo(skb)->nr_frags)) {
+				frag = &skb_shinfo(skb)->frags[frag_idx];
+
+				/* Move to next segment */
+				frag_size = frag->size;
+				frag_ptr = page_address(frag->page.p) +
+					   frag->page_offset;
+				frag_idx++;
+			}
+		}
+	}
+
+	return desc_count;
+
+err_release:
+	/* Release all used data descriptors; header descriptors must not
+	 * be DMA-unmapped.
+	 */
+	for (i = desc_count - 1; i >= 0; i--) {
+		struct mvneta_tx_desc *tx_desc = txq->descs + i;
+		if (!(tx_desc->command & MVNETA_TXD_F_DESC))
+			dma_unmap_single(pp->dev->dev.parent,
+					 tx_desc->buf_phys_addr,
+					 tx_desc->data_size,
+					 DMA_TO_DEVICE);
+		mvneta_txq_desc_put(txq);
+	}
+	return 0;
+}
+
 /* Handle tx fragmentation processing */
 static int mvneta_tx_frag_process(struct mvneta_port *pp, struct sk_buff *skb,
 				  struct mvneta_tx_queue *txq)
@@ -1590,6 +1774,11 @@ static int mvneta_tx(struct sk_buff *skb, struct net_device *dev)
 	if (!netif_running(dev))
 		goto out;
 
+	if (skb_is_gso(skb)) {
+		frags = mvneta_tx_tso(skb, dev, txq);
+		goto out;
+	}
+
 	frags = skb_shinfo(skb)->nr_frags + 1;
 
 	/* Get a descriptor for the first part of the packet */
@@ -2108,6 +2297,18 @@ static int mvneta_txq_init(struct mvneta_port *pp,
 				  txq->descs, txq->descs_phys);
 		return -ENOMEM;
 	}
+
+	/* Allocate DMA buffers for TSO MAC/IP/TCP headers */
+	txq->tso_hdrs = dma_alloc_coherent(pp->dev->dev.parent,
+					   txq->size * TSO_HEADER_SIZE,
+					   &txq->tso_hdrs_phys, GFP_KERNEL);
+	if (txq->tso_hdrs == NULL) {
+		kfree(txq->tx_skb);
+		dma_free_coherent(pp->dev->dev.parent,
+				  txq->size * MVNETA_DESC_ALIGNED_SIZE,
+				  txq->descs, txq->descs_phys);
+		return -ENOMEM;
+	}
 	mvneta_tx_done_pkts_coal_set(pp, txq, txq->done_pkts_coal);
 
 	return 0;
@@ -2119,6 +2320,10 @@ static void mvneta_txq_deinit(struct mvneta_port *pp,
 {
 	kfree(txq->tx_skb);
 
+	if (txq->tso_hdrs)
+		dma_free_coherent(pp->dev->dev.parent,
+				  txq->size * TSO_HEADER_SIZE,
+				  txq->tso_hdrs, txq->tso_hdrs_phys);
 	if (txq->descs)
 		dma_free_coherent(pp->dev->dev.parent,
 				  txq->size * MVNETA_DESC_ALIGNED_SIZE,
@@ -2861,7 +3066,7 @@ static int mvneta_probe(struct platform_device *pdev)
 
 	netif_napi_add(dev, &pp->napi, mvneta_poll, pp->weight);
 
-	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM;
+	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
 	dev->hw_features |= dev->features;
 	dev->vlan_features |= dev->features;
 	dev->priv_flags |= IFF_UNICAST_FLT;
-- 
1.9.1
