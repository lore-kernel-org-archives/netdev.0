From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 01/11] net: dsa: mv88e6xxx: Take switch out of reset before probe
Date: Fri, 11 Nov 2016 03:53:33 +0100
Message-ID: <1478832823-31471-2-git-send-email-andrew@lunn.ch>
References: <1478832823-31471-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34679 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965451AbcKKC6Y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 21:58:24 -0500
In-Reply-To: <1478832823-31471-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The switch needs to be taken out of reset before we can read its ID
register on the MDIO bus.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index d6d9d66b81ce..2c5c37318e31 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3839,16 +3839,16 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	if (err)
 		return err;
 
+	chip->reset = devm_gpiod_get_optional(dev, "reset", GPIOD_OUT_LOW);
+	if (IS_ERR(chip->reset))
+		return PTR_ERR(chip->reset);
+
 	err = mv88e6xxx_detect(chip);
 	if (err)
 		return err;
 
 	mv88e6xxx_phy_init(chip);
 
-	chip->reset = devm_gpiod_get_optional(dev, "reset", GPIOD_ASIS);
-	if (IS_ERR(chip->reset))
-		return PTR_ERR(chip->reset);
-
 	if (chip->info->ops->get_eeprom &&
 	    !of_property_read_u32(np, "eeprom-length", &eeprom_len))
 		chip->eeprom_len = eeprom_len;
-- 
2.10.2
