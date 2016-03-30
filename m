From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 07/11] ixgbevf: fix error code path when setting MAC address
Date: Wed, 30 Mar 2016 16:00:51 -0700
Message-ID: <1459378855-139837-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459378855-139837-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49527 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755348AbcC3XBU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Mar 2016 19:01:20 -0400
In-Reply-To: <1459378855-139837-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Return error when a MAC address change is rejected by the PF.

This will prevent the user from modifying the MAC address when
that operation is not permitted.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 12 ++++++++----
 drivers/net/ethernet/intel/ixgbevf/vf.c           |  4 +++-
 2 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 6a337bb..b0edae9 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3692,19 +3692,23 @@ static int ixgbevf_set_mac(struct net_device *netdev, void *p)
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct sockaddr *addr = p;
+	int err;
 
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
-	ether_addr_copy(netdev->dev_addr, addr->sa_data);
-	ether_addr_copy(hw->mac.addr, addr->sa_data);
-
 	spin_lock_bh(&adapter->mbx_lock);
 
-	hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0);
+	err = hw->mac.ops.set_rar(hw, 0, addr->sa_data, 0);
 
 	spin_unlock_bh(&adapter->mbx_lock);
 
+	if (err)
+		return -EPERM;
+
+	ether_addr_copy(hw->mac.addr, addr->sa_data);
+	ether_addr_copy(netdev->dev_addr, addr->sa_data);
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index 61a98f4..4d613a4 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -408,8 +408,10 @@ static s32 ixgbevf_set_rar_vf(struct ixgbe_hw *hw, u32 index, u8 *addr,
 
 	/* if nacked the address was rejected, use "perm_addr" */
 	if (!ret_val &&
-	    (msgbuf[0] == (IXGBE_VF_SET_MAC_ADDR | IXGBE_VT_MSGTYPE_NACK)))
+	    (msgbuf[0] == (IXGBE_VF_SET_MAC_ADDR | IXGBE_VT_MSGTYPE_NACK))) {
 		ixgbevf_get_mac_addr_vf(hw, hw->mac.addr);
+		return IXGBE_ERR_MBX;
+	}
 
 	return ret_val;
 }
-- 
2.5.5
