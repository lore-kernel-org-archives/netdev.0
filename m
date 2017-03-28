From: Aviad Yehezkel <aviadye@mellanox.com>
Subject: [RFC TLS Offload Support 11/15] mlx/tls: TLS offload driver Add the main module entrypoints and tie the module into the build system
Date: Tue, 28 Mar 2017 16:26:28 +0300
Message-ID: <1490707592-1430-12-git-send-email-aviadye@mellanox.com>
References: <1490707592-1430-1-git-send-email-aviadye@mellanox.com>
Cc: matanb@mellanox.com, liranl@mellanox.com, haggaie@mellanox.com,
        tom@herbertland.com, herbert@gondor.apana.org.au, nmav@gnults.org,
        fridolin.pokorny@gmail.com, ilant@mellanox.com,
        kliteyn@mellanox.com, linux-crypto@vger.kernel.org,
        saeedm@mellanox.com, aviadye@dev.mellanox.co.il
To: davem@davemloft.net, aviadye@mellanox.com, ilyal@mellanox.com,
        borisp@mellanox.com, davejwatson@fb.com, netdev@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1490707592-1430-1-git-send-email-aviadye@mellanox.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ilya Lesokhin <ilyal@mellanox.com>

Signed-off-by: Guy Shapiro <guysh@mellanox.com>
Signed-off-by: Ilya Lesokhin <ilyal@mellanox.com>
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Haggai Eran <haggaie@mellanox.com>
Signed-off-by: Aviad Yehezkel <aviadye@mellanox.com>
---
 drivers/net/ethernet/mellanox/Kconfig              |  1 +
 drivers/net/ethernet/mellanox/Makefile             |  1 +
 .../net/ethernet/mellanox/accelerator/tls/Kconfig  | 11 ++++
 .../net/ethernet/mellanox/accelerator/tls/Makefile |  4 ++
 .../ethernet/mellanox/accelerator/tls/tls_main.c   | 77 ++++++++++++++++++++++
 5 files changed, 94 insertions(+)
 create mode 100644 drivers/net/ethernet/mellanox/accelerator/tls/Kconfig
 create mode 100644 drivers/net/ethernet/mellanox/accelerator/tls/Makefile
 create mode 100644 drivers/net/ethernet/mellanox/accelerator/tls/tls_main.c

diff --git a/drivers/net/ethernet/mellanox/Kconfig b/drivers/net/ethernet/mellanox/Kconfig
index 1b3ca6a..f270b76 100644
--- a/drivers/net/ethernet/mellanox/Kconfig
+++ b/drivers/net/ethernet/mellanox/Kconfig
@@ -21,6 +21,7 @@ source "drivers/net/ethernet/mellanox/mlx5/core/Kconfig"
 source "drivers/net/ethernet/mellanox/mlxsw/Kconfig"
 source "drivers/net/ethernet/mellanox/accelerator/core/Kconfig"
 source "drivers/net/ethernet/mellanox/accelerator/ipsec/Kconfig"
+source "drivers/net/ethernet/mellanox/accelerator/tls/Kconfig"
 source "drivers/net/ethernet/mellanox/accelerator/tools/Kconfig"
 
 endif # NET_VENDOR_MELLANOX
diff --git a/drivers/net/ethernet/mellanox/Makefile b/drivers/net/ethernet/mellanox/Makefile
index 96a5856..fd8afc0 100644
--- a/drivers/net/ethernet/mellanox/Makefile
+++ b/drivers/net/ethernet/mellanox/Makefile
@@ -7,4 +7,5 @@ obj-$(CONFIG_MLX5_CORE) += mlx5/core/
 obj-$(CONFIG_MLXSW_CORE) += mlxsw/
 obj-$(CONFIG_MLX_ACCEL_CORE) += accelerator/core/
 obj-$(CONFIG_MLX_ACCEL_IPSEC) += accelerator/ipsec/
+obj-$(CONFIG_MLX_ACCEL_TLS) += accelerator/tls/
 obj-$(CONFIG_MLX_ACCEL_TOOLS) += accelerator/tools/
diff --git a/drivers/net/ethernet/mellanox/accelerator/tls/Kconfig b/drivers/net/ethernet/mellanox/accelerator/tls/Kconfig
new file mode 100644
index 0000000..d9c0733
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/accelerator/tls/Kconfig
@@ -0,0 +1,11 @@
+#
+# Mellanox tls accelerator driver configuration
+#
+
+config MLX_ACCEL_TLS
+	tristate "Mellanox Technologies TLS accelarator driver"
+	depends on MLX_ACCEL_CORE
+	default n
+	---help---
+	  TLS accelarator driver by Mellanox Technologies.
+
diff --git a/drivers/net/ethernet/mellanox/accelerator/tls/Makefile b/drivers/net/ethernet/mellanox/accelerator/tls/Makefile
new file mode 100644
index 0000000..93a7733
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/accelerator/tls/Makefile
@@ -0,0 +1,4 @@
+obj-$(CONFIG_MLX_ACCEL_TLS)		+= mlx_tls.o
+
+ccflags-y := -I$(srctree)/
+mlx_tls-y :=  tls_main.o tls_sysfs.o tls_hw.o tls.o
diff --git a/drivers/net/ethernet/mellanox/accelerator/tls/tls_main.c b/drivers/net/ethernet/mellanox/accelerator/tls/tls_main.c
new file mode 100644
index 0000000..85078f5
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/accelerator/tls/tls_main.c
@@ -0,0 +1,77 @@
+/*
+ * Copyright (c) 2015-2017 Mellanox Technologies. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+#include <linux/module.h>
+
+#include "tls.h"
+
+MODULE_AUTHOR("Mellanox Technologies Advance Develop Team <adv-dev@mellanox.com>");
+MODULE_DESCRIPTION("Mellanox Innova TLS Driver");
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_VERSION(DRIVER_VERSION);
+
+static struct mlx_accel_core_client mlx_tls_client = {
+	.name   = "mlx_tls",
+	.add    = mlx_tls_add_one,
+	.remove = mlx_tls_remove_one,
+};
+
+static struct notifier_block mlx_tls_netdev_notifier = {
+	.notifier_call = mlx_tls_netdev_event,
+};
+
+static int __init mlx_tls_init(void)
+{
+	int err = 0;
+
+	err = register_netdevice_notifier(&mlx_tls_netdev_notifier);
+	if (err) {
+		pr_warn("mlx_tls_init error in register_netdevice_notifier %d\n",
+			err);
+		goto out_wq;
+	}
+
+	mlx_accel_core_client_register(&mlx_tls_client);
+
+out_wq:
+	return err;
+}
+
+static void __exit mlx_tls_exit(void)
+{
+	mlx_accel_core_client_unregister(&mlx_tls_client);
+	unregister_netdevice_notifier(&mlx_tls_netdev_notifier);
+}
+
+module_init(mlx_tls_init);
+module_exit(mlx_tls_exit);
+
-- 
2.7.4
