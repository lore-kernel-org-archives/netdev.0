From: Mathieu Olivari <mathieu-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: [PATCH 1/7] net: dsa: add new driver for ar8xxx family
Date: Thu, 28 May 2015 18:42:16 -0700
Message-ID: <1432863742-18427-2-git-send-email-mathieu@codeaurora.org>
References: <1432863742-18427-1-git-send-email-mathieu@codeaurora.org>
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, mathieu-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
	f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org, gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org, leitec-z4FmpzNVuK5Wk0Htik3J/w@public.gmane.org, fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org,
	alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, pavel.nakonechny-Fmhy8gsqeTEvJsYlp49lxw@public.gmane.org,
	joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, sfeldma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org,
	juhosg-p3rKhJxN3npAfugRpC6u6w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1432863742-18427-1-git-send-email-mathieu-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch contains initial init & registration code for QCA8337. It
will detect a QCA8337 switch, if present and declared in DT/platform.

Each port will be represented through a standalone net_device interface,
as for other DSA switches. CPU can communicate with any of the ports by
setting an IP@ on ethN interface. Ports cannot communicate with each
other just yet.

Link status will be reported through polling, and we don't use any
encapsulation.

Signed-off-by: Mathieu Olivari <mathieu-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
---
 drivers/net/dsa/Kconfig  |   7 ++
 drivers/net/dsa/Makefile |   1 +
 drivers/net/dsa/ar8xxx.c | 303 +++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/ar8xxx.h |  82 +++++++++++++
 net/dsa/dsa.c            |   1 +
 5 files changed, 394 insertions(+)
 create mode 100644 drivers/net/dsa/ar8xxx.c
 create mode 100644 drivers/net/dsa/ar8xxx.h

diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index 7ad0a4d..2aae541 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -65,4 +65,11 @@ config NET_DSA_BCM_SF2
 	  This enables support for the Broadcom Starfighter 2 Ethernet
 	  switch chips.
 
+config NET_DSA_AR8XXX
+	tristate "Qualcomm Atheros AR8XXX Ethernet switch family support"
+	depends on NET_DSA
+	---help---
+	  This enables support for the Qualcomm Atheros AR8XXX Ethernet
+	  switch chips.
+
 endmenu
diff --git a/drivers/net/dsa/Makefile b/drivers/net/dsa/Makefile
index e2d51c4..7647687 100644
--- a/drivers/net/dsa/Makefile
+++ b/drivers/net/dsa/Makefile
@@ -14,3 +14,4 @@ ifdef CONFIG_NET_DSA_MV88E6171
 mv88e6xxx_drv-y += mv88e6171.o
 endif
 obj-$(CONFIG_NET_DSA_BCM_SF2)	+= bcm_sf2.o
+obj-$(CONFIG_NET_DSA_AR8XXX)	+= ar8xxx.o
diff --git a/drivers/net/dsa/ar8xxx.c b/drivers/net/dsa/ar8xxx.c
new file mode 100644
index 0000000..4ce3ffc
--- /dev/null
+++ b/drivers/net/dsa/ar8xxx.c
@@ -0,0 +1,303 @@
+/*
+ * Copyright (C) 2009 Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
+ * Copyright (C) 2011-2012 Gabor Juhos <juhosg-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
+ * Copyright (c) 2015, The Linux Foundation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 and
+ * only version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/module.h>
+#include <linux/phy.h>
+#include <linux/netdevice.h>
+#include <net/dsa.h>
+#include <linux/phy.h>
+#include <linux/of_net.h>
+
+#include "ar8xxx.h"
+
+u32
+ar8xxx_mii_read32(struct mii_bus *bus, int phy_id, int regnum)
+{
+	u16 lo, hi;
+
+	lo = bus->read(bus, phy_id, regnum);
+	hi = bus->read(bus, phy_id, regnum + 1);
+
+	return (hi << 16) | lo;
+}
+
+void
+ar8xxx_mii_write32(struct mii_bus *bus, int phy_id, int regnum, u32 val)
+{
+	u16 lo, hi;
+
+	lo = val & 0xffff;
+	hi = (u16)(val >> 16);
+
+	bus->write(bus, phy_id, regnum, lo);
+	bus->write(bus, phy_id, regnum + 1, hi);
+}
+
+u32 ar8xxx_read(struct dsa_switch *ds, int reg)
+{
+	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);
+	u16 r1, r2, page;
+	u32 val;
+
+	split_addr((u32)reg, &r1, &r2, &page);
+
+	mutex_lock(&bus->mdio_lock);
+
+	bus->write(bus, 0x18, 0, page);
+	wait_for_page_switch();
+	val = ar8xxx_mii_read32(bus, 0x10 | r2, r1);
+
+	mutex_unlock(&bus->mdio_lock);
+
+	return val;
+}
+
+void ar8xxx_write(struct dsa_switch *ds, int reg, u32 val)
+{
+	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);
+	u16 r1, r2, page;
+
+	split_addr((u32)reg, &r1, &r2, &page);
+
+	mutex_lock(&bus->mdio_lock);
+
+	bus->write(bus, 0x18, 0, page);
+	wait_for_page_switch();
+	ar8xxx_mii_write32(bus, 0x10 | r2, r1, val);
+
+	mutex_unlock(&bus->mdio_lock);
+}
+
+u32
+ar8xxx_rmw(struct dsa_switch *ds, int reg, u32 mask, u32 val)
+{
+	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);
+	u16 r1, r2, page;
+	u32 ret;
+
+	split_addr((u32)reg, &r1, &r2, &page);
+
+	mutex_lock(&bus->mdio_lock);
+
+	bus->write(bus, 0x18, 0, page);
+	wait_for_page_switch();
+
+	ret = ar8xxx_mii_read32(bus, 0x10 | r2, r1);
+	ret &= ~mask;
+	ret |= val;
+	ar8xxx_mii_write32(bus, 0x10 | r2, r1, ret);
+
+	mutex_unlock(&bus->mdio_lock);
+
+	return ret;
+}
+
+static char *ar8xxx_probe(struct device *host_dev, int sw_addr)
+{
+	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
+	u32 phy_id;
+
+	if (!bus)
+		return NULL;
+
+	/* sw_addr is irrelevant as the switch occupies the MDIO bus from
+	 * addresses 0 to 4 (PHYs) and 16-23 (for MDIO 32bits protocol). So
+	 * we'll probe address 0 to see if we see the right switch family.
+	 */
+	phy_id = mdiobus_read(bus, 0, MII_PHYSID1) << 16;
+	phy_id |= mdiobus_read(bus, 0, MII_PHYSID2);
+
+	switch (phy_id) {
+	case PHY_ID_QCA8337:
+		return "QCA8337";
+	default:
+		return NULL;
+	}
+}
+
+static int ar8xxx_set_pad_ctrl(struct dsa_switch *ds, int port, int mode)
+{
+	int reg;
+
+	switch (port) {
+	case 0:
+		reg = AR8327_REG_PORT0_PAD_CTRL;
+		break;
+	case 6:
+		reg = AR8327_REG_PORT6_PAD_CTRL;
+		break;
+	default:
+		pr_err("Can't set PAD_CTRL on port %d\n", port);
+		return -EINVAL;
+	}
+
+	/* DSA only supports 1 CPU port for now, so we'll take the assumption
+	 * that P0 is connected to the CPU master_dev.
+	 */
+	switch (mode) {
+	case PHY_INTERFACE_MODE_RGMII:
+		ar8xxx_write(ds, reg,
+			     AR8327_PORT_PAD_RGMII_EN |
+			     AR8327_PORT_PAD_RGMII_TX_DELAY(3) |
+			     AR8327_PORT_PAD_RGMII_RX_DELAY(3));
+
+		/* According to the datasheet, RGMII delay is enabled through
+		 * PORT5_PAD_CTRL for all ports, rather than individual port
+		 * registers
+		 */
+		ar8xxx_write(ds, AR8327_REG_PORT5_PAD_CTRL,
+			     AR8327_PORT_PAD_RGMII_RX_DELAY_EN);
+		break;
+	default:
+		pr_err("xMII mode %d not supported\n", mode);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int ar8xxx_setup(struct dsa_switch *ds)
+{
+	struct net_device *netdev = ds->dst->pd->of_netdev;
+	int ret, i, phy_mode;
+
+	/* Initialize CPU port pad mode (xMII type, delays...) */
+	phy_mode = of_get_phy_mode(netdev->dev.parent->of_node);
+	if (phy_mode < 0) {
+		pr_err("Can't find phy-mode for master device\n");
+		return phy_mode;
+	}
+
+	ret = ar8xxx_set_pad_ctrl(ds, 0, phy_mode);
+	if (ret < 0)
+		return ret;
+
+	/* Disable forwarding by default on all ports */
+	for (i = 0; i < AR8327_NUM_PORTS; i++)
+		ar8xxx_rmw(ds, AR8327_PORT_LOOKUP_CTRL(i),
+			   AR8327_PORT_LOOKUP_MEMBER, 0);
+
+	/* Setup connection between CPU ports & PHYs */
+	for (i = 0; i < DSA_MAX_PORTS; i++) {
+		/* CPU port gets connected to all PHYs in the switch */
+		if (dsa_is_cpu_port(ds, i)) {
+			ar8xxx_rmw(ds, AR8327_PORT_LOOKUP_CTRL(0),
+				   AR8327_PORT_LOOKUP_MEMBER,
+				   ds->phys_port_mask << 1);
+		}
+
+		/* Invividual PHYs gets connected to CPU port only */
+		if (ds->phys_port_mask & BIT(i)) {
+			ar8xxx_rmw(ds, AR8327_PORT_LOOKUP_CTRL(phy_to_port(i)),
+				   AR8327_PORT_LOOKUP_MEMBER, BIT(0));
+		}
+	}
+
+	return 0;
+}
+
+static int ar8xxx_set_addr(struct dsa_switch *ds, u8 *addr)
+{
+	return 0;
+}
+
+static int ar8xxx_phy_read(struct dsa_switch *ds, int phy, int regnum)
+{
+	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);
+
+	return mdiobus_read(bus, phy, regnum);
+}
+
+static int
+ar8xxx_phy_write(struct dsa_switch *ds, int phy, int regnum, u16 val)
+{
+	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);
+
+	return mdiobus_write(bus, phy, regnum, val);
+}
+
+static void ar8xxx_poll_link(struct dsa_switch *ds)
+{
+	int i = 0;
+	struct net_device *dev;
+
+	while ((dev = ds->ports[i++]) != NULL) {
+		u32 status;
+		int link;
+		int speed;
+		int duplex;
+
+		status = ar8xxx_read(ds, AR8327_REG_PORT_STATUS(i));
+		link = !!(status & AR8XXX_PORT_STATUS_LINK_UP);
+		duplex = !!(status & AR8XXX_PORT_STATUS_DUPLEX);
+
+		switch (status & AR8XXX_PORT_STATUS_SPEED) {
+		case AR8XXX_PORT_SPEED_10M:
+			speed = 10;
+			break;
+		case AR8XXX_PORT_SPEED_100M:
+			speed = 100;
+			break;
+		case AR8XXX_PORT_SPEED_1000M:
+			speed = 1000;
+			break;
+		default:
+			speed = 0;
+		}
+
+		if (!link) {
+			/* This poll happens every ~1s, so we don't want to
+			 * print the status every time. Only when the device
+			 * transitions from Link UP to Link DOWN
+			 */
+			if (netif_carrier_ok(dev))
+				netif_carrier_off(dev);
+			continue;
+		} else {
+			/* Same thing here. But we detect a Link UP event */
+			if (!netif_carrier_ok(dev))
+				netif_carrier_on(dev);
+			continue;
+		}
+	}
+}
+
+static struct dsa_switch_driver ar8xxx_switch_driver = {
+	.tag_protocol	= DSA_TAG_PROTO_NONE,
+	.probe		= ar8xxx_probe,
+	.setup		= ar8xxx_setup,
+	.set_addr	= ar8xxx_set_addr,
+	.poll_link	= ar8xxx_poll_link,
+	.phy_read	= ar8xxx_phy_read,
+	.phy_write	= ar8xxx_phy_write,
+};
+
+static int __init ar8xxx_init(void)
+{
+	register_switch_driver(&ar8xxx_switch_driver);
+	return 0;
+}
+module_init(ar8xxx_init);
+
+static void __exit ar8xxx_cleanup(void)
+{
+	unregister_switch_driver(&ar8xxx_switch_driver);
+}
+module_exit(ar8xxx_cleanup);
+
+MODULE_AUTHOR("Mathieu Olivari <mathieu-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>");
+MODULE_DESCRIPTION("Driver for AR8XXX ethernet switch family");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:ar8xxx");
diff --git a/drivers/net/dsa/ar8xxx.h b/drivers/net/dsa/ar8xxx.h
new file mode 100644
index 0000000..a29b6d3
--- /dev/null
+++ b/drivers/net/dsa/ar8xxx.h
@@ -0,0 +1,82 @@
+/*
+ * Copyright (C) 2009 Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
+ * Copyright (C) 2011-2012 Gabor Juhos <juhosg-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
+ * Copyright (c) 2015, The Linux Foundation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 and
+ * only version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef __AR8XXX_H
+#define __AR8XXX_H
+
+#include <linux/delay.h>
+
+#define AR8327_NUM_PORTS		7
+
+#define PHY_ID_QCA8337			0x004dd036
+
+#define AR8327_REG_PORT0_PAD_CTRL		0x004
+#define AR8327_REG_PORT5_PAD_CTRL		0x008
+#define AR8327_REG_PORT6_PAD_CTRL		0x00c
+#define   AR8327_PORT_PAD_RGMII_EN		BIT(26)
+#define   AR8327_PORT_PAD_RGMII_TX_DELAY(x)	((0x8 + (x & 0x3)) << 22)
+#define   AR8327_PORT_PAD_RGMII_RX_DELAY(x)	((0x10 + (x & 0x3)) << 20)
+#define   AR8327_PORT_PAD_RGMII_RX_DELAY_EN	BIT(24)
+#define   AR8327_PORT_PAD_SGMII_EN		BIT(7)
+
+#define AR8327_REG_PORT_STATUS(_i)		(0x07c + (_i) * 4)
+#define   AR8XXX_PORT_STATUS_SPEED	GENMASK(2, 0)
+#define   AR8XXX_PORT_STATUS_SPEED_S	0
+#define   AR8XXX_PORT_STATUS_TXMAC	BIT(2)
+#define   AR8XXX_PORT_STATUS_RXMAC	BIT(3)
+#define   AR8XXX_PORT_STATUS_TXFLOW	BIT(4)
+#define   AR8XXX_PORT_STATUS_RXFLOW	BIT(5)
+#define   AR8XXX_PORT_STATUS_DUPLEX	BIT(6)
+#define   AR8XXX_PORT_STATUS_LINK_UP	BIT(8)
+#define   AR8XXX_PORT_STATUS_LINK_AUTO	BIT(9)
+#define   AR8XXX_PORT_STATUS_LINK_PAUSE	BIT(10)
+
+#define AR8327_PORT_LOOKUP_CTRL(_i)		(0x660 + (_i) * 0xc)
+#define   AR8327_PORT_LOOKUP_MEMBER		GENMASK(6, 0)
+#define   AR8327_PORT_LOOKUP_IN_MODE		GENMASK(9, 8)
+#define   AR8327_PORT_LOOKUP_IN_MODE_S		8
+#define   AR8327_PORT_LOOKUP_STATE		GENMASK(18, 16)
+#define   AR8327_PORT_LOOKUP_STATE_S		16
+#define   AR8327_PORT_LOOKUP_LEARN		BIT(20)
+#define   AR8327_PORT_LOOKUP_ING_MIRROR_EN	BIT(25)
+
+/* port speed */
+enum {
+	AR8XXX_PORT_SPEED_10M = 0,
+	AR8XXX_PORT_SPEED_100M = 1,
+	AR8XXX_PORT_SPEED_1000M = 2,
+	AR8XXX_PORT_SPEED_ERR = 3,
+};
+
+static inline void
+split_addr(u32 regaddr, u16 *r1, u16 *r2, u16 *page)
+{
+	regaddr >>= 1;
+	*r1 = regaddr & 0x1e;
+
+	regaddr >>= 5;
+	*r2 = regaddr & 0x7;
+
+	regaddr >>= 3;
+	*page = regaddr & 0x1ff;
+}
+
+static inline void
+wait_for_page_switch(void)
+{
+	udelay(5);
+}
+
+#endif /* __AR8XXX_H */
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index e6f6cc3..fffb9aa 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -893,6 +893,7 @@ static SIMPLE_DEV_PM_OPS(dsa_pm_ops, dsa_suspend, dsa_resume);
 
 static const struct of_device_id dsa_of_match_table[] = {
 	{ .compatible = "brcm,bcm7445-switch-v4.0" },
+	{ .compatible = "qca,ar8xxx", },
 	{ .compatible = "marvell,dsa", },
 	{}
 };
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
