From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 17/20] fm10k: implement request_lport_map pointer
Date: Wed, 20 Jul 2016 15:23:55 -0700
Message-ID: <1469053438-85381-18-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4181 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755455AbcGTWYJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 18:24:09 -0400
In-Reply-To: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

If the fm10k interface is brought up, but the switch manager software is
not running, the driver will continuously request the lport map every
few seconds in the base driver watchdog routine. Eventually after
several minutes the switch mailbox Tx fifo will fill up and the mailbox
will timeout, resulting in a reset. This reset will appear as if for no
reason, and occurs regularly every few minutes until the switch manager
software is loaded.

Prevent this from happening by only requesting the lport map after we've
verified the switch mailbox is tx_ready. In order to simplify code logic
and reduce code duplication, implement this as a new function pointer
"mac.ops.request_lport_map" which the VF will not implement. Otherwise,
we have to duplicate the tx_ready check outside of
fm10k_get_host_state_generic, or re-implement most of
fm10k_get_host_state_generic in the pf version.

The resulting code is simpler and easier to understand, and prevents the
PF from continuously requesting lport map and filling the Tx fifo of
a switch mailbox that isn't ready.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_common.c |  6 +++++-
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c     | 15 +++------------
 drivers/net/ethernet/intel/fm10k/fm10k_type.h   |  1 +
 3 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_common.c b/drivers/net/ethernet/intel/fm10k/fm10k_common.c
index 5bbf19c..d6baaea 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_common.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_common.c
@@ -519,8 +519,12 @@ s32 fm10k_get_host_state_generic(struct fm10k_hw *hw, bool *host_ready)
 		goto out;
 
 	/* interface cannot receive traffic without logical ports */
-	if (mac->dglort_map == FM10K_DGLORTMAP_NONE)
+	if (mac->dglort_map == FM10K_DGLORTMAP_NONE) {
+		if (hw->mac.ops.request_lport_map)
+			ret_val = hw->mac.ops.request_lport_map(hw);
+
 		goto out;
+	}
 
 	/* if we passed all the tests above then the switch is ready and we no
 	 * longer need to check for link
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 23f3566..682299d 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -1622,25 +1622,15 @@ static s32 fm10k_request_lport_map_pf(struct fm10k_hw *hw)
  **/
 static s32 fm10k_get_host_state_pf(struct fm10k_hw *hw, bool *switch_ready)
 {
-	s32 ret_val = 0;
 	u32 dma_ctrl2;
 
 	/* verify the switch is ready for interaction */
 	dma_ctrl2 = fm10k_read_reg(hw, FM10K_DMA_CTRL2);
 	if (!(dma_ctrl2 & FM10K_DMA_CTRL2_SWITCH_READY))
-		goto out;
+		return 0;
 
 	/* retrieve generic host state info */
-	ret_val = fm10k_get_host_state_generic(hw, switch_ready);
-	if (ret_val)
-		goto out;
-
-	/* interface cannot receive traffic without logical ports */
-	if (hw->mac.dglort_map == FM10K_DGLORTMAP_NONE)
-		ret_val = fm10k_request_lport_map_pf(hw);
-
-out:
-	return ret_val;
+	return fm10k_get_host_state_generic(hw, switch_ready);
 }
 
 /* This structure defines the attibutes to be parsed below */
@@ -1816,6 +1806,7 @@ static const struct fm10k_mac_ops mac_ops_pf = {
 	.set_dma_mask		= fm10k_set_dma_mask_pf,
 	.get_fault		= fm10k_get_fault_pf,
 	.get_host_state		= fm10k_get_host_state_pf,
+	.request_lport_map	= fm10k_request_lport_map_pf,
 };
 
 static const struct fm10k_iov_ops iov_ops_pf = {
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_type.h b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
index 1d65ad8..f4e75c4 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_type.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
@@ -526,6 +526,7 @@ struct fm10k_mac_ops {
 	s32 (*stop_hw)(struct fm10k_hw *);
 	s32 (*get_bus_info)(struct fm10k_hw *);
 	s32 (*get_host_state)(struct fm10k_hw *, bool *);
+	s32 (*request_lport_map)(struct fm10k_hw *);
 	s32 (*update_vlan)(struct fm10k_hw *, u32, u8, bool);
 	s32 (*read_mac_addr)(struct fm10k_hw *);
 	s32 (*update_uc_addr)(struct fm10k_hw *, u16, const u8 *,
-- 
2.5.5
