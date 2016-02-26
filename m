From: John Crispin <blogic@openwrt.org>
Subject: [PATCH V2 07/12] net-next: mediatek: add support for rt3883
Date: Fri, 26 Feb 2016 15:21:39 +0100
Message-ID: <1456496504-50429-8-git-send-email-blogic@openwrt.org>
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

Add support for rt3883 and its smaller version rt3662. They both have a
single gBit port that will normally be attached to an external phy or
switch. There are not many rt3883 based routers in the field. I think
there is a second MAC on these SoCs. Due to lack of hardware utilizing this
I never added support. RT3883 is somewhat unique as it is the only SoC made
by Ralink that uses the mips74 core.

Signed-off-by: John Crispin <blogic@openwrt.org>
Signed-off-by: Felix Fietkau <nbd@openwrt.org>
Signed-off-by: Michael Lee <igvtee@gmail.com>
---
 drivers/net/ethernet/mediatek/soc_rt3883.c |   72 ++++++++++++++++++++++++++++
 1 file changed, 72 insertions(+)
 create mode 100644 drivers/net/ethernet/mediatek/soc_rt3883.c

diff --git a/drivers/net/ethernet/mediatek/soc_rt3883.c b/drivers/net/ethernet/mediatek/soc_rt3883.c
new file mode 100644
index 0000000..8138370
--- /dev/null
+++ b/drivers/net/ethernet/mediatek/soc_rt3883.c
@@ -0,0 +1,72 @@
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
+#define RT3883_RSTCTRL_FE		BIT(21)
+
+static void rt3883_mtk_reset(struct mtk_eth *eth)
+{
+	mtk_reset(eth, RT3883_RSTCTRL_FE);
+}
+
+static int rt3883_fwd_config(struct mtk_eth *eth)
+{
+	int ret;
+
+	ret = mtk_set_clock_cycle(eth);
+	if (ret)
+		return ret;
+
+	mtk_fwd_config(eth);
+	mtk_w32(eth, MTK_PSE_FQFC_CFG_256Q, MTK_PSE_FQ_CFG);
+	mtk_csum_config(eth);
+
+	return ret;
+}
+
+static struct mtk_soc_data rt3883_data = {
+	.hw_features = NETIF_F_SG | NETIF_F_IP_CSUM |
+		       NETIF_F_RXCSUM | NETIF_F_HW_VLAN_CTAG_TX,
+	.dma_type = MTK_PDMA,
+	.dma_ring_size = 128,
+	.napi_weight = 32,
+	.padding_64b = 1,
+	.padding_bug = 1,
+	.mac_count = 1,
+	.txd4 = TX_DMA_DESP4_DEF,
+	.reset_fe = rt3883_mtk_reset,
+	.fwd_config = rt3883_fwd_config,
+	.pdma_glo_cfg = MTK_PDMA_SIZE_8DWORDS,
+	.rx_int = MTK_RX_DONE_INT,
+	.tx_int = MTK_TX_DONE_INT,
+	.status_int = MTK_CNT_GDM_AF,
+	.checksum_bit = RX_DMA_L4VALID,
+	.mdio_read = rt2880_mdio_read,
+	.mdio_write = rt2880_mdio_write,
+	.mdio_adjust_link = rt2880_mdio_link_adjust,
+	.port_init = rt2880_port_init,
+};
+
+const struct of_device_id of_mtk_match[] = {
+	{ .compatible = "ralink,rt3883-eth", .data = &rt3883_data },
+	{},
+};
+
+MODULE_DEVICE_TABLE(of, of_mtk_match);
-- 
1.7.10.4
