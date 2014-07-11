From: Ethan Zhao <ethan.zhao@oracle.com>
Subject: [PATCH 1/4] PCI: introduce VFs reference counter and
	simplify pci_vfs_assigned() implementation
Date: Fri, 11 Jul 2014 08:47:19 +0800
Message-ID: <1405039642-23519-1-git-send-email-ethan.zhao@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ethan Zhao <ethan.zhao@oracle.com>, linux.nics@intel.com,
	kvm@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	linux-pci@vger.kernel.org, vaughan.cao@oracle.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ethan.kernel@gmail.com
To: bhelgaas@google.com, konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	david.vrabel@citrix.com, gleb@kernel.org, pbonzini@redhat.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Current implementation of helper function pci_vfs_assigned() is a little complex, to
get sum of VFs that assigned to VM, access low level configuration space register and
then loop in traversing device tree.

This patch introduce an atomic reference counter for VFs that assigned to VM in struct
pci_sriov, and compose two more helper functions

pci_sriov_assign_device(),
pci_sriov_deassign_device()

to replace manipulation to device flag and the meanwhile increase and decease the counter.

Passed building on 3.15.5

Signed-off-by: Ethan Zhao <ethan.zhao@oracle.com>
---
 drivers/pci/iov.c   |   65 ++++++++++++++++++++++++++++----------------------
 drivers/pci/pci.h   |    1 +
 include/linux/pci.h |    4 +++
 3 files changed, 41 insertions(+), 29 deletions(-)

diff --git a/drivers/pci/iov.c b/drivers/pci/iov.c
index de7a747..72e267f 100644
--- a/drivers/pci/iov.c
+++ b/drivers/pci/iov.c
@@ -382,6 +382,7 @@ found:
 	iov->nres = nres;
 	iov->ctrl = ctrl;
 	iov->total_VFs = total;
+	atomic_set(&iov->VFs_assigned_cnt, 0);
 	iov->offset = offset;
 	iov->stride = stride;
 	iov->pgsz = pgsz;
@@ -603,45 +604,51 @@ int pci_num_vf(struct pci_dev *dev)
 EXPORT_SYMBOL_GPL(pci_num_vf);
 
 /**
- * pci_vfs_assigned - returns number of VFs are assigned to a guest
- * @dev: the PCI device
+ * pci_vfs_assigned - returns number of VFs are assigned to VM
+ * @dev: the physical PCI device that contains the VFs.
  *
- * Returns number of VFs belonging to this device that are assigned to a guest.
+ * Returns number of VFs belonging to this device that are assigned to VM.
  * If device is not a physical function returns 0.
  */
 int pci_vfs_assigned(struct pci_dev *dev)
 {
-	struct pci_dev *vfdev;
-	unsigned int vfs_assigned = 0;
-	unsigned short dev_id;
-
-	/* only search if we are a PF */
 	if (!dev->is_physfn)
 		return 0;
+	if (dev->sriov)
+		return atomic_read(&dev->sriov->VFs_assigned_cnt);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(pci_vfs_assigned);
 
-	/*
-	 * determine the device ID for the VFs, the vendor ID will be the
-	 * same as the PF so there is no need to check for that one
-	 */
-	pci_read_config_word(dev, dev->sriov->pos + PCI_SRIOV_VF_DID, &dev_id);
-
-	/* loop through all the VFs to see if we own any that are assigned */
-	vfdev = pci_get_device(dev->vendor, dev_id, NULL);
-	while (vfdev) {
-		/*
-		 * It is considered assigned if it is a virtual function with
-		 * our dev as the physical function and the assigned bit is set
-		 */
-		if (vfdev->is_virtfn && (vfdev->physfn == dev) &&
-		    (vfdev->dev_flags & PCI_DEV_FLAGS_ASSIGNED))
-			vfs_assigned++;
-
-		vfdev = pci_get_device(dev->vendor, dev_id, vfdev);
-	}
+/**
+ * pci_sriov_assign_device - assign device to VM
+ * @pdev: the device to be assigned.
+ */
+void pci_sriov_assign_device(struct pci_dev *pdev)
+{
+	pdev->dev_flags |= PCI_DEV_FLAGS_ASSIGNED;
+	if (pdev->is_virtfn && !pdev->is_physfn)
+		if (pdev->physfn)
+			if (pdev->physfn->sriov)
+				atomic_inc(&pdev->physfn->sriov->
+						VFs_assigned_cnt);
+}
+EXPORT_SYMBOL_GPL(pci_sriov_assign_device);
 
-	return vfs_assigned;
+/**
+ * pci_sriov_deassign_device - deasign device from VM
+ * @pdev: the device to be deassigned.
+ */
+void pci_sriov_deassign_device(struct pci_dev *pdev)
+{
+	pdev->dev_flags &= ~PCI_DEV_FLAGS_ASSIGNED;
+	if (pdev->is_virtfn && !pdev->is_physfn)
+		if (pdev->physfn)
+			if (pdev->physfn->sriov)
+				atomic_dec(&pdev->physfn->sriov->
+						VFs_assigned_cnt);
 }
-EXPORT_SYMBOL_GPL(pci_vfs_assigned);
+EXPORT_SYMBOL_GPL(pci_sriov_deassign_device);
 
 /**
  * pci_sriov_set_totalvfs -- reduce the TotalVFs available
diff --git a/drivers/pci/pci.h b/drivers/pci/pci.h
index 6bd0822..d17bda2 100644
--- a/drivers/pci/pci.h
+++ b/drivers/pci/pci.h
@@ -235,6 +235,7 @@ struct pci_sriov {
 	u32 pgsz;		/* page size for BAR alignment */
 	u8 link;		/* Function Dependency Link */
 	u16 driver_max_VFs;	/* max num VFs driver supports */
+	atomic_t VFs_assigned_cnt; /* counter of VFs assigned to VM */
 	struct pci_dev *dev;	/* lowest numbered PF */
 	struct pci_dev *self;	/* this PF */
 	struct mutex lock;	/* lock for VF bus */
diff --git a/include/linux/pci.h b/include/linux/pci.h
index aab57b4..5cf6833 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1601,6 +1601,8 @@ int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn);
 void pci_disable_sriov(struct pci_dev *dev);
 int pci_num_vf(struct pci_dev *dev);
 int pci_vfs_assigned(struct pci_dev *dev);
+void pci_sriov_assign_device(struct pci_dev *dev);
+void pci_sriov_deassign_device(struct pci_dev *dev);
 int pci_sriov_set_totalvfs(struct pci_dev *dev, u16 numvfs);
 int pci_sriov_get_totalvfs(struct pci_dev *dev);
 #else
@@ -1610,6 +1612,8 @@ static inline void pci_disable_sriov(struct pci_dev *dev) { }
 static inline int pci_num_vf(struct pci_dev *dev) { return 0; }
 static inline int pci_vfs_assigned(struct pci_dev *dev)
 { return 0; }
+static inline void pci_sriov_assign_device(struct pci_dev *dev) { }
+static inline void pci_sriov_deassign_device(struct pci_dev *dev) { }
 static inline int pci_sriov_set_totalvfs(struct pci_dev *dev, u16 numvfs)
 { return 0; }
 static inline int pci_sriov_get_totalvfs(struct pci_dev *dev)
-- 
1.7.1


------------------------------------------------------------------------------
Open source business process management suite built on Java and Eclipse
Turn processes into business applications with Bonita BPM Community Edition
Quickly connect people, data, and systems into organized workflows
Winner of BOSSIE, CODIE, OW2 and Gartner awards
http://p.sf.net/sfu/Bonitasoft
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
