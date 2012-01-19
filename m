From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 6/9] ixgbevf: Prevent possible race condition by checking for message
Date: Thu, 19 Jan 2012 00:13:31 -0800
Message-ID: <1326960814-16976-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1326960814-16976-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:7452 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754608Ab2ASINy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 03:13:54 -0500
In-Reply-To: <1326960814-16976-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The mailbox interrupt routine might cause a race condition sometimes
and cause a message to be missed.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   39 +++++++++++---------
 1 files changed, 21 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 891162d..1cad3b6 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -917,31 +917,34 @@ static irqreturn_t ixgbevf_msix_mbx(int irq, void *data)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 eicr;
 	u32 msg;
+	bool got_ack = false;
 
 	eicr = IXGBE_READ_REG(hw, IXGBE_VTEICS);
 	IXGBE_WRITE_REG(hw, IXGBE_VTEICR, eicr);
 
-	if (!hw->mbx.ops.check_for_ack(hw)) {
-		/*
-		 * checking for the ack clears the PFACK bit.  Place
-		 * it back in the v2p_mailbox cache so that anyone
-		 * polling for an ack will not miss it.  Also
-		 * avoid the read below because the code to read
-		 * the mailbox will also clear the ack bit.  This was
-		 * causing lost acks.  Just cache the bit and exit
-		 * the IRQ handler.
-		 */
-		hw->mbx.v2p_mailbox |= IXGBE_VFMAILBOX_PFACK;
-		goto out;
-	}
+	if (!hw->mbx.ops.check_for_ack(hw))
+		got_ack = true;
 
-	/* Not an ack interrupt, go ahead and read the message */
-	hw->mbx.ops.read(hw, &msg, 1);
+	if (!hw->mbx.ops.check_for_msg(hw)) {
+		hw->mbx.ops.read(hw, &msg, 1);
 
-	if ((msg & IXGBE_MBVFICR_VFREQ_MASK) == IXGBE_PF_CONTROL_MSG)
-		mod_timer(&adapter->watchdog_timer,
-			  round_jiffies(jiffies + 1));
+		if ((msg & IXGBE_MBVFICR_VFREQ_MASK) == IXGBE_PF_CONTROL_MSG)
+			mod_timer(&adapter->watchdog_timer,
+				  round_jiffies(jiffies + 1));
 
+		if (msg & IXGBE_VT_MSGTYPE_NACK)
+			pr_warn("Last Request of type %2.2x to PF Nacked\n",
+				msg & 0xFF);
+		goto out;
+	}
+
+	/*
+	 * checking for the ack clears the PFACK bit.  Place
+	 * it back in the v2p_mailbox cache so that anyone
+	 * polling for an ack will not miss it
+	 */
+	if (got_ack)
+		hw->mbx.v2p_mailbox |= IXGBE_VFMAILBOX_PFACK;
 out:
 	return IRQ_HANDLED;
 }
-- 
1.7.7.5
