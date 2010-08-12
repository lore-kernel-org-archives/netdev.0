From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 6/6 v2] au1000-eth: remove volatiles, switch to I/O accessors
Date: Thu, 12 Aug 2010 10:10:06 +0200
Message-ID: <201008121010.06660.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:60085 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932943Ab0HLIKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 04:10:05 -0400
Received: by mail-ww0-f42.google.com with SMTP id 26so6107322wwf.1
        for <netdev@vger.kernel.org>; Thu, 12 Aug 2010 01:10:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Remove all the volatile keywords where they were used, switch to using the
proper readl/writel accessors.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 7b823c9..4ccdde3 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -163,10 +163,10 @@ static void au1000_enable_mac(struct net_device *dev, int force_reset)
 	spin_lock_irqsave(&aup->lock, flags);
 
 	if (force_reset || (!aup->mac_enabled)) {
-		*aup->enable = MAC_EN_CLOCK_ENABLE;
+		writel(MAC_EN_CLOCK_ENABLE, &aup->enable);
 		au_sync_delay(2);
-		*aup->enable = (MAC_EN_RESET0 | MAC_EN_RESET1 | MAC_EN_RESET2
-				| MAC_EN_CLOCK_ENABLE);
+		writel((MAC_EN_RESET0 | MAC_EN_RESET1 | MAC_EN_RESET2
+				| MAC_EN_CLOCK_ENABLE), &aup->enable);
 		au_sync_delay(2);
 
 		aup->mac_enabled = 1;
@@ -181,12 +181,12 @@ static void au1000_enable_mac(struct net_device *dev, int force_reset)
 static int au1000_mdio_read(struct net_device *dev, int phy_addr, int reg)
 {
 	struct au1000_private *aup = netdev_priv(dev);
-	volatile u32 *const mii_control_reg = &aup->mac->mii_control;
-	volatile u32 *const mii_data_reg = &aup->mac->mii_data;
+	u32 *const mii_control_reg = &aup->mac->mii_control;
+	u32 *const mii_data_reg = &aup->mac->mii_data;
 	u32 timedout = 20;
 	u32 mii_control;
 
-	while (*mii_control_reg & MAC_MII_BUSY) {
+	while (readl(mii_control_reg) & MAC_MII_BUSY) {
 		mdelay(1);
 		if (--timedout == 0) {
 			netdev_err(dev, "read_MII busy timeout!!\n");
@@ -197,29 +197,29 @@ static int au1000_mdio_read(struct net_device *dev, int phy_addr, int reg)
 	mii_control = MAC_SET_MII_SELECT_REG(reg) |
 		MAC_SET_MII_SELECT_PHY(phy_addr) | MAC_MII_READ;
 
-	*mii_control_reg = mii_control;
+	writel(mii_control, mii_control_reg);
 
 	timedout = 20;
-	while (*mii_control_reg & MAC_MII_BUSY) {
+	while (readl(mii_control_reg) & MAC_MII_BUSY) {
 		mdelay(1);
 		if (--timedout == 0) {
 			netdev_err(dev, "mdio_read busy timeout!!\n");
 			return -1;
 		}
 	}
-	return (int)*mii_data_reg;
+	return readl(mii_data_reg);
 }
 
 static void au1000_mdio_write(struct net_device *dev, int phy_addr,
 			      int reg, u16 value)
 {
 	struct au1000_private *aup = netdev_priv(dev);
-	volatile u32 *const mii_control_reg = &aup->mac->mii_control;
-	volatile u32 *const mii_data_reg = &aup->mac->mii_data;
+	u32 *const mii_control_reg = &aup->mac->mii_control;
+	u32 *const mii_data_reg = &aup->mac->mii_data;
 	u32 timedout = 20;
 	u32 mii_control;
 
-	while (*mii_control_reg & MAC_MII_BUSY) {
+	while (readl(mii_control_reg) & MAC_MII_BUSY) {
 		mdelay(1);
 		if (--timedout == 0) {
 			netdev_err(dev, "mdio_write busy timeout!!\n");
@@ -230,8 +230,8 @@ static void au1000_mdio_write(struct net_device *dev, int phy_addr,
 	mii_control = MAC_SET_MII_SELECT_REG(reg) |
 		MAC_SET_MII_SELECT_PHY(phy_addr) | MAC_MII_WRITE;
 
-	*mii_data_reg = value;
-	*mii_control_reg = mii_control;
+	writel(value, mii_data_reg);
+	writel(mii_control, mii_control_reg);
 }
 
 static int au1000_mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
@@ -268,20 +268,26 @@ static int au1000_mdiobus_reset(struct mii_bus *bus)
 static void au1000_hard_stop(struct net_device *dev)
 {
 	struct au1000_private *aup = netdev_priv(dev);
+	u32 reg;
 
 	netif_dbg(aup, drv, dev, "hard stop\n");
 
-	aup->mac->control &= ~(MAC_RX_ENABLE | MAC_TX_ENABLE);
+	reg = readl(&aup->mac->control);
+	reg &= ~(MAC_RX_ENABLE | MAC_TX_ENABLE);
+	writel(reg, &aup->mac->control);
 	au_sync_delay(10);
 }
 
 static void au1000_enable_rx_tx(struct net_device *dev)
 {
 	struct au1000_private *aup = netdev_priv(dev);
+	u32 reg;
 
 	netif_dbg(aup, hw, dev, "enable_rx_tx\n");
 
-	aup->mac->control |= (MAC_RX_ENABLE | MAC_TX_ENABLE);
+	reg = readl(&aup->mac->control);
+	reg |= (MAC_RX_ENABLE | MAC_TX_ENABLE);
+	writel(reg, &aup->mac->control);
 	au_sync_delay(10);
 }
 
@@ -291,6 +297,7 @@ au1000_adjust_link(struct net_device *dev)
 	struct au1000_private *aup = netdev_priv(dev);
 	struct phy_device *phydev = aup->phy_dev;
 	unsigned long flags;
+	u32 reg;
 
 	int status_change = 0;
 
@@ -322,14 +329,15 @@ au1000_adjust_link(struct net_device *dev)
 		/* switching duplex mode requires to disable rx and tx! */
 		au1000_hard_stop(dev);
 
-		if (DUPLEX_FULL == phydev->duplex)
-			aup->mac->control = ((aup->mac->control
-					     | MAC_FULL_DUPLEX)
-					     & ~MAC_DISABLE_RX_OWN);
-		else
-			aup->mac->control = ((aup->mac->control
-					      & ~MAC_FULL_DUPLEX)
-					     | MAC_DISABLE_RX_OWN);
+		reg = readl(&aup->mac->control);
+		if (DUPLEX_FULL == phydev->duplex) {
+			reg |= MAC_FULL_DUPLEX;
+			reg &= ~MAC_DISABLE_RX_OWN;
+		} else {
+			reg &= ~MAC_FULL_DUPLEX;
+			reg |= MAC_DISABLE_RX_OWN;
+		}
+		writel(reg, &aup->mac->control);
 		au_sync_delay(1);
 
 		au1000_enable_rx_tx(dev);
@@ -495,9 +503,9 @@ static void au1000_reset_mac_unlocked(struct net_device *dev)
 
 	au1000_hard_stop(dev);
 
-	*aup->enable = MAC_EN_CLOCK_ENABLE;
+	writel(MAC_EN_CLOCK_ENABLE, &aup->enable);
 	au_sync_delay(2);
-	*aup->enable = 0;
+	writel(0, &aup->enable);
 	au_sync_delay(2);
 
 	aup->tx_full = 0;
@@ -541,12 +549,12 @@ au1000_setup_hw_rings(struct au1000_private *aup, u32 rx_base, u32 tx_base)
 
 	for (i = 0; i < NUM_RX_DMA; i++) {
 		aup->rx_dma_ring[i] =
-			(volatile struct rx_dma *)
+			(struct rx_dma *)
 					(rx_base + sizeof(struct rx_dma)*i);
 	}
 	for (i = 0; i < NUM_TX_DMA; i++) {
 		aup->tx_dma_ring[i] =
-			(volatile struct tx_dma *)
+			(struct tx_dma *)
 					(tx_base + sizeof(struct tx_dma)*i);
 	}
 }
@@ -635,14 +643,16 @@ static int au1000_init(struct net_device *dev)
 
 	spin_lock_irqsave(&aup->lock, flags);
 
-	aup->mac->control = 0;
+	writel(0, &aup->mac->control);
 	aup->tx_head = (aup->tx_dma_ring[0]->buff_stat & 0xC) >> 2;
 	aup->tx_tail = aup->tx_head;
 	aup->rx_head = (aup->rx_dma_ring[0]->buff_stat & 0xC) >> 2;
 
-	aup->mac->mac_addr_high = dev->dev_addr[5]<<8 | dev->dev_addr[4];
-	aup->mac->mac_addr_low = dev->dev_addr[3]<<24 | dev->dev_addr[2]<<16 |
-		dev->dev_addr[1]<<8 | dev->dev_addr[0];
+	writel(dev->dev_addr[5]<<8 | dev->dev_addr[4],
+					&aup->mac->mac_addr_high);
+	writel(dev->dev_addr[3]<<24 | dev->dev_addr[2]<<16 |
+		dev->dev_addr[1]<<8 | dev->dev_addr[0],
+					&aup->mac->mac_addr_low);
 
 
 	for (i = 0; i < NUM_RX_DMA; i++)
@@ -663,8 +673,8 @@ static int au1000_init(struct net_device *dev)
 		control |= MAC_FULL_DUPLEX;
 	}
 
-	aup->mac->control = control;
-	aup->mac->vlan1_tag = 0x8100; /* activate vlan support */
+	writel(control, &aup->mac->control);
+	writel(0x8100, &aup->mac->vlan1_tag); /* activate vlan support */
 	au_sync();
 
 	spin_unlock_irqrestore(&aup->lock, flags);
@@ -701,7 +711,7 @@ static int au1000_rx(struct net_device *dev)
 {
 	struct au1000_private *aup = netdev_priv(dev);
 	struct sk_buff *skb;
-	volatile struct rx_dma *prxd;
+	struct rx_dma *prxd;
 	u32 buff_stat, status;
 	struct db_dest *pDB;
 	u32	frmlen;
@@ -797,7 +807,7 @@ static void au1000_update_tx_stats(struct net_device *dev, u32 status)
 static void au1000_tx_ack(struct net_device *dev)
 {
 	struct au1000_private *aup = netdev_priv(dev);
-	volatile struct tx_dma *ptxd;
+	struct tx_dma *ptxd;
 
 	ptxd = aup->tx_dma_ring[aup->tx_tail];
 
@@ -896,7 +906,7 @@ static netdev_tx_t au1000_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct au1000_private *aup = netdev_priv(dev);
 	struct net_device_stats *ps = &dev->stats;
-	volatile struct tx_dma *ptxd;
+	struct tx_dma *ptxd;
 	u32 buff_stat;
 	struct db_dest *pDB;
 	int i;
@@ -958,15 +968,18 @@ static void au1000_tx_timeout(struct net_device *dev)
 static void au1000_multicast_list(struct net_device *dev)
 {
 	struct au1000_private *aup = netdev_priv(dev);
+	u32 reg;
 
 	netif_dbg(aup, drv, dev, "au1000_multicast_list: flags=%x\n",
 							dev->flags);
+
+	reg = readl(&aup->mac->control);
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
-		aup->mac->control |= MAC_PROMISCUOUS;
+		reg |= MAC_PROMISCUOUS;
 	} else if ((dev->flags & IFF_ALLMULTI)  ||
 			   netdev_mc_count(dev) > MULTICAST_FILTER_LIMIT) {
-		aup->mac->control |= MAC_PASS_ALL_MULTI;
-		aup->mac->control &= ~MAC_PROMISCUOUS;
+		reg |= MAC_PASS_ALL_MULTI;
+		reg &= ~MAC_PROMISCUOUS;
 		netdev_info(dev, "Pass all multicast\n");
 	} else {
 		struct netdev_hw_addr *ha;
@@ -976,11 +989,12 @@ static void au1000_multicast_list(struct net_device *dev)
 		netdev_for_each_mc_addr(ha, dev)
 			set_bit(ether_crc(ETH_ALEN, ha->addr)>>26,
 					(long *)mc_filter);
-		aup->mac->multi_hash_high = mc_filter[1];
-		aup->mac->multi_hash_low = mc_filter[0];
-		aup->mac->control &= ~MAC_PROMISCUOUS;
-		aup->mac->control |= MAC_HASH_MODE;
+		writel(mc_filter[1], &aup->mac->multi_hash_high);
+		writel(mc_filter[0], &aup->mac->multi_hash_low);
+		reg &= ~MAC_PROMISCUOUS;
+		reg |= MAC_HASH_MODE;
 	}
+	writel(reg, &aup->mac->control);
 }
 
 static int au1000_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
@@ -1083,7 +1097,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	}
 
 	/* aup->mac is the base address of the MAC's registers */
-	aup->mac = (volatile struct mac_reg *)
+	aup->mac = (struct mac_reg *)
 			ioremap_nocache(base->start, resource_size(base));
 	if (!aup->mac) {
 		dev_err(&pdev->dev, "failed to ioremap MAC registers\n");
@@ -1092,7 +1106,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	}
 
 	/* Setup some variables for quick register address access */
-	aup->enable = (volatile u32 *)ioremap_nocache(macen->start,
+	aup->enable = (u32 *)ioremap_nocache(macen->start,
 						resource_size(macen));
 	if (!aup->enable) {
 		dev_err(&pdev->dev, "failed to ioremap MAC enable register\n");
@@ -1121,7 +1135,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	memcpy(dev->dev_addr, au1000_mac_addr, sizeof(au1000_mac_addr));
 	dev->dev_addr[5] += pdev->id;
 
-	*aup->enable = 0;
+	writel(0, &aup->enable);
 	aup->mac_enabled = 0;
 
 	pd = pdev->dev.platform_data;
diff --git a/drivers/net/au1000_eth.h b/drivers/net/au1000_eth.h
index 38c1d88..4b638df 100644
--- a/drivers/net/au1000_eth.h
+++ b/drivers/net/au1000_eth.h
@@ -46,7 +46,7 @@
  */
 struct db_dest {
 	struct db_dest *pnext;
-	volatile u32 *vaddr;
+	u32 *vaddr;
 	dma_addr_t dma_addr;
 };
 
@@ -88,8 +88,8 @@ struct mac_reg {
 struct au1000_private {
 	struct db_dest *pDBfree;
 	struct db_dest db[NUM_RX_BUFFS+NUM_TX_BUFFS];
-	volatile struct rx_dma *rx_dma_ring[NUM_RX_DMA];
-	volatile struct tx_dma *tx_dma_ring[NUM_TX_DMA];
+	struct rx_dma *rx_dma_ring[NUM_RX_DMA];
+	struct tx_dma *tx_dma_ring[NUM_TX_DMA];
 	struct db_dest *rx_db_inuse[NUM_RX_DMA];
 	struct db_dest *tx_db_inuse[NUM_TX_DMA];
 	u32 rx_head;
@@ -120,8 +120,8 @@ struct au1000_private {
 
 	/* These variables are just for quick access
 	 * to certain regs addresses. */
-	volatile struct mac_reg *mac;  /* mac registers                      */
-	volatile u32 *enable;     /* address of MAC Enable Register     */
+	struct mac_reg *mac;  /* mac registers                      */
+	u32 *enable;     /* address of MAC Enable Register     */
 
 	u32 vaddr;                /* virtual address of rx/tx buffers   */
 	dma_addr_t dma_addr;      /* dma address of rx/tx buffers       */


