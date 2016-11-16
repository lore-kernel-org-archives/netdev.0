From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 6/6] net: dsa: mv88e6xxx: Hold the mutex while freeing g1 interrupts
Date: Wed, 16 Nov 2016 01:56:56 +0100
Message-ID: <1479257816-7496-7-git-send-email-andrew@lunn.ch>
References: <1479257816-7496-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41256 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751951AbcKPA6h (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 19:58:37 -0500
In-Reply-To: <1479257816-7496-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Freeing interrupts requires switch register access to mask the
interrupts. Hence we must hold the register mutex.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 614b2f68d401..e30d0eaf2b5f 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3916,8 +3916,11 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_INT) && chip->irq > 0)
 		mv88e6xxx_g2_irq_free(chip);
 out_g1_irq:
-	if (chip->irq > 0)
+	if (chip->irq > 0) {
+		mutex_lock(&chip->reg_lock);
 		mv88e6xxx_g1_irq_free(chip);
+		mutex_unlock(&chip->reg_lock);
+	}
 out:
 	return err;
 }
-- 
2.10.2
