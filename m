From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/5] mlxsw: Move PCI id table definitions into driver modules
Date: Thu, 27 Oct 2016 15:12:59 +0200
Message-ID: <1477573981-26546-4-git-send-email-jiri@resnulli.us>
References: <1477573981-26546-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35258 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935004AbcJ0ORR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 10:17:17 -0400
Received: by mail-wm0-f44.google.com with SMTP id e69so37809268wmg.0
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 07:17:16 -0700 (PDT)
In-Reply-To: <1477573981-26546-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

So far, mlxsw_pci.ko is the module that registers PCI table for all
drivers (spectrum and switchx2). That is problematic for example with
dracut. Since mlxsw_spectrum.ko and mlxsw_switchx2.ko are loaded
dynamically from within mlxsw_core.ko, dracut does not have track of
them and avoids them from being included in initramfs.

So make this in an ordinary way and define the PCI tables in individual
driver modules, so it can be properly loaded and included in dracut
initramfs image. As a side effect, this patch could remove no longer
necessary driver "kind" strings which were used to link PCI ids with
individual mlxsw drivers.

Suggested-by: Ivan Vecera <ivecera@redhat.com>
Tested-by: Ivan Vecera <ivecera@redhat.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/Kconfig    |  4 +-
 drivers/net/ethernet/mellanox/mlxsw/core.c     | 14 ------
 drivers/net/ethernet/mellanox/mlxsw/core.h     |  8 ----
 drivers/net/ethernet/mellanox/mlxsw/pci.c      | 56 ++++++++---------------
 drivers/net/ethernet/mellanox/mlxsw/pci.h      | 63 ++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/pci_hw.h   |  2 -
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 25 ++++++++--
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 34 ++++++++++++--
 8 files changed, 135 insertions(+), 71 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/pci.h

diff --git a/drivers/net/ethernet/mellanox/mlxsw/Kconfig b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
index 5989f7c..d0bcf59 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
@@ -31,7 +31,7 @@ config MLXSW_PCI
 
 config MLXSW_SWITCHX2
 	tristate "Mellanox Technologies SwitchX-2 support"
-	depends on MLXSW_CORE && NET_SWITCHDEV
+	depends on MLXSW_CORE && MLXSW_PCI && NET_SWITCHDEV
 	default m
 	---help---
 	  This driver supports Mellanox Technologies SwitchX-2 Ethernet
@@ -42,7 +42,7 @@ config MLXSW_SWITCHX2
 
 config MLXSW_SPECTRUM
 	tristate "Mellanox Technologies Spectrum support"
-	depends on MLXSW_CORE && NET_SWITCHDEV && VLAN_8021Q
+	depends on MLXSW_CORE && MLXSW_PCI && NET_SWITCHDEV && VLAN_8021Q
 	default m
 	---help---
 	  This driver supports Mellanox Technologies Spectrum Ethernet
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index a37d471..02183f6 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -823,17 +823,6 @@ static struct mlxsw_driver *mlxsw_core_driver_get(const char *kind)
 
 	spin_lock(&mlxsw_core_driver_list_lock);
 	mlxsw_driver = __driver_find(kind);
-	if (!mlxsw_driver) {
-		spin_unlock(&mlxsw_core_driver_list_lock);
-		request_module(MLXSW_MODULE_ALIAS_PREFIX "%s", kind);
-		spin_lock(&mlxsw_core_driver_list_lock);
-		mlxsw_driver = __driver_find(kind);
-	}
-	if (mlxsw_driver) {
-		if (!try_module_get(mlxsw_driver->owner))
-			mlxsw_driver = NULL;
-	}
-
 	spin_unlock(&mlxsw_core_driver_list_lock);
 	return mlxsw_driver;
 }
@@ -845,9 +834,6 @@ static void mlxsw_core_driver_put(const char *kind)
 	spin_lock(&mlxsw_core_driver_list_lock);
 	mlxsw_driver = __driver_find(kind);
 	spin_unlock(&mlxsw_core_driver_list_lock);
-	if (!mlxsw_driver)
-		return;
-	module_put(mlxsw_driver->owner);
 }
 
 static int mlxsw_core_debugfs_init(struct mlxsw_core *mlxsw_core)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 94a846d..0cf721c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -51,13 +51,6 @@
 #include "cmd.h"
 #include "resources.h"
 
-#define MLXSW_MODULE_ALIAS_PREFIX "mlxsw-driver-"
-#define MODULE_MLXSW_DRIVER_ALIAS(kind)	\
-	MODULE_ALIAS(MLXSW_MODULE_ALIAS_PREFIX kind)
-
-#define MLXSW_DEVICE_KIND_SWITCHX2 "switchx2"
-#define MLXSW_DEVICE_KIND_SPECTRUM "spectrum"
-
 struct mlxsw_core;
 struct mlxsw_driver;
 struct mlxsw_bus;
@@ -221,7 +214,6 @@ struct mlxsw_config_profile {
 struct mlxsw_driver {
 	struct list_head list;
 	const char *kind;
-	struct module *owner;
 	size_t priv_size;
 	int (*init)(struct mlxsw_core *mlxsw_core,
 		    const struct mlxsw_bus_info *mlxsw_bus_info);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 209630c..63d89f7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -49,6 +49,7 @@
 #include <linux/string.h>
 
 #include "pci_hw.h"
+#include "pci.h"
 #include "core.h"
 #include "cmd.h"
 #include "port.h"
@@ -56,26 +57,8 @@
 
 static const char mlxsw_pci_driver_name[] = "mlxsw_pci";
 
-static const struct pci_device_id mlxsw_pci_id_table[] = {
-	{PCI_VDEVICE(MELLANOX, PCI_DEVICE_ID_MELLANOX_SWITCHX2), 0},
-	{PCI_VDEVICE(MELLANOX, PCI_DEVICE_ID_MELLANOX_SPECTRUM), 0},
-	{0, }
-};
-
 static struct dentry *mlxsw_pci_dbg_root;
 
-static const char *mlxsw_pci_device_kind_get(const struct pci_device_id *id)
-{
-	switch (id->device) {
-	case PCI_DEVICE_ID_MELLANOX_SWITCHX2:
-		return MLXSW_DEVICE_KIND_SWITCHX2;
-	case PCI_DEVICE_ID_MELLANOX_SPECTRUM:
-		return MLXSW_DEVICE_KIND_SPECTRUM;
-	default:
-		BUG();
-	}
-}
-
 #define mlxsw_pci_write32(mlxsw_pci, reg, val) \
 	iowrite32be(val, (mlxsw_pci)->hw_addr + (MLXSW_PCI_ ## reg))
 #define mlxsw_pci_read32(mlxsw_pci, reg) \
@@ -1553,7 +1536,7 @@ static int mlxsw_pci_init(void *bus_priv, struct mlxsw_core *mlxsw_core,
 
 	err = request_irq(mlxsw_pci->msix_entry.vector,
 			  mlxsw_pci_eq_irq_handler, 0,
-			  mlxsw_pci_driver_name, mlxsw_pci);
+			  mlxsw_pci->bus_info.device_kind, mlxsw_pci);
 	if (err) {
 		dev_err(&pdev->dev, "IRQ request failed\n");
 		goto err_request_eq_irq;
@@ -1793,6 +1776,7 @@ static int mlxsw_pci_sw_reset(struct mlxsw_pci *mlxsw_pci)
 
 static int mlxsw_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 {
+	const char *driver_name = pdev->driver->name;
 	struct mlxsw_pci *mlxsw_pci;
 	int err;
 
@@ -1806,7 +1790,7 @@ static int mlxsw_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 		goto err_pci_enable_device;
 	}
 
-	err = pci_request_regions(pdev, mlxsw_pci_driver_name);
+	err = pci_request_regions(pdev, driver_name);
 	if (err) {
 		dev_err(&pdev->dev, "pci_request_regions failed\n");
 		goto err_pci_request_regions;
@@ -1857,7 +1841,7 @@ static int mlxsw_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 		goto err_msix_init;
 	}
 
-	mlxsw_pci->bus_info.device_kind = mlxsw_pci_device_kind_get(id);
+	mlxsw_pci->bus_info.device_kind = driver_name;
 	mlxsw_pci->bus_info.device_name = pci_name(mlxsw_pci->pdev);
 	mlxsw_pci->bus_info.dev = &pdev->dev;
 
@@ -1909,33 +1893,30 @@ static void mlxsw_pci_remove(struct pci_dev *pdev)
 	kfree(mlxsw_pci);
 }
 
-static struct pci_driver mlxsw_pci_driver = {
-	.name		= mlxsw_pci_driver_name,
-	.id_table	= mlxsw_pci_id_table,
-	.probe		= mlxsw_pci_probe,
-	.remove		= mlxsw_pci_remove,
-};
+int mlxsw_pci_driver_register(struct pci_driver *pci_driver)
+{
+	pci_driver->probe = mlxsw_pci_probe;
+	pci_driver->remove = mlxsw_pci_remove;
+	return pci_register_driver(pci_driver);
+}
+EXPORT_SYMBOL(mlxsw_pci_driver_register);
 
-static int __init mlxsw_pci_module_init(void)
+void mlxsw_pci_driver_unregister(struct pci_driver *pci_driver)
 {
-	int err;
+	pci_unregister_driver(pci_driver);
+}
+EXPORT_SYMBOL(mlxsw_pci_driver_unregister);
 
+static int __init mlxsw_pci_module_init(void)
+{
 	mlxsw_pci_dbg_root = debugfs_create_dir(mlxsw_pci_driver_name, NULL);
 	if (!mlxsw_pci_dbg_root)
 		return -ENOMEM;
-	err = pci_register_driver(&mlxsw_pci_driver);
-	if (err)
-		goto err_register_driver;
 	return 0;
-
-err_register_driver:
-	debugfs_remove_recursive(mlxsw_pci_dbg_root);
-	return err;
 }
 
 static void __exit mlxsw_pci_module_exit(void)
 {
-	pci_unregister_driver(&mlxsw_pci_driver);
 	debugfs_remove_recursive(mlxsw_pci_dbg_root);
 }
 
@@ -1945,4 +1926,3 @@ module_exit(mlxsw_pci_module_exit);
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_AUTHOR("Jiri Pirko <jiri@mellanox.com>");
 MODULE_DESCRIPTION("Mellanox switch PCI interface driver");
-MODULE_DEVICE_TABLE(pci, mlxsw_pci_id_table);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.h b/drivers/net/ethernet/mellanox/mlxsw/pci.h
new file mode 100644
index 0000000..35a0011
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.h
@@ -0,0 +1,63 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/pci.h
+ * Copyright (c) 2016 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2016 Jiri Pirko <jiri@mellanox.com>
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. Neither the names of the copyright holders nor the names of its
+ *    contributors may be used to endorse or promote products derived from
+ *    this software without specific prior written permission.
+ *
+ * Alternatively, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") version 2 as published by the Free
+ * Software Foundation.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef _MLXSW_PCI_H
+#define _MLXSW_PCI_H
+
+#include <linux/pci.h>
+
+#define PCI_DEVICE_ID_MELLANOX_SWITCHX2		0xc738
+#define PCI_DEVICE_ID_MELLANOX_SPECTRUM		0xcb84
+
+#if IS_ENABLED(CONFIG_MLXSW_PCI)
+
+int mlxsw_pci_driver_register(struct pci_driver *pci_driver);
+void mlxsw_pci_driver_unregister(struct pci_driver *pci_driver);
+
+#else
+
+static inline int
+mlxsw_pci_driver_register(struct pci_driver *pci_driver)
+{
+	return 0;
+}
+
+static inline void
+mlxsw_pci_driver_unregister(struct pci_driver *pci_driver)
+{
+}
+
+#endif
+
+#endif
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci_hw.h b/drivers/net/ethernet/mellanox/mlxsw/pci_hw.h
index 45bc1979..708736f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci_hw.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci_hw.h
@@ -39,8 +39,6 @@
 
 #include "item.h"
 
-#define PCI_DEVICE_ID_MELLANOX_SWITCHX2	0xc738
-#define PCI_DEVICE_ID_MELLANOX_SPECTRUM	0xcb84
 #define MLXSW_PCI_BAR0_SIZE		(1024 * 1024) /* 1MB */
 #define MLXSW_PCI_PAGE_SIZE		4096
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 5d8f1d5..7805240 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -37,6 +37,7 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/types.h>
+#include <linux/pci.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
@@ -59,6 +60,7 @@
 #include <net/netevent.h>
 
 #include "spectrum.h"
+#include "pci.h"
 #include "core.h"
 #include "reg.h"
 #include "port.h"
@@ -3066,8 +3068,7 @@ static struct mlxsw_config_profile mlxsw_sp_config_profile = {
 };
 
 static struct mlxsw_driver mlxsw_sp_driver = {
-	.kind				= MLXSW_DEVICE_KIND_SPECTRUM,
-	.owner				= THIS_MODULE,
+	.kind				= mlxsw_sp_driver_name,
 	.priv_size			= sizeof(struct mlxsw_sp),
 	.init				= mlxsw_sp_init,
 	.fini				= mlxsw_sp_fini,
@@ -4662,6 +4663,16 @@ static struct notifier_block mlxsw_sp_router_netevent_nb __read_mostly = {
 	.notifier_call = mlxsw_sp_router_netevent_event,
 };
 
+static const struct pci_device_id mlxsw_sp_pci_id_table[] = {
+	{PCI_VDEVICE(MELLANOX, PCI_DEVICE_ID_MELLANOX_SPECTRUM), 0},
+	{0, },
+};
+
+static struct pci_driver mlxsw_sp_pci_driver = {
+	.name = mlxsw_sp_driver_name,
+	.id_table = mlxsw_sp_pci_id_table,
+};
+
 static int __init mlxsw_sp_module_init(void)
 {
 	int err;
@@ -4673,8 +4684,15 @@ static int __init mlxsw_sp_module_init(void)
 	err = mlxsw_core_driver_register(&mlxsw_sp_driver);
 	if (err)
 		goto err_core_driver_register;
+
+	err = mlxsw_pci_driver_register(&mlxsw_sp_pci_driver);
+	if (err)
+		goto err_pci_driver_register;
+
 	return 0;
 
+err_pci_driver_register:
+	mlxsw_core_driver_unregister(&mlxsw_sp_driver);
 err_core_driver_register:
 	unregister_netevent_notifier(&mlxsw_sp_router_netevent_nb);
 	unregister_inetaddr_notifier(&mlxsw_sp_inetaddr_nb);
@@ -4684,6 +4702,7 @@ static int __init mlxsw_sp_module_init(void)
 
 static void __exit mlxsw_sp_module_exit(void)
 {
+	mlxsw_pci_driver_unregister(&mlxsw_sp_pci_driver);
 	mlxsw_core_driver_unregister(&mlxsw_sp_driver);
 	unregister_netevent_notifier(&mlxsw_sp_router_netevent_nb);
 	unregister_inetaddr_notifier(&mlxsw_sp_inetaddr_nb);
@@ -4696,4 +4715,4 @@ module_exit(mlxsw_sp_module_exit);
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_AUTHOR("Jiri Pirko <jiri@mellanox.com>");
 MODULE_DESCRIPTION("Mellanox Spectrum driver");
-MODULE_MLXSW_DRIVER_ALIAS(MLXSW_DEVICE_KIND_SPECTRUM);
+MODULE_DEVICE_TABLE(pci, mlxsw_sp_pci_id_table);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 963618d..938e22d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -37,6 +37,7 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/types.h>
+#include <linux/pci.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/slab.h>
@@ -46,6 +47,7 @@
 #include <net/switchdev.h>
 #include <generated/utsrelease.h>
 
+#include "pci.h"
 #include "core.h"
 #include "reg.h"
 #include "port.h"
@@ -1544,8 +1546,7 @@ static struct mlxsw_config_profile mlxsw_sx_config_profile = {
 };
 
 static struct mlxsw_driver mlxsw_sx_driver = {
-	.kind			= MLXSW_DEVICE_KIND_SWITCHX2,
-	.owner			= THIS_MODULE,
+	.kind			= mlxsw_sx_driver_name,
 	.priv_size		= sizeof(struct mlxsw_sx),
 	.init			= mlxsw_sx_init,
 	.fini			= mlxsw_sx_fini,
@@ -1554,13 +1555,38 @@ static struct mlxsw_driver mlxsw_sx_driver = {
 	.profile		= &mlxsw_sx_config_profile,
 };
 
+static const struct pci_device_id mlxsw_sx_pci_id_table[] = {
+	{PCI_VDEVICE(MELLANOX, PCI_DEVICE_ID_MELLANOX_SWITCHX2), 0},
+	{0, },
+};
+
+static struct pci_driver mlxsw_sx_pci_driver = {
+	.name = mlxsw_sx_driver_name,
+	.id_table = mlxsw_sx_pci_id_table,
+};
+
 static int __init mlxsw_sx_module_init(void)
 {
-	return mlxsw_core_driver_register(&mlxsw_sx_driver);
+	int err;
+
+	err = mlxsw_core_driver_register(&mlxsw_sx_driver);
+	if (err)
+		return err;
+
+	err = mlxsw_pci_driver_register(&mlxsw_sx_pci_driver);
+	if (err)
+		goto err_pci_driver_register;
+
+	return 0;
+
+err_pci_driver_register:
+	mlxsw_core_driver_unregister(&mlxsw_sx_driver);
+	return err;
 }
 
 static void __exit mlxsw_sx_module_exit(void)
 {
+	mlxsw_pci_driver_unregister(&mlxsw_sx_pci_driver);
 	mlxsw_core_driver_unregister(&mlxsw_sx_driver);
 }
 
@@ -1570,4 +1596,4 @@ module_exit(mlxsw_sx_module_exit);
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_AUTHOR("Jiri Pirko <jiri@mellanox.com>");
 MODULE_DESCRIPTION("Mellanox SwitchX-2 driver");
-MODULE_MLXSW_DRIVER_ALIAS(MLXSW_DEVICE_KIND_SWITCHX2);
+MODULE_DEVICE_TABLE(pci, mlxsw_sx_pci_id_table);
-- 
2.5.5
