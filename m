From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 1/6] net: dsa: mv88e6xxx: Implement interrupt support.
Date: Wed, 28 Sep 2016 10:32:19 +0200
Message-ID: <1475051544-18561-2-git-send-email-andrew@lunn.ch>
References: <1475051544-18561-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34947 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751634AbcI1Iek (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Sep 2016 04:34:40 -0400
In-Reply-To: <1475051544-18561-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The switch can have up to two interrupt controllers. One of these
contains the interrupts from the integrated PHYs, so is useful to
export. The Marvell PHY driver can then be used in interrupt mode,
rather than polling, speeding up PHY handling and reducing load on the
MDIO bus.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 .../devicetree/bindings/net/dsa/marvell.txt        |  21 +-
 drivers/net/dsa/mv88e6xxx/chip.c                   | 247 ++++++++++++++++++++-
 drivers/net/dsa/mv88e6xxx/global2.c                | 140 +++++++++++-
 drivers/net/dsa/mv88e6xxx/global2.h                |  11 +
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h              |  32 ++-
 5 files changed, 438 insertions(+), 13 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/dsa/marvell.txt b/Documentation/devicetree/bindings/net/dsa/marvell.txt
index 7629189398aa..2e1e66521882 100644
--- a/Documentation/devicetree/bindings/net/dsa/marvell.txt
+++ b/Documentation/devicetree/bindings/net/dsa/marvell.txt
@@ -20,16 +20,35 @@ Required properties:
 Optional properties:
 
 - reset-gpios		: Should be a gpio specifier for a reset line
-
+- interrupt-parent	: Parent interrupt controller
+- interrupts		: Interrupt from the switch
+- interrupt-controller	: Indicates the switch is itself an interrupt
+			  controller. This is used for the PHY interrupts.
+#interrupt-cells = <2>	: Controller uses one cell.
+- mdio			: container of PHY and devices on the switches MDIO
+			  bus
 Example:
 
        mdio {
                #address-cells = <1>;
                #size-cells = <0>;
+               interrupt-parent = <&gpio0>;
+               interrupts = <27 IRQ_TYPE_LEVEL_LOW>;
+               interrupt-controller;
+               #interrupt-cells = <2>;
 
                switch0: switch@0 {
                        compatible = "marvell,mv88e6085";
                        reg = <0>;
 		       reset-gpios = <&gpio5 1 GPIO_ACTIVE_LOW>;
                };
+               mdio {
+                       #address-cells = <1>;
+                       #size-cells = <0>;
+                       switch1phy0: switch1phy0@0 {
+                               reg = <0>;
+                               interrupt-parent = <&switch1>;
+                               interrupts = <0 IRQ_TYPE_LEVEL_HIGH>;
+                       };
+               };
        };
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index fb24865e9ee4..f0eb49cdca93 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -18,11 +18,15 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/if_bridge.h>
+#include <linux/interrupt.h>
+#include <linux/irq.h>
+#include <linux/irqdomain.h>
 #include <linux/jiffies.h>
 #include <linux/list.h>
 #include <linux/mdio.h>
 #include <linux/module.h>
 #include <linux/of_device.h>
+#include <linux/of_irq.h>
 #include <linux/of_mdio.h>
 #include <linux/netdevice.h>
 #include <linux/gpio/consumer.h>
@@ -322,6 +326,164 @@ static int mv88e6xxx_serdes_write(struct mv88e6xxx_chip *chip, int reg, u16 val)
 					reg, val);
 }
 
+static void mv88e6xxx_g1_irq_mask(struct irq_data *d)
+{
+	struct mv88e6xxx_chip *chip = irq_data_get_irq_chip_data(d);
+	unsigned int n = d->hwirq;
+
+	chip->g1_irq.masked |= (1 << n);
+}
+
+static void mv88e6xxx_g1_irq_unmask(struct irq_data *d)
+{
+	struct mv88e6xxx_chip *chip = irq_data_get_irq_chip_data(d);
+	unsigned int n = d->hwirq;
+
+	chip->g1_irq.masked &= ~(1 << n);
+}
+
+static irqreturn_t mv88e6xxx_g1_irq_thread_fn(int irq, void *dev_id)
+{
+	struct mv88e6xxx_chip *chip = dev_id;
+	unsigned int nhandled = 0;
+	unsigned int sub_irq;
+	unsigned int n;
+	u16 reg;
+	int err;
+
+	mutex_lock(&chip->reg_lock);
+	err = mv88e6xxx_read(chip, REG_GLOBAL, GLOBAL_STATUS, &reg);
+	mutex_unlock(&chip->reg_lock);
+
+	if (err)
+		goto out;
+
+	for (n = 0; n < chip->g1_irq.nirqs; ++n) {
+		if (reg & (1 << n)) {
+			sub_irq = irq_find_mapping(chip->g1_irq.domain, n);
+			handle_nested_irq(sub_irq);
+			++nhandled;
+		}
+	}
+out:
+	return (nhandled > 0 ? IRQ_HANDLED : IRQ_NONE);
+}
+
+static void mv88e6xxx_g1_irq_bus_lock(struct irq_data *d)
+{
+	struct mv88e6xxx_chip *chip = irq_data_get_irq_chip_data(d);
+
+	mutex_lock(&chip->reg_lock);
+}
+
+static void mv88e6xxx_g1_irq_bus_sync_unlock(struct irq_data *d)
+{
+	struct mv88e6xxx_chip *chip = irq_data_get_irq_chip_data(d);
+	u16 mask = GENMASK(chip->g1_irq.nirqs, 0);
+	u16 reg;
+	int err;
+
+	err = mv88e6xxx_read(chip, REG_GLOBAL, GLOBAL_CONTROL, &reg);
+	if (err)
+		goto out;
+
+	reg &= ~mask;
+	reg |= (~chip->g1_irq.masked & mask);
+
+	err = mv88e6xxx_write(chip, REG_GLOBAL, GLOBAL_CONTROL, reg);
+	if (err)
+		goto out;
+
+out:
+	mutex_unlock(&chip->reg_lock);
+}
+
+static struct irq_chip mv88e6xxx_g1_irq_chip = {
+	.name			= "mv88e6xxx-g1",
+	.irq_mask		= mv88e6xxx_g1_irq_mask,
+	.irq_unmask		= mv88e6xxx_g1_irq_unmask,
+	.irq_bus_lock		= mv88e6xxx_g1_irq_bus_lock,
+	.irq_bus_sync_unlock	= mv88e6xxx_g1_irq_bus_sync_unlock,
+};
+
+static int mv88e6xxx_g1_irq_domain_map(struct irq_domain *d,
+				       unsigned int irq,
+				       irq_hw_number_t hwirq)
+{
+	struct mv88e6xxx_chip *chip = d->host_data;
+
+	irq_set_chip_data(irq, d->host_data);
+	irq_set_chip_and_handler(irq, &chip->g1_irq.chip, handle_level_irq);
+	irq_set_noprobe(irq);
+
+	return 0;
+}
+
+static const struct irq_domain_ops mv88e6xxx_g1_irq_domain_ops = {
+	.map	= mv88e6xxx_g1_irq_domain_map,
+	.xlate	= irq_domain_xlate_twocell,
+};
+
+static void mv88e6xxx_g1_irq_free(struct mv88e6xxx_chip *chip)
+{
+	int irq, virq;
+
+	for (irq = 0; irq < 16; irq++) {
+		virq = irq_find_mapping(chip->g2_irq.domain, irq);
+		irq_dispose_mapping(virq);
+	}
+
+	irq_domain_remove(chip->g2_irq.domain);
+}
+
+static int mv88e6xxx_g1_irq_setup(struct mv88e6xxx_chip *chip)
+{
+	int err, irq;
+	u16 reg;
+
+	chip->g1_irq.nirqs = chip->info->g1_irqs;
+	chip->g1_irq.domain = irq_domain_add_simple(
+		NULL, chip->g1_irq.nirqs, 0,
+		&mv88e6xxx_g1_irq_domain_ops, chip);
+	if (!chip->g1_irq.domain)
+		return -ENOMEM;
+
+	for (irq = 0; irq < chip->g1_irq.nirqs; irq++)
+		irq_create_mapping(chip->g1_irq.domain, irq);
+
+	chip->g1_irq.chip = mv88e6xxx_g1_irq_chip;
+	chip->g1_irq.masked = ~0;
+
+	err = mv88e6xxx_read(chip, REG_GLOBAL, GLOBAL_CONTROL, &reg);
+	if (err)
+		goto out;
+
+	reg &= ~GENMASK(chip->g1_irq.nirqs, 0);
+
+	err = mv88e6xxx_write(chip, REG_GLOBAL, GLOBAL_CONTROL, reg);
+	if (err)
+		goto out;
+
+	/* Reading the interrupt status clears (most of) them */
+	err = mv88e6xxx_read(chip, REG_GLOBAL, GLOBAL_STATUS, &reg);
+	if (err)
+		goto out;
+
+	err = request_threaded_irq(chip->irq, NULL,
+				   mv88e6xxx_g1_irq_thread_fn,
+				   IRQF_ONESHOT | IRQF_TRIGGER_FALLING,
+				   dev_name(chip->dev), chip);
+	if (err)
+		goto out;
+
+	return 0;
+
+out:
+	mv88e6xxx_g1_irq_free(chip);
+
+	return err;
+}
+
 int mv88e6xxx_wait(struct mv88e6xxx_chip *chip, int addr, int reg, u16 mask)
 {
 	int i;
@@ -2817,7 +2979,11 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 	/* Enable the PHY Polling Unit if present, don't discard any packets,
 	 * and mask all interrupt sources.
 	 */
-	reg = 0;
+	reg = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_CONTROL);
+	if (reg < 0)
+		return reg;
+
+	reg &= ~GLOBAL_CONTROL_PPU_ENABLE;
 	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU) ||
 	    mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU_ACTIVE))
 		reg |= GLOBAL_CONTROL_PPU_ENABLE;
@@ -2925,10 +3091,6 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
 
 	mutex_lock(&chip->reg_lock);
 
-	err = mv88e6xxx_switch_reset(chip);
-	if (err)
-		goto unlock;
-
 	/* Setup Switch Port Registers */
 	for (i = 0; i < chip->info->num_ports; i++) {
 		err = mv88e6xxx_setup_port(chip, i);
@@ -3271,6 +3433,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x10,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6097,
+		.g1_irqs = 8,
 	},
 
 	[MV88E6095] = {
@@ -3282,6 +3445,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x10,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6095,
+		.g1_irqs = 8,
 	},
 
 	[MV88E6123] = {
@@ -3293,6 +3457,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x10,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
+		.g1_irqs = 9,
 	},
 
 	[MV88E6131] = {
@@ -3304,6 +3469,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x10,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
+		.g1_irqs = 9,
 	},
 
 	[MV88E6161] = {
@@ -3315,6 +3481,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x10,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
+		.g1_irqs = 9,
 	},
 
 	[MV88E6165] = {
@@ -3326,6 +3493,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x10,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
+		.g1_irqs = 9,
 	},
 
 	[MV88E6171] = {
@@ -3337,6 +3505,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x10,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
+		.g1_irqs = 9,
 	},
 
 	[MV88E6172] = {
@@ -3348,6 +3517,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x10,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
+		.g1_irqs = 9,
 	},
 
 	[MV88E6175] = {
@@ -3359,6 +3529,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x10,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
+		.g1_irqs = 9,
 	},
 
 	[MV88E6176] = {
@@ -3370,6 +3541,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x10,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
+		.g1_irqs = 9,
 	},
 
 	[MV88E6185] = {
@@ -3381,6 +3553,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x10,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
+		.g1_irqs = 8,
 	},
 
 	[MV88E6240] = {
@@ -3392,6 +3565,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x10,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
+		.g1_irqs = 9,
 	},
 
 	[MV88E6320] = {
@@ -3403,6 +3577,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x10,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
+		.g1_irqs = 8,
 	},
 
 	[MV88E6321] = {
@@ -3414,6 +3589,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x10,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
+		.g1_irqs = 8,
 	},
 
 	[MV88E6350] = {
@@ -3425,6 +3601,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x10,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
+		.g1_irqs = 9,
 	},
 
 	[MV88E6351] = {
@@ -3436,6 +3613,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x10,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
+		.g1_irqs = 9,
 	},
 
 	[MV88E6352] = {
@@ -3447,6 +3625,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.port_base_addr = 0x10,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
+		.g1_irqs = 9,
 	},
 };
 
@@ -3595,6 +3774,12 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
 	if (err)
 		goto free;
 
+	mutex_lock(&chip->reg_lock);
+	err = mv88e6xxx_switch_reset(chip);
+	mutex_unlock(&chip->reg_lock);
+	if (err)
+		goto free;
+
 	mv88e6xxx_phy_init(chip);
 
 	err = mv88e6xxx_mdio_register(chip, NULL);
@@ -3765,17 +3950,55 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	    !of_property_read_u32(np, "eeprom-length", &eeprom_len))
 		chip->eeprom_len = eeprom_len;
 
+	mutex_lock(&chip->reg_lock);
+	err = mv88e6xxx_switch_reset(chip);
+	mutex_unlock(&chip->reg_lock);
+	if (err)
+		goto out;
+
+	chip->irq = of_irq_get(np, 0);
+	if (chip->irq == -EPROBE_DEFER) {
+		err = chip->irq;
+		goto out;
+	}
+
+	if (chip->irq > 0) {
+		/* Has to be performed before the MDIO bus is created,
+		 * because the PHYs will link there interrupts to these
+		 * interrupt controllers
+		 */
+		err = mv88e6xxx_g1_irq_setup(chip);
+		if (err)
+			goto out;
+
+		if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_INT)) {
+			mutex_unlock(&chip->reg_lock);
+			err = mv88e6xxx_g2_irq_setup(chip);
+			mutex_unlock(&chip->reg_lock);
+			if (err)
+				goto out_g1_irq;
+		}
+	}
+
 	err = mv88e6xxx_mdio_register(chip, np);
 	if (err)
-		return err;
+		goto out_g2_irq;
 
 	err = mv88e6xxx_register_switch(chip, np);
-	if (err) {
-		mv88e6xxx_mdio_unregister(chip);
-		return err;
-	}
+	if (err)
+		goto out_mdio;
 
 	return 0;
+
+out_mdio:
+	mv88e6xxx_mdio_unregister(chip);
+out_g2_irq:
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_INT))
+		mv88e6xxx_g2_irq_free(chip);
+out_g1_irq:
+	mv88e6xxx_g1_irq_free(chip);
+out:
+	return err;
 }
 
 static void mv88e6xxx_remove(struct mdio_device *mdiodev)
@@ -3786,6 +4009,10 @@ static void mv88e6xxx_remove(struct mdio_device *mdiodev)
 	mv88e6xxx_phy_destroy(chip);
 	mv88e6xxx_unregister_switch(chip);
 	mv88e6xxx_mdio_unregister(chip);
+
+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_INT))
+		mv88e6xxx_g2_irq_free(chip);
+	mv88e6xxx_g1_irq_free(chip);
 }
 
 static const struct of_device_id mv88e6xxx_of_match[] = {
diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index 99ed028298ac..e4cbe4560904 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -1,5 +1,6 @@
 /*
- * Marvell 88E6xxx Switch Global 2 Registers support (device address 0x1C)
+ * Marvell 88E6xxx Switch Global 2 Registers support (device address
+ * 0x1C)
  *
  * Copyright (c) 2008 Marvell Semiconductor
  *
@@ -11,6 +12,7 @@
  * (at your option) any later version.
  */
 
+#include <linux/irqdomain.h>
 #include "mv88e6xxx.h"
 #include "global2.h"
 
@@ -395,6 +397,142 @@ int mv88e6xxx_g2_smi_phy_write(struct mv88e6xxx_chip *chip, int addr, int reg,
 	return mv88e6xxx_g2_smi_phy_cmd(chip, cmd);
 }
 
+static void mv88e6xxx_g2_irq_mask(struct irq_data *d)
+{
+	struct mv88e6xxx_chip *chip = irq_data_get_irq_chip_data(d);
+	unsigned int n = d->hwirq;
+
+	chip->g2_irq.masked |= (1 << n);
+}
+
+static void mv88e6xxx_g2_irq_unmask(struct irq_data *d)
+{
+	struct mv88e6xxx_chip *chip = irq_data_get_irq_chip_data(d);
+	unsigned int n = d->hwirq;
+
+	chip->g2_irq.masked &= ~(1 << n);
+}
+
+static irqreturn_t mv88e6xxx_g2_irq_thread_fn(int irq, void *dev_id)
+{
+	struct mv88e6xxx_chip *chip = dev_id;
+	unsigned int nhandled = 0;
+	unsigned int sub_irq;
+	unsigned int n;
+	int err;
+	u16 reg;
+
+	mutex_lock(&chip->reg_lock);
+	err = mv88e6xxx_read(chip, REG_GLOBAL2, GLOBAL2_INT_SOURCE, &reg);
+	mutex_unlock(&chip->reg_lock);
+	if (err)
+		goto out;
+
+	for (n = 0; n < 16; ++n) {
+		if (reg & (1 << n)) {
+			sub_irq = irq_find_mapping(chip->g2_irq.domain, n);
+			handle_nested_irq(sub_irq);
+			++nhandled;
+		}
+	}
+out:
+	return (nhandled > 0 ? IRQ_HANDLED : IRQ_NONE);
+}
+
+static void mv88e6xxx_g2_irq_bus_lock(struct irq_data *d)
+{
+	struct mv88e6xxx_chip *chip = irq_data_get_irq_chip_data(d);
+
+	mutex_lock(&chip->reg_lock);
+}
+
+static void mv88e6xxx_g2_irq_bus_sync_unlock(struct irq_data *d)
+{
+	struct mv88e6xxx_chip *chip = irq_data_get_irq_chip_data(d);
+
+	mv88e6xxx_write(chip, REG_GLOBAL2, GLOBAL2_INT_MASK,
+			~chip->g2_irq.masked);
+
+	mutex_unlock(&chip->reg_lock);
+}
+
+static struct irq_chip mv88e6xxx_g2_irq_chip = {
+	.name			= "mv88e6xxx-g2",
+	.irq_mask		= mv88e6xxx_g2_irq_mask,
+	.irq_unmask		= mv88e6xxx_g2_irq_unmask,
+	.irq_bus_lock		= mv88e6xxx_g2_irq_bus_lock,
+	.irq_bus_sync_unlock	= mv88e6xxx_g2_irq_bus_sync_unlock,
+};
+
+static int mv88e6xxx_g2_irq_domain_map(struct irq_domain *d,
+				       unsigned int irq,
+				       irq_hw_number_t hwirq)
+{
+	struct mv88e6xxx_chip *chip = d->host_data;
+
+	irq_set_chip_data(irq, d->host_data);
+	irq_set_chip_and_handler(irq, &chip->g2_irq.chip, handle_level_irq);
+	irq_set_noprobe(irq);
+
+	return 0;
+}
+
+static const struct irq_domain_ops mv88e6xxx_g2_irq_domain_ops = {
+	.map	= mv88e6xxx_g2_irq_domain_map,
+	.xlate	= irq_domain_xlate_twocell,
+};
+
+void mv88e6xxx_g2_irq_free(struct mv88e6xxx_chip *chip)
+{
+	int irq, virq;
+
+	for (irq = 0; irq < 16; irq++) {
+		virq = irq_find_mapping(chip->g2_irq.domain, irq);
+		irq_dispose_mapping(virq);
+	}
+
+	irq_domain_remove(chip->g2_irq.domain);
+}
+
+int mv88e6xxx_g2_irq_setup(struct mv88e6xxx_chip *chip)
+{
+	int device_irq;
+	int err, irq;
+
+	if (!chip->dev->of_node)
+		return -EINVAL;
+
+	chip->g2_irq.domain = irq_domain_add_simple(
+		chip->dev->of_node, 16, 0, &mv88e6xxx_g2_irq_domain_ops, chip);
+	if (!chip->g2_irq.domain)
+		return -ENOMEM;
+
+	for (irq = 0; irq < 16; irq++)
+		irq_create_mapping(chip->g2_irq.domain, irq);
+
+	chip->g2_irq.chip = mv88e6xxx_g2_irq_chip;
+	chip->g2_irq.masked = ~0;
+
+	device_irq = irq_find_mapping(chip->g1_irq.domain,
+				      GLOBAL_STATUS_IRQ_DEVICE);
+	if (device_irq < 0) {
+		err = device_irq;
+		goto out;
+	}
+
+	err = devm_request_threaded_irq(chip->dev, device_irq, NULL,
+					mv88e6xxx_g2_irq_thread_fn,
+					IRQF_ONESHOT, "mv88e6xxx-g1", chip);
+	if (err)
+		goto out;
+
+	return 0;
+out:
+	mv88e6xxx_g2_irq_free(chip);
+
+	return err;
+}
+
 int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 {
 	u16 reg;
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index c4bb9035ee3a..6cbb42b60d80 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -33,6 +33,8 @@ int mv88e6xxx_g2_get_eeprom16(struct mv88e6xxx_chip *chip,
 int mv88e6xxx_g2_set_eeprom16(struct mv88e6xxx_chip *chip,
 			      struct ethtool_eeprom *eeprom, u8 *data);
 int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip);
+int mv88e6xxx_g2_irq_setup(struct mv88e6xxx_chip *chip);
+void mv88e6xxx_g2_irq_free(struct mv88e6xxx_chip *chip);
 
 #else /* !CONFIG_NET_DSA_MV88E6XXX_GLOBAL2 */
 
@@ -83,6 +85,15 @@ static inline int mv88e6xxx_g2_setup(struct mv88e6xxx_chip *chip)
 	return -EOPNOTSUPP;
 }
 
+static inline int mv88e6xxx_g2_irq_setup(struct mv88e6xxx_chip *chip)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline void mv88e6xxx_g2_irq_setup(struct mv88e6xxx_chip *chip)
+{
+}
+
 #endif /* CONFIG_NET_DSA_MV88E6XXX_GLOBAL2 */
 
 #endif /* _MV88E6XXX_GLOBAL2_H */
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index a365cec615b9..61dec0bc6d59 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -13,6 +13,7 @@
 #define __MV88E6XXX_H
 
 #include <linux/if_vlan.h>
+#include <linux/irq.h>
 #include <linux/gpio/consumer.h>
 
 #ifndef UINT64_MAX
@@ -168,6 +169,15 @@
 #define GLOBAL_STATUS_PPU_INITIALIZING	(0x1 << 14)
 #define GLOBAL_STATUS_PPU_DISABLED	(0x2 << 14)
 #define GLOBAL_STATUS_PPU_POLLING	(0x3 << 14)
+#define GLOBAL_STATUS_IRQ_AVB		8
+#define GLOBAL_STATUS_IRQ_DEVICE	7
+#define GLOBAL_STATUS_IRQ_STATS		6
+#define GLOBAL_STATUS_IRQ_VTU_PROBLEM	5
+#define GLOBAL_STATUS_IRQ_VTU_DONE	4
+#define GLOBAL_STATUS_IRQ_ATU_PROBLEM	3
+#define GLOBAL_STATUS_IRQ_ATU_DONE	2
+#define GLOBAL_STATUS_IRQ_TCAM_DONE	1
+#define GLOBAL_STATUS_IRQ_EEPROM_DONE	0
 #define GLOBAL_MAC_01		0x01
 #define GLOBAL_MAC_23		0x02
 #define GLOBAL_MAC_45		0x03
@@ -414,6 +424,7 @@ enum mv88e6xxx_cap {
 	 * The device contains a second set of global 16-bit registers.
 	 */
 	MV88E6XXX_CAP_GLOBAL2,
+	MV88E6XXX_CAP_G2_INT,		/* (0x00) Interrupt Status */
 	MV88E6XXX_CAP_G2_MGMT_EN_2X,	/* (0x02) MGMT Enable Register 2x */
 	MV88E6XXX_CAP_G2_MGMT_EN_0X,	/* (0x03) MGMT Enable Register 0x */
 	MV88E6XXX_CAP_G2_IRL_CMD,	/* (0x09) Ingress Rate Command */
@@ -463,6 +474,7 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_SERDES		BIT_ULL(MV88E6XXX_CAP_SERDES)
 
 #define MV88E6XXX_FLAG_GLOBAL2		BIT_ULL(MV88E6XXX_CAP_GLOBAL2)
+#define MV88E6XXX_FLAG_G2_INT		BIT_ULL(MV88E6XXX_CAP_G2_INT)
 #define MV88E6XXX_FLAG_G2_MGMT_EN_2X	BIT_ULL(MV88E6XXX_CAP_G2_MGMT_EN_2X)
 #define MV88E6XXX_FLAG_G2_MGMT_EN_0X	BIT_ULL(MV88E6XXX_CAP_G2_MGMT_EN_0X)
 #define MV88E6XXX_FLAG_G2_IRL_CMD	BIT_ULL(MV88E6XXX_CAP_G2_IRL_CMD)
@@ -534,6 +546,7 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAGS_FAMILY_6165	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
+	 MV88E6XXX_FLAG_G2_INT |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_SWITCH_MAC |	\
@@ -547,6 +560,7 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAGS_FAMILY_6185	\
 	(MV88E6XXX_FLAG_GLOBAL2 |	\
+	 MV88E6XXX_FLAG_G2_INT |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAGS_MULTI_CHIP |	\
 	 MV88E6XXX_FLAG_PPU |		\
@@ -573,6 +587,7 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
 	(MV88E6XXX_FLAG_EDSA |		\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
+	 MV88E6XXX_FLAG_G2_INT |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_SWITCH_MAC |	\
@@ -590,6 +605,7 @@ enum mv88e6xxx_cap {
 	(MV88E6XXX_FLAG_EDSA |		\
 	 MV88E6XXX_FLAG_EEE |		\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
+	 MV88E6XXX_FLAG_G2_INT |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
 	 MV88E6XXX_FLAG_G2_SWITCH_MAC |	\
@@ -615,6 +631,7 @@ struct mv88e6xxx_info {
 	unsigned int port_base_addr;
 	unsigned int age_time_coeff;
 	unsigned long long flags;
+	unsigned int g1_irqs;
 };
 
 struct mv88e6xxx_atu_entry {
@@ -642,6 +659,13 @@ struct mv88e6xxx_priv_port {
 	struct net_device *bridge_dev;
 };
 
+struct mv88e6xxx_irq {
+	u16 masked;
+	struct irq_chip chip;
+	struct irq_domain *domain;
+	unsigned int nirqs;
+};
+
 struct mv88e6xxx_chip {
 	struct dentry *dbgfs;
 
@@ -693,6 +717,13 @@ struct mv88e6xxx_chip {
 
 	/* And the MDIO bus itself */
 	struct mii_bus *mdio_bus;
+
+	/* There can be two interrupt controllers, which are chained
+	 * off a GPIO as interrupt source
+	 */
+	struct mv88e6xxx_irq g1_irq;
+	struct mv88e6xxx_irq g2_irq;
+	int irq;
 };
 
 struct mv88e6xxx_ops {
@@ -724,5 +755,4 @@ int mv88e6xxx_write(struct mv88e6xxx_chip *chip, int addr, int reg, u16 val);
 int mv88e6xxx_update(struct mv88e6xxx_chip *chip, int addr, int reg,
 		     u16 update);
 int mv88e6xxx_wait(struct mv88e6xxx_chip *chip, int addr, int reg, u16 mask);
-
 #endif
-- 
2.9.3
