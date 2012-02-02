From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/8] ixgbe: fix namespace issues when FCoE is not enabled
Date: Thu,  2 Feb 2012 04:20:17 -0800
Message-ID: <1328185221-8591-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328185221-8591-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:3805 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754208Ab2BBMUZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Feb 2012 07:20:25 -0500
In-Reply-To: <1328185221-8591-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several functions are made external but are not used externally when
FCoE/DCB is not enabled.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    8 ++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   23 +++++++++++++++++++++++
 2 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index e6aeb64..e71d545 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -560,7 +560,9 @@ extern int ixgbe_copy_dcb_cfg(struct ixgbe_dcb_config *src_dcb_cfg,
 
 extern char ixgbe_driver_name[];
 extern const char ixgbe_driver_version[];
+#ifdef IXGBE_FCOE
 extern char ixgbe_default_device_descr[];
+#endif /* IXGBE_FCOE */
 
 extern void ixgbe_up(struct ixgbe_adapter *adapter);
 extern void ixgbe_down(struct ixgbe_adapter *adapter);
@@ -576,8 +578,10 @@ extern void ixgbe_configure_tx_ring(struct ixgbe_adapter *,struct ixgbe_ring *);
 extern void ixgbe_disable_rx_queue(struct ixgbe_adapter *adapter,
 				   struct ixgbe_ring *);
 extern void ixgbe_update_stats(struct ixgbe_adapter *adapter);
+#ifdef IXGBE_FCOE
 extern int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter);
 extern void ixgbe_clear_interrupt_scheme(struct ixgbe_adapter *adapter);
+#endif /* IXGBE_FCOE */
 extern netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *,
 					 struct ixgbe_adapter *,
 					 struct ixgbe_ring *);
@@ -604,8 +608,12 @@ extern s32 ixgbe_fdir_erase_perfect_filter_82599(struct ixgbe_hw *hw,
 extern void ixgbe_atr_compute_perfect_hash_82599(union ixgbe_atr_input *input,
 						 union ixgbe_atr_input *mask);
 extern void ixgbe_set_rx_mode(struct net_device *netdev);
+#ifdef CONFIG_IXGBE_DCB
 extern int ixgbe_setup_tc(struct net_device *dev, u8 tc);
+#endif /* CONFIG_IXGBE_DCB */
+#ifdef IXGBE_FCOE
 extern void ixgbe_tx_ctxtdesc(struct ixgbe_ring *, u32, u32, u32, u32);
+#endif /* IXGBE_FCOE */
 extern void ixgbe_do_reset(struct net_device *netdev);
 #ifdef IXGBE_FCOE
 extern void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 92192c6..6119ec5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -55,8 +55,13 @@
 char ixgbe_driver_name[] = "ixgbe";
 static const char ixgbe_driver_string[] =
 			      "Intel(R) 10 Gigabit PCI Express Network Driver";
+#ifdef IXGBE_FCOE
 char ixgbe_default_device_descr[] =
 			      "Intel(R) 10 Gigabit Network Connection";
+#else
+static char ixgbe_default_device_descr[] =
+			      "Intel(R) 10 Gigabit Network Connection";
+#endif
 #define MAJ 3
 #define MIN 6
 #define BUILD 7
@@ -4850,7 +4855,11 @@ static void ixgbe_reset_interrupt_capability(struct ixgbe_adapter *adapter)
  * - Hardware queue count (num_*_queues)
  *   - defined by miscellaneous hardware support/features (RSS, etc.)
  **/
+#ifdef IXGBE_FCOE
 int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter)
+#else
+static int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter)
+#endif
 {
 	int err;
 
@@ -4900,7 +4909,11 @@ err_set_interrupt:
  * We go through and clear interrupt specific resources and reset the structure
  * to pre-load conditions
  **/
+#ifdef IXGBE_FCOE
 void ixgbe_clear_interrupt_scheme(struct ixgbe_adapter *adapter)
+#else
+static void ixgbe_clear_interrupt_scheme(struct ixgbe_adapter *adapter)
+#endif
 {
 	int i;
 
@@ -6269,8 +6282,14 @@ static void ixgbe_service_task(struct work_struct *work)
 	ixgbe_service_event_complete(adapter);
 }
 
+#ifdef IXGBE_FCOE
 void ixgbe_tx_ctxtdesc(struct ixgbe_ring *tx_ring, u32 vlan_macip_lens,
 		       u32 fcoe_sof_eof, u32 type_tucmd, u32 mss_l4len_idx)
+#else
+static void ixgbe_tx_ctxtdesc(struct ixgbe_ring *tx_ring, u32 vlan_macip_lens,
+			      u32 fcoe_sof_eof, u32 type_tucmd,
+			      u32 mss_l4len_idx)
+#endif
 {
 	struct ixgbe_adv_tx_context_desc *context_desc;
 	u16 i = tx_ring->next_to_use;
@@ -7118,7 +7137,11 @@ static void ixgbe_validate_rtr(struct ixgbe_adapter *adapter, u8 tc)
  * @netdev: net device to configure
  * @tc: number of traffic classes to enable
  */
+#ifdef CONFIG_IXGBE_DCB
 int ixgbe_setup_tc(struct net_device *dev, u8 tc)
+#else
+static int ixgbe_setup_tc(struct net_device *dev, u8 tc)
+#endif
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	struct ixgbe_hw *hw = &adapter->hw;
-- 
1.7.7.6
