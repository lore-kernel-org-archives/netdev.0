From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 03/41]bnx2x: MSI support
Date: Thu, 12 Feb 2009 20:36:15 +0200
Message-ID: <1234463775.1863.134.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2676 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757800AbZBLSgu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:36:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 03/41]bnx2x: MSI support
Enabling MSI on top of MSI-X and INTA. Also changing the module parameter to
allow choosing INTA or MSI even when MSI-X is available. The default status
block should not be reversed for endianity. Since MSI can issue
re-configuration, the interrupt disable function now requires mmiowb

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    5 +-
 drivers/net/bnx2x_hsi.h  |    6 --
 drivers/net/bnx2x_main.c |  155 ++++++++++++++++++++++++++++++++--------------
 drivers/net/bnx2x_reg.h  |   20 ++++++
 4 files changed, 132 insertions(+), 54 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 7edad1f..153cc95 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -740,6 +740,9 @@ struct bnx2x {
 
 	atomic_t		intr_sem;
 	struct msix_entry	msix_table[MAX_CONTEXT+1];
+#define INT_MODE_INTx			1
+#define INT_MODE_MSI			2
+#define INT_MODE_MSIX			3
 
 	int			tx_ring_size;
 
@@ -794,7 +797,7 @@ struct bnx2x {
 #define NO_WOL_FLAG			8
 #define USING_DAC_FLAG			0x10
 #define USING_MSIX_FLAG			0x20
-#define ASF_ENABLE_FLAG			0x40
+#define USING_MSI_FLAG			0x40
 #define TPA_ENABLE_FLAG			0x80
 #define NO_MCP_FLAG			0x100
 #define BP_NOMCP(bp)			(bp->flags & NO_MCP_FLAG)
diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index c416823..25751a2 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -1224,15 +1224,9 @@ struct host_func_stats {
 struct atten_def_status_block {
 	u32 attn_bits;
 	u32 attn_bits_ack;
-#if defined(__BIG_ENDIAN)
-	u16 attn_bits_index;
-	u8 reserved0;
-	u8 status_block_id;
-#elif defined(__LITTLE_ENDIAN)
 	u8 status_block_id;
 	u8 reserved0;
 	u16 attn_bits_index;
-#endif
 	u32 reserved1;
 };
 
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 60762f7..db8506d 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -77,17 +77,19 @@ static int multi_mode = 1;
 module_param(multi_mode, int, 0);
 
 static int disable_tpa;
-static int use_inta;
 static int poll;
 static int debug;
 static int load_count[3]; /* 0-common, 1-port0, 2-port1 */
 
 module_param(disable_tpa, int, 0);
-module_param(use_inta, int, 0);
+
+static int int_mode;
+module_param(int_mode, int, 0);
+MODULE_PARM_DESC(int_mode, " Force interrupt mode (1 INT#x; 2 MSI)");
+
 module_param(poll, int, 0);
 module_param(debug, int, 0);
 MODULE_PARM_DESC(disable_tpa, "disable the TPA (LRO) feature");
-MODULE_PARM_DESC(use_inta, "use INT#A instead of MSI-X");
 MODULE_PARM_DESC(poll, "use polling (for debug)");
 MODULE_PARM_DESC(debug, "default debug msglevel");
 
@@ -588,34 +590,41 @@ static void bnx2x_int_enable(struct bnx2x *bp)
 	u32 addr = port ? HC_REG_CONFIG_1 : HC_REG_CONFIG_0;
 	u32 val = REG_RD(bp, addr);
 	int msix = (bp->flags & USING_MSIX_FLAG) ? 1 : 0;
+	int msi = (bp->flags & USING_MSI_FLAG) ? 1 : 0;
 
 	if (msix) {
-		val &= ~HC_CONFIG_0_REG_SINGLE_ISR_EN_0;
+		val &= ~(HC_CONFIG_0_REG_SINGLE_ISR_EN_0 |
+			 HC_CONFIG_0_REG_INT_LINE_EN_0);
 		val |= (HC_CONFIG_0_REG_MSI_MSIX_INT_EN_0 |
 			HC_CONFIG_0_REG_ATTN_BIT_EN_0);
+	} else if (msi) {
+		val &= ~HC_CONFIG_0_REG_INT_LINE_EN_0;
+		val |= (HC_CONFIG_0_REG_SINGLE_ISR_EN_0 |
+			HC_CONFIG_0_REG_MSI_MSIX_INT_EN_0 |
+			HC_CONFIG_0_REG_ATTN_BIT_EN_0);
 	} else {
 		val |= (HC_CONFIG_0_REG_SINGLE_ISR_EN_0 |
 			HC_CONFIG_0_REG_MSI_MSIX_INT_EN_0 |
 			HC_CONFIG_0_REG_INT_LINE_EN_0 |
 			HC_CONFIG_0_REG_ATTN_BIT_EN_0);
 
-		DP(NETIF_MSG_INTR, "write %x to HC %d (addr 0x%x)  MSI-X %d\n",
-		   val, port, addr, msix);
+		DP(NETIF_MSG_INTR, "write %x to HC %d (addr 0x%x)\n",
+		   val, port, addr);
 
 		REG_WR(bp, addr, val);
 
 		val &= ~HC_CONFIG_0_REG_MSI_MSIX_INT_EN_0;
 	}
 
-	DP(NETIF_MSG_INTR, "write %x to HC %d (addr 0x%x)  MSI-X %d\n",
-	   val, port, addr, msix);
+	DP(NETIF_MSG_INTR, "write %x to HC %d (addr 0x%x)  mode %s\n",
+	   val, port, addr, (msix ? "MSI-X" : (msi ? "MSI" : "INTx")));
 
 	REG_WR(bp, addr, val);
 
 	if (CHIP_IS_E1H(bp)) {
 		/* init leading/trailing edge */
 		if (IS_E1HMF(bp)) {
-			val = (0xfe0f | (1 << (BP_E1HVN(bp) + 4)));
+			val = (0xee0f | (1 << (BP_E1HVN(bp) + 4)));
 			if (bp->port.pmf)
 				/* enable nig attention */
 				val |= 0x0100;
@@ -641,6 +650,9 @@ static void bnx2x_int_disable(struct bnx2x *bp)
 	DP(NETIF_MSG_INTR, "write %x to HC %d (addr 0x%x)\n",
 	   val, port, addr);
 
+	/* flush all outstanding writes */
+	mmiowb();
+
 	REG_WR(bp, addr, val);
 	if (REG_RD(bp, addr) != val)
 		BNX2X_ERR("BUG! proper val not read from IGU!\n");
@@ -649,7 +661,7 @@ static void bnx2x_int_disable(struct bnx2x *bp)
 static void bnx2x_int_disable_sync(struct bnx2x *bp, int disable_hw)
 {
 	int msix = (bp->flags & USING_MSIX_FLAG) ? 1 : 0;
-	int i;
+	int i, offset;
 
 	/* disable interrupt handling */
 	atomic_inc(&bp->intr_sem);
@@ -659,11 +671,10 @@ static void bnx2x_int_disable_sync(struct bnx2x *bp, int disable_hw)
 
 	/* make sure all ISRs are done */
 	if (msix) {
+		synchronize_irq(bp->msix_table[0].vector);
+		offset = 1;
 		for_each_queue(bp, i)
-			synchronize_irq(bp->msix_table[i].vector);
-
-		/* one more for the Slow Path IRQ */
-		synchronize_irq(bp->msix_table[i].vector);
+			synchronize_irq(bp->msix_table[i + offset].vector);
 	} else
 		synchronize_irq(bp->pdev->irq);
 
@@ -5198,6 +5209,8 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	REG_WR(bp, PXP2_REG_RQ_SRC_ENDIAN_M, 1);
 	REG_WR(bp, PXP2_REG_RQ_CDU_ENDIAN_M, 1);
 	REG_WR(bp, PXP2_REG_RQ_DBG_ENDIAN_M, 1);
+	/* make sure this value is 0 */
+	REG_WR(bp, PXP2_REG_RQ_HC_ENDIAN_M, 0);
 
 /*	REG_WR(bp, PXP2_REG_RD_PBF_SWAP_MODE, 1); */
 	REG_WR(bp, PXP2_REG_RD_QM_SWAP_MODE, 1);
@@ -5648,10 +5661,17 @@ static int bnx2x_init_func(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
 	int func = BP_FUNC(bp);
+	u32 addr, val;
 	int i;
 
 	DP(BNX2X_MSG_MCP, "starting func init  func %x\n", func);
 
+	/* set MSI reconfigure capability */
+	addr = (port ? HC_REG_CONFIG_1 : HC_REG_CONFIG_0);
+	val = REG_RD(bp, addr);
+	val |= HC_CONFIG_0_REG_MSI_ATTN_EN_0;
+	REG_WR(bp, addr, val);
+
 	i = FUNC_ILT_BASE(func);
 
 	bnx2x_ilt_wr(bp, i, bnx2x_sp_mapping(bp, context));
@@ -6053,10 +6073,6 @@ static void bnx2x_free_msix_irqs(struct bnx2x *bp)
 		   "state %x\n", i, bp->msix_table[i + offset].vector,
 		   bnx2x_fp(bp, i, state));
 
-		if (bnx2x_fp(bp, i, state) != BNX2X_FP_STATE_CLOSED)
-			BNX2X_ERR("IRQ of fp #%d being freed while "
-				  "state != closed\n", i);
-
 		free_irq(bp->msix_table[i + offset].vector, &bp->fp[i]);
 	}
 }
@@ -6068,21 +6084,25 @@ static void bnx2x_free_irq(struct bnx2x *bp)
 		pci_disable_msix(bp->pdev);
 		bp->flags &= ~USING_MSIX_FLAG;
 
+	} else if (bp->flags & USING_MSI_FLAG) {
+		free_irq(bp->pdev->irq, bp->dev);
+		pci_disable_msi(bp->pdev);
+		bp->flags &= ~USING_MSI_FLAG;
+
 	} else
 		free_irq(bp->pdev->irq, bp->dev);
 }
 
 static int bnx2x_enable_msix(struct bnx2x *bp)
 {
-	int i, rc, offset;
+	int i, rc, offset = 1;
+	int igu_vec = 0;
 
-	bp->msix_table[0].entry = 0;
-	offset = 1;
-	DP(NETIF_MSG_IFUP, "msix_table[0].entry = 0 (slowpath)\n");
+	bp->msix_table[0].entry = igu_vec;
+	DP(NETIF_MSG_IFUP, "msix_table[0].entry = %d (slowpath)\n", igu_vec);
 
 	for_each_queue(bp, i) {
-		int igu_vec = offset + i + BP_L_ID(bp);
-
+		igu_vec = BP_L_ID(bp) + offset + i;
 		bp->msix_table[i + offset].entry = igu_vec;
 		DP(NETIF_MSG_IFUP, "msix_table[%d].entry = %d "
 		   "(fastpath #%u)\n", i + offset, igu_vec, i);
@@ -6091,9 +6111,10 @@ static int bnx2x_enable_msix(struct bnx2x *bp)
 	rc = pci_enable_msix(bp->pdev, &bp->msix_table[0],
 			     BNX2X_NUM_QUEUES(bp) + offset);
 	if (rc) {
-		DP(NETIF_MSG_IFUP, "MSI-X is not attainable\n");
-		return -1;
+		DP(NETIF_MSG_IFUP, "MSI-X is not attainable  rc %d\n", rc);
+		return rc;
 	}
+
 	bp->flags |= USING_MSIX_FLAG;
 
 	return 0;
@@ -6140,11 +6161,31 @@ static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 	return 0;
 }
 
+static int bnx2x_enable_msi(struct bnx2x *bp)
+{
+	int rc;
+
+	rc = pci_enable_msi(bp->pdev);
+	if (rc) {
+		DP(NETIF_MSG_IFUP, "MSI is not attainable\n");
+		return -1;
+	}
+	bp->flags |= USING_MSI_FLAG;
+
+	return 0;
+}
+
 static int bnx2x_req_irq(struct bnx2x *bp)
 {
+	unsigned long flags;
 	int rc;
 
-	rc = request_irq(bp->pdev->irq, bnx2x_interrupt, IRQF_SHARED,
+	if (bp->flags & USING_MSI_FLAG)
+		flags = 0;
+	else
+		flags = IRQF_SHARED;
+
+	rc = request_irq(bp->pdev->irq, bnx2x_interrupt, flags,
 			 bp->dev->name, bp->dev);
 	if (!rc)
 		bnx2x_fp(bp, 0, state) = BNX2X_FP_STATE_IRQ;
@@ -6365,28 +6406,23 @@ static int bnx2x_setup_multi(struct bnx2x *bp, int index)
 }
 
 static int bnx2x_poll(struct napi_struct *napi, int budget);
-static void bnx2x_set_rx_mode(struct net_device *dev);
 
-/* must be called with rtnl_lock */
-static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
+static void bnx2x_set_int_mode(struct bnx2x *bp)
 {
-	u32 load_code;
-	int i, rc = 0;
 	int num_queues;
-#ifdef BNX2X_STOP_ON_ERROR
-	if (unlikely(bp->panic))
-		return -EPERM;
-#endif
-
-	bp->state = BNX2X_STATE_OPENING_WAIT4_LOAD;
 
-	if (use_inta) {
+	switch (int_mode) {
+	case INT_MODE_INTx:
+	case INT_MODE_MSI:
 		num_queues = 1;
 		bp->num_rx_queues = num_queues;
 		bp->num_tx_queues = num_queues;
 		DP(NETIF_MSG_IFUP,
 		   "set number of queues to %d\n", num_queues);
-	} else {
+		break;
+
+	case INT_MODE_MSIX:
+	default:
 		if (bp->multi_mode == ETH_RSS_MODE_REGULAR)
 			num_queues = min_t(u32, num_online_cpus(),
 					   BNX2X_MAX_QUEUES(bp));
@@ -6401,8 +6437,7 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		 * so try to enable MSI-X with the requested number of fp's
 		 * and fallback to MSI or legacy INTx with one fp
 		 */
-		rc = bnx2x_enable_msix(bp);
-		if (rc) {
+		if (bnx2x_enable_msix(bp)) {
 			/* failed to enable MSI-X */
 			num_queues = 1;
 			bp->num_rx_queues = num_queues;
@@ -6412,8 +6447,27 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 					  "enable MSI-X  set number of "
 					  "queues to %d\n", num_queues);
 		}
+		break;
 	}
 	bp->dev->real_num_tx_queues = bp->num_tx_queues;
+}
+
+static void bnx2x_set_rx_mode(struct net_device *dev);
+
+/* must be called with rtnl_lock */
+static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
+{
+	u32 load_code;
+	int i, rc = 0;
+#ifdef BNX2X_STOP_ON_ERROR
+	DP(NETIF_MSG_IFUP, "enter  load_mode %d\n", load_mode);
+	if (unlikely(bp->panic))
+		return -EPERM;
+#endif
+
+	bp->state = BNX2X_STATE_OPENING_WAIT4_LOAD;
+
+	bnx2x_set_int_mode(bp);
 
 	if (bnx2x_alloc_mem(bp))
 		return -ENOMEM;
@@ -6445,14 +6499,22 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 			pci_disable_msix(bp->pdev);
 			goto load_error1;
 		}
-		printk(KERN_INFO PFX "%s: using MSI-X\n", bp->dev->name);
 	} else {
+		if ((rc != -ENOMEM) && (int_mode != INT_MODE_INTx))
+			bnx2x_enable_msi(bp);
 		bnx2x_ack_int(bp);
 		rc = bnx2x_req_irq(bp);
 		if (rc) {
 			BNX2X_ERR("IRQ request failed  rc %d, aborting\n", rc);
+			if (bp->flags & USING_MSI_FLAG)
+				pci_disable_msi(bp->pdev);
 			goto load_error1;
 		}
+		if (bp->flags & USING_MSI_FLAG) {
+			bp->dev->irq = bp->pdev->irq;
+			printk(KERN_INFO PFX "%s: using MSI  IRQ %d\n",
+			       bp->dev->name, bp->pdev->irq);
+		}
 	}
 
 	/* Send LOAD_REQUEST command to MCP
@@ -6689,8 +6751,6 @@ static void bnx2x_reset_func(struct bnx2x *bp)
 	REG_WR(bp, HC_REG_LEADING_EDGE_0 + port*8, 0);
 	REG_WR(bp, HC_REG_TRAILING_EDGE_0 + port*8, 0);
 
-	REG_WR(bp, HC_REG_CONFIG_0 + port*4, 0x1000);
-
 	/* Clear ILT */
 	base = FUNC_ILT_BASE(func);
 	for (i = base; i < base + ILT_PER_FUNC; i++)
@@ -7636,9 +7696,10 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 		       "MCP disabled, must load devices in order!\n");
 
 	/* Set multi queue mode */
-	if ((multi_mode != ETH_RSS_MODE_DISABLED) && (!use_inta)) {
+	if ((multi_mode != ETH_RSS_MODE_DISABLED) &&
+	    ((int_mode == INT_MODE_INTx) || (int_mode == INT_MODE_MSI))) {
 		printk(KERN_ERR PFX
-		      "Multi disabled since INTA is requested\n");
+		      "Multi disabled since int_mode requested is not MSI-X\n");
 		multi_mode = ETH_RSS_MODE_DISABLED;
 	}
 	bp->multi_mode = multi_mode;
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index fc957fa..0be77c5 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -745,6 +745,7 @@
 #define DORQ_REG_SHRT_CMHEAD					 0x170054
 #define HC_CONFIG_0_REG_ATTN_BIT_EN_0				 (0x1<<4)
 #define HC_CONFIG_0_REG_INT_LINE_EN_0				 (0x1<<3)
+#define HC_CONFIG_0_REG_MSI_ATTN_EN_0				 (0x1<<7)
 #define HC_CONFIG_0_REG_MSI_MSIX_INT_EN_0			 (0x1<<2)
 #define HC_CONFIG_0_REG_SINGLE_ISR_EN_0 			 (0x1<<1)
 #define HC_REG_AGG_INT_0					 0x108050
@@ -5359,9 +5360,28 @@
 #define PCICFG_PM_CSR_STATE			(0x3<<0)
 #define PCICFG_PM_CSR_PME_ENABLE		(1<<8)
 #define PCICFG_PM_CSR_PME_STATUS		(1<<15)
+#define PCICFG_MSI_CAP_ID				0x58
+#define PCICFG_MSI_CONTROL_ENABLE		(0x1<<16)
+#define PCICFG_MSI_CONTROL_MCAP 		(0x7<<17)
+#define PCICFG_MSI_CONTROL_MENA 		(0x7<<20)
+#define PCICFG_MSI_CONTROL_64_BIT_ADDR_CAP	(0x1<<23)
+#define PCICFG_MSI_CONTROL_MSI_PVMASK_CAPABLE	(0x1<<24)
 #define PCICFG_GRC_ADDRESS				0x78
 #define PCICFG_GRC_DATA 				0x80
+#define PCICFG_MSIX_CAP_ID				0xa0
+#define PCICFG_MSIX_CONTROL_TABLE_SIZE		(0x7ff<<16)
+#define PCICFG_MSIX_CONTROL_RESERVED		(0x7<<27)
+#define PCICFG_MSIX_CONTROL_FUNC_MASK		(0x1<<30)
+#define PCICFG_MSIX_CONTROL_MSIX_ENABLE 	(0x1<<31)
+
 #define PCICFG_DEVICE_CONTROL				0xb4
+#define PCICFG_DEVICE_STATUS				0xb6
+#define PCICFG_DEVICE_STATUS_CORR_ERR_DET	(1<<0)
+#define PCICFG_DEVICE_STATUS_NON_FATAL_ERR_DET	(1<<1)
+#define PCICFG_DEVICE_STATUS_FATAL_ERR_DET	(1<<2)
+#define PCICFG_DEVICE_STATUS_UNSUP_REQ_DET	(1<<3)
+#define PCICFG_DEVICE_STATUS_AUX_PWR_DET	(1<<4)
+#define PCICFG_DEVICE_STATUS_NO_PEND		(1<<5)
 #define PCICFG_LINK_CONTROL				0xbc
 
 
-- 
1.5.4.3




