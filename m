From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 3/7] netxen: fix legacy interrupts
Date: Fri,  1 Aug 2008 03:14:57 -0700
Message-ID: <1217585701-13958-4-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:42822 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753003AbYHAKPF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2008 06:15:05 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix legacy interrupt mode for NX3031 chips, read pci interrupt state
in hardware to guard against spurious interrupt.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_hdr.h  |    3 ++
 drivers/net/netxen/netxen_nic_main.c |   48 ++++++++++++++++++++++------------
 2 files changed, 34 insertions(+), 17 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index ccf6d70..e8e8d73 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -843,9 +843,11 @@ enum {
 
 #define PCIE_SETUP_FUNCTION	(0x12040)
 #define PCIE_SETUP_FUNCTION2	(0x12048)
+#define PCIE_MISCCFG_RC         (0x1206c)
 #define PCIE_TGT_SPLIT_CHICKEN	(0x12080)
 #define PCIE_CHICKEN3		(0x120c8)
 
+#define ISR_INT_STATE_REG       (NETXEN_PCIX_PS_REG(PCIE_MISCCFG_RC))
 #define PCIE_MAX_MASTER_SPLIT	(0x14048)
 
 #define NETXEN_PORT_MODE_NONE		0
@@ -861,6 +863,7 @@ enum {
 #define NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL		(0x14)
 
 #define	ISR_MSI_INT_TRIGGER(FUNC) (NETXEN_PCIX_PS_REG(PCIX_MSI_F(FUNC)))
+#define ISR_LEGACY_INT_TRIGGERED(VAL)	(((VAL) & 0x300) == 0x200)
 
 /*
  * PCI Interrupt Vector Values.
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 153b391..320d010 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -166,7 +166,8 @@ static void netxen_nic_disable_int(struct netxen_adapter *adapter)
 	if (!NETXEN_IS_MSI_FAMILY(adapter)) {
 		do {
 			adapter->pci_write_immediate(adapter,
-					ISR_INT_TARGET_STATUS, 0xffffffff);
+					adapter->legacy_intr.tgt_status_reg,
+					0xffffffff);
 			mask = adapter->pci_read_immediate(adapter,
 					ISR_INT_VECTOR);
 			if (!(mask & 0x80))
@@ -175,7 +176,7 @@ static void netxen_nic_disable_int(struct netxen_adapter *adapter)
 		} while (--retries);
 
 		if (!retries) {
-			printk(KERN_NOTICE "%s: Failed to disable interrupt completely\n",
+			printk(KERN_NOTICE "%s: Failed to disable interrupt\n",
 					netxen_nic_driver_name);
 		}
 	} else {
@@ -190,8 +191,6 @@ static void netxen_nic_enable_int(struct netxen_adapter *adapter)
 {
 	u32 mask;
 
-	DPRINTK(1, INFO, "Entered ISR Enable \n");
-
 	if (adapter->intr_scheme != -1 &&
 		adapter->intr_scheme != INTR_SCHEME_PERPORT) {
 		switch (adapter->ahw.board_type) {
@@ -213,16 +212,13 @@ static void netxen_nic_enable_int(struct netxen_adapter *adapter)
 
 	if (!NETXEN_IS_MSI_FAMILY(adapter)) {
 		mask = 0xbff;
-		if (adapter->intr_scheme != -1 &&
-			adapter->intr_scheme != INTR_SCHEME_PERPORT) {
+		if (adapter->intr_scheme == INTR_SCHEME_PERPORT)
+			adapter->pci_write_immediate(adapter,
+				adapter->legacy_intr.tgt_mask_reg, mask);
+		else
 			adapter->pci_write_normalize(adapter,
 					CRB_INT_VECTOR, 0);
-		}
-		adapter->pci_write_immediate(adapter,
-				ISR_INT_TARGET_MASK, mask);
 	}
-
-	DPRINTK(1, INFO, "Done with enable Int\n");
 }
 
 static int nx_set_dma_mask(struct netxen_adapter *adapter, uint8_t revision_id)
@@ -1538,15 +1534,33 @@ static irqreturn_t netxen_intr(int irq, void *data)
 	struct netxen_adapter *adapter = data;
 	u32 our_int = 0;
 
-	our_int = adapter->pci_read_normalize(adapter, CRB_INT_VECTOR);
-	/* not our interrupt */
-	if ((our_int & (0x80 << adapter->portnum)) == 0)
+	u32 status = 0;
+
+	status = adapter->pci_read_immediate(adapter, ISR_INT_VECTOR);
+
+	if (!(status & adapter->legacy_intr.int_vec_bit))
 		return IRQ_NONE;
 
-	if (adapter->intr_scheme == INTR_SCHEME_PERPORT) {
-		/* claim interrupt */
-		adapter->pci_write_normalize(adapter, CRB_INT_VECTOR,
+	if (adapter->ahw.revision_id >= NX_P3_B1) {
+		/* check interrupt state machine, to be sure */
+		status = adapter->pci_read_immediate(adapter,
+				ISR_INT_STATE_REG);
+		if (!ISR_LEGACY_INT_TRIGGERED(status))
+			return IRQ_NONE;
+
+	} else if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
+
+		our_int = adapter->pci_read_normalize(adapter, CRB_INT_VECTOR);
+		/* not our interrupt */
+		if ((our_int & (0x80 << adapter->portnum)) == 0)
+			return IRQ_NONE;
+
+		if (adapter->intr_scheme == INTR_SCHEME_PERPORT) {
+			/* claim interrupt */
+			adapter->pci_write_normalize(adapter,
+				CRB_INT_VECTOR,
 				our_int & ~((u32)(0x80 << adapter->portnum)));
+		}
 	}
 
 	netxen_handle_int(adapter);
-- 
1.5.4.3

