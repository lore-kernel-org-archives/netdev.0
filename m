From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/6] ixgbevf: Return error on failure to enable VLAN
Date: Mon, 24 Sep 2012 02:00:07 -0700
Message-ID: <1348477207-27030-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1348477207-27030-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:2616 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751635Ab2IXJAQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 05:00:16 -0400
In-Reply-To: <1348477207-27030-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

With recent kernel changes we can now return errors on a failure to setup a
VLAN filter.  This patch takes advantage of that opportunity so that we can
return either an EIO error in the case of a mailbox failure, or an EACCESS
error in the case of being denied access to the VLAN filter table by the
PF.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Robert Garrett <robertx.e.garrett@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 21 ++++++++++++++++-----
 drivers/net/ethernet/intel/ixgbevf/vf.c           | 20 ++++++++++++++++++--
 2 files changed, 34 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 2ba15ae..cf372ee 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1126,36 +1126,47 @@ static int ixgbevf_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
+	int err;
+
+	if (!hw->mac.ops.set_vfta)
+		return -EOPNOTSUPP;
 
 	spin_lock(&adapter->mbx_lock);
 
 	/* add VID to filter table */
-	if (hw->mac.ops.set_vfta)
-		hw->mac.ops.set_vfta(hw, vid, 0, true);
+	err = hw->mac.ops.set_vfta(hw, vid, 0, true);
 
 	spin_unlock(&adapter->mbx_lock);
 
+	/* translate error return types so error makes sense */
+	if (err == IXGBE_ERR_MBX)
+		return -EIO;
+
+	if (err == IXGBE_ERR_INVALID_ARGUMENT)
+		return -EACCES;
+
 	set_bit(vid, adapter->active_vlans);
 
-	return 0;
+	return err;
 }
 
 static int ixgbevf_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
+	int err = -EOPNOTSUPP;
 
 	spin_lock(&adapter->mbx_lock);
 
 	/* remove VID from filter table */
 	if (hw->mac.ops.set_vfta)
-		hw->mac.ops.set_vfta(hw, vid, 0, false);
+		err = hw->mac.ops.set_vfta(hw, vid, 0, false);
 
 	spin_unlock(&adapter->mbx_lock);
 
 	clear_bit(vid, adapter->active_vlans);
 
-	return 0;
+	return err;
 }
 
 static void ixgbevf_restore_vlan(struct ixgbevf_adapter *adapter)
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index a5e66c7..0c7447e 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -349,16 +349,32 @@ static s32 ixgbevf_update_mc_addr_list_vf(struct ixgbe_hw *hw,
 static s32 ixgbevf_set_vfta_vf(struct ixgbe_hw *hw, u32 vlan, u32 vind,
 			       bool vlan_on)
 {
+	struct ixgbe_mbx_info *mbx = &hw->mbx;
 	u32 msgbuf[2];
+	s32 err;
 
 	msgbuf[0] = IXGBE_VF_SET_VLAN;
 	msgbuf[1] = vlan;
 	/* Setting the 8 bit field MSG INFO to TRUE indicates "add" */
 	msgbuf[0] |= vlan_on << IXGBE_VT_MSGINFO_SHIFT;
 
-	ixgbevf_write_msg_read_ack(hw, msgbuf, 2);
+	err = mbx->ops.write_posted(hw, msgbuf, 2);
+	if (err)
+		goto mbx_err;
 
-	return 0;
+	err = mbx->ops.read_posted(hw, msgbuf, 2);
+	if (err)
+		goto mbx_err;
+
+	/* remove extra bits from the message */
+	msgbuf[0] &= ~IXGBE_VT_MSGTYPE_CTS;
+	msgbuf[0] &= ~(0xFF << IXGBE_VT_MSGINFO_SHIFT);
+
+	if (msgbuf[0] != (IXGBE_VF_SET_VLAN | IXGBE_VT_MSGTYPE_ACK))
+		err = IXGBE_ERR_INVALID_ARGUMENT;
+
+mbx_err:
+	return err;
 }
 
 /**
-- 
1.7.11.4
