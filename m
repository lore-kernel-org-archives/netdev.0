From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH v8 2/4] PCI: Disable PCIe Relaxed Ordering if unsupported
Date: Thu, 3 Aug 2017 21:44:47 +0800
Message-ID: <1501767889-7772-3-git-send-email-dingtianhong@huawei.com>
References: <1501767889-7772-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ding Tianhong <dingtianhong@huawei.com>
To: <leedom@chelsio.com>, <ashok.raj@intel.com>, <bhelgaas@google.com>,
 <helgaas@kernel.org>, <werner@chelsio.com>, <ganeshgr@chelsio.com>,
 <asit.k.mallick@intel.com>, <patrick.j.cramer@intel.com>,
 <Suravee.Suthikulpanit@amd.com>, <Bob.Shaw@amd.com>,
 <l.stach@pengutronix.de>, <amira@mellanox.com>,
 <gabriele.paoloni@huawei.com>, <David.Laight@aculab.com>,
 <jeffrey.t.kirsher@intel.com>, <catalin.marinas@arm.com>,
 <will.deacon@arm.com>, <mark.rutland@arm.com>, <robin.murphy@arm.com>,
 <davem@davemloft.net>, <alexander.duyck@gmail.com>,
 <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
 <linux-pci@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
 <linuxarm@huawei.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1501767889-7772-1-git-send-email-dingtianhong@huawei.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

When bit4 is set in the PCIe Device Control register, it indicates
whether the device is permitted to use relaxed ordering.
On some platforms using relaxed ordering can have performance issues or
due to erratum can cause data-corruption. In such cases devices must avoid
using relaxed ordering.

This patch checks if there is any node in the hierarchy that indicates that
using relaxed ordering is not safe. In such cases the patch turns off the
relaxed ordering by clearing the eapability for this device. And if the
device is probably running in a guest machine, we should do nothing.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Ashok Raj <ashok.raj@intel.com>
---
 drivers/pci/pci.c   | 29 +++++++++++++++++++++++++++++
 drivers/pci/probe.c | 37 +++++++++++++++++++++++++++++++++++++
 include/linux/pci.h |  2 ++
 3 files changed, 68 insertions(+)

diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
index af0cc34..4f9d7c1 100644
--- a/drivers/pci/pci.c
+++ b/drivers/pci/pci.c
@@ -4854,6 +4854,35 @@ int pcie_set_mps(struct pci_dev *dev, int mps)
 EXPORT_SYMBOL(pcie_set_mps);
 
 /**
+ * pcie_clear_relaxed_ordering - clear PCI Express relaxed ordering bit
+ * @dev: PCI device to query
+ *
+ * If possible clear relaxed ordering
+ */
+int pcie_clear_relaxed_ordering(struct pci_dev *dev)
+{
+	return pcie_capability_clear_word(dev, PCI_EXP_DEVCTL,
+					  PCI_EXP_DEVCTL_RELAX_EN);
+}
+EXPORT_SYMBOL(pcie_clear_relaxed_ordering);
+
+/**
+ * pcie_relaxed_ordering_supported - Probe for PCIe relexed ordering support
+ * @dev: PCI device to query
+ *
+ * Returns true if the device support relaxed ordering attribute.
+ */
+bool pcie_relaxed_ordering_supported(struct pci_dev *dev)
+{
+	u16 v;
+
+	pcie_capability_read_word(dev, PCI_EXP_DEVCTL, &v);
+
+	return !!(v & PCI_EXP_DEVCTL_RELAX_EN);
+}
+EXPORT_SYMBOL(pcie_relaxed_ordering_supported);
+
+/**
  * pcie_get_minimum_link - determine minimum link settings of a PCI device
  * @dev: PCI device to query
  * @speed: storage for minimum speed
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index c31310d..48df012 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1762,6 +1762,42 @@ static void pci_configure_extended_tags(struct pci_dev *dev)
 					 PCI_EXP_DEVCTL_EXT_TAG);
 }
 
+/**
+ * pci_dev_should_disable_relaxed_ordering - check if the PCI device
+ * should disable the relaxed ordering attribute.
+ * @dev: PCI device
+ *
+ * Return true if any of the PCI devices above us do not support
+ * relaxed ordering.
+ */
+static bool pci_dev_should_disable_relaxed_ordering(struct pci_dev *dev)
+{
+	while (dev) {
+		if (dev->dev_flags & PCI_DEV_FLAGS_NO_RELAXED_ORDERING)
+			return true;
+
+		dev = dev->bus->self;
+	}
+
+	return false;
+}
+
+static void pci_configure_relaxed_ordering(struct pci_dev *dev)
+{
+	/* We should not alter the relaxed ordering bit for the VF */
+	if (dev->is_virtfn)
+		return;
+
+	/* If the releaxed ordering enable bit is not set, do nothing. */
+	if (!pcie_relaxed_ordering_supported(dev))
+		return;
+
+	if (pci_dev_should_disable_relaxed_ordering(dev)) {
+		pcie_clear_relaxed_ordering(dev);
+		dev_info(&dev->dev, "Disable Relaxed Ordering\n");
+	}
+}
+
 static void pci_configure_device(struct pci_dev *dev)
 {
 	struct hotplug_params hpp;
@@ -1769,6 +1805,7 @@ static void pci_configure_device(struct pci_dev *dev)
 
 	pci_configure_mps(dev);
 	pci_configure_extended_tags(dev);
+	pci_configure_relaxed_ordering(dev);
 
 	memset(&hpp, 0, sizeof(hpp));
 	ret = pci_get_hp_params(dev, &hpp);
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 412ec1c..3aa23a2 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1127,6 +1127,8 @@ int pci_add_ext_cap_save_buffer(struct pci_dev *dev,
 void pci_pme_wakeup_bus(struct pci_bus *bus);
 void pci_d3cold_enable(struct pci_dev *dev);
 void pci_d3cold_disable(struct pci_dev *dev);
+int pcie_clear_relaxed_ordering(struct pci_dev *dev);
+bool pcie_relaxed_ordering_supported(struct pci_dev *dev);
 
 /* PCI Virtual Channel */
 int pci_save_vc_state(struct pci_dev *dev);
-- 
1.8.3.1
