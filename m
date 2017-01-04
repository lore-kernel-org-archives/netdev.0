From: Emil Tantilov <emil.s.tantilov@intel.com>
Subject: [PATCH 1/2] PCI: introduce locked pci_add/remove_virtfn
Date: Tue, 03 Jan 2017 16:48:26 -0800
Message-ID: <20170104004826.17866.77074.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: linux-pci@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26148 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S967086AbdADA5B (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 19:57:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is to allow moving the mutex lock outside of
pci_iov_add/rem_virtfn() for enabling/disabling SRIOV, while
still making it possible to call the _locked version like it is
the case for PPC's eeh_driver.

CC: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
---
 arch/powerpc/kernel/eeh_driver.c |    4 ++--
 drivers/pci/iov.c                |   31 ++++++++++++++++++++++++-------
 include/linux/pci.h              |    4 ++--
 3 files changed, 28 insertions(+), 11 deletions(-)

diff --git a/arch/powerpc/kernel/eeh_driver.c b/arch/powerpc/kernel/eeh_driver.c
index d88573b..81aaea7 100644
--- a/arch/powerpc/kernel/eeh_driver.c
+++ b/arch/powerpc/kernel/eeh_driver.c
@@ -441,7 +441,7 @@ static void *eeh_add_virt_device(void *data, void *userdata)
 	}
 
 #ifdef CONFIG_PPC_POWERNV
-	pci_iov_add_virtfn(edev->physfn, pdn->vf_index, 0);
+	pci_iov_add_virtfn_locked(edev->physfn, pdn->vf_index, 0);
 #endif
 	return NULL;
 }
@@ -499,7 +499,7 @@ static void *eeh_rmv_device(void *data, void *userdata)
 #ifdef CONFIG_PPC_POWERNV
 		struct pci_dn *pdn = eeh_dev_to_pdn(edev);
 
-		pci_iov_remove_virtfn(edev->physfn, pdn->vf_index, 0);
+		pci_iov_remove_virtfn_locked(edev->physfn, pdn->vf_index, 0);
 		edev->pdev = NULL;
 
 		/*
diff --git a/drivers/pci/iov.c b/drivers/pci/iov.c
index 4722782..fea322db 100644
--- a/drivers/pci/iov.c
+++ b/drivers/pci/iov.c
@@ -113,7 +113,7 @@ resource_size_t pci_iov_resource_size(struct pci_dev *dev, int resno)
 	return dev->sriov->barsz[resno - PCI_IOV_RESOURCES];
 }
 
-int pci_iov_add_virtfn(struct pci_dev *dev, int id, int reset)
+static int pci_iov_add_virtfn(struct pci_dev *dev, int id, int reset)
 {
 	int i;
 	int rc = -ENOMEM;
@@ -124,7 +124,6 @@ int pci_iov_add_virtfn(struct pci_dev *dev, int id, int reset)
 	struct pci_sriov *iov = dev->sriov;
 	struct pci_bus *bus;
 
-	mutex_lock(&iov->dev->sriov->lock);
 	bus = virtfn_add_bus(dev->bus, pci_iov_virtfn_bus(dev, id));
 	if (!bus)
 		goto failed;
@@ -162,7 +161,6 @@ int pci_iov_add_virtfn(struct pci_dev *dev, int id, int reset)
 		__pci_reset_function(virtfn);
 
 	pci_device_add(virtfn, virtfn->bus);
-	mutex_unlock(&iov->dev->sriov->lock);
 
 	pci_bus_add_device(virtfn);
 	sprintf(buf, "virtfn%u", id);
@@ -191,11 +189,22 @@ int pci_iov_add_virtfn(struct pci_dev *dev, int id, int reset)
 	return rc;
 }
 
-void pci_iov_remove_virtfn(struct pci_dev *dev, int id, int reset)
+int pci_iov_add_virtfn_locked(struct pci_dev *dev, int id, int reset)
+{
+	struct pci_sriov *iov = dev->sriov;
+	int rc;
+
+	mutex_lock(&iov->dev->sriov->lock);
+	rc = pci_iov_add_virtfn(dev, id, reset);
+	mutex_unlock(&iov->dev->sriov->lock);
+
+	return rc;
+}
+
+static void pci_iov_remove_virtfn(struct pci_dev *dev, int id, int reset)
 {
 	char buf[VIRTFN_ID_LEN];
 	struct pci_dev *virtfn;
-	struct pci_sriov *iov = dev->sriov;
 
 	virtfn = pci_get_domain_bus_and_slot(pci_domain_nr(dev->bus),
 					     pci_iov_virtfn_bus(dev, id),
@@ -218,16 +227,24 @@ void pci_iov_remove_virtfn(struct pci_dev *dev, int id, int reset)
 	if (virtfn->dev.kobj.sd)
 		sysfs_remove_link(&virtfn->dev.kobj, "physfn");
 
-	mutex_lock(&iov->dev->sriov->lock);
 	pci_stop_and_remove_bus_device(virtfn);
 	virtfn_remove_bus(dev->bus, virtfn->bus);
-	mutex_unlock(&iov->dev->sriov->lock);
 
 	/* balance pci_get_domain_bus_and_slot() */
 	pci_dev_put(virtfn);
 	pci_dev_put(dev);
 }
 
+void pci_iov_remove_virtfn_locked(struct pci_dev *dev, int id, int reset)
+{
+	struct pci_sriov *iov = dev->sriov;
+
+	mutex_lock(&iov->dev->sriov->lock);
+	pci_iov_remove_virtfn(dev, id, reset);
+	mutex_unlock(&iov->dev->sriov->lock);
+}
+
+
 int __weak pcibios_sriov_enable(struct pci_dev *pdev, u16 num_vfs)
 {
 	return 0;
diff --git a/include/linux/pci.h b/include/linux/pci.h
index e2d1a12..4351ceb7 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1872,8 +1872,8 @@ static inline void pci_mmcfg_late_init(void) { }
 
 int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn);
 void pci_disable_sriov(struct pci_dev *dev);
-int pci_iov_add_virtfn(struct pci_dev *dev, int id, int reset);
-void pci_iov_remove_virtfn(struct pci_dev *dev, int id, int reset);
+int pci_iov_add_virtfn_locked(struct pci_dev *dev, int id, int reset);
+void pci_iov_remove_virtfn_locked(struct pci_dev *dev, int id, int reset);
 int pci_num_vf(struct pci_dev *dev);
 int pci_vfs_assigned(struct pci_dev *dev);
 int pci_sriov_set_totalvfs(struct pci_dev *dev, u16 numvfs);
