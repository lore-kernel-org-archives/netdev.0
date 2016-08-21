From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/6] ixgbevf: fix incorrect MAC address on load
Date: Sat, 20 Aug 2016 20:22:18 -0700
Message-ID: <1471749742-7080-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471749742-7080-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:61110 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752265AbcHUDWZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 20 Aug 2016 23:22:25 -0400
In-Reply-To: <1471749742-7080-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

The PF driver was only receiving the first 4 bytes of the MAC due
to an incorrect size parameter for ixgbevf_write_msg_read_ack()
in ixgbevf_set_rar_vf().

Correct the size by calculating it on a fly for all instances where
we call ixgbevf_write_msg_read_ack()

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/vf.c | 21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index a52f70e..d46ba1d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -284,7 +284,8 @@ static s32 ixgbevf_set_uc_addr_vf(struct ixgbe_hw *hw, u32 index, u8 *addr)
 	if (addr)
 		ether_addr_copy(msg_addr, addr);
 
-	ret_val = ixgbevf_write_msg_read_ack(hw, msgbuf, msgbuf, 3);
+	ret_val = ixgbevf_write_msg_read_ack(hw, msgbuf, msgbuf,
+					     sizeof(msgbuf) / sizeof(u32));
 	if (!ret_val) {
 		msgbuf[0] &= ~IXGBE_VT_MSGTYPE_CTS;
 
@@ -441,7 +442,8 @@ static s32 ixgbevf_set_rar_vf(struct ixgbe_hw *hw, u32 index, u8 *addr,
 	msgbuf[0] = IXGBE_VF_SET_MAC_ADDR;
 	ether_addr_copy(msg_addr, addr);
 
-	ret_val = ixgbevf_write_msg_read_ack(hw, msgbuf, msgbuf, 2);
+	ret_val = ixgbevf_write_msg_read_ack(hw, msgbuf, msgbuf,
+					     sizeof(msgbuf) / sizeof(u32));
 
 	msgbuf[0] &= ~IXGBE_VT_MSGTYPE_CTS;
 
@@ -551,7 +553,8 @@ static s32 ixgbevf_update_xcast_mode(struct ixgbe_hw *hw, int xcast_mode)
 	msgbuf[0] = IXGBE_VF_UPDATE_XCAST_MODE;
 	msgbuf[1] = xcast_mode;
 
-	err = ixgbevf_write_msg_read_ack(hw, msgbuf, msgbuf, 2);
+	err = ixgbevf_write_msg_read_ack(hw, msgbuf, msgbuf,
+					 sizeof(msgbuf) / sizeof(u32));
 	if (err)
 		return err;
 
@@ -588,7 +591,8 @@ static s32 ixgbevf_set_vfta_vf(struct ixgbe_hw *hw, u32 vlan, u32 vind,
 	/* Setting the 8 bit field MSG INFO to TRUE indicates "add" */
 	msgbuf[0] |= vlan_on << IXGBE_VT_MSGINFO_SHIFT;
 
-	err = ixgbevf_write_msg_read_ack(hw, msgbuf, msgbuf, 2);
+	err = ixgbevf_write_msg_read_ack(hw, msgbuf, msgbuf,
+					 sizeof(msgbuf) / sizeof(u32));
 	if (err)
 		goto mbx_err;
 
@@ -791,7 +795,8 @@ static s32 ixgbevf_set_rlpml_vf(struct ixgbe_hw *hw, u16 max_size)
 	msgbuf[0] = IXGBE_VF_SET_LPE;
 	msgbuf[1] = max_size;
 
-	ret_val = ixgbevf_write_msg_read_ack(hw, msgbuf, msgbuf, 2);
+	ret_val = ixgbevf_write_msg_read_ack(hw, msgbuf, msgbuf,
+					     sizeof(msgbuf) / sizeof(u32));
 	if (ret_val)
 		return ret_val;
 	if ((msgbuf[0] & IXGBE_VF_SET_LPE) &&
@@ -837,7 +842,8 @@ static int ixgbevf_negotiate_api_version_vf(struct ixgbe_hw *hw, int api)
 	msg[1] = api;
 	msg[2] = 0;
 
-	err = ixgbevf_write_msg_read_ack(hw, msg, msg, 3);
+	err = ixgbevf_write_msg_read_ack(hw, msg, msg,
+					 sizeof(msg) / sizeof(u32));
 	if (!err) {
 		msg[0] &= ~IXGBE_VT_MSGTYPE_CTS;
 
@@ -887,7 +893,8 @@ int ixgbevf_get_queues(struct ixgbe_hw *hw, unsigned int *num_tcs,
 	msg[0] = IXGBE_VF_GET_QUEUE;
 	msg[1] = msg[2] = msg[3] = msg[4] = 0;
 
-	err = ixgbevf_write_msg_read_ack(hw, msg, msg, 5);
+	err = ixgbevf_write_msg_read_ack(hw, msg, msg,
+					 sizeof(msg) / sizeof(u32));
 	if (!err) {
 		msg[0] &= ~IXGBE_VT_MSGTYPE_CTS;
 
-- 
2.7.4
