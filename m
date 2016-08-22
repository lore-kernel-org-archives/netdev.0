From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 3/4] dsa: mv88e6xxx: Delete ppu timer when removing module
Date: Mon, 22 Aug 2016 16:01:03 +0200
Message-ID: <1471874464-16142-4-git-send-email-andrew@lunn.ch>
References: <1471874464-16142-1-git-send-email-andrew@lunn.ch>
Cc: Jamie Lentin <jm@lentin.co.uk>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40517 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754022AbcHVOBv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 10:01:51 -0400
In-Reply-To: <1471874464-16142-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PPU method of accessing PHYs makes use of a timer. Make sure this
timer is deleted before unloading the driver.

Reported-by: Jamie Lentin <jm@lentin.co.uk>
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index b315769aa5be..1d5f9576e62a 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -486,6 +486,11 @@ static void mv88e6xxx_ppu_state_init(struct mv88e6xxx_chip *chip)
 	chip->ppu_timer.function = mv88e6xxx_ppu_reenable_timer;
 }
 
+static void mv88e6xxx_ppu_state_destroy(struct mv88e6xxx_chip *chip)
+{
+	del_timer_sync(&chip->ppu_timer);
+}
+
 static int mv88e6xxx_phy_ppu_read(struct mv88e6xxx_chip *chip, int addr,
 				  int reg, u16 *val)
 {
@@ -3892,6 +3897,13 @@ static void mv88e6xxx_phy_init(struct mv88e6xxx_chip *chip)
 	}
 }
 
+static void mv88e6xxx_phy_destroy(struct mv88e6xxx_chip *chip)
+{
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU)) {
+		mv88e6xxx_ppu_state_destroy(chip);
+	}
+}
+
 static int mv88e6xxx_smi_init(struct mv88e6xxx_chip *chip,
 			      struct mii_bus *bus, int sw_addr)
 {
@@ -4080,6 +4092,7 @@ static void mv88e6xxx_remove(struct mdio_device *mdiodev)
 	struct dsa_switch *ds = dev_get_drvdata(&mdiodev->dev);
 	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
 
+	mv88e6xxx_phy_destroy(chip);
 	mv88e6xxx_unregister_switch(chip);
 	mv88e6xxx_mdio_unregister(chip);
 }
-- 
2.8.1
