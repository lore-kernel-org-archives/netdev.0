From: Arun Murthy <arun.murthy@stericsson.com>
Subject: [PATCHv2 2/4] modem_shm: Register u8500 client for MAF
Date: Tue, 7 Aug 2012 12:24:29 +0530
Message-ID: <1344322471-3640-3-git-send-email-arun.murthy@stericsson.com>
References: <1344322471-3640-1-git-send-email-arun.murthy@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <sjur.brandeland@stericsson.com>, <arun.murthy@stericsson.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-doc@vger.kernel.org>, <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:36808 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750830Ab2HGGy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 02:54:57 -0400
In-Reply-To: <1344322471-3640-1-git-send-email-arun.murthy@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Register with Modem Access Framework(MAF) for u8500 platform. This will provide
interface to enable and disable modem access and also provide the status.

Signed-off-by: Arun Murthy <arun.murthy@stericsson.com>
Acked-by: Linus Walleij <linus.walleij@stericsson.com>
---
 drivers/modem_shm/Kconfig       |   11 +++++
 drivers/modem_shm/Makefile      |    1 +
 drivers/modem_shm/modem_u8500.c |   96 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 108 insertions(+), 0 deletions(-)
 create mode 100644 drivers/modem_shm/modem_u8500.c

diff --git a/drivers/modem_shm/Kconfig b/drivers/modem_shm/Kconfig
index 0e5fc7a..f2b36a9 100644
--- a/drivers/modem_shm/Kconfig
+++ b/drivers/modem_shm/Kconfig
@@ -7,3 +7,14 @@ config MODEM_SHM
 	 and allows transparent access to modem to the client drivers.
 
 	 If unsure, say N.
+
+config MODEM_U8500
+	bool "Modem Access driver for STE U8500 platform"
+	depends on MODEM_SHM
+	default n
+	help
+	 Add support for Modem Access driver on STE U8500 platform which
+	 uses Shared Memroy as IPC mechanism between Modem processor and
+	 Application processor.
+
+	 If unsure, say N.
diff --git a/drivers/modem_shm/Makefile b/drivers/modem_shm/Makefile
index b77bcc0..a9aac0f 100644
--- a/drivers/modem_shm/Makefile
+++ b/drivers/modem_shm/Makefile
@@ -1 +1,2 @@
 obj-$(CONFIG_MODEM_SHM)		:= modem_access.o
+obj-$(CONFIG_MODEM_U8500)	+= modem_u8500.o
diff --git a/drivers/modem_shm/modem_u8500.c b/drivers/modem_shm/modem_u8500.c
new file mode 100644
index 0000000..86966fc
--- /dev/null
+++ b/drivers/modem_shm/modem_u8500.c
@@ -0,0 +1,96 @@
+/*
+ * Copyright (C) ST-Ericsson SA 2011
+ *
+ * License Terms: GNU General Public License v2
+ * Author: Kumar Sanghvi
+ *	Arun Murthy <arun.murthy@stericsson.com>
+ *
+ * Platform driver implementing access mechanisms to modem
+ * on U8500 which uses Shared Memroy as IPC between Application
+ * Processor and Modem processor.
+ */
+#include <linux/module.h>
+#include <linux/err.h>
+#include <linux/platform_device.h>
+#include <linux/modem_shm/modem.h>
+#include <linux/mfd/dbx500-prcmu.h>
+
+static int u8500_modem_request(struct modem_dev *mdev)
+{
+	return prcmu_ac_wake_req();
+}
+
+static void u8500_modem_release(struct modem_dev *mdev)
+{
+	prcmu_ac_sleep_req();
+}
+
+static int u8500_modem_is_requested(struct modem_dev *mdev)
+{
+	return prcmu_is_ac_wake_requested();
+}
+
+static struct modem_ops u8500_modem_ops = {
+	.request = u8500_modem_request,
+	.release = u8500_modem_release,
+	.is_requested = u8500_modem_is_requested,
+};
+
+static struct modem_desc u8500_modem_desc = {
+	.name   = "u8500-shrm-modem",
+	.id     = 0,
+	.ops    = &u8500_modem_ops,
+	.owner  = THIS_MODULE,
+};
+
+
+static int __devinit u8500_modem_probe(struct platform_device *pdev)
+{
+	struct modem_dev *mdev;
+	int err;
+
+	mdev = modem_register(&u8500_modem_desc, &pdev->dev,
+			NULL);
+	if (IS_ERR(mdev)) {
+		err = PTR_ERR(mdev);
+		pr_err("failed to register %s: err %i\n",
+				u8500_modem_desc.name, err);
+	}
+
+	return 0;
+}
+
+static int __devexit u8500_modem_remove(struct platform_device *pdev)
+{
+
+	return 0;
+}
+
+static struct platform_driver u8500_modem_driver = {
+	.driver = {
+		.name = "u8500-modem",
+		.owner = THIS_MODULE,
+	},
+	.probe = u8500_modem_probe,
+	.remove = __devexit_p(u8500_modem_remove),
+};
+
+static int __init u8500_modem_init(void)
+{
+	int ret;
+
+	ret = platform_driver_register(&u8500_modem_driver);
+	if (ret < 0) {
+		printk(KERN_ERR "u8500_modem: platform driver reg failed\n");
+		return -ENODEV;
+	}
+
+	return 0;
+}
+
+static void __exit u8500_modem_exit(void)
+{
+	platform_driver_unregister(&u8500_modem_driver);
+}
+
+arch_initcall(u8500_modem_init);
-- 
1.7.4.3
