From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 1/2] net: dsa: mv88e6xxx: Workaround missing PHY ID on mv88e6390
Date: Wed,  1 Feb 2017 03:40:05 +0100
Message-ID: <1485916806-27299-2-git-send-email-andrew@lunn.ch>
References: <1485916806-27299-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:51907 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750796AbdBACkc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Jan 2017 21:40:32 -0500
In-Reply-To: <1485916806-27299-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The internal PHYs of the mv88e6390 do not have a model ID. Trap any
calls to the ID register, and if it is zero, return the ID for the
mv88e6390. The Marvell PHY driver can then bind to this ID.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index bf385377a461..29190303ace0 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2930,6 +2930,14 @@ static int mv88e6xxx_mdio_read(struct mii_bus *bus, int phy, int reg)
 	err = chip->info->ops->phy_read(chip, bus, phy, reg, &val);
 	mutex_unlock(&chip->reg_lock);
 
+	if (reg == MII_PHYSID2) {
+		/* Some internal PHYS don't have a model number.  Use
+		 * the mv88e6390 family model number instead.
+		 */
+		if (!(val & 0x3f0))
+			val |= PORT_SWITCH_ID_PROD_NUM_6390;
+	}
+
 	return err ? err : val;
 }
 
-- 
2.11.0
