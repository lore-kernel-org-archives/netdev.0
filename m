From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH pci] pci: Add helper function to set VPD size
Date: Thu, 14 Apr 2016 23:42:05 +0530
Message-ID: <1460657525-17551-1-git-send-email-hariprasad@chelsio.com>
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org,
	leedom@chelsio.com, swise@opengridcomputing.com,
	nirranjan@chelsio.com, santosh@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: bhelgaas@google.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:42331 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932104AbcDNSIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 14:08:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 104daa71b396 ("PCI: Determine actual VPD size on first access")
introduced a regression in cxgb4 driver and used to fail in pci probe.

The problem is stemming from the fact that the Chelsio adapters actually
have two VPD structures stored in the VPD. An abbreviated on at Offset 0x0
and the complete VPD at Offset 0x400. The abbreviated one only contains
the PN, SN and EC Keywords, while the complete VPD contains those plus
various adapter constants contained in V0, V1, etc. And it also contains
the Base Ethernet MAC Address in the "NA" Keyword which the cxgb4 driver
needs when it can't contact the adapter firmware. (We don't have the "NA"
Keywork in the VPD Structure at Offset 0x0 because that's not an allowed
VPD Keyword in the PCI-E 3.0 specification.)

With the new code, the computed size of the VPD is 0x200 and so our efforts
to read the VPD at Offset 0x400 silently fails. We check the result of the
read looking for a signature 0x82 byte but we're checking against random
stack garbage.

The fix is to add a PCI helper function to set the VPD size, so the
driver can expicitly set the exact size of the VPD.

Fixes commit 104daa71b396 ("PCI: Determine actual VPD size on first access")

Signed-off-by: Casey Leedom <leedom@chelsio.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 10 +++++++
 drivers/pci/access.c                       | 42 ++++++++++++++++++++++++++++++
 drivers/pci/pci.h                          |  1 +
 include/linux/pci.h                        |  1 +
 4 files changed, 54 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index cc1736bece0f..2033159e26a5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -2557,6 +2557,7 @@ void t4_get_regs(struct adapter *adap, void *buf, size_t buf_size)
 }
 
 #define EEPROM_STAT_ADDR   0x7bfc
+#define VPD_SIZE           0x800
 #define VPD_BASE           0x400
 #define VPD_BASE_OLD       0
 #define VPD_LEN            1024
@@ -2594,6 +2595,15 @@ int t4_get_raw_vpd_params(struct adapter *adapter, struct vpd_params *p)
 	if (!vpd)
 		return -ENOMEM;
 
+	/* We have two VPD data structures stored in the adapter VPD area.
+	 * By default, Linux calculates the size of the VPD area by traversing
+	 * the first VPD area at offset 0x0, so we need to tell the OS what
+	 * our real VPD size is.
+	 */
+	ret = pci_set_size_vpd(adapter->pdev, VPD_SIZE);
+	if (ret < 0)
+		goto out;
+
 	/* Card information normally starts at VPD_BASE but early cards had
 	 * it at 0.
 	 */
diff --git a/drivers/pci/access.c b/drivers/pci/access.c
index 01b9d0a00abc..e69b3877bd37 100644
--- a/drivers/pci/access.c
+++ b/drivers/pci/access.c
@@ -275,6 +275,19 @@ ssize_t pci_write_vpd(struct pci_dev *dev, loff_t pos, size_t count, const void
 }
 EXPORT_SYMBOL(pci_write_vpd);
 
+/**
+ * pci_set_size_vpd - Set size of Vital Product Data space
+ * @dev:	pci device struct
+ * @len:	size of vpd space
+ */
+ssize_t pci_set_size_vpd(struct pci_dev *dev, size_t len)
+{
+	if (!dev->vpd || !dev->vpd->ops)
+		return -ENODEV;
+	return dev->vpd->ops->set_size(dev, len);
+}
+EXPORT_SYMBOL(pci_set_size_vpd);
+
 #define PCI_VPD_MAX_SIZE (PCI_VPD_ADDR_MASK + 1)
 
 /**
@@ -498,9 +511,23 @@ out:
 	return ret ? ret : count;
 }
 
+static ssize_t pci_vpd_set_size(struct pci_dev *dev, size_t len)
+{
+	struct pci_vpd *vpd = dev->vpd;
+
+	if (len == 0 || len > PCI_VPD_MAX_SIZE)
+		return -EIO;
+
+	vpd->valid = 1;
+	vpd->len = len;
+
+	return 0;
+}
+
 static const struct pci_vpd_ops pci_vpd_ops = {
 	.read = pci_vpd_read,
 	.write = pci_vpd_write,
+	.set_size = pci_vpd_set_size,
 };
 
 static ssize_t pci_vpd_f0_read(struct pci_dev *dev, loff_t pos, size_t count,
@@ -533,9 +560,24 @@ static ssize_t pci_vpd_f0_write(struct pci_dev *dev, loff_t pos, size_t count,
 	return ret;
 }
 
+static ssize_t pci_vpd_f0_set_size(struct pci_dev *dev, size_t len)
+{
+	struct pci_dev *tdev = pci_get_slot(dev->bus,
+					    PCI_DEVFN(PCI_SLOT(dev->devfn), 0));
+	ssize_t ret;
+
+	if (!tdev)
+		return -ENODEV;
+
+	ret = pci_set_size_vpd(tdev, len);
+	pci_dev_put(tdev);
+	return ret;
+}
+
 static const struct pci_vpd_ops pci_vpd_f0_ops = {
 	.read = pci_vpd_f0_read,
 	.write = pci_vpd_f0_write,
+	.set_size = pci_vpd_f0_set_size,
 };
 
 int pci_vpd_init(struct pci_dev *dev)
diff --git a/drivers/pci/pci.h b/drivers/pci/pci.h
index d0fb93481573..8239d186f1ed 100644
--- a/drivers/pci/pci.h
+++ b/drivers/pci/pci.h
@@ -97,6 +97,7 @@ static inline bool pci_has_subordinate(struct pci_dev *pci_dev)
 struct pci_vpd_ops {
 	ssize_t (*read)(struct pci_dev *dev, loff_t pos, size_t count, void *buf);
 	ssize_t (*write)(struct pci_dev *dev, loff_t pos, size_t count, const void *buf);
+	ssize_t (*set_size)(struct pci_dev *dev, size_t len);
 };
 
 struct pci_vpd {
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 004b8133417d..1ab1b7458a8b 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1111,6 +1111,7 @@ void pci_unlock_rescan_remove(void);
 /* Vital product data routines */
 ssize_t pci_read_vpd(struct pci_dev *dev, loff_t pos, size_t count, void *buf);
 ssize_t pci_write_vpd(struct pci_dev *dev, loff_t pos, size_t count, const void *buf);
+ssize_t pci_set_size_vpd(struct pci_dev *dev, size_t len);
 
 /* Helper functions for low-level code (drivers/pci/setup-[bus,res].c) */
 resource_size_t pcibios_retrieve_fw_addr(struct pci_dev *dev, int idx);
-- 
2.3.4
