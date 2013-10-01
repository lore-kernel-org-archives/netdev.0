From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  2/9] ixgbevf: cleanup redundant mailbox read failure check
Date: Tue,  1 Oct 2013 04:33:49 -0700
Message-ID: <1380627236-3190-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1380627236-3190-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:49978 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751095Ab3JALeA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 07:34:00 -0400
In-Reply-To: <1380627236-3190-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Since we are already checking for read failure in check_link we don't need
to do it here. Instead just make sure the watchdog task gets scheduled, if
we are up, and it can be done there. This will better follow igbvf method
of handling a mailbox event and message timeout.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 29 ++---------------------
 1 file changed, 2 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 59a62bb..b9a78a2 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -756,37 +756,12 @@ static void ixgbevf_set_itr(struct ixgbevf_q_vector *q_vector)
 static irqreturn_t ixgbevf_msix_other(int irq, void *data)
 {
 	struct ixgbevf_adapter *adapter = data;
-	struct pci_dev *pdev = adapter->pdev;
 	struct ixgbe_hw *hw = &adapter->hw;
-	u32 msg;
-	bool got_ack = false;
 
 	hw->mac.get_link_status = 1;
-	if (!hw->mbx.ops.check_for_ack(hw))
-		got_ack = true;
-
-	if (!hw->mbx.ops.check_for_msg(hw)) {
-		hw->mbx.ops.read(hw, &msg, 1);
 
-		if ((msg & IXGBE_MBVFICR_VFREQ_MASK) == IXGBE_PF_CONTROL_MSG) {
-			mod_timer(&adapter->watchdog_timer,
-				  round_jiffies(jiffies + 1));
-			adapter->link_up = false;
-		}
-
-		if (msg & IXGBE_VT_MSGTYPE_NACK)
-			dev_info(&pdev->dev,
-				 "Last Request of type %2.2x to PF Nacked\n",
-				 msg & 0xFF);
-		hw->mbx.v2p_mailbox |= IXGBE_VFMAILBOX_PFSTS;
-	}
-
-	/* checking for the ack clears the PFACK bit.  Place
-	 * it back in the v2p_mailbox cache so that anyone
-	 * polling for an ack will not miss it
-	 */
-	if (got_ack)
-		hw->mbx.v2p_mailbox |= IXGBE_VFMAILBOX_PFACK;
+	if (!test_bit(__IXGBEVF_DOWN, &adapter->state))
+		mod_timer(&adapter->watchdog_timer, jiffies);
 
 	IXGBE_WRITE_REG(hw, IXGBE_VTEIMS, adapter->eims_other);
 
-- 
1.8.3.1
