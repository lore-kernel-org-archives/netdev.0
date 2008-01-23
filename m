From: Olof Johansson <olof@lixom.net>
Subject: [PATCH 2/3] pasemi_mac: add support for setting MTU
Date: Wed, 23 Jan 2008 13:56:47 -0600
Message-ID: <20080123195647.GC32380@lixom.net>
References: <20080123195537.GA32380@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:46901 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751702AbYAWTx3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2008 14:53:29 -0500
Content-Disposition: inline
In-Reply-To: <20080123195537.GA32380@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently keeping it at 1500 bytes or below since jumbo frames need
special checksum offload on TX.

Signed-off-by: Olof Johansson <olof@lixom.net>

diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 59dea3f..059c6b0 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -62,6 +62,10 @@
 
 #define LRO_MAX_AGGR 64
 
+#define PE_MIN_MTU	64
+#define PE_MAX_MTU	1500
+#define PE_DEF_MTU	ETH_DATA_LEN
+
 #define DEFAULT_MSG_ENABLE	  \
 	(NETIF_MSG_DRV		| \
 	 NETIF_MSG_PROBE	| \
@@ -82,8 +86,6 @@
 				 & ((ring)->size - 1))
 #define RING_AVAIL(ring)	((ring->size) - RING_USED(ring))
 
-#define BUF_SIZE 1646 /* 1500 MTU + ETH_HLEN + VLAN_HLEN + 2 64B cachelines */
-
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR ("Olof Johansson <olof@lixom.net>");
 MODULE_DESCRIPTION("PA Semi PWRficient Ethernet driver");
@@ -175,6 +177,24 @@ static int mac_to_intf(struct pasemi_mac *mac)
 	return -1;
 }
 
+static void pasemi_mac_intf_disable(struct pasemi_mac *mac)
+{
+	unsigned int flags;
+
+	flags = read_mac_reg(mac, PAS_MAC_CFG_PCFG);
+	flags &= ~PAS_MAC_CFG_PCFG_PE;
+	write_mac_reg(mac, PAS_MAC_CFG_PCFG, flags);
+}
+
+static void pasemi_mac_intf_enable(struct pasemi_mac *mac)
+{
+	unsigned int flags;
+
+	flags = read_mac_reg(mac, PAS_MAC_CFG_PCFG);
+	flags |= PAS_MAC_CFG_PCFG_PE;
+	write_mac_reg(mac, PAS_MAC_CFG_PCFG, flags);
+}
+
 static int pasemi_get_mac_addr(struct pasemi_mac *mac)
 {
 	struct pci_dev *pdev = mac->pdev;
@@ -480,7 +500,7 @@ static void pasemi_mac_free_tx_resources(struct pasemi_mac *mac)
 
 }
 
-static void pasemi_mac_free_rx_resources(struct pasemi_mac *mac)
+static void pasemi_mac_free_rx_buffers(struct pasemi_mac *mac)
 {
 	struct pasemi_mac_rxring *rx = rx_ring(mac);
 	unsigned int i;
@@ -500,7 +520,12 @@ static void pasemi_mac_free_rx_resources(struct pasemi_mac *mac)
 	}
 
 	for (i = 0; i < RX_RING_SIZE; i++)
-		RX_DESC(rx, i) = 0;
+		RX_BUFF(rx, i) = 0;
+}
+
+static void pasemi_mac_free_rx_resources(struct pasemi_mac *mac)
+{
+	pasemi_mac_free_rx_buffers(mac);
 
 	dma_free_coherent(&mac->dma_pdev->dev, RX_RING_SIZE * sizeof(u64),
 			  rx_ring(mac)->buffers, rx_ring(mac)->buf_dma);
@@ -530,14 +555,14 @@ static void pasemi_mac_replenish_rx_ring(const struct net_device *dev,
 		/* Entry in use? */
 		WARN_ON(*buff);
 
-		skb = dev_alloc_skb(BUF_SIZE);
+		skb = dev_alloc_skb(mac->bufsz);
 		skb_reserve(skb, LOCAL_SKB_ALIGN);
 
 		if (unlikely(!skb))
 			break;
 
 		dma = pci_map_single(mac->dma_pdev, skb->data,
-				     BUF_SIZE - LOCAL_SKB_ALIGN,
+				     mac->bufsz - LOCAL_SKB_ALIGN,
 				     PCI_DMA_FROMDEVICE);
 
 		if (unlikely(dma_mapping_error(dma))) {
@@ -547,7 +572,7 @@ static void pasemi_mac_replenish_rx_ring(const struct net_device *dev,
 
 		info->skb = skb;
 		info->dma = dma;
-		*buff = XCT_RXB_LEN(BUF_SIZE) | XCT_RXB_ADDR(dma);
+		*buff = XCT_RXB_LEN(mac->bufsz) | XCT_RXB_ADDR(dma);
 		fill++;
 	}
 
@@ -677,7 +702,7 @@ static int pasemi_mac_clean_rx(struct pasemi_mac_rxring *rx,
 
 		len = (macrx & XCT_MACRX_LLEN_M) >> XCT_MACRX_LLEN_S;
 
-		pci_unmap_single(pdev, dma, BUF_SIZE-LOCAL_SKB_ALIGN,
+		pci_unmap_single(pdev, dma, mac->bufsz - LOCAL_SKB_ALIGN,
 				 PCI_DMA_FROMDEVICE);
 
 		if (macrx & XCT_MACRX_CRC) {
@@ -901,24 +926,6 @@ static irqreturn_t pasemi_mac_tx_intr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-static void pasemi_mac_intf_disable(struct pasemi_mac *mac)
-{
-	unsigned int flags;
-
-	flags = read_mac_reg(mac, PAS_MAC_CFG_PCFG);
-	flags &= ~PAS_MAC_CFG_PCFG_PE;
-	write_mac_reg(mac, PAS_MAC_CFG_PCFG, flags);
-}
-
-static void pasemi_mac_intf_enable(struct pasemi_mac *mac)
-{
-	unsigned int flags;
-
-	flags = read_mac_reg(mac, PAS_MAC_CFG_PCFG);
-	flags |= PAS_MAC_CFG_PCFG_PE;
-	write_mac_reg(mac, PAS_MAC_CFG_PCFG, flags);
-}
-
 static void pasemi_adjust_link(struct net_device *dev)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
@@ -1175,11 +1182,71 @@ out_rx_resources:
 
 #define MAX_RETRIES 5000
 
+static void pasemi_mac_pause_txchan(struct pasemi_mac *mac)
+{
+	unsigned int sta, retries;
+	int txch = tx_ring(mac)->chan.chno;
+
+	write_dma_reg(PAS_DMA_TXCHAN_TCMDSTA(txch),
+		      PAS_DMA_TXCHAN_TCMDSTA_ST);
+
+	for (retries = 0; retries < MAX_RETRIES; retries++) {
+		sta = read_dma_reg(PAS_DMA_TXCHAN_TCMDSTA(txch));
+		if (!(sta & PAS_DMA_TXCHAN_TCMDSTA_ACT))
+			break;
+		cond_resched();
+	}
+
+	if (sta & PAS_DMA_TXCHAN_TCMDSTA_ACT)
+		dev_err(&mac->dma_pdev->dev,
+			"Failed to stop tx channel, tcmdsta %08x\n", sta);
+
+	write_dma_reg(PAS_DMA_TXCHAN_TCMDSTA(txch), 0);
+}
+
+static void pasemi_mac_pause_rxchan(struct pasemi_mac *mac)
+{
+	unsigned int sta, retries;
+	int rxch = rx_ring(mac)->chan.chno;
+
+	write_dma_reg(PAS_DMA_RXCHAN_CCMDSTA(rxch),
+		      PAS_DMA_RXCHAN_CCMDSTA_ST);
+	for (retries = 0; retries < MAX_RETRIES; retries++) {
+		sta = read_dma_reg(PAS_DMA_RXCHAN_CCMDSTA(rxch));
+		if (!(sta & PAS_DMA_RXCHAN_CCMDSTA_ACT))
+			break;
+		cond_resched();
+	}
+
+	if (sta & PAS_DMA_RXCHAN_CCMDSTA_ACT)
+		dev_err(&mac->dma_pdev->dev,
+			"Failed to stop rx channel, ccmdsta 08%x\n", sta);
+	write_dma_reg(PAS_DMA_RXCHAN_CCMDSTA(rxch), 0);
+}
+
+static void pasemi_mac_pause_rxint(struct pasemi_mac *mac)
+{
+	unsigned int sta, retries;
+
+	write_dma_reg(PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
+		      PAS_DMA_RXINT_RCMDSTA_ST);
+	for (retries = 0; retries < MAX_RETRIES; retries++) {
+		sta = read_dma_reg(PAS_DMA_RXINT_RCMDSTA(mac->dma_if));
+		if (!(sta & PAS_DMA_RXINT_RCMDSTA_ACT))
+			break;
+		cond_resched();
+	}
+
+	if (sta & PAS_DMA_RXINT_RCMDSTA_ACT)
+		dev_err(&mac->dma_pdev->dev,
+			"Failed to stop rx interface, rcmdsta %08x\n", sta);
+	write_dma_reg(PAS_DMA_RXINT_RCMDSTA(mac->dma_if), 0);
+}
+
 static int pasemi_mac_close(struct net_device *dev)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
 	unsigned int sta;
-	int retries;
 	int rxch, txch;
 
 	rxch = rx_ring(mac)->chan.chno;
@@ -1217,51 +1284,9 @@ static int pasemi_mac_close(struct net_device *dev)
 	pasemi_mac_clean_tx(tx_ring(mac));
 	pasemi_mac_clean_rx(rx_ring(mac), RX_RING_SIZE);
 
-	/* Disable interface */
-	write_dma_reg(PAS_DMA_TXCHAN_TCMDSTA(txch),
-		      PAS_DMA_TXCHAN_TCMDSTA_ST);
-	write_dma_reg( PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
-		      PAS_DMA_RXINT_RCMDSTA_ST);
-	write_dma_reg(PAS_DMA_RXCHAN_CCMDSTA(rxch),
-		      PAS_DMA_RXCHAN_CCMDSTA_ST);
-
-	for (retries = 0; retries < MAX_RETRIES; retries++) {
-		sta = read_dma_reg(PAS_DMA_TXCHAN_TCMDSTA(rxch));
-		if (!(sta & PAS_DMA_TXCHAN_TCMDSTA_ACT))
-			break;
-		cond_resched();
-	}
-
-	if (sta & PAS_DMA_TXCHAN_TCMDSTA_ACT)
-		dev_err(&mac->dma_pdev->dev, "Failed to stop tx channel\n");
-
-	for (retries = 0; retries < MAX_RETRIES; retries++) {
-		sta = read_dma_reg(PAS_DMA_RXCHAN_CCMDSTA(rxch));
-		if (!(sta & PAS_DMA_RXCHAN_CCMDSTA_ACT))
-			break;
-		cond_resched();
-	}
-
-	if (sta & PAS_DMA_RXCHAN_CCMDSTA_ACT)
-		dev_err(&mac->dma_pdev->dev, "Failed to stop rx channel\n");
-
-	for (retries = 0; retries < MAX_RETRIES; retries++) {
-		sta = read_dma_reg(PAS_DMA_RXINT_RCMDSTA(mac->dma_if));
-		if (!(sta & PAS_DMA_RXINT_RCMDSTA_ACT))
-			break;
-		cond_resched();
-	}
-
-	if (sta & PAS_DMA_RXINT_RCMDSTA_ACT)
-		dev_err(&mac->dma_pdev->dev, "Failed to stop rx interface\n");
-
-	/* Then, disable the channel. This must be done separately from
-	 * stopping, since you can't disable when active.
-	 */
-
-	write_dma_reg(PAS_DMA_TXCHAN_TCMDSTA(txch), 0);
-	write_dma_reg(PAS_DMA_RXCHAN_CCMDSTA(rxch), 0);
-	write_dma_reg(PAS_DMA_RXINT_RCMDSTA(mac->dma_if), 0);
+	pasemi_mac_pause_txchan(mac);
+	pasemi_mac_pause_rxint(mac);
+	pasemi_mac_pause_rxchan(mac);
 
 	free_irq(mac->tx->chan.irq, mac->tx);
 	free_irq(mac->rx->chan.irq, mac->rx);
@@ -1415,6 +1440,62 @@ static int pasemi_mac_poll(struct napi_struct *napi, int budget)
 	return pkts;
 }
 
+static int pasemi_mac_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct pasemi_mac *mac = netdev_priv(dev);
+	unsigned int reg;
+	unsigned int rcmdsta;
+	int running;
+
+	if (new_mtu < PE_MIN_MTU || new_mtu > PE_MAX_MTU)
+		return -EINVAL;
+
+	running = netif_running(dev);
+
+	if (running) {
+		/* Need to stop the interface, clean out all already
+		 * received buffers, free all unused buffers on the RX
+		 * interface ring, then finally re-fill the rx ring with
+		 * the new-size buffers and restart.
+		 */
+
+		napi_disable(&mac->napi);
+		netif_tx_disable(dev);
+		pasemi_mac_intf_disable(mac);
+
+		rcmdsta = read_dma_reg(PAS_DMA_RXINT_RCMDSTA(mac->dma_if));
+		pasemi_mac_pause_rxint(mac);
+		pasemi_mac_clean_rx(rx_ring(mac), RX_RING_SIZE);
+		pasemi_mac_free_rx_buffers(mac);
+	}
+
+	/* Change maxf, i.e. what size frames are accepted.
+	 * Need room for ethernet header and CRC word
+	 */
+	reg = read_mac_reg(mac, PAS_MAC_CFG_MACCFG);
+	reg &= ~PAS_MAC_CFG_MACCFG_MAXF_M;
+	reg |= PAS_MAC_CFG_MACCFG_MAXF(new_mtu + ETH_HLEN + 4);
+	write_mac_reg(mac, PAS_MAC_CFG_MACCFG, reg);
+
+	dev->mtu = new_mtu;
+	/* MTU + ETH_HLEN + VLAN_HLEN + 2 64B cachelines */
+	mac->bufsz = new_mtu + ETH_HLEN + ETH_FCS_LEN + LOCAL_SKB_ALIGN + 128;
+
+	if (running) {
+		write_dma_reg(PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
+			      rcmdsta | PAS_DMA_RXINT_RCMDSTA_EN);
+
+		rx_ring(mac)->next_to_fill = 0;
+		pasemi_mac_replenish_rx_ring(dev, RX_RING_SIZE-1);
+
+		napi_enable(&mac->napi);
+		netif_start_queue(dev);
+		pasemi_mac_intf_enable(mac);
+	}
+
+	return 0;
+}
+
 static int __devinit
 pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -1503,6 +1584,11 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->hard_start_xmit = pasemi_mac_start_tx;
 	dev->set_multicast_list = pasemi_mac_set_rx_mode;
 	dev->set_mac_address = pasemi_mac_set_mac_addr;
+	dev->mtu = PE_DEF_MTU;
+	/* 1500 MTU + ETH_HLEN + VLAN_HLEN + 2 64B cachelines */
+	mac->bufsz = dev->mtu + ETH_HLEN + ETH_FCS_LEN + LOCAL_SKB_ALIGN + 128;
+
+	dev->change_mtu = pasemi_mac_change_mtu;
 
 	if (err)
 		goto out;
diff --git a/drivers/net/pasemi_mac.h b/drivers/net/pasemi_mac.h
index 39d3259..99e7b93 100644
--- a/drivers/net/pasemi_mac.h
+++ b/drivers/net/pasemi_mac.h
@@ -59,6 +59,7 @@ struct pasemi_mac {
 	struct phy_device *phydev;
 	struct napi_struct napi;
 
+	int		bufsz; /* RX ring buffer size */
 	u8		type;
 #define MAC_TYPE_GMAC	1
 #define MAC_TYPE_XAUI	2
@@ -96,6 +97,7 @@ struct pasemi_mac_buffer {
 /* MAC CFG register offsets */
 enum {
 	PAS_MAC_CFG_PCFG = 0x80,
+	PAS_MAC_CFG_MACCFG = 0x84,
 	PAS_MAC_CFG_ADR0 = 0x8c,
 	PAS_MAC_CFG_ADR1 = 0x90,
 	PAS_MAC_CFG_TXP = 0x98,
@@ -132,6 +134,18 @@ enum {
 #define PAS_MAC_CFG_PCFG_SPD_100M	0x00000001
 #define PAS_MAC_CFG_PCFG_SPD_1G		0x00000002
 #define PAS_MAC_CFG_PCFG_SPD_10G	0x00000003
+
+#define PAS_MAC_CFG_MACCFG_TXT_M	0x70000000
+#define PAS_MAC_CFG_MACCFG_TXT_S	28
+#define PAS_MAC_CFG_MACCFG_PRES_M	0x0f000000
+#define PAS_MAC_CFG_MACCFG_PRES_S	24
+#define PAS_MAC_CFG_MACCFG_MAXF_M	0x00ffff00
+#define PAS_MAC_CFG_MACCFG_MAXF_S	8
+#define PAS_MAC_CFG_MACCFG_MAXF(x)	(((x) << PAS_MAC_CFG_MACCFG_MAXF_S) & \
+					 PAS_MAC_CFG_MACCFG_MAXF_M)
+#define PAS_MAC_CFG_MACCFG_MINF_M	0x000000ff
+#define PAS_MAC_CFG_MACCFG_MINF_S	0
+
 #define PAS_MAC_CFG_TXP_FCF		0x01000000
 #define PAS_MAC_CFG_TXP_FCE		0x00800000
 #define PAS_MAC_CFG_TXP_FC		0x00400000
