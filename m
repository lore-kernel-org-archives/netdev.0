From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] igb: fix rtnl race in PM resume path
Date: Thu, 10 May 2012 18:38:37 -0700
Message-ID: <1336700317-31929-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Benjamin Poirier <bpoirier@suse.de>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:53863 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754253Ab2EKBik (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2012 21:38:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Poirier <bpoirier@suse.de>

Since the caller (PM resume code) is not the one holding rtnl, when taking the
'else' branch rtnl may be released at any moment, thereby defeating the whole
purpose of this code block.

Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
This patch is also available on my net tree on kernel.org, but did not
send a pull-request since I did not see the point in pulling a single
patch.

The following are changes since commit 0e0c55165b638e96c8d7097ea638aa368daa268a:
  Merge branch 'sfc-3.4' of git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master
---
 drivers/net/ethernet/intel/igb/igb_main.c |   20 ++++++--------------
 1 files changed, 6 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index d223500..8683ca4 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1111,9 +1111,12 @@ msi_only:
 		adapter->flags |= IGB_FLAG_HAS_MSI;
 out:
 	/* Notify the stack of the (possibly) reduced queue counts. */
+	rtnl_lock();
 	netif_set_real_num_tx_queues(adapter->netdev, adapter->num_tx_queues);
-	return netif_set_real_num_rx_queues(adapter->netdev,
-					    adapter->num_rx_queues);
+	err = netif_set_real_num_rx_queues(adapter->netdev,
+		adapter->num_rx_queues);
+	rtnl_unlock();
+	return err;
 }
 
 /**
@@ -6796,18 +6799,7 @@ static int igb_resume(struct device *dev)
 	pci_enable_wake(pdev, PCI_D3hot, 0);
 	pci_enable_wake(pdev, PCI_D3cold, 0);
 
-	if (!rtnl_is_locked()) {
-		/*
-		 * shut up ASSERT_RTNL() warning in
-		 * netif_set_real_num_tx/rx_queues.
-		 */
-		rtnl_lock();
-		err = igb_init_interrupt_scheme(adapter);
-		rtnl_unlock();
-	} else {
-		err = igb_init_interrupt_scheme(adapter);
-	}
-	if (err) {
+	if (igb_init_interrupt_scheme(adapter)) {
 		dev_err(&pdev->dev, "Unable to allocate memory for queues\n");
 		return -ENOMEM;
 	}
-- 
1.7.7.6
