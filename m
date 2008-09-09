From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/9] PCI: add interface to set visible size of VPD (rev3)
Date: Tue, 09 Sep 2008 11:20:43 -0700
Message-ID: <20080909182057.103624821@vyatta.com>
References: <20080909182040.246073057@vyatta.com>
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:37565 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753976AbYIIT3V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 15:29:21 -0400
Content-Disposition: inline; filename=vpd-size.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The VPD on all devices may not be 32K. Unfortunately, there is no
generic way to find the size, so this adds a simple API hook
to reset it.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/pci/access.c |   23 +++++++++++++++++++++++
 include/linux/pci.h  |    1 +
 2 files changed, 24 insertions(+)

--- a/drivers/pci/access.c	2008-09-09 11:00:09.000000000 -0700
+++ b/drivers/pci/access.c	2008-09-09 11:18:05.000000000 -0700
@@ -339,6 +339,29 @@ int pci_vpd_pci22_init(struct pci_dev *d
 }
 
 /**
+ * pci_vpd_truncate - Set available Vital Product Data size
+ * @dev:	pci device struct
+ * @size:	available memory in bytes
+ *
+ * Adjust size of available VPD area.
+ */
+int pci_vpd_truncate(struct pci_dev *dev, size_t size)
+{
+	if (!dev->vpd)
+		return -EINVAL;
+
+	/* limited by the access method */
+	if (size > dev->vpd->len)
+		return -EINVAL;
+
+	dev->vpd->len = size;
+	dev->vpd->attr->size = size;
+
+	return 0;
+}
+EXPORT_SYMBOL(pci_vpd_truncate);
+
+/**
  * pci_block_user_cfg_access - Block userspace PCI config reads/writes
  * @dev:	pci device struct
  *
--- a/include/linux/pci.h	2008-09-09 11:01:07.000000000 -0700
+++ b/include/linux/pci.h	2008-09-09 11:17:49.000000000 -0700
@@ -653,6 +653,7 @@ int pci_bus_find_capability(struct pci_b
 /* Vital product data routines */
 ssize_t pci_read_vpd(struct pci_dev *dev, loff_t pos, size_t count, void *buf);
 ssize_t pci_write_vpd(struct pci_dev *dev, loff_t pos, size_t count, const void *buf);
+int pci_vpd_truncate(struct pci_dev *dev, size_t size);
 
 /* Helper functions for low-level code (drivers/pci/setup-[bus,res].c) */
 void pci_bus_assign_resources(struct pci_bus *bus);

-- 

