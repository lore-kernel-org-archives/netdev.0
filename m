From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [RFC PATCH] net: stmicro: eQOS IP Core
Date: Fri, 20 Jan 2017 12:27:33 +0000
Message-ID: <4584830fd1416af69ddb2e0168f78b1e343c33fe.1484914583.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.47.9]:32973 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751812AbdATM1j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 07:27:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For historical reasons the Designware eQOS IP Core started in version 4.x,
instead of starting in 1.x. This caused some misunderstanding, which resulted
in calling this IP as GMAC4. If you go to Synopsys website and check the
Ethernet portfolio there is no GMAC4 IP:
https://www.synopsys.com/designware-ip/interface-ip/ethernet.html

There is a new version of eQOS comming out (5.x) that will have the same
mac, dma registers and flow, with an extra set of registers to enable
features like TSN. The creation of a dwmac5 or gmac5 would be wrong, and
including those new features related to eQOS 5.x in dwmac4 would also not
be very correct.

This patch suggests to rename dwmac4_* driver to eqos_*, turning it the
official driver for eQOS IP. The registers definitions are also now
called QOS_ instead of GMAC4_.

For more information about eQOS IP please check:
https://www.synopsys.com/dw/ipdir.php?ds=dwc_ether_qos

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/Makefile       |   4 +-
 drivers/net/ethernet/stmicro/stmmac/common.h       |  16 +--
 .../ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c    |   4 +-
 .../ethernet/stmicro/stmmac/{dwmac4.h => eqos.h}   |  28 ++---
 .../stmicro/stmmac/{dwmac4_core.c => eqos_core.c}  | 125 ++++++++++-----------
 .../stmmac/{dwmac4_descs.c => eqos_descs.c}        |  92 +++++++--------
 .../stmmac/{dwmac4_descs.h => eqos_descs.h}        |   8 +-
 .../stmicro/stmmac/{dwmac4_dma.c => eqos_dma.c}    | 125 ++++++++++-----------
 .../stmicro/stmmac/{dwmac4_dma.h => eqos_dma.h}    |  38 +++----
 .../stmicro/stmmac/{dwmac4_lib.c => eqos_lib.c}    |  36 +++---
 drivers/net/ethernet/stmicro/stmmac/mmc.h          |   2 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   4 +-
 .../net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c  |  10 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  42 +++----
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |  20 ++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |  30 +++--
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c   |   2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h   |   4 +-
 include/linux/stmmac.h                             |   2 +-
 20 files changed, 300 insertions(+), 294 deletions(-)
 rename drivers/net/ethernet/stmicro/stmmac/{dwmac4.h => eqos.h} (93%)
 rename drivers/net/ethernet/stmicro/stmmac/{dwmac4_core.c => eqos_core.c} (77%)
 rename drivers/net/ethernet/stmicro/stmmac/{dwmac4_descs.c => eqos_descs.c} (78%)
 rename drivers/net/ethernet/stmicro/stmmac/{dwmac4_descs.h => eqos_descs.h} (97%)
 rename drivers/net/ethernet/stmicro/stmmac/{dwmac4_dma.c => eqos_dma.c} (77%)
 rename drivers/net/ethernet/stmicro/stmmac/{dwmac4_dma.h => eqos_dma.h} (86%)
 rename drivers/net/ethernet/stmicro/stmmac/{dwmac4_lib.c => eqos_lib.c} (83%)

diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index 700c603..6b7df7f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -2,8 +2,8 @@ obj-$(CONFIG_STMMAC_ETH) += stmmac.o
 stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode.o	\
 	      chain_mode.o dwmac_lib.o dwmac1000_core.o dwmac1000_dma.o	\
 	      dwmac100_core.o dwmac100_dma.o enh_desc.o norm_desc.o	\
-	      mmc_core.o stmmac_hwtstamp.o stmmac_ptp.o dwmac4_descs.o	\
-	      dwmac4_dma.o dwmac4_lib.o dwmac4_core.o $(stmmac-y)
+	      mmc_core.o stmmac_hwtstamp.o stmmac_ptp.o eqos_descs.o	\
+	      eqos_dma.o eqos_lib.o eqos_core.o $(stmmac-y)
 
 # Ordering matters. Generic driver must be last.
 obj-$(CONFIG_STMMAC_PLATFORM)	+= stmmac-platform.o
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 75e2666..2645a09 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -493,16 +493,16 @@ struct stmmac_ops {
 struct stmmac_hwtimestamp {
 	void (*config_hw_tstamping) (void __iomem *ioaddr, u32 data);
 	u32 (*config_sub_second_increment)(void __iomem *ioaddr, u32 ptp_clock,
-					   int gmac4);
+					   int qos);
 	int (*init_systime) (void __iomem *ioaddr, u32 sec, u32 nsec);
 	int (*config_addend) (void __iomem *ioaddr, u32 addend);
 	int (*adjust_systime) (void __iomem *ioaddr, u32 sec, u32 nsec,
-			       int add_sub, int gmac4);
+			       int add_sub, int qos);
 	 u64(*get_systime) (void __iomem *ioaddr);
 };
 
 extern const struct stmmac_hwtimestamp stmmac_ptp;
-extern const struct stmmac_mode_ops dwmac4_ring_mode_ops;
+extern const struct stmmac_mode_ops eqos_ring_mode_ops;
 
 struct mac_link {
 	int port;
@@ -555,7 +555,7 @@ struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr, int mcbins,
 					int perfect_uc_entries,
 					int *synopsys_id);
 struct mac_device_info *dwmac100_setup(void __iomem *ioaddr, int *synopsys_id);
-struct mac_device_info *dwmac4_setup(void __iomem *ioaddr, int mcbins,
+struct mac_device_info *eqos_setup(void __iomem *ioaddr, int mcbins,
 				     int perfect_uc_entries, int *synopsys_id);
 
 void stmmac_set_mac_addr(void __iomem *ioaddr, u8 addr[6],
@@ -564,17 +564,17 @@ void stmmac_get_mac_addr(void __iomem *ioaddr, unsigned char *addr,
 			 unsigned int high, unsigned int low);
 void stmmac_set_mac(void __iomem *ioaddr, bool enable);
 
-void stmmac_dwmac4_set_mac_addr(void __iomem *ioaddr, u8 addr[6],
+void stmmac_eqos_set_mac_addr(void __iomem *ioaddr, u8 addr[6],
 				unsigned int high, unsigned int low);
-void stmmac_dwmac4_get_mac_addr(void __iomem *ioaddr, unsigned char *addr,
+void stmmac_eqos_get_mac_addr(void __iomem *ioaddr, unsigned char *addr,
 				unsigned int high, unsigned int low);
-void stmmac_dwmac4_set_mac(void __iomem *ioaddr, bool enable);
+void stmmac_eqos_set_mac(void __iomem *ioaddr, bool enable);
 
 void dwmac_dma_flush_tx_fifo(void __iomem *ioaddr);
 
 extern const struct stmmac_mode_ops ring_mode_ops;
 extern const struct stmmac_mode_ops chain_mode_ops;
-extern const struct stmmac_desc_ops dwmac4_desc_ops;
+extern const struct stmmac_desc_ops eqos_desc_ops;
 
 /**
  * stmmac_get_synopsys_id - return the SYINID.
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
index 1a3fa3d..6b4da51 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
@@ -97,8 +97,8 @@ static int dwc_eth_dwmac_config_dt(struct platform_device *pdev,
 		}
 	}
 
-	/* dwc-qos needs GMAC4, AAL, TSO and PMT */
-	plat_dat->has_gmac4 = 1;
+	/* dwc-qos needs eQOS, AAL, TSO and PMT */
+	plat_dat->has_qos = 1;
 	plat_dat->dma_cfg->aal = 1;
 	plat_dat->tso_en = 1;
 	plat_dat->pmt = 1;
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/eqos.h
similarity index 93%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac4.h
rename to drivers/net/ethernet/stmicro/stmmac/eqos.h
index db45134..5b98ad0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
+++ b/drivers/net/ethernet/stmicro/stmmac/eqos.h
@@ -1,5 +1,5 @@
 /*
- * DWMAC4 Header file.
+ * eQOS Header file.
  *
  * Copyright (C) 2015  STMicroelectronics Ltd
  *
@@ -10,8 +10,8 @@
  * Author: Alexandre Torgue <alexandre.torgue@st.com>
  */
 
-#ifndef __DWMAC4_H__
-#define __DWMAC4_H__
+#ifndef __EQOS_H__
+#define __EQOS_H__
 
 #include "common.h"
 
@@ -70,7 +70,7 @@
 
 #define	GMAC_INT_DEFAULT_MASK	GMAC_INT_PMT_EN
 
-enum dwmac4_irq_status {
+enum eqos_irq_status {
 	time_stamp_irq = 0x00001000,
 	mmc_rx_csum_offload_irq = 0x00000800,
 	mmc_tx_irq = 0x00000400,
@@ -90,18 +90,18 @@ enum power_event {
 	power_down = 0x00000001,
 };
 
-/* Energy Efficient Ethernet (EEE) for GMAC4
+/* Energy Efficient Ethernet (EEE) for eQOS
  *
  * LPI status, timer and control register offset
  */
-#define GMAC4_LPI_CTRL_STATUS	0xd0
-#define GMAC4_LPI_TIMER_CTRL	0xd4
+#define QOS_LPI_CTRL_STATUS	0xd0
+#define QOS_LPI_TIMER_CTRL	0xd4
 
 /* LPI control and status defines */
-#define GMAC4_LPI_CTRL_STATUS_LPITCSE	BIT(21)	/* LPI Tx Clock Stop Enable */
-#define GMAC4_LPI_CTRL_STATUS_LPITXA	BIT(19)	/* Enable LPI TX Automate */
-#define GMAC4_LPI_CTRL_STATUS_PLS	BIT(17) /* PHY Link Status */
-#define GMAC4_LPI_CTRL_STATUS_LPIEN	BIT(16)	/* LPI Enable */
+#define QOS_LPI_CTRL_STATUS_LPITCSE	BIT(21)	/* LPI Tx Clock Stop Enable */
+#define QOS_LPI_CTRL_STATUS_LPITXA	BIT(19)	/* Enable LPI TX Automate */
+#define QOS_LPI_CTRL_STATUS_PLS	BIT(17) /* PHY Link Status */
+#define QOS_LPI_CTRL_STATUS_LPIEN	BIT(16)	/* LPI Enable */
 
 /* MAC Debug bitmap */
 #define GMAC_DEBUG_TFCSTS_MASK		GENMASK(18, 17)
@@ -287,6 +287,6 @@ enum power_event {
 #define GMAC_PHYIF_CTRLSTATUS_SPEED_25		0x1
 #define GMAC_PHYIF_CTRLSTATUS_SPEED_2_5		0x0
 
-extern const struct stmmac_dma_ops dwmac4_dma_ops;
-extern const struct stmmac_dma_ops dwmac410_dma_ops;
-#endif /* __DWMAC4_H__ */
+extern const struct stmmac_dma_ops eqos_dma_ops;
+extern const struct stmmac_dma_ops eqos10_dma_ops;
+#endif /* __EQOS_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/eqos_core.c
similarity index 77%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
rename to drivers/net/ethernet/stmicro/stmmac/eqos_core.c
index 834f40f..b063f4c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/eqos_core.c
@@ -1,8 +1,7 @@
 /*
- * This is the driver for the GMAC on-chip Ethernet controller for ST SoCs.
- * DWC Ether MAC version 4.00  has been used for developing this code.
+ * This is the driver for the eQOS on-chip Ethernet controller for ST SoCs.
  *
- * This only implements the mac core functions for this chip.
+ * This only implements the eQOS core functions.
  *
  * Copyright (C) 2015  STMicroelectronics Ltd
  *
@@ -18,9 +17,9 @@
 #include <linux/ethtool.h>
 #include <linux/io.h>
 #include "stmmac_pcs.h"
-#include "dwmac4.h"
+#include "eqos.h"
 
-static void dwmac4_core_init(struct mac_device_info *hw, int mtu)
+static void eqos_core_init(struct mac_device_info *hw, int mtu)
 {
 	void __iomem *ioaddr = hw->pcsr;
 	u32 value = readl(ioaddr + GMAC_CONFIG);
@@ -59,7 +58,7 @@ static void dwmac4_core_init(struct mac_device_info *hw, int mtu)
 	writel(value, ioaddr + GMAC_INT_EN);
 }
 
-static void dwmac4_rx_queue_enable(struct mac_device_info *hw, u32 queue)
+static void eqos_rx_queue_enable(struct mac_device_info *hw, u32 queue)
 {
 	void __iomem *ioaddr = hw->pcsr;
 	u32 value = readl(ioaddr + GMAC_RXQ_CTRL0);
@@ -70,12 +69,12 @@ static void dwmac4_rx_queue_enable(struct mac_device_info *hw, u32 queue)
 	writel(value, ioaddr + GMAC_RXQ_CTRL0);
 }
 
-static void dwmac4_dump_regs(struct mac_device_info *hw)
+static void eqos_dump_regs(struct mac_device_info *hw)
 {
 	void __iomem *ioaddr = hw->pcsr;
 	int i;
 
-	pr_debug("\tDWMAC4 regs (base addr = 0x%p)\n", ioaddr);
+	pr_debug("\teqos regs (base addr = 0x%p)\n", ioaddr);
 
 	for (i = 0; i < GMAC_REG_NUM; i++) {
 		int offset = i * 4;
@@ -85,7 +84,7 @@ static void dwmac4_dump_regs(struct mac_device_info *hw)
 	}
 }
 
-static int dwmac4_rx_ipc_enable(struct mac_device_info *hw)
+static int eqos_rx_ipc_enable(struct mac_device_info *hw)
 {
 	void __iomem *ioaddr = hw->pcsr;
 	u32 value = readl(ioaddr + GMAC_CONFIG);
@@ -102,7 +101,7 @@ static int dwmac4_rx_ipc_enable(struct mac_device_info *hw)
 	return !!(value & GMAC_CONFIG_IPC);
 }
 
-static void dwmac4_pmt(struct mac_device_info *hw, unsigned long mode)
+static void eqos_pmt(struct mac_device_info *hw, unsigned long mode)
 {
 	void __iomem *ioaddr = hw->pcsr;
 	unsigned int pmt = 0;
@@ -119,25 +118,25 @@ static void dwmac4_pmt(struct mac_device_info *hw, unsigned long mode)
 	writel(pmt, ioaddr + GMAC_PMT);
 }
 
-static void dwmac4_set_umac_addr(struct mac_device_info *hw,
+static void eqos_set_umac_addr(struct mac_device_info *hw,
 				 unsigned char *addr, unsigned int reg_n)
 {
 	void __iomem *ioaddr = hw->pcsr;
 
-	stmmac_dwmac4_set_mac_addr(ioaddr, addr, GMAC_ADDR_HIGH(reg_n),
+	stmmac_eqos_set_mac_addr(ioaddr, addr, GMAC_ADDR_HIGH(reg_n),
 				   GMAC_ADDR_LOW(reg_n));
 }
 
-static void dwmac4_get_umac_addr(struct mac_device_info *hw,
+static void eqos_get_umac_addr(struct mac_device_info *hw,
 				 unsigned char *addr, unsigned int reg_n)
 {
 	void __iomem *ioaddr = hw->pcsr;
 
-	stmmac_dwmac4_get_mac_addr(ioaddr, addr, GMAC_ADDR_HIGH(reg_n),
+	stmmac_eqos_get_mac_addr(ioaddr, addr, GMAC_ADDR_HIGH(reg_n),
 				   GMAC_ADDR_LOW(reg_n));
 }
 
-static void dwmac4_set_eee_mode(struct mac_device_info *hw,
+static void eqos_set_eee_mode(struct mac_device_info *hw,
 				bool en_tx_lpi_clockgating)
 {
 	void __iomem *ioaddr = hw->pcsr;
@@ -147,41 +146,41 @@ static void dwmac4_set_eee_mode(struct mac_device_info *hw,
 	 * receive path and instruct the transmit to enter in LPI
 	 * state.
 	 */
-	value = readl(ioaddr + GMAC4_LPI_CTRL_STATUS);
-	value |= GMAC4_LPI_CTRL_STATUS_LPIEN | GMAC4_LPI_CTRL_STATUS_LPITXA;
+	value = readl(ioaddr + QOS_LPI_CTRL_STATUS);
+	value |= QOS_LPI_CTRL_STATUS_LPIEN | QOS_LPI_CTRL_STATUS_LPITXA;
 
 	if (en_tx_lpi_clockgating)
-		value |= GMAC4_LPI_CTRL_STATUS_LPITCSE;
+		value |= QOS_LPI_CTRL_STATUS_LPITCSE;
 
-	writel(value, ioaddr + GMAC4_LPI_CTRL_STATUS);
+	writel(value, ioaddr + QOS_LPI_CTRL_STATUS);
 }
 
-static void dwmac4_reset_eee_mode(struct mac_device_info *hw)
+static void eqos_reset_eee_mode(struct mac_device_info *hw)
 {
 	void __iomem *ioaddr = hw->pcsr;
 	u32 value;
 
-	value = readl(ioaddr + GMAC4_LPI_CTRL_STATUS);
-	value &= ~(GMAC4_LPI_CTRL_STATUS_LPIEN | GMAC4_LPI_CTRL_STATUS_LPITXA);
-	writel(value, ioaddr + GMAC4_LPI_CTRL_STATUS);
+	value = readl(ioaddr + QOS_LPI_CTRL_STATUS);
+	value &= ~(QOS_LPI_CTRL_STATUS_LPIEN | QOS_LPI_CTRL_STATUS_LPITXA);
+	writel(value, ioaddr + QOS_LPI_CTRL_STATUS);
 }
 
-static void dwmac4_set_eee_pls(struct mac_device_info *hw, int link)
+static void eqos_set_eee_pls(struct mac_device_info *hw, int link)
 {
 	void __iomem *ioaddr = hw->pcsr;
 	u32 value;
 
-	value = readl(ioaddr + GMAC4_LPI_CTRL_STATUS);
+	value = readl(ioaddr + QOS_LPI_CTRL_STATUS);
 
 	if (link)
-		value |= GMAC4_LPI_CTRL_STATUS_PLS;
+		value |= QOS_LPI_CTRL_STATUS_PLS;
 	else
-		value &= ~GMAC4_LPI_CTRL_STATUS_PLS;
+		value &= ~QOS_LPI_CTRL_STATUS_PLS;
 
-	writel(value, ioaddr + GMAC4_LPI_CTRL_STATUS);
+	writel(value, ioaddr + QOS_LPI_CTRL_STATUS);
 }
 
-static void dwmac4_set_eee_timer(struct mac_device_info *hw, int ls, int tw)
+static void eqos_set_eee_timer(struct mac_device_info *hw, int ls, int tw)
 {
 	void __iomem *ioaddr = hw->pcsr;
 	int value = ((tw & 0xffff)) | ((ls & 0x7ff) << 16);
@@ -193,10 +192,10 @@ static void dwmac4_set_eee_timer(struct mac_device_info *hw, int ls, int tw)
 	 * TW: minimum time (us) for which the core waits
 	 *  after it has stopped transmitting the LPI pattern.
 	 */
-	writel(value, ioaddr + GMAC4_LPI_TIMER_CTRL);
+	writel(value, ioaddr + QOS_LPI_TIMER_CTRL);
 }
 
-static void dwmac4_set_filter(struct mac_device_info *hw,
+static void eqos_set_filter(struct mac_device_info *hw,
 			      struct net_device *dev)
 {
 	void __iomem *ioaddr = (void __iomem *)dev->base_addr;
@@ -248,7 +247,7 @@ static void dwmac4_set_filter(struct mac_device_info *hw,
 		struct netdev_hw_addr *ha;
 
 		netdev_for_each_uc_addr(ha, dev) {
-			dwmac4_set_umac_addr(hw, ha->addr, reg);
+			eqos_set_umac_addr(hw, ha->addr, reg);
 			reg++;
 		}
 	}
@@ -256,7 +255,7 @@ static void dwmac4_set_filter(struct mac_device_info *hw,
 	writel(value, ioaddr + GMAC_PACKET_FILTER);
 }
 
-static void dwmac4_flow_ctrl(struct mac_device_info *hw, unsigned int duplex,
+static void eqos_flow_ctrl(struct mac_device_info *hw, unsigned int duplex,
 			     unsigned int fc, unsigned int pause_time)
 {
 	void __iomem *ioaddr = hw->pcsr;
@@ -282,24 +281,24 @@ static void dwmac4_flow_ctrl(struct mac_device_info *hw, unsigned int duplex,
 	}
 }
 
-static void dwmac4_ctrl_ane(void __iomem *ioaddr, bool ane, bool srgmi_ral,
+static void eqos_ctrl_ane(void __iomem *ioaddr, bool ane, bool srgmi_ral,
 			    bool loopback)
 {
 	dwmac_ctrl_ane(ioaddr, GMAC_PCS_BASE, ane, srgmi_ral, loopback);
 }
 
-static void dwmac4_rane(void __iomem *ioaddr, bool restart)
+static void eqos_rane(void __iomem *ioaddr, bool restart)
 {
 	dwmac_rane(ioaddr, GMAC_PCS_BASE, restart);
 }
 
-static void dwmac4_get_adv_lp(void __iomem *ioaddr, struct rgmii_adv *adv)
+static void eqos_get_adv_lp(void __iomem *ioaddr, struct rgmii_adv *adv)
 {
 	dwmac_get_adv_lp(ioaddr, GMAC_PCS_BASE, adv);
 }
 
 /* RGMII or SMII interface */
-static void dwmac4_phystatus(void __iomem *ioaddr, struct stmmac_extra_stats *x)
+static void eqos_phystatus(void __iomem *ioaddr, struct stmmac_extra_stats *x)
 {
 	u32 status;
 
@@ -331,7 +330,7 @@ static void dwmac4_phystatus(void __iomem *ioaddr, struct stmmac_extra_stats *x)
 	}
 }
 
-static int dwmac4_irq_status(struct mac_device_info *hw,
+static int eqos_irq_status(struct mac_device_info *hw,
 			     struct stmmac_extra_stats *x)
 {
 	void __iomem *ioaddr = hw->pcsr;
@@ -370,12 +369,12 @@ static int dwmac4_irq_status(struct mac_device_info *hw,
 
 	dwmac_pcs_isr(ioaddr, GMAC_PCS_BASE, intr_status, x);
 	if (intr_status & PCS_RGSMIIIS_IRQ)
-		dwmac4_phystatus(ioaddr, x);
+		eqos_phystatus(ioaddr, x);
 
 	return ret;
 }
 
-static void dwmac4_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x)
+static void eqos_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x)
 {
 	u32 value;
 
@@ -459,28 +458,28 @@ static void dwmac4_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x)
 		x->mac_gmii_rx_proto_engine++;
 }
 
-static const struct stmmac_ops dwmac4_ops = {
-	.core_init = dwmac4_core_init,
-	.rx_ipc = dwmac4_rx_ipc_enable,
-	.rx_queue_enable = dwmac4_rx_queue_enable,
-	.dump_regs = dwmac4_dump_regs,
-	.host_irq_status = dwmac4_irq_status,
-	.flow_ctrl = dwmac4_flow_ctrl,
-	.pmt = dwmac4_pmt,
-	.set_umac_addr = dwmac4_set_umac_addr,
-	.get_umac_addr = dwmac4_get_umac_addr,
-	.set_eee_mode = dwmac4_set_eee_mode,
-	.reset_eee_mode = dwmac4_reset_eee_mode,
-	.set_eee_timer = dwmac4_set_eee_timer,
-	.set_eee_pls = dwmac4_set_eee_pls,
-	.pcs_ctrl_ane = dwmac4_ctrl_ane,
-	.pcs_rane = dwmac4_rane,
-	.pcs_get_adv_lp = dwmac4_get_adv_lp,
-	.debug = dwmac4_debug,
-	.set_filter = dwmac4_set_filter,
+static const struct stmmac_ops eqos_ops = {
+	.core_init = eqos_core_init,
+	.rx_ipc = eqos_rx_ipc_enable,
+	.rx_queue_enable = eqos_rx_queue_enable,
+	.dump_regs = eqos_dump_regs,
+	.host_irq_status = eqos_irq_status,
+	.flow_ctrl = eqos_flow_ctrl,
+	.pmt = eqos_pmt,
+	.set_umac_addr = eqos_set_umac_addr,
+	.get_umac_addr = eqos_get_umac_addr,
+	.set_eee_mode = eqos_set_eee_mode,
+	.reset_eee_mode = eqos_reset_eee_mode,
+	.set_eee_timer = eqos_set_eee_timer,
+	.set_eee_pls = eqos_set_eee_pls,
+	.pcs_ctrl_ane = eqos_ctrl_ane,
+	.pcs_rane = eqos_rane,
+	.pcs_get_adv_lp = eqos_get_adv_lp,
+	.debug = eqos_debug,
+	.set_filter = eqos_set_filter,
 };
 
-struct mac_device_info *dwmac4_setup(void __iomem *ioaddr, int mcbins,
+struct mac_device_info *eqos_setup(void __iomem *ioaddr, int mcbins,
 				     int perfect_uc_entries, int *synopsys_id)
 {
 	struct mac_device_info *mac;
@@ -498,7 +497,7 @@ struct mac_device_info *dwmac4_setup(void __iomem *ioaddr, int mcbins,
 	if (mac->multicast_filter_bins)
 		mac->mcast_bits_log2 = ilog2(mac->multicast_filter_bins);
 
-	mac->mac = &dwmac4_ops;
+	mac->mac = &eqos_ops;
 
 	mac->link.port = GMAC_CONFIG_PS;
 	mac->link.duplex = GMAC_CONFIG_DM;
@@ -516,9 +515,9 @@ struct mac_device_info *dwmac4_setup(void __iomem *ioaddr, int mcbins,
 	*synopsys_id = stmmac_get_synopsys_id(hwid);
 
 	if (*synopsys_id > DWMAC_CORE_4_00)
-		mac->dma = &dwmac410_dma_ops;
+		mac->dma = &eqos10_dma_ops;
 	else
-		mac->dma = &dwmac4_dma_ops;
+		mac->dma = &eqos_dma_ops;
 
 	return mac;
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c b/drivers/net/ethernet/stmicro/stmmac/eqos_descs.c
similarity index 78%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
rename to drivers/net/ethernet/stmicro/stmmac/eqos_descs.c
index 8816515..cd6bf4d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
+++ b/drivers/net/ethernet/stmicro/stmmac/eqos_descs.c
@@ -1,6 +1,6 @@
 /*
  * This contains the functions to handle the descriptors for DesignWare databook
- * 4.xx.
+ * eQOS IP.
  *
  * Copyright (C) 2015  STMicroelectronics Ltd
  *
@@ -13,9 +13,9 @@
 
 #include <linux/stmmac.h>
 #include "common.h"
-#include "dwmac4_descs.h"
+#include "eqos_descs.h"
 
-static int dwmac4_wrback_get_tx_status(void *data, struct stmmac_extra_stats *x,
+static int eqos_wrback_get_tx_status(void *data, struct stmmac_extra_stats *x,
 				       struct dma_desc *p,
 				       void __iomem *ioaddr)
 {
@@ -73,7 +73,7 @@ static int dwmac4_wrback_get_tx_status(void *data, struct stmmac_extra_stats *x,
 	return ret;
 }
 
-static int dwmac4_wrback_get_rx_status(void *data, struct stmmac_extra_stats *x,
+static int eqos_wrback_get_rx_status(void *data, struct stmmac_extra_stats *x,
 				       struct dma_desc *p)
 {
 	struct net_device_stats *stats = (struct net_device_stats *)data;
@@ -174,43 +174,43 @@ static int dwmac4_wrback_get_rx_status(void *data, struct stmmac_extra_stats *x,
 	return ret;
 }
 
-static int dwmac4_rd_get_tx_len(struct dma_desc *p)
+static int eqos_rd_get_tx_len(struct dma_desc *p)
 {
 	return (le32_to_cpu(p->des2) & TDES2_BUFFER1_SIZE_MASK);
 }
 
-static int dwmac4_get_tx_owner(struct dma_desc *p)
+static int eqos_get_tx_owner(struct dma_desc *p)
 {
 	return (le32_to_cpu(p->des3) & TDES3_OWN) >> TDES3_OWN_SHIFT;
 }
 
-static void dwmac4_set_tx_owner(struct dma_desc *p)
+static void eqos_set_tx_owner(struct dma_desc *p)
 {
 	p->des3 |= cpu_to_le32(TDES3_OWN);
 }
 
-static void dwmac4_set_rx_owner(struct dma_desc *p)
+static void eqos_set_rx_owner(struct dma_desc *p)
 {
 	p->des3 |= cpu_to_le32(RDES3_OWN);
 }
 
-static int dwmac4_get_tx_ls(struct dma_desc *p)
+static int eqos_get_tx_ls(struct dma_desc *p)
 {
 	return (le32_to_cpu(p->des3) & TDES3_LAST_DESCRIPTOR)
 		>> TDES3_LAST_DESCRIPTOR_SHIFT;
 }
 
-static int dwmac4_wrback_get_rx_frame_len(struct dma_desc *p, int rx_coe)
+static int eqos_wrback_get_rx_frame_len(struct dma_desc *p, int rx_coe)
 {
 	return (le32_to_cpu(p->des3) & RDES3_PACKET_SIZE_MASK);
 }
 
-static void dwmac4_rd_enable_tx_timestamp(struct dma_desc *p)
+static void eqos_rd_enable_tx_timestamp(struct dma_desc *p)
 {
 	p->des2 |= cpu_to_le32(TDES2_TIMESTAMP_ENABLE);
 }
 
-static int dwmac4_wrback_get_tx_timestamp_status(struct dma_desc *p)
+static int eqos_wrback_get_tx_timestamp_status(struct dma_desc *p)
 {
 	/* Context type from W/B descriptor must be zero */
 	if (le32_to_cpu(p->des3) & TDES3_CONTEXT_TYPE)
@@ -223,7 +223,7 @@ static int dwmac4_wrback_get_tx_timestamp_status(struct dma_desc *p)
 	return 1;
 }
 
-static inline u64 dwmac4_get_timestamp(void *desc, u32 ats)
+static inline u64 eqos_get_timestamp(void *desc, u32 ats)
 {
 	struct dma_desc *p = (struct dma_desc *)desc;
 	u64 ns;
@@ -235,7 +235,7 @@ static inline u64 dwmac4_get_timestamp(void *desc, u32 ats)
 	return ns;
 }
 
-static int dwmac4_rx_check_timestamp(void *desc)
+static int eqos_rx_check_timestamp(void *desc)
 {
 	struct dma_desc *p = (struct dma_desc *)desc;
 	u32 own, ctxt;
@@ -258,7 +258,7 @@ static int dwmac4_rx_check_timestamp(void *desc)
 	return ret;
 }
 
-static int dwmac4_wrback_get_rx_timestamp_status(void *desc, u32 ats)
+static int eqos_wrback_get_rx_timestamp_status(void *desc, u32 ats)
 {
 	struct dma_desc *p = (struct dma_desc *)desc;
 	int ret = -EINVAL;
@@ -270,7 +270,7 @@ static int dwmac4_wrback_get_rx_timestamp_status(void *desc, u32 ats)
 
 			/* Check if timestamp is OK from context descriptor */
 			do {
-				ret = dwmac4_rx_check_timestamp(desc);
+				ret = eqos_rx_check_timestamp(desc);
 				if (ret < 0)
 					goto exit;
 				i++;
@@ -285,7 +285,7 @@ static int dwmac4_wrback_get_rx_timestamp_status(void *desc, u32 ats)
 	return ret;
 }
 
-static void dwmac4_rd_init_rx_desc(struct dma_desc *p, int disable_rx_ic,
+static void eqos_rd_init_rx_desc(struct dma_desc *p, int disable_rx_ic,
 				   int mode, int end)
 {
 	p->des3 = cpu_to_le32(RDES3_OWN | RDES3_BUFFER1_VALID_ADDR);
@@ -294,7 +294,7 @@ static void dwmac4_rd_init_rx_desc(struct dma_desc *p, int disable_rx_ic,
 		p->des3 |= cpu_to_le32(RDES3_INT_ON_COMPLETION_EN);
 }
 
-static void dwmac4_rd_init_tx_desc(struct dma_desc *p, int mode, int end)
+static void eqos_rd_init_tx_desc(struct dma_desc *p, int mode, int end)
 {
 	p->des0 = 0;
 	p->des1 = 0;
@@ -302,7 +302,7 @@ static void dwmac4_rd_init_tx_desc(struct dma_desc *p, int mode, int end)
 	p->des3 = 0;
 }
 
-static void dwmac4_rd_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
+static void eqos_rd_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 				      bool csum_flag, int mode, bool tx_own,
 				      bool ls)
 {
@@ -339,7 +339,7 @@ static void dwmac4_rd_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 	p->des3 = cpu_to_le32(tdes3);
 }
 
-static void dwmac4_rd_prepare_tso_tx_desc(struct dma_desc *p, int is_fs,
+static void eqos_rd_prepare_tso_tx_desc(struct dma_desc *p, int is_fs,
 					  int len1, int len2, bool tx_own,
 					  bool ls, unsigned int tcphdrlen,
 					  unsigned int tcppayloadlen)
@@ -382,18 +382,18 @@ static void dwmac4_rd_prepare_tso_tx_desc(struct dma_desc *p, int is_fs,
 	p->des3 = cpu_to_le32(tdes3);
 }
 
-static void dwmac4_release_tx_desc(struct dma_desc *p, int mode)
+static void eqos_release_tx_desc(struct dma_desc *p, int mode)
 {
 	p->des2 = 0;
 	p->des3 = 0;
 }
 
-static void dwmac4_rd_set_tx_ic(struct dma_desc *p)
+static void eqos_rd_set_tx_ic(struct dma_desc *p)
 {
 	p->des2 |= cpu_to_le32(TDES2_INTERRUPT_ON_COMPLETION);
 }
 
-static void dwmac4_display_ring(void *head, unsigned int size, bool rx)
+static void eqos_display_ring(void *head, unsigned int size, bool rx)
 {
 	struct dma_desc *p = (struct dma_desc *)head;
 	int i;
@@ -409,7 +409,7 @@ static void dwmac4_display_ring(void *head, unsigned int size, bool rx)
 	}
 }
 
-static void dwmac4_set_mss_ctxt(struct dma_desc *p, unsigned int mss)
+static void eqos_set_mss_ctxt(struct dma_desc *p, unsigned int mss)
 {
 	p->des0 = 0;
 	p->des1 = 0;
@@ -417,27 +417,27 @@ static void dwmac4_set_mss_ctxt(struct dma_desc *p, unsigned int mss)
 	p->des3 = cpu_to_le32(TDES3_CONTEXT_TYPE | TDES3_CTXT_TCMSSV);
 }
 
-const struct stmmac_desc_ops dwmac4_desc_ops = {
-	.tx_status = dwmac4_wrback_get_tx_status,
-	.rx_status = dwmac4_wrback_get_rx_status,
-	.get_tx_len = dwmac4_rd_get_tx_len,
-	.get_tx_owner = dwmac4_get_tx_owner,
-	.set_tx_owner = dwmac4_set_tx_owner,
-	.set_rx_owner = dwmac4_set_rx_owner,
-	.get_tx_ls = dwmac4_get_tx_ls,
-	.get_rx_frame_len = dwmac4_wrback_get_rx_frame_len,
-	.enable_tx_timestamp = dwmac4_rd_enable_tx_timestamp,
-	.get_tx_timestamp_status = dwmac4_wrback_get_tx_timestamp_status,
-	.get_rx_timestamp_status = dwmac4_wrback_get_rx_timestamp_status,
-	.get_timestamp = dwmac4_get_timestamp,
-	.set_tx_ic = dwmac4_rd_set_tx_ic,
-	.prepare_tx_desc = dwmac4_rd_prepare_tx_desc,
-	.prepare_tso_tx_desc = dwmac4_rd_prepare_tso_tx_desc,
-	.release_tx_desc = dwmac4_release_tx_desc,
-	.init_rx_desc = dwmac4_rd_init_rx_desc,
-	.init_tx_desc = dwmac4_rd_init_tx_desc,
-	.display_ring = dwmac4_display_ring,
-	.set_mss = dwmac4_set_mss_ctxt,
+const struct stmmac_desc_ops eqos_desc_ops = {
+	.tx_status = eqos_wrback_get_tx_status,
+	.rx_status = eqos_wrback_get_rx_status,
+	.get_tx_len = eqos_rd_get_tx_len,
+	.get_tx_owner = eqos_get_tx_owner,
+	.set_tx_owner = eqos_set_tx_owner,
+	.set_rx_owner = eqos_set_rx_owner,
+	.get_tx_ls = eqos_get_tx_ls,
+	.get_rx_frame_len = eqos_wrback_get_rx_frame_len,
+	.enable_tx_timestamp = eqos_rd_enable_tx_timestamp,
+	.get_tx_timestamp_status = eqos_wrback_get_tx_timestamp_status,
+	.get_rx_timestamp_status = eqos_wrback_get_rx_timestamp_status,
+	.get_timestamp = eqos_get_timestamp,
+	.set_tx_ic = eqos_rd_set_tx_ic,
+	.prepare_tx_desc = eqos_rd_prepare_tx_desc,
+	.prepare_tso_tx_desc = eqos_rd_prepare_tso_tx_desc,
+	.release_tx_desc = eqos_release_tx_desc,
+	.init_rx_desc = eqos_rd_init_rx_desc,
+	.init_tx_desc = eqos_rd_init_tx_desc,
+	.display_ring = eqos_display_ring,
+	.set_mss = eqos_set_mss_ctxt,
 };
 
-const struct stmmac_mode_ops dwmac4_ring_mode_ops = { };
+const struct stmmac_mode_ops eqos_ring_mode_ops = { };
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h b/drivers/net/ethernet/stmicro/stmmac/eqos_descs.h
similarity index 97%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h
rename to drivers/net/ethernet/stmicro/stmmac/eqos_descs.h
index 9736c50..c9c33e7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h
+++ b/drivers/net/ethernet/stmicro/stmmac/eqos_descs.h
@@ -1,6 +1,6 @@
 /*
  * Header File to describe the DMA descriptors and related definitions specific
- * for DesignWare databook 4.xx.
+ * for DesignWare eQOS.
  *
  * Copyright (C) 2015  STMicroelectronics Ltd
  *
@@ -11,8 +11,8 @@
  * Author: Alexandre Torgue <alexandre.torgue@st.com>
  */
 
-#ifndef __DWMAC4_DESCS_H__
-#define __DWMAC4_DESCS_H__
+#ifndef __EQOS_DESCS_H__
+#define __EQOS_DESCS_H__
 
 #include <linux/bitops.h>
 
@@ -130,4 +130,4 @@
 /* TDS3 use for both format (read and write back) */
 #define RDES3_OWN			BIT(31)
 
-#endif /* __DWMAC4_DESCS_H__ */
+#endif /* __EQOS_DESCS_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/stmicro/stmmac/eqos_dma.c
similarity index 77%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
rename to drivers/net/ethernet/stmicro/stmmac/eqos_dma.c
index 377d1b4..fb4d892 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/eqos_dma.c
@@ -1,6 +1,5 @@
 /*
- * This is the driver for the GMAC on-chip Ethernet controller for ST SoCs.
- * DWC Ether MAC version 4.xx  has been used for  developing this code.
+ * This is the driver for the eQOS on-chip Ethernet controller for ST SoCs.
  *
  * This contains the functions to handle the dma.
  *
@@ -14,15 +13,15 @@
  */
 
 #include <linux/io.h>
-#include "dwmac4.h"
-#include "dwmac4_dma.h"
+#include "eqos.h"
+#include "eqos_dma.h"
 
-static void dwmac4_dma_axi(void __iomem *ioaddr, struct stmmac_axi *axi)
+static void eqos_dma_axi(void __iomem *ioaddr, struct stmmac_axi *axi)
 {
 	u32 value = readl(ioaddr + DMA_SYS_BUS_MODE);
 	int i;
 
-	pr_info("dwmac4: Master AXI performs %s burst length\n",
+	pr_info("eQOS: Master AXI performs %s burst length\n",
 		(value & DMA_SYS_BUS_FB) ? "fixed" : "any");
 
 	if (axi->axi_lpi_en)
@@ -71,7 +70,7 @@ static void dwmac4_dma_axi(void __iomem *ioaddr, struct stmmac_axi *axi)
 	writel(value, ioaddr + DMA_SYS_BUS_MODE);
 }
 
-static void dwmac4_dma_init_channel(void __iomem *ioaddr,
+static void eqos_dma_init_channel(void __iomem *ioaddr,
 				    struct stmmac_dma_cfg *dma_cfg,
 				    u32 dma_tx_phy, u32 dma_rx_phy,
 				    u32 channel)
@@ -103,7 +102,7 @@ static void dwmac4_dma_init_channel(void __iomem *ioaddr,
 	writel(dma_rx_phy, ioaddr + DMA_CHAN_RX_BASE_ADDR(channel));
 }
 
-static void dwmac4_dma_init(void __iomem *ioaddr,
+static void eqos_dma_init(void __iomem *ioaddr,
 			    struct stmmac_dma_cfg *dma_cfg,
 			    u32 dma_tx, u32 dma_rx, int atds)
 {
@@ -124,10 +123,10 @@ static void dwmac4_dma_init(void __iomem *ioaddr,
 	writel(value, ioaddr + DMA_SYS_BUS_MODE);
 
 	for (i = 0; i < DMA_CHANNEL_NB_MAX; i++)
-		dwmac4_dma_init_channel(ioaddr, dma_cfg, dma_tx, dma_rx, i);
+		eqos_dma_init_channel(ioaddr, dma_cfg, dma_tx, dma_rx, i);
 }
 
-static void _dwmac4_dump_dma_regs(void __iomem *ioaddr, u32 channel)
+static void _eqos_dump_dma_regs(void __iomem *ioaddr, u32 channel)
 {
 	pr_debug(" Channel %d\n", channel);
 	pr_debug("\tDMA_CHAN_CONTROL, offset: 0x%x, val: 0x%x\n", 0,
@@ -166,17 +165,17 @@ static void _dwmac4_dump_dma_regs(void __iomem *ioaddr, u32 channel)
 		 readl(ioaddr + DMA_CHAN_STATUS(channel)));
 }
 
-static void dwmac4_dump_dma_regs(void __iomem *ioaddr)
+static void eqos_dump_dma_regs(void __iomem *ioaddr)
 {
 	int i;
 
-	pr_debug(" GMAC4 DMA registers\n");
+	pr_debug("eQOS DMA registers\n");
 
 	for (i = 0; i < DMA_CHANNEL_NB_MAX; i++)
-		_dwmac4_dump_dma_regs(ioaddr, i);
+		_eqos_dump_dma_regs(ioaddr, i);
 }
 
-static void dwmac4_rx_watchdog(void __iomem *ioaddr, u32 riwt)
+static void eqos_rx_watchdog(void __iomem *ioaddr, u32 riwt)
 {
 	int i;
 
@@ -184,7 +183,7 @@ static void dwmac4_rx_watchdog(void __iomem *ioaddr, u32 riwt)
 		writel(riwt, ioaddr + DMA_CHAN_RX_WATCHDOG(i));
 }
 
-static void dwmac4_dma_chan_op_mode(void __iomem *ioaddr, int txmode,
+static void eqos_dma_chan_op_mode(void __iomem *ioaddr, int txmode,
 				    int rxmode, u32 channel)
 {
 	u32 mtl_tx_op, mtl_rx_op, mtl_rx_int;
@@ -195,11 +194,11 @@ static void dwmac4_dma_chan_op_mode(void __iomem *ioaddr, int txmode,
 	mtl_tx_op = readl(ioaddr + MTL_CHAN_TX_OP_MODE(channel));
 
 	if (txmode == SF_DMA_MODE) {
-		pr_debug("GMAC: enable TX store and forward mode\n");
+		pr_debug("eQOS: enable TX store and forward mode\n");
 		/* Transmit COE type 2 cannot be done in cut-through mode. */
 		mtl_tx_op |= MTL_OP_MODE_TSF;
 	} else {
-		pr_debug("GMAC: disabling TX SF (threshold %d)\n", txmode);
+		pr_debug("eQOS: disabling TX SF (threshold %d)\n", txmode);
 		mtl_tx_op &= ~MTL_OP_MODE_TSF;
 		mtl_tx_op &= MTL_OP_MODE_TTC_MASK;
 		/* Set the transmit threshold */
@@ -236,10 +235,10 @@ static void dwmac4_dma_chan_op_mode(void __iomem *ioaddr, int txmode,
 	mtl_rx_op = readl(ioaddr + MTL_CHAN_RX_OP_MODE(channel));
 
 	if (rxmode == SF_DMA_MODE) {
-		pr_debug("GMAC: enable RX store and forward mode\n");
+		pr_debug("eQOS: enable RX store and forward mode\n");
 		mtl_rx_op |= MTL_OP_MODE_RSF;
 	} else {
-		pr_debug("GMAC: disable RX SF mode (threshold %d)\n", rxmode);
+		pr_debug("eQOS: disable RX SF mode (threshold %d)\n", rxmode);
 		mtl_rx_op &= ~MTL_OP_MODE_RSF;
 		mtl_rx_op &= MTL_OP_MODE_RTC_MASK;
 		if (rxmode <= 32)
@@ -260,14 +259,14 @@ static void dwmac4_dma_chan_op_mode(void __iomem *ioaddr, int txmode,
 	       ioaddr + MTL_CHAN_INT_CTRL(channel));
 }
 
-static void dwmac4_dma_operation_mode(void __iomem *ioaddr, int txmode,
+static void eqos_dma_operation_mode(void __iomem *ioaddr, int txmode,
 				      int rxmode, int rxfifosz)
 {
 	/* Only Channel 0 is actually configured and used */
-	dwmac4_dma_chan_op_mode(ioaddr, txmode, rxmode, 0);
+	eqos_dma_chan_op_mode(ioaddr, txmode, rxmode, 0);
 }
 
-static void dwmac4_get_hw_feature(void __iomem *ioaddr,
+static void eqos_get_hw_feature(void __iomem *ioaddr,
 				  struct dma_features *dma_cap)
 {
 	u32 hw_cap = readl(ioaddr + GMAC_HW_FEATURE0);
@@ -314,7 +313,7 @@ static void dwmac4_get_hw_feature(void __iomem *ioaddr,
 }
 
 /* Enable/disable TSO feature and set MSS */
-static void dwmac4_enable_tso(void __iomem *ioaddr, bool en, u32 chan)
+static void eqos_enable_tso(void __iomem *ioaddr, bool en, u32 chan)
 {
 	u32 value;
 
@@ -331,46 +330,46 @@ static void dwmac4_enable_tso(void __iomem *ioaddr, bool en, u32 chan)
 	}
 }
 
-const struct stmmac_dma_ops dwmac4_dma_ops = {
-	.reset = dwmac4_dma_reset,
-	.init = dwmac4_dma_init,
-	.axi = dwmac4_dma_axi,
-	.dump_regs = dwmac4_dump_dma_regs,
-	.dma_mode = dwmac4_dma_operation_mode,
-	.enable_dma_irq = dwmac4_enable_dma_irq,
-	.disable_dma_irq = dwmac4_disable_dma_irq,
-	.start_tx = dwmac4_dma_start_tx,
-	.stop_tx = dwmac4_dma_stop_tx,
-	.start_rx = dwmac4_dma_start_rx,
-	.stop_rx = dwmac4_dma_stop_rx,
-	.dma_interrupt = dwmac4_dma_interrupt,
-	.get_hw_feature = dwmac4_get_hw_feature,
-	.rx_watchdog = dwmac4_rx_watchdog,
-	.set_rx_ring_len = dwmac4_set_rx_ring_len,
-	.set_tx_ring_len = dwmac4_set_tx_ring_len,
-	.set_rx_tail_ptr = dwmac4_set_rx_tail_ptr,
-	.set_tx_tail_ptr = dwmac4_set_tx_tail_ptr,
-	.enable_tso = dwmac4_enable_tso,
+const struct stmmac_dma_ops eqos_dma_ops = {
+	.reset = eqos_dma_reset,
+	.init = eqos_dma_init,
+	.axi = eqos_dma_axi,
+	.dump_regs = eqos_dump_dma_regs,
+	.dma_mode = eqos_dma_operation_mode,
+	.enable_dma_irq = eqos_enable_dma_irq,
+	.disable_dma_irq = eqos_disable_dma_irq,
+	.start_tx = eqos_dma_start_tx,
+	.stop_tx = eqos_dma_stop_tx,
+	.start_rx = eqos_dma_start_rx,
+	.stop_rx = eqos_dma_stop_rx,
+	.dma_interrupt = eqos_dma_interrupt,
+	.get_hw_feature = eqos_get_hw_feature,
+	.rx_watchdog = eqos_rx_watchdog,
+	.set_rx_ring_len = eqos_set_rx_ring_len,
+	.set_tx_ring_len = eqos_set_tx_ring_len,
+	.set_rx_tail_ptr = eqos_set_rx_tail_ptr,
+	.set_tx_tail_ptr = eqos_set_tx_tail_ptr,
+	.enable_tso = eqos_enable_tso,
 };
 
-const struct stmmac_dma_ops dwmac410_dma_ops = {
-	.reset = dwmac4_dma_reset,
-	.init = dwmac4_dma_init,
-	.axi = dwmac4_dma_axi,
-	.dump_regs = dwmac4_dump_dma_regs,
-	.dma_mode = dwmac4_dma_operation_mode,
-	.enable_dma_irq = dwmac410_enable_dma_irq,
-	.disable_dma_irq = dwmac4_disable_dma_irq,
-	.start_tx = dwmac4_dma_start_tx,
-	.stop_tx = dwmac4_dma_stop_tx,
-	.start_rx = dwmac4_dma_start_rx,
-	.stop_rx = dwmac4_dma_stop_rx,
-	.dma_interrupt = dwmac4_dma_interrupt,
-	.get_hw_feature = dwmac4_get_hw_feature,
-	.rx_watchdog = dwmac4_rx_watchdog,
-	.set_rx_ring_len = dwmac4_set_rx_ring_len,
-	.set_tx_ring_len = dwmac4_set_tx_ring_len,
-	.set_rx_tail_ptr = dwmac4_set_rx_tail_ptr,
-	.set_tx_tail_ptr = dwmac4_set_tx_tail_ptr,
-	.enable_tso = dwmac4_enable_tso,
+const struct stmmac_dma_ops eqos10_dma_ops = {
+	.reset = eqos_dma_reset,
+	.init = eqos_dma_init,
+	.axi = eqos_dma_axi,
+	.dump_regs = eqos_dump_dma_regs,
+	.dma_mode = eqos_dma_operation_mode,
+	.enable_dma_irq = eqos10_enable_dma_irq,
+	.disable_dma_irq = eqos_disable_dma_irq,
+	.start_tx = eqos_dma_start_tx,
+	.stop_tx = eqos_dma_stop_tx,
+	.start_rx = eqos_dma_start_rx,
+	.stop_rx = eqos_dma_stop_rx,
+	.dma_interrupt = eqos_dma_interrupt,
+	.get_hw_feature = eqos_get_hw_feature,
+	.rx_watchdog = eqos_rx_watchdog,
+	.set_rx_ring_len = eqos_set_rx_ring_len,
+	.set_tx_ring_len = eqos_set_tx_ring_len,
+	.set_rx_tail_ptr = eqos_set_rx_tail_ptr,
+	.set_tx_tail_ptr = eqos_set_tx_tail_ptr,
+	.enable_tso = eqos_enable_tso,
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h b/drivers/net/ethernet/stmicro/stmmac/eqos_dma.h
similarity index 86%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
rename to drivers/net/ethernet/stmicro/stmmac/eqos_dma.h
index 1b06df7..fa7b5a7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
+++ b/drivers/net/ethernet/stmicro/stmmac/eqos_dma.h
@@ -1,5 +1,5 @@
 /*
- * DWMAC4 DMA Header file.
+ * eQOS DMA Header file.
  *
  *
  * Copyright (C) 2007-2015  STMicroelectronics Ltd
@@ -11,11 +11,11 @@
  * Author: Alexandre Torgue <alexandre.torgue@st.com>
  */
 
-#ifndef __DWMAC4_DMA_H__
-#define __DWMAC4_DMA_H__
+#ifndef __EQOS_DMA_H__
+#define __EQOS_DMA_H__
 
 /* Define the max channel number used for tx (also rx).
- * dwmac4 accepts up to 8 channels for TX (and also 8 channels for RX
+ * eQOS accepts up to 8 channels for TX (and also 8 channels for RX
  */
 #define DMA_CHANNEL_NB_MAX		1
 
@@ -183,20 +183,20 @@
 #define DMA_CHAN0_DBG_STAT_RPS		GENMASK(11, 8)
 #define DMA_CHAN0_DBG_STAT_RPS_SHIFT	8
 
-int dwmac4_dma_reset(void __iomem *ioaddr);
-void dwmac4_enable_dma_transmission(void __iomem *ioaddr, u32 tail_ptr);
-void dwmac4_enable_dma_irq(void __iomem *ioaddr);
-void dwmac410_enable_dma_irq(void __iomem *ioaddr);
-void dwmac4_disable_dma_irq(void __iomem *ioaddr);
-void dwmac4_dma_start_tx(void __iomem *ioaddr);
-void dwmac4_dma_stop_tx(void __iomem *ioaddr);
-void dwmac4_dma_start_rx(void __iomem *ioaddr);
-void dwmac4_dma_stop_rx(void __iomem *ioaddr);
-int dwmac4_dma_interrupt(void __iomem *ioaddr,
+int eqos_dma_reset(void __iomem *ioaddr);
+void eqos_enable_dma_transmission(void __iomem *ioaddr, u32 tail_ptr);
+void eqos_enable_dma_irq(void __iomem *ioaddr);
+void eqos10_enable_dma_irq(void __iomem *ioaddr);
+void eqos_disable_dma_irq(void __iomem *ioaddr);
+void eqos_dma_start_tx(void __iomem *ioaddr);
+void eqos_dma_stop_tx(void __iomem *ioaddr);
+void eqos_dma_start_rx(void __iomem *ioaddr);
+void eqos_dma_stop_rx(void __iomem *ioaddr);
+int eqos_dma_interrupt(void __iomem *ioaddr,
 			 struct stmmac_extra_stats *x);
-void dwmac4_set_rx_ring_len(void __iomem *ioaddr, u32 len);
-void dwmac4_set_tx_ring_len(void __iomem *ioaddr, u32 len);
-void dwmac4_set_rx_tail_ptr(void __iomem *ioaddr, u32 tail_ptr, u32 chan);
-void dwmac4_set_tx_tail_ptr(void __iomem *ioaddr, u32 tail_ptr, u32 chan);
+void eqos_set_rx_ring_len(void __iomem *ioaddr, u32 len);
+void eqos_set_tx_ring_len(void __iomem *ioaddr, u32 len);
+void eqos_set_rx_tail_ptr(void __iomem *ioaddr, u32 tail_ptr, u32 chan);
+void eqos_set_tx_tail_ptr(void __iomem *ioaddr, u32 tail_ptr, u32 chan);
 
-#endif /* __DWMAC4_DMA_H__ */
+#endif /* __EQOS_DMA_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c b/drivers/net/ethernet/stmicro/stmmac/eqos_lib.c
similarity index 83%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
rename to drivers/net/ethernet/stmicro/stmmac/eqos_lib.c
index c7326d5..ddfedce 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
+++ b/drivers/net/ethernet/stmicro/stmmac/eqos_lib.c
@@ -11,10 +11,10 @@
 #include <linux/io.h>
 #include <linux/delay.h>
 #include "common.h"
-#include "dwmac4_dma.h"
-#include "dwmac4.h"
+#include "eqos_dma.h"
+#include "eqos.h"
 
-int dwmac4_dma_reset(void __iomem *ioaddr)
+int eqos_dma_reset(void __iomem *ioaddr)
 {
 	u32 value = readl(ioaddr + DMA_BUS_MODE);
 	int limit;
@@ -35,17 +35,17 @@ int dwmac4_dma_reset(void __iomem *ioaddr)
 	return 0;
 }
 
-void dwmac4_set_rx_tail_ptr(void __iomem *ioaddr, u32 tail_ptr, u32 chan)
+void eqos_set_rx_tail_ptr(void __iomem *ioaddr, u32 tail_ptr, u32 chan)
 {
 	writel(tail_ptr, ioaddr + DMA_CHAN_RX_END_ADDR(0));
 }
 
-void dwmac4_set_tx_tail_ptr(void __iomem *ioaddr, u32 tail_ptr, u32 chan)
+void eqos_set_tx_tail_ptr(void __iomem *ioaddr, u32 tail_ptr, u32 chan)
 {
 	writel(tail_ptr, ioaddr + DMA_CHAN_TX_END_ADDR(0));
 }
 
-void dwmac4_dma_start_tx(void __iomem *ioaddr)
+void eqos_dma_start_tx(void __iomem *ioaddr)
 {
 	u32 value = readl(ioaddr + DMA_CHAN_TX_CONTROL(STMMAC_CHAN0));
 
@@ -57,7 +57,7 @@ void dwmac4_dma_start_tx(void __iomem *ioaddr)
 	writel(value, ioaddr + GMAC_CONFIG);
 }
 
-void dwmac4_dma_stop_tx(void __iomem *ioaddr)
+void eqos_dma_stop_tx(void __iomem *ioaddr)
 {
 	u32 value = readl(ioaddr + DMA_CHAN_TX_CONTROL(STMMAC_CHAN0));
 
@@ -69,7 +69,7 @@ void dwmac4_dma_stop_tx(void __iomem *ioaddr)
 	writel(value, ioaddr + GMAC_CONFIG);
 }
 
-void dwmac4_dma_start_rx(void __iomem *ioaddr)
+void eqos_dma_start_rx(void __iomem *ioaddr)
 {
 	u32 value = readl(ioaddr + DMA_CHAN_RX_CONTROL(STMMAC_CHAN0));
 
@@ -82,7 +82,7 @@ void dwmac4_dma_start_rx(void __iomem *ioaddr)
 	writel(value, ioaddr + GMAC_CONFIG);
 }
 
-void dwmac4_dma_stop_rx(void __iomem *ioaddr)
+void eqos_dma_stop_rx(void __iomem *ioaddr)
 {
 	u32 value = readl(ioaddr + DMA_CHAN_RX_CONTROL(STMMAC_CHAN0));
 
@@ -94,34 +94,34 @@ void dwmac4_dma_stop_rx(void __iomem *ioaddr)
 	writel(value, ioaddr + GMAC_CONFIG);
 }
 
-void dwmac4_set_tx_ring_len(void __iomem *ioaddr, u32 len)
+void eqos_set_tx_ring_len(void __iomem *ioaddr, u32 len)
 {
 	writel(len, ioaddr + DMA_CHAN_TX_RING_LEN(STMMAC_CHAN0));
 }
 
-void dwmac4_set_rx_ring_len(void __iomem *ioaddr, u32 len)
+void eqos_set_rx_ring_len(void __iomem *ioaddr, u32 len)
 {
 	writel(len, ioaddr + DMA_CHAN_RX_RING_LEN(STMMAC_CHAN0));
 }
 
-void dwmac4_enable_dma_irq(void __iomem *ioaddr)
+void eqos_enable_dma_irq(void __iomem *ioaddr)
 {
 	writel(DMA_CHAN_INTR_DEFAULT_MASK, ioaddr +
 	       DMA_CHAN_INTR_ENA(STMMAC_CHAN0));
 }
 
-void dwmac410_enable_dma_irq(void __iomem *ioaddr)
+void eqos10_enable_dma_irq(void __iomem *ioaddr)
 {
 	writel(DMA_CHAN_INTR_DEFAULT_MASK_4_10,
 	       ioaddr + DMA_CHAN_INTR_ENA(STMMAC_CHAN0));
 }
 
-void dwmac4_disable_dma_irq(void __iomem *ioaddr)
+void eqos_disable_dma_irq(void __iomem *ioaddr)
 {
 	writel(0, ioaddr + DMA_CHAN_INTR_ENA(STMMAC_CHAN0));
 }
 
-int dwmac4_dma_interrupt(void __iomem *ioaddr,
+int eqos_dma_interrupt(void __iomem *ioaddr,
 			 struct stmmac_extra_stats *x)
 {
 	int ret = 0;
@@ -177,7 +177,7 @@ int dwmac4_dma_interrupt(void __iomem *ioaddr,
 	return ret;
 }
 
-void stmmac_dwmac4_set_mac_addr(void __iomem *ioaddr, u8 addr[6],
+void stmmac_eqos_set_mac_addr(void __iomem *ioaddr, u8 addr[6],
 				unsigned int high, unsigned int low)
 {
 	unsigned long data;
@@ -194,7 +194,7 @@ void stmmac_dwmac4_set_mac_addr(void __iomem *ioaddr, u8 addr[6],
 }
 
 /* Enable disable MAC RX/TX */
-void stmmac_dwmac4_set_mac(void __iomem *ioaddr, bool enable)
+void stmmac_eqos_set_mac(void __iomem *ioaddr, bool enable)
 {
 	u32 value = readl(ioaddr + GMAC_CONFIG);
 
@@ -206,7 +206,7 @@ void stmmac_dwmac4_set_mac(void __iomem *ioaddr, bool enable)
 	writel(value, ioaddr + GMAC_CONFIG);
 }
 
-void stmmac_dwmac4_get_mac_addr(void __iomem *ioaddr, unsigned char *addr,
+void stmmac_eqos_get_mac_addr(void __iomem *ioaddr, unsigned char *addr,
 				unsigned int high, unsigned int low)
 {
 	unsigned int hi_addr, lo_addr;
diff --git a/drivers/net/ethernet/stmicro/stmmac/mmc.h b/drivers/net/ethernet/stmicro/stmmac/mmc.h
index 38a1a56..4db02a5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/mmc.h
+++ b/drivers/net/ethernet/stmicro/stmmac/mmc.h
@@ -36,7 +36,7 @@
 #define MMC_CNTRL_PRESET		0x10
 #define MMC_CNTRL_FULL_HALF_PRESET	0x20
 
-#define MMC_GMAC4_OFFSET		0x700
+#define MMC_QOS_OFFSET		0x700
 #define MMC_GMAC3_X_OFFSET		0x100
 
 struct stmmac_counters {
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 322e5c6..4a22f8f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -263,7 +263,7 @@ static void stmmac_ethtool_getdrvinfo(struct net_device *dev,
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 
-	if (priv->plat->has_gmac || priv->plat->has_gmac4)
+	if (priv->plat->has_gmac || priv->plat->has_qos)
 		strlcpy(info->driver, GMAC_ETHTOOL_NAME, sizeof(info->driver));
 	else
 		strlcpy(info->driver, MAC100_ETHTOOL_NAME,
@@ -446,7 +446,7 @@ static void stmmac_ethtool_gregs(struct net_device *dev,
 
 	memset(reg_space, 0x0, REG_SPACE_SIZE);
 
-	if (!(priv->plat->has_gmac || priv->plat->has_gmac4)) {
+	if (!(priv->plat->has_gmac || priv->plat->has_qos)) {
 		/* MAC registers */
 		for (i = 0; i < 12; i++)
 			reg_space[i] = readl(priv->ioaddr + (i * 4));
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
index 10d6059..218cadc 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
@@ -34,7 +34,7 @@ static void stmmac_config_hw_tstamping(void __iomem *ioaddr, u32 data)
 }
 
 static u32 stmmac_config_sub_second_increment(void __iomem *ioaddr,
-					      u32 ptp_clock, int gmac4)
+					      u32 ptp_clock, int qos)
 {
 	u32 value = readl(ioaddr + PTP_TCR);
 	unsigned long data;
@@ -54,8 +54,8 @@ static u32 stmmac_config_sub_second_increment(void __iomem *ioaddr,
 
 	data &= PTP_SSIR_SSINC_MASK;
 
-	if (gmac4)
-		data = data << GMAC4_PTP_SSIR_SSINC_SHIFT;
+	if (qos)
+		data = data << QOS_PTP_SSIR_SSINC_SHIFT;
 
 	writel(data, ioaddr + PTP_SSIR);
 
@@ -112,7 +112,7 @@ static int stmmac_config_addend(void __iomem *ioaddr, u32 addend)
 }
 
 static int stmmac_adjust_systime(void __iomem *ioaddr, u32 sec, u32 nsec,
-				 int add_sub, int gmac4)
+				 int add_sub, int qos)
 {
 	u32 value;
 	int limit;
@@ -122,7 +122,7 @@ static int stmmac_adjust_systime(void __iomem *ioaddr, u32 sec, u32 nsec,
 		 * the system time, then MAC_STSUR reg should be
 		 * programmed with (2^32 – <new_sec_value>)
 		 */
-		if (gmac4)
+		if (qos)
 			sec = (100000000ULL - sec);
 
 		value = readl(ioaddr + PTP_TCR);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 38e1fb7..d29b3d4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -398,8 +398,8 @@ static void stmmac_get_rx_hwtstamp(struct stmmac_priv *priv, struct dma_desc *p,
 
 	/* Check if timestamp is available */
 	if (!priv->hw->desc->get_rx_timestamp_status(p, priv->adv_ts)) {
-		/* For GMAC4, the valid timestamp is from CTX next desc. */
-		if (priv->plat->has_gmac4)
+		/* For eQOS, the valid timestamp is from CTX next desc. */
+		if (priv->plat->has_qos)
 			ns = priv->hw->desc->get_timestamp(np, priv->adv_ts);
 		else
 			ns = priv->hw->desc->get_timestamp(p, priv->adv_ts);
@@ -608,7 +608,7 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 		/* program Sub Second Increment reg */
 		sec_inc = priv->hw->ptp->config_sub_second_increment(
 			priv->ptpaddr, priv->plat->clk_ptp_rate,
-			priv->plat->has_gmac4);
+			priv->plat->has_qos);
 		temp = div_u64(1000000000ULL, sec_inc);
 
 		/* calculate default added value:
@@ -647,7 +647,7 @@ static int stmmac_init_ptp(struct stmmac_priv *priv)
 
 	priv->adv_ts = 0;
 	/* Check if adv_ts can be enabled for dwmac 4.x core */
-	if (priv->plat->has_gmac4 && priv->dma_cap.atime_stamp)
+	if (priv->plat->has_qos && priv->dma_cap.atime_stamp)
 		priv->adv_ts = 1;
 	/* Dwmac 3.x core with extend_desc can support adv_ts */
 	else if (priv->extend_desc && priv->dma_cap.atime_stamp)
@@ -721,14 +721,14 @@ static void stmmac_adjust_link(struct net_device *dev)
 			switch (phydev->speed) {
 			case 1000:
 				if (likely((priv->plat->has_gmac) ||
-					   (priv->plat->has_gmac4)))
+					   (priv->plat->has_qos)))
 					ctrl &= ~priv->hw->link.port;
 				stmmac_hw_fix_mac_speed(priv);
 				break;
 			case 100:
 			case 10:
 				if (likely((priv->plat->has_gmac) ||
-					   (priv->plat->has_gmac4))) {
+					   (priv->plat->has_qos))) {
 					ctrl |= priv->hw->link.port;
 					if (phydev->speed == SPEED_100) {
 						ctrl |= priv->hw->link.speed;
@@ -1491,8 +1491,8 @@ static void stmmac_mmc_setup(struct stmmac_priv *priv)
 			    MMC_CNTRL_PRESET | MMC_CNTRL_FULL_HALF_PRESET;
 
 	if (priv->synopsys_id >= DWMAC_CORE_4_00) {
-		priv->ptpaddr = priv->ioaddr + PTP_GMAC4_OFFSET;
-		priv->mmcaddr = priv->ioaddr + MMC_GMAC4_OFFSET;
+		priv->ptpaddr = priv->ioaddr + PTP_QOS_OFFSET;
+		priv->mmcaddr = priv->ioaddr + MMC_QOS_OFFSET;
 	} else {
 		priv->ptpaddr = priv->ioaddr + PTP_GMAC3_X_OFFSET;
 		priv->mmcaddr = priv->ioaddr + MMC_GMAC3_X_OFFSET;
@@ -1715,7 +1715,7 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 
 	/* Enable the MAC Rx/Tx */
 	if (priv->synopsys_id >= DWMAC_CORE_4_00)
-		stmmac_dwmac4_set_mac(priv->ioaddr, true);
+		stmmac_eqos_set_mac(priv->ioaddr, true);
 	else
 		stmmac_set_mac(priv->ioaddr, true);
 
@@ -1979,7 +1979,7 @@ static void stmmac_tso_allocator(struct stmmac_priv *priv, unsigned int des,
  *  @skb : the socket buffer
  *  @dev : device pointer
  *  Description: this is the transmit function that is called on TSO frames
- *  (support available on GMAC4 and newer chips).
+ *  (support available on eQOS and newer chips).
  *  Diagram below show the ring programming in case of TSO frames:
  *
  *  First Descriptor
@@ -2187,7 +2187,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int enh_desc;
 	unsigned int des;
 
-	/* Manage oversized TCP frames for GMAC4 device */
+	/* Manage oversized TCP frames for eQOS device */
 	if (skb_is_gso(skb) && priv->tso) {
 		if (ip_hdr(skb)->protocol == IPPROTO_TCP)
 			return stmmac_tso_xmit(skb, dev);
@@ -2584,10 +2584,10 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 			}
 
 			/* The zero-copy is always used for all the sizes
-			 * in case of GMAC4 because it needs
+			 * in case of eQOS because it needs
 			 * to refill the used descriptors, always.
 			 */
-			if (unlikely(!priv->plat->has_gmac4 &&
+			if (unlikely(!priv->plat->has_qos &&
 				     ((frame_len < priv->rx_copybreak) ||
 				     stmmac_rx_threshold_count(priv)))) {
 				skb = netdev_alloc_skb_ip_align(priv->dev,
@@ -2822,7 +2822,7 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 	}
 
 	/* To handle GMAC own interrupts */
-	if ((priv->plat->has_gmac) || (priv->plat->has_gmac4)) {
+	if ((priv->plat->has_gmac) || (priv->plat->has_qos)) {
 		int status = priv->hw->mac->host_irq_status(priv->hw,
 							    &priv->xstats);
 		if (unlikely(status)) {
@@ -3127,9 +3127,9 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 				      priv->plat->multicast_filter_bins,
 				      priv->plat->unicast_filter_entries,
 				      &priv->synopsys_id);
-	} else if (priv->plat->has_gmac4) {
+	} else if (priv->plat->has_qos) {
 		priv->dev->priv_flags |= IFF_UNICAST_FLT;
-		mac = dwmac4_setup(priv->ioaddr,
+		mac = eqos_setup(priv->ioaddr,
 				   priv->plat->multicast_filter_bins,
 				   priv->plat->unicast_filter_entries,
 				   &priv->synopsys_id);
@@ -3143,7 +3143,7 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 
 	/* To use the chained or ring mode */
 	if (priv->synopsys_id >= DWMAC_CORE_4_00) {
-		priv->hw->mode = &dwmac4_ring_mode_ops;
+		priv->hw->mode = &eqos_ring_mode_ops;
 	} else {
 		if (chain_mode) {
 			priv->hw->mode = &chain_mode_ops;
@@ -3176,7 +3176,7 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 		else
 			priv->plat->tx_coe = priv->dma_cap.tx_coe;
 
-		/* In case of GMAC4 rx_coe is from HW cap register. */
+		/* In case of eQOS rx_coe is from HW cap register. */
 		priv->plat->rx_coe = priv->dma_cap.rx_coe;
 
 		if (priv->dma_cap.rx_coe_type2)
@@ -3188,9 +3188,9 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 		dev_info(priv->device, "No HW DMA feature register supported\n");
 	}
 
-	/* To use alternate (extended), normal or GMAC4 descriptor structures */
+	/* To use alternate (extended), normal or eQOS descriptor structures */
 	if (priv->synopsys_id >= DWMAC_CORE_4_00)
-		priv->hw->desc = &dwmac4_desc_ops;
+		priv->hw->desc = &eqos_desc_ops;
 	else
 		stmmac_selec_desc_mode(priv);
 
@@ -3504,7 +3504,7 @@ int stmmac_resume(struct device *dev)
 	priv->dirty_tx = 0;
 	priv->cur_tx = 0;
 	/* reset private mss value to force mss context settings at
-	 * next tso xmit (only used for gmac4).
+	 * next tso xmit (only used for eQOS).
 	 */
 	priv->mss = 0;
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index b0344c2..cc7a29f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -37,10 +37,10 @@
 #define MII_BUSY 0x00000001
 #define MII_WRITE 0x00000002
 
-/* GMAC4 defines */
-#define MII_GMAC4_GOC_SHIFT		2
-#define MII_GMAC4_WRITE			(1 << MII_GMAC4_GOC_SHIFT)
-#define MII_GMAC4_READ			(3 << MII_GMAC4_GOC_SHIFT)
+/* QOS defines */
+#define MII_QOS_GOC_SHIFT		2
+#define MII_QOS_WRITE			(1 << MII_QOS_GOC_SHIFT)
+#define MII_QOS_READ			(3 << MII_QOS_GOC_SHIFT)
 
 static int stmmac_mdio_busy_wait(void __iomem *ioaddr, unsigned int mii_addr)
 {
@@ -83,8 +83,8 @@ static int stmmac_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg)
 	value |= (phyreg << priv->hw->mii.reg_shift) & priv->hw->mii.reg_mask;
 	value |= (priv->clk_csr << priv->hw->mii.clk_csr_shift)
 		& priv->hw->mii.clk_csr_mask;
-	if (priv->plat->has_gmac4)
-		value |= MII_GMAC4_READ;
+	if (priv->plat->has_qos)
+		value |= MII_QOS_READ;
 
 	if (stmmac_mdio_busy_wait(priv->ioaddr, mii_address))
 		return -EBUSY;
@@ -124,8 +124,8 @@ static int stmmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
 
 	value |= (priv->clk_csr << priv->hw->mii.clk_csr_shift)
 		& priv->hw->mii.clk_csr_mask;
-	if (priv->plat->has_gmac4)
-		value |= MII_GMAC4_WRITE;
+	if (priv->plat->has_qos)
+		value |= MII_QOS_WRITE;
 	else
 		value |= MII_WRITE;
 
@@ -198,10 +198,10 @@ int stmmac_mdio_reset(struct mii_bus *bus)
 
 	/* This is a workaround for problems with the STE101P PHY.
 	 * It doesn't complete its reset until at least one clock cycle
-	 * on MDC, so perform a dummy mdio read. To be upadted for GMAC4
+	 * on MDC, so perform a dummy mdio read. To be upadted for eQOS
 	 * if needed.
 	 */
-	if (!priv->plat->has_gmac4)
+	if (!priv->plat->has_qos)
 		writel(0, priv->ioaddr + mii_address);
 #endif
 	return 0;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 3da4737..24cade3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -47,6 +47,8 @@ struct stmmac_pci_info {
 	struct stmmac_pci_dmi_data *dmi;
 };
 
+static const u8 snps_dev_addr[6] = {0, 0x55, 0x7b, 0xb5, 0x7d, 0xf7};
+
 static int stmmac_pci_find_phy_addr(struct stmmac_pci_info *info)
 {
 	const char *name = dmi_get_system_info(DMI_BOARD_NAME);
@@ -72,10 +74,13 @@ static void stmmac_default_data(struct plat_stmmacenet_data *plat)
 {
 	plat->bus_id = 1;
 	plat->phy_addr = 0;
-	plat->interface = PHY_INTERFACE_MODE_GMII;
-	plat->clk_csr = 2;	/* clk_csr_i = 20-35MHz & MDC = clk_csr_i/16 */
-	plat->has_gmac = 1;
-	plat->force_sf_dma_mode = 1;
+	plat->interface = PHY_INTERFACE_MODE_SGMII;
+	plat->clk_csr = 0x5;
+	plat->has_gmac = 0;
+	plat->has_qos = 1;
+	plat->force_sf_dma_mode = 0;
+	plat->rx_fifo_size = 8192;
+	plat->maxmtu = JUMBO_LEN;
 
 	plat->mdio_bus_data->phy_reset = NULL;
 	plat->mdio_bus_data->phy_mask = 0;
@@ -87,11 +92,11 @@ static void stmmac_default_data(struct plat_stmmacenet_data *plat)
 	/* Set default value for multicast hash bins */
 	plat->multicast_filter_bins = HASH_TABLE_SIZE;
 
+	plat->dma_cfg->fixed_burst = 0;
+	plat->dma_cfg->aal = 0;
+
 	/* Set default value for unicast filter entries */
 	plat->unicast_filter_entries = 1;
-
-	/* Set the maxmtu to a default of JUMBO_LEN */
-	plat->maxmtu = JUMBO_LEN;
 }
 
 static int quark_default_data(struct plat_stmmacenet_data *plat,
@@ -129,9 +134,6 @@ static int quark_default_data(struct plat_stmmacenet_data *plat,
 	/* Set default value for unicast filter entries */
 	plat->unicast_filter_entries = 1;
 
-	/* Set the maxmtu to a default of JUMBO_LEN */
-	plat->maxmtu = JUMBO_LEN;
-
 	return 0;
 }
 
@@ -220,13 +222,15 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 	} else
 		stmmac_default_data(plat);
 
-	pci_enable_msi(pdev);
+	/*pci_enable_msi(pdev);*/
 
 	memset(&res, 0, sizeof(res));
 	res.addr = pcim_iomap_table(pdev)[i];
 	res.wol_irq = pdev->irq;
 	res.irq = pdev->irq;
 
+	res.mac = snps_dev_addr;
+
 	return stmmac_dvr_probe(&pdev->dev, plat, &res);
 }
 
@@ -247,11 +251,15 @@ static SIMPLE_DEV_PM_OPS(stmmac_pm_ops, stmmac_suspend, stmmac_resume);
 #define STMMAC_VENDOR_ID 0x700
 #define STMMAC_QUARK_ID  0x0937
 #define STMMAC_DEVICE_ID 0x1108
+#define DEVICE_ID_HAPS_DX 0x7102
+#define DEVICE_ID_HAPS_6X 0x7101
 
 static const struct pci_device_id stmmac_id_table[] = {
 	{PCI_DEVICE(STMMAC_VENDOR_ID, STMMAC_DEVICE_ID)},
 	{PCI_DEVICE(PCI_VENDOR_ID_STMICRO, PCI_DEVICE_ID_STMICRO_MAC)},
 	{PCI_VDEVICE(INTEL, STMMAC_QUARK_ID), (kernel_ulong_t)&quark_pci_info},
+	{PCI_DEVICE(PCI_VENDOR_ID_SYNOPSYS, DEVICE_ID_HAPS_DX)},
+	{PCI_DEVICE(PCI_VENDOR_ID_SYNOPSYS, DEVICE_ID_HAPS_6X)},
 	{}
 };
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 460f94f..dc9646b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -302,7 +302,7 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 
 	if (of_device_is_compatible(np, "snps,dwmac-4.00") ||
 	    of_device_is_compatible(np, "snps,dwmac-4.10a")) {
-		plat->has_gmac4 = 1;
+		plat->has_qos = 1;
 		plat->has_gmac = 0;
 		plat->pmt = 1;
 		plat->tso_en = of_property_read_bool(np, "snps,tso");
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
index 3eb281d..9f335e0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
@@ -90,7 +90,7 @@ static int stmmac_adjust_time(struct ptp_clock_info *ptp, s64 delta)
 	spin_lock_irqsave(&priv->ptp_lock, flags);
 
 	priv->hw->ptp->adjust_systime(priv->ptpaddr, sec, nsec, neg_adj,
-				      priv->plat->has_gmac4);
+				      priv->plat->has_qos);
 
 	spin_unlock_irqrestore(&priv->ptp_lock, flags);
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
index c06938c..ab96f3c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
@@ -25,7 +25,7 @@
 #ifndef	__STMMAC_PTP_H__
 #define	__STMMAC_PTP_H__
 
-#define	PTP_GMAC4_OFFSET	0xb00
+#define	PTP_QOS_OFFSET	0xb00
 #define	PTP_GMAC3_X_OFFSET	0x700
 
 /* IEEE 1588 PTP register offsets */
@@ -69,6 +69,6 @@
 
 /* SSIR defines */
 #define	PTP_SSIR_SSINC_MASK		0xff
-#define	GMAC4_PTP_SSIR_SSINC_SHIFT	16
+#define	QOS_PTP_SSIR_SSINC_SHIFT	16
 
 #endif	/* __STMMAC_PTP_H__ */
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index d76033d6..134f94d 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -144,7 +144,7 @@ struct plat_stmmacenet_data {
 	unsigned int clk_ptp_rate;
 	struct reset_control *stmmac_rst;
 	struct stmmac_axi *axi;
-	int has_gmac4;
+	int has_qos;
 	bool tso_en;
 	int mac_port_sel_speed;
 	bool en_tx_lpi_clockgating;
-- 
2.9.3
