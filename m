From: Christophe Roullier <christophe.roullier@st.com>
Subject: [PATCH] net: ethernet: stmmac: add ARP management
Date: Tue, 17 Jan 2017 17:56:40 +0100
Message-ID: <1484672200-7755-1-git-send-email-christophe.roullier@st.com>
Mime-Version: 1.0
Content-Type: text/plain
To: Alexandre Torgue <alexandre.torgue@st.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Christophe Roullier <christophe.roullier@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DWC_ether_qos supports the Address Recognition
Protocol (ARP) Offload for IPv4 packets. This feature
allows the processing of the IPv4 ARP request packet
in the receive path and generating corresponding ARP
response packet in the transmit path. DWC_ether_qos
generates the ARP reply packets for appropriate ARP
request packets.

Signed-off-by: Christophe Roullier <christophe.roullier@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |  4 ++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h       |  3 +++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  | 15 ++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c   | 23 ++++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |  1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 13 ++++++++++++
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  1 +
 include/linux/stmmac.h                             |  1 +
 8 files changed, 61 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 75e2666..1d1c815 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -306,6 +306,7 @@ struct dma_features {
 	unsigned int pmt_remote_wake_up;
 	unsigned int pmt_magic_frame;
 	unsigned int rmon;
+	unsigned int arpoffsel;
 	/* IEEE 1588-2002 */
 	unsigned int time_stamp;
 	/* IEEE 1588-2008 */
@@ -447,6 +448,7 @@ struct stmmac_dma_ops {
 	void (*set_rx_tail_ptr)(void __iomem *ioaddr, u32 tail_ptr, u32 chan);
 	void (*set_tx_tail_ptr)(void __iomem *ioaddr, u32 tail_ptr, u32 chan);
 	void (*enable_tso)(void __iomem *ioaddr, bool en, u32 chan);
+	void (*set_arp_addr)(void __iomem *ioaddr, bool en, u32 addr);
 };
 
 struct mac_device_info;
@@ -459,6 +461,8 @@ struct stmmac_ops {
 	int (*rx_ipc)(struct mac_device_info *hw);
 	/* Enable RX Queues */
 	void (*rx_queue_enable)(struct mac_device_info *hw, u32 queue);
+	/* Enable and verify that the ARP feature is supported */
+	int (*arp_en)(struct mac_device_info *hw);
 	/* Dump MAC registers */
 	void (*dump_regs)(struct mac_device_info *hw);
 	/* Handle extra events on specific interrupts hw dependent */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
index db45134..d1e2e37 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
@@ -35,6 +35,7 @@
 #define GMAC_HW_FEATURE2		0x00000124
 #define GMAC_MDIO_ADDR			0x00000200
 #define GMAC_MDIO_DATA			0x00000204
+#define GMAC_ARP_ADDR			0x00000210
 #define GMAC_ADDR_HIGH(reg)		(0x300 + reg * 8)
 #define GMAC_ADDR_LOW(reg)		(0x304 + reg * 8)
 
@@ -116,6 +117,7 @@ enum power_event {
 #define GMAC_DEBUG_RPESTS		BIT(0)
 
 /* MAC config */
+#define GMAC_CONFIG_ARPEN		BIT(31)
 #define GMAC_CONFIG_IPC			BIT(27)
 #define GMAC_CONFIG_2K			BIT(22)
 #define GMAC_CONFIG_ACS			BIT(20)
@@ -135,6 +137,7 @@ enum power_event {
 #define GMAC_HW_FEAT_TXCOSEL		BIT(14)
 #define GMAC_HW_FEAT_EEESEL		BIT(13)
 #define GMAC_HW_FEAT_TSSEL		BIT(12)
+#define GMAC_HW_FEAT_ARPOFFSEL		BIT(9)
 #define GMAC_HW_FEAT_MMCSEL		BIT(8)
 #define GMAC_HW_FEAT_MGKSEL		BIT(7)
 #define GMAC_HW_FEAT_RWKSEL		BIT(6)
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index 834f40f..33d0fb3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -102,6 +102,20 @@ static int dwmac4_rx_ipc_enable(struct mac_device_info *hw)
 	return !!(value & GMAC_CONFIG_IPC);
 }
 
+static int dwmac4_arp_enable(struct mac_device_info *hw)
+{
+	void __iomem *ioaddr = hw->pcsr;
+	u32 value = readl(ioaddr + GMAC_CONFIG);
+
+	value |= GMAC_CONFIG_ARPEN;
+
+	writel(value, ioaddr + GMAC_CONFIG);
+
+	value = readl(ioaddr + GMAC_CONFIG);
+
+	return !!(value & GMAC_CONFIG_ARPEN);
+}
+
 static void dwmac4_pmt(struct mac_device_info *hw, unsigned long mode)
 {
 	void __iomem *ioaddr = hw->pcsr;
@@ -463,6 +477,7 @@ static void dwmac4_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x)
 	.core_init = dwmac4_core_init,
 	.rx_ipc = dwmac4_rx_ipc_enable,
 	.rx_queue_enable = dwmac4_rx_queue_enable,
+	.arp_en = dwmac4_arp_enable,
 	.dump_regs = dwmac4_dump_regs,
 	.host_irq_status = dwmac4_irq_status,
 	.flow_ctrl = dwmac4_flow_ctrl,
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
index 377d1b4..fbbd303 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
@@ -284,6 +284,8 @@ static void dwmac4_get_hw_feature(void __iomem *ioaddr,
 	dma_cap->pmt_magic_frame = (hw_cap & GMAC_HW_FEAT_MGKSEL) >> 7;
 	/* MMC */
 	dma_cap->rmon = (hw_cap & GMAC_HW_FEAT_MMCSEL) >> 8;
+	/* ARP */
+	dma_cap->arpoffsel = (hw_cap & GMAC_HW_FEAT_ARPOFFSEL) >> 9;
 	/* IEEE 1588-2008 */
 	dma_cap->atime_stamp = (hw_cap & GMAC_HW_FEAT_TSSEL) >> 12;
 	/* 802.3az - Energy-Efficient Ethernet (EEE) */
@@ -331,6 +333,25 @@ static void dwmac4_enable_tso(void __iomem *ioaddr, bool en, u32 chan)
 	}
 }
 
+/* Set ARP Address */
+static void dwmac4_set_arp_addr(void __iomem *ioaddr, bool set, u32 addr)
+{
+	u32 value;
+
+	value = readl(ioaddr + GMAC_ARP_ADDR);
+
+	if (set) {
+		/* set arp address */
+		value = addr;
+	} else {
+		/* unset arp address */
+		value = 0;
+	}
+
+	writel(value, ioaddr + GMAC_ARP_ADDR);
+	value = readl(ioaddr + GMAC_ARP_ADDR);
+}
+
 const struct stmmac_dma_ops dwmac4_dma_ops = {
 	.reset = dwmac4_dma_reset,
 	.init = dwmac4_dma_init,
@@ -351,6 +372,7 @@ static void dwmac4_enable_tso(void __iomem *ioaddr, bool en, u32 chan)
 	.set_rx_tail_ptr = dwmac4_set_rx_tail_ptr,
 	.set_tx_tail_ptr = dwmac4_set_tx_tail_ptr,
 	.enable_tso = dwmac4_enable_tso,
+	.set_arp_addr = dwmac4_set_arp_addr,
 };
 
 const struct stmmac_dma_ops dwmac410_dma_ops = {
@@ -373,4 +395,5 @@ static void dwmac4_enable_tso(void __iomem *ioaddr, bool en, u32 chan)
 	.set_rx_tail_ptr = dwmac4_set_rx_tail_ptr,
 	.set_tx_tail_ptr = dwmac4_set_tx_tail_ptr,
 	.enable_tso = dwmac4_enable_tso,
+	.set_arp_addr = dwmac4_set_arp_addr,
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index bf8a83e..51666fa 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -67,6 +67,7 @@ struct stmmac_priv {
 	bool tx_path_in_lpi_mode;
 	struct timer_list txtimer;
 	bool tso;
+	int arp;
 
 	struct dma_desc *dma_rx	____cacheline_aligned_in_smp;
 	struct dma_extended_desc *dma_erx;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index d481c5f..2217dc3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3284,6 +3284,19 @@ int stmmac_dvr_probe(struct device *device,
 		priv->tso = true;
 		dev_info(priv->device, "TSO feature enabled\n");
 	}
+
+	if ((priv->plat->arp_en) && (priv->dma_cap.arpoffsel)) {
+		ret = priv->hw->mac->arp_en(priv->hw);
+		if (!ret) {
+			pr_warn(" ARP feature disabled\n");
+		} else {
+			pr_info(" ARP feature enabled\n");
+			/* Copy MAC addr into MAC_ARP_ADDRESS register*/
+			priv->hw->dma->set_arp_addr(priv->ioaddr, 1,
+						    priv->dev->dev_addr);
+		}
+	}
+
 	ndev->features |= ndev->hw_features | NETIF_F_HIGHDMA;
 	ndev->watchdog_timeo = msecs_to_jiffies(watchdog);
 #ifdef STMMAC_VLAN_TAG_USED
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 4daa8a3..92a0db9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -306,6 +306,7 @@ struct plat_stmmacenet_data *
 		plat->has_gmac = 0;
 		plat->pmt = 1;
 		plat->tso_en = of_property_read_bool(np, "snps,tso");
+		plat->arp_en = of_property_read_bool(np, "snps,arp");
 	}
 
 	if (of_device_is_compatible(np, "snps,dwmac-3.610") ||
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index d76033d6..2491285 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -148,5 +148,6 @@ struct plat_stmmacenet_data {
 	bool tso_en;
 	int mac_port_sel_speed;
 	bool en_tx_lpi_clockgating;
+	bool arp_en;
 };
 #endif
-- 
1.9.1
