From: John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: [PATCH V2 04/12] net-next: mediatek: add gigabit switch driver (GSW)
Date: Fri, 26 Feb 2016 15:21:36 +0100
Message-ID: <1456496504-50429-5-git-send-email-blogic@openwrt.org>
References: <1456496504-50429-1-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?q?Fred=20Chang=20=28=E5=BC=B5=E5=98=89=E5=AE=8F=29?=
 <Fred.Chang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>,
 =?UTF-8?q?Steven=20Liu=20=28=E5=8A=89=E4=BA=BA=E8=B1=AA=29?=
 <steven.liu-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 =?UTF-8?q?Carlos=20Huang=20=28=E9=BB=83=E5=A3=AB=E5=BD=B0=29?=
 <Carlos.Huang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Matthias Brugger <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1456496504-50429-1-git-send-email-blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

The GSW is found in all of the 1000mbit SoCs. it has 5 external ports,
1-2 cpu ports and 1 further port that the internal HW offloading engine
connects to. The switch core used is a MT7530, which also exists as a
standalone chip. Although these SoCs (mt7620/1/3) share the same switch
core, the bring up of these is slightly different. One of the reasons is
that on mt7620 the switch core is mmio mapped while MT7621/3 talks to the
switch via MDIO addr 0x1f. Additionally, the SoCs have different MAC types
and some of them have TRGMII support. MT7621 can do 1,2gbit and MT7623 is
able to do 2,6gbit. The support for the TRGMII bring up is not part of this
series as the code is based on the SDK driver and has between 1500 and 2000
magic values that still need to be converted to defines.

Because of these differences we have 3 separate drivers for these 3 SoCs.
These drivers are very basic and only provides basic init and irq support.

The SoC and switch core both have support for a special tag making DSA
support possible.

Signed-off-by: John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
---
 drivers/net/ethernet/mediatek/gsw_mt7620.c |  256 +++++++++++++++++
 drivers/net/ethernet/mediatek/gsw_mt7620.h |  277 ++++++++++++++++++
 drivers/net/ethernet/mediatek/gsw_mt7621.c |  265 ++++++++++++++++++
 drivers/net/ethernet/mediatek/gsw_mt7623.c |  417 ++++++++++++++++++++++++++++
 4 files changed, 1215 insertions(+)
 create mode 100644 drivers/net/ethernet/mediatek/gsw_mt7620.c
 create mode 100644 drivers/net/ethernet/mediatek/gsw_mt7620.h
 create mode 100644 drivers/net/ethernet/mediatek/gsw_mt7621.c
 create mode 100644 drivers/net/ethernet/mediatek/gsw_mt7623.c

diff --git a/drivers/net/ethernet/mediatek/gsw_mt7620.c b/drivers/net/ethernet/mediatek/gsw_mt7620.c
new file mode 100644
index 0000000..8a81048
--- /dev/null
+++ b/drivers/net/ethernet/mediatek/gsw_mt7620.c
@@ -0,0 +1,256 @@
+/*   This program is free software; you can redistribute it and/or modify
+ *   it under the terms of the GNU General Public License as published by
+ *   the Free Software Foundation; version 2 of the License
+ *
+ *   This program is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *   GNU General Public License for more details.
+ *
+ *   Copyright (C) 2009-2016 John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
+ *   Copyright (C) 2009-2016 Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
+ *   Copyright (C) 2013-2016 Michael Lee <igvtee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/platform_device.h>
+#include <linux/of_device.h>
+#include <linux/of_irq.h>
+
+#include <ralink_regs.h>
+
+#include "mtk_eth_soc.h"
+#include "gsw_mt7620.h"
+
+void mtk_switch_w32(struct mt7620_gsw *gsw, u32 val, unsigned reg)
+{
+	iowrite32(val, gsw->base + reg);
+}
+
+u32 mtk_switch_r32(struct mt7620_gsw *gsw, unsigned reg)
+{
+	return ioread32(gsw->base + reg);
+}
+
+static irqreturn_t gsw_interrupt_mt7620(int irq, void *_eth)
+{
+	struct mtk_eth *eth = (struct mtk_eth *)_eth;
+	struct mt7620_gsw *gsw = (struct mt7620_gsw *)eth->sw_priv;
+	int i, max = (gsw->port4 == PORT4_EPHY) ? (4) : (3);
+	u32 status;
+
+	status = mtk_switch_r32(gsw, GSW_REG_ISR);
+	if (status & PORT_IRQ_ST_CHG)
+		for (i = 0; i <= max; i++) {
+			u32 status = mtk_switch_r32(gsw,
+						    GSW_REG_PORT_STATUS(i));
+			int link = status & 0x1;
+
+			if (link != eth->link[i])
+				mt7620_print_link_state(eth, i, link,
+							(status >> 2) & 3,
+							(status & 0x2));
+
+			eth->link[i] = link;
+		}
+	mtk_switch_w32(gsw, status, GSW_REG_ISR);
+
+	return IRQ_HANDLED;
+}
+
+static void mt7620_hw_init(struct mt7620_gsw *gsw, struct device_node *np)
+{
+	u32 is_BGA = (rt_sysc_r32(0x0c) >> 16) & 1;
+
+	rt_sysc_w32(rt_sysc_r32(SYSC_REG_CFG1) | BIT(8), SYSC_REG_CFG1);
+	mtk_switch_w32(gsw, mtk_switch_r32(gsw, GSW_REG_CKGCR) & ~(0x3 << 4),
+		       GSW_REG_CKGCR);
+
+	if (of_property_read_bool(np, "mediatek,mt7530")) {
+		u32 val;
+
+		/* turn off ephy and set phy base addr to 12 */
+		mtk_switch_w32(gsw, mtk_switch_r32(gsw, GSW_REG_GPC1) |
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
+	mtk_switch_w32(gsw, 0x5e33b, GSW_REG_PORT_PMCR(6));
+
+	/* Set Port 6 as CPU Port */
+	mtk_switch_w32(gsw, 0x7f7f7fe0, 0x0010);
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
+static const struct of_device_id mediatek_gsw_match[] = {
+	{ .compatible = "mediatek,mt7620-gsw" },
+	{},
+};
+MODULE_DEVICE_TABLE(of, mediatek_gsw_match);
+
+int mtk_gsw_init(struct mtk_eth *eth)
+{
+	struct device_node *np = eth->switch_np;
+	struct platform_device *pdev = of_find_device_by_node(np);
+	struct mt7620_gsw *gsw;
+
+	if (!pdev)
+		return -ENODEV;
+
+	if (!of_device_is_compatible(np, mediatek_gsw_match->compatible))
+		return -EINVAL;
+
+	gsw = platform_get_drvdata(pdev);
+	eth->sw_priv = gsw;
+
+	mt7620_hw_init(gsw, np);
+
+	if (gsw->irq) {
+		request_irq(gsw->irq, gsw_interrupt_mt7620, 0,
+			    "gsw", eth);
+		mtk_switch_w32(gsw, ~PORT_IRQ_ST_CHG, GSW_REG_IMR);
+	}
+
+	return 0;
+}
+
+static int mt7620_gsw_probe(struct platform_device *pdev)
+{
+	struct resource *res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	struct device_node *np = pdev->dev.of_node;
+	const char *port4 = NULL;
+	struct mt7620_gsw *gsw;
+
+	gsw = devm_kzalloc(&pdev->dev, sizeof(struct mt7620_gsw), GFP_KERNEL);
+	if (!gsw)
+		return -ENOMEM;
+
+	gsw->base = devm_ioremap_resource(&pdev->dev, res);
+	if (!gsw->base)
+		return -EADDRNOTAVAIL;
+
+	gsw->dev = &pdev->dev;
+
+	of_property_read_string(np, "mediatek,port4", &port4);
+	if (port4 && !strcmp(port4, "ephy"))
+		gsw->port4 = PORT4_EPHY;
+	else if (port4 && !strcmp(port4, "mac"))
+		gsw->port4 = PORT4_EXT;
+	else
+		gsw->port4 = PORT4_EPHY;
+
+	gsw->irq = irq_of_parse_and_map(np, 0);
+
+	platform_set_drvdata(pdev, gsw);
+
+	return 0;
+}
+
+static int mt7620_gsw_remove(struct platform_device *pdev)
+{
+	platform_set_drvdata(pdev, NULL);
+
+	return 0;
+}
+
+static struct platform_driver gsw_driver = {
+	.probe = mt7620_gsw_probe,
+	.remove = mt7620_gsw_remove,
+	.driver = {
+		.name = "mt7620-gsw",
+		.owner = THIS_MODULE,
+		.of_match_table = mediatek_gsw_match,
+	},
+};
+
+module_platform_driver(gsw_driver);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>");
+MODULE_DESCRIPTION("GBit switch driver for Mediatek MT7620 SoC");
diff --git a/drivers/net/ethernet/mediatek/gsw_mt7620.h b/drivers/net/ethernet/mediatek/gsw_mt7620.h
new file mode 100644
index 0000000..1766939
--- /dev/null
+++ b/drivers/net/ethernet/mediatek/gsw_mt7620.h
@@ -0,0 +1,277 @@
+/*   This program is free software; you can redistribute it and/or modify
+ *   it under the terms of the GNU General Public License as published by
+ *   the Free Software Foundation; version 2 of the License
+ *
+ *   This program is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *   GNU General Public License for more details.
+ *
+ *   Copyright (C) 2009-2016 John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
+ *   Copyright (C) 2009-2016 Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
+ *   Copyright (C) 2013-2016 Michael Lee <igvtee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ */
+
+#ifndef _RALINK_GSW_MT7620_H__
+#define _RALINK_GSW_MT7620_H__
+
+#define GSW_REG_PHY_TIMEOUT	(5 * HZ)
+
+#define MT7620_GSW_REG_PIAC	0x0004
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
+#define SYSC_REG_CFG		0x10
+#define SYSC_REG_CFG1		0x14
+#define RST_CTRL_MCM		BIT(2)
+#define SYSC_PAD_RGMII2_MDIO	0x58
+#define SYSC_GPIO_MODE		0x60
+
+#define PORT_IRQ_ST_CHG		0x7f
+
+#define MT7621_ESW_PHY_POLLING	0x0000
+#define MT7620_ESW_PHY_POLLING	0x7000
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
+/* ethernet subsystem config register */
+#define ETHSYS_SYSCFG0		0x14
+/* ethernet subsystem clock register */
+#define ETHSYS_CLKCFG0		0x2c
+#define ETHSYS_TRGMII_CLK_SEL362_5	BIT(11)
+
+/* p5 RGMII wrapper TX clock control register */
+#define MT7530_P5RGMIITXCR	0x7b04
+/* p5 RGMII wrapper RX clock control register */
+#define MT7530_P5RGMIIRXCR	0x7b00
+/* TRGMII TDX ODT registers */
+#define MT7530_TRGMII_TD0_ODT	0x7a54
+#define MT7530_TRGMII_TD1_ODT	0x7a5c
+#define MT7530_TRGMII_TD2_ODT	0x7a64
+#define MT7530_TRGMII_TD3_ODT	0x7a6c
+#define MT7530_TRGMII_TD4_ODT	0x7a74
+#define MT7530_TRGMII_TD5_ODT	0x7a7c
+/* TRGMII TCK ctrl register */
+#define MT7530_TRGMII_TCK_CTRL	0x7a78
+/* TRGMII Tx ctrl register */
+#define MT7530_TRGMII_TXCTRL	0x7a40
+/* port 6 extended control register */
+#define MT7530_P6ECR            0x7830
+/* IO driver control register */
+#define MT7530_IO_DRV_CR	0x7810
+/* top signal control register */
+#define MT7530_TOP_SIG_CTRL	0x7808
+/* modified hwtrap register */
+#define MT7530_MHWTRAP		0x7804
+/* hwtrap status register */
+#define MT7530_HWTRAP		0x7800
+/* status interrupt register */
+#define MT7530_SYS_INT_STS	0x700c
+/* system nterrupt register */
+#define MT7530_SYS_INT_EN	0x7008
+/* system control register */
+#define MT7530_SYS_CTRL		0x7000
+/* port MAC status register */
+#define MT7530_PMSR_P(x)	(0x3008 + (x * 0x100))
+/* port MAC control register */
+#define MT7530_PMCR_P(x)	(0x3000 + (x * 0x100))
+
+#define MT7621_XTAL_SHIFT	6
+#define MT7621_XTAL_MASK	0x7
+#define MT7621_XTAL_25		6
+#define MT7621_XTAL_40		3
+#define MT7621_MDIO_DRV_MASK	(3 << 4)
+#define MT7621_GE1_MODE_MASK	(3 << 12)
+
+#define TRGMII_TXCTRL_TXC_INV	BIT(30)
+#define P6ECR_INTF_MODE_RGMII	BIT(1)
+#define P5RGMIIRXCR_C_ALIGN	BIT(8)
+#define P5RGMIIRXCR_DELAY_2	BIT(1)
+#define P5RGMIITXCR_DELAY_2	(BIT(8) | BIT(2))
+
+/* TOP_SIG_CTRL bits */
+#define TOP_SIG_CTRL_NORMAL	(BIT(17) | BIT(16))
+
+/* MHWTRAP bits */
+#define MHWTRAP_MANUAL		BIT(16)
+#define MHWTRAP_P5_MAC_SEL	BIT(13)
+#define MHWTRAP_P6_DIS		BIT(8)
+#define MHWTRAP_P5_RGMII_MODE	BIT(7)
+#define MHWTRAP_P5_DIS		BIT(6)
+#define MHWTRAP_PHY_ACCESS	BIT(5)
+
+/* HWTRAP bits */
+#define HWTRAP_XTAL_SHIFT	9
+#define HWTRAP_XTAL_MASK	0x3
+
+/* SYS_CTRL bits */
+#define SYS_CTRL_SW_RST		BIT(1)
+#define SYS_CTRL_REG_RST	BIT(0)
+
+/* PMCR bits */
+#define PMCR_IFG_XMIT_96	BIT(18)
+#define PMCR_MAC_MODE		BIT(16)
+#define PMCR_FORCE_MODE		BIT(15)
+#define PMCR_TX_EN		BIT(14)
+#define PMCR_RX_EN		BIT(13)
+#define PMCR_BACK_PRES_EN	BIT(9)
+#define PMCR_BACKOFF_EN		BIT(8)
+#define PMCR_TX_FC_EN		BIT(5)
+#define PMCR_RX_FC_EN		BIT(4)
+#define PMCR_FORCE_SPEED_1000	BIT(3)
+#define PMCR_FORCE_FDX		BIT(1)
+#define PMCR_FORCE_LNK		BIT(0)
+#define PMCR_FIXED_LINK		(PMCR_IFG_XMIT_96 | PMCR_MAC_MODE | \
+				 PMCR_FORCE_MODE | PMCR_TX_EN | PMCR_RX_EN | \
+				 PMCR_BACK_PRES_EN | PMCR_BACKOFF_EN | \
+				 PMCR_FORCE_SPEED_1000 | PMCR_FORCE_FDX | \
+				 PMCR_FORCE_LNK)
+
+#define PMCR_FIXED_LINK_FC	(PMCR_FIXED_LINK | \
+				 PMCR_TX_FC_EN | PMCR_RX_FC_EN)
+
+/* TRGMII control registers */
+#define GSW_INTF_MODE		0x390
+#define GSW_TRGMII_TD0_ODT	0x354
+#define GSW_TRGMII_TD1_ODT	0x35c
+#define GSW_TRGMII_TD2_ODT	0x364
+#define GSW_TRGMII_TD3_ODT	0x36c
+#define GSW_TRGMII_TXCTL_ODT	0x374
+#define GSW_TRGMII_TCK_ODT	0x37c
+#define GSW_TRGMII_RCK_CTRL	0x300
+
+#define INTF_MODE_TRGMII	BIT(1)
+#define TRGMII_RCK_CTRL_RX_RST	BIT(31)
+
+/* Mac control registers */
+#define MTK_MAC_P2_MCR		0x200
+#define MTK_MAC_P1_MCR		0x100
+
+#define MAC_MCR_MAX_RX_2K	BIT(29)
+#define MAC_MCR_IPG_CFG		(BIT(18) | BIT(16))
+#define MAC_MCR_FORCE_MODE	BIT(15)
+#define MAC_MCR_TX_EN		BIT(14)
+#define MAC_MCR_RX_EN		BIT(13)
+#define MAC_MCR_BACKOFF_EN	BIT(9)
+#define MAC_MCR_BACKPR_EN	BIT(8)
+#define MAC_MCR_FORCE_RX_FC	BIT(5)
+#define MAC_MCR_FORCE_TX_FC	BIT(4)
+#define MAC_MCR_SPEED_1000	BIT(3)
+#define MAC_MCR_FORCE_DPX	BIT(1)
+#define MAC_MCR_FORCE_LINK	BIT(0)
+#define MAC_MCR_FIXED_LINK	(MAC_MCR_MAX_RX_2K | MAC_MCR_IPG_CFG | \
+				 MAC_MCR_FORCE_MODE | MAC_MCR_TX_EN | \
+				 MAC_MCR_RX_EN | MAC_MCR_BACKOFF_EN | \
+				 MAC_MCR_BACKPR_EN | MAC_MCR_FORCE_RX_FC | \
+				 MAC_MCR_FORCE_TX_FC | MAC_MCR_SPEED_1000 | \
+				 MAC_MCR_FORCE_DPX | MAC_MCR_FORCE_LINK)
+#define MAC_MCR_FIXED_LINK_FC	(MAC_MCR_MAX_RX_2K | MAC_MCR_IPG_CFG | \
+				 MAC_MCR_FIXED_LINK)
+
+/* possible XTAL speed */
+#define	MT7623_XTAL_40		0
+#define MT7623_XTAL_20		1
+#define MT7623_XTAL_25		3
+
+/* GPIO port control registers */
+#define	GPIO_OD33_CTRL8		0x4c0
+#define	GPIO_BIAS_CTRL		0xed0
+#define GPIO_DRV_SEL10		0xf00
+
+/* on MT7620 the functio of port 4 can be software configured */
+enum {
+	PORT4_EPHY = 0,
+	PORT4_EXT,
+};
+
+/* struct mt7620_gsw -	the structure that holds the SoC specific data
+ * @dev:		The Device struct
+ * @base:		The base address
+ * @piac_offset:	The PIAC base may change depending on SoC
+ * @irq:		The IRQ we are using
+ * @port4:		The port4 mode on MT7620
+ * @autopoll:		Is MDIO autopolling enabled
+ * @ethsys:		The ethsys register map
+ * @pctl:		The pin control register map
+ * @clk_gsw:		The switch clock
+ * @clk_gp1:		The gmac1 clock
+ * @clk_gp2:		The gmac2 clock
+ * @clk_trgpll:		The trgmii pll clock
+ */
+struct mt7620_gsw {
+	struct device		*dev;
+	void __iomem		*base;
+	u32			piac_offset;
+	int			irq;
+	int			port4;
+	unsigned long int	autopoll;
+
+	struct regmap		*ethsys;
+	struct regmap		*pctl;
+
+	struct clk		*clk_gsw;
+	struct clk		*clk_gp1;
+	struct clk		*clk_gp2;
+	struct clk		*clk_trgpll;
+};
+
+/* switch register I/O wrappers */
+void mtk_switch_w32(struct mt7620_gsw *gsw, u32 val, unsigned reg);
+u32 mtk_switch_r32(struct mt7620_gsw *gsw, unsigned reg);
+
+/* the callback used by the driver core to bringup the switch */
+int mtk_gsw_init(struct mtk_eth *eth);
+
+/* MDIO access wrappers */
+int mt7620_mdio_write(struct mii_bus *bus, int phy_addr, int phy_reg, u16 val);
+int mt7620_mdio_read(struct mii_bus *bus, int phy_addr, int phy_reg);
+void mt7620_mdio_link_adjust(struct mtk_eth *eth, int port);
+int mt7620_has_carrier(struct mtk_eth *eth);
+void mt7620_print_link_state(struct mtk_eth *eth, int port, int link,
+			     int speed, int duplex);
+void mt7530_mdio_w32(struct mt7620_gsw *gsw, u32 reg, u32 val);
+u32 mt7530_mdio_r32(struct mt7620_gsw *gsw, u32 reg);
+void mt7530_mdio_m32(struct mt7620_gsw *gsw, u32 mask, u32 set, u32 reg);
+
+u32 _mt7620_mii_write(struct mt7620_gsw *gsw, u32 phy_addr,
+		      u32 phy_register, u32 write_data);
+u32 _mt7620_mii_read(struct mt7620_gsw *gsw, int phy_addr, int phy_reg);
+void mt7620_handle_carrier(struct mtk_eth *eth);
+
+#endif
diff --git a/drivers/net/ethernet/mediatek/gsw_mt7621.c b/drivers/net/ethernet/mediatek/gsw_mt7621.c
new file mode 100644
index 0000000..3e0a37f
--- /dev/null
+++ b/drivers/net/ethernet/mediatek/gsw_mt7621.c
@@ -0,0 +1,265 @@
+/*   This program is free software; you can redistribute it and/or modify
+ *   it under the terms of the GNU General Public License as published by
+ *   the Free Software Foundation; version 2 of the License
+ *
+ *   This program is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *   GNU General Public License for more details.
+ *
+ *   Copyright (C) 2009-2016 John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
+ *   Copyright (C) 2009-2016 Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
+ *   Copyright (C) 2013-2016 Michael Lee <igvtee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/platform_device.h>
+#include <linux/of_device.h>
+#include <linux/of_irq.h>
+
+#include <ralink_regs.h>
+
+#include "mtk_eth_soc.h"
+#include "gsw_mt7620.h"
+
+void mtk_switch_w32(struct mt7620_gsw *gsw, u32 val, unsigned reg)
+{
+	iowrite32(val, gsw->base + reg);
+}
+
+u32 mtk_switch_r32(struct mt7620_gsw *gsw, unsigned reg)
+{
+	return ioread32(gsw->base + reg);
+}
+
+static irqreturn_t gsw_interrupt_mt7621(int irq, void *_eth)
+{
+	struct mtk_eth *eth = (struct mtk_eth *)_eth;
+	struct mt7620_gsw *gsw = (struct mt7620_gsw *)eth->sw_priv;
+	u32 reg, i;
+
+	reg = mt7530_mdio_r32(gsw, MT7530_SYS_INT_STS);
+
+	for (i = 0; i < 5; i++) {
+		unsigned int link;
+
+		if ((reg & BIT(i)) == 0)
+			continue;
+
+		link = mt7530_mdio_r32(gsw, MT7530_PMSR_P(i)) & 0x1;
+
+		if (link == eth->link[i])
+			continue;
+
+		eth->link[i] = link;
+		if (link)
+			netdev_info(*eth->netdev,
+				    "port %d link up\n", i);
+		else
+			netdev_info(*eth->netdev,
+				    "port %d link down\n", i);
+	}
+
+	mt7530_mdio_w32(gsw, MT7530_SYS_INT_STS, 0x1f);
+
+	return IRQ_HANDLED;
+}
+
+static void mt7621_hw_init(struct mtk_eth *eth, struct mt7620_gsw *gsw,
+			   struct device_node *np)
+{
+	u32 i;
+	u32 val;
+
+	/* wardware reset the switch */
+	mtk_reset(eth, RST_CTRL_MCM);
+	mdelay(10);
+
+	/* reduce RGMII2 PAD driving strength */
+	rt_sysc_m32(MT7621_MDIO_DRV_MASK, 0, SYSC_PAD_RGMII2_MDIO);
+
+	/* set GMAC1 RGMII mode */
+	rt_sysc_m32(MT7621_GE1_MODE_MASK, 0, SYSC_REG_CFG1);
+
+	/* turn off all PHYs */
+	for (i = 0; i <= 4; i++) {
+		val = _mt7620_mii_read(gsw, i, 0x0);
+		val |= BIT(11);
+		_mt7620_mii_write(gsw, i, 0x0, val);
+	}
+
+	/* reset the switch */
+	mt7530_mdio_w32(gsw, MT7530_SYS_CTRL,
+			SYS_CTRL_SW_RST | SYS_CTRL_REG_RST);
+	usleep_range(10, 20);
+
+	if ((rt_sysc_r32(SYSC_REG_CHIP_REV_ID) & 0xFFFF) == 0x0101) {
+		/* GE1, Force 1000M/FD, FC ON, MAX_RX_LENGTH 1536 */
+		mtk_switch_w32(gsw, MAC_MCR_FIXED_LINK, MTK_MAC_P2_MCR);
+		mt7530_mdio_w32(gsw, MT7530_PMCR_P(6), PMCR_FIXED_LINK);
+	} else {
+		/* GE1, Force 1000M/FD, FC ON, MAX_RX_LENGTH 1536 */
+		mtk_switch_w32(gsw, MAC_MCR_FIXED_LINK_FC, MTK_MAC_P1_MCR);
+		mt7530_mdio_w32(gsw, MT7530_PMCR_P(6), PMCR_FIXED_LINK_FC);
+	}
+
+	/* GE2, Link down */
+	mtk_switch_w32(gsw, MAC_MCR_FORCE_MODE, MTK_MAC_P2_MCR);
+
+	/* Enable Port 6, P5 as GMAC5, P5 disable */
+	val = mt7530_mdio_r32(gsw, MT7530_MHWTRAP);
+	/* Enable Port 6 */
+	val &= ~MHWTRAP_P6_DIS;
+	/* Disable Port 5 */
+	val |= MHWTRAP_P5_DIS;
+	/* manual override of HW-Trap */
+	val |= MHWTRAP_MANUAL;
+	mt7530_mdio_w32(gsw, MT7530_MHWTRAP, val);
+
+	val = rt_sysc_r32(SYSC_REG_CFG);
+	val = (val >> MT7621_XTAL_SHIFT) & MT7621_XTAL_MASK;
+	if (val < MT7621_XTAL_25 && val >= MT7621_XTAL_40) {
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
+	}
+
+	/* RGMII */
+	_mt7620_mii_write(gsw, 0, 14, 0x1);
+
+	/* set MT7530 central align */
+	mt7530_mdio_w32(gsw, MT7530_P6ECR, P6ECR_INTF_MODE_RGMII);
+	mt7530_mdio_m32(gsw, TRGMII_TXCTRL_TXC_INV, 0,
+			MT7530_TRGMII_TXCTRL);
+	mt7530_mdio_w32(gsw, MT7530_TRGMII_TCK_CTRL, 0x855);
+
+	/* delay setting for 10/1000M */
+	mt7530_mdio_w32(gsw, MT7530_P5RGMIIRXCR,
+			P5RGMIIRXCR_C_ALIGN | P5RGMIIRXCR_DELAY_2);
+	mt7530_mdio_w32(gsw, MT7530_P5RGMIITXCR, P5RGMIITXCR_DELAY_2);
+
+	/* lower Tx Driving*/
+	mt7530_mdio_w32(gsw, MT7530_TRGMII_TD0_ODT, 0x44);
+	mt7530_mdio_w32(gsw, MT7530_TRGMII_TD0_ODT, 0x44);
+	mt7530_mdio_w32(gsw, MT7530_TRGMII_TD0_ODT, 0x44);
+	mt7530_mdio_w32(gsw, MT7530_TRGMII_TD0_ODT, 0x44);
+	mt7530_mdio_w32(gsw, MT7530_TRGMII_TD0_ODT, 0x44);
+	mt7530_mdio_w32(gsw, MT7530_TRGMII_TD0_ODT, 0x44);
+
+	/* turn on all PHYs */
+	for (i = 0; i <= 4; i++) {
+		val = _mt7620_mii_read(gsw, i, 0);
+		val &= ~BIT(11);
+		_mt7620_mii_write(gsw, i, 0, val);
+	}
+
+	/* enable irq */
+	mt7530_mdio_m32(gsw, 0, 3 << 16, MT7530_SYS_INT_EN);
+}
+
+static const struct of_device_id mediatek_gsw_match[] = {
+	{ .compatible = "mediatek,mt7621-gsw" },
+	{},
+};
+MODULE_DEVICE_TABLE(of, mediatek_gsw_match);
+
+int mtk_gsw_init(struct mtk_eth *eth)
+{
+	struct device_node *np = eth->switch_np;
+	struct platform_device *pdev = of_find_device_by_node(np);
+	struct mt7620_gsw *gsw;
+
+	if (!pdev)
+		return -ENODEV;
+
+	if (!of_device_is_compatible(np, mediatek_gsw_match->compatible))
+		return -EINVAL;
+
+	gsw = platform_get_drvdata(pdev);
+	eth->sw_priv = gsw;
+
+	mt7621_hw_init(eth, gsw, np);
+
+	if (gsw->irq) {
+		request_irq(gsw->irq, gsw_interrupt_mt7621, 0,
+			    "gsw", eth);
+		mt7530_mdio_w32(gsw, MT7530_SYS_INT_EN, 0x1f);
+	}
+
+	return 0;
+}
+
+static int mt7621_gsw_probe(struct platform_device *pdev)
+{
+	struct resource *res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	struct mt7620_gsw *gsw;
+
+	gsw = devm_kzalloc(&pdev->dev, sizeof(struct mt7620_gsw), GFP_KERNEL);
+	if (!gsw)
+		return -ENOMEM;
+
+	gsw->base = devm_ioremap_resource(&pdev->dev, res);
+	if (!gsw->base)
+		return -EADDRNOTAVAIL;
+
+	gsw->dev = &pdev->dev;
+	gsw->irq = irq_of_parse_and_map(pdev->dev.of_node, 0);
+
+	platform_set_drvdata(pdev, gsw);
+
+	return 0;
+}
+
+static int mt7621_gsw_remove(struct platform_device *pdev)
+{
+	platform_set_drvdata(pdev, NULL);
+
+	return 0;
+}
+
+static struct platform_driver gsw_driver = {
+	.probe = mt7621_gsw_probe,
+	.remove = mt7621_gsw_remove,
+	.driver = {
+		.name = "mt7621-gsw",
+		.owner = THIS_MODULE,
+		.of_match_table = mediatek_gsw_match,
+	},
+};
+
+module_platform_driver(gsw_driver);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>");
+MODULE_DESCRIPTION("GBit switch driver for Mediatek MT7621 SoC");
diff --git a/drivers/net/ethernet/mediatek/gsw_mt7623.c b/drivers/net/ethernet/mediatek/gsw_mt7623.c
new file mode 100644
index 0000000..a64bae1
--- /dev/null
+++ b/drivers/net/ethernet/mediatek/gsw_mt7623.c
@@ -0,0 +1,417 @@
+/*   This program is free software; you can redistribute it and/or modify
+ *   it under the terms of the GNU General Public License as published by
+ *   the Free Software Foundation; version 2 of the License
+ *
+ *   This program is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *   GNU General Public License for more details.
+ *
+ *   Copyright (C) 2009-2016 John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
+ *   Copyright (C) 2009-2016 Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
+ *   Copyright (C) 2013-2016 Michael Lee <igvtee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/platform_device.h>
+#include <linux/of_device.h>
+#include <linux/of_irq.h>
+#include <linux/of_gpio.h>
+#include <linux/clk.h>
+#include <linux/mfd/syscon.h>
+#include <linux/regulator/consumer.h>
+#include <linux/pm_runtime.h>
+#include <linux/regmap.h>
+
+#include "mtk_eth_soc.h"
+#include "gsw_mt7620.h"
+
+void mtk_switch_w32(struct mt7620_gsw *gsw, u32 val, unsigned reg)
+{
+	iowrite32(val, gsw->base + reg);
+}
+
+u32 mtk_switch_r32(struct mt7620_gsw *gsw, unsigned reg)
+{
+	return ioread32(gsw->base + reg);
+}
+
+void mtk_switch_m32(struct mt7620_gsw *gsw, u32 mask, u32 set, unsigned reg)
+{
+	u32 val = ioread32(gsw->base + reg);
+
+	val &= mask;
+	val |= set;
+
+	iowrite32(val, gsw->base + reg);
+}
+
+static irqreturn_t gsw_interrupt_mt7623(int irq, void *_eth)
+{
+	struct mtk_eth *eth = (struct mtk_eth *)_eth;
+	struct mt7620_gsw *gsw = (struct mt7620_gsw *)eth->sw_priv;
+	u32 reg, i;
+
+	reg = mt7530_mdio_r32(gsw, MT7530_SYS_INT_STS);
+
+	for (i = 0; i < 5; i++) {
+		unsigned int link;
+
+		if ((reg & BIT(i)) == 0)
+			continue;
+
+		link = mt7530_mdio_r32(gsw, MT7530_PMSR_P(i)) & 0x1;
+
+		if (link == eth->link[i])
+			continue;
+
+		eth->link[i] = link;
+		if (link)
+			dev_info(gsw->dev, "port %d link up\n", i);
+		else
+			dev_info(gsw->dev, "port %d link down\n", i);
+	}
+
+	mt7530_mdio_w32(gsw, MT7530_SYS_INT_STS, 0x1f);
+
+	return IRQ_HANDLED;
+}
+
+static void mt7623_hw_init(struct mtk_eth *eth, struct mt7620_gsw *gsw,
+			   struct device_node *np)
+{
+	u32 i;
+	u32 val, reg;
+	u32 xtal_mode;
+
+	regmap_update_bits(gsw->ethsys, ETHSYS_CLKCFG0,
+			   ETHSYS_TRGMII_CLK_SEL362_5,
+			   ETHSYS_TRGMII_CLK_SEL362_5);
+
+	/* reset the TRGMII core */
+	mtk_switch_m32(gsw, 0, INTF_MODE_TRGMII, GSW_INTF_MODE);
+	mtk_switch_m32(gsw, 0, TRGMII_RCK_CTRL_RX_RST, GSW_TRGMII_RCK_CTRL);
+
+	/* Hardware reset Switch */
+	mtk_reset(eth, RST_CTRL_MCM);
+
+	/* Wait for Switch Reset Completed*/
+	for (i = 0; i < 100; i++) {
+		mdelay(10);
+		if (mt7530_mdio_r32(gsw, MT7530_HWTRAP))
+			break;
+	}
+
+	/* turn off all PHYs */
+	for (i = 0; i <= 4; i++) {
+		val = _mt7620_mii_read(gsw, i, 0x0);
+		val |= BIT(11);
+		_mt7620_mii_write(gsw, i, 0x0, val);
+	}
+
+	/* reset the switch */
+	mt7530_mdio_w32(gsw, MT7530_SYS_CTRL,
+			SYS_CTRL_SW_RST | SYS_CTRL_REG_RST);
+	udelay(100);
+
+	/* GE1, Force 1000M/FD, FC ON */
+	mtk_switch_w32(gsw, MAC_MCR_FIXED_LINK_FC, MTK_MAC_P1_MCR);
+	mt7530_mdio_w32(gsw, MT7530_PMCR_P(6), PMCR_FIXED_LINK_FC);
+
+	/* GE2, Force 1000M/FD, FC ON */
+	mtk_switch_w32(gsw, MAC_MCR_FIXED_LINK_FC, MTK_MAC_P2_MCR);
+	mt7530_mdio_w32(gsw, MT7530_PMCR_P(5), PMCR_FIXED_LINK_FC);
+
+	regmap_read(gsw->ethsys, ETHSYS_SYSCFG0, &reg);
+	/* clear the GE2_MODE bits, setting the port to RGMII */
+	reg &= ~(0x3 << 14);
+	/* clear the GE1_MODE bits, setting the port to RGMII */
+	reg &= ~(0x3 << 12);
+	regmap_write(gsw->ethsys, ETHSYS_SYSCFG0, reg);
+
+	/* Enable Port 6, P5 as GMAC5, P5 disable */
+	val = mt7530_mdio_r32(gsw, MT7530_MHWTRAP);
+	/* Enable Port 6 */
+	val &= ~MHWTRAP_P6_DIS;
+	/* Enable Port 5 */
+	val &= ~MHWTRAP_P5_DIS;
+	/* Port 5 as GMAC */
+	val |= MHWTRAP_P5_MAC_SEL;
+	/* Port 5 Interface mode */
+	val |= MHWTRAP_P5_RGMII_MODE;
+	/* Set MT7530 phy direct access mode**/
+	val &= ~MHWTRAP_PHY_ACCESS;
+	/* manual override of HW-Trap */
+	val |= MHWTRAP_MANUAL;
+	mt7530_mdio_w32(gsw, MT7530_MHWTRAP, val);
+
+	xtal_mode = mt7530_mdio_r32(gsw, MT7530_HWTRAP);
+	xtal_mode >>= HWTRAP_XTAL_SHIFT;
+	xtal_mode &= HWTRAP_XTAL_MASK;
+	if (xtal_mode == MT7623_XTAL_40) {
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
+		udelay(20);
+
+		/* enable MT7530 core clock */
+		_mt7620_mii_write(gsw, 0, 13, 0x1f);
+		_mt7620_mii_write(gsw, 0, 14, 0x410);
+		_mt7620_mii_write(gsw, 0, 13, 0x401f);
+	}
+
+	/* RGMII */
+	_mt7620_mii_write(gsw, 0, 14, 0x1);
+
+	/* set MT7530 central align */
+	mt7530_mdio_m32(gsw, ~BIT(0), BIT(1), MT7530_P6ECR);
+	mt7530_mdio_m32(gsw, ~BIT(30), 0, MT7530_TRGMII_TXCTRL);
+	mt7530_mdio_w32(gsw, MT7530_TRGMII_TCK_CTRL, 0x855);
+
+	/* delay setting for 10/1000M */
+	mt7530_mdio_w32(gsw, MT7530_P5RGMIIRXCR, 0x104);
+	mt7530_mdio_w32(gsw, MT7530_P5RGMIITXCR, 0x10);
+
+	/* lower Tx Driving */
+	mt7530_mdio_w32(gsw, MT7530_TRGMII_TD0_ODT, 0x88);
+	mt7530_mdio_w32(gsw, MT7530_TRGMII_TD1_ODT, 0x88);
+	mt7530_mdio_w32(gsw, MT7530_TRGMII_TD2_ODT, 0x88);
+	mt7530_mdio_w32(gsw, MT7530_TRGMII_TD3_ODT, 0x88);
+	mt7530_mdio_w32(gsw, MT7530_TRGMII_TD4_ODT, 0x88);
+	mt7530_mdio_w32(gsw, MT7530_TRGMII_TD5_ODT, 0x88);
+	mt7530_mdio_w32(gsw, MT7530_IO_DRV_CR, 0x11);
+
+	/* Set MT7623/MT7683 TX Driving */
+	mtk_switch_w32(gsw, 0x88, GSW_TRGMII_TD0_ODT);
+	mtk_switch_w32(gsw, 0x88, GSW_TRGMII_TD0_ODT);
+	mtk_switch_w32(gsw, 0x88, GSW_TRGMII_TD0_ODT);
+	mtk_switch_w32(gsw, 0x88, GSW_TRGMII_TD0_ODT);
+	mtk_switch_w32(gsw, 0x88, GSW_TRGMII_TXCTL_ODT);
+	mtk_switch_w32(gsw, 0x88, GSW_TRGMII_TCK_ODT);
+
+	/* disable EEE */
+	for (i = 0; i <= 4; i++) {
+		_mt7620_mii_write(gsw, i, 13, 0x7);
+		_mt7620_mii_write(gsw, i, 14, 0x3C);
+		_mt7620_mii_write(gsw, i, 13, 0x4007);
+		_mt7620_mii_write(gsw, i, 14, 0x0);
+
+		/* Increase SlvDPSready time */
+		_mt7620_mii_write(gsw, i, 31, 0x52b5);
+		_mt7620_mii_write(gsw, i, 16, 0xafae);
+		_mt7620_mii_write(gsw, i, 18, 0x2f);
+		_mt7620_mii_write(gsw, i, 16, 0x8fae);
+
+		/* Incease post_update_timer */
+		_mt7620_mii_write(gsw, i, 31, 0x3);
+		_mt7620_mii_write(gsw, i, 17, 0x4b);
+
+		/* Adjust 100_mse_threshold */
+		_mt7620_mii_write(gsw, i, 13, 0x1e);
+		_mt7620_mii_write(gsw, i, 14, 0x123);
+		_mt7620_mii_write(gsw, i, 13, 0x401e);
+		_mt7620_mii_write(gsw, i, 14, 0xffff);
+
+		/* Disable mcc */
+		_mt7620_mii_write(gsw, i, 13, 0x1e);
+		_mt7620_mii_write(gsw, i, 14, 0xa6);
+		_mt7620_mii_write(gsw, i, 13, 0x401e);
+		_mt7620_mii_write(gsw, i, 14, 0x300);
+
+		/* Disable HW auto downshift*/
+		_mt7620_mii_write(gsw, i, 31, 0x1);
+		val = _mt7620_mii_read(gsw, i, 0x14);
+		val &= ~BIT(4);
+		_mt7620_mii_write(gsw, i, 0x14, val);
+	}
+
+	/* turn on all PHYs */
+	for (i = 0; i <= 4; i++) {
+		val = _mt7620_mii_read(gsw, i, 0);
+		val &= ~BIT(11);
+		_mt7620_mii_write(gsw, i, 0, val);
+	}
+
+	/* enable irq */
+	mt7530_mdio_m32(gsw, 0, TOP_SIG_CTRL_NORMAL, MT7530_TOP_SIG_CTRL);
+}
+
+static const struct of_device_id mediatek_gsw_match[] = {
+	{ .compatible = "mediatek,mt7623-gsw" },
+	{},
+};
+MODULE_DEVICE_TABLE(of, mediatek_gsw_match);
+
+int mtk_gsw_init(struct mtk_eth *eth)
+{
+	struct device_node *np = eth->switch_np;
+	struct platform_device *pdev = of_find_device_by_node(np);
+	struct mt7620_gsw *gsw;
+
+	if (!pdev)
+		return -ENODEV;
+
+	if (!of_device_is_compatible(np, mediatek_gsw_match->compatible))
+		return -EINVAL;
+
+	gsw = platform_get_drvdata(pdev);
+	if (!gsw)
+		return -ENODEV;
+	eth->sw_priv = gsw;
+
+	mt7623_hw_init(eth, gsw, np);
+
+	request_threaded_irq(gsw->irq, gsw_interrupt_mt7623, NULL, 0,
+			     "gsw", eth);
+	mt7530_mdio_w32(gsw, MT7530_SYS_INT_EN, 0x1f);
+
+	return 0;
+}
+
+static int mt7623_gsw_probe(struct platform_device *pdev)
+{
+	struct resource *res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	struct device_node *np = pdev->dev.of_node;
+	struct device_node *pctl;
+	int reset_pin, ret;
+	struct mt7620_gsw *gsw;
+	struct regulator *supply;
+
+	gsw = devm_kzalloc(&pdev->dev, sizeof(struct mt7620_gsw), GFP_KERNEL);
+	if (!gsw)
+		return -ENOMEM;
+
+	gsw->dev = &pdev->dev;
+	gsw->irq = irq_of_parse_and_map(np, 0);
+	if (gsw->irq < 0)
+		return -EINVAL;
+
+	gsw->base = devm_ioremap_resource(&pdev->dev, res);
+	if (!gsw->base)
+		return -EADDRNOTAVAIL;
+
+	gsw->ethsys = syscon_regmap_lookup_by_phandle(np, "mediatek,ethsys");
+	if (IS_ERR(gsw->ethsys))
+		return PTR_ERR(gsw->ethsys);
+
+	reset_pin = of_get_named_gpio(np, "mediatek,reset-pin", 0);
+	if (reset_pin < 0)
+		return reset_pin;
+
+	pctl = of_parse_phandle(np, "mediatek,pctl-regmap", 0);
+	if (IS_ERR(pctl))
+		return PTR_ERR(pctl);
+
+	gsw->pctl = syscon_node_to_regmap(pctl);
+	if (IS_ERR(pctl))
+		return PTR_ERR(pctl);
+
+	ret = devm_gpio_request(&pdev->dev, reset_pin, "mt7530-reset");
+	if (ret)
+		return ret;
+
+	gsw->clk_gsw = devm_clk_get(&pdev->dev, "esw");
+	gsw->clk_gp1 = devm_clk_get(&pdev->dev, "gp1");
+	gsw->clk_gp2 = devm_clk_get(&pdev->dev, "gp2");
+	gsw->clk_trgpll = devm_clk_get(&pdev->dev, "trgpll");
+
+	if (IS_ERR(gsw->clk_gsw) || IS_ERR(gsw->clk_gp1) ||
+	    IS_ERR(gsw->clk_gp2) || IS_ERR(gsw->clk_trgpll))
+		return -ENODEV;
+
+	supply = devm_regulator_get(&pdev->dev, "mt7530");
+	if (IS_ERR(supply))
+		return PTR_ERR(supply);
+
+	regulator_set_voltage(supply, 1000000, 1000000);
+	ret = regulator_enable(supply);
+	if (ret) {
+		dev_err(&pdev->dev, "Failed to enable reg-7530: %d\n", ret);
+		return ret;
+	}
+	pm_runtime_enable(&pdev->dev);
+	pm_runtime_get_sync(&pdev->dev);
+
+	ret = clk_set_rate(gsw->clk_trgpll, 500000000);
+	if (ret)
+		return ret;
+
+	clk_prepare_enable(gsw->clk_gsw);
+	clk_prepare_enable(gsw->clk_gp1);
+	clk_prepare_enable(gsw->clk_gp2);
+	clk_prepare_enable(gsw->clk_trgpll);
+
+	gpio_direction_output(reset_pin, 0);
+	udelay(1000);
+	gpio_set_value(reset_pin, 1);
+	mdelay(100);
+
+	/* Set GE2 driving and slew rate */
+	regmap_write(gsw->pctl, GPIO_DRV_SEL10, 0xa00);
+
+	/* set GE2 TDSEL */
+	regmap_write(gsw->pctl, GPIO_OD33_CTRL8, 0x5);
+
+	/* set GE2 TUNE */
+	regmap_write(gsw->pctl, GPIO_BIAS_CTRL, 0x0);
+
+	platform_set_drvdata(pdev, gsw);
+
+	return 0;
+}
+
+static int mt7623_gsw_remove(struct platform_device *pdev)
+{
+	struct mt7620_gsw *gsw = platform_get_drvdata(pdev);
+
+	clk_disable_unprepare(gsw->clk_gsw);
+	clk_disable_unprepare(gsw->clk_gp1);
+	clk_disable_unprepare(gsw->clk_gp2);
+	clk_disable_unprepare(gsw->clk_trgpll);
+
+	pm_runtime_put_sync(&pdev->dev);
+	pm_runtime_disable(&pdev->dev);
+
+	platform_set_drvdata(pdev, NULL);
+
+	return 0;
+}
+
+static struct platform_driver gsw_driver = {
+	.probe = mt7623_gsw_probe,
+	.remove = mt7623_gsw_remove,
+	.driver = {
+		.name = "mt7623-gsw",
+		.owner = THIS_MODULE,
+		.of_match_table = mediatek_gsw_match,
+	},
+};
+
+module_platform_driver(gsw_driver);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>");
+MODULE_DESCRIPTION("GBit switch driver for Mediatek MT7623 SoC");
-- 
1.7.10.4
