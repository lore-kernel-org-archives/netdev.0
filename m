From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 2/6] net: phy: avoid genphy_aneg_done() for PHYs without
 clause 22 support
Date: Mon, 05 Jun 2017 12:22:55 +0100
Message-ID: <E1dHq63-0005Wr-K2@rmk-PC.armlinux.org.uk>
References: <20170605112203.GA10680@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:32994 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751859AbdFELW7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 07:22:59 -0400
In-Reply-To: <20170605112203.GA10680@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid calling genphy_aneg_done() for PHYs that do not implement the
Clause 22 register set.

Clause 45 PHYs may implement the Clause 22 register set along with the
Clause 22 extension MMD.  Hence, we can't simply block access to the
Clause 22 functions based on the PHY being a Clause 45 PHY.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/phy.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 82ab8fb82587..788da83a5c7e 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -163,6 +163,12 @@ int phy_aneg_done(struct phy_device *phydev)
 	if (phydev->drv && phydev->drv->aneg_done)
 		return phydev->drv->aneg_done(phydev);
 
+	/* Avoid genphy_aneg_done() if the Clause 45 PHY does not
+	 * implement Clause 22 registers
+	 */
+	if (phydev->is_c45 && !(phydev->c45_ids.devices_in_package & BIT(0)))
+		return -EINVAL;
+
 	return genphy_aneg_done(phydev);
 }
 EXPORT_SYMBOL(phy_aneg_done);
-- 
2.7.4
