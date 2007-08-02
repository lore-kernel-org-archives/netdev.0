From: Brandon Philips <brandon@suse.de>
Subject: [patch 4/5][RFC] Implement devm_kcalloc
Date: Thu, 2 Aug 2007 15:45:45 -0700
Message-ID: <20070802224545.GF5181@ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: teheo@suse.de, Brandon Philips <bphilips@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:55907 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756401AbXHBWpt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 18:45:49 -0400
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 5DC0312471
	for <netdev@vger.kernel.org>; Fri,  3 Aug 2007 00:45:48 +0200 (CEST)
Content-Disposition: inline; filename="kcalloc-devres.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

devm_kcalloc is a simple wrapper around devm_kzalloc for arrays.  This is
needed because kcalloc is often used in network devices. 

Signed-off-by: Brandon Philips <bphilips@suse.de>

---
 drivers/base/devres.c  |   16 ++++++++++++++++
 include/linux/device.h |    1 +
 2 files changed, 17 insertions(+)

Index: linux-2.6/drivers/base/devres.c
===================================================================
--- linux-2.6.orig/drivers/base/devres.c
+++ linux-2.6/drivers/base/devres.c
@@ -630,6 +630,22 @@ void * devm_kzalloc(struct device *dev, 
 EXPORT_SYMBOL_GPL(devm_kzalloc);
 
 /**
+ * devm_kcalloc - resource-managed kcalloc
+ * @dev: Device to allocate memory for
+ * @n: number of elements.
+ * @size: element size.
+ * @flags: the type of memory to allocate.
+ */
+inline void * devm_kcalloc(struct device * dev, size_t n, size_t size,
+			   gfp_t flags)
+{
+        if (n != 0 && size > ULONG_MAX / n)
+                return NULL;
+        return devm_kzalloc(dev, n * size, flags);
+}
+EXPORT_SYMBOL_GPL(devm_kcalloc);
+
+/**
  * devm_kfree - Resource-managed kfree
  * @dev: Device this memory belongs to
  * @p: Memory to free
Index: linux-2.6/include/linux/device.h
===================================================================
--- linux-2.6.orig/include/linux/device.h
+++ linux-2.6/include/linux/device.h
@@ -402,6 +402,7 @@ extern int devres_release_group(struct d
 
 /* managed kzalloc/kfree for device drivers, no kmalloc, always use kzalloc */
 extern void *devm_kzalloc(struct device *dev, size_t size, gfp_t gfp);
+extern void *devm_kcalloc(struct device *dev, size_t n, size_t size, gfp_t flags);
 extern void devm_kfree(struct device *dev, void *p);
 
 struct device {

-- 
