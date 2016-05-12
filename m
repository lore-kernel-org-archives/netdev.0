From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] driver: ixgbevf: ixgbevf_write/read_posted_mbx should use IXGBE_ERR_MBX to initialize ret_val
Date: Fri, 13 May 2016 01:51:55 +0800
Message-ID: <c74ebf3e68d0207e95f71086693916fe99f10658.1463075515.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>
To: network dev <netdev@vger.kernel.org>,
	intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33146 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751693AbcELRv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 13:51:59 -0400
Received: by mail-pa0-f66.google.com with SMTP id gh9so6670547pac.0
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 10:51:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now ixgbevf_write/read_posted_mbx use -IXGBE_ERR_MBX as the initiative
return value, but it's incorrect, cause in ixgbevf_vlan_rx_add_vid(),
it use err == IXGBE_ERR_MBX, the err returned from mac.ops.set_vfta,
and in ixgbevf_set_vfta_vf, it return from write/read_posted. so we
should initialize err with IXGBE_ERR_MBX, instead of -IXGBE_ERR_MBX.

With this fix, the other functions that called it also can work well,
cause they only care about if err is 0 or not.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 drivers/net/ethernet/intel/ixgbevf/mbx.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.c b/drivers/net/ethernet/intel/ixgbevf/mbx.c
index dc68fea..567ed6d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/mbx.c
+++ b/drivers/net/ethernet/intel/ixgbevf/mbx.c
@@ -85,7 +85,7 @@ static s32 ixgbevf_poll_for_ack(struct ixgbe_hw *hw)
 static s32 ixgbevf_read_posted_mbx(struct ixgbe_hw *hw, u32 *msg, u16 size)
 {
 	struct ixgbe_mbx_info *mbx = &hw->mbx;
-	s32 ret_val = -IXGBE_ERR_MBX;
+	s32 ret_val = IXGBE_ERR_MBX;
 
 	if (!mbx->ops.read)
 		goto out;
@@ -111,7 +111,7 @@ out:
 static s32 ixgbevf_write_posted_mbx(struct ixgbe_hw *hw, u32 *msg, u16 size)
 {
 	struct ixgbe_mbx_info *mbx = &hw->mbx;
-	s32 ret_val = -IXGBE_ERR_MBX;
+	s32 ret_val = IXGBE_ERR_MBX;
 
 	/* exit if either we can't write or there isn't a defined timeout */
 	if (!mbx->ops.write || !mbx->timeout)
-- 
2.1.0
