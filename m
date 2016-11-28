From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 2/9] liquidio CN23XX: VF registration
Date: Sun, 27 Nov 2016 20:51:35 -0800
Message-ID: <1480308702-6261-3-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1480308702-6261-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0089.outbound.protection.outlook.com ([104.47.41.89]:13344
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753327AbcK1EwX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Nov 2016 23:52:23 -0500
In-Reply-To: <1480308702-6261-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for cn23xx VF probe and registration.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/Kconfig                |  12 +++
 drivers/net/ethernet/cavium/liquidio/Makefile      |  21 ++++
 .../ethernet/cavium/liquidio/cn23xx_vf_device.h    |  34 ++++++
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 120 +++++++++++++++++++++
 .../net/ethernet/cavium/liquidio/octeon_device.c   |   4 +
 5 files changed, 191 insertions(+)
 create mode 100644 drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
 create mode 100644 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c

diff --git a/drivers/net/ethernet/cavium/Kconfig b/drivers/net/ethernet/cavium/Kconfig
index 92f411c..c0679c2 100644
--- a/drivers/net/ethernet/cavium/Kconfig
+++ b/drivers/net/ethernet/cavium/Kconfig
@@ -74,4 +74,16 @@ config OCTEON_MGMT_ETHERNET
 	  port on Cavium Networks' Octeon CN57XX, CN56XX, CN55XX,
 	  CN54XX, CN52XX, and CN6XXX chips.
 
+config LIQUIDIO_VF
+	tristate "Cavium LiquidIO VF support"
+	depends on 64BIT && PCI_MSI
+	select PTP_1588_CLOCK
+	---help---
+	  This driver supports Cavium LiquidIO Intelligent Server Adapter
+	  based on CN23XX chips.
+
+	  To compile this driver as a module, choose M here: The module
+	  will be called liquidio_vf. MSI-X interrupt support is required
+	  for this driver to work correctly
+
 endif # NET_VENDOR_CAVIUM
diff --git a/drivers/net/ethernet/cavium/liquidio/Makefile b/drivers/net/ethernet/cavium/liquidio/Makefile
index 14958de..69d23fc 100644
--- a/drivers/net/ethernet/cavium/liquidio/Makefile
+++ b/drivers/net/ethernet/cavium/liquidio/Makefile
@@ -17,3 +17,24 @@ liquidio-$(CONFIG_LIQUIDIO) += lio_ethtool.o \
 			octeon_nic.o
 
 liquidio-objs := lio_main.o octeon_console.o $(liquidio-y)
+
+obj-$(CONFIG_LIQUIDIO_VF) += liquidio_vf.o
+
+ifeq ($(CONFIG_LIQUIDIO)$(CONFIG_LIQUIDIO_VF), yy)
+	liquidio_vf-objs := lio_vf_main.o
+else
+liquidio_vf-$(CONFIG_LIQUIDIO_VF) += lio_ethtool.o \
+			lio_core.o         \
+			request_manager.o  \
+			response_manager.o \
+			octeon_device.o    \
+			cn66xx_device.o    \
+			cn68xx_device.o    \
+			cn23xx_pf_device.o \
+			octeon_mailbox.o   \
+			octeon_mem_ops.o   \
+			octeon_droq.o      \
+			octeon_nic.o
+
+liquidio_vf-objs := lio_vf_main.o $(liquidio_vf-y)
+endif
diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
new file mode 100644
index 0000000..015b6d4
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
@@ -0,0 +1,34 @@
+/**********************************************************************
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2016 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
+/*! \file  cn23xx_device.h
+ * \brief Host Driver: Routines that perform CN23XX specific operations.
+ */
+
+#ifndef __CN23XX_VF_DEVICE_H__
+#define __CN23XX_VF_DEVICE_H__
+
+#include "cn23xx_vf_regs.h"
+
+/* Register address and configuration for a CN23XX devices.
+ * If device specific changes need to be made then add a struct to include
+ * device specific fields as shown in the commented section
+ */
+struct octeon_cn23xx_vf {
+	struct octeon_config *conf;
+};
+#endif
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
new file mode 100644
index 0000000..d1b1a24
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -0,0 +1,120 @@
+/**********************************************************************
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2016 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
+#include <linux/pci.h>
+#include <net/vxlan.h>
+#include "liquidio_common.h"
+#include "octeon_droq.h"
+#include "octeon_iq.h"
+#include "response_manager.h"
+#include "octeon_device.h"
+
+MODULE_AUTHOR("Cavium Networks, <support@cavium.com>");
+MODULE_DESCRIPTION("Cavium LiquidIO Intelligent Server Adapter Virtual Function Driver");
+MODULE_LICENSE("GPL");
+MODULE_VERSION(LIQUIDIO_VERSION);
+
+struct octeon_device_priv {
+	/* Tasklet structures for this device. */
+	struct tasklet_struct droq_tasklet;
+	unsigned long napi_mask;
+};
+
+static int
+liquidio_vf_probe(struct pci_dev *pdev, const struct pci_device_id *ent);
+static void liquidio_vf_remove(struct pci_dev *pdev);
+
+static const struct pci_device_id liquidio_vf_pci_tbl[] = {
+	{
+		PCI_VENDOR_ID_CAVIUM, OCTEON_CN23XX_VF_VID,
+		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0
+	},
+	{
+		0, 0, 0, 0, 0, 0, 0
+	}
+};
+MODULE_DEVICE_TABLE(pci, liquidio_vf_pci_tbl);
+
+static struct pci_driver liquidio_vf_pci_driver = {
+	.name		= "LiquidIO_VF",
+	.id_table	= liquidio_vf_pci_tbl,
+	.probe		= liquidio_vf_probe,
+	.remove		= liquidio_vf_remove,
+};
+
+/**
+ * \brief PCI probe handler
+ * @param pdev PCI device structure
+ * @param ent unused
+ */
+static int
+liquidio_vf_probe(struct pci_dev *pdev,
+		  const struct pci_device_id *ent __attribute__((unused)))
+{
+	struct octeon_device *oct_dev = NULL;
+
+	oct_dev = octeon_allocate_device(pdev->device,
+					 sizeof(struct octeon_device_priv));
+
+	if (!oct_dev) {
+		dev_err(&pdev->dev, "Unable to allocate device\n");
+		return -ENOMEM;
+	}
+
+	dev_info(&pdev->dev, "Initializing device %x:%x.\n",
+		 (u32)pdev->vendor, (u32)pdev->device);
+
+	/* Assign octeon_device for this device to the private data area. */
+	pci_set_drvdata(pdev, oct_dev);
+
+	/* set linux specific device pointer */
+	oct_dev->pci_dev = (void *)pdev;
+
+	return 0;
+}
+
+/**
+ * \brief Cleans up resources at unload time
+ * @param pdev PCI device structure
+ */
+static void liquidio_vf_remove(struct pci_dev *pdev)
+{
+	struct octeon_device *oct_dev = pci_get_drvdata(pdev);
+
+	dev_dbg(&oct_dev->pci_dev->dev, "Stopping device\n");
+
+	/* This octeon device has been removed. Update the global
+	 * data structure to reflect this. Free the device structure.
+	 */
+	octeon_free_device_mem(oct_dev);
+}
+
+static int __init liquidio_vf_init(void)
+{
+	octeon_init_device_list(0);
+	return pci_register_driver(&liquidio_vf_pci_driver);
+}
+
+static void __exit liquidio_vf_exit(void)
+{
+	pci_unregister_driver(&liquidio_vf_pci_driver);
+
+	pr_info("LiquidIO_VF network module is now unloaded\n");
+}
+
+module_init(liquidio_vf_init);
+module_exit(liquidio_vf_exit);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 79c8875..05bb0fd 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -28,6 +28,7 @@
 #include "cn66xx_regs.h"
 #include "cn66xx_device.h"
 #include "cn23xx_pf_device.h"
+#include "cn23xx_vf_device.h"
 
 /** Default configuration
  *  for CN66XX OCTEON Models.
@@ -672,6 +673,9 @@ static struct octeon_device *octeon_allocate_device_mem(u32 pci_id,
 	case OCTEON_CN23XX_PF_VID:
 		configsize = sizeof(struct octeon_cn23xx_pf);
 		break;
+	case OCTEON_CN23XX_VF_VID:
+		configsize = sizeof(struct octeon_cn23xx_vf);
+		break;
 	default:
 		pr_err("%s: Unknown PCI Device: 0x%x\n",
 		       __func__,
-- 
1.8.3.1
