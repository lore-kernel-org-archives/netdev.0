From: prasanna.panchamukhi@riverbed.com
Subject: [PATCH] e100: Don't enable interrupts while exiting polling
Date: Tue, 17 May 2011 17:16:21 -0700
Message-ID: <1305677781-16768-1-git-send-email-prasanna.panchamukhi@riverbed.com>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	prasanna.panchamukhi@riverbed.com
To: bruce.w.allan@intel.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from eng.riverbed.com ([208.70.196.44]:59425 "EHLO
	smtp2.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756439Ab1ERAQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 20:16:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Interrupts remain enabled while exiting the e100_poll(), when the driver is
down. Anything bad can happen resulting in a crash.
The solution is not to enable the interrupts while the driver is down.

Signed-off-by: Prasanna S. Panchamukhi <prasanna.panchamukhi@riverbed.com>
---
 drivers/net/e100.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index abbf229..479219f 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -426,6 +426,7 @@ enum cb_command {
 };
 
 enum e100_state_t {
+	__E100_DOWN,
 	__E100_TESTING
 };
 
@@ -2177,7 +2178,8 @@ static int e100_poll(struct napi_struct *napi, int budget)
 	/* If budget not fully consumed, exit the polling mode */
 	if (work_done < budget) {
 		napi_complete(napi);
-		e100_enable_irq(nic);
+		if (!test_bit(__E100_DOWN, &nic->state))
+			e100_enable_irq(nic);
 	}
 
 	return work_done;
@@ -2230,6 +2232,7 @@ static int e100_up(struct nic *nic)
 {
 	int err;
 
+	clear_bit(__E100_DOWN, &nic->state);
 	if ((err = e100_rx_alloc_list(nic)))
 		return err;
 	if ((err = e100_alloc_cbs(nic)))
@@ -2242,6 +2245,7 @@ static int e100_up(struct nic *nic)
 	if ((err = request_irq(nic->pdev->irq, e100_intr, IRQF_SHARED,
 		nic->netdev->name, nic->netdev)))
 		goto err_no_irq;
+	set_bit(__E100_DOWN, &nic->state);
 	netif_wake_queue(nic->netdev);
 	napi_enable(&nic->napi);
 	/* enable ints _after_ enabling poll, preventing a race between
@@ -2917,7 +2921,9 @@ err_out_free_dev:
 static void __devexit e100_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct nic *nic = netdev_priv(netdev);
 
+	set_bit(__E100_DOWN, &nic->state);
 	if (netdev) {
 		struct nic *nic = netdev_priv(netdev);
 		unregister_netdev(netdev);
-- 
1.7.0.4

