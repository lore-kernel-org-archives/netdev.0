From: Maciej Sosnowski <maciej.sosnowski@intel.com>
Subject: [PATCH v2 4/4] I/OAT: I/OAT version 3.0 support
Date: Fri, 18 Jul 2008 17:29:42 +0200
Message-ID: <20080718152918.21235.33418.stgit@linux.site>
References: <20080718152541.21235.85961.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: shannon.nelson@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44672 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754871AbYGRPjc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 11:39:32 -0400
In-Reply-To: <20080718152541.21235.85961.stgit@linux.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds to ioatdma and dca modules 
support for Intel I/OAT DMA engine ver.3 (aka CB3 device).
The main features of I/OAT ver.3 are:
 * 8 single channel DMA devices (8 channels total)
 * 8 DCA providers, each can accept 2 requesters
 * 8-bit TAG values and 32-bit extended APIC IDs

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
---

 drivers/dca/dca-core.c          |  131 ++++++++++++++++-----
 drivers/dca/dca-sysfs.c         |    3 
 drivers/dma/ioat.c              |   15 ++
 drivers/dma/ioat_dca.c          |  244 ++++++++++++++++++++++++++++++++++++++-
 drivers/dma/ioat_dma.c          |  101 ++++++++++++++--
 drivers/dma/ioatdma.h           |    4 -
 drivers/dma/ioatdma_hw.h        |    1 
 drivers/dma/ioatdma_registers.h |   20 +++
 include/linux/dca.h             |    7 +
 include/linux/pci_ids.h         |    8 +
 10 files changed, 485 insertions(+), 49 deletions(-)

diff --git a/drivers/dca/dca-core.c b/drivers/dca/dca-core.c
index bf5b92f..ec249d2 100644
--- a/drivers/dca/dca-core.c
+++ b/drivers/dca/dca-core.c
@@ -28,13 +28,29 @@ #include <linux/notifier.h>
 #include <linux/device.h>
 #include <linux/dca.h>
 
-MODULE_LICENSE("GPL");
+#define DCA_VERSION "1.4"
 
-/* For now we're assuming a single, global, DCA provider for the system. */
+MODULE_VERSION(DCA_VERSION);
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Intel Corporation");
 
 static DEFINE_SPINLOCK(dca_lock);
 
-static struct dca_provider *global_dca = NULL;
+static LIST_HEAD(dca_providers);
+
+static struct dca_provider *dca_find_provider_by_dev(struct device *dev)
+{
+	struct dca_provider *dca, *ret = NULL;
+
+	list_for_each_entry(dca, &dca_providers, node) {
+		if ((!dev) || (dca->ops->dev_managed(dca, dev))) {
+			ret = dca;
+			break;
+		}
+	}
+
+	return ret;
+}
 
 /**
  * dca_add_requester - add a dca client to the list
@@ -42,25 +58,39 @@ static struct dca_provider *global_dca =
  */
 int dca_add_requester(struct device *dev)
 {
-	int err, slot;
+	struct dca_provider *dca;
+	int err, slot = -ENODEV;
 
-	if (!global_dca)
-		return -ENODEV;
+	if (!dev)
+		return -EFAULT;
 
 	spin_lock(&dca_lock);
-	slot = global_dca->ops->add_requester(global_dca, dev);
-	spin_unlock(&dca_lock);
-	if (slot < 0)
+
+	/* check if the requester has not been added already */
+	dca = dca_find_provider_by_dev(dev);
+	if (dca) {
+		spin_unlock(&dca_lock);
+		return -EEXIST;
+	}
+
+	list_for_each_entry(dca, &dca_providers, node) {
+		slot = dca->ops->add_requester(dca, dev);
+		if (slot >= 0)
+			break;
+	}
+	if (slot < 0) {
+		spin_unlock(&dca_lock);
 		return slot;
+	}
 
-	err = dca_sysfs_add_req(global_dca, dev, slot);
+	err = dca_sysfs_add_req(dca, dev, slot);
 	if (err) {
-		spin_lock(&dca_lock);
-		global_dca->ops->remove_requester(global_dca, dev);
+		dca->ops->remove_requester(dca, dev);
 		spin_unlock(&dca_lock);
 		return err;
 	}
 
+	spin_unlock(&dca_lock);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(dca_add_requester);
@@ -71,30 +101,78 @@ EXPORT_SYMBOL_GPL(dca_add_requester);
  */
 int dca_remove_requester(struct device *dev)
 {
+	struct dca_provider *dca;
 	int slot;
-	if (!global_dca)
-		return -ENODEV;
+
+	if (!dev)
+		return -EFAULT;
 
 	spin_lock(&dca_lock);
-	slot = global_dca->ops->remove_requester(global_dca, dev);
-	spin_unlock(&dca_lock);
-	if (slot < 0)
+	dca = dca_find_provider_by_dev(dev);
+	if (!dca) {
+		spin_unlock(&dca_lock);
+		return -ENODEV;
+	}
+	slot = dca->ops->remove_requester(dca, dev);
+	if (slot < 0) {
+		spin_unlock(&dca_lock);
 		return slot;
+	}
 
-	dca_sysfs_remove_req(global_dca, slot);
+	dca_sysfs_remove_req(dca, slot);
+
+	spin_unlock(&dca_lock);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(dca_remove_requester);
 
 /**
- * dca_get_tag - return the dca tag for the given cpu
+ * dca_common_get_tag - return the dca tag (serves both new and old api)
+ * @dev - the device that wants dca service
  * @cpu - the cpuid as returned by get_cpu()
  */
-u8 dca_get_tag(int cpu)
+u8 dca_common_get_tag(struct device *dev, int cpu)
 {
-	if (!global_dca)
+	struct dca_provider *dca;
+	u8 tag;
+
+	spin_lock(&dca_lock);
+
+	dca = dca_find_provider_by_dev(dev);
+	if (!dca) {
+		spin_unlock(&dca_lock);
 		return -ENODEV;
-	return global_dca->ops->get_tag(global_dca, cpu);
+	}
+	tag = dca->ops->get_tag(dca, dev, cpu);
+
+	spin_unlock(&dca_lock);
+	return tag;
+}
+
+/**
+ * dca3_get_tag - return the dca tag to the requester device
+ *                for the given cpu (new api)
+ * @dev - the device that wants dca service
+ * @cpu - the cpuid as returned by get_cpu()
+ */
+u8 dca3_get_tag(struct device *dev, int cpu)
+{
+	if (!dev)
+		return -EFAULT;
+
+	return dca_common_get_tag(dev, cpu);
+}
+EXPORT_SYMBOL_GPL(dca3_get_tag);
+
+/**
+ * dca_get_tag - return the dca tag for the given cpu (old api)
+ * @cpu - the cpuid as returned by get_cpu()
+ */
+u8 dca_get_tag(int cpu)
+{
+	struct device *dev = NULL;
+
+	return dca_common_get_tag(dev, cpu);
 }
 EXPORT_SYMBOL_GPL(dca_get_tag);
 
@@ -140,12 +218,10 @@ int register_dca_provider(struct dca_pro
 {
 	int err;
 
-	if (global_dca)
-		return -EEXIST;
 	err = dca_sysfs_add_provider(dca, dev);
 	if (err)
 		return err;
-	global_dca = dca;
+	list_add(&dca->node, &dca_providers);
 	blocking_notifier_call_chain(&dca_provider_chain,
 				     DCA_PROVIDER_ADD, NULL);
 	return 0;
@@ -158,11 +234,9 @@ EXPORT_SYMBOL_GPL(register_dca_provider)
  */
 void unregister_dca_provider(struct dca_provider *dca)
 {
-	if (!global_dca)
-		return;
 	blocking_notifier_call_chain(&dca_provider_chain,
 				     DCA_PROVIDER_REMOVE, NULL);
-	global_dca = NULL;
+	list_del(&dca->node);
 	dca_sysfs_remove_provider(dca);
 }
 EXPORT_SYMBOL_GPL(unregister_dca_provider);
@@ -187,6 +261,7 @@ EXPORT_SYMBOL_GPL(dca_unregister_notify)
 
 static int __init dca_init(void)
 {
+	printk(KERN_ERR "dca service started, version %s\n", DCA_VERSION);
 	return dca_sysfs_init();
 }
 
diff --git a/drivers/dca/dca-sysfs.c b/drivers/dca/dca-sysfs.c
index 011328f..3d47e9d 100644
--- a/drivers/dca/dca-sysfs.c
+++ b/drivers/dca/dca-sysfs.c
@@ -13,9 +13,10 @@ static spinlock_t dca_idr_lock;
 int dca_sysfs_add_req(struct dca_provider *dca, struct device *dev, int slot)
 {
 	struct device *cd;
+	static int req_count;
 
 	cd = device_create(dca_class, dca->cd, MKDEV(0, slot + 1),
-			   "requester%d", slot);
+			   "requester%d", req_count++);
 	if (IS_ERR(cd))
 		return PTR_ERR(cd);
 	return 0;
diff --git a/drivers/dma/ioat.c b/drivers/dma/ioat.c
index 16e0fd8..9b16a3a 100644
--- a/drivers/dma/ioat.c
+++ b/drivers/dma/ioat.c
@@ -47,6 +47,16 @@ static struct pci_device_id ioat_pci_tbl
 
 	/* I/OAT v2 platforms */
 	{ PCI_DEVICE(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_IOAT_SNB) },
+
+	/* I/OAT v3 platforms */
+	{ PCI_DEVICE(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_IOAT_TBG0) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_IOAT_TBG1) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_IOAT_TBG2) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_IOAT_TBG3) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_IOAT_TBG4) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_IOAT_TBG5) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_IOAT_TBG6) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_IOAT_TBG7) },
 	{ 0, }
 };
 
@@ -83,6 +93,11 @@ static int ioat_setup_functionality(stru
 		if (device->dma && ioat_dca_enabled)
 			device->dca = ioat2_dca_init(pdev, iobase);
 		break;
+	case IOAT_VER_3_0:
+		device->dma = ioat_dma_probe(pdev, iobase);
+		if (device->dma && ioat_dca_enabled)
+			device->dca = ioat3_dca_init(pdev, iobase);
+		break;
 	default:
 		err = -ENODEV;
 		break;
diff --git a/drivers/dma/ioat_dca.c b/drivers/dma/ioat_dca.c
index 9e92276..6cf622d 100644
--- a/drivers/dma/ioat_dca.c
+++ b/drivers/dma/ioat_dca.c
@@ -37,12 +37,18 @@ #include "ioatdma.h"
 #include "ioatdma_registers.h"
 
 /*
- * Bit 16 of a tag map entry is the "valid" bit, if it is set then bits 0:15
+ * Bit 7 of a tag map entry is the "valid" bit, if it is set then bits 0:6
  * contain the bit number of the APIC ID to map into the DCA tag.  If the valid
  * bit is not set, then the value must be 0 or 1 and defines the bit in the tag.
  */
 #define DCA_TAG_MAP_VALID 0x80
 
+#define DCA3_TAG_MAP_BIT_TO_INV 0x80
+#define DCA3_TAG_MAP_BIT_TO_SEL 0x40
+#define DCA3_TAG_MAP_LITERAL_VAL 0x1
+
+#define DCA_TAG_MAP_MASK 0xDF
+
 /*
  * "Legacy" DCA systems do not implement the DCA register set in the
  * I/OAT device.  Software needs direct support for their tag mappings.
@@ -95,6 +101,7 @@ struct ioat_dca_slot {
 };
 
 #define IOAT_DCA_MAX_REQ 6
+#define IOAT3_DCA_MAX_REQ 2
 
 struct ioat_dca_priv {
 	void __iomem		*iobase;
@@ -171,7 +178,9 @@ static int ioat_dca_remove_requester(str
 	return -ENODEV;
 }
 
-static u8 ioat_dca_get_tag(struct dca_provider *dca, int cpu)
+static u8 ioat_dca_get_tag(struct dca_provider *dca,
+			   struct device *dev,
+			   int cpu)
 {
 	struct ioat_dca_priv *ioatdca = dca_priv(dca);
 	int i, apic_id, bit, value;
@@ -193,10 +202,26 @@ static u8 ioat_dca_get_tag(struct dca_pr
 	return tag;
 }
 
+static int ioat_dca_dev_managed(struct dca_provider *dca,
+				struct device *dev)
+{
+	struct ioat_dca_priv *ioatdca = dca_priv(dca);
+	struct pci_dev *pdev;
+	int i;
+
+	pdev = to_pci_dev(dev);
+	for (i = 0; i < ioatdca->max_requesters; i++) {
+		if (ioatdca->req_slots[i].pdev == pdev)
+			return 1;
+	}
+	return 0;
+}
+
 static struct dca_ops ioat_dca_ops = {
 	.add_requester		= ioat_dca_add_requester,
 	.remove_requester	= ioat_dca_remove_requester,
 	.get_tag		= ioat_dca_get_tag,
+	.dev_managed		= ioat_dca_dev_managed,
 };
 
 
@@ -207,6 +232,8 @@ struct dca_provider *ioat_dca_init(struc
 	u8 *tag_map = NULL;
 	int i;
 	int err;
+	u8 version;
+	u8 max_requesters;
 
 	if (!system_has_dca_enabled(pdev))
 		return NULL;
@@ -237,15 +264,20 @@ struct dca_provider *ioat_dca_init(struc
 	if (tag_map == NULL)
 		return NULL;
 
+	version = readb(iobase + IOAT_VER_OFFSET);
+	if (version == IOAT_VER_3_0)
+		max_requesters = IOAT3_DCA_MAX_REQ;
+	else
+		max_requesters = IOAT_DCA_MAX_REQ;
+
 	dca = alloc_dca_provider(&ioat_dca_ops,
 			sizeof(*ioatdca) +
-			(sizeof(struct ioat_dca_slot) * IOAT_DCA_MAX_REQ));
+			(sizeof(struct ioat_dca_slot) * max_requesters));
 	if (!dca)
 		return NULL;
 
 	ioatdca = dca_priv(dca);
-	ioatdca->max_requesters = IOAT_DCA_MAX_REQ;
-
+	ioatdca->max_requesters = max_requesters;
 	ioatdca->dca_base = iobase + 0x54;
 
 	/* copy over the APIC ID to DCA tag mapping */
@@ -323,11 +355,13 @@ static int ioat2_dca_remove_requester(st
 	return -ENODEV;
 }
 
-static u8 ioat2_dca_get_tag(struct dca_provider *dca, int cpu)
+static u8 ioat2_dca_get_tag(struct dca_provider *dca,
+			    struct device *dev,
+			    int cpu)
 {
 	u8 tag;
 
-	tag = ioat_dca_get_tag(dca, cpu);
+	tag = ioat_dca_get_tag(dca, dev, cpu);
 	tag = (~tag) & 0x1F;
 	return tag;
 }
@@ -336,6 +370,7 @@ static struct dca_ops ioat2_dca_ops = {
 	.add_requester		= ioat2_dca_add_requester,
 	.remove_requester	= ioat2_dca_remove_requester,
 	.get_tag		= ioat2_dca_get_tag,
+	.dev_managed		= ioat_dca_dev_managed,
 };
 
 static int ioat2_dca_count_dca_slots(void __iomem *iobase, u16 dca_offset)
@@ -425,3 +460,198 @@ struct dca_provider *ioat2_dca_init(stru
 
 	return dca;
 }
+
+static int ioat3_dca_add_requester(struct dca_provider *dca, struct device *dev)
+{
+	struct ioat_dca_priv *ioatdca = dca_priv(dca);
+	struct pci_dev *pdev;
+	int i;
+	u16 id;
+	u16 global_req_table;
+
+	/* This implementation only supports PCI-Express */
+	if (dev->bus != &pci_bus_type)
+		return -ENODEV;
+	pdev = to_pci_dev(dev);
+	id = dcaid_from_pcidev(pdev);
+
+	if (ioatdca->requester_count == ioatdca->max_requesters)
+		return -ENODEV;
+
+	for (i = 0; i < ioatdca->max_requesters; i++) {
+		if (ioatdca->req_slots[i].pdev == NULL) {
+			/* found an empty slot */
+			ioatdca->requester_count++;
+			ioatdca->req_slots[i].pdev = pdev;
+			ioatdca->req_slots[i].rid = id;
+			global_req_table =
+			      readw(ioatdca->dca_base + IOAT3_DCA_GREQID_OFFSET);
+			writel(id | IOAT_DCA_GREQID_VALID,
+			       ioatdca->iobase + global_req_table + (i * 4));
+			return i;
+		}
+	}
+	/* Error, ioatdma->requester_count is out of whack */
+	return -EFAULT;
+}
+
+static int ioat3_dca_remove_requester(struct dca_provider *dca,
+				      struct device *dev)
+{
+	struct ioat_dca_priv *ioatdca = dca_priv(dca);
+	struct pci_dev *pdev;
+	int i;
+	u16 global_req_table;
+
+	/* This implementation only supports PCI-Express */
+	if (dev->bus != &pci_bus_type)
+		return -ENODEV;
+	pdev = to_pci_dev(dev);
+
+	for (i = 0; i < ioatdca->max_requesters; i++) {
+		if (ioatdca->req_slots[i].pdev == pdev) {
+			global_req_table =
+			      readw(ioatdca->dca_base + IOAT3_DCA_GREQID_OFFSET);
+			writel(0, ioatdca->iobase + global_req_table + (i * 4));
+			ioatdca->req_slots[i].pdev = NULL;
+			ioatdca->req_slots[i].rid = 0;
+			ioatdca->requester_count--;
+			return i;
+		}
+	}
+	return -ENODEV;
+}
+
+static u8 ioat3_dca_get_tag(struct dca_provider *dca,
+			    struct device *dev,
+			    int cpu)
+{
+	u8 tag;
+
+	struct ioat_dca_priv *ioatdca = dca_priv(dca);
+	int i, apic_id, bit, value;
+	u8 entry;
+
+	tag = 0;
+	apic_id = cpu_physical_id(cpu);
+
+	for (i = 0; i < IOAT_TAG_MAP_LEN; i++) {
+		entry = ioatdca->tag_map[i];
+		if (entry & DCA3_TAG_MAP_BIT_TO_SEL) {
+			bit = entry &
+				~(DCA3_TAG_MAP_BIT_TO_SEL | DCA3_TAG_MAP_BIT_TO_INV);
+			value = (apic_id & (1 << bit)) ? 1 : 0;
+		} else if (entry & DCA3_TAG_MAP_BIT_TO_INV) {
+			bit = entry & ~DCA3_TAG_MAP_BIT_TO_INV;
+			value = (apic_id & (1 << bit)) ? 0 : 1;
+		} else {
+			value = (entry & DCA3_TAG_MAP_LITERAL_VAL) ? 1 : 0;
+		}
+		tag |= (value << i);
+	}
+
+	return tag;
+}
+
+static struct dca_ops ioat3_dca_ops = {
+	.add_requester		= ioat3_dca_add_requester,
+	.remove_requester	= ioat3_dca_remove_requester,
+	.get_tag		= ioat3_dca_get_tag,
+	.dev_managed		= ioat_dca_dev_managed,
+};
+
+static int ioat3_dca_count_dca_slots(void *iobase, u16 dca_offset)
+{
+	int slots = 0;
+	u32 req;
+	u16 global_req_table;
+
+	global_req_table = readw(iobase + dca_offset + IOAT3_DCA_GREQID_OFFSET);
+	if (global_req_table == 0)
+		return 0;
+
+	do {
+		req = readl(iobase + global_req_table + (slots * sizeof(u32)));
+		slots++;
+	} while ((req & IOAT_DCA_GREQID_LASTID) == 0);
+
+	return slots;
+}
+
+struct dca_provider *ioat3_dca_init(struct pci_dev *pdev, void __iomem *iobase)
+{
+	struct dca_provider *dca;
+	struct ioat_dca_priv *ioatdca;
+	int slots;
+	int i;
+	int err;
+	u16 dca_offset;
+	u16 csi_fsb_control;
+	u16 pcie_control;
+	u8 bit;
+
+	union {
+		u64 full;
+		struct {
+			u32 low;
+			u32 high;
+		};
+	} tag_map;
+
+	if (!system_has_dca_enabled(pdev))
+		return NULL;
+
+	dca_offset = readw(iobase + IOAT_DCAOFFSET_OFFSET);
+	if (dca_offset == 0)
+		return NULL;
+
+	slots = ioat3_dca_count_dca_slots(iobase, dca_offset);
+	if (slots == 0)
+		return NULL;
+
+	dca = alloc_dca_provider(&ioat3_dca_ops,
+				 sizeof(*ioatdca)
+				      + (sizeof(struct ioat_dca_slot) * slots));
+	if (!dca)
+		return NULL;
+
+	ioatdca = dca_priv(dca);
+	ioatdca->iobase = iobase;
+	ioatdca->dca_base = iobase + dca_offset;
+	ioatdca->max_requesters = slots;
+
+	/* some bios might not know to turn these on */
+	csi_fsb_control = readw(ioatdca->dca_base + IOAT3_CSI_CONTROL_OFFSET);
+	if ((csi_fsb_control & IOAT3_CSI_CONTROL_PREFETCH) == 0) {
+		csi_fsb_control |= IOAT3_CSI_CONTROL_PREFETCH;
+		writew(csi_fsb_control,
+		       ioatdca->dca_base + IOAT3_CSI_CONTROL_OFFSET);
+	}
+	pcie_control = readw(ioatdca->dca_base + IOAT3_PCI_CONTROL_OFFSET);
+	if ((pcie_control & IOAT3_PCI_CONTROL_MEMWR) == 0) {
+		pcie_control |= IOAT3_PCI_CONTROL_MEMWR;
+		writew(pcie_control,
+		       ioatdca->dca_base + IOAT3_PCI_CONTROL_OFFSET);
+	}
+
+
+	/* TODO version, compatibility and configuration checks */
+
+	/* copy out the APIC to DCA tag map */
+	tag_map.low =
+		readl(ioatdca->dca_base + IOAT3_APICID_TAG_MAP_OFFSET_LOW);
+	tag_map.high =
+		readl(ioatdca->dca_base + IOAT3_APICID_TAG_MAP_OFFSET_HIGH);
+	for (i = 0; i < 8; i++) {
+		bit = tag_map.full >> (8 * i);
+		ioatdca->tag_map[i] = bit & DCA_TAG_MAP_MASK;
+	}
+
+	err = register_dca_provider(dca, &pdev->dev);
+	if (err) {
+		free_dca_provider(dca);
+		return NULL;
+	}
+
+	return dca;
+}
diff --git a/drivers/dma/ioat_dma.c b/drivers/dma/ioat_dma.c
index b5ce5be..890e252 100644
--- a/drivers/dma/ioat_dma.c
+++ b/drivers/dma/ioat_dma.c
@@ -63,8 +63,15 @@ #ifdef CONFIG_NET_DMA
  */
 #define IOAT1_DEFAULT_TCP_DMA_COPYBREAK 4096
 #define IOAT2_DEFAULT_TCP_DMA_COPYBREAK 2048
+#define IOAT3_DEFAULT_TCP_DMA_COPYBREAK 4096
 #endif
 
+/*
+ * workaround for IOAT ver.3.0 null descriptor issue
+ * (channel returns error when size is 0)
+ */
+#define NULL_DESC_BUFFER_SIZE 1
+
 /* internal functions */
 static void ioat_dma_start_null_desc(struct ioat_dma_chan *ioat_chan);
 static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat_chan);
@@ -141,6 +148,38 @@ static int ioat_dma_enumerate_channels(s
 	int i;
 	struct ioat_dma_chan *ioat_chan;
 
+	/*
+	 * IOAT ver.3 workarounds
+	 */
+	if (device->version == IOAT_VER_3_0) {
+		u32 chan_err_mask;
+		u16 dev_id;
+		u32 dmauncerrsts;
+
+		/*
+		 * Write CHANERRMSK_INT with 3E07h to mask out the errors
+		 * that can cause stability issues for IOAT ver.3
+		 */
+		chan_err_mask = 0x3E07;
+		pci_write_config_dword(device->pdev,
+			IOAT_PCI_CHANERRMASK_INT_OFFSET,
+			chan_err_mask);
+
+		/*
+		 * Clear DMAUNCERRSTS Cfg-Reg Parity Error status bit
+		 * (workaround for spurious config parity error after restart)
+		 */
+		pci_read_config_word(device->pdev,
+			IOAT_PCI_DEVICE_ID_OFFSET,
+			&dev_id);
+		if (dev_id == PCI_DEVICE_ID_INTEL_IOAT_TBG0) {
+			dmauncerrsts = 0x10;
+			pci_write_config_dword(device->pdev,
+				IOAT_PCI_DMAUNCERRSTS_OFFSET,
+				dmauncerrsts);
+		}
+	}
+
 	device->common.chancnt = readb(device->reg_base + IOAT_CHANCNT_OFFSET);
 	xfercap_scale = readb(device->reg_base + IOAT_XFERCAP_OFFSET);
 	xfercap = (xfercap_scale == 0 ? -1 : (1UL << xfercap_scale));
@@ -485,6 +524,13 @@ static dma_cookie_t ioat1_tx_submit(stru
 		prev = new;
 	} while (len && (new = ioat1_dma_get_next_descriptor(ioat_chan)));
 
+	if (!new) {
+		dev_err(&ioat_chan->device->pdev->dev,
+			"tx submit failed\n");
+		spin_unlock_bh(&ioat_chan->desc_lock);
+		return -ENOMEM;
+	}
+
 	hw->ctl = IOAT_DMA_DESCRIPTOR_CTL_CP_STS;
 	if (new->async_tx.callback) {
 		hw->ctl |= IOAT_DMA_DESCRIPTOR_CTL_INT_GN;
@@ -570,7 +616,14 @@ static dma_cookie_t ioat2_tx_submit(stru
 		desc_count++;
 	} while (len && (new = ioat2_dma_get_next_descriptor(ioat_chan)));
 
-	hw->ctl = IOAT_DMA_DESCRIPTOR_CTL_CP_STS;
+	if (!new) {
+		dev_err(&ioat_chan->device->pdev->dev,
+			"tx submit failed\n");
+		spin_unlock_bh(&ioat_chan->desc_lock);
+		return -ENOMEM;
+	}
+
+	hw->ctl |= IOAT_DMA_DESCRIPTOR_CTL_CP_STS;
 	if (new->async_tx.callback) {
 		hw->ctl |= IOAT_DMA_DESCRIPTOR_CTL_INT_GN;
 		if (first != new) {
@@ -641,6 +694,7 @@ static struct ioat_desc_sw *ioat_dma_all
 		desc_sw->async_tx.tx_submit = ioat1_tx_submit;
 		break;
 	case IOAT_VER_2_0:
+	case IOAT_VER_3_0:
 		desc_sw->async_tx.tx_submit = ioat2_tx_submit;
 		break;
 	}
@@ -790,6 +844,7 @@ static void ioat_dma_free_chan_resources
 		}
 		break;
 	case IOAT_VER_2_0:
+	case IOAT_VER_3_0:
 		list_for_each_entry_safe(desc, _desc,
 					 ioat_chan->free_desc.next, node) {
 			list_del(&desc->node);
@@ -879,7 +934,8 @@ ioat2_dma_get_next_descriptor(struct ioa
 
 		/* set up the noop descriptor */
 		noop_desc = to_ioat_desc(ioat_chan->used_desc.next);
-		noop_desc->hw->size = 0;
+		/* set size to non-zero value (channel returns error when size is 0) */
+		noop_desc->hw->size = NULL_DESC_BUFFER_SIZE;
 		noop_desc->hw->ctl = IOAT_DMA_DESCRIPTOR_NUL;
 		noop_desc->hw->src_addr = 0;
 		noop_desc->hw->dst_addr = 0;
@@ -929,6 +985,7 @@ static struct ioat_desc_sw *ioat_dma_get
 		return ioat1_dma_get_next_descriptor(ioat_chan);
 		break;
 	case IOAT_VER_2_0:
+	case IOAT_VER_3_0:
 		return ioat2_dma_get_next_descriptor(ioat_chan);
 		break;
 	}
@@ -1051,10 +1108,12 @@ #endif
 		 * perhaps we're stuck so hard that the watchdog can't go off?
 		 * try to catch it after 2 seconds
 		 */
-		if (time_after(jiffies,
-			       ioat_chan->last_completion_time + HZ*WATCHDOG_DELAY)) {
-			ioat_dma_chan_watchdog(&(ioat_chan->device->work.work));
-			ioat_chan->last_completion_time = jiffies;
+		if (ioat_chan->device->version != IOAT_VER_3_0) {
+			if (time_after(jiffies,
+				       ioat_chan->last_completion_time + HZ*WATCHDOG_DELAY)) {
+				ioat_dma_chan_watchdog(&(ioat_chan->device->work.work));
+				ioat_chan->last_completion_time = jiffies;
+			}
 		}
 		return;
 	}
@@ -1124,6 +1183,7 @@ #endif
 		}
 		break;
 	case IOAT_VER_2_0:
+	case IOAT_VER_3_0:
 		/* has some other thread has already cleaned up? */
 		if (ioat_chan->used_desc.prev == NULL)
 			break;
@@ -1236,10 +1296,19 @@ static void ioat_dma_start_null_desc(str
 	spin_lock_bh(&ioat_chan->desc_lock);
 
 	desc = ioat_dma_get_next_descriptor(ioat_chan);
+
+	if (!desc) {
+		dev_err(&ioat_chan->device->pdev->dev,
+			"Unable to start null desc - get next desc failed\n");
+		spin_unlock_bh(&ioat_chan->desc_lock);
+		return;
+	}
+
 	desc->hw->ctl = IOAT_DMA_DESCRIPTOR_NUL
 				| IOAT_DMA_DESCRIPTOR_CTL_INT_GN
 				| IOAT_DMA_DESCRIPTOR_CTL_CP_STS;
-	desc->hw->size = 0;
+	/* set size to non-zero value (channel returns error when size is 0) */
+	desc->hw->size = NULL_DESC_BUFFER_SIZE;
 	desc->hw->src_addr = 0;
 	desc->hw->dst_addr = 0;
 	async_tx_ack(&desc->async_tx);
@@ -1257,6 +1326,7 @@ static void ioat_dma_start_null_desc(str
 			+ IOAT_CHANCMD_OFFSET(ioat_chan->device->version));
 		break;
 	case IOAT_VER_2_0:
+	case IOAT_VER_3_0:
 		writel(((u64) desc->async_tx.phys) & 0x00000000FFFFFFFF,
 		       ioat_chan->reg_base + IOAT2_CHAINADDR_OFFSET_LOW);
 		writel(((u64) desc->async_tx.phys) >> 32,
@@ -1575,6 +1645,7 @@ struct ioatdma_device *ioat_dma_probe(st
 						ioat1_dma_memcpy_issue_pending;
 		break;
 	case IOAT_VER_2_0:
+	case IOAT_VER_3_0:
 		device->common.device_prep_dma_memcpy = ioat2_dma_prep_memcpy;
 		device->common.device_issue_pending =
 						ioat2_dma_memcpy_issue_pending;
@@ -1604,14 +1675,20 @@ #ifdef CONFIG_NET_DMA
 		sysctl_tcp_dma_copybreak =
 			IOAT2_DEFAULT_TCP_DMA_COPYBREAK;
 		break;
+	case IOAT_VER_3_0:
+		sysctl_tcp_dma_copybreak =
+			IOAT3_DEFAULT_TCP_DMA_COPYBREAK;
+		break;
 	}
 #endif
 
 	dma_async_device_register(&device->common);
 
-	INIT_DELAYED_WORK(&device->work, ioat_dma_chan_watchdog);
-	schedule_delayed_work(&device->work,
-			      WATCHDOG_DELAY);
+	if (device->version != IOAT_VER_3_0) {
+		INIT_DELAYED_WORK(&device->work, ioat_dma_chan_watchdog);
+		schedule_delayed_work(&device->work,
+				      WATCHDOG_DELAY);
+	}
 
 	return device;
 
@@ -1645,7 +1722,9 @@ void ioat_dma_remove(struct ioatdma_devi
 	pci_release_regions(device->pdev);
 	pci_disable_device(device->pdev);
 
-	cancel_delayed_work(&device->work);
+	if (device->version != IOAT_VER_3_0) {
+		cancel_delayed_work(&device->work);
+	}
 
 	list_for_each_entry_safe(chan, _chan,
 				 &device->common.channels, device_node) {
diff --git a/drivers/dma/ioatdma.h b/drivers/dma/ioatdma.h
index c6ec933..24c127b 100644
--- a/drivers/dma/ioatdma.h
+++ b/drivers/dma/ioatdma.h
@@ -28,7 +28,7 @@ #include <linux/dmapool.h>
 #include <linux/cache.h>
 #include <linux/pci_ids.h>
 
-#define IOAT_DMA_VERSION  "2.18"
+#define IOAT_DMA_VERSION  "3.30"
 
 enum ioat_interrupt {
 	none = 0,
@@ -135,11 +135,13 @@ struct ioatdma_device *ioat_dma_probe(st
 void ioat_dma_remove(struct ioatdma_device *device);
 struct dca_provider *ioat_dca_init(struct pci_dev *pdev, void __iomem *iobase);
 struct dca_provider *ioat2_dca_init(struct pci_dev *pdev, void __iomem *iobase);
+struct dca_provider *ioat3_dca_init(struct pci_dev *pdev, void __iomem *iobase);
 #else
 #define ioat_dma_probe(pdev, iobase)    NULL
 #define ioat_dma_remove(device)         do { } while (0)
 #define ioat_dca_init(pdev, iobase)	NULL
 #define ioat2_dca_init(pdev, iobase)	NULL
+#define ioat3_dca_init(pdev, iobase)	NULL
 #endif
 
 #endif /* IOATDMA_H */
diff --git a/drivers/dma/ioatdma_hw.h b/drivers/dma/ioatdma_hw.h
index dd470fa..f1ae2c7 100644
--- a/drivers/dma/ioatdma_hw.h
+++ b/drivers/dma/ioatdma_hw.h
@@ -35,6 +35,7 @@ #define IOAT_PCI_SVID           0x8086
 #define IOAT_PCI_SID            0x8086
 #define IOAT_VER_1_2            0x12    /* Version 1.2 */
 #define IOAT_VER_2_0            0x20    /* Version 2.0 */
+#define IOAT_VER_3_0            0x30    /* Version 3.0 */
 
 struct ioat_dma_descriptor {
 	uint32_t	size;
diff --git a/drivers/dma/ioatdma_registers.h b/drivers/dma/ioatdma_registers.h
index 9832d7e..827cb50 100644
--- a/drivers/dma/ioatdma_registers.h
+++ b/drivers/dma/ioatdma_registers.h
@@ -25,6 +25,10 @@ #define IOAT_PCI_DMACTRL_OFFSET			0x48
 #define IOAT_PCI_DMACTRL_DMA_EN			0x00000001
 #define IOAT_PCI_DMACTRL_MSI_EN			0x00000002
 
+#define IOAT_PCI_DEVICE_ID_OFFSET		0x02
+#define IOAT_PCI_DMAUNCERRSTS_OFFSET		0x148
+#define IOAT_PCI_CHANERRMASK_INT_OFFSET		0x184
+
 /* MMIO Device Registers */
 #define IOAT_CHANCNT_OFFSET			0x00	/*  8-bit */
 
@@ -149,7 +153,23 @@ #define IOAT_DCA_GREQID_IGNOREFUN   0x10
 #define IOAT_DCA_GREQID_VALID       0x20000000
 #define IOAT_DCA_GREQID_LASTID      0x80000000
 
+#define IOAT3_CSI_CAPABILITY_OFFSET 0x08
+#define IOAT3_CSI_CAPABILITY_PREFETCH    0x1
+
+#define IOAT3_PCI_CAPABILITY_OFFSET 0x0A
+#define IOAT3_PCI_CAPABILITY_MEMWR  0x1
+
+#define IOAT3_CSI_CONTROL_OFFSET    0x0C
+#define IOAT3_CSI_CONTROL_PREFETCH  0x1
+
+#define IOAT3_PCI_CONTROL_OFFSET    0x0E
+#define IOAT3_PCI_CONTROL_MEMWR     0x1
+
+#define IOAT3_APICID_TAG_MAP_OFFSET 0x10
+#define IOAT3_APICID_TAG_MAP_OFFSET_LOW  0x10
+#define IOAT3_APICID_TAG_MAP_OFFSET_HIGH 0x14
 
+#define IOAT3_DCA_GREQID_OFFSET     0x02
 
 #define IOAT1_CHAINADDR_OFFSET		0x0C	/* 64-bit Descriptor Chain Address Register */
 #define IOAT2_CHAINADDR_OFFSET		0x10	/* 64-bit Descriptor Chain Address Register */
diff --git a/include/linux/dca.h b/include/linux/dca.h
index af61cd1..b00a753 100644
--- a/include/linux/dca.h
+++ b/include/linux/dca.h
@@ -10,6 +10,7 @@ #define DCA_PROVIDER_ADD     0x0001
 #define DCA_PROVIDER_REMOVE  0x0002
 
 struct dca_provider {
+	struct list_head	node;
 	struct dca_ops		*ops;
 	struct device 		*cd;
 	int			 id;
@@ -18,7 +19,9 @@ struct dca_provider {
 struct dca_ops {
 	int	(*add_requester)    (struct dca_provider *, struct device *);
 	int	(*remove_requester) (struct dca_provider *, struct device *);
-	u8	(*get_tag)	    (struct dca_provider *, int cpu);
+	u8	(*get_tag)	    (struct dca_provider *, struct device *,
+				     int cpu);
+	int	(*dev_managed)      (struct dca_provider *, struct device *);
 };
 
 struct dca_provider *alloc_dca_provider(struct dca_ops *ops, int priv_size);
@@ -32,9 +35,11 @@ static inline void *dca_priv(struct dca_
 }
 
 /* Requester API */
+#define DCA_GET_TAG_TWO_ARGS
 int dca_add_requester(struct device *dev);
 int dca_remove_requester(struct device *dev);
 u8 dca_get_tag(int cpu);
+u8 dca3_get_tag(struct device *dev, int cpu);
 
 /* internal stuff */
 int __init dca_sysfs_init(void);
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 6be6a79..f1e1560 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2368,6 +2368,14 @@ #define PCI_DEVICE_ID_INTEL_ICH9_6	0x293
 #define PCI_DEVICE_ID_INTEL_ICH9_7	0x2916
 #define PCI_DEVICE_ID_INTEL_ICH9_8	0x2918
 #define PCI_DEVICE_ID_INTEL_82855PM_HB	0x3340
+#define PCI_DEVICE_ID_INTEL_IOAT_TBG4	0x3429
+#define PCI_DEVICE_ID_INTEL_IOAT_TBG5	0x342a
+#define PCI_DEVICE_ID_INTEL_IOAT_TBG6	0x342b
+#define PCI_DEVICE_ID_INTEL_IOAT_TBG7	0x342c
+#define PCI_DEVICE_ID_INTEL_IOAT_TBG0	0x3430
+#define PCI_DEVICE_ID_INTEL_IOAT_TBG1	0x3431
+#define PCI_DEVICE_ID_INTEL_IOAT_TBG2	0x3432
+#define PCI_DEVICE_ID_INTEL_IOAT_TBG3	0x3433
 #define PCI_DEVICE_ID_INTEL_82830_HB	0x3575
 #define PCI_DEVICE_ID_INTEL_82830_CGC	0x3577
 #define PCI_DEVICE_ID_INTEL_82855GM_HB	0x3580

