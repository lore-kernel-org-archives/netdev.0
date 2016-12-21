From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH net-next 13/27] net: mvpp2: add and use accessors for TX/RX descriptors
Date: Wed, 21 Dec 2016 12:16:20 +0100
Message-ID: <1482318994-23488-14-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1482318994-23488-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:56130 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757006AbcLULQn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 06:16:43 -0500
In-Reply-To: <1482318994-23488-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PPv2.2 IP has a different TX and RX descriptor layout compared to
PPv2.1. In order to prepare for the introduction of PPv2.2 support in
mvpp2, this commit adds accessors for the different fields of the TX
and RX descriptors, and changes the code to use them.

For now, the mvpp2_port argument passed to the accessors is not used,
but it will be used in follow-up to update the descriptor according to
the version of the IP being used.

Apart from the mechanical changes to use the newly introduced
accessors, a few other changes, needed to use the accessors, are made:

 - The mvpp2_txq_inc_put() function now takes a mvpp2_port as first
   argument, as it is needed to use the accessors.

 - Similarly, the mvpp2_bm_cookie_build() gains a mvpp2_port first
   argument, for the same reason.

 - In mvpp2_rx_error(), instead of accessing the RX descriptor in each
   case of the switch, we introduce a local variable to store the
   packet size.

 - Similarly, in mvpp2_buff_hdr_rx(), we introduce a local "cookie"
   variable to store the RX descriptor cookie, rather than accessing
   it from the descriptor each time.

 - In mvpp2_tx_frag_process() and mvpp2_tx() instead of accessing the
   packet size from the TX descriptor, we use the actual value
   available in the function, which is used to set the TX descriptor
   packet size a few lines before.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 187 +++++++++++++++++++++++++----------
 1 file changed, 137 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 55ebfb3..e35871f 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -967,6 +967,77 @@ static u32 mvpp2_read(struct mvpp2 *priv, u32 offset)
 	return readl(priv->base + offset);
 }
 
+static dma_addr_t mvpp2_txdesc_phys_addr_get(struct mvpp2_port *port,
+					     struct mvpp2_tx_desc *tx_desc)
+{
+	return tx_desc->buf_phys_addr;
+}
+
+static void mvpp2_txdesc_phys_addr_set(struct mvpp2_port *port,
+				       struct mvpp2_tx_desc *tx_desc,
+				       dma_addr_t phys_addr)
+{
+	tx_desc->buf_phys_addr = phys_addr;
+}
+
+static size_t mvpp2_txdesc_size_get(struct mvpp2_port *port,
+				    struct mvpp2_tx_desc *tx_desc)
+{
+	return tx_desc->data_size;
+}
+
+static void mvpp2_txdesc_size_set(struct mvpp2_port *port,
+				  struct mvpp2_tx_desc *tx_desc,
+				  size_t size)
+{
+	tx_desc->data_size = size;
+}
+
+static void mvpp2_txdesc_txq_set(struct mvpp2_port *port,
+				 struct mvpp2_tx_desc *tx_desc,
+				 unsigned int txq)
+{
+	tx_desc->phys_txq = txq;
+}
+
+static void mvpp2_txdesc_cmd_set(struct mvpp2_port *port,
+				 struct mvpp2_tx_desc *tx_desc,
+				 unsigned int command)
+{
+	tx_desc->command = command;
+}
+
+static void mvpp2_txdesc_offset_set(struct mvpp2_port *port,
+				    struct mvpp2_tx_desc *tx_desc,
+				    unsigned int offset)
+{
+	tx_desc->packet_offset = offset;
+}
+
+static dma_addr_t mvpp2_rxdesc_phys_addr_get(struct mvpp2_port *port,
+					     struct mvpp2_rx_desc *rx_desc)
+{
+	return rx_desc->buf_phys_addr;
+}
+
+static unsigned long mvpp2_rxdesc_virt_addr_get(struct mvpp2_port *port,
+						struct mvpp2_rx_desc *rx_desc)
+{
+	return rx_desc->buf_cookie;
+}
+
+static size_t mvpp2_rxdesc_size_get(struct mvpp2_port *port,
+				    struct mvpp2_rx_desc *rx_desc)
+{
+	return rx_desc->data_size;
+}
+
+static u32 mvpp2_rxdesc_status_get(struct mvpp2_port *port,
+				   struct mvpp2_rx_desc *rx_desc)
+{
+	return rx_desc->status;
+}
+
 static void mvpp2_txq_inc_get(struct mvpp2_txq_pcpu *txq_pcpu)
 {
 	txq_pcpu->txq_get_index++;
@@ -974,15 +1045,16 @@ static void mvpp2_txq_inc_get(struct mvpp2_txq_pcpu *txq_pcpu)
 		txq_pcpu->txq_get_index = 0;
 }
 
-static void mvpp2_txq_inc_put(struct mvpp2_txq_pcpu *txq_pcpu,
+static void mvpp2_txq_inc_put(struct mvpp2_port *port,
+			      struct mvpp2_txq_pcpu *txq_pcpu,
 			      struct sk_buff *skb,
 			      struct mvpp2_tx_desc *tx_desc)
 {
 	struct mvpp2_txq_pcpu_buf *tx_buf =
 		txq_pcpu->buffs + txq_pcpu->txq_put_index;
 	tx_buf->skb = skb;
-	tx_buf->size = tx_desc->data_size;
-	tx_buf->phys = tx_desc->buf_phys_addr;
+	tx_buf->size = mvpp2_txdesc_size_get(port, tx_desc);
+	tx_buf->phys = mvpp2_txdesc_phys_addr_get(port, tx_desc);
 	txq_pcpu->txq_put_index++;
 	if (txq_pcpu->txq_put_index == txq_pcpu->size)
 		txq_pcpu->txq_put_index = 0;
@@ -4147,11 +4219,15 @@ static void mvpp2_rxq_offset_set(struct mvpp2_port *port,
 }
 
 /* Obtain BM cookie information from descriptor */
-static u32 mvpp2_bm_cookie_build(struct mvpp2_rx_desc *rx_desc)
+static u32 mvpp2_bm_cookie_build(struct mvpp2_port *port,
+				 struct mvpp2_rx_desc *rx_desc)
 {
-	int pool = (rx_desc->status & MVPP2_RXD_BM_POOL_ID_MASK) >>
-		   MVPP2_RXD_BM_POOL_ID_OFFS;
 	int cpu = smp_processor_id();
+	int pool;
+
+	pool = (mvpp2_rxdesc_status_get(port, rx_desc) &
+		MVPP2_RXD_BM_POOL_ID_MASK) >>
+		MVPP2_RXD_BM_POOL_ID_OFFS;
 
 	return ((pool & 0xFF) << MVPP2_BM_COOKIE_POOL_OFFS) |
 	       ((cpu & 0xFF) << MVPP2_BM_COOKIE_CPU_OFFS);
@@ -4580,10 +4656,11 @@ static void mvpp2_rxq_drop_pkts(struct mvpp2_port *port,
 
 	for (i = 0; i < rx_received; i++) {
 		struct mvpp2_rx_desc *rx_desc = mvpp2_rxq_next_desc_get(rxq);
-		u32 bm = mvpp2_bm_cookie_build(rx_desc);
+		u32 bm = mvpp2_bm_cookie_build(port, rx_desc);
 
-		mvpp2_pool_refill(port, bm, rx_desc->buf_phys_addr,
-				  rx_desc->buf_cookie);
+		mvpp2_pool_refill(port, bm,
+				  mvpp2_rxdesc_phys_addr_get(port, rx_desc),
+				  mvpp2_rxdesc_virt_addr_get(port, rx_desc));
 	}
 	mvpp2_rxq_status_update(port, rxq->id, rx_received, rx_received);
 }
@@ -4972,20 +5049,21 @@ static enum hrtimer_restart mvpp2_hr_timer_cb(struct hrtimer *timer)
 static void mvpp2_rx_error(struct mvpp2_port *port,
 			   struct mvpp2_rx_desc *rx_desc)
 {
-	u32 status = rx_desc->status;
+	u32 status = mvpp2_rxdesc_status_get(port, rx_desc);
+	size_t sz = mvpp2_rxdesc_size_get(port, rx_desc);
 
 	switch (status & MVPP2_RXD_ERR_CODE_MASK) {
 	case MVPP2_RXD_ERR_CRC:
-		netdev_err(port->dev, "bad rx status %08x (crc error), size=%d\n",
-			   status, rx_desc->data_size);
+		netdev_err(port->dev, "bad rx status %08x (crc error), size=%zu\n",
+			   status, sz);
 		break;
 	case MVPP2_RXD_ERR_OVERRUN:
-		netdev_err(port->dev, "bad rx status %08x (overrun error), size=%d\n",
-			   status, rx_desc->data_size);
+		netdev_err(port->dev, "bad rx status %08x (overrun error), size=%zu\n",
+			   status, sz);
 		break;
 	case MVPP2_RXD_ERR_RESOURCE:
-		netdev_err(port->dev, "bad rx status %08x (resource error), size=%d\n",
-			   status, rx_desc->data_size);
+		netdev_err(port->dev, "bad rx status %08x (resource error), size=%zu\n",
+			   status, sz);
 		break;
 	}
 }
@@ -5061,7 +5139,7 @@ static void mvpp2_buff_hdr_rx(struct mvpp2_port *port,
 {
 	struct mvpp2_buff_hdr *buff_hdr;
 	struct sk_buff *skb;
-	u32 rx_status = rx_desc->status;
+	u32 rx_status = mvpp2_rxdesc_status_get(port, rx_desc);
 	dma_addr_t buff_phys_addr;
 	unsigned long buff_virt_addr;
 	dma_addr_t buff_phys_addr_next;
@@ -5071,8 +5149,8 @@ static void mvpp2_buff_hdr_rx(struct mvpp2_port *port,
 
 	pool_id = (rx_status & MVPP2_RXD_BM_POOL_ID_MASK) >>
 		   MVPP2_RXD_BM_POOL_ID_OFFS;
-	buff_phys_addr = rx_desc->buf_phys_addr;
-	buff_virt_addr = rx_desc->buf_cookie;
+	buff_phys_addr = mvpp2_rxdesc_phys_addr_get(port, rx_desc);
+	buff_virt_addr = mvpp2_rxdesc_virt_addr_get(port, rx_desc);
 
 	do {
 		skb = (struct sk_buff *)buff_virt_addr;
@@ -5119,12 +5197,13 @@ static int mvpp2_rx(struct mvpp2_port *port, int rx_todo,
 		void *data;
 
 		rx_done++;
-		rx_status = rx_desc->status;
-		rx_bytes = rx_desc->data_size - MVPP2_MH_SIZE;
-		phys_addr = rx_desc->buf_phys_addr;
-		data = (void *)rx_desc->buf_cookie;
+		rx_status = mvpp2_rxdesc_status_get(port, rx_desc);
+		rx_bytes = mvpp2_rxdesc_size_get(port, rx_desc);
+		rx_bytes -= MVPP2_MH_SIZE;
+		phys_addr = mvpp2_rxdesc_phys_addr_get(port, rx_desc);
+		data = (void *)mvpp2_rxdesc_virt_addr_get(port, rx_desc);
 
-		bm = mvpp2_bm_cookie_build(rx_desc);
+		bm = mvpp2_bm_cookie_build(port, rx_desc);
 		pool = mvpp2_bm_cookie_pool_get(bm);
 		bm_pool = &port->priv->bm_pools[pool];
 		/* Check if buffer header is used */
@@ -5143,9 +5222,8 @@ static int mvpp2_rx(struct mvpp2_port *port, int rx_todo,
 			dev->stats.rx_errors++;
 			mvpp2_rx_error(port, rx_desc);
 			/* Return the buffer to the pool */
-
-			mvpp2_pool_refill(port, bm, rx_desc->buf_phys_addr,
-					  rx_desc->buf_cookie);
+			mvpp2_pool_refill(port, bm, phys_addr,
+					  (unsigned long)data);
 			continue;
 		}
 
@@ -5197,11 +5275,15 @@ static int mvpp2_rx(struct mvpp2_port *port, int rx_todo,
 }
 
 static inline void
-tx_desc_unmap_put(struct device *dev, struct mvpp2_tx_queue *txq,
+tx_desc_unmap_put(struct mvpp2_port *port, struct mvpp2_tx_queue *txq,
 		  struct mvpp2_tx_desc *desc)
 {
-	dma_unmap_single(dev, desc->buf_phys_addr,
-			 desc->data_size, DMA_TO_DEVICE);
+	dma_addr_t buf_phys_addr =
+		mvpp2_txdesc_phys_addr_get(port, desc);
+	size_t buf_sz =
+		mvpp2_txdesc_size_get(port, desc);
+	dma_unmap_single(port->dev->dev.parent, buf_phys_addr,
+			 buf_sz, DMA_TO_DEVICE);
 	mvpp2_txq_desc_put(txq);
 }
 
@@ -5220,28 +5302,31 @@ static int mvpp2_tx_frag_process(struct mvpp2_port *port, struct sk_buff *skb,
 		void *addr = page_address(frag->page.p) + frag->page_offset;
 
 		tx_desc = mvpp2_txq_next_desc_get(aggr_txq);
-		tx_desc->phys_txq = txq->id;
-		tx_desc->data_size = frag->size;
+		mvpp2_txdesc_txq_set(port, tx_desc, txq->id);
+		mvpp2_txdesc_size_set(port, tx_desc, frag->size);
 
 		buf_phys_addr = dma_map_single(port->dev->dev.parent, addr,
-					       tx_desc->data_size,
+					       frag->size,
 					       DMA_TO_DEVICE);
 		if (dma_mapping_error(port->dev->dev.parent, buf_phys_addr)) {
 			mvpp2_txq_desc_put(txq);
 			goto error;
 		}
 
-		tx_desc->packet_offset = buf_phys_addr & MVPP2_TX_DESC_ALIGN;
-		tx_desc->buf_phys_addr = buf_phys_addr & (~MVPP2_TX_DESC_ALIGN);
+		mvpp2_txdesc_phys_addr_set(port, tx_desc,
+					   buf_phys_addr & MVPP2_TX_DESC_ALIGN);
+		mvpp2_txdesc_offset_set(port, tx_desc,
+					buf_phys_addr & (~MVPP2_TX_DESC_ALIGN));
 
 		if (i == (skb_shinfo(skb)->nr_frags - 1)) {
 			/* Last descriptor */
-			tx_desc->command = MVPP2_TXD_L_DESC;
-			mvpp2_txq_inc_put(txq_pcpu, skb, tx_desc);
+			mvpp2_txdesc_cmd_set(port, tx_desc,
+					     MVPP2_TXD_L_DESC);
+			mvpp2_txq_inc_put(port, txq_pcpu, skb, tx_desc);
 		} else {
 			/* Descriptor in the middle: Not First, Not Last */
-			tx_desc->command = 0;
-			mvpp2_txq_inc_put(txq_pcpu, NULL, tx_desc);
+			mvpp2_txdesc_cmd_set(port, tx_desc, 0);
+			mvpp2_txq_inc_put(port, txq_pcpu, NULL, tx_desc);
 		}
 	}
 
@@ -5253,7 +5338,7 @@ static int mvpp2_tx_frag_process(struct mvpp2_port *port, struct sk_buff *skb,
 	 */
 	for (i = i - 1; i >= 0; i--) {
 		tx_desc = txq->descs + i;
-		tx_desc_unmap_put(port->dev->dev.parent, txq, tx_desc);
+		tx_desc_unmap_put(port, txq, tx_desc);
 	}
 
 	return -ENOMEM;
@@ -5288,35 +5373,37 @@ static int mvpp2_tx(struct sk_buff *skb, struct net_device *dev)
 
 	/* Get a descriptor for the first part of the packet */
 	tx_desc = mvpp2_txq_next_desc_get(aggr_txq);
-	tx_desc->phys_txq = txq->id;
-	tx_desc->data_size = skb_headlen(skb);
+	mvpp2_txdesc_txq_set(port, tx_desc, txq->id);
+	mvpp2_txdesc_size_set(port, tx_desc, skb_headlen(skb));
 
 	buf_phys_addr = dma_map_single(dev->dev.parent, skb->data,
-				       tx_desc->data_size, DMA_TO_DEVICE);
+				       skb_headlen(skb), DMA_TO_DEVICE);
 	if (unlikely(dma_mapping_error(dev->dev.parent, buf_phys_addr))) {
 		mvpp2_txq_desc_put(txq);
 		frags = 0;
 		goto out;
 	}
-	tx_desc->packet_offset = buf_phys_addr & MVPP2_TX_DESC_ALIGN;
-	tx_desc->buf_phys_addr = buf_phys_addr & ~MVPP2_TX_DESC_ALIGN;
+	mvpp2_txdesc_offset_set(port, tx_desc,
+				buf_phys_addr & MVPP2_TX_DESC_ALIGN);
+	mvpp2_txdesc_phys_addr_set(port, tx_desc,
+				   buf_phys_addr & ~MVPP2_TX_DESC_ALIGN);
 
 	tx_cmd = mvpp2_skb_tx_csum(port, skb);
 
 	if (frags == 1) {
 		/* First and Last descriptor */
 		tx_cmd |= MVPP2_TXD_F_DESC | MVPP2_TXD_L_DESC;
-		tx_desc->command = tx_cmd;
-		mvpp2_txq_inc_put(txq_pcpu, skb, tx_desc);
+		mvpp2_txdesc_cmd_set(port, tx_desc, tx_cmd);
+		mvpp2_txq_inc_put(port, txq_pcpu, skb, tx_desc);
 	} else {
 		/* First but not Last */
 		tx_cmd |= MVPP2_TXD_F_DESC | MVPP2_TXD_PADDING_DISABLE;
-		tx_desc->command = tx_cmd;
-		mvpp2_txq_inc_put(txq_pcpu, NULL, tx_desc);
+		mvpp2_txdesc_cmd_set(port, tx_desc, tx_cmd);
+		mvpp2_txq_inc_put(port, txq_pcpu, NULL, tx_desc);
 
 		/* Continue with other skb fragments */
 		if (mvpp2_tx_frag_process(port, skb, aggr_txq, txq)) {
-			tx_desc_unmap_put(port->dev->dev.parent, txq, tx_desc);
+			tx_desc_unmap_put(port, txq, tx_desc);
 			frags = 0;
 			goto out;
 		}
-- 
2.7.4
