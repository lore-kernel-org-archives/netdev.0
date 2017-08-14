From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH v10 1/5] PCI: Disable PCIe Relaxed Ordering if unsupported
Date: Mon, 14 Aug 2017 23:44:55 +0800
Message-ID: <1502725499-11276-2-git-send-email-dingtianhong@huawei.com>
References: <1502725499-11276-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ding Tianhong <dingtianhong@huawei.com>
To: <leedom@chelsio.com>, <ashok.raj@intel.com>, <bhelgaas@google.com>,
        <helgaas@kernel.org>, <werner@chelsio.com>, <ganeshgr@chelsio.com>,
        <asit.k.mallick@intel.com>, <patrick.j.cramer@intel.com>,
        <Suravee.Suthikulpanit@amd.com>, <Bob.Shaw@amd.com>,
        <l.stach@pengutronix.de>, <amira@mellanox.com>,
        <gabriele.paoloni@huawei.com>, <David.Laight@aculab.com>,
        <jeffrey.t.kirsher@intel.com>, <catalin.marinas@arm.com>,
        <will.deacon@arm.com>, <mark.rutland@arm.com>,
        <robin.murphy@arm.com>, <davem@davemloft.net>,
        <alexander.duyck@gmail.com>,
        <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
        <linux-pci@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502725499-11276-1-git-send-email-dingtianhong@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When bit4 is set in the PCIe Device Control register, it indicates
whether the device is permitted to use relaxed ordering.
On some platforms using relaxed ordering can have performance issues or
due to erratum can cause data-corruption. In such cases devices must avoid
using relaxed ordering.

The patch adds a new flag PCI_DEV_FLAGS_NO_RELAXED_ORDERING to indicate that
Relaxed Ordering (RO) attribute should not be used for Transaction Layer
Packets (TLP) targeted towards these affected root complexes.

This patch checks if there is any node in the hierarchy that indicates that
using relaxed ordering is not safe. In such cases the patch turns off the
relaxed ordering by clearing the capability for this device.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Acked-by: Ashok Raj <ashok.raj@intel.com>
Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/pci/probe.c  | 43 +++++++++++++++++++++++++++++++++++++++++++
 drivers/pci/quirks.c | 11 +++++++++++
 include/linux/pci.h  |  3 +++
 3 files changed, 57 insertions(+)

diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index c31310d..779e646 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1762,6 +1762,48 @@ static void pci_configure_extended_tags(struct pci_dev *dev)
 					 PCI_EXP_DEVCTL_EXT_TAG);
 }
 
+/**
+ * pcie_relaxed_ordering_enabled - Probe for PCIe relaxed ordering enable
+ * @dev: PCI device to query
+ *
+ * Returns true if the device has enabled relaxed ordering attribute.
+ */
+bool pcie_relaxed_ordering_enabled(struct pci_dev *dev)
+{
+	u16 v;
+
+	pcie_capability_read_word(dev, PCI_EXP_DEVCTL, &v);
+
+	return !!(v & PCI_EXP_DEVCTL_RELAX_EN);
+}
+EXPORT_SYMBOL(pcie_relaxed_ordering_enabled);
+
+static void pci_configure_relaxed_ordering(struct pci_dev *dev)
+{
+	struct pci_dev *root;
+
+	/* PCI_EXP_DEVICE_RELAX_EN is RsvdP in VFs */
+	if (dev->is_virtfn)
+		return;
+
+	if (!pcie_relaxed_ordering_enabled(dev))
+		return;
+
+	/*
+	 * For now, we only deal with Relaxed Ordering issues with Root
+	 * Ports. Peer-to-Peer DMA is another can of worms.
+	 */
+	root = pci_find_pcie_root_port(dev);
+	if (!root)
+		return;
+
+	if (root->dev_flags & PCI_DEV_FLAGS_NO_RELAXED_ORDERING) {
+		pcie_capability_clear_word(dev, PCI_EXP_DEVCTL,
+					   PCI_EXP_DEVCTL_RELAX_EN);
+		dev_info(&dev->dev, "Disable Relaxed Ordering because the Root Port didn't support it\n");
+	}
+}
+
 static void pci_configure_device(struct pci_dev *dev)
 {
 	struct hotplug_params hpp;
@@ -1769,6 +1811,7 @@ static void pci_configure_device(struct pci_dev *dev)
 
 	pci_configure_mps(dev);
 	pci_configure_extended_tags(dev);
+	pci_configure_relaxed_ordering(dev);
 
 	memset(&hpp, 0, sizeof(hpp));
 	ret = pci_get_hp_params(dev, &hpp);
diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index 6967c6b..61b59bf 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -4016,6 +4016,17 @@ static void quirk_tw686x_class(struct pci_dev *pdev)
 			      quirk_tw686x_class);
 
 /*
+ * Some devices have problems with Transaction Layer Packets with the Relaxed
+ * Ordering Attribute set.  Such devices should mark themselves and other
+ * Device Drivers should check before sending TLPs with RO set.
+ */
+static void quirk_relaxedordering_disable(struct pci_dev *dev)
+{
+	dev->dev_flags |= PCI_DEV_FLAGS_NO_RELAXED_ORDERING;
+	dev_info(&dev->dev, "Disable Relaxed Ordering Attributes to avoid PCIe Completion erratum\n");
+}
+
+/*
  * Per PCIe r3.0, sec 2.2.9, "Completion headers must supply the same
  * values for the Attribute as were supplied in the header of the
  * corresponding Request, except as explicitly allowed when IDO is used."
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 4869e66..29606fb 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -188,6 +188,8 @@ enum pci_dev_flags {
 	 * the direct_complete optimization.
 	 */
 	PCI_DEV_FLAGS_NEEDS_RESUME = (__force pci_dev_flags_t) (1 << 11),
+	/* Don't use Relaxed Ordering for TLPs directed at this device */
+	PCI_DEV_FLAGS_NO_RELAXED_ORDERING = (__force pci_dev_flags_t) (1 << 12),
 };
 
 enum pci_irq_reroute_variant {
@@ -1125,6 +1127,7 @@ int pci_add_ext_cap_save_buffer(struct pci_dev *dev,
 void pci_pme_wakeup_bus(struct pci_bus *bus);
 void pci_d3cold_enable(struct pci_dev *dev);
 void pci_d3cold_disable(struct pci_dev *dev);
+bool pcie_relaxed_ordering_enabled(struct pci_dev *dev);
 
 /* PCI Virtual Channel */
 int pci_save_vc_state(struct pci_dev *dev);
-- 
1.8.3.1
