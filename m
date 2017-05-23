From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v3 net] net: phy: marvell: Limit errata to 88m1101
Date: Tue, 23 May 2017 17:49:13 +0200
Message-ID: <1495554553-21118-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41647 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1761781AbdEWPtb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 11:49:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 88m1101 has an errata when configuring autoneg. However, it was
being applied to many other Marvell PHYs as well. Limit its scope to
just the 88m1101.

Fixes: 76884679c644 ("phylib: Add support for Marvell 88e1111S and 88e1145")
Reported-by: Daniel Walker <danielwa@cisco.com>
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Acked-by: Harini Katakam <harinik@xilinx.com>
---

v3: Rebase onto net.

drivers/net/phy/marvell.c | 66 ++++++++++++++++++++++++++---------------------
 1 file changed, 37 insertions(+), 29 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 272b051a0199..9097e42bec2e 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -255,34 +255,6 @@ static int marvell_config_aneg(struct phy_device *phydev)
 {
 	int err;
 
-	/* The Marvell PHY has an errata which requires
-	 * that certain registers get written in order
-	 * to restart autonegotiation */
-	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
-
-	if (err < 0)
-		return err;
-
-	err = phy_write(phydev, 0x1d, 0x1f);
-	if (err < 0)
-		return err;
-
-	err = phy_write(phydev, 0x1e, 0x200c);
-	if (err < 0)
-		return err;
-
-	err = phy_write(phydev, 0x1d, 0x5);
-	if (err < 0)
-		return err;
-
-	err = phy_write(phydev, 0x1e, 0);
-	if (err < 0)
-		return err;
-
-	err = phy_write(phydev, 0x1e, 0x100);
-	if (err < 0)
-		return err;
-
 	err = marvell_set_polarity(phydev, phydev->mdix_ctrl);
 	if (err < 0)
 		return err;
@@ -316,6 +288,42 @@ static int marvell_config_aneg(struct phy_device *phydev)
 	return 0;
 }
 
+static int m88e1101_config_aneg(struct phy_device *phydev)
+{
+	int err;
+
+	/* This Marvell PHY has an errata which requires
+	 * that certain registers get written in order
+	 * to restart autonegotiation
+	 */
+	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
+
+	if (err < 0)
+		return err;
+
+	err = phy_write(phydev, 0x1d, 0x1f);
+	if (err < 0)
+		return err;
+
+	err = phy_write(phydev, 0x1e, 0x200c);
+	if (err < 0)
+		return err;
+
+	err = phy_write(phydev, 0x1d, 0x5);
+	if (err < 0)
+		return err;
+
+	err = phy_write(phydev, 0x1e, 0);
+	if (err < 0)
+		return err;
+
+	err = phy_write(phydev, 0x1e, 0x100);
+	if (err < 0)
+		return err;
+
+	return marvell_config_aneg(phydev);
+}
+
 static int m88e1111_config_aneg(struct phy_device *phydev)
 {
 	int err;
@@ -1892,7 +1900,7 @@ static struct phy_driver marvell_drivers[] = {
 		.flags = PHY_HAS_INTERRUPT,
 		.probe = marvell_probe,
 		.config_init = &marvell_config_init,
-		.config_aneg = &marvell_config_aneg,
+		.config_aneg = &m88e1101_config_aneg,
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
-- 
2.11.0
