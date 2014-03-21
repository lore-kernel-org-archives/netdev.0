From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/16] ixgbevf: Check register reads for adapter removal
Date: Fri, 21 Mar 2014 05:09:58 -0700
Message-ID: <1395403806-29302-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:15007 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965500AbaCUMKN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2014 08:10:13 -0400
In-Reply-To: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Check all register reads for adapter removal by checking the status
register after any register read that returns 0xFFFFFFFF. Since the
status register will never return 0xFFFFFFFF unless the adapter is
removed, such a value from a status register read confirms the
removal. Since this patch adds so much to ixgbe_read_reg, stop
inlining it, to reduce driver bloat.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  1 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 51 +++++++++++++++++++++--
 drivers/net/ethernet/intel/ixgbevf/vf.h           |  9 ++--
 3 files changed, 53 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index d4b1f50..a08bd7c 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -406,6 +406,7 @@ struct ixgbevf_adapter {
 	u64 bp_tx_missed;
 #endif
 
+	u8 __iomem *io_addr; /* Mainly for iounmap use */
 	u32 link_speed;
 	bool link_up;
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 74df8bf..37c4ebe 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -99,6 +99,48 @@ static void ixgbevf_queue_reset_subtask(struct ixgbevf_adapter *adapter);
 static void ixgbevf_set_itr(struct ixgbevf_q_vector *q_vector);
 static void ixgbevf_free_all_rx_resources(struct ixgbevf_adapter *adapter);
 
+static void ixgbevf_remove_adapter(struct ixgbe_hw *hw)
+{
+	struct ixgbevf_adapter *adapter = hw->back;
+
+	if (!hw->hw_addr)
+		return;
+	hw->hw_addr = NULL;
+	dev_err(&adapter->pdev->dev, "Adapter removed\n");
+}
+
+static void ixgbevf_check_remove(struct ixgbe_hw *hw, u32 reg)
+{
+	u32 value;
+
+	/* The following check not only optimizes a bit by not
+	 * performing a read on the status register when the
+	 * register just read was a status register read that
+	 * returned IXGBE_FAILED_READ_REG. It also blocks any
+	 * potential recursion.
+	 */
+	if (reg == IXGBE_VFSTATUS) {
+		ixgbevf_remove_adapter(hw);
+		return;
+	}
+	value = ixgbe_read_reg(hw, IXGBE_VFSTATUS);
+	if (value == IXGBE_FAILED_READ_REG)
+		ixgbevf_remove_adapter(hw);
+}
+
+u32 ixgbe_read_reg(struct ixgbe_hw *hw, u32 reg)
+{
+	u8 __iomem *reg_addr = ACCESS_ONCE(hw->hw_addr);
+	u32 value;
+
+	if (IXGBE_REMOVED(reg_addr))
+		return IXGBE_FAILED_READ_REG;
+	value = readl(reg_addr + reg);
+	if (unlikely(value == IXGBE_FAILED_READ_REG))
+		ixgbevf_check_remove(hw, reg);
+	return value;
+}
+
 static inline void ixgbevf_release_rx_desc(struct ixgbevf_ring *rx_ring,
 					   u32 val)
 {
@@ -1139,7 +1181,7 @@ static void ixgbevf_configure_tx_ring(struct ixgbevf_adapter *adapter,
 	/* reset head and tail pointers */
 	IXGBE_WRITE_REG(hw, IXGBE_VFTDH(reg_idx), 0);
 	IXGBE_WRITE_REG(hw, IXGBE_VFTDT(reg_idx), 0);
-	ring->tail = hw->hw_addr + IXGBE_VFTDT(reg_idx);
+	ring->tail = adapter->io_addr + IXGBE_VFTDT(reg_idx);
 
 	/* reset ntu and ntc to place SW in sync with hardwdare */
 	ring->next_to_clean = 0;
@@ -1318,7 +1360,7 @@ static void ixgbevf_configure_rx_ring(struct ixgbevf_adapter *adapter,
 	/* reset head and tail pointers */
 	IXGBE_WRITE_REG(hw, IXGBE_VFRDH(reg_idx), 0);
 	IXGBE_WRITE_REG(hw, IXGBE_VFRDT(reg_idx), 0);
-	ring->tail = hw->hw_addr + IXGBE_VFRDT(reg_idx);
+	ring->tail = adapter->io_addr + IXGBE_VFRDT(reg_idx);
 
 	/* reset ntu and ntc to place SW in sync with hardwdare */
 	ring->next_to_clean = 0;
@@ -3459,6 +3501,7 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	hw->hw_addr = ioremap(pci_resource_start(pdev, 0),
 			      pci_resource_len(pdev, 0));
+	adapter->io_addr = hw->hw_addr;
 	if (!hw->hw_addr) {
 		err = -EIO;
 		goto err_ioremap;
@@ -3544,7 +3587,7 @@ err_register:
 	ixgbevf_clear_interrupt_scheme(adapter);
 err_sw_init:
 	ixgbevf_reset_interrupt_capability(adapter);
-	iounmap(hw->hw_addr);
+	iounmap(adapter->io_addr);
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
@@ -3582,7 +3625,7 @@ static void ixgbevf_remove(struct pci_dev *pdev)
 	ixgbevf_clear_interrupt_scheme(adapter);
 	ixgbevf_reset_interrupt_capability(adapter);
 
-	iounmap(adapter->hw.hw_addr);
+	iounmap(adapter->io_addr);
 	pci_release_regions(pdev);
 
 	hw_dbg(&adapter->hw, "Remove complete\n");
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
index 8ebed72..7cb1a52 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
@@ -172,16 +172,17 @@ struct ixgbevf_info {
 	const struct ixgbe_mac_operations *mac_ops;
 };
 
+#define IXGBE_FAILED_READ_REG 0xffffffffU
+
+#define IXGBE_REMOVED(a) unlikely(!(a))
+
 static inline void ixgbe_write_reg(struct ixgbe_hw *hw, u32 reg, u32 value)
 {
 	writel(value, hw->hw_addr + reg);
 }
 #define IXGBE_WRITE_REG(h, r, v) ixgbe_write_reg(h, r, v)
 
-static inline u32 ixgbe_read_reg(struct ixgbe_hw *hw, u32 reg)
-{
-	return readl(hw->hw_addr + reg);
-}
+u32 ixgbe_read_reg(struct ixgbe_hw *hw, u32 reg);
 #define IXGBE_READ_REG(h, r) ixgbe_read_reg(h, r)
 
 static inline void ixgbe_write_reg_array(struct ixgbe_hw *hw, u32 reg,
-- 
1.8.3.1
