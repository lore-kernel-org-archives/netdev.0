From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 3/6] net: phy: hook up clause 45 autonegotiation restart
Date: Mon, 05 Jun 2017 12:23:00 +0100
Message-ID: <E1dHq68-0005Wy-Na@rmk-PC.armlinux.org.uk>
References: <20170605112203.GA10680@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:33002 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751859AbdFELXE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 07:23:04 -0400
In-Reply-To: <20170605112203.GA10680@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

genphy_restart_aneg() can only restart autonegotiation on clause 22
PHYs.  Add a phy_restart_aneg() function which selects between the
clause 22 and clause 45 restart functionality depending on the PHY
type and whether the Clause 45 PHY supports the Clause 22 register set.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/phy.c | 23 +++++++++++++++++++++--
 include/linux/phy.h   |  1 +
 2 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 788da83a5c7e..117eced4c08d 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -149,6 +149,25 @@ static int phy_config_interrupt(struct phy_device *phydev, u32 interrupts)
 	return 0;
 }
 
+/**
+ * phy_restart_aneg - restart auto-negotiation
+ * @phydev: target phy_device struct
+ *
+ * Restart the autonegotiation on @phydev.  Returns >= 0 on success or
+ * negative errno on error.
+ */
+int phy_restart_aneg(struct phy_device *phydev)
+{
+	int ret;
+
+	if (phydev->is_c45 && !(phydev->c45_ids.devices_in_package & BIT(0)))
+		ret = genphy_c45_restart_aneg(phydev);
+	else
+		ret = genphy_restart_aneg(phydev);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(phy_restart_aneg);
 
 /**
  * phy_aneg_done - return auto-negotiation status
@@ -1421,7 +1440,7 @@ int phy_ethtool_set_eee(struct phy_device *phydev, struct ethtool_eee *data)
 		/* Restart autonegotiation so the new modes get sent to the
 		 * link partner.
 		 */
-		ret = genphy_restart_aneg(phydev);
+		ret = phy_restart_aneg(phydev);
 		if (ret < 0)
 			return ret;
 	}
@@ -1480,6 +1499,6 @@ int phy_ethtool_nway_reset(struct net_device *ndev)
 	if (!phydev->drv)
 		return -EIO;
 
-	return genphy_restart_aneg(phydev);
+	return phy_restart_aneg(phydev);
 }
 EXPORT_SYMBOL(phy_ethtool_nway_reset);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index e089253f98a2..e6fcee188c8d 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -804,6 +804,7 @@ int phy_start_aneg(struct phy_device *phydev);
 int phy_aneg_done(struct phy_device *phydev);
 
 int phy_stop_interrupts(struct phy_device *phydev);
+int phy_restart_aneg(struct phy_device *phydev);
 
 static inline int phy_read_status(struct phy_device *phydev)
 {
-- 
2.7.4
