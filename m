From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH v4 2/3] PCI: Enable PCIe Relaxed Ordering if supported
Date: Mon, 12 Jun 2017 19:05:24 +0800
Message-ID: <1497265525-4752-3-git-send-email-dingtianhong@huawei.com>
References: <1497265525-4752-1-git-send-email-dingtianhong@huawei.com>
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
In-Reply-To: <1497265525-4752-1-git-send-email-dingtianhong@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PCIe Device Control Register use the bit 4 to indicate that
whether the device is permitted to enable relaxed ordering or not.
But relaxed ordering is not safe for some platform which could only
use strong write ordering, so devices are allowed (but not required)
to enable relaxed ordering bit by default.

If a PCIe device didn't enable the relaxed ordering attribute default,
we should not do anything in the PCIe configuration, otherwise we
should check if any of the devices above us do not support relaxed
ordering by the PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag, then base on
the result if we get a return that indicate that the relaxed ordering
is not supported we should update our device to disable relaxed ordering
in configuration space. If the device above us doesn't exist or isn't
the PCIe device, we shouldn't do anything and skip updating relaxed ordering
because we are probably running in a guest machine.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/pci/pci.c   | 32 ++++++++++++++++++++++++++++++++
 drivers/pci/probe.c | 41 +++++++++++++++++++++++++++++++++++++++++
 include/linux/pci.h |  2 ++
 3 files changed, 75 insertions(+)

diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
index b01bd5b..b44f34c 100644
--- a/drivers/pci/pci.c
+++ b/drivers/pci/pci.c
@@ -4878,6 +4878,38 @@ int pcie_set_mps(struct pci_dev *dev, int mps)
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
+	bool ro_supported = false;
+	u16 v;
+
+	pcie_capability_read_word(dev, PCI_EXP_DEVCTL, &v);
+	if ((v & PCI_EXP_DEVCTL_RELAX_EN) >> 4)
+		ro_supported = true;
+
+	return ro_supported;
+}
+EXPORT_SYMBOL(pcie_relaxed_ordering_supported);
+
+/**
  * pcie_get_minimum_link - determine minimum link settings of a PCI device
  * @dev: PCI device to query
  * @speed: storage for minimum speed
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 19c8950..ed1f717 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1701,6 +1701,46 @@ static void pci_configure_extended_tags(struct pci_dev *dev)
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
+	bool ro_disabled = false;
+
+	while (dev) {
+		if (dev->dev_flags & PCI_DEV_FLAGS_NO_RELAXED_ORDERING) {
+			ro_disabled = true;
+			break;
+		}
+		dev = dev->bus->self;
+	}
+
+	return ro_disabled;
+}
+
+static void pci_configure_relaxed_ordering(struct pci_dev *dev)
+{
+	struct pci_dev *bridge = pci_upstream_bridge(dev);
+
+	if (!pci_is_pcie(dev) || !bridge || !pci_is_pcie(bridge))
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
@@ -1708,6 +1748,7 @@ static void pci_configure_device(struct pci_dev *dev)
 
 	pci_configure_mps(dev);
 	pci_configure_extended_tags(dev);
+	pci_configure_relaxed_ordering(dev);
 
 	memset(&hpp, 0, sizeof(hpp));
 	ret = pci_get_hp_params(dev, &hpp);
diff --git a/include/linux/pci.h b/include/linux/pci.h
index e1e8428..9870781 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1105,6 +1105,8 @@ int __pci_enable_wake(struct pci_dev *dev, pci_power_t state,
 void pci_pme_wakeup_bus(struct pci_bus *bus);
 void pci_d3cold_enable(struct pci_dev *dev);
 void pci_d3cold_disable(struct pci_dev *dev);
+int pcie_clear_relaxed_ordering(struct pci_dev *dev);
+bool pcie_relaxed_ordering_supported(struct pci_dev *dev);
 
 static inline int pci_enable_wake(struct pci_dev *dev, pci_power_t state,
 				  bool enable)
-- 
1.9.0
