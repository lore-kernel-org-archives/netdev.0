From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/14] ixgbevf: Add range checking for setting MTU
Date: Fri, 22 Jul 2016 23:49:48 -0700
Message-ID: <1469256591-109822-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469256591-109822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:62671 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751241AbcGWGuN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 02:50:13 -0400
In-Reply-To: <1469256591-109822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Nguyen <anthony.l.nguyen@intel.com>

Currently when setting the VF's MTU, the PF can return a NACK but this
isn't passed on to the VF.  Propagate the results from the PF to the VF
so errors can be reported.

In ixgbevf_change_mtu, return an error and reject the change.

For ixgbevf_configure_rx, log the error for debugging purposes since
the function is buried in a series of Rx config routines that are void.

Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 17 ++++++---
 drivers/net/ethernet/intel/ixgbevf/vf.c           | 42 +++++++++++++++--------
 drivers/net/ethernet/intel/ixgbevf/vf.h           |  2 +-
 3 files changed, 40 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 201e482..d9d6616 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1802,16 +1802,19 @@ static void ixgbevf_configure_rx_ring(struct ixgbevf_adapter *adapter,
  **/
 static void ixgbevf_configure_rx(struct ixgbevf_adapter *adapter)
 {
-	int i;
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
+	int i, ret;
 
 	ixgbevf_setup_psrtype(adapter);
 	if (hw->mac.type >= ixgbe_mac_X550_vf)
 		ixgbevf_setup_vfmrqc(adapter);
 
 	/* notify the PF of our intent to use this size of frame */
-	hw->mac.ops.set_rlpml(hw, netdev->mtu + ETH_HLEN + ETH_FCS_LEN);
+	ret = hw->mac.ops.set_rlpml(hw, netdev->mtu + ETH_HLEN + ETH_FCS_LEN);
+	if (ret)
+		dev_err(&adapter->pdev->dev,
+			"Failed to set MTU at %d\n", netdev->mtu);
 
 	/* Setup the HW Rx Head and Tail Descriptor Pointers and
 	 * the Base and Length of the Rx Descriptor Ring
@@ -3737,6 +3740,7 @@ static int ixgbevf_change_mtu(struct net_device *netdev, int new_mtu)
 	struct ixgbe_hw *hw = &adapter->hw;
 	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
 	int max_possible_frame = MAXIMUM_ETHERNET_VLAN_SIZE;
+	int ret;
 
 	switch (adapter->hw.api_version) {
 	case ixgbe_mbox_api_11:
@@ -3753,14 +3757,17 @@ static int ixgbevf_change_mtu(struct net_device *netdev, int new_mtu)
 	if ((new_mtu < 68) || (max_frame > max_possible_frame))
 		return -EINVAL;
 
+	/* notify the PF of our intent to use this size of frame */
+	ret = hw->mac.ops.set_rlpml(hw, max_frame);
+	if (ret)
+		return -EINVAL;
+
 	hw_dbg(hw, "changing MTU from %d to %d\n",
 	       netdev->mtu, new_mtu);
+
 	/* must set new MTU before calling down or up */
 	netdev->mtu = new_mtu;
 
-	/* notify the PF of our intent to use this size of frame */
-	hw->mac.ops.set_rlpml(hw, max_frame);
-
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index cb409b3..4862bc2 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -33,6 +33,18 @@
  */
 #define IXGBE_HV_RESET_OFFSET           0x201
 
+static inline s32 ixgbevf_write_msg_read_ack(struct ixgbe_hw *hw, u32 *msg,
+					     u32 *retmsg, u16 size)
+{
+	struct ixgbe_mbx_info *mbx = &hw->mbx;
+	s32 retval = mbx->ops.write_posted(hw, msg, size);
+
+	if (retval)
+		return retval;
+
+	return mbx->ops.read_posted(hw, retmsg, size);
+}
+
 /**
  *  ixgbevf_start_hw_vf - Prepare hardware for Tx/Rx
  *  @hw: pointer to hardware structure
@@ -470,17 +482,6 @@ static s32 ixgbevf_hv_set_rar_vf(struct ixgbe_hw *hw, u32 index, u8 *addr,
 	return -EOPNOTSUPP;
 }
 
-static void ixgbevf_write_msg_read_ack(struct ixgbe_hw *hw,
-				       u32 *msg, u16 size)
-{
-	struct ixgbe_mbx_info *mbx = &hw->mbx;
-	u32 retmsg[IXGBE_VFMAILBOX_SIZE];
-	s32 retval = mbx->ops.write_posted(hw, msg, size);
-
-	if (!retval)
-		mbx->ops.read_posted(hw, retmsg, size);
-}
-
 /**
  *  ixgbevf_update_mc_addr_list_vf - Update Multicast addresses
  *  @hw: pointer to the HW structure
@@ -521,7 +522,7 @@ static s32 ixgbevf_update_mc_addr_list_vf(struct ixgbe_hw *hw,
 		vector_list[i++] = ixgbevf_mta_vector(hw, ha->addr);
 	}
 
-	ixgbevf_write_msg_read_ack(hw, msgbuf, IXGBE_VFMAILBOX_SIZE);
+	ixgbevf_write_msg_read_ack(hw, msgbuf, msgbuf, IXGBE_VFMAILBOX_SIZE);
 
 	return 0;
 }
@@ -799,13 +800,22 @@ out:
  *  @hw: pointer to the HW structure
  *  @max_size: value to assign to max frame size
  **/
-static void ixgbevf_set_rlpml_vf(struct ixgbe_hw *hw, u16 max_size)
+static s32 ixgbevf_set_rlpml_vf(struct ixgbe_hw *hw, u16 max_size)
 {
 	u32 msgbuf[2];
+	s32 ret_val;
 
 	msgbuf[0] = IXGBE_VF_SET_LPE;
 	msgbuf[1] = max_size;
-	ixgbevf_write_msg_read_ack(hw, msgbuf, 2);
+
+	ret_val = ixgbevf_write_msg_read_ack(hw, msgbuf, msgbuf, 2);
+	if (ret_val)
+		return ret_val;
+	if ((msgbuf[0] & IXGBE_VF_SET_LPE) &&
+	    (msgbuf[0] & IXGBE_VT_MSGTYPE_NACK))
+		return IXGBE_ERR_MBX;
+
+	return 0;
 }
 
 /**
@@ -814,7 +824,7 @@ static void ixgbevf_set_rlpml_vf(struct ixgbe_hw *hw, u16 max_size)
  * @max_size: value to assign to max frame size
  * Hyper-V variant.
  **/
-static void ixgbevf_hv_set_rlpml_vf(struct ixgbe_hw *hw, u16 max_size)
+static s32 ixgbevf_hv_set_rlpml_vf(struct ixgbe_hw *hw, u16 max_size)
 {
 	u32 reg;
 
@@ -825,6 +835,8 @@ static void ixgbevf_hv_set_rlpml_vf(struct ixgbe_hw *hw, u16 max_size)
 	/* CRC == 4 */
 	reg |= ((max_size + 4) | IXGBE_RXDCTL_RLPML_EN);
 	IXGBE_WRITE_REG(hw, IXGBE_VFRXDCTL(0), reg);
+
+	return 0;
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
index e3a0dea..04d8d4e 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
@@ -69,7 +69,7 @@ struct ixgbe_mac_operations {
 	s32 (*disable_mc)(struct ixgbe_hw *);
 	s32 (*clear_vfta)(struct ixgbe_hw *);
 	s32 (*set_vfta)(struct ixgbe_hw *, u32, u32, bool);
-	void (*set_rlpml)(struct ixgbe_hw *, u16);
+	s32 (*set_rlpml)(struct ixgbe_hw *, u16);
 };
 
 enum ixgbe_mac_type {
-- 
2.5.5
