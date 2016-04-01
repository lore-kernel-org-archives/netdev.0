From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [RESEND PATCH net-next 02/13] stmmac: rework the routines to show the ring status
Date: Fri, 1 Apr 2016 11:37:26 +0200
Message-ID: <1459503457-22569-3-git-send-email-alexandre.torgue@st.com>
References: <1459503457-22569-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Lars Persson <lars.persson@axis.com>
To: <netdev@vger.kernel.org>, <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:14289 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753712AbcDAJh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 05:37:58 -0400
In-Reply-To: <1459503457-22569-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To avoid lot of check in stmmac_main for display ring management
and support the GMAC4 chip, the display_ring function is moved
into dedicated descriptor file.

Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 797a913..6cea61b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -380,6 +380,8 @@ struct stmmac_desc_ops {
 	 u64(*get_timestamp) (void *desc, u32 ats);
 	/* get rx timestamp status */
 	int (*get_rx_timestamp_status) (void *desc, u32 ats);
+	/* Display ring */
+	void (*display_ring)(void *head, unsigned int size, bool rx);
 };
 
 extern const struct stmmac_desc_ops enh_desc_ops;
diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
index cfb018c..38f19c9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -411,6 +411,26 @@ static int enh_desc_get_rx_timestamp_status(void *desc, u32 ats)
 	}
 }
 
+static void enh_desc_display_ring(void *head, unsigned int size, bool rx)
+{
+	struct dma_extended_desc *ep = (struct dma_extended_desc *)head;
+	int i;
+
+	pr_info("Extended %s descriptor ring:\n", rx ? "RX" : "TX");
+
+	for (i = 0; i < size; i++) {
+		u64 x;
+
+		x = *(u64 *)ep;
+		pr_info("%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
+			i, (unsigned int)virt_to_phys(ep),
+			(unsigned int)x, (unsigned int)(x >> 32),
+			ep->basic.des2, ep->basic.des3);
+		ep++;
+	}
+	pr_info("\n");
+}
+
 const struct stmmac_desc_ops enh_desc_ops = {
 	.tx_status = enh_desc_get_tx_status,
 	.rx_status = enh_desc_get_rx_status,
@@ -430,4 +450,5 @@ const struct stmmac_desc_ops enh_desc_ops = {
 	.get_tx_timestamp_status = enh_desc_get_tx_timestamp_status,
 	.get_timestamp = enh_desc_get_timestamp,
 	.get_rx_timestamp_status = enh_desc_get_rx_timestamp_status,
+	.display_ring = enh_desc_display_ring,
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index e13228f..b9f6e3f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -279,6 +279,26 @@ static int ndesc_get_rx_timestamp_status(void *desc, u32 ats)
 		return 1;
 }
 
+static void ndesc_display_ring(void *head, unsigned int size, bool rx)
+{
+	struct dma_desc *p = (struct dma_desc *)head;
+	int i;
+
+	pr_info("%s descriptor ring:\n", rx ? "RX" : "TX");
+
+	for (i = 0; i < size; i++) {
+		u64 x;
+
+		x = *(u64 *)p;
+		pr_info("%d [0x%x]: 0x%x 0x%x 0x%x 0x%x",
+			i, (unsigned int)virt_to_phys(p),
+			(unsigned int)x, (unsigned int)(x >> 32),
+			p->des2, p->des3);
+		p++;
+	}
+	pr_info("\n");
+}
+
 const struct stmmac_desc_ops ndesc_ops = {
 	.tx_status = ndesc_get_tx_status,
 	.rx_status = ndesc_get_rx_status,
@@ -297,4 +317,5 @@ const struct stmmac_desc_ops ndesc_ops = {
 	.get_tx_timestamp_status = ndesc_get_tx_timestamp_status,
 	.get_timestamp = ndesc_get_timestamp,
 	.get_rx_timestamp_status = ndesc_get_rx_timestamp_status,
+	.display_ring = ndesc_display_ring,
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index d3ebfea..8103527 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -883,53 +883,22 @@ static int stmmac_init_phy(struct net_device *dev)
 	return 0;
 }
 
-/**
- * stmmac_display_ring - display ring
- * @head: pointer to the head of the ring passed.
- * @size: size of the ring.
- * @extend_desc: to verify if extended descriptors are used.
- * Description: display the control/status and buffer descriptors.
- */
-static void stmmac_display_ring(void *head, int size, int extend_desc)
-{
-	int i;
-	struct dma_extended_desc *ep = (struct dma_extended_desc *)head;
-	struct dma_desc *p = (struct dma_desc *)head;
-
-	for (i = 0; i < size; i++) {
-		u64 x;
-		if (extend_desc) {
-			x = *(u64 *) ep;
-			pr_info("%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
-				i, (unsigned int)virt_to_phys(ep),
-				(unsigned int)x, (unsigned int)(x >> 32),
-				ep->basic.des2, ep->basic.des3);
-			ep++;
-		} else {
-			x = *(u64 *) p;
-			pr_info("%d [0x%x]: 0x%x 0x%x 0x%x 0x%x",
-				i, (unsigned int)virt_to_phys(p),
-				(unsigned int)x, (unsigned int)(x >> 32),
-				p->des2, p->des3);
-			p++;
-		}
-		pr_info("\n");
-	}
-}
-
 static void stmmac_display_rings(struct stmmac_priv *priv)
 {
+	void *head_rx, *head_tx;
+
 	if (priv->extend_desc) {
-		pr_info("Extended RX descriptor ring:\n");
-		stmmac_display_ring((void *)priv->dma_erx, DMA_RX_SIZE, 1);
-		pr_info("Extended TX descriptor ring:\n");
-		stmmac_display_ring((void *)priv->dma_etx, DMA_TX_SIZE, 1);
+		head_rx = (void *)priv->dma_erx;
+		head_tx = (void *)priv->dma_etx;
 	} else {
-		pr_info("RX descriptor ring:\n");
-		stmmac_display_ring((void *)priv->dma_rx, DMA_RX_SIZE, 0);
-		pr_info("TX descriptor ring:\n");
-		stmmac_display_ring((void *)priv->dma_tx, DMA_TX_SIZE, 0);
+		head_rx = (void *)priv->dma_rx;
+		head_tx = (void *)priv->dma_tx;
 	}
+
+	/* Display Rx ring */
+	priv->hw->desc->display_ring(head_rx, DMA_RX_SIZE, true);
+	/* Display Tx ring */
+	priv->hw->desc->display_ring(head_tx, DMA_TX_SIZE, false);
 }
 
 static int stmmac_set_bfsize(int mtu, int bufsize)
@@ -1996,16 +1965,18 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	priv->cur_tx = entry;
 
 	if (netif_msg_pktdata(priv)) {
+		void *tx_head;
+
 		pr_debug("%s: curr=%d dirty=%d f=%d, e=%d, first=%p, nfrags=%d",
 			 __func__, priv->cur_tx, priv->dirty_tx, first_entry,
 			 entry, first, nfrags);
 
 		if (priv->extend_desc)
-			stmmac_display_ring((void *)priv->dma_etx,
-					    DMA_TX_SIZE, 1);
+			tx_head = (void *)priv->dma_etx;
 		else
-			stmmac_display_ring((void *)priv->dma_tx,
-					    DMA_TX_SIZE, 0);
+			tx_head = (void *)priv->dma_tx;
+
+		priv->hw->desc->display_ring(tx_head, DMA_TX_SIZE, false);
 
 		pr_debug(">>> frame to be transmitted: ");
 		print_pkt(skb->data, skb->len);
@@ -2190,13 +2161,15 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 	int coe = priv->hw->rx_csum;
 
 	if (netif_msg_rx_status(priv)) {
+		void *rx_head;
+
 		pr_debug("%s: descriptor ring:\n", __func__);
 		if (priv->extend_desc)
-			stmmac_display_ring((void *)priv->dma_erx,
-					    DMA_RX_SIZE, 1);
+			rx_head = (void *)priv->dma_erx;
 		else
-			stmmac_display_ring((void *)priv->dma_rx,
-					    DMA_RX_SIZE, 0);
+			rx_head = (void *)priv->dma_rx;
+
+		priv->hw->desc->display_ring(rx_head, DMA_RX_SIZE, true);
 	}
 	while (count < limit) {
 		int status;
-- 
1.9.1
