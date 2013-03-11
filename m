From: Michael Stapelberg <michael@stapelberg.de>
Subject: [PATCH net-next 1/2] phy: add set_wol/get_wol functions
Date: Tue, 12 Mar 2013 00:56:44 +0100
Message-ID: <1363046205-17239-1-git-send-email-michael@stapelberg.de>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	Andrew Lunn <andrew@lunn.ch>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Michael Stapelberg <michael@stapelberg.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from infra.in.zekjur.net ([79.140.39.194]:33347 "EHLO
	infra.in.zekjur.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754571Ab3CLAEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 20:04:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows ethernet drivers (such as the mv643xx_eth) to support
Wake on LAN on platforms where PHY registers have to be configured
for Wake on LAN (e.g. the Marvell Kirkwood based qnap TS-119P II).

Signed-off-by: Michael Stapelberg <michael@stapelberg.de>
---
 drivers/net/phy/phy.c |   16 ++++++++++++++++
 include/linux/phy.h   |   10 ++++++++++
 2 files changed, 26 insertions(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index ef9ea92..298b4c2 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1188,3 +1188,19 @@ int phy_ethtool_set_eee(struct phy_device *phydev, struct ethtool_eee *data)
 	return 0;
 }
 EXPORT_SYMBOL(phy_ethtool_set_eee);
+
+int phy_ethtool_set_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol)
+{
+	if (phydev->drv->set_wol)
+		return phydev->drv->set_wol(phydev, wol);
+
+	return -EOPNOTSUPP;
+}
+EXPORT_SYMBOL(phy_ethtool_set_wol);
+
+void phy_ethtool_get_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol)
+{
+	if (phydev->drv->get_wol)
+		phydev->drv->get_wol(phydev, wol);
+}
+EXPORT_SYMBOL(phy_ethtool_get_wol);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 33999ad..9e11039 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -455,6 +455,14 @@ struct phy_driver {
 	 */
 	void (*txtstamp)(struct phy_device *dev, struct sk_buff *skb, int type);
 
+	/* Some devices (e.g. qnap TS-119P II) require PHY register changes to
+	 * enable Wake on LAN, so set_wol is provided to be called in the
+	 * ethernet driver's set_wol function. */
+	int (*set_wol)(struct phy_device *dev, struct ethtool_wolinfo *wol);
+
+	/* See set_wol, but for checking whether Wake on LAN is enabled. */
+	void (*get_wol)(struct phy_device *dev, struct ethtool_wolinfo *wol);
+
 	struct device_driver driver;
 };
 #define to_phy_driver(d) container_of(d, struct phy_driver, driver)
@@ -560,6 +568,8 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable);
 int phy_get_eee_err(struct phy_device *phydev);
 int phy_ethtool_set_eee(struct phy_device *phydev, struct ethtool_eee *data);
 int phy_ethtool_get_eee(struct phy_device *phydev, struct ethtool_eee *data);
+int phy_ethtool_set_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol);
+void phy_ethtool_get_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol);
 
 int __init mdio_bus_init(void);
 void mdio_bus_exit(void);
-- 
1.7.10.4
