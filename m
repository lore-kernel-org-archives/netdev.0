From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH v3 1/3] net: phy: avoid setting unsupported EEE advertisments
Date: Fri, 31 Mar 2017 10:37:07 +0100
Message-ID: <E1ctszT-00063O-NJ@rmk-PC.armlinux.org.uk>
References: <20170331093645.GA15329@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:48478 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932903AbdCaJhO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 05:37:14 -0400
In-Reply-To: <20170331093645.GA15329@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently allow userspace to set any EEE advertisments it desires,
whether or not the PHY supports them.  For example:

 # ethtool --set-eee eth1 advertise 0xffffffff
 # ethtool --show-eee eth1
 EEE Settings for eth1:
        EEE status: disabled
        Tx LPI: disabled
        Supported EEE link modes:  100baseT/Full
                                   1000baseT/Full
                                   10000baseT/Full
        Advertised EEE link modes:  100baseT/Full
                                    1000baseT/Full
                                    1000baseKX/Full
                                    10000baseT/Full
                                    10000baseKX4/Full
                                    10000baseKR/Full

Clearly, this is not sane, we should only allow link modes that are
supported to be advertised (as we do elsewhere.)  Ensure that we mask
the MDIO_AN_EEE_ADV value with the capabilities retrieved from the
MDIO_PCS_EEE_ABLE register.

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/phy.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index ba4676ee9018..7b1c93b0233a 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1332,17 +1332,22 @@ EXPORT_SYMBOL(phy_ethtool_get_eee);
  */
 int phy_ethtool_set_eee(struct phy_device *phydev, struct ethtool_eee *data)
 {
-	int val = ethtool_adv_to_mmd_eee_adv_t(data->advertised);
+	int cap, adv;
 
 	if (!phydev->drv)
 		return -EIO;
 
-	/* Mask prohibited EEE modes */
-	val &= ~phydev->eee_broken_modes;
+	/* Get Supported EEE */
+	cap = phy_read_mmd(phydev, MDIO_MMD_PCS, MDIO_PCS_EEE_ABLE);
+	if (cap < 0)
+		return cap;
 
-	phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_EEE_ADV, val);
+	adv = ethtool_adv_to_mmd_eee_adv_t(data->advertised) & cap;
 
-	return 0;
+	/* Mask prohibited EEE modes */
+	adv &= ~phydev->eee_broken_modes;
+
+	return phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_EEE_ADV, adv);
 }
 EXPORT_SYMBOL(phy_ethtool_set_eee);
 
-- 
2.7.4
