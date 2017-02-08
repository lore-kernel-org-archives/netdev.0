From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2 2/3] net: phy: Check phydev->drv
Date: Tue,  7 Feb 2017 23:37:45 -0800
Message-ID: <20170208073746.10963-3-f.fainelli@gmail.com>
References: <20170208073746.10963-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, rmk+kernel@armlinux.org.uk,
        maowenan@huawei.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f194.google.com ([74.125.82.194]:33435 "EHLO
        mail-ot0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932193AbdBHHhw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 02:37:52 -0500
Received: by mail-ot0-f194.google.com with SMTP id f9so17146013otd.0
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 23:37:52 -0800 (PST)
In-Reply-To: <20170208073746.10963-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for supporting driver bind/unbind properly, sprinkle checks on
phydev->drv where we may call into PHYLIB from user-space or other parts of the
kernel.

Suggested-by: Russell King <rmk+kernel@armlinux.org.uk>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c | 26 ++++++++++++++++++++++----
 include/linux/phy.h   |  3 +++
 2 files changed, 25 insertions(+), 4 deletions(-)

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
