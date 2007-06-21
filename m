From: Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 2/2] NetXen: Make use of per port interrupt mask scheme
Date: Thu, 21 Jun 2007 10:07:00 -0700
Message-ID: <200706211707.l5LH70Gs005811@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, netxenproj@linsyssoft.com,
	rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:4512 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753996AbXFURHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 13:07:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Make use of per port interrupt scheme.
This patch makes the driver inform the firmware that it can support the
per port interrupt mask scheme. The driver too needs to check whether
the firmware also supports the per port interrupt scheme. If yes, 
then interrupt for each port is enabled/disabled instead of disabling 
for the entire card as it was being done till now.

Signed-off-by: Milan Bag <mbag@netxen.com>
Signed-off-by: Wen Xiong <wenxiong@us.ibm.com>
Signed-off-by: Mithlesh Thukral <mithlesh@netxen.com>

---

 drivers/net/netxen/netxen_nic.h          |  104 +++++++++++++++++----
 drivers/net/netxen/netxen_nic_hw.c       |    5 -
 drivers/net/netxen/netxen_nic_init.c     |    2 
 drivers/net/netxen/netxen_nic_main.c     |   28 +++--
 drivers/net/netxen/netxen_nic_phan_reg.h |   14 ++
 5 files changed, 121 insertions(+), 32 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 91f25e0..62aeab9 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -937,6 +937,7 @@ struct netxen_adapter {
 	struct netxen_ring_ctx *ctx_desc;
 	struct pci_dev *ctx_desc_pdev;
 	dma_addr_t ctx_desc_phys_addr;
+	int intr_scheme;
 	int (*enable_phy_interrupts) (struct netxen_adapter *);
 	int (*disable_phy_interrupts) (struct netxen_adapter *);
 	void (*handle_phy_intr) (struct netxen_adapter *);
@@ -1080,37 +1081,102 @@ struct net_device_stats *netxen_nic_get_
 
 static inline void netxen_nic_disable_int(struct netxen_adapter *adapter)
 {
-	/*
-	 * ISR_INT_MASK: Can be read from window 0 or 1.
-	 */
-	writel(0x7ff, PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK));
+	uint32_t	mask = 0x7ff;
+	int count = 0;
+
+	DPRINTK(1,INFO,"Entered ISR Disable \n");
+
+	switch(adapter->portnum) {
+		case 0:
+			writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_0));
+			break;
+		case 1:
+			writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_1));
+			break;
+		case 2:
+			writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_2));
+			break;
+		case 3:
+			writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_3));
+			break;
+	}
+
+	if (adapter->intr_scheme != -1 &&
+		adapter->intr_scheme != INTR_SCHEME_PERPORT) {
+		writel(mask,
+			(void *)(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK)));
+	}
 
+	/* Window = 0 or 1 */
+	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
+		do {
+			writel(0xffffffff, (void *)
+				(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_TARGET_STATUS)));
+			mask = readl((void *)
+					(pci_base_offset(adapter, ISR_INT_VECTOR)));
+		} while (((mask & 0x80) != 0) && (++count < 32));
+
+		if ((mask & 0x80) != 0) {
+			printk(KERN_NOTICE "Could not disable interrupt completely\n");
+		}
+	}
+
+	DPRINTK(1,INFO,"Done with Disable Int\n");
+
+	return;
 }
 
 static inline void netxen_nic_enable_int(struct netxen_adapter *adapter)
 {
 	u32 mask;
 
-	switch (adapter->ahw.board_type) {
-	case NETXEN_NIC_GBE:
-		mask = 0x77b;
-		break;
-	case NETXEN_NIC_XGBE:
-		mask = 0x77f;
-		break;
-	default:
-		mask = 0x7ff;
-		break;
-	}
+	DPRINTK(1, INFO, "Entered ISR Enable \n");
+
+	if (adapter->intr_scheme != -1 &&
+		adapter->intr_scheme != INTR_SCHEME_PERPORT) {
+		switch (adapter->ahw.board_type) {
+			case NETXEN_NIC_GBE:
+				mask  =  0x77b;
+				break;
+			case NETXEN_NIC_XGBE:
+				mask  =  0x77f;
+				break;
+			default:
+				mask  =  0x7ff;
+				break;
+		}
 
-	writel(mask, PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK));
+		writel(mask,
+			(void *)(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK)));
+	}
+	switch (adapter->portnum) {
+		case 0:
+			writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_0));
+			break;
+		case 1:
+			writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_1));
+			break;
+		case 2:
+			writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_2));
+			break;
+		case 3:
+			writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_3));
+			break;
+	}
 
 	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
 		mask = 0xbff;
-		writel(0X0, NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
-		writel(mask, PCI_OFFSET_SECOND_RANGE(adapter,
-						     ISR_INT_TARGET_MASK));
+		if (adapter->intr_scheme != -1 &&
+			adapter->intr_scheme != INTR_SCHEME_PERPORT) {
+			writel(0X0, NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
+		}
+		writel(mask,
+			(void *)(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_TARGET_MASK)));
 	}
+
+	DPRINTK(1,INFO,"Done with enable Int\n");
+
+	return;
 }
 
 /*
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index c012764..4e958c9 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -392,7 +392,10 @@ int netxen_nic_hw_resources(struct netxe
 			return err;
 		}
 	}
-	DPRINTK(INFO, "Recieve Peg ready too. starting stuff\n");
+	adapter->intr_scheme = readl(
+		NETXEN_CRB_NORMALIZE(adapter, CRB_NIC_CAPABILITIES_FW));
+	printk(KERN_NOTICE "%s: FW capabilities:0x%x\n", __FUNCTION__, adapter->intr_scheme);
+	DPRINTK(INFO, "Receive Peg ready too. starting stuff\n");
 
 	addr = netxen_alloc(adapter->ahw.pdev,
 			    sizeof(struct netxen_ring_ctx) +
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index bb23f4c..15f6dc5 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -139,6 +139,8 @@ int netxen_init_firmware(struct netxen_a
 		return err;
 	}
 	/* Window 1 call */
+	writel(INTR_SCHEME_PERPORT,
+	       NETXEN_CRB_NORMALIZE(adapter, CRB_NIC_CAPABILITIES_HOST));
 	writel(MPORT_MULTI_FUNCTION_MODE,
 	       NETXEN_CRB_NORMALIZE(adapter, CRB_MPORT_MODE));
 	writel(PHAN_INITIALIZE_ACK,
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index e68356b..44a6fcd 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -308,7 +308,13 @@ netxen_nic_probe(struct pci_dev *pdev, c
 
 	adapter->netdev  = netdev;
 	adapter->pdev    = pdev;
+
+	/* this will be read from FW later */
+	adapter->intr_scheme = -1;
+
+	/* This will be reset for mezz cards  */
 	adapter->portnum = pci_func_id;
+	adapter->status   &= ~NETXEN_NETDEV_STATUS;
 
 	netdev->open		   = netxen_nic_open;
 	netdev->stop		   = netxen_nic_close;
@@ -1102,28 +1108,26 @@ static int
 netxen_handle_int(struct netxen_adapter *adapter, struct net_device *netdev)
 {
 	u32 ret = 0;
+	u32 our_int = 0;
 
 	DPRINTK(INFO, "Entered handle ISR\n");
 	adapter->stats.ints++;
 
 	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
-		int count = 0;
-		u32 mask;
-		u32 our_int = 0;
 		our_int = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
 		/* not our interrupt */
 		if ((our_int & (0x80 << adapter->portnum)) == 0)
 			return ret;
-		netxen_nic_disable_int(adapter);
-		/* Window = 0 or 1 */
-		do {
-			writel(0xffffffff, PCI_OFFSET_SECOND_RANGE(adapter,
-						ISR_INT_TARGET_STATUS));
-			mask = readl(pci_base_offset(adapter, ISR_INT_VECTOR));
-		} while (((mask & 0x80) != 0) && (++count < 32));
-		if ((mask & 0x80) != 0)
-			printk("Could not disable interrupt completely\n");
+	}
 
+	netxen_nic_disable_int(adapter);
+
+	if (adapter->intr_scheme == INTR_SCHEME_PERPORT) {
+		/* claim interrupt */
+		if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
+			writel(our_int & ~((u32)(0x80 << adapter->portnum)),
+			NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
+		}
 	}
 
 	if (netxen_nic_rx_has_work(adapter) || netxen_nic_tx_has_work(adapter)) {
diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
index 9457fc7..10fe6fa 100644
--- a/drivers/net/netxen/netxen_nic_phan_reg.h
+++ b/drivers/net/netxen/netxen_nic_phan_reg.h
@@ -114,6 +114,20 @@ #define CRB_V2P_2		    NETXEN_NIC_REG(0x
 #define CRB_V2P_3		    NETXEN_NIC_REG(0x29c)
 #define CRB_V2P(port)		    (CRB_V2P_0+((port)*4))
 #define CRB_DRIVER_VERSION	    NETXEN_NIC_REG(0x2a0)
+/* sw int status/mask registers */
+#define CRB_SW_INT_MASK_0	   NETXEN_NIC_REG(0x1d8)
+#define CRB_SW_INT_MASK_1	   NETXEN_NIC_REG(0x1e0)
+#define CRB_SW_INT_MASK_2	   NETXEN_NIC_REG(0x1e4)
+#define CRB_SW_INT_MASK_3	   NETXEN_NIC_REG(0x1e8)
+
+/*
+ * capabilities register, can be used to selectively enable/disable features
+ * for backward compability
+ */
+#define CRB_NIC_CAPABILITIES_HOST	NETXEN_NIC_REG(0x1a8)
+#define CRB_NIC_CAPABILITIES_FW	  	NETXEN_NIC_REG(0x1dc)
+
+#define INTR_SCHEME_PERPORT	      	0x1
 
 /* used for ethtool tests */
 #define CRB_SCRATCHPAD_TEST	    NETXEN_NIC_REG(0x280)
