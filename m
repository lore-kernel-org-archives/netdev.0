From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/9] ixgbe: Fix memory leak when SR-IOV VFs are direct assigned
Date: Thu, 19 Jul 2012 18:23:59 -0700
Message-ID: <1342747446-16132-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342747446-16132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9033 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752087Ab2GTBYO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2012 21:24:14 -0400
In-Reply-To: <1342747446-16132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The VF driver had a memory leak that would occur if VFs were assigned to a
guest.  The amount of leak would vary with the number of VFs but could max
out at about 14K per PF.  To reproduce the leak all you would need to do is
enable all the VFs on the first PF.  Then start a loop of loading and
unloading the driver with max_vfs=63 for the first port.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index c7d831d..4f22668 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -208,6 +208,17 @@ void ixgbe_disable_sriov(struct ixgbe_adapter *adapter)
 	u32 vmdctl;
 	int i;
 
+	/* set num VFs to 0 to prevent access to vfinfo */
+	adapter->num_vfs = 0;
+
+	/* free VF control structures */
+	kfree(adapter->vfinfo);
+	adapter->vfinfo = NULL;
+
+	/* free macvlan list */
+	kfree(adapter->mv_list);
+	adapter->mv_list = NULL;
+
 #ifdef CONFIG_PCI_IOV
 	/* disable iov and allow time for transactions to clear */
 	pci_disable_sriov(adapter->pdev);
@@ -238,11 +249,7 @@ void ixgbe_disable_sriov(struct ixgbe_adapter *adapter)
 		if (adapter->vfinfo[i].vfdev)
 			pci_dev_put(adapter->vfinfo[i].vfdev);
 	}
-	kfree(adapter->vfinfo);
-	kfree(adapter->mv_list);
-	adapter->vfinfo = NULL;
 
-	adapter->num_vfs = 0;
 	adapter->flags &= ~IXGBE_FLAG_SRIOV_ENABLED;
 }
 
-- 
1.7.10.4
