From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/7] igb: Change how we check for pre-existing and assigned VFs
Date: Sat, 22 Sep 2012 03:30:30 -0700
Message-ID: <1348309836-7107-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1348309836-7107-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stefan Assmann <sassmann@kpanic.de>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:39138 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755191Ab2IVKaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Sep 2012 06:30:46 -0400
In-Reply-To: <1348309836-7107-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Assmann <sassmann@kpanic.de>

Adapt the pre-existing and assigned VFs code to the ixgbe way introduced
in commit 9297127b9cdd8d30c829ef5fd28b7cc0323a7bcd.

Instead of searching the enabled VFs we use pci_num_vf to determine enabled VFs.
By comparing to which PF an assigned VF is owned it's possible to decide
whether to leave it enabled or not.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
Acked-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Robert Garrett <robertx.e.garrett@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      |   1 -
 drivers/net/ethernet/intel/igb/igb_main.c | 104 +++++++-----------------------
 2 files changed, 22 insertions(+), 83 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 43c8e29..6f17f69 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -101,7 +101,6 @@ struct vf_data_storage {
 	u16 pf_vlan; /* When set, guest VLAN config not allowed. */
 	u16 pf_qos;
 	u16 tx_rate;
-	struct pci_dev *vfdev;
 };
 
 #define IGB_VF_FLAG_CTS            0x00000001 /* VF is clear to send data */
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 246646b..0730096 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -172,8 +172,7 @@ static void igb_check_vf_rate_limit(struct igb_adapter *);
 
 #ifdef CONFIG_PCI_IOV
 static int igb_vf_configure(struct igb_adapter *adapter, int vf);
-static int igb_find_enabled_vfs(struct igb_adapter *adapter);
-static int igb_check_vf_assignment(struct igb_adapter *adapter);
+static bool igb_vfs_are_assigned(struct igb_adapter *adapter);
 #endif
 
 #ifdef CONFIG_PM
@@ -2300,11 +2299,11 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 	/* reclaim resources allocated to VFs */
 	if (adapter->vf_data) {
 		/* disable iov and allow time for transactions to clear */
-		if (!igb_check_vf_assignment(adapter)) {
+		if (igb_vfs_are_assigned(adapter)) {
+			dev_info(&pdev->dev, "Unloading driver while VFs are assigned - VFs will not be deallocated\n");
+		} else {
 			pci_disable_sriov(pdev);
 			msleep(500);
-		} else {
-			dev_info(&pdev->dev, "VF(s) assigned to guests!\n");
 		}
 
 		kfree(adapter->vf_data);
@@ -2344,7 +2343,7 @@ static void __devinit igb_probe_vfs(struct igb_adapter * adapter)
 #ifdef CONFIG_PCI_IOV
 	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_hw *hw = &adapter->hw;
-	int old_vfs = igb_find_enabled_vfs(adapter);
+	int old_vfs = pci_num_vf(adapter->pdev);
 	int i;
 
 	/* Virtualization features not supported on i210 family. */
@@ -5037,102 +5036,43 @@ static int igb_notify_dca(struct notifier_block *nb, unsigned long event,
 static int igb_vf_configure(struct igb_adapter *adapter, int vf)
 {
 	unsigned char mac_addr[ETH_ALEN];
-	struct pci_dev *pdev = adapter->pdev;
-	struct e1000_hw *hw = &adapter->hw;
-	struct pci_dev *pvfdev;
-	unsigned int device_id;
-	u16 thisvf_devfn;
 
 	eth_random_addr(mac_addr);
 	igb_set_vf_mac(adapter, vf, mac_addr);
 
-	switch (adapter->hw.mac.type) {
-	case e1000_82576:
-		device_id = IGB_82576_VF_DEV_ID;
-		/* VF Stride for 82576 is 2 */
-		thisvf_devfn = (pdev->devfn + 0x80 + (vf << 1)) |
-			(pdev->devfn & 1);
-		break;
-	case e1000_i350:
-		device_id = IGB_I350_VF_DEV_ID;
-		/* VF Stride for I350 is 4 */
-		thisvf_devfn = (pdev->devfn + 0x80 + (vf << 2)) |
-				(pdev->devfn & 3);
-		break;
-	default:
-		device_id = 0;
-		thisvf_devfn = 0;
-		break;
-	}
-
-	pvfdev = pci_get_device(hw->vendor_id, device_id, NULL);
-	while (pvfdev) {
-		if (pvfdev->devfn == thisvf_devfn)
-			break;
-		pvfdev = pci_get_device(hw->vendor_id,
-					device_id, pvfdev);
-	}
-
-	if (pvfdev)
-		adapter->vf_data[vf].vfdev = pvfdev;
-	else
-		dev_err(&pdev->dev,
-			"Couldn't find pci dev ptr for VF %4.4x\n",
-			thisvf_devfn);
-	return pvfdev != NULL;
+	return 0;
 }
 
-static int igb_find_enabled_vfs(struct igb_adapter *adapter)
+static bool igb_vfs_are_assigned(struct igb_adapter *adapter)
 {
-	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
-	struct pci_dev *pvfdev;
-	u16 vf_devfn = 0;
-	u16 vf_stride;
-	unsigned int device_id;
-	int vfs_found = 0;
+	struct pci_dev *vfdev;
+	int dev_id;
 
 	switch (adapter->hw.mac.type) {
 	case e1000_82576:
-		device_id = IGB_82576_VF_DEV_ID;
-		/* VF Stride for 82576 is 2 */
-		vf_stride = 2;
+		dev_id = IGB_82576_VF_DEV_ID;
 		break;
 	case e1000_i350:
-		device_id = IGB_I350_VF_DEV_ID;
-		/* VF Stride for I350 is 4 */
-		vf_stride = 4;
+		dev_id = IGB_I350_VF_DEV_ID;
 		break;
 	default:
-		device_id = 0;
-		vf_stride = 0;
-		break;
-	}
-
-	vf_devfn = pdev->devfn + 0x80;
-	pvfdev = pci_get_device(hw->vendor_id, device_id, NULL);
-	while (pvfdev) {
-		if (pvfdev->devfn == vf_devfn &&
-		    (pvfdev->bus->number >= pdev->bus->number))
-			vfs_found++;
-		vf_devfn += vf_stride;
-		pvfdev = pci_get_device(hw->vendor_id,
-					device_id, pvfdev);
+		return false;
 	}
 
-	return vfs_found;
-}
-
-static int igb_check_vf_assignment(struct igb_adapter *adapter)
-{
-	int i;
-	for (i = 0; i < adapter->vfs_allocated_count; i++) {
-		if (adapter->vf_data[i].vfdev) {
-			if (adapter->vf_data[i].vfdev->dev_flags &
-			    PCI_DEV_FLAGS_ASSIGNED)
+	/* loop through all the VFs to see if we own any that are assigned */
+	vfdev = pci_get_device(PCI_VENDOR_ID_INTEL, dev_id, NULL);
+	while (vfdev) {
+		/* if we don't own it we don't care */
+		if (vfdev->is_virtfn && vfdev->physfn == pdev) {
+			/* if it is assigned we cannot release it */
+			if (vfdev->dev_flags & PCI_DEV_FLAGS_ASSIGNED)
 				return true;
 		}
+
+		vfdev = pci_get_device(PCI_VENDOR_ID_INTEL, dev_id, vfdev);
 	}
+
 	return false;
 }
 
-- 
1.7.11.4
