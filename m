From: Jose Abreu <Jose.Abreu@synopsys.com>
Subject: [PATCH v2 net-next] net: stmmac: Add support for DWMAC5 with TSN features
Date: Fri, 27 Oct 2017 14:55:44 +0100
Message-ID: <859e8dd503b6368d4ec2ac2130cdeb88f48e2ae9.1509112414.git.joabreu@synopsys.com>
Cc: Jose Abreu <Jose.Abreu@synopsys.com>,
        "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds support for IP version 5 of DWMAC. The new introduced
features are the Enhancements to Scheduled Traffic (EST) as
defined by IEEE802.1Qbv-2015 and Frame Preemption (FPE) as
defined by IEEE802.1Qbu.

In order to not break previous setups all the necessary
configuration is only performed when GMAC5 is detected and
only when all the necessary parameters are available in the
Device Tree.

EST:
The IEEE802.1Qbv-2015 defines the schedule for each of the
queues which makes the IP aware of traffic arrival time. This
information can be used to block the lower priority traffic
from transmission in this time window/slot.

FPE:
The IEEE802.1Qbu defines a mechanism which breaks interfering
frames into smaller fragments shuch that we have a more efficient
use of network bandwidth. This needs EST enabled.

Signed-off-by: Jose Abreu <joabreu@synopsys.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Joao Pinto <jpinto@synopsys.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Alexandre Torgue <alexandre.torgue@st.com>
---
Changes since v1:
- Removed DT parsing
---
 drivers/net/ethernet/stmicro/stmmac/Makefile       |  2 +-
 drivers/net/ethernet/stmicro/stmmac/common.h       |  4 +
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  | 37 +++++++-
 drivers/net/ethernet/stmicro/stmmac/dwmac5_tsn.c   | 99 ++++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac5_tsn.h   | 57 +++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  4 +
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  3 +-
 include/linux/stmmac.h                             | 11 +++
 8 files changed, 214 insertions(+), 3 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac5_tsn.c
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac5_tsn.h

diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index 238307f..45b594e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -3,7 +3,7 @@ stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode.o	\
 	      chain_mode.o dwmac_lib.o dwmac1000_core.o dwmac1000_dma.o	\
 	      dwmac100_core.o dwmac100_dma.o enh_desc.o norm_desc.o	\
 	      mmc_core.o stmmac_hwtstamp.o stmmac_ptp.o dwmac4_descs.o	\
-	      dwmac4_dma.o dwmac4_lib.o dwmac4_core.o $(stmmac-y)
+	      dwmac4_dma.o dwmac4_lib.o dwmac4_core.o dwmac5_tsn.o $(stmmac-y)
 
 # Ordering matters. Generic driver must be last.
 obj-$(CONFIG_STMMAC_PLATFORM)	+= stmmac-platform.o
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index e1e5ac0..d052b9f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -38,6 +38,7 @@
 #define	DWMAC_CORE_3_40	0x34
 #define	DWMAC_CORE_3_50	0x35
 #define	DWMAC_CORE_4_00	0x40
+#define DWMAC_CORE_5_00 0x50
 #define STMMAC_CHAN0	0	/* Always supported and default for all chips */
 
 /* These need to be power of two, and >= 4 */
@@ -501,6 +502,9 @@ struct stmmac_ops {
 	void (*config_cbs)(struct mac_device_info *hw, u32 send_slope,
 			   u32 idle_slope, u32 high_credit, u32 low_credit,
 			   u32 queue);
+	/* Configure TSN features */
+	void (*config_tsn)(struct mac_device_info *hw,
+			   struct plat_stmmacenet_data *plat);
 	/* Dump MAC registers */
 	void (*dump_regs)(struct mac_device_info *hw, u32 *reg_space);
 	/* Handle extra events on specific interrupts hw dependent */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index 2f7d7ec..54370da 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -19,6 +19,7 @@
 #include <linux/io.h>
 #include "stmmac_pcs.h"
 #include "dwmac4.h"
+#include "dwmac5_tsn.h"
 
 static void dwmac4_core_init(struct mac_device_info *hw, int mtu)
 {
@@ -738,6 +739,38 @@ static void dwmac4_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x,
 	.set_filter = dwmac4_set_filter,
 };
 
+static const struct stmmac_ops dwmac5_ops = {
+	.core_init = dwmac4_core_init,
+	.set_mac = stmmac_dwmac4_set_mac,
+	.rx_ipc = dwmac4_rx_ipc_enable,
+	.rx_queue_enable = dwmac4_rx_queue_enable,
+	.rx_queue_prio = dwmac4_rx_queue_priority,
+	.tx_queue_prio = dwmac4_tx_queue_priority,
+	.rx_queue_routing = dwmac4_tx_queue_routing,
+	.prog_mtl_rx_algorithms = dwmac4_prog_mtl_rx_algorithms,
+	.prog_mtl_tx_algorithms = dwmac4_prog_mtl_tx_algorithms,
+	.set_mtl_tx_queue_weight = dwmac4_set_mtl_tx_queue_weight,
+	.map_mtl_to_dma = dwmac4_map_mtl_dma,
+	.config_cbs = dwmac4_config_cbs,
+	.config_tsn = dwmac5_config_tsn,
+	.dump_regs = dwmac4_dump_regs,
+	.host_irq_status = dwmac4_irq_status,
+	.host_mtl_irq_status = dwmac4_irq_mtl_status,
+	.flow_ctrl = dwmac4_flow_ctrl,
+	.pmt = dwmac4_pmt,
+	.set_umac_addr = dwmac4_set_umac_addr,
+	.get_umac_addr = dwmac4_get_umac_addr,
+	.set_eee_mode = dwmac4_set_eee_mode,
+	.reset_eee_mode = dwmac4_reset_eee_mode,
+	.set_eee_timer = dwmac4_set_eee_timer,
+	.set_eee_pls = dwmac4_set_eee_pls,
+	.pcs_ctrl_ane = dwmac4_ctrl_ane,
+	.pcs_rane = dwmac4_rane,
+	.pcs_get_adv_lp = dwmac4_get_adv_lp,
+	.debug = dwmac4_debug,
+	.set_filter = dwmac4_set_filter,
+};
+
 struct mac_device_info *dwmac4_setup(void __iomem *ioaddr, int mcbins,
 				     int perfect_uc_entries, int *synopsys_id)
 {
@@ -778,7 +811,9 @@ struct mac_device_info *dwmac4_setup(void __iomem *ioaddr, int mcbins,
 	else
 		mac->dma = &dwmac4_dma_ops;
 
-	if (*synopsys_id >= DWMAC_CORE_4_00)
+	if (*synopsys_id >= DWMAC_CORE_5_00)
+		mac->mac = &dwmac5_ops;
+	else if (*synopsys_id >= DWMAC_CORE_4_00)
 		mac->mac = &dwmac410_ops;
 	else
 		mac->mac = &dwmac4_ops;
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac5_tsn.c b/drivers/net/ethernet/stmicro/stmmac/dwmac5_tsn.c
new file mode 100644
index 0000000..fa1d506
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac5_tsn.c
@@ -0,0 +1,99 @@
+/*
+ * DWMAC5 TSN Core Functions
+ * Copyright (C) 2017 Synopsys, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * Author: Jose Abreu <joabreu@synopsys.com>
+ */
+
+#include "common.h"
+#include "dwmac5_tsn.h"
+
+static int dwmac5_est_write(void __iomem *ioaddr, u32 reg, u32 val, bool gcla)
+{
+	int timeout_ms = EST_WRITE_TIMEOUT_MS;
+	u32 ctrl = 0x0;
+
+	writel(val, ioaddr + MTL_EST_GCL_DATA);
+
+	ctrl |= reg;
+	ctrl |= gcla ? 0x0 : MTL_EST_GCRR;
+	writel(ctrl, ioaddr + MTL_EST_GCL_CONTROL);
+
+	ctrl |= MTL_EST_SRWO;
+	writel(ctrl, ioaddr + MTL_EST_GCL_CONTROL);
+
+	while (--timeout_ms) {
+		udelay(1000);
+		if (readl(ioaddr + MTL_EST_GCL_CONTROL) & MTL_EST_SRWO)
+			continue;
+		break;
+	}
+
+	if (!timeout_ms)
+		return -ETIMEDOUT;
+	return 0;
+}
+
+static void dwmac5_config_est(struct mac_device_info *hw,
+			      struct plat_stmmacenet_data *plat)
+{
+	struct stmmac_est_cfg *est = &plat->est_cfg;
+	void __iomem *ioaddr = hw->pcsr;
+	u32 ctrl = 0x0, btr[2];
+	struct timespec64 now;
+	int i;
+
+	/* Add real time to offset */
+	ktime_get_real_ts64(&now);
+	btr[0] = (u32)now.tv_nsec + est->btr[0];
+	btr[1] = (u32)now.tv_sec + est->btr[1];
+
+	/* Write parameters */
+	dwmac5_est_write(ioaddr, MTL_EST_BTR_LOW, btr[0], false);
+	dwmac5_est_write(ioaddr, MTL_EST_BTR_HIGH, btr[1], false);
+	dwmac5_est_write(ioaddr, MTL_EST_CTR_LOW, est->ctr[0], false);
+	dwmac5_est_write(ioaddr, MTL_EST_CTR_HIGH, est->ctr[1], false);
+	dwmac5_est_write(ioaddr, MTL_EST_TER, est->ter, false);
+	dwmac5_est_write(ioaddr, MTL_EST_LLR, est->llr, false);
+
+	/* Write GCL table */
+	for (i = 0; i < est->llr; i++) {
+		u32 reg = (i << MTL_EST_ADDR_SHIFT) & MTL_EST_ADDR;
+		dwmac5_est_write(ioaddr, reg, est->gcl[i], true);
+	}
+
+	/* Enable EST */
+	ctrl |= MTL_EST_EEST;
+	writel(ctrl, ioaddr + MTL_EST_CONTROL);
+
+	/* Store table */
+	ctrl |= MTL_EST_SSWL;
+	writel(ctrl, ioaddr + MTL_EST_CONTROL);
+}
+
+void dwmac5_config_fp(struct mac_device_info *hw)
+{
+	void __iomem *ioaddr = hw->pcsr;
+	u32 ctrl;
+
+	/* Enable frame preemption */
+	ctrl = readl(ioaddr + GMAC_FPE_CTRL_STS);
+	ctrl |= GMAC_FPE_EFPE;
+	writel(ctrl, ioaddr + GMAC_FPE_CTRL_STS);
+}
+
+void dwmac5_config_tsn(struct mac_device_info *hw,
+		       struct plat_stmmacenet_data *plat)
+{
+	void __iomem *ioaddr = hw->pcsr;
+	u32 value = readl(ioaddr + GMAC_HW_FEATURE3);
+
+	if ((value & GMAC_HW_FEAT_ESTSEL) && plat->est_en)
+		dwmac5_config_est(hw, plat);
+	if ((value & GMAC_HW_FEAT_FPESEL) && plat->fp_en)
+		dwmac5_config_fp(hw);
+}
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac5_tsn.h b/drivers/net/ethernet/stmicro/stmmac/dwmac5_tsn.h
new file mode 100644
index 0000000..07bda8b
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac5_tsn.h
@@ -0,0 +1,57 @@
+/*
+ * DWMAC5 TSN Header File
+ * Copyright (C) 2017 Synopsys, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * Author: Jose Abreu <joabreu@synopsys.com>
+ */
+
+#ifndef __DWMAC5_TSN_H__
+#define __DWMAC5_TSN_H__
+
+#include <linux/stmmac.h>
+
+/* MAC registers */
+#define GMAC_HW_FEATURE3		0x00000128
+#define GMAC_FPE_CTRL_STS		0x00000234
+
+/* MAC HW features3 bitmap */
+#define GMAC_HW_FEAT_FPESEL		BIT(26)
+#define GMAC_HW_FEAT_ESTSEL		BIT(16)
+
+/* MAC FPE control/status bitmap */
+#define GMAC_FPE_EFPE			BIT(0)
+
+/* MTL registers */
+#define MTL_EST_CONTROL			0x00000c50
+#define MTL_EST_GCL_CONTROL		0x00000c80
+#define MTL_EST_GCL_DATA		0x00000c84
+
+/* EST control bitmap */
+#define MTL_EST_EEST			BIT(0)
+#define MTL_EST_SSWL			BIT(1)
+
+/* EST GCL control bitmap */
+#define MTL_EST_ADDR_SHIFT		8
+#define MTL_EST_ADDR			GENMASK(19, 8)
+#define MTL_EST_GCRR			BIT(2)
+#define MTL_EST_SRWO			BIT(0)
+
+/* EST GCRA addresses */
+#define MTL_EST_BTR_LOW			(0x0 << MTL_EST_ADDR_SHIFT)
+#define MTL_EST_BTR_HIGH		(0x1 << MTL_EST_ADDR_SHIFT)
+#define MTL_EST_CTR_LOW			(0x2 << MTL_EST_ADDR_SHIFT)
+#define MTL_EST_CTR_HIGH		(0x3 << MTL_EST_ADDR_SHIFT)
+#define MTL_EST_TER			(0x4 << MTL_EST_ADDR_SHIFT)
+#define MTL_EST_LLR			(0x5 << MTL_EST_ADDR_SHIFT)
+
+/* Misc */
+#define EST_WRITE_TIMEOUT_MS		5
+
+void dwmac5_config_tsn(struct mac_device_info *hw,
+		       struct plat_stmmacenet_data *plat);
+
+#endif /* __DWMAC5_TSN_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index c7a894e..24861e2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2418,6 +2418,10 @@ static void stmmac_mtl_configuration(struct stmmac_priv *priv)
 	if (tx_queues_count > 1 && priv->hw->mac->config_cbs)
 		stmmac_configure_cbs(priv);
 
+	/* Configure TSN features */
+	if (tx_queues_count > 1 && priv->hw->mac->config_tsn)
+		priv->hw->mac->config_tsn(priv->hw, priv->plat);
+
 	/* Map RX MTL to DMA channels */
 	if (priv->hw->mac->map_mtl_to_dma)
 		stmmac_rx_queue_dma_chan_map(priv);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 8a280b4..c2aeb10 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -453,7 +453,8 @@ struct plat_stmmacenet_data *
 	}
 
 	if (of_device_is_compatible(np, "snps,dwmac-4.00") ||
-	    of_device_is_compatible(np, "snps,dwmac-4.10a")) {
+	    of_device_is_compatible(np, "snps,dwmac-4.10a") ||
+	    of_device_is_compatible(np, "snps,dwmac-5.00")) {
 		plat->has_gmac4 = 1;
 		plat->has_gmac = 0;
 		plat->pmt = 1;
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 108739f..9b9a102 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -144,6 +144,14 @@ struct stmmac_txq_cfg {
 	u32 prio;
 };
 
+struct stmmac_est_cfg {
+	u32 btr[2];
+	u32 ctr[2];
+	u32 ter;
+	u32 llr;
+	u32 *gcl;
+};
+
 struct plat_stmmacenet_data {
 	int bus_id;
 	int phy_addr;
@@ -190,5 +198,8 @@ struct plat_stmmacenet_data {
 	bool tso_en;
 	int mac_port_sel_speed;
 	bool en_tx_lpi_clockgating;
+	bool est_en;
+	struct stmmac_est_cfg est_cfg;
+	bool fp_en;
 };
 #endif
-- 
1.9.1
