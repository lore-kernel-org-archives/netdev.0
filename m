From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 4/9] net: mvneta: Implement software TSO
Date: Mon, 19 May 2014 13:59:55 -0300
Message-ID: <1400518800-6111-5-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1400518800-6111-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:53605 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932566AbaESRBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 13:01:06 -0400
In-Reply-To: <1400518800-6111-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the TSO helper API has been introduced, this commit makes use
of it to implement the TSO in this driver.

Using iperf to test and vmstat to check the CPU usage, shows a substantial
CPU usage drop when TSO is on (~15% vs. ~25%). HTTP-based tests performed
by Willy Tarreau have shown performance improvements.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 153 +++++++++++++++++++++++++++++++++-
 1 file changed, 152 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 8509029..18c698d 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -23,6 +23,7 @@
 #include <net/ip.h>
 #include <net/ipv6.h>
 #include <linux/io.h>
+#include <net/tso.h>
 #include <linux/of.h>
 #include <linux/of_irq.h>
 #include <linux/of_mdio.h>
@@ -244,6 +245,9 @@
 
 #define MVNETA_TX_MTU_MAX		0x3ffff
 
+/* TSO header size */
+#define TSO_HEADER_SIZE 128
+
 /* Max number of Rx descriptors */
 #define MVNETA_MAX_RXD 128
 
@@ -413,6 +417,12 @@ struct mvneta_tx_queue {
 
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
@@ -1519,6 +1529,126 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 	return rx_done;
 }
 
+static inline void
+mvneta_tso_put_hdr(struct sk_buff *skb,
+		   struct mvneta_port *pp, struct mvneta_tx_queue *txq)
+{
+	struct mvneta_tx_desc *tx_desc;
+	int hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
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
+mvneta_tso_put_data(struct net_device *dev, struct mvneta_tx_queue *txq,
+		    struct sk_buff *skb, char *data, int size,
+		    bool last_tcp, bool is_last)
+{
+	struct mvneta_tx_desc *tx_desc;
+
+	tx_desc = mvneta_txq_next_desc_get(txq);
+	tx_desc->data_size = size;
+	tx_desc->buf_phys_addr = dma_map_single(dev->dev.parent, data,
+						size, DMA_TO_DEVICE);
+	if (unlikely(dma_mapping_error(dev->dev.parent,
+		     tx_desc->buf_phys_addr))) {
+		mvneta_txq_desc_put(txq);
+		return -ENOMEM;
+	}
+
+	tx_desc->command = 0;
+	txq->tx_skb[txq->txq_put_index] = NULL;
+
+	if (last_tcp) {
+		/* last descriptor in the TCP packet */
+		tx_desc->command = MVNETA_TXD_L_DESC;
+
+		/* last descriptor in SKB */
+		if (is_last)
+			txq->tx_skb[txq->txq_put_index] = skb;
+	}
+	mvneta_txq_inc_put(txq);
+	return 0;
+}
+
+static int mvneta_tx_tso(struct sk_buff *skb, struct net_device *dev,
+			 struct mvneta_tx_queue *txq)
+{
+	int total_len, data_left;
+	int desc_count = 0;
+	struct mvneta_port *pp = netdev_priv(dev);
+	struct tso_t tso;
+	int hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
+	int i;
+
+	/* Count needed descriptors */
+	if ((txq->count + tso_count_descs(skb)) >= txq->size)
+		return 0;
+
+	if (skb_headlen(skb) < (skb_transport_offset(skb) + tcp_hdrlen(skb))) {
+		pr_info("*** Is this even  possible???!?!?\n");
+		return 0;
+	}
+
+	/* Initialize the TSO handler, and prepare the first payload */
+	tso_start(skb, &tso);
+
+	total_len = skb->len - hdr_len;
+	while (total_len > 0) {
+		char *hdr;
+
+		data_left = min_t(int, skb_shinfo(skb)->gso_size, total_len);
+		total_len -= data_left;
+		desc_count++;
+
+		/* prepare packet headers: MAC + IP + TCP */
+		hdr = txq->tso_hdrs + txq->txq_put_index * TSO_HEADER_SIZE;
+		tso_build_hdr(skb, hdr, &tso, data_left, total_len == 0);
+
+		mvneta_tso_put_hdr(skb, pp, txq);
+
+		while (data_left > 0) {
+			int size;
+			desc_count++;
+
+			size = min_t(int, tso.size, data_left);
+
+			if (mvneta_tso_put_data(dev, txq, skb,
+						 tso.data, size,
+						 size == data_left,
+						 total_len == 0))
+				goto err_release;
+			data_left -= size;
+
+			tso_build_data(skb, &tso, size);
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
@@ -1590,6 +1720,11 @@ static int mvneta_tx(struct sk_buff *skb, struct net_device *dev)
 	if (!netif_running(dev))
 		goto out;
 
+	if (skb_is_gso(skb)) {
+		frags = mvneta_tx_tso(skb, dev, txq);
+		goto out;
+	}
+
 	frags = skb_shinfo(skb)->nr_frags + 1;
 
 	/* Get a descriptor for the first part of the packet */
@@ -2108,6 +2243,18 @@ static int mvneta_txq_init(struct mvneta_port *pp,
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
@@ -2119,6 +2266,10 @@ static void mvneta_txq_deinit(struct mvneta_port *pp,
 {
 	kfree(txq->tx_skb);
 
+	if (txq->tso_hdrs)
+		dma_free_coherent(pp->dev->dev.parent,
+				  txq->size * TSO_HEADER_SIZE,
+				  txq->tso_hdrs, txq->tso_hdrs_phys);
 	if (txq->descs)
 		dma_free_coherent(pp->dev->dev.parent,
 				  txq->size * MVNETA_DESC_ALIGNED_SIZE,
@@ -2894,7 +3045,7 @@ static int mvneta_probe(struct platform_device *pdev)
 
 	netif_napi_add(dev, &pp->napi, mvneta_poll, pp->weight);
 
-	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM;
+	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
 	dev->hw_features |= dev->features;
 	dev->vlan_features |= dev->features;
 	dev->priv_flags |= IFF_UNICAST_FLT;
-- 
1.9.1
