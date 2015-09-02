From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 18/19] ixgbe: Remove bimodal SR-IOV disabling
Date: Tue,  1 Sep 2015 18:14:02 -0700
Message-ID: <1441156443-33381-19-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alex Williamson <alex.williamson@redhat.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59618 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752999AbbIBBOO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 21:14:14 -0400
In-Reply-To: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Williamson <alex.williamson@redhat.com>

When unbinding an SR-IOV device with VFs configured from ixgbe, the
driver behaves in one of two ways.  If max_vfs was specified, the
SR-IOV state is disabled, removing the VFs.  The occurs regardless of
whether the VF count was later modified through sysfs.  If however
max_vfs is zero, such as by not specifying the module parameter, the
VFs persist after the PF is unbound from ixgbe.  If the PF is then
bound to vfio-pci to be assigned to a VM, the PF is non-functional.

>From the comment, commit da36b64736cf ("ixgbe: Implement PCI SR-IOV
sysfs callback operation") clearly intended this alternate behavior,
but probably didn't realize the PF doesn't work in this mode.

This bimodal behavior is confusing to users and results in a state
where the PF is broken for other uses unless the user sets
sriov_numvfs to zero prior to unbinding the device.  Remove this
behavior so that VFs are removed and the PF is functional for other
uses after unbind, regardless of the way VFs are enabled.

Signed-off-by: Alex Williamson <alex.williamson@redhat.com>
Acked-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 54dfad9..63b2cfe 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9023,12 +9023,7 @@ static void ixgbe_remove(struct pci_dev *pdev)
 		unregister_netdev(netdev);
 
 #ifdef CONFIG_PCI_IOV
-	/*
-	 * Only disable SR-IOV on unload if the user specified the now
-	 * deprecated max_vfs module parameter.
-	 */
-	if (max_vfs)
-		ixgbe_disable_sriov(adapter);
+	ixgbe_disable_sriov(adapter);
 #endif
 	ixgbe_clear_interrupt_scheme(adapter);
 
-- 
2.4.3
