From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 1/3] tg3: add support a phy at an address different than 01
Date: Sat, 28 Sep 2013 23:15:26 +0200
Message-ID: <1380402928-11480-1-git-send-email-hauke@hauke-m.de>
Cc: nsujir@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:45245 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755165Ab3I1VPn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Sep 2013 17:15:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When phylib was in use tg3 only searched at address 01 on the mdio
bus and did not work with any other address. On the BCM4705 SoCs the
switch is connected as a PHY behind the MAC driven by tg3 and it is at
PHY address 30 in most cases. This is a preparation patch to allow
support for such switches.

phy_addr is set to TG3_PHY_MII_ADDR for all devices, which are using
phylib, so this should not change any behavior.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/tg3.c |   38 +++++++++++++++++------------------
 1 file changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 221a181..853a05e 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -1375,7 +1375,7 @@ static int tg3_mdio_read(struct mii_bus *bp, int mii_id, int reg)
 
 	spin_lock_bh(&tp->lock);
 
-	if (tg3_readphy(tp, reg, &val))
+	if (__tg3_readphy(tp, mii_id, reg, &val))
 		val = -EIO;
 
 	spin_unlock_bh(&tp->lock);
@@ -1390,7 +1390,7 @@ static int tg3_mdio_write(struct mii_bus *bp, int mii_id, int reg, u16 val)
 
 	spin_lock_bh(&tp->lock);
 
-	if (tg3_writephy(tp, reg, val))
+	if (__tg3_writephy(tp, mii_id, reg, val))
 		ret = -EIO;
 
 	spin_unlock_bh(&tp->lock);
@@ -1408,7 +1408,7 @@ static void tg3_mdio_config_5785(struct tg3 *tp)
 	u32 val;
 	struct phy_device *phydev;
 
-	phydev = tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR];
+	phydev = tp->mdio_bus->phy_map[tp->phy_addr];
 	switch (phydev->drv->phy_id & phydev->drv->phy_id_mask) {
 	case PHY_ID_BCM50610:
 	case PHY_ID_BCM50610M:
@@ -1533,7 +1533,7 @@ static int tg3_mdio_init(struct tg3 *tp)
 	tp->mdio_bus->read     = &tg3_mdio_read;
 	tp->mdio_bus->write    = &tg3_mdio_write;
 	tp->mdio_bus->reset    = &tg3_mdio_reset;
-	tp->mdio_bus->phy_mask = ~(1 << TG3_PHY_MII_ADDR);
+	tp->mdio_bus->phy_mask = ~(1 << tp->phy_addr);
 	tp->mdio_bus->irq      = &tp->mdio_irq[0];
 
 	for (i = 0; i < PHY_MAX_ADDR; i++)
@@ -1554,7 +1554,7 @@ static int tg3_mdio_init(struct tg3 *tp)
 		return i;
 	}
 
-	phydev = tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR];
+	phydev = tp->mdio_bus->phy_map[tp->phy_addr];
 
 	if (!phydev || !phydev->drv) {
 		dev_warn(&tp->pdev->dev, "No PHY devices\n");
@@ -1964,7 +1964,7 @@ static void tg3_setup_flow_control(struct tg3 *tp, u32 lcladv, u32 rmtadv)
 	u32 old_tx_mode = tp->tx_mode;
 
 	if (tg3_flag(tp, USE_PHYLIB))
-		autoneg = tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR]->autoneg;
+		autoneg = tp->mdio_bus->phy_map[tp->phy_addr]->autoneg;
 	else
 		autoneg = tp->link_config.autoneg;
 
@@ -2000,7 +2000,7 @@ static void tg3_adjust_link(struct net_device *dev)
 	u8 oldflowctrl, linkmesg = 0;
 	u32 mac_mode, lcl_adv, rmt_adv;
 	struct tg3 *tp = netdev_priv(dev);
-	struct phy_device *phydev = tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR];
+	struct phy_device *phydev = tp->mdio_bus->phy_map[tp->phy_addr];
 
 	spin_lock_bh(&tp->lock);
 
@@ -2089,7 +2089,7 @@ static int tg3_phy_init(struct tg3 *tp)
 	/* Bring the PHY back to a known state. */
 	tg3_bmcr_reset(tp);
 
-	phydev = tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR];
+	phydev = tp->mdio_bus->phy_map[tp->phy_addr];
 
 	/* Attach the MAC to the PHY. */
 	phydev = phy_connect(tp->dev, dev_name(&phydev->dev),
@@ -2116,7 +2116,7 @@ static int tg3_phy_init(struct tg3 *tp)
 				      SUPPORTED_Asym_Pause);
 		break;
 	default:
-		phy_disconnect(tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR]);
+		phy_disconnect(tp->mdio_bus->phy_map[tp->phy_addr]);
 		return -EINVAL;
 	}
 
@@ -2134,7 +2134,7 @@ static void tg3_phy_start(struct tg3 *tp)
 	if (!(tp->phy_flags & TG3_PHYFLG_IS_CONNECTED))
 		return;
 
-	phydev = tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR];
+	phydev = tp->mdio_bus->phy_map[tp->phy_addr];
 
 	if (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER) {
 		tp->phy_flags &= ~TG3_PHYFLG_IS_LOW_POWER;
@@ -2154,13 +2154,13 @@ static void tg3_phy_stop(struct tg3 *tp)
 	if (!(tp->phy_flags & TG3_PHYFLG_IS_CONNECTED))
 		return;
 
-	phy_stop(tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR]);
+	phy_stop(tp->mdio_bus->phy_map[tp->phy_addr]);
 }
 
 static void tg3_phy_fini(struct tg3 *tp)
 {
 	if (tp->phy_flags & TG3_PHYFLG_IS_CONNECTED) {
-		phy_disconnect(tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR]);
+		phy_disconnect(tp->mdio_bus->phy_map[tp->phy_addr]);
 		tp->phy_flags &= ~TG3_PHYFLG_IS_CONNECTED;
 	}
 }
@@ -4034,7 +4034,7 @@ static int tg3_power_down_prepare(struct tg3 *tp)
 			struct phy_device *phydev;
 			u32 phyid, advertising;
 
-			phydev = tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR];
+			phydev = tp->mdio_bus->phy_map[tp->phy_addr];
 
 			tp->phy_flags |= TG3_PHYFLG_IS_LOW_POWER;
 
@@ -11922,7 +11922,7 @@ static int tg3_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		struct phy_device *phydev;
 		if (!(tp->phy_flags & TG3_PHYFLG_IS_CONNECTED))
 			return -EAGAIN;
-		phydev = tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR];
+		phydev = tp->mdio_bus->phy_map[tp->phy_addr];
 		return phy_ethtool_gset(phydev, cmd);
 	}
 
@@ -11989,7 +11989,7 @@ static int tg3_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		struct phy_device *phydev;
 		if (!(tp->phy_flags & TG3_PHYFLG_IS_CONNECTED))
 			return -EAGAIN;
-		phydev = tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR];
+		phydev = tp->mdio_bus->phy_map[tp->phy_addr];
 		return phy_ethtool_sset(phydev, cmd);
 	}
 
@@ -12144,7 +12144,7 @@ static int tg3_nway_reset(struct net_device *dev)
 	if (tg3_flag(tp, USE_PHYLIB)) {
 		if (!(tp->phy_flags & TG3_PHYFLG_IS_CONNECTED))
 			return -EAGAIN;
-		r = phy_start_aneg(tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR]);
+		r = phy_start_aneg(tp->mdio_bus->phy_map[tp->phy_addr]);
 	} else {
 		u32 bmcr;
 
@@ -12260,7 +12260,7 @@ static int tg3_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam
 		u32 newadv;
 		struct phy_device *phydev;
 
-		phydev = tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR];
+		phydev = tp->mdio_bus->phy_map[tp->phy_addr];
 
 		if (!(phydev->supported & SUPPORTED_Pause) ||
 		    (!(phydev->supported & SUPPORTED_Asym_Pause) &&
@@ -13696,7 +13696,7 @@ static int tg3_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		struct phy_device *phydev;
 		if (!(tp->phy_flags & TG3_PHYFLG_IS_CONNECTED))
 			return -EAGAIN;
-		phydev = tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR];
+		phydev = tp->mdio_bus->phy_map[tp->phy_addr];
 		return phy_mii_ioctl(phydev, ifr, cmd);
 	}
 
@@ -17635,7 +17635,7 @@ static int tg3_init_one(struct pci_dev *pdev,
 
 	if (tp->phy_flags & TG3_PHYFLG_IS_CONNECTED) {
 		struct phy_device *phydev;
-		phydev = tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR];
+		phydev = tp->mdio_bus->phy_map[tp->phy_addr];
 		netdev_info(dev,
 			    "attached PHY driver [%s] (mii_bus:phy_addr=%s)\n",
 			    phydev->drv->name, dev_name(&phydev->dev));
-- 
1.7.10.4
