From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 2/5] net: phy: hook up clause 45 autonegotiation restart
Date: Thu, 01 Jun 2017 11:26:36 +0100
Message-ID: <E1dGNJM-00043g-KJ@rmk-PC.armlinux.org.uk>
References: <20170601102327.GF27796@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:53046 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751587AbdFAK0l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 06:26:41 -0400
In-Reply-To: <20170601102327.GF27796@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

genphy_restart_aneg() can only restart autonegotiation on clause 22
PHYs.  Add a phy_restart_aneg() function which selects between the
clause 22 and clause 45 restart functionality depending on the PHY
type.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/phy.c | 23 +++++++++++++++++++++--
 include/linux/phy.h   |  1 +
 2 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 82ab8fb82587..25b24789a409 100644
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
+	if (phydev->is_c45)
+		ret = genphy_c45_restart_aneg(phydev);
+	else
+		ret = genphy_restart_aneg(phydev);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(phy_restart_aneg);
 
 /**
  * phy_aneg_done - return auto-negotiation status
@@ -1415,7 +1434,7 @@ int phy_ethtool_set_eee(struct phy_device *phydev, struct ethtool_eee *data)
 		/* Restart autonegotiation so the new modes get sent to the
 		 * link partner.
 		 */
-		ret = genphy_restart_aneg(phydev);
+		ret = phy_restart_aneg(phydev);
 		if (ret < 0)
 			return ret;
 	}
@@ -1474,6 +1493,6 @@ int phy_ethtool_nway_reset(struct net_device *ndev)
 	if (!phydev->drv)
 		return -EIO;
 
-	return genphy_restart_aneg(phydev);
+	return phy_restart_aneg(phydev);
 }
 EXPORT_SYMBOL(phy_ethtool_nway_reset);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 735ff1f98db3..45dfe1b2b003 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -793,6 +793,7 @@ int phy_start_aneg(struct phy_device *phydev);
 int phy_aneg_done(struct phy_device *phydev);
 
 int phy_stop_interrupts(struct phy_device *phydev);
+int phy_restart_aneg(struct phy_device *phydev);
 
 static inline int phy_read_status(struct phy_device *phydev)
 {
-- 
2.7.4
