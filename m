From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/20] fm10k: split fm10k_reinit into two functions
Date: Wed, 20 Jul 2016 15:23:48 -0700
Message-ID: <1469053438-85381-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21457 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755371AbcGTWYE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 18:24:04 -0400
In-Reply-To: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

There are several flows in the driver which perform the similar function
of tearing down software and restoring software to recover from certain
errors or PCIe events, including:

  * fm10k_reinit
  * fm10k_suspend/resume
  * fm10k_io_error_detected/fm10k_io_resume

In addition, we want to implement a .reset_notify() handler as well
which will also perform similar function.

Rework how the driver codes reset and resume flows by separating out the
reinit logic into two functions "fm10k_prepare_for_reset" and
"fm10k_handle_reset". This first step will allow us to re-use this
functionality in the similar blocks of code instead of re-coding the
same sequence of events slightly different.

The end result should be more maintainable and correct, fixing several
inconsistencies with the work flow.

The new functions expect to take the rtnl_lock() themselves, and it does
have the unfortunate side effect of having the reinit flow take then
release then take the rtnl_lock. However, this minor downside is
out weighted by the benefits of code reduction and reducing needless
difference between these flows.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 33 +++++++++++++++++++++++-----
 1 file changed, 28 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 7c9b20c..2963b41 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -136,11 +136,9 @@ static void fm10k_detach_subtask(struct fm10k_intfc *interface)
 	rtnl_unlock();
 }
 
-static void fm10k_reinit(struct fm10k_intfc *interface)
+static void fm10k_prepare_for_reset(struct fm10k_intfc *interface)
 {
 	struct net_device *netdev = interface->netdev;
-	struct fm10k_hw *hw = &interface->hw;
-	int err;
 
 	WARN_ON(in_interrupt());
 
@@ -165,6 +163,17 @@ static void fm10k_reinit(struct fm10k_intfc *interface)
 	/* delay any future reset requests */
 	interface->last_reset = jiffies + (10 * HZ);
 
+	rtnl_unlock();
+}
+
+static int fm10k_handle_reset(struct fm10k_intfc *interface)
+{
+	struct net_device *netdev = interface->netdev;
+	struct fm10k_hw *hw = &interface->hw;
+	int err;
+
+	rtnl_lock();
+
 	/* reset and initialize the hardware so it is in a known state */
 	err = hw->mac.ops.reset_hw(hw);
 	if (err) {
@@ -185,7 +194,7 @@ static void fm10k_reinit(struct fm10k_intfc *interface)
 		goto reinit_err;
 	}
 
-	/* reassociate interrupts */
+	/* re-associate interrupts */
 	err = fm10k_mbx_request_irq(interface);
 	if (err)
 		goto err_mbx_irq;
@@ -219,7 +228,7 @@ static void fm10k_reinit(struct fm10k_intfc *interface)
 
 	clear_bit(__FM10K_RESETTING, &interface->state);
 
-	return;
+	return err;
 err_open:
 	fm10k_mbx_free_irq(interface);
 err_mbx_irq:
@@ -230,6 +239,20 @@ reinit_err:
 	rtnl_unlock();
 
 	clear_bit(__FM10K_RESETTING, &interface->state);
+
+	return err;
+}
+
+static void fm10k_reinit(struct fm10k_intfc *interface)
+{
+	int err;
+
+	fm10k_prepare_for_reset(interface);
+
+	err = fm10k_handle_reset(interface);
+	if (err)
+		dev_err(&interface->pdev->dev,
+			"fm10k_handle_reset failed: %d\n", err);
 }
 
 static void fm10k_reset_subtask(struct fm10k_intfc *interface)
-- 
2.5.5
