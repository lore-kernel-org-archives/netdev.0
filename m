From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/14] ixgbevf: Commonize mailbox write/read
Date: Fri, 22 Jul 2016 23:49:49 -0700
Message-ID: <1469256591-109822-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469256591-109822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:6141 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751244AbcGWGuO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 02:50:14 -0400
In-Reply-To: <1469256591-109822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Nguyen <anthony.l.nguyen@intel.com>

With changes to ixgbevf_write_msg_read_ack(), other functions are
performing the same operations done here; change those functions to
utilize ixgbevf_write_msg_read_ack().

Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/vf.c | 35 ++++++---------------------------
 1 file changed, 6 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index 4862bc2..a52f70e 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -267,7 +267,6 @@ static s32 ixgbevf_get_mac_addr_vf(struct ixgbe_hw *hw, u8 *mac_addr)
 
 static s32 ixgbevf_set_uc_addr_vf(struct ixgbe_hw *hw, u32 index, u8 *addr)
 {
-	struct ixgbe_mbx_info *mbx = &hw->mbx;
 	u32 msgbuf[3], msgbuf_chk;
 	u8 *msg_addr = (u8 *)(&msgbuf[1]);
 	s32 ret_val;
@@ -284,11 +283,8 @@ static s32 ixgbevf_set_uc_addr_vf(struct ixgbe_hw *hw, u32 index, u8 *addr)
 
 	if (addr)
 		ether_addr_copy(msg_addr, addr);
-	ret_val = mbx->ops.write_posted(hw, msgbuf, 3);
-
-	if (!ret_val)
-		ret_val = mbx->ops.read_posted(hw, msgbuf, 3);
 
+	ret_val = ixgbevf_write_msg_read_ack(hw, msgbuf, msgbuf, 3);
 	if (!ret_val) {
 		msgbuf[0] &= ~IXGBE_VT_MSGTYPE_CTS;
 
@@ -437,7 +433,6 @@ int ixgbevf_get_rss_key_locked(struct ixgbe_hw *hw, u8 *rss_key)
 static s32 ixgbevf_set_rar_vf(struct ixgbe_hw *hw, u32 index, u8 *addr,
 			      u32 vmdq)
 {
-	struct ixgbe_mbx_info *mbx = &hw->mbx;
 	u32 msgbuf[3];
 	u8 *msg_addr = (u8 *)(&msgbuf[1]);
 	s32 ret_val;
@@ -445,10 +440,8 @@ static s32 ixgbevf_set_rar_vf(struct ixgbe_hw *hw, u32 index, u8 *addr,
 	memset(msgbuf, 0, sizeof(msgbuf));
 	msgbuf[0] = IXGBE_VF_SET_MAC_ADDR;
 	ether_addr_copy(msg_addr, addr);
-	ret_val = mbx->ops.write_posted(hw, msgbuf, 3);
 
-	if (!ret_val)
-		ret_val = mbx->ops.read_posted(hw, msgbuf, 3);
+	ret_val = ixgbevf_write_msg_read_ack(hw, msgbuf, msgbuf, 2);
 
 	msgbuf[0] &= ~IXGBE_VT_MSGTYPE_CTS;
 
@@ -545,7 +538,6 @@ static s32 ixgbevf_hv_update_mc_addr_list_vf(struct ixgbe_hw *hw,
  **/
 static s32 ixgbevf_update_xcast_mode(struct ixgbe_hw *hw, int xcast_mode)
 {
-	struct ixgbe_mbx_info *mbx = &hw->mbx;
 	u32 msgbuf[2];
 	s32 err;
 
@@ -559,11 +551,7 @@ static s32 ixgbevf_update_xcast_mode(struct ixgbe_hw *hw, int xcast_mode)
 	msgbuf[0] = IXGBE_VF_UPDATE_XCAST_MODE;
 	msgbuf[1] = xcast_mode;
 
-	err = mbx->ops.write_posted(hw, msgbuf, 2);
-	if (err)
-		return err;
-
-	err = mbx->ops.read_posted(hw, msgbuf, 2);
+	err = ixgbevf_write_msg_read_ack(hw, msgbuf, msgbuf, 2);
 	if (err)
 		return err;
 
@@ -592,7 +580,6 @@ static s32 ixgbevf_hv_update_xcast_mode(struct ixgbe_hw *hw, int xcast_mode)
 static s32 ixgbevf_set_vfta_vf(struct ixgbe_hw *hw, u32 vlan, u32 vind,
 			       bool vlan_on)
 {
-	struct ixgbe_mbx_info *mbx = &hw->mbx;
 	u32 msgbuf[2];
 	s32 err;
 
@@ -601,11 +588,7 @@ static s32 ixgbevf_set_vfta_vf(struct ixgbe_hw *hw, u32 vlan, u32 vind,
 	/* Setting the 8 bit field MSG INFO to TRUE indicates "add" */
 	msgbuf[0] |= vlan_on << IXGBE_VT_MSGINFO_SHIFT;
 
-	err = mbx->ops.write_posted(hw, msgbuf, 2);
-	if (err)
-		goto mbx_err;
-
-	err = mbx->ops.read_posted(hw, msgbuf, 2);
+	err = ixgbevf_write_msg_read_ack(hw, msgbuf, msgbuf, 2);
 	if (err)
 		goto mbx_err;
 
@@ -853,11 +836,8 @@ static int ixgbevf_negotiate_api_version_vf(struct ixgbe_hw *hw, int api)
 	msg[0] = IXGBE_VF_API_NEGOTIATE;
 	msg[1] = api;
 	msg[2] = 0;
-	err = hw->mbx.ops.write_posted(hw, msg, 3);
-
-	if (!err)
-		err = hw->mbx.ops.read_posted(hw, msg, 3);
 
+	err = ixgbevf_write_msg_read_ack(hw, msg, msg, 3);
 	if (!err) {
 		msg[0] &= ~IXGBE_VT_MSGTYPE_CTS;
 
@@ -906,11 +886,8 @@ int ixgbevf_get_queues(struct ixgbe_hw *hw, unsigned int *num_tcs,
 	/* Fetch queue configuration from the PF */
 	msg[0] = IXGBE_VF_GET_QUEUE;
 	msg[1] = msg[2] = msg[3] = msg[4] = 0;
-	err = hw->mbx.ops.write_posted(hw, msg, 5);
-
-	if (!err)
-		err = hw->mbx.ops.read_posted(hw, msg, 5);
 
+	err = ixgbevf_write_msg_read_ack(hw, msg, msg, 5);
 	if (!err) {
 		msg[0] &= ~IXGBE_VT_MSGTYPE_CTS;
 
-- 
2.5.5
