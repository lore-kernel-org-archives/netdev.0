From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V3 3/9] liquidio CN23XX: VF config setup
Date: Mon, 28 Nov 2016 16:54:35 -0800
Message-ID: <1480380881-19255-4-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1480380881-19255-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-cys01nam02on0085.outbound.protection.outlook.com ([104.47.37.85]:55098
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753542AbcK2AzS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 19:55:18 -0500
In-Reply-To: <1480380881-19255-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for setting up VF configuration.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/Makefile      |   2 +
 .../ethernet/cavium/liquidio/cn23xx_vf_device.c    |  44 +++++++
 .../ethernet/cavium/liquidio/cn23xx_vf_device.h    |   2 +
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 136 +++++++++++++++++++++
 .../net/ethernet/cavium/liquidio/octeon_device.c   |  11 +-
 5 files changed, 191 insertions(+), 4 deletions(-)
 create mode 100644 drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c

diff --git a/drivers/net/ethernet/cavium/liquidio/Makefile b/drivers/net/ethernet/cavium/liquidio/Makefile
index 69d23fc..c4d411d 100644
--- a/drivers/net/ethernet/cavium/liquidio/Makefile
+++ b/drivers/net/ethernet/cavium/liquidio/Makefile
@@ -11,6 +11,7 @@ liquidio-$(CONFIG_LIQUIDIO) += lio_ethtool.o \
 			cn66xx_device.o    \
 			cn68xx_device.o    \
 			cn23xx_pf_device.o \
+			cn23xx_vf_device.o \
 			octeon_mailbox.o   \
 			octeon_mem_ops.o   \
 			octeon_droq.o      \
@@ -31,6 +32,7 @@ liquidio_vf-$(CONFIG_LIQUIDIO_VF) += lio_ethtool.o \
 			cn66xx_device.o    \
 			cn68xx_device.o    \
 			cn23xx_pf_device.o \
+			cn23xx_vf_device.o \
 			octeon_mailbox.o   \
 			octeon_mem_ops.o   \
 			octeon_droq.o      \
diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c
new file mode 100644
index 0000000..d683bda
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c
@@ -0,0 +1,44 @@
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
+#include <linux/netdevice.h>
+#include "liquidio_common.h"
+#include "octeon_droq.h"
+#include "octeon_iq.h"
+#include "response_manager.h"
+#include "octeon_device.h"
+#include "cn23xx_vf_device.h"
+#include "octeon_main.h"
+
+int cn23xx_setup_octeon_vf_device(struct octeon_device *oct)
+{
+	struct octeon_cn23xx_vf *cn23xx = (struct octeon_cn23xx_vf *)oct->chip;
+
+	if (octeon_map_pci_barx(oct, 0, 0))
+		return 1;
+
+	cn23xx->conf  = oct_get_config_info(oct, LIO_23XX);
+	if (!cn23xx->conf) {
+		dev_err(&oct->pci_dev->dev, "%s No Config found for CN23XX\n",
+			__func__);
+		octeon_unmap_pci_barx(oct, 0);
+		return 1;
+	}
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
index 015b6d4..9e4fb50 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
@@ -31,4 +31,6 @@
 struct octeon_cn23xx_vf {
 	struct octeon_config *conf;
 };
+
+int cn23xx_setup_octeon_vf_device(struct octeon_device *oct);
 #endif
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index fd108cd..dd1dad1 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -22,6 +22,8 @@
 #include "octeon_iq.h"
 #include "response_manager.h"
 #include "octeon_device.h"
+#include "octeon_main.h"
+#include "cn23xx_vf_device.h"
 
 MODULE_AUTHOR("Cavium Networks, <support@cavium.com>");
 MODULE_DESCRIPTION("Cavium LiquidIO Intelligent Server Adapter Virtual Function Driver");
@@ -37,6 +39,7 @@ struct octeon_device_priv {
 static int
 liquidio_vf_probe(struct pci_dev *pdev, const struct pci_device_id *ent);
 static void liquidio_vf_remove(struct pci_dev *pdev);
+static int octeon_device_init(struct octeon_device *oct);
 
 static const struct pci_device_id liquidio_vf_pci_tbl[] = {
 	{
@@ -84,10 +87,78 @@ struct octeon_device_priv {
 	/* set linux specific device pointer */
 	oct_dev->pci_dev = pdev;
 
+	if (octeon_device_init(oct_dev)) {
+		liquidio_vf_remove(pdev);
+		return -ENOMEM;
+	}
+
+	dev_dbg(&oct_dev->pci_dev->dev, "Device is ready\n");
+
 	return 0;
 }
 
 /**
+ * \brief PCI FLR for each Octeon device.
+ * @param oct octeon device
+ */
+static void octeon_pci_flr(struct octeon_device *oct)
+{
+	u16 status;
+
+	pci_save_state(oct->pci_dev);
+
+	pci_cfg_access_lock(oct->pci_dev);
+
+	/* Quiesce the device completely */
+	pci_write_config_word(oct->pci_dev, PCI_COMMAND,
+			      PCI_COMMAND_INTX_DISABLE);
+
+	/* Wait for Transaction Pending bit clean */
+	msleep(100);
+	pcie_capability_read_word(oct->pci_dev, PCI_EXP_DEVSTA, &status);
+	if (status & PCI_EXP_DEVSTA_TRPND) {
+		dev_info(&oct->pci_dev->dev, "Function reset incomplete after 100ms, sleeping for 5 seconds\n");
+		ssleep(5);
+		pcie_capability_read_word(oct->pci_dev, PCI_EXP_DEVSTA,
+					  &status);
+		if (status & PCI_EXP_DEVSTA_TRPND)
+			dev_info(&oct->pci_dev->dev, "Function reset still incomplete after 5s, reset anyway\n");
+	}
+	pcie_capability_set_word(oct->pci_dev, PCI_EXP_DEVCTL,
+				 PCI_EXP_DEVCTL_BCR_FLR);
+	mdelay(100);
+
+	pci_cfg_access_unlock(oct->pci_dev);
+
+	pci_restore_state(oct->pci_dev);
+}
+
+/**
+ *\brief Destroy resources associated with octeon device
+ * @param pdev PCI device structure
+ * @param ent unused
+ */
+static void octeon_destroy_resources(struct octeon_device *oct)
+{
+	switch (atomic_read(&oct->status)) {
+	case OCT_DEV_PCI_MAP_DONE:
+		octeon_unmap_pci_barx(oct, 0);
+		octeon_unmap_pci_barx(oct, 1);
+
+	/* fallthrough */
+	case OCT_DEV_PCI_ENABLE_DONE:
+		pci_clear_master(oct->pci_dev);
+		/* Disable the device, releasing the PCI INT */
+		pci_disable_device(oct->pci_dev);
+
+	/* fallthrough */
+	case OCT_DEV_BEGIN_STATE:
+		/* Nothing to be done here either */
+		break;
+	}
+}
+
+/**
  * \brief Cleans up resources at unload time
  * @param pdev PCI device structure
  */
@@ -97,12 +168,77 @@ static void liquidio_vf_remove(struct pci_dev *pdev)
 
 	dev_dbg(&oct_dev->pci_dev->dev, "Stopping device\n");
 
+	/* Reset the octeon device and cleanup all memory allocated for
+	 * the octeon device by driver.
+	 */
+	octeon_destroy_resources(oct_dev);
+
+	dev_info(&oct_dev->pci_dev->dev, "Device removed\n");
+
 	/* This octeon device has been removed. Update the global
 	 * data structure to reflect this. Free the device structure.
 	 */
 	octeon_free_device_mem(oct_dev);
 }
 
+/**
+ * \brief PCI initialization for each Octeon device.
+ * @param oct octeon device
+ */
+static int octeon_pci_os_setup(struct octeon_device *oct)
+{
+#ifdef CONFIG_PCI_IOV
+	/* setup PCI stuff first */
+	if (!oct->pci_dev->physfn)
+		octeon_pci_flr(oct);
+#endif
+
+	if (pci_enable_device(oct->pci_dev)) {
+		dev_err(&oct->pci_dev->dev, "pci_enable_device failed\n");
+		return 1;
+	}
+
+	if (dma_set_mask_and_coherent(&oct->pci_dev->dev, DMA_BIT_MASK(64))) {
+		dev_err(&oct->pci_dev->dev, "Unexpected DMA device capability\n");
+		pci_disable_device(oct->pci_dev);
+		return 1;
+	}
+
+	/* Enable PCI DMA Master. */
+	pci_set_master(oct->pci_dev);
+
+	return 0;
+}
+
+/**
+ * \brief Device initialization for each Octeon device that is probed
+ * @param octeon_dev  octeon device
+ */
+static int octeon_device_init(struct octeon_device *oct)
+{
+	u32 rev_id;
+
+	atomic_set(&oct->status, OCT_DEV_BEGIN_STATE);
+
+	/* Enable access to the octeon device and make its DMA capability
+	 * known to the OS.
+	 */
+	if (octeon_pci_os_setup(oct))
+		return 1;
+	atomic_set(&oct->status, OCT_DEV_PCI_ENABLE_DONE);
+
+	oct->chip_id = OCTEON_CN23XX_VF_VID;
+	pci_read_config_dword(oct->pci_dev, 8, &rev_id);
+	oct->rev_id = rev_id & 0xff;
+
+	if (cn23xx_setup_octeon_vf_device(oct))
+		return 1;
+
+	atomic_set(&oct->status, OCT_DEV_PCI_MAP_DONE);
+
+	return 0;
+}
+
 static int __init liquidio_vf_init(void)
 {
 	octeon_init_device_list(0);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 05bb0fd..7e6c8b8 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -572,15 +572,17 @@ static void *__retrieve_octeon_config_info(struct octeon_device *oct,
 	switch (oct_conf_info[oct_id].conf_type) {
 	case OCTEON_CONFIG_TYPE_DEFAULT:
 		if (oct->chip_id == OCTEON_CN66XX) {
-			ret = (void *)&default_cn66xx_conf;
+			ret = &default_cn66xx_conf;
 		} else if ((oct->chip_id == OCTEON_CN68XX) &&
 			   (card_type == LIO_210NV)) {
-			ret =  (void *)&default_cn68xx_210nv_conf;
+			ret = &default_cn68xx_210nv_conf;
 		} else if ((oct->chip_id == OCTEON_CN68XX) &&
 			   (card_type == LIO_410NV)) {
-			ret =  (void *)&default_cn68xx_conf;
+			ret = &default_cn68xx_conf;
 		} else if (oct->chip_id == OCTEON_CN23XX_PF_VID) {
-			ret =  (void *)&default_cn23xx_conf;
+			ret = &default_cn23xx_conf;
+		} else if (oct->chip_id == OCTEON_CN23XX_VF_VID) {
+			ret = &default_cn23xx_conf;
 		}
 		break;
 	default:
@@ -596,6 +598,7 @@ static int __verify_octeon_config_info(struct octeon_device *oct, void *conf)
 	case OCTEON_CN68XX:
 		return lio_validate_cn6xxx_config_info(oct, conf);
 	case OCTEON_CN23XX_PF_VID:
+	case OCTEON_CN23XX_VF_VID:
 		return 0;
 	default:
 		break;
-- 
1.8.3.1
