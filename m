From: Maciej Sosnowski <maciej.sosnowski@intel.com>
Subject: [PATCH] dca: registering requesters in multiple dca domains
Date: Thu, 10 Sep 2009 15:05:58 +0200
Message-ID: <20090910130558.30672.84011.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53556 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752243AbZIJNJz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Sep 2009 09:09:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables DCA support on multiple-IOH/multiple-IIO architectures.
It modifies dca module by replacing single dca_providers list
with dca_domains list, each domain containing separate list of providers.
This approach lets dca driver manage multiple domains, i.e. sets of providers
and requesters mapped back to the same PCI root complex device.
The driver takes care to register each requester to a provider
from the same domain.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
---

 drivers/dca/dca-core.c |  122 +++++++++++++++++++++++++++++++++++++++++++-----
 drivers/dma/ioat/pci.c |    2 -
 include/linux/dca.h    |   11 ++++
 3 files changed, 120 insertions(+), 15 deletions(-)

diff --git a/drivers/dca/dca-core.c b/drivers/dca/dca-core.c
index 25b743a..7e318de 100644
--- a/drivers/dca/dca-core.c
+++ b/drivers/dca/dca-core.c
@@ -28,7 +28,7 @@ #include <linux/notifier.h>
 #include <linux/device.h>
 #include <linux/dca.h>
 
-#define DCA_VERSION "1.8"
+#define DCA_VERSION "1.12.1"
 
 MODULE_VERSION(DCA_VERSION);
 MODULE_LICENSE("GPL");
@@ -36,20 +36,92 @@ MODULE_AUTHOR("Intel Corporation");
 
 static DEFINE_SPINLOCK(dca_lock);
 
-static LIST_HEAD(dca_providers);
+static LIST_HEAD(dca_domains);
 
-static struct dca_provider *dca_find_provider_by_dev(struct device *dev)
+static struct pci_bus *dca_pci_rc_from_dev(struct device *dev)
 {
-	struct dca_provider *dca, *ret = NULL;
+	struct pci_dev *pdev = to_pci_dev(dev);
+	struct pci_bus *bus = pdev->bus;
 
-	list_for_each_entry(dca, &dca_providers, node) {
-		if ((!dev) || (dca->ops->dev_managed(dca, dev))) {
-			ret = dca;
-			break;
-		}
+	while (bus->parent)
+		bus = bus->parent;
+
+	return bus;
+}
+
+static struct dca_domain *dca_allocate_domain(struct pci_bus *rc)
+{
+	struct dca_domain *domain;
+
+	domain = kzalloc(sizeof(*domain), GFP_NOWAIT);
+	if (!domain)
+		return NULL;
+
+	INIT_LIST_HEAD(&domain->dca_providers);
+	domain->pci_rc = rc;
+
+	return domain;
+}
+
+static void dca_free_domain(struct dca_domain *domain)
+{
+	list_del(&domain->node);
+	kfree(domain);
+}
+
+static struct dca_domain *dca_find_domain(struct pci_bus *rc)
+{
+	struct dca_domain *domain;
+
+	list_for_each_entry(domain, &dca_domains, node)
+		if (domain->pci_rc == rc)
+			return domain;
+
+	return NULL;
+}
+
+static struct dca_domain *dca_get_domain(struct device *dev)
+{
+	struct pci_bus *rc;
+	struct dca_domain *domain;
+
+	rc = dca_pci_rc_from_dev(dev);
+	domain = dca_find_domain(rc);
+
+	if (!domain) {
+		domain = dca_allocate_domain(rc);
+		if (domain)
+			list_add(&domain->node, &dca_domains);
+	}
+
+	return domain;
+}
+
+static struct dca_provider *dca_find_provider_by_dev(struct device *dev)
+{
+	struct dca_provider *dca;
+	struct pci_bus *rc;
+	struct dca_domain *domain;
+
+	if (dev) {
+		rc = dca_pci_rc_from_dev(dev);
+		domain = dca_find_domain(rc);
+		if (!domain)
+			return NULL;
+	} else {
+		if (!list_empty(&dca_domains))
+			domain = list_first_entry(&dca_domains,
+						  struct dca_domain,
+						  node);
+		else
+			return NULL;
 	}
 
-	return ret;
+	list_for_each_entry(dca, &domain->dca_providers, node)
+		if ((!dev) || (dca->ops->dev_managed(dca, dev)))
+			return dca;
+
+	return NULL;
 }
 
 /**
@@ -61,6 +133,8 @@ int dca_add_requester(struct device *dev
 	struct dca_provider *dca;
 	int err, slot = -ENODEV;
 	unsigned long flags;
+	struct pci_bus *pci_rc;
+	struct dca_domain *domain;
 
 	if (!dev)
 		return -EFAULT;
@@ -74,7 +148,14 @@ int dca_add_requester(struct device *dev
 		return -EEXIST;
 	}
 
-	list_for_each_entry(dca, &dca_providers, node) {
+	pci_rc = dca_pci_rc_from_dev(dev);
+	domain = dca_find_domain(pci_rc);
+	if (!domain) {
+		spin_unlock_irqrestore(&dca_lock, flags);
+		return -ENODEV;
+	}
+
+	list_for_each_entry(dca, &domain->dca_providers, node) {
 		slot = dca->ops->add_requester(dca, dev);
 		if (slot >= 0)
 			break;
@@ -222,13 +303,19 @@ int register_dca_provider(struct dca_pro
 {
 	int err;
 	unsigned long flags;
+	struct dca_domain *domain;
 
 	err = dca_sysfs_add_provider(dca, dev);
 	if (err)
 		return err;
 
 	spin_lock_irqsave(&dca_lock, flags);
-	list_add(&dca->node, &dca_providers);
+	domain = dca_get_domain(dev);
+	if (!domain) {
+		spin_unlock_irqrestore(&dca_lock, flags);
+		return -ENODEV;
+	}
+	list_add(&dca->node, &domain->dca_providers);
 	spin_unlock_irqrestore(&dca_lock, flags);
 
 	blocking_notifier_call_chain(&dca_provider_chain,
@@ -241,15 +328,24 @@ EXPORT_SYMBOL_GPL(register_dca_provider)
  * unregister_dca_provider - remove a dca provider
  * @dca - struct created by alloc_dca_provider()
  */
-void unregister_dca_provider(struct dca_provider *dca)
+void unregister_dca_provider(struct dca_provider *dca, struct device *dev)
 {
 	unsigned long flags;
+	struct pci_bus *pci_rc;
+	struct dca_domain *domain;
 
 	blocking_notifier_call_chain(&dca_provider_chain,
 				     DCA_PROVIDER_REMOVE, NULL);
 
 	spin_lock_irqsave(&dca_lock, flags);
+
 	list_del(&dca->node);
+
+	pci_rc = dca_pci_rc_from_dev(dev);
+	domain = dca_find_domain(pci_rc);
+	if (list_empty(&domain->dca_providers))
+		dca_free_domain(domain);
+
 	spin_unlock_irqrestore(&dca_lock, flags);
 
 	dca_sysfs_remove_provider(dca);
diff --git a/drivers/dma/ioat/pci.c b/drivers/dma/ioat/pci.c
index c788fa2..d545fae 100644
--- a/drivers/dma/ioat/pci.c
+++ b/drivers/dma/ioat/pci.c
@@ -175,7 +175,7 @@ static void __devexit ioat_remove(struct
 
 	dev_err(&pdev->dev, "Removing dma and dca services\n");
 	if (device->dca) {
-		unregister_dca_provider(device->dca);
+		unregister_dca_provider(device->dca, &pdev->dev);
 		free_dca_provider(device->dca);
 		device->dca = NULL;
 	}
diff --git a/include/linux/dca.h b/include/linux/dca.h
index 9c20c7e..d27a7a0 100644
--- a/include/linux/dca.h
+++ b/include/linux/dca.h
@@ -20,6 +20,9 @@
  */
 #ifndef DCA_H
 #define DCA_H
+
+#include <linux/pci.h>
+
 /* DCA Provider API */
 
 /* DCA Notifier Interface */
@@ -36,6 +39,12 @@ struct dca_provider {
 	int			 id;
 };
 
+struct dca_domain {
+	struct list_head	node;
+	struct list_head	dca_providers;
+	struct pci_bus		*pci_rc;
+};
+
 struct dca_ops {
 	int	(*add_requester)    (struct dca_provider *, struct device *);
 	int	(*remove_requester) (struct dca_provider *, struct device *);
@@ -47,7 +56,7 @@ struct dca_ops {
 struct dca_provider *alloc_dca_provider(struct dca_ops *ops, int priv_size);
 void free_dca_provider(struct dca_provider *dca);
 int register_dca_provider(struct dca_provider *dca, struct device *dev);
-void unregister_dca_provider(struct dca_provider *dca);
+void unregister_dca_provider(struct dca_provider *dca, struct device *dev);
 
 static inline void *dca_priv(struct dca_provider *dca)
 {

