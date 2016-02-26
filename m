From: John Crispin <blogic@openwrt.org>
Subject: [PATCH V2 05/12] net-next: mediatek: add support for rt2880
Date: Fri, 26 Feb 2016 15:21:37 +0100
Message-ID: <1456496504-50429-6-git-send-email-blogic@openwrt.org>
References: <1456496504-50429-1-git-send-email-blogic@openwrt.org>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
	Matthias Brugger <matthias.bgg@gmail.com>,
	=?UTF-8?q?Steven=20Liu=20=28=E5=8A=89=E4=BA=BA=E8=B1=AA=29?=
	<steven.liu@mediatek.com>,
	=?UTF-8?q?Carlos=20Huang=20=28=E9=BB=83=E5=A3=AB=E5=BD=B0=29?=
	<Carlos.Huang@mediatek.com>,
	=?UTF-8?q?Fred=20Chang=20=28=E5=BC=B5=E5=98=89=E5=AE=8F=29?=
	<Fred.Chang@mediatek.com>, John Crispin <blogic@openwrt.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Lee <igvtee@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456496504-50429-1-git-send-email-blogic@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rt2880 is the oldest SoC with this core. It has a single gBit port that
will normally be attached to an external phy or switch. The patch also
adds the code required to drive the mdio bus os these SoCs. According to
the datasheet, this SoC has has checksum offloading and 2 byte dma padding.
On device testing has however shown that this does not work reliably so we
do not enable it.

Signed-off-by: John Crispin <blogic@openwrt.org>
Signed-off-by: Felix Fietkau <nbd@openwrt.org>
Signed-off-by: Michael Lee <igvtee@gmail.com>
---
 drivers/net/ethernet/mediatek/mdio_rt2880.c |  224 +++++++++++++++++++++++++++
 drivers/net/ethernet/mediatek/mdio_rt2880.h |   24 +++
 drivers/net/ethernet/mediatek/soc_rt2880.c  |   71 +++++++++
 3 files changed, 319 insertions(+)
 create mode 100644 drivers/net/ethernet/mediatek/mdio_rt2880.c
 create mode 100644 drivers/net/ethernet/mediatek/mdio_rt2880.h
 create mode 100644 drivers/net/ethernet/mediatek/soc_rt2880.c

diff --git a/drivers/net/ethernet/mediatek/mdio_rt2880.c b/drivers/net/ethernet/mediatek/mdio_rt2880.c
new file mode 100644
index 0000000..25db957
--- /dev/null
+++ b/drivers/net/ethernet/mediatek/mdio_rt2880.c
@@ -0,0 +1,224 @@
+/*   This program is free software; you can redistribute it and/or modify
+ *   it under the terms of the GNU General Public License as published by
+ *   the Free Software Foundation; version 2 of the License
+ *
+ *   This program is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *   GNU General Public License for more details.
+ *
+ *   Copyright (C) 2009-2016 John Crispin <blogic@openwrt.org>
+ *   Copyright (C) 2009-2016 Felix Fietkau <nbd@openwrt.org>
+ *   Copyright (C) 2013-2016 Michael Lee <igvtee@gmail.com>
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/of_net.h>
+#include <linux/of_mdio.h>
+
+#include "mtk_eth_soc.h"
+#include "mdio_rt2880.h"
+#include "mdio.h"
+
+#define MTK_MDIO_RETRY	1000
+
+static unsigned char *rt2880_speed_str(struct mtk_eth *eth)
+{
+	switch (eth->phy->speed[0]) {
+	case SPEED_1000:
+		return "1000";
+	case SPEED_100:
+		return "100";
+	case SPEED_10:
+		return "10";
+	}
+
+	return "?";
+}
+
+void rt2880_mdio_link_adjust(struct mtk_eth *eth, int port)
+{
+	u32 mdio_cfg;
+
+	if (!eth->link[0]) {
+		netif_carrier_off(*eth->netdev);
+		netdev_info(*eth->netdev, "link down\n");
+		return;
+	}
+
+	mdio_cfg = MTK_MDIO_CFG_TX_CLK_SKEW_200 |
+		   MTK_MDIO_CFG_RX_CLK_SKEW_200 |
+		   MTK_MDIO_CFG_GP1_FRC_EN;
+
+	if (eth->phy->duplex[0] == DUPLEX_FULL)
+		mdio_cfg |= MTK_MDIO_CFG_GP1_DUPLEX;
+
+	if (eth->phy->tx_fc[0])
+		mdio_cfg |= MTK_MDIO_CFG_GP1_FC_TX;
+
+	if (eth->phy->rx_fc[0])
+		mdio_cfg |= MTK_MDIO_CFG_GP1_FC_RX;
+
+	switch (eth->phy->speed[0]) {
+	case SPEED_10:
+		mdio_cfg |= MTK_MDIO_CFG_GP1_SPEED_10;
+		break;
+	case SPEED_100:
+		mdio_cfg |= MTK_MDIO_CFG_GP1_SPEED_100;
+		break;
+	case SPEED_1000:
+		mdio_cfg |= MTK_MDIO_CFG_GP1_SPEED_1000;
+		break;
+	default:
+		netdev_err(*eth->netdev, "unknown link speed\n");
+		return;
+	}
+
+	mtk_w32(eth, mdio_cfg, MTK_MDIO_CFG);
+
+	netif_carrier_on(*eth->netdev);
+	netdev_info(*eth->netdev, "link up (%sMbps/%s duplex)\n",
+		    rt2880_speed_str(eth),
+		    (eth->phy->duplex[0] == DUPLEX_FULL) ? "Full" : "Half");
+}
+
+static int rt2880_mdio_wait_ready(struct mtk_eth *eth)
+{
+	int retries;
+
+	retries = MTK_MDIO_RETRY;
+	while (1) {
+		u32 t;
+
+		t = mtk_r32(eth, MTK_MDIO_ACCESS);
+		if ((t & BIT(31)) == 0)
+			return 0;
+
+		if (retries-- == 0)
+			break;
+
+		udelay(1);
+	}
+
+	dev_err(eth->dev, "MDIO operation timed out\n");
+	return -ETIMEDOUT;
+}
+
+int rt2880_mdio_read(struct mii_bus *bus, int phy_addr, int phy_reg)
+{
+	struct mtk_eth *eth = bus->priv;
+	int err;
+	u32 t;
+
+	err = rt2880_mdio_wait_ready(eth);
+	if (err)
+		return 0xffff;
+
+	t = (phy_addr << 24) | (phy_reg << 16);
+	mtk_w32(eth, t, MTK_MDIO_ACCESS);
+	t |= BIT(31);
+	mtk_w32(eth, t, MTK_MDIO_ACCESS);
+
+	err = rt2880_mdio_wait_ready(eth);
+	if (err)
+		return 0xffff;
+
+	pr_debug("%s: addr=%04x, reg=%04x, value=%04x\n", __func__,
+		 phy_addr, phy_reg, mtk_r32(eth, MTK_MDIO_ACCESS) & 0xffff);
+
+	return mtk_r32(eth, MTK_MDIO_ACCESS) & 0xffff;
+}
+
+int rt2880_mdio_write(struct mii_bus *bus, int phy_addr, int phy_reg, u16 val)
+{
+	struct mtk_eth *eth = bus->priv;
+	int err;
+	u32 t;
+
+	pr_debug("%s: addr=%04x, reg=%04x, value=%04x\n", __func__,
+		 phy_addr, phy_reg, mtk_r32(eth, MTK_MDIO_ACCESS) & 0xffff);
+
+	err = rt2880_mdio_wait_ready(eth);
+	if (err)
+		return err;
+
+	t = (1 << 30) | (phy_addr << 24) | (phy_reg << 16) | val;
+	mtk_w32(eth, t, MTK_MDIO_ACCESS);
+	t |= BIT(31);
+	mtk_w32(eth, t, MTK_MDIO_ACCESS);
+
+	return rt2880_mdio_wait_ready(eth);
+}
+
+void rt2880_port_init(struct mtk_eth *eth, struct mtk_mac *mac,
+		      struct device_node *np)
+{
+	const __be32 *id = of_get_property(np, "reg", NULL);
+	const __be32 *link;
+	int size;
+	int phy_mode;
+
+	if (!id || (be32_to_cpu(*id) != 0)) {
+		pr_err("%s: invalid port id\n", np->name);
+		return;
+	}
+
+	eth->phy->phy_fixed[0] = of_get_property(np,
+						  "mediatek,fixed-link", &size);
+	if (eth->phy->phy_fixed[0] &&
+	    (size != (4 * sizeof(*eth->phy->phy_fixed[0])))) {
+		pr_err("%s: invalid fixed link property\n", np->name);
+		eth->phy->phy_fixed[0] = NULL;
+		return;
+	}
+
+	phy_mode = of_get_phy_mode(np);
+	switch (phy_mode) {
+	case PHY_INTERFACE_MODE_RGMII:
+		break;
+	case PHY_INTERFACE_MODE_MII:
+		break;
+	case PHY_INTERFACE_MODE_RMII:
+		break;
+	default:
+		if (!eth->phy->phy_fixed[0])
+			dev_err(eth->dev, "port %d - invalid phy mode\n",
+				eth->phy->speed[0]);
+		break;
+	}
+
+	eth->phy->phy_node[0] = of_parse_phandle(np, "phy-handle", 0);
+	if (!eth->phy->phy_node[0] && !eth->phy->phy_fixed[0])
+		return;
+
+	if (eth->phy->phy_fixed[0]) {
+		link = eth->phy->phy_fixed[0];
+		eth->phy->speed[0] = be32_to_cpup(link++);
+		eth->phy->duplex[0] = be32_to_cpup(link++);
+		eth->phy->tx_fc[0] = be32_to_cpup(link++);
+		eth->phy->rx_fc[0] = be32_to_cpup(link++);
+
+		eth->link[0] = 1;
+		switch (eth->phy->speed[0]) {
+		case SPEED_10:
+			break;
+		case SPEED_100:
+			break;
+		case SPEED_1000:
+			break;
+		default:
+			dev_err(eth->dev, "invalid link speed: %d\n",
+				eth->phy->speed[0]);
+			eth->phy->phy_fixed[0] = 0;
+			return;
+		}
+		dev_info(eth->dev, "using fixed link parameters\n");
+		rt2880_mdio_link_adjust(eth, 0);
+		return;
+	}
+
+	if (eth->phy->phy_node[0] && eth->mii_bus->phy_map[0])
+		mtk_connect_phy_node(eth, mac, eth->phy->phy_node[0]);
+}
diff --git a/drivers/net/ethernet/mediatek/mdio_rt2880.h b/drivers/net/ethernet/mediatek/mdio_rt2880.h
new file mode 100644
index 0000000..26f273d
--- /dev/null
+++ b/drivers/net/ethernet/mediatek/mdio_rt2880.h
@@ -0,0 +1,24 @@
+/*   This program is free software; you can redistribute it and/or modify
+ *   it under the terms of the GNU General Public License as published by
+ *   the Free Software Foundation; version 2 of the License
+ *
+ *   This program is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *   GNU General Public License for more details.
+ *
+ *   Copyright (C) 2009-2016 John Crispin <blogic@openwrt.org>
+ *   Copyright (C) 2009-2016 Felix Fietkau <nbd@openwrt.org>
+ *   Copyright (C) 2013-2016 Michael Lee <igvtee@gmail.com>
+ */
+
+#ifndef _RALINK_MDIO_RT2880_H__
+#define _RALINK_MDIO_RT2880_H__
+
+void rt2880_mdio_link_adjust(struct mtk_eth *eth, int port);
+int rt2880_mdio_read(struct mii_bus *bus, int phy_addr, int phy_reg);
+int rt2880_mdio_write(struct mii_bus *bus, int phy_addr, int phy_reg, u16 val);
+void rt2880_port_init(struct mtk_eth *eth, struct mtk_mac *mac,
+		      struct device_node *np);
+
+#endif
diff --git a/drivers/net/ethernet/mediatek/soc_rt2880.c b/drivers/net/ethernet/mediatek/soc_rt2880.c
new file mode 100644
index 0000000..854d5a7
--- /dev/null
+++ b/drivers/net/ethernet/mediatek/soc_rt2880.c
@@ -0,0 +1,71 @@
+/*   This program is free software; you can redistribute it and/or modify
+ *   it under the terms of the GNU General Public License as published by
+ *   the Free Software Foundation; version 2 of the License
+ *
+ *   This program is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *   GNU General Public License for more details.
+ *
+ *   Copyright (C) 2009-2016 John Crispin <blogic@openwrt.org>
+ *   Copyright (C) 2009-2016 Felix Fietkau <nbd@openwrt.org>
+ *   Copyright (C) 2013-2016 Michael Lee <igvtee@gmail.com>
+ */
+
+#include <linux/module.h>
+
+#include <asm/mach-ralink/ralink_regs.h>
+
+#include "mtk_eth_soc.h"
+#include "mdio_rt2880.h"
+
+#define RT2880_RESET_FE			BIT(18)
+
+void rt2880_mtk_reset(struct mtk_eth *eth)
+{
+	mtk_reset(eth, RT2880_RESET_FE);
+}
+
+static int rt2880_fwd_config(struct mtk_eth *eth)
+{
+	int ret;
+
+	ret = mtk_set_clock_cycle(eth);
+	if (ret)
+		return ret;
+
+	mtk_fwd_config(eth);
+	mtk_w32(eth, MTK_PSE_FQFC_CFG_INIT, MTK_PSE_FQ_CFG);
+	mtk_csum_config(eth);
+
+	return ret;
+}
+
+struct mtk_soc_data rt2880_data = {
+	.hw_features = NETIF_F_SG | NETIF_F_HW_VLAN_CTAG_TX,
+	.dma_type = MTK_PDMA,
+	.dma_ring_size = 128,
+	.napi_weight = 32,
+	.padding_64b = 1,
+	.padding_bug = 1,
+	.mac_count = 1,
+	.txd4 = TX_DMA_DESP4_DEF,
+	.reset_fe = rt2880_mtk_reset,
+	.fwd_config = rt2880_fwd_config,
+	.pdma_glo_cfg = MTK_PDMA_SIZE_8DWORDS,
+	.checksum_bit = RX_DMA_L4VALID,
+	.rx_int = MTK_RX_DONE_INT,
+	.tx_int = MTK_TX_DONE_INT,
+	.status_int = MTK_CNT_GDM_AF,
+	.mdio_read = rt2880_mdio_read,
+	.mdio_write = rt2880_mdio_write,
+	.mdio_adjust_link = rt2880_mdio_link_adjust,
+	.port_init = rt2880_port_init,
+};
+
+const struct of_device_id of_mtk_match[] = {
+	{ .compatible = "ralink,rt2880-eth", .data = &rt2880_data },
+	{},
+};
+
+MODULE_DEVICE_TABLE(of, of_mtk_match);
-- 
1.7.10.4
