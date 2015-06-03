From: Mark D Rustad <mark.d.rustad@intel.com>
Subject: [PATCH V2 1/2] pci: Add dev_flags bit to access VPD through
 function 0
Date: Tue, 02 Jun 2015 17:10:11 -0700
Message-ID: <20150603001011.71269.79857.stgit@mdrustad-wks.jf.intel.com>
References: <20150603000645.71269.26134.stgit@mdrustad-wks.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-pci@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org
To: bhelgaas@google.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20150603000645.71269.26134.stgit@mdrustad-wks.jf.intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a dev_flags bit, PCI_DEV_FLAGS_VPD_REF_F0, to access VPD through
function 0 to provide VPD access on other functions. This solves
concurrent access problems on many devices without changing the
attributes exposed in sysfs. Never set this bit on function 0 or
there will be an infinite recursion.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
---
Changes in V2:
- Corrected spelling in log message
- Added checks to see that the referenced function 0 is reasonable
---
 drivers/pci/access.c |   48 +++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 47 insertions(+), 1 deletion(-)

diff --git a/drivers/pci/access.c b/drivers/pci/access.c
index d9b64a175990..74634d4868a2 100644
--- a/drivers/pci/access.c
+++ b/drivers/pci/access.c
@@ -439,6 +439,40 @@ static const struct pci_vpd_ops pci_vpd_pci22_ops = {
 	.release = pci_vpd_pci22_release,
 };
 
+static ssize_t pci_vpd_f0_read(struct pci_dev *dev, loff_t pos, size_t count,
+			       void *arg)
+{
+	struct pci_dev *tdev = pci_get_slot(dev->bus, PCI_SLOT(dev->devfn));
+	ssize_t ret;
+
+	if (!tdev)
+		return -ENODEV;
+
+	ret = pci_read_vpd(tdev, pos, count, arg);
+	pci_dev_put(tdev);
+	return ret;
+}
+
+static ssize_t pci_vpd_f0_write(struct pci_dev *dev, loff_t pos, size_t count,
+				const void *arg)
+{
+	struct pci_dev *tdev = pci_get_slot(dev->bus, PCI_SLOT(dev->devfn));
+	ssize_t ret;
+
+	if (!tdev)
+		return -ENODEV;
+
+	ret = pci_write_vpd(tdev, pos, count, arg);
+	pci_dev_put(tdev);
+	return ret;
+}
+
+static const struct pci_vpd_ops pci_vpd_f0_ops = {
+	.read = pci_vpd_f0_read,
+	.write = pci_vpd_f0_write,
+	.release = pci_vpd_pci22_release,
+};
+
 int pci_vpd_pci22_init(struct pci_dev *dev)
 {
 	struct pci_vpd_pci22 *vpd;
@@ -447,12 +481,24 @@ int pci_vpd_pci22_init(struct pci_dev *dev)
 	cap = pci_find_capability(dev, PCI_CAP_ID_VPD);
 	if (!cap)
 		return -ENODEV;
+	if (dev->dev_flags & PCI_DEV_FLAGS_VPD_REF_F0) {
+		struct pci_dev *tdev;
+
+		tdev = pci_get_slot(dev->bus, PCI_SLOT(dev->devfn));
+		if (!tdev || !dev->multifunction || !tdev->multifunction ||
+		    dev->class != tdev->class || dev->vendor != tdev->vendor ||
+		    dev->device != tdev->device)
+			return -ENODEV;
+	}
 	vpd = kzalloc(sizeof(*vpd), GFP_ATOMIC);
 	if (!vpd)
 		return -ENOMEM;
 
 	vpd->base.len = PCI_VPD_PCI22_SIZE;
-	vpd->base.ops = &pci_vpd_pci22_ops;
+	if (dev->dev_flags & PCI_DEV_FLAGS_VPD_REF_F0)
+		vpd->base.ops = &pci_vpd_f0_ops;
+	else
+		vpd->base.ops = &pci_vpd_pci22_ops;
 	mutex_init(&vpd->lock);
 	vpd->cap = cap;
 	vpd->busy = false;
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 353db8dc4c6e..194df6d635e6 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -180,6 +180,8 @@ enum pci_dev_flags {
 	PCI_DEV_FLAGS_NO_BUS_RESET = (__force pci_dev_flags_t) (1 << 6),
 	/* Do not use PM reset even if device advertises NoSoftRst- */
 	PCI_DEV_FLAGS_NO_PM_RESET = (__force pci_dev_flags_t) (1 << 7),
+	/* Get VPD from function 0 VPD */
+	PCI_DEV_FLAGS_VPD_REF_F0 = (__force pci_dev_flags_t) (1 << 8),
 };
 
 enum pci_irq_reroute_variant {
