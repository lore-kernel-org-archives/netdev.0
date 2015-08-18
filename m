From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] igb: Teardown SR-IOV before unregister_netdev()
Date: Tue, 18 Aug 2015 14:09:13 -0700
Message-ID: <1439932162-1995-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1439932162-1995-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alex Williamson <alex.williamson@redhat.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:5294 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753531AbbHRVJ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 17:09:27 -0400
In-Reply-To: <1439932162-1995-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 67ac0ea..8d22298 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2809,14 +2809,14 @@ static void igb_remove(struct pci_dev *pdev)
 	 */
 	igb_release_hw_control(adapter);
 
-	unregister_netdev(netdev);
-
-	igb_clear_interrupt_scheme(adapter);
-
 #ifdef CONFIG_PCI_IOV
 	igb_disable_sriov(pdev);
 #endif
 
+	unregister_netdev(netdev);
+
+	igb_clear_interrupt_scheme(adapter);
+
 	pci_iounmap(pdev, hw->hw_addr);
 	if (hw->flash_address)
 		iounmap(hw->flash_address);
-- 
2.4.3
