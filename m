From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 04/40] net: fec: add struct bufdesc_prop
Date: Thu, 28 Jan 2016 14:25:28 -0700
Message-ID: <1454016364-30985-5-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34055 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933201AbcA1V2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:28:16 -0500
Received: by mail-pa0-f45.google.com with SMTP id uo6so29715913pac.1
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:28:15 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reduces code and gains speed.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec.h      |  29 ++-
 drivers/net/ethernet/freescale/fec_main.c | 288 ++++++++++++------------------
 2 files changed, 132 insertions(+), 185 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 5144e73..6018d0e4 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -432,33 +432,34 @@ struct bufdesc_ex {
 /* Controller supports RACC register */
 #define FEC_QUIRK_HAS_RACC		(1 << 12)
 
+struct bufdesc_prop {
+	int qid;
+	/* Address of Rx and Tx buffers */
+	struct bufdesc	*base;
+	struct bufdesc	*last;
+	struct bufdesc	*cur;
+	dma_addr_t	dma;
+	unsigned short ring_size;
+	unsigned char dsize;
+	unsigned char dsize_log2;
+};
+
 struct fec_enet_priv_tx_q {
-	int index;
+	struct bufdesc_prop bd;
 	unsigned char *tx_bounce[TX_RING_SIZE];
 	struct  sk_buff *tx_skbuff[TX_RING_SIZE];
 
-	dma_addr_t	bd_dma;
-	struct bufdesc	*tx_bd_base;
-	uint tx_ring_size;
-
 	unsigned short tx_stop_threshold;
 	unsigned short tx_wake_threshold;
 
-	struct bufdesc	*cur_tx;
 	struct bufdesc	*dirty_tx;
 	char *tso_hdrs;
 	dma_addr_t tso_hdrs_dma;
 };
 
 struct fec_enet_priv_rx_q {
-	int index;
+	struct bufdesc_prop bd;
 	struct  sk_buff *rx_skbuff[RX_RING_SIZE];
-
-	dma_addr_t	bd_dma;
-	struct bufdesc	*rx_bd_base;
-	uint rx_ring_size;
-
-	struct bufdesc	*cur_rx;
 };
 
 /* The FEC buffer descriptors track the ring buffers.  The rx_bd_base and
@@ -498,8 +499,6 @@ struct fec_enet_private {
 	unsigned long work_ts;
 	unsigned long work_mdio;
 
-	unsigned short bufdesc_size;
-
 	struct	platform_device *pdev;
 
 	int	dev_id;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 8e1f2a6..feff466 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -217,86 +217,38 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
 
 #define IS_TSO_HEADER(txq, addr) \
 	((addr >= txq->tso_hdrs_dma) && \
-	(addr < txq->tso_hdrs_dma + txq->tx_ring_size * TSO_HEADER_SIZE))
+	(addr < txq->tso_hdrs_dma + txq->bd.ring_size * TSO_HEADER_SIZE))
 
 static int mii_cnt;
 
-static inline
-struct bufdesc *fec_enet_get_nextdesc(struct bufdesc *bdp,
-				      struct fec_enet_private *fep,
-				      int queue_id)
-{
-	struct bufdesc *new_bd = bdp + 1;
-	struct bufdesc_ex *ex_new_bd = (struct bufdesc_ex *)bdp + 1;
-	struct fec_enet_priv_tx_q *txq = fep->tx_queue[queue_id];
-	struct fec_enet_priv_rx_q *rxq = fep->rx_queue[queue_id];
-	struct bufdesc_ex *ex_base;
-	struct bufdesc *base;
-	int ring_size;
-
-	if (bdp >= txq->tx_bd_base) {
-		base = txq->tx_bd_base;
-		ring_size = txq->tx_ring_size;
-		ex_base = (struct bufdesc_ex *)txq->tx_bd_base;
-	} else {
-		base = rxq->rx_bd_base;
-		ring_size = rxq->rx_ring_size;
-		ex_base = (struct bufdesc_ex *)rxq->rx_bd_base;
-	}
-
-	if (fep->bufdesc_ex)
-		return (struct bufdesc *)((ex_new_bd >= (ex_base + ring_size)) ?
-			ex_base : ex_new_bd);
-	else
-		return (new_bd >= (base + ring_size)) ?
-			base : new_bd;
-}
-
-static inline
-struct bufdesc *fec_enet_get_prevdesc(struct bufdesc *bdp,
-				      struct fec_enet_private *fep,
-				      int queue_id)
-{
-	struct bufdesc *new_bd = bdp - 1;
-	struct bufdesc_ex *ex_new_bd = (struct bufdesc_ex *)bdp - 1;
-	struct fec_enet_priv_tx_q *txq = fep->tx_queue[queue_id];
-	struct fec_enet_priv_rx_q *rxq = fep->rx_queue[queue_id];
-	struct bufdesc_ex *ex_base;
-	struct bufdesc *base;
-	int ring_size;
-
-	if (bdp >= txq->tx_bd_base) {
-		base = txq->tx_bd_base;
-		ring_size = txq->tx_ring_size;
-		ex_base = (struct bufdesc_ex *)txq->tx_bd_base;
-	} else {
-		base = rxq->rx_bd_base;
-		ring_size = rxq->rx_ring_size;
-		ex_base = (struct bufdesc_ex *)rxq->rx_bd_base;
-	}
+static struct bufdesc *fec_enet_get_nextdesc(struct bufdesc *bdp,
+					     struct bufdesc_prop *bd)
+{
+	return (bdp >= bd->last) ? bd->base
+			: (struct bufdesc *)(((unsigned)bdp) + bd->dsize);
+}
 
-	if (fep->bufdesc_ex)
-		return (struct bufdesc *)((ex_new_bd < ex_base) ?
-			(ex_new_bd + ring_size) : ex_new_bd);
-	else
-		return (new_bd < base) ? (new_bd + ring_size) : new_bd;
+static struct bufdesc *fec_enet_get_prevdesc(struct bufdesc *bdp,
+					     struct bufdesc_prop *bd)
+{
+	return (bdp <= bd->base) ? bd->last
+			: (struct bufdesc *)(((unsigned)bdp) - bd->dsize);
 }
 
-static int fec_enet_get_bd_index(struct bufdesc *base, struct bufdesc *bdp,
-				struct fec_enet_private *fep)
+static int fec_enet_get_bd_index(struct bufdesc *bdp,
+				 struct bufdesc_prop *bd)
 {
-	return ((const char *)bdp - (const char *)base) / fep->bufdesc_size;
+	return ((const char *)bdp - (const char *)bd->base) >> bd->dsize_log2;
 }
 
-static int fec_enet_get_free_txdesc_num(struct fec_enet_private *fep,
-					struct fec_enet_priv_tx_q *txq)
+static int fec_enet_get_free_txdesc_num(struct fec_enet_priv_tx_q *txq)
 {
 	int entries;
 
-	entries = ((const char *)txq->dirty_tx -
-			(const char *)txq->cur_tx) / fep->bufdesc_size - 1;
+	entries = (((const char *)txq->dirty_tx -
+			(const char *)txq->bd.cur) >> txq->bd.dsize_log2) - 1;
 
-	return entries >= 0 ? entries : entries + txq->tx_ring_size;
+	return entries >= 0 ? entries : entries + txq->bd.ring_size;
 }
 
 static void swap_buffer(void *bufaddr, int len)
@@ -329,18 +281,18 @@ static void fec_dump(struct net_device *ndev)
 	pr_info("Nr     SC     addr       len  SKB\n");
 
 	txq = fep->tx_queue[0];
-	bdp = txq->tx_bd_base;
+	bdp = txq->bd.base;
 
 	do {
 		pr_info("%3u %c%c 0x%04x 0x%08lx %4u %p\n",
 			index,
-			bdp == txq->cur_tx ? 'S' : ' ',
+			bdp == txq->bd.cur ? 'S' : ' ',
 			bdp == txq->dirty_tx ? 'H' : ' ',
 			bdp->cbd_sc, bdp->cbd_bufaddr, bdp->cbd_datlen,
 			txq->tx_skbuff[index]);
-		bdp = fec_enet_get_nextdesc(bdp, fep, 0);
+		bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
 		index++;
-	} while (bdp != txq->tx_bd_base);
+	} while (bdp != txq->bd.base);
 }
 
 static inline bool is_ipv4_pkt(struct sk_buff *skb)
@@ -371,7 +323,7 @@ fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
 			     struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
-	struct bufdesc *bdp = txq->cur_tx;
+	struct bufdesc *bdp = txq->bd.cur;
 	struct bufdesc_ex *ebdp;
 	int nr_frags = skb_shinfo(skb)->nr_frags;
 	unsigned short queue = skb_get_queue_mapping(skb);
@@ -386,7 +338,7 @@ fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
 
 	for (frag = 0; frag < nr_frags; frag++) {
 		this_frag = &skb_shinfo(skb)->frags[frag];
-		bdp = fec_enet_get_nextdesc(bdp, fep, queue);
+		bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
 		ebdp = (struct bufdesc_ex *)bdp;
 
 		status = bdp->cbd_sc;
@@ -416,7 +368,7 @@ fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
 
 		bufaddr = page_address(this_frag->page.p) + this_frag->page_offset;
 
-		index = fec_enet_get_bd_index(txq->tx_bd_base, bdp, fep);
+		index = fec_enet_get_bd_index(bdp, &txq->bd);
 		if (((unsigned long) bufaddr) & fep->tx_align ||
 			fep->quirks & FEC_QUIRK_SWAP_FRAME) {
 			memcpy(txq->tx_bounce[index], bufaddr, frag_len);
@@ -442,9 +394,9 @@ fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
 
 	return bdp;
 dma_mapping_error:
-	bdp = txq->cur_tx;
+	bdp = txq->bd.cur;
 	for (i = 0; i < frag; i++) {
-		bdp = fec_enet_get_nextdesc(bdp, fep, queue);
+		bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
 		dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
 				bdp->cbd_datlen, DMA_TO_DEVICE);
 	}
@@ -466,7 +418,7 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 	unsigned int index;
 	int entries_free;
 
-	entries_free = fec_enet_get_free_txdesc_num(fep, txq);
+	entries_free = fec_enet_get_free_txdesc_num(txq);
 	if (entries_free < MAX_SKB_FRAGS + 1) {
 		dev_kfree_skb_any(skb);
 		if (net_ratelimit())
@@ -481,7 +433,7 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 	}
 
 	/* Fill in a Tx ring entry */
-	bdp = txq->cur_tx;
+	bdp = txq->bd.cur;
 	last_bdp = bdp;
 	status = bdp->cbd_sc;
 	status &= ~BD_ENET_TX_STATS;
@@ -491,7 +443,7 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 	buflen = skb_headlen(skb);
 
 	queue = skb_get_queue_mapping(skb);
-	index = fec_enet_get_bd_index(txq->tx_bd_base, bdp, fep);
+	index = fec_enet_get_bd_index(bdp, &txq->bd);
 	if (((unsigned long) bufaddr) & fep->tx_align ||
 		fep->quirks & FEC_QUIRK_SWAP_FRAME) {
 		memcpy(txq->tx_bounce[index], skb->data, buflen);
@@ -542,7 +494,7 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 		ebdp->cbd_esc = estatus;
 	}
 
-	index = fec_enet_get_bd_index(txq->tx_bd_base, last_bdp, fep);
+	index = fec_enet_get_bd_index(last_bdp, &txq->bd);
 	/* Save skb pointer */
 	txq->tx_skbuff[index] = skb;
 
@@ -556,15 +508,15 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 	bdp->cbd_sc = status;
 
 	/* If this was the last BD in the ring, start at the beginning again. */
-	bdp = fec_enet_get_nextdesc(last_bdp, fep, queue);
+	bdp = fec_enet_get_nextdesc(last_bdp, &txq->bd);
 
 	skb_tx_timestamp(skb);
 
 	/* Make sure the update to bdp and tx_skbuff are performed before
-	 * cur_tx.
+	 * txq->bd.cur.
 	 */
 	wmb();
-	txq->cur_tx = bdp;
+	txq->bd.cur = bdp;
 
 	/* Trigger transmission start */
 	writel(0, fep->hwp + FEC_X_DES_ACTIVE(queue));
@@ -695,13 +647,13 @@ static int fec_enet_txq_submit_tso(struct fec_enet_priv_tx_q *txq,
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	int hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 	int total_len, data_left;
-	struct bufdesc *bdp = txq->cur_tx;
+	struct bufdesc *bdp = txq->bd.cur;
 	unsigned short queue = skb_get_queue_mapping(skb);
 	struct tso_t tso;
 	unsigned int index = 0;
 	int ret;
 
-	if (tso_count_descs(skb) >= fec_enet_get_free_txdesc_num(fep, txq)) {
+	if (tso_count_descs(skb) >= fec_enet_get_free_txdesc_num(txq)) {
 		dev_kfree_skb_any(skb);
 		if (net_ratelimit())
 			netdev_err(ndev, "NOT enough BD for TSO!\n");
@@ -721,7 +673,7 @@ static int fec_enet_txq_submit_tso(struct fec_enet_priv_tx_q *txq,
 	while (total_len > 0) {
 		char *hdr;
 
-		index = fec_enet_get_bd_index(txq->tx_bd_base, bdp, fep);
+		index = fec_enet_get_bd_index(bdp, &txq->bd);
 		data_left = min_t(int, skb_shinfo(skb)->gso_size, total_len);
 		total_len -= data_left;
 
@@ -736,9 +688,8 @@ static int fec_enet_txq_submit_tso(struct fec_enet_priv_tx_q *txq,
 			int size;
 
 			size = min_t(int, tso.size, data_left);
-			bdp = fec_enet_get_nextdesc(bdp, fep, queue);
-			index = fec_enet_get_bd_index(txq->tx_bd_base,
-						      bdp, fep);
+			bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
+			index = fec_enet_get_bd_index(bdp, &txq->bd);
 			ret = fec_enet_txq_put_data_tso(txq, skb, ndev,
 							bdp, index,
 							tso.data, size,
@@ -751,14 +702,14 @@ static int fec_enet_txq_submit_tso(struct fec_enet_priv_tx_q *txq,
 			tso_build_data(skb, &tso, size);
 		}
 
-		bdp = fec_enet_get_nextdesc(bdp, fep, queue);
+		bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
 	}
 
 	/* Save skb pointer */
 	txq->tx_skbuff[index] = skb;
 
 	skb_tx_timestamp(skb);
-	txq->cur_tx = bdp;
+	txq->bd.cur = bdp;
 
 	/* Trigger transmission start */
 	if (!(fep->quirks & FEC_QUIRK_ERR007885) ||
@@ -796,7 +747,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	if (ret)
 		return ret;
 
-	entries_free = fec_enet_get_free_txdesc_num(fep, txq);
+	entries_free = fec_enet_get_free_txdesc_num(txq);
 	if (entries_free <= txq->tx_stop_threshold)
 		netif_tx_stop_queue(nq);
 
@@ -817,32 +768,32 @@ static void fec_enet_bd_init(struct net_device *dev)
 	for (q = 0; q < fep->num_rx_queues; q++) {
 		/* Initialize the receive buffer descriptors. */
 		rxq = fep->rx_queue[q];
-		bdp = rxq->rx_bd_base;
+		bdp = rxq->bd.base;
 
-		for (i = 0; i < rxq->rx_ring_size; i++) {
+		for (i = 0; i < rxq->bd.ring_size; i++) {
 
 			/* Initialize the BD for every fragment in the page. */
 			if (bdp->cbd_bufaddr)
 				bdp->cbd_sc = BD_ENET_RX_EMPTY;
 			else
 				bdp->cbd_sc = 0;
-			bdp = fec_enet_get_nextdesc(bdp, fep, q);
+			bdp = fec_enet_get_nextdesc(bdp, &rxq->bd);
 		}
 
 		/* Set the last buffer to wrap */
-		bdp = fec_enet_get_prevdesc(bdp, fep, q);
+		bdp = fec_enet_get_prevdesc(bdp, &rxq->bd);
 		bdp->cbd_sc |= BD_SC_WRAP;
 
-		rxq->cur_rx = rxq->rx_bd_base;
+		rxq->bd.cur = rxq->bd.base;
 	}
 
 	for (q = 0; q < fep->num_tx_queues; q++) {
 		/* ...and the same for transmit */
 		txq = fep->tx_queue[q];
-		bdp = txq->tx_bd_base;
-		txq->cur_tx = bdp;
+		bdp = txq->bd.base;
+		txq->bd.cur = bdp;
 
-		for (i = 0; i < txq->tx_ring_size; i++) {
+		for (i = 0; i < txq->bd.ring_size; i++) {
 			/* Initialize the BD for every fragment in the page. */
 			bdp->cbd_sc = 0;
 			if (txq->tx_skbuff[i]) {
@@ -850,11 +801,11 @@ static void fec_enet_bd_init(struct net_device *dev)
 				txq->tx_skbuff[i] = NULL;
 			}
 			bdp->cbd_bufaddr = 0;
-			bdp = fec_enet_get_nextdesc(bdp, fep, q);
+			bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
 		}
 
 		/* Set the last buffer to wrap */
-		bdp = fec_enet_get_prevdesc(bdp, fep, q);
+		bdp = fec_enet_get_prevdesc(bdp, &txq->bd);
 		bdp->cbd_sc |= BD_SC_WRAP;
 		txq->dirty_tx = bdp;
 	}
@@ -878,7 +829,7 @@ static void fec_enet_enable_ring(struct net_device *ndev)
 
 	for (i = 0; i < fep->num_rx_queues; i++) {
 		rxq = fep->rx_queue[i];
-		writel(rxq->bd_dma, fep->hwp + FEC_R_DES_START(i));
+		writel(rxq->bd.dma, fep->hwp + FEC_R_DES_START(i));
 		writel(PKT_MAXBLR_SIZE, fep->hwp + FEC_R_BUFF_SIZE(i));
 
 		/* enable DMA1/2 */
@@ -889,7 +840,7 @@ static void fec_enet_enable_ring(struct net_device *ndev)
 
 	for (i = 0; i < fep->num_tx_queues; i++) {
 		txq = fep->tx_queue[i];
-		writel(txq->bd_dma, fep->hwp + FEC_X_DES_START(i));
+		writel(txq->bd.dma, fep->hwp + FEC_X_DES_START(i));
 
 		/* enable DMA1/2 */
 		if (i)
@@ -907,7 +858,7 @@ static void fec_enet_reset_skb(struct net_device *ndev)
 	for (i = 0; i < fep->num_tx_queues; i++) {
 		txq = fep->tx_queue[i];
 
-		for (j = 0; j < txq->tx_ring_size; j++) {
+		for (j = 0; j < txq->bd.ring_size; j++) {
 			if (txq->tx_skbuff[j]) {
 				dev_kfree_skb_any(txq->tx_skbuff[j]);
 				txq->tx_skbuff[j] = NULL;
@@ -1218,16 +1169,16 @@ fec_enet_tx_queue(struct net_device *ndev, u16 queue_id)
 	bdp = txq->dirty_tx;
 
 	/* get next bdp of dirty_tx */
-	bdp = fec_enet_get_nextdesc(bdp, fep, queue_id);
+	bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
 
-	while (bdp != READ_ONCE(txq->cur_tx)) {
-		/* Order the load of cur_tx and cbd_sc */
+	while (bdp != READ_ONCE(txq->bd.cur)) {
+		/* Order the load of bd.cur and cbd_sc */
 		rmb();
 		status = READ_ONCE(bdp->cbd_sc);
 		if (status & BD_ENET_TX_READY)
 			break;
 
-		index = fec_enet_get_bd_index(txq->tx_bd_base, bdp, fep);
+		index = fec_enet_get_bd_index(bdp, &txq->bd);
 
 		skb = txq->tx_skbuff[index];
 		txq->tx_skbuff[index] = NULL;
@@ -1236,7 +1187,7 @@ fec_enet_tx_queue(struct net_device *ndev, u16 queue_id)
 					bdp->cbd_datlen, DMA_TO_DEVICE);
 		bdp->cbd_bufaddr = 0;
 		if (!skb) {
-			bdp = fec_enet_get_nextdesc(bdp, fep, queue_id);
+			bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
 			continue;
 		}
 
@@ -1285,19 +1236,19 @@ fec_enet_tx_queue(struct net_device *ndev, u16 queue_id)
 		txq->dirty_tx = bdp;
 
 		/* Update pointer to next buffer descriptor to be transmitted */
-		bdp = fec_enet_get_nextdesc(bdp, fep, queue_id);
+		bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
 
 		/* Since we have freed up a buffer, the ring is no longer full
 		 */
 		if (netif_queue_stopped(ndev)) {
-			entries_free = fec_enet_get_free_txdesc_num(fep, txq);
+			entries_free = fec_enet_get_free_txdesc_num(txq);
 			if (entries_free >= txq->tx_wake_threshold)
 				netif_tx_wake_queue(nq);
 		}
 	}
 
 	/* ERR006538: Keep the transmitter going */
-	if (bdp != txq->cur_tx &&
+	if (bdp != txq->bd.cur &&
 	    readl(fep->hwp + FEC_X_DES_ACTIVE(queue_id)) == 0)
 		writel(0, fep->hwp + FEC_X_DES_ACTIVE(queue_id));
 }
@@ -1362,7 +1313,7 @@ static bool fec_enet_copybreak(struct net_device *ndev, struct sk_buff **skb,
 	return true;
 }
 
-/* During a receive, the cur_rx points to the current incoming buffer.
+/* During a receive, the bd_rx.cur points to the current incoming buffer.
  * When we update through the ring, if the next incoming buffer has
  * not been given to the system, we just set the empty indicator,
  * effectively tossing the packet.
@@ -1395,7 +1346,7 @@ fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
 	/* First, grab all of the stats for the incoming packet.
 	 * These get messed up if we get called due to a busy condition.
 	 */
-	bdp = rxq->cur_rx;
+	bdp = rxq->bd.cur;
 
 	while (!((status = bdp->cbd_sc) & BD_ENET_RX_EMPTY)) {
 
@@ -1436,7 +1387,7 @@ fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
 		pkt_len = bdp->cbd_datlen;
 		ndev->stats.rx_bytes += pkt_len;
 
-		index = fec_enet_get_bd_index(rxq->rx_bd_base, bdp, fep);
+		index = fec_enet_get_bd_index(bdp, &rxq->bd);
 		skb = rxq->rx_skbuff[index];
 
 		/* The packet length includes FCS, but we don't want to
@@ -1533,7 +1484,7 @@ rx_processing_done:
 		}
 
 		/* Update BD pointer to next entry */
-		bdp = fec_enet_get_nextdesc(bdp, fep, queue_id);
+		bdp = fec_enet_get_nextdesc(bdp, &rxq->bd);
 
 		/* Doing this here will keep the FEC running while we process
 		 * incoming frames.  On a heavily loaded network, we should be
@@ -1541,7 +1492,7 @@ rx_processing_done:
 		 */
 		writel(0, fep->hwp + FEC_R_DES_ACTIVE(queue_id));
 	}
-	rxq->cur_rx = bdp;
+	rxq->bd.cur = bdp;
 	return pkt_received;
 }
 
@@ -2651,8 +2602,8 @@ static void fec_enet_free_buffers(struct net_device *ndev)
 
 	for (q = 0; q < fep->num_rx_queues; q++) {
 		rxq = fep->rx_queue[q];
-		bdp = rxq->rx_bd_base;
-		for (i = 0; i < rxq->rx_ring_size; i++) {
+		bdp = rxq->bd.base;
+		for (i = 0; i < rxq->bd.ring_size; i++) {
 			skb = rxq->rx_skbuff[i];
 			rxq->rx_skbuff[i] = NULL;
 			if (skb) {
@@ -2662,14 +2613,14 @@ static void fec_enet_free_buffers(struct net_device *ndev)
 						 DMA_FROM_DEVICE);
 				dev_kfree_skb(skb);
 			}
-			bdp = fec_enet_get_nextdesc(bdp, fep, q);
+			bdp = fec_enet_get_nextdesc(bdp, &rxq->bd);
 		}
 	}
 
 	for (q = 0; q < fep->num_tx_queues; q++) {
 		txq = fep->tx_queue[q];
-		bdp = txq->tx_bd_base;
-		for (i = 0; i < txq->tx_ring_size; i++) {
+		bdp = txq->bd.base;
+		for (i = 0; i < txq->bd.ring_size; i++) {
 			kfree(txq->tx_bounce[i]);
 			txq->tx_bounce[i] = NULL;
 			skb = txq->tx_skbuff[i];
@@ -2689,7 +2640,7 @@ static void fec_enet_free_queue(struct net_device *ndev)
 		if (fep->tx_queue[i] && fep->tx_queue[i]->tso_hdrs) {
 			txq = fep->tx_queue[i];
 			dma_free_coherent(NULL,
-					  txq->tx_ring_size * TSO_HEADER_SIZE,
+					  txq->bd.ring_size * TSO_HEADER_SIZE,
 					  txq->tso_hdrs,
 					  txq->tso_hdrs_dma);
 		}
@@ -2715,15 +2666,15 @@ static int fec_enet_alloc_queue(struct net_device *ndev)
 		}
 
 		fep->tx_queue[i] = txq;
-		txq->tx_ring_size = TX_RING_SIZE;
-		fep->total_tx_ring_size += fep->tx_queue[i]->tx_ring_size;
+		txq->bd.ring_size = TX_RING_SIZE;
+		fep->total_tx_ring_size += fep->tx_queue[i]->bd.ring_size;
 
 		txq->tx_stop_threshold = FEC_MAX_SKB_DESCS;
 		txq->tx_wake_threshold =
-				(txq->tx_ring_size - txq->tx_stop_threshold) / 2;
+			(txq->bd.ring_size - txq->tx_stop_threshold) / 2;
 
 		txq->tso_hdrs = dma_alloc_coherent(NULL,
-					txq->tx_ring_size * TSO_HEADER_SIZE,
+					txq->bd.ring_size * TSO_HEADER_SIZE,
 					&txq->tso_hdrs_dma,
 					GFP_KERNEL);
 		if (!txq->tso_hdrs) {
@@ -2740,8 +2691,8 @@ static int fec_enet_alloc_queue(struct net_device *ndev)
 			goto alloc_failed;
 		}
 
-		fep->rx_queue[i]->rx_ring_size = RX_RING_SIZE;
-		fep->total_rx_ring_size += fep->rx_queue[i]->rx_ring_size;
+		fep->rx_queue[i]->bd.ring_size = RX_RING_SIZE;
+		fep->total_rx_ring_size += fep->rx_queue[i]->bd.ring_size;
 	}
 	return ret;
 
@@ -2760,8 +2711,8 @@ fec_enet_alloc_rxq_buffers(struct net_device *ndev, unsigned int queue)
 	struct fec_enet_priv_rx_q *rxq;
 
 	rxq = fep->rx_queue[queue];
-	bdp = rxq->rx_bd_base;
-	for (i = 0; i < rxq->rx_ring_size; i++) {
+	bdp = rxq->bd.base;
+	for (i = 0; i < rxq->bd.ring_size; i++) {
 		skb = netdev_alloc_skb(ndev, FEC_ENET_RX_FRSIZE);
 		if (!skb)
 			goto err_alloc;
@@ -2779,11 +2730,11 @@ fec_enet_alloc_rxq_buffers(struct net_device *ndev, unsigned int queue)
 			ebdp->cbd_esc = BD_ENET_RX_INT;
 		}
 
-		bdp = fec_enet_get_nextdesc(bdp, fep, queue);
+		bdp = fec_enet_get_nextdesc(bdp, &rxq->bd);
 	}
 
 	/* Set the last buffer to wrap. */
-	bdp = fec_enet_get_prevdesc(bdp, fep, queue);
+	bdp = fec_enet_get_prevdesc(bdp, &rxq->bd);
 	bdp->cbd_sc |= BD_SC_WRAP;
 	return 0;
 
@@ -2801,8 +2752,8 @@ fec_enet_alloc_txq_buffers(struct net_device *ndev, unsigned int queue)
 	struct fec_enet_priv_tx_q *txq;
 
 	txq = fep->tx_queue[queue];
-	bdp = txq->tx_bd_base;
-	for (i = 0; i < txq->tx_ring_size; i++) {
+	bdp = txq->bd.base;
+	for (i = 0; i < txq->bd.ring_size; i++) {
 		txq->tx_bounce[i] = kmalloc(FEC_ENET_TX_FRSIZE, GFP_KERNEL);
 		if (!txq->tx_bounce[i])
 			goto err_alloc;
@@ -2815,11 +2766,11 @@ fec_enet_alloc_txq_buffers(struct net_device *ndev, unsigned int queue)
 			ebdp->cbd_esc = BD_ENET_TX_INT;
 		}
 
-		bdp = fec_enet_get_nextdesc(bdp, fep, queue);
+		bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
 	}
 
 	/* Set the last buffer to wrap. */
-	bdp = fec_enet_get_prevdesc(bdp, fep, queue);
+	bdp = fec_enet_get_prevdesc(bdp, &txq->bd);
 	bdp->cbd_sc |= BD_SC_WRAP;
 
 	return 0;
@@ -3110,13 +3061,15 @@ static const struct net_device_ops fec_netdev_ops = {
 static int fec_enet_init(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
-	struct fec_enet_priv_tx_q *txq;
-	struct fec_enet_priv_rx_q *rxq;
 	struct bufdesc *cbd_base;
 	dma_addr_t bd_dma;
 	int bd_size;
 	unsigned int i;
+	unsigned dsize = fep->bufdesc_ex ? sizeof(struct bufdesc_ex) :
+			sizeof(struct bufdesc);
+	unsigned dsize_log2 = __fls(dsize);
 
+	WARN_ON(dsize != (1 << dsize_log2));
 #if defined(CONFIG_ARM)
 	fep->rx_align = 0xf;
 	fep->tx_align = 0xf;
@@ -3127,12 +3080,7 @@ static int fec_enet_init(struct net_device *ndev)
 
 	fec_enet_alloc_queue(ndev);
 
-	if (fep->bufdesc_ex)
-		fep->bufdesc_size = sizeof(struct bufdesc_ex);
-	else
-		fep->bufdesc_size = sizeof(struct bufdesc);
-	bd_size = (fep->total_tx_ring_size + fep->total_rx_ring_size) *
-			fep->bufdesc_size;
+	bd_size = (fep->total_tx_ring_size + fep->total_rx_ring_size) * dsize;
 
 	/* Allocate memory for buffer descriptors. */
 	cbd_base = dmam_alloc_coherent(&fep->pdev->dev, bd_size, &bd_dma,
@@ -3150,33 +3098,33 @@ static int fec_enet_init(struct net_device *ndev)
 
 	/* Set receive and transmit descriptor base. */
 	for (i = 0; i < fep->num_rx_queues; i++) {
-		rxq = fep->rx_queue[i];
-		rxq->index = i;
-		rxq->rx_bd_base = (struct bufdesc *)cbd_base;
-		rxq->bd_dma = bd_dma;
-		if (fep->bufdesc_ex) {
-			bd_dma += sizeof(struct bufdesc_ex) * rxq->rx_ring_size;
-			cbd_base = (struct bufdesc *)
-				(((struct bufdesc_ex *)cbd_base) + rxq->rx_ring_size);
-		} else {
-			bd_dma += sizeof(struct bufdesc) * rxq->rx_ring_size;
-			cbd_base += rxq->rx_ring_size;
-		}
+		struct fec_enet_priv_rx_q *rxq = fep->rx_queue[i];
+		unsigned size = dsize * rxq->bd.ring_size;
+
+		rxq->bd.qid = i;
+		rxq->bd.base = cbd_base;
+		rxq->bd.cur = cbd_base;
+		rxq->bd.dma = bd_dma;
+		rxq->bd.dsize = dsize;
+		rxq->bd.dsize_log2 = dsize_log2;
+		bd_dma += size;
+		cbd_base = (struct bufdesc *)(((void *)cbd_base) + size);
+		rxq->bd.last = (struct bufdesc *)(((void *)cbd_base) - dsize);
 	}
 
 	for (i = 0; i < fep->num_tx_queues; i++) {
-		txq = fep->tx_queue[i];
-		txq->index = i;
-		txq->tx_bd_base = (struct bufdesc *)cbd_base;
-		txq->bd_dma = bd_dma;
-		if (fep->bufdesc_ex) {
-			bd_dma += sizeof(struct bufdesc_ex) * txq->tx_ring_size;
-			cbd_base = (struct bufdesc *)
-			 (((struct bufdesc_ex *)cbd_base) + txq->tx_ring_size);
-		} else {
-			bd_dma += sizeof(struct bufdesc) * txq->tx_ring_size;
-			cbd_base += txq->tx_ring_size;
-		}
+		struct fec_enet_priv_tx_q *txq = fep->tx_queue[i];
+		unsigned size = dsize * txq->bd.ring_size;
+
+		txq->bd.qid = i;
+		txq->bd.base = cbd_base;
+		txq->bd.cur = cbd_base;
+		txq->bd.dma = bd_dma;
+		txq->bd.dsize = dsize;
+		txq->bd.dsize_log2 = dsize_log2;
+		bd_dma += size;
+		cbd_base = (struct bufdesc *)(((void *)cbd_base) + size);
+		txq->bd.last = (struct bufdesc *)(((void *)cbd_base) - dsize);
 	}
 
 
-- 
2.5.0
