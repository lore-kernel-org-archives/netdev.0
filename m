From: frank.blaschka@de.ibm.com
Subject: [patch 03/11] ccwgroup: Unify parsing for group attribute.
Date: Thu, 24 Apr 2008 10:15:20 +0200
Message-ID: <20080424081903.377322000@de.ibm.com>
References: <20080424081517.987104000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <braunu@de.ibm.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:41684 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266AbYDXITG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 04:19:06 -0400
Content-Disposition: inline; filename=702-cio-ccwgroup.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <braunu@de.ibm.com>

Instead of having each driver for ccwgroup slave device parsing the
input itself and calling ccwgroup_create(), introduce a new function
ccwgroup_create_from_string() and handle parsing inside the ccwgroup
core.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/cio/ccwgroup.c       |   96 +++++++++++++++++++++++++++++---------
 drivers/s390/net/cu3088.c         |   20 -------
 drivers/s390/net/qeth_core_main.c |   23 ---------
 include/asm-s390/ccwgroup.h       |    7 +-
 4 files changed, 82 insertions(+), 64 deletions(-)

Index: git_linus/drivers/s390/cio/ccwgroup.c
===================================================================
--- git_linus.orig/drivers/s390/cio/ccwgroup.c	2008-04-24 09:04:43.000000000 +0200
+++ git_linus/drivers/s390/cio/ccwgroup.c	2008-04-24 09:05:08.000000000 +0200
@@ -152,44 +152,89 @@
 	return 0;
 }
 
+static int __get_next_bus_id(const char **buf, char *bus_id)
+{
+	int rc, len;
+	char *start, *end;
+
+	start = (char *)*buf;
+	end = strchr(start, ',');
+	if (!end) {
+		/* Last entry. Strip trailing newline, if applicable. */
+		end = strchr(start, '\n');
+		if (end)
+			*end = '\0';
+		len = strlen(start) + 1;
+	} else {
+		len = end - start + 1;
+		end++;
+	}
+	if (len < BUS_ID_SIZE) {
+		strlcpy(bus_id, start, len);
+		rc = 0;
+	} else
+		rc = -EINVAL;
+	*buf = end;
+	return rc;
+}
+
+static int __is_valid_bus_id(char bus_id[BUS_ID_SIZE])
+{
+	int cssid, ssid, devno;
+
+	/* Must be of form %x.%x.%04x */
+	if (sscanf(bus_id, "%x.%1x.%04x", &cssid, &ssid, &devno) != 3)
+		return 0;
+	return 1;
+}
+
 /**
- * ccwgroup_create() - create and register a ccw group device
+ * ccwgroup_create_from_string() - create and register a ccw group device
  * @root: parent device for the new device
  * @creator_id: identifier of creating driver
  * @cdrv: ccw driver of slave devices
- * @argc: number of slave devices
- * @argv: bus ids of slave devices
+ * @num_devices: number of slave devices
+ * @buf: buffer containing comma separated bus ids of slave devices
  *
  * Create and register a new ccw group device as a child of @root. Slave
- * devices are obtained from the list of bus ids given in @argv[] and must all
+ * devices are obtained from the list of bus ids given in @buf and must all
  * belong to @cdrv.
  * Returns:
  *  %0 on success and an error code on failure.
  * Context:
  *  non-atomic
  */
-int ccwgroup_create(struct device *root, unsigned int creator_id,
-		    struct ccw_driver *cdrv, int argc, char *argv[])
+int ccwgroup_create_from_string(struct device *root, unsigned int creator_id,
+				struct ccw_driver *cdrv, int num_devices,
+				const char *buf)
 {
 	struct ccwgroup_device *gdev;
-	int i;
-	int rc;
+	int rc, i;
+	char tmp_bus_id[BUS_ID_SIZE];
+	const char *curr_buf;
 
-	if (argc > 256) /* disallow dumb users */
-		return -EINVAL;
-
-	gdev = kzalloc(sizeof(*gdev) + argc*sizeof(gdev->cdev[0]), GFP_KERNEL);
+	gdev = kzalloc(sizeof(*gdev) + num_devices * sizeof(gdev->cdev[0]),
+		       GFP_KERNEL);
 	if (!gdev)
 		return -ENOMEM;
 
 	atomic_set(&gdev->onoff, 0);
 	mutex_init(&gdev->reg_mutex);
 	mutex_lock(&gdev->reg_mutex);
-	for (i = 0; i < argc; i++) {
-		gdev->cdev[i] = get_ccwdev_by_busid(cdrv, argv[i]);
-
-		/* all devices have to be of the same type in
-		 * order to be grouped */
+	curr_buf = buf;
+	for (i = 0; i < num_devices && curr_buf; i++) {
+		rc = __get_next_bus_id(&curr_buf, tmp_bus_id);
+		if (rc != 0)
+			goto error;
+		if (!__is_valid_bus_id(tmp_bus_id)) {
+			rc = -EINVAL;
+			goto error;
+		}
+		gdev->cdev[i] = get_ccwdev_by_busid(cdrv, tmp_bus_id);
+		/*
+		 * All devices have to be of the same type in
+		 * order to be grouped.
+		 */
 		if (!gdev->cdev[i]
 		    || gdev->cdev[i]->id.driver_info !=
 		    gdev->cdev[0]->id.driver_info) {
@@ -203,9 +248,18 @@
 		}
 		dev_set_drvdata(&gdev->cdev[i]->dev, gdev);
 	}
-
+	/* Check for sufficient number of bus ids. */
+	if (i < num_devices && !curr_buf) {
+		rc = -EINVAL;
+		goto error;
+	}
+	/* Check for trailing stuff. */
+	if (i == num_devices && strlen(curr_buf) > 0) {
+		rc = -EINVAL;
+		goto error;
+	}
 	gdev->creator_id = creator_id;
-	gdev->count = argc;
+	gdev->count = num_devices;
 	gdev->dev.bus = &ccwgroup_bus_type;
 	gdev->dev.parent = root;
 	gdev->dev.release = ccwgroup_release;
@@ -233,7 +287,7 @@
 	device_remove_file(&gdev->dev, &dev_attr_ungroup);
 	device_unregister(&gdev->dev);
 error:
-	for (i = 0; i < argc; i++)
+	for (i = 0; i < num_devices; i++)
 		if (gdev->cdev[i]) {
 			if (dev_get_drvdata(&gdev->cdev[i]->dev) == gdev)
 				dev_set_drvdata(&gdev->cdev[i]->dev, NULL);
@@ -243,6 +297,7 @@
 	put_device(&gdev->dev);
 	return rc;
 }
+EXPORT_SYMBOL(ccwgroup_create_from_string);
 
 static int __init
 init_ccwgroup (void)
@@ -518,6 +573,5 @@
 MODULE_LICENSE("GPL");
 EXPORT_SYMBOL(ccwgroup_driver_register);
 EXPORT_SYMBOL(ccwgroup_driver_unregister);
-EXPORT_SYMBOL(ccwgroup_create);
 EXPORT_SYMBOL(ccwgroup_probe_ccwdev);
 EXPORT_SYMBOL(ccwgroup_remove_ccwdev);
Index: git_linus/drivers/s390/net/cu3088.c
===================================================================
--- git_linus.orig/drivers/s390/net/cu3088.c	2008-04-24 09:04:43.000000000 +0200
+++ git_linus/drivers/s390/net/cu3088.c	2008-04-24 09:05:08.000000000 +0200
@@ -62,30 +62,14 @@
 static ssize_t
 group_write(struct device_driver *drv, const char *buf, size_t count)
 {
-	const char *start, *end;
-	char bus_ids[2][BUS_ID_SIZE], *argv[2];
-	int i;
 	int ret;
 	struct ccwgroup_driver *cdrv;
 
 	cdrv = to_ccwgroupdrv(drv);
 	if (!cdrv)
 		return -EINVAL;
-	start = buf;
-	for (i=0; i<2; i++) {
-		static const char delim[] = {',', '\n'};
-		int len;
-
-		if (!(end = strchr(start, delim[i])))
-			return -EINVAL;
-		len = min_t(ptrdiff_t, BUS_ID_SIZE, end - start + 1);
-		strlcpy (bus_ids[i], start, len);
-		argv[i] = bus_ids[i];
-		start = end + 1;
-	}
-
-	ret = ccwgroup_create(cu3088_root_dev, cdrv->driver_id,
-			      &cu3088_driver, 2, argv);
+	ret = ccwgroup_create_from_string(cu3088_root_dev, cdrv->driver_id,
+					  &cu3088_driver, 2, buf);
 
 	return (ret == 0) ? count : ret;
 }
Index: git_linus/drivers/s390/net/qeth_core_main.c
===================================================================
--- git_linus.orig/drivers/s390/net/qeth_core_main.c	2008-04-24 09:04:43.000000000 +0200
+++ git_linus/drivers/s390/net/qeth_core_main.c	2008-04-24 09:05:08.000000000 +0200
@@ -3827,27 +3827,8 @@
 static int qeth_core_driver_group(const char *buf, struct device *root_dev,
 				unsigned long driver_id)
 {
-	const char *start, *end;
-	char bus_ids[3][BUS_ID_SIZE], *argv[3];
-	int i;
-
-	start = buf;
-	for (i = 0; i < 3; i++) {
-		static const char delim[] = { ',', ',', '\n' };
-		int len;
-
-		end = strchr(start, delim[i]);
-		if (!end)
-			return -EINVAL;
-		len = min_t(ptrdiff_t, BUS_ID_SIZE, end - start);
-		strncpy(bus_ids[i], start, len);
-		bus_ids[i][len] = '\0';
-		start = end + 1;
-		argv[i] = bus_ids[i];
-	}
-
-	return (ccwgroup_create(root_dev, driver_id,
-				&qeth_ccw_driver, 3, argv));
+	return ccwgroup_create_from_string(root_dev, driver_id,
+					   &qeth_ccw_driver, 3, buf);
 }
 
 int qeth_core_hardsetup_card(struct qeth_card *card)
Index: git_linus/include/asm-s390/ccwgroup.h
===================================================================
--- git_linus.orig/include/asm-s390/ccwgroup.h	2008-04-24 09:04:43.000000000 +0200
+++ git_linus/include/asm-s390/ccwgroup.h	2008-04-24 09:05:08.000000000 +0200
@@ -57,10 +57,9 @@
 
 extern int  ccwgroup_driver_register   (struct ccwgroup_driver *cdriver);
 extern void ccwgroup_driver_unregister (struct ccwgroup_driver *cdriver);
-extern int ccwgroup_create (struct device *root,
-			    unsigned int creator_id,
-			    struct ccw_driver *gdrv,
-			    int argc, char *argv[]);
+int ccwgroup_create_from_string(struct device *root, unsigned int creator_id,
+				struct ccw_driver *cdrv, int num_devices,
+				const char *buf);
 
 extern int ccwgroup_probe_ccwdev(struct ccw_device *cdev);
 extern void ccwgroup_remove_ccwdev(struct ccw_device *cdev);

-- 
