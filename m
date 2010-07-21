From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 2/2 v2] net: dsa: introduce MICREL KSZ8893MQL/BL ethernet switch chip support
Date: Wed, 21 Jul 2010 12:29:36 -0400
Message-ID: <1279729776-30091-1-git-send-email-vapier@gentoo.org>
References: <1279719442-10174-2-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org,
	Karl Beldan <karl.beldan@gmail.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Graf Yang <graf.yang@analog.com>,
	Bryan Wu <cooloney@kernel.org>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:58040 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751980Ab0GUQ3S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jul 2010 12:29:18 -0400
In-Reply-To: <1279719442-10174-2-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Graf Yang <graf.yang@analog.com>

Signed-off-by: Graf Yang <graf.yang@analog.com>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
v2
	- clean up header duplication

 net/dsa/Kconfig    |    7 +
 net/dsa/Makefile   |    1 +
 net/dsa/ksz8893m.c |  341 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/dsa/ksz8893m.h |  163 +++++++++++++++++++++++++
 4 files changed, 512 insertions(+), 0 deletions(-)
 create mode 100644 net/dsa/ksz8893m.c
 create mode 100644 net/dsa/ksz8893m.h

diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index ee8d705..4a87436 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -60,4 +60,11 @@ config NET_DSA_MV88E6123_61_65
 	  This enables support for the Marvell 88E6123/6161/6165
 	  ethernet switch chips.
 
+config NET_DSA_KSZ8893M
+	bool "MICREL KSZ8893MQL/BL ethernet switch chip support"
+	select NET_DSA_TAG_STPID
+	---help---
+	  This enables support for the Micrel KSZ8893MQL/BL
+	  ethernet switch chips.
+
 endif
diff --git a/net/dsa/Makefile b/net/dsa/Makefile
index 4881577..c4295e3 100644
--- a/net/dsa/Makefile
+++ b/net/dsa/Makefile
@@ -9,6 +9,7 @@ obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx.o
 obj-$(CONFIG_NET_DSA_MV88E6060) += mv88e6060.o
 obj-$(CONFIG_NET_DSA_MV88E6123_61_65) += mv88e6123_61_65.o
 obj-$(CONFIG_NET_DSA_MV88E6131) += mv88e6131.o
+obj-$(CONFIG_NET_DSA_KSZ8893M) += ksz8893m.o
 
 # the core
 obj-$(CONFIG_NET_DSA) += dsa.o slave.o
diff --git a/net/dsa/ksz8893m.c b/net/dsa/ksz8893m.c
new file mode 100644
index 0000000..0bfa193
--- /dev/null
+++ b/net/dsa/ksz8893m.c
@@ -0,0 +1,341 @@
+/*
+ * Integrated 3-Port 10/100 Managed Switch with PHYs
+ *
+ * - KSZ8893M support
+ *
+ * Copyright 2008-2010 Analog Devices Inc.
+ *
+ * Licensed under the GPL-2 or later.
+ */
+
+#define pr_fmt(fmt) "ksz8893m: " fmt
+
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+#include <linux/spi/spi.h>
+#include "dsa_priv.h"
+#include "ksz8893m.h"
+
+#define  BUF_LEN 6
+
+static struct _spi_switch {
+	struct spi_transfer xfer;
+	struct spi_device *dev;
+} sw;
+
+static int ksz8893m_read(unsigned char *din, unsigned char reg, int len)
+{
+	int i, ret;
+	struct spi_message message;
+	unsigned char dout[BUF_LEN];
+	struct spi_transfer *t = &sw.xfer;
+
+	t->len = len;
+	t->tx_buf = dout;
+	t->rx_buf = din;
+	dout[0] = SPI_READ;
+	dout[1] = reg;
+	for (i = 2; i < len; i++)
+		dout[i] = 0;
+
+	spi_message_init(&message);
+	spi_message_add_tail(t, &message);
+	ret = spi_sync(sw.dev, &message);
+	if (!ret)
+		return message.status;
+
+	pr_err("read reg%d failed, ret=%d\n", reg, ret);
+	return ret;
+}
+
+static int ksz8893m_write(unsigned char *dout, unsigned char reg, int len)
+{
+	int ret;
+	struct spi_message message;
+	unsigned char din[BUF_LEN];
+	struct spi_transfer *t = &sw.xfer;
+
+	t->len = len;
+	t->tx_buf = dout;
+	t->rx_buf = din;
+	dout[0] = SPI_WRITE;
+	dout[1] = reg;
+
+	spi_message_init(&message);
+	spi_message_add_tail(t, &message);
+	ret = spi_sync(sw.dev, &message);
+	if (!ret)
+		return message.status;
+
+	pr_err("write reg%d failed, ret=%d\n", reg, ret);
+	return ret;
+}
+
+static char *ksz8893m_probe(struct mii_bus *bus, int sw_addr)
+{
+	int ret, phyid_low, phyid_high;
+	unsigned char din[BUF_LEN];
+
+	phyid_high = mdiobus_read(bus, KSZ8893M_CPU_PORT, MII_PHYSID1);
+	phyid_low = mdiobus_read(bus, KSZ8893M_CPU_PORT, MII_PHYSID2);
+	if (phyid_high != PHYID_HIGH || phyid_low != PHYID_LOW)
+		return NULL;
+
+	ret = ksz8893m_read(din, ChipID0, 3);
+
+	if (!ret && FAMILY_ID == din[2])
+		return "KSZ8893M";
+
+	return NULL;
+}
+
+static int ksz8893m_switch_reset(struct dsa_switch *ds)
+{
+	return 0;
+}
+
+static int ksz8893m_setup_global(struct dsa_switch *ds)
+{
+	int ret;
+	unsigned char dout[BUF_LEN];
+	unsigned char din[BUF_LEN];
+
+	/* Set VLAN VID of port1 */
+	ret = ksz8893m_read(din, Port1Control3, 3);
+	if (ret)
+		return ret;
+	din[2] &= 0xf0;
+	dout[2] = (DEFAULT_PORT_VID & 0xfff) >> 8 | din[2];
+	dout[3] = DEFAULT_PORT_VID & 0xff;
+	ret = ksz8893m_write(dout, Port1Control3, 4);
+	if (ret)
+		return ret;
+
+	/* Set VLAN VID of port2 */
+	ret = ksz8893m_read(din, Port2Control3, 3);
+	if (ret)
+		return ret;
+	din[2] &= 0xf0;
+	dout[2] = (DEFAULT_PORT_VID & 0xfff) >> 8 | din[2];
+	dout[3] = DEFAULT_PORT_VID & 0xff;
+	ret = ksz8893m_write(dout, Port2Control3, 4);
+	if (ret)
+		return ret;
+
+	/* Set VLAN VID of port3 */
+	ret = ksz8893m_read(din, Port3Control3, 3);
+	if (ret)
+		return ret;
+	din[2] &= 0xf0;
+	dout[2] = (DEFAULT_PORT_VID & 0xfff) >> 8 | din[2];
+	dout[3] = DEFAULT_PORT_VID & 0xff;
+	ret = ksz8893m_write(dout, Port3Control3, 4);
+	if (ret)
+		return ret;
+
+	/* Insert VLAN tag that egress Port3 */
+	ret = ksz8893m_read(din, Port3Control0, 3);
+	if (ret)
+		return ret;
+	dout[2] = TAG_INSERTION | din[2];
+	ret = ksz8893m_write(dout, Port3Control0, 3);
+	if (ret)
+		return ret;
+
+	/* Enable STPID Mode */
+	ret = ksz8893m_read(din, GlobalControl9, 3);
+	if (ret)
+		return ret;
+	dout[2] = SPECIAL_TPID_MODE | din[2];
+	ret = ksz8893m_write(dout, GlobalControl9, 3);
+	if (ret)
+		return ret;
+
+	/* Start switch */
+	dout[2] = START_SWITCH;
+	ret = ksz8893m_write(dout, ChipID1_StartSwitch, 3);
+	if (ret)
+		return ret;
+
+	return 0;
+}
+
+static int ksz8893m_setup_port(struct dsa_switch *ds, int p)
+{
+	int val, ret;
+	val = mdiobus_read(ds->master_mii_bus, p, MII_BMCR);
+	if (val < 0)
+		return val;
+	val |= BMCR_ANENABLE | BMCR_SPEED100 | BMCR_FULLDPLX;
+	val &= ~(BMCR_PDOWN | DISABLE_MDIX | DIS_FAR_END_FAULT |
+			DISABLE_TRANSMIT | DISABLE_LED);
+	ret = mdiobus_write(ds->master_mii_bus, p, MII_BMCR, val);
+	if (ret < 0)
+		return ret;
+
+	val = mdiobus_read(ds->master_mii_bus, p, MII_ADVERTISE);
+	if (val < 0)
+		return val;
+	val |= ADVERTISE_10HALF | ADVERTISE_10FULL |
+		ADVERTISE_100HALF | ADVERTISE_100FULL;
+	ret = mdiobus_write(ds->master_mii_bus, p, MII_ADVERTISE, val);
+	if (ret < 0)
+		return ret;
+	return 0;
+}
+
+static int ksz8893m_setup(struct dsa_switch *ds)
+{
+	int i;
+	int ret;
+
+	ret = ksz8893m_switch_reset(ds);
+	if (ret < 0)
+		return ret;
+
+	ret = ksz8893m_setup_global(ds);
+	if (ret < 0)
+		return ret;
+
+	for (i = 1; i < KSZ8893M_PORT_NUM; i++) {
+		ret = ksz8893m_setup_port(ds, i);
+		if (ret < 0)
+			return ret;
+	}
+
+	return 0;
+}
+
+static int ksz8893m_set_addr(struct dsa_switch *ds, u8 *addr)
+{
+	return 0;
+}
+
+static int ksz8893m_port_to_phy_addr(int port)
+{
+	if (port >= 1 && port <= KSZ8893M_PORT_NUM)
+		return port;
+	return -1;
+}
+
+static int
+ksz8893m_phy_read(struct dsa_switch *ds, int port, int regnum)
+{
+	int phy_addr = ksz8893m_port_to_phy_addr(port);
+	return mdiobus_read(ds->master_mii_bus, phy_addr, regnum);
+}
+
+static int
+ksz8893m_phy_write(struct dsa_switch *ds,
+			      int port, int regnum, u16 val)
+{
+	int phy_addr = ksz8893m_port_to_phy_addr(port);
+	return mdiobus_write(ds->master_mii_bus, phy_addr, regnum, val);
+}
+
+static void ksz8893m_poll_link(struct dsa_switch *ds)
+{
+	int i;
+
+	for (i = 1; i < KSZ8893M_PORT_NUM; i++) {
+		struct net_device *dev;
+		int val, link;
+
+		dev = ds->ports[i];
+		if (dev == NULL)
+			continue;
+
+		link = 0;
+		if (dev->flags & IFF_UP) {
+			val = mdiobus_read(ds->master_mii_bus, i, MII_BMSR);
+			if (val < 0)
+				continue;
+
+			link = val & BMSR_LSTATUS;
+		}
+
+		if (!link) {
+			if (netif_carrier_ok(dev)) {
+				printk(KERN_INFO "%s: link down\n", dev->name);
+				netif_carrier_off(dev);
+			}
+			continue;
+		}
+
+		val = mdiobus_read(ds->master_mii_bus, i, MII_BMSR);
+		if (val < 0)
+			continue;
+
+		if (!netif_carrier_ok(dev)) {
+			printk(KERN_INFO "%s: link up, %d Mb/s, %s duplex\n",
+					dev->name,
+					(val & LPA_100) ? 100 : 10,
+					(val & LPA_DUPLEX) ? "half" : "full");
+			netif_carrier_on(dev);
+		}
+	}
+}
+
+static int __devinit spi_switch_probe(struct spi_device *spi)
+{
+	if (sw.dev) {
+		pr_err("only one instance supported at a time\n");
+		return 1;
+	}
+	memset(&sw.xfer, 0, sizeof(sw.xfer));
+	sw.dev = spi;
+	return 0;
+}
+
+static int __devexit spi_switch_remove(struct spi_device *spi)
+{
+	sw.dev = NULL;
+	return 0;
+}
+
+static struct spi_driver spi_switch_driver = {
+	.driver = {
+		.name	= "ksz8893m",
+		.bus	= &spi_bus_type,
+		.owner	= THIS_MODULE,
+	},
+	.probe	= spi_switch_probe,
+	.remove	= __devexit_p(spi_switch_remove),
+};
+
+static struct dsa_switch_driver ksz8893m_switch_driver = {
+	.tag_protocol		= __constant_htons(ETH_P_STPID),
+	.probe			= ksz8893m_probe,
+	.setup			= ksz8893m_setup,
+	.set_addr		= ksz8893m_set_addr,
+	.phy_read		= ksz8893m_phy_read,
+	.phy_write		= ksz8893m_phy_write,
+	.poll_link		= ksz8893m_poll_link,
+};
+
+static int __init ksz8893m_init(void)
+{
+	int ret;
+
+	ret = spi_register_driver(&spi_switch_driver);
+	if (ret) {
+		pr_err("can't register driver\n");
+		return ret;
+	}
+
+	register_switch_driver(&ksz8893m_switch_driver);
+	return 0;
+}
+module_init(ksz8893m_init);
+
+static void __exit ksz8893m_cleanup(void)
+{
+	spi_unregister_driver(&spi_switch_driver);
+	unregister_switch_driver(&ksz8893m_switch_driver);
+}
+module_exit(ksz8893m_cleanup);
+
+MODULE_AUTHOR("Graf Yang <graf.yang@analog.com>");
+MODULE_DESCRIPTION("KSZ8893M driver for DSA");
+MODULE_LICENSE("GPL");
diff --git a/net/dsa/ksz8893m.h b/net/dsa/ksz8893m.h
new file mode 100644
index 0000000..30e0df0
--- /dev/null
+++ b/net/dsa/ksz8893m.h
@@ -0,0 +1,163 @@
+/*
+ * Integrated 3-Port 10/100 Managed Switch with PHYs
+ *
+ * - KSZ8893M support
+ *
+ * Copyright 2008-2010 Analog Devices Inc.
+ *
+ * Licensed under the GPL-2 or later.
+ */
+
+#ifndef __KSZ8893M_H__
+#define __KSZ8893M_H__
+
+#define KSZ8893M_PORT_NUM 3
+#define KSZ8893M_CPU_PORT 3
+
+#define DEFAULT_PORT_VID  0
+
+/* Simple SPI command set for poking registers */
+#define SPI_READ          3
+#define SPI_WRITE         2
+
+/* Expected value for MII_PHYSID1 */
+#define PHYID_HIGH        0x22
+/* Expected value for MII_PHYSID2 */
+#define PHYID_LOW         0x1430
+
+/* ChipID0 defines */
+#define FAMILY_ID         0x88
+
+/* ChipID1_StartSwitch defines */
+#define START_SWITCH      0x01
+
+/* Port3Control0 defines */
+#define TAG_INSERTION     0x04
+
+/* GlobalControl9 defines */
+#define SPECIAL_TPID_MODE 0x01
+
+/* BMCR Reserved Bits */
+#define HP_MDIX           0x0020
+#define FORCE_MDI         0x0010
+#define DISABLE_MDIX      0x0008
+#define DIS_FAR_END_FAULT 0x0004
+#define DISABLE_TRANSMIT  0x0002
+#define DISABLE_LED       0x0001
+
+/* BMSCR Reserved Bits */
+#define PREAMBLE_SUPPRESS 0x0040
+
+enum switch_phy_reg {
+	/* Global Registers: 0-15 */
+	ChipID0 = 0,
+	ChipID1_StartSwitch,
+	GlobalControl0,
+	GlobalControl1,
+	GlobalControl2, /* 4 */
+	GlobalControl3,
+	GlobalControl4,
+	GlobalControl5,
+	GlobalControl6, /* 8 */
+	GlobalControl7,
+	GlobalControl8,
+	GlobalControl9,
+	GlobalControl10, /* 12 */
+	GlobalControl11,
+	GlobalControl12,
+	GlobalControl13,
+	/* Port Registers: 16-95 */
+	Port1Control0 = 16,
+	Port1Control1,
+	Port1Control2,
+	Port1Control3,
+	Port1Control4, /* 20 */
+	Port1Control5,
+	Port1Control6,
+	Port1Control7,
+	Port1Control8, /* 24 */
+	Port1Control9,
+	Port1PHYSpecialControl_Status,
+	Port1LinkMDResult,
+	Port1Control12, /* 28 */
+	Port1Control13,
+	Port1Status0,
+	Port1Status1,
+	Port2Control0, /* 32 */
+	Port2Control1,
+	Port2Control2,
+	Port2Control3,
+	Port2Control4, /* 36 */
+	Port2Control5,
+	Port2Control6,
+	Port2Control7,
+	Port2Control8, /* 40 */
+	Port2Control9,
+	Port2PHYSpecialControl_Status,
+	Port2LinkMDResult,
+	Port2Control12, /* 44 */
+	Port2Control13,
+	Port2Status0,
+	Port2Status1,
+	Port3Control0, /* 48 */
+	Port3Control1,
+	Port3Control2,
+	Port3Control3,
+	Port3Control4, /* 52 */
+	Port3Control5,
+	Port3Control6,
+	Port3Control7,
+	Port3Control8, /* 56 */
+	Port3Control9,
+	Reservednotappliedtoport3, /* 58-62 */
+	Port3Status1 = 63,
+	/* Advanced Control Registers: 96-141 */
+	TOSPriorityControlRegister0 = 96,
+	TOSPriorityControlRegister1,
+	TOSPriorityControlRegister2,
+	TOSPriorityControlRegister3,
+	TOSPriorityControlRegister4, /* 100 */
+	TOSPriorityControlRegister5,
+	TOSPriorityControlRegister6,
+	TOSPriorityControlRegister7,
+	TOSPriorityControlRegister8, /* 104 */
+	TOSPriorityControlRegister9,
+	TOSPriorityControlRegister10,
+	TOSPriorityControlRegister11,
+	TOSPriorityControlRegister12, /* 108 */
+	TOSPriorityControlRegister13,
+	TOSPriorityControlRegister14,
+	TOSPriorityControlRegister15,
+	MACAddressRegister0 = 112,
+	MACAddressRegister1,
+	MACAddressRegister2,
+	MACAddressRegister3,
+	MACAddressRegister4,
+	MACAddressRegister5,
+	UserDefinedRegister1 = 118,
+	UserDefinedRegister2,
+	UserDefinedRegister3,
+	IndirectAccessControl0 = 121,
+	IndirectAccessControl1,
+	IndirectDataRegister8 = 123,
+	IndirectDataRegister7,
+	IndirectDataRegister6,
+	IndirectDataRegister5,
+	IndirectDataRegister4,
+	IndirectDataRegister3,
+	IndirectDataRegister2,
+	IndirectDataRegister1,
+	IndirectDataRegister0,
+	DigitalTestingStatus0 = 132,
+	DigitalTestingControl0,
+	AnalogTestingControl0,
+	AnalogTestingControl1,
+	AnalogTestingControl2,
+	AnalogTestingControl3,
+	AnalogTestingStatus,
+	AnalogTestingControl4,
+	QMDebug1,
+	QMDebug2,
+};
+
+#endif
-- 
1.7.1.1

