From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net] net: phy: marvell: Only configure RGMII delays when using RGMII
Date: Tue, 31 Oct 2017 20:31:28 +0100
Message-ID: <1509478288-27130-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Aaro Koskinen <aaro.koskinen@iki.fi>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:35673 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932684AbdJaTcB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 15:32:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fix 5987feb38aa5 ("net: phy: marvell: logical vs bitwise OR typo")
uncovered another bug in the Marvell PHY driver, which broke the
Marvell OpenRD platform. It relies on the bootloader configuring the
RGMII delays and does not specify a phy-mode in its device tree.  The
PHY driver should only configure RGMII delays if the phy mode
indicates it is using RGMII. Without anything in device tree, the
mv643xx Ethernet driver defaults to GMII.

Fixes: 5987feb38aa5 ("net: phy: marvell: logical vs bitwise OR typo")
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---

Aaro

Please can you test this and see if it fixes your OpenRD. This should
cause it to leave the bootloader configuration alone. That will fix
the regression for older DT blobs. Adding correct phy-mode properties
can also be done. That would increase the robustness to bootloader
changes.

drivers/net/phy/marvell.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 15cbcdba618a..4d02b27df044 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -681,9 +681,11 @@ static int m88e1116r_config_init(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	err = m88e1121_config_aneg_rgmii_delays(phydev);
-	if (err < 0)
-		return err;
+	if (phy_interface_is_rgmii(phydev)) {
+		err = m88e1121_config_aneg_rgmii_delays(phydev);
+		if (err < 0)
+			return err;
+	}
 
 	err = genphy_soft_reset(phydev);
 	if (err < 0)
-- 
2.14.1
