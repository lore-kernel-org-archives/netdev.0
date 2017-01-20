From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 5/8] net: dsa: mv88e6xxx: Workaround missing PHY ID on mv88e6390
Date: Sat, 21 Jan 2017 00:30:59 +0100
Message-ID: <1484955062-26718-6-git-send-email-andrew@lunn.ch>
References: <1484955062-26718-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40339 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752110AbdATXdQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Jan 2017 18:33:16 -0500
In-Reply-To: <1484955062-26718-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The internal PHYs of the mv88e6390 do not have a model ID. Trap any
calls to the ID register, and if it is zero, return the ID for the
mv88e6390. The Marvell PHY driver can then bind to this ID.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/global2.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index 5c9ccb6775ae..e2b00d1b0c28 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -518,7 +518,21 @@ int mv88e6xxx_g2_smi_phy_read(struct mv88e6xxx_chip *chip, int addr, int reg,
 	if (err)
 		return err;
 
-	return mv88e6xxx_g2_read(chip, GLOBAL2_SMI_PHY_DATA, val);
+	err = mv88e6xxx_g2_read(chip, GLOBAL2_SMI_PHY_DATA, val);
+	if (err)
+		return err;
+
+	if (reg == MII_PHYSID2) {
+		/* The mv88e6390 internal PHYS don't have a model number.
+		 * Use the switch family model number instead.
+		 */
+		if (!(*val & 0x1ff)) {
+			if (chip->info->family == MV88E6XXX_FAMILY_6390)
+				*val |= PORT_SWITCH_ID_PROD_NUM_6390;
+		}
+	}
+
+	return 0;
 }
 
 int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip, int addr, int reg,
-- 
2.11.0
