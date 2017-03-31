From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH v3 2/3] net: phy: restart phy autonegotiation after EEE
 advertisment change
Date: Fri, 31 Mar 2017 10:37:12 +0100
Message-ID: <E1ctszY-00063V-Rx@rmk-PC.armlinux.org.uk>
References: <20170331093645.GA15329@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:48486 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932895AbdCaJhZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 05:37:25 -0400
In-Reply-To: <20170331093645.GA15329@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the EEE advertisment is changed, we should restart autonegotiation
to update the link partner with the new EEE settings.  Add this trigger
but only if the advertisment has changed.

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/phy.c | 21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 7b1c93b0233a..345251f21699 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1332,7 +1332,7 @@ EXPORT_SYMBOL(phy_ethtool_get_eee);
  */
 int phy_ethtool_set_eee(struct phy_device *phydev, struct ethtool_eee *data)
 {
-	int cap, adv;
+	int cap, old_adv, adv, ret;
 
 	if (!phydev->drv)
 		return -EIO;
@@ -1342,12 +1342,29 @@ int phy_ethtool_set_eee(struct phy_device *phydev, struct ethtool_eee *data)
 	if (cap < 0)
 		return cap;
 
+	old_adv = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_AN_EEE_ADV);
+	if (old_adv < 0)
+		return old_adv;
+
 	adv = ethtool_adv_to_mmd_eee_adv_t(data->advertised) & cap;
 
 	/* Mask prohibited EEE modes */
 	adv &= ~phydev->eee_broken_modes;
 
-	return phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_EEE_ADV, adv);
+	if (old_adv != adv) {
+		ret = phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_EEE_ADV, adv);
+		if (ret < 0)
+			return ret;
+
+		/* Restart autonegotiation so the new modes get sent to the
+		 * link partner.
+		 */
+		ret = genphy_restart_aneg(phydev);
+		if (ret < 0)
+			return ret;
+	}
+
+	return 0;
 }
 EXPORT_SYMBOL(phy_ethtool_set_eee);
 
-- 
2.7.4
