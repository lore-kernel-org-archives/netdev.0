From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net-next.git) 1/3] drivers: net: stmmac: reworking the PCS code.
Date: Fri, 24 Jun 2016 15:16:24 +0200
Message-ID: <1466774186-2320-2-git-send-email-peppe.cavallaro@st.com>
References: <1466774186-2320-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexandre.torgue@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:5091 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751317AbcFXN1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 09:27:46 -0400
Received: from pps.filterd (m0046668.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5ODO9e3020319
	for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 15:27:44 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx07-00178001.pphosted.com with ESMTP id 23n0hkgmy6-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 15:27:44 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 59F1D34
	for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 13:27:43 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 332D71B88
	for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 13:27:43 +0000 (GMT)
In-Reply-To: <1466774186-2320-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 3.xx and 4.xx synopsys gmacs have a very similar
PCS embedded module and they share almost the same registers:
for example:
  AN_Control, AN_Status, AN_Advertisement, AN_Link_Partner_Ability,
  AN_Expansion, TBI_Extended_Status.

Just the RGMII/SMII Control/Status register differs.

So This patch aims to reorganize and enhance the PCS support.
It removes the existent support from the dwmac1000/dwmac4_core.c
moving basic PCS functions inside a new file called: stmmac_pcs.h.

The patch also reviews the available APIs to be better shared among
different hardware and easily enhanced to support new features.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 Documentation/networking/stmmac.txt                |   1 +
 drivers/net/ethernet/stmicro/stmmac/common.h       |  16 ++-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |  56 +++-----
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   | 110 +++++++-------
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h       |  34 +++--
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  |  73 ++++++----
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |  54 ++++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  12 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_pcs.h   | 159 +++++++++++++++++++++
 9 files changed, 350 insertions(+), 165 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_pcs.h

diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking/stmmac.txt
index 671fe3d..e226f89 100644
--- a/Documentation/networking/stmmac.txt
+++ b/Documentation/networking/stmmac.txt
@@ -285,6 +285,7 @@ Please see the following document:
  o mmc_core.c/mmc.h: Management MAC Counters;
  o stmmac_hwtstamp.c: HW timestamp support for PTP;
  o stmmac_ptp.c: PTP 1588 clock;
+ o stmmac_pcs.h: Physical Coding Sublayer common implementation;
  o dwmac-<XXX>.c: these are for the platform glue-logic file; e.g. dwmac-sti.c
    for STMicroelectronics SoCs.
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index fc60368..86eba2a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -232,6 +232,11 @@ struct stmmac_extra_stats {
 #define DMA_HW_FEAT_ACTPHYIF	0x70000000	/* Active/selected PHY iface */
 #define DEFAULT_DMA_PBL		8
 
+/* PCS status and mask defines */
+#define	PCS_ANE_IRQ		BIT(2)	/* PCS Auto-Negotiation */
+#define	PCS_LINK_IRQ		BIT(1)	/* PCS Link */
+#define	PCS_RGSMIIIS_IRQ	BIT(0)	/* RGMII or SMII Interrupt */
+
 /* Max/Min RI Watchdog Timer count value */
 #define MAX_DMA_RIWT		0xff
 #define MIN_DMA_RIWT		0x20
@@ -272,9 +277,6 @@ enum dma_irq_status {
 #define	CORE_IRQ_RX_PATH_IN_LPI_MODE	(1 << 2)
 #define	CORE_IRQ_RX_PATH_EXIT_LPI_MODE	(1 << 3)
 
-#define	CORE_PCS_ANE_COMPLETE		(1 << 5)
-#define	CORE_PCS_LINK_STATUS		(1 << 6)
-#define	CORE_RGMII_IRQ			(1 << 7)
 #define CORE_IRQ_MTL_RX_OVERFLOW	BIT(8)
 
 /* Physical Coding Sublayer */
@@ -469,9 +471,12 @@ struct stmmac_ops {
 	void (*reset_eee_mode)(struct mac_device_info *hw);
 	void (*set_eee_timer)(struct mac_device_info *hw, int ls, int tw);
 	void (*set_eee_pls)(struct mac_device_info *hw, int link);
-	void (*ctrl_ane)(struct mac_device_info *hw, bool restart);
-	void (*get_adv)(struct mac_device_info *hw, struct rgmii_adv *adv);
 	void (*debug)(void __iomem *ioaddr, struct stmmac_extra_stats *x);
+	/* PCS calls */
+	void (*pcs_ctrl_ane)(void __iomem *ioaddr, bool ane, bool srgmi_ral,
+			     bool loopback);
+	void (*pcs_rane)(void __iomem *ioaddr, bool restart);
+	void (*pcs_get_adv_lp)(void __iomem *ioaddr, struct rgmii_adv *adv);
 };
 
 /* PTP and HW Timer helpers */
@@ -546,6 +551,7 @@ void stmmac_dwmac4_get_mac_addr(void __iomem *ioaddr, unsigned char *addr,
 void stmmac_dwmac4_set_mac(void __iomem *ioaddr, bool enable);
 
 void dwmac_dma_flush_tx_fifo(void __iomem *ioaddr);
+
 extern const struct stmmac_mode_ops ring_mode_ops;
 extern const struct stmmac_mode_ops chain_mode_ops;
 extern const struct stmmac_desc_ops dwmac4_desc_ops;
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
index b0593a4..e671360 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
@@ -46,9 +46,6 @@ enum dwmac1000_irq_status {
 	mmc_rx_irq = 0x0020,
 	mmc_irq = 0x0010,
 	pmt_irq = 0x0008,
-	pcs_ane_irq = 0x0004,
-	pcs_link_irq = 0x0002,
-	rgmii_irq = 0x0001,
 };
 #define GMAC_INT_MASK		0x0000003c	/* interrupt mask register */
 
@@ -90,42 +87,23 @@ enum power_event {
 				(reg * 8))
 #define GMAC_MAX_PERFECT_ADDRESSES	1
 
-/* PCS registers (AN/TBI/SGMII/RGMII) offset */
-#define GMAC_AN_CTRL	0x000000c0	/* AN control */
-#define GMAC_AN_STATUS	0x000000c4	/* AN status */
-#define GMAC_ANE_ADV	0x000000c8	/* Auto-Neg. Advertisement */
-#define GMAC_ANE_LPA	0x000000cc	/* Auto-Neg. link partener ability */
-#define GMAC_ANE_EXP	0x000000d0	/* ANE expansion */
-#define GMAC_TBI	0x000000d4	/* TBI extend status */
-#define GMAC_S_R_GMII	0x000000d8	/* SGMII RGMII status */
-
-/* AN Configuration defines */
-#define GMAC_AN_CTRL_RAN	0x00000200	/* Restart Auto-Negotiation */
-#define GMAC_AN_CTRL_ANE	0x00001000	/* Auto-Negotiation Enable */
-#define GMAC_AN_CTRL_ELE	0x00004000	/* External Loopback Enable */
-#define GMAC_AN_CTRL_ECD	0x00010000	/* Enable Comma Detect */
-#define GMAC_AN_CTRL_LR		0x00020000	/* Lock to Reference */
-#define GMAC_AN_CTRL_SGMRAL	0x00040000	/* SGMII RAL Control */
-
-/* AN Status defines */
-#define GMAC_AN_STATUS_LS	0x00000004	/* Link Status 0:down 1:up */
-#define GMAC_AN_STATUS_ANA	0x00000008	/* Auto-Negotiation Ability */
-#define GMAC_AN_STATUS_ANC	0x00000020	/* Auto-Negotiation Complete */
-#define GMAC_AN_STATUS_ES	0x00000100	/* Extended Status */
-
-/* Register 54 (SGMII/RGMII status register) */
-#define GMAC_S_R_GMII_LINK		0x8
-#define GMAC_S_R_GMII_SPEED		0x5
-#define GMAC_S_R_GMII_SPEED_SHIFT	0x1
-#define GMAC_S_R_GMII_MODE		0x1
-#define GMAC_S_R_GMII_SPEED_125		2
-#define GMAC_S_R_GMII_SPEED_25		1
-
-/* Common ADV and LPA defines */
-#define GMAC_ANE_FD		(1 << 5)
-#define GMAC_ANE_HD		(1 << 6)
-#define GMAC_ANE_PSE		(3 << 7)
-#define GMAC_ANE_PSE_SHIFT	7
+#define GMAC_PCS_BASE		0x000000c0	/* PCS register base */
+#define GMAC_RGSMIIIS		0x000000d8	/* RGMII/SMII status */
+
+/* SGMII/RGMII status register */
+#define GMAC_RGSMIIIS_LNKMODE		BIT(0)
+#define GMAC_RGSMIIIS_SPEED		GENMASK(2, 1)
+#define GMAC_RGSMIIIS_SPEED_SHIFT	1
+#define GMAC_RGSMIIIS_LNKSTS		BIT(3)
+#define GMAC_RGSMIIIS_JABTO		BIT(4)
+#define GMAC_RGSMIIIS_FALSECARDET	BIT(5)
+#define GMAC_RGSMIIIS_SMIDRXS		BIT(16)
+/* LNKMOD */
+#define GMAC_RGSMIIIS_LNKMOD_MASK	0x1
+/* LNKSPEED */
+#define GMAC_RGSMIIIS_SPEED_125		0x2
+#define GMAC_RGSMIIIS_SPEED_25		0x1
+#define GMAC_RGSMIIIS_SPEED_2_5		0x0
 
 /* GMAC Configuration defines */
 #define GMAC_CONTROL_2K 0x08000000	/* IEEE 802.3as 2K packets */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index fb1eb57..9772a43c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -30,6 +30,7 @@
 #include <linux/slab.h>
 #include <linux/ethtool.h>
 #include <asm/io.h>
+#include "stmmac_pcs.h"
 #include "dwmac1000.h"
 
 static void dwmac1000_core_init(struct mac_device_info *hw, int mtu)
@@ -241,6 +242,39 @@ static void dwmac1000_pmt(struct mac_device_info *hw, unsigned long mode)
 	writel(pmt, ioaddr + GMAC_PMT);
 }
 
+/* RGMII or SMII interface */
+static void dwmac1000_rgsmii(void __iomem *ioaddr, struct stmmac_extra_stats *x)
+{
+	u32 status;
+
+	status = readl(ioaddr + GMAC_RGSMIIIS);
+	x->irq_rgmii_n++;
+
+	/* Check the link status */
+	if (status & GMAC_RGSMIIIS_LNKSTS) {
+		int speed_value;
+
+		x->pcs_link = 1;
+
+		speed_value = ((status & GMAC_RGSMIIIS_SPEED) >>
+			       GMAC_RGSMIIIS_SPEED_SHIFT);
+		if (speed_value == GMAC_RGSMIIIS_SPEED_125)
+			x->pcs_speed = SPEED_1000;
+		else if (speed_value == GMAC_RGSMIIIS_SPEED_25)
+			x->pcs_speed = SPEED_100;
+		else
+			x->pcs_speed = SPEED_10;
+
+		x->pcs_duplex = (status & GMAC_RGSMIIIS_LNKMOD_MASK);
+
+		pr_info("Link is Up - %d/%s\n", (int)x->pcs_speed,
+			x->pcs_duplex ? "Full" : "Half");
+	} else {
+		x->pcs_link = 0;
+		pr_info("Link is Down\n");
+	}
+}
+
 static int dwmac1000_irq_status(struct mac_device_info *hw,
 				struct stmmac_extra_stats *x)
 {
@@ -260,6 +294,7 @@ static int dwmac1000_irq_status(struct mac_device_info *hw,
 		readl(ioaddr + GMAC_PMT);
 		x->irq_receive_pmt_irq_n++;
 	}
+
 	/* MAC trx/rx EEE LPI entry/exit interrupts */
 	if (intr_status & lpiis_irq) {
 		/* Clean LPI interrupt by reading the Reg 12 */
@@ -275,36 +310,10 @@ static int dwmac1000_irq_status(struct mac_device_info *hw,
 			x->irq_rx_path_exit_lpi_mode_n++;
 	}
 
-	if ((intr_status & pcs_ane_irq) || (intr_status & pcs_link_irq)) {
-		readl(ioaddr + GMAC_AN_STATUS);
-		x->irq_pcs_ane_n++;
-	}
-	if (intr_status & rgmii_irq) {
-		u32 status = readl(ioaddr + GMAC_S_R_GMII);
-		x->irq_rgmii_n++;
-
-		/* Save and dump the link status. */
-		if (status & GMAC_S_R_GMII_LINK) {
-			int speed_value = (status & GMAC_S_R_GMII_SPEED) >>
-			    GMAC_S_R_GMII_SPEED_SHIFT;
-			x->pcs_duplex = (status & GMAC_S_R_GMII_MODE);
-
-			if (speed_value == GMAC_S_R_GMII_SPEED_125)
-				x->pcs_speed = SPEED_1000;
-			else if (speed_value == GMAC_S_R_GMII_SPEED_25)
-				x->pcs_speed = SPEED_100;
-			else
-				x->pcs_speed = SPEED_10;
-
-			x->pcs_link = 1;
-			pr_debug("%s: Link is Up - %d/%s\n", __func__,
-				 (int)x->pcs_speed,
-				 x->pcs_duplex ? "Full" : "Half");
-		} else {
-			x->pcs_link = 0;
-			pr_debug("%s: Link is Down\n", __func__);
-		}
-	}
+	dwmac_pcs_isr(ioaddr, GMAC_PCS_BASE, intr_status, x);
+
+	if (intr_status & PCS_RGSMIIIS_IRQ)
+		dwmac1000_rgsmii(ioaddr, x);
 
 	return ret;
 }
@@ -363,38 +372,20 @@ static void dwmac1000_set_eee_timer(struct mac_device_info *hw, int ls, int tw)
 	writel(value, ioaddr + LPI_TIMER_CTRL);
 }
 
-static void dwmac1000_ctrl_ane(struct mac_device_info *hw, bool restart)
+static void dwmac1000_ctrl_ane(void __iomem *ioaddr, bool ane, bool srgmi_ral,
+			       bool loopback)
 {
-	void __iomem *ioaddr = hw->pcsr;
-	/* auto negotiation enable and External Loopback enable */
-	u32 value = GMAC_AN_CTRL_ANE | GMAC_AN_CTRL_ELE;
-
-	if (restart)
-		value |= GMAC_AN_CTRL_RAN;
-
-	writel(value, ioaddr + GMAC_AN_CTRL);
+	dwmac_ctrl_ane(ioaddr, GMAC_PCS_BASE, ane, srgmi_ral, loopback);
 }
 
-static void dwmac1000_get_adv(struct mac_device_info *hw, struct rgmii_adv *adv)
+static void dwmac1000_rane(void __iomem *ioaddr, bool restart)
 {
-	void __iomem *ioaddr = hw->pcsr;
-	u32 value = readl(ioaddr + GMAC_ANE_ADV);
-
-	if (value & GMAC_ANE_FD)
-		adv->duplex = DUPLEX_FULL;
-	if (value & GMAC_ANE_HD)
-		adv->duplex |= DUPLEX_HALF;
-
-	adv->pause = (value & GMAC_ANE_PSE) >> GMAC_ANE_PSE_SHIFT;
-
-	value = readl(ioaddr + GMAC_ANE_LPA);
-
-	if (value & GMAC_ANE_FD)
-		adv->lp_duplex = DUPLEX_FULL;
-	if (value & GMAC_ANE_HD)
-		adv->lp_duplex = DUPLEX_HALF;
+	dwmac_rane(ioaddr, GMAC_PCS_BASE, restart);
+}
 
-	adv->lp_pause = (value & GMAC_ANE_PSE) >> GMAC_ANE_PSE_SHIFT;
+static void dwmac1000_get_adv_lp(void __iomem *ioaddr, struct rgmii_adv *adv)
+{
+	dwmac_get_adv_lp(ioaddr, GMAC_PCS_BASE, adv);
 }
 
 static void dwmac1000_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x)
@@ -485,9 +476,10 @@ static const struct stmmac_ops dwmac1000_ops = {
 	.reset_eee_mode = dwmac1000_reset_eee_mode,
 	.set_eee_timer = dwmac1000_set_eee_timer,
 	.set_eee_pls = dwmac1000_set_eee_pls,
-	.ctrl_ane = dwmac1000_ctrl_ane,
-	.get_adv = dwmac1000_get_adv,
 	.debug = dwmac1000_debug,
+	.pcs_ctrl_ane = dwmac1000_ctrl_ane,
+	.pcs_rane = dwmac1000_rane,
+	.pcs_get_adv_lp = dwmac1000_get_adv_lp,
 };
 
 struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr, int mcbins,
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
index bc50952..227fa20 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
@@ -24,10 +24,8 @@
 #define GMAC_QX_TX_FLOW_CTRL(x)		(0x70 + x * 4)
 #define GMAC_INT_STATUS			0x000000b0
 #define GMAC_INT_EN			0x000000b4
-#define GMAC_AN_CTRL			0x000000e0
-#define GMAC_AN_STATUS			0x000000e4
-#define GMAC_AN_ADV			0x000000e8
-#define GMAC_AN_LPA			0x000000ec
+#define GMAC_PCS_BASE			0x000000e0
+#define GMAC_PHYIF_CONTROL_STATUS	0x000000f8
 #define GMAC_PMT			0x000000c0
 #define GMAC_VERSION			0x00000110
 #define GMAC_DEBUG			0x00000114
@@ -64,19 +62,8 @@ enum dwmac4_irq_status {
 	mmc_rx_irq = 0x00000200,
 	mmc_irq = 0x00000100,
 	pmt_irq = 0x00000010,
-	pcs_ane_irq = 0x00000004,
-	pcs_link_irq = 0x00000002,
 };
 
-/* MAC Auto-Neg bitmap*/
-#define	GMAC_AN_CTRL_RAN		BIT(9)
-#define	GMAC_AN_CTRL_ANE		BIT(12)
-#define GMAC_AN_CTRL_ELE		BIT(14)
-#define GMAC_AN_FD			BIT(5)
-#define GMAC_AN_HD			BIT(6)
-#define GMAC_AN_PSE_MASK		GENMASK(8, 7)
-#define GMAC_AN_PSE_SHIFT		7
-
 /* MAC PMT bitmap */
 enum power_event {
 	pointer_reset =	0x80000000,
@@ -250,6 +237,23 @@ enum power_event {
 #define MTL_DEBUG_RRCSTS_FLUSH		3
 #define MTL_DEBUG_RWCSTS		BIT(0)
 
+/* SGMII/RGMII status register */
+#define GMAC_PHYIF_CTRLSTATUS_TC		BIT(0)
+#define GMAC_PHYIF_CTRLSTATUS_LUD		BIT(1)
+#define GMAC_PHYIF_CTRLSTATUS_SMIDRXS		BIT(4)
+#define GMAC_PHYIF_CTRLSTATUS_LNKMOD		BIT(16)
+#define GMAC_PHYIF_CTRLSTATUS_SPEED		GENMASK(18, 17)
+#define GMAC_PHYIF_CTRLSTATUS_SPEED_SHIFT	17
+#define GMAC_PHYIF_CTRLSTATUS_LNKSTS		BIT(19)
+#define GMAC_PHYIF_CTRLSTATUS_JABTO		BIT(20)
+#define GMAC_PHYIF_CTRLSTATUS_FALSECARDET	BIT(21)
+/* LNKMOD */
+#define GMAC_PHYIF_CTRLSTATUS_LNKMOD_MASK	0x1
+/* LNKSPEED */
+#define GMAC_PHYIF_CTRLSTATUS_SPEED_125		0x2
+#define GMAC_PHYIF_CTRLSTATUS_SPEED_25		0x1
+#define GMAC_PHYIF_CTRLSTATUS_SPEED_2_5		0x0
+
 extern const struct stmmac_dma_ops dwmac4_dma_ops;
 extern const struct stmmac_dma_ops dwmac410_dma_ops;
 #endif /* __DWMAC4_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index 44da877..207d8bb 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -17,6 +17,7 @@
 #include <linux/slab.h>
 #include <linux/ethtool.h>
 #include <linux/io.h>
+#include "stmmac_pcs.h"
 #include "dwmac4.h"
 
 static void dwmac4_core_init(struct mac_device_info *hw, int mtu)
@@ -190,39 +191,53 @@ static void dwmac4_flow_ctrl(struct mac_device_info *hw, unsigned int duplex,
 	}
 }
 
-static void dwmac4_ctrl_ane(struct mac_device_info *hw, bool restart)
+static void dwmac4_ctrl_ane(void __iomem *ioaddr, bool ane, bool srgmi_ral,
+			    bool loopback)
 {
-	void __iomem *ioaddr = hw->pcsr;
-
-	/* auto negotiation enable and External Loopback enable */
-	u32 value = GMAC_AN_CTRL_ANE | GMAC_AN_CTRL_ELE;
+	dwmac_ctrl_ane(ioaddr, GMAC_PCS_BASE, ane, srgmi_ral, loopback);
+}
 
-	if (restart)
-		value |= GMAC_AN_CTRL_RAN;
+static void dwmac4_rane(void __iomem *ioaddr, bool restart)
+{
+	dwmac_rane(ioaddr, GMAC_PCS_BASE, restart);
+}
 
-	writel(value, ioaddr + GMAC_AN_CTRL);
+static void dwmac4_get_adv_lp(void __iomem *ioaddr, struct rgmii_adv *adv)
+{
+	dwmac_get_adv_lp(ioaddr, GMAC_PCS_BASE, adv);
 }
 
-static void dwmac4_get_adv(struct mac_device_info *hw, struct rgmii_adv *adv)
+/* RGMII or SMII interface */
+static void dwmac4_phystatus(void __iomem *ioaddr, struct stmmac_extra_stats *x)
 {
-	void __iomem *ioaddr = hw->pcsr;
-	u32 value = readl(ioaddr + GMAC_AN_ADV);
+	u32 status;
 
-	if (value & GMAC_AN_FD)
-		adv->duplex = DUPLEX_FULL;
-	if (value & GMAC_AN_HD)
-		adv->duplex |= DUPLEX_HALF;
+	status = readl(ioaddr + GMAC_PHYIF_CONTROL_STATUS);
+	x->irq_rgmii_n++;
 
-	adv->pause = (value & GMAC_AN_PSE_MASK) >> GMAC_AN_PSE_SHIFT;
+	/* Check the link status */
+	if (status & GMAC_PHYIF_CTRLSTATUS_LNKSTS) {
+		int speed_value;
 
-	value = readl(ioaddr + GMAC_AN_LPA);
+		x->pcs_link = 1;
 
-	if (value & GMAC_AN_FD)
-		adv->lp_duplex = DUPLEX_FULL;
-	if (value & GMAC_AN_HD)
-		adv->lp_duplex = DUPLEX_HALF;
+		speed_value = ((status & GMAC_PHYIF_CTRLSTATUS_SPEED) >>
+			       GMAC_PHYIF_CTRLSTATUS_SPEED_SHIFT);
+		if (speed_value == GMAC_PHYIF_CTRLSTATUS_SPEED_125)
+			x->pcs_speed = SPEED_1000;
+		else if (speed_value == GMAC_PHYIF_CTRLSTATUS_SPEED_25)
+			x->pcs_speed = SPEED_100;
+		else
+			x->pcs_speed = SPEED_10;
+
+		x->pcs_duplex = (status & GMAC_PHYIF_CTRLSTATUS_LNKMOD_MASK);
 
-	adv->lp_pause = (value & GMAC_AN_PSE_MASK) >> GMAC_AN_PSE_SHIFT;
+		pr_info("Link is Up - %d/%s\n", (int)x->pcs_speed,
+			x->pcs_duplex ? "Full" : "Half");
+	} else {
+		x->pcs_link = 0;
+		pr_info("Link is Down\n");
+	}
 }
 
 static int dwmac4_irq_status(struct mac_device_info *hw,
@@ -248,11 +263,6 @@ static int dwmac4_irq_status(struct mac_device_info *hw,
 		x->irq_receive_pmt_irq_n++;
 	}
 
-	if ((intr_status & pcs_ane_irq) || (intr_status & pcs_link_irq)) {
-		readl(ioaddr + GMAC_AN_STATUS);
-		x->irq_pcs_ane_n++;
-	}
-
 	mtl_int_qx_status = readl(ioaddr + MTL_INT_STATUS);
 	/* Check MTL Interrupt: Currently only one queue is used: Q0. */
 	if (mtl_int_qx_status & MTL_INT_Q0) {
@@ -267,6 +277,10 @@ static int dwmac4_irq_status(struct mac_device_info *hw,
 		}
 	}
 
+	dwmac_pcs_isr(ioaddr, GMAC_PCS_BASE, intr_status, x);
+	if (intr_status & PCS_RGSMIIIS_IRQ)
+		dwmac4_phystatus(ioaddr, x);
+
 	return ret;
 }
 
@@ -363,8 +377,9 @@ static const struct stmmac_ops dwmac4_ops = {
 	.pmt = dwmac4_pmt,
 	.set_umac_addr = dwmac4_set_umac_addr,
 	.get_umac_addr = dwmac4_get_umac_addr,
-	.ctrl_ane = dwmac4_ctrl_ane,
-	.get_adv = dwmac4_get_adv,
+	.pcs_ctrl_ane = dwmac4_ctrl_ane,
+	.pcs_rane = dwmac4_rane,
+	.pcs_get_adv_lp = dwmac4_get_adv_lp,
 	.debug = dwmac4_debug,
 	.set_filter = dwmac4_set_filter,
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index e2b98b0..a5f4f46 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -289,10 +289,10 @@ static int stmmac_ethtool_getsettings(struct net_device *dev,
 		ethtool_cmd_speed_set(cmd, priv->xstats.pcs_speed);
 
 		/* Get and convert ADV/LP_ADV from the HW AN registers */
-		if (!priv->hw->mac->get_adv)
+		if (!priv->hw->mac->pcs_get_adv_lp)
 			return -EOPNOTSUPP;	/* should never happen indeed */
 
-		priv->hw->mac->get_adv(priv->hw, &adv);
+		priv->hw->mac->pcs_get_adv_lp(priv->ioaddr, &adv);
 
 		/* Encoding of PSE bits is defined in 802.3z, 37.2.1.4 */
 
@@ -376,8 +376,10 @@ static int stmmac_ethtool_setsettings(struct net_device *dev,
 			ADVERTISED_10baseT_Full);
 
 		spin_lock(&priv->lock);
-		if (priv->hw->mac->ctrl_ane)
-			priv->hw->mac->ctrl_ane(priv->hw, 1);
+
+		if (priv->hw->mac->pcs_ctrl_ane)
+			priv->hw->mac->pcs_ctrl_ane(priv->ioaddr, 1, 0, 0);
+
 		spin_unlock(&priv->lock);
 
 		return 0;
@@ -452,11 +454,22 @@ stmmac_get_pauseparam(struct net_device *netdev,
 {
 	struct stmmac_priv *priv = netdev_priv(netdev);
 
-	if (priv->pcs)	/* FIXME */
-		return;
-
 	pause->rx_pause = 0;
 	pause->tx_pause = 0;
+
+	if (priv->pcs && priv->hw->mac->pcs_get_adv_lp) {
+		struct rgmii_adv adv_lp;
+
+		pause->autoneg = 1;
+		priv->hw->mac->pcs_get_adv_lp(priv->ioaddr, &adv_lp);
+		if (!adv_lp.pause)
+			return;
+	} else {
+		if (!(priv->phydev->supported & SUPPORTED_Pause) ||
+		    !(priv->phydev->supported & SUPPORTED_Asym_Pause))
+			return;
+	}
+
 	pause->autoneg = priv->phydev->autoneg;
 
 	if (priv->flow_ctrl & FLOW_RX)
@@ -473,10 +486,19 @@ stmmac_set_pauseparam(struct net_device *netdev,
 	struct stmmac_priv *priv = netdev_priv(netdev);
 	struct phy_device *phy = priv->phydev;
 	int new_pause = FLOW_OFF;
-	int ret = 0;
 
-	if (priv->pcs)	/* FIXME */
-		return -EOPNOTSUPP;
+	if (priv->pcs && priv->hw->mac->pcs_get_adv_lp) {
+		struct rgmii_adv adv_lp;
+
+		pause->autoneg = 1;
+		priv->hw->mac->pcs_get_adv_lp(priv->ioaddr, &adv_lp);
+		if (!adv_lp.pause)
+			return -EOPNOTSUPP;
+	} else {
+		if (!(phy->supported & SUPPORTED_Pause) ||
+		    !(phy->supported & SUPPORTED_Asym_Pause))
+			return -EOPNOTSUPP;
+	}
 
 	if (pause->rx_pause)
 		new_pause |= FLOW_RX;
@@ -485,14 +507,14 @@ stmmac_set_pauseparam(struct net_device *netdev,
 
 	priv->flow_ctrl = new_pause;
 	phy->autoneg = pause->autoneg;
-
 	if (phy->autoneg) {
 		if (netif_running(netdev))
-			ret = phy_start_aneg(phy);
-	} else
-		priv->hw->mac->flow_ctrl(priv->hw, phy->duplex,
-					 priv->flow_ctrl, priv->pause);
-	return ret;
+			return phy_start_aneg(phy);
+	}
+
+	priv->hw->mac->flow_ctrl(priv->hw, phy->duplex, priv->flow_ctrl,
+				 priv->pause);
+	return 0;
 }
 
 static void stmmac_get_ethtool_stats(struct net_device *dev,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index a473c18..6c43d68 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1714,8 +1714,8 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 		priv->hw->dma->rx_watchdog(priv->ioaddr, MAX_DMA_RIWT);
 	}
 
-	if (priv->pcs && priv->hw->mac->ctrl_ane)
-		priv->hw->mac->ctrl_ane(priv->hw, 0);
+	if (priv->pcs && priv->hw->mac->pcs_ctrl_ane)
+		priv->hw->mac->pcs_ctrl_ane(priv->hw, 1, 0, 0);
 
 	/*  set TX ring length */
 	if (priv->hw->dma->set_tx_ring_len)
@@ -2809,6 +2809,14 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 							priv->rx_tail_addr,
 							STMMAC_CHAN0);
 		}
+
+		/* PCS link status */
+		if (priv->pcs) {
+			if (priv->xstats.pcs_link)
+				netif_carrier_on(dev);
+			else
+				netif_carrier_off(dev);
+		}
 	}
 
 	/* To handle DMA interrupts */
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pcs.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_pcs.h
new file mode 100644
index 0000000..eba41c2
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pcs.h
@@ -0,0 +1,159 @@
+/*
+ * stmmac_pcs.h: Physical Coding Sublayer Header File
+ *
+ * Copyright (C) 2016 STMicroelectronics (R&D) Limited
+ * Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef __STMMAC_PCS_H__
+#define __STMMAC_PCS_H__
+
+#include <linux/slab.h>
+#include <linux/io.h>
+#include "common.h"
+
+/* PCS registers (AN/TBI/SGMII/RGMII) offsets */
+#define GMAC_AN_CTRL(x)		(x)		/* AN control */
+#define GMAC_AN_STATUS(x)	(x + 0x4)	/* AN status */
+#define GMAC_ANE_ADV(x)		(x + 0x8)	/* ANE Advertisement */
+#define GMAC_ANE_LPA(x)		(x + 0xc)	/* ANE link partener ability */
+#define GMAC_ANE_EXP(x)		(x + 0x10)	/* ANE expansion */
+#define GMAC_TBI(x)		(x + 0x14)	/* TBI extend status */
+
+/* AN Configuration defines */
+#define GMAC_AN_CTRL_RAN	BIT(9)	/* Restart Auto-Negotiation */
+#define GMAC_AN_CTRL_ANE	BIT(12)	/* Auto-Negotiation Enable */
+#define GMAC_AN_CTRL_ELE	BIT(14)	/* External Loopback Enable */
+#define GMAC_AN_CTRL_ECD	BIT(16)	/* Enable Comma Detect */
+#define GMAC_AN_CTRL_LR		BIT(17)	/* Lock to Reference */
+#define GMAC_AN_CTRL_SGMRAL	BIT(18)	/* SGMII RAL Control */
+
+/* AN Status defines */
+#define GMAC_AN_STATUS_LS	BIT(2)	/* Link Status 0:down 1:up */
+#define GMAC_AN_STATUS_ANA	BIT(3)	/* Auto-Negotiation Ability */
+#define GMAC_AN_STATUS_ANC	BIT(5)	/* Auto-Negotiation Complete */
+#define GMAC_AN_STATUS_ES	BIT(8)	/* Extended Status */
+
+/* ADV and LPA defines */
+#define GMAC_ANE_FD		BIT(5)
+#define GMAC_ANE_HD		BIT(6)
+#define GMAC_ANE_PSE		GENMASK(8, 7)
+#define GMAC_ANE_PSE_SHIFT	7
+#define GMAC_ANE_RFE		GENMASK(13, 12)
+#define GMAC_ANE_RFE_SHIFT	12
+#define GMAC_ANE_ACK		BIT(14)
+
+/**
+ * dwmac_pcs_isr - TBI, RTBI, or SGMII PHY ISR
+ * @ioaddr: IO registers pointer
+ * @reg: Base address of the AN Control Register.
+ * @intr_status: GMAC core interrupt status
+ * @x: pointer to log these events as stats
+ * Description: it is the ISR for PCS events: Auto-Negotiation Completed and
+ * Link status.
+ */
+static inline void dwmac_pcs_isr(void __iomem *ioaddr, u32 reg,
+				 unsigned int intr_status,
+				 struct stmmac_extra_stats *x)
+{
+	u32 val = readl(ioaddr + GMAC_AN_STATUS(reg));
+
+	if (intr_status & PCS_ANE_IRQ) {
+		x->irq_pcs_ane_n++;
+		if (val & GMAC_AN_STATUS_ANC)
+			pr_info("stmmac_pcs: ANE process completed\n");
+	}
+
+	if (intr_status & PCS_LINK_IRQ) {
+		x->irq_pcs_link_n++;
+		if (val & GMAC_AN_STATUS_LS)
+			pr_info("stmmac_pcs: Link Up\n");
+		else
+			pr_info("stmmac_pcs: Link Down\n");
+	}
+}
+
+/**
+ * dwmac_rane - To restart ANE
+ * @ioaddr: IO registers pointer
+ * @reg: Base address of the AN Control Register.
+ * @restart: to restart ANE
+ * Description: this is to just restart the Auto-Negotiation.
+ */
+static inline void dwmac_rane(void __iomem *ioaddr, u32 reg, bool restart)
+{
+	u32 value = readl(ioaddr + GMAC_AN_CTRL(reg));
+
+	if (restart)
+		value |= GMAC_AN_CTRL_RAN;
+
+	writel(value, ioaddr + GMAC_AN_CTRL(reg));
+}
+
+/**
+ * dwmac_ctrl_ane - To program the AN Control Register.
+ * @ioaddr: IO registers pointer
+ * @reg: Base address of the AN Control Register.
+ * @ane: to enable the auto-negotiation
+ * @srgmi_ral: to manage MAC-2-MAC SGMII connections.
+ * @loopback: to cause the PHY to loopback tx data into rx path.
+ * Description: this is the main function to configure the AN control register
+ * and init the ANE, select loopback (usually for debugging purpose) and
+ * configure SGMII RAL.
+ */
+static inline void dwmac_ctrl_ane(void __iomem *ioaddr, u32 reg, bool ane,
+				  bool srgmi_ral, bool loopback)
+{
+	u32 value = readl(ioaddr + GMAC_AN_CTRL(reg));
+
+	/* Enable and restart the Auto-Negotiation */
+	if (ane)
+		value |= GMAC_AN_CTRL_ANE | GMAC_AN_CTRL_RAN;
+
+	/* In case of MAC-2-MAC connection, block is configured to operate
+	 * according to MAC conf register.
+	 */
+	if (srgmi_ral)
+		value |= GMAC_AN_CTRL_SGMRAL;
+
+	if (loopback)
+		value |= GMAC_AN_CTRL_ELE;
+
+	writel(value, ioaddr + GMAC_AN_CTRL(reg));
+}
+
+/**
+ * dwmac_get_adv_lp - Get ADV and LP cap
+ * @ioaddr: IO registers pointer
+ * @reg: Base address of the AN Control Register.
+ * @adv_lp: structure to store the adv,lp status
+ * Description: this is to expose the ANE advertisement and Link partner ability
+ * status to ethtool support.
+ */
+static inline void dwmac_get_adv_lp(void __iomem *ioaddr, u32 reg,
+				    struct rgmii_adv *adv_lp)
+{
+	u32 value = readl(ioaddr + GMAC_ANE_ADV(reg));
+
+	if (value & GMAC_ANE_FD)
+		adv_lp->duplex = DUPLEX_FULL;
+	if (value & GMAC_ANE_HD)
+		adv_lp->duplex |= DUPLEX_HALF;
+
+	adv_lp->pause = (value & GMAC_ANE_PSE) >> GMAC_ANE_PSE_SHIFT;
+
+	value = readl(ioaddr + GMAC_ANE_LPA(reg));
+
+	if (value & GMAC_ANE_FD)
+		adv_lp->lp_duplex = DUPLEX_FULL;
+	if (value & GMAC_ANE_HD)
+		adv_lp->lp_duplex = DUPLEX_HALF;
+
+	adv_lp->lp_pause = (value & GMAC_ANE_PSE) >> GMAC_ANE_PSE_SHIFT;
+}
+#endif /* __STMMAC_PCS_H__ */
-- 
2.7.4
