From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/5] igb: VFTA Table Fix for i350 devices
Date: Fri, 21 Oct 2011 03:32:01 -0700
Message-ID: <1319193121-2729-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1319193121-2729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30637 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754230Ab1JUKcI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Oct 2011 06:32:08 -0400
In-Reply-To: <1319193121-2729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

Due to a hardware problem, writes to the VFTA register can
theoretically fail. Although the likelihood of this is very low.
This patch adds a shadow vfta in the adapter struct for reading
and adds new write functions for these devices to work around the problem.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c |    5 ++-
 drivers/net/ethernet/intel/igb/e1000_mac.c   |   56 ++++++++++++++++++++++++-
 drivers/net/ethernet/intel/igb/e1000_mac.h   |    1 +
 drivers/net/ethernet/intel/igb/igb.h         |    1 +
 drivers/net/ethernet/intel/igb/igb_main.c    |    6 +++
 5 files changed, 65 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index 6580cea..7881fb9 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -1051,7 +1051,10 @@ static s32 igb_init_hw_82575(struct e1000_hw *hw)
 
 	/* Disabling VLAN filtering */
 	hw_dbg("Initializing the IEEE VLAN\n");
-	igb_clear_vfta(hw);
+	if (hw->mac.type == e1000_i350)
+		igb_clear_vfta_i350(hw);
+	else
+		igb_clear_vfta(hw);
 
 	/* Setup the receive address */
 	igb_init_rx_addrs(hw, rar_count);
diff --git a/drivers/net/ethernet/intel/igb/e1000_mac.c b/drivers/net/ethernet/intel/igb/e1000_mac.c
index bad3e14..73aac08 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mac.c
+++ b/drivers/net/ethernet/intel/igb/e1000_mac.c
@@ -117,6 +117,50 @@ static void igb_write_vfta(struct e1000_hw *hw, u32 offset, u32 value)
 	wrfl();
 }
 
+/* Due to a hw errata, if the host tries to  configure the VFTA register
+ * while performing queries from the BMC or DMA, then the VFTA in some
+ * cases won't be written.
+ */
+
+/**
+ *  igb_clear_vfta_i350 - Clear VLAN filter table
+ *  @hw: pointer to the HW structure
+ *
+ *  Clears the register array which contains the VLAN filter table by
+ *  setting all the values to 0.
+ **/
+void igb_clear_vfta_i350(struct e1000_hw *hw)
+{
+	u32 offset;
+	int i;
+
+	for (offset = 0; offset < E1000_VLAN_FILTER_TBL_SIZE; offset++) {
+		for (i = 0; i < 10; i++)
+			array_wr32(E1000_VFTA, offset, 0);
+
+		wrfl();
+	}
+}
+
+/**
+ *  igb_write_vfta_i350 - Write value to VLAN filter table
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset in VLAN filter table
+ *  @value: register value written to VLAN filter table
+ *
+ *  Writes value at the given offset in the register array which stores
+ *  the VLAN filter table.
+ **/
+void igb_write_vfta_i350(struct e1000_hw *hw, u32 offset, u32 value)
+{
+	int i;
+
+	for (i = 0; i < 10; i++)
+		array_wr32(E1000_VFTA, offset, value);
+
+	wrfl();
+}
+
 /**
  *  igb_init_rx_addrs - Initialize receive address's
  *  @hw: pointer to the HW structure
@@ -155,9 +199,12 @@ s32 igb_vfta_set(struct e1000_hw *hw, u32 vid, bool add)
 {
 	u32 index = (vid >> E1000_VFTA_ENTRY_SHIFT) & E1000_VFTA_ENTRY_MASK;
 	u32 mask = 1 << (vid & E1000_VFTA_ENTRY_BIT_SHIFT_MASK);
-	u32 vfta = array_rd32(E1000_VFTA, index);
+	u32 vfta;
+	struct igb_adapter *adapter = hw->back;
 	s32 ret_val = 0;
 
+	vfta = adapter->shadow_vfta[index];
+
 	/* bit was set/cleared before we started */
 	if ((!!(vfta & mask)) == add) {
 		ret_val = -E1000_ERR_CONFIG;
@@ -167,8 +214,11 @@ s32 igb_vfta_set(struct e1000_hw *hw, u32 vid, bool add)
 		else
 			vfta &= ~mask;
 	}
-
-	igb_write_vfta(hw, index, vfta);
+	if (hw->mac.type == e1000_i350)
+		igb_write_vfta_i350(hw, index, vfta);
+	else
+		igb_write_vfta(hw, index, vfta);
+	adapter->shadow_vfta[index] = vfta;
 
 	return ret_val;
 }
diff --git a/drivers/net/ethernet/intel/igb/e1000_mac.h b/drivers/net/ethernet/intel/igb/e1000_mac.h
index 4927f61..e45996b 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mac.h
+++ b/drivers/net/ethernet/intel/igb/e1000_mac.h
@@ -60,6 +60,7 @@ s32  igb_write_8bit_ctrl_reg(struct e1000_hw *hw, u32 reg,
 
 void igb_clear_hw_cntrs_base(struct e1000_hw *hw);
 void igb_clear_vfta(struct e1000_hw *hw);
+void igb_clear_vfta_i350(struct e1000_hw *hw);
 s32  igb_vfta_set(struct e1000_hw *hw, u32 vid, bool add);
 void igb_config_collision_dist(struct e1000_hw *hw);
 void igb_init_rx_addrs(struct e1000_hw *hw, u16 rar_count);
diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 5594430..c69feeb 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -363,6 +363,7 @@ struct igb_adapter {
 	u32 rss_queues;
 	u32 wvbr;
 	int node;
+	u32 *shadow_vfta;
 };
 
 #define IGB_FLAG_HAS_MSI           (1 << 0)
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index b186353..ced5444 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2206,6 +2206,7 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 	pci_release_selected_regions(pdev,
 	                             pci_select_bars(pdev, IORESOURCE_MEM));
 
+	kfree(adapter->shadow_vfta);
 	free_netdev(netdev);
 
 	pci_disable_pcie_error_reporting(pdev);
@@ -2438,6 +2439,11 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
 	    ((adapter->rss_queues > 1) && (adapter->vfs_allocated_count > 6)))
 		adapter->flags |= IGB_FLAG_QUEUE_PAIRS;
 
+	/* Setup and initialize a copy of the hw vlan table array */
+	adapter->shadow_vfta = kzalloc(sizeof(u32) *
+				E1000_VLAN_FILTER_TBL_SIZE,
+				GFP_ATOMIC);
+
 	/* This call may decrease the number of queues */
 	if (igb_init_interrupt_scheme(adapter)) {
 		dev_err(&pdev->dev, "Unable to allocate memory for queues\n");
-- 
1.7.6.4
