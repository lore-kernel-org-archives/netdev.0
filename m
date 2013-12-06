From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 1/9] net: phy: report link partner features through ethtool
Date: Fri, 6 Dec 2013 13:01:30 -0800
Message-ID: <1386363698-8407-2-git-send-email-f.fainelli@gmail.com>
References: <1386363698-8407-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <sebastian.hesselbarth@gmail.com>,
	<sergei.shtylyov@cogentembedded.com>, <afleming@gmail.com>,
	<kyle@moffetthome.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:32631 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758521Ab3LFVDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 16:03:43 -0500
In-Reply-To: <1386363698-8407-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PHY library already reads the MII_STAT1000 and MII_LPA registers in
genphy_read_status(), so extend it to also populate the PHY device link
partner advertised features such that we can feed this back into ethtool
when asked for it in phy_ethtool_gset().

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c        | 1 +
 drivers/net/phy/phy_device.c | 6 ++++++
 include/linux/phy.h          | 5 +++--
 3 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 36c6994..05cb8fe 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -289,6 +289,7 @@ int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 	cmd->supported = phydev->supported;
 
 	cmd->advertising = phydev->advertising;
+	cmd->lp_advertising = phydev->lp_advertising;
 
 	ethtool_cmd_speed_set(cmd, phydev->speed);
 	cmd->duplex = phydev->duplex;
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index d6447b3..6db3659 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -839,6 +839,8 @@ int genphy_read_status(struct phy_device *phydev)
 	if (err)
 		return err;
 
+	phydev->lp_advertising = 0;
+
 	if (AUTONEG_ENABLE == phydev->autoneg) {
 		if (phydev->supported & (SUPPORTED_1000baseT_Half
 					| SUPPORTED_1000baseT_Full)) {
@@ -852,6 +854,8 @@ int genphy_read_status(struct phy_device *phydev)
 			if (adv < 0)
 				return adv;
 
+			phydev->lp_advertising =
+				mii_stat1000_to_ethtool_lpa_t(lpagb);
 			lpagb &= adv << 2;
 		}
 
@@ -860,6 +864,8 @@ int genphy_read_status(struct phy_device *phydev)
 		if (lpa < 0)
 			return lpa;
 
+		phydev->lp_advertising |= mii_lpa_to_ethtool_lpa_t(lpa);
+
 		adv = phy_read(phydev, MII_ADVERTISE);
 
 		if (adv < 0)
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 7ff751a..90a666e 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -287,8 +287,8 @@ struct phy_c45_device_ids {
  * adjust_state: Callback for the enet driver to respond to
  * changes in the state machine.
  *
- * speed, duplex, pause, supported, advertising, and
- * autoneg are used like in mii_if_info
+ * speed, duplex, pause, supported, advertising, lp_advertising,
+ * and autoneg are used like in mii_if_info
  *
  * interrupts currently only supports enabled or disabled,
  * but could be changed in the future to support enabling
@@ -340,6 +340,7 @@ struct phy_device {
 	/* See mii.h for more info */
 	u32 supported;
 	u32 advertising;
+	u32 lp_advertising;
 
 	int autoneg;
 
-- 
1.8.3.2
