From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 08/14] pci: Add SRIOV helper function to determine if VFs are assigned to guest
Date: Wed, 24 Apr 2013 21:08:41 -0700
Message-ID: <1366862927-1855-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366862927-1855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:33226 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751020Ab3DYEJF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 00:09:05 -0400
In-Reply-To: <1366862927-1855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This function is meant to add a helper function that will determine if a PF
has any VFs that are currently assigned to a guest.  We currently have been
implementing this function per driver, and going forward I would like to avoid
that by making this function generic and using this helper.

v2: Removed extern from declaration of pci_vfs_assigned in pci.h and return
    0 if SR-IOV is disabled which is inline with other PCI SRIOV functions.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Bjorn Helgaas <bhelgaas@google.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/pci/iov.c   | 41 +++++++++++++++++++++++++++++++++++++++++
 include/linux/pci.h |  5 +++++
 2 files changed, 46 insertions(+)

diff --git a/drivers/pci/iov.c b/drivers/pci/iov.c
index ee599f2..c93071d 100644
--- a/drivers/pci/iov.c
+++ b/drivers/pci/iov.c
@@ -729,6 +729,47 @@ int pci_num_vf(struct pci_dev *dev)
 EXPORT_SYMBOL_GPL(pci_num_vf);
 
 /**
+ * pci_vfs_assigned - returns number of VFs are assigned to a guest
+ * @dev: the PCI device
+ *
+ * Returns number of VFs belonging to this device that are assigned to a guest.
+ * If device is not a physical function returns -ENODEV.
+ */
+int pci_vfs_assigned(struct pci_dev *dev)
+{
+	struct pci_dev *vfdev;
+	unsigned int vfs_assigned = 0;
+	unsigned short dev_id;
+
+	/* only search if we are a PF */
+	if (!dev->is_physfn)
+		return 0;
+
+	/*
+	 * determine the device ID for the VFs, the vendor ID will be the
+	 * same as the PF so there is no need to check for that one
+	 */
+	pci_read_config_word(dev, dev->sriov->pos + PCI_SRIOV_VF_DID, &dev_id);
+
+	/* loop through all the VFs to see if we own any that are assigned */
+	vfdev = pci_get_device(dev->vendor, dev_id, NULL);
+	while (vfdev) {
+		/*
+		 * It is considered assigned if it is a virtual function with
+		 * our dev as the physical function and the assigned bit is set
+		 */
+		if (vfdev->is_virtfn && (vfdev->physfn == dev) &&
+		    (vfdev->dev_flags & PCI_DEV_FLAGS_ASSIGNED))
+			vfs_assigned++;
+
+		vfdev = pci_get_device(dev->vendor, dev_id, vfdev);
+	}
+
+	return vfs_assigned;
+}
+EXPORT_SYMBOL_GPL(pci_vfs_assigned);
+
+/**
  * pci_sriov_set_totalvfs -- reduce the TotalVFs available
  * @dev: the PCI PF device
  * @numvfs: number that should be used for TotalVFs supported
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 710067f..43e45ac 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1644,6 +1644,7 @@ extern int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn);
 extern void pci_disable_sriov(struct pci_dev *dev);
 extern irqreturn_t pci_sriov_migration(struct pci_dev *dev);
 extern int pci_num_vf(struct pci_dev *dev);
+int pci_vfs_assigned(struct pci_dev *dev);
 extern int pci_sriov_set_totalvfs(struct pci_dev *dev, u16 numvfs);
 extern int pci_sriov_get_totalvfs(struct pci_dev *dev);
 #else
@@ -1662,6 +1663,10 @@ static inline int pci_num_vf(struct pci_dev *dev)
 {
 	return 0;
 }
+static inline int pci_vfs_assigned(struct pci_dev *dev)
+{
+	return 0;
+}
 static inline int pci_sriov_set_totalvfs(struct pci_dev *dev, u16 numvfs)
 {
 	return 0;
-- 
1.7.11.7
