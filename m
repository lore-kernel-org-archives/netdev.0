From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH v3 1/5] pci: Add SR-IOV convenience functions and
	macros
Date: Wed, 10 Feb 2010 03:43:04 -0800
Message-ID: <20100210114303.14483.71368.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:56387 "EHLO
	qmta04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753151Ab0BJLnW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 06:43:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Williams, Mitch A <mitch.a.williams@intel.com>

Add and export pci_num_vf to allow other subsystems to determine how many
virtual function devices are associated with an SR-IOV physical function
device.
Add macros dev_is_pci, dev_is_ps, and dev_num_vf to make it easier for
non-PCI specific code to determine SR-IOV capabilities.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/pci/iov.c   |   15 +++++++++++++++
 include/linux/pci.h |   11 +++++++++++
 2 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/drivers/pci/iov.c b/drivers/pci/iov.c
index b2a448e..3e5ab2b 100644
--- a/drivers/pci/iov.c
+++ b/drivers/pci/iov.c
@@ -706,6 +706,21 @@ irqreturn_t pci_sriov_migration(struct pci_dev *dev)
 }
 EXPORT_SYMBOL_GPL(pci_sriov_migration);
 
+/**
+ * pci_num_vf - return number of VFs associated with a PF device_release_driver
+ * @dev: the PCI device
+ *
+ * Returns number of VFs, or 0 if SR-IOV is not enabled.
+ */
+int pci_num_vf(struct pci_dev *dev)
+{
+	if (!dev || !dev->is_physfn)
+		return 0;
+	else
+		return dev->sriov->nr_virtfn;
+}
+EXPORT_SYMBOL_GPL(pci_num_vf);
+
 static int ats_alloc_one(struct pci_dev *dev, int ps)
 {
 	int pos;
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 174e539..59a98e2 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -612,6 +612,9 @@ extern void pci_remove_bus_device(struct pci_dev *dev);
 extern void pci_stop_bus_device(struct pci_dev *dev);
 void pci_setup_cardbus(struct pci_bus *bus);
 extern void pci_sort_breadthfirst(void);
+#define dev_is_pci(d) ((d)->bus == &pci_bus_type)
+#define dev_is_pf(d) ((dev_is_pci(d) ? to_pci_dev(d)->is_physfn : false))
+#define dev_num_vf(d) ((dev_is_pci(d) ? pci_num_vf(to_pci_dev(d)) : 0))
 
 /* Generic PCI functions exported to card drivers */
 
@@ -1129,6 +1132,9 @@ static inline struct pci_dev *pci_get_bus_and_slot(unsigned int bus,
 						unsigned int devfn)
 { return NULL; }
 
+#define dev_is_pci(d) (false)
+#define dev_is_pf(d) (false)
+#define dev_num_vf(d) (0)
 #endif /* CONFIG_PCI */
 
 /* Include architecture-dependent settings and functions */
@@ -1286,6 +1292,7 @@ void __iomem *pci_ioremap_bar(struct pci_dev *pdev, int bar);
 extern int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn);
 extern void pci_disable_sriov(struct pci_dev *dev);
 extern irqreturn_t pci_sriov_migration(struct pci_dev *dev);
+extern int pci_num_vf(struct pci_dev *dev);
 #else
 static inline int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn)
 {
@@ -1298,6 +1305,10 @@ static inline irqreturn_t pci_sriov_migration(struct pci_dev *dev)
 {
 	return IRQ_NONE;
 }
+static inline int pci_num_vf(struct pci_dev *dev)
+{
+	return 0;
+}
 #endif
 
 #if defined(CONFIG_HOTPLUG_PCI) || defined(CONFIG_HOTPLUG_PCI_MODULE)

