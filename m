From: wfg@linux.intel.com
Subject: [net-next:master 294/295]
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:287:3: error: implicit
 declaration of function 'phy_init_eee'
Date: Sun, 1 Jul 2012 19:35:21 +0800
Message-ID: <20120701113521.GA11294@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="yrj/dFKFPuw6o+aM"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:43575 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932124Ab2GALfX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jul 2012 07:35:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--yrj/dFKFPuw6o+aM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Giuseppe,

Here is a build dependency: the below commit used some functions
provided by the immediate next commit "phy: add the EEE support and
the way to access to the MMD registers."

---
Kernel build failed on

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   a59a4d1921664da63d801ba477950114c71c88c9
commit: d765955d2ae0b88781a0db3a5bacfe4241925e09 [294/295] stmmac: add the Energy Efficient Ethernet support
config: x86_64-allmodconfig

All related error/warning messages:

drivers/net/ethernet/stmicro/stmmac/stmmac_main.c: In function 'stmmac_eee_init':
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:287:3: error: implicit declaration of function 'phy_init_eee' [-Werror=implicit-function-declaration]
drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c: In function 'stmmac_get_ethtool_stats':
drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c:380:4: error: implicit declaration of function 'phy_get_eee_err' [-Werror=implicit-function-declaration]
drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c: In function 'stmmac_ethtool_op_get_eee':
drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c:494:2: error: implicit declaration of function 'phy_ethtool_get_eee' [-Werror=implicit-function-declaration]
drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c: In function 'stmmac_ethtool_op_set_eee':
drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c:519:2: error: implicit declaration of function 'phy_ethtool_set_eee' [-Werror=implicit-function-declaration]

drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:287:
   284		/* MAC core supports the EEE feature. */
   285		if (priv->dma_cap.eee) {
   286			/* Check if the PHY supports EEE */
 > 287			if (phy_init_eee(priv->phydev, 1))
   288				goto out;
   289	
   290			priv->eee_active = 1;

---
0-DAY kernel build testing backend         Open Source Technology Centre
Fengguang Wu <wfg@linux.intel.com>                     Intel Corporation

--yrj/dFKFPuw6o+aM
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-stmmac-add-the-Energy-Efficient-Ethernet-support.patch"

>From d765955d2ae0b88781a0db3a5bacfe4241925e09 Mon Sep 17 00:00:00 2001
From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Wed, 27 Jun 2012 21:14:37 +0000
Subject: [PATCH] stmmac: add the Energy Efficient Ethernet support

This patch adds the Energy Efficient Ethernet support to the stmmac.

Please see the driver's documentation for further details about this support
in the driver.

Thanks also goes to Rayagond Kokatanur for his first implementation.

Note:
 to clearly manage and expose the lpi interrupt status and eee ethtool
 stats I've had to do some modifications to the driver's design and I
 found really useful to move other parts of the code (e.g. mmc irq stat)
 in the main directly. So this means that some core has been reworked
 to introduce the EEE.

v1: initial patch
v2: fixed some sparse issues (typos)
v3: erroneously sent the v2 renamed as v3
v4:
	o Fixed the return value of the stmmac_eee_init as suggested by D.Miller
	o Totally reviewed the ethtool support for EEE
	o Added a new internal parameter to tune the SW timer for TX LPI.
v5: do not change any eee setting in case of the stmmac_ethtool_op_set_eee fails
    (it has to return -EOPNOTSUPP in that case).

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |   31 +++-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |   20 +++
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |  101 +++++++++++-
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |    4 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |    1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    8 +
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   57 +++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  166 +++++++++++++++++++-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    2 +
 9 files changed, 372 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index bcd54d6..e2d0832 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -89,18 +89,28 @@ struct stmmac_extra_stats {
 	unsigned long tx_early_irq;
 	unsigned long fatal_bus_error_irq;
 	/* Extra info */
 	unsigned long threshold;
 	unsigned long tx_pkt_n;
 	unsigned long rx_pkt_n;
 	unsigned long poll_n;
 	unsigned long sched_timer_n;
 	unsigned long normal_irq_n;
+	unsigned long mmc_tx_irq_n;
+	unsigned long mmc_rx_irq_n;
+	unsigned long mmc_rx_csum_offload_irq_n;
+	/* EEE */
+	unsigned long irq_receive_pmt_irq_n;
+	unsigned long irq_tx_path_in_lpi_mode_n;
+	unsigned long irq_tx_path_exit_lpi_mode_n;
+	unsigned long irq_rx_path_in_lpi_mode_n;
+	unsigned long irq_rx_path_exit_lpi_mode_n;
+	unsigned long phy_eee_wakeup_error_n;
 };
 
 /* CSR Frequency Access Defines*/
 #define CSR_F_35M	35000000
 #define CSR_F_60M	60000000
 #define CSR_F_100M	100000000
 #define CSR_F_150M	150000000
 #define CSR_F_250M	250000000
 #define CSR_F_300M	300000000
@@ -156,18 +166,29 @@ enum rx_frame_status { /* IPC status */
 	llc_snap = 4,
 };
 
 enum tx_dma_irq_status {
 	tx_hard_error = 1,
 	tx_hard_error_bump_tc = 2,
 	handle_tx_rx = 3,
 };
 
+enum core_specific_irq_mask {
+	core_mmc_tx_irq = 1,
+	core_mmc_rx_irq = 2,
+	core_mmc_rx_csum_offload_irq = 4,
+	core_irq_receive_pmt_irq = 8,
+	core_irq_tx_path_in_lpi_mode = 16,
+	core_irq_tx_path_exit_lpi_mode = 32,
+	core_irq_rx_path_in_lpi_mode = 64,
+	core_irq_rx_path_exit_lpi_mode = 128,
+};
+
 /* DMA HW capabilities */
 struct dma_features {
 	unsigned int mbps_10_100;
 	unsigned int mbps_1000;
 	unsigned int half_duplex;
 	unsigned int hash_filter;
 	unsigned int multi_addr;
 	unsigned int pcs;
 	unsigned int sma_mdio;
@@ -202,18 +223,22 @@ struct dma_features {
 /* Power Down and WOL */
 #define PMT_NOT_SUPPORTED 0
 #define PMT_SUPPORTED 1
 
 /* Common MAC defines */
 #define MAC_CTRL_REG		0x00000000	/* MAC Control */
 #define MAC_ENABLE_TX		0x00000008	/* Transmitter Enable */
 #define MAC_RNABLE_RX		0x00000004	/* Receiver Enable */
 
+/* Default LPI timers */
+#define STMMAC_DEFAULT_LIT_LS_TIMER	0x3E8
+#define STMMAC_DEFAULT_TWT_LS_TIMER	0x0
+
 struct stmmac_desc_ops {
 	/* DMA RX descriptor ring initialization */
 	void (*init_rx_desc) (struct dma_desc *p, unsigned int ring_size,
 			      int disable_rx_ic);
 	/* DMA TX descriptor ring initialization */
 	void (*init_tx_desc) (struct dma_desc *p, unsigned int ring_size);
 
 	/* Invoked by the xmit function to prepare the tx descriptor */
 	void (*prepare_tx_desc) (struct dma_desc *p, int is_fs, int len,
@@ -272,31 +297,35 @@ struct stmmac_dma_ops {
 
 struct stmmac_ops {
 	/* MAC core initialization */
 	void (*core_init) (void __iomem *ioaddr) ____cacheline_aligned;
 	/* Enable and verify that the IPC module is supported */
 	int (*rx_ipc) (void __iomem *ioaddr);
 	/* Dump MAC registers */
 	void (*dump_regs) (void __iomem *ioaddr);
 	/* Handle extra events on specific interrupts hw dependent */
-	void (*host_irq_status) (void __iomem *ioaddr);
+	int (*host_irq_status) (void __iomem *ioaddr);
 	/* Multicast filter setting */
 	void (*set_filter) (struct net_device *dev, int id);
 	/* Flow control setting */
 	void (*flow_ctrl) (void __iomem *ioaddr, unsigned int duplex,
 			   unsigned int fc, unsigned int pause_time);
 	/* Set power management mode (e.g. magic frame) */
 	void (*pmt) (void __iomem *ioaddr, unsigned long mode);
 	/* Set/Get Unicast MAC addresses */
 	void (*set_umac_addr) (void __iomem *ioaddr, unsigned char *addr,
 			       unsigned int reg_n);
 	void (*get_umac_addr) (void __iomem *ioaddr, unsigned char *addr,
 			       unsigned int reg_n);
+	void (*set_eee_mode) (void __iomem *ioaddr);
+	void (*reset_eee_mode) (void __iomem *ioaddr);
+	void (*set_eee_timer) (void __iomem *ioaddr, int ls, int tw);
+	void (*set_eee_pls) (void __iomem *ioaddr, int link);
 };
 
 struct mac_link {
 	int port;
 	int duplex;
 	int speed;
 };
 
 struct mii_regs {
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
index 23478bf..f90fcb5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
@@ -30,18 +30,19 @@
 #define GMAC_MII_ADDR		0x00000010	/* MII Address */
 #define GMAC_MII_DATA		0x00000014	/* MII Data */
 #define GMAC_FLOW_CTRL		0x00000018	/* Flow Control */
 #define GMAC_VLAN_TAG		0x0000001c	/* VLAN Tag */
 #define GMAC_VERSION		0x00000020	/* GMAC CORE Version */
 #define GMAC_WAKEUP_FILTER	0x00000028	/* Wake-up Frame Filter */
 
 #define GMAC_INT_STATUS		0x00000038	/* interrupt status register */
 enum dwmac1000_irq_status {
+	lpiis_irq = 0x400,
 	time_stamp_irq = 0x0200,
 	mmc_rx_csum_offload_irq = 0x0080,
 	mmc_tx_irq = 0x0040,
 	mmc_rx_irq = 0x0020,
 	mmc_irq = 0x0010,
 	pmt_irq = 0x0008,
 	pcs_ane_irq = 0x0004,
 	pcs_link_irq = 0x0002,
 	rgmii_irq = 0x0001,
@@ -54,18 +55,37 @@ enum power_event {
 	pointer_reset = 0x80000000,
 	global_unicast = 0x00000200,
 	wake_up_rx_frame = 0x00000040,
 	magic_frame = 0x00000020,
 	wake_up_frame_en = 0x00000004,
 	magic_pkt_en = 0x00000002,
 	power_down = 0x00000001,
 };
 
+/* Energy Efficient Ethernet (EEE)
+ *
+ * LPI status, timer and control register offset
+ */
+#define LPI_CTRL_STATUS	0x0030
+#define LPI_TIMER_CTRL	0x0034
+
+/* LPI control and status defines */
+#define LPI_CTRL_STATUS_LPITXA	0x00080000	/* Enable LPI TX Automate */
+#define LPI_CTRL_STATUS_PLSEN	0x00040000	/* Enable PHY Link Status */
+#define LPI_CTRL_STATUS_PLS	0x00020000	/* PHY Link Status */
+#define LPI_CTRL_STATUS_LPIEN	0x00010000	/* LPI Enable */
+#define LPI_CTRL_STATUS_RLPIST	0x00000200	/* Receive LPI state */
+#define LPI_CTRL_STATUS_TLPIST	0x00000100	/* Transmit LPI state */
+#define LPI_CTRL_STATUS_RLPIEX	0x00000008	/* Receive LPI Exit */
+#define LPI_CTRL_STATUS_RLPIEN	0x00000004	/* Receive LPI Entry */
+#define LPI_CTRL_STATUS_TLPIEX	0x00000002	/* Transmit LPI Exit */
+#define LPI_CTRL_STATUS_TLPIEN	0x00000001	/* Transmit LPI Entry */
+
 /* GMAC HW ADDR regs */
 #define GMAC_ADDR_HIGH(reg)	(((reg > 15) ? 0x00000800 : 0x00000040) + \
 				(reg * 8))
 #define GMAC_ADDR_LOW(reg)	(((reg > 15) ? 0x00000804 : 0x00000044) + \
 				(reg * 8))
 #define GMAC_MAX_PERFECT_ADDRESSES	32
 
 #define GMAC_AN_CTRL	0x000000c0	/* AN control */
 #define GMAC_AN_STATUS	0x000000c4	/* AN status */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index b5e4d02..bfe0226 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -188,50 +188,135 @@ static void dwmac1000_pmt(void __iomem *ioaddr, unsigned long mode)
 	if (mode & WAKE_UCAST) {
 		CHIP_DBG(KERN_DEBUG "GMAC: WOL on global unicast\n");
 		pmt |= global_unicast;
 	}
 
 	writel(pmt, ioaddr + GMAC_PMT);
 }
 
 
-static void dwmac1000_irq_status(void __iomem *ioaddr)
+static int dwmac1000_irq_status(void __iomem *ioaddr)
 {
 	u32 intr_status = readl(ioaddr + GMAC_INT_STATUS);
+	int status = 0;
 
 	/* Not used events (e.g. MMC interrupts) are not handled. */
-	if ((intr_status & mmc_tx_irq))
-		CHIP_DBG(KERN_DEBUG "GMAC: MMC tx interrupt: 0x%08x\n",
+	if ((intr_status & mmc_tx_irq)) {
+		CHIP_DBG(KERN_INFO "GMAC: MMC tx interrupt: 0x%08x\n",
 		    readl(ioaddr + GMAC_MMC_TX_INTR));
-	if (unlikely(intr_status & mmc_rx_irq))
-		CHIP_DBG(KERN_DEBUG "GMAC: MMC rx interrupt: 0x%08x\n",
+		status |= core_mmc_tx_irq;
+	}
+	if (unlikely(intr_status & mmc_rx_irq)) {
+		CHIP_DBG(KERN_INFO "GMAC: MMC rx interrupt: 0x%08x\n",
 		    readl(ioaddr + GMAC_MMC_RX_INTR));
-	if (unlikely(intr_status & mmc_rx_csum_offload_irq))
-		CHIP_DBG(KERN_DEBUG "GMAC: MMC rx csum offload: 0x%08x\n",
+		status |= core_mmc_rx_irq;
+	}
+	if (unlikely(intr_status & mmc_rx_csum_offload_irq)) {
+		CHIP_DBG(KERN_INFO "GMAC: MMC rx csum offload: 0x%08x\n",
 		    readl(ioaddr + GMAC_MMC_RX_CSUM_OFFLOAD));
+		status |= core_mmc_rx_csum_offload_irq;
+	}
 	if (unlikely(intr_status & pmt_irq)) {
-		CHIP_DBG(KERN_DEBUG "GMAC: received Magic frame\n");
+		CHIP_DBG(KERN_INFO "GMAC: received Magic frame\n");
 		/* clear the PMT bits 5 and 6 by reading the PMT
 		 * status register. */
 		readl(ioaddr + GMAC_PMT);
+		status |= core_irq_receive_pmt_irq;
 	}
+	/* MAC trx/rx EEE LPI entry/exit interrupts */
+	if (intr_status & lpiis_irq) {
+		/* Clean LPI interrupt by reading the Reg 12 */
+		u32 lpi_status = readl(ioaddr + LPI_CTRL_STATUS);
+
+		if (lpi_status & LPI_CTRL_STATUS_TLPIEN) {
+			CHIP_DBG(KERN_INFO "GMAC TX entered in LPI\n");
+			status |= core_irq_tx_path_in_lpi_mode;
+		}
+		if (lpi_status & LPI_CTRL_STATUS_TLPIEX) {
+			CHIP_DBG(KERN_INFO "GMAC TX exit from LPI\n");
+			status |= core_irq_tx_path_exit_lpi_mode;
+		}
+		if (lpi_status & LPI_CTRL_STATUS_RLPIEN) {
+			CHIP_DBG(KERN_INFO "GMAC RX entered in LPI\n");
+			status |= core_irq_rx_path_in_lpi_mode;
+		}
+		if (lpi_status & LPI_CTRL_STATUS_RLPIEX) {
+			CHIP_DBG(KERN_INFO "GMAC RX exit from LPI\n");
+			status |= core_irq_rx_path_exit_lpi_mode;
+		}
+	}
+
+	return status;
+}
+
+static void  dwmac1000_set_eee_mode(void __iomem *ioaddr)
+{
+	u32 value;
+
+	/* Enable the link status receive on RGMII, SGMII ore SMII
+	 * receive path and instruct the transmit to enter in LPI
+	 * state. */
+	value = readl(ioaddr + LPI_CTRL_STATUS);
+	value |= LPI_CTRL_STATUS_LPIEN | LPI_CTRL_STATUS_LPITXA;
+	writel(value, ioaddr + LPI_CTRL_STATUS);
+}
+
+static void  dwmac1000_reset_eee_mode(void __iomem *ioaddr)
+{
+	u32 value;
+
+	value = readl(ioaddr + LPI_CTRL_STATUS);
+	value &= ~(LPI_CTRL_STATUS_LPIEN | LPI_CTRL_STATUS_LPITXA);
+	writel(value, ioaddr + LPI_CTRL_STATUS);
+}
+
+static void  dwmac1000_set_eee_pls(void __iomem *ioaddr, int link)
+{
+	u32 value;
+
+	value = readl(ioaddr + LPI_CTRL_STATUS);
+
+	if (link)
+		value |= LPI_CTRL_STATUS_PLS;
+	else
+		value &= ~LPI_CTRL_STATUS_PLS;
+
+	writel(value, ioaddr + LPI_CTRL_STATUS);
+}
+
+static void  dwmac1000_set_eee_timer(void __iomem *ioaddr, int ls, int tw)
+{
+	int value = ((tw & 0xffff)) | ((ls & 0x7ff) << 16);
+
+	/* Program the timers in the LPI timer control register:
+	 * LS: minimum time (ms) for which the link
+	 *  status from PHY should be ok before transmitting
+	 *  the LPI pattern.
+	 * TW: minimum time (us) for which the core waits
+	 *  after it has stopped transmitting the LPI pattern.
+	 */
+	writel(value, ioaddr + LPI_TIMER_CTRL);
 }
 
 static const struct stmmac_ops dwmac1000_ops = {
 	.core_init = dwmac1000_core_init,
 	.rx_ipc = dwmac1000_rx_ipc_enable,
 	.dump_regs = dwmac1000_dump_regs,
 	.host_irq_status = dwmac1000_irq_status,
 	.set_filter = dwmac1000_set_filter,
 	.flow_ctrl = dwmac1000_flow_ctrl,
 	.pmt = dwmac1000_pmt,
 	.set_umac_addr = dwmac1000_set_umac_addr,
 	.get_umac_addr = dwmac1000_get_umac_addr,
+	.set_eee_mode =  dwmac1000_set_eee_mode,
+	.reset_eee_mode =  dwmac1000_reset_eee_mode,
+	.set_eee_timer =  dwmac1000_set_eee_timer,
+	.set_eee_pls =  dwmac1000_set_eee_pls,
 };
 
 struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr)
 {
 	struct mac_device_info *mac;
 	u32 hwid = readl(ioaddr + GMAC_VERSION);
 
 	mac = kzalloc(sizeof(const struct mac_device_info), GFP_KERNEL);
 	if (!mac)
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
index 19e0f4e..f83210e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
@@ -66,21 +66,21 @@ static void dwmac100_dump_mac_regs(void __iomem *ioaddr)
 	pr_info("\tVLAN2 tag (offset 0x%x): 0x%08x\n", MAC_VLAN2,
 		readl(ioaddr + MAC_VLAN2));
 }
 
 static int dwmac100_rx_ipc_enable(void __iomem *ioaddr)
 {
 	return 0;
 }
 
-static void dwmac100_irq_status(void __iomem *ioaddr)
+static int dwmac100_irq_status(void __iomem *ioaddr)
 {
-	return;
+	return 0;
 }
 
 static void dwmac100_set_umac_addr(void __iomem *ioaddr, unsigned char *addr,
 				   unsigned int reg_n)
 {
 	stmmac_set_mac_addr(ioaddr, addr, MAC_ADDR_HIGH, MAC_ADDR_LOW);
 }
 
 static void dwmac100_get_umac_addr(void __iomem *ioaddr, unsigned char *addr,
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
index 6e0360f..e678ce3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
@@ -64,18 +64,19 @@
 #define DMA_INTR_ENA_TSE 0x00000002	/* Transmit Stopped */
 
 #define DMA_INTR_ABNORMAL	(DMA_INTR_ENA_AIE | DMA_INTR_ENA_FBE | \
 				DMA_INTR_ENA_UNE)
 
 /* DMA default interrupt mask */
 #define DMA_INTR_DEFAULT_MASK	(DMA_INTR_NORMAL | DMA_INTR_ABNORMAL)
 
 /* DMA Status register defines */
+#define DMA_STATUS_GLPII	0x40000000	/* GMAC LPI interrupt */
 #define DMA_STATUS_GPI		0x10000000	/* PMT interrupt */
 #define DMA_STATUS_GMI		0x08000000	/* MMC interrupt */
 #define DMA_STATUS_GLI		0x04000000	/* GMAC Line interface int */
 #define DMA_STATUS_GMI		0x08000000
 #define DMA_STATUS_GLI		0x04000000
 #define DMA_STATUS_EB_MASK	0x00380000	/* Error Bits Mask */
 #define DMA_STATUS_EB_TX_ABORT	0x00080000	/* Error Bits - TX Abort */
 #define DMA_STATUS_EB_RX_ABORT	0x00100000	/* Error Bits - RX Abort */
 #define DMA_STATUS_TS_MASK	0x00700000	/* Transmit Process State */
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index dc20c56..ab4c376 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -81,35 +81,43 @@ struct stmmac_priv {
 	struct plat_stmmacenet_data *plat;
 	struct stmmac_counters mmc;
 	struct dma_features dma_cap;
 	int hw_cap_support;
 #ifdef CONFIG_HAVE_CLK
 	struct clk *stmmac_clk;
 #endif
 	int clk_csr;
 	int synopsys_id;
+	struct timer_list eee_ctrl_timer;
+	bool tx_path_in_lpi_mode;
+	int lpi_irq;
+	int eee_enabled;
+	int eee_active;
+	int tx_lpi_timer;
 };
 
 extern int phyaddr;
 
 extern int stmmac_mdio_unregister(struct net_device *ndev);
 extern int stmmac_mdio_register(struct net_device *ndev);
 extern void stmmac_set_ethtool_ops(struct net_device *netdev);
 extern const struct stmmac_desc_ops enh_desc_ops;
 extern const struct stmmac_desc_ops ndesc_ops;
 int stmmac_freeze(struct net_device *ndev);
 int stmmac_restore(struct net_device *ndev);
 int stmmac_resume(struct net_device *ndev);
 int stmmac_suspend(struct net_device *ndev);
 int stmmac_dvr_remove(struct net_device *ndev);
 struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 				     struct plat_stmmacenet_data *plat_dat,
 				     void __iomem *addr);
+void stmmac_disable_eee_mode(struct stmmac_priv *priv);
+bool stmmac_eee_init(struct stmmac_priv *priv);
 
 #ifdef CONFIG_HAVE_CLK
 static inline int stmmac_clk_enable(struct stmmac_priv *priv)
 {
 	if (!IS_ERR(priv->stmmac_clk))
 		return clk_prepare_enable(priv->stmmac_clk);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index ce43184..76fd61a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -87,18 +87,28 @@ static const struct stmmac_stats stmmac_gstrings_stats[] = {
 	STMMAC_STAT(tx_early_irq),
 	STMMAC_STAT(fatal_bus_error_irq),
 	/* Extra info */
 	STMMAC_STAT(threshold),
 	STMMAC_STAT(tx_pkt_n),
 	STMMAC_STAT(rx_pkt_n),
 	STMMAC_STAT(poll_n),
 	STMMAC_STAT(sched_timer_n),
 	STMMAC_STAT(normal_irq_n),
+	STMMAC_STAT(normal_irq_n),
+	STMMAC_STAT(mmc_tx_irq_n),
+	STMMAC_STAT(mmc_rx_irq_n),
+	STMMAC_STAT(mmc_rx_csum_offload_irq_n),
+	STMMAC_STAT(irq_receive_pmt_irq_n),
+	STMMAC_STAT(irq_tx_path_in_lpi_mode_n),
+	STMMAC_STAT(irq_tx_path_exit_lpi_mode_n),
+	STMMAC_STAT(irq_rx_path_in_lpi_mode_n),
+	STMMAC_STAT(irq_rx_path_exit_lpi_mode_n),
+	STMMAC_STAT(phy_eee_wakeup_error_n),
 };
 #define STMMAC_STATS_LEN ARRAY_SIZE(stmmac_gstrings_stats)
 
 /* HW MAC Management counters (if supported) */
 #define STMMAC_MMC_STAT(m)	\
 	{ #m, FIELD_SIZEOF(struct stmmac_counters, m),	\
 	offsetof(struct stmmac_priv, mmc.m)}
 
 static const struct stmmac_stats stmmac_mmc[] = {
@@ -360,18 +370,23 @@ static void stmmac_get_ethtool_stats(struct net_device *dev,
 			for (i = 0; i < STMMAC_MMC_STATS_LEN; i++) {
 				char *p;
 				p = (char *)priv + stmmac_mmc[i].stat_offset;
 
 				data[j++] = (stmmac_mmc[i].sizeof_stat ==
 					     sizeof(u64)) ? (*(u64 *)p) :
 					     (*(u32 *)p);
 			}
 		}
+		if (priv->eee_enabled) {
+			int val = phy_get_eee_err(priv->phydev);
+			if (val)
+				priv->xstats.phy_eee_wakeup_error_n = val;
+		}
 	}
 	for (i = 0; i < STMMAC_STATS_LEN; i++) {
 		char *p = (char *)priv + stmmac_gstrings_stats[i].stat_offset;
 		data[j++] = (stmmac_gstrings_stats[i].sizeof_stat ==
 			     sizeof(u64)) ? (*(u64 *)p) : (*(u32 *)p);
 	}
 }
 
 static int stmmac_get_sset_count(struct net_device *netdev, int sset)
@@ -458,33 +473,75 @@ static int stmmac_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	}
 
 	spin_lock_irq(&priv->lock);
 	priv->wolopts = wol->wolopts;
 	spin_unlock_irq(&priv->lock);
 
 	return 0;
 }
 
+static int stmmac_ethtool_op_get_eee(struct net_device *dev,
+				     struct ethtool_eee *edata)
+{
+	struct stmmac_priv *priv = netdev_priv(dev);
+
+	if (!priv->dma_cap.eee)
+		return -EOPNOTSUPP;
+
+	edata->eee_enabled = priv->eee_enabled;
+	edata->eee_active = priv->eee_active;
+	edata->tx_lpi_timer = priv->tx_lpi_timer;
+
+	return phy_ethtool_get_eee(priv->phydev, edata);
+}
+
+static int stmmac_ethtool_op_set_eee(struct net_device *dev,
+				     struct ethtool_eee *edata)
+{
+	struct stmmac_priv *priv = netdev_priv(dev);
+
+	priv->eee_enabled = edata->eee_enabled;
+
+	if (!priv->eee_enabled)
+		stmmac_disable_eee_mode(priv);
+	else {
+		/* We are asking for enabling the EEE but it is safe
+		 * to verify all by invoking the eee_init function.
+		 * In case of failure it will return an error.
+		 */
+		priv->eee_enabled = stmmac_eee_init(priv);
+		if (!priv->eee_enabled)
+			return -EOPNOTSUPP;
+
+		/* Do not change tx_lpi_timer in case of failure */
+		priv->tx_lpi_timer = edata->tx_lpi_timer;
+	}
+
+	return phy_ethtool_set_eee(priv->phydev, edata);
+}
+
 static const struct ethtool_ops stmmac_ethtool_ops = {
 	.begin = stmmac_check_if_running,
 	.get_drvinfo = stmmac_ethtool_getdrvinfo,
 	.get_settings = stmmac_ethtool_getsettings,
 	.set_settings = stmmac_ethtool_setsettings,
 	.get_msglevel = stmmac_ethtool_getmsglevel,
 	.set_msglevel = stmmac_ethtool_setmsglevel,
 	.get_regs = stmmac_ethtool_gregs,
 	.get_regs_len = stmmac_ethtool_get_regs_len,
 	.get_link = ethtool_op_get_link,
 	.get_pauseparam = stmmac_get_pauseparam,
 	.set_pauseparam = stmmac_set_pauseparam,
 	.get_ethtool_stats = stmmac_get_ethtool_stats,
 	.get_strings = stmmac_get_strings,
 	.get_wol = stmmac_get_wol,
 	.set_wol = stmmac_set_wol,
+	.get_eee = stmmac_ethtool_op_get_eee,
+	.set_eee = stmmac_ethtool_op_set_eee,
 	.get_sset_count	= stmmac_get_sset_count,
 	.get_ts_info = ethtool_op_get_ts_info,
 };
 
 void stmmac_set_ethtool_ops(struct net_device *netdev)
 {
 	SET_ETHTOOL_OPS(netdev, &stmmac_ethtool_ops);
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index eba49cb..ea3bc09 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -127,18 +127,24 @@ MODULE_PARM_DESC(tmrate, "External timer freq. (default: 256Hz)");
 #define DMA_BUFFER_SIZE	BUF_SIZE_2KiB
 static int buf_sz = DMA_BUFFER_SIZE;
 module_param(buf_sz, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(buf_sz, "DMA buffer size");
 
 static const u32 default_msg_level = (NETIF_MSG_DRV | NETIF_MSG_PROBE |
 				      NETIF_MSG_LINK | NETIF_MSG_IFUP |
 				      NETIF_MSG_IFDOWN | NETIF_MSG_TIMER);
 
+#define STMMAC_DEFAULT_LPI_TIMER	1000
+static int eee_timer = STMMAC_DEFAULT_LPI_TIMER;
+module_param(eee_timer, int, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(eee_timer, "LPI tx expiration time in msec");
+#define STMMAC_LPI_TIMER(x) (jiffies + msecs_to_jiffies(x))
+
 static irqreturn_t stmmac_interrupt(int irq, void *dev_id);
 
 #ifdef CONFIG_STMMAC_DEBUG_FS
 static int stmmac_init_fs(struct net_device *dev);
 static void stmmac_exit_fs(void);
 #endif
 
 /**
  * stmmac_verify_args - verify the driver parameters.
@@ -155,18 +161,20 @@ static void stmmac_verify_args(void)
 		dma_txsize = DMA_TX_SIZE;
 	if (unlikely((buf_sz < DMA_BUFFER_SIZE) || (buf_sz > BUF_SIZE_16KiB)))
 		buf_sz = DMA_BUFFER_SIZE;
 	if (unlikely(flow_ctrl > 1))
 		flow_ctrl = FLOW_AUTO;
 	else if (likely(flow_ctrl < 0))
 		flow_ctrl = FLOW_OFF;
 	if (unlikely((pause < 0) || (pause > 0xffff)))
 		pause = PAUSE_TIME;
+	if (eee_timer < 0)
+		eee_timer = STMMAC_DEFAULT_LPI_TIMER;
 }
 
 static void stmmac_clk_csr_set(struct stmmac_priv *priv)
 {
 #ifdef CONFIG_HAVE_CLK
 	u32 clk_rate;
 
 	if (IS_ERR(priv->stmmac_clk))
 		return;
@@ -223,18 +231,97 @@ static inline u32 stmmac_tx_avail(struct stmmac_priv *priv)
 static inline void stmmac_hw_fix_mac_speed(struct stmmac_priv *priv)
 {
 	struct phy_device *phydev = priv->phydev;
 
 	if (likely(priv->plat->fix_mac_speed))
 		priv->plat->fix_mac_speed(priv->plat->bsp_priv,
 					  phydev->speed);
 }
 
+static void stmmac_enable_eee_mode(struct stmmac_priv *priv)
+{
+	/* Check and enter in LPI mode */
+	if ((priv->dirty_tx == priv->cur_tx) &&
+	    (priv->tx_path_in_lpi_mode == false))
+		priv->hw->mac->set_eee_mode(priv->ioaddr);
+}
+
+void stmmac_disable_eee_mode(struct stmmac_priv *priv)
+{
+	/* Exit and disable EEE in case of we are are in LPI state. */
+	priv->hw->mac->reset_eee_mode(priv->ioaddr);
+	del_timer_sync(&priv->eee_ctrl_timer);
+	priv->tx_path_in_lpi_mode = false;
+}
+
+/**
+ * stmmac_eee_ctrl_timer
+ * @arg : data hook
+ * Description:
+ *  If there is no data transfer and if we are not in LPI state,
+ *  then MAC Transmitter can be moved to LPI state.
+ */
+static void stmmac_eee_ctrl_timer(unsigned long arg)
+{
+	struct stmmac_priv *priv = (struct stmmac_priv *)arg;
+
+	stmmac_enable_eee_mode(priv);
+	mod_timer(&priv->eee_ctrl_timer, STMMAC_LPI_TIMER(eee_timer));
+}
+
+/**
+ * stmmac_eee_init
+ * @priv: private device pointer
+ * Description:
+ *  If the EEE support has been enabled while configuring the driver,
+ *  if the GMAC actually supports the EEE (from the HW cap reg) and the
+ *  phy can also manage EEE, so enable the LPI state and start the timer
+ *  to verify if the tx path can enter in LPI state.
+ */
+bool stmmac_eee_init(struct stmmac_priv *priv)
+{
+	bool ret = false;
+
+	/* MAC core supports the EEE feature. */
+	if (priv->dma_cap.eee) {
+		/* Check if the PHY supports EEE */
+		if (phy_init_eee(priv->phydev, 1))
+			goto out;
+
+		priv->eee_active = 1;
+		init_timer(&priv->eee_ctrl_timer);
+		priv->eee_ctrl_timer.function = stmmac_eee_ctrl_timer;
+		priv->eee_ctrl_timer.data = (unsigned long)priv;
+		priv->eee_ctrl_timer.expires = STMMAC_LPI_TIMER(eee_timer);
+		add_timer(&priv->eee_ctrl_timer);
+
+		priv->hw->mac->set_eee_timer(priv->ioaddr,
+					     STMMAC_DEFAULT_LIT_LS_TIMER,
+					     priv->tx_lpi_timer);
+
+		pr_info("stmmac: Energy-Efficient Ethernet initialized\n");
+
+		ret = true;
+	}
+out:
+	return ret;
+}
+
+static void stmmac_eee_adjust(struct stmmac_priv *priv)
+{
+	/* When the EEE has been already initialised we have to
+	 * modify the PLS bit in the LPI ctrl & status reg according
+	 * to the PHY link status. For this reason.
+	 */
+	if (priv->eee_enabled)
+		priv->hw->mac->set_eee_pls(priv->ioaddr, priv->phydev->link);
+}
+
 /**
  * stmmac_adjust_link
  * @dev: net device structure
  * Description: it adjusts the link parameters.
  */
 static void stmmac_adjust_link(struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 	struct phy_device *phydev = priv->phydev;
@@ -243,18 +330,19 @@ static void stmmac_adjust_link(struct net_device *dev)
 	unsigned int fc = priv->flow_ctrl, pause_time = priv->pause;
 
 	if (phydev == NULL)
 		return;
 
 	DBG(probe, DEBUG, "stmmac_adjust_link: called.  address %d link %d\n",
 	    phydev->addr, phydev->link);
 
 	spin_lock_irqsave(&priv->lock, flags);
+
 	if (phydev->link) {
 		u32 ctrl = readl(priv->ioaddr + MAC_CTRL_REG);
 
 		/* Now we make sure that we can be in full duplex mode.
 		 * If not, we operate in half-duplex mode. */
 		if (phydev->duplex != priv->oldduplex) {
 			new_state = 1;
 			if (!(phydev->duplex))
 				ctrl &= ~priv->hw->link.duplex;
@@ -309,54 +397,57 @@ static void stmmac_adjust_link(struct net_device *dev)
 		new_state = 1;
 		priv->oldlink = 0;
 		priv->speed = 0;
 		priv->oldduplex = -1;
 	}
 
 	if (new_state && netif_msg_link(priv))
 		phy_print_status(phydev);
 
+	stmmac_eee_adjust(priv);
+
 	spin_unlock_irqrestore(&priv->lock, flags);
 
 	DBG(probe, DEBUG, "stmmac_adjust_link: exiting\n");
 }
 
 /**
  * stmmac_init_phy - PHY initialization
  * @dev: net device structure
  * Description: it initializes the driver's PHY state, and attaches the PHY
  * to the mac driver.
  *  Return value:
  *  0 on success
  */
 static int stmmac_init_phy(struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 	struct phy_device *phydev;
-	char phy_id[MII_BUS_ID_SIZE + 3];
+	char phy_id_fmt[MII_BUS_ID_SIZE + 3];
 	char bus_id[MII_BUS_ID_SIZE];
 	int interface = priv->plat->interface;
 	priv->oldlink = 0;
 	priv->speed = 0;
 	priv->oldduplex = -1;
 
 	if (priv->plat->phy_bus_name)
 		snprintf(bus_id, MII_BUS_ID_SIZE, "%s-%x",
 				priv->plat->phy_bus_name, priv->plat->bus_id);
 	else
 		snprintf(bus_id, MII_BUS_ID_SIZE, "stmmac-%x",
 				priv->plat->bus_id);
 
-	snprintf(phy_id, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, bus_id,
+	snprintf(phy_id_fmt, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, bus_id,
 		 priv->plat->phy_addr);
-	pr_debug("stmmac_init_phy:  trying to attach to %s\n", phy_id);
+	pr_debug("stmmac_init_phy:  trying to attach to %s\n", phy_id_fmt);
 
-	phydev = phy_connect(dev, phy_id, &stmmac_adjust_link, 0, interface);
+	phydev = phy_connect(dev, phy_id_fmt, &stmmac_adjust_link, 0,
+			     interface);
 
 	if (IS_ERR(phydev)) {
 		pr_err("%s: Could not attach to PHY\n", dev->name);
 		return PTR_ERR(phydev);
 	}
 
 	/* Stop Advertising 1000BASE Capability if interface is not GMII */
 	if ((interface == PHY_INTERFACE_MODE_MII) ||
 	    (interface == PHY_INTERFACE_MODE_RMII))
@@ -683,18 +774,23 @@ static void stmmac_tx(struct stmmac_priv *priv)
 		     stmmac_tx_avail(priv) > STMMAC_TX_THRESH(priv))) {
 		netif_tx_lock(priv->dev);
 		if (netif_queue_stopped(priv->dev) &&
 		     stmmac_tx_avail(priv) > STMMAC_TX_THRESH(priv)) {
 			TX_DBG("%s: restart transmit\n", __func__);
 			netif_wake_queue(priv->dev);
 		}
 		netif_tx_unlock(priv->dev);
 	}
+
+	if ((priv->eee_enabled) && (!priv->tx_path_in_lpi_mode)) {
+		stmmac_enable_eee_mode(priv);
+		mod_timer(&priv->eee_ctrl_timer, STMMAC_LPI_TIMER(eee_timer));
+	}
 	spin_unlock(&priv->tx_lock);
 }
 
 static inline void stmmac_enable_irq(struct stmmac_priv *priv)
 {
 #ifdef CONFIG_STMMAC_TIMER
 	if (likely(priv->tm->enable))
 		priv->tm->timer_start(tmrate);
 	else
@@ -1021,18 +1117,29 @@ static int stmmac_open(struct net_device *dev)
 		ret = request_irq(priv->wol_irq, stmmac_interrupt,
 				  IRQF_SHARED, dev->name, dev);
 		if (unlikely(ret < 0)) {
 			pr_err("%s: ERROR: allocating the ext WoL IRQ %d "
 			       "(error: %d)\n",	__func__, priv->wol_irq, ret);
 			goto open_error_wolirq;
 		}
 	}
 
+	/* Request the IRQ lines */
+	if (priv->lpi_irq != -ENXIO) {
+		ret = request_irq(priv->lpi_irq, stmmac_interrupt, IRQF_SHARED,
+				  dev->name, dev);
+		if (unlikely(ret < 0)) {
+			pr_err("%s: ERROR: allocating the LPI IRQ %d (%d)\n",
+			       __func__, priv->lpi_irq, ret);
+			goto open_error_lpiirq;
+		}
+	}
+
 	/* Enable the MAC Rx/Tx */
 	stmmac_set_mac(priv->ioaddr, true);
 
 	/* Set the HW DMA mode and the COE */
 	stmmac_dma_operation_mode(priv);
 
 	/* Extra statistics */
 	memset(&priv->xstats, 0, sizeof(struct stmmac_extra_stats));
 	priv->xstats.threshold = tc;
@@ -1056,24 +1163,31 @@ static int stmmac_open(struct net_device *dev)
 	/* Dump DMA/MAC registers */
 	if (netif_msg_hw(priv)) {
 		priv->hw->mac->dump_regs(priv->ioaddr);
 		priv->hw->dma->dump_regs(priv->ioaddr);
 	}
 
 	if (priv->phydev)
 		phy_start(priv->phydev);
 
+	priv->tx_lpi_timer = STMMAC_DEFAULT_TWT_LS_TIMER;
+	priv->eee_enabled = stmmac_eee_init(priv);
+
 	napi_enable(&priv->napi);
 	skb_queue_head_init(&priv->rx_recycle);
 	netif_start_queue(dev);
 
 	return 0;
 
+open_error_lpiirq:
+	if (priv->wol_irq != dev->irq)
+		free_irq(priv->wol_irq, dev);
+
 open_error_wolirq:
 	free_irq(dev->irq, dev);
 
 open_error:
 #ifdef CONFIG_STMMAC_TIMER
 	kfree(priv->tm);
 #endif
 	if (priv->phydev)
 		phy_disconnect(priv->phydev);
@@ -1087,18 +1201,21 @@ open_error:
  *  stmmac_release - close entry point of the driver
  *  @dev : device pointer.
  *  Description:
  *  This is the stop entry point of the driver.
  */
 static int stmmac_release(struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 
+	if (priv->eee_enabled)
+		del_timer_sync(&priv->eee_ctrl_timer);
+
 	/* Stop and disconnect the PHY */
 	if (priv->phydev) {
 		phy_stop(priv->phydev);
 		phy_disconnect(priv->phydev);
 		priv->phydev = NULL;
 	}
 
 	netif_stop_queue(dev);
 
@@ -1109,18 +1226,20 @@ static int stmmac_release(struct net_device *dev)
 		kfree(priv->tm);
 #endif
 	napi_disable(&priv->napi);
 	skb_queue_purge(&priv->rx_recycle);
 
 	/* Free the IRQ lines */
 	free_irq(dev->irq, dev);
 	if (priv->wol_irq != dev->irq)
 		free_irq(priv->wol_irq, dev);
+	if (priv->lpi_irq != -ENXIO)
+		free_irq(priv->lpi_irq, dev);
 
 	/* Stop TX/RX DMA and clear the descriptors */
 	priv->hw->dma->stop_tx(priv->ioaddr);
 	priv->hw->dma->stop_rx(priv->ioaddr);
 
 	/* Release and free the Rx/Tx resources */
 	free_dma_desc_resources(priv);
 
 	/* Disable the MAC Rx/Tx */
@@ -1158,18 +1277,21 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 			/* This is a hard error, log it. */
 			pr_err("%s: BUG! Tx Ring full when queue awake\n",
 				__func__);
 		}
 		return NETDEV_TX_BUSY;
 	}
 
 	spin_lock(&priv->tx_lock);
 
+	if (priv->tx_path_in_lpi_mode)
+		stmmac_disable_eee_mode(priv);
+
 	entry = priv->cur_tx % txsize;
 
 #ifdef STMMAC_XMIT_DEBUG
 	if ((skb->len > ETH_FRAME_LEN) || nfrags)
 		pr_info("stmmac xmit:\n"
 		       "\tskb addr %p - len: %d - nopaged_len: %d\n"
 		       "\tn_frags: %d - ip_summed: %d - %s gso\n",
 		       skb, skb->len, nopaged_len, nfrags, skb->ip_summed,
 		       !skb_is_gso(skb) ? "isn't" : "is");
@@ -1534,22 +1656,49 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
 	struct stmmac_priv *priv = netdev_priv(dev);
 
 	if (unlikely(!dev)) {
 		pr_err("%s: invalid dev pointer\n", __func__);
 		return IRQ_NONE;
 	}
 
-	if (priv->plat->has_gmac)
-		/* To handle GMAC own interrupts */
-		priv->hw->mac->host_irq_status((void __iomem *) dev->base_addr);
+	/* To handle GMAC own interrupts */
+	if (priv->plat->has_gmac) {
+		int status = priv->hw->mac->host_irq_status((void __iomem *)
+							    dev->base_addr);
+		if (unlikely(status)) {
+			if (status & core_mmc_tx_irq)
+				priv->xstats.mmc_tx_irq_n++;
+			if (status & core_mmc_rx_irq)
+				priv->xstats.mmc_rx_irq_n++;
+			if (status & core_mmc_rx_csum_offload_irq)
+				priv->xstats.mmc_rx_csum_offload_irq_n++;
+			if (status & core_irq_receive_pmt_irq)
+				priv->xstats.irq_receive_pmt_irq_n++;
+
+			/* For LPI we need to save the tx status */
+			if (status & core_irq_tx_path_in_lpi_mode) {
+				priv->xstats.irq_tx_path_in_lpi_mode_n++;
+				priv->tx_path_in_lpi_mode = true;
+			}
+			if (status & core_irq_tx_path_exit_lpi_mode) {
+				priv->xstats.irq_tx_path_exit_lpi_mode_n++;
+				priv->tx_path_in_lpi_mode = false;
+			}
+			if (status & core_irq_rx_path_in_lpi_mode)
+				priv->xstats.irq_rx_path_in_lpi_mode_n++;
+			if (status & core_irq_rx_path_exit_lpi_mode)
+				priv->xstats.irq_rx_path_exit_lpi_mode_n++;
+		}
+	}
 
+	/* To handle DMA interrupts */
 	stmmac_dma_interrupt(priv);
 
 	return IRQ_HANDLED;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /* Polling receive - used by NETCONSOLE and other diagnostic tools
  * to allow network I/O with interrupts disabled. */
 static void stmmac_poll_controller(struct net_device *dev)
@@ -2149,18 +2298,21 @@ static int __init stmmac_cmdline_opt(char *str)
 		} else if (!strncmp(opt, "watchdog:", 9)) {
 			if (kstrtoint(opt + 9, 0, &watchdog))
 				goto err;
 		} else if (!strncmp(opt, "flow_ctrl:", 10)) {
 			if (kstrtoint(opt + 10, 0, &flow_ctrl))
 				goto err;
 		} else if (!strncmp(opt, "pause:", 6)) {
 			if (kstrtoint(opt + 6, 0, &pause))
 				goto err;
+		} else if (!strncmp(opt, "eee_timer:", 6)) {
+			if (kstrtoint(opt + 10, 0, &eee_timer))
+				goto err;
 #ifdef CONFIG_STMMAC_TIMER
 		} else if (!strncmp(opt, "tmrate:", 7)) {
 			if (kstrtoint(opt + 7, 0, &tmrate))
 				goto err;
 #endif
 		}
 	}
 	return 0;
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 20eb502..7d36163 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -150,18 +150,20 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 	 * named as "eth_wake_irq"
 	 *
 	 * In case the wake up interrupt is not passed from the platform
 	 * so the driver will continue to use the mac irq (ndev->irq)
 	 */
 	priv->wol_irq = platform_get_irq_byname(pdev, "eth_wake_irq");
 	if (priv->wol_irq == -ENXIO)
 		priv->wol_irq = priv->dev->irq;
 
+	priv->lpi_irq = platform_get_irq_byname(pdev, "eth_lpi");
+
 	platform_set_drvdata(pdev, priv->dev);
 
 	pr_debug("STMMAC platform driver registration completed");
 
 	return 0;
 
 out_unmap:
 	iounmap(addr);
 	platform_set_drvdata(pdev, NULL);
-- 
1.7.10


--yrj/dFKFPuw6o+aM--
