From: John Crispin <john@phrozen.org>
Subject: [PATCH V3 3/3] net-next: dsa: add new driver for qca8xxx family
Date: Thu, 15 Sep 2016 16:26:41 +0200
Message-ID: <1473949601-20674-4-git-send-email-john@phrozen.org>
References: <1473949601-20674-1-git-send-email-john@phrozen.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        qsdk-review@qca.qualcomm.com, John Crispin <john@phrozen.org>
To: "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:50604 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758407AbcIOO05 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Sep 2016 10:26:57 -0400
In-Reply-To: <1473949601-20674-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch contains initial support for the QCA8337 switch. It
will detect a QCA8337 switch, if present and declared in the DT.

Each port will be represented through a standalone net_device interface,
as for other DSA switches. CPU can communicate with any of the ports by
setting an IP@ on ethN interface. Most of the extra callbacks of the DSA
subsystem are already supported, such as bridge offloading, stp, fdb.

Signed-off-by: John Crispin <john@phrozen.org>
---
Changes in V2
* add proper locking for the FDB table
* remove udelay when changing the page. neither datasheet nore SDK code
  requires a sleep
* add a cond_resched to the busy wait loop
* use nested locking when accessing the mdio bus
* remove the phy_to_port() wrappers
* remove mmd access function and use existing phy helpers
* fix a copy/paste bug breaking the eee callbacks
* use default vid 1 when fdb entries are added fro vid 0
* remove the phy id check and add a switch id check instead
* add error handling to the mdio read/write functions
* remove inline usage

Changes in V3
* remove qca8k_to_priv() helper
* turn fdb mutex into a generic register mutex
* verify that port0 is the cpu port
* flush MIB counters on startup
* more PHY->port
* implement fdb_prepare properly
* power ports up/down on PM event and shutdown

 drivers/net/dsa/Kconfig  |    9 +
 drivers/net/dsa/Makefile |    1 +
 drivers/net/dsa/qca8k.c  | 1060 ++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/qca8k.h  |  185 ++++++++
 4 files changed, 1255 insertions(+)
 create mode 100644 drivers/net/dsa/qca8k.c
 create mode 100644 drivers/net/dsa/qca8k.h

diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index de6d044..0659846 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -25,4 +25,13 @@ source "drivers/net/dsa/b53/Kconfig"
 
 source "drivers/net/dsa/mv88e6xxx/Kconfig"
 
+config NET_DSA_QCA8K
+	tristate "Qualcomm Atheros QCA8K Ethernet switch family support"
+	depends on NET_DSA
+	select NET_DSA_TAG_QCA
+	select REGMAP
+	---help---
+	  This enables support for the Qualcomm Atheros QCA8K Ethernet
+	  switch chips.
+
 endmenu
diff --git a/drivers/net/dsa/Makefile b/drivers/net/dsa/Makefile
index ca1e71b..8346e4f 100644
--- a/drivers/net/dsa/Makefile
+++ b/drivers/net/dsa/Makefile
@@ -1,5 +1,6 @@
 obj-$(CONFIG_NET_DSA_MV88E6060) += mv88e6060.o
 obj-$(CONFIG_NET_DSA_BCM_SF2)	+= bcm_sf2.o
+obj-$(CONFIG_NET_DSA_QCA8K)	+= qca8k.o
 
 obj-y				+= b53/
 obj-y				+= mv88e6xxx/
diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
new file mode 100644
index 0000000..7f3f178
--- /dev/null
+++ b/drivers/net/dsa/qca8k.c
@@ -0,0 +1,1060 @@
+/*
+ * Copyright (C) 2009 Felix Fietkau <nbd@nbd.name>
+ * Copyright (C) 2011-2012 Gabor Juhos <juhosg@openwrt.org>
+ * Copyright (c) 2015, The Linux Foundation. All rights reserved.
+ * Copyright (c) 2016 John Crispin <john@phrozen.org>
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
+#include <net/switchdev.h>
+#include <linux/of_net.h>
+#include <linux/of_platform.h>
+#include <linux/if_bridge.h>
+#include <linux/mdio.h>
+#include <linux/etherdevice.h>
+
+#include "qca8k.h"
+
+#define MIB_DESC(_s, _o, _n)	\
+	{			\
+		.size = (_s),	\
+		.offset = (_o),	\
+		.name = (_n),	\
+	}
+
+static const struct qca8k_mib_desc ar8327_mib[] = {
+	MIB_DESC(1, 0x00, "RxBroad"),
+	MIB_DESC(1, 0x04, "RxPause"),
+	MIB_DESC(1, 0x08, "RxMulti"),
+	MIB_DESC(1, 0x0c, "RxFcsErr"),
+	MIB_DESC(1, 0x10, "RxAlignErr"),
+	MIB_DESC(1, 0x14, "RxRunt"),
+	MIB_DESC(1, 0x18, "RxFragment"),
+	MIB_DESC(1, 0x1c, "Rx64Byte"),
+	MIB_DESC(1, 0x20, "Rx128Byte"),
+	MIB_DESC(1, 0x24, "Rx256Byte"),
+	MIB_DESC(1, 0x28, "Rx512Byte"),
+	MIB_DESC(1, 0x2c, "Rx1024Byte"),
+	MIB_DESC(1, 0x30, "Rx1518Byte"),
+	MIB_DESC(1, 0x34, "RxMaxByte"),
+	MIB_DESC(1, 0x38, "RxTooLong"),
+	MIB_DESC(2, 0x3c, "RxGoodByte"),
+	MIB_DESC(2, 0x44, "RxBadByte"),
+	MIB_DESC(1, 0x4c, "RxOverFlow"),
+	MIB_DESC(1, 0x50, "Filtered"),
+	MIB_DESC(1, 0x54, "TxBroad"),
+	MIB_DESC(1, 0x58, "TxPause"),
+	MIB_DESC(1, 0x5c, "TxMulti"),
+	MIB_DESC(1, 0x60, "TxUnderRun"),
+	MIB_DESC(1, 0x64, "Tx64Byte"),
+	MIB_DESC(1, 0x68, "Tx128Byte"),
+	MIB_DESC(1, 0x6c, "Tx256Byte"),
+	MIB_DESC(1, 0x70, "Tx512Byte"),
+	MIB_DESC(1, 0x74, "Tx1024Byte"),
+	MIB_DESC(1, 0x78, "Tx1518Byte"),
+	MIB_DESC(1, 0x7c, "TxMaxByte"),
+	MIB_DESC(1, 0x80, "TxOverSize"),
+	MIB_DESC(2, 0x84, "TxByte"),
+	MIB_DESC(1, 0x8c, "TxCollision"),
+	MIB_DESC(1, 0x90, "TxAbortCol"),
+	MIB_DESC(1, 0x94, "TxMultiCol"),
+	MIB_DESC(1, 0x98, "TxSingleCol"),
+	MIB_DESC(1, 0x9c, "TxExcDefer"),
+	MIB_DESC(1, 0xa0, "TxDefer"),
+	MIB_DESC(1, 0xa4, "TxLateCol"),
+};
+
+/* The 32bit switch registers are accessed indirectly. To achieve this we need
+ * to set the page of the register. Track the last page that was set to reduce
+ * mdio writes
+ */
+static u16 qca8k_current_page = 0xffff;
+
+static void
+qca8k_split_addr(u32 regaddr, u16 *r1, u16 *r2, u16 *page)
+{
+	regaddr >>= 1;
+	*r1 = regaddr & 0x1e;
+
+	regaddr >>= 5;
+	*r2 = regaddr & 0x7;
+
+	regaddr >>= 3;
+	*page = regaddr & 0x3ff;
+}
+
+static u32
+qca8k_mii_read32(struct mii_bus *bus, int phy_id, u32 regnum)
+{
+	u32 val;
+	int ret;
+
+	ret = bus->read(bus, phy_id, regnum);
+	if (ret >= 0) {
+		val = ret;
+		ret = bus->read(bus, phy_id, regnum + 1);
+		val |= ret << 16;
+	}
+
+	if (ret < 0) {
+		dev_err_ratelimited(&bus->dev,
+				    "failed to read qca8k 32bit register\n");
+		return ret;
+	}
+
+	return val;
+}
+
+static void
+qca8k_mii_write32(struct mii_bus *bus, int phy_id, u32 regnum, u32 val)
+{
+	u16 lo, hi;
+	int ret;
+
+	lo = val & 0xffff;
+	hi = (u16)(val >> 16);
+
+	ret = bus->write(bus, phy_id, regnum, lo);
+	if (ret >= 0)
+		ret = bus->write(bus, phy_id, regnum + 1, hi);
+	if (ret < 0)
+		dev_err_ratelimited(&bus->dev,
+				    "failed to write qca8k 32bit register\n");
+}
+
+static void
+qca8k_set_page(struct mii_bus *bus, u16 page)
+{
+	if (page == qca8k_current_page)
+		return;
+
+	if (bus->write(bus, 0x18, 0, page) < 0)
+		dev_err_ratelimited(&bus->dev,
+				    "failed to set qca8k page\n");
+	qca8k_current_page = page;
+}
+
+static u32
+qca8k_read(struct qca8k_priv *priv, u32 reg)
+{
+	u16 r1, r2, page;
+	u32 val;
+
+	qca8k_split_addr(reg, &r1, &r2, &page);
+
+	mutex_lock_nested(&priv->bus->mdio_lock, MDIO_MUTEX_NESTED);
+
+	qca8k_set_page(priv->bus, page);
+	val = qca8k_mii_read32(priv->bus, 0x10 | r2, r1);
+
+	mutex_unlock(&priv->bus->mdio_lock);
+
+	return val;
+}
+
+static void
+qca8k_write(struct qca8k_priv *priv, u32 reg, u32 val)
+{
+	u16 r1, r2, page;
+
+	qca8k_split_addr(reg, &r1, &r2, &page);
+
+	mutex_lock_nested(&priv->bus->mdio_lock, MDIO_MUTEX_NESTED);
+
+	qca8k_set_page(priv->bus, page);
+	qca8k_mii_write32(priv->bus, 0x10 | r2, r1, val);
+
+	mutex_unlock(&priv->bus->mdio_lock);
+}
+
+static u32
+qca8k_rmw(struct qca8k_priv *priv, u32 reg, u32 mask, u32 val)
+{
+	u16 r1, r2, page;
+	u32 ret;
+
+	qca8k_split_addr(reg, &r1, &r2, &page);
+
+	mutex_lock_nested(&priv->bus->mdio_lock, MDIO_MUTEX_NESTED);
+
+	qca8k_set_page(priv->bus, page);
+	ret = qca8k_mii_read32(priv->bus, 0x10 | r2, r1);
+	ret &= ~mask;
+	ret |= val;
+	qca8k_mii_write32(priv->bus, 0x10 | r2, r1, ret);
+
+	mutex_unlock(&priv->bus->mdio_lock);
+
+	return ret;
+}
+
+static void
+qca8k_reg_set(struct qca8k_priv *priv, u32 reg, u32 val)
+{
+	qca8k_rmw(priv, reg, 0, val);
+}
+
+static void
+qca8k_reg_clear(struct qca8k_priv *priv, u32 reg, u32 val)
+{
+	qca8k_rmw(priv, reg, val, 0);
+}
+
+static int
+qca8k_regmap_read(void *ctx, uint32_t reg, uint32_t *val)
+{
+	struct qca8k_priv *priv = (struct qca8k_priv *)ctx;
+
+	*val = qca8k_read(priv, reg);
+
+	return 0;
+}
+
+static int
+qca8k_regmap_write(void *ctx, uint32_t reg, uint32_t val)
+{
+	struct qca8k_priv *priv = (struct qca8k_priv *)ctx;
+
+	qca8k_write(priv, reg, val);
+
+	return 0;
+}
+
+static const struct regmap_range qca8k_readable_ranges[] = {
+	regmap_reg_range(0x0000, 0x00e4), /* Global control */
+	regmap_reg_range(0x0100, 0x0168), /* EEE control */
+	regmap_reg_range(0x0200, 0x0270), /* Parser control */
+	regmap_reg_range(0x0400, 0x0454), /* ACL */
+	regmap_reg_range(0x0600, 0x0718), /* Lookup */
+	regmap_reg_range(0x0800, 0x0b70), /* QM */
+	regmap_reg_range(0x0c00, 0x0c80), /* PKT */
+	regmap_reg_range(0x0e00, 0x0e98), /* L3 */
+	regmap_reg_range(0x1000, 0x10ac), /* MIB - Port0 */
+	regmap_reg_range(0x1100, 0x11ac), /* MIB - Port1 */
+	regmap_reg_range(0x1200, 0x12ac), /* MIB - Port2 */
+	regmap_reg_range(0x1300, 0x13ac), /* MIB - Port3 */
+	regmap_reg_range(0x1400, 0x14ac), /* MIB - Port4 */
+	regmap_reg_range(0x1500, 0x15ac), /* MIB - Port5 */
+	regmap_reg_range(0x1600, 0x16ac), /* MIB - Port6 */
+
+};
+
+static struct regmap_access_table qca8k_readable_table = {
+	.yes_ranges = qca8k_readable_ranges,
+	.n_yes_ranges = ARRAY_SIZE(qca8k_readable_ranges),
+};
+
+struct regmap_config qca8k_regmap_config = {
+	.reg_bits = 16,
+	.val_bits = 32,
+	.reg_stride = 4,
+	.max_register = 0x16ac, /* end MIB - Port6 range */
+	.reg_read = qca8k_regmap_read,
+	.reg_write = qca8k_regmap_write,
+	.rd_table = &qca8k_readable_table,
+};
+
+static int
+qca8k_busy_wait(struct qca8k_priv *priv, u32 reg, u32 mask)
+{
+	unsigned long timeout;
+
+	timeout = jiffies + msecs_to_jiffies(20);
+
+	/* loop until the busy flag has cleared */
+	do {
+		u32 val = qca8k_read(priv, reg);
+		int busy = val & mask;
+
+		if (!busy)
+			break;
+		cond_resched();
+	} while (!time_after_eq(jiffies, timeout));
+
+	return time_after_eq(jiffies, timeout);
+}
+
+static void
+qca8k_fdb_read(struct qca8k_priv *priv, struct qca8k_fdb *fdb)
+{
+	u32 reg[4];
+	int i;
+
+	/* load the ARL table into an array */
+	for (i = 0; i < 4; i++)
+		reg[i] = qca8k_read(priv, QCA8K_REG_ATU_DATA0 + (i * 4));
+
+	/* vid - 83:72 */
+	fdb->vid = (reg[2] >> QCA8K_ATU_VID_S) & QCA8K_ATU_VID_M;
+	/* aging - 67:64 */
+	fdb->aging = reg[2] & QCA8K_ATU_STATUS_M;
+	/* portmask - 54:48 */
+	fdb->port_mask = (reg[1] >> QCA8K_ATU_PORT_S) & QCA8K_ATU_PORT_M;
+	/* mac - 47:0 */
+	fdb->mac[0] = (reg[1] >> QCA8K_ATU_ADDR0_S) & 0xff;
+	fdb->mac[1] = reg[1] & 0xff;
+	fdb->mac[2] = (reg[0] >> QCA8K_ATU_ADDR2_S) & 0xff;
+	fdb->mac[3] = (reg[0] >> QCA8K_ATU_ADDR3_S) & 0xff;
+	fdb->mac[4] = (reg[0] >> QCA8K_ATU_ADDR4_S) & 0xff;
+	fdb->mac[5] = reg[0] & 0xff;
+}
+
+static void
+qca8k_fdb_write(struct qca8k_priv *priv, u16 vid, u8 port_mask, const u8 *mac,
+		u8 aging)
+{
+	u32 reg[3] = { 0 };
+	int i;
+
+	/* vid - 83:72 */
+	reg[2] = (vid & QCA8K_ATU_VID_M) << QCA8K_ATU_VID_S;
+	/* aging - 67:64 */
+	reg[2] |= aging & QCA8K_ATU_STATUS_M;
+	/* portmask - 54:48 */
+	reg[1] = (port_mask & QCA8K_ATU_PORT_M) << QCA8K_ATU_PORT_S;
+	/* mac - 47:0 */
+	reg[1] |= mac[0] << QCA8K_ATU_ADDR0_S;
+	reg[1] |= mac[1];
+	reg[0] |= mac[2] << QCA8K_ATU_ADDR2_S;
+	reg[0] |= mac[3] << QCA8K_ATU_ADDR3_S;
+	reg[0] |= mac[4] << QCA8K_ATU_ADDR4_S;
+	reg[0] |= mac[5];
+
+	/* load the array into the ARL table */
+	for (i = 0; i < 3; i++)
+		qca8k_write(priv, QCA8K_REG_ATU_DATA0 + (i * 4), reg[i]);
+}
+
+static int
+qca8k_fdb_access(struct qca8k_priv *priv, enum qca8k_fdb_cmd cmd, int port)
+{
+	u32 reg;
+
+	/* Set the command and FDB index */
+	reg = QCA8K_ATU_FUNC_BUSY;
+	reg |= cmd;
+	if (port >= 0) {
+		reg |= QCA8K_ATU_FUNC_PORT_EN;
+		reg |= (port & QCA8K_ATU_FUNC_PORT_M) << QCA8K_ATU_FUNC_PORT_S;
+	}
+
+	/* Write the function register triggering the table access */
+	qca8k_write(priv, QCA8K_REG_ATU_FUNC, reg);
+
+	/* wait for completion */
+	if (qca8k_busy_wait(priv, QCA8K_REG_ATU_FUNC, QCA8K_ATU_FUNC_BUSY))
+		return -1;
+
+	/* Check for table full violation when adding an entry */
+	if (cmd == QCA8K_FDB_LOAD) {
+		reg = qca8k_read(priv, QCA8K_REG_ATU_FUNC);
+		if (reg & QCA8K_ATU_FUNC_FULL)
+			return -1;
+	}
+
+	return 0;
+}
+
+static int
+qca8k_fdb_next(struct qca8k_priv *priv, struct qca8k_fdb *fdb, int port)
+{
+	int ret;
+
+	qca8k_fdb_write(priv, fdb->vid, fdb->port_mask, fdb->mac, fdb->aging);
+	ret = qca8k_fdb_access(priv, QCA8K_FDB_NEXT, port);
+	if (ret >= 0)
+		qca8k_fdb_read(priv, fdb);
+
+	return ret;
+}
+
+static int
+qca8k_fdb_add(struct qca8k_priv *priv, const u8 *mac, u16 port_mask,
+	      u16 vid, u8 aging)
+{
+	int ret;
+
+	mutex_lock(&priv->reg_mutex);
+	qca8k_fdb_write(priv, vid, port_mask, mac, aging);
+	ret = qca8k_fdb_access(priv, QCA8K_FDB_LOAD, -1);
+	mutex_unlock(&priv->reg_mutex);
+
+	return ret;
+}
+
+static int
+qca8k_fdb_del(struct qca8k_priv *priv, const u8 *mac, u16 port_mask, u16 vid)
+{
+	int ret;
+
+	mutex_lock(&priv->reg_mutex);
+	qca8k_fdb_write(priv, vid, port_mask, mac, 0);
+	ret = qca8k_fdb_access(priv, QCA8K_FDB_PURGE, -1);
+	mutex_unlock(&priv->reg_mutex);
+
+	return ret;
+}
+
+static void
+qca8k_fdb_flush(struct qca8k_priv *priv)
+{
+	mutex_lock(&priv->reg_mutex);
+	qca8k_fdb_access(priv, QCA8K_FDB_FLUSH, -1);
+	mutex_unlock(&priv->reg_mutex);
+}
+
+static void
+qca8k_mib_init(struct qca8k_priv *priv)
+{
+	mutex_lock(&priv->reg_mutex);
+	qca8k_reg_set(priv, QCA8K_REG_MIB, QCA8K_MIB_FLUSH | QCA8K_MIB_BUSY);
+	qca8k_busy_wait(priv, QCA8K_REG_MIB, QCA8K_MIB_BUSY);
+	qca8k_reg_set(priv, QCA8K_REG_MIB, QCA8K_MIB_CPU_KEEP);
+	qca8k_write(priv, QCA8K_REG_MODULE_EN, QCA8K_MODULE_EN_MIB);
+	mutex_unlock(&priv->reg_mutex);
+}
+
+static int
+qca8k_set_pad_ctrl(struct qca8k_priv *priv, int port, int mode)
+{
+	u32 reg;
+
+	switch (port) {
+	case 0:
+		reg = QCA8K_REG_PORT0_PAD_CTRL;
+		break;
+	case 6:
+		reg = QCA8K_REG_PORT6_PAD_CTRL;
+		break;
+	default:
+		pr_err("Can't set PAD_CTRL on port %d\n", port);
+		return -EINVAL;
+	}
+
+	/* Configure a port to be directly connected to an external
+	 * PHY or MAC.
+	 */
+	switch (mode) {
+	case PHY_INTERFACE_MODE_RGMII:
+		qca8k_write(priv, reg,
+			    QCA8K_PORT_PAD_RGMII_EN |
+			    QCA8K_PORT_PAD_RGMII_TX_DELAY(3) |
+			    QCA8K_PORT_PAD_RGMII_RX_DELAY(3));
+
+		/* According to the datasheet, RGMII delay is enabled through
+		 * PORT5_PAD_CTRL for all ports, rather than individual port
+		 * registers
+		 */
+		qca8k_write(priv, QCA8K_REG_PORT5_PAD_CTRL,
+			    QCA8K_PORT_PAD_RGMII_RX_DELAY_EN);
+		break;
+	case PHY_INTERFACE_MODE_SGMII:
+		qca8k_write(priv, reg, QCA8K_PORT_PAD_SGMII_EN);
+		break;
+	default:
+		pr_err("xMII mode %d not supported\n", mode);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static void
+qca8k_port_set_status(struct qca8k_priv *priv, int port, int enable)
+{
+	u32 mask = QCA8K_PORT_STATUS_TXMAC;
+
+	/* Port 0 and 6 have no internal PHY */
+	if ((port > 0) && (port < 6))
+		mask |= QCA8K_PORT_STATUS_LINK_AUTO;
+
+	if (enable)
+		qca8k_reg_set(priv, QCA8K_REG_PORT_STATUS(port), mask);
+	else
+		qca8k_reg_clear(priv, QCA8K_REG_PORT_STATUS(port), mask);
+}
+
+static int
+qca8k_setup(struct dsa_switch *ds)
+{
+	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
+	int ret, i, phy_mode = -1;
+
+	/* Make sure that port 0 is the cpu port */
+	if (!dsa_is_cpu_port(ds, 0)) {
+		pr_err("port 0 is not the CPU port\n");
+		return -EINVAL;
+	}
+
+	mutex_init(&priv->reg_mutex);
+
+	/* Start by setting up the register mapping */
+	priv->regmap = devm_regmap_init(ds->dev, NULL, priv,
+					&qca8k_regmap_config);
+	if (IS_ERR(priv->regmap))
+		pr_warn("regmap initialization failed");
+
+	/* Initialize CPU port pad mode (xMII type, delays...) */
+	phy_mode = of_get_phy_mode(ds->ports[ds->dst->cpu_port].dn);
+	if (phy_mode < 0) {
+		pr_err("Can't find phy-mode for master device\n");
+		return phy_mode;
+	}
+	ret = qca8k_set_pad_ctrl(priv, QCA8K_CPU_PORT, phy_mode);
+	if (ret < 0)
+		return ret;
+
+	/* Enable CPU Port */
+	qca8k_reg_set(priv, QCA8K_REG_GLOBAL_FW_CTRL0,
+		      QCA8K_GLOBAL_FW_CTRL0_CPU_PORT_EN);
+	qca8k_port_set_status(priv, QCA8K_CPU_PORT, 1);
+	priv->port_sts[QCA8K_CPU_PORT].enabled = 1;
+
+	/* Enable MIB counters */
+	qca8k_mib_init(priv);
+
+	/* Enable QCA header mode on the cpu port */
+	qca8k_write(priv, QCA8K_REG_PORT_HDR_CTRL(QCA8K_CPU_PORT),
+		    QCA8K_PORT_HDR_CTRL_ALL << QCA8K_PORT_HDR_CTRL_TX_S |
+		    QCA8K_PORT_HDR_CTRL_ALL << QCA8K_PORT_HDR_CTRL_RX_S);
+
+	/* Disable forwarding by default on all ports */
+	for (i = 0; i < QCA8K_NUM_PORTS; i++)
+		qca8k_rmw(priv, QCA8K_PORT_LOOKUP_CTRL(i),
+			  QCA8K_PORT_LOOKUP_MEMBER, 0);
+
+	/* Disable MAC by default on all user ports */
+	for (i = 1; i < QCA8K_NUM_PORTS; i++)
+		if (ds->enabled_port_mask & BIT(i))
+			qca8k_port_set_status(priv, i, 0);
+
+	/* Forward all unknown frames to CPU port for Linux processing */
+	qca8k_write(priv, QCA8K_REG_GLOBAL_FW_CTRL1,
+		    BIT(0) << QCA8K_GLOBAL_FW_CTRL1_IGMP_DP_S |
+		    BIT(0) << QCA8K_GLOBAL_FW_CTRL1_BC_DP_S |
+		    BIT(0) << QCA8K_GLOBAL_FW_CTRL1_MC_DP_S |
+		    BIT(0) << QCA8K_GLOBAL_FW_CTRL1_UC_DP_S);
+
+	/* Setup connection between CPU port & user ports */
+	for (i = 0; i < DSA_MAX_PORTS; i++) {
+		/* CPU port gets connected to all user ports of the switch */
+		if (dsa_is_cpu_port(ds, i)) {
+			qca8k_rmw(priv, QCA8K_PORT_LOOKUP_CTRL(QCA8K_CPU_PORT),
+				  QCA8K_PORT_LOOKUP_MEMBER,
+				  ds->enabled_port_mask);
+		}
+
+		/* Invividual user ports get connected to CPU port only */
+		if (ds->enabled_port_mask & BIT(i)) {
+			int shift = 16 * (i % 2);
+
+			qca8k_rmw(priv, QCA8K_PORT_LOOKUP_CTRL(i),
+				  QCA8K_PORT_LOOKUP_MEMBER,
+				  BIT(QCA8K_CPU_PORT));
+
+			/* Enable ARP Auto-learning by default */
+			qca8k_reg_set(priv, QCA8K_PORT_LOOKUP_CTRL(i),
+				      QCA8K_PORT_LOOKUP_LEARN);
+
+			/* For port based vlans to work we need to set the
+			 * default egress vid
+			 */
+			qca8k_rmw(priv, QCA8K_EGRESS_VLAN(i),
+				  0xffff << shift, 1 << shift);
+			qca8k_write(priv, QCA8K_REG_PORT_VLAN_CTRL0(i),
+				    QCA8K_PORT_VLAN_CVID(1) |
+				    QCA8K_PORT_VLAN_SVID(1));
+		}
+	}
+
+	/* Flush the FDB table */
+	qca8k_fdb_flush(priv);
+
+	return 0;
+}
+
+static int
+qca8k_set_addr(struct dsa_switch *ds, u8 *addr)
+{
+	/* The subsystem always calls this function so add an empty stub */
+	return 0;
+}
+
+static int
+qca8k_phy_read(struct dsa_switch *ds, int phy, int regnum)
+{
+	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
+
+	return mdiobus_read(priv->bus, phy, regnum);
+}
+
+static int
+qca8k_phy_write(struct dsa_switch *ds, int phy, int regnum, u16 val)
+{
+	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
+
+	return mdiobus_write(priv->bus, phy, regnum, val);
+}
+
+static void
+qca8k_get_strings(struct dsa_switch *ds, int port, uint8_t *data)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(ar8327_mib); i++)
+		strncpy(data + i * ETH_GSTRING_LEN, ar8327_mib[i].name,
+			ETH_GSTRING_LEN);
+}
+
+static void
+qca8k_get_ethtool_stats(struct dsa_switch *ds, int port,
+			uint64_t *data)
+{
+	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
+	const struct qca8k_mib_desc *mib;
+	u32 reg, i;
+	u64 hi;
+
+	for (i = 0; i < ARRAY_SIZE(ar8327_mib); i++) {
+		mib = &ar8327_mib[i];
+		reg = QCA8K_PORT_MIB_COUNTER(port) + mib->offset;
+
+		data[i] = qca8k_read(priv, reg);
+		if (mib->size == 2) {
+			hi = qca8k_read(priv, reg + 4);
+			data[i] |= hi << 32;
+		}
+	}
+}
+
+static int
+qca8k_get_sset_count(struct dsa_switch *ds)
+{
+	return ARRAY_SIZE(ar8327_mib);
+}
+
+static void
+qca8k_eee_enable_set(struct dsa_switch *ds, int port, bool enable)
+{
+	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
+	u32 lpi_en = QCA8K_REG_EEE_CTRL_LPI_EN(port);
+	u32 reg;
+
+	mutex_lock(&priv->reg_mutex);
+	reg = qca8k_read(priv, QCA8K_REG_EEE_CTRL);
+	if (enable)
+		reg |= lpi_en;
+	else
+		reg &= ~lpi_en;
+	qca8k_write(priv, QCA8K_REG_EEE_CTRL, reg);
+	mutex_unlock(&priv->reg_mutex);
+}
+
+static int
+qca8k_eee_init(struct dsa_switch *ds, int port,
+	       struct phy_device *phy)
+{
+	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
+	struct ethtool_eee *p = &priv->port_sts[port].eee;
+	int ret;
+
+	p->supported = (SUPPORTED_1000baseT_Full | SUPPORTED_100baseT_Full);
+
+	ret = phy_init_eee(phy, 0);
+	if (ret)
+		return ret;
+
+	qca8k_eee_enable_set(ds, port, true);
+
+	return 0;
+}
+
+static int
+qca8k_set_eee(struct dsa_switch *ds, int port,
+	      struct phy_device *phydev,
+	      struct ethtool_eee *e)
+{
+	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
+	struct ethtool_eee *p = &priv->port_sts[port].eee;
+	int ret = 0;
+
+	p->eee_enabled = e->eee_enabled;
+
+	if (e->eee_enabled) {
+		p->eee_enabled = qca8k_eee_init(ds, port, phydev);
+		if (!p->eee_enabled)
+			ret = -EOPNOTSUPP;
+	}
+	qca8k_eee_enable_set(ds, port, p->eee_enabled);
+
+	return ret;
+}
+
+static int
+qca8k_get_eee(struct dsa_switch *ds, int port,
+	      struct ethtool_eee *e)
+{
+	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
+	struct ethtool_eee *p = &priv->port_sts[port].eee;
+	struct net_device *netdev = ds->ports[port].netdev;
+	int ret;
+
+	ret = phy_ethtool_get_eee(netdev->phydev, p);
+	if (!ret)
+		e->eee_active =
+			!!(p->supported & p->advertised & p->lp_advertised);
+	else
+		e->eee_active = 0;
+
+	e->eee_enabled = p->eee_enabled;
+
+	return ret;
+}
+
+static void
+qca8k_port_stp_state_set(struct dsa_switch *ds, int port, u8 state)
+{
+	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
+	u32 stp_state;
+
+	switch (state) {
+	case BR_STATE_DISABLED:
+		stp_state = QCA8K_PORT_LOOKUP_STATE_DISABLED;
+		break;
+	case BR_STATE_BLOCKING:
+		stp_state = QCA8K_PORT_LOOKUP_STATE_BLOCKING;
+		break;
+	case BR_STATE_LISTENING:
+		stp_state = QCA8K_PORT_LOOKUP_STATE_LISTENING;
+		break;
+	case BR_STATE_LEARNING:
+		stp_state = QCA8K_PORT_LOOKUP_STATE_LEARNING;
+		break;
+	case BR_STATE_FORWARDING:
+	default:
+		stp_state = QCA8K_PORT_LOOKUP_STATE_FORWARD;
+		break;
+	}
+
+	qca8k_rmw(priv, QCA8K_PORT_LOOKUP_CTRL(port),
+		  QCA8K_PORT_LOOKUP_STATE_MASK, stp_state);
+}
+
+static int
+qca8k_port_bridge_join(struct dsa_switch *ds, int port,
+		       struct net_device *bridge)
+{
+	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
+	int port_mask = BIT(QCA8K_CPU_PORT);
+	int i;
+
+	priv->port_sts[port].bridge_dev = bridge;
+
+	for (i = 1; i < QCA8K_NUM_PORTS; i++) {
+		if (priv->port_sts[i].bridge_dev != bridge)
+			continue;
+		/* Add this port to the portvlan mask of the other ports
+		 * in the bridge
+		 */
+		qca8k_reg_set(priv,
+			      QCA8K_PORT_LOOKUP_CTRL(i),
+			      BIT(port));
+		if (i != port)
+			port_mask |= BIT(i);
+	}
+	/* Add all other ports to this ports portvlan mask */
+	qca8k_rmw(priv, QCA8K_PORT_LOOKUP_CTRL(port),
+		  QCA8K_PORT_LOOKUP_MEMBER, port_mask);
+
+	return 0;
+}
+
+static void
+qca8k_port_bridge_leave(struct dsa_switch *ds, int port)
+{
+	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
+	int i;
+
+	for (i = 1; i < QCA8K_NUM_PORTS; i++) {
+		if (priv->port_sts[i].bridge_dev !=
+		    priv->port_sts[port].bridge_dev)
+			continue;
+		/* Remove this port to the portvlan mask of the other ports
+		 * in the bridge
+		 */
+		qca8k_reg_clear(priv,
+				QCA8K_PORT_LOOKUP_CTRL(i),
+				BIT(port));
+	}
+	priv->port_sts[port].bridge_dev = NULL;
+	/* Set the cpu port to be the only one in the portvlan mask of
+	 * this port
+	 */
+	qca8k_rmw(priv, QCA8K_PORT_LOOKUP_CTRL(port),
+		  QCA8K_PORT_LOOKUP_MEMBER, BIT(QCA8K_CPU_PORT));
+}
+
+static int
+qca8k_port_enable(struct dsa_switch *ds, int port,
+		  struct phy_device *phy)
+{
+	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
+
+	qca8k_port_set_status(priv, port, 1);
+	priv->port_sts[port].enabled = 1;
+
+	return 0;
+}
+
+static void
+qca8k_port_disable(struct dsa_switch *ds, int port,
+		   struct phy_device *phy)
+{
+	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
+
+	qca8k_port_set_status(priv, port, 0);
+	priv->port_sts[port].enabled = 0;
+}
+
+static int
+qca8k_port_fdb_insert(struct qca8k_priv *priv, const u8 *addr,
+		      u16 port_mask, u16 vid)
+{
+	/* Set the vid to the port vlan id if no vid is set */
+	if (!vid)
+		vid = 1;
+
+	return qca8k_fdb_add(priv, addr, port_mask, vid,
+			     QCA8K_ATU_STATUS_STATIC);
+}
+
+static int
+qca8k_port_fdb_prepare(struct dsa_switch *ds, int port,
+		       const struct switchdev_obj_port_fdb *fdb,
+		       struct switchdev_trans *trans)
+{
+	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
+
+	/* The FDB table for static and auto learned entries is the same. We
+	 * need to reserve an entry with no port_mask set to make sure that
+	 * when port_fdb_add is called an entry is still available. Otherwise
+	 * the last free entry might have been used up by auto learning
+	 */
+	return qca8k_port_fdb_insert(priv, fdb->addr, 0, fdb->vid);
+}
+
+static void
+qca8k_port_fdb_add(struct dsa_switch *ds, int port,
+		   const struct switchdev_obj_port_fdb *fdb,
+		   struct switchdev_trans *trans)
+{
+	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
+	u16 port_mask = BIT(port);
+
+	/* Update the FDB entry adding the port_mask */
+	qca8k_port_fdb_insert(priv, fdb->addr, port_mask, fdb->vid);
+}
+
+static int
+qca8k_port_fdb_del(struct dsa_switch *ds, int port,
+		   const struct switchdev_obj_port_fdb *fdb)
+{
+	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
+	u16 port_mask = BIT(port);
+	u16 vid = fdb->vid;
+
+	if (!vid)
+		vid = 1;
+
+	return qca8k_fdb_del(priv, fdb->addr, port_mask, vid);
+}
+
+static int
+qca8k_port_fdb_dump(struct dsa_switch *ds, int port,
+		    struct switchdev_obj_port_fdb *fdb,
+		    int (*cb)(struct switchdev_obj *obj))
+{
+	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
+	struct qca8k_fdb _fdb = { 0 };
+	int cnt = QCA8K_NUM_FDB_RECORDS;
+	int ret = 0;
+
+	mutex_lock(&priv->reg_mutex);
+	while (cnt-- && !qca8k_fdb_next(priv, &_fdb, port)) {
+		if (!_fdb.aging)
+			break;
+
+		ether_addr_copy(fdb->addr, _fdb.mac);
+		fdb->vid = _fdb.vid;
+		if (_fdb.aging == QCA8K_ATU_STATUS_STATIC)
+			fdb->ndm_state = NUD_NOARP;
+		else
+			fdb->ndm_state = NUD_REACHABLE;
+
+		ret = cb(&fdb->obj);
+		if (ret)
+			break;
+	}
+	mutex_unlock(&priv->reg_mutex);
+
+	return 0;
+}
+
+static enum dsa_tag_protocol
+qca8k_get_tag_protocol(struct dsa_switch *ds)
+{
+	return DSA_TAG_PROTO_QCA;
+}
+
+static struct dsa_switch_ops qca8k_switch_ops = {
+	.get_tag_protocol	= qca8k_get_tag_protocol,
+	.setup			= qca8k_setup,
+	.set_addr		= qca8k_set_addr,
+	.get_strings		= qca8k_get_strings,
+	.phy_read		= qca8k_phy_read,
+	.phy_write		= qca8k_phy_write,
+	.get_ethtool_stats	= qca8k_get_ethtool_stats,
+	.get_sset_count		= qca8k_get_sset_count,
+	.get_eee		= qca8k_get_eee,
+	.set_eee		= qca8k_set_eee,
+	.port_enable		= qca8k_port_enable,
+	.port_disable		= qca8k_port_disable,
+	.port_stp_state_set	= qca8k_port_stp_state_set,
+	.port_bridge_join	= qca8k_port_bridge_join,
+	.port_bridge_leave	= qca8k_port_bridge_leave,
+	.port_fdb_prepare	= qca8k_port_fdb_prepare,
+	.port_fdb_add		= qca8k_port_fdb_add,
+	.port_fdb_del		= qca8k_port_fdb_del,
+	.port_fdb_dump		= qca8k_port_fdb_dump,
+};
+
+static int
+qca8k_sw_probe(struct mdio_device *mdiodev)
+{
+	struct qca8k_priv *priv;
+	u32 id;
+
+	/* allocate the private data struct so that we can probe the switches
+	 * ID register
+	 */
+	priv = devm_kzalloc(&mdiodev->dev, sizeof(*priv), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
+	priv->bus = mdiodev->bus;
+
+	/* read the switches ID register */
+	id = qca8k_read(priv, QCA8K_REG_MASK_CTRL);
+	id >>= QCA8K_MASK_CTRL_ID_S;
+	id &= QCA8K_MASK_CTRL_ID_M;
+	if (id != QCA8K_ID_QCA8337)
+		return -ENODEV;
+
+	priv->ds = devm_kzalloc(&mdiodev->dev, sizeof(*priv->ds), GFP_KERNEL);
+	if (!priv->ds)
+		return -ENOMEM;
+
+	priv->ds->priv = priv;
+	priv->ds->dev = &mdiodev->dev;
+	priv->ds->ops = &qca8k_switch_ops;
+	mutex_init(&priv->reg_mutex);
+	dev_set_drvdata(&mdiodev->dev, priv);
+
+	return dsa_register_switch(priv->ds, priv->ds->dev->of_node);
+}
+
+static void
+qca8k_sw_remove(struct mdio_device *mdiodev)
+{
+	struct qca8k_priv *priv = dev_get_drvdata(&mdiodev->dev);
+	int i;
+
+	for (i = 0; i < QCA8K_NUM_PORTS; i++)
+		qca8k_port_set_status(priv, i, 0);
+
+	dsa_unregister_switch(priv->ds);
+}
+
+#ifdef CONFIG_PM_SLEEP
+static void
+qca8k_set_pm(struct qca8k_priv *priv, int enable)
+{
+	int i;
+
+	for (i = 0; i < QCA8K_NUM_PORTS; i++) {
+		if (!priv->port_sts[i].enabled)
+			continue;
+
+		qca8k_port_set_status(priv, i, enable);
+	}
+}
+
+static int qca8k_suspend(struct device *dev)
+{
+	struct platform_device *pdev = to_platform_device(dev);
+	struct qca8k_priv *priv = platform_get_drvdata(pdev);
+
+	qca8k_set_pm(priv, 0);
+
+	return dsa_switch_suspend(priv->ds);
+}
+
+static int qca8k_resume(struct device *dev)
+{
+	struct platform_device *pdev = to_platform_device(dev);
+	struct qca8k_priv *priv = platform_get_drvdata(pdev);
+
+	qca8k_set_pm(priv, 1);
+
+	return dsa_switch_resume(priv->ds);
+}
+#endif /* CONFIG_PM_SLEEP */
+
+static SIMPLE_DEV_PM_OPS(qca8k_pm_ops,
+			 qca8k_suspend, qca8k_resume);
+
+static const struct of_device_id qca8k_of_match[] = {
+	{ .compatible = "qca,qca8337" },
+	{ /* sentinel */ },
+};
+
+static struct mdio_driver qca8kmdio_driver = {
+	.probe  = qca8k_sw_probe,
+	.remove = qca8k_sw_remove,
+	.mdiodrv.driver = {
+		.name = "qca8k",
+		.of_match_table = qca8k_of_match,
+		.pm = &qca8k_pm_ops,
+	},
+};
+
+static int __init
+qca8kmdio_driver_register(void)
+{
+	return mdio_driver_register(&qca8kmdio_driver);
+}
+module_init(qca8kmdio_driver_register);
+
+static void __exit
+qca8kmdio_driver_unregister(void)
+{
+	mdio_driver_unregister(&qca8kmdio_driver);
+}
+module_exit(qca8kmdio_driver_unregister);
+
+MODULE_AUTHOR("Mathieu Olivari, John Crispin <john@phrozen.org>");
+MODULE_DESCRIPTION("Driver for QCA8K ethernet switch family");
+MODULE_LICENSE("GPL v2");
+MODULE_ALIAS("platform:qca8k");
diff --git a/drivers/net/dsa/qca8k.h b/drivers/net/dsa/qca8k.h
new file mode 100644
index 0000000..2014647
--- /dev/null
+++ b/drivers/net/dsa/qca8k.h
@@ -0,0 +1,185 @@
+/*
+ * Copyright (C) 2009 Felix Fietkau <nbd@nbd.name>
+ * Copyright (C) 2011-2012 Gabor Juhos <juhosg@openwrt.org>
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
+#ifndef __QCA8K_H
+#define __QCA8K_H
+
+#include <linux/delay.h>
+#include <linux/regmap.h>
+
+#define QCA8K_NUM_PORTS					7
+
+#define PHY_ID_QCA8337					0x004dd036
+#define QCA8K_ID_QCA8337				0x13
+
+#define QCA8K_NUM_FDB_RECORDS				2048
+
+#define QCA8K_CPU_PORT					0
+
+/* Global control registers */
+#define QCA8K_REG_MASK_CTRL				0x000
+#define   QCA8K_MASK_CTRL_ID_M				0xff
+#define   QCA8K_MASK_CTRL_ID_S				8
+#define QCA8K_REG_PORT0_PAD_CTRL			0x004
+#define QCA8K_REG_PORT5_PAD_CTRL			0x008
+#define QCA8K_REG_PORT6_PAD_CTRL			0x00c
+#define   QCA8K_PORT_PAD_RGMII_EN			BIT(26)
+#define   QCA8K_PORT_PAD_RGMII_TX_DELAY(x)		\
+						((0x8 + (x & 0x3)) << 22)
+#define   QCA8K_PORT_PAD_RGMII_RX_DELAY(x)		\
+						((0x10 + (x & 0x3)) << 20)
+#define   QCA8K_PORT_PAD_RGMII_RX_DELAY_EN		BIT(24)
+#define   QCA8K_PORT_PAD_SGMII_EN			BIT(7)
+#define QCA8K_REG_MODULE_EN				0x030
+#define   QCA8K_MODULE_EN_MIB				BIT(0)
+#define QCA8K_REG_MIB					0x034
+#define   QCA8K_MIB_FLUSH				BIT(24)
+#define   QCA8K_MIB_CPU_KEEP				BIT(20)
+#define   QCA8K_MIB_BUSY				BIT(17)
+#define QCA8K_GOL_MAC_ADDR0				0x60
+#define QCA8K_GOL_MAC_ADDR1				0x64
+#define QCA8K_REG_PORT_STATUS(_i)			(0x07c + (_i) * 4)
+#define   QCA8K_PORT_STATUS_SPEED			GENMASK(2, 0)
+#define   QCA8K_PORT_STATUS_SPEED_S			0
+#define   QCA8K_PORT_STATUS_TXMAC			BIT(2)
+#define   QCA8K_PORT_STATUS_RXMAC			BIT(3)
+#define   QCA8K_PORT_STATUS_TXFLOW			BIT(4)
+#define   QCA8K_PORT_STATUS_RXFLOW			BIT(5)
+#define   QCA8K_PORT_STATUS_DUPLEX			BIT(6)
+#define   QCA8K_PORT_STATUS_LINK_UP			BIT(8)
+#define   QCA8K_PORT_STATUS_LINK_AUTO			BIT(9)
+#define   QCA8K_PORT_STATUS_LINK_PAUSE			BIT(10)
+#define QCA8K_REG_PORT_HDR_CTRL(_i)			(0x9c + (_i * 4))
+#define   QCA8K_PORT_HDR_CTRL_RX_MASK			GENMASK(3, 2)
+#define   QCA8K_PORT_HDR_CTRL_RX_S			2
+#define   QCA8K_PORT_HDR_CTRL_TX_MASK			GENMASK(1, 0)
+#define   QCA8K_PORT_HDR_CTRL_TX_S			0
+#define   QCA8K_PORT_HDR_CTRL_ALL			2
+#define   QCA8K_PORT_HDR_CTRL_MGMT			1
+#define   QCA8K_PORT_HDR_CTRL_NONE			0
+
+/* EEE control registers */
+#define QCA8K_REG_EEE_CTRL				0x100
+#define  QCA8K_REG_EEE_CTRL_LPI_EN(_i)			((_i + 1) * 2)
+
+/* ACL registers */
+#define QCA8K_REG_PORT_VLAN_CTRL0(_i)			(0x420 + (_i * 8))
+#define   QCA8K_PORT_VLAN_CVID(x)			(x << 16)
+#define   QCA8K_PORT_VLAN_SVID(x)			x
+#define QCA8K_REG_PORT_VLAN_CTRL1(_i)			(0x424 + (_i * 8))
+#define QCA8K_REG_IPV4_PRI_BASE_ADDR			0x470
+#define QCA8K_REG_IPV4_PRI_ADDR_MASK			0x474
+
+/* Lookup registers */
+#define QCA8K_REG_ATU_DATA0				0x600
+#define   QCA8K_ATU_ADDR2_S				24
+#define   QCA8K_ATU_ADDR3_S				16
+#define   QCA8K_ATU_ADDR4_S				8
+#define QCA8K_REG_ATU_DATA1				0x604
+#define   QCA8K_ATU_PORT_M				0x7f
+#define   QCA8K_ATU_PORT_S				16
+#define   QCA8K_ATU_ADDR0_S				8
+#define QCA8K_REG_ATU_DATA2				0x608
+#define   QCA8K_ATU_VID_M				0xfff
+#define   QCA8K_ATU_VID_S				8
+#define   QCA8K_ATU_STATUS_M				0xf
+#define   QCA8K_ATU_STATUS_STATIC			0xf
+#define QCA8K_REG_ATU_FUNC				0x60c
+#define   QCA8K_ATU_FUNC_BUSY				BIT(31)
+#define   QCA8K_ATU_FUNC_PORT_EN			BIT(14)
+#define   QCA8K_ATU_FUNC_MULTI_EN			BIT(13)
+#define   QCA8K_ATU_FUNC_FULL				BIT(12)
+#define   QCA8K_ATU_FUNC_PORT_M				0xf
+#define   QCA8K_ATU_FUNC_PORT_S				8
+#define QCA8K_REG_GLOBAL_FW_CTRL0			0x620
+#define   QCA8K_GLOBAL_FW_CTRL0_CPU_PORT_EN		BIT(10)
+#define QCA8K_REG_GLOBAL_FW_CTRL1			0x624
+#define   QCA8K_GLOBAL_FW_CTRL1_IGMP_DP_S		24
+#define   QCA8K_GLOBAL_FW_CTRL1_BC_DP_S			16
+#define   QCA8K_GLOBAL_FW_CTRL1_MC_DP_S			8
+#define   QCA8K_GLOBAL_FW_CTRL1_UC_DP_S			0
+#define QCA8K_PORT_LOOKUP_CTRL(_i)			(0x660 + (_i) * 0xc)
+#define   QCA8K_PORT_LOOKUP_MEMBER			GENMASK(6, 0)
+#define   QCA8K_PORT_LOOKUP_STATE_MASK			GENMASK(18, 16)
+#define   QCA8K_PORT_LOOKUP_STATE_DISABLED		(0 << 16)
+#define   QCA8K_PORT_LOOKUP_STATE_BLOCKING		(1 << 16)
+#define   QCA8K_PORT_LOOKUP_STATE_LISTENING		(2 << 16)
+#define   QCA8K_PORT_LOOKUP_STATE_LEARNING		(3 << 16)
+#define   QCA8K_PORT_LOOKUP_STATE_FORWARD		(4 << 16)
+#define   QCA8K_PORT_LOOKUP_STATE			GENMASK(18, 16)
+#define   QCA8K_PORT_LOOKUP_LEARN			BIT(20)
+
+/* Pkt edit registers */
+#define QCA8K_EGRESS_VLAN(x)				(0x0c70 + (4 * (x / 2)))
+
+/* L3 registers */
+#define QCA8K_HROUTER_CONTROL				0xe00
+#define   QCA8K_HROUTER_CONTROL_GLB_LOCKTIME_M		GENMASK(17, 16)
+#define   QCA8K_HROUTER_CONTROL_GLB_LOCKTIME_S		16
+#define   QCA8K_HROUTER_CONTROL_ARP_AGE_MODE		1
+#define QCA8K_HROUTER_PBASED_CONTROL1			0xe08
+#define QCA8K_HROUTER_PBASED_CONTROL2			0xe0c
+#define QCA8K_HNAT_CONTROL				0xe38
+
+/* MIB registers */
+#define QCA8K_PORT_MIB_COUNTER(_i)			(0x1000 + (_i) * 0x100)
+
+/* QCA specific MII registers */
+#define MII_ATH_MMD_ADDR				0x0d
+#define MII_ATH_MMD_DATA				0x0e
+
+enum {
+	QCA8K_PORT_SPEED_10M = 0,
+	QCA8K_PORT_SPEED_100M = 1,
+	QCA8K_PORT_SPEED_1000M = 2,
+	QCA8K_PORT_SPEED_ERR = 3,
+};
+
+enum qca8k_fdb_cmd {
+	QCA8K_FDB_FLUSH	= 1,
+	QCA8K_FDB_LOAD = 2,
+	QCA8K_FDB_PURGE = 3,
+	QCA8K_FDB_NEXT = 6,
+	QCA8K_FDB_SEARCH = 7,
+};
+
+struct ar8xxx_port_status {
+	struct ethtool_eee eee;
+	struct net_device *bridge_dev;
+	int enabled;
+};
+
+struct qca8k_priv {
+	struct regmap *regmap;
+	struct mii_bus *bus;
+	struct ar8xxx_port_status port_sts[QCA8K_NUM_PORTS];
+	struct dsa_switch *ds;
+	struct mutex reg_mutex;
+};
+
+struct qca8k_mib_desc {
+	unsigned int size;
+	unsigned int offset;
+	const char *name;
+};
+
+struct qca8k_fdb {
+	u16 vid;
+	u8 port_mask;
+	u8 aging;
+	u8 mac[6];
+};
+
+#endif /* __QCA8K_H */
-- 
1.7.10.4
