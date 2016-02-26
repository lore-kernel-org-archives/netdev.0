From: John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: [PATCH V2 06/12] net-next: mediatek: add support for rt3050
Date: Fri, 26 Feb 2016 15:21:38 +0100
Message-ID: <1456496504-50429-7-git-send-email-blogic@openwrt.org>
References: <1456496504-50429-1-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?q?Fred=20Chang=20=28=E5=BC=B5=E5=98=89=E5=AE=8F=29?=
 <Fred.Chang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
 =?UTF-8?q?Steven=20Liu=20=28=E5=8A=89=E4=BA=BA=E8=B1=AA=29?=
 <steven.liu-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 =?UTF-8?q?Carlos=20Huang=20=28=E9=BB=83=E5=A3=AB=E5=BD=B0=29?=
 <Carlos.Huang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Matthias Brugger <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 Michael Lee <igvtee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
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

Add support for SoCs from the rt3050 family. This include rt3050, rt3052,
rt3352 and rt5350. These all have a builtin 5 port 100mbit switch (ESW).
There are a huge amount of CPEs in the wild that use this SoC as they were
some of the first to have builtin 802.11n wmacs.

rt5350 was an ultra low cost device, that had seen some changes in the
reset bits and register layout. However as the difference are rather minor
support for all of these is in the same driver. OpenWrt builds generic
images where the kernel works on all of the SoCs listed above.

Signed-off-by: John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Signed-off-by: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Signed-off-by: Michael Lee <igvtee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ethernet/mediatek/soc_rt3050.c |  138 ++++++++++++++++++++++++++++
 1 file changed, 138 insertions(+)
 create mode 100644 drivers/net/ethernet/mediatek/soc_rt3050.c

diff --git a/drivers/net/ethernet/mediatek/soc_rt3050.c b/drivers/net/ethernet/mediatek/soc_rt3050.c
new file mode 100644
index 0000000..5c4739a
--- /dev/null
+++ b/drivers/net/ethernet/mediatek/soc_rt3050.c
@@ -0,0 +1,138 @@
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
+
+#include <asm/mach-ralink/ralink_regs.h>
+
+#include "mtk_eth_soc.h"
+#include "esw_rt3050.h"
+#include "mdio_rt2880.h"
+
+#define RT305X_RESET_FE         BIT(21)
+#define RT305X_RESET_ESW        BIT(23)
+
+static const u16 rt5350_reg_table[MTK_REG_COUNT] = {
+	[MTK_REG_PDMA_GLO_CFG] = RT5350_PDMA_GLO_CFG,
+	[MTK_REG_PDMA_RST_CFG] = RT5350_PDMA_RST_CFG,
+	[MTK_REG_DLY_INT_CFG] = RT5350_DLY_INT_CFG,
+	[MTK_REG_TX_BASE_PTR0] = RT5350_TX_BASE_PTR0,
+	[MTK_REG_TX_MAX_CNT0] = RT5350_TX_MAX_CNT0,
+	[MTK_REG_TX_CTX_IDX0] = RT5350_TX_CTX_IDX0,
+	[MTK_REG_TX_DTX_IDX0] = RT5350_TX_DTX_IDX0,
+	[MTK_REG_RX_BASE_PTR0] = RT5350_RX_BASE_PTR0,
+	[MTK_REG_RX_MAX_CNT0] = RT5350_RX_MAX_CNT0,
+	[MTK_REG_RX_CALC_IDX0] = RT5350_RX_CALC_IDX0,
+	[MTK_REG_RX_DRX_IDX0] = RT5350_RX_DRX_IDX0,
+	[MTK_REG_MTK_INT_ENABLE] = RT5350_MTK_INT_ENABLE,
+	[MTK_REG_MTK_INT_STATUS] = RT5350_MTK_INT_STATUS,
+	[MTK_REG_MTK_RST_GL] = 0,
+	[MTK_REG_MTK_DMA_VID_BASE] = 0,
+};
+
+static int rt3050_fwd_config(struct mtk_eth *eth)
+{
+	int ret;
+
+	if (ralink_soc != RT305X_SOC_RT3052) {
+		ret = mtk_set_clock_cycle(eth);
+		if (ret)
+			return ret;
+	}
+
+	mtk_fwd_config(eth);
+	if (ralink_soc != RT305X_SOC_RT3352)
+		mtk_w32(eth, MTK_PSE_FQFC_CFG_INIT, MTK_PSE_FQ_CFG);
+	mtk_csum_config(eth);
+
+	return 0;
+}
+
+static void rt305x_mtk_reset(struct mtk_eth *eth)
+{
+	mtk_reset(eth, RT305X_RESET_FE);
+}
+
+static void rt5350_set_mac(struct mtk_mac *mac, unsigned char *hwaddr)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&mac->hw->page_lock, flags);
+	mtk_w32(mac->hw, (hwaddr[0] << 8) | hwaddr[1], RT5350_SDM_MAC_ADRH);
+	mtk_w32(mac->hw, (hwaddr[2] << 24) | (hwaddr[3] << 16) |
+		     (hwaddr[4] << 8) | hwaddr[5],
+		RT5350_SDM_MAC_ADRL);
+	spin_unlock_irqrestore(&mac->hw->page_lock, flags);
+}
+
+static int rt5350_fwd_config(struct mtk_eth *eth)
+{
+	/* enable rx checksums */
+	mtk_w32(eth,
+		mtk_r32(eth, RT5350_SDM_CFG) | (RT5350_SDM_ICS_EN |
+			RT5350_SDM_TCS_EN | RT5350_SDM_UCS_EN),
+			RT5350_SDM_CFG);
+	return 0;
+}
+
+static void rt5350_mtk_reset(struct mtk_eth *eth)
+{
+	mtk_reset(eth, RT305X_RESET_FE | RT305X_RESET_ESW);
+}
+
+static struct mtk_soc_data rt3050_data = {
+	.hw_features = NETIF_F_SG | NETIF_F_IP_CSUM |
+		       NETIF_F_RXCSUM | NETIF_F_HW_VLAN_CTAG_TX,
+	.dma_type = MTK_PDMA,
+	.dma_ring_size = 128,
+	.napi_weight = 32,
+	.padding_64b = 1,
+	.padding_bug = 1,
+	.has_switch = 1,
+	.mac_count = 1,
+	.reset_fe = rt305x_mtk_reset,
+	.fwd_config = rt3050_fwd_config,
+	.switch_init = mtk_esw_init,
+	.pdma_glo_cfg = MTK_PDMA_SIZE_8DWORDS,
+	.checksum_bit = RX_DMA_L4VALID,
+	.rx_int = MTK_RX_DONE_INT,
+	.tx_int = MTK_TX_DONE_INT,
+	.status_int = MTK_CNT_GDM_AF,
+};
+
+static struct mtk_soc_data rt5350_data = {
+	.hw_features = NETIF_F_SG | NETIF_F_RXCSUM,
+	.dma_type = MTK_PDMA,
+	.dma_ring_size = 128,
+	.napi_weight = 32,
+	.has_switch = 1,
+	.mac_count = 1,
+	.reg_table = rt5350_reg_table,
+	.reset_fe = rt5350_mtk_reset,
+	.set_mac = rt5350_set_mac,
+	.fwd_config = rt5350_fwd_config,
+	.switch_init = mtk_esw_init,
+	.pdma_glo_cfg = MTK_PDMA_SIZE_8DWORDS,
+	.checksum_bit = RX_DMA_L4VALID,
+	.rx_int = RT5350_RX_DONE_INT,
+	.tx_int = RT5350_TX_DONE_INT,
+};
+
+const struct of_device_id of_mtk_match[] = {
+	{ .compatible = "ralink,rt3050-eth", .data = &rt3050_data },
+	{ .compatible = "ralink,rt5350-eth", .data = &rt5350_data },
+	{},
+};
+
+MODULE_DEVICE_TABLE(of, of_mtk_match);
-- 
1.7.10.4
