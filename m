From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/2] net: phy: Check phydev->drv
Date: Fri, 17 Feb 2017 16:07:34 -0800
Message-ID: <20170218000734.32590-3-f.fainelli@gmail.com>
References: <20170218000734.32590-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, rmk+kernel@armlinux.org.uk,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35890 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752324AbdBRAQb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 19:16:31 -0500
Received: by mail-wr0-f196.google.com with SMTP id z61so5938180wrc.3
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 16:16:30 -0800 (PST)
In-Reply-To: <20170218000734.32590-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are number of function calls, originating from user-space,
typically through the Ethernet driver that can make us crash by
dereferencing phydev->drv which will be NULL once we unbind the driver
from the PHY.

There are still functional issues that prevent an unbind then rebind to
work, but these will be addressed separately.

Suggested-by: Russell King <rmk+kernel@armlinux.org.uk>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c        | 26 ++++++++++++++++++++++----
 drivers/net/phy/phy_device.c |  6 +++---
 include/linux/phy.h          |  3 +++
 3 files changed, 28 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 7cc1b7dcfe05..d6f7838455dd 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -580,7 +580,7 @@ int phy_mii_ioctl(struct phy_device *phydev, struct ifreq *ifr, int cmd)
 		return 0;
 
 	case SIOCSHWTSTAMP:
-		if (phydev->drv->hwtstamp)
+		if (phydev->drv && phydev->drv->hwtstamp)
 			return phydev->drv->hwtstamp(phydev, ifr);
 		/* fall through */
 
@@ -603,6 +603,9 @@ int phy_start_aneg(struct phy_device *phydev)
 {
 	int err;
 
+	if (!phydev->drv)
+		return -EIO;
+
 	mutex_lock(&phydev->lock);
 
 	if (AUTONEG_DISABLE == phydev->autoneg)
@@ -975,7 +978,7 @@ void phy_state_machine(struct work_struct *work)
 
 	old_state = phydev->state;
 
-	if (phydev->drv->link_change_notify)
+	if (phydev->drv && phydev->drv->link_change_notify)
 		phydev->drv->link_change_notify(phydev);
 
 	switch (phydev->state) {
@@ -1286,6 +1289,9 @@ EXPORT_SYMBOL(phy_write_mmd_indirect);
  */
 int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 {
+	if (!phydev->drv)
+		return -EIO;
+
 	/* According to 802.3az,the EEE is supported only in full duplex-mode.
 	 * Also EEE feature is active when core is operating with MII, GMII
 	 * or RGMII (all kinds). Internal PHYs are also allowed to proceed and
@@ -1363,6 +1369,9 @@ EXPORT_SYMBOL(phy_init_eee);
  */
 int phy_get_eee_err(struct phy_device *phydev)
 {
+	if (!phydev->drv)
+		return -EIO;
+
 	return phy_read_mmd_indirect(phydev, MDIO_PCS_EEE_WK_ERR, MDIO_MMD_PCS);
 }
 EXPORT_SYMBOL(phy_get_eee_err);
@@ -1379,6 +1388,9 @@ int phy_ethtool_get_eee(struct phy_device *phydev, struct ethtool_eee *data)
 {
 	int val;
 
+	if (!phydev->drv)
+		return -EIO;
+
 	/* Get Supported EEE */
 	val = phy_read_mmd_indirect(phydev, MDIO_PCS_EEE_ABLE, MDIO_MMD_PCS);
 	if (val < 0)
@@ -1412,6 +1424,9 @@ int phy_ethtool_set_eee(struct phy_device *phydev, struct ethtool_eee *data)
 {
 	int val = ethtool_adv_to_mmd_eee_adv_t(data->advertised);
 
+	if (!phydev->drv)
+		return -EIO;
+
 	/* Mask prohibited EEE modes */
 	val &= ~phydev->eee_broken_modes;
 
@@ -1423,7 +1438,7 @@ EXPORT_SYMBOL(phy_ethtool_set_eee);
 
 int phy_ethtool_set_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol)
 {
-	if (phydev->drv->set_wol)
+	if (phydev->drv && phydev->drv->set_wol)
 		return phydev->drv->set_wol(phydev, wol);
 
 	return -EOPNOTSUPP;
@@ -1432,7 +1447,7 @@ EXPORT_SYMBOL(phy_ethtool_set_wol);
 
 void phy_ethtool_get_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol)
 {
-	if (phydev->drv->get_wol)
+	if (phydev->drv && phydev->drv->get_wol)
 		phydev->drv->get_wol(phydev, wol);
 }
 EXPORT_SYMBOL(phy_ethtool_get_wol);
@@ -1468,6 +1483,9 @@ int phy_ethtool_nway_reset(struct net_device *ndev)
 	if (!phydev)
 		return -ENODEV;
 
+	if (!phydev->drv)
+		return -EIO;
+
 	return genphy_restart_aneg(phydev);
 }
 EXPORT_SYMBOL(phy_ethtool_nway_reset);
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 7f9319586b7e..daec6555f3b1 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1094,7 +1094,7 @@ int phy_suspend(struct phy_device *phydev)
 	if (wol.wolopts)
 		return -EBUSY;
 
-	if (phydrv->suspend)
+	if (phydev->drv && phydrv->suspend)
 		ret = phydrv->suspend(phydev);
 
 	if (ret)
@@ -1111,7 +1111,7 @@ int phy_resume(struct phy_device *phydev)
 	struct phy_driver *phydrv = to_phy_driver(phydev->mdio.dev.driver);
 	int ret = 0;
 
-	if (phydrv->resume)
+	if (phydev->drv && phydrv->resume)
 		ret = phydrv->resume(phydev);
 
 	if (ret)
@@ -1790,7 +1790,7 @@ static int phy_remove(struct device *dev)
 	phydev->state = PHY_DOWN;
 	mutex_unlock(&phydev->lock);
 
-	if (phydev->drv->remove)
+	if (phydev->drv && phydev->drv->remove)
 		phydev->drv->remove(phydev);
 	phydev->drv = NULL;
 
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 7fc1105605bf..231e07bb0d76 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -802,6 +802,9 @@ int phy_stop_interrupts(struct phy_device *phydev);
 
 static inline int phy_read_status(struct phy_device *phydev)
 {
+	if (!phydev->drv)
+		return -EIO;
+
 	return phydev->drv->read_status(phydev);
 }
 
-- 
2.9.3
