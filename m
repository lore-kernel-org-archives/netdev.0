From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] ixgbevf: Move API negotiation function into mac_ops
Date: Mon, 25 Apr 2016 05:44:28 -0700
Message-ID: <1461588269-128728-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461588269-128728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10855 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932424AbcDYMog (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2016 08:44:36 -0400
In-Reply-To: <1461588269-128728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

This patch moves API negotiation into mac_ops.  The general idea here is
that with HyperV on the way we need to make certain that anything that will
have different versions between HyperV and a standard VF needs to be
abstracted enough so that we can have a separate function between the two
so we can avoid changes in one breaking something in the other.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 2 +-
 drivers/net/ethernet/intel/ixgbevf/vf.c           | 5 +++--
 drivers/net/ethernet/intel/ixgbevf/vf.h           | 2 +-
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index eb91922..319e25f 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2056,7 +2056,7 @@ static void ixgbevf_negotiate_api(struct ixgbevf_adapter *adapter)
 	spin_lock_bh(&adapter->mbx_lock);
 
 	while (api[idx] != ixgbe_mbox_api_unknown) {
-		err = ixgbevf_negotiate_api_version(hw, api[idx]);
+		err = hw->mac.ops.negotiate_api_version(hw, api[idx]);
 		if (!err)
 			break;
 		idx++;
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index 4d613a4..987ad69 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -670,11 +670,11 @@ void ixgbevf_rlpml_set_vf(struct ixgbe_hw *hw, u16 max_size)
 }
 
 /**
- *  ixgbevf_negotiate_api_version - Negotiate supported API version
+ *  ixgbevf_negotiate_api_version_vf - Negotiate supported API version
  *  @hw: pointer to the HW structure
  *  @api: integer containing requested API version
  **/
-int ixgbevf_negotiate_api_version(struct ixgbe_hw *hw, int api)
+static int ixgbevf_negotiate_api_version_vf(struct ixgbe_hw *hw, int api)
 {
 	int err;
 	u32 msg[3];
@@ -769,6 +769,7 @@ static const struct ixgbe_mac_operations ixgbevf_mac_ops = {
 	.stop_adapter		= ixgbevf_stop_hw_vf,
 	.setup_link		= ixgbevf_setup_mac_link_vf,
 	.check_link		= ixgbevf_check_mac_link_vf,
+	.negotiate_api_version	= ixgbevf_negotiate_api_version_vf,
 	.set_rar		= ixgbevf_set_rar_vf,
 	.update_mc_addr_list	= ixgbevf_update_mc_addr_list_vf,
 	.update_xcast_mode	= ixgbevf_update_xcast_mode,
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
index ef9f773..8e623f9 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
@@ -51,6 +51,7 @@ struct ixgbe_mac_operations {
 	s32 (*get_mac_addr)(struct ixgbe_hw *, u8 *);
 	s32 (*stop_adapter)(struct ixgbe_hw *);
 	s32 (*get_bus_info)(struct ixgbe_hw *);
+	s32 (*negotiate_api_version)(struct ixgbe_hw *hw, int api);
 
 	/* Link */
 	s32 (*setup_link)(struct ixgbe_hw *, ixgbe_link_speed, bool, bool);
@@ -208,7 +209,6 @@ static inline u32 ixgbe_read_reg_array(struct ixgbe_hw *hw, u32 reg,
 #define IXGBE_READ_REG_ARRAY(h, r, o) ixgbe_read_reg_array(h, r, o)
 
 void ixgbevf_rlpml_set_vf(struct ixgbe_hw *hw, u16 max_size);
-int ixgbevf_negotiate_api_version(struct ixgbe_hw *hw, int api);
 int ixgbevf_get_queues(struct ixgbe_hw *hw, unsigned int *num_tcs,
 		       unsigned int *default_tc);
 int ixgbevf_get_reta_locked(struct ixgbe_hw *hw, u32 *reta, int num_rx_queues);
-- 
2.5.5
