From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 1/4] stmmac: tidy-up stmmac_priv structure
Date: Wed, 24 Nov 2010 13:37:58 +0100
Message-ID: <1290561646-9429-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Peppe CAVALLARO <peppe.cavallaro@st.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:51090 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753666Ab0KXMiW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Nov 2010 07:38:22 -0500
Received: from zeta.dmz-us.st.com (ns4.st.com [167.4.80.115])
	by beta.dmz-us.st.com (STMicroelectronics) with ESMTP id 343B3149
	for <netdev@vger.kernel.org>; Wed, 24 Nov 2010 12:38:17 +0000 (GMT)
Received: from Webmail-eu.st.com (safex1hubcas2.st.com [10.75.90.16])
	by zeta.dmz-us.st.com (STMicroelectronics) with ESMTP id 5FCE11F2
	for <netdev@vger.kernel.org>; Wed, 24 Nov 2010 12:38:16 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch tidies-up the stmmac_priv structure
that had many fileds alredy defined in the
plat_stmmacenet_data structure.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac.h         |   15 ++------
 drivers/net/stmmac/stmmac_ethtool.c |    4 +-
 drivers/net/stmmac/stmmac_main.c    |   69 ++++++++++++++++++-----------------
 drivers/net/stmmac/stmmac_mdio.c    |    8 ++--
 4 files changed, 44 insertions(+), 52 deletions(-)

diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index 79bdc2e..3157567 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -37,7 +37,6 @@ struct stmmac_priv {
 	unsigned int cur_tx;
 	unsigned int dirty_tx;
 	unsigned int dma_tx_size;
-	int tx_coe;
 	int tx_coalesce;
 
 	struct dma_desc *dma_rx ;
@@ -48,7 +47,6 @@ struct stmmac_priv {
 	struct sk_buff_head rx_recycle;
 
 	struct net_device *dev;
-	int is_gmac;
 	dma_addr_t dma_rx_phy;
 	unsigned int dma_rx_size;
 	unsigned int dma_buf_sz;
@@ -60,14 +58,11 @@ struct stmmac_priv {
 	struct napi_struct napi;
 
 	phy_interface_t phy_interface;
-	int pbl;
-	int bus_id;
 	int phy_addr;
 	int phy_mask;
 	int (*phy_reset) (void *priv);
-	void (*fix_mac_speed) (void *priv, unsigned int speed);
-	void (*bus_setup)(void __iomem *ioaddr);
-	void *bsp_priv;
+	int rx_coe;
+	int no_csum_insertion;
 
 	int phy_irq;
 	struct phy_device *phydev;
@@ -77,7 +72,6 @@ struct stmmac_priv {
 	unsigned int flow_ctrl;
 	unsigned int pause;
 	struct mii_bus *mii;
-	int mii_clk_csr;
 
 	u32 msg_enable;
 	spinlock_t lock;
@@ -90,10 +84,7 @@ struct stmmac_priv {
 #ifdef STMMAC_VLAN_TAG_USED
 	struct vlan_group *vlgrp;
 #endif
-	int enh_desc;
-	int rx_coe;
-	int bugged_jumbo;
-	int no_csum_insertion;
+	struct plat_stmmacenet_data *plat;
 };
 
 #ifdef CONFIG_STM_DRIVERS
diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/stmmac_ethtool.c
index 6d65482..f2695fd 100644
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -94,7 +94,7 @@ static void stmmac_ethtool_getdrvinfo(struct net_device *dev,
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 
-	if (!priv->is_gmac)
+	if (!priv->plat->has_gmac)
 		strcpy(info->driver, MAC100_ETHTOOL_NAME);
 	else
 		strcpy(info->driver, GMAC_ETHTOOL_NAME);
@@ -176,7 +176,7 @@ static void stmmac_ethtool_gregs(struct net_device *dev,
 
 	memset(reg_space, 0x0, REG_SPACE_SIZE);
 
-	if (!priv->is_gmac) {
+	if (!priv->plat->has_gmac) {
 		/* MAC registers */
 		for (i = 0; i < 12; i++)
 			reg_space[i] = readl(priv->ioaddr + (i * 4));
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 06bc603..29ba286 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -186,6 +186,18 @@ static inline u32 stmmac_tx_avail(struct stmmac_priv *priv)
 	return priv->dirty_tx + priv->dma_tx_size - priv->cur_tx - 1;
 }
 
+/* On some ST platforms, some HW system configuraton registers have to be
+ * set according to the link speed negotiated.
+ */
+static inline void stmmac_hw_fix_mac_speed(struct stmmac_priv *priv)
+{
+	struct phy_device *phydev = priv->phydev;
+
+	if (likely(priv->plat->fix_mac_speed))
+		priv->plat->fix_mac_speed(priv->plat->bsp_priv,
+					  phydev->speed);
+}
+
 /**
  * stmmac_adjust_link
  * @dev: net device structure
@@ -228,15 +240,13 @@ static void stmmac_adjust_link(struct net_device *dev)
 			new_state = 1;
 			switch (phydev->speed) {
 			case 1000:
-				if (likely(priv->is_gmac))
+				if (likely(priv->plat->has_gmac))
 					ctrl &= ~priv->hw->link.port;
-				if (likely(priv->fix_mac_speed))
-					priv->fix_mac_speed(priv->bsp_priv,
-							    phydev->speed);
+				stmmac_hw_fix_mac_speed(priv);
 				break;
 			case 100:
 			case 10:
-				if (priv->is_gmac) {
+				if (priv->plat->has_gmac) {
 					ctrl |= priv->hw->link.port;
 					if (phydev->speed == SPEED_100) {
 						ctrl |= priv->hw->link.speed;
@@ -246,9 +256,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 				} else {
 					ctrl &= ~priv->hw->link.port;
 				}
-				if (likely(priv->fix_mac_speed))
-					priv->fix_mac_speed(priv->bsp_priv,
-							    phydev->speed);
+				stmmac_hw_fix_mac_speed(priv);
 				break;
 			default:
 				if (netif_msg_link(priv))
@@ -305,7 +313,7 @@ static int stmmac_init_phy(struct net_device *dev)
 		return 0;
 	}
 
-	snprintf(bus_id, MII_BUS_ID_SIZE, "%x", priv->bus_id);
+	snprintf(bus_id, MII_BUS_ID_SIZE, "%x", priv->plat->bus_id);
 	snprintf(phy_id, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, bus_id,
 		 priv->phy_addr);
 	pr_debug("stmmac_init_phy:  trying to attach to %s\n", phy_id);
@@ -552,7 +560,7 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
  */
 static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 {
-	if (likely((priv->tx_coe) && (!priv->no_csum_insertion))) {
+	if (likely((priv->plat->tx_coe) && (!priv->no_csum_insertion))) {
 		/* In case of GMAC, SF mode has to be enabled
 		 * to perform the TX COE. This depends on:
 		 * 1) TX COE if actually supported
@@ -814,7 +822,7 @@ static int stmmac_open(struct net_device *dev)
 	init_dma_desc_rings(dev);
 
 	/* DMA initialization and SW reset */
-	if (unlikely(priv->hw->dma->init(priv->ioaddr, priv->pbl,
+	if (unlikely(priv->hw->dma->init(priv->ioaddr, priv->plat->pbl,
 					 priv->dma_tx_phy,
 					 priv->dma_rx_phy) < 0)) {
 
@@ -825,15 +833,15 @@ static int stmmac_open(struct net_device *dev)
 	/* Copy the MAC addr into the HW  */
 	priv->hw->mac->set_umac_addr(priv->ioaddr, dev->dev_addr, 0);
 	/* If required, perform hw setup of the bus. */
-	if (priv->bus_setup)
-		priv->bus_setup(priv->ioaddr);
+	if (priv->plat->bus_setup)
+		priv->plat->bus_setup(priv->ioaddr);
 	/* Initialize the MAC Core */
 	priv->hw->mac->core_init(priv->ioaddr);
 
 	priv->rx_coe = priv->hw->mac->rx_coe(priv->ioaddr);
 	if (priv->rx_coe)
 		pr_info("stmmac: Rx Checksum Offload Engine supported\n");
-	if (priv->tx_coe)
+	if (priv->plat->tx_coe)
 		pr_info("\tTX Checksum insertion supported\n");
 
 	priv->shutdown = 0;
@@ -1042,7 +1050,8 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		return stmmac_sw_tso(priv, skb);
 
 	if (likely((skb->ip_summed == CHECKSUM_PARTIAL))) {
-		if (unlikely((!priv->tx_coe) || (priv->no_csum_insertion)))
+		if (unlikely((!priv->plat->tx_coe) ||
+			     (priv->no_csum_insertion)))
 			skb_checksum_help(skb);
 		else
 			csum_insertion = 1;
@@ -1146,7 +1155,7 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 					   DMA_FROM_DEVICE);
 
 			(p + entry)->des2 = priv->rx_skbuff_dma[entry];
-			if (unlikely(priv->is_gmac)) {
+			if (unlikely(priv->plat->has_gmac)) {
 				if (bfsize >= BUF_SIZE_8KiB)
 					(p + entry)->des3 =
 					    (p + entry)->des2 + BUF_SIZE_8KiB;
@@ -1356,7 +1365,7 @@ static int stmmac_change_mtu(struct net_device *dev, int new_mtu)
 		return -EBUSY;
 	}
 
-	if (priv->is_gmac)
+	if (priv->plat->has_gmac)
 		max_mtu = JUMBO_LEN;
 	else
 		max_mtu = ETH_DATA_LEN;
@@ -1370,7 +1379,7 @@ static int stmmac_change_mtu(struct net_device *dev, int new_mtu)
 	 * needs to have the Tx COE disabled for oversized frames
 	 * (due to limited buffer sizes). In this case we disable
 	 * the TX csum insertionin the TDES and not use SF. */
-	if ((priv->bugged_jumbo) && (priv->dev->mtu > ETH_DATA_LEN))
+	if ((priv->plat->bugged_jumbo) && (priv->dev->mtu > ETH_DATA_LEN))
 		priv->no_csum_insertion = 1;
 	else
 		priv->no_csum_insertion = 0;
@@ -1390,7 +1399,7 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 		return IRQ_NONE;
 	}
 
-	if (priv->is_gmac)
+	if (priv->plat->has_gmac)
 		/* To handle GMAC own interrupts */
 		priv->hw->mac->host_irq_status((void __iomem *) dev->base_addr);
 
@@ -1536,7 +1545,7 @@ static int stmmac_mac_device_setup(struct net_device *dev)
 
 	struct mac_device_info *device;
 
-	if (priv->is_gmac)
+	if (priv->plat->has_gmac)
 		device = dwmac1000_setup(priv->ioaddr);
 	else
 		device = dwmac100_setup(priv->ioaddr);
@@ -1544,7 +1553,7 @@ static int stmmac_mac_device_setup(struct net_device *dev)
 	if (!device)
 		return -ENOMEM;
 
-	if (priv->enh_desc) {
+	if (priv->plat->enh_desc) {
 		device->desc = &enh_desc_ops;
 		pr_info("\tEnhanced descriptor structure\n");
 	} else
@@ -1598,7 +1607,7 @@ static int stmmac_associate_phy(struct device *dev, void *data)
 		plat_dat->bus_id);
 
 	/* Check that this phy is for the MAC being initialised */
-	if (priv->bus_id != plat_dat->bus_id)
+	if (priv->plat->bus_id != plat_dat->bus_id)
 		return 0;
 
 	/* OK, this PHY is connected to the MAC.
@@ -1683,13 +1692,9 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	priv->device = &(pdev->dev);
 	priv->dev = ndev;
 	plat_dat = pdev->dev.platform_data;
-	priv->bus_id = plat_dat->bus_id;
-	priv->pbl = plat_dat->pbl;	/* TLI */
-	priv->mii_clk_csr = plat_dat->clk_csr;
-	priv->tx_coe = plat_dat->tx_coe;
-	priv->bugged_jumbo = plat_dat->bugged_jumbo;
-	priv->is_gmac = plat_dat->has_gmac;	/* GMAC is on board */
-	priv->enh_desc = plat_dat->enh_desc;
+
+	priv->plat = plat_dat;
+
 	priv->ioaddr = addr;
 
 	/* PMT module is not integrated in all the MAC devices. */
@@ -1727,16 +1732,12 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 		goto out;
 	}
 
-	priv->fix_mac_speed = plat_dat->fix_mac_speed;
-	priv->bus_setup = plat_dat->bus_setup;
-	priv->bsp_priv = plat_dat->bsp_priv;
-
 	pr_info("\t%s - (dev. name: %s - id: %d, IRQ #%d\n"
 	       "\tIO base addr: 0x%p)\n", ndev->name, pdev->name,
 	       pdev->id, ndev->irq, addr);
 
 	/* MDIO bus Registration */
-	pr_debug("\tMDIO bus (id: %d)...", priv->bus_id);
+	pr_debug("\tMDIO bus (id: %d)...", priv->plat->bus_id);
 	ret = stmmac_mdio_register(ndev);
 	if (ret < 0)
 		goto out;
diff --git a/drivers/net/stmmac/stmmac_mdio.c b/drivers/net/stmmac/stmmac_mdio.c
index d744161..234b406 100644
--- a/drivers/net/stmmac/stmmac_mdio.c
+++ b/drivers/net/stmmac/stmmac_mdio.c
@@ -53,7 +53,7 @@ static int stmmac_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg)
 	int data;
 	u16 regValue = (((phyaddr << 11) & (0x0000F800)) |
 			((phyreg << 6) & (0x000007C0)));
-	regValue |= MII_BUSY | ((priv->mii_clk_csr & 7) << 2);
+	regValue |= MII_BUSY | ((priv->plat->clk_csr & 7) << 2);
 
 	do {} while (((readl(priv->ioaddr + mii_address)) & MII_BUSY) == 1);
 	writel(regValue, priv->ioaddr + mii_address);
@@ -85,7 +85,7 @@ static int stmmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
 	    (((phyaddr << 11) & (0x0000F800)) | ((phyreg << 6) & (0x000007C0)))
 	    | MII_WRITE;
 
-	value |= MII_BUSY | ((priv->mii_clk_csr & 7) << 2);
+	value |= MII_BUSY | ((priv->plat->clk_csr & 7) << 2);
 
 
 	/* Wait until any existing MII operation is complete */
@@ -114,7 +114,7 @@ static int stmmac_mdio_reset(struct mii_bus *bus)
 
 	if (priv->phy_reset) {
 		pr_debug("stmmac_mdio_reset: calling phy_reset\n");
-		priv->phy_reset(priv->bsp_priv);
+		priv->phy_reset(priv->plat->bsp_priv);
 	}
 
 	/* This is a workaround for problems with the STE101P PHY.
@@ -157,7 +157,7 @@ int stmmac_mdio_register(struct net_device *ndev)
 	new_bus->read = &stmmac_mdio_read;
 	new_bus->write = &stmmac_mdio_write;
 	new_bus->reset = &stmmac_mdio_reset;
-	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", priv->bus_id);
+	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", priv->plat->bus_id);
 	new_bus->priv = ndev;
 	new_bus->irq = irqlist;
 	new_bus->phy_mask = priv->phy_mask;
-- 
1.5.5.6
