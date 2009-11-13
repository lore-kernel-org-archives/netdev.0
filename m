From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 3/4] [PATCH] s390: remove cu3088 layer for lcs and ctcm
Date: Fri, 13 Nov 2009 08:46:29 +0100
Message-ID: <20091113075050.734146000@linux.vnet.ibm.com>
References: <20091113074626.078348000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:58060 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752582AbZKMHur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 02:50:47 -0500
Content-Disposition: inline; filename=615-remove-cu3088.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

The cu3088-driver used as common base for lcs- and ctcm-devices
makes it difficult to assign the appropriate driver to an lcs-device
or a ctcm-device. This patch eliminates the cu3088-driver and thus
the root device "cu3088". Path /sys/devices/cu3088 is replaced with
the pathes /sys/devices/lcs and /sys/devices/ctcm.

Patch is based on a proposal from Cornelia Huck.

Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 drivers/s390/net/Makefile     |    6 -
 drivers/s390/net/claw.c       |   82 ++++++++++++++++++++---
 drivers/s390/net/claw.h       |   12 +++
 drivers/s390/net/ctcm_fsms.c  |    1 
 drivers/s390/net/ctcm_fsms.h  |    1 
 drivers/s390/net/ctcm_main.c  |  104 +++++++++++++++++++++++------
 drivers/s390/net/ctcm_main.h  |   20 +++++
 drivers/s390/net/ctcm_mpc.c   |    1 
 drivers/s390/net/ctcm_sysfs.c |   11 ++-
 drivers/s390/net/cu3088.c     |  148 ------------------------------------------
 drivers/s390/net/cu3088.h     |   41 -----------
 drivers/s390/net/lcs.c        |  101 ++++++++++++++++++++++++----
 drivers/s390/net/lcs.h        |   18 +++++
 13 files changed, 304 insertions(+), 242 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/claw.c linux-2.6-patched/drivers/s390/net/claw.c
--- linux-2.6/drivers/s390/net/claw.c	2009-11-12 14:58:54.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/claw.c	2009-11-12 14:59:32.000000000 +0100
@@ -90,7 +90,6 @@
 #include <linux/timer.h>
 #include <linux/types.h>
 
-#include "cu3088.h"
 #include "claw.h"
 
 /*
@@ -258,6 +257,9 @@ static int claw_pm_prepare(struct ccwgro
 	return -EPERM;
 }
 
+/* the root device for claw group devices */
+static struct device *claw_root_dev;
+
 /* ccwgroup table  */
 
 static struct ccwgroup_driver claw_group_driver = {
@@ -272,6 +274,47 @@ static struct ccwgroup_driver claw_group
 	.prepare     = claw_pm_prepare,
 };
 
+static struct ccw_device_id claw_ids[] = {
+	{CCW_DEVICE(0x3088, 0x61), .driver_info = claw_channel_type_claw},
+	{},
+};
+MODULE_DEVICE_TABLE(ccw, claw_ids);
+
+static struct ccw_driver claw_ccw_driver = {
+	.owner	= THIS_MODULE,
+	.name	= "claw",
+	.ids	= claw_ids,
+	.probe	= ccwgroup_probe_ccwdev,
+	.remove	= ccwgroup_remove_ccwdev,
+};
+
+static ssize_t
+claw_driver_group_store(struct device_driver *ddrv, const char *buf,
+			size_t count)
+{
+	int err;
+	err = ccwgroup_create_from_string(claw_root_dev,
+					  claw_group_driver.driver_id,
+					  &claw_ccw_driver, 3, buf);
+	return err ? err : count;
+}
+
+static DRIVER_ATTR(group, 0200, NULL, claw_driver_group_store);
+
+static struct attribute *claw_group_attrs[] = {
+	&driver_attr_group.attr,
+	NULL,
+};
+
+static struct attribute_group claw_group_attr_group = {
+	.attrs = claw_group_attrs,
+};
+
+static struct attribute_group *claw_group_attr_groups[] = {
+	&claw_group_attr_group,
+	NULL,
+};
+
 /*
 *       Key functions
 */
@@ -3326,7 +3369,11 @@ claw_remove_files(struct device *dev)
 static void __exit
 claw_cleanup(void)
 {
-	unregister_cu3088_discipline(&claw_group_driver);
+	driver_remove_file(&claw_group_driver.driver,
+			   &driver_attr_group);
+	ccwgroup_driver_unregister(&claw_group_driver);
+	ccw_driver_unregister(&claw_ccw_driver);
+	root_device_unregister(claw_root_dev);
 	claw_unregister_debug_facility();
 	pr_info("Driver unloaded\n");
 
@@ -3348,16 +3395,31 @@ claw_init(void)
 	if (ret) {
 		pr_err("Registering with the S/390 debug feature"
 			" failed with error code %d\n", ret);
-		return ret;
+		goto out_err;
 	}
 	CLAW_DBF_TEXT(2, setup, "init_mod");
-	ret = register_cu3088_discipline(&claw_group_driver);
-	if (ret) {
-		CLAW_DBF_TEXT(2, setup, "init_bad");
-		claw_unregister_debug_facility();
-		pr_err("Registering with the cu3088 device driver failed "
-			   "with error code %d\n", ret);
-	}
+	claw_root_dev = root_device_register("qeth");
+	ret = IS_ERR(claw_root_dev) ? PTR_ERR(claw_root_dev) : 0;
+	if (ret)
+		goto register_err;
+	ret = ccw_driver_register(&claw_ccw_driver);
+	if (ret)
+		goto ccw_err;
+	claw_group_driver.driver.groups = claw_group_attr_groups;
+	ret = ccwgroup_driver_register(&claw_group_driver);
+	if (ret)
+		goto ccwgroup_err;
+	return 0;
+
+ccwgroup_err:
+	ccw_driver_unregister(&claw_ccw_driver);
+ccw_err:
+	root_device_unregister(claw_root_dev);
+register_err:
+	CLAW_DBF_TEXT(2, setup, "init_bad");
+	claw_unregister_debug_facility();
+out_err:
+	pr_err("Initializing the claw device driver failed\n");
 	return ret;
 }
 
diff -urpN linux-2.6/drivers/s390/net/claw.h linux-2.6-patched/drivers/s390/net/claw.h
--- linux-2.6/drivers/s390/net/claw.h	2009-09-10 00:13:59.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/claw.h	2009-11-12 14:59:32.000000000 +0100
@@ -129,6 +129,18 @@ static inline int claw_dbf_passes(debug_
 		} \
 	} while (0)
 
+/**
+ * Enum for classifying detected devices.
+ */
+enum claw_channel_types {
+	/* Device is not a channel  */
+	claw_channel_type_none,
+
+	/* Device is a CLAW channel device */
+	claw_channel_type_claw
+};
+
+
 /*******************************************************
 *  Define Control Blocks                               *
 *                                                      *
diff -urpN linux-2.6/drivers/s390/net/ctcm_fsms.c linux-2.6-patched/drivers/s390/net/ctcm_fsms.c
--- linux-2.6/drivers/s390/net/ctcm_fsms.c	2009-09-10 00:13:59.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/ctcm_fsms.c	2009-11-12 14:59:32.000000000 +0100
@@ -44,7 +44,6 @@
 #include <asm/idals.h>
 
 #include "fsm.h"
-#include "cu3088.h"
 
 #include "ctcm_dbug.h"
 #include "ctcm_main.h"
diff -urpN linux-2.6/drivers/s390/net/ctcm_fsms.h linux-2.6-patched/drivers/s390/net/ctcm_fsms.h
--- linux-2.6/drivers/s390/net/ctcm_fsms.h	2009-09-10 00:13:59.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/ctcm_fsms.h	2009-11-12 14:59:32.000000000 +0100
@@ -39,7 +39,6 @@
 #include <asm/idals.h>
 
 #include "fsm.h"
-#include "cu3088.h"
 #include "ctcm_main.h"
 
 /*
diff -urpN linux-2.6/drivers/s390/net/ctcm_main.c linux-2.6-patched/drivers/s390/net/ctcm_main.c
--- linux-2.6/drivers/s390/net/ctcm_main.c	2009-11-12 14:59:32.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/ctcm_main.c	2009-11-12 14:59:32.000000000 +0100
@@ -51,12 +51,16 @@
 
 #include <asm/idals.h>
 
-#include "cu3088.h"
 #include "ctcm_fsms.h"
 #include "ctcm_main.h"
 
 /* Some common global variables */
 
+/**
+ * The root device for ctcm group devices
+ */
+static struct device *ctcm_root_dev;
+
 /*
  * Linked list of all detected channels.
  */
@@ -246,7 +250,7 @@ static void channel_remove(struct channe
  *
  * returns Pointer to a channel or NULL if no matching channel available.
  */
-static struct channel *channel_get(enum channel_types type,
+static struct channel *channel_get(enum ctcm_channel_types type,
 					char *id, int direction)
 {
 	struct channel *ch = channels;
@@ -1342,7 +1346,7 @@ static int ctcm_probe_device(struct ccwg
  *
  * returns 0 on success, !0 on error.
  */
-static int add_channel(struct ccw_device *cdev, enum channel_types type,
+static int add_channel(struct ccw_device *cdev, enum ctcm_channel_types type,
 				struct ctcm_priv *priv)
 {
 	struct channel **c = &channels;
@@ -1501,13 +1505,13 @@ free_return:	/* note that all channel po
 /*
  * Return type of a detected device.
  */
-static enum channel_types get_channel_type(struct ccw_device_id *id)
+static enum ctcm_channel_types get_channel_type(struct ccw_device_id *id)
 {
-	enum channel_types type;
-	type = (enum channel_types)id->driver_info;
+	enum ctcm_channel_types type;
+	type = (enum ctcm_channel_types)id->driver_info;
 
-	if (type == channel_type_ficon)
-		type = channel_type_escon;
+	if (type == ctcm_channel_type_ficon)
+		type = ctcm_channel_type_escon;
 
 	return type;
 }
@@ -1525,7 +1529,7 @@ static int ctcm_new_device(struct ccwgro
 	char read_id[CTCM_ID_SIZE];
 	char write_id[CTCM_ID_SIZE];
 	int direction;
-	enum channel_types type;
+	enum ctcm_channel_types type;
 	struct ctcm_priv *priv;
 	struct net_device *dev;
 	struct ccw_device *cdev0;
@@ -1749,6 +1753,22 @@ err_out:
 	return rc;
 }
 
+static struct ccw_device_id ctcm_ids[] = {
+	{CCW_DEVICE(0x3088, 0x08), .driver_info = ctcm_channel_type_parallel},
+	{CCW_DEVICE(0x3088, 0x1e), .driver_info = ctcm_channel_type_ficon},
+	{CCW_DEVICE(0x3088, 0x1f), .driver_info = ctcm_channel_type_escon},
+	{},
+};
+MODULE_DEVICE_TABLE(ccw, ctcm_ids);
+
+static struct ccw_driver ctcm_ccw_driver = {
+	.owner	= THIS_MODULE,
+	.name	= "ctcm",
+	.ids	= ctcm_ids,
+	.probe	= ccwgroup_probe_ccwdev,
+	.remove	= ccwgroup_remove_ccwdev,
+};
+
 static struct ccwgroup_driver ctcm_group_driver = {
 	.owner       = THIS_MODULE,
 	.name        = CTC_DRIVER_NAME,
@@ -1763,6 +1783,33 @@ static struct ccwgroup_driver ctcm_group
 	.restore     = ctcm_pm_resume,
 };
 
+static ssize_t
+ctcm_driver_group_store(struct device_driver *ddrv, const char *buf,
+			size_t count)
+{
+	int err;
+
+	err = ccwgroup_create_from_string(ctcm_root_dev,
+					  ctcm_group_driver.driver_id,
+					  &ctcm_ccw_driver, 2, buf);
+	return err ? err : count;
+}
+
+static DRIVER_ATTR(group, 0200, NULL, ctcm_driver_group_store);
+
+static struct attribute *ctcm_group_attrs[] = {
+	&driver_attr_group.attr,
+	NULL,
+};
+
+static struct attribute_group ctcm_group_attr_group = {
+	.attrs = ctcm_group_attrs,
+};
+
+static struct attribute_group *ctcm_group_attr_groups[] = {
+	&ctcm_group_attr_group,
+	NULL,
+};
 
 /*
  * Module related routines
@@ -1776,7 +1823,10 @@ static struct ccwgroup_driver ctcm_group
  */
 static void __exit ctcm_exit(void)
 {
-	unregister_cu3088_discipline(&ctcm_group_driver);
+	driver_remove_file(&ctcm_group_driver.driver, &driver_attr_group);
+	ccwgroup_driver_unregister(&ctcm_group_driver);
+	ccw_driver_unregister(&ctcm_ccw_driver);
+	root_device_unregister(ctcm_root_dev);
 	ctcm_unregister_dbf_views();
 	pr_info("CTCM driver unloaded\n");
 }
@@ -1802,17 +1852,31 @@ static int __init ctcm_init(void)
 	channels = NULL;
 
 	ret = ctcm_register_dbf_views();
-	if (ret) {
-		return ret;
-	}
-	ret = register_cu3088_discipline(&ctcm_group_driver);
-	if (ret) {
-		ctcm_unregister_dbf_views();
-		pr_err("%s / register_cu3088_discipline failed, ret = %d\n",
-			__func__, ret);
-		return ret;
-	}
+	if (ret)
+		goto out_err;
+	ctcm_root_dev = root_device_register("ctcm");
+	ret = IS_ERR(ctcm_root_dev) ? PTR_ERR(ctcm_root_dev) : 0;
+	if (ret)
+		goto register_err;
+	ret = ccw_driver_register(&ctcm_ccw_driver);
+	if (ret)
+		goto ccw_err;
+	ctcm_group_driver.driver.groups = ctcm_group_attr_groups;
+	ret = ccwgroup_driver_register(&ctcm_group_driver);
+	if (ret)
+		goto ccwgroup_err;
 	print_banner();
+	return 0;
+
+ccwgroup_err:
+	ccw_driver_unregister(&ctcm_ccw_driver);
+ccw_err:
+	root_device_unregister(ctcm_root_dev);
+register_err:
+	ctcm_unregister_dbf_views();
+out_err:
+	pr_err("%s / Initializing the ctcm device driver failed, ret = %d\n",
+		__func__, ret);
 	return ret;
 }
 
diff -urpN linux-2.6/drivers/s390/net/ctcm_main.h linux-2.6-patched/drivers/s390/net/ctcm_main.h
--- linux-2.6/drivers/s390/net/ctcm_main.h	2009-09-10 00:13:59.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/ctcm_main.h	2009-11-12 14:59:32.000000000 +0100
@@ -16,7 +16,6 @@
 #include <linux/netdevice.h>
 
 #include "fsm.h"
-#include "cu3088.h"
 #include "ctcm_dbug.h"
 #include "ctcm_mpc.h"
 
@@ -66,6 +65,23 @@
 			ctcmpc_dumpit(buf, len); \
 	} while (0)
 
+/**
+ * Enum for classifying detected devices
+ */
+enum ctcm_channel_types {
+	/* Device is not a channel  */
+	ctcm_channel_type_none,
+
+	/* Device is a CTC/A */
+	ctcm_channel_type_parallel,
+
+	/* Device is a FICON channel */
+	ctcm_channel_type_ficon,
+
+	/* Device is a ESCON channel */
+	ctcm_channel_type_escon
+};
+
 /*
  * CCW commands, used in this driver.
  */
@@ -121,7 +137,7 @@ struct channel {
 	 * Type of this channel.
 	 * CTC/A or Escon for valid channels.
 	 */
-	enum channel_types type;
+	enum ctcm_channel_types type;
 	/*
 	 * Misc. flags. See CHANNEL_FLAGS_... below
 	 */
diff -urpN linux-2.6/drivers/s390/net/ctcm_mpc.c linux-2.6-patched/drivers/s390/net/ctcm_mpc.c
--- linux-2.6/drivers/s390/net/ctcm_mpc.c	2009-09-10 00:13:59.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/ctcm_mpc.c	2009-11-12 14:59:32.000000000 +0100
@@ -53,7 +53,6 @@
 #include <linux/moduleparam.h>
 #include <asm/idals.h>
 
-#include "cu3088.h"
 #include "ctcm_mpc.h"
 #include "ctcm_main.h"
 #include "ctcm_fsms.h"
diff -urpN linux-2.6/drivers/s390/net/ctcm_sysfs.c linux-2.6-patched/drivers/s390/net/ctcm_sysfs.c
--- linux-2.6/drivers/s390/net/ctcm_sysfs.c	2009-09-10 00:13:59.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/ctcm_sysfs.c	2009-11-12 14:59:32.000000000 +0100
@@ -158,6 +158,15 @@ static ssize_t ctcm_proto_store(struct d
 	return count;
 }
 
+const char *ctcm_type[] = {
+	"not a channel",
+	"CTC/A",
+	"FICON channel",
+	"ESCON channel",
+	"unknown channel type",
+	"unsupported channel type",
+};
+
 static ssize_t ctcm_type_show(struct device *dev,
 				struct device_attribute *attr, char *buf)
 {
@@ -168,7 +177,7 @@ static ssize_t ctcm_type_show(struct dev
 		return -ENODEV;
 
 	return sprintf(buf, "%s\n",
-			cu3088_type[cgdev->cdev[0]->id.driver_info]);
+			ctcm_type[cgdev->cdev[0]->id.driver_info]);
 }
 
 static DEVICE_ATTR(buffer, 0644, ctcm_buffer_show, ctcm_buffer_write);
diff -urpN linux-2.6/drivers/s390/net/cu3088.c linux-2.6-patched/drivers/s390/net/cu3088.c
--- linux-2.6/drivers/s390/net/cu3088.c	2009-09-10 00:13:59.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/cu3088.c	1970-01-01 01:00:00.000000000 +0100
@@ -1,148 +0,0 @@
-/*
- * CTC / LCS ccw_device driver
- *
- * Copyright (C) 2002 IBM Deutschland Entwicklung GmbH, IBM Corporation
- * Author(s): Arnd Bergmann <arndb@de.ibm.com>
- *            Cornelia Huck <cornelia.huck@de.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2, or (at your option)
- * any later version.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
- *
- */
-
-#include <linux/init.h>
-#include <linux/module.h>
-#include <linux/err.h>
-
-#include <asm/ccwdev.h>
-#include <asm/ccwgroup.h>
-
-#include "cu3088.h"
-
-const char *cu3088_type[] = {
-	"not a channel",
-	"CTC/A",
-	"ESCON channel",
-	"FICON channel",
-	"OSA LCS card",
-	"CLAW channel device",
-	"unknown channel type",
-	"unsupported channel type",
-};
-
-/* static definitions */
-
-static struct ccw_device_id cu3088_ids[] = {
-	{ CCW_DEVICE(0x3088, 0x08), .driver_info = channel_type_parallel },
-	{ CCW_DEVICE(0x3088, 0x1f), .driver_info = channel_type_escon },
-	{ CCW_DEVICE(0x3088, 0x1e), .driver_info = channel_type_ficon },
-	{ CCW_DEVICE(0x3088, 0x60), .driver_info = channel_type_osa2 },
-	{ CCW_DEVICE(0x3088, 0x61), .driver_info = channel_type_claw },
-	{ /* end of list */ }
-};
-
-static struct ccw_driver cu3088_driver;
-
-static struct device *cu3088_root_dev;
-
-static ssize_t
-group_write(struct device_driver *drv, const char *buf, size_t count)
-{
-	int ret;
-	struct ccwgroup_driver *cdrv;
-
-	cdrv = to_ccwgroupdrv(drv);
-	if (!cdrv)
-		return -EINVAL;
-	ret = ccwgroup_create_from_string(cu3088_root_dev, cdrv->driver_id,
-					  &cu3088_driver, 2, buf);
-
-	return (ret == 0) ? count : ret;
-}
-
-static DRIVER_ATTR(group, 0200, NULL, group_write);
-
-/* Register-unregister for ctc&lcs */
-int
-register_cu3088_discipline(struct ccwgroup_driver *dcp)
-{
-	int rc;
-
-	if (!dcp)
-		return -EINVAL;
-
-	/* Register discipline.*/
-	rc = ccwgroup_driver_register(dcp);
-	if (rc)
-		return rc;
-
-	rc = driver_create_file(&dcp->driver, &driver_attr_group);
-	if (rc)
-		ccwgroup_driver_unregister(dcp);
-
-	return rc;
-
-}
-
-void
-unregister_cu3088_discipline(struct ccwgroup_driver *dcp)
-{
-	if (!dcp)
-		return;
-
-	driver_remove_file(&dcp->driver, &driver_attr_group);
-	ccwgroup_driver_unregister(dcp);
-}
-
-static struct ccw_driver cu3088_driver = {
-	.owner	     = THIS_MODULE,
-	.ids	     = cu3088_ids,
-	.name        = "cu3088",
-	.probe	     = ccwgroup_probe_ccwdev,
-	.remove	     = ccwgroup_remove_ccwdev,
-};
-
-/* module setup */
-static int __init
-cu3088_init (void)
-{
-	int rc;
-
-	cu3088_root_dev = root_device_register("cu3088");
-	if (IS_ERR(cu3088_root_dev))
-		return PTR_ERR(cu3088_root_dev);
-	rc = ccw_driver_register(&cu3088_driver);
-	if (rc)
-		root_device_unregister(cu3088_root_dev);
-
-	return rc;
-}
-
-static void __exit
-cu3088_exit (void)
-{
-	ccw_driver_unregister(&cu3088_driver);
-	root_device_unregister(cu3088_root_dev);
-}
-
-MODULE_DEVICE_TABLE(ccw,cu3088_ids);
-MODULE_AUTHOR("Arnd Bergmann <arndb@de.ibm.com>");
-MODULE_LICENSE("GPL");
-
-module_init(cu3088_init);
-module_exit(cu3088_exit);
-
-EXPORT_SYMBOL_GPL(cu3088_type);
-EXPORT_SYMBOL_GPL(register_cu3088_discipline);
-EXPORT_SYMBOL_GPL(unregister_cu3088_discipline);
diff -urpN linux-2.6/drivers/s390/net/cu3088.h linux-2.6-patched/drivers/s390/net/cu3088.h
--- linux-2.6/drivers/s390/net/cu3088.h	2009-09-10 00:13:59.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/cu3088.h	1970-01-01 01:00:00.000000000 +0100
@@ -1,41 +0,0 @@
-#ifndef _CU3088_H
-#define _CU3088_H
-
-/**
- * Enum for classifying detected devices.
- */
-enum channel_types {
-        /* Device is not a channel  */
-	channel_type_none,
-
-        /* Device is a CTC/A */
-	channel_type_parallel,
-
-	/* Device is a ESCON channel */
-	channel_type_escon,
-
-	/* Device is a FICON channel */
-	channel_type_ficon,
-
-	/* Device is a OSA2 card */
-	channel_type_osa2,
-
-	/* Device is a CLAW channel device */
-	channel_type_claw,
-
-	/* Device is a channel, but we don't know
-	 * anything about it */
-	channel_type_unknown,
-
-	/* Device is an unsupported model */
-	channel_type_unsupported,
-
-	/* number of type entries */
-	num_channel_types
-};
-
-extern const char *cu3088_type[num_channel_types];
-extern int register_cu3088_discipline(struct ccwgroup_driver *);
-extern void unregister_cu3088_discipline(struct ccwgroup_driver *);
-
-#endif
diff -urpN linux-2.6/drivers/s390/net/lcs.c linux-2.6-patched/drivers/s390/net/lcs.c
--- linux-2.6/drivers/s390/net/lcs.c	2009-11-12 14:59:31.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/lcs.c	2009-11-12 14:59:32.000000000 +0100
@@ -47,7 +47,6 @@
 #include <asm/ccwgroup.h>
 
 #include "lcs.h"
-#include "cu3088.h"
 
 
 #if !defined(CONFIG_NET_ETHERNET) && \
@@ -60,7 +59,11 @@
  */
 
 static char version[] __initdata = "LCS driver";
-static char debug_buffer[255];
+
+/**
+  * the root device for lcs group devices
+  */
+static struct device *lcs_root_dev;
 
 /**
  * Some prototypes.
@@ -76,6 +79,7 @@ static int lcs_recovery(void *ptr);
 /**
  * Debug Facility Stuff
  */
+static char debug_buffer[255];
 static debug_info_t *lcs_dbf_setup;
 static debug_info_t *lcs_dbf_trace;
 
@@ -1968,6 +1972,15 @@ lcs_portno_store (struct device *dev, st
 
 static DEVICE_ATTR(portno, 0644, lcs_portno_show, lcs_portno_store);
 
+const char *lcs_type[] = {
+	"not a channel",
+	"2216 parallel",
+	"2216 channel",
+	"OSA LCS card",
+	"unknown channel type",
+	"unsupported channel type",
+};
+
 static ssize_t
 lcs_type_show(struct device *dev, struct device_attribute *attr, char *buf)
 {
@@ -1977,7 +1990,7 @@ lcs_type_show(struct device *dev, struct
 	if (!cgdev)
 		return -ENODEV;
 
-	return sprintf(buf, "%s\n", cu3088_type[cgdev->cdev[0]->id.driver_info]);
+	return sprintf(buf, "%s\n", lcs_type[cgdev->cdev[0]->id.driver_info]);
 }
 
 static DEVICE_ATTR(type, 0444, lcs_type_show, NULL);
@@ -2370,6 +2383,22 @@ static int lcs_restore(struct ccwgroup_d
 	return lcs_pm_resume(card);
 }
 
+static struct ccw_device_id lcs_ids[] = {
+	{CCW_DEVICE(0x3088, 0x08), .driver_info = lcs_channel_type_parallel},
+	{CCW_DEVICE(0x3088, 0x1f), .driver_info = lcs_channel_type_2216},
+	{CCW_DEVICE(0x3088, 0x60), .driver_info = lcs_channel_type_osa2},
+	{},
+};
+MODULE_DEVICE_TABLE(ccw, lcs_ids);
+
+static struct ccw_driver lcs_ccw_driver = {
+	.owner	= THIS_MODULE,
+	.name	= "lcs",
+	.ids	= lcs_ids,
+	.probe	= ccwgroup_probe_ccwdev,
+	.remove	= ccwgroup_remove_ccwdev,
+};
+
 /**
  * LCS ccwgroup driver registration
  */
@@ -2389,6 +2418,33 @@ static struct ccwgroup_driver lcs_group_
 	.restore     = lcs_restore,
 };
 
+static ssize_t
+lcs_driver_group_store(struct device_driver *ddrv, const char *buf,
+		       size_t count)
+{
+	int err;
+	err = ccwgroup_create_from_string(lcs_root_dev,
+					  lcs_group_driver.driver_id,
+					  &lcs_ccw_driver, 2, buf);
+	return err ? err : count;
+}
+
+static DRIVER_ATTR(group, 0200, NULL, lcs_driver_group_store);
+
+static struct attribute *lcs_group_attrs[] = {
+	&driver_attr_group.attr,
+	NULL,
+};
+
+static struct attribute_group lcs_group_attr_group = {
+	.attrs = lcs_group_attrs,
+};
+
+static struct attribute_group *lcs_group_attr_groups[] = {
+	&lcs_group_attr_group,
+	NULL,
+};
+
 /**
  *  LCS Module/Kernel initialization function
  */
@@ -2400,17 +2456,30 @@ __init lcs_init_module(void)
 	pr_info("Loading %s\n", version);
 	rc = lcs_register_debug_facility();
 	LCS_DBF_TEXT(0, setup, "lcsinit");
-	if (rc) {
-		pr_err("Initialization failed\n");
-		return rc;
-	}
-
-	rc = register_cu3088_discipline(&lcs_group_driver);
-	if (rc) {
-		pr_err("Initialization failed\n");
-		return rc;
-	}
+	if (rc)
+		goto out_err;
+	lcs_root_dev = root_device_register("lcs");
+	rc = IS_ERR(lcs_root_dev) ? PTR_ERR(lcs_root_dev) : 0;
+	if (rc)
+		goto register_err;
+	rc = ccw_driver_register(&lcs_ccw_driver);
+	if (rc)
+		goto ccw_err;
+	lcs_group_driver.driver.groups = lcs_group_attr_groups;
+	rc = ccwgroup_driver_register(&lcs_group_driver);
+	if (rc)
+		goto ccwgroup_err;
 	return 0;
+
+ccwgroup_err:
+	ccw_driver_unregister(&lcs_ccw_driver);
+ccw_err:
+	root_device_unregister(lcs_root_dev);
+register_err:
+	lcs_unregister_debug_facility();
+out_err:
+	pr_err("Initializing the lcs device driver failed\n");
+	return rc;
 }
 
 
@@ -2422,7 +2491,11 @@ __exit lcs_cleanup_module(void)
 {
 	pr_info("Terminating lcs module.\n");
 	LCS_DBF_TEXT(0, trace, "cleanup");
-	unregister_cu3088_discipline(&lcs_group_driver);
+	driver_remove_file(&lcs_group_driver.driver,
+			   &driver_attr_group);
+	ccwgroup_driver_unregister(&lcs_group_driver);
+	ccw_driver_unregister(&lcs_ccw_driver);
+	root_device_unregister(lcs_root_dev);
 	lcs_unregister_debug_facility();
 }
 
diff -urpN linux-2.6/drivers/s390/net/lcs.h linux-2.6-patched/drivers/s390/net/lcs.h
--- linux-2.6/drivers/s390/net/lcs.h	2009-09-10 00:13:59.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/lcs.h	2009-11-12 14:59:32.000000000 +0100
@@ -36,6 +36,24 @@ static inline int lcs_dbf_passes(debug_i
 #define CARD_FROM_DEV(cdev) \
 	(struct lcs_card *) dev_get_drvdata( \
 		&((struct ccwgroup_device *)dev_get_drvdata(&cdev->dev))->dev);
+
+/**
+ * Enum for classifying detected devices.
+ */
+enum lcs_channel_types {
+	/* Device is not a channel  */
+	lcs_channel_type_none,
+
+	/* Device is a 2216 channel */
+	lcs_channel_type_parallel,
+
+	/* Device is a 2216 channel */
+	lcs_channel_type_2216,
+
+	/* Device is a OSA2 card */
+	lcs_channel_type_osa2
+};
+
 /**
  * CCW commands used in this driver
  */
diff -urpN linux-2.6/drivers/s390/net/Makefile linux-2.6-patched/drivers/s390/net/Makefile
--- linux-2.6/drivers/s390/net/Makefile	2009-09-10 00:13:59.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/Makefile	2009-11-12 14:59:32.000000000 +0100
@@ -3,11 +3,11 @@
 #
 
 ctcm-y += ctcm_main.o ctcm_fsms.o ctcm_mpc.o ctcm_sysfs.o ctcm_dbug.o
-obj-$(CONFIG_CTCM) += ctcm.o fsm.o cu3088.o
+obj-$(CONFIG_CTCM) += ctcm.o fsm.o
 obj-$(CONFIG_NETIUCV) += netiucv.o fsm.o
 obj-$(CONFIG_SMSGIUCV) += smsgiucv.o
-obj-$(CONFIG_LCS) += lcs.o cu3088.o
-obj-$(CONFIG_CLAW) += claw.o cu3088.o
+obj-$(CONFIG_LCS) += lcs.o
+obj-$(CONFIG_CLAW) += claw.o
 qeth-y += qeth_core_sys.o qeth_core_main.o qeth_core_mpc.o
 obj-$(CONFIG_QETH) += qeth.o
 qeth_l2-y += qeth_l2_main.o

