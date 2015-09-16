From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/18] ixgbe: Teardown SR-IOV before unregister_netdev()
Date: Tue, 15 Sep 2015 17:36:27 -0700
Message-ID: <1442363803-47237-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alex Williamson <alex.williamson@redhat.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:26285 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752914AbbIPAgr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 20:36:47 -0400
In-Reply-To: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Williamson <alex.williamson@redhat.com>

When the .remove() callback for a PF is called, SR-IOV support for the
device is disabled, which requires unbinding and removing the VFs.
The VFs may be in-use either by the host kernel or userspace, such as
assigned to a VM through vfio-pci.  In this latter case, the VFs may
be removed either by shutting down the VM or hot-unplugging the
devices from the VM.  Unfortunately in the case of a Windows 2012 R2
guest, hot-unplug is broken due to the ordering of the PF driver
teardown.  Disabling SR-IOV prior to unregister_netdev() avoids this
issue.

Signed-off-by: Alex Williamson <alex.williamson@redhat.com>
Acked-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index b9267e2..c04480e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9028,12 +9028,12 @@ static void ixgbe_remove(struct pci_dev *pdev)
 	/* remove the added san mac */
 	ixgbe_del_sanmac_netdev(netdev);
 
-	if (netdev->reg_state == NETREG_REGISTERED)
-		unregister_netdev(netdev);
-
 #ifdef CONFIG_PCI_IOV
 	ixgbe_disable_sriov(adapter);
 #endif
+	if (netdev->reg_state == NETREG_REGISTERED)
+		unregister_netdev(netdev);
+
 	ixgbe_clear_interrupt_scheme(adapter);
 
 	ixgbe_release_hw_control(adapter);
-- 
2.4.3
