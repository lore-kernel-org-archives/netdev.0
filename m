From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/8] PCI: add interface to set visible size of VPD (rev3)
Date: Wed, 17 Dec 2008 16:01:47 -0800
Message-ID: <20081218000241.020462227@vyatta.com>
References: <20081218000144.964015472@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52774 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752015AbYLRAFh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2008 19:05:37 -0500
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

--- a/drivers/pci/access.c	2008-10-25 09:01:54.000000000 -0700
+++ b/drivers/pci/access.c	2008-10-25 09:03:27.000000000 -0700
@@ -340,6 +340,29 @@ int pci_vpd_pci22_init(struct pci_dev *d
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
--- a/include/linux/pci.h	2008-10-25 09:01:54.000000000 -0700
+++ b/include/linux/pci.h	2008-10-25 09:03:27.000000000 -0700
@@ -672,6 +672,7 @@ int pci_bus_find_capability(struct pci_b
 /* Vital product data routines */
 ssize_t pci_read_vpd(struct pci_dev *dev, loff_t pos, size_t count, void *buf);
 ssize_t pci_write_vpd(struct pci_dev *dev, loff_t pos, size_t count, const void *buf);
+int pci_vpd_truncate(struct pci_dev *dev, size_t size);
 
 /* Helper functions for low-level code (drivers/pci/setup-[bus,res].c) */
 void pci_bus_assign_resources(struct pci_bus *bus);

-- 

