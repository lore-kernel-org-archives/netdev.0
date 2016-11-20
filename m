From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 net-next 4/6] net: dsa: mv88e6xxx: Fix cleanup on error for g1 interrupt setup
Date: Sun, 20 Nov 2016 20:14:17 +0100
Message-ID: <1479669260-14638-5-git-send-email-andrew@lunn.ch>
References: <1479669260-14638-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46514 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752929AbcKTTOt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 20 Nov 2016 14:14:49 -0500
In-Reply-To: <1479669260-14638-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On error, remask the interrupts, release all maps, and remove the
domain. This cannot be done using the mv88e6xxx_g1_irq_free() because
some of these actions are not idempotent.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 31 ++++++++++++++++++++-----------
 1 file changed, 20 insertions(+), 11 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 8fcef7e0d3ba..614b2f68d401 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -431,8 +431,8 @@ static void mv88e6xxx_g1_irq_free(struct mv88e6xxx_chip *chip)
 
 static int mv88e6xxx_g1_irq_setup(struct mv88e6xxx_chip *chip)
 {
-	int err, irq;
-	u16 reg;
+	int err, irq, virq;
+	u16 reg, mask;
 
 	chip->g1_irq.nirqs = chip->info->g1_irqs;
 	chip->g1_irq.domain = irq_domain_add_simple(
@@ -447,32 +447,41 @@ static int mv88e6xxx_g1_irq_setup(struct mv88e6xxx_chip *chip)
 	chip->g1_irq.chip = mv88e6xxx_g1_irq_chip;
 	chip->g1_irq.masked = ~0;
 
-	err = mv88e6xxx_g1_read(chip, GLOBAL_CONTROL, &reg);
+	err = mv88e6xxx_g1_read(chip, GLOBAL_CONTROL, &mask);
 	if (err)
-		goto out;
+		goto out_mapping;
 
-	reg &= ~GENMASK(chip->g1_irq.nirqs, 0);
+	mask &= ~GENMASK(chip->g1_irq.nirqs, 0);
 
-	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL, reg);
+	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL, mask);
 	if (err)
-		goto out;
+		goto out_disable;
 
 	/* Reading the interrupt status clears (most of) them */
 	err = mv88e6xxx_g1_read(chip, GLOBAL_STATUS, &reg);
 	if (err)
-		goto out;
+		goto out_disable;
 
 	err = request_threaded_irq(chip->irq, NULL,
 				   mv88e6xxx_g1_irq_thread_fn,
 				   IRQF_ONESHOT | IRQF_TRIGGER_FALLING,
 				   dev_name(chip->dev), chip);
 	if (err)
-		goto out;
+		goto out_disable;
 
 	return 0;
 
-out:
-	mv88e6xxx_g1_irq_free(chip);
+out_disable:
+	mask |= GENMASK(chip->g1_irq.nirqs, 0);
+	mv88e6xxx_g1_write(chip, GLOBAL_CONTROL, mask);
+
+out_mapping:
+	for (irq = 0; irq < 16; irq++) {
+		virq = irq_find_mapping(chip->g1_irq.domain, irq);
+		irq_dispose_mapping(virq);
+	}
+
+	irq_domain_remove(chip->g1_irq.domain);
 
 	return err;
 }
-- 
2.10.2
