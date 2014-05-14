From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 09/11] net: dsa: add Broadcom SF2 switch driver
Date: Tue, 13 May 2014 22:00:35 -0700
Message-ID: <1400043637-9799-10-git-send-email-f.fainelli@gmail.com>
References: <1400043637-9799-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	nhorman@tuxdriver.com, andy@greyhouse.net, tgraf@suug.ch,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, jhs@mojatatu.com,
	sfeldma@cumulusnetworks.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:49412 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754123AbaENFBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 01:01:33 -0400
Received: by mail-pa0-f46.google.com with SMTP id kq14so1192107pab.19
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 22:01:33 -0700 (PDT)
In-Reply-To: <1400043637-9799-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add basic support for the Broadcom Starfigther 2 switch chip using a DSA
driver. For now we just do the basic initialization to put the switch
into a forwarding mode as well as allowing reading its per-port MIB
counters.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/Kconfig        |  10 +
 drivers/net/dsa/Makefile       |   1 +
 drivers/net/dsa/bcm_sf2.c      | 482 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/bcm_sf2.h      | 135 ++++++++++++
 drivers/net/dsa/bcm_sf2_regs.h | 167 ++++++++++++++
 5 files changed, 795 insertions(+)
 create mode 100644 drivers/net/dsa/bcm_sf2.c
 create mode 100644 drivers/net/dsa/bcm_sf2.h
 create mode 100644 drivers/net/dsa/bcm_sf2_regs.h

diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index b8fe808b7957..9b51960a4227 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -36,4 +36,14 @@ config NET_DSA_MV88E6123_61_65
 	  This enables support for the Marvell 88E6123/6161/6165
 	  ethernet switch chips.
 
+config NET_DSA_BCM_SF2
+	tristate "Broadcom Starfighter 2 Ethernet switch support"
+	select NET_DSA
+	select FIXED_PHY
+	select BCM7XXX_PHY
+	select MDIO_UNIMAC
+	---help---
+	  This enables support for the Broadcom Starfighter 2 ethernet
+	  switch chips.
+
 endmenu
diff --git a/drivers/net/dsa/Makefile b/drivers/net/dsa/Makefile
index f3bda05536cc..dd3cd3b8157f 100644
--- a/drivers/net/dsa/Makefile
+++ b/drivers/net/dsa/Makefile
@@ -7,3 +7,4 @@ endif
 ifdef CONFIG_NET_DSA_MV88E6131
 mv88e6xxx_drv-y += mv88e6131.o
 endif
+obj-$(CONFIG_NET_DSA_BCM_SF2)	+= bcm_sf2.o
diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
new file mode 100644
index 000000000000..1f8ac8d45c90
--- /dev/null
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -0,0 +1,482 @@
+/*
+ * Broadcom Starfighter 2 DSA switch driver
+ *
+ * Copyright (C) 2014, Broadcom Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/list.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/interrupt.h>
+#include <linux/platform_device.h>
+#include <linux/of.h>
+#include <linux/phy.h>
+#include <linux/phy_fixed.h>
+#include <linux/mii.h>
+#include <linux/of.h>
+#include <linux/of_irq.h>
+#include <linux/of_address.h>
+#include <net/dsa.h>
+
+#include "bcm_sf2.h"
+#include "bcm_sf2_regs.h"
+
+/* String, offset, and register size in bytes if different from 4 bytes */
+static const struct bcm_sf2_hw_stats bcm_sf2_mib[] = {
+	{ "TxOctets",		0x000, 8	},
+	{ "TxDropPkts",		0x020		},
+	{ "TxQPKTQ0",		0x030		},
+	{ "TxBroadcastPkts",	0x040		},
+	{ "TxMulticastPkts",	0x050		},
+	{ "TxUnicastPKts",	0x060		},
+	{ "TxCollisions",	0x070		},
+	{ "TxSingleCollision",	0x080		},
+	{ "TxMultipleCollision", 0x090		},
+	{ "TxDeferredCollision", 0x0a0		},
+	{ "TxLateCollision",	0x0b0		},
+	{ "TxExcessiveCollision", 0x0c0		},
+	{ "TxFrameInDisc",	0x0d0		},
+	{ "TxPausePkts",	0x0e0		},
+	{ "TxQPKTQ1",		0x0f0		},
+	{ "TxQPKTQ2",		0x100		},
+	{ "TxQPKTQ3",		0x110		},
+	{ "TxQPKTQ4",		0x120		},
+	{ "TxQPKTQ5",		0x130		},
+	{ "RxOctets",		0x140, 8	},
+	{ "RxUndersizePkts",	0x160		},
+	{ "RxPausePkts",	0x170		},
+	{ "RxPkts64Octets",	0x180		},
+	{ "RxPkts65to127Octets", 0x190		},
+	{ "RxPkts128to255Octets", 0x1a0		},
+	{ "RxPkts256to511Octets", 0x1b0		},
+	{ "RxPkts512to1023Octets", 0x1c0	},
+	{ "RxPkts1024toMaxPktsOctets", 0x1d0	},
+	{ "RxOversizePkts",	0x1e0		},
+	{ "RxJabbers",		0x1f0		},
+	{ "RxAlignmentErrors",	0x200		},
+	{ "RxFCSErrors",	0x210		},
+	{ "RxGoodOctets",	0x220, 8	},
+	{ "RxDropPkts",		0x240		},
+	{ "RxUnicastPkts",	0x250		},
+	{ "RxMulticastPkts",	0x260		},
+	{ "RxBroadcastPkts",	0x270		},
+	{ "RxSAChanges",	0x280		},
+	{ "RxFragments",	0x290		},
+	{ "RxJumboPkt",		0x2a0		},
+	{ "RxSymblErr",		0x2b0		},
+	{ "InRangeErrCount",	0x2c0		},
+	{ "OutRangeErrCount",	0x2d0		},
+	{ "EEELpiEvent",	0x2e0		},
+	{ "EEELpiDuration",	0x2f0		},
+	{ "RxDiscard",		0x300, 8	},
+	{ "TxQPKTQ6",		0x320		},
+	{ "TxQPKTQ7",		0x330		},
+	{ "TxPkts64Octets",	0x340		},
+	{ "TxPkts65to127Octets", 0x350		},
+	{ "TxPkts128to255Octets", 0x360		},
+	{ "TxPkts256to511Ocets", 0x370		},
+	{ "TxPkts512to1023Ocets", 0x380		},
+	{ "TxPkts1024toMaxPktOcets", 0x390	},
+};
+
+#define BCM_SF2_STATS_SIZE	ARRAY_SIZE(bcm_sf2_mib)
+
+static void bcm_sf2_sw_get_strings(struct dsa_switch *ds,
+					int port, uint8_t *data)
+{
+	unsigned int i;
+
+	for (i = 0; i < BCM_SF2_STATS_SIZE; i++)
+		memcpy(data + i * ETH_GSTRING_LEN,
+			bcm_sf2_mib[i].string, ETH_GSTRING_LEN);
+}
+
+static void bcm_sf2_sw_get_ethtool_stats(struct dsa_switch *ds,
+					int port, uint64_t *data)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	const struct bcm_sf2_hw_stats *s;
+	unsigned int i;
+	u64 val = 0;
+	u32 offset;
+
+	mutex_lock(&priv->stats_mutex);
+
+	/* Now fetch the per-port counters */
+	for (i = 0; i < BCM_SF2_STATS_SIZE; i++) {
+		s = &bcm_sf2_mib[i];
+
+		/* Do a latched 64-bit read if needed */
+		offset = s->reg + CORE_P_MIB_OFFSET(port);
+		if (s->sizeof_stat == 8)
+			val = core_readq(priv, offset);
+		else
+			val = core_readl(priv, offset);
+
+		data[i] = (u64)val;
+	}
+
+	mutex_unlock(&priv->stats_mutex);
+}
+
+static int bcm_sf2_sw_get_sset_count(struct dsa_switch *ds)
+{
+	return BCM_SF2_STATS_SIZE;
+}
+
+static char *bcm_sf2_sw_probe(struct mii_bus *bus, int sw_addr)
+{
+	return "Broadcom Starfighter 2";
+}
+
+static void bcm_sf2_imp_setup(struct dsa_switch *ds, int port)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	u32 reg, val;
+
+	/* Enable Broadcast, Multicast, Unicast forwarding to IMP port */
+	reg = core_readl(priv, CORE_IMP_CTL);
+	reg |= (RX_BCST_EN | RX_MCST_EN | RX_UCST_EN);
+	reg &= ~(RX_DIS | TX_DIS);
+	core_writel(priv, reg, CORE_IMP_CTL);
+
+	/* Enable forwarding and managed mode */
+	core_writel(priv, SW_FWDG_EN | SW_FWDG_MODE, CORE_SWMODE);
+
+	/* Resolve which bit controls the Broadcom tag */
+	switch (port) {
+	case 8:
+		val = BRCM_HDR_EN_P8;
+		break;
+	case 7:
+		val = BRCM_HDR_EN_P7;
+		break;
+	case 5:
+		val = BRCM_HDR_EN_P5;
+		break;
+	default:
+		val = 0;
+		break;
+	}
+
+	/* Disable Broadcom tags for IMP port */
+	reg = core_readl(priv, CORE_BRCM_HDR_CTRL);
+	reg &= ~val;
+	core_writel(priv, reg, CORE_BRCM_HDR_CTRL);
+
+	/* Force link status for IMP port */
+	reg = core_readl(priv, CORE_STS_OVERRIDE_IMP);
+	reg |= (MII_SW_OR | LINK_STS);
+	core_writel(priv, reg, CORE_STS_OVERRIDE_IMP);
+}
+
+static void bcm_sf2_port_setup(struct dsa_switch *ds, int port)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	u32 reg;
+
+	/* Clear the Rx and Tx disable bits and set to no spanning tree */
+	core_writel(priv, 0, CORE_G_PCTL_PORT(port));
+
+	/* Reset port status override */
+	reg = core_readl(priv, CORE_STS_OVERRIDE_GMIIP_PORT(port));
+	reg &= ~SW_OVERRIDE;
+	core_writel(priv, reg, CORE_STS_OVERRIDE_GMIIP_PORT(port));
+
+	/* Enable port 7 interrupts to get notified */
+	if (port == 7)
+		intrl2_1_mask_clear(priv, P_IRQ_MASK(P7_IRQ_OFF));
+}
+
+static void bcm_sf2_port_disable(struct dsa_switch *ds, int port)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+
+	/* Disable the port since it is unused */
+	core_writel(priv, RX_DIS | TX_DIS, CORE_G_PCTL_PORT(port));
+}
+
+static irqreturn_t bcm_sf2_switch_0_isr(int irq, void *dev_id)
+{
+	struct bcm_sf2_priv *priv = dev_id;
+
+	priv->irq0_stat = intrl2_0_readl(priv, INTRL2_CPU_STATUS) &
+				~priv->irq0_mask;
+	intrl2_0_writel(priv, priv->irq0_stat, INTRL2_CPU_CLEAR);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t bcm_sf2_switch_1_isr(int irq, void *dev_id)
+{
+	struct bcm_sf2_priv *priv = dev_id;
+
+	priv->irq1_stat = intrl2_1_readl(priv, INTRL2_CPU_STATUS) &
+				~priv->irq1_mask;
+	intrl2_1_writel(priv, priv->irq1_stat, INTRL2_CPU_CLEAR);
+
+	if (priv->irq1_stat & P_LINK_UP_IRQ(P7_IRQ_OFF))
+		priv->port_sts[7].link = 1;
+	if (priv->irq1_stat & P_LINK_DOWN_IRQ(P7_IRQ_OFF))
+		priv->port_sts[7].link = 0;
+
+	return IRQ_HANDLED;
+}
+
+static int bcm_sf2_sw_setup(struct dsa_switch *ds)
+{
+	const char *reg_names[BCM_SF2_REGS_NUM] = BCM_SF2_REGS_NAME;
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct device_node *dn;
+	void __iomem **base;
+	unsigned int port;
+	unsigned int i;
+	u32 reg, rev;
+	int ret;
+
+	spin_lock_init(&priv->indir_lock);
+	mutex_init(&priv->stats_mutex);
+
+	/* All the interesting properties are at the parent device_node
+	 * level
+	 */
+	dn = ds->pd->of_node->parent;
+
+	priv->irq0 = irq_of_parse_and_map(dn, 0);
+	priv->irq1 = irq_of_parse_and_map(dn, 1);
+
+	base = &priv->core;
+	for (i = 0; i < BCM_SF2_REGS_NUM; i++) {
+		*base = of_iomap(dn, i);
+		if (*base == NULL) {
+			pr_err("unable to find register: %s\n", reg_names[i]);
+			return -ENODEV;
+		}
+		base++;
+	}
+
+	/* Disable all interrupts and request them */
+	intrl2_0_writel(priv, 0xffffffff, INTRL2_CPU_MASK_SET);
+	intrl2_0_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
+	intrl2_0_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
+	intrl2_1_writel(priv, 0xffffffff, INTRL2_CPU_MASK_SET);
+	intrl2_1_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
+	intrl2_1_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
+
+	ret = request_irq(priv->irq0, bcm_sf2_switch_0_isr, 0,
+				"switch_0", priv);
+	if (ret < 0) {
+		pr_err("failed to request switch_0 IRQ\n");
+		goto out_unmap;
+	}
+
+	ret = request_irq(priv->irq1, bcm_sf2_switch_1_isr, 0,
+				"switch_1", priv);
+	if (ret < 0) {
+		pr_err("failed to request switch_1 IRQ\n");
+		goto out_unmap;
+	}
+
+	/* Reset the MIB counters */
+	reg = core_readl(priv, CORE_GMNCFGCFG);
+	reg |= RST_MIB_CNT;
+	core_writel(priv, reg, CORE_GMNCFGCFG);
+	reg &= ~RST_MIB_CNT;
+	core_writel(priv, reg, CORE_GMNCFGCFG);
+
+	/* Enable all valid ports and disable those unused */
+	for (port = 0; port < DSA_MAX_PORTS; port++) {
+		/* IMP port receives special treatment */
+		if (dsa_is_cpu_port(ds, port))
+			bcm_sf2_imp_setup(ds, port);
+		if ((1 << port) & ds->phys_port_mask)
+			bcm_sf2_port_setup(ds, port);
+		else
+			bcm_sf2_port_disable(ds, port);
+	}
+
+	rev = reg_readl(priv, REG_SWITCH_REVISION);
+	priv->hw_params.top_rev = (rev >> SWITCH_TOP_REV_SHIFT) &
+					SWITCH_TOP_REV_MASK;
+	priv->hw_params.core_rev = (rev & SF2_REV_MASK);
+
+	pr_info("Starfigther 2 top: %x.%02x, core: %x.%02x base: 0x%p, IRQs: %d, %d\n",
+		priv->hw_params.top_rev >> 8, priv->hw_params.top_rev & 0xff,
+		priv->hw_params.core_rev >> 8, priv->hw_params.core_rev & 0xff,
+		priv->core, priv->irq0, priv->irq1);
+
+	return 0;
+
+out_unmap:
+	base = &priv->core;
+	for (i = 0; i < BCM_SF2_REGS_NUM; i++) {
+		iounmap(*base);
+		base++;
+	}
+	return ret;
+}
+
+static int bcm_sf2_sw_set_addr(struct dsa_switch *ds, u8 *addr)
+{
+	return 0;
+}
+
+static int bcm_sf2_sw_phy_read(struct dsa_switch *ds, int port, int regnum)
+{
+	return 0;
+}
+
+static int bcm_sf2_sw_phy_write(struct dsa_switch *ds, int port, int regnum,
+				u16 val)
+{
+	return 0;
+}
+
+static void bcm_sf2_sw_adjust_link(struct dsa_switch *ds, int port,
+					struct phy_device *phydev)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	u32 id_mode_dis = 0, port_mode;
+	const char *str = NULL;
+	u32 reg;
+
+	switch (phydev->interface) {
+	case PHY_INTERFACE_MODE_RGMII:
+		str = "RGMII (no delay)";
+		id_mode_dis = 1;
+	case PHY_INTERFACE_MODE_RGMII_TXID:
+		if (!str)
+			str = "RGMII (TX delay)";
+		port_mode = EXT_GPHY;
+		break;
+	case PHY_INTERFACE_MODE_MII:
+		str = "MII";
+		port_mode = EXT_EPHY;
+		break;
+	case PHY_INTERFACE_MODE_REVMII:
+		str = "Reverse MII";
+		port_mode = EXT_REVMII;
+		break;
+	default:
+		return;
+	}
+
+	/* Clear id_mode_dis bit, and the existing port mode, but
+	 * make sure we enable the RGMII block for data to pass
+	 */
+	reg = reg_readl(priv, REG_RGMII_CNTRL_P(port));
+	reg &= ~ID_MODE_DIS;
+	reg &= ~(PORT_MODE_MASK << PORT_MODE_SHIFT);
+	reg &= ~(RX_PAUSE_EN | TX_PAUSE_EN);
+
+	reg |= port_mode | RGMII_MODE_EN;
+	if (id_mode_dis)
+		reg |= ID_MODE_DIS;
+
+	if (phydev->pause) {
+		if (phydev->asym_pause)
+			reg |= TX_PAUSE_EN;
+		reg |= RX_PAUSE_EN;
+	}
+
+	reg_writel(priv, reg, REG_RGMII_CNTRL_P(port));
+
+	pr_info("Port %d configured for %s\n", port, str);
+}
+
+static void bcm_sf2_sw_fixed_link_update(struct dsa_switch *ds, int port,
+					struct fixed_phy_status *status)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	u32 link, duplex, pause, speed;
+	u32 reg;
+
+	link = core_readl(priv, CORE_LNKSTS);
+	duplex = core_readl(priv, CORE_DUPSTS);
+	pause = core_readl(priv, CORE_PAUSESTS);
+	speed = core_readl(priv, CORE_SPDSTS);
+
+	speed >>= (port * SPDSTS_SHIFT);
+	speed &= SPDSTS_MASK;
+
+	status->link = 0;
+
+	/* Port 7 is special as we do not get link status from CORE_LNKSTS,
+	 * which means that we need to force the link at the port override
+	 * level to get the data to flow. We do use what the interrupt handler
+	 * did determine before.
+	 */
+	if (port == 7) {
+		status->link = priv->port_sts[port].link;
+		reg = core_readl(priv, CORE_STS_OVERRIDE_GMIIP_PORT(7));
+		reg |= SW_OVERRIDE;
+		if (status->link)
+			reg |= LINK_STS;
+		else
+			reg &= ~LINK_STS;
+		core_writel(priv, reg, CORE_STS_OVERRIDE_GMIIP_PORT(7));
+	} else
+		status->link = !!(link & (1 << port));
+
+	status->duplex = !!(duplex & (1 << port));
+
+	switch (speed) {
+	case SPDSTS_10:
+		status->speed = SPEED_10;
+		break;
+	case SPDSTS_100:
+		status->speed = SPEED_100;
+		break;
+	case SPDSTS_1000:
+		status->speed = SPEED_1000;
+		break;
+	}
+
+	if ((pause & (1 << port)) &&
+		(pause & (1 << (port + PAUSESTS_TX_PAUSE_SHIFT)))) {
+		status->asym_pause = 1;
+		status->pause = 1;
+	}
+
+	if (pause & (1 << port))
+		status->pause = 1;
+}
+
+static struct dsa_switch_driver bcm_sf2_switch_driver = {
+	.tag_protocol		= htons(ETH_P_BRCMTAG),
+	.priv_size		= sizeof(struct bcm_sf2_priv),
+	.probe			= bcm_sf2_sw_probe,
+	.setup			= bcm_sf2_sw_setup,
+	.set_addr		= bcm_sf2_sw_set_addr,
+	.phy_read		= bcm_sf2_sw_phy_read,
+	.phy_write		= bcm_sf2_sw_phy_write,
+	.get_strings		= bcm_sf2_sw_get_strings,
+	.get_ethtool_stats	= bcm_sf2_sw_get_ethtool_stats,
+	.get_sset_count		= bcm_sf2_sw_get_sset_count,
+	.adjust_link		= bcm_sf2_sw_adjust_link,
+	.fixed_link_update	= bcm_sf2_sw_fixed_link_update,
+};
+
+static int __init bcm_sf2_init(void)
+{
+	register_switch_driver(&bcm_sf2_switch_driver);
+
+	return 0;
+}
+module_init(bcm_sf2_init);
+
+static void __exit bcm_sf2_exit(void)
+{
+	unregister_switch_driver(&bcm_sf2_switch_driver);
+}
+module_exit(bcm_sf2_exit);
+
+MODULE_AUTHOR("Broadcom Corporation");
+MODULE_DESCRIPTION("Driver for Broadcom Starfighter 2 ethernet switch chip");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:brcm-sf2");
diff --git a/drivers/net/dsa/bcm_sf2.h b/drivers/net/dsa/bcm_sf2.h
new file mode 100644
index 000000000000..72e165bf229c
--- /dev/null
+++ b/drivers/net/dsa/bcm_sf2.h
@@ -0,0 +1,135 @@
+/*
+ * Broadcom Starfighter2 private context
+ *
+ * Copyright (C) 2014, Broadcom Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef __BCM_SF2_H
+#define __BCM_SF2_H
+
+#include <linux/platform_device.h>
+#include <linux/kernel.h>
+#include <linux/io.h>
+#include <linux/spinlock.h>
+#include <linux/mutex.h>
+#include <linux/mii.h>
+
+#include <net/dsa.h>
+
+#include "bcm_sf2_regs.h"
+
+struct bcm_sf2_hw_params {
+	u16	top_rev;
+	u16	core_rev;
+	u8	num_acb_queue;
+	u8	num_gphy;
+	u8	num_rgmii;
+	u8	fcb_pause_override:1;
+	u8	acb_packets_inflight:1;
+};
+
+#define BCM_SF2_REGS_NAME {\
+	"core", "reg", "intrl2_0", "intrl2_1", "fcb", "acb" \
+}
+#define BCM_SF2_REGS_NUM	6
+
+struct bcm_sf2_port_status {
+	unsigned int link;
+};
+
+struct bcm_sf2_priv {
+	/* Base registers, keep those in order with BCM_SF2_REGS_NAME */
+	void __iomem			*core;
+	void __iomem			*reg;
+	void __iomem			*intrl2_0;
+	void __iomem			*intrl2_1;
+	void __iomem			*fcb;
+	void __iomem			*acb;
+	spinlock_t			indir_lock;
+
+	int				irq0;
+	int				irq1;
+	u32				irq0_stat;
+	u32				irq0_mask;
+	u32				irq1_stat;
+	u32				irq1_mask;
+
+	struct mutex			stats_mutex;
+
+	struct bcm_sf2_hw_params	hw_params;
+
+	struct bcm_sf2_port_status	port_sts[DSA_MAX_PORTS];
+};
+
+struct bcm_sf2_hw_stats {
+	const char	*string;
+	u16		reg;
+	u8		sizeof_stat;
+};
+
+#define SF2_IO_MACRO(name) \
+static inline u32 name##_readl(struct bcm_sf2_priv *priv, u32 off)	\
+{									\
+	return __raw_readl(priv->name + off);				\
+}									\
+static inline void name##_writel(struct bcm_sf2_priv *priv,		\
+				  u32 val, u32 off)			\
+{									\
+	__raw_writel(val, priv->name + off);				\
+}									\
+
+/* Accesses to 64-bits register requires us to latch the hi/lo pairs
+ * using the REG_DIR_DATA_{READ,WRITE} ancillary registers. The 'indir_lock'
+ * spinlock is automatically grabbed and released to provide relative
+ * atomiticy with latched reads/writes.
+ */
+#define SF2_IO64_MACRO(name) \
+static inline u64 name##_readq(struct bcm_sf2_priv *priv, u32 off)	\
+{									\
+	u32 indir, dir;							\
+	spin_lock(&priv->indir_lock);					\
+	indir = reg_readl(priv, REG_DIR_DATA_READ);			\
+	dir = __raw_readl(priv->name + off);				\
+	spin_unlock(&priv->indir_lock);					\
+	return (u64)indir << 32 | dir;					\
+}									\
+static inline void name##_writeq(struct bcm_sf2_priv *priv, u32 off,	\
+							u64 val)	\
+{									\
+	spin_lock(&priv->indir_lock);					\
+	reg_writel(priv, upper_32_bits(val), REG_DIR_DATA_WRITE);	\
+	__raw_writel(lower_32_bits(val), priv->name + off);		\
+	spin_unlock(&priv->indir_lock);					\
+}
+
+#define SWITCH_INTR_L2(which)						\
+static inline void intrl2_##which##_mask_clear(struct bcm_sf2_priv *priv, \
+						u32 mask)		\
+{									\
+	intrl2_##which##_writel(priv, mask, INTRL2_CPU_MASK_CLEAR);	\
+	priv->irq##which##_mask &= ~(mask);				\
+}									\
+static inline void intrl2_##which##_mask_set(struct bcm_sf2_priv *priv, \
+						u32 mask)		\
+{									\
+	intrl2_## which##_writel(priv, mask, INTRL2_CPU_MASK_SET);	\
+	priv->irq##which##_mask |= (mask);				\
+}									\
+
+SF2_IO_MACRO(core);
+SF2_IO_MACRO(reg);
+SF2_IO64_MACRO(core);
+SF2_IO_MACRO(intrl2_0);
+SF2_IO_MACRO(intrl2_1);
+SF2_IO_MACRO(fcb);
+SF2_IO_MACRO(acb);
+
+SWITCH_INTR_L2(0);
+SWITCH_INTR_L2(1);
+
+#endif /* __BCM_SF2_H */
diff --git a/drivers/net/dsa/bcm_sf2_regs.h b/drivers/net/dsa/bcm_sf2_regs.h
new file mode 100644
index 000000000000..e183cac3d7c8
--- /dev/null
+++ b/drivers/net/dsa/bcm_sf2_regs.h
@@ -0,0 +1,167 @@
+/*
+ * Broadcom Starfigther 2 switch register defines
+ *
+ * Copyright (C) 2014, Broadcom Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+#ifndef __BCM_SF2_REGS_H
+#define __BCM_SF2_REGS_H
+
+
+/* Register set relative to 'REG' */
+#define REG_SWITCH_CNTRL		0x00
+#define REG_SWITCH_STATUS		0x04
+#define REG_DIR_DATA_WRITE		0x08
+#define REG_DIR_DATA_READ		0x0C
+
+#define REG_SWITCH_REVISION		0x18
+#define  SF2_REV_MASK			0xffff
+#define  SWITCH_TOP_REV_SHIFT		16
+#define  SWITCH_TOP_REV_MASK		0xffff
+
+#define REG_PHY_REVISION		0x1C
+
+#define REG_SPHY_CNTRL			0x2C
+#define  IDDQ_BIAS			(1 << 0)
+#define  EXT_PWR_DOWN			(1 << 1)
+#define  FORCE_DLL_EN			(1 << 2)
+#define  IDDQ_GLOBAL_PWR		(1 << 3)
+#define  CK25_DIS			(1 << 4)
+#define  PHY_RESET			(1 << 5)
+#define  PHY_PHYAD_SHIFT		8
+#define  PHY_PHYAD_MASK			0x1F
+
+#define REG_RGMII_0_BASE		0x34
+#define REG_RGMII_CNTRL			0x00
+#define REG_RGMII_IB_STATUS		0x04
+#define REG_RGMII_RX_CLOCK_DELAY_CNTRL	0x08
+#define REG_RGMII_CNTRL_SIZE		0x0C
+#define REG_RGMII_CNTRL_P(x)		(REG_RGMII_0_BASE + \
+					((x) * REG_RGMII_CNTRL_SIZE))
+/* Relative to REG_RGMII_CNTRL */
+#define  RGMII_MODE_EN			(1 << 0)
+#define  ID_MODE_DIS			(1 << 1)
+#define  PORT_MODE_SHIFT		2
+#define  INT_EPHY			(0 << PORT_MODE_SHIFT)
+#define  INT_GPHY			(1 << PORT_MODE_SHIFT)
+#define  EXT_EPHY			(2 << PORT_MODE_SHIFT)
+#define  EXT_GPHY			(3 << PORT_MODE_SHIFT)
+#define  EXT_REVMII			(4 << PORT_MODE_SHIFT)
+#define  PORT_MODE_MASK			0x7
+#define  RVMII_REF_SEL			(1 << 5)
+#define  RX_PAUSE_EN			(1 << 6)
+#define  TX_PAUSE_EN			(1 << 7)
+#define  TX_CLK_STOP_EN			(1 << 8)
+#define  LPI_COUNT_SHIFT		9
+#define  LPI_COUNT_MASK			0x3F
+
+/* Register set relative to 'INTRL2_0' and 'INTRL2_1' */
+#define INTRL2_CPU_STATUS		0x00
+#define INTRL2_CPU_SET			0x04
+#define INTRL2_CPU_CLEAR		0x08
+#define INTRL2_CPU_MASK_STATUS		0x0c
+#define INTRL2_CPU_MASK_SET		0x10
+#define INTRL2_CPU_MASK_CLEAR		0x14
+
+/* Shared INTRL2_0 and INTRL2_ interrupt sources macros */
+#define P_LINK_UP_IRQ(x)		(1 << (0 + (x)))
+#define P_LINK_DOWN_IRQ(x)		(1 << (1 + (x)))
+#define P_ENERGY_ON_IRQ(x)		(1 << (2 + (x)))
+#define P_ENERGY_OFF_IRQ(x)		(1 << (3 + (x)))
+#define P_GPHY_IRQ(x)			(1 << (4 + (x)))
+#define P_NUM_IRQ			5
+#define P_IRQ_MASK(x)			(P_LINK_UP_IRQ((x)) | \
+					 P_LINK_DOWN_IRQ((x)) | \
+					 P_ENERGY_ON_IRQ((x)) | \
+					 P_ENERGY_OFF_IRQ((x)) | \
+					 P_GPHY_IRQ((x)))
+
+/* INTRL2_0 interrupt sources */
+#define P0_IRQ_OFF			0
+#define MEM_DOUBLE_IRQ			(1 << 5)
+#define EEE_LPI_IRQ			(1 << 6)
+#define P5_CPU_WAKE_IRQ			(1 << 7)
+#define P8_CPU_WAKE_IRQ			(1 << 8)
+#define P7_CPU_WAKE_IRQ			(1 << 9)
+#define IEEE1588_IRQ			(1 << 10)
+#define MDIO_ERR_IRQ			(1 << 11)
+#define MDIO_DONE_IRQ			(1 << 12)
+#define GISB_ERR_IRQ			(1 << 13)
+#define UBUS_ERR_IRQ			(1 << 14)
+#define FAILOVER_ON_IRQ			(1 << 15)
+#define FAILOVER_OFF_IRQ		(1 << 16)
+#define TCAM_SOFT_ERR_IRQ		(1 << 17)
+
+/* INTRL2_1 interrupt sources */
+#define P7_IRQ_OFF			0
+#define P_IRQ_OFF(x)			((6 - (x)) * P_NUM_IRQ)
+
+/* Register set relative to 'CORE' */
+#define CORE_G_PCTL_PORT0		0x00000
+#define CORE_G_PCTL_PORT(x)		(CORE_G_PCTL_PORT0 + (x * 0x4))
+#define CORE_IMP_CTL			0x00020
+#define  RX_DIS				(1 << 0)
+#define  TX_DIS				(1 << 1)
+#define  RX_BCST_EN			(1 << 2)
+#define  RX_MCST_EN			(1 << 3)
+#define  RX_UCST_EN			(1 << 4)
+#define  G_MISTP_STATE_SHIFT		5
+#define  G_MISTP_NO_STP			(0 << G_MISTP_STATE_SHIFT)
+#define  G_MISTP_DIS_STATE		(1 << G_MISTP_STATE_SHIFT)
+#define  G_MISTP_BLOCK_STATE		(2 << G_MISTP_STATE_SHIFT)
+#define  G_MISTP_LISTEN_STATE		(3 << G_MISTP_STATE_SHIFT)
+#define  G_MISTP_LEARN_STATE		(4 << G_MISTP_STATE_SHIFT)
+#define  G_MISTP_FWD_STATE		(5 << G_MISTP_STATE_SHIFT)
+#define  G_MISTP_STATE_MASK		0x7
+
+#define CORE_SWMODE			0x0002c
+#define  SW_FWDG_MODE			(1 << 0)
+#define  SW_FWDG_EN			(1 << 1)
+#define  RTRY_LMT_DIS			(1 << 2)
+
+#define CORE_STS_OVERRIDE_IMP		0x00038
+#define  GMII_SPEED_UP_2G		(1 << 6)
+#define  MII_SW_OR			(1 << 7)
+
+#define CORE_STS_OVERRIDE_GMIIP_PORT(x)	(0x160 + (x) * 4)
+#define  LINK_STS			(1 << 0)
+#define  DUPLX_MODE			(1 << 1)
+#define  SPEED_SHIFT			(1 << 2)
+#define  SPEED_MASK			0x3
+#define  RXFLOW_CNTL			(1 << 4)
+#define  TXFLOW_CNTL			(1 << 5)
+#define  SW_OVERRIDE			(1 << 6)
+
+#define CORE_LNKSTS			0x00400
+#define  LNK_STS_MASK			0x1ff
+
+#define CORE_SPDSTS			0x00410
+#define  SPDSTS_10			0
+#define  SPDSTS_100			1
+#define  SPDSTS_1000			2
+#define  SPDSTS_SHIFT			2
+#define  SPDSTS_MASK			0x3
+
+#define CORE_DUPSTS			0x00420
+#define  CORE_DUPSTS_MASK		0x1ff
+
+#define CORE_PAUSESTS			0x00428
+#define  PAUSESTS_TX_PAUSE_SHIFT	9
+
+#define CORE_BRCM_HDR_CTRL		0x0080c
+#define  BRCM_HDR_EN_P8			(1 << 0)
+#define  BRCM_HDR_EN_P5			(1 << 1)
+#define  BRCM_HDR_EN_P7			(1 << 2)
+
+#define CORE_BRCM_HDR_RX_DIS		0x0980
+#define CORE_BRCM_HDR_TX_DIS		0x0988
+
+#define	CORE_P0_MIB_OFFSET		0x8000
+#define P_MIB_SIZE			0x400
+#define CORE_P_MIB_OFFSET(x)		(CORE_P0_MIB_OFFSET + (x) * P_MIB_SIZE)
+
+#endif /* __BCM_SF2_REGS_H */
-- 
1.9.1
