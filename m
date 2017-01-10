From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH] net: phy: marvell: fix Marvell 88E1512 used in SGMII mode
Date: Tue, 10 Jan 2017 23:13:45 +0000
Message-ID: <E1cR5bt-0000O8-1T@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Andrew Lunn <andrew@lunn.ch>,
        Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:59824 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754602AbdAJXNx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 18:13:53 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an Marvell 88E1512 PHY is connected to a nic in SGMII mode, the
fiber page is used for the SGMII host-side connection.  The PHY driver
notices that SUPPORTED_FIBRE is set, so it tries reading the fiber page
for the link status, and ends up reading the MAC-side status instead of
the outgoing (copper) link.  This leads to incorrect results reported
via ethtool.

If the PHY is connected via SGMII to the host, ignore the fiber page.
However, continue to allow the existing power management code to
suspend and resume the fiber page.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/marvell.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 6ad76829c7cd..04e439ad5cff 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -1190,7 +1190,8 @@ static int marvell_read_status(struct phy_device *phydev)
 	int err;
 
 	/* Check the fiber mode first */
-	if (phydev->supported & SUPPORTED_FIBRE) {
+	if (phydev->supported & SUPPORTED_FIBRE &&
+	    phydev->interface != PHY_INTERFACE_MODE_SGMII) {
 		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
 		if (err < 0)
 			goto error;
-- 
2.7.4
