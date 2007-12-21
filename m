From: dhananjay@netxen.com
Subject: [patch 3/6] netxen: improve MSI interrupt handling
Date: Thu, 20 Dec 2007 18:36:59 -0800
Message-ID: <20071221024308.680157171@netxen.com>
References: <20071221023656.409657310@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:36120 "EHLO dut46.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754704AbXLUCvQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 21:51:16 -0500
Content-Disposition: inline; filename=msifix.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent netxen firmware has new scheme of generating MSI interrupts, it
raises interrupt and blocks itself, waiting for driver to unmask. This
reduces chance of spurious interrupts.

The driver will be able to deal with older firmware as well.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Index: netdev-2.6/drivers/net/netxen/netxen_nic_hw.c
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic_hw.c
+++ netdev-2.6/drivers/net/netxen/netxen_nic_hw.c
@@ -398,6 +398,8 @@ int netxen_nic_hw_resources(struct netxe
 		NETXEN_CRB_NORMALIZE(adapter, CRB_NIC_CAPABILITIES_FW));
 	printk(KERN_NOTICE "%s: FW capabilities:0x%x\n", netxen_nic_driver_name,
 			adapter->intr_scheme);
+	adapter->msi_mode = readl(
+		NETXEN_CRB_NORMALIZE(adapter, CRB_NIC_MSI_MODE_FW));
 	DPRINTK(INFO, "Receive Peg ready too. starting stuff\n");
 
 	addr = netxen_alloc(adapter->ahw.pdev,
Index: netdev-2.6/drivers/net/netxen/netxen_nic_main.c
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic_main.c
+++ netdev-2.6/drivers/net/netxen/netxen_nic_main.c
@@ -149,33 +149,33 @@ static void netxen_nic_update_cmd_consum
 
 #define	ADAPTER_LIST_SIZE 12
 
+static uint32_t msi_tgt_status[4] = {
+	ISR_INT_TARGET_STATUS, ISR_INT_TARGET_STATUS_F1,
+	ISR_INT_TARGET_STATUS_F2, ISR_INT_TARGET_STATUS_F3
+};
+
+static uint32_t sw_int_mask[4] = {
+	CRB_SW_INT_MASK_0, CRB_SW_INT_MASK_1,
+	CRB_SW_INT_MASK_2, CRB_SW_INT_MASK_3
+};
+
 static void netxen_nic_disable_int(struct netxen_adapter *adapter)
 {
-	uint32_t	mask = 0x7ff;
+	u32 mask;
 	int retries = 32;
+	int port = adapter->portnum;
+	int pci_fn = adapter->ahw.pci_func;
 
 	DPRINTK(1, INFO, "Entered ISR Disable \n");
 
-	switch (adapter->portnum) {
-	case 0:
-		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_0));
-		break;
-	case 1:
-		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_1));
-		break;
-	case 2:
-		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_2));
-		break;
-	case 3:
-		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_3));
-		break;
+	if (adapter->msi_mode != MSI_MODE_MULTIFUNC) {
+		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, sw_int_mask[port]));
 	}
 
 	if (adapter->intr_scheme != -1 &&
 	    adapter->intr_scheme != INTR_SCHEME_PERPORT)
-		writel(mask,PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK));
+		writel(0x7ff,PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK));
 
-	/* Window = 0 or 1 */
 	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
 		do {
 			writel(0xffffffff,
@@ -190,6 +190,11 @@ static void netxen_nic_disable_int(struc
 			printk(KERN_NOTICE "%s: Failed to disable interrupt completely\n",
 					netxen_nic_driver_name);
 		}
+	} else {
+		if (adapter->msi_mode == MSI_MODE_MULTIFUNC) {
+			writel(0xffffffff, PCI_OFFSET_SECOND_RANGE(adapter,
+						msi_tgt_status[pci_fn]));
+		}
 	}
 
 	DPRINTK(1, INFO, "Done with Disable Int\n");
@@ -198,6 +203,7 @@ static void netxen_nic_disable_int(struc
 static void netxen_nic_enable_int(struct netxen_adapter *adapter)
 {
 	u32 mask;
+	int port = adapter->portnum;
 
 	DPRINTK(1, INFO, "Entered ISR Enable \n");
 
@@ -218,20 +224,7 @@ static void netxen_nic_enable_int(struct
 		writel(mask, PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK));
 	}
 
-	switch (adapter->portnum) {
-	case 0:
-		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_0));
-		break;
-	case 1:
-		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_1));
-		break;
-	case 2:
-		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_2));
-		break;
-	case 3:
-		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_3));
-		break;
-	}
+	writel(0x1, NETXEN_CRB_NORMALIZE(adapter, sw_int_mask[port]));
 
 	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
 		mask = 0xbff;
@@ -401,6 +394,7 @@ netxen_nic_probe(struct pci_dev *pdev, c
 
 	/* this will be read from FW later */
 	adapter->intr_scheme = -1;
+	adapter->msi_mode = -1;
 
 	/* This will be reset for mezz cards  */
 	adapter->portnum = pci_func_id;
Index: netdev-2.6/drivers/net/netxen/netxen_nic.h
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic.h
+++ netdev-2.6/drivers/net/netxen/netxen_nic.h
@@ -939,6 +939,7 @@ struct netxen_adapter {
 	struct pci_dev *ctx_desc_pdev;
 	dma_addr_t ctx_desc_phys_addr;
 	int intr_scheme;
+	int msi_mode;
 	int (*enable_phy_interrupts) (struct netxen_adapter *);
 	int (*disable_phy_interrupts) (struct netxen_adapter *);
 	void (*handle_phy_intr) (struct netxen_adapter *);
Index: netdev-2.6/drivers/net/netxen/netxen_nic_phan_reg.h
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic_phan_reg.h
+++ netdev-2.6/drivers/net/netxen/netxen_nic_phan_reg.h
@@ -126,8 +126,11 @@
  */
 #define CRB_NIC_CAPABILITIES_HOST	NETXEN_NIC_REG(0x1a8)
 #define CRB_NIC_CAPABILITIES_FW	  	NETXEN_NIC_REG(0x1dc)
+#define CRB_NIC_MSI_MODE_HOST		NETXEN_NIC_REG(0x270)
+#define CRB_NIC_MSI_MODE_FW	  		NETXEN_NIC_REG(0x274)
 
 #define INTR_SCHEME_PERPORT	      	0x1
+#define MSI_MODE_MULTIFUNC	      	0x1
 
 /* used for ethtool tests */
 #define CRB_SCRATCHPAD_TEST	    NETXEN_NIC_REG(0x280)
Index: netdev-2.6/drivers/net/netxen/netxen_nic_hdr.h
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic_hdr.h
+++ netdev-2.6/drivers/net/netxen/netxen_nic_hdr.h
@@ -456,6 +456,12 @@ enum {
 #define ISR_INT_MASK_SLOW	(NETXEN_PCIX_PS_REG(PCIX_INT_MASK))
 #define ISR_INT_TARGET_STATUS	(NETXEN_PCIX_PS_REG(PCIX_TARGET_STATUS))
 #define ISR_INT_TARGET_MASK	(NETXEN_PCIX_PS_REG(PCIX_TARGET_MASK))
+#define ISR_INT_TARGET_STATUS_F1   (NETXEN_PCIX_PS_REG(PCIX_TARGET_STATUS_F1))
+#define ISR_INT_TARGET_MASK_F1     (NETXEN_PCIX_PS_REG(PCIX_TARGET_MASK_F1))
+#define ISR_INT_TARGET_STATUS_F2   (NETXEN_PCIX_PS_REG(PCIX_TARGET_STATUS_F2))
+#define ISR_INT_TARGET_MASK_F2     (NETXEN_PCIX_PS_REG(PCIX_TARGET_MASK_F2))
+#define ISR_INT_TARGET_STATUS_F3   (NETXEN_PCIX_PS_REG(PCIX_TARGET_STATUS_F3))
+#define ISR_INT_TARGET_MASK_F3     (NETXEN_PCIX_PS_REG(PCIX_TARGET_MASK_F3))
 
 #define NETXEN_PCI_MAPSIZE	128
 #define NETXEN_PCI_DDR_NET	(0x00000000UL)
@@ -662,6 +668,12 @@ enum {
 
 #define PCIX_TARGET_STATUS	(0x10118)
 #define PCIX_TARGET_MASK	(0x10128)
+#define PCIX_TARGET_STATUS_F1 (0x10160)
+#define PCIX_TARGET_MASK_F1   (0x10170)
+#define PCIX_TARGET_STATUS_F2 (0x10164)
+#define PCIX_TARGET_MASK_F2   (0x10174)
+#define PCIX_TARGET_STATUS_F3 (0x10168)
+#define PCIX_TARGET_MASK_F3   (0x10178)
 
 #define PCIX_MSI_F0		(0x13000)
 #define PCIX_MSI_F1		(0x13004)
Index: netdev-2.6/drivers/net/netxen/netxen_nic_init.c
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic_init.c
+++ netdev-2.6/drivers/net/netxen/netxen_nic_init.c
@@ -145,6 +145,8 @@ int netxen_init_firmware(struct netxen_a
 	/* Window 1 call */
 	writel(INTR_SCHEME_PERPORT,
 	       NETXEN_CRB_NORMALIZE(adapter, CRB_NIC_CAPABILITIES_HOST));
+	writel(MSI_MODE_MULTIFUNC,
+	       NETXEN_CRB_NORMALIZE(adapter, CRB_NIC_MSI_MODE_HOST));
 	writel(MPORT_MULTI_FUNCTION_MODE,
 	       NETXEN_CRB_NORMALIZE(adapter, CRB_MPORT_MODE));
 	writel(PHAN_INITIALIZE_ACK,

-- 
