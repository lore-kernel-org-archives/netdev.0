From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v3 01/29] fm10k: Add skeletal frame for Intel(R) FM10000 Ethernet Switch Host Interface Driver
Date: Tue, 23 Sep 2014 04:16:29 -0700
Message-ID: <1411471017-28213-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10551 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753694AbaIWLRF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 07:17:05 -0400
In-Reply-To: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch adds the beginning framework onto which I am going to add the
fm10k driver which supports the Intel(R) FM10000 Ethernet Switch Host
Interface.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/Kconfig            |  19 ++++
 drivers/net/ethernet/intel/Makefile           |   1 +
 drivers/net/ethernet/intel/fm10k/Makefile     |  30 ++++++
 drivers/net/ethernet/intel/fm10k/fm10k.h      |  39 +++++++
 drivers/net/ethernet/intel/fm10k/fm10k_main.c |  67 ++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c  | 145 ++++++++++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_type.h |  27 +++++
 7 files changed, 328 insertions(+)
 create mode 100644 drivers/net/ethernet/intel/fm10k/Makefile
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k.h
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_main.c
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_pci.c
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_type.h

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index bb9f0ba..6a6d5ee 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -300,4 +300,23 @@ config I40EVF
 	  will be called i40evf.  MSI-X interrupt support is required
 	  for this driver to work correctly.
 
+config FM10K
+	tristate "Intel(R) FM10000 Ethernet Switch Host Interface Support"
+	default n
+	depends on PCI_MSI
+	---help---
+	  This driver supports Intel(R) FM10000 Ethernet Switch Host
+	  Interface.  For more information on how to identify your adapter,
+	  go to the Adapter & Driver ID Guide at:
+
+	  <http://support.intel.com/support/network/sb/CS-008441.htm>
+
+	  For general information and support, go to the Intel support
+	  website at:
+
+	  <http://support.intel.com>
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called fm10k.  MSI-X interrupt support is required
+
 endif # NET_VENDOR_INTEL
diff --git a/drivers/net/ethernet/intel/Makefile b/drivers/net/ethernet/intel/Makefile
index cdbbca8..5ea764d 100644
--- a/drivers/net/ethernet/intel/Makefile
+++ b/drivers/net/ethernet/intel/Makefile
@@ -12,3 +12,4 @@ obj-$(CONFIG_IXGBEVF) += ixgbevf/
 obj-$(CONFIG_I40E) += i40e/
 obj-$(CONFIG_IXGB) += ixgb/
 obj-$(CONFIG_I40EVF) += i40evf/
+obj-$(CONFIG_FM10K) += fm10k/
diff --git a/drivers/net/ethernet/intel/fm10k/Makefile b/drivers/net/ethernet/intel/fm10k/Makefile
new file mode 100644
index 0000000..ddc0eb7
--- /dev/null
+++ b/drivers/net/ethernet/intel/fm10k/Makefile
@@ -0,0 +1,30 @@
+################################################################################
+#
+# Intel Ethernet Switch Host Interface Driver
+# Copyright(c) 2013 - 2014 Intel Corporation.
+#
+# This program is free software; you can redistribute it and/or modify it
+# under the terms and conditions of the GNU General Public License,
+# version 2, as published by the Free Software Foundation.
+#
+# This program is distributed in the hope it will be useful, but WITHOUT
+# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+# more details.
+#
+# The full GNU General Public License is included in this distribution in
+# the file called "COPYING".
+#
+# Contact Information:
+# e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+# Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+#
+################################################################################
+
+#
+# Makefile for the Intel(R) FM10000 Ethernet Switch Host Interface driver
+#
+
+obj-$(CONFIG_FM10K) += fm10k.o
+
+fm10k-objs := fm10k_main.o fm10k_pci.o
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
new file mode 100644
index 0000000..2e27bd9
--- /dev/null
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -0,0 +1,39 @@
+/* Intel Ethernet Switch Host Interface Driver
+ * Copyright(c) 2013 - 2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
+
+#ifndef _FM10K_H_
+#define _FM10K_H_
+
+#include <linux/types.h>
+#include <linux/etherdevice.h>
+#include <linux/rtnetlink.h>
+#include <linux/if_vlan.h>
+#include <linux/pci.h>
+
+#include "fm10k_type.h"
+
+/* main */
+extern char fm10k_driver_name[];
+extern const char fm10k_driver_version[];
+
+/* PCI */
+int fm10k_register_pci_driver(void);
+void fm10k_unregister_pci_driver(void);
+#endif /* _FM10K_H_ */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
new file mode 100644
index 0000000..a7822b8
--- /dev/null
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -0,0 +1,67 @@
+/* Intel Ethernet Switch Host Interface Driver
+ * Copyright(c) 2013 - 2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
+
+#include <linux/types.h>
+#include <linux/module.h>
+#include <net/ipv6.h>
+#include <net/ip.h>
+#include <net/tcp.h>
+#include <linux/if_macvlan.h>
+
+#include "fm10k.h"
+
+#define DRV_VERSION	"0.12.2-k"
+const char fm10k_driver_version[] = DRV_VERSION;
+char fm10k_driver_name[] = "fm10k";
+static const char fm10k_driver_string[] =
+	"Intel(R) Ethernet Switch Host Interface Driver";
+static const char fm10k_copyright[] =
+	"Copyright (c) 2013 Intel Corporation.";
+
+MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
+MODULE_DESCRIPTION("Intel(R) Ethernet Switch Host Interface Driver");
+MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
+
+/** fm10k_init_module - Driver Registration Routine
+ *
+ * fm10k_init_module is the first routine called when the driver is
+ * loaded.  All it does is register with the PCI subsystem.
+ **/
+static int __init fm10k_init_module(void)
+{
+	pr_info("%s - version %s\n", fm10k_driver_string, fm10k_driver_version);
+	pr_info("%s\n", fm10k_copyright);
+
+	return fm10k_register_pci_driver();
+}
+module_init(fm10k_init_module);
+
+/**
+ * fm10k_exit_module - Driver Exit Cleanup Routine
+ *
+ * fm10k_exit_module is called just before the driver is removed
+ * from memory.
+ **/
+static void __exit fm10k_exit_module(void)
+{
+	fm10k_unregister_pci_driver();
+}
+module_exit(fm10k_exit_module);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
new file mode 100644
index 0000000..12089ce
--- /dev/null
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -0,0 +1,145 @@
+/* Intel Ethernet Switch Host Interface Driver
+ * Copyright(c) 2013 - 2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
+
+#include <linux/module.h>
+
+#include "fm10k.h"
+
+/**
+ * fm10k_pci_tbl - PCI Device ID Table
+ *
+ * Wildcard entries (PCI_ANY_ID) should come last
+ * Last entry must be all 0s
+ *
+ * { Vendor ID, Device ID, SubVendor ID, SubDevice ID,
+ *   Class, Class Mask, private data (not used) }
+ */
+static const struct pci_device_id fm10k_pci_tbl[] = {
+	{ PCI_VDEVICE(INTEL, FM10K_DEV_ID_PF) },
+	/* required last entry */
+	{ 0, }
+};
+MODULE_DEVICE_TABLE(pci, fm10k_pci_tbl);
+
+/**
+ * fm10k_probe - Device Initialization Routine
+ * @pdev: PCI device information struct
+ * @ent: entry in fm10k_pci_tbl
+ *
+ * Returns 0 on success, negative on failure
+ *
+ * fm10k_probe initializes an interface identified by a pci_dev structure.
+ * The OS initialization, configuring of the interface private structure,
+ * and a hardware reset occur.
+ **/
+static int fm10k_probe(struct pci_dev *pdev,
+		       const struct pci_device_id *ent)
+{
+	int err;
+	u64 dma_mask;
+
+	err = pci_enable_device_mem(pdev);
+	if (err)
+		return err;
+
+	/* By default fm10k only supports a 48 bit DMA mask */
+	dma_mask = DMA_BIT_MASK(48) | dma_get_required_mask(&pdev->dev);
+
+	if ((dma_mask <= DMA_BIT_MASK(32)) ||
+	    dma_set_mask_and_coherent(&pdev->dev, dma_mask)) {
+		dma_mask &= DMA_BIT_MASK(32);
+
+		err = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
+		err = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
+		if (err) {
+			err = dma_set_coherent_mask(&pdev->dev,
+						    DMA_BIT_MASK(32));
+			if (err) {
+				dev_err(&pdev->dev,
+					"No usable DMA configuration, aborting\n");
+				goto err_dma;
+			}
+		}
+	}
+
+	err = pci_request_selected_regions(pdev,
+					   pci_select_bars(pdev,
+							   IORESOURCE_MEM),
+					   fm10k_driver_name);
+	if (err) {
+		dev_err(&pdev->dev,
+			"pci_request_selected_regions failed 0x%x\n", err);
+		goto err_pci_reg;
+	}
+
+	pci_set_master(pdev);
+	pci_save_state(pdev);
+
+	return 0;
+
+err_pci_reg:
+err_dma:
+	pci_disable_device(pdev);
+	return err;
+}
+
+/**
+ * fm10k_remove - Device Removal Routine
+ * @pdev: PCI device information struct
+ *
+ * fm10k_remove is called by the PCI subsystem to alert the driver
+ * that it should release a PCI device.  The could be caused by a
+ * Hot-Plug event, or because the driver is going to be removed from
+ * memory.
+ **/
+static void fm10k_remove(struct pci_dev *pdev)
+{
+	pci_release_selected_regions(pdev,
+				     pci_select_bars(pdev, IORESOURCE_MEM));
+
+	pci_disable_device(pdev);
+}
+
+static struct pci_driver fm10k_driver = {
+	.name			= fm10k_driver_name,
+	.id_table		= fm10k_pci_tbl,
+	.probe			= fm10k_probe,
+	.remove			= fm10k_remove,
+};
+
+/**
+ * fm10k_register_pci_driver - register driver interface
+ *
+ * This funciton is called on module load in order to register the driver.
+ **/
+int fm10k_register_pci_driver(void)
+{
+	return pci_register_driver(&fm10k_driver);
+}
+
+/**
+ * fm10k_unregister_pci_driver - unregister driver interface
+ *
+ * This funciton is called on module unload in order to remove the driver.
+ **/
+void fm10k_unregister_pci_driver(void)
+{
+	pci_unregister_driver(&fm10k_driver);
+}
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_type.h b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
new file mode 100644
index 0000000..2c06f02
--- /dev/null
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
@@ -0,0 +1,27 @@
+/* Intel Ethernet Switch Host Interface Driver
+ * Copyright(c) 2013 - 2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
+
+#ifndef _FM10K_TYPE_H_
+#define _FM10K_TYPE_H_
+
+#define FM10K_DEV_ID_PF			0x15A4
+#define FM10K_DEV_ID_VF			0x15A5
+
+#endif /* _FM10K_TYPE_H */
-- 
1.9.3
