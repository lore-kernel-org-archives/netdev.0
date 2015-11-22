From: John Crispin <blogic@openwrt.org>
Subject: [RFC 7/8] net-next: ralink: add support for mt7620 family
Date: Sun, 22 Nov 2015 09:40:57 +0100
Message-ID: <1448181658-38111-7-git-send-email-blogic@openwrt.org>
References: <1448181658-38111-1-git-send-email-blogic@openwrt.org>
Cc: netdev@vger.kernel.org, Michael Lee <igvtee@gmail.com>,
	Felix Fietkau <nbd@openwrt.org>,
	=?UTF-8?q?Steven=20Liu=20=28=E5=8A=89=E4=BA=BA=E8=B1=AA=29?=
	<steven.liu@mediatek.com>,
	=?UTF-8?q?Fred=20Chang=20=28=E5=BC=B5=E5=98=89=E5=AE=8F=29?=
	<Fred.Chang@mediatek.com>, John Crispin <blogic@openwrt.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:46198 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751394AbbKVIl3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Nov 2015 03:41:29 -0500
In-Reply-To: <1448181658-38111-1-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for SoCs from the mt7620 family. This include mt7620 and mt7621.
These all have one dedicated external gbit port and a builtin 5 port 100mbit
switch. Additionally one of the 5 switch ports can be changed to become an
additional gbit port that we can attach a phy to. This patch includes
rudimentary code to power up the switch. There are a lot of magic values
that get written to the switch and the internal phys. These values come
straight from the SDK driver.

Signed-off-by: John Crispin <blogic@openwrt.org>
Signed-off-by: Felix Fietkau <nbd@openwrt.org>
Signed-off-by: Michael Lee <igvtee@gmail.com>
---
 drivers/net/ethernet/ralink/gsw_mt7620.c |  784 ++++++++++++++++++++++++++++++
 drivers/net/ethernet/ralink/gsw_mt7620.h |   26 +
 drivers/net/ethernet/ralink/soc_mt7620.c |  273 +++++++++++
 3 files changed, 1083 insertions(+)
 create mode 100644 drivers/net/ethernet/ralink/gsw_mt7620.c
 create mode 100644 drivers/net/ethernet/ralink/gsw_mt7620.h
 create mode 100644 drivers/net/ethernet/ralink/soc_mt7620.c

diff --git a/drivers/net/ethernet/ralink/gsw_mt7620.c b/drivers/net/ethernet/ralink/gsw_mt7620.c
new file mode 100644
index 0000000..24bc312
--- /dev/null
+++ b/drivers/net/ethernet/ralink/gsw_mt7620.c
@@ -0,0 +1,784 @@
+/*   This program is free software; you can redistribute it and/or modify
+ *   it under the terms of the GNU General Public License as published by
+ *   the Free Software Foundation; version 2 of the License
+ *
+ *   This program is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *   GNU General Public License for more details.
+ *
+ *   Copyright (C) 2009-2015 John Crispin <blogic@openwrt.org>
+ *   Copyright (C) 2009-2015 Felix Fietkau <nbd@openwrt.org>
+ *   Copyright (C) 2013-2015 Michael Lee <igvtee@gmail.com>
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/dma-mapping.h>
+#include <linux/init.h>
+#include <linux/skbuff.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/platform_device.h>
+#include <linux/of_device.h>
+#include <linux/clk.h>
+#include <linux/of_net.h>
+#include <linux/of_mdio.h>
+#include <linux/of_irq.h>
+#include <linux/of_address.h>
+#include <linux/ioport.h>
+#include <linux/mii.h>
+
+#include <asm/mach-ralink/ralink_regs.h>
+
+#include "ralink_soc_eth.h"
+
+#include <ralink_regs.h>
+#include <asm/mach-ralink/mt7620.h>
+
+#include "ralink_soc_eth.h"
+#include "gsw_mt7620.h"
+#include "mdio.h"
+
+#define GSW_REG_PHY_TIMEOUT	(5 * HZ)
+
+#ifdef CONFIG_SOC_MT7621
+#define MT7620A_GSW_REG_PIAC	0x0004
+#else
+#define MT7620A_GSW_REG_PIAC	0x7004
+#endif
+
+#define GSW_NUM_VLANS		16
+#define GSW_NUM_VIDS		4096
+#define GSW_NUM_PORTS		7
+#define GSW_PORT6		6
+
+#define GSW_MDIO_ACCESS		BIT(31)
+#define GSW_MDIO_READ		BIT(19)
+#define GSW_MDIO_WRITE		BIT(18)
+#define GSW_MDIO_START		BIT(16)
+#define GSW_MDIO_ADDR_SHIFT	20
+#define GSW_MDIO_REG_SHIFT	25
+
+#define GSW_REG_PORT_PMCR(x)	(0x3000 + (x * 0x100))
+#define GSW_REG_PORT_STATUS(x)	(0x3008 + (x * 0x100))
+#define GSW_REG_SMACCR0		0x3fE4
+#define GSW_REG_SMACCR1		0x3fE8
+#define GSW_REG_CKGCR		0x3ff0
+
+#define GSW_REG_IMR		0x7008
+#define GSW_REG_ISR		0x700c
+#define GSW_REG_GPC1		0x7014
+
+#define SYSC_REG_CHIP_REV_ID	0x0c
+#define SYSC_REG_CFG1		0x14
+#define RST_CTRL_MCM		BIT(2)
+#define SYSC_PAD_RGMII2_MDIO	0x58
+#define SYSC_GPIO_MODE		0x60
+
+#define PORT_IRQ_ST_CHG		0x7f
+
+#ifdef CONFIG_SOC_MT7621
+#define ESW_PHY_POLLING		0x0000
+#else
+#define ESW_PHY_POLLING		0x7000
+#endif
+
+#define	PMCR_IPG		BIT(18)
+#define	PMCR_MAC_MODE		BIT(16)
+#define	PMCR_FORCE		BIT(15)
+#define	PMCR_TX_EN		BIT(14)
+#define	PMCR_RX_EN		BIT(13)
+#define	PMCR_BACKOFF		BIT(9)
+#define	PMCR_BACKPRES		BIT(8)
+#define	PMCR_RX_FC		BIT(5)
+#define	PMCR_TX_FC		BIT(4)
+#define	PMCR_SPEED(_x)		(_x << 2)
+#define	PMCR_DUPLEX		BIT(1)
+#define	PMCR_LINK		BIT(0)
+
+#define PHY_AN_EN		BIT(31)
+#define PHY_PRE_EN		BIT(30)
+#define PMY_MDC_CONF(_x)	((_x & 0x3f) << 24)
+
+enum {
+	/* Global attributes. */
+	GSW_ATTR_ENABLE_VLAN,
+	/* Port attributes. */
+	GSW_ATTR_PORT_UNTAG,
+};
+
+enum {
+	PORT4_EPHY = 0,
+	PORT4_EXT,
+};
+
+struct mt7620_gsw {
+	struct device		*dev;
+	void __iomem		*base;
+	int			irq;
+	int			port4;
+	unsigned long int	autopoll;
+};
+
+static inline void gsw_w32(struct mt7620_gsw *gsw, u32 val, unsigned reg)
+{
+	iowrite32(val, gsw->base + reg);
+}
+
+static inline u32 gsw_r32(struct mt7620_gsw *gsw, unsigned reg)
+{
+	return ioread32(gsw->base + reg);
+}
+
+static int mt7620_mii_busy_wait(struct mt7620_gsw *gsw)
+{
+	unsigned long t_start = jiffies;
+
+	while (1) {
+		if (!(gsw_r32(gsw, MT7620A_GSW_REG_PIAC) & GSW_MDIO_ACCESS))
+			return 0;
+		if (time_after(jiffies, t_start + GSW_REG_PHY_TIMEOUT))
+			break;
+	}
+
+	dev_err(gsw->dev, "mdio: MDIO timeout\n");
+	return -1;
+}
+
+static u32 _mt7620_mii_write(struct mt7620_gsw *gsw, u32 phy_addr,
+			     u32 phy_register, u32 write_data)
+{
+	if (mt7620_mii_busy_wait(gsw))
+		return -1;
+
+	write_data &= 0xffff;
+
+	gsw_w32(gsw, GSW_MDIO_ACCESS | GSW_MDIO_START | GSW_MDIO_WRITE |
+		(phy_register << GSW_MDIO_REG_SHIFT) |
+		(phy_addr << GSW_MDIO_ADDR_SHIFT) | write_data,
+		MT7620A_GSW_REG_PIAC);
+
+	if (mt7620_mii_busy_wait(gsw))
+		return -1;
+
+	return 0;
+}
+
+static u32 _mt7620_mii_read(struct mt7620_gsw *gsw, int phy_addr, int phy_reg)
+{
+	u32 d;
+
+	if (mt7620_mii_busy_wait(gsw))
+		return 0xffff;
+
+	gsw_w32(gsw, GSW_MDIO_ACCESS | GSW_MDIO_START | GSW_MDIO_READ |
+		(phy_reg << GSW_MDIO_REG_SHIFT) |
+		(phy_addr << GSW_MDIO_ADDR_SHIFT),
+		MT7620A_GSW_REG_PIAC);
+
+	if (mt7620_mii_busy_wait(gsw))
+		return 0xffff;
+
+	d = gsw_r32(gsw, MT7620A_GSW_REG_PIAC) & 0xffff;
+
+	return d;
+}
+
+int mt7620_mdio_write(struct mii_bus *bus, int phy_addr, int phy_reg, u16 val)
+{
+	struct fe_priv *priv = bus->priv;
+	struct mt7620_gsw *gsw = (struct mt7620_gsw *)priv->soc->swpriv;
+
+	return _mt7620_mii_write(gsw, phy_addr, phy_reg, val);
+}
+
+int mt7620_mdio_read(struct mii_bus *bus, int phy_addr, int phy_reg)
+{
+	struct fe_priv *priv = bus->priv;
+	struct mt7620_gsw *gsw = (struct mt7620_gsw *)priv->soc->swpriv;
+
+	return _mt7620_mii_read(gsw, phy_addr, phy_reg);
+}
+
+static void mt7530_mdio_w32(struct mt7620_gsw *gsw, u32 reg, u32 val)
+{
+	_mt7620_mii_write(gsw, 0x1f, 0x1f, (reg >> 6) & 0x3ff);
+	_mt7620_mii_write(gsw, 0x1f, (reg >> 2) & 0xf,  val & 0xffff);
+	_mt7620_mii_write(gsw, 0x1f, 0x10, val >> 16);
+}
+
+static u32 mt7530_mdio_r32(struct mt7620_gsw *gsw, u32 reg)
+{
+	u16 high, low;
+
+	_mt7620_mii_write(gsw, 0x1f, 0x1f, (reg >> 6) & 0x3ff);
+	low = _mt7620_mii_read(gsw, 0x1f, (reg >> 2) & 0xf);
+	high = _mt7620_mii_read(gsw, 0x1f, 0x10);
+
+	return (high << 16) | (low & 0xffff);
+}
+
+static unsigned char *fe_speed_str(int speed)
+{
+	switch (speed) {
+	case 2:
+	case SPEED_1000:
+		return "1000";
+	case 1:
+	case SPEED_100:
+		return "100";
+	case 0:
+	case SPEED_10:
+		return "10";
+	}
+
+	return "? ";
+}
+
+int mt7620a_has_carrier(struct fe_priv *priv)
+{
+	struct mt7620_gsw *gsw = (struct mt7620_gsw *)priv->soc->swpriv;
+	int i;
+
+	for (i = 0; i < GSW_PORT6; i++)
+		if (gsw_r32(gsw, GSW_REG_PORT_STATUS(i)) & 0x1)
+			return 1;
+	return 0;
+}
+
+static void mt7620_handle_carrier(struct fe_priv *priv)
+{
+	if (!priv->phy)
+		return;
+
+	if (mt7620a_has_carrier(priv))
+		netif_carrier_on(priv->netdev);
+	else
+		netif_carrier_off(priv->netdev);
+}
+
+static void mt7620_print_link_state(struct fe_priv *priv, int port, int link,
+				    int speed, int duplex)
+{
+	if (link)
+		netdev_info(priv->netdev, "port %d link up (%sMbps/%s duplex)\n",
+			    port, fe_speed_str(speed),
+			    (duplex) ? "Full" : "Half");
+	else
+		netdev_info(priv->netdev, "port %d link down\n", port);
+}
+
+void mt7620_mdio_link_adjust(struct fe_priv *priv, int port)
+{
+	mt7620_print_link_state(priv, port, priv->link[port],
+				priv->phy->speed[port],
+				(priv->phy->duplex[port] == DUPLEX_FULL));
+	mt7620_handle_carrier(priv);
+}
+
+static irqreturn_t gsw_interrupt_mt7620(int irq, void *_priv)
+{
+	struct fe_priv *priv = (struct fe_priv *)_priv;
+	struct mt7620_gsw *gsw = (struct mt7620_gsw *)priv->soc->swpriv;
+	u32 status;
+	int i, max = (gsw->port4 == PORT4_EPHY) ? (4) : (3);
+
+	status = gsw_r32(gsw, GSW_REG_ISR);
+	if (status & PORT_IRQ_ST_CHG)
+		for (i = 0; i <= max; i++) {
+			u32 status = gsw_r32(gsw, GSW_REG_PORT_STATUS(i));
+			int link = status & 0x1;
+
+			if (link != priv->link[i])
+				mt7620_print_link_state(priv, i, link,
+							(status >> 2) & 3,
+							(status & 0x2));
+
+			priv->link[i] = link;
+		}
+	mt7620_handle_carrier(priv);
+
+	gsw_w32(gsw, status, GSW_REG_ISR);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t gsw_interrupt_mt7621(int irq, void *_priv)
+{
+	struct fe_priv *priv = (struct fe_priv *)_priv;
+	struct mt7620_gsw *gsw = (struct mt7620_gsw *)priv->soc->swpriv;
+	u32 reg, i;
+
+	reg = mt7530_mdio_r32(gsw, 0x700c);
+
+	for (i = 0; i < 5; i++)
+		if (reg & BIT(i)) {
+			unsigned int link;
+
+			link = mt7530_mdio_r32(gsw,
+					       0x3008 + (i * 0x100)) & 0x1;
+
+			if (link != priv->link[i]) {
+				priv->link[i] = link;
+				if (link)
+					netdev_info(priv->netdev,
+						    "port %d link up\n", i);
+				else
+					netdev_info(priv->netdev,
+						    "port %d link down\n", i);
+			}
+		}
+
+	mt7620_handle_carrier(priv);
+	mt7530_mdio_w32(gsw, 0x700c, 0x1f);
+
+	return IRQ_HANDLED;
+}
+
+static int mt7620_is_bga(void)
+{
+	u32 bga = rt_sysc_r32(0x0c);
+
+	return (bga >> 16) & 1;
+}
+
+static void gsw_auto_poll(struct mt7620_gsw *gsw)
+{
+	int phy;
+	int lsb = -1, msb = 0;
+
+	for_each_set_bit(phy, &gsw->autopoll, 32) {
+		if (lsb < 0)
+			lsb = phy;
+		msb = phy;
+	}
+
+	if (lsb == msb)
+		lsb--;
+
+	gsw_w32(gsw, PHY_AN_EN | PHY_PRE_EN | PMY_MDC_CONF(5) |
+		(msb << 8) | lsb, ESW_PHY_POLLING);
+}
+
+void mt7620_port_init(struct fe_priv *priv, struct device_node *np)
+{
+	struct mt7620_gsw *gsw = (struct mt7620_gsw *)priv->soc->swpriv;
+	const __be32 *_id = of_get_property(np, "reg", NULL);
+	int phy_mode, size, id;
+	int shift = 12;
+	u32 val, mask = 0;
+	int min = (gsw->port4 == PORT4_EPHY) ? (5) : (4);
+
+	if (!_id || (be32_to_cpu(*_id) < min) || (be32_to_cpu(*_id) > 5)) {
+		if (_id)
+			pr_err("%s: invalid port id %d\n", np->name,
+			       be32_to_cpu(*_id));
+		else
+			pr_err("%s: invalid port id\n", np->name);
+		return;
+	}
+
+	id = be32_to_cpu(*_id);
+
+	if (id == 4)
+		shift = 14;
+
+	priv->phy->phy_fixed[id] = of_get_property(np, "ralink,fixed-link",
+						   &size);
+	if (priv->phy->phy_fixed[id] &&
+	    (size != (4 * sizeof(*priv->phy->phy_fixed[id])))) {
+		pr_err("%s: invalid fixed link property\n", np->name);
+		priv->phy->phy_fixed[id] = NULL;
+		return;
+	}
+
+	phy_mode = of_get_phy_mode(np);
+	switch (phy_mode) {
+	case PHY_INTERFACE_MODE_RGMII:
+		mask = 0;
+		break;
+	case PHY_INTERFACE_MODE_MII:
+		mask = 1;
+		break;
+	case PHY_INTERFACE_MODE_RMII:
+		mask = 2;
+		break;
+	default:
+		dev_err(priv->device, "port %d - invalid phy mode\n", id);
+		return;
+	}
+
+	priv->phy->phy_node[id] = of_parse_phandle(np, "phy-handle", 0);
+	if (!priv->phy->phy_node[id] && !priv->phy->phy_fixed[id])
+		return;
+
+	val = rt_sysc_r32(SYSC_REG_CFG1);
+	val &= ~(3 << shift);
+	val |= mask << shift;
+	rt_sysc_w32(val, SYSC_REG_CFG1);
+
+	if (priv->phy->phy_fixed[id]) {
+		const __be32 *link = priv->phy->phy_fixed[id];
+		int tx_fc, rx_fc;
+		u32 val = 0;
+
+		priv->phy->speed[id] = be32_to_cpup(link++);
+		tx_fc = be32_to_cpup(link++);
+		rx_fc = be32_to_cpup(link++);
+		priv->phy->duplex[id] = be32_to_cpup(link++);
+		priv->link[id] = 1;
+
+		switch (priv->phy->speed[id]) {
+		case SPEED_10:
+			val = 0;
+			break;
+		case SPEED_100:
+			val = 1;
+			break;
+		case SPEED_1000:
+			val = 2;
+			break;
+		default:
+			dev_err(priv->device, "invalid link speed: %d\n",
+				priv->phy->speed[id]);
+			priv->phy->phy_fixed[id] = 0;
+			return;
+		}
+		val = PMCR_SPEED(val);
+		val |= PMCR_LINK | PMCR_BACKPRES | PMCR_BACKOFF | PMCR_RX_EN |
+			PMCR_TX_EN | PMCR_FORCE | PMCR_MAC_MODE | PMCR_IPG;
+		if (tx_fc)
+			val |= PMCR_TX_FC;
+		if (rx_fc)
+			val |= PMCR_RX_FC;
+		if (priv->phy->duplex[id])
+			val |= PMCR_DUPLEX;
+		gsw_w32(gsw, val, GSW_REG_PORT_PMCR(id));
+		dev_info(priv->device, "using fixed link parameters\n");
+		return;
+	}
+
+	if (priv->phy->phy_node[id] && priv->mii_bus->phy_map[id]) {
+		u32 val = PMCR_BACKPRES | PMCR_BACKOFF | PMCR_RX_EN |
+			PMCR_TX_EN |  PMCR_MAC_MODE | PMCR_IPG;
+
+		gsw_w32(gsw, val, GSW_REG_PORT_PMCR(id));
+		fe_connect_phy_node(priv, priv->phy->phy_node[id]);
+		gsw->autopoll |= BIT(id);
+		gsw_auto_poll(gsw);
+		return;
+	}
+}
+
+static void gsw_hw_init_mt7620(struct mt7620_gsw *gsw, struct device_node *np)
+{
+	u32 is_BGA = mt7620_is_bga();
+
+	rt_sysc_w32(rt_sysc_r32(SYSC_REG_CFG1) | BIT(8), SYSC_REG_CFG1);
+	gsw_w32(gsw, gsw_r32(gsw, GSW_REG_CKGCR) & ~(0x3 << 4), GSW_REG_CKGCR);
+
+	if (of_property_read_bool(np, "mediatek,mt7530")) {
+		u32 val;
+
+		/* turn off ephy and set phy base addr to 12 */
+		gsw_w32(gsw, gsw_r32(gsw, GSW_REG_GPC1) |
+			(0x1f << 24) | (0xc << 16),
+			GSW_REG_GPC1);
+
+		/* set MT7530 central align */
+		val = mt7530_mdio_r32(gsw, 0x7830);
+		val &= ~BIT(0);
+		val |= BIT(1);
+		mt7530_mdio_w32(gsw, 0x7830, val);
+
+		val = mt7530_mdio_r32(gsw, 0x7a40);
+		val &= ~BIT(30);
+		mt7530_mdio_w32(gsw, 0x7a40, val);
+
+		mt7530_mdio_w32(gsw, 0x7a78, 0x855);
+	} else {
+		/* EPHY1 fixup - only run if the ephy is enabled */
+
+		/* global page 4 */
+		_mt7620_mii_write(gsw, 1, 31, 0x4000);
+
+		_mt7620_mii_write(gsw, 1, 17, 0x7444);
+		if (is_BGA)
+			_mt7620_mii_write(gsw, 1, 19, 0x0114);
+		else
+			_mt7620_mii_write(gsw, 1, 19, 0x0117);
+
+		_mt7620_mii_write(gsw, 1, 22, 0x10cf);
+		_mt7620_mii_write(gsw, 1, 25, 0x6212);
+		_mt7620_mii_write(gsw, 1, 26, 0x0777);
+		_mt7620_mii_write(gsw, 1, 29, 0x4000);
+		_mt7620_mii_write(gsw, 1, 28, 0xc077);
+		_mt7620_mii_write(gsw, 1, 24, 0x0000);
+
+		/* global page 3 */
+		_mt7620_mii_write(gsw, 1, 31, 0x3000);
+		_mt7620_mii_write(gsw, 1, 17, 0x4838);
+
+		/* global page 2 */
+		_mt7620_mii_write(gsw, 1, 31, 0x2000);
+		if (is_BGA) {
+			_mt7620_mii_write(gsw, 1, 21, 0x0515);
+			_mt7620_mii_write(gsw, 1, 22, 0x0053);
+			_mt7620_mii_write(gsw, 1, 23, 0x00bf);
+			_mt7620_mii_write(gsw, 1, 24, 0x0aaf);
+			_mt7620_mii_write(gsw, 1, 25, 0x0fad);
+			_mt7620_mii_write(gsw, 1, 26, 0x0fc1);
+		} else {
+			_mt7620_mii_write(gsw, 1, 21, 0x0517);
+			_mt7620_mii_write(gsw, 1, 22, 0x0fd2);
+			_mt7620_mii_write(gsw, 1, 23, 0x00bf);
+			_mt7620_mii_write(gsw, 1, 24, 0x0aab);
+			_mt7620_mii_write(gsw, 1, 25, 0x00ae);
+			_mt7620_mii_write(gsw, 1, 26, 0x0fff);
+		}
+		/* global page 1 */
+		_mt7620_mii_write(gsw, 1, 31, 0x1000);
+		_mt7620_mii_write(gsw, 1, 17, 0xe7f8);
+	}
+
+	/* global page 0 */
+	_mt7620_mii_write(gsw, 1, 31, 0x8000);
+	_mt7620_mii_write(gsw, 0, 30, 0xa000);
+	_mt7620_mii_write(gsw, 1, 30, 0xa000);
+	_mt7620_mii_write(gsw, 2, 30, 0xa000);
+	_mt7620_mii_write(gsw, 3, 30, 0xa000);
+
+	_mt7620_mii_write(gsw, 0, 4, 0x05e1);
+	_mt7620_mii_write(gsw, 1, 4, 0x05e1);
+	_mt7620_mii_write(gsw, 2, 4, 0x05e1);
+	_mt7620_mii_write(gsw, 3, 4, 0x05e1);
+
+	/* global page 2 */
+	_mt7620_mii_write(gsw, 1, 31, 0xa000);
+	_mt7620_mii_write(gsw, 0, 16, 0x1111);
+	_mt7620_mii_write(gsw, 1, 16, 0x1010);
+	_mt7620_mii_write(gsw, 2, 16, 0x1515);
+	_mt7620_mii_write(gsw, 3, 16, 0x0f0f);
+
+	/* CPU Port6 Force Link 1G, FC ON */
+	gsw_w32(gsw, 0x5e33b, GSW_REG_PORT_PMCR(6));
+
+	/* Set Port 6 as CPU Port */
+	gsw_w32(gsw, 0x7f7f7fe0, 0x0010);
+
+	/* setup port 4 */
+	if (gsw->port4 == PORT4_EPHY) {
+		u32 val = rt_sysc_r32(SYSC_REG_CFG1);
+
+		val |= 3 << 14;
+		rt_sysc_w32(val, SYSC_REG_CFG1);
+		_mt7620_mii_write(gsw, 4, 30, 0xa000);
+		_mt7620_mii_write(gsw, 4, 4, 0x05e1);
+		_mt7620_mii_write(gsw, 4, 16, 0x1313);
+		pr_info("gsw: setting port4 to ephy mode\n");
+	}
+}
+
+static void gsw_hw_init_mt7621(struct mt7620_gsw *gsw, struct device_node *np)
+{
+	u32 i;
+	u32 val;
+
+	/* wardware reset the switch */
+	fe_reset(RST_CTRL_MCM);
+	mdelay(10);
+
+	/* reduce RGMII2 PAD driving strength */
+	rt_sysc_m32(3 << 4, 0, SYSC_PAD_RGMII2_MDIO);
+
+	/* gpio mux - RGMII1=Normal mode */
+	rt_sysc_m32(BIT(14), 0, SYSC_GPIO_MODE);
+
+	/* set GMAC1 RGMII mode */
+	rt_sysc_m32(3 << 12, 0, SYSC_REG_CFG1);
+
+	/* enable MDIO to control MT7530 */
+	rt_sysc_m32(3 << 12, 0, SYSC_GPIO_MODE);
+
+	/* turn off all PHYs */
+	for (i = 0; i <= 4; i++) {
+		val = _mt7620_mii_read(gsw, i, 0x0);
+		val |= BIT(11);
+		_mt7620_mii_write(gsw, i, 0x0, val);
+	}
+
+	/* reset the switch */
+	mt7530_mdio_w32(gsw, 0x7000, 0x3);
+	usleep_range(10, 20);
+
+	if ((rt_sysc_r32(SYSC_REG_CHIP_REV_ID) & 0xFFFF) == 0x0101) {
+		/* (GE1, Force 1000M/FD, FC ON, MAX_RX_LENGTH 1536) */
+		gsw_w32(gsw, 0x2105e30b, 0x100);
+		mt7530_mdio_w32(gsw, 0x3600, 0x5e30b);
+	} else {
+		/* (GE1, Force 1000M/FD, FC ON, MAX_RX_LENGTH 1536) */
+		gsw_w32(gsw, 0x2105e33b, 0x100);
+		mt7530_mdio_w32(gsw, 0x3600, 0x5e33b);
+	}
+
+	/* (GE2, Link down) */
+	gsw_w32(gsw, 0x8000, 0x200);
+
+	/* Enable Port 6, P5 as GMAC5, P5 disable */
+	val = mt7530_mdio_r32(gsw, 0x7804);
+	val &= ~BIT(8);
+	val |= BIT(6) | BIT(13) | BIT(16);
+	mt7530_mdio_w32(gsw, 0x7804, val);
+
+	val = rt_sysc_r32(0x10);
+	val = (val >> 6) & 0x7;
+	if (val >= 6) {
+		/* 25Mhz Xtal - do nothing */
+	} else if (val >= 3) {
+		/* 40Mhz */
+
+		/* disable MT7530 core clock */
+		_mt7620_mii_write(gsw, 0, 13, 0x1f);
+		_mt7620_mii_write(gsw, 0, 14, 0x410);
+		_mt7620_mii_write(gsw, 0, 13, 0x401f);
+		_mt7620_mii_write(gsw, 0, 14, 0x0);
+
+		/* disable MT7530 PLL */
+		_mt7620_mii_write(gsw, 0, 13, 0x1f);
+		_mt7620_mii_write(gsw, 0, 14, 0x40d);
+		_mt7620_mii_write(gsw, 0, 13, 0x401f);
+		_mt7620_mii_write(gsw, 0, 14, 0x2020);
+
+		/* for MT7530 core clock = 500Mhz */
+		_mt7620_mii_write(gsw, 0, 13, 0x1f);
+		_mt7620_mii_write(gsw, 0, 14, 0x40e);
+		_mt7620_mii_write(gsw, 0, 13, 0x401f);
+		_mt7620_mii_write(gsw, 0, 14, 0x119);
+
+		/* enable MT7530 PLL */
+		_mt7620_mii_write(gsw, 0, 13, 0x1f);
+		_mt7620_mii_write(gsw, 0, 14, 0x40d);
+		_mt7620_mii_write(gsw, 0, 13, 0x401f);
+		_mt7620_mii_write(gsw, 0, 14, 0x2820);
+
+		usleep_range(20, 40);
+
+		/* enable MT7530 core clock */
+		_mt7620_mii_write(gsw, 0, 13, 0x1f);
+		_mt7620_mii_write(gsw, 0, 14, 0x410);
+		_mt7620_mii_write(gsw, 0, 13, 0x401f);
+	} else {
+		/* 20Mhz Xtal - TODO */
+	}
+
+	/* RGMII */
+	_mt7620_mii_write(gsw, 0, 14, 0x1);
+
+	/* set MT7530 central align */
+	val = mt7530_mdio_r32(gsw, 0x7830);
+	val &= ~BIT(0);
+	val |= BIT(1);
+	mt7530_mdio_w32(gsw, 0x7830, val);
+	val = mt7530_mdio_r32(gsw, 0x7a40);
+	val &= ~BIT(30);
+	mt7530_mdio_w32(gsw, 0x7a40, val);
+	mt7530_mdio_w32(gsw, 0x7a78, 0x855);
+
+	/* delay setting for 10/1000M */
+	mt7530_mdio_w32(gsw, 0x7b00, 0x102);
+	mt7530_mdio_w32(gsw, 0x7b04, 0x14);
+
+	/* lower Tx Driving*/
+	mt7530_mdio_w32(gsw, 0x7a54, 0x44);
+	mt7530_mdio_w32(gsw, 0x7a5c, 0x44);
+	mt7530_mdio_w32(gsw, 0x7a64, 0x44);
+	mt7530_mdio_w32(gsw, 0x7a6c, 0x44);
+	mt7530_mdio_w32(gsw, 0x7a74, 0x44);
+	mt7530_mdio_w32(gsw, 0x7a7c, 0x44);
+
+	/* turn on all PHYs */
+	for (i = 0; i <= 4; i++) {
+		val = _mt7620_mii_read(gsw, i, 0);
+		val &= ~BIT(11);
+		_mt7620_mii_write(gsw, i, 0, val);
+	}
+
+	/* enable irq */
+	val = mt7530_mdio_r32(gsw, 0x7808);
+	val |= 3 << 16;
+	mt7530_mdio_w32(gsw, 0x7808, val);
+}
+
+void mt7620_set_mac(struct fe_priv *priv, unsigned char *mac)
+{
+	struct mt7620_gsw *gsw = (struct mt7620_gsw *)priv->soc->swpriv;
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->page_lock, flags);
+	gsw_w32(gsw, (mac[0] << 8) | mac[1], GSW_REG_SMACCR1);
+	gsw_w32(gsw, (mac[2] << 24) | (mac[3] << 16) | (mac[4] << 8) | mac[5],
+		GSW_REG_SMACCR0);
+	spin_unlock_irqrestore(&priv->page_lock, flags);
+}
+
+static const struct of_device_id gsw_match[] = {
+	{ .compatible = "mediatek,mt7620-gsw" },
+	{}
+};
+
+int mt7620_gsw_probe(struct fe_priv *priv)
+{
+	struct mt7620_gsw *gsw;
+	struct device_node *np;
+	const char *port4 = NULL;
+
+	np = of_find_matching_node(NULL, gsw_match);
+	if (!np) {
+		dev_err(priv->device, "no gsw node found\n");
+		return -EINVAL;
+	}
+	np = of_node_get(np);
+
+	gsw = devm_kzalloc(priv->device, sizeof(struct mt7620_gsw), GFP_KERNEL);
+	if (!gsw)
+		return -ENOMEM;
+
+	gsw->base = of_iomap(np, 0);
+	if (!gsw->base) {
+		dev_err(priv->device, "gsw ioremap failed\n");
+		return -ENOMEM;
+	}
+
+	gsw->dev = priv->device;
+	priv->soc->swpriv = gsw;
+
+	of_property_read_string(np, "mediatek,port4", &port4);
+	if (port4 && !strcmp(port4, "ephy"))
+		gsw->port4 = PORT4_EPHY;
+	else if (port4 && !strcmp(port4, "gmac"))
+		gsw->port4 = PORT4_EXT;
+	else
+		gsw->port4 = PORT4_EPHY;
+
+	if (IS_ENABLED(CONFIG_SOC_MT7620))
+		gsw_hw_init_mt7620(gsw, np);
+	else
+		gsw_hw_init_mt7621(gsw, np);
+
+	gsw->irq = irq_of_parse_and_map(np, 0);
+	if (gsw->irq) {
+		if (IS_ENABLED(CONFIG_SOC_MT7620)) {
+			request_irq(gsw->irq, gsw_interrupt_mt7620, 0,
+				    "gsw", priv);
+			gsw_w32(gsw, ~PORT_IRQ_ST_CHG, GSW_REG_IMR);
+		} else {
+			request_irq(gsw->irq, gsw_interrupt_mt7621, 0,
+				    "gsw", priv);
+			mt7530_mdio_w32(gsw, 0x7008, 0x1f);
+		}
+	}
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/ralink/gsw_mt7620.h b/drivers/net/ethernet/ralink/gsw_mt7620.h
new file mode 100644
index 0000000..9a42332
--- /dev/null
+++ b/drivers/net/ethernet/ralink/gsw_mt7620.h
@@ -0,0 +1,26 @@
+/*   This program is free software; you can redistribute it and/or modify
+ *   it under the terms of the GNU General Public License as published by
+ *   the Free Software Foundation; version 2 of the License
+ *
+ *   This program is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *   GNU General Public License for more details.
+ *
+ *   Copyright (C) 2009-2015 John Crispin <blogic@openwrt.org>
+ *   Copyright (C) 2009-2015 Felix Fietkau <nbd@openwrt.org>
+ *   Copyright (C) 2013-2015 Michael Lee <igvtee@gmail.com>
+ */
+
+#ifndef _RALINK_GSW_MT7620_H__
+#define _RALINK_GSW_MT7620_H__
+
+int mt7620_gsw_probe(struct fe_priv *priv);
+void mt7620_set_mac(struct fe_priv *priv, unsigned char *mac);
+int mt7620_mdio_write(struct mii_bus *bus, int phy_addr, int phy_reg, u16 val);
+int mt7620_mdio_read(struct mii_bus *bus, int phy_addr, int phy_reg);
+void mt7620_mdio_link_adjust(struct fe_priv *priv, int port);
+void mt7620_port_init(struct fe_priv *priv, struct device_node *np);
+int mt7620a_has_carrier(struct fe_priv *priv);
+
+#endif
diff --git a/drivers/net/ethernet/ralink/soc_mt7620.c b/drivers/net/ethernet/ralink/soc_mt7620.c
new file mode 100644
index 0000000..baced12
--- /dev/null
+++ b/drivers/net/ethernet/ralink/soc_mt7620.c
@@ -0,0 +1,273 @@
+/*   This program is free software; you can redistribute it and/or modify
+ *   it under the terms of the GNU General Public License as published by
+ *   the Free Software Foundation; version 2 of the License
+ *
+ *   This program is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *   GNU General Public License for more details.
+ *
+ *   Copyright (C) 2009-2015 John Crispin <blogic@openwrt.org>
+ *   Copyright (C) 2009-2015 Felix Fietkau <nbd@openwrt.org>
+ *   Copyright (C) 2013-2015 Michael Lee <igvtee@gmail.com>
+ */
+
+#include <linux/module.h>
+#include <linux/platform_device.h>
+#include <linux/if_vlan.h>
+
+#include <asm/mach-ralink/ralink_regs.h>
+
+#include <mt7620.h>
+#include "ralink_soc_eth.h"
+#include "gsw_mt7620.h"
+
+#define MT7620A_CDMA_CSG_CFG	0x400
+#define MT7620_DMA_VID		(MT7620A_CDMA_CSG_CFG | 0x30)
+#define MT7621_CDMP_IG_CTRL	(MT7620A_CDMA_CSG_CFG + 0x00)
+#define MT7621_CDMP_EG_CTRL	(MT7620A_CDMA_CSG_CFG + 0x04)
+#define MT7620A_RESET_FE	BIT(21)
+#define MT7621_RESET_FE		BIT(6)
+#define MT7620A_RESET_ESW	BIT(23)
+#define MT7620_L4_VALID		BIT(23)
+#define MT7621_L4_VALID		BIT(24)
+
+#define MT7620_TX_DMA_UDF	BIT(15)
+#define MT7621_TX_DMA_UDF	BIT(19)
+#define TX_DMA_FP_BMAP		((0xff) << 19)
+
+#define CDMA_ICS_EN		BIT(2)
+#define CDMA_UCS_EN		BIT(1)
+#define CDMA_TCS_EN		BIT(0)
+
+#define GDMA_ICS_EN		BIT(22)
+#define GDMA_TCS_EN		BIT(21)
+#define GDMA_UCS_EN		BIT(20)
+
+/* frame engine counters */
+#define MT7620_REG_MIB_OFFSET	0x1000
+#define MT7620_PPE_AC_BCNT0	(MT7620_REG_MIB_OFFSET + 0x00)
+#define MT7620_GDM1_TX_GBCNT	(MT7620_REG_MIB_OFFSET + 0x300)
+#define MT7620_GDM2_TX_GBCNT	(MT7620_GDM1_TX_GBCNT + 0x40)
+
+#define MT7621_REG_MIB_OFFSET	0x2000
+#define MT7621_PPE_AC_BCNT0	(MT7621_REG_MIB_OFFSET + 0x00)
+#define MT7621_GDM1_TX_GBCNT	(MT7621_REG_MIB_OFFSET + 0x400)
+#define MT7621_GDM2_TX_GBCNT	(MT7621_GDM1_TX_GBCNT + 0x40)
+
+#define GSW_REG_GDMA1_MAC_ADRL	0x508
+#define GSW_REG_GDMA1_MAC_ADRH	0x50C
+
+#define MT7621_FE_RST_GL	(FE_FE_OFFSET + 0x04)
+#define MT7620_FE_INT_STATUS2	(FE_FE_OFFSET + 0x08)
+
+/* FE_INT_STATUS reg on mt7620 define CNT_GDM1_AF at BIT(29)
+ * but after test it should be BIT(13).
+ */
+#define MT7620_FE_GDM1_AF	BIT(13)
+#define MT7621_FE_GDM1_AF	BIT(28)
+#define MT7621_FE_GDM2_AF	BIT(29)
+
+static const u16 mt7620_reg_table[FE_REG_COUNT] = {
+	[FE_REG_PDMA_GLO_CFG] = RT5350_PDMA_GLO_CFG,
+	[FE_REG_PDMA_RST_CFG] = RT5350_PDMA_RST_CFG,
+	[FE_REG_DLY_INT_CFG] = RT5350_DLY_INT_CFG,
+	[FE_REG_TX_BASE_PTR0] = RT5350_TX_BASE_PTR0,
+	[FE_REG_TX_MAX_CNT0] = RT5350_TX_MAX_CNT0,
+	[FE_REG_TX_CTX_IDX0] = RT5350_TX_CTX_IDX0,
+	[FE_REG_TX_DTX_IDX0] = RT5350_TX_DTX_IDX0,
+	[FE_REG_RX_BASE_PTR0] = RT5350_RX_BASE_PTR0,
+	[FE_REG_RX_MAX_CNT0] = RT5350_RX_MAX_CNT0,
+	[FE_REG_RX_CALC_IDX0] = RT5350_RX_CALC_IDX0,
+	[FE_REG_RX_DRX_IDX0] = RT5350_RX_DRX_IDX0,
+	[FE_REG_FE_INT_ENABLE] = RT5350_FE_INT_ENABLE,
+	[FE_REG_FE_INT_STATUS] = RT5350_FE_INT_STATUS,
+	[FE_REG_FE_DMA_VID_BASE] = MT7620_DMA_VID,
+	[FE_REG_FE_COUNTER_BASE] = MT7620_GDM1_TX_GBCNT,
+	[FE_REG_FE_RST_GL] = MT7621_FE_RST_GL,
+	[FE_REG_FE_INT_STATUS2] = MT7620_FE_INT_STATUS2,
+};
+
+static const u16 mt7621_reg_table[FE_REG_COUNT] = {
+	[FE_REG_PDMA_GLO_CFG] = RT5350_PDMA_GLO_CFG,
+	[FE_REG_PDMA_RST_CFG] = RT5350_PDMA_RST_CFG,
+	[FE_REG_DLY_INT_CFG] = RT5350_DLY_INT_CFG,
+	[FE_REG_TX_BASE_PTR0] = RT5350_TX_BASE_PTR0,
+	[FE_REG_TX_MAX_CNT0] = RT5350_TX_MAX_CNT0,
+	[FE_REG_TX_CTX_IDX0] = RT5350_TX_CTX_IDX0,
+	[FE_REG_TX_DTX_IDX0] = RT5350_TX_DTX_IDX0,
+	[FE_REG_RX_BASE_PTR0] = RT5350_RX_BASE_PTR0,
+	[FE_REG_RX_MAX_CNT0] = RT5350_RX_MAX_CNT0,
+	[FE_REG_RX_CALC_IDX0] = RT5350_RX_CALC_IDX0,
+	[FE_REG_RX_DRX_IDX0] = RT5350_RX_DRX_IDX0,
+	[FE_REG_FE_INT_ENABLE] = RT5350_FE_INT_ENABLE,
+	[FE_REG_FE_INT_STATUS] = RT5350_FE_INT_STATUS,
+	[FE_REG_FE_DMA_VID_BASE] = 0,
+	[FE_REG_FE_COUNTER_BASE] = MT7621_GDM1_TX_GBCNT,
+	[FE_REG_FE_RST_GL] = MT7621_FE_RST_GL,
+	[FE_REG_FE_INT_STATUS2] = MT7620_FE_INT_STATUS2,
+};
+
+static void mt7620_fe_reset(void)
+{
+	fe_reset(MT7620A_RESET_FE | MT7620A_RESET_ESW);
+}
+
+static void mt7621_fe_reset(void)
+{
+	fe_reset(MT7621_RESET_FE);
+}
+
+static void mt7620_rxcsum_config(bool enable)
+{
+	if (enable)
+		fe_w32(fe_r32(MT7620A_GDMA1_FWD_CFG) | (GDMA_ICS_EN |
+					GDMA_TCS_EN | GDMA_UCS_EN),
+				MT7620A_GDMA1_FWD_CFG);
+	else
+		fe_w32(fe_r32(MT7620A_GDMA1_FWD_CFG) & ~(GDMA_ICS_EN |
+					GDMA_TCS_EN | GDMA_UCS_EN),
+				MT7620A_GDMA1_FWD_CFG);
+}
+
+static void mt7620_txcsum_config(bool enable)
+{
+	if (enable)
+		fe_w32(fe_r32(MT7620A_CDMA_CSG_CFG) | (CDMA_ICS_EN |
+					CDMA_UCS_EN | CDMA_TCS_EN),
+				MT7620A_CDMA_CSG_CFG);
+	else
+		fe_w32(fe_r32(MT7620A_CDMA_CSG_CFG) & ~(CDMA_ICS_EN |
+					CDMA_UCS_EN | CDMA_TCS_EN),
+				MT7620A_CDMA_CSG_CFG);
+}
+
+static void mt7621_rxvlan_config(bool enable)
+{
+	if (enable)
+		fe_w32(1, MT7621_CDMP_EG_CTRL);
+	else
+		fe_w32(0, MT7621_CDMP_EG_CTRL);
+}
+
+static int mt7620_fwd_config(struct fe_priv *priv)
+{
+	struct net_device *dev = priv_netdev(priv);
+
+	fe_w32(fe_r32(MT7620A_GDMA1_FWD_CFG) & ~7, MT7620A_GDMA1_FWD_CFG);
+
+	mt7620_txcsum_config((dev->features & NETIF_F_IP_CSUM));
+	mt7620_rxcsum_config((dev->features & NETIF_F_RXCSUM));
+
+	return 0;
+}
+
+static int mt7621_fwd_config(struct fe_priv *priv)
+{
+	struct net_device *dev = priv_netdev(priv);
+
+	fe_w32(fe_r32(MT7620A_GDMA1_FWD_CFG) & ~0xffff,
+	       MT7620A_GDMA1_FWD_CFG);
+
+	/* mt7621 don't have txcsum config */
+	mt7620_rxcsum_config((dev->features & NETIF_F_RXCSUM));
+	mt7621_rxvlan_config((dev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
+			     (priv->flags & FE_FLAG_RX_VLAN_CTAG));
+
+	return 0;
+}
+
+static void mt7620_tx_dma(struct fe_tx_dma *txd)
+{
+}
+
+static void mt7621_tx_dma(struct fe_tx_dma *txd)
+{
+	txd->txd4 = BIT(25);
+}
+
+static void mt7620_init_data(struct fe_soc_data *data,
+			     struct net_device *netdev)
+{
+	struct fe_priv *priv = netdev_priv(netdev);
+
+	priv->flags = FE_FLAG_PADDING_64B | FE_FLAG_RX_2B_OFFSET |
+		FE_FLAG_RX_SG_DMA;
+
+	netdev->hw_features = NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
+		NETIF_F_HW_VLAN_CTAG_TX;
+	if (mt7620_get_eco() >= 5)
+		netdev->hw_features |= NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO6 |
+			NETIF_F_IPV6_CSUM;
+}
+
+static void mt7621_init_data(struct fe_soc_data *data,
+			     struct net_device *netdev)
+{
+	struct fe_priv *priv = netdev_priv(netdev);
+
+	priv->flags = FE_FLAG_PADDING_64B | FE_FLAG_RX_2B_OFFSET |
+		FE_FLAG_RX_SG_DMA | FE_FLAG_NAPI_WEIGHT;
+
+	netdev->hw_features = NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
+		NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_SG | NETIF_F_TSO |
+		NETIF_F_TSO6 | NETIF_F_IPV6_CSUM;
+}
+
+static void mt7621_set_mac(struct fe_priv *priv, unsigned char *mac)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->page_lock, flags);
+	fe_w32((mac[0] << 8) | mac[1], GSW_REG_GDMA1_MAC_ADRH);
+	fe_w32((mac[2] << 24) | (mac[3] << 16) | (mac[4] << 8) | mac[5],
+	       GSW_REG_GDMA1_MAC_ADRL);
+	spin_unlock_irqrestore(&priv->page_lock, flags);
+}
+
+static struct fe_soc_data mt7620_data = {
+	.init_data = mt7620_init_data,
+	.reset_fe = mt7620_fe_reset,
+	.set_mac = mt7620_set_mac,
+	.fwd_config = mt7620_fwd_config,
+	.tx_dma = mt7620_tx_dma,
+	.switch_init = mt7620_gsw_probe,
+	.port_init = mt7620_port_init,
+	.reg_table = mt7620_reg_table,
+	.pdma_glo_cfg = FE_PDMA_SIZE_16DWORDS,
+	.rx_int = RT5350_RX_DONE_INT,
+	.tx_int = RT5350_TX_DONE_INT,
+	.status_int = MT7620_FE_GDM1_AF,
+	.checksum_bit = MT7620_L4_VALID,
+	.has_carrier = mt7620a_has_carrier,
+	.mdio_read = mt7620_mdio_read,
+	.mdio_write = mt7620_mdio_write,
+	.mdio_adjust_link = mt7620_mdio_link_adjust,
+};
+
+static struct fe_soc_data mt7621_data = {
+	.init_data = mt7621_init_data,
+	.reset_fe = mt7621_fe_reset,
+	.set_mac = mt7621_set_mac,
+	.fwd_config = mt7621_fwd_config,
+	.tx_dma = mt7621_tx_dma,
+	.switch_init = mt7620_gsw_probe,
+	.reg_table = mt7621_reg_table,
+	.pdma_glo_cfg = FE_PDMA_SIZE_16DWORDS,
+	.rx_int = RT5350_RX_DONE_INT,
+	.tx_int = RT5350_TX_DONE_INT,
+	.status_int = (MT7621_FE_GDM1_AF | MT7621_FE_GDM2_AF),
+	.checksum_bit = MT7621_L4_VALID,
+	.has_carrier = mt7620a_has_carrier,
+	.mdio_read = mt7620_mdio_read,
+	.mdio_write = mt7620_mdio_write,
+	.mdio_adjust_link = mt7620_mdio_link_adjust,
+};
+
+const struct of_device_id of_fe_match[] = {
+	{ .compatible = "mediatek,mt7620-eth", .data = &mt7620_data },
+	{ .compatible = "mediatek,mt7621-eth", .data = &mt7621_data },
+	{},
+};
+
+MODULE_DEVICE_TABLE(of, of_fe_match);
-- 
1.7.10.4
