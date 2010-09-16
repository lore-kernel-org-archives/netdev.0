From: Maciej Sosnowski <maciej.sosnowski@intel.com>
Subject: [PATCH] dca: disable dca on IOAT ver.3.0 multiple-IOH platforms
Date: Thu, 16 Sep 2010 18:02:26 +0200
Message-ID: <20100916160217.20315.35536.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: dan.j.williams@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Direct Cache Access is not supported on IOAT ver.3.0 multiple-IOH platforms.
This patch blocks registering of dca providers when multiple IOH detected with IOAT ver.3.0.

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
---

 drivers/dca/dca-core.c |   85 +++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 79 insertions(+), 6 deletions(-)

diff --git a/drivers/dca/dca-core.c b/drivers/dca/dca-core.c
index 8661c84..b98c676 100644
--- a/drivers/dca/dca-core.c
+++ b/drivers/dca/dca-core.c
@@ -39,6 +39,10 @@ static DEFINE_SPINLOCK(dca_lock);
 
 static LIST_HEAD(dca_domains);
 
+static BLOCKING_NOTIFIER_HEAD(dca_provider_chain);
+
+static int dca_providers_blocked;
+
 static struct pci_bus *dca_pci_rc_from_dev(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
@@ -70,6 +74,60 @@ static void dca_free_domain(struct dca_d
 	kfree(domain);
 }
 
+static int dca_provider_ioat_ver_3_0(struct device *dev)
+{
+	struct pci_dev *pdev = to_pci_dev(dev);
+
+	return ((pdev->vendor == PCI_VENDOR_ID_INTEL) &&
+		((pdev->device == PCI_DEVICE_ID_INTEL_IOAT_TBG0) ||
+		(pdev->device == PCI_DEVICE_ID_INTEL_IOAT_TBG1) ||
+		(pdev->device == PCI_DEVICE_ID_INTEL_IOAT_TBG2) ||
+		(pdev->device == PCI_DEVICE_ID_INTEL_IOAT_TBG3) ||
+		(pdev->device == PCI_DEVICE_ID_INTEL_IOAT_TBG4) ||
+		(pdev->device == PCI_DEVICE_ID_INTEL_IOAT_TBG5) ||
+		(pdev->device == PCI_DEVICE_ID_INTEL_IOAT_TBG6) ||
+		(pdev->device == PCI_DEVICE_ID_INTEL_IOAT_TBG7)));
+}
+
+static void unregister_dca_providers(void)
+{
+	struct dca_provider *dca, *_dca;
+	struct list_head unregistered_providers;
+	struct dca_domain *domain;
+	unsigned long flags;
+
+	blocking_notifier_call_chain(&dca_provider_chain,
+				     DCA_PROVIDER_REMOVE, NULL);
+
+	INIT_LIST_HEAD(&unregistered_providers);
+
+	spin_lock_irqsave(&dca_lock, flags);
+
+	if (list_empty(&dca_domains)) {
+		spin_unlock_irqrestore(&dca_lock, flags);
+		return;
+	}
+
+	/* at this point only one domain in the list is expected */
+	domain = list_first_entry(&dca_domains, struct dca_domain, node);
+	if (!domain)
+		return;
+
+	list_for_each_entry_safe(dca, _dca, &domain->dca_providers, node) {
+		list_del(&dca->node);
+		list_add(&dca->node, &unregistered_providers);
+	}
+
+	dca_free_domain(domain);
+
+	spin_unlock_irqrestore(&dca_lock, flags);
+
+	list_for_each_entry_safe(dca, _dca, &unregistered_providers, node) {
+		dca_sysfs_remove_provider(dca);
+		list_del(&dca->node);
+	}
+}
+
 static struct dca_domain *dca_find_domain(struct pci_bus *rc)
 {
 	struct dca_domain *domain;
@@ -90,9 +148,13 @@ static struct dca_domain *dca_get_domain
 	domain = dca_find_domain(rc);
 
 	if (!domain) {
-		domain = dca_allocate_domain(rc);
-		if (domain)
-			list_add(&domain->node, &dca_domains);
+		if (dca_provider_ioat_ver_3_0(dev) && !list_empty(&dca_domains)) {
+			dca_providers_blocked = 1;
+		} else {
+			domain = dca_allocate_domain(rc);
+			if (domain)
+				list_add(&domain->node, &dca_domains);
+		}
 	}
 
 	return domain;
@@ -293,8 +355,6 @@ void free_dca_provider(struct dca_provid
 }
 EXPORT_SYMBOL_GPL(free_dca_provider);
 
-static BLOCKING_NOTIFIER_HEAD(dca_provider_chain);
-
 /**
  * register_dca_provider - register a dca provider
  * @dca - struct created by alloc_dca_provider()
@@ -306,6 +366,13 @@ int register_dca_provider(struct dca_pro
 	unsigned long flags;
 	struct dca_domain *domain;
 
+	spin_lock_irqsave(&dca_lock, flags);
+	if (dca_providers_blocked) {
+		spin_unlock_irqrestore(&dca_lock, flags);
+		return -ENODEV;
+	}
+	spin_unlock_irqrestore(&dca_lock, flags);
+
 	err = dca_sysfs_add_provider(dca, dev);
 	if (err)
 		return err;
@@ -313,7 +380,13 @@ int register_dca_provider(struct dca_pro
 	spin_lock_irqsave(&dca_lock, flags);
 	domain = dca_get_domain(dev);
 	if (!domain) {
-		spin_unlock_irqrestore(&dca_lock, flags);
+		if (dca_providers_blocked) {
+			spin_unlock_irqrestore(&dca_lock, flags);
+			dca_sysfs_remove_provider(dca);
+			unregister_dca_providers();
+		} else {
+			spin_unlock_irqrestore(&dca_lock, flags);
+		}
 		return -ENODEV;
 	}
 	list_add(&dca->node, &domain->dca_providers);
