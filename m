From: Arun Murthy <arun.murthy@stericsson.com>
Subject: [PATCHv5 1/4] modem_shm: Add Modem Access Framework
Date: Mon, 15 Oct 2012 10:58:37 +0530
Message-ID: <1350278920-25510-2-git-send-email-arun.murthy@stericsson.com>
References: <1350278920-25510-1-git-send-email-arun.murthy@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Arun Murthy <arun.murthy@stericsson.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-doc@vger.kernel.org>, <gregkh@linuxfoundation.org>,
	<alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1350278920-25510-1-git-send-email-arun.murthy@stericsson.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds Modem Access Framework, which allows for registering platform specific
modem access mechanisms. The framework also exposes APIs for client drivers
for getting and releasing access to modem, regardless of the underlying
platform specific access mechanism.

Signed-off-by: Arun Murthy <arun.murthy@stericsson.com>
---
 drivers/Kconfig                  |    2 +
 drivers/Makefile                 |    1 +
 drivers/modem_shm/Kconfig        |    9 ++
 drivers/modem_shm/Makefile       |    1 +
 drivers/modem_shm/modem_access.c |  226 ++++++++++++++++++++++++++++++++++++++
 include/linux/modem_shm/modem.h  |   59 ++++++++++
 6 files changed, 298 insertions(+), 0 deletions(-)
 create mode 100644 drivers/modem_shm/Kconfig
 create mode 100644 drivers/modem_shm/Makefile
 create mode 100644 drivers/modem_shm/modem_access.c
 create mode 100644 include/linux/modem_shm/modem.h

diff --git a/drivers/Kconfig b/drivers/Kconfig
index ece958d..dc7c14a 100644
--- a/drivers/Kconfig
+++ b/drivers/Kconfig
@@ -152,4 +152,6 @@ source "drivers/vme/Kconfig"
 
 source "drivers/pwm/Kconfig"
 
+source "drivers/modem_shm/Kconfig"
+
 endmenu
diff --git a/drivers/Makefile b/drivers/Makefile
index 5b42184..902dfec 100644
--- a/drivers/Makefile
+++ b/drivers/Makefile
@@ -139,3 +139,4 @@ obj-$(CONFIG_EXTCON)		+= extcon/
 obj-$(CONFIG_MEMORY)		+= memory/
 obj-$(CONFIG_IIO)		+= iio/
 obj-$(CONFIG_VME_BUS)		+= vme/
+obj-$(CONFIG_MODEM_SHM)		+= modem_shm/
diff --git a/drivers/modem_shm/Kconfig b/drivers/modem_shm/Kconfig
new file mode 100644
index 0000000..f4b7e54
--- /dev/null
+++ b/drivers/modem_shm/Kconfig
@@ -0,0 +1,9 @@
+config MODEM_SHM
+        bool "Modem Access Framework"
+        default n
+        help
+         Add support for Modem Access Framework. It allows different
+	 platform specific drivers to register modem access mechanisms
+	 and allows transparent access to modem to the client drivers.
+
+	 If unsure, say N.
diff --git a/drivers/modem_shm/Makefile b/drivers/modem_shm/Makefile
new file mode 100644
index 0000000..b77bcc0
--- /dev/null
+++ b/drivers/modem_shm/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_MODEM_SHM)		:= modem_access.o
diff --git a/drivers/modem_shm/modem_access.c b/drivers/modem_shm/modem_access.c
new file mode 100644
index 0000000..e06c51a
--- /dev/null
+++ b/drivers/modem_shm/modem_access.c
@@ -0,0 +1,226 @@
+/*
+ * Copyright (C) ST-Ericsson SA 2011
+ *
+ * License Terms: GNU General Public License v2
+ * Author: Kumar Sanghvi
+ *	Arun Murthy <arun.murthy@stericsson.com>
+ *
+ * Heavily adapted from Regulator framework.
+ * Provides mechanisms for registering platform specific access
+ * mechanisms for modem.
+ * Also, exposes APIs for gettng/releasing the access and even
+ * query the access status, and the modem usage status.
+ */
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/err.h>
+#include <linux/printk.h>
+#include <linux/modem_shm/modem.h>
+
+static struct class *modem_class;
+
+static int __modem_get_usage(struct device *dev, void *data)
+{
+	struct modem_desc *mdesc = (struct modem_desc *)data;
+
+	if (!mdesc->mclients) {
+		printk(KERN_ERR "modem_access: modem description is NULL\n");
+		return 0;
+	}
+	return atomic_read(&mdesc->mclients->cnt);
+}
+
+/**
+ * modem_is_requested - check if modem access to APE is already enabled
+ * @mdesc:	pointer to the struct modem_desc
+ *
+ * check if any of the client on ape has requested access to modem
+ * and return non-zero on success and zero on failure.
+ */
+int modem_get_usage(struct modem_desc *mdesc)
+{
+	return class_for_each_device(modem_class, NULL, (void *)mdesc, __modem_get_usage);
+}
+
+/**
+ * modem_is_requested - check if modem access to APE is already enabled
+ * @mdesc:	pointer to the struct modem_desc
+ *
+ * check for a particular client if ape has requested access to modem
+ * and return non-zero on success and zero on failure.
+ */
+int modem_is_requested(struct modem_desc *mdesc)
+{
+	return atomic_read(&mdesc->mclients->cnt);
+}
+
+/**
+ * modem_release - disable modem access for APE
+ * @mdesc:	pointer to the struct modem_desc
+ *
+ * disable modem access to the APE. For a particluar client it checks if modem
+ * has already been releases and if so returns else will call the platform
+ * specific function to disable access to modem.
+ */
+int modem_release(struct modem_desc *mdesc)
+{
+	if (!mdesc->release)
+		return -EFAULT;
+
+	if (modem_is_requested(mdesc)) {
+		atomic_dec(&mdesc->mclients->cnt);
+		if (atomic_read(&mdesc->use_cnt) == 1) {
+			mdesc->release(mdesc);
+			atomic_dec(&mdesc->use_cnt);
+		}
+	} else
+		printk(KERN_WARNING
+			"modem_shm: client %s has not requested modem to release\n",
+			mdesc->mclients->name);
+	return 0;
+}
+
+/**
+ * modem_request - enable modem access for APE
+ * @mdesc:	pointer to the struct modem_desc
+ *
+ * enable modem access to the APE. For a particluar client it checks if modem
+ * has already been accessed and if so returns else will call the platform
+ * specific function to enable access to modem.
+ */
+int modem_request(struct modem_desc *mdesc)
+{
+	if (!mdesc->request)
+		return -EFAULT;
+
+	if (atomic_read(&mdesc->mclients->cnt) == 0) {
+		mdesc->request(mdesc);
+		atomic_inc(&mdesc->mclients->cnt);
+		atomic_inc(&mdesc->use_cnt);
+		if (atomic_read(&mdesc->use_cnt) > mdesc->no_clients) {
+			dev_warn(mdesc->dev,
+					"modem_shm: mismatch in the modem count\n");
+		}
+	} else
+		dev_warn(mdesc->dev,
+				"modem_shm: client '%s' has already requested modem\n",
+				dev_name(mdesc->mclients->dev));
+	return 0;
+}
+
+/**
+ * modem_put - free the modem corresponding to the client
+ * @mdesc:	pointer to the struct modem_desc
+ *
+ * Free the modem associated to the client, makeing the modem no more
+ * usable to the client.
+ */
+int modem_put(struct modem_desc *mdesc)
+{
+	if (atomic_read(&mdesc->cli_cnt)) {
+		atomic_dec(&mdesc->cli_cnt);
+		modem_release(mdesc);
+		kfree(mdesc->mclients);
+		return 0;
+	} else {
+		dev_err(mdesc->dev, "mismatch in the no of clients\n");
+		return -EFAULT;
+	}
+}
+
+static int modem_match_device_by_name(struct device *dev, void *data)
+{
+	const char *name = data;
+	struct modem_desc *mdesc = dev_get_drvdata(dev);
+
+	return strcmp(mdesc->name, name) == 0;
+}
+
+/**
+ * modem_get - get reference to platform specific modem
+ * @pdev:	pointer to the client's device struct
+ * @name:	pointer to the modem's name
+ *
+ * This function checks if the requested modem is present in the modem access
+ * framework and if present returns the pointer to the struct modem_desc.
+ */
+struct modem_desc *modem_get(struct device *pdev, const char *name)
+{
+	struct clients *mcli;
+	struct modem_desc *mdesc = NULL;
+	struct device *dev = class_find_device(modem_class, NULL, (void *)name,
+			modem_match_device_by_name);
+	mdesc = dev ? dev_get_drvdata(dev): NULL;
+	if (mdesc) {
+		if (atomic_read(&mdesc->cli_cnt) >= mdesc->no_clients) {
+			dev_err(pdev, "already %d clients have requested\n",
+					mdesc->no_clients);
+			return NULL;
+		}
+		mcli = kzalloc(sizeof(struct clients), GFP_KERNEL);
+		if (!mcli) {
+			dev_err(pdev, "uanable to allocate memory\n");
+			return NULL;
+		}
+		mdesc->mclients = mcli;
+		mdesc->mclients->dev = pdev;
+		atomic_inc(&mdesc->cli_cnt);
+		atomic_set(&mdesc->mclients->cnt, 0);
+	}
+	return mdesc;
+}
+
+/**
+ * modem_unregister - unregister the modem
+ * @mdec:	pointer to the struct modem_desc
+ *
+ * This function registers the modem device with the modem access framework,
+ * so that it could be used by clients for accessing and releasing modem.
+ */
+int modem_register(struct device *parent, struct modem_desc *mdesc)
+{
+	mdesc->dev = device_create(modem_class, parent, 0, mdesc, "%s", mdesc->name);
+	if (IS_ERR(mdesc->dev)) {
+		dev_err(parent, "failed to create device\n");
+		return PTR_ERR(mdesc->dev);
+	}
+
+	atomic_set(&mdesc->use_cnt, 0);
+	atomic_set(&mdesc->cli_cnt, 0);
+	return 0;
+}
+
+/**
+ * modem_unregister - unregister the modem
+ * @mdec:	pointer to the struct modem_desc
+ *
+ * This function unregisters the modem device from the modem access framework
+ * and makes the modem no more useful.
+ */
+int modem_unregister(struct modem_desc *mdesc)
+{
+	device_unregister(mdesc->dev);
+	return 0;
+}
+
+static int modem_init(void)
+{
+	modem_class = class_create(THIS_MODULE, "modem_access");
+	if (IS_ERR(modem_class)) {
+		printk(KERN_ERR "modem_access: unable to create class\n");
+		return PTR_ERR(modem_class);
+	}
+
+	if (modem_class == NULL || IS_ERR(modem_class))
+		printk(KERN_ERR "modem_access: MODEM ERR0R");
+
+	return 0;
+}
+
+static void modem_exit(void)
+{
+	class_destroy(modem_class);
+}
+
+arch_initcall(modem_init);
+module_exit(modem_exit);
diff --git a/include/linux/modem_shm/modem.h b/include/linux/modem_shm/modem.h
new file mode 100644
index 0000000..7a58fff
--- /dev/null
+++ b/include/linux/modem_shm/modem.h
@@ -0,0 +1,59 @@
+/*
+ * Copyright (C) ST-Ericsson SA 2011
+ *
+ * License Terms: GNU General Public License v2
+ * Author: Kumar Sanghvi
+ *	Arun Murthy <arun.murthy@stericsson.com>
+ *
+ * Heavily adapted from Regulator framework
+ */
+#ifndef __MODEM_H__
+#define __MODEM_H__
+
+#include <linux/device.h>
+
+struct clients {
+	struct device *dev;
+	const char *name;
+	atomic_t cnt;
+};
+
+struct modem_desc {
+	int (*request)(struct modem_desc *);
+	void (*release)(struct modem_desc *);
+	int (*is_requested)(struct modem_desc *);
+	struct clients *mclients;
+	struct device *dev;
+	char *name;
+	u8 no_clients;
+	atomic_t use_cnt;
+	atomic_t cli_cnt;
+};
+
+#ifdef CONFIG_MODEM_SHM
+int modem_register(struct device *parent, struct modem_desc *mdesc);
+int modem_unregister(struct modem_desc *mdesc);
+struct modem_desc *modem_get(struct device *dev, const char *name);
+int modem_put(struct modem_desc *mdesc);
+int modem_release(struct modem_desc *mdesc);
+int modem_is_requested(struct modem_desc *mdesc);
+int modem_get_usage(struct modem_desc *mdesc);
+int modem_request(struct modem_desc *mdesc);
+
+
+#else
+int modem_register(struct device *parent, struct modem_desc *mdesc)
+{
+	return NULL;
+}
+
+static inline int modem_unregister(struct modem_desc *mdesc)
+{
+	return NULL;
+}
+int modem_get_usage(struct modem_desc *mdesc)
+{
+	return 0;
+}
+#endif
+#endif /* __MODEM_H__ */
-- 
1.7.0.4
