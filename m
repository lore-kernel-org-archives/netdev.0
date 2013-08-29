From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 01/10] ixgbe: disable link when adapter goes down
Date: Thu, 29 Aug 2013 03:49:57 -0700
Message-ID: <1377773406-24851-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1377773406-24851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:42737 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756023Ab3H2KuM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 06:50:12 -0400
In-Reply-To: <1377773406-24851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch fixes an issue with the 82599 adapter where it can potentially keep
link lights up when the adapter has gone down. The patch adds a function which
ensures link is disabled, and calls this function when the adapter transitions
to a down state.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c | 20 ++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  3 +++
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  |  2 ++
 3 files changed, 25 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index 207f68f..51ee8ad 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -49,6 +49,7 @@ static s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
 static s32 ixgbe_setup_mac_link_smartspeed(struct ixgbe_hw *hw,
                                            ixgbe_link_speed speed,
                                            bool autoneg_wait_to_complete);
+static void ixgbe_stop_mac_link_on_d3_82599(struct ixgbe_hw *hw);
 static s32 ixgbe_start_mac_link_82599(struct ixgbe_hw *hw,
 				      bool autoneg_wait_to_complete);
 static s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw,
@@ -432,6 +433,24 @@ out:
 }
 
 /**
+ * ixgbe_stop_mac_link_on_d3_82599 - Disables link on D3
+ * @hw: pointer to hardware structure
+ *
+ * Disables link, should be called during D3 power down sequence.
+ *
+ */
+static void ixgbe_stop_mac_link_on_d3_82599(struct ixgbe_hw *hw)
+{
+	u32 autoc2_reg;
+
+	if (!hw->mng_fw_enabled && !hw->wol_enabled) {
+		autoc2_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC2);
+		autoc2_reg |= IXGBE_AUTOC2_LINK_DISABLE_ON_D3_MASK;
+		IXGBE_WRITE_REG(hw, IXGBE_AUTOC2, autoc2_reg);
+	}
+}
+
+/**
  *  ixgbe_start_mac_link_82599 - Setup MAC link settings
  *  @hw: pointer to hardware structure
  *  @autoneg_wait_to_complete: true when waiting for completion is needed
@@ -2477,6 +2496,7 @@ static struct ixgbe_mac_operations mac_ops_82599 = {
 	.set_lan_id             = &ixgbe_set_lan_id_multi_port_pcie,
 	.read_analog_reg8       = &ixgbe_read_analog_reg8_82599,
 	.write_analog_reg8      = &ixgbe_write_analog_reg8_82599,
+	.stop_link_on_d3	= &ixgbe_stop_mac_link_on_d3_82599,
 	.setup_link             = &ixgbe_setup_mac_link_82599,
 	.set_rxpba		= &ixgbe_set_rxpba_generic,
 	.check_link             = &ixgbe_check_mac_link_generic,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 128d6b8..cf1b41e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5292,6 +5292,9 @@ static int __ixgbe_shutdown(struct pci_dev *pdev, bool *enable_wake)
 		return retval;
 
 #endif
+	if (hw->mac.ops.stop_link_on_d3)
+		hw->mac.ops.stop_link_on_d3(hw);
+
 	if (wufc) {
 		ixgbe_set_rx_mode(netdev);
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 161ff18..6442cf8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -1596,6 +1596,7 @@ enum {
 #define IXGBE_AUTOC2_10G_KR  (0x0 << IXGBE_AUTOC2_10G_SERIAL_PMA_PMD_SHIFT)
 #define IXGBE_AUTOC2_10G_XFI (0x1 << IXGBE_AUTOC2_10G_SERIAL_PMA_PMD_SHIFT)
 #define IXGBE_AUTOC2_10G_SFI (0x2 << IXGBE_AUTOC2_10G_SERIAL_PMA_PMD_SHIFT)
+#define IXGBE_AUTOC2_LINK_DISABLE_ON_D3_MASK  0x50000000
 #define IXGBE_AUTOC2_LINK_DISABLE_MASK        0x70000000
 
 #define IXGBE_MACC_FLU       0x00000001
@@ -2847,6 +2848,7 @@ struct ixgbe_mac_operations {
 	void (*disable_tx_laser)(struct ixgbe_hw *);
 	void (*enable_tx_laser)(struct ixgbe_hw *);
 	void (*flap_tx_laser)(struct ixgbe_hw *);
+	void (*stop_link_on_d3)(struct ixgbe_hw *);
 	s32 (*setup_link)(struct ixgbe_hw *, ixgbe_link_speed, bool);
 	s32 (*check_link)(struct ixgbe_hw *, ixgbe_link_speed *, bool *, bool);
 	s32 (*get_link_capabilities)(struct ixgbe_hw *, ixgbe_link_speed *,
-- 
1.8.3.1
