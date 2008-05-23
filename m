From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 5/8] tg3: Add libphy support.
Date: Thu, 22 May 2008 19:57:05 -0700
Message-ID: <1211511425.0@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4999 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758078AbYEWCxg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 22:53:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces the libphy support.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index f5cb1c0..a555ddc 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1114,11 +1114,17 @@ static u8 tg3_resolve_flowctrl_1000X(u16 lcladv, u16 rmtadv)
 
 static void tg3_setup_flow_control(struct tg3 *tp, u32 lcladv, u32 rmtadv)
 {
+	u8 autoneg;
 	u8 flowctrl = 0;
 	u32 old_rx_mode = tp->rx_mode;
 	u32 old_tx_mode = tp->tx_mode;
 
-	if (tp->link_config.autoneg == AUTONEG_ENABLE &&
+	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB)
+		autoneg = tp->mdio_bus.phy_map[PHY_ADDR]->autoneg;
+	else
+		autoneg = tp->link_config.autoneg;
+
+	if (autoneg == AUTONEG_ENABLE &&
 	    (tp->tg3_flags & TG3_FLAG_PAUSE_AUTONEG)) {
 		if (tp->tg3_flags2 & TG3_FLG2_ANY_SERDES)
 			flowctrl = tg3_resolve_flowctrl_1000X(lcladv, rmtadv);
@@ -1146,6 +1152,152 @@ static void tg3_setup_flow_control(struct tg3 *tp, u32 lcladv, u32 rmtadv)
 		tw32_f(MAC_TX_MODE, tp->tx_mode);
 }
 
+static void tg3_adjust_link(struct net_device *dev)
+{
+	u8 oldflowctrl, linkmesg = 0;
+	u32 mac_mode, lcl_adv, rmt_adv;
+	struct tg3 *tp = netdev_priv(dev);
+	struct phy_device *phydev = tp->mdio_bus.phy_map[PHY_ADDR];
+
+	spin_lock(&tp->lock);
+
+	mac_mode = tp->mac_mode & ~(MAC_MODE_PORT_MODE_MASK |
+				    MAC_MODE_HALF_DUPLEX);
+
+	oldflowctrl = tp->link_config.active_flowctrl;
+
+	if (phydev->link) {
+		lcl_adv = 0;
+		rmt_adv = 0;
+
+		if (phydev->speed == SPEED_100 || phydev->speed == SPEED_10)
+			mac_mode |= MAC_MODE_PORT_MODE_MII;
+		else
+			mac_mode |= MAC_MODE_PORT_MODE_GMII;
+
+		if (phydev->duplex == DUPLEX_HALF)
+			mac_mode |= MAC_MODE_HALF_DUPLEX;
+		else {
+			lcl_adv = tg3_advert_flowctrl_1000T(
+				  tp->link_config.flowctrl);
+
+			if (phydev->pause)
+				rmt_adv = LPA_PAUSE_CAP;
+			if (phydev->asym_pause)
+				rmt_adv |= LPA_PAUSE_ASYM;
+		}
+
+		tg3_setup_flow_control(tp, lcl_adv, rmt_adv);
+	} else
+		mac_mode |= MAC_MODE_PORT_MODE_GMII;
+
+	if (mac_mode != tp->mac_mode) {
+		tp->mac_mode = mac_mode;
+		tw32_f(MAC_MODE, tp->mac_mode);
+		udelay(40);
+	}
+
+	if (phydev->speed == SPEED_1000 && phydev->duplex == DUPLEX_HALF)
+		tw32(MAC_TX_LENGTHS,
+		     ((2 << TX_LENGTHS_IPG_CRS_SHIFT) |
+		      (6 << TX_LENGTHS_IPG_SHIFT) |
+		      (0xff << TX_LENGTHS_SLOT_TIME_SHIFT)));
+	else
+		tw32(MAC_TX_LENGTHS,
+		     ((2 << TX_LENGTHS_IPG_CRS_SHIFT) |
+		      (6 << TX_LENGTHS_IPG_SHIFT) |
+		      (32 << TX_LENGTHS_SLOT_TIME_SHIFT)));
+
+	if ((phydev->link && tp->link_config.active_speed == SPEED_INVALID) ||
+	    (!phydev->link && tp->link_config.active_speed != SPEED_INVALID) ||
+	    phydev->speed != tp->link_config.active_speed ||
+	    phydev->duplex != tp->link_config.active_duplex ||
+	    oldflowctrl != tp->link_config.active_flowctrl)
+	    linkmesg = 1;
+
+	tp->link_config.active_speed = phydev->speed;
+	tp->link_config.active_duplex = phydev->duplex;
+
+	spin_unlock(&tp->lock);
+
+	if (linkmesg)
+		tg3_link_report(tp);
+}
+
+static int tg3_phy_init(struct tg3 *tp)
+{
+	struct phy_device *phydev;
+
+	if (tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED)
+		return 0;
+
+	/* Bring the PHY back to a known state. */
+	tg3_bmcr_reset(tp);
+
+	phydev = tp->mdio_bus.phy_map[PHY_ADDR];
+
+	/* Attach the MAC to the PHY. */
+	phydev = phy_connect(tp->dev, phydev->dev.bus_id,
+			     tg3_adjust_link, 0, phydev->interface);
+	if (IS_ERR(phydev)) {
+		printk(KERN_ERR "%s: Could not attach to PHY\n", tp->dev->name);
+		return PTR_ERR(phydev);
+	}
+
+	tp->tg3_flags3 |= TG3_FLG3_PHY_CONNECTED;
+
+	/* Mask with MAC supported features. */
+	phydev->supported &= (PHY_GBIT_FEATURES |
+			      SUPPORTED_Pause |
+			      SUPPORTED_Asym_Pause);
+
+	phydev->advertising = phydev->supported;
+
+	printk(KERN_INFO
+	       "%s: attached PHY driver [%s] (mii_bus:phy_addr=%s)\n",
+	       tp->dev->name, phydev->drv->name, phydev->dev.bus_id);
+
+	return 0;
+}
+
+static void tg3_phy_start(struct tg3 *tp)
+{
+	struct phy_device *phydev;
+
+	if (!(tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED))
+		return;
+
+	phydev = tp->mdio_bus.phy_map[PHY_ADDR];
+
+	if (tp->link_config.phy_is_low_power) {
+		tp->link_config.phy_is_low_power = 0;
+		phydev->speed = tp->link_config.orig_speed;
+		phydev->duplex = tp->link_config.orig_duplex;
+		phydev->autoneg = tp->link_config.orig_autoneg;
+		phydev->advertising = tp->link_config.orig_advertising;
+	}
+
+	phy_start(phydev);
+
+	phy_start_aneg(phydev);
+}
+
+static void tg3_phy_stop(struct tg3 *tp)
+{
+	if (!(tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED))
+		return;
+
+	phy_stop(tp->mdio_bus.phy_map[PHY_ADDR]);
+}
+
+static void tg3_phy_fini(struct tg3 *tp)
+{
+	if (tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED) {
+		phy_disconnect(tp->mdio_bus.phy_map[PHY_ADDR]);
+		tp->tg3_flags3 &= ~TG3_FLG3_PHY_CONNECTED;
+	}
+}
+
 static void tg3_phydsp_write(struct tg3 *tp, u32 reg, u32 val)
 {
 	tg3_writephy(tp, MII_TG3_DSP_ADDRESS, reg);
@@ -1798,7 +1950,40 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 	     misc_host_ctrl | MISC_HOST_CTRL_MASK_PCI_INT);
 
 	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
-		tp->link_config.phy_is_low_power = 1;
+		if ((tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED) &&
+		    !tp->link_config.phy_is_low_power) {
+			struct phy_device *phydev;
+			u32 advertising;
+
+			phydev = tp->mdio_bus.phy_map[PHY_ADDR];
+
+			tp->link_config.phy_is_low_power = 1;
+
+			tp->link_config.orig_speed = phydev->speed;
+			tp->link_config.orig_duplex = phydev->duplex;
+			tp->link_config.orig_autoneg = phydev->autoneg;
+			tp->link_config.orig_advertising = phydev->advertising;
+
+			advertising = ADVERTISED_TP |
+				      ADVERTISED_Pause |
+				      ADVERTISED_Autoneg |
+				      ADVERTISED_10baseT_Half;
+
+			if ((tp->tg3_flags & TG3_FLAG_ENABLE_ASF) ||
+			    (tp->tg3_flags & TG3_FLAG_WOL_ENABLE)) {
+				if (tp->tg3_flags & TG3_FLAG_WOL_SPEED_100MB)
+					advertising |=
+						ADVERTISED_100baseT_Half |
+						ADVERTISED_100baseT_Full |
+						ADVERTISED_10baseT_Full;
+				else
+					advertising |= ADVERTISED_10baseT_Full;
+			}
+
+			phydev->advertising = advertising;
+
+			phy_start_aneg(phydev);
+		}
 	} else {
 		if (tp->link_config.phy_is_low_power == 0) {
 			tp->link_config.phy_is_low_power = 1;
@@ -4233,6 +4418,7 @@ static void tg3_poll_controller(struct net_device *dev)
 static void tg3_reset_task(struct work_struct *work)
 {
 	struct tg3 *tp = container_of(work, struct tg3, reset_task);
+	int err;
 	unsigned int restart_timer;
 
 	tg3_full_lock(tp, 0);
@@ -4244,6 +4430,8 @@ static void tg3_reset_task(struct work_struct *work)
 
 	tg3_full_unlock(tp);
 
+	tg3_phy_stop(tp);
+
 	tg3_netif_stop(tp);
 
 	tg3_full_lock(tp, 1);
@@ -4259,7 +4447,8 @@ static void tg3_reset_task(struct work_struct *work)
 	}
 
 	tg3_halt(tp, RESET_KIND_SHUTDOWN, 0);
-	if (tg3_init_hw(tp, 1))
+	err = tg3_init_hw(tp, 1);
+	if (err)
 		goto out;
 
 	tg3_netif_start(tp);
@@ -4269,6 +4458,9 @@ static void tg3_reset_task(struct work_struct *work)
 
 out:
 	tg3_full_unlock(tp);
+
+	if (!err)
+		tg3_phy_start(tp);
 }
 
 static void tg3_dump_short_state(struct tg3 *tp)
@@ -4772,6 +4964,8 @@ static int tg3_change_mtu(struct net_device *dev, int new_mtu)
 		return 0;
 	}
 
+	tg3_phy_stop(tp);
+
 	tg3_netif_stop(tp);
 
 	tg3_full_lock(tp, 1);
@@ -4787,6 +4981,9 @@ static int tg3_change_mtu(struct net_device *dev, int new_mtu)
 
 	tg3_full_unlock(tp);
 
+	if (!err)
+		tg3_phy_start(tp);
+
 	return err;
 }
 
@@ -7864,6 +8061,8 @@ static int tg3_open(struct net_device *dev)
 		}
 	}
 
+	tg3_phy_start(tp);
+
 	tg3_full_lock(tp, 0);
 
 	add_timer(&tp->timer);
@@ -8665,7 +8864,13 @@ static int tg3_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 
 static int tg3_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-  	struct tg3 *tp = netdev_priv(dev);
+	struct tg3 *tp = netdev_priv(dev);
+
+	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
+		if (!(tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED))
+			return -EAGAIN;
+		return phy_ethtool_gset(tp->mdio_bus.phy_map[PHY_ADDR], cmd);
+	}
 
 	cmd->supported = (SUPPORTED_Autoneg);
 
@@ -8702,6 +8907,12 @@ static int tg3_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct tg3 *tp = netdev_priv(dev);
 
+	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
+		if (!(tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED))
+			return -EAGAIN;
+		return phy_ethtool_sset(tp->mdio_bus.phy_map[PHY_ADDR], cmd);
+	}
+
 	if (tp->tg3_flags2 & TG3_FLG2_ANY_SERDES) {
 		/* These are the only valid advertisement bits allowed.  */
 		if (cmd->autoneg == AUTONEG_ENABLE &&
@@ -8734,7 +8945,7 @@ static int tg3_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		tp->link_config.advertising = 0;
 		tp->link_config.speed = cmd->speed;
 		tp->link_config.duplex = cmd->duplex;
-  	}
+	}
 
 	tp->link_config.orig_speed = tp->link_config.speed;
 	tp->link_config.orig_duplex = tp->link_config.duplex;
@@ -8828,7 +9039,6 @@ static int tg3_set_tso(struct net_device *dev, u32 value)
 static int tg3_nway_reset(struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
-	u32 bmcr;
 	int r;
 
 	if (!netif_running(dev))
@@ -8837,17 +9047,25 @@ static int tg3_nway_reset(struct net_device *dev)
 	if (tp->tg3_flags2 & TG3_FLG2_PHY_SERDES)
 		return -EINVAL;
 
-	spin_lock_bh(&tp->lock);
-	r = -EINVAL;
-	tg3_readphy(tp, MII_BMCR, &bmcr);
-	if (!tg3_readphy(tp, MII_BMCR, &bmcr) &&
-	    ((bmcr & BMCR_ANENABLE) ||
-	     (tp->tg3_flags2 & TG3_FLG2_PARALLEL_DETECT))) {
-		tg3_writephy(tp, MII_BMCR, bmcr | BMCR_ANRESTART |
-					   BMCR_ANENABLE);
-		r = 0;
+	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
+		if (!(tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED))
+			return -EAGAIN;
+		r = phy_start_aneg(tp->mdio_bus.phy_map[PHY_ADDR]);
+	} else {
+		u32 bmcr;
+
+		spin_lock_bh(&tp->lock);
+		r = -EINVAL;
+		tg3_readphy(tp, MII_BMCR, &bmcr);
+		if (!tg3_readphy(tp, MII_BMCR, &bmcr) &&
+		    ((bmcr & BMCR_ANENABLE) ||
+		     (tp->tg3_flags2 & TG3_FLG2_PARALLEL_DETECT))) {
+			tg3_writephy(tp, MII_BMCR, bmcr | BMCR_ANRESTART |
+						   BMCR_ANENABLE);
+			r = 0;
+		}
+		spin_unlock_bh(&tp->lock);
 	}
-	spin_unlock_bh(&tp->lock);
 
 	return r;
 }
@@ -8889,6 +9107,7 @@ static int tg3_set_ringparam(struct net_device *dev, struct ethtool_ringparam *e
 		return -EINVAL;
 
 	if (netif_running(dev)) {
+		tg3_phy_stop(tp);
 		tg3_netif_stop(tp);
 		irq_sync = 1;
 	}
@@ -8912,6 +9131,9 @@ static int tg3_set_ringparam(struct net_device *dev, struct ethtool_ringparam *e
 
 	tg3_full_unlock(tp);
 
+	if (irq_sync && !err)
+		tg3_phy_start(tp);
+
 	return err;
 }
 
@@ -8935,36 +9157,92 @@ static void tg3_get_pauseparam(struct net_device *dev, struct ethtool_pauseparam
 static int tg3_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam *epause)
 {
 	struct tg3 *tp = netdev_priv(dev);
-	int irq_sync = 0, err = 0;
+	int err = 0;
 
-	if (netif_running(dev)) {
-		tg3_netif_stop(tp);
-		irq_sync = 1;
-	}
+	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
+		if (!(tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED))
+			return -EAGAIN;
 
-	tg3_full_lock(tp, irq_sync);
+		if (epause->autoneg) {
+			u32 newadv;
+			struct phy_device *phydev;
 
-	if (epause->autoneg)
-		tp->tg3_flags |= TG3_FLAG_PAUSE_AUTONEG;
-	else
-		tp->tg3_flags &= ~TG3_FLAG_PAUSE_AUTONEG;
-	if (epause->rx_pause)
-		tp->link_config.flowctrl |= TG3_FLOW_CTRL_RX;
-	else
-		tp->link_config.flowctrl &= ~TG3_FLOW_CTRL_RX;
-	if (epause->tx_pause)
-		tp->link_config.flowctrl |= TG3_FLOW_CTRL_TX;
-	else
-		tp->link_config.flowctrl &= ~TG3_FLOW_CTRL_TX;
+			phydev = tp->mdio_bus.phy_map[PHY_ADDR];
 
-	if (netif_running(dev)) {
-		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
-		err = tg3_restart_hw(tp, 1);
-		if (!err)
-			tg3_netif_start(tp);
-	}
+			if (epause->rx_pause) {
+				if (epause->tx_pause)
+					newadv = ADVERTISED_Pause;
+				else
+					newadv = ADVERTISED_Pause |
+						 ADVERTISED_Asym_Pause;
+			} else if (epause->tx_pause) {
+				newadv = ADVERTISED_Asym_Pause;
+			} else
+				newadv = 0;
+
+			if (tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED) {
+				u32 oldadv = phydev->advertising &
+					     (ADVERTISED_Pause |
+					      ADVERTISED_Asym_Pause);
+				if (oldadv != newadv) {
+					phydev->advertising &=
+						~(ADVERTISED_Pause |
+						  ADVERTISED_Asym_Pause);
+					phydev->advertising |= newadv;
+					err = phy_start_aneg(phydev);
+				}
+			} else {
+				tp->link_config.advertising &=
+						~(ADVERTISED_Pause |
+						  ADVERTISED_Asym_Pause);
+				tp->link_config.advertising |= newadv;
+			}
+		} else {
+			if (epause->rx_pause)
+				tp->link_config.flowctrl |= TG3_FLOW_CTRL_RX;
+			else
+				tp->link_config.flowctrl &= ~TG3_FLOW_CTRL_RX;
 
-	tg3_full_unlock(tp);
+			if (epause->tx_pause)
+				tp->link_config.flowctrl |= TG3_FLOW_CTRL_TX;
+			else
+				tp->link_config.flowctrl &= ~TG3_FLOW_CTRL_TX;
+
+			if (netif_running(dev))
+				tg3_setup_flow_control(tp, 0, 0);
+		}
+	} else {
+		int irq_sync = 0;
+
+		if (netif_running(dev)) {
+			tg3_netif_stop(tp);
+			irq_sync = 1;
+		}
+
+		tg3_full_lock(tp, irq_sync);
+
+		if (epause->autoneg)
+			tp->tg3_flags |= TG3_FLAG_PAUSE_AUTONEG;
+		else
+			tp->tg3_flags &= ~TG3_FLAG_PAUSE_AUTONEG;
+		if (epause->rx_pause)
+			tp->link_config.flowctrl |= TG3_FLOW_CTRL_RX;
+		else
+			tp->link_config.flowctrl &= ~TG3_FLOW_CTRL_RX;
+		if (epause->tx_pause)
+			tp->link_config.flowctrl |= TG3_FLOW_CTRL_TX;
+		else
+			tp->link_config.flowctrl &= ~TG3_FLOW_CTRL_TX;
+
+		if (netif_running(dev)) {
+			tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
+			err = tg3_restart_hw(tp, 1);
+			if (!err)
+				tg3_netif_start(tp);
+		}
+
+		tg3_full_unlock(tp);
+	}
 
 	return err;
 }
@@ -9799,9 +10077,10 @@ static void tg3_self_test(struct net_device *dev, struct ethtool_test *etest,
 		data[1] = 1;
 	}
 	if (etest->flags & ETH_TEST_FL_OFFLINE) {
-		int err, irq_sync = 0;
+		int err, err2 = 0, irq_sync = 0;
 
 		if (netif_running(dev)) {
+			tg3_phy_stop(tp);
 			tg3_netif_stop(tp);
 			irq_sync = 1;
 		}
@@ -9842,11 +10121,15 @@ static void tg3_self_test(struct net_device *dev, struct ethtool_test *etest,
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
 		if (netif_running(dev)) {
 			tp->tg3_flags |= TG3_FLAG_INIT_COMPLETE;
-			if (!tg3_restart_hw(tp, 1))
+			err2 = tg3_restart_hw(tp, 1);
+			if (!err2)
 				tg3_netif_start(tp);
 		}
 
 		tg3_full_unlock(tp);
+
+		if (irq_sync && !err2)
+			tg3_phy_start(tp);
 	}
 	if (tp->link_config.phy_is_low_power)
 		tg3_set_power_state(tp, PCI_D3hot);
@@ -9859,6 +10142,12 @@ static int tg3_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	struct tg3 *tp = netdev_priv(dev);
 	int err;
 
+	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
+		if (!(tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED))
+			return -EAGAIN;
+		return phy_mii_ioctl(tp->mdio_bus.phy_map[PHY_ADDR], data, cmd);
+	}
+
 	switch(cmd) {
 	case SIOCGMIIPHY:
 		data->phy_id = PHY_ADDR;
@@ -11110,6 +11399,9 @@ static int __devinit tg3_phy_probe(struct tg3 *tp)
 	u32 hw_phy_id, hw_phy_id_masked;
 	int err;
 
+	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB)
+		return tg3_phy_init(tp);
+
 	/* Reading the PHY ID register can conflict with ASF
 	 * firwmare access to the PHY hardware.
 	 */
@@ -12043,6 +12335,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		printk(KERN_ERR PFX "(%s) phy probe failed, err %d\n",
 		       pci_name(tp->pdev), err);
 		/* ... but do not return immediately ... */
+		tg3_mdio_fini(tp);
 	}
 
 	tg3_read_partno(tp);
@@ -13163,8 +13456,10 @@ static void __devexit tg3_remove_one(struct pci_dev *pdev)
 
 		flush_scheduled_work();
 
-		if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB)
+		if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
+			tg3_phy_fini(tp);
 			tg3_mdio_fini(tp);
+		}
 
 		unregister_netdev(dev);
 		if (tp->aperegs) {
@@ -13198,6 +13493,7 @@ static int tg3_suspend(struct pci_dev *pdev, pm_message_t state)
 		return 0;
 
 	flush_scheduled_work();
+	tg3_phy_stop(tp);
 	tg3_netif_stop(tp);
 
 	del_timer_sync(&tp->timer);
@@ -13215,10 +13511,13 @@ static int tg3_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	err = tg3_set_power_state(tp, pci_choose_state(pdev, state));
 	if (err) {
+		int err2;
+
 		tg3_full_lock(tp, 0);
 
 		tp->tg3_flags |= TG3_FLAG_INIT_COMPLETE;
-		if (tg3_restart_hw(tp, 1))
+		err2 = tg3_restart_hw(tp, 1);
+		if (err2)
 			goto out;
 
 		tp->timer.expires = jiffies + tp->timer_offset;
@@ -13229,6 +13528,9 @@ static int tg3_suspend(struct pci_dev *pdev, pm_message_t state)
 
 out:
 		tg3_full_unlock(tp);
+
+		if (!err2)
+			tg3_phy_start(tp);
 	}
 
 	return err;
@@ -13266,6 +13568,9 @@ static int tg3_resume(struct pci_dev *pdev)
 out:
 	tg3_full_unlock(tp);
 
+	if (!err)
+		tg3_phy_start(tp);
+
 	return err;
 }
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index e0914fd..48f45c1 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2205,6 +2205,7 @@ struct tg3_link_config {
 	u16				orig_speed;
 	u8				orig_duplex;
 	u8				orig_autoneg;
+	u32				orig_advertising;
 };
 
 struct tg3_bufmgr_config {
@@ -2483,6 +2484,7 @@ struct tg3 {
 #define TG3_FLG3_USE_PHYLIB		0x00000010
 #define TG3_FLG3_MDIOBUS_INITED		0x00000020
 #define TG3_FLG3_MDIOBUS_PAUSED		0x00000040
+#define TG3_FLG3_PHY_CONNECTED		0x00000080
 
 	struct timer_list		timer;
 	u16				timer_counter;


