From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/5] pci: Add SR-IOV convenience functions and
	macros
Date: Sat, 30 Jan 2010 02:39:28 -0800
Message-ID: <20100130103842.26633.73429.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.westchester.pa.mail.comcast.net ([76.96.59.212]:38572
	"EHLO qmta14.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751256Ab0A3Kjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2010 05:39:47 -0500
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
 include/linux/pci.h |    8 ++++++++
 2 files changed, 23 insertions(+), 0 deletions(-)

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
index 174e539..db7706d 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -310,6 +310,9 @@ extern struct pci_dev *alloc_pci_dev(void);
 #define pci_dev_b(n) list_entry(n, struct pci_dev, bus_list)
 #define	to_pci_dev(n) container_of(n, struct pci_dev, dev)
 #define for_each_pci_dev(d) while ((d = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, d)) != NULL)
+#define dev_is_pci(d) ((d)->bus == &pci_bus_type)
+#define dev_is_pf(d) ((dev_is_pci(d) ? to_pci_dev(d)->is_physfn : false))
+#define dev_num_vf(d) ((dev_is_pci(d) ? pci_num_vf(to_pci_dev(d)) : 0))
 
 static inline int pci_channel_offline(struct pci_dev *pdev)
 {
@@ -1286,6 +1289,7 @@ void __iomem *pci_ioremap_bar(struct pci_dev *pdev, int bar);
 extern int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn);
 extern void pci_disable_sriov(struct pci_dev *dev);
 extern irqreturn_t pci_sriov_migration(struct pci_dev *dev);
+extern int pci_num_vf(struct pci_dev *dev);
 #else
 static inline int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn)
 {
@@ -1298,6 +1302,10 @@ static inline irqreturn_t pci_sriov_migration(struct pci_dev *dev)
 {
 	return IRQ_NONE;
 }
+static inline int pci_num_vf(struct pci_dev *dev)
+{
+	return 0;
+}
 #endif
 
 #if defined(CONFIG_HOTPLUG_PCI) || defined(CONFIG_HOTPLUG_PCI_MODULE)

