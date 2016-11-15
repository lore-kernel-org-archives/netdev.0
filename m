From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH net-next v8 1/9] devres: add devm_alloc_percpu()
Date: Tue, 15 Nov 2016 10:41:01 +0200
Message-ID: <1479199269-9748-2-git-send-email-madalin.bucur@nxp.com>
References: <1479199269-9748-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
        <davem@davemloft.net>, <oss@buserror.net>, <ppc@mindchasers.com>,
        <joe@perches.com>, <pebolle@tiscali.nl>,
        <joakim.tjernlund@infinera.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479199269-9748-1-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce managed counterparts for alloc_percpu() and free_percpu().
Add devm_alloc_percpu() and devm_free_percpu() into the managed
interfaces list.

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 Documentation/driver-model/devres.txt |  4 +++
 drivers/base/devres.c                 | 66 +++++++++++++++++++++++++++++++++++
 include/linux/device.h                | 19 ++++++++++
 3 files changed, 89 insertions(+)

diff --git a/Documentation/driver-model/devres.txt b/Documentation/driver-model/devres.txt
index 1670708..ca9d1eb 100644
--- a/Documentation/driver-model/devres.txt
+++ b/Documentation/driver-model/devres.txt
@@ -332,6 +332,10 @@ MEM
 MFD
  devm_mfd_add_devices()
 
+PER-CPU MEM
+  devm_alloc_percpu()
+  devm_free_percpu()
+
 PCI
   pcim_enable_device()	: after success, all PCI ops become managed
   pcim_pin_device()	: keep PCI device enabled after release
diff --git a/drivers/base/devres.c b/drivers/base/devres.c
index 8fc654f..71d5770 100644
--- a/drivers/base/devres.c
+++ b/drivers/base/devres.c
@@ -10,6 +10,7 @@
 #include <linux/device.h>
 #include <linux/module.h>
 #include <linux/slab.h>
+#include <linux/percpu.h>
 
 #include "base.h"
 
@@ -985,3 +986,68 @@ void devm_free_pages(struct device *dev, unsigned long addr)
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
+ * @align: Alignment of per-cpu memory to allocate
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
+	if (!p) {
+		free_percpu(pcpu);
+		return NULL;
+	}
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
index bc41e87..a00105c 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -698,6 +698,25 @@ static inline int devm_add_action_or_reset(struct device *dev,
 	return ret;
 }
 
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
+	((typeof(type) __percpu *)__devm_alloc_percpu((dev), sizeof(type), \
+						      __alignof__(type)))
+
+void __percpu *__devm_alloc_percpu(struct device *dev, size_t size,
+				   size_t align);
+void devm_free_percpu(struct device *dev, void __percpu *pdata);
+
 struct device_dma_parameters {
 	/*
 	 * a low level driver may set these to teach IOMMU code about
-- 
2.1.0
