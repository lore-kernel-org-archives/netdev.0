From: Bruce Allan <bruce.w.allan@intel.com>
Subject: [PATCH] vfio-pci: PCI_DEV_FLAGS_ASSIGNED flag not set when PCI
 device is assigned
Date: Tue, 12 May 2015 18:35:50 -0700
Message-ID: <20150513013550.10328.1416.stgit@bwallan-smackover2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
To: kvm@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:5399 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965002AbbEMBfw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 May 2015 21:35:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A number of PCI device drivers supporting SR-IOV use pci_vfs_assigned() to
check if there are any VF devices assigned by a VMM prior to disabling
SR-IOV (i.e. bnx2x, be2net, fm10k, i40e, igb, ixgbe, qlcnic).  This check
works fine with the legacy device assignment (pci-stub enables the device)
which calls pci_set_dev_assigned().  The newer VFIO-based assignment
(vfio-pci enables device) doesn't call pci_set_dev_assigned() potentially
leading to issues in those drivers when disabling SR-IOV with VFs assigned.

Add calls to pci_[set|clear]_dev_assigned() to set the flag as expected.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
---
 drivers/vfio/pci/vfio_pci.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/vfio/pci/vfio_pci.c b/drivers/vfio/pci/vfio_pci.c
index 69fab0f..3f368ce 100644
--- a/drivers/vfio/pci/vfio_pci.c
+++ b/drivers/vfio/pci/vfio_pci.c
@@ -956,6 +956,8 @@ static int vfio_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 		return ret;
 	}
 
+	pci_set_dev_assigned(pdev);
+
 	if (vfio_pci_is_vga(pdev)) {
 		vga_client_register(pdev, vdev, NULL, vfio_pci_set_vga_decode);
 		vga_set_legacy_decoding(pdev,
@@ -990,6 +992,8 @@ static void vfio_pci_remove(struct pci_dev *pdev)
 	iommu_group_put(pdev->dev.iommu_group);
 	kfree(vdev);
 
+	pci_clear_dev_assigned(pdev);
+
 	if (vfio_pci_is_vga(pdev)) {
 		vga_client_register(pdev, NULL, NULL, NULL);
 		vga_set_legacy_decoding(pdev,
