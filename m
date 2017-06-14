From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 9/9] ixgbe: pci_set_drvdata must be called before register_netdev
Date: Tue, 13 Jun 2017 17:38:10 -0700
Message-ID: <20170614003810.33189-10-jeffrey.t.kirsher@intel.com>
References: <20170614003810.33189-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Mahoney <jeffm@suse.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:22692 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753988AbdFNAiX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Jun 2017 20:38:23 -0400
In-Reply-To: <20170614003810.33189-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Mahoney <jeffm@suse.com>

We call pci_set_drvdata immediately after calling register_netdev,
which leaves a window where tasks writing to the sriov_numvfs sysfs
attribute can sneak in and crash the kernel.  register_netdev cleans
up after itself so placing pci_set_drvdata immediately before it
should preserve the intent of commit 0fb6a55cc31f ("ixgbe: fix crash
on rmmod after probe fail").

Fixes: 0fb6a55cc31f ("ixgbe: fix crash on rmmod after probe fail")
Signed-off-by: Jeff Mahoney <jeffm@suse.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index c17c8317e001..f3dc5dea9300 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -10372,11 +10372,11 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			   "hardware.\n");
 	}
 	strcpy(netdev->name, "eth%d");
+	pci_set_drvdata(pdev, adapter);
 	err = register_netdev(netdev);
 	if (err)
 		goto err_register;
 
-	pci_set_drvdata(pdev, adapter);
 
 	/* power down the optics for 82599 SFP+ fiber */
 	if (hw->mac.ops.disable_tx_laser)
-- 
2.12.2
