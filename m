From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/9] ixgbe: Check register reads for adapter removal
Date: Thu,  2 Jan 2014 01:33:35 -0800
Message-ID: <1388655221-25428-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388655221-25428-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49542 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750744AbaABJdr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jan 2014 04:33:47 -0500
In-Reply-To: <1388655221-25428-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

When CONFIG_IXGBE_LER is defined, check all register reads for
adapter removal by checking the status register after any register
read that returns 0xFFFFFFFF. Since the status register will never
return 0xFFFFFFFF unless the adapter is removed, such a value from
a status register read confirms the removal.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h        |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h | 21 +++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   | 40 ++++++++++++++++++++++---
 3 files changed, 58 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 9e9b8d0..ad34757 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -747,6 +747,7 @@ struct ixgbe_adapter {
 #ifdef IXGBE_FCOE
 	struct ixgbe_fcoe fcoe;
 #endif /* IXGBE_FCOE */
+	u8 __iomem *io_addr; /* Mainly for iounmap use */
 	u32 wol;
 
 	u16 bd_number;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
index 503790a..7626c84 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
@@ -124,6 +124,15 @@ s32 ixgbe_reset_pipeline_82599(struct ixgbe_hw *hw);
 s32 ixgbe_get_thermal_sensor_data_generic(struct ixgbe_hw *hw);
 s32 ixgbe_init_thermal_sensor_thresh_generic(struct ixgbe_hw *hw);
 
+#define IXGBE_FAILED_READ_REG 0xffffffffU
+
+#ifdef CONFIG_IXGBE_LER
+void ixgbe_check_remove(struct ixgbe_hw *hw, u32 reg);
+#define IXGBE_REMOVED(a) unlikely(!(a))
+#else
+#define IXGBE_REMOVED(a) (0)
+#endif /* CONFIG_IXGBE_LER */
+
 static inline void IXGBE_WRITE_REG(struct ixgbe_hw *hw, u32 reg, u32 value)
 {
 	writel(value, hw->hw_addr + reg);
@@ -141,7 +150,19 @@ static inline void IXGBE_WRITE_REG64(struct ixgbe_hw *hw, u32 reg, u64 value)
 
 static inline u32 IXGBE_READ_REG(struct ixgbe_hw *hw, u32 reg)
 {
+#ifdef CONFIG_IXGBE_LER
+	u8 __iomem *reg_addr = hw->hw_addr;
+	u32 value;
+
+	if (IXGBE_REMOVED(reg_addr))
+		return IXGBE_FAILED_READ_REG;
+	value = readl(reg_addr + reg);
+	if (unlikely(value == IXGBE_FAILED_READ_REG))
+		ixgbe_check_remove(hw, reg);
+	return value;
+#else
 	return readl(hw->hw_addr + reg);
+#endif /* CONFIG_IXGBE_LER */
 }
 
 #define IXGBE_WRITE_REG_ARRAY(a, reg, offset, value) \
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 752c20b..1100315 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -282,6 +282,37 @@ static void ixgbe_service_event_schedule(struct ixgbe_adapter *adapter)
 		schedule_work(&adapter->service_task);
 }
 
+#ifdef CONFIG_IXGBE_LER
+static void ixgbe_remove_adapter(struct ixgbe_hw *hw)
+{
+	struct ixgbe_adapter *adapter = hw->back;
+
+	if (!hw->hw_addr)
+		return;
+	hw->hw_addr = NULL;
+	e_dev_err("Adapter removed\n");
+}
+
+void ixgbe_check_remove(struct ixgbe_hw *hw, u32 reg)
+{
+	u32 value;
+
+	/* The following check not only optimizes a bit by not
+	 * performing a read on the status register when the
+	 * register just read was a status register read that
+	 * returned IXGBE_FAILED_READ_REG. It also blocks any
+	 * potential recursion.
+	 */
+	if (reg == IXGBE_STATUS) {
+		ixgbe_remove_adapter(hw);
+		return;
+	}
+	value = IXGBE_READ_REG(hw, IXGBE_STATUS);
+	if (value == IXGBE_FAILED_READ_REG)
+		ixgbe_remove_adapter(hw);
+}
+#endif /* CONFIG_IXGBE_LER */
+
 static void ixgbe_service_event_complete(struct ixgbe_adapter *adapter)
 {
 	BUG_ON(!test_bit(__IXGBE_SERVICE_SCHED, &adapter->state));
@@ -2969,7 +3000,7 @@ void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
 			ring->count * sizeof(union ixgbe_adv_tx_desc));
 	IXGBE_WRITE_REG(hw, IXGBE_TDH(reg_idx), 0);
 	IXGBE_WRITE_REG(hw, IXGBE_TDT(reg_idx), 0);
-	ring->tail = hw->hw_addr + IXGBE_TDT(reg_idx);
+	ring->tail = adapter->io_addr + IXGBE_TDT(reg_idx);
 
 	/*
 	 * set WTHRESH to encourage burst writeback, it should not be set
@@ -3372,7 +3403,7 @@ void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
 			ring->count * sizeof(union ixgbe_adv_rx_desc));
 	IXGBE_WRITE_REG(hw, IXGBE_RDH(reg_idx), 0);
 	IXGBE_WRITE_REG(hw, IXGBE_RDT(reg_idx), 0);
-	ring->tail = hw->hw_addr + IXGBE_RDT(reg_idx);
+	ring->tail = adapter->io_addr + IXGBE_RDT(reg_idx);
 
 	ixgbe_configure_srrctl(adapter, ring);
 	ixgbe_configure_rscctl(adapter, ring);
@@ -7881,6 +7912,7 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	hw->hw_addr = ioremap(pci_resource_start(pdev, 0),
 			      pci_resource_len(pdev, 0));
+	adapter->io_addr = hw->hw_addr;
 	if (!hw->hw_addr) {
 		err = -EIO;
 		goto err_ioremap;
@@ -8189,7 +8221,7 @@ err_register:
 err_sw_init:
 	ixgbe_disable_sriov(adapter);
 	adapter->flags2 &= ~IXGBE_FLAG2_SEARCH_FOR_SFP;
-	iounmap(hw->hw_addr);
+	iounmap(adapter->io_addr);
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
@@ -8256,7 +8288,7 @@ static void ixgbe_remove(struct pci_dev *pdev)
 	kfree(adapter->ixgbe_ieee_ets);
 
 #endif
-	iounmap(adapter->hw.hw_addr);
+	iounmap(adapter->io_addr);
 	pci_release_selected_regions(pdev, pci_select_bars(pdev,
 				     IORESOURCE_MEM));
 
-- 
1.8.3.1
