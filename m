From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCHv2] ixgbe: Re-enable relaxed ordering as part of init/restart
 sequence for non-DCA config
Date: Wed, 14 Jan 2015 20:03:52 -0500
Message-ID: <20150115010352.GK24238@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sparclinux@vger.kernel.org, emil.s.tantilov@intel.com
To: sowmini.varadhan@oracle.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com
Return-path: <sparclinux-owner@vger.kernel.org>
Content-Disposition: inline
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Relaxed ordering is disabled by default at driver initialization
and re-enabled when DCA is used. The reason it is disabled  was
due to an issue on some chipsets (see comments in ixgbe_update_tx_dca()).
But when DCA is not used, RO needs to be re-enabled, else we have
a serialization bottleneck on platforms like SPARC.

This patch eliminates the bottleneck for ixgbe when DCA is not configured.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>

---
v2: incoroporate comments from Emil Tantilov

 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c  |   23 +++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |   20 ++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |   11 +++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c   |    1 +
 6 files changed, 57 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index c5c97b4..0c78b5a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -1154,6 +1154,28 @@ static void ixgbe_set_rxpba_82598(struct ixgbe_hw *hw, int num_pb,
 		IXGBE_WRITE_REG(hw, IXGBE_TXPBSIZE(i), IXGBE_TXPBSIZE_40KB);
 }
 
+static void ixgbe_enable_relaxed_ordering_82598(struct ixgbe_hw *hw)
+{
+	u32 regval;
+	u32 i;
+
+	/* Enable relaxed ordering */
+	for (i = 0; ((i < hw->mac.max_tx_queues) &&
+		     (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
+		regval = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(i));
+		regval |= IXGBE_DCA_TXCTRL_DESC_WRO_EN;
+		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(i), regval);
+	}
+
+	for (i = 0; ((i < hw->mac.max_rx_queues) &&
+		     (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
+		regval = IXGBE_READ_REG(hw, IXGBE_DCA_RXCTRL(i));
+		regval |= IXGBE_DCA_RXCTRL_DATA_WRO_EN |
+			  IXGBE_DCA_RXCTRL_HEAD_WRO_EN;
+		IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(i), regval);
+	}
+}
+
 static struct ixgbe_mac_operations mac_ops_82598 = {
 	.init_hw		= &ixgbe_init_hw_generic,
 	.reset_hw		= &ixgbe_reset_hw_82598,
@@ -1161,6 +1183,7 @@ static struct ixgbe_mac_operations mac_ops_82598 = {
 	.clear_hw_cntrs		= &ixgbe_clear_hw_cntrs_generic,
 	.get_media_type		= &ixgbe_get_media_type_82598,
 	.enable_rx_dma          = &ixgbe_enable_rx_dma_generic,
+	.enable_relaxed_ordering = &ixgbe_enable_relaxed_ordering_82598,
 	.get_mac_addr		= &ixgbe_get_mac_addr_generic,
 	.stop_adapter		= &ixgbe_stop_adapter_generic,
 	.get_bus_info           = &ixgbe_get_bus_info_generic,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 9c66bab..4453d92 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -338,6 +338,26 @@ s32 ixgbe_start_hw_gen2(struct ixgbe_hw *hw)
 	return 0;
 }
 
+void ixgbe_enable_relaxed_ordering(struct ixgbe_hw *hw)
+{
+	u32 i;
+	u32 regval;
+
+	/* Enable relaxed ordering */
+	for (i = 0; i < hw->mac.max_tx_queues; i++) {
+		regval = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL_82599(i));
+		regval |= IXGBE_DCA_TXCTRL_DESC_WRO_EN;
+		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL_82599(i), regval);
+	}
+
+	for (i = 0; i < hw->mac.max_rx_queues; i++) {
+		regval = IXGBE_READ_REG(hw, IXGBE_DCA_RXCTRL(i));
+		regval |= (IXGBE_DCA_RXCTRL_DATA_WRO_EN |
+			    IXGBE_DCA_RXCTRL_HEAD_WRO_EN);
+		IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(i), regval);
+	}
+}
+
 /**
  *  ixgbe_init_hw_generic - Generic hardware initialization
  *  @hw: pointer to hardware structure
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
index 8cfadcb..c399c18 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
@@ -37,6 +37,7 @@ s32 ixgbe_init_ops_generic(struct ixgbe_hw *hw);
 s32 ixgbe_init_hw_generic(struct ixgbe_hw *hw);
 s32 ixgbe_start_hw_generic(struct ixgbe_hw *hw);
 s32 ixgbe_start_hw_gen2(struct ixgbe_hw *hw);
+void ixgbe_enable_relaxed_ordering(struct ixgbe_hw *hw);
 s32 ixgbe_clear_hw_cntrs_generic(struct ixgbe_hw *hw);
 s32 ixgbe_read_pba_string_generic(struct ixgbe_hw *hw, u8 *pba_num,
 				  u32 pba_num_size);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 2ed2c7d..dec815b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4898,6 +4898,12 @@ void ixgbe_reset(struct ixgbe_adapter *adapter)
 
 	if (test_bit(__IXGBE_PTP_RUNNING, &adapter->state))
 		ixgbe_ptp_reset(adapter);
+
+#ifndef CONFIG_IXGBE_DCA
+	/* ixgbe_update_tx_dca() will re-enable RO when DCA is enabled */
+	if (hw->mac.ops.enable_relaxed_ordering)
+		hw->mac.ops.enable_relaxed_ordering(hw);
+#endif
 }
 
 /**
@@ -8470,6 +8476,11 @@ skip_sriov:
 			   "representative who provided you with this "
 			   "hardware.\n");
 	}
+#ifndef CONFIG_IXGBE_DCA
+	/* ixgbe_update_tx_dca() will re-enable RO when DCA is enabled */
+	if (hw->mac.ops.enable_relaxed_ordering)
+		hw->mac.ops.enable_relaxed_ordering(hw);
+#endif
 	strcpy(netdev->name, "eth%d");
 	err = register_netdev(netdev);
 	if (err)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index d101b25..b967241 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -3013,6 +3013,7 @@ struct ixgbe_mac_operations {
 	void (*release_swfw_sync)(struct ixgbe_hw *, u32);
 	s32 (*prot_autoc_read)(struct ixgbe_hw *, bool *, u32 *);
 	s32 (*prot_autoc_write)(struct ixgbe_hw *, u32, bool);
+	void (*enable_relaxed_ordering)(struct ixgbe_hw *);
 
 	/* Link */
 	void (*disable_tx_laser)(struct ixgbe_hw *);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index ba54ff0..88adad2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -781,6 +781,7 @@ static struct ixgbe_mac_operations mac_ops_X540 = {
 	.clear_hw_cntrs         = &ixgbe_clear_hw_cntrs_generic,
 	.get_media_type         = &ixgbe_get_media_type_X540,
 	.enable_rx_dma          = &ixgbe_enable_rx_dma_generic,
+	.enable_relaxed_ordering = &ixgbe_enable_relaxed_ordering,
 	.get_mac_addr           = &ixgbe_get_mac_addr_generic,
 	.get_san_mac_addr       = &ixgbe_get_san_mac_addr_generic,
 	.get_device_caps        = &ixgbe_get_device_caps_generic,
-- 
1.7.1

