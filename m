From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 3/6] net: dsa: mv88e6xxx: Mask g1 interrupts and free interrupt
Date: Wed, 16 Nov 2016 01:56:53 +0100
Message-ID: <1479257816-7496-4-git-send-email-andrew@lunn.ch>
References: <1479257816-7496-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41252 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751985AbcKPA6U (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 19:58:20 -0500
In-Reply-To: <1479257816-7496-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the g1 interrupt free code such that is masks any further
interrupts, and then releases the interrupt.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index b843052d32bd..8fcef7e0d3ba 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -413,6 +413,13 @@ static const struct irq_domain_ops mv88e6xxx_g1_irq_domain_ops = {
 static void mv88e6xxx_g1_irq_free(struct mv88e6xxx_chip *chip)
 {
 	int irq, virq;
+	u16 mask;
+
+	mv88e6xxx_g1_read(chip, GLOBAL_CONTROL, &mask);
+	mask |= GENMASK(chip->g1_irq.nirqs, 0);
+	mv88e6xxx_g1_write(chip, GLOBAL_CONTROL, mask);
+
+	free_irq(chip->irq, chip);
 
 	for (irq = 0; irq < 16; irq++) {
 		virq = irq_find_mapping(chip->g1_irq.domain, irq);
-- 
2.10.2
