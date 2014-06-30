From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net v2 3/3] net: stmmac: Improve mcast/ucast filter for all Synopsys EMAC Configurations
Date: Sun, 29 Jun 2014 20:35:10 -0500
Message-ID: <1404092110-18667-4-git-send-email-vbridgers2013@gmail.com>
References: <1404092110-18667-1-git-send-email-vbridgers2013@gmail.com>
Cc: dinguyen@altera.com, davem@davemloft.net, vbridgers2013@gmail.com,
	vbridger@altera.com
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	peppe.cavallaro@st.com, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	linux@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org,
	robh+dt@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:44366 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753857AbaF3BjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2014 21:39:08 -0400
In-Reply-To: <1404092110-18667-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The synopsys EMAC can be configured for different numbers of multicast hash
bins and perfect filter entries at device creation time and there's no way
to query this configuration information at runtime. As a result, a devicetree
parameter is required in order for the driver to program these filters
correctly for a particular device instance. This patch extends the current
driver by providing a different multicast filter programming function if
different than the currently supported 64 multicast hash bins and 32
perfect unicast addresses. This patch is required to correct multicast
filtering for the Altera Cyclone V SOC.

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
V2: Confirm with Synopsys methods to determine number of Multicast bins
    and Unicast address filter entries per first round review comments.
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |   48 ++++----
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |    2 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |  121 +++++++++++++-------
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |   27 +++--
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    6 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   38 +++---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   52 +++++++++
 include/linux/stmmac.h                             |    2 +
 8 files changed, 203 insertions(+), 93 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 74610f3..686b384 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -368,34 +368,37 @@ struct stmmac_dma_ops {
 	void (*rx_watchdog) (void __iomem *ioaddr, u32 riwt);
 };
 
+struct mac_device_info;
+
 struct stmmac_ops {
 	/* MAC core initialization */
-	void (*core_init) (void __iomem *ioaddr, int mtu);
+	void (*core_init)(struct mac_device_info *hw, int mtu);
 	/* Enable and verify that the IPC module is supported */
-	int (*rx_ipc) (void __iomem *ioaddr);
+	int (*rx_ipc)(struct mac_device_info *hw);
 	/* Dump MAC registers */
-	void (*dump_regs) (void __iomem *ioaddr);
+	void (*dump_regs)(struct mac_device_info *hw);
 	/* Handle extra events on specific interrupts hw dependent */
-	int (*host_irq_status) (void __iomem *ioaddr,
-				struct stmmac_extra_stats *x);
+	int (*host_irq_status)(struct mac_device_info *hw,
+			       struct stmmac_extra_stats *x);
 	/* Multicast filter setting */
-	void (*set_filter) (struct net_device *dev, int id);
+	void (*set_filter)(struct mac_device_info *hw,
+			   struct net_device *dev);
 	/* Flow control setting */
-	void (*flow_ctrl) (void __iomem *ioaddr, unsigned int duplex,
-			   unsigned int fc, unsigned int pause_time);
+	void (*flow_ctrl)(struct mac_device_info *hw, unsigned int duplex,
+			  unsigned int fc, unsigned int pause_time);
 	/* Set power management mode (e.g. magic frame) */
-	void (*pmt) (void __iomem *ioaddr, unsigned long mode);
+	void (*pmt)(struct mac_device_info *hw, unsigned long mode);
 	/* Set/Get Unicast MAC addresses */
-	void (*set_umac_addr) (void __iomem *ioaddr, unsigned char *addr,
-			       unsigned int reg_n);
-	void (*get_umac_addr) (void __iomem *ioaddr, unsigned char *addr,
-			       unsigned int reg_n);
-	void (*set_eee_mode) (void __iomem *ioaddr);
-	void (*reset_eee_mode) (void __iomem *ioaddr);
-	void (*set_eee_timer) (void __iomem *ioaddr, int ls, int tw);
-	void (*set_eee_pls) (void __iomem *ioaddr, int link);
-	void (*ctrl_ane) (void __iomem *ioaddr, bool restart);
-	void (*get_adv) (void __iomem *ioaddr, struct rgmii_adv *adv);
+	void (*set_umac_addr)(struct mac_device_info *hw, unsigned char *addr,
+			      unsigned int reg_n);
+	void (*get_umac_addr)(struct mac_device_info *hw, unsigned char *addr,
+			      unsigned int reg_n);
+	void (*set_eee_mode)(struct mac_device_info *hw);
+	void (*reset_eee_mode)(struct mac_device_info *hw);
+	void (*set_eee_timer)(struct mac_device_info *hw, int ls, int tw);
+	void (*set_eee_pls)(struct mac_device_info *hw, int link);
+	void (*ctrl_ane)(struct mac_device_info *hw, bool restart);
+	void (*get_adv)(struct mac_device_info *hw, struct rgmii_adv *adv);
 };
 
 struct stmmac_hwtimestamp {
@@ -439,9 +442,14 @@ struct mac_device_info {
 	struct mii_regs mii;	/* MII register Addresses */
 	struct mac_link link;
 	unsigned int synopsys_uid;
+	void __iomem *pcsr;	/* vpointer to device CSRs */
+	int multicast_filter_bins;
+	int unicast_filter_entries;
+	int mcast_bits_log2;
 };
 
-struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr);
+struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr,
+					int mcbins, int perfect_uc_entries);
 struct mac_device_info *dwmac100_setup(void __iomem *ioaddr);
 
 void stmmac_set_mac_addr(void __iomem *ioaddr, u8 addr[6],
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
index f37d90f..8abf4cb 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
@@ -87,7 +87,6 @@ enum power_event {
 				(reg * 8))
 #define GMAC_ADDR_LOW(reg)	(((reg > 15) ? 0x00000804 : 0x00000044) + \
 				(reg * 8))
-#define GMAC_MAX_PERFECT_ADDRESSES	32
 
 /* PCS registers (AN/TBI/SGMII/RGMII) offset */
 #define GMAC_AN_CTRL	0x000000c0	/* AN control */
@@ -261,6 +260,7 @@ enum rtc_control {
 #define GMAC_MMC_RX_INTR   0x104
 #define GMAC_MMC_TX_INTR   0x108
 #define GMAC_MMC_RX_CSUM_OFFLOAD   0x208
+#define GMAC_EXTHASH_BASE  0x500
 
 extern const struct stmmac_dma_ops dwmac1000_dma_ops;
 #endif /* __DWMAC1000_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index 9d37483..9ff7e57 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -32,8 +32,9 @@
 #include <asm/io.h>
 #include "dwmac1000.h"
 
-static void dwmac1000_core_init(void __iomem *ioaddr, int mtu)
+static void dwmac1000_core_init(struct mac_device_info *hw, int mtu)
 {
+	void __iomem *ioaddr = hw->pcsr;
 	u32 value = readl(ioaddr + GMAC_CONTROL);
 	value |= GMAC_CORE_INIT;
 	if (mtu > 1500)
@@ -52,8 +53,9 @@ static void dwmac1000_core_init(void __iomem *ioaddr, int mtu)
 #endif
 }
 
-static int dwmac1000_rx_ipc_enable(void __iomem *ioaddr)
+static int dwmac1000_rx_ipc_enable(struct mac_device_info *hw)
 {
+	void __iomem *ioaddr = hw->pcsr;
 	u32 value = readl(ioaddr + GMAC_CONTROL);
 
 	value |= GMAC_CONTROL_IPC;
@@ -64,8 +66,9 @@ static int dwmac1000_rx_ipc_enable(void __iomem *ioaddr)
 	return !!(value & GMAC_CONTROL_IPC);
 }
 
-static void dwmac1000_dump_regs(void __iomem *ioaddr)
+static void dwmac1000_dump_regs(struct mac_device_info *hw)
 {
+	void __iomem *ioaddr = hw->pcsr;
 	int i;
 	pr_info("\tDWMAC1000 regs (base addr = 0x%p)\n", ioaddr);
 
@@ -76,69 +79,91 @@ static void dwmac1000_dump_regs(void __iomem *ioaddr)
 	}
 }
 
-static void dwmac1000_set_umac_addr(void __iomem *ioaddr, unsigned char *addr,
+static void dwmac1000_set_umac_addr(struct mac_device_info *hw,
+				    unsigned char *addr,
 				    unsigned int reg_n)
 {
+	void __iomem *ioaddr = hw->pcsr;
 	stmmac_set_mac_addr(ioaddr, addr, GMAC_ADDR_HIGH(reg_n),
 			    GMAC_ADDR_LOW(reg_n));
 }
 
-static void dwmac1000_get_umac_addr(void __iomem *ioaddr, unsigned char *addr,
+static void dwmac1000_get_umac_addr(struct mac_device_info *hw,
+				    unsigned char *addr,
 				    unsigned int reg_n)
 {
+	void __iomem *ioaddr = hw->pcsr;
 	stmmac_get_mac_addr(ioaddr, addr, GMAC_ADDR_HIGH(reg_n),
 			    GMAC_ADDR_LOW(reg_n));
 }
 
-static void dwmac1000_set_filter(struct net_device *dev, int id)
+static void dwmac1000_set_extmchash(void __iomem *ioaddr, u32 *mcfilterbits,
+				    int numhashregs)
+{
+	int regs;
+
+	for (regs = 0; regs < numhashregs; regs++)
+		writel(mcfilterbits[regs],
+		       ioaddr + GMAC_EXTHASH_BASE + regs * 4);
+}
+
+static void dwmac1000_set_filterex(struct mac_device_info *hw,
+				   struct net_device *dev)
 {
 	void __iomem *ioaddr = (void __iomem *)dev->base_addr;
 	unsigned int value = 0;
 	unsigned int perfect_addr_number;
+	u32 mc_filter[8];
 
 	pr_debug("%s: # mcasts %d, # unicast %d\n", __func__,
 		 netdev_mc_count(dev), netdev_uc_count(dev));
 
-	if (dev->flags & IFF_PROMISC)
+	if (dev->flags & IFF_PROMISC) {
 		value = GMAC_FRAME_FILTER_PR;
-	else if ((netdev_mc_count(dev) > HASH_TABLE_SIZE)
-		 || (dev->flags & IFF_ALLMULTI)) {
+	} else if (dev->flags & IFF_ALLMULTI) {
 		value = GMAC_FRAME_FILTER_PM;	/* pass all multi */
-		writel(0xffffffff, ioaddr + GMAC_HASH_HIGH);
-		writel(0xffffffff, ioaddr + GMAC_HASH_LOW);
 	} else if (!netdev_mc_empty(dev)) {
-		u32 mc_filter[2];
 		struct netdev_hw_addr *ha;
 
+		memset(mc_filter, 0, sizeof(mc_filter));
+
 		/* Hash filter for multicast */
 		value = GMAC_FRAME_FILTER_HMC;
 
-		memset(mc_filter, 0, sizeof(mc_filter));
 		netdev_for_each_mc_addr(ha, dev) {
-			/* The upper 6 bits of the calculated CRC are used to
-			 * index the contens of the hash table
+			/* The upper n bits of the calculated CRC are used to
+			 * index the contents of the hash table depending
+			 * on the particular core's multicast hash size
+			 * configured through Synopsys Core Consultant
 			 */
-			int bit_nr = bitrev32(~crc32_le(~0, ha->addr, 6)) >> 26;
+			int bit_nr = bitrev32(~crc32_le(~0, ha->addr,
+					      ETH_ALEN)) >>
+					     (32 - hw->mcast_bits_log2);
+
 			/* The most significant bit determines the register to
 			 * use (H/L) while the other 5 bits determine the bit
 			 * within the register.
 			 */
 			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
 		}
-		writel(mc_filter[0], ioaddr + GMAC_HASH_LOW);
-		writel(mc_filter[1], ioaddr + GMAC_HASH_HIGH);
+		if (hw->mcast_bits_log2 == 6) {
+			writel(mc_filter[0], ioaddr + GMAC_HASH_LOW);
+			writel(mc_filter[1], ioaddr + GMAC_HASH_HIGH);
+		} else if (hw->mcast_bits_log2 == 7) {
+			dwmac1000_set_extmchash(ioaddr, mc_filter, 4);
+		} else if (hw->mcast_bits_log2 == 8) {
+			dwmac1000_set_extmchash(ioaddr, mc_filter, 8);
+		} else {
+			pr_debug("STMMAC: err in setting mulitcast filter\n");
+		}
 	}
 
-	/* Extra 16 regs are available in cores newer than the 3.40. */
-	if (id > DWMAC_CORE_3_40)
-		perfect_addr_number = GMAC_MAX_PERFECT_ADDRESSES;
-	else
-		perfect_addr_number = GMAC_MAX_PERFECT_ADDRESSES / 2;
+	perfect_addr_number = hw->unicast_filter_entries;
 
 	/* Handle multiple unicast addresses (perfect filtering) */
 	if (netdev_uc_count(dev) > perfect_addr_number)
-		/* Switch to promiscuous mode if more than 16 addrs
-		 * are required
+		/* Switch to promiscuous mode if more unicast addresses
+		 * than maximum supported number are required
 		 */
 		value |= GMAC_FRAME_FILTER_PR;
 	else {
@@ -146,7 +171,7 @@ static void dwmac1000_set_filter(struct net_device *dev, int id)
 		struct netdev_hw_addr *ha;
 
 		netdev_for_each_uc_addr(ha, dev) {
-			dwmac1000_set_umac_addr(ioaddr, ha->addr, reg);
+			dwmac1000_set_umac_addr(hw, ha->addr, reg);
 			reg++;
 		}
 	}
@@ -156,15 +181,12 @@ static void dwmac1000_set_filter(struct net_device *dev, int id)
 	value |= GMAC_FRAME_FILTER_RA;
 #endif
 	writel(value, ioaddr + GMAC_FRAME_FILTER);
-
-	pr_debug("\tFilter: 0x%08x\n\tHash: HI 0x%08x, LO 0x%08x\n",
-		 readl(ioaddr + GMAC_FRAME_FILTER),
-		 readl(ioaddr + GMAC_HASH_HIGH), readl(ioaddr + GMAC_HASH_LOW));
 }
 
-static void dwmac1000_flow_ctrl(void __iomem *ioaddr, unsigned int duplex,
+static void dwmac1000_flow_ctrl(struct mac_device_info *hw, unsigned int duplex,
 				unsigned int fc, unsigned int pause_time)
 {
+	void __iomem *ioaddr = hw->pcsr;
 	unsigned int flow = 0;
 
 	pr_debug("GMAC Flow-Control:\n");
@@ -185,8 +207,9 @@ static void dwmac1000_flow_ctrl(void __iomem *ioaddr, unsigned int duplex,
 	writel(flow, ioaddr + GMAC_FLOW_CTRL);
 }
 
-static void dwmac1000_pmt(void __iomem *ioaddr, unsigned long mode)
+static void dwmac1000_pmt(struct mac_device_info *hw, unsigned long mode)
 {
+	void __iomem *ioaddr = hw->pcsr;
 	unsigned int pmt = 0;
 
 	if (mode & WAKE_MAGIC) {
@@ -201,9 +224,10 @@ static void dwmac1000_pmt(void __iomem *ioaddr, unsigned long mode)
 	writel(pmt, ioaddr + GMAC_PMT);
 }
 
-static int dwmac1000_irq_status(void __iomem *ioaddr,
+static int dwmac1000_irq_status(struct mac_device_info *hw,
 				struct stmmac_extra_stats *x)
 {
+	void __iomem *ioaddr = hw->pcsr;
 	u32 intr_status = readl(ioaddr + GMAC_INT_STATUS);
 	int ret = 0;
 
@@ -268,8 +292,9 @@ static int dwmac1000_irq_status(void __iomem *ioaddr,
 	return ret;
 }
 
-static void dwmac1000_set_eee_mode(void __iomem *ioaddr)
+static void dwmac1000_set_eee_mode(struct mac_device_info *hw)
 {
+	void __iomem *ioaddr = hw->pcsr;
 	u32 value;
 
 	/* Enable the link status receive on RGMII, SGMII ore SMII
@@ -281,8 +306,9 @@ static void dwmac1000_set_eee_mode(void __iomem *ioaddr)
 	writel(value, ioaddr + LPI_CTRL_STATUS);
 }
 
-static void dwmac1000_reset_eee_mode(void __iomem *ioaddr)
+static void dwmac1000_reset_eee_mode(struct mac_device_info *hw)
 {
+	void __iomem *ioaddr = hw->pcsr;
 	u32 value;
 
 	value = readl(ioaddr + LPI_CTRL_STATUS);
@@ -290,8 +316,9 @@ static void dwmac1000_reset_eee_mode(void __iomem *ioaddr)
 	writel(value, ioaddr + LPI_CTRL_STATUS);
 }
 
-static void dwmac1000_set_eee_pls(void __iomem *ioaddr, int link)
+static void dwmac1000_set_eee_pls(struct mac_device_info *hw, int link)
 {
+	void __iomem *ioaddr = hw->pcsr;
 	u32 value;
 
 	value = readl(ioaddr + LPI_CTRL_STATUS);
@@ -304,8 +331,9 @@ static void dwmac1000_set_eee_pls(void __iomem *ioaddr, int link)
 	writel(value, ioaddr + LPI_CTRL_STATUS);
 }
 
-static void dwmac1000_set_eee_timer(void __iomem *ioaddr, int ls, int tw)
+static void dwmac1000_set_eee_timer(struct mac_device_info *hw, int ls, int tw)
 {
+	void __iomem *ioaddr = hw->pcsr;
 	int value = ((tw & 0xffff)) | ((ls & 0x7ff) << 16);
 
 	/* Program the timers in the LPI timer control register:
@@ -318,8 +346,9 @@ static void dwmac1000_set_eee_timer(void __iomem *ioaddr, int ls, int tw)
 	writel(value, ioaddr + LPI_TIMER_CTRL);
 }
 
-static void dwmac1000_ctrl_ane(void __iomem *ioaddr, bool restart)
+static void dwmac1000_ctrl_ane(struct mac_device_info *hw, bool restart)
 {
+	void __iomem *ioaddr = hw->pcsr;
 	/* auto negotiation enable and External Loopback enable */
 	u32 value = GMAC_AN_CTRL_ANE | GMAC_AN_CTRL_ELE;
 
@@ -329,8 +358,9 @@ static void dwmac1000_ctrl_ane(void __iomem *ioaddr, bool restart)
 	writel(value, ioaddr + GMAC_AN_CTRL);
 }
 
-static void dwmac1000_get_adv(void __iomem *ioaddr, struct rgmii_adv *adv)
+static void dwmac1000_get_adv(struct mac_device_info *hw, struct rgmii_adv *adv)
 {
+	void __iomem *ioaddr = hw->pcsr;
 	u32 value = readl(ioaddr + GMAC_ANE_ADV);
 
 	if (value & GMAC_ANE_FD)
@@ -355,7 +385,7 @@ static const struct stmmac_ops dwmac1000_ops = {
 	.rx_ipc = dwmac1000_rx_ipc_enable,
 	.dump_regs = dwmac1000_dump_regs,
 	.host_irq_status = dwmac1000_irq_status,
-	.set_filter = dwmac1000_set_filter,
+	.set_filter = dwmac1000_set_filterex,
 	.flow_ctrl = dwmac1000_flow_ctrl,
 	.pmt = dwmac1000_pmt,
 	.set_umac_addr = dwmac1000_set_umac_addr,
@@ -368,7 +398,8 @@ static const struct stmmac_ops dwmac1000_ops = {
 	.get_adv = dwmac1000_get_adv,
 };
 
-struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr)
+struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr, int mcbins,
+					int perfect_uc_entries)
 {
 	struct mac_device_info *mac;
 	u32 hwid = readl(ioaddr + GMAC_VERSION);
@@ -377,6 +408,14 @@ struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr)
 	if (!mac)
 		return NULL;
 
+	mac->pcsr = ioaddr;
+	mac->multicast_filter_bins = mcbins;
+	mac->unicast_filter_entries = perfect_uc_entries;
+	mac->mcast_bits_log2 = 0;
+
+	if (mac->multicast_filter_bins)
+		mac->mcast_bits_log2 = ilog2(mac->multicast_filter_bins);
+
 	mac->mac = &dwmac1000_ops;
 	mac->dma = &dwmac1000_dma_ops;
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
index 2ff767b..f8dd773 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
@@ -32,8 +32,9 @@
 #include <asm/io.h>
 #include "dwmac100.h"
 
-static void dwmac100_core_init(void __iomem *ioaddr, int mtu)
+static void dwmac100_core_init(struct mac_device_info *hw, int mtu)
 {
+	void __iomem *ioaddr = hw->pcsr;
 	u32 value = readl(ioaddr + MAC_CONTROL);
 
 	writel((value | MAC_CORE_INIT), ioaddr + MAC_CONTROL);
@@ -43,8 +44,9 @@ static void dwmac100_core_init(void __iomem *ioaddr, int mtu)
 #endif
 }
 
-static void dwmac100_dump_mac_regs(void __iomem *ioaddr)
+static void dwmac100_dump_mac_regs(struct mac_device_info *hw)
 {
+	void __iomem *ioaddr = hw->pcsr;
 	pr_info("\t----------------------------------------------\n"
 		"\t  DWMAC 100 CSR (base addr = 0x%p)\n"
 		"\t----------------------------------------------\n", ioaddr);
@@ -66,30 +68,35 @@ static void dwmac100_dump_mac_regs(void __iomem *ioaddr)
 		readl(ioaddr + MAC_VLAN2));
 }
 
-static int dwmac100_rx_ipc_enable(void __iomem *ioaddr)
+static int dwmac100_rx_ipc_enable(struct mac_device_info *hw)
 {
 	return 0;
 }
 
-static int dwmac100_irq_status(void __iomem *ioaddr,
+static int dwmac100_irq_status(struct mac_device_info *hw,
 			       struct stmmac_extra_stats *x)
 {
 	return 0;
 }
 
-static void dwmac100_set_umac_addr(void __iomem *ioaddr, unsigned char *addr,
+static void dwmac100_set_umac_addr(struct mac_device_info *hw,
+				   unsigned char *addr,
 				   unsigned int reg_n)
 {
+	void __iomem *ioaddr = hw->pcsr;
 	stmmac_set_mac_addr(ioaddr, addr, MAC_ADDR_HIGH, MAC_ADDR_LOW);
 }
 
-static void dwmac100_get_umac_addr(void __iomem *ioaddr, unsigned char *addr,
+static void dwmac100_get_umac_addr(struct mac_device_info *hw,
+				   unsigned char *addr,
 				   unsigned int reg_n)
 {
+	void __iomem *ioaddr = hw->pcsr;
 	stmmac_get_mac_addr(ioaddr, addr, MAC_ADDR_HIGH, MAC_ADDR_LOW);
 }
 
-static void dwmac100_set_filter(struct net_device *dev, int id)
+static void dwmac100_set_filter(struct mac_device_info *hw,
+				struct net_device *dev)
 {
 	void __iomem *ioaddr = (void __iomem *)dev->base_addr;
 	u32 value = readl(ioaddr + MAC_CONTROL);
@@ -137,9 +144,10 @@ static void dwmac100_set_filter(struct net_device *dev, int id)
 	writel(value, ioaddr + MAC_CONTROL);
 }
 
-static void dwmac100_flow_ctrl(void __iomem *ioaddr, unsigned int duplex,
+static void dwmac100_flow_ctrl(struct mac_device_info *hw, unsigned int duplex,
 			       unsigned int fc, unsigned int pause_time)
 {
+	void __iomem *ioaddr = hw->pcsr;
 	unsigned int flow = MAC_FLOW_CTRL_ENABLE;
 
 	if (duplex)
@@ -148,7 +156,7 @@ static void dwmac100_flow_ctrl(void __iomem *ioaddr, unsigned int duplex,
 }
 
 /* No PMT module supported on ST boards with this Eth chip. */
-static void dwmac100_pmt(void __iomem *ioaddr, unsigned long mode)
+static void dwmac100_pmt(struct mac_device_info *hw, unsigned long mode)
 {
 	return;
 }
@@ -175,6 +183,7 @@ struct mac_device_info *dwmac100_setup(void __iomem *ioaddr)
 
 	pr_info("\tDWMAC100\n");
 
+	mac->pcsr = ioaddr;
 	mac->mac = &dwmac100_ops;
 	mac->dma = &dwmac100_dma_ops;
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index c62e67f..9af50ba 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -262,7 +262,7 @@ static int stmmac_ethtool_getsettings(struct net_device *dev,
 
 		/* Get and convert ADV/LP_ADV from the HW AN registers */
 		if (priv->hw->mac->get_adv)
-			priv->hw->mac->get_adv(priv->ioaddr, &adv);
+			priv->hw->mac->get_adv(priv->hw, &adv);
 		else
 			return -EOPNOTSUPP;	/* should never happen indeed */
 
@@ -350,7 +350,7 @@ static int stmmac_ethtool_setsettings(struct net_device *dev,
 
 			spin_lock(&priv->lock);
 			if (priv->hw->mac->ctrl_ane)
-				priv->hw->mac->ctrl_ane(priv->ioaddr, 1);
+				priv->hw->mac->ctrl_ane(priv->hw, 1);
 			spin_unlock(&priv->lock);
 		}
 
@@ -464,7 +464,7 @@ stmmac_set_pauseparam(struct net_device *netdev,
 		if (netif_running(netdev))
 			ret = phy_start_aneg(phy);
 	} else
-		priv->hw->mac->flow_ctrl(priv->ioaddr, phy->duplex,
+		priv->hw->mac->flow_ctrl(priv->hw, phy->duplex,
 					 priv->flow_ctrl, priv->pause);
 	return ret;
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 18315f3..08addd6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -233,7 +233,7 @@ static void stmmac_enable_eee_mode(struct stmmac_priv *priv)
 	/* Check and enter in LPI mode */
 	if ((priv->dirty_tx == priv->cur_tx) &&
 	    (priv->tx_path_in_lpi_mode == false))
-		priv->hw->mac->set_eee_mode(priv->ioaddr);
+		priv->hw->mac->set_eee_mode(priv->hw);
 }
 
 /**
@@ -244,7 +244,7 @@ static void stmmac_enable_eee_mode(struct stmmac_priv *priv)
  */
 void stmmac_disable_eee_mode(struct stmmac_priv *priv)
 {
-	priv->hw->mac->reset_eee_mode(priv->ioaddr);
+	priv->hw->mac->reset_eee_mode(priv->hw);
 	del_timer_sync(&priv->eee_ctrl_timer);
 	priv->tx_path_in_lpi_mode = false;
 }
@@ -298,7 +298,7 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
 			if (priv->eee_active) {
 				pr_debug("stmmac: disable EEE\n");
 				del_timer_sync(&priv->eee_ctrl_timer);
-				priv->hw->mac->set_eee_timer(priv->ioaddr, 0,
+				priv->hw->mac->set_eee_timer(priv->hw, 0,
 							     tx_lpi_timer);
 			}
 			priv->eee_active = 0;
@@ -313,12 +313,12 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
 			priv->eee_ctrl_timer.expires = STMMAC_LPI_T(eee_timer);
 			add_timer(&priv->eee_ctrl_timer);
 
-			priv->hw->mac->set_eee_timer(priv->ioaddr,
+			priv->hw->mac->set_eee_timer(priv->hw,
 						     STMMAC_DEFAULT_LIT_LS,
 						     tx_lpi_timer);
 		} else
 			/* Set HW EEE according to the speed */
-			priv->hw->mac->set_eee_pls(priv->ioaddr,
+			priv->hw->mac->set_eee_pls(priv->hw,
 						   priv->phydev->link);
 
 		pr_debug("stmmac: Energy-Efficient Ethernet initialized\n");
@@ -693,7 +693,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 		}
 		/* Flow Control operation */
 		if (phydev->pause)
-			priv->hw->mac->flow_ctrl(priv->ioaddr, phydev->duplex,
+			priv->hw->mac->flow_ctrl(priv->hw, phydev->duplex,
 						 fc, pause_time);
 
 		if (phydev->speed != priv->speed) {
@@ -1531,8 +1531,7 @@ static int stmmac_get_hw_features(struct stmmac_priv *priv)
 static void stmmac_check_ether_addr(struct stmmac_priv *priv)
 {
 	if (!is_valid_ether_addr(priv->dev->dev_addr)) {
-		priv->hw->mac->get_umac_addr((void __iomem *)
-					     priv->dev->base_addr,
+		priv->hw->mac->get_umac_addr(priv->hw,
 					     priv->dev->dev_addr, 0);
 		if (!is_valid_ether_addr(priv->dev->dev_addr))
 			eth_hw_addr_random(priv->dev);
@@ -1629,14 +1628,14 @@ static int stmmac_hw_setup(struct net_device *dev)
 	}
 
 	/* Copy the MAC addr into the HW  */
-	priv->hw->mac->set_umac_addr(priv->ioaddr, dev->dev_addr, 0);
+	priv->hw->mac->set_umac_addr(priv->hw, dev->dev_addr, 0);
 
 	/* If required, perform hw setup of the bus. */
 	if (priv->plat->bus_setup)
 		priv->plat->bus_setup(priv->ioaddr);
 
 	/* Initialize the MAC Core */
-	priv->hw->mac->core_init(priv->ioaddr, dev->mtu);
+	priv->hw->mac->core_init(priv->hw, dev->mtu);
 
 	/* Enable the MAC Rx/Tx */
 	stmmac_set_mac(priv->ioaddr, true);
@@ -1662,7 +1661,7 @@ static int stmmac_hw_setup(struct net_device *dev)
 
 	/* Dump DMA/MAC registers */
 	if (netif_msg_hw(priv)) {
-		priv->hw->mac->dump_regs(priv->ioaddr);
+		priv->hw->mac->dump_regs(priv->hw);
 		priv->hw->dma->dump_regs(priv->ioaddr);
 	}
 	priv->tx_lpi_timer = STMMAC_DEFAULT_TWT_LS;
@@ -1677,7 +1676,7 @@ static int stmmac_hw_setup(struct net_device *dev)
 	}
 
 	if (priv->pcs && priv->hw->mac->ctrl_ane)
-		priv->hw->mac->ctrl_ane(priv->ioaddr, 0);
+		priv->hw->mac->ctrl_ane(priv->hw, 0);
 
 	return 0;
 }
@@ -2226,7 +2225,7 @@ static void stmmac_set_rx_mode(struct net_device *dev)
 	struct stmmac_priv *priv = netdev_priv(dev);
 
 	spin_lock(&priv->lock);
-	priv->hw->mac->set_filter(dev, priv->synopsys_id);
+	priv->hw->mac->set_filter(priv->hw, dev);
 	spin_unlock(&priv->lock);
 }
 
@@ -2316,8 +2315,7 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 
 	/* To handle GMAC own interrupts */
 	if (priv->plat->has_gmac) {
-		int status = priv->hw->mac->host_irq_status((void __iomem *)
-							    dev->base_addr,
+		int status = priv->hw->mac->host_irq_status(priv->hw,
 							    &priv->xstats);
 		if (unlikely(status)) {
 			/* For LPI we need to save the tx status */
@@ -2600,7 +2598,9 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 	/* Identify the MAC HW device */
 	if (priv->plat->has_gmac) {
 		priv->dev->priv_flags |= IFF_UNICAST_FLT;
-		mac = dwmac1000_setup(priv->ioaddr);
+		mac = dwmac1000_setup(priv->ioaddr,
+				      priv->plat->multicast_filter_bins,
+				      priv->plat->unicast_filter_entries);
 	} else {
 		mac = dwmac100_setup(priv->ioaddr);
 	}
@@ -2649,7 +2649,7 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 	/* To use alternate (extended) or normal descriptor structures */
 	stmmac_selec_desc_mode(priv);
 
-	ret = priv->hw->mac->rx_ipc(priv->ioaddr);
+	ret = priv->hw->mac->rx_ipc(priv->hw);
 	if (!ret) {
 		pr_warn(" RX IPC Checksum Offload not configured.\n");
 		priv->plat->rx_coe = STMMAC_RX_COE_NONE;
@@ -2869,7 +2869,7 @@ int stmmac_suspend(struct net_device *ndev)
 
 	/* Enable Power down mode by programming the PMT regs */
 	if (device_may_wakeup(priv->device)) {
-		priv->hw->mac->pmt(priv->ioaddr, priv->wolopts);
+		priv->hw->mac->pmt(priv->hw, priv->wolopts);
 		priv->irq_wake = 1;
 	} else {
 		stmmac_set_mac(priv->ioaddr, false);
@@ -2902,7 +2902,7 @@ int stmmac_resume(struct net_device *ndev)
 	 * from another devices (e.g. serial console).
 	 */
 	if (device_may_wakeup(priv->device)) {
-		priv->hw->mac->pmt(priv->ioaddr, 0);
+		priv->hw->mac->pmt(priv->hw, 0);
 		priv->irq_wake = 0;
 	} else {
 		pinctrl_pm_select_default_state(priv->device);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index ea7a65b..f0c51c7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -51,6 +51,44 @@ static const struct of_device_id stmmac_dt_ids[] = {
 };
 MODULE_DEVICE_TABLE(of, stmmac_dt_ids);
 
+
+static int stmmac_validate_mcast_bins(int mcast_bins)
+{
+	int x = mcast_bins;
+
+	switch (x) {
+	case 0:
+	case HASH_TABLE_SIZE:
+	case 128:
+	case 256:
+		break;
+	default:
+		x = HASH_TABLE_SIZE;
+		pr_info("Hash table entries set to unexpected value %d",
+			mcast_bins);
+		break;
+	}
+	return x;
+}
+
+static int stmmac_validate_ucast_entries(int ucast_entries)
+{
+	int x = ucast_entries;
+
+	switch (x) {
+	case 32:
+	case 64:
+	case 128:
+		break;
+	default:
+		x = 32;
+		pr_info("Unicast table entries set to unexpected value %d\n",
+			ucast_entries);
+		break;
+	}
+	return x;
+}
+
 #ifdef CONFIG_OF
 static int stmmac_probe_config_dt(struct platform_device *pdev,
 				  struct plat_stmmacenet_data *plat,
@@ -115,6 +153,12 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 	 */
 	plat->maxmtu = JUMBO_LEN;
 
+	/* Set default value for multicast hash bins */
+	plat->multicast_filter_bins = HASH_TABLE_SIZE;
+
+	/* Set default value for unicast filter entries */
+	plat->unicast_filter_entries = 1;
+
 	/*
 	 * Currently only the properties needed on SPEAr600
 	 * are provided. All other properties should be added
@@ -131,6 +175,14 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 		 * are clearly MTUs
 		 */
 		of_property_read_u32(np, "max-frame-size", &plat->maxmtu);
+		of_property_read_u32(np, "snps,multicast-filter-bins",
+				     &plat->multicast_filter_bins);
+		of_property_read_u32(np, "snps,perfect-filter-entries",
+				     &plat->unicast_filter_entries);
+		plat->unicast_filter_entries = stmmac_validate_ucast_entries(
+				     plat->unicast_filter_entries);
+		plat->multicast_filter_bins = stmmac_validate_mcast_bins(
+				     plat->multicast_filter_bins);
 		plat->has_gmac = 1;
 		plat->pmt = 1;
 	}
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 6f27d4f..cd63851 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -112,6 +112,8 @@ struct plat_stmmacenet_data {
 	int riwt_off;
 	int max_speed;
 	int maxmtu;
+	int multicast_filter_bins;
+	int unicast_filter_entries;
 	void (*fix_mac_speed)(void *priv, unsigned int speed);
 	void (*bus_setup)(void __iomem *ioaddr);
 	void *(*setup)(struct platform_device *pdev);
-- 
1.7.9.5
