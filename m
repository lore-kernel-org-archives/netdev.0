From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 5/8] ixgbevf: Fix mailbox interrupt ack bug
Date: Thu,  2 Feb 2012 04:20:18 -0800
Message-ID: <1328185221-8591-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328185221-8591-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:61281 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755968Ab2BBMUZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Feb 2012 07:20:25 -0500
In-Reply-To: <1328185221-8591-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Remove jump to out label that was skipping over code to replace the
ack bit in the mailbox cache variable.  This was causing driver mailbox
routines that poll for the PF to ack a message to time out which would
in turn cause all other mailbox messages to fail.  Also replace the
mailbox cache variable message indication bit when a message is found
so that other functions that choose to poll for a mailbox message from
the PF won't miss it.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Robert E Garrett <robertX.e.garrett@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    8 ++++++--
 drivers/net/ethernet/intel/ixgbevf/vf.c           |   19 +++++++++++++++----
 2 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index bed411b..3044a56 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -935,7 +935,11 @@ static irqreturn_t ixgbevf_msix_mbx(int irq, void *data)
 		if (msg & IXGBE_VT_MSGTYPE_NACK)
 			pr_warn("Last Request of type %2.2x to PF Nacked\n",
 				msg & 0xFF);
-		goto out;
+		/*
+		 * Restore the PFSTS bit in case someone is polling for a
+		 * return message from the PF
+		 */
+		hw->mbx.v2p_mailbox |= IXGBE_VFMAILBOX_PFSTS;
 	}
 
 	/*
@@ -945,7 +949,7 @@ static irqreturn_t ixgbevf_msix_mbx(int irq, void *data)
 	 */
 	if (got_ack)
 		hw->mbx.v2p_mailbox |= IXGBE_VFMAILBOX_PFACK;
-out:
+
 	return IRQ_HANDLED;
 }
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index d0138d7..77a19d9 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -283,6 +283,17 @@ static s32 ixgbevf_set_rar_vf(struct ixgbe_hw *hw, u32 index, u8 *addr,
 	return ret_val;
 }
 
+static void ixgbevf_write_msg_read_ack(struct ixgbe_hw *hw,
+					u32 *msg, u16 size)
+{
+	struct ixgbe_mbx_info *mbx = &hw->mbx;
+	u32 retmsg[IXGBE_VFMAILBOX_SIZE];
+	s32 retval = mbx->ops.write_posted(hw, msg, size);
+
+	if (!retval)
+		mbx->ops.read_posted(hw, retmsg, size);
+}
+
 /**
  *  ixgbevf_update_mc_addr_list_vf - Update Multicast addresses
  *  @hw: pointer to the HW structure
@@ -294,7 +305,6 @@ static s32 ixgbevf_update_mc_addr_list_vf(struct ixgbe_hw *hw,
 					  struct net_device *netdev)
 {
 	struct netdev_hw_addr *ha;
-	struct ixgbe_mbx_info *mbx = &hw->mbx;
 	u32 msgbuf[IXGBE_VFMAILBOX_SIZE];
 	u16 *vector_list = (u16 *)&msgbuf[1];
 	u32 cnt, i;
@@ -321,7 +331,7 @@ static s32 ixgbevf_update_mc_addr_list_vf(struct ixgbe_hw *hw,
 		vector_list[i++] = ixgbevf_mta_vector(hw, ha->addr);
 	}
 
-	mbx->ops.write_posted(hw, msgbuf, IXGBE_VFMAILBOX_SIZE);
+	ixgbevf_write_msg_read_ack(hw, msgbuf, IXGBE_VFMAILBOX_SIZE);
 
 	return 0;
 }
@@ -336,7 +346,6 @@ static s32 ixgbevf_update_mc_addr_list_vf(struct ixgbe_hw *hw,
 static s32 ixgbevf_set_vfta_vf(struct ixgbe_hw *hw, u32 vlan, u32 vind,
 			       bool vlan_on)
 {
-	struct ixgbe_mbx_info *mbx = &hw->mbx;
 	u32 msgbuf[2];
 
 	msgbuf[0] = IXGBE_VF_SET_VLAN;
@@ -344,7 +353,9 @@ static s32 ixgbevf_set_vfta_vf(struct ixgbe_hw *hw, u32 vlan, u32 vind,
 	/* Setting the 8 bit field MSG INFO to TRUE indicates "add" */
 	msgbuf[0] |= vlan_on << IXGBE_VT_MSGINFO_SHIFT;
 
-	return mbx->ops.write_posted(hw, msgbuf, 2);
+	ixgbevf_write_msg_read_ack(hw, msgbuf, 2);
+
+	return 0;
 }
 
 /**
-- 
1.7.7.6
