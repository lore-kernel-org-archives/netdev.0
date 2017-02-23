From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH] net: stmmac: unify registers dumps methods
Date: Thu, 23 Feb 2017 14:12:25 +0100
Message-ID: <20170223131225.5420-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35966 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750916AbdBWNOh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 08:14:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The stmmac driver have two methods for registers dumps: via ethtool and
at init (if NETIF_MSG_HW is enabled).

It is better to keep only one method, ethtool, since the other was ugly.

This patch convert all dump_regs() function from "printing regs" to
"fill the reg_space used by ethtool".

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |  4 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   | 10 +--
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    | 16 ++---
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    | 30 +++------
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c | 15 ++---
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  | 12 +---
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c   | 78 +++++++++++-----------
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   | 21 +-----
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  5 --
 9 files changed, 71 insertions(+), 120 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index daaafa9..7552775 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -416,7 +416,7 @@ struct stmmac_dma_ops {
 	/* Configure the AXI Bus Mode Register */
 	void (*axi)(void __iomem *ioaddr, struct stmmac_axi *axi);
 	/* Dump DMA registers */
-	void (*dump_regs) (void __iomem *ioaddr);
+	void (*dump_regs)(void __iomem *ioaddr, u32 *reg_space);
 	/* Set tx/rx threshold in the csr6 register
 	 * An invalid value enables the store-and-forward mode */
 	void (*dma_mode)(void __iomem *ioaddr, int txmode, int rxmode,
@@ -456,7 +456,7 @@ struct stmmac_ops {
 	/* Enable RX Queues */
 	void (*rx_queue_enable)(struct mac_device_info *hw, u32 queue);
 	/* Dump MAC registers */
-	void (*dump_regs)(struct mac_device_info *hw);
+	void (*dump_regs)(struct mac_device_info *hw, u32 *reg_space);
 	/* Handle extra events on specific interrupts hw dependent */
 	int (*host_irq_status)(struct mac_device_info *hw,
 			       struct stmmac_extra_stats *x);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index 91c8926..19b9b30 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -92,17 +92,13 @@ static int dwmac1000_rx_ipc_enable(struct mac_device_info *hw)
 	return !!(value & GMAC_CONTROL_IPC);
 }
 
-static void dwmac1000_dump_regs(struct mac_device_info *hw)
+static void dwmac1000_dump_regs(struct mac_device_info *hw, u32 *reg_space)
 {
 	void __iomem *ioaddr = hw->pcsr;
 	int i;
-	pr_info("\tDWMAC1000 regs (base addr = 0x%p)\n", ioaddr);
 
-	for (i = 0; i < 55; i++) {
-		int offset = i * 4;
-		pr_info("\tReg No. %d (offset 0x%x): 0x%08x\n", i,
-			offset, readl(ioaddr + offset));
-	}
+	for (i = 0; i < 55; i++)
+		reg_space[i] = readl(ioaddr + i * 4);
 }
 
 static void dwmac1000_set_umac_addr(struct mac_device_info *hw,
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
index fbaec0f..d3654a4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
@@ -201,18 +201,14 @@ static void dwmac1000_dma_operation_mode(void __iomem *ioaddr, int txmode,
 	writel(csr6, ioaddr + DMA_CONTROL);
 }
 
-static void dwmac1000_dump_dma_regs(void __iomem *ioaddr)
+static void dwmac1000_dump_dma_regs(void __iomem *ioaddr, u32 *reg_space)
 {
 	int i;
-	pr_info(" DMA registers\n");
-	for (i = 0; i < 22; i++) {
-		if ((i < 9) || (i > 17)) {
-			int offset = i * 4;
-			pr_err("\t Reg No. %d (offset 0x%x): 0x%08x\n", i,
-			       (DMA_BUS_MODE + offset),
-			       readl(ioaddr + DMA_BUS_MODE + offset));
-		}
-	}
+
+	for (i = 0; i < 22; i++)
+		if ((i < 9) || (i > 17))
+			reg_space[DMA_BUS_MODE / 4 + i] =
+				readl(ioaddr + DMA_BUS_MODE + i * 4);
 }
 
 static void dwmac1000_get_hw_feature(void __iomem *ioaddr,
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
index 8ab5189..e370cce 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
@@ -40,28 +40,18 @@ static void dwmac100_core_init(struct mac_device_info *hw, int mtu)
 #endif
 }
 
-static void dwmac100_dump_mac_regs(struct mac_device_info *hw)
+static void dwmac100_dump_mac_regs(struct mac_device_info *hw, u32 *reg_space)
 {
 	void __iomem *ioaddr = hw->pcsr;
-	pr_info("\t----------------------------------------------\n"
-		"\t  DWMAC 100 CSR (base addr = 0x%p)\n"
-		"\t----------------------------------------------\n", ioaddr);
-	pr_info("\tcontrol reg (offset 0x%x): 0x%08x\n", MAC_CONTROL,
-		readl(ioaddr + MAC_CONTROL));
-	pr_info("\taddr HI (offset 0x%x): 0x%08x\n ", MAC_ADDR_HIGH,
-		readl(ioaddr + MAC_ADDR_HIGH));
-	pr_info("\taddr LO (offset 0x%x): 0x%08x\n", MAC_ADDR_LOW,
-		readl(ioaddr + MAC_ADDR_LOW));
-	pr_info("\tmulticast hash HI (offset 0x%x): 0x%08x\n",
-		MAC_HASH_HIGH, readl(ioaddr + MAC_HASH_HIGH));
-	pr_info("\tmulticast hash LO (offset 0x%x): 0x%08x\n",
-		MAC_HASH_LOW, readl(ioaddr + MAC_HASH_LOW));
-	pr_info("\tflow control (offset 0x%x): 0x%08x\n",
-		MAC_FLOW_CTRL, readl(ioaddr + MAC_FLOW_CTRL));
-	pr_info("\tVLAN1 tag (offset 0x%x): 0x%08x\n", MAC_VLAN1,
-		readl(ioaddr + MAC_VLAN1));
-	pr_info("\tVLAN2 tag (offset 0x%x): 0x%08x\n", MAC_VLAN2,
-		readl(ioaddr + MAC_VLAN2));
+
+	reg_space[MAC_CONTROL / 4] = readl(ioaddr + MAC_CONTROL);
+	reg_space[MAC_ADDR_HIGH / 4] = readl(ioaddr + MAC_ADDR_HIGH);
+	reg_space[MAC_ADDR_LOW / 4] = readl(ioaddr + MAC_ADDR_LOW);
+	reg_space[MAC_HASH_HIGH / 4] = readl(ioaddr + MAC_HASH_HIGH);
+	reg_space[MAC_HASH_LOW / 4] = readl(ioaddr + MAC_HASH_LOW);
+	reg_space[MAC_FLOW_CTRL / 4] = readl(ioaddr + MAC_FLOW_CTRL);
+	reg_space[MAC_VLAN1 / 4] = readl(ioaddr + MAC_VLAN1);
+	reg_space[MAC_VLAN2 / 4] = readl(ioaddr + MAC_VLAN2);
 }
 
 static int dwmac100_rx_ipc_enable(struct mac_device_info *hw)
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
index d40e91e8..eef2f22 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
@@ -66,19 +66,18 @@ static void dwmac100_dma_operation_mode(void __iomem *ioaddr, int txmode,
 	writel(csr6, ioaddr + DMA_CONTROL);
 }
 
-static void dwmac100_dump_dma_regs(void __iomem *ioaddr)
+static void dwmac100_dump_dma_regs(void __iomem *ioaddr, u32 *reg_space)
 {
 	int i;
 
-	pr_debug("DWMAC 100 DMA CSR\n");
 	for (i = 0; i < 9; i++)
-		pr_debug("\t CSR%d (offset 0x%x): 0x%08x\n", i,
-			 (DMA_BUS_MODE + i * 4),
-			 readl(ioaddr + DMA_BUS_MODE + i * 4));
+		reg_space[DMA_BUS_MODE / 4 + i] =
+			readl(ioaddr + DMA_BUS_MODE + i * 4);
 
-	pr_debug("\tCSR20 (0x%x): 0x%08x, CSR21 (0x%x): 0x%08x\n",
-		 DMA_CUR_TX_BUF_ADDR, readl(ioaddr + DMA_CUR_TX_BUF_ADDR),
-		 DMA_CUR_RX_BUF_ADDR, readl(ioaddr + DMA_CUR_RX_BUF_ADDR));
+	reg_space[DMA_CUR_TX_BUF_ADDR / 4] =
+		readl(ioaddr + DMA_CUR_TX_BUF_ADDR);
+	reg_space[DMA_CUR_RX_BUF_ADDR / 4] =
+		readl(ioaddr + DMA_CUR_RX_BUF_ADDR);
 }
 
 /* DMA controller has two counters to track the number of the missed frames. */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index 202216c..1e79e65 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -70,19 +70,13 @@ static void dwmac4_rx_queue_enable(struct mac_device_info *hw, u32 queue)
 	writel(value, ioaddr + GMAC_RXQ_CTRL0);
 }
 
-static void dwmac4_dump_regs(struct mac_device_info *hw)
+static void dwmac4_dump_regs(struct mac_device_info *hw, u32 *reg_space)
 {
 	void __iomem *ioaddr = hw->pcsr;
 	int i;
 
-	pr_debug("\tDWMAC4 regs (base addr = 0x%p)\n", ioaddr);
-
-	for (i = 0; i < GMAC_REG_NUM; i++) {
-		int offset = i * 4;
-
-		pr_debug("\tReg No. %d (offset 0x%x): 0x%08x\n", i,
-			 offset, readl(ioaddr + offset));
-	}
+	for (i = 0; i < GMAC_REG_NUM; i++)
+		reg_space[i] = readl(ioaddr + i * 4);
 }
 
 static int dwmac4_rx_ipc_enable(struct mac_device_info *hw)
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
index 377d1b4..f97b0d5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
@@ -127,53 +127,51 @@ static void dwmac4_dma_init(void __iomem *ioaddr,
 		dwmac4_dma_init_channel(ioaddr, dma_cfg, dma_tx, dma_rx, i);
 }
 
-static void _dwmac4_dump_dma_regs(void __iomem *ioaddr, u32 channel)
+static void _dwmac4_dump_dma_regs(void __iomem *ioaddr, u32 channel,
+				  u32 *reg_space)
 {
-	pr_debug(" Channel %d\n", channel);
-	pr_debug("\tDMA_CHAN_CONTROL, offset: 0x%x, val: 0x%x\n", 0,
-		 readl(ioaddr + DMA_CHAN_CONTROL(channel)));
-	pr_debug("\tDMA_CHAN_TX_CONTROL, offset: 0x%x, val: 0x%x\n", 0x4,
-		 readl(ioaddr + DMA_CHAN_TX_CONTROL(channel)));
-	pr_debug("\tDMA_CHAN_RX_CONTROL, offset: 0x%x, val: 0x%x\n", 0x8,
-		 readl(ioaddr + DMA_CHAN_RX_CONTROL(channel)));
-	pr_debug("\tDMA_CHAN_TX_BASE_ADDR, offset: 0x%x, val: 0x%x\n", 0x14,
-		 readl(ioaddr + DMA_CHAN_TX_BASE_ADDR(channel)));
-	pr_debug("\tDMA_CHAN_RX_BASE_ADDR, offset: 0x%x, val: 0x%x\n", 0x1c,
-		 readl(ioaddr + DMA_CHAN_RX_BASE_ADDR(channel)));
-	pr_debug("\tDMA_CHAN_TX_END_ADDR, offset: 0x%x, val: 0x%x\n", 0x20,
-		 readl(ioaddr + DMA_CHAN_TX_END_ADDR(channel)));
-	pr_debug("\tDMA_CHAN_RX_END_ADDR, offset: 0x%x, val: 0x%x\n", 0x28,
-		 readl(ioaddr + DMA_CHAN_RX_END_ADDR(channel)));
-	pr_debug("\tDMA_CHAN_TX_RING_LEN, offset: 0x%x, val: 0x%x\n", 0x2c,
-		 readl(ioaddr + DMA_CHAN_TX_RING_LEN(channel)));
-	pr_debug("\tDMA_CHAN_RX_RING_LEN, offset: 0x%x, val: 0x%x\n", 0x30,
-		 readl(ioaddr + DMA_CHAN_RX_RING_LEN(channel)));
-	pr_debug("\tDMA_CHAN_INTR_ENA, offset: 0x%x, val: 0x%x\n", 0x34,
-		 readl(ioaddr + DMA_CHAN_INTR_ENA(channel)));
-	pr_debug("\tDMA_CHAN_RX_WATCHDOG, offset: 0x%x, val: 0x%x\n", 0x38,
-		 readl(ioaddr + DMA_CHAN_RX_WATCHDOG(channel)));
-	pr_debug("\tDMA_CHAN_SLOT_CTRL_STATUS, offset: 0x%x, val: 0x%x\n", 0x3c,
-		 readl(ioaddr + DMA_CHAN_SLOT_CTRL_STATUS(channel)));
-	pr_debug("\tDMA_CHAN_CUR_TX_DESC, offset: 0x%x, val: 0x%x\n", 0x44,
-		 readl(ioaddr + DMA_CHAN_CUR_TX_DESC(channel)));
-	pr_debug("\tDMA_CHAN_CUR_RX_DESC, offset: 0x%x, val: 0x%x\n", 0x4c,
-		 readl(ioaddr + DMA_CHAN_CUR_RX_DESC(channel)));
-	pr_debug("\tDMA_CHAN_CUR_TX_BUF_ADDR, offset: 0x%x, val: 0x%x\n", 0x54,
-		 readl(ioaddr + DMA_CHAN_CUR_TX_BUF_ADDR(channel)));
-	pr_debug("\tDMA_CHAN_CUR_RX_BUF_ADDR, offset: 0x%x, val: 0x%x\n", 0x5c,
-		 readl(ioaddr + DMA_CHAN_CUR_RX_BUF_ADDR(channel)));
-	pr_debug("\tDMA_CHAN_STATUS, offset: 0x%x, val: 0x%x\n", 0x60,
-		 readl(ioaddr + DMA_CHAN_STATUS(channel)));
+	reg_space[DMA_CHAN_CONTROL(channel) / 4] =
+		readl(ioaddr + DMA_CHAN_CONTROL(channel));
+	reg_space[DMA_CHAN_TX_CONTROL(channel) / 4] =
+		readl(ioaddr + DMA_CHAN_TX_CONTROL(channel));
+	reg_space[DMA_CHAN_RX_CONTROL(channel) / 4] =
+		readl(ioaddr + DMA_CHAN_RX_CONTROL(channel));
+	reg_space[DMA_CHAN_TX_BASE_ADDR(channel) / 4] =
+		readl(ioaddr + DMA_CHAN_TX_BASE_ADDR(channel));
+	reg_space[DMA_CHAN_RX_BASE_ADDR(channel) / 4] =
+		readl(ioaddr + DMA_CHAN_RX_BASE_ADDR(channel));
+	reg_space[DMA_CHAN_TX_END_ADDR(channel) / 4] =
+		readl(ioaddr + DMA_CHAN_TX_END_ADDR(channel));
+	reg_space[DMA_CHAN_RX_END_ADDR(channel) / 4] =
+		readl(ioaddr + DMA_CHAN_RX_END_ADDR(channel));
+	reg_space[DMA_CHAN_TX_RING_LEN(channel) / 4] =
+		readl(ioaddr + DMA_CHAN_TX_RING_LEN(channel));
+	reg_space[DMA_CHAN_RX_RING_LEN(channel) / 4] =
+		readl(ioaddr + DMA_CHAN_RX_RING_LEN(channel));
+	reg_space[DMA_CHAN_INTR_ENA(channel) / 4] =
+		readl(ioaddr + DMA_CHAN_INTR_ENA(channel));
+	reg_space[DMA_CHAN_RX_WATCHDOG(channel) / 4] =
+		readl(ioaddr + DMA_CHAN_RX_WATCHDOG(channel));
+	reg_space[DMA_CHAN_SLOT_CTRL_STATUS(channel) / 4] =
+		readl(ioaddr + DMA_CHAN_SLOT_CTRL_STATUS(channel));
+	reg_space[DMA_CHAN_CUR_TX_DESC(channel) / 4] =
+		readl(ioaddr + DMA_CHAN_CUR_TX_DESC(channel));
+	reg_space[DMA_CHAN_CUR_RX_DESC(channel) / 4] =
+		readl(ioaddr + DMA_CHAN_CUR_RX_DESC(channel));
+	reg_space[DMA_CHAN_CUR_TX_BUF_ADDR(channel) / 4] =
+		readl(ioaddr + DMA_CHAN_CUR_TX_BUF_ADDR(channel));
+	reg_space[DMA_CHAN_CUR_RX_BUF_ADDR(channel) / 4] =
+		readl(ioaddr + DMA_CHAN_CUR_RX_BUF_ADDR(channel));
+	reg_space[DMA_CHAN_STATUS(channel) / 4] =
+		readl(ioaddr + DMA_CHAN_STATUS(channel));
 }
 
-static void dwmac4_dump_dma_regs(void __iomem *ioaddr)
+static void dwmac4_dump_dma_regs(void __iomem *ioaddr, u32 *reg_space)
 {
 	int i;
 
-	pr_debug(" GMAC4 DMA registers\n");
-
 	for (i = 0; i < DMA_CHANNEL_NB_MAX; i++)
-		_dwmac4_dump_dma_regs(ioaddr, i);
+		_dwmac4_dump_dma_regs(ioaddr, i, reg_space);
 }
 
 static void dwmac4_rx_watchdog(void __iomem *ioaddr, u32 riwt)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 5ff6bc4..40b7772 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -442,25 +442,8 @@ static void stmmac_ethtool_gregs(struct net_device *dev,
 
 	memset(reg_space, 0x0, REG_SPACE_SIZE);
 
-	if (priv->plat->has_gmac || priv->plat->has_gmac4) {
-		/* MAC registers */
-		for (i = 0; i < 55; i++)
-			reg_space[i] = readl(priv->ioaddr + (i * 4));
-		/* DMA registers */
-		for (i = 0; i < 22; i++)
-			reg_space[i + 55] =
-			    readl(priv->ioaddr + (DMA_BUS_MODE + (i * 4)));
-	} else {
-		/* MAC registers */
-		for (i = 0; i < 12; i++)
-			reg_space[i] = readl(priv->ioaddr + (i * 4));
-		/* DMA registers */
-		for (i = 0; i < 9; i++)
-			reg_space[i + 12] =
-			    readl(priv->ioaddr + (DMA_BUS_MODE + (i * 4)));
-		reg_space[22] = readl(priv->ioaddr + DMA_CUR_TX_BUF_ADDR);
-		reg_space[23] = readl(priv->ioaddr + DMA_CUR_RX_BUF_ADDR);
-	}
+	priv->hw->mac->dump_regs(priv->hw, reg_space);
+	priv->hw->dma->dump_regs(priv->ioaddr, reg_space);
 }
 
 static void
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index f473d54..6c955ca 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1758,11 +1758,6 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 	priv->hw->dma->start_tx(priv->ioaddr);
 	priv->hw->dma->start_rx(priv->ioaddr);
 
-	/* Dump DMA/MAC registers */
-	if (netif_msg_hw(priv)) {
-		priv->hw->mac->dump_regs(priv->hw);
-		priv->hw->dma->dump_regs(priv->ioaddr);
-	}
 	priv->tx_lpi_timer = STMMAC_DEFAULT_TWT_LS;
 
 	if ((priv->use_riwt) && (priv->hw->dma->rx_watchdog)) {
-- 
2.10.2
