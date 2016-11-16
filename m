From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 2/6] net: dsa: mv88e6xxx: Fix unconditional irq freeing
Date: Wed, 16 Nov 2016 01:56:52 +0100
Message-ID: <1479257816-7496-3-git-send-email-andrew@lunn.ch>
References: <1479257816-7496-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41239 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752415AbcKPA5R (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 19:57:17 -0500
In-Reply-To: <1479257816-7496-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trying to remove an IRQ domain that was not created results in an
Opps. Add the necessary checks that the irqs were created before
freeing them.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 6aa81d2d8f63..b843052d32bd 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3897,10 +3897,11 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 out_mdio:
 	mv88e6xxx_mdio_unregister(chip);
 out_g2_irq:
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_INT))
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_INT) && chip->irq > 0)
 		mv88e6xxx_g2_irq_free(chip);
 out_g1_irq:
-	mv88e6xxx_g1_irq_free(chip);
+	if (chip->irq > 0)
+		mv88e6xxx_g1_irq_free(chip);
 out:
 	return err;
 }
@@ -3914,9 +3915,11 @@ static void mv88e6xxx_remove(struct mdio_device *mdiodev)
 	mv88e6xxx_unregister_switch(chip);
 	mv88e6xxx_mdio_unregister(chip);
 
-	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_INT))
-		mv88e6xxx_g2_irq_free(chip);
-	mv88e6xxx_g1_irq_free(chip);
+	if (chip->irq > 0) {
+		if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_INT))
+			mv88e6xxx_g2_irq_free(chip);
+		mv88e6xxx_g1_irq_free(chip);
+	}
 }
 
 static const struct of_device_id mv88e6xxx_of_match[] = {
-- 
2.10.2
