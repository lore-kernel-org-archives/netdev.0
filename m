From: <sean.wang@mediatek.com>
Subject: [PATCH net-next] net: ethernet: mediatek: use phydev from struct net_device
Date: Thu, 22 Sep 2016 16:33:35 +0800
Message-ID: <1474533215-22273-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        <objelf@gmail.com>, Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sean Wang <sean.wang@mediatek.com>

reuse phydev already in struct net_device instead of creating
another new one in private structure.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 73 ++++++++++++++---------------
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |  2 -
 2 files changed, 36 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index ec60794..6b7acf4 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -175,7 +175,7 @@ static void mtk_phy_link_adjust(struct net_device *dev)
 	if (unlikely(test_bit(MTK_RESETTING, &mac->hw->state)))
 		return;
 
-	switch (mac->phy_dev->speed) {
+	switch (dev->phydev->speed) {
 	case SPEED_1000:
 		mcr |= MAC_MCR_SPEED_1000;
 		break;
@@ -185,22 +185,22 @@ static void mtk_phy_link_adjust(struct net_device *dev)
 	};
 
 	if (mac->id == 0 && !mac->trgmii)
-		mtk_gmac0_rgmii_adjust(mac->hw, mac->phy_dev->speed);
+		mtk_gmac0_rgmii_adjust(mac->hw, dev->phydev->speed);
 
-	if (mac->phy_dev->link)
+	if (dev->phydev->link)
 		mcr |= MAC_MCR_FORCE_LINK;
 
-	if (mac->phy_dev->duplex) {
+	if (dev->phydev->duplex) {
 		mcr |= MAC_MCR_FORCE_DPX;
 
-		if (mac->phy_dev->pause)
+		if (dev->phydev->pause)
 			rmt_adv = LPA_PAUSE_CAP;
-		if (mac->phy_dev->asym_pause)
+		if (dev->phydev->asym_pause)
 			rmt_adv |= LPA_PAUSE_ASYM;
 
-		if (mac->phy_dev->advertising & ADVERTISED_Pause)
+		if (dev->phydev->advertising & ADVERTISED_Pause)
 			lcl_adv |= ADVERTISE_PAUSE_CAP;
-		if (mac->phy_dev->advertising & ADVERTISED_Asym_Pause)
+		if (dev->phydev->advertising & ADVERTISED_Asym_Pause)
 			lcl_adv |= ADVERTISE_PAUSE_ASYM;
 
 		flowctrl = mii_resolve_flowctrl_fdx(lcl_adv, rmt_adv);
@@ -217,7 +217,7 @@ static void mtk_phy_link_adjust(struct net_device *dev)
 
 	mtk_w32(mac->hw, mcr, MTK_MAC_MCR(mac->id));
 
-	if (mac->phy_dev->link)
+	if (dev->phydev->link)
 		netif_carrier_on(dev);
 	else
 		netif_carrier_off(dev);
@@ -255,17 +255,17 @@ static int mtk_phy_connect_node(struct mtk_eth *eth, struct mtk_mac *mac,
 		 mac->id, phydev_name(phydev), phydev->phy_id,
 		 phydev->drv->name);
 
-	mac->phy_dev = phydev;
-
 	return 0;
 }
 
-static int mtk_phy_connect(struct mtk_mac *mac)
+static int mtk_phy_connect(struct net_device *dev)
 {
-	struct mtk_eth *eth = mac->hw;
+	struct mtk_mac *mac = netdev_priv(dev);
+	struct mtk_eth *eth;
 	struct device_node *np;
 	u32 val;
 
+	eth = mac->hw;
 	np = of_parse_phandle(mac->of_node, "phy-handle", 0);
 	if (!np && of_phy_is_fixed_link(mac->of_node))
 		if (!of_phy_register_fixed_link(mac->of_node))
@@ -303,20 +303,21 @@ static int mtk_phy_connect(struct mtk_mac *mac)
 	val |= SYSCFG0_GE_MODE(mac->ge_mode, mac->id);
 	regmap_write(eth->ethsys, ETHSYS_SYSCFG0, val);
 
+	/* couple phydev to net_device */
 	mtk_phy_connect_node(eth, mac, np);
-	mac->phy_dev->autoneg = AUTONEG_ENABLE;
-	mac->phy_dev->speed = 0;
-	mac->phy_dev->duplex = 0;
+	dev->phydev->autoneg = AUTONEG_ENABLE;
+	dev->phydev->speed = 0;
+	dev->phydev->duplex = 0;
 
 	if (of_phy_is_fixed_link(mac->of_node))
-		mac->phy_dev->supported |=
+		dev->phydev->supported |=
 		SUPPORTED_Pause | SUPPORTED_Asym_Pause;
 
-	mac->phy_dev->supported &= PHY_GBIT_FEATURES | SUPPORTED_Pause |
+	dev->phydev->supported &= PHY_GBIT_FEATURES | SUPPORTED_Pause |
 				   SUPPORTED_Asym_Pause;
-	mac->phy_dev->advertising = mac->phy_dev->supported |
+	dev->phydev->advertising = dev->phydev->supported |
 				    ADVERTISED_Autoneg;
-	phy_start_aneg(mac->phy_dev);
+	phy_start_aneg(dev->phydev);
 
 	of_node_put(np);
 
@@ -1742,7 +1743,7 @@ static int mtk_open(struct net_device *dev)
 	}
 	atomic_inc(&eth->dma_refcnt);
 
-	phy_start(mac->phy_dev);
+	phy_start(dev->phydev);
 	netif_start_queue(dev);
 
 	return 0;
@@ -1777,7 +1778,7 @@ static int mtk_stop(struct net_device *dev)
 	struct mtk_eth *eth = mac->hw;
 
 	netif_tx_disable(dev);
-	phy_stop(mac->phy_dev);
+	phy_stop(dev->phydev);
 
 	/* only shutdown DMA if this is the last user */
 	if (!atomic_dec_and_test(&eth->dma_refcnt))
@@ -1917,7 +1918,7 @@ static int __init mtk_init(struct net_device *dev)
 		dev->addr_assign_type = NET_ADDR_RANDOM;
 	}
 
-	return mtk_phy_connect(mac);
+	return mtk_phy_connect(dev);
 }
 
 static void mtk_uninit(struct net_device *dev)
@@ -1925,20 +1926,18 @@ static void mtk_uninit(struct net_device *dev)
 	struct mtk_mac *mac = netdev_priv(dev);
 	struct mtk_eth *eth = mac->hw;
 
-	phy_disconnect(mac->phy_dev);
+	phy_disconnect(dev->phydev);
 	mtk_irq_disable(eth, MTK_QDMA_INT_MASK, ~0);
 	mtk_irq_disable(eth, MTK_PDMA_INT_MASK, ~0);
 }
 
 static int mtk_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	struct mtk_mac *mac = netdev_priv(dev);
-
 	switch (cmd) {
 	case SIOCGMIIPHY:
 	case SIOCGMIIREG:
 	case SIOCSMIIREG:
-		return phy_mii_ioctl(mac->phy_dev, ifr, cmd);
+		return phy_mii_ioctl(dev->phydev, ifr, cmd);
 	default:
 		break;
 	}
@@ -1983,7 +1982,7 @@ static void mtk_pending_work(struct work_struct *work)
 		if (!eth->mac[i] ||
 		    of_phy_is_fixed_link(eth->mac[i]->of_node))
 			continue;
-		err = phy_init_hw(eth->mac[i]->phy_dev);
+		err = phy_init_hw(eth->netdev[i]->phydev);
 		if (err)
 			dev_err(eth->dev, "%s: PHY init failed.\n",
 				eth->netdev[i]->name);
@@ -2052,11 +2051,11 @@ static int mtk_get_settings(struct net_device *dev,
 	if (unlikely(test_bit(MTK_RESETTING, &mac->hw->state)))
 		return -EBUSY;
 
-	err = phy_read_status(mac->phy_dev);
+	err = phy_read_status(dev->phydev);
 	if (err)
 		return -ENODEV;
 
-	return phy_ethtool_gset(mac->phy_dev, cmd);
+	return phy_ethtool_gset(dev->phydev, cmd);
 }
 
 static int mtk_set_settings(struct net_device *dev,
@@ -2064,14 +2063,14 @@ static int mtk_set_settings(struct net_device *dev,
 {
 	struct mtk_mac *mac = netdev_priv(dev);
 
-	if (cmd->phy_address != mac->phy_dev->mdio.addr) {
-		mac->phy_dev = mdiobus_get_phy(mac->hw->mii_bus,
+	if (cmd->phy_address != dev->phydev->mdio.addr) {
+		dev->phydev = mdiobus_get_phy(mac->hw->mii_bus,
 					       cmd->phy_address);
-		if (!mac->phy_dev)
+		if (!dev->phydev)
 			return -ENODEV;
 	}
 
-	return phy_ethtool_sset(mac->phy_dev, cmd);
+	return phy_ethtool_sset(dev->phydev, cmd);
 }
 
 static void mtk_get_drvinfo(struct net_device *dev,
@@ -2105,7 +2104,7 @@ static int mtk_nway_reset(struct net_device *dev)
 	if (unlikely(test_bit(MTK_RESETTING, &mac->hw->state)))
 		return -EBUSY;
 
-	return genphy_restart_aneg(mac->phy_dev);
+	return genphy_restart_aneg(dev->phydev);
 }
 
 static u32 mtk_get_link(struct net_device *dev)
@@ -2116,11 +2115,11 @@ static u32 mtk_get_link(struct net_device *dev)
 	if (unlikely(test_bit(MTK_RESETTING, &mac->hw->state)))
 		return -EBUSY;
 
-	err = genphy_update_link(mac->phy_dev);
+	err = genphy_update_link(dev->phydev);
 	if (err)
 		return ethtool_op_get_link(dev);
 
-	return mac->phy_dev->link;
+	return dev->phydev->link;
 }
 
 static void mtk_get_strings(struct net_device *dev, u32 stringset, u8 *data)
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index e521156..7e194f7 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -557,7 +557,6 @@ struct mtk_eth {
  * @of_node:		Our devicetree node
  * @hw:			Backpointer to our main datastruture
  * @hw_stats:		Packet statistics counter
- * @phy_dev:		The attached PHY if available
  * @trgmii		Indicate if the MAC uses TRGMII connected to internal
 			switch
  */
@@ -567,7 +566,6 @@ struct mtk_mac {
 	struct device_node		*of_node;
 	struct mtk_eth			*hw;
 	struct mtk_hw_stats		*hw_stats;
-	struct phy_device		*phy_dev;
 	__be32				hwlro_ip[MTK_MAX_LRO_IP_CNT];
 	int				hwlro_ip_cnt;
 	bool				trgmii;
-- 
1.9.1
