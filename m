From: Maciej Sosnowski <maciej.sosnowski@intel.com>
Subject: [PATCH] dca: redesign locks
Date: Mon, 02 Feb 2009 18:14:01 +0100
Message-ID: <20090202171312.1559.65827.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42659 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757893AbZBBRXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Feb 2009 12:23:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change spin_locks to irqsave to prevent dead-locks.
Protect adding and deleting to/from dca_providers list.
Drop the lock during dca_sysfs_add_req() and dca_sysfs_remove_req() calls
as they might sleep (use GFP_KERNEL allocation).

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
---

 drivers/dca/dca-core.c |   51 +++++++++++++++++++++++++++++++-----------------
 1 files changed, 33 insertions(+), 18 deletions(-)

diff --git a/drivers/dca/dca-core.c b/drivers/dca/dca-core.c
index 5543384..33bd753 100644
--- a/drivers/dca/dca-core.c
+++ b/drivers/dca/dca-core.c
@@ -28,7 +28,7 @@ #include <linux/notifier.h>
 #include <linux/device.h>
 #include <linux/dca.h>
 
-#define DCA_VERSION "1.4"
+#define DCA_VERSION "1.8"
 
 MODULE_VERSION(DCA_VERSION);
 MODULE_LICENSE("GPL");
@@ -60,16 +60,17 @@ int dca_add_requester(struct device *dev
 {
 	struct dca_provider *dca;
 	int err, slot = -ENODEV;
+	unsigned long flags;
 
 	if (!dev)
 		return -EFAULT;
 
-	spin_lock(&dca_lock);
+	spin_lock_irqsave(&dca_lock, flags);
 
 	/* check if the requester has not been added already */
 	dca = dca_find_provider_by_dev(dev);
 	if (dca) {
-		spin_unlock(&dca_lock);
+		spin_unlock_irqrestore(&dca_lock, flags);
 		return -EEXIST;
 	}
 
@@ -78,19 +79,21 @@ int dca_add_requester(struct device *dev
 		if (slot >= 0)
 			break;
 	}
-	if (slot < 0) {
-		spin_unlock(&dca_lock);
+
+	spin_unlock_irqrestore(&dca_lock, flags);
+
+	if (slot < 0)
 		return slot;
-	}
 
 	err = dca_sysfs_add_req(dca, dev, slot);
 	if (err) {
-		dca->ops->remove_requester(dca, dev);
-		spin_unlock(&dca_lock);
+		spin_lock_irqsave(&dca_lock, flags);
+		if (dca == dca_find_provider_by_dev(dev))
+			dca->ops->remove_requester(dca, dev);
+		spin_unlock_irqrestore(&dca_lock, flags);
 		return err;
 	}
 
-	spin_unlock(&dca_lock);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(dca_add_requester);
@@ -103,25 +106,25 @@ int dca_remove_requester(struct device *
 {
 	struct dca_provider *dca;
 	int slot;
+	unsigned long flags;
 
 	if (!dev)
 		return -EFAULT;
 
-	spin_lock(&dca_lock);
+	spin_lock_irqsave(&dca_lock, flags);
 	dca = dca_find_provider_by_dev(dev);
 	if (!dca) {
-		spin_unlock(&dca_lock);
+		spin_unlock_irqrestore(&dca_lock, flags);
 		return -ENODEV;
 	}
 	slot = dca->ops->remove_requester(dca, dev);
-	if (slot < 0) {
-		spin_unlock(&dca_lock);
+	spin_unlock_irqrestore(&dca_lock, flags);
+
+	if (slot < 0)
 		return slot;
-	}
 
 	dca_sysfs_remove_req(dca, slot);
 
-	spin_unlock(&dca_lock);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(dca_remove_requester);
@@ -135,17 +138,18 @@ u8 dca_common_get_tag(struct device *dev
 {
 	struct dca_provider *dca;
 	u8 tag;
+	unsigned long flags;
 
-	spin_lock(&dca_lock);
+	spin_lock_irqsave(&dca_lock, flags);
 
 	dca = dca_find_provider_by_dev(dev);
 	if (!dca) {
-		spin_unlock(&dca_lock);
+		spin_unlock_irqrestore(&dca_lock, flags);
 		return -ENODEV;
 	}
 	tag = dca->ops->get_tag(dca, dev, cpu);
 
-	spin_unlock(&dca_lock);
+	spin_unlock_irqrestore(&dca_lock, flags);
 	return tag;
 }
 
@@ -217,11 +221,16 @@ static BLOCKING_NOTIFIER_HEAD(dca_provid
 int register_dca_provider(struct dca_provider *dca, struct device *dev)
 {
 	int err;
+	unsigned long flags;
 
 	err = dca_sysfs_add_provider(dca, dev);
 	if (err)
 		return err;
+
+	spin_lock_irqsave(&dca_lock, flags);
 	list_add(&dca->node, &dca_providers);
+	spin_unlock_irqrestore(&dca_lock, flags);
+
 	blocking_notifier_call_chain(&dca_provider_chain,
 				     DCA_PROVIDER_ADD, NULL);
 	return 0;
@@ -234,9 +243,15 @@ EXPORT_SYMBOL_GPL(register_dca_provider)
  */
 void unregister_dca_provider(struct dca_provider *dca)
 {
+	unsigned long flags;
+
 	blocking_notifier_call_chain(&dca_provider_chain,
 				     DCA_PROVIDER_REMOVE, NULL);
+
+	spin_lock_irqsave(&dca_lock, flags);
 	list_del(&dca->node);
+	spin_unlock_irqrestore(&dca_lock, flags);
+
 	dca_sysfs_remove_provider(dca);
 }
 EXPORT_SYMBOL_GPL(unregister_dca_provider);

