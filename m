From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v3 net-next 1/2] net: dsa: mv88e6xxx: Add watchdog interrupt handler
Date: Thu,  9 Feb 2017 00:03:42 +0100
Message-ID: <1486595023-28371-2-git-send-email-andrew@lunn.ch>
References: <1486595023-28371-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60477 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751141AbdBHXEd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 18:04:33 -0500
In-Reply-To: <1486595023-28371-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The switch contains a watchdog looking for issues with the internal
gubbins of the switch. Hook the interrupt the watchdog triggers and
log the value of the control register indicating why the watchdog
fired. The watchdog can only be cleared with a switch reset, which
will destroy the current configuration. Rather than doing this, just
disable the interrupt.

The mv88e6390 family has different watchdog registers. So use an ops
structure, so support for the mv88e6390 family can be added later.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
v2:
  Use ops and exclude the 6390 family
  Add missing locks in the IRQ handler
v3:
  remove g2_ from ops name.
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 14 ++++++
 drivers/net/dsa/mv88e6xxx/global2.c   | 89 ++++++++++++++++++++++++++++++++++-
 drivers/net/dsa/mv88e6xxx/global2.h   |  4 ++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 21 +++++++++
 4 files changed, 127 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 7b4e40b286e4..489a59f5dea3 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3111,6 +3111,7 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.ppu_enable = mv88e6185_g1_ppu_enable,
 	.ppu_disable = mv88e6185_g1_ppu_disable,
@@ -3179,6 +3180,7 @@ static const struct mv88e6xxx_ops mv88e6123_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 };
@@ -3205,6 +3207,7 @@ static const struct mv88e6xxx_ops mv88e6131_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.ppu_enable = mv88e6185_g1_ppu_enable,
 	.ppu_disable = mv88e6185_g1_ppu_disable,
@@ -3232,6 +3235,7 @@ static const struct mv88e6xxx_ops mv88e6161_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 };
@@ -3250,6 +3254,7 @@ static const struct mv88e6xxx_ops mv88e6165_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 };
@@ -3276,6 +3281,7 @@ static const struct mv88e6xxx_ops mv88e6171_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 };
@@ -3304,6 +3310,7 @@ static const struct mv88e6xxx_ops mv88e6172_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 };
@@ -3330,6 +3337,7 @@ static const struct mv88e6xxx_ops mv88e6175_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 };
@@ -3358,6 +3366,7 @@ static const struct mv88e6xxx_ops mv88e6176_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 };
@@ -3380,6 +3389,7 @@ static const struct mv88e6xxx_ops mv88e6185_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.ppu_enable = mv88e6185_g1_ppu_enable,
 	.ppu_disable = mv88e6185_g1_ppu_disable,
@@ -3491,6 +3501,7 @@ static const struct mv88e6xxx_ops mv88e6240_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 };
@@ -3598,6 +3609,7 @@ static const struct mv88e6xxx_ops mv88e6350_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 };
@@ -3624,6 +3636,7 @@ static const struct mv88e6xxx_ops mv88e6351_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 };
@@ -3652,6 +3665,7 @@ static const struct mv88e6xxx_ops mv88e6352_ops = {
 	.stats_get_stats = mv88e6095_stats_get_stats,
 	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
 	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
+	.watchdog_ops = &mv88e6097_watchdog_ops,
 	.mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
 	.reset = mv88e6352_g1_reset,
 };
diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index 50e4e0be4227..1e2d65826d12 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -649,6 +649,91 @@ int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip,
 	return mv88e6xxx_g2_smi_phy_write_c22(chip, addr, reg, val, external);
 }
 
+static int mv88e6097_watchdog_action(struct mv88e6xxx_chip *chip, int irq)
+{
+	u16 reg;
+
+	mv88e6xxx_g2_read(chip, GLOBAL2_WDOG_CONTROL, &reg);
+
+	dev_info(chip->dev, "Watchdog event: 0x%04x", reg);
+
+	return IRQ_HANDLED;
+}
+
+static void mv88e6097_watchdog_free(struct mv88e6xxx_chip *chip)
+{
+	u16 reg;
+
+	mv88e6xxx_g2_read(chip, GLOBAL2_WDOG_CONTROL, &reg);
+
+	reg &= ~(GLOBAL2_WDOG_CONTROL_EGRESS_ENABLE |
+		 GLOBAL2_WDOG_CONTROL_QC_ENABLE);
+
+	mv88e6xxx_g2_write(chip, GLOBAL2_WDOG_CONTROL, reg);
+}
+
+static int mv88e6097_watchdog_setup(struct mv88e6xxx_chip *chip)
+{
+	return mv88e6xxx_g2_write(chip, GLOBAL2_WDOG_CONTROL,
+				  GLOBAL2_WDOG_CONTROL_EGRESS_ENABLE |
+				  GLOBAL2_WDOG_CONTROL_QC_ENABLE |
+				  GLOBAL2_WDOG_CONTROL_SWRESET);
+}
+
+const struct mv88e6xxx_irq_ops mv88e6097_watchdog_ops = {
+	.irq_action = mv88e6097_watchdog_action,
+	.irq_setup = mv88e6097_watchdog_setup,
+	.irq_free = mv88e6097_watchdog_free,
+};
+
+static irqreturn_t mv88e6xxx_g2_watchdog_thread_fn(int irq, void *dev_id)
+{
+	struct mv88e6xxx_chip *chip = dev_id;
+	irqreturn_t ret = IRQ_NONE;
+
+	mutex_lock(&chip->reg_lock);
+	if (chip->info->ops->watchdog_ops->irq_action)
+		ret = chip->info->ops->watchdog_ops->irq_action(chip, irq);
+	mutex_unlock(&chip->reg_lock);
+
+	return ret;
+}
+
+static void mv88e6xxx_g2_watchdog_free(struct mv88e6xxx_chip *chip)
+{
+	mutex_lock(&chip->reg_lock);
+	if (chip->info->ops->watchdog_ops->irq_free)
+		chip->info->ops->watchdog_ops->irq_free(chip);
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
+	if (chip->info->ops->watchdog_ops->irq_setup)
+		err = chip->info->ops->watchdog_ops->irq_setup(chip);
+	mutex_unlock(&chip->reg_lock);
+
+	return err;
+}
+
 static void mv88e6xxx_g2_irq_mask(struct irq_data *d)
 {
 	struct mv88e6xxx_chip *chip = irq_data_get_irq_chip_data(d);
@@ -737,6 +822,8 @@ void mv88e6xxx_g2_irq_free(struct mv88e6xxx_chip *chip)
 {
 	int irq, virq;
 
+	mv88e6xxx_g2_watchdog_free(chip);
+
 	free_irq(chip->device_irq, chip);
 	irq_dispose_mapping(chip->device_irq);
 
@@ -779,7 +866,7 @@ int mv88e6xxx_g2_irq_setup(struct mv88e6xxx_chip *chip)
 	if (err)
 		goto out;
 
-	return 0;
+	return mv88e6xxx_g2_watchdog_setup(chip);
 
 out:
 	for (irq = 0; irq < 16; irq++) {
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index 00e635279ba1..8305f6941fd1 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -46,6 +46,8 @@ int mv88e6xxx_g2_irq_setup(struct mv88e6xxx_chip *chip);
 void mv88e6xxx_g2_irq_free(struct mv88e6xxx_chip *chip);
 int mv88e6095_g2_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip);
 
+extern const struct mv88e6xxx_irq_ops mv88e6097_watchdog_ops;
+
 #else /* !CONFIG_NET_DSA_MV88E6XXX_GLOBAL2 */
 
 static inline int mv88e6xxx_g2_require(struct mv88e6xxx_chip *chip)
@@ -125,6 +127,8 @@ static inline int mv88e6095_g2_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip)
 	return -EOPNOTSUPP;
 }
 
+static const struct mv88e6xxx_irq_ops mv88e6097_watchdog_ops = {};
+
 #endif /* CONFIG_NET_DSA_MV88E6XXX_GLOBAL2 */
 
 #endif /* _MV88E6XXX_GLOBAL2_H */
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index d6b335cd8c09..e97adc75b6fc 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -338,6 +338,7 @@
 #define GLOBAL_STATS_COUNTER_01	0x1f
 
 #define GLOBAL2_INT_SOURCE	0x00
+#define GLOBAL2_INT_SOURCE_WATCHDOG	15
 #define GLOBAL2_INT_MASK	0x01
 #define GLOBAL2_MGMT_EN_2X	0x02
 #define GLOBAL2_MGMT_EN_0X	0x03
@@ -414,6 +415,14 @@
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
+#define GLOBAL2_WDOG_CONTROL_SWRESET		BIT(0)
 #define GLOBAL2_QOS_WEIGHT	0x1c
 #define GLOBAL2_MISC		0x1d
 
@@ -705,6 +714,7 @@ struct mv88e6xxx_vtu_entry {
 };
 
 struct mv88e6xxx_bus_ops;
+struct mv88e6xxx_irq_ops;
 
 struct mv88e6xxx_irq {
 	u16 masked;
@@ -765,6 +775,7 @@ struct mv88e6xxx_chip {
 	struct mv88e6xxx_irq g2_irq;
 	int irq;
 	int device_irq;
+	int watchdog_irq;
 };
 
 struct mv88e6xxx_bus_ops {
@@ -878,11 +889,21 @@ struct mv88e6xxx_ops {
 				uint64_t *data);
 	int (*g1_set_cpu_port)(struct mv88e6xxx_chip *chip, int port);
 	int (*g1_set_egress_port)(struct mv88e6xxx_chip *chip, int port);
+	const struct mv88e6xxx_irq_ops *watchdog_ops;
 
 	/* Can be either in g1 or g2, so don't use a prefix */
 	int (*mgmt_rsvd2cpu)(struct mv88e6xxx_chip *chip);
 };
 
+struct mv88e6xxx_irq_ops {
+	/* Action to be performed when the interrupt happens */
+	int (*irq_action)(struct mv88e6xxx_chip *chip, int irq);
+	/* Setup the hardware to generate the interrupt */
+	int (*irq_setup)(struct mv88e6xxx_chip *chip);
+	/* Reset the hardware to stop generating the interrupt */
+	void (*irq_free)(struct mv88e6xxx_chip *chip);
+};
+
 #define STATS_TYPE_PORT		BIT(0)
 #define STATS_TYPE_BANK0	BIT(1)
 #define STATS_TYPE_BANK1	BIT(2)
-- 
2.11.0
