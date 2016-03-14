From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH 2/8] dsa: mv88e6xxx: Add support for switch and device interrupts
Date: Mon, 14 Mar 2016 01:33:45 +0100
Message-ID: <1457915631-16696-3-git-send-email-andrew@lunn.ch>
References: <1457915631-16696-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55950 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932298AbcCNAex (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Mar 2016 20:34:53 -0400
In-Reply-To: <1457915631-16696-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The switch contains an interrupt controller. This then has a chained
device interrupt controller, which contains interrupts from the
embedded PHYs. Add support for these interrupt controllers.
---
 drivers/net/dsa/mv88e6xxx.c | 312 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  22 ++++
 2 files changed, 334 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 5f07524083c3..2301dfbc3582 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -21,6 +21,9 @@
 #include <linux/netdevice.h>
 #include <linux/gpio/consumer.h>
 #include <linux/phy.h>
+#include <linux/interrupt.h>
+#include <linux/irq.h>
+#include <linux/irqdomain.h>
 #include <net/dsa.h>
 #include <net/switchdev.h>
 #include "mv88e6xxx.h"
@@ -2536,6 +2539,315 @@ int mv88e6xxx_setup_ports(struct dsa_switch *ds)
 	return 0;
 }
 
+static int mv88e6xxx_nirqs(struct dsa_switch *ds)
+{
+	int nirqs = 8;
+
+	if (mv88e6xxx_6165_family(ds) ||
+	    mv88e6xxx_6351_family(ds) ||
+	    mv88e6xxx_6352_family(ds))
+		nirqs = 9;
+
+	return nirqs;
+}
+
+static void mv88e6xxx_switch_irq_mask(struct irq_data *d)
+{
+	struct dsa_switch *ds = irq_data_get_irq_chip_data(d);
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	unsigned int n = d->hwirq;
+
+	ps->switch_irq_masked |= (1 << n);
+}
+
+static void mv88e6xxx_switch_irq_unmask(struct irq_data *d)
+{
+	struct dsa_switch *ds = irq_data_get_irq_chip_data(d);
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	unsigned int n = d->hwirq;
+
+	ps->switch_irq_masked &= ~(1 << n);
+}
+
+static irqreturn_t mv88e6xxx_switch_irq_thread_fn(int irq, void *dev_id)
+{
+	struct dsa_switch *ds = (struct dsa_switch *)dev_id;
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	unsigned nhandled = 0;
+	unsigned sub_irq;
+	unsigned n;
+	int val;
+
+	val = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_STATUS);
+	if (val < 0)
+		goto out;
+
+	for (n = 0; n < ps->switch_nirqs; ++n) {
+		if (val & (1 << n)) {
+			sub_irq = irq_find_mapping(ps->switch_irq_domain, n);
+			handle_nested_irq(sub_irq);
+			++nhandled;
+		}
+	}
+out:
+	return (nhandled > 0 ? IRQ_HANDLED : IRQ_NONE);
+}
+
+static void mv88e6xxx_switch_irq_bus_lock(struct irq_data *d)
+{
+	struct dsa_switch *ds = irq_data_get_irq_chip_data(d);
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	mutex_lock(&ps->smi_mutex);
+}
+
+static void mv88e6xxx_switch_irq_bus_sync_unlock(struct irq_data *d)
+{
+	struct dsa_switch *ds = irq_data_get_irq_chip_data(d);
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	u16 mask = GENMASK(ps->switch_nirqs, 0);
+	int reg, ret;
+
+	reg = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_CONTROL);
+	if (reg < 0)
+		goto out;
+
+	reg &= ~mask;
+	reg |= (~ps->switch_irq_masked & mask);
+
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_CONTROL, reg);
+	if (ret < 0)
+		goto out;
+
+out:
+	mutex_unlock(&ps->smi_mutex);
+}
+
+static struct irq_chip mv88e6xxx_switch_irq_chip = {
+	.name			= "mv88e6xxx-switch",
+	.irq_mask		= mv88e6xxx_switch_irq_mask,
+	.irq_unmask		= mv88e6xxx_switch_irq_unmask,
+	.irq_bus_lock		= mv88e6xxx_switch_irq_bus_lock,
+	.irq_bus_sync_unlock	= mv88e6xxx_switch_irq_bus_sync_unlock,
+};
+
+static int mv88e6xxx_switch_irq_domain_map(struct irq_domain *d,
+					   unsigned int irq,
+					   irq_hw_number_t hwirq)
+{
+	struct dsa_switch *ds = d->host_data;
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	irq_set_chip_data(irq, d->host_data);
+	irq_set_chip_and_handler(irq, &ps->switch_irq_chip, handle_level_irq);
+	irq_set_noprobe(irq);
+
+	return 0;
+}
+
+static const struct irq_domain_ops mv88e6xxx_switch_irq_domain_ops = {
+	.map	= mv88e6xxx_switch_irq_domain_map,
+	.xlate	= irq_domain_xlate_twocell,
+};
+
+int mv88e6xxx_setup_switch_irq(struct dsa_switch *ds)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	u16 mask = GENMASK(ps->switch_nirqs, 0);
+	int err, irq, reg;
+
+	ps->switch_nirqs = mv88e6xxx_nirqs(ds);
+	ps->switch_irq_domain = irq_domain_add_simple(
+		NULL, ps->switch_nirqs, 0,
+		&mv88e6xxx_switch_irq_domain_ops, ds);
+	if (!ps->switch_irq_domain)
+		return -ENOMEM;
+
+	for (irq = 0; irq < ps->switch_nirqs; irq++)
+		irq_create_mapping(ps->switch_irq_domain, irq);
+
+	ps->switch_irq_chip = mv88e6xxx_switch_irq_chip;
+	ps->switch_irq_masked = ~0;
+
+	reg = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_CONTROL);
+	if (reg < 0) {
+		err = reg;
+		goto out;
+	}
+
+	reg &= ~mask;
+
+	err = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_CONTROL, reg);
+	if (err < 0)
+		goto out;
+
+	/* Reading the interrupt status clears (most of) them */
+	reg = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_STATUS);
+	if (reg < 0) {
+		err = reg;
+		goto out;
+	}
+
+	err = request_threaded_irq(ds->pd->irq, NULL,
+				   mv88e6xxx_switch_irq_thread_fn,
+				   IRQF_ONESHOT | IRQF_TRIGGER_FALLING,
+				   "mv88e6xxx-switch", ds);
+
+	if (err)
+		goto out;
+
+	return 0;
+
+out:
+	irq_domain_remove(ps->switch_irq_domain);
+	return err;
+}
+
+static void mv88e6xxx_device_irq_mask(struct irq_data *d)
+{
+	struct dsa_switch *ds = irq_data_get_irq_chip_data(d);
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	unsigned int n = d->hwirq;
+
+	ps->device_irq_masked |= (1 << n);
+}
+
+static void mv88e6xxx_device_irq_unmask(struct irq_data *d)
+{
+	struct dsa_switch *ds = irq_data_get_irq_chip_data(d);
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	unsigned int n = d->hwirq;
+
+	ps->device_irq_masked &= ~(1 << n);
+}
+
+static irqreturn_t mv88e6xxx_device_irq_thread_fn(int irq, void *dev_id)
+{
+	struct dsa_switch *ds = (struct dsa_switch *)dev_id;
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	unsigned nhandled = 0;
+	unsigned sub_irq;
+	unsigned n;
+	int val;
+
+	val = _mv88e6xxx_reg_read(ds, REG_GLOBAL2, GLOBAL2_INT_SOURCE);
+	if (val < 0)
+		goto out;
+
+	for (n = 0; n < 16; ++n) {
+		if (val & (1 << n)) {
+			sub_irq = irq_find_mapping(ps->device_irq_domain, n);
+			handle_nested_irq(sub_irq);
+			++nhandled;
+		}
+	}
+out:
+	return (nhandled > 0 ? IRQ_HANDLED : IRQ_NONE);
+}
+
+static void mv88e6xxx_device_irq_bus_lock(struct irq_data *d)
+{
+	struct dsa_switch *ds = irq_data_get_irq_chip_data(d);
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	mutex_lock(&ps->smi_mutex);
+}
+
+static void mv88e6xxx_device_irq_bus_sync_unlock(struct irq_data *d)
+{
+	struct dsa_switch *ds = irq_data_get_irq_chip_data(d);
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int ret;
+
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_INT_MASK,
+				   ~ps->device_irq_masked);
+	if (ret < 0)
+		goto out;
+
+out:
+	mutex_unlock(&ps->smi_mutex);
+}
+
+static struct irq_chip mv88e6xxx_device_irq_chip = {
+	.name			= "mv88e6xxx-device",
+	.irq_mask		= mv88e6xxx_device_irq_mask,
+	.irq_unmask		= mv88e6xxx_device_irq_unmask,
+	.irq_bus_lock		= mv88e6xxx_device_irq_bus_lock,
+	.irq_bus_sync_unlock	= mv88e6xxx_device_irq_bus_sync_unlock,
+};
+
+static int mv88e6xxx_device_irq_domain_map(struct irq_domain *d,
+					   unsigned int irq,
+					   irq_hw_number_t hwirq)
+{
+	struct dsa_switch *ds = d->host_data;
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	irq_set_chip_data(irq, d->host_data);
+	irq_set_chip_and_handler(irq, &ps->device_irq_chip, handle_level_irq);
+	irq_set_noprobe(irq);
+
+	return 0;
+}
+
+static const struct irq_domain_ops mv88e6xxx_device_irq_domain_ops = {
+	.map	= mv88e6xxx_device_irq_domain_map,
+	.xlate	= irq_domain_xlate_twocell,
+};
+
+int mv88e6xxx_setup_device_irq(struct dsa_switch *ds)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct device_node *np = ds->pd->of_node;
+	int device_irq;
+	int err, irq;
+
+	ps->device_irq_domain = irq_domain_add_simple(
+		np, 16, 0, &mv88e6xxx_device_irq_domain_ops, ds);
+	if (!ps->device_irq_domain)
+		return -ENOMEM;
+
+	for (irq = 0; irq < 16; irq++)
+		irq_create_mapping(ps->device_irq_domain, irq);
+
+	ps->device_irq_chip = mv88e6xxx_device_irq_chip;
+	ps->device_irq_masked = ~0;
+
+	device_irq = irq_find_mapping(ps->switch_irq_domain,
+				      GLOBAL_STATUS_IRQ_DEVICE);
+	if (device_irq < 0) {
+		err = device_irq;
+		goto out;
+	}
+
+	err = request_threaded_irq(device_irq, NULL,
+				   mv88e6xxx_device_irq_thread_fn,
+				   IRQF_ONESHOT, "mv88e6xxx-device", ds);
+	if (err)
+		goto out;
+
+	return 0;
+out:
+	irq_domain_remove(ps->device_irq_domain);
+	return err;
+}
+
+int mv88e6xxx_setup_irqs(struct dsa_switch *ds)
+{
+	int err;
+
+	if (ds->pd->irq) {
+		err = mv88e6xxx_setup_switch_irq(ds);
+		if (err)
+			return err;
+
+		if (mv88e6xxx_6165_family(ds) || mv88e6xxx_6351_family(ds) ||
+		    mv88e6xxx_6352_family(ds))
+			return mv88e6xxx_setup_device_irq(ds);
+	}
+	return 0;
+}
+
 int mv88e6xxx_setup_common(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 3425616987ed..bb97fdc21e0e 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -12,6 +12,7 @@
 #define __MV88E6XXX_H
 
 #include <linux/if_vlan.h>
+#include <linux/irq.h>
 
 #ifndef UINT64_MAX
 #define UINT64_MAX		(u64)(~((u64)0))
@@ -185,6 +186,15 @@
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
@@ -428,6 +438,17 @@ struct mv88e6xxx_priv_state {
 
 	DECLARE_BITMAP(port_state_update_mask, DSA_MAX_PORTS);
 
+	/* Main switch interrupt controller */
+	u16 switch_irq_masked;
+	struct irq_chip switch_irq_chip;
+	struct irq_domain *switch_irq_domain;
+	unsigned switch_nirqs;
+
+	/* Device interrupt controller */
+	u16 device_irq_masked;
+	struct irq_chip device_irq_chip;
+	struct irq_domain *device_irq_domain;
+
 	struct work_struct bridge_work;
 };
 
@@ -451,6 +472,7 @@ char *mv88e6xxx_lookup_name(struct device *host_dev, int sw_addr,
 int mv88e6xxx_setup_ports(struct dsa_switch *ds);
 int mv88e6xxx_setup_common(struct dsa_switch *ds);
 int mv88e6xxx_setup_global(struct dsa_switch *ds);
+int mv88e6xxx_setup_irqs(struct dsa_switch *ds);
 int mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg);
 int mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg, u16 val);
 int mv88e6xxx_set_addr_direct(struct dsa_switch *ds, u8 *addr);
-- 
2.7.0
