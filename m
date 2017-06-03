From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH v2 2/3] PCI: Enable PCIe Relaxed Ordering if supported
Date: Sat, 3 Jun 2017 12:04:06 +0800
Message-ID: <1496462647-7632-3-git-send-email-dingtianhong@huawei.com>
References: <1496462647-7632-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ding Tianhong <dingtianhong@huawei.com>
To: <leedom@chelsio.com>, <ashok.raj@intel.com>, <helgaas@kernel.org>,
        <werner@chelsio.com>, <ganeshgr@chelsio.com>,
        <asit.k.mallick@intel.com>, <patrick.j.cramer@intel.com>,
        <Suravee.Suthikulpanit@amd.com>, <Bob.Shaw@amd.com>,
        <l.stach@pengutronix.de>, <amira@mellanox.com>,
        <gabriele.paoloni@huawei.com>, <David.Laight@aculab.com>,
        <jeffrey.t.kirsher@intel.com>, <catalin.marinas@arm.com>,
        <will.deacon@arm.com>, <mark.rutland@arm.com>,
        <robin.murphy@arm.com>, <davem@davemloft.net>,
        <alexander.duyck@gmail.com>,
        <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
        <linux-pci@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496462647-7632-1-git-send-email-dingtianhong@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PCIe Device Control Register use the bit 4 to indicate that
whether the device is permitted to enable relaxed ordering or not.
But relaxed ordering is not safe for some platform which could only
use strong write ordering, so devices are allowed (but not required)
to enable relaxed ordering bit by default.

If a platform support relaxed ordering but does not enable it by
default, enable it in the PCIe configuration. This allows some device
to send TLPs with the relaxed ordering attributes set, which may
improve the performance.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/pci/pci.c   | 42 ++++++++++++++++++++++++++++++++++++++++++
 drivers/pci/probe.c | 11 +++++++++++
 include/linux/pci.h |  3 +++
 3 files changed, 56 insertions(+)

diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
index b01bd5b..f57a374 100644
--- a/drivers/pci/pci.c
+++ b/drivers/pci/pci.c
@@ -4878,6 +4878,48 @@ int pcie_set_mps(struct pci_dev *dev, int mps)
 EXPORT_SYMBOL(pcie_set_mps);
 
 /**
+ * pcie_set_relaxed_ordering - set PCI Express relexed ordering bit
+ * @dev: PCI device to query
+ *
+ * If possible sets relaxed ordering
+ */
+int pcie_set_relaxed_ordering(struct pci_dev *dev)
+{
+	return pcie_capability_set_word(dev, PCI_EXP_DEVCTL, PCI_EXP_DEVCTL_RELAX_EN);
+}
+EXPORT_SYMBOL(pcie_set_relaxed_ordering);
+
+/**
+ * pcie_clear_relaxed_ordering - clear PCI Express relexed ordering bit
+ * @dev: PCI device to query
+ *
+ * If possible clear relaxed ordering
+ */
+int pcie_clear_relaxed_ordering(struct pci_dev *dev)
+{
+	return pcie_capability_clear_word(dev, PCI_EXP_DEVCTL, PCI_EXP_DEVCTL_RELAX_EN);
+}
+EXPORT_SYMBOL(pcie_clear_relaxed_ordering);
+
+/**
+ * pcie_get_relaxed_ordering - check PCI Express relexed ordering bit
+ * @dev: PCI device to query
+ *
+ * Returns true if relaxed ordering is been set
+ */
+int pcie_get_relaxed_ordering(struct pci_dev *dev)
+{
+	u16 v;
+
+	pcie_capability_read_word(dev, PCI_EXP_DEVCTL, &v);
+
+	return (v & PCI_EXP_DEVCTL_RELAX_EN) >> 4;
+}
+EXPORT_SYMBOL(pcie_get_relaxed_ordering);
+
+/**
+ * pcie_set_mps - set PCI Express maximum payload size
+/**
  * pcie_get_minimum_link - determine minimum link settings of a PCI device
  * @dev: PCI device to query
  * @speed: storage for minimum speed
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 19c8950..aeb22b5 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1701,6 +1701,16 @@ static void pci_configure_extended_tags(struct pci_dev *dev)
 					 PCI_EXP_DEVCTL_EXT_TAG);
 }
 
+static void pci_configure_relaxed_ordering(struct pci_dev *dev)
+{
+	int ret;
+
+	if (dev && (dev->dev_flags & PCI_DEV_FLAGS_NO_RELAXED_ORDERING))
+		pcie_set_relaxed_ordering(dev);
+	else
+		pcie_clear_relaxed_ordering(dev);
+}
+
 static void pci_configure_device(struct pci_dev *dev)
 {
 	struct hotplug_params hpp;
@@ -1708,6 +1718,7 @@ static void pci_configure_device(struct pci_dev *dev)
 
 	pci_configure_mps(dev);
 	pci_configure_extended_tags(dev);
+	pci_configure_relaxed_ordering(dev);
 
 	memset(&hpp, 0, sizeof(hpp));
 	ret = pci_get_hp_params(dev, &hpp);
diff --git a/include/linux/pci.h b/include/linux/pci.h
index e1e8428..84bd6af 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1105,6 +1105,9 @@ int __pci_enable_wake(struct pci_dev *dev, pci_power_t state,
 void pci_pme_wakeup_bus(struct pci_bus *bus);
 void pci_d3cold_enable(struct pci_dev *dev);
 void pci_d3cold_disable(struct pci_dev *dev);
+int pcie_set_relaxed_ordering(struct pci_dev *dev);
+int pcie_clear_relaxed_ordering(struct pci_dev *dev);
+int pcie_get_relaxed_ordering(struct pci_dev *dev);
 
 static inline int pci_enable_wake(struct pci_dev *dev, pci_power_t state,
 				  bool enable)
-- 
1.9.0
