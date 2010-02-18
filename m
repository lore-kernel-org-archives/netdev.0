From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 05/15] drivers/net/bnx2x: Use (pr|netdev|netif)_<level> macro helpers
Date: Wed, 17 Feb 2010 17:01:52 -0800
Message-ID: <30c0b394b12779fb43ef6adce82cdee940b017f1.1266454576.git.joe@perches.com>
References: <cover.1266454575.git.joe@perches.com>
Cc: Eilon Greenstein <eilong@broadcom.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1266454575.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Convert struct bnx2x member msglevel to msg_enable for netif_msg_<foo> macros
Remove #define PFX
Use pr_<level>
Use netdev_<level>
Use netif_<level>
Coalesce long formats

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/bnx2x.h      |   49 +++++++-----
 drivers/net/bnx2x_link.c |   21 ++----
 drivers/net/bnx2x_main.c |  185 ++++++++++++++++++++-------------------------
 3 files changed, 117 insertions(+), 138 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 602ab86..9f64f79 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -44,7 +44,6 @@
 /* error/debug prints */
 
 #define DRV_MODULE_NAME		"bnx2x"
-#define PFX DRV_MODULE_NAME	": "
 
 /* for messages that are currently off */
 #define BNX2X_MSG_OFF			0
@@ -58,30 +57,40 @@
 #define DP_LEVEL			KERN_NOTICE	/* was: KERN_DEBUG */
 
 /* regular debug print */
-#define DP(__mask, __fmt, __args...) do { \
-	if (bp->msglevel & (__mask)) \
-		printk(DP_LEVEL "[%s:%d(%s)]" __fmt, __func__, __LINE__, \
-			bp->dev ? (bp->dev->name) : "?", ##__args); \
-	} while (0)
+#define DP(__mask, __fmt, __args...)				\
+do {								\
+	if (bp->msg_enable & (__mask))				\
+		printk(DP_LEVEL "[%s:%d(%s)]" __fmt,		\
+		       __func__, __LINE__,			\
+		       bp->dev ? (bp->dev->name) : "?",		\
+		       ##__args);				\
+} while (0)
 
 /* errors debug print */
-#define BNX2X_DBG_ERR(__fmt, __args...) do { \
-	if (bp->msglevel & NETIF_MSG_PROBE) \
-		printk(KERN_ERR "[%s:%d(%s)]" __fmt, __func__, __LINE__, \
-			bp->dev ? (bp->dev->name) : "?", ##__args); \
-	} while (0)
+#define BNX2X_DBG_ERR(__fmt, __args...)				\
+do {								\
+	if (netif_msg_probe(bp))				\
+		pr_err("[%s:%d(%s)]" __fmt,			\
+		       __func__, __LINE__,			\
+		       bp->dev ? (bp->dev->name) : "?",		\
+		       ##__args);				\
+} while (0)
 
 /* for errors (never masked) */
-#define BNX2X_ERR(__fmt, __args...) do { \
-	printk(KERN_ERR "[%s:%d(%s)]" __fmt, __func__, __LINE__, \
-		bp->dev ? (bp->dev->name) : "?", ##__args); \
-	} while (0)
+#define BNX2X_ERR(__fmt, __args...)				\
+do {								\
+	pr_err("[%s:%d(%s)]" __fmt,				\
+	       __func__, __LINE__,				\
+	       bp->dev ? (bp->dev->name) : "?",			\
+	       ##__args);					\
+} while (0)
 
 /* before we have a dev->name use dev_info() */
-#define BNX2X_DEV_INFO(__fmt, __args...) do { \
-	if (bp->msglevel & NETIF_MSG_PROBE) \
-		dev_info(&bp->pdev->dev, __fmt, ##__args); \
-	} while (0)
+#define BNX2X_DEV_INFO(__fmt, __args...)			 \
+do {								 \
+	if (netif_msg_probe(bp))				 \
+		dev_info(&bp->pdev->dev, __fmt, ##__args);	 \
+} while (0)
 
 
 #ifdef BNX2X_STOP_ON_ERROR
@@ -882,7 +891,7 @@ struct bnx2x {
 	/* End of fields used in the performance code paths */
 
 	int			panic;
-	int			msglevel;
+	int			msg_enable;
 
 	u32			flags;
 #define PCIX_FLAG			1
diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index cf57789..32e79c3 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -14,6 +14,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/errno.h>
 #include <linux/pci.h>
@@ -2987,11 +2989,8 @@ static u8 bnx2x_verify_sfp_module(struct link_params *params)
 	else
 		vendor_pn[SFP_EEPROM_PART_NO_SIZE] = '\0';
 
-	printk(KERN_INFO PFX  "Warning: "
-			 "Unqualified SFP+ module "
-			 "detected on %s, Port %d from %s part number %s\n"
-			, bp->dev->name, params->port,
-			vendor_name, vendor_pn);
+	netdev_info(bp->dev, "Warning: Unqualified SFP+ module detected, Port %d from %s part number %s\n",
+		    params->port, vendor_name, vendor_pn);
 	return -EINVAL;
 }
 
@@ -4846,16 +4845,8 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 						     " has been detected on "
 						     "port %d\n",
 						 params->port);
-					printk(KERN_ERR PFX  "Error:  Power"
-						 " fault on %s Port %d has"
-						 " been detected and the"
-						 " power to that SFP+ module"
-						 " has been removed to prevent"
-						 " failure of the card. Please"
-						 " remove the SFP+ module and"
-						 " restart the system to clear"
-						 " this error.\n"
-			, bp->dev->name, params->port);
+					netdev_err(bp->dev, "Error:  Power fault on Port %d has been detected and the power to that SFP+ module has been removed to prevent failure of the card. Please remove the SFP+ module and restart the system to clear this error.\n",
+						   params->port);
 					/*
 					 * Disable all RX_ALARMs except for
 					 * mod_abs
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 6d85590..e01675c 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -514,24 +514,24 @@ static void bnx2x_fw_dump(struct bnx2x *bp)
 
 	mark = REG_RD(bp, MCP_REG_MCPR_SCRATCH + 0xf104);
 	mark = ((mark + 0x3) & ~0x3);
-	printk(KERN_ERR PFX "begin fw dump (mark 0x%x)\n", mark);
+	pr_err("begin fw dump (mark 0x%x)\n", mark);
 
-	printk(KERN_ERR PFX);
+	pr_err("");
 	for (offset = mark - 0x08000000; offset <= 0xF900; offset += 0x8*4) {
 		for (word = 0; word < 8; word++)
 			data[word] = htonl(REG_RD(bp, MCP_REG_MCPR_SCRATCH +
 						  offset + 4*word));
 		data[8] = 0x0;
-		printk(KERN_CONT "%s", (char *)data);
+		pr_cont("%s", (char *)data);
 	}
 	for (offset = 0xF108; offset <= mark - 0x08000000; offset += 0x8*4) {
 		for (word = 0; word < 8; word++)
 			data[word] = htonl(REG_RD(bp, MCP_REG_MCPR_SCRATCH +
 						  offset + 4*word));
 		data[8] = 0x0;
-		printk(KERN_CONT "%s", (char *)data);
+		pr_cont("%s", (char *)data);
 	}
-	printk(KERN_ERR PFX "end of fw dump\n");
+	pr_err("end of fw dump\n");
 }
 
 static void bnx2x_panic_dump(struct bnx2x *bp)
@@ -2136,7 +2136,7 @@ static void bnx2x_link_report(struct bnx2x *bp)
 {
 	if (bp->flags & MF_FUNC_DIS) {
 		netif_carrier_off(bp->dev);
-		printk(KERN_ERR PFX "%s NIC Link is Down\n", bp->dev->name);
+		netdev_err(bp->dev, "NIC Link is Down\n");
 		return;
 	}
 
@@ -2145,7 +2145,7 @@ static void bnx2x_link_report(struct bnx2x *bp)
 
 		if (bp->state == BNX2X_STATE_OPEN)
 			netif_carrier_on(bp->dev);
-		printk(KERN_INFO PFX "%s NIC Link is Up, ", bp->dev->name);
+		netdev_info(bp->dev, "NIC Link is Up, ");
 
 		line_speed = bp->link_vars.line_speed;
 		if (IS_E1HMF(bp)) {
@@ -2157,29 +2157,29 @@ static void bnx2x_link_report(struct bnx2x *bp)
 			if (vn_max_rate < line_speed)
 				line_speed = vn_max_rate;
 		}
-		printk("%d Mbps ", line_speed);
+		pr_cont("%d Mbps ", line_speed);
 
 		if (bp->link_vars.duplex == DUPLEX_FULL)
-			printk("full duplex");
+			pr_cont("full duplex");
 		else
-			printk("half duplex");
+			pr_cont("half duplex");
 
 		if (bp->link_vars.flow_ctrl != BNX2X_FLOW_CTRL_NONE) {
 			if (bp->link_vars.flow_ctrl & BNX2X_FLOW_CTRL_RX) {
-				printk(", receive ");
+				pr_cont(", receive ");
 				if (bp->link_vars.flow_ctrl &
 				    BNX2X_FLOW_CTRL_TX)
-					printk("& transmit ");
+					pr_cont("& transmit ");
 			} else {
-				printk(", transmit ");
+				pr_cont(", transmit ");
 			}
-			printk("flow control ON");
+			pr_cont("flow control ON");
 		}
-		printk("\n");
+		pr_cont("\n");
 
 	} else { /* link_down */
 		netif_carrier_off(bp->dev);
-		printk(KERN_ERR PFX "%s NIC Link is Down\n", bp->dev->name);
+		netdev_err(bp->dev, "NIC Link is Down\n");
 	}
 }
 
@@ -2898,10 +2898,8 @@ static inline void bnx2x_fan_failure(struct bnx2x *bp)
 		 bp->link_params.ext_phy_config);
 
 	/* log the failure */
-	printk(KERN_ERR PFX "Fan Failure on Network Controller %s has caused"
-	       " the driver to shutdown the card to prevent permanent"
-	       " damage.  Please contact Dell Support for assistance\n",
-	       bp->dev->name);
+	netdev_err(bp->dev, "Fan Failure on Network Controller has caused the driver to shutdown the card to prevent permanent damage.\n"
+		   "Please contact Dell Support for assistance.\n");
 }
 
 static inline void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 attn)
@@ -4296,7 +4294,7 @@ static void bnx2x_stats_update(struct bnx2x *bp)
 	bnx2x_net_stats_update(bp);
 	bnx2x_drv_stats_update(bp);
 
-	if (bp->msglevel & NETIF_MSG_TIMER) {
+	if (netif_msg_timer(bp)) {
 		struct bnx2x_fastpath *fp0_rx = bp->fp;
 		struct bnx2x_fastpath *fp0_tx = bp->fp;
 		struct tstorm_per_client_stats *old_tclient =
@@ -4306,7 +4304,7 @@ static void bnx2x_stats_update(struct bnx2x *bp)
 		struct net_device_stats *nstats = &bp->dev->stats;
 		int i;
 
-		printk(KERN_DEBUG "%s:\n", bp->dev->name);
+		netdev_printk(KERN_DEBUG, bp->dev, "\n");
 		printk(KERN_DEBUG "  tx avail (%4x)  tx hc idx (%x)"
 				  "  tx pkt (%lx)\n",
 		       bnx2x_tx_avail(fp0_tx),
@@ -4464,7 +4462,7 @@ static void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_event event)
 	/* Make sure the state has been "changed" */
 	smp_wmb();
 
-	if ((event != STATS_EVENT_UPDATE) || (bp->msglevel & NETIF_MSG_TIMER))
+	if ((event != STATS_EVENT_UPDATE) || netif_msg_timer(bp))
 		DP(BNX2X_MSG_STATS, "state %d -> event %d -> state %d\n",
 		   state, event, bp->stats_state);
 }
@@ -5674,8 +5672,7 @@ gunzip_nomem2:
 	bp->gunzip_buf = NULL;
 
 gunzip_nomem1:
-	printk(KERN_ERR PFX "%s: Cannot allocate firmware buffer for"
-	       " un-compression\n", bp->dev->name);
+	netdev_err(bp->dev, "Cannot allocate firmware buffer for un-compression\n");
 	return -ENOMEM;
 }
 
@@ -5721,14 +5718,13 @@ static int bnx2x_gunzip(struct bnx2x *bp, const u8 *zbuf, int len)
 
 	rc = zlib_inflate(bp->strm, Z_FINISH);
 	if ((rc != Z_OK) && (rc != Z_STREAM_END))
-		printk(KERN_ERR PFX "%s: Firmware decompression error: %s\n",
-		       bp->dev->name, bp->strm->msg);
+		netdev_err(bp->dev, "Firmware decompression error: %s\n",
+			   bp->strm->msg);
 
 	bp->gunzip_outlen = (FW_BUF_SIZE - bp->strm->avail_out);
 	if (bp->gunzip_outlen & 0x3)
-		printk(KERN_ERR PFX "%s: Firmware decompression error:"
-				    " gunzip_outlen (%d) not aligned\n",
-		       bp->dev->name, bp->gunzip_outlen);
+		netdev_err(bp->dev, "Firmware decompression error: gunzip_outlen (%d) not aligned\n",
+			   bp->gunzip_outlen);
 	bp->gunzip_outlen >>= 2;
 
 	zlib_inflateEnd(bp->strm);
@@ -6213,8 +6209,8 @@ static int bnx2x_init_common(struct bnx2x *bp)
 
 	if (sizeof(union cdu_context) != 1024)
 		/* we currently assume that a context is 1024 bytes */
-		printk(KERN_ALERT PFX "please adjust the size of"
-		       " cdu_context(%ld)\n", (long)sizeof(union cdu_context));
+		pr_alert("please adjust the size of cdu_context(%ld)\n",
+			 (long)sizeof(union cdu_context));
 
 	bnx2x_init_block(bp, CDU_BLOCK, COMMON_STAGE);
 	val = (4 << 24) + (0 << 12) + 1024;
@@ -7018,11 +7014,10 @@ static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 	}
 
 	i = BNX2X_NUM_QUEUES(bp);
-	printk(KERN_INFO PFX "%s: using MSI-X  IRQs: sp %d  fp[%d] %d"
-	       " ... fp[%d] %d\n",
-	       bp->dev->name, bp->msix_table[0].vector,
-	       0, bp->msix_table[offset].vector,
-	       i - 1, bp->msix_table[offset + i - 1].vector);
+	netdev_info(bp->dev, "using MSI-X  IRQs: sp %d  fp[%d] %d ... fp[%d] %d\n",
+		    bp->msix_table[0].vector,
+		    0, bp->msix_table[offset].vector,
+		    i - 1, bp->msix_table[offset + i - 1].vector);
 
 	return 0;
 }
@@ -7477,8 +7472,8 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		}
 		if (bp->flags & USING_MSI_FLAG) {
 			bp->dev->irq = bp->pdev->irq;
-			printk(KERN_INFO PFX "%s: using MSI  IRQ %d\n",
-			       bp->dev->name, bp->pdev->irq);
+			netdev_info(bp->dev, "using MSI  IRQ %d\n",
+				    bp->pdev->irq);
 		}
 	}
 
@@ -8297,8 +8292,7 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 	val3 = SHMEM_RD(bp, dev_info.shared_hw_config.part_num[8]);
 	val4 = SHMEM_RD(bp, dev_info.shared_hw_config.part_num[12]);
 
-	printk(KERN_INFO PFX "part number %X-%X-%X-%X\n",
-	       val, val2, val3, val4);
+	pr_info("part number %X-%X-%X-%X\n", val, val2, val3, val4);
 }
 
 static void __devinit bnx2x_link_settings_supported(struct bnx2x *bp,
@@ -8909,17 +8903,15 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 		bnx2x_undi_unload(bp);
 
 	if (CHIP_REV_IS_FPGA(bp))
-		printk(KERN_ERR PFX "FPGA detected\n");
+		pr_err("FPGA detected\n");
 
 	if (BP_NOMCP(bp) && (func == 0))
-		printk(KERN_ERR PFX
-		       "MCP disabled, must load devices in order!\n");
+		pr_err("MCP disabled, must load devices in order!\n");
 
 	/* Set multi queue mode */
 	if ((multi_mode != ETH_RSS_MODE_DISABLED) &&
 	    ((int_mode == INT_MODE_INTx) || (int_mode == INT_MODE_MSI))) {
-		printk(KERN_ERR PFX
-		      "Multi disabled since int_mode requested is not MSI-X\n");
+		pr_err("Multi disabled since int_mode requested is not MSI-X\n");
 		multi_mode = ETH_RSS_MODE_DISABLED;
 	}
 	bp->multi_mode = multi_mode;
@@ -9345,7 +9337,7 @@ static u32 bnx2x_get_msglevel(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
-	return bp->msglevel;
+	return bp->msg_enable;
 }
 
 static void bnx2x_set_msglevel(struct net_device *dev, u32 level)
@@ -9353,7 +9345,7 @@ static void bnx2x_set_msglevel(struct net_device *dev, u32 level)
 	struct bnx2x *bp = netdev_priv(dev);
 
 	if (capable(CAP_NET_ADMIN))
-		bp->msglevel = level;
+		bp->msg_enable = level;
 }
 
 static int bnx2x_nway_reset(struct net_device *dev)
@@ -10644,7 +10636,7 @@ static const struct {
 	((bnx2x_stats_arr[i].flags & STATS_FLAGS_BOTH) == STATS_FLAGS_PORT)
 #define IS_FUNC_STAT(i)		(bnx2x_stats_arr[i].flags & STATS_FLAGS_FUNC)
 #define IS_E1HMF_MODE_STAT(bp) \
-			(IS_E1HMF(bp) && !(bp->msglevel & BNX2X_MSG_STATS))
+			(IS_E1HMF(bp) && !(bp->msg_enable & BNX2X_MSG_STATS))
 
 static int bnx2x_get_sset_count(struct net_device *dev, int stringset)
 {
@@ -11777,20 +11769,18 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 
 	rc = pci_enable_device(pdev);
 	if (rc) {
-		printk(KERN_ERR PFX "Cannot enable PCI device, aborting\n");
+		pr_err("Cannot enable PCI device, aborting\n");
 		goto err_out;
 	}
 
 	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
-		printk(KERN_ERR PFX "Cannot find PCI device base address,"
-		       " aborting\n");
+		pr_err("Cannot find PCI device base address, aborting\n");
 		rc = -ENODEV;
 		goto err_out_disable;
 	}
 
 	if (!(pci_resource_flags(pdev, 2) & IORESOURCE_MEM)) {
-		printk(KERN_ERR PFX "Cannot find second PCI device"
-		       " base address, aborting\n");
+		pr_err("Cannot find second PCI device base address, aborting\n");
 		rc = -ENODEV;
 		goto err_out_disable;
 	}
@@ -11798,8 +11788,7 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 	if (atomic_read(&pdev->enable_cnt) == 1) {
 		rc = pci_request_regions(pdev, DRV_MODULE_NAME);
 		if (rc) {
-			printk(KERN_ERR PFX "Cannot obtain PCI resources,"
-			       " aborting\n");
+			pr_err("Cannot obtain PCI resources, aborting\n");
 			goto err_out_disable;
 		}
 
@@ -11809,16 +11798,14 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 
 	bp->pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
 	if (bp->pm_cap == 0) {
-		printk(KERN_ERR PFX "Cannot find power management"
-		       " capability, aborting\n");
+		pr_err("Cannot find power management capability, aborting\n");
 		rc = -EIO;
 		goto err_out_release;
 	}
 
 	bp->pcie_cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
 	if (bp->pcie_cap == 0) {
-		printk(KERN_ERR PFX "Cannot find PCI Express capability,"
-		       " aborting\n");
+		pr_err("Cannot find PCI Express capability, aborting\n");
 		rc = -EIO;
 		goto err_out_release;
 	}
@@ -11826,15 +11813,13 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) == 0) {
 		bp->flags |= USING_DAC_FLAG;
 		if (pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64)) != 0) {
-			printk(KERN_ERR PFX "pci_set_consistent_dma_mask"
-			       " failed, aborting\n");
+			pr_err("pci_set_consistent_dma_mask failed, aborting\n");
 			rc = -EIO;
 			goto err_out_release;
 		}
 
 	} else if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) != 0) {
-		printk(KERN_ERR PFX "System does not support DMA,"
-		       " aborting\n");
+		pr_err("System does not support DMA, aborting\n");
 		rc = -EIO;
 		goto err_out_release;
 	}
@@ -11847,7 +11832,7 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 
 	bp->regview = pci_ioremap_bar(pdev, 0);
 	if (!bp->regview) {
-		printk(KERN_ERR PFX "Cannot map register space, aborting\n");
+		pr_err("Cannot map register space, aborting\n");
 		rc = -ENOMEM;
 		goto err_out_release;
 	}
@@ -11856,7 +11841,7 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 					min_t(u64, BNX2X_DB_SIZE,
 					      pci_resource_len(pdev, 2)));
 	if (!bp->doorbells) {
-		printk(KERN_ERR PFX "Cannot map doorbell space, aborting\n");
+		pr_err("Cannot map doorbell space, aborting\n");
 		rc = -ENOMEM;
 		goto err_out_unmap;
 	}
@@ -11958,8 +11943,7 @@ static int __devinit bnx2x_check_firmware(struct bnx2x *bp)
 		offset = be32_to_cpu(sections[i].offset);
 		len = be32_to_cpu(sections[i].len);
 		if (offset + len > firmware->size) {
-			printk(KERN_ERR PFX "Section %d length is out of "
-					    "bounds\n", i);
+			pr_err("Section %d length is out of bounds\n", i);
 			return -EINVAL;
 		}
 	}
@@ -11971,8 +11955,7 @@ static int __devinit bnx2x_check_firmware(struct bnx2x *bp)
 
 	for (i = 0; i < be32_to_cpu(fw_hdr->init_ops_offsets.len) / 2; i++) {
 		if (be16_to_cpu(ops_offsets[i]) > num_ops) {
-			printk(KERN_ERR PFX "Section offset %d is out of "
-					    "bounds\n", i);
+			pr_err("Section offset %d is out of bounds\n", i);
 			return -EINVAL;
 		}
 	}
@@ -11984,8 +11967,7 @@ static int __devinit bnx2x_check_firmware(struct bnx2x *bp)
 	    (fw_ver[1] != BCM_5710_FW_MINOR_VERSION) ||
 	    (fw_ver[2] != BCM_5710_FW_REVISION_VERSION) ||
 	    (fw_ver[3] != BCM_5710_FW_ENGINEERING_VERSION)) {
-		printk(KERN_ERR PFX "Bad FW version:%d.%d.%d.%d."
-				    " Should be %d.%d.%d.%d\n",
+		pr_err("Bad FW version:%d.%d.%d.%d. Should be %d.%d.%d.%d\n",
 		       fw_ver[0], fw_ver[1], fw_ver[2],
 		       fw_ver[3], BCM_5710_FW_MAJOR_VERSION,
 		       BCM_5710_FW_MINOR_VERSION,
@@ -12035,18 +12017,17 @@ static inline void be16_to_cpu_n(const u8 *_source, u8 *_target, u32 n)
 		target[i] = be16_to_cpu(source[i]);
 }
 
-#define BNX2X_ALLOC_AND_SET(arr, lbl, func) \
-	do { \
-		u32 len = be32_to_cpu(fw_hdr->arr.len); \
-		bp->arr = kmalloc(len, GFP_KERNEL); \
-		if (!bp->arr) { \
-			printk(KERN_ERR PFX "Failed to allocate %d bytes " \
-					    "for "#arr"\n", len); \
-			goto lbl; \
-		} \
-		func(bp->firmware->data + be32_to_cpu(fw_hdr->arr.offset), \
-		     (u8 *)bp->arr, len); \
-	} while (0)
+#define BNX2X_ALLOC_AND_SET(arr, lbl, func)				\
+do {									\
+	u32 len = be32_to_cpu(fw_hdr->arr.len);				\
+	bp->arr = kmalloc(len, GFP_KERNEL);				\
+	if (!bp->arr) {							\
+		pr_err("Failed to allocate %d bytes for "#arr"\n", len); \
+		goto lbl;						\
+	}								\
+	func(bp->firmware->data + be32_to_cpu(fw_hdr->arr.offset),	\
+	     (u8 *)bp->arr, len);					\
+} while (0)
 
 static int __devinit bnx2x_init_firmware(struct bnx2x *bp, struct device *dev)
 {
@@ -12059,18 +12040,17 @@ static int __devinit bnx2x_init_firmware(struct bnx2x *bp, struct device *dev)
 	else
 		fw_file_name = FW_FILE_NAME_E1H;
 
-	printk(KERN_INFO PFX "Loading %s\n", fw_file_name);
+	pr_info("Loading %s\n", fw_file_name);
 
 	rc = request_firmware(&bp->firmware, fw_file_name, dev);
 	if (rc) {
-		printk(KERN_ERR PFX "Can't load firmware file %s\n",
-		       fw_file_name);
+		pr_err("Can't load firmware file %s\n", fw_file_name);
 		goto request_firmware_exit;
 	}
 
 	rc = bnx2x_check_firmware(bp);
 	if (rc) {
-		printk(KERN_ERR PFX "Corrupt firmware file %s\n", fw_file_name);
+		pr_err("Corrupt firmware file %s\n", fw_file_name);
 		goto request_firmware_exit;
 	}
 
@@ -12129,12 +12109,12 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	/* dev zeroed in init_etherdev */
 	dev = alloc_etherdev_mq(sizeof(*bp), MAX_CONTEXT);
 	if (!dev) {
-		printk(KERN_ERR PFX "Cannot allocate net device\n");
+		pr_err("Cannot allocate net device\n");
 		return -ENOMEM;
 	}
 
 	bp = netdev_priv(dev);
-	bp->msglevel = debug;
+	bp->msg_enable = debug;
 
 	pci_set_drvdata(pdev, dev);
 
@@ -12151,7 +12131,7 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	/* Set init arrays */
 	rc = bnx2x_init_firmware(bp, &pdev->dev);
 	if (rc) {
-		printk(KERN_ERR PFX "Error loading firmware\n");
+		pr_err("Error loading firmware\n");
 		goto init_one_exit;
 	}
 
@@ -12162,12 +12142,11 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	}
 
 	bnx2x_get_pcie_width_speed(bp, &pcie_width, &pcie_speed);
-	printk(KERN_INFO "%s: %s (%c%d) PCI-E x%d %s found at mem %lx,"
-	       " IRQ %d, ", dev->name, board_info[ent->driver_data].name,
-	       (CHIP_REV(bp) >> 12) + 'A', (CHIP_METAL(bp) >> 4),
-	       pcie_width, (pcie_speed == 2) ? "5GHz (Gen2)" : "2.5GHz",
-	       dev->base_addr, bp->pdev->irq);
-	printk(KERN_CONT "node addr %pM\n", dev->dev_addr);
+	netdev_info(dev, "%s (%c%d) PCI-E x%d %s found at mem %lx, IRQ %d, node addr %pM\n",
+		    board_info[ent->driver_data].name,
+		    (CHIP_REV(bp) >> 12) + 'A', (CHIP_METAL(bp) >> 4),
+		    pcie_width, (pcie_speed == 2) ? "5GHz (Gen2)" : "2.5GHz",
+		    dev->base_addr, bp->pdev->irq, dev->dev_addr);
 
 	return 0;
 
@@ -12195,7 +12174,7 @@ static void __devexit bnx2x_remove_one(struct pci_dev *pdev)
 	struct bnx2x *bp;
 
 	if (!dev) {
-		printk(KERN_ERR PFX "BAD net device from bnx2x_init_one\n");
+		pr_err("BAD net device from bnx2x_init_one\n");
 		return;
 	}
 	bp = netdev_priv(dev);
@@ -12228,7 +12207,7 @@ static int bnx2x_suspend(struct pci_dev *pdev, pm_message_t state)
 	struct bnx2x *bp;
 
 	if (!dev) {
-		printk(KERN_ERR PFX "BAD net device from bnx2x_init_one\n");
+		pr_err("BAD net device from bnx2x_init_one\n");
 		return -ENODEV;
 	}
 	bp = netdev_priv(dev);
@@ -12260,7 +12239,7 @@ static int bnx2x_resume(struct pci_dev *pdev)
 	int rc;
 
 	if (!dev) {
-		printk(KERN_ERR PFX "BAD net device from bnx2x_init_one\n");
+		pr_err("BAD net device from bnx2x_init_one\n");
 		return -ENODEV;
 	}
 	bp = netdev_priv(dev);
@@ -12463,17 +12442,17 @@ static int __init bnx2x_init(void)
 {
 	int ret;
 
-	printk(KERN_INFO "%s", version);
+	pr_info("%s", version);
 
 	bnx2x_wq = create_singlethread_workqueue("bnx2x");
 	if (bnx2x_wq == NULL) {
-		printk(KERN_ERR PFX "Cannot create workqueue\n");
+		pr_err("Cannot create workqueue\n");
 		return -ENOMEM;
 	}
 
 	ret = pci_register_driver(&bnx2x_pci_driver);
 	if (ret) {
-		printk(KERN_ERR PFX "Cannot register driver\n");
+		pr_err("Cannot register driver\n");
 		destroy_workqueue(bnx2x_wq);
 	}
 	return ret;
-- 
1.7.0.14.g7e948
