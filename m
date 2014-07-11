From: Ethan Zhao <ethan.zhao@oracle.com>
Subject: [PATCH 2/2 V3] PCI: implement VFs assignment
	reference counter
Date: Fri, 11 Jul 2014 20:30:02 +0800
Message-ID: <1405081802-419-2-git-send-email-ethan.zhao@oracle.com>
References: <1405081802-419-1-git-send-email-ethan.zhao@oracle.com>
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
	mitch.a.williams@intel.com, alex.williamson@redhat.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1405081802-419-1-git-send-email-ethan.zhao@oracle.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Current implementation of helper function pci_vfs_assigned() is a
little complex, to get sum of VFs that assigned to VM, access low
level configuration space register and then loop in traversing
device tree.

This patch introduces an atomic reference counter for VFs those
were assigned to VM in struct pci_sriov. and simplify the code in
pci_vfs_assigned().

v3: change the naming of device assignment helpers, because they work
for all kind of PCI device, not only SR-IOV (david.vrabel@citrix.com)

v2: reorder the patchset according to the suggestion from
alex.williamson@redhat.com

Signed-off-by: Ethan Zhao <ethan.zhao@oracle.com>
---
 drivers/pci/iov.c |   42 ++++++++++++++++--------------------------
 drivers/pci/pci.h |    1 +
 2 files changed, 17 insertions(+), 26 deletions(-)

diff --git a/drivers/pci/iov.c b/drivers/pci/iov.c
index 090f827..10efe43 100644
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
@@ -603,43 +604,22 @@ int pci_num_vf(struct pci_dev *dev)
 EXPORT_SYMBOL_GPL(pci_num_vf);
 
 /**
- * pci_vfs_assigned - returns number of VFs are assigned to a guest
- * @dev: the PCI device
+ * pci_vfs_assigned - returns number of VFs are assigned to VM
+ * @dev: the physical PCI device that contains the VFs.
  *
  * Returns number of VFs belonging to this device that are assigned to a guest.
  * If device is not a physical function returns 0.
  */
 int pci_vfs_assigned(struct pci_dev *dev)
 {
-	struct pci_dev *vfdev;
-	unsigned int vfs_assigned = 0;
-	unsigned short dev_id;
 
 	/* only search if we are a PF */
 	if (!dev->is_physfn)
 		return 0;
 
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
-
-	return vfs_assigned;
+	if (dev->sriov)
+		return atomic_read(&dev->sriov->VFs_assigned_cnt);
+	return 0;
 }
 EXPORT_SYMBOL_GPL(pci_vfs_assigned);
 
@@ -650,6 +630,11 @@ EXPORT_SYMBOL_GPL(pci_vfs_assigned);
 void pci_iov_assign_device(struct pci_dev *pdev)
 {
 	pdev->dev_flags |= PCI_DEV_FLAGS_ASSIGNED;
+	if (pdev->is_virtfn && !pdev->is_physfn)
+		if (pdev->physfn)
+			if (pdev->physfn->sriov)
+				atomic_inc(&pdev->physfn->sriov->
+					VFs_assigned_cnt);
 }
 EXPORT_SYMBOL_GPL(pci_iov_assign_device);
 
@@ -660,6 +645,11 @@ EXPORT_SYMBOL_GPL(pci_iov_assign_device);
 void pci_iov_deassign_device(struct pci_dev *pdev)
 {
 	pdev->dev_flags &= ~PCI_DEV_FLAGS_ASSIGNED;
+	if (pdev->is_virtfn && !pdev->is_physfn)
+		if (pdev->physfn)
+			if (pdev->physfn->sriov)
+				atomic_dec(&pdev->physfn->sriov->
+					VFs_assigned_cnt);
 }
 EXPORT_SYMBOL_GPL(pci_iov_deassign_device);
 
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
