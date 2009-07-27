From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 04/12] netxen: annotate dma watchdog setup
Date: Sun, 26 Jul 2009 23:07:39 -0700
Message-ID: <1248674867-18821-5-git-send-email-dhananjay@netxen.com>
References: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:33565 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751130AbZG0GHr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2009 02:07:47 -0400
In-Reply-To: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o remove superfluous code to setup PCI dma watchdog for NX2031.
o disable dma watchdog completely for NX3031 (not required).

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |   73 +--------------------------------
 drivers/net/netxen/netxen_nic_hdr.h  |    2 +-
 drivers/net/netxen/netxen_nic_init.c |   59 ++++++++++++++++-----------
 drivers/net/netxen/netxen_nic_main.c |    8 ++--
 4 files changed, 43 insertions(+), 99 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 6b9e759..3368af0 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1324,24 +1324,6 @@ struct netxen_adapter {
 	const struct firmware *fw;
 };
 
-/*
- * NetXen dma watchdog control structure
- *
- *	Bit 0		: enabled => R/O: 1 watchdog active, 0 inactive
- *	Bit 1		: disable_request => 1 req disable dma watchdog
- *	Bit 2		: enable_request =>  1 req enable dma watchdog
- *	Bit 3-31	: unused
- */
-
-#define netxen_set_dma_watchdog_disable_req(config_word) \
-	_netxen_set_bits(config_word, 1, 1, 1)
-#define netxen_set_dma_watchdog_enable_req(config_word) \
-	_netxen_set_bits(config_word, 2, 1, 1)
-#define netxen_get_dma_watchdog_enabled(config_word) \
-	((config_word) & 0x1)
-#define netxen_get_dma_watchdog_disabled(config_word) \
-	(((config_word) >> 1) & 0x1)
-
 int netxen_niu_xgbe_enable_phy_interrupts(struct netxen_adapter *adapter);
 int netxen_niu_gbe_enable_phy_interrupts(struct netxen_adapter *adapter);
 int netxen_niu_xgbe_disable_phy_interrupts(struct netxen_adapter *adapter);
@@ -1402,8 +1384,9 @@ unsigned long netxen_nic_pci_set_window_2M(struct netxen_adapter *adapter,
 		unsigned long long addr);
 
 /* Functions from netxen_nic_init.c */
-void netxen_free_adapter_offload(struct netxen_adapter *adapter);
-int netxen_initialize_adapter_offload(struct netxen_adapter *adapter);
+int netxen_init_dummy_dma(struct netxen_adapter *adapter);
+void netxen_free_dummy_dma(struct netxen_adapter *adapter);
+
 int netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val);
 int netxen_load_firmware(struct netxen_adapter *adapter);
 int netxen_need_fw_reset(struct netxen_adapter *adapter);
@@ -1510,56 +1493,6 @@ static inline void get_brd_name_by_type(u32 type, char *name)
 		name = "Unknown";
 }
 
-static inline int
-dma_watchdog_shutdown_request(struct netxen_adapter *adapter)
-{
-	u32 ctrl;
-
-	/* check if already inactive */
-	ctrl = adapter->hw_read_wx(adapter,
-			NETXEN_CAM_RAM(NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL));
-
-	if (netxen_get_dma_watchdog_enabled(ctrl) == 0)
-		return 1;
-
-	/* Send the disable request */
-	netxen_set_dma_watchdog_disable_req(ctrl);
-	NXWR32(adapter, NETXEN_CAM_RAM(NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL), ctrl);
-
-	return 0;
-}
-
-static inline int
-dma_watchdog_shutdown_poll_result(struct netxen_adapter *adapter)
-{
-	u32 ctrl;
-
-	ctrl = adapter->hw_read_wx(adapter,
-			NETXEN_CAM_RAM(NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL));
-
-	return (netxen_get_dma_watchdog_enabled(ctrl) == 0);
-}
-
-static inline int
-dma_watchdog_wakeup(struct netxen_adapter *adapter)
-{
-	u32 ctrl;
-
-	ctrl = adapter->hw_read_wx(adapter,
-			NETXEN_CAM_RAM(NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL));
-
-	if (netxen_get_dma_watchdog_enabled(ctrl))
-		return 1;
-
-	/* send the wakeup request */
-	netxen_set_dma_watchdog_enable_req(ctrl);
-
-	NXWR32(adapter, NETXEN_CAM_RAM(NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL), ctrl);
-
-	return 0;
-}
-
-
 static inline u32 netxen_tx_avail(struct nx_host_tx_ring *tx_ring)
 {
 	smp_mb();
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index 8241036..a732858 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -852,7 +852,7 @@ enum {
 #define NX_PEG_TUNE_MN_PRESENT		0x1
 #define NX_PEG_TUNE_CAPABILITY		(NETXEN_CAM_RAM(0x02c))
 
-#define NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL		(0x14)
+#define NETXEN_DMA_WATCHDOG_CTRL	(NETXEN_CAM_RAM(0x14))
 #define NETXEN_PEG_ALIVE_COUNTER	(NETXEN_CAM_RAM(0xb0))
 
 #define	ISR_MSI_INT_TRIGGER(FUNC) (NETXEN_PCIX_PS_REG(PCIX_MSI_F(FUNC)))
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 5d7a2c4..9135845 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -954,19 +954,20 @@ netxen_release_firmware(struct netxen_adapter *adapter)
 		release_firmware(adapter->fw);
 }
 
-int netxen_initialize_adapter_offload(struct netxen_adapter *adapter)
+int netxen_init_dummy_dma(struct netxen_adapter *adapter)
 {
-	uint64_t addr;
-	uint32_t hi;
-	uint32_t lo;
+	u64 addr;
+	u32 hi, lo;
 
-	adapter->dummy_dma.addr =
-	    pci_alloc_consistent(adapter->pdev,
+	if (!NX_IS_REVISION_P2(adapter->ahw.revision_id))
+		return 0;
+
+	adapter->dummy_dma.addr = pci_alloc_consistent(adapter->pdev,
 				 NETXEN_HOST_DUMMY_DMA_SIZE,
 				 &adapter->dummy_dma.phys_addr);
 	if (adapter->dummy_dma.addr == NULL) {
-		printk("%s: ERROR: Could not allocate dummy DMA memory\n",
-		       __func__);
+		dev_err(&adapter->pdev->dev,
+			"ERROR: Could not allocate dummy DMA memory\n");
 		return -ENOMEM;
 	}
 
@@ -977,29 +978,41 @@ int netxen_initialize_adapter_offload(struct netxen_adapter *adapter)
 	NXWR32(adapter, CRB_HOST_DUMMY_BUF_ADDR_HI, hi);
 	NXWR32(adapter, CRB_HOST_DUMMY_BUF_ADDR_LO, lo);
 
-	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
-		uint32_t temp = 0;
-		NXWR32(adapter, CRB_HOST_DUMMY_BUF, temp);
-	}
-
 	return 0;
 }
 
-void netxen_free_adapter_offload(struct netxen_adapter *adapter)
+/*
+ * NetXen DMA watchdog control:
+ *
+ *	Bit 0		: enabled => R/O: 1 watchdog active, 0 inactive
+ *	Bit 1		: disable_request => 1 req disable dma watchdog
+ *	Bit 2		: enable_request =>  1 req enable dma watchdog
+ *	Bit 3-31	: unused
+ */
+void netxen_free_dummy_dma(struct netxen_adapter *adapter)
 {
 	int i = 100;
+	u32 ctrl;
+
+	if (!NX_IS_REVISION_P2(adapter->ahw.revision_id))
+		return;
 
 	if (!adapter->dummy_dma.addr)
 		return;
 
-	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
-		do {
-			if (dma_watchdog_shutdown_request(adapter) == 1)
-				break;
+	ctrl = NXRD32(adapter, NETXEN_DMA_WATCHDOG_CTRL);
+	if ((ctrl & 0x1) != 0) {
+		NXWR32(adapter, NETXEN_DMA_WATCHDOG_CTRL, (ctrl | 0x2));
+
+		while ((ctrl & 0x1) != 0) {
+
 			msleep(50);
-			if (dma_watchdog_shutdown_poll_result(adapter) == 1)
+
+			ctrl = NXRD32(adapter, NETXEN_DMA_WATCHDOG_CTRL);
+
+			if (--i == 0)
 				break;
-		} while (--i);
+		};
 	}
 
 	if (i) {
@@ -1008,10 +1021,8 @@ void netxen_free_adapter_offload(struct netxen_adapter *adapter)
 			    adapter->dummy_dma.addr,
 			    adapter->dummy_dma.phys_addr);
 		adapter->dummy_dma.addr = NULL;
-	} else {
-		printk(KERN_ERR "%s: dma_watchdog_shutdown failed\n",
-				adapter->netdev->name);
-	}
+	} else
+		dev_err(&adapter->pdev->dev, "dma_watchdog_shutdown failed\n");
 }
 
 int netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val)
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 76bdd5c..fb976cb 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -745,7 +745,7 @@ netxen_start_firmware(struct netxen_adapter *adapter, int request_fw)
 
 	}
 
-	err = netxen_initialize_adapter_offload(adapter);
+	err = netxen_init_dummy_dma(adapter);
 	if (err)
 		return err;
 
@@ -761,7 +761,7 @@ wait_init:
 	/* Handshake with the card before we register the devices. */
 	err = netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
 	if (err) {
-		netxen_free_adapter_offload(adapter);
+		netxen_free_dummy_dma(adapter);
 		return err;
 	}
 
@@ -1154,7 +1154,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 err_out_disable_msi:
 	netxen_teardown_intr(adapter);
 
-	netxen_free_adapter_offload(adapter);
+	netxen_free_dummy_dma(adapter);
 
 err_out_iounmap:
 	netxen_cleanup_pci_map(adapter);
@@ -1189,7 +1189,7 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 	}
 
 	if (adapter->portnum == 0)
-		netxen_free_adapter_offload(adapter);
+		netxen_free_dummy_dma(adapter);
 
 	netxen_teardown_intr(adapter);
 	netxen_free_sds_rings(&adapter->recv_ctx);
-- 
1.6.0.2

