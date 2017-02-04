From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next] net: dsa: mv88e6xxx: Add watchdog interrupt handler
Date: Sat,  4 Feb 2017 21:38:54 +0100
Message-ID: <1486240734-13157-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55774 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750921AbdBDUjP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 4 Feb 2017 15:39:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The switch contains a watchdog looking for issues with the internal
gubbins of the switch. Hook the interrupt the watchdog triggers and
log the value of the control register indicating why the watchdog
fired. The watchdog can only be cleared with a switch reset, which
will destroy the current configuration. Rather than doing this, just
disable the interrupt.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/global2.c   | 64 ++++++++++++++++++++++++++++++++++-
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  9 +++++
 2 files changed, 72 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index 50e4e0be4227..8013d8e18e3f 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -649,6 +649,66 @@ int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip,
 	return mv88e6xxx_g2_smi_phy_write_c22(chip, addr, reg, val, external);
 }
 
+static irqreturn_t mv88e6xxx_g2_watchdog_thread_fn(int irq, void *dev_id)
+{
+	u16 reg;
+
+	struct mv88e6xxx_chip *chip = dev_id;
+
+	mv88e6xxx_g2_read(chip, GLOBAL2_WDOG_CONTROL, &reg);
+
+	dev_info(chip->dev, "Watchdog event: %04x", reg);
+
+	/* The watchdog interrupt cannot be cleared without resetting
+	 * the switch, so just disable the interrupt.
+	 */
+	disable_irq(irq);
+
+	return IRQ_HANDLED;
+}
+
+static void mv88e6xxx_g2_watchdog_free(struct mv88e6xxx_chip *chip)
+{
+	u16 reg;
+
+	mutex_lock(&chip->reg_lock);
+	mv88e6xxx_g2_read(chip, GLOBAL2_WDOG_CONTROL, &reg);
+
+	reg &= ~(GLOBAL2_WDOG_CONTROL_EGRESS_ENABLE |
+		 GLOBAL2_WDOG_CONTROL_QC_ENABLE);
+
+	mv88e6xxx_g2_write(chip, GLOBAL2_WDOG_CONTROL, reg);
+	mutex_unlock(&chip->reg_lock);
+
+	free_irq(chip->watchdog_irq, chip);
+	irq_dispose_mapping(chip->watchdog_irq);
+}
+
+static int mv88e6xxx_g2_watchdog_setup(struct mv88e6xxx_chip *chip)
+{
+	int err;
+
+	chip->watchdog_irq = irq_find_mapping(chip->g2_irq.domain,
+					      GLOBAL2_INT_SOURCE_WATCHDOG);
+	if (chip->watchdog_irq < 0)
+		return chip->watchdog_irq;
+
+	err = request_threaded_irq(chip->watchdog_irq, NULL,
+				   mv88e6xxx_g2_watchdog_thread_fn,
+				   IRQF_ONESHOT | IRQF_TRIGGER_FALLING,
+				   "mv88e6xxx-watchdog", chip);
+	if (err)
+		return err;
+
+	mutex_lock(&chip->reg_lock);
+	err = mv88e6xxx_g2_write(chip, GLOBAL2_WDOG_CONTROL,
+				 GLOBAL2_WDOG_CONTROL_EGRESS_ENABLE |
+				 GLOBAL2_WDOG_CONTROL_QC_ENABLE);
+	mutex_unlock(&chip->reg_lock);
+
+	return err;
+}
+
 static void mv88e6xxx_g2_irq_mask(struct irq_data *d)
 {
 	struct mv88e6xxx_chip *chip = irq_data_get_irq_chip_data(d);
@@ -737,6 +797,8 @@ void mv88e6xxx_g2_irq_free(struct mv88e6xxx_chip *chip)
 {
 	int irq, virq;
 
+	mv88e6xxx_g2_watchdog_free(chip);
+
 	free_irq(chip->device_irq, chip);
 	irq_dispose_mapping(chip->device_irq);
 
@@ -779,7 +841,7 @@ int mv88e6xxx_g2_irq_setup(struct mv88e6xxx_chip *chip)
 	if (err)
 		goto out;
 
-	return 0;
+	return mv88e6xxx_g2_watchdog_setup(chip);
 
 out:
 	for (irq = 0; irq < 16; irq++) {
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 8a21800374f3..854a1480c001 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -338,6 +338,7 @@
 #define GLOBAL_STATS_COUNTER_01	0x1f
 
 #define GLOBAL2_INT_SOURCE	0x00
+#define GLOBAL2_INT_SOURCE_WATCHDOG	15
 #define GLOBAL2_INT_MASK	0x01
 #define GLOBAL2_MGMT_EN_2X	0x02
 #define GLOBAL2_MGMT_EN_0X	0x03
@@ -414,6 +415,13 @@
 #define GLOBAL2_SCRATCH_REGISTER_SHIFT	8
 #define GLOBAL2_SCRATCH_VALUE_MASK	0xff
 #define GLOBAL2_WDOG_CONTROL	0x1b
+#define GLOBAL2_WDOG_CONTROL_EGRESS_EVENT	BIT(7)
+#define GLOBAL2_WDOG_CONTROL_RMU_TIMEOUT	BIT(6)
+#define GLOBAL2_WDOG_CONTROL_QC_ENABLE		BIT(5)
+#define GLOBAL2_WDOG_CONTROL_EGRESS_HISTORY	BIT(4)
+#define GLOBAL2_WDOG_CONTROL_EGRESS_ENABLE	BIT(3)
+#define GLOBAL2_WDOG_CONTROL_FORCE_IRQ		BIT(2)
+#define GLOBAL2_WDOG_CONTROL_HISTORY		BIT(1)
 #define GLOBAL2_QOS_WEIGHT	0x1c
 #define GLOBAL2_MISC		0x1d
 
@@ -765,6 +773,7 @@ struct mv88e6xxx_chip {
 	struct mv88e6xxx_irq g2_irq;
 	int irq;
 	int device_irq;
+	int watchdog_irq;
 };
 
 struct mv88e6xxx_bus_ops {
-- 
2.11.0
