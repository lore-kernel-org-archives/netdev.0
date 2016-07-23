From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] ixgbevf: fix NACK check in ixgbevf_set_uc_addr_vf()
Date: Fri, 22 Jul 2016 23:49:38 -0700
Message-ID: <1469256591-109822-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469256591-109822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55381 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750949AbcGWGuJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 02:50:09 -0400
In-Reply-To: <1469256591-109822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Fix the NACK check in ixgbevf_set_uc_addr_vf() for instances where
index != 0.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/vf.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index e670d3b..aa2b1e8 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -256,7 +256,7 @@ static s32 ixgbevf_get_mac_addr_vf(struct ixgbe_hw *hw, u8 *mac_addr)
 static s32 ixgbevf_set_uc_addr_vf(struct ixgbe_hw *hw, u32 index, u8 *addr)
 {
 	struct ixgbe_mbx_info *mbx = &hw->mbx;
-	u32 msgbuf[3];
+	u32 msgbuf[3], msgbuf_chk;
 	u8 *msg_addr = (u8 *)(&msgbuf[1]);
 	s32 ret_val;
 
@@ -268,6 +268,8 @@ static s32 ixgbevf_set_uc_addr_vf(struct ixgbe_hw *hw, u32 index, u8 *addr)
 	 */
 	msgbuf[0] |= index << IXGBE_VT_MSGINFO_SHIFT;
 	msgbuf[0] |= IXGBE_VF_SET_MACVLAN;
+	msgbuf_chk = msgbuf[0];
+
 	if (addr)
 		ether_addr_copy(msg_addr, addr);
 	ret_val = mbx->ops.write_posted(hw, msgbuf, 3);
@@ -275,12 +277,12 @@ static s32 ixgbevf_set_uc_addr_vf(struct ixgbe_hw *hw, u32 index, u8 *addr)
 	if (!ret_val)
 		ret_val = mbx->ops.read_posted(hw, msgbuf, 3);
 
-	msgbuf[0] &= ~IXGBE_VT_MSGTYPE_CTS;
+	if (!ret_val) {
+		msgbuf[0] &= ~IXGBE_VT_MSGTYPE_CTS;
 
-	if (!ret_val)
-		if (msgbuf[0] ==
-		    (IXGBE_VF_SET_MACVLAN | IXGBE_VT_MSGTYPE_NACK))
-			ret_val = -ENOMEM;
+		if (msgbuf[0] == (msgbuf_chk | IXGBE_VT_MSGTYPE_NACK))
+			return -ENOMEM;
+	}
 
 	return ret_val;
 }
-- 
2.5.5
