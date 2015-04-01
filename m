From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [PATCH RFC 01/10] devres: add devm_alloc_percpu()
Date: Wed, 1 Apr 2015 19:19:39 +0300
Message-ID: <1427905179-27755-1-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <gregkh@linuxfoundation.org>,
	"Madalin Bucur" <madalin.bucur@freescale.com>
To: <netdev@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0104.outbound.protection.outlook.com ([157.56.111.104]:50919
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752290AbbDAQTs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 12:19:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce managed counterparts for alloc_percpu() and free_percpu().
Add devm_alloc_percpu() and devm_free_percpu() into the managed
interfaces list.

Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
Tested-by: Madalin-Cristian Bucur <madalin.bucur@freescale.com>
---
 Documentation/driver-model/devres.txt |  4 +++
 drivers/base/devres.c                 | 63 +++++++++++++++++++++++++++++++++++
 include/linux/device.h                | 19 +++++++++++
 3 files changed, 86 insertions(+)

diff --git a/Documentation/driver-model/devres.txt b/Documentation/driver-model/devres.txt
index 6d1e8ee..f105669 100644
--- a/Documentation/driver-model/devres.txt
+++ b/Documentation/driver-model/devres.txt
@@ -307,6 +307,10 @@ MEM
   devm_kvasprintf()
   devm_kzalloc()
 
+PER-CPU MEM
+  devm_alloc_percpu()
+  devm_free_percpu()
+
 PCI
   pcim_enable_device()	: after success, all PCI ops become managed
   pcim_pin_device()	: keep PCI device enabled after release
diff --git a/drivers/base/devres.c b/drivers/base/devres.c
index c8a53d1..6c76e75 100644
--- a/drivers/base/devres.c
+++ b/drivers/base/devres.c
@@ -984,3 +984,66 @@ void devm_free_pages(struct device *dev, unsigned long addr)
 			       &devres));
 }
 EXPORT_SYMBOL_GPL(devm_free_pages);
+
+static void devm_percpu_release(struct device *dev, void *pdata)
+{
+	void __percpu *p;
+
+	p = *(void __percpu **)pdata;
+	free_percpu(p);
+}
+
+static int devm_percpu_match(struct device *dev, void *data, void *p)
+{
+	struct devres *devr = container_of(data, struct devres, data);
+
+	return *(void **)devr->data == p;
+}
+
+/**
+ * __devm_alloc_percpu - Resource-managed alloc_percpu
+ * @dev: Device to allocate per-cpu memory for
+ * @size: Size of per-cpu memory to allocate
+ * @align: Alignement of per-cpu memory to allocate
+ *
+ * Managed alloc_percpu. Per-cpu memory allocated with this function is
+ * automatically freed on driver detach.
+ *
+ * RETURNS:
+ * Pointer to allocated memory on success, NULL on failure.
+ */
+void __percpu *__devm_alloc_percpu(struct device *dev, size_t size,
+		size_t align)
+{
+	void *p;
+	void __percpu *pcpu;
+
+	pcpu = __alloc_percpu(size, align);
+	if (!pcpu)
+		return NULL;
+
+	p = devres_alloc(devm_percpu_release, sizeof(void *), GFP_KERNEL);
+	if (!p)
+		return NULL;
+
+	*(void __percpu **)p = pcpu;
+
+	devres_add(dev, p);
+
+	return pcpu;
+}
+EXPORT_SYMBOL_GPL(__devm_alloc_percpu);
+
+/**
+ * devm_free_percpu - Resource-managed free_percpu
+ * @dev: Device this memory belongs to
+ * @pdata: Per-cpu memory to free
+ *
+ * Free memory allocated with devm_alloc_percpu().
+ */
+void devm_free_percpu(struct device *dev, void __percpu *pdata)
+{
+	WARN_ON(devres_destroy(dev, devm_percpu_release, devm_percpu_match,
+			       (void *)pdata));
+}
+EXPORT_SYMBOL_GPL(devm_free_percpu);
diff --git a/include/linux/device.h b/include/linux/device.h
index 0eb8ee2..5b570f4 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -641,6 +641,25 @@ void __iomem *devm_ioremap_resource(struct device *dev, struct resource *res);
 int devm_add_action(struct device *dev, void (*action)(void *), void *data);
 void devm_remove_action(struct device *dev, void (*action)(void *), void *data);
 
+/**
+ * devm_alloc_percpu - Resource-managed alloc_percpu
+ * @dev: Device to allocate per-cpu memory for
+ * @type: Type to allocate per-cpu memory for
+ *
+ * Managed alloc_percpu. Per-cpu memory allocated with this function is
+ * automatically freed on driver detach.
+ *
+ * RETURNS:
+ * Pointer to allocated memory on success, NULL on failure.
+ */
+#define devm_alloc_percpu(dev, type)      \
+	(typeof(type) __percpu *)__devm_alloc_percpu(dev, sizeof(type), \
+						     __alignof__(type))
+
+void __percpu *__devm_alloc_percpu(struct device *dev, size_t size,
+				   size_t align);
+void devm_free_percpu(struct device *dev, void __percpu *pdata);
+
 struct device_dma_parameters {
 	/*
 	 * a low level driver may set these to teach IOMMU code about
-- 
1.7.11.7
