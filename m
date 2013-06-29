From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 8/8] alx: remove WoL support
Date: Sat, 29 Jun 2013 19:23:20 +0200
Message-ID: <1372526600-15934-9-git-send-email-johannes@sipsolutions.net>
References: <1372526600-15934-1-git-send-email-johannes@sipsolutions.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:58306 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752644Ab3F2RX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 13:23:27 -0400
Received: by sipsolutions.net with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <johannes@sipsolutions.net>)
	id 1Usyru-0006aE-MN
	for netdev@vger.kernel.org; Sat, 29 Jun 2013 19:23:26 +0200
In-Reply-To: <1372526600-15934-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unfortunately, WoL is broken and the system will immediately
resume after suspending, and I can't seem to figure out why.
Remove WoL support until the issue can be found.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 drivers/net/ethernet/atheros/alx/ethtool.c |  36 -------
 drivers/net/ethernet/atheros/alx/hw.c      | 155 -----------------------------
 drivers/net/ethernet/atheros/alx/hw.h      |   5 -
 drivers/net/ethernet/atheros/alx/main.c    | 144 ---------------------------
 4 files changed, 340 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/ethtool.c b/drivers/net/ethernet/atheros/alx/ethtool.c
index 9261006..45b3650 100644
--- a/drivers/net/ethernet/atheros/alx/ethtool.c
+++ b/drivers/net/ethernet/atheros/alx/ethtool.c
@@ -201,40 +201,6 @@ static void alx_set_msglevel(struct net_device *netdev, u32 data)
 	alx->msg_enable = data;
 }
 
-static void alx_get_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
-{
-	struct alx_priv *alx = netdev_priv(netdev);
-	struct alx_hw *hw = &alx->hw;
-
-	wol->supported = WAKE_MAGIC | WAKE_PHY;
-	wol->wolopts = 0;
-
-	if (hw->sleep_ctrl & ALX_SLEEP_WOL_MAGIC)
-		wol->wolopts |= WAKE_MAGIC;
-	if (hw->sleep_ctrl & ALX_SLEEP_WOL_PHY)
-		wol->wolopts |= WAKE_PHY;
-}
-
-static int alx_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
-{
-	struct alx_priv *alx = netdev_priv(netdev);
-	struct alx_hw *hw = &alx->hw;
-
-	if (wol->wolopts & ~(WAKE_MAGIC | WAKE_PHY))
-		return -EOPNOTSUPP;
-
-	hw->sleep_ctrl = 0;
-
-	if (wol->wolopts & WAKE_MAGIC)
-		hw->sleep_ctrl |= ALX_SLEEP_WOL_MAGIC;
-	if (wol->wolopts & WAKE_PHY)
-		hw->sleep_ctrl |= ALX_SLEEP_WOL_PHY;
-
-	device_set_wakeup_enable(&alx->hw.pdev->dev, hw->sleep_ctrl);
-
-	return 0;
-}
-
 const struct ethtool_ops alx_ethtool_ops = {
 	.get_settings	= alx_get_settings,
 	.set_settings	= alx_set_settings,
@@ -242,7 +208,5 @@ const struct ethtool_ops alx_ethtool_ops = {
 	.set_pauseparam	= alx_set_pauseparam,
 	.get_msglevel	= alx_get_msglevel,
 	.set_msglevel	= alx_set_msglevel,
-	.get_wol	= alx_get_wol,
-	.set_wol	= alx_set_wol,
 	.get_link	= ethtool_op_get_link,
 };
diff --git a/drivers/net/ethernet/atheros/alx/hw.c b/drivers/net/ethernet/atheros/alx/hw.c
index ea99e5d..1e8c24a 100644
--- a/drivers/net/ethernet/atheros/alx/hw.c
+++ b/drivers/net/ethernet/atheros/alx/hw.c
@@ -332,16 +332,6 @@ void alx_set_macaddr(struct alx_hw *hw, const u8 *addr)
 	alx_write_mem32(hw, ALX_STAD1, val);
 }
 
-static void alx_enable_osc(struct alx_hw *hw)
-{
-	u32 val;
-
-	/* rising edge */
-	val = alx_read_mem32(hw, ALX_MISC);
-	alx_write_mem32(hw, ALX_MISC, val & ~ALX_MISC_INTNLOSC_OPEN);
-	alx_write_mem32(hw, ALX_MISC, val | ALX_MISC_INTNLOSC_OPEN);
-}
-
 static void alx_reset_osc(struct alx_hw *hw, u8 rev)
 {
 	u32 val, val2;
@@ -858,66 +848,6 @@ void alx_post_phy_link(struct alx_hw *hw)
 	}
 }
 
-
-/* NOTE:
- *    1. phy link must be established before calling this function
- *    2. wol option (pattern,magic,link,etc.) is configed before call it.
- */
-int alx_pre_suspend(struct alx_hw *hw, int speed, u8 duplex)
-{
-	u32 master, mac, phy, val;
-	int err = 0;
-
-	master = alx_read_mem32(hw, ALX_MASTER);
-	master &= ~ALX_MASTER_PCLKSEL_SRDS;
-	mac = hw->rx_ctrl;
-	/* 10/100 half */
-	ALX_SET_FIELD(mac, ALX_MAC_CTRL_SPEED,  ALX_MAC_CTRL_SPEED_10_100);
-	mac &= ~(ALX_MAC_CTRL_FULLD | ALX_MAC_CTRL_RX_EN | ALX_MAC_CTRL_TX_EN);
-
-	phy = alx_read_mem32(hw, ALX_PHY_CTRL);
-	phy &= ~(ALX_PHY_CTRL_DSPRST_OUT | ALX_PHY_CTRL_CLS);
-	phy |= ALX_PHY_CTRL_RST_ANALOG | ALX_PHY_CTRL_HIB_PULSE |
-	       ALX_PHY_CTRL_HIB_EN;
-
-	/* without any activity  */
-	if (!(hw->sleep_ctrl & ALX_SLEEP_ACTIVE)) {
-		err = alx_write_phy_reg(hw, ALX_MII_IER, 0);
-		if (err)
-			return err;
-		phy |= ALX_PHY_CTRL_IDDQ | ALX_PHY_CTRL_POWER_DOWN;
-	} else {
-		if (hw->sleep_ctrl & (ALX_SLEEP_WOL_MAGIC | ALX_SLEEP_CIFS))
-			mac |= ALX_MAC_CTRL_RX_EN | ALX_MAC_CTRL_BRD_EN;
-		if (hw->sleep_ctrl & ALX_SLEEP_CIFS)
-			mac |= ALX_MAC_CTRL_TX_EN;
-		if (duplex == DUPLEX_FULL)
-			mac |= ALX_MAC_CTRL_FULLD;
-		if (speed == SPEED_1000)
-			ALX_SET_FIELD(mac, ALX_MAC_CTRL_SPEED,
-				      ALX_MAC_CTRL_SPEED_1000);
-		phy |= ALX_PHY_CTRL_DSPRST_OUT;
-		err = alx_write_phy_ext(hw, ALX_MIIEXT_ANEG,
-					ALX_MIIEXT_S3DIG10,
-					ALX_MIIEXT_S3DIG10_SL);
-		if (err)
-			return err;
-	}
-
-	alx_enable_osc(hw);
-	hw->rx_ctrl = mac;
-	alx_write_mem32(hw, ALX_MASTER, master);
-	alx_write_mem32(hw, ALX_MAC_CTRL, mac);
-	alx_write_mem32(hw, ALX_PHY_CTRL, phy);
-
-	/* set val of PDLL D3PLLOFF */
-	val = alx_read_mem32(hw, ALX_PDLL_TRNS1);
-	val |= ALX_PDLL_TRNS1_D3PLLOFF_EN;
-	alx_write_mem32(hw, ALX_PDLL_TRNS1, val);
-
-	return 0;
-}
-
 bool alx_phy_configured(struct alx_hw *hw)
 {
 	u32 cfg, hw_cfg;
@@ -990,26 +920,6 @@ int alx_clear_phy_intr(struct alx_hw *hw)
 	return alx_read_phy_reg(hw, ALX_MII_ISR, &isr);
 }
 
-int alx_config_wol(struct alx_hw *hw)
-{
-	u32 wol = 0;
-	int err = 0;
-
-	/* turn on magic packet event */
-	if (hw->sleep_ctrl & ALX_SLEEP_WOL_MAGIC)
-		wol |= ALX_WOL0_MAGIC_EN | ALX_WOL0_PME_MAGIC_EN;
-
-	/* turn on link up event */
-	if (hw->sleep_ctrl & ALX_SLEEP_WOL_PHY) {
-		wol |=  ALX_WOL0_LINK_EN | ALX_WOL0_PME_LINK;
-		/* only link up can wake up */
-		err = alx_write_phy_reg(hw, ALX_MII_IER, ALX_IER_LINK_UP);
-	}
-	alx_write_mem32(hw, ALX_WOL0, wol);
-
-	return err;
-}
-
 void alx_disable_rss(struct alx_hw *hw)
 {
 	u32 ctrl = alx_read_mem32(hw, ALX_RXQ0);
@@ -1121,71 +1031,6 @@ void alx_configure_basic(struct alx_hw *hw)
 	alx_write_mem32(hw, ALX_WRR, val);
 }
 
-int alx_select_powersaving_speed(struct alx_hw *hw, int *speed, u8 *duplex)
-{
-	int i, err;
-	u16 lpa;
-
-	err = alx_read_phy_link(hw);
-	if (err)
-		return err;
-
-	if (hw->link_speed == SPEED_UNKNOWN) {
-		*speed = SPEED_UNKNOWN;
-		*duplex = DUPLEX_UNKNOWN;
-		return 0;
-	}
-
-	err = alx_read_phy_reg(hw, MII_LPA, &lpa);
-	if (err)
-		return err;
-
-	if (!(lpa & LPA_LPACK)) {
-		*speed = hw->link_speed;
-		return 0;
-	}
-
-	if (lpa & LPA_10FULL) {
-		*speed = SPEED_10;
-		*duplex = DUPLEX_FULL;
-	} else if (lpa & LPA_10HALF) {
-		*speed = SPEED_10;
-		*duplex = DUPLEX_HALF;
-	} else if (lpa & LPA_100FULL) {
-		*speed = SPEED_100;
-		*duplex = DUPLEX_FULL;
-	} else {
-		*speed = SPEED_100;
-		*duplex = DUPLEX_HALF;
-	}
-
-	if (*speed == hw->link_speed && *duplex == hw->duplex)
-		return 0;
-	err = alx_write_phy_reg(hw, ALX_MII_IER, 0);
-	if (err)
-		return err;
-	err = alx_setup_speed_duplex(hw, alx_speed_to_ethadv(*speed, *duplex) |
-					 ADVERTISED_Autoneg, ALX_FC_ANEG |
-					 ALX_FC_RX | ALX_FC_TX);
-	if (err)
-		return err;
-
-	/* wait for linkup */
-	for (i = 0; i < ALX_MAX_SETUP_LNK_CYCLE; i++) {
-		msleep(100);
-
-		err = alx_read_phy_link(hw);
-		if (err < 0)
-			return err;
-		if (hw->link_speed != SPEED_UNKNOWN)
-			break;
-	}
-	if (i == ALX_MAX_SETUP_LNK_CYCLE)
-		return -ETIMEDOUT;
-
-	return 0;
-}
-
 bool alx_get_phy_info(struct alx_hw *hw)
 {
 	u16  devs1, devs2;
diff --git a/drivers/net/ethernet/atheros/alx/hw.h b/drivers/net/ethernet/atheros/alx/hw.h
index a60e35c..96f3b43 100644
--- a/drivers/net/ethernet/atheros/alx/hw.h
+++ b/drivers/net/ethernet/atheros/alx/hw.h
@@ -418,8 +418,6 @@ struct alx_hw {
 	u8 flowctrl;
 	u32 adv_cfg;
 
-	u32 sleep_ctrl;
-
 	spinlock_t mdio_lock;
 	struct mdio_if_info mdio;
 	u16 phy_id[2];
@@ -479,14 +477,12 @@ void alx_reset_pcie(struct alx_hw *hw);
 void alx_enable_aspm(struct alx_hw *hw, bool l0s_en, bool l1_en);
 int alx_setup_speed_duplex(struct alx_hw *hw, u32 ethadv, u8 flowctrl);
 void alx_post_phy_link(struct alx_hw *hw);
-int alx_pre_suspend(struct alx_hw *hw, int speed, u8 duplex);
 int alx_read_phy_reg(struct alx_hw *hw, u16 reg, u16 *phy_data);
 int alx_write_phy_reg(struct alx_hw *hw, u16 reg, u16 phy_data);
 int alx_read_phy_ext(struct alx_hw *hw, u8 dev, u16 reg, u16 *pdata);
 int alx_write_phy_ext(struct alx_hw *hw, u8 dev, u16 reg, u16 data);
 int alx_read_phy_link(struct alx_hw *hw);
 int alx_clear_phy_intr(struct alx_hw *hw);
-int alx_config_wol(struct alx_hw *hw);
 void alx_cfg_mac_flowcontrol(struct alx_hw *hw, u8 fc);
 void alx_start_mac(struct alx_hw *hw);
 int alx_reset_mac(struct alx_hw *hw);
@@ -494,7 +490,6 @@ void alx_set_macaddr(struct alx_hw *hw, const u8 *addr);
 bool alx_phy_configured(struct alx_hw *hw);
 void alx_configure_basic(struct alx_hw *hw);
 void alx_disable_rss(struct alx_hw *hw);
-int alx_select_powersaving_speed(struct alx_hw *hw, int *speed, u8 *duplex);
 bool alx_get_phy_info(struct alx_hw *hw);
 
 static inline u32 alx_speed_to_ethadv(int speed, u8 duplex)
diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index 148b4b9..e2f4178 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -706,7 +706,6 @@ static int alx_init_sw(struct alx_priv *alx)
 	alx->rxbuf_size = ALIGN(ALX_RAW_MTU(hw->mtu), 8);
 	alx->tx_ringsz = 256;
 	alx->rx_ringsz = 512;
-	hw->sleep_ctrl = ALX_SLEEP_WOL_MAGIC | ALX_SLEEP_WOL_PHY;
 	hw->imt = 200;
 	alx->int_mask = ALX_ISR_MISC;
 	hw->dma_chnl = hw->max_dma_chnl;
@@ -961,66 +960,6 @@ static int alx_stop(struct net_device *netdev)
 	return 0;
 }
 
-static int __alx_shutdown(struct pci_dev *pdev, bool *wol_en)
-{
-	struct alx_priv *alx = pci_get_drvdata(pdev);
-	struct net_device *netdev = alx->dev;
-	struct alx_hw *hw = &alx->hw;
-	int err, speed;
-	u8 duplex;
-
-	netif_device_detach(netdev);
-
-	if (netif_running(netdev))
-		__alx_stop(alx);
-
-#ifdef CONFIG_PM_SLEEP
-	err = pci_save_state(pdev);
-	if (err)
-		return err;
-#endif
-
-	err = alx_select_powersaving_speed(hw, &speed, &duplex);
-	if (err)
-		return err;
-	err = alx_clear_phy_intr(hw);
-	if (err)
-		return err;
-	err = alx_pre_suspend(hw, speed, duplex);
-	if (err)
-		return err;
-	err = alx_config_wol(hw);
-	if (err)
-		return err;
-
-	*wol_en = false;
-	if (hw->sleep_ctrl & ALX_SLEEP_ACTIVE) {
-		netif_info(alx, wol, netdev,
-			   "wol: ctrl=%X, speed=%X\n",
-			   hw->sleep_ctrl, speed);
-		device_set_wakeup_enable(&pdev->dev, true);
-		*wol_en = true;
-	}
-
-	pci_disable_device(pdev);
-
-	return 0;
-}
-
-static void alx_shutdown(struct pci_dev *pdev)
-{
-	int err;
-	bool wol_en;
-
-	err = __alx_shutdown(pdev, &wol_en);
-	if (!err) {
-		pci_wake_from_d3(pdev, wol_en);
-		pci_set_power_state(pdev, PCI_D3hot);
-	} else {
-		dev_err(&pdev->dev, "shutdown fail %d\n", err);
-	}
-}
-
 static void alx_link_check(struct work_struct *work)
 {
 	struct alx_priv *alx;
@@ -1399,8 +1338,6 @@ static int alx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto out_unmap;
 	}
 
-	device_set_wakeup_enable(&pdev->dev, hw->sleep_ctrl);
-
 	netdev_info(netdev,
 		    "Qualcomm Atheros AR816x/AR817x Ethernet [%pM]\n",
 		    netdev->dev_addr);
@@ -1441,76 +1378,6 @@ static void alx_remove(struct pci_dev *pdev)
 	free_netdev(alx->dev);
 }
 
-#ifdef CONFIG_PM_SLEEP
-static int alx_suspend(struct device *dev)
-{
-	struct pci_dev *pdev = to_pci_dev(dev);
-	int err;
-	bool wol_en;
-
-	err = __alx_shutdown(pdev, &wol_en);
-	if (err) {
-		dev_err(&pdev->dev, "shutdown fail in suspend %d\n", err);
-		return err;
-	}
-
-	if (wol_en) {
-		pci_prepare_to_sleep(pdev);
-	} else {
-		pci_wake_from_d3(pdev, false);
-		pci_set_power_state(pdev, PCI_D3hot);
-	}
-
-	return 0;
-}
-
-static int alx_resume(struct device *dev)
-{
-	struct pci_dev *pdev = to_pci_dev(dev);
-	struct alx_priv *alx = pci_get_drvdata(pdev);
-	struct net_device *netdev = alx->dev;
-	struct alx_hw *hw = &alx->hw;
-	int err;
-
-	pci_set_power_state(pdev, PCI_D0);
-	pci_restore_state(pdev);
-	pci_save_state(pdev);
-
-	pci_enable_wake(pdev, PCI_D3hot, 0);
-	pci_enable_wake(pdev, PCI_D3cold, 0);
-
-	hw->link_speed = SPEED_UNKNOWN;
-	alx->int_mask = ALX_ISR_MISC;
-
-	alx_reset_pcie(hw);
-	alx_reset_phy(hw);
-
-	err = alx_reset_mac(hw);
-	if (err) {
-		netif_err(alx, hw, alx->dev,
-			  "resume:reset_mac fail %d\n", err);
-		return -EIO;
-	}
-
-	err = alx_setup_speed_duplex(hw, hw->adv_cfg, hw->flowctrl);
-	if (err) {
-		netif_err(alx, hw, alx->dev,
-			  "resume:setup_speed_duplex fail %d\n", err);
-		return -EIO;
-	}
-
-	if (netif_running(netdev)) {
-		err = __alx_open(alx, true);
-		if (err)
-			return err;
-	}
-
-	netif_device_attach(netdev);
-
-	return err;
-}
-#endif
-
 static pci_ers_result_t alx_pci_error_detected(struct pci_dev *pdev,
 					       pci_channel_state_t state)
 {
@@ -1553,8 +1420,6 @@ static pci_ers_result_t alx_pci_error_slot_reset(struct pci_dev *pdev)
 	}
 
 	pci_set_master(pdev);
-	pci_enable_wake(pdev, PCI_D3hot, 0);
-	pci_enable_wake(pdev, PCI_D3cold, 0);
 
 	alx_reset_pcie(hw);
 	if (!alx_reset_mac(hw))
@@ -1590,13 +1455,6 @@ static const struct pci_error_handlers alx_err_handlers = {
 	.resume         = alx_pci_error_resume,
 };
 
-#ifdef CONFIG_PM_SLEEP
-static SIMPLE_DEV_PM_OPS(alx_pm_ops, alx_suspend, alx_resume);
-#define ALX_PM_OPS      (&alx_pm_ops)
-#else
-#define ALX_PM_OPS      NULL
-#endif
-
 static DEFINE_PCI_DEVICE_TABLE(alx_pci_tbl) = {
 	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_AR8161),
 	  .driver_data = ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG },
@@ -1614,9 +1472,7 @@ static struct pci_driver alx_driver = {
 	.id_table    = alx_pci_tbl,
 	.probe       = alx_probe,
 	.remove      = alx_remove,
-	.shutdown    = alx_shutdown,
 	.err_handler = &alx_err_handlers,
-	.driver.pm   = ALX_PM_OPS,
 };
 
 module_pci_driver(alx_driver);
-- 
1.8.0
