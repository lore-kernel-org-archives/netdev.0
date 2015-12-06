From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/15] fm10k: always check init_hw for errors
Date: Sun,  6 Dec 2015 00:01:22 -0800
Message-ID: <1449388894-128573-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449388894-128573-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24651 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751686AbbLFIBg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Dec 2015 03:01:36 -0500
In-Reply-To: <1449388894-128573-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

A recent change modified init_hw in some flows the function may fail on
VF devices. For example, if a VF doesn't yet own its own queues.
However, many callers of init_hw didn't bother to check the error code.
Other callers checked but only displayed diagnostic messages without
actually handling the consequences.

Fix this by (a) always returning and preventing the netdevice from going
up, and (b) printing the diagnostic in every flow for consistency. This
should resolve an issue where VF drivers would attempt to come up
before the PF has finished assigning queues.

In addition, change the dmesg output to explicitly show the actual
function that failed, instead of combining reset_hw and init_hw into a
single check, to help for future debugging.

Fixes: 1d568b0f6424 ("fm10k: do not assume VF always has 1 queue")
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Reviewed-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 34 ++++++++++++++++++++++++----
 1 file changed, 29 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 1af4b22..9c21d1e 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -163,9 +163,17 @@ static void fm10k_reinit(struct fm10k_intfc *interface)
 	interface->last_reset = jiffies + (10 * HZ);
 
 	/* reset and initialize the hardware so it is in a known state */
-	err = hw->mac.ops.reset_hw(hw) ? : hw->mac.ops.init_hw(hw);
-	if (err)
+	err = hw->mac.ops.reset_hw(hw);
+	if (err) {
+		dev_err(&interface->pdev->dev, "reset_hw failed: %d\n", err);
+		goto reinit_err;
+	}
+
+	err = hw->mac.ops.init_hw(hw);
+	if (err) {
 		dev_err(&interface->pdev->dev, "init_hw failed: %d\n", err);
+		goto reinit_err;
+	}
 
 	/* reassociate interrupts */
 	fm10k_mbx_request_irq(interface);
@@ -193,6 +201,10 @@ static void fm10k_reinit(struct fm10k_intfc *interface)
 
 	fm10k_iov_resume(interface->pdev);
 
+reinit_err:
+	if (err)
+		netif_device_detach(netdev);
+
 	rtnl_unlock();
 
 	clear_bit(__FM10K_RESETTING, &interface->state);
@@ -1684,7 +1696,13 @@ static int fm10k_sw_init(struct fm10k_intfc *interface,
 	interface->last_reset = jiffies + (10 * HZ);
 
 	/* reset and initialize the hardware so it is in a known state */
-	err = hw->mac.ops.reset_hw(hw) ? : hw->mac.ops.init_hw(hw);
+	err = hw->mac.ops.reset_hw(hw);
+	if (err) {
+		dev_err(&pdev->dev, "reset_hw failed: %d\n", err);
+		return err;
+	}
+
+	err = hw->mac.ops.init_hw(hw);
 	if (err) {
 		dev_err(&pdev->dev, "init_hw failed: %d\n", err);
 		return err;
@@ -2064,8 +2082,10 @@ static int fm10k_resume(struct pci_dev *pdev)
 
 	/* reset hardware to known state */
 	err = hw->mac.ops.init_hw(&interface->hw);
-	if (err)
+	if (err) {
+		dev_err(&pdev->dev, "init_hw failed: %d\n", err);
 		return err;
+	}
 
 	/* reset statistics starting values */
 	hw->mac.ops.rebind_hw_stats(hw, &interface->stats);
@@ -2241,7 +2261,11 @@ static void fm10k_io_resume(struct pci_dev *pdev)
 	int err = 0;
 
 	/* reset hardware to known state */
-	hw->mac.ops.init_hw(&interface->hw);
+	err = hw->mac.ops.init_hw(&interface->hw);
+	if (err) {
+		dev_err(&pdev->dev, "init_hw failed: %d\n", err);
+		return;
+	}
 
 	/* reset statistics starting values */
 	hw->mac.ops.rebind_hw_stats(hw, &interface->stats);
-- 
2.5.0
