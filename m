From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/10] ixgbevf: add spinlocks for MTU change calls
Date: Fri, 23 Sep 2016 00:51:38 -0700
Message-ID: <1474617103-59530-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474617103-59530-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:8864 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757450AbcIWHvr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 03:51:47 -0400
In-Reply-To: <1474617103-59530-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Protect set_rlpml with mailbox lock to make sure the MTU configuration
is handled properly.

This change resolves an issue where set_rlpml can fail when the VF
interface is brought up:
ixgbevf 0000:03:1d.6: Failed to set MTU at 1500

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 4044608..7eaac32 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1810,8 +1810,10 @@ static void ixgbevf_configure_rx(struct ixgbevf_adapter *adapter)
 	if (hw->mac.type >= ixgbe_mac_X550_vf)
 		ixgbevf_setup_vfmrqc(adapter);
 
+	spin_lock_bh(&adapter->mbx_lock);
 	/* notify the PF of our intent to use this size of frame */
 	ret = hw->mac.ops.set_rlpml(hw, netdev->mtu + ETH_HLEN + ETH_FCS_LEN);
+	spin_unlock_bh(&adapter->mbx_lock);
 	if (ret)
 		dev_err(&adapter->pdev->dev,
 			"Failed to set MTU at %d\n", netdev->mtu);
@@ -3758,8 +3760,10 @@ static int ixgbevf_change_mtu(struct net_device *netdev, int new_mtu)
 	if ((new_mtu < 68) || (max_frame > max_possible_frame))
 		return -EINVAL;
 
+	spin_lock_bh(&adapter->mbx_lock);
 	/* notify the PF of our intent to use this size of frame */
 	ret = hw->mac.ops.set_rlpml(hw, max_frame);
+	spin_unlock_bh(&adapter->mbx_lock);
 	if (ret)
 		return -EINVAL;
 
-- 
2.7.4
