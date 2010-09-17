From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 2/4] stmmac: consolidate and tidy-up the COE support
Date: Fri, 17 Sep 2010 15:23:40 +0200
Message-ID: <1284729822-29176-2-git-send-email-peppe.cavallaro@st.com>
References: <1284729822-29176-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Johannes Stezenbach <js@sig21.net>,
	Deepak SIKRI <deepak.sikri@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:58203 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752350Ab0IQNYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 09:24:05 -0400
In-Reply-To: <1284729822-29176-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first version of the driver had hard-coded the logic
for handling the checksum offloading.
This was designed according to the chips included in
the STM platforms where:
o MAC10/100 supports no COE at all.
o GMAC fully supports RX/TX COE.

This is not good for other chip configurations where,
for example, the mac10/100 supports the tx csum in HW
or when the GMAC has no IPC.

Thanks to Johannes Stezenbach; he provided me a first
draft of this patch that only reviewed the IPC for the
GMAC devices.

This patch also helps on SPEAr platforms where the
MAC10/100 can perform the TX csum in HW.
Thanks to Deepak SIKRI for his support on this.

In the end, GMAC devices for STM platforms have
a bugged Jumbo frame support that needs to have
the Tx COE disabled for oversized frames (due to
limited buffer sizes). This information is also
passed through the driver's platform structure.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Signed-off-by: Johannes Stezenbach <js@sig21.net>
Signed-off-by: Deepak SIKRI <deepak.sikri@st.com>
---
 drivers/net/stmmac/common.h         |    4 +-
 drivers/net/stmmac/dwmac1000.h      |    2 +-
 drivers/net/stmmac/dwmac1000_core.c |   13 +++++++
 drivers/net/stmmac/dwmac100_core.c  |    6 +++
 drivers/net/stmmac/stmmac.h         |    4 ++-
 drivers/net/stmmac/stmmac_ethtool.c |    2 +-
 drivers/net/stmmac/stmmac_main.c    |   66 +++++++++++++++++------------------
 include/linux/stmmac.h              |    2 +
 8 files changed, 60 insertions(+), 39 deletions(-)

diff --git a/drivers/net/stmmac/common.h b/drivers/net/stmmac/common.h
index e8cbcb5..673ef86 100644
--- a/drivers/net/stmmac/common.h
+++ b/drivers/net/stmmac/common.h
@@ -102,8 +102,6 @@ struct stmmac_extra_stats {
 
 #define SF_DMA_MODE 1 /* DMA STORE-AND-FORWARD Operation Mode */
 
-#define HW_CSUM 1
-#define NO_HW_CSUM 0
 enum rx_frame_status { /* IPC status */
 	good_frame = 0,
 	discard_frame = 1,
@@ -205,6 +203,8 @@ struct stmmac_dma_ops {
 struct stmmac_ops {
 	/* MAC core initialization */
 	void (*core_init) (void __iomem *ioaddr) ____cacheline_aligned;
+	/* Support checksum offload engine */
+	int  (*rx_coe) (void __iomem *ioaddr);
 	/* Dump MAC registers */
 	void (*dump_regs) (void __iomem *ioaddr);
 	/* Handle extra events on specific interrupts hw dependent */
diff --git a/drivers/net/stmmac/dwmac1000.h b/drivers/net/stmmac/dwmac1000.h
index 8b20b19..81ee4fd 100644
--- a/drivers/net/stmmac/dwmac1000.h
+++ b/drivers/net/stmmac/dwmac1000.h
@@ -99,7 +99,7 @@ enum inter_frame_gap {
 #define GMAC_CONTROL_RE		0x00000004 /* Receiver Enable */
 
 #define GMAC_CORE_INIT (GMAC_CONTROL_JD | GMAC_CONTROL_PS | GMAC_CONTROL_ACS | \
-			GMAC_CONTROL_IPC | GMAC_CONTROL_JE | GMAC_CONTROL_BE)
+			GMAC_CONTROL_JE | GMAC_CONTROL_BE)
 
 /* GMAC Frame Filter defines */
 #define GMAC_FRAME_FILTER_PR	0x00000001	/* Promiscuous Mode */
diff --git a/drivers/net/stmmac/dwmac1000_core.c b/drivers/net/stmmac/dwmac1000_core.c
index f1f4261..c18c859 100644
--- a/drivers/net/stmmac/dwmac1000_core.c
+++ b/drivers/net/stmmac/dwmac1000_core.c
@@ -50,6 +50,18 @@ static void dwmac1000_core_init(void __iomem *ioaddr)
 #endif
 }
 
+static int dwmac1000_rx_coe_supported(void __iomem *ioaddr)
+{
+	u32 value = readl(ioaddr + GMAC_CONTROL);
+
+	value |= GMAC_CONTROL_IPC;
+	writel(value, ioaddr + GMAC_CONTROL);
+
+	value = readl(ioaddr + GMAC_CONTROL);
+
+	return !!(value & GMAC_CONTROL_IPC);
+}
+
 static void dwmac1000_dump_regs(void __iomem *ioaddr)
 {
 	int i;
@@ -202,6 +214,7 @@ static void dwmac1000_irq_status(void __iomem *ioaddr)
 
 struct stmmac_ops dwmac1000_ops = {
 	.core_init = dwmac1000_core_init,
+	.rx_coe = dwmac1000_rx_coe_supported,
 	.dump_regs = dwmac1000_dump_regs,
 	.host_irq_status = dwmac1000_irq_status,
 	.set_filter = dwmac1000_set_filter,
diff --git a/drivers/net/stmmac/dwmac100_core.c b/drivers/net/stmmac/dwmac100_core.c
index db06c04..58a914b 100644
--- a/drivers/net/stmmac/dwmac100_core.c
+++ b/drivers/net/stmmac/dwmac100_core.c
@@ -42,6 +42,11 @@ static void dwmac100_core_init(void __iomem *ioaddr)
 #endif
 }
 
+static int dwmac100_rx_coe_supported(void __iomem *ioaddr)
+{
+	return 0;
+}
+
 static void dwmac100_dump_mac_regs(void __iomem *ioaddr)
 {
 	pr_info("\t----------------------------------------------\n"
@@ -165,6 +170,7 @@ static void dwmac100_pmt(void __iomem *ioaddr, unsigned long mode)
 
 struct stmmac_ops dwmac100_ops = {
 	.core_init = dwmac100_core_init,
+	.rx_coe = dwmac100_rx_coe_supported,
 	.dump_regs = dwmac100_dump_mac_regs,
 	.host_irq_status = dwmac100_irq_status,
 	.set_filter = dwmac100_set_filter,
diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index 12d1cb0..92154ff 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -51,7 +51,6 @@ struct stmmac_priv {
 	int is_gmac;
 	dma_addr_t dma_rx_phy;
 	unsigned int dma_rx_size;
-	int rx_csum;
 	unsigned int dma_buf_sz;
 	struct device *device;
 	struct mac_device_info *hw;
@@ -92,6 +91,9 @@ struct stmmac_priv {
 	struct vlan_group *vlgrp;
 #endif
 	int enh_desc;
+	int rx_coe;
+	int bugged_jumbo;
+	int no_csum_insertion;
 };
 
 #ifdef CONFIG_STM_DRIVERS
diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/stmmac_ethtool.c
index 63b68e6..b32c16a 100644
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -209,7 +209,7 @@ u32 stmmac_ethtool_get_rx_csum(struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 
-	return priv->rx_csum;
+	return priv->rx_coe;
 }
 
 static void
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index a169b14..a908f72 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -134,13 +134,6 @@ static int buf_sz = DMA_BUFFER_SIZE;
 module_param(buf_sz, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(buf_sz, "DMA buffer size");
 
-/* In case of Giga ETH, we can enable/disable the COE for the
- * transmit HW checksum computation.
- * Note that, if tx csum is off in HW, SG will be still supported. */
-static int tx_coe = HW_CSUM;
-module_param(tx_coe, int, S_IRUGO | S_IWUSR);
-MODULE_PARM_DESC(tx_coe, "GMAC COE type 2 [on/off]");
-
 static const u32 default_msg_level = (NETIF_MSG_DRV | NETIF_MSG_PROBE |
 				      NETIF_MSG_LINK | NETIF_MSG_IFUP |
 				      NETIF_MSG_IFDOWN | NETIF_MSG_TIMER);
@@ -569,29 +562,22 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
  *  stmmac_dma_operation_mode - HW DMA operation mode
  *  @priv : pointer to the private device structure.
  *  Description: it sets the DMA operation mode: tx/rx DMA thresholds
- *  or Store-And-Forward capability. It also verifies the COE for the
- *  transmission in case of Giga ETH.
+ *  or Store-And-Forward capability.
  */
 static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 {
-	if (!priv->is_gmac) {
-		/* MAC 10/100 */
-		priv->hw->dma->dma_mode(priv->ioaddr, tc, 0);
-		priv->tx_coe = NO_HW_CSUM;
-	} else {
-		if ((priv->dev->mtu <= ETH_DATA_LEN) && (tx_coe)) {
-			priv->hw->dma->dma_mode(priv->ioaddr,
-						SF_DMA_MODE, SF_DMA_MODE);
-			tc = SF_DMA_MODE;
-			priv->tx_coe = HW_CSUM;
-		} else {
-			/* Checksum computation is performed in software. */
-			priv->hw->dma->dma_mode(priv->ioaddr, tc,
-						SF_DMA_MODE);
-			priv->tx_coe = NO_HW_CSUM;
-		}
-	}
-	tx_coe = priv->tx_coe;
+	if (likely((priv->tx_coe) && (!priv->no_csum_insertion))) {
+		/* In case of GMAC, SF mode has to be enabled
+		 * to perform the TX COE. This depends on:
+		 * 1) TX COE if actually supported
+		 * 2) There is no bugged Jumbo frame support
+		 *    that needs to not insert csum in the TDES.
+		 */
+		priv->hw->dma->dma_mode(priv->ioaddr,
+					SF_DMA_MODE, SF_DMA_MODE);
+		tc = SF_DMA_MODE;
+	} else
+		priv->hw->dma->dma_mode(priv->ioaddr, tc, SF_DMA_MODE);
 }
 
 /**
@@ -858,6 +844,12 @@ static int stmmac_open(struct net_device *dev)
 	/* Initialize the MAC Core */
 	priv->hw->mac->core_init(priv->ioaddr);
 
+	priv->rx_coe = priv->hw->mac->rx_coe(priv->ioaddr);
+	if (priv->rx_coe)
+		pr_info("stmmac: Rx Checksum Offload Engine supported\n");
+	if (priv->tx_coe)
+		pr_info("\tTX Checksum insertion supported\n");
+
 	priv->shutdown = 0;
 
 	/* Initialise the MMC (if present) to disable all interrupts. */
@@ -1066,7 +1058,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		return stmmac_sw_tso(priv, skb);
 
 	if (likely((skb->ip_summed == CHECKSUM_PARTIAL))) {
-		if (likely(priv->tx_coe == NO_HW_CSUM))
+		if (unlikely((!priv->tx_coe) || (priv->no_csum_insertion)))
 			skb_checksum_help(skb);
 		else
 			csum_insertion = 1;
@@ -1390,6 +1382,15 @@ static int stmmac_change_mtu(struct net_device *dev, int new_mtu)
 		return -EINVAL;
 	}
 
+	/* Some GMAC devices have a bugged Jumbo frame support that
+	 * needs to have the Tx COE disabled for oversized frames
+	 * (due to limited buffer sizes). In this case we disable
+	 * the TX csum insertionin the TDES and not use SF. */
+	if ((priv->bugged_jumbo) && (priv->dev->mtu > ETH_DATA_LEN))
+		priv->no_csum_insertion = 1;
+	else
+		priv->no_csum_insertion = 0;
+
 	dev->mtu = new_mtu;
 
 	return 0;
@@ -1510,9 +1511,6 @@ static int stmmac_probe(struct net_device *dev)
 #endif
 	priv->msg_enable = netif_msg_init(debug, default_msg_level);
 
-	if (priv->is_gmac)
-		priv->rx_csum = 1;
-
 	if (flow_ctrl)
 		priv->flow_ctrl = FLOW_AUTO;	/* RX/TX pause on */
 
@@ -1662,7 +1660,7 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 		ret = -ENODEV;
 		goto out;
 	}
-	pr_info("done!\n");
+	pr_info("\tdone!\n");
 
 	if (!request_mem_region(res->start, resource_size(res),
 				pdev->name)) {
@@ -1705,6 +1703,8 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	priv->bus_id = plat_dat->bus_id;
 	priv->pbl = plat_dat->pbl;	/* TLI */
 	priv->mii_clk_csr = plat_dat->clk_csr;
+	priv->tx_coe = plat_dat->tx_coe;
+	priv->bugged_jumbo = plat_dat->bugged_jumbo;
 	priv->is_gmac = plat_dat->has_gmac;	/* GMAC is on board */
 	priv->enh_desc = plat_dat->enh_desc;
 	priv->ioaddr = addr;
@@ -1966,8 +1966,6 @@ static int __init stmmac_cmdline_opt(char *str)
 			strict_strtoul(opt + 7, 0, (unsigned long *)&buf_sz);
 		else if (!strncmp(opt, "tc:", 3))
 			strict_strtoul(opt + 3, 0, (unsigned long *)&tc);
-		else if (!strncmp(opt, "tx_coe:", 7))
-			strict_strtoul(opt + 7, 0, (unsigned long *)&tx_coe);
 		else if (!strncmp(opt, "watchdog:", 9))
 			strict_strtoul(opt + 9, 0, (unsigned long *)&watchdog);
 		else if (!strncmp(opt, "flow_ctrl:", 10))
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index c87c88c..1d8baf7 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -35,6 +35,8 @@ struct plat_stmmacenet_data {
 	int clk_csr;
 	int has_gmac;
 	int enh_desc;
+	int tx_coe;
+	int bugged_jumbo;
 	void (*fix_mac_speed)(void *priv, unsigned int speed);
 	void (*bus_setup)(void __iomem *ioaddr);
 #ifdef CONFIG_STM_DRIVERS
-- 
1.7.0.4

