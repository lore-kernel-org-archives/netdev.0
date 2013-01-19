From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/10] ixgbevf: Synch out of tree and in tree mailbox interrupt handlers
Date: Sat, 19 Jan 2013 05:14:55 -0800
Message-ID: <1358601299-10404-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358601299-10404-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:7088 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751012Ab3ASNPI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Jan 2013 08:15:08 -0500
In-Reply-To: <1358601299-10404-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The out of tree driver and the in kernel driver should use the same
interrupt handling logic for mailbox interrupts.  The difference in
the handlers was causing dissimilar behavior between the two drivers
complicating debug and trouble shooting.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 27 +++++++++++++++++++++--
 1 file changed, 25 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index c27d986..580dfd8 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -750,12 +750,35 @@ static void ixgbevf_set_itr(struct ixgbevf_q_vector *q_vector)
 static irqreturn_t ixgbevf_msix_other(int irq, void *data)
 {
 	struct ixgbevf_adapter *adapter = data;
+	struct pci_dev *pdev = adapter->pdev;
 	struct ixgbe_hw *hw = &adapter->hw;
+	u32 msg;
+	bool got_ack = false;
 
 	hw->mac.get_link_status = 1;
+	if (!hw->mbx.ops.check_for_ack(hw))
+		got_ack = true;
 
-	if (!test_bit(__IXGBEVF_DOWN, &adapter->state))
-		mod_timer(&adapter->watchdog_timer, jiffies);
+	if (!hw->mbx.ops.check_for_msg(hw)) {
+		hw->mbx.ops.read(hw, &msg, 1);
+
+		if ((msg & IXGBE_MBVFICR_VFREQ_MASK) == IXGBE_PF_CONTROL_MSG)
+			mod_timer(&adapter->watchdog_timer,
+				  round_jiffies(jiffies + 1));
+
+		if (msg & IXGBE_VT_MSGTYPE_NACK)
+			dev_info(&pdev->dev,
+				 "Last Request of type %2.2x to PF Nacked\n",
+				 msg & 0xFF);
+		hw->mbx.v2p_mailbox |= IXGBE_VFMAILBOX_PFSTS;
+	}
+
+	/* checking for the ack clears the PFACK bit.  Place
+	 * it back in the v2p_mailbox cache so that anyone
+	 * polling for an ack will not miss it
+	 */
+	if (got_ack)
+		hw->mbx.v2p_mailbox |= IXGBE_VFMAILBOX_PFACK;
 
 	IXGBE_WRITE_REG(hw, IXGBE_VTEIMS, adapter->eims_other);
 
-- 
1.7.11.7
