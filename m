From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 4/6] net: dsa: mv88e6xxx: Fix releasing for the global2 interrupts
Date: Wed, 16 Nov 2016 01:56:54 +0100
Message-ID: <1479257816-7496-5-git-send-email-andrew@lunn.ch>
References: <1479257816-7496-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41260 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750979AbcKPA6w (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 19:58:52 -0500
In-Reply-To: <1479257816-7496-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is not possible to use devm_request_threaded_irq() because we have
two stacked interrupt controllers in one device. The lower interrupt
controller cannot be removed until the upper is fully removed. This
happens too late with the devm API, resulting in error messages about
removing a domain while there is still an active interrupt. Swap to
using request_threaded_irq() and manage the release of the interrupt
manually.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/global2.c   | 25 +++++++++++++++++--------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  1 +
 2 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index 1a0b13521d13..703d68e92f76 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -507,6 +507,9 @@ void mv88e6xxx_g2_irq_free(struct mv88e6xxx_chip *chip)
 {
 	int irq, virq;
 
+	free_irq(chip->device_irq, chip);
+	irq_dispose_mapping(chip->device_irq);
+
 	for (irq = 0; irq < 16; irq++) {
 		virq = irq_find_mapping(chip->g2_irq.domain, irq);
 		irq_dispose_mapping(virq);
@@ -518,7 +521,7 @@ void mv88e6xxx_g2_irq_free(struct mv88e6xxx_chip *chip)
 int mv88e6xxx_g2_irq_setup(struct mv88e6xxx_chip *chip)
 {
 	int device_irq;
-	int err, irq;
+	int err, irq, virq;
 
 	if (!chip->dev->of_node)
 		return -EINVAL;
@@ -534,22 +537,28 @@ int mv88e6xxx_g2_irq_setup(struct mv88e6xxx_chip *chip)
 	chip->g2_irq.chip = mv88e6xxx_g2_irq_chip;
 	chip->g2_irq.masked = ~0;
 
-	device_irq = irq_find_mapping(chip->g1_irq.domain,
-				      GLOBAL_STATUS_IRQ_DEVICE);
-	if (device_irq < 0) {
+	chip->device_irq = irq_find_mapping(chip->g1_irq.domain,
+					    GLOBAL_STATUS_IRQ_DEVICE);
+	if (chip->device_irq < 0) {
 		err = device_irq;
 		goto out;
 	}
 
-	err = devm_request_threaded_irq(chip->dev, device_irq, NULL,
-					mv88e6xxx_g2_irq_thread_fn,
-					IRQF_ONESHOT, "mv88e6xxx-g1", chip);
+	err = request_threaded_irq(chip->device_irq, NULL,
+				   mv88e6xxx_g2_irq_thread_fn,
+				   IRQF_ONESHOT, "mv88e6xxx-g1", chip);
 	if (err)
 		goto out;
 
 	return 0;
+
 out:
-	mv88e6xxx_g2_irq_free(chip);
+	for (irq = 0; irq < 16; irq++) {
+		virq = irq_find_mapping(chip->g2_irq.domain, irq);
+		irq_dispose_mapping(virq);
+	}
+
+	irq_domain_remove(chip->g2_irq.domain);
 
 	return err;
 }
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 929613021eff..a3869504f881 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -714,6 +714,7 @@ struct mv88e6xxx_chip {
 	struct mv88e6xxx_irq g1_irq;
 	struct mv88e6xxx_irq g2_irq;
 	int irq;
+	int device_irq;
 };
 
 struct mv88e6xxx_bus_ops {
-- 
2.10.2
