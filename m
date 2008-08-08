From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 5/7] netxen: cleanup interrupt code
Date: Fri,  8 Aug 2008 00:08:43 -0700
Message-ID: <1218179325-32493-6-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:60718 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752235AbYHHHIr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 03:08:47 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark interrupt scheme in very old firmware incompatible. Interrupt mask
and status registers are per pci function / port.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |  123 +++++++++++-----------------------
 1 files changed, 40 insertions(+), 83 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index f69807c..3c424a8 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -149,76 +149,18 @@ static uint32_t msi_tgt_status[8] = {
 
 static struct netxen_legacy_intr_set legacy_intr[] = NX_LEGACY_INTR_CONFIG;
 
-static void netxen_nic_disable_int(struct netxen_adapter *adapter)
+static inline void netxen_nic_disable_int(struct netxen_adapter *adapter)
 {
-	u32 mask = 0x7ff;
-	int retries = 32;
-	int pci_fn = adapter->ahw.pci_func;
-
-	if (adapter->msi_mode != MSI_MODE_MULTIFUNC)
-		adapter->pci_write_normalize(adapter,
-				adapter->crb_intr_mask, 0);
-
-	if (adapter->intr_scheme != -1 &&
-	    adapter->intr_scheme != INTR_SCHEME_PERPORT)
-		adapter->pci_write_immediate(adapter, ISR_INT_MASK, mask);
-
-	if (!NETXEN_IS_MSI_FAMILY(adapter)) {
-		do {
-			adapter->pci_write_immediate(adapter,
-					adapter->legacy_intr.tgt_status_reg,
-					0xffffffff);
-			mask = adapter->pci_read_immediate(adapter,
-					ISR_INT_VECTOR);
-			if (!(mask & 0x80))
-				break;
-			udelay(10);
-		} while (--retries);
-
-		if (!retries) {
-			printk(KERN_NOTICE "%s: Failed to disable interrupt\n",
-					netxen_nic_driver_name);
-		}
-	} else {
-		if (adapter->msi_mode == MSI_MODE_MULTIFUNC) {
-			adapter->pci_write_immediate(adapter,
-					msi_tgt_status[pci_fn], 0xffffffff);
-		}
-	}
+	adapter->pci_write_normalize(adapter, adapter->crb_intr_mask, 0);
 }
 
-static void netxen_nic_enable_int(struct netxen_adapter *adapter)
+static inline void netxen_nic_enable_int(struct netxen_adapter *adapter)
 {
-	u32 mask;
-
-	if (adapter->intr_scheme != -1 &&
-		adapter->intr_scheme != INTR_SCHEME_PERPORT) {
-		switch (adapter->ahw.board_type) {
-		case NETXEN_NIC_GBE:
-			mask  =  0x77b;
-			break;
-		case NETXEN_NIC_XGBE:
-			mask  =  0x77f;
-			break;
-		default:
-			mask  =  0x7ff;
-			break;
-		}
-
-		adapter->pci_write_immediate(adapter, ISR_INT_MASK, mask);
-	}
-
 	adapter->pci_write_normalize(adapter, adapter->crb_intr_mask, 0x1);
 
-	if (!NETXEN_IS_MSI_FAMILY(adapter)) {
-		mask = 0xbff;
-		if (adapter->intr_scheme == INTR_SCHEME_PERPORT)
-			adapter->pci_write_immediate(adapter,
-				adapter->legacy_intr.tgt_mask_reg, mask);
-		else
-			adapter->pci_write_normalize(adapter,
-					CRB_INT_VECTOR, 0);
-	}
+	if (!NETXEN_IS_MSI_FAMILY(adapter))
+		adapter->pci_write_immediate(adapter,
+				adapter->legacy_intr.tgt_mask_reg, 0xfbff);
 }
 
 static int nx_set_dma_mask(struct netxen_adapter *adapter, uint8_t revision_id)
@@ -1086,6 +1028,15 @@ static int netxen_nic_open(struct net_device *netdev)
 			goto err_out_free_sw;
 		}
 
+		if ((adapter->msi_mode != MSI_MODE_MULTIFUNC) ||
+			(adapter->intr_scheme != INTR_SCHEME_PERPORT)) {
+			printk(KERN_ERR "%s: Firmware interrupt scheme is "
+					"incompatible with driver\n",
+					netdev->name);
+			adapter->driver_mismatch = 1;
+			goto err_out_free_hw;
+		}
+
 		if (adapter->fw_major < 4) {
 			adapter->crb_addr_cmd_producer =
 				crb_cmd_producer[adapter->portnum];
@@ -1147,6 +1098,7 @@ err_out_free_irq:
 	free_irq(adapter->irq, adapter);
 err_out_free_rxbuf:
 	netxen_release_rx_buffers(adapter);
+err_out_free_hw:
 	netxen_free_hw_resources(adapter);
 err_out_free_sw:
 	netxen_free_sw_resources(adapter);
@@ -1536,18 +1488,9 @@ struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev)
 	return stats;
 }
 
-static inline void
-netxen_handle_int(struct netxen_adapter *adapter)
-{
-	netxen_nic_disable_int(adapter);
-	napi_schedule(&adapter->napi);
-}
-
 static irqreturn_t netxen_intr(int irq, void *data)
 {
 	struct netxen_adapter *adapter = data;
-	u32 our_int = 0;
-
 	u32 status = 0;
 
 	status = adapter->pci_read_immediate(adapter, ISR_INT_VECTOR);
@@ -1562,22 +1505,32 @@ static irqreturn_t netxen_intr(int irq, void *data)
 		if (!ISR_LEGACY_INT_TRIGGERED(status))
 			return IRQ_NONE;
 
-	} else if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
+	} else {
+		unsigned long our_int = 0;
 
 		our_int = adapter->pci_read_normalize(adapter, CRB_INT_VECTOR);
+
 		/* not our interrupt */
-		if ((our_int & (0x80 << adapter->portnum)) == 0)
+		if (!test_and_clear_bit((7 + adapter->portnum), &our_int))
 			return IRQ_NONE;
 
-		if (adapter->intr_scheme == INTR_SCHEME_PERPORT) {
-			/* claim interrupt */
-			adapter->pci_write_normalize(adapter,
-				CRB_INT_VECTOR,
-				our_int & ~((u32)(0x80 << adapter->portnum)));
-		}
+		/* claim interrupt */
+		adapter->pci_write_normalize(adapter,
+				CRB_INT_VECTOR, (our_int & 0xffffffff));
 	}
 
-	netxen_handle_int(adapter);
+	/* clear interrupt */
+	if (adapter->fw_major < 4)
+		netxen_nic_disable_int(adapter);
+
+	adapter->pci_write_immediate(adapter,
+			adapter->legacy_intr.tgt_status_reg,
+			0xffffffff);
+	/* read twice to ensure write is flushed */
+	adapter->pci_read_immediate(adapter, ISR_INT_VECTOR);
+	adapter->pci_read_immediate(adapter, ISR_INT_VECTOR);
+
+	napi_schedule(&adapter->napi);
 
 	return IRQ_HANDLED;
 }
@@ -1586,7 +1539,11 @@ static irqreturn_t netxen_msi_intr(int irq, void *data)
 {
 	struct netxen_adapter *adapter = data;
 
-	netxen_handle_int(adapter);
+	/* clear interrupt */
+	adapter->pci_write_immediate(adapter,
+			msi_tgt_status[adapter->ahw.pci_func], 0xffffffff);
+
+	napi_schedule(&adapter->napi);
 	return IRQ_HANDLED;
 }
 
-- 
1.5.4.3

