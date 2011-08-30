From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 7/9] stmmac: add HW DMA feature register (v2)
Date: Tue, 30 Aug 2011 16:21:02 +0200
Message-ID: <1314714064-29101-8-git-send-email-peppe.cavallaro@st.com>
References: <1314714064-29101-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:42052 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754428Ab1H3OVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 10:21:49 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id B9345E1
	for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 14:21:47 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 5DB142261
	for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 14:21:47 +0000 (GMT)
In-Reply-To: <1314714064-29101-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New GMAC chips have an extra register to indicate
the presence of the optional features/functions of
the DMA core.

This patch adds this support and all the HW cap
are exported via debugfs.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/Kconfig         |    3 +-
 drivers/net/stmmac/common.h        |   33 +++++++++
 drivers/net/stmmac/dwmac1000_dma.c |    6 ++
 drivers/net/stmmac/dwmac_dma.h     |    1 +
 drivers/net/stmmac/stmmac.h        |    1 +
 drivers/net/stmmac/stmmac_main.c   |  131 ++++++++++++++++++++++++++++++++++++
 6 files changed, 174 insertions(+), 1 deletions(-)

diff --git a/drivers/net/stmmac/Kconfig b/drivers/net/stmmac/Kconfig
index c253012..c4be14e 100644
--- a/drivers/net/stmmac/Kconfig
+++ b/drivers/net/stmmac/Kconfig
@@ -16,7 +16,8 @@ config STMMAC_DEBUG_FS
 	default n
 	depends on STMMAC_ETH && DEBUG_FS
 	-- help
-	  The stmmac entry in /sys reports DMA TX/RX rings.
+	  The stmmac entry in /sys reports DMA TX/RX rings
+	  or (if supported) the HW cap register.
 
 config STMMAC_DA
 	bool "STMMAC DMA arbitration scheme"
diff --git a/drivers/net/stmmac/common.h b/drivers/net/stmmac/common.h
index 65b1e56..22c61b2 100644
--- a/drivers/net/stmmac/common.h
+++ b/drivers/net/stmmac/common.h
@@ -116,6 +116,37 @@ enum tx_dma_irq_status {
 	handle_tx_rx = 3,
 };
 
+/* DMA HW capabilities */
+struct dma_features {
+	unsigned int mbps_10_100;
+	unsigned int mbps_1000;
+	unsigned int half_duplex;
+	unsigned int hash_filter;
+	unsigned int multi_addr;
+	unsigned int pcs;
+	unsigned int sma_mdio;
+	unsigned int pmt_remote_wake_up;
+	unsigned int pmt_magic_frame;
+	unsigned int rmon;
+	/* IEEE 1588-2002*/
+	unsigned int time_stamp;
+	/* IEEE 1588-2008*/
+	unsigned int atime_stamp;
+	/* 802.3az - Energy-Efficient Ethernet (EEE) */
+	unsigned int eee;
+	unsigned int av;
+	/* TX and RX csum */
+	unsigned int tx_coe;
+	unsigned int rx_coe_type1;
+	unsigned int rx_coe_type2;
+	unsigned int rxfifo_over_2048;
+	/* TX and RX number of channels */
+	unsigned int number_rx_channel;
+	unsigned int number_tx_channel;
+	/* Alternate (enhanced) DESC mode*/
+	unsigned int enh_desc;
+};
+
 /* GMAC TX FIFO is 8K, Rx FIFO is 16K */
 #define BUF_SIZE_16KiB 16384
 #define BUF_SIZE_8KiB 8192
@@ -188,6 +219,8 @@ struct stmmac_dma_ops {
 	void (*stop_rx) (void __iomem *ioaddr);
 	int (*dma_interrupt) (void __iomem *ioaddr,
 			      struct stmmac_extra_stats *x);
+	/* If supported then get the optional core features */
+	unsigned int (*get_hw_feature) (void __iomem *ioaddr);
 };
 
 struct stmmac_ops {
diff --git a/drivers/net/stmmac/dwmac1000_dma.c b/drivers/net/stmmac/dwmac1000_dma.c
index a89384c..da66ac5 100644
--- a/drivers/net/stmmac/dwmac1000_dma.c
+++ b/drivers/net/stmmac/dwmac1000_dma.c
@@ -132,6 +132,11 @@ static void dwmac1000_dump_dma_regs(void __iomem *ioaddr)
 	}
 }
 
+static unsigned int dwmac1000_get_hw_feature(void __iomem *ioaddr)
+{
+	return readl(ioaddr + DMA_HW_FEATURE);
+}
+
 const struct stmmac_dma_ops dwmac1000_dma_ops = {
 	.init = dwmac1000_dma_init,
 	.dump_regs = dwmac1000_dump_dma_regs,
@@ -144,4 +149,5 @@ const struct stmmac_dma_ops dwmac1000_dma_ops = {
 	.start_rx = dwmac_dma_start_rx,
 	.stop_rx = dwmac_dma_stop_rx,
 	.dma_interrupt = dwmac_dma_interrupt,
+	.get_hw_feature = dwmac1000_get_hw_feature,
 };
diff --git a/drivers/net/stmmac/dwmac_dma.h b/drivers/net/stmmac/dwmac_dma.h
index da3f5cc..437edac 100644
--- a/drivers/net/stmmac/dwmac_dma.h
+++ b/drivers/net/stmmac/dwmac_dma.h
@@ -34,6 +34,7 @@
 #define DMA_MISSED_FRAME_CTR	0x00001020	/* Missed Frame Counter */
 #define DMA_CUR_TX_BUF_ADDR	0x00001050	/* Current Host Tx Buffer */
 #define DMA_CUR_RX_BUF_ADDR	0x00001054	/* Current Host Rx Buffer */
+#define DMA_HW_FEATURE		0x00001058	/* HW Feature Register */
 
 /* DMA Control register defines */
 #define DMA_CONTROL_ST		0x00002000	/* Start/Stop Transmission */
diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index ef03796..c3a2da7 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -78,6 +78,7 @@ struct stmmac_priv {
 #endif
 	struct plat_stmmacenet_data *plat;
 	struct stmmac_counters mmc;
+	struct dma_features dma_cap;
 };
 
 extern int stmmac_mdio_unregister(struct net_device *ndev);
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index f9ba0f7..a87d583 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -779,6 +779,49 @@ static u32 stmmac_get_synopsys_id(struct stmmac_priv *priv)
 	}
 	return 0;
 }
+
+/* New GMAC chips support a new register to indicate the
+ * presence of the optional feature/functions.
+ */
+static int stmmac_get_hw_features(struct stmmac_priv *priv)
+{
+	u32 hw_cap = priv->hw->dma->get_hw_feature(priv->ioaddr);
+
+	if (likely(hw_cap)) {
+		priv->dma_cap.mbps_10_100 = (hw_cap & 0x1);
+		priv->dma_cap.mbps_1000 = (hw_cap & 0x2) >> 1;
+		priv->dma_cap.half_duplex = (hw_cap & 0x4) >> 2;
+		priv->dma_cap.hash_filter = (hw_cap & 0x10) >> 4;
+		priv->dma_cap.multi_addr = (hw_cap & 0x20) >> 5;
+		priv->dma_cap.pcs = (hw_cap & 0x40) >> 6;
+		priv->dma_cap.sma_mdio = (hw_cap & 0x100) >> 8;
+		priv->dma_cap.pmt_remote_wake_up = (hw_cap & 0x200) >> 9;
+		priv->dma_cap.pmt_magic_frame = (hw_cap & 0x400) >> 10;
+		priv->dma_cap.rmon = (hw_cap & 0x800) >> 11; /* MMC */
+		/* IEEE 1588-2002*/
+		priv->dma_cap.time_stamp = (hw_cap & 0x1000) >> 12;
+		/* IEEE 1588-2008*/
+		priv->dma_cap.atime_stamp = (hw_cap & 0x2000) >> 13;
+		/* 802.3az - Energy-Efficient Ethernet (EEE) */
+		priv->dma_cap.eee = (hw_cap & 0x4000) >> 14;
+		priv->dma_cap.av = (hw_cap & 0x8000) >> 15;
+		/* TX and RX csum */
+		priv->dma_cap.tx_coe = (hw_cap & 0x10000) >> 16;
+		priv->dma_cap.rx_coe_type1 = (hw_cap & 0x20000) >> 17;
+		priv->dma_cap.rx_coe_type2 = (hw_cap & 0x40000) >> 18;
+		priv->dma_cap.rxfifo_over_2048 = (hw_cap & 0x80000) >> 19;
+		/* TX and RX number of channels */
+		priv->dma_cap.number_rx_channel = (hw_cap & 0x300000) >> 20;
+		priv->dma_cap.number_tx_channel = (hw_cap & 0xc00000) >> 22;
+		/* Alternate (enhanced) DESC mode*/
+		priv->dma_cap.enh_desc = (hw_cap & 0x1000000) >> 24;
+
+	} else
+		pr_debug("\tNo HW DMA feature register supported");
+
+	return hw_cap;
+}
+
 /**
  *  stmmac_open - open entry point of the driver
  *  @dev : pointer to the device structure.
@@ -853,6 +896,8 @@ static int stmmac_open(struct net_device *dev)
 
 	stmmac_get_synopsys_id(priv);
 
+	stmmac_get_hw_features(priv);
+
 	if (priv->rx_coe)
 		pr_info("stmmac: Rx Checksum Offload Engine supported\n");
 	if (priv->plat->tx_coe)
@@ -1449,6 +1494,7 @@ static int stmmac_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 #ifdef CONFIG_STMMAC_DEBUG_FS
 static struct dentry *stmmac_fs_dir;
 static struct dentry *stmmac_rings_status;
+static struct dentry *stmmac_dma_cap;
 
 static int stmmac_sysfs_ring_read(struct seq_file *seq, void *v)
 {
@@ -1502,6 +1548,78 @@ static const struct file_operations stmmac_rings_status_fops = {
 	.release = seq_release,
 };
 
+static int stmmac_sysfs_dma_cap_read(struct seq_file *seq, void *v)
+{
+	struct net_device *dev = seq->private;
+	struct stmmac_priv *priv = netdev_priv(dev);
+
+	if (!stmmac_get_hw_features(priv)) {
+		seq_printf(seq, "DMA HW features not supported\n");
+		return 0;
+	}
+
+	seq_printf(seq, "==============================\n");
+	seq_printf(seq, "\tDMA HW features\n");
+	seq_printf(seq, "==============================\n");
+
+	seq_printf(seq, "\t10/100 Mbps %s\n",
+		   (priv->dma_cap.mbps_10_100) ? "Y" : "N");
+	seq_printf(seq, "\t1000 Mbps %s\n",
+		   (priv->dma_cap.mbps_1000) ? "Y" : "N");
+	seq_printf(seq, "\tHalf duple %s\n",
+		   (priv->dma_cap.half_duplex) ? "Y" : "N");
+	seq_printf(seq, "\tHash Filter: %s\n",
+		   (priv->dma_cap.hash_filter) ? "Y" : "N");
+	seq_printf(seq, "\tMultiple MAC address registers: %s\n",
+		   (priv->dma_cap.multi_addr) ? "Y" : "N");
+	seq_printf(seq, "\tPCS (TBI/SGMII/RTBI PHY interfatces): %s\n",
+		   (priv->dma_cap.pcs) ? "Y" : "N");
+	seq_printf(seq, "\tSMA (MDIO) Interface: %s\n",
+		   (priv->dma_cap.sma_mdio) ? "Y" : "N");
+	seq_printf(seq, "\tPMT Remote wake up: %s\n",
+		   (priv->dma_cap.pmt_remote_wake_up) ? "Y" : "N");
+	seq_printf(seq, "\tPMT Magic Frame: %s\n",
+		   (priv->dma_cap.pmt_magic_frame) ? "Y" : "N");
+	seq_printf(seq, "\tRMON module: %s\n",
+		   (priv->dma_cap.rmon) ? "Y" : "N");
+	seq_printf(seq, "\tIEEE 1588-2002 Time Stamp: %s\n",
+		   (priv->dma_cap.time_stamp) ? "Y" : "N");
+	seq_printf(seq, "\tIEEE 1588-2008 Advanced Time Stamp:%s\n",
+		   (priv->dma_cap.atime_stamp) ? "Y" : "N");
+	seq_printf(seq, "\t802.3az - Energy-Efficient Ethernet (EEE) %s\n",
+		   (priv->dma_cap.eee) ? "Y" : "N");
+	seq_printf(seq, "\tAV features: %s\n", (priv->dma_cap.av) ? "Y" : "N");
+	seq_printf(seq, "\tChecksum Offload in TX: %s\n",
+		   (priv->dma_cap.tx_coe) ? "Y" : "N");
+	seq_printf(seq, "\tIP Checksum Offload (type1) in RX: %s\n",
+		   (priv->dma_cap.rx_coe_type1) ? "Y" : "N");
+	seq_printf(seq, "\tIP Checksum Offload (type2) in RX: %s\n",
+		   (priv->dma_cap.rx_coe_type2) ? "Y" : "N");
+	seq_printf(seq, "\tRXFIFO > 2048bytes: %s\n",
+		   (priv->dma_cap.rxfifo_over_2048) ? "Y" : "N");
+	seq_printf(seq, "\tNumber of Additional RX channel: %d\n",
+		   priv->dma_cap.number_rx_channel);
+	seq_printf(seq, "\tNumber of Additional TX channel: %d\n",
+		   priv->dma_cap.number_tx_channel);
+	seq_printf(seq, "\tEnhanced descriptors: %s\n",
+		   (priv->dma_cap.enh_desc) ? "Y" : "N");
+
+	return 0;
+}
+
+static int stmmac_sysfs_dma_cap_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, stmmac_sysfs_dma_cap_read, inode->i_private);
+}
+
+static const struct file_operations stmmac_dma_cap_fops = {
+	.owner = THIS_MODULE,
+	.open = stmmac_sysfs_dma_cap_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = seq_release,
+};
+
 static int stmmac_init_fs(struct net_device *dev)
 {
 	/* Create debugfs entries */
@@ -1526,12 +1644,25 @@ static int stmmac_init_fs(struct net_device *dev)
 		return -ENOMEM;
 	}
 
+	/* Entry to report the DMA HW features */
+	stmmac_dma_cap = debugfs_create_file("dma_cap", S_IRUGO, stmmac_fs_dir,
+					     dev, &stmmac_dma_cap_fops);
+
+	if (!stmmac_dma_cap || IS_ERR(stmmac_dma_cap)) {
+		pr_info("ERROR creating stmmac MMC debugfs file\n");
+		debugfs_remove(stmmac_rings_status);
+		debugfs_remove(stmmac_fs_dir);
+
+		return -ENOMEM;
+	}
+
 	return 0;
 }
 
 static void stmmac_exit_fs(void)
 {
 	debugfs_remove(stmmac_rings_status);
+	debugfs_remove(stmmac_dma_cap);
 	debugfs_remove(stmmac_fs_dir);
 }
 #endif /* CONFIG_STMMAC_DEBUG_FS */
-- 
1.7.4.4
