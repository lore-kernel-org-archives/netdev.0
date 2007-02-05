From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 4/7] [S390]: Adapt vmlogrdr driver to new IUCV API
Date: Mon, 5 Feb 2007 15:02:15 +0100
Message-ID: <20070205140215.GE19137@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-s390@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:47605 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932617AbXBEOB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 09:01:56 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Martin Schwidefsky <schwidefsky@de.ibm.com>

Adapt vmlogrdr character device driver to new IUCV API

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 drivers/s390/char/vmlogrdr.c |  284 +++++++++++++++++++-----------------------
 1 files changed, 129 insertions(+), 155 deletions(-)

diff --git a/drivers/s390/char/vmlogrdr.c b/drivers/s390/char/vmlogrdr.c
index 6cb2304..8432a76 100644
--- a/drivers/s390/char/vmlogrdr.c
+++ b/drivers/s390/char/vmlogrdr.c
@@ -3,7 +3,7 @@
  *	character device driver for reading z/VM system service records
  *
  *
- *	Copyright (C) 2004 IBM Corporation
+ *	Copyright 2004 IBM Corporation
  *	character device driver for reading z/VM system service records,
  *	Version 1.0
  *	Author(s): Xenia Tkatschow <xenia@us.ibm.com>
@@ -21,7 +21,7 @@ #include <asm/uaccess.h>
 #include <asm/cpcmd.h>
 #include <asm/debug.h>
 #include <asm/ebcdic.h>
-#include "../net/iucv.h"
+#include <net/iucv/iucv.h>
 #include <linux/kmod.h>
 #include <linux/cdev.h>
 #include <linux/device.h>
@@ -60,12 +60,11 @@ struct vmlogrdr_priv_t {
 	char system_service[8];
 	char internal_name[8];
 	char recording_name[8];
-	u16 pathid;
+	struct iucv_path *path;
 	int connection_established;
 	int iucv_path_severed;
-	iucv_MessagePending local_interrupt_buffer;
+	struct iucv_message local_interrupt_buffer;
 	atomic_t receive_ready;
-	iucv_handle_t iucv_handle;
 	int minor_num;
 	char * buffer;
 	char * current_position;
@@ -97,40 +96,21 @@ static struct file_operations vmlogrdr_f
 };
 
 
-static u8 iucvMagic[16] = {
-	0xF0, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40,
-	0xF0, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40
-};
+static void vmlogrdr_iucv_path_complete(struct iucv_path *, u8 ipuser[16]);
+static void vmlogrdr_iucv_path_severed(struct iucv_path *, u8 ipuser[16]);
+static void vmlogrdr_iucv_message_pending(struct iucv_path *,
+					  struct iucv_message *);
 
 
-static u8 mask[] = {
-	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
-	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
-	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
-	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
+static struct iucv_handler vmlogrdr_iucv_handler = {
+	.path_complete	 = vmlogrdr_iucv_path_complete,
+	.path_severed	 = vmlogrdr_iucv_path_severed,
+	.message_pending = vmlogrdr_iucv_message_pending,
 };
 
 
-static u8 iucv_host[8] = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
-
-
-static void
-vmlogrdr_iucv_ConnectionComplete(iucv_ConnectionComplete *eib, void *pgm_data);
-static void
-vmlogrdr_iucv_ConnectionSevered(iucv_ConnectionSevered *eib, void *pgm_data);
-static void
-vmlogrdr_iucv_MessagePending(iucv_MessagePending *eib, void *pgm_data);
-
-
-static iucv_interrupt_ops_t vmlogrdr_iucvops = {
-	.ConnectionComplete = vmlogrdr_iucv_ConnectionComplete,
-	.ConnectionSevered  = vmlogrdr_iucv_ConnectionSevered,
-	.MessagePending     = vmlogrdr_iucv_MessagePending,
-};
-
-
-DECLARE_WAIT_QUEUE_HEAD(conn_wait_queue);
-DECLARE_WAIT_QUEUE_HEAD(read_wait_queue);
+static DECLARE_WAIT_QUEUE_HEAD(conn_wait_queue);
+static DECLARE_WAIT_QUEUE_HEAD(read_wait_queue);
 
 /*
  * pointer to system service private structure
@@ -177,28 +157,29 @@ static struct cdev  *vmlogrdr_cdev = NUL
 static int recording_class_AB;
 
 
-static void
-vmlogrdr_iucv_ConnectionComplete (iucv_ConnectionComplete * eib,
-				   void * pgm_data)
+static void vmlogrdr_iucv_path_complete(struct iucv_path *path, u8 ipuser[16])
 {
-	struct vmlogrdr_priv_t * logptr = pgm_data;
+	struct vmlogrdr_priv_t * logptr = path->private;
+
 	spin_lock(&logptr->priv_lock);
 	logptr->connection_established = 1;
 	spin_unlock(&logptr->priv_lock);
 	wake_up(&conn_wait_queue);
-	return;
 }
 
 
-static void
-vmlogrdr_iucv_ConnectionSevered (iucv_ConnectionSevered * eib, void * pgm_data)
+static void vmlogrdr_iucv_path_severed(struct iucv_path *path, u8 ipuser[16])
 {
-	u8 reason = (u8) eib->ipuser[8];
-	struct vmlogrdr_priv_t * logptr = pgm_data;
+	struct vmlogrdr_priv_t * logptr = path->private;
+	u8 reason = (u8) ipuser[8];
 
 	printk (KERN_ERR "vmlogrdr: connection severed with"
 		" reason %i\n", reason);
 
+	iucv_path_sever(path, NULL);
+	kfree(path);
+	logptr->path = NULL;
+
 	spin_lock(&logptr->priv_lock);
 	logptr->connection_established = 0;
 	logptr->iucv_path_severed = 1;
@@ -210,10 +191,10 @@ vmlogrdr_iucv_ConnectionSevered (iucv_Co
 }
 
 
-static void
-vmlogrdr_iucv_MessagePending (iucv_MessagePending * eib, void * pgm_data)
+static void vmlogrdr_iucv_message_pending(struct iucv_path *path,
+					  struct iucv_message *msg)
 {
-	struct vmlogrdr_priv_t * logptr = pgm_data;
+	struct vmlogrdr_priv_t * logptr = path->private;
 
 	/*
 	 * This function is the bottom half so it should be quick.
@@ -221,15 +202,15 @@ vmlogrdr_iucv_MessagePending (iucv_Messa
 	 * the usage count
 	 */
 	spin_lock(&logptr->priv_lock);
-	memcpy(&(logptr->local_interrupt_buffer), eib, sizeof(*eib));
+	memcpy(&logptr->local_interrupt_buffer, msg, sizeof(*msg));
 	atomic_inc(&logptr->receive_ready);
 	spin_unlock(&logptr->priv_lock);
 	wake_up_interruptible(&read_wait_queue);
 }
 
 
-static int
-vmlogrdr_get_recording_class_AB(void) {
+static int vmlogrdr_get_recording_class_AB(void)
+{
 	char cp_command[]="QUERY COMMAND RECORDING ";
 	char cp_response[80];
 	char *tail;
@@ -259,8 +240,9 @@ vmlogrdr_get_recording_class_AB(void) {
 }
 
 
-static int
-vmlogrdr_recording(struct vmlogrdr_priv_t * logptr, int action, int purge) {
+static int vmlogrdr_recording(struct vmlogrdr_priv_t * logptr,
+			      int action, int purge)
+{
 
 	char cp_command[80];
 	char cp_response[160];
@@ -318,8 +300,7 @@ vmlogrdr_recording(struct vmlogrdr_priv_
 }
 
 
-static int
-vmlogrdr_open (struct inode *inode, struct file *filp)
+static int vmlogrdr_open (struct inode *inode, struct file *filp)
 {
 	int dev_num = 0;
 	struct vmlogrdr_priv_t * logptr = NULL;
@@ -329,10 +310,7 @@ vmlogrdr_open (struct inode *inode, stru
 	dev_num = iminor(inode);
 	if (dev_num > MAXMINOR)
 		return -ENODEV;
-
 	logptr = &sys_ser[dev_num];
-	if (logptr == NULL)
-		return -ENODEV;
 
 	/*
 	 * only allow for blocking reads to be open
@@ -345,52 +323,38 @@ vmlogrdr_open (struct inode *inode, stru
 	if (logptr->dev_in_use)	{
 		spin_unlock_bh(&logptr->priv_lock);
 		return -EBUSY;
-	} else {
-		logptr->dev_in_use = 1;
-		spin_unlock_bh(&logptr->priv_lock);
 	}
-
+	logptr->dev_in_use = 1;
+	logptr->connection_established = 0;
+	logptr->iucv_path_severed = 0;
 	atomic_set(&logptr->receive_ready, 0);
 	logptr->buffer_free = 1;
+	spin_unlock_bh(&logptr->priv_lock);
 
 	/* set the file options */
 	filp->private_data = logptr;
 	filp->f_op = &vmlogrdr_fops;
 
 	/* start recording for this service*/
-	ret=0;
-	if (logptr->autorecording)
+	if (logptr->autorecording) {
 		ret = vmlogrdr_recording(logptr,1,logptr->autopurge);
-	if (ret)
-		printk (KERN_WARNING "vmlogrdr: failed to start "
-			"recording automatically\n");
-
-	/* Register with iucv driver */
-	logptr->iucv_handle = iucv_register_program(iucvMagic,
-			logptr->system_service, mask, &vmlogrdr_iucvops,
-			logptr);
-
-	if (logptr->iucv_handle == NULL) {
-		printk (KERN_ERR "vmlogrdr: failed to register with"
-			"iucv driver\n");
-		goto not_registered;
+		if (ret)
+			printk (KERN_WARNING "vmlogrdr: failed to start "
+				"recording automatically\n");
 	}
 
 	/* create connection to the system service */
-	spin_lock_bh(&logptr->priv_lock);
-	logptr->connection_established = 0;
-	logptr->iucv_path_severed = 0;
-	spin_unlock_bh(&logptr->priv_lock);
-
-	connect_rc = iucv_connect (&(logptr->pathid), 10, iucvMagic,
-					logptr->system_service, iucv_host, 0,
-					NULL, NULL,
-					logptr->iucv_handle, NULL);
+	logptr->path = iucv_path_alloc(10, 0, GFP_KERNEL);
+	if (!logptr->path)
+		goto out_dev;
+	connect_rc = iucv_path_connect(logptr->path, &vmlogrdr_iucv_handler,
+				       logptr->system_service, NULL, NULL,
+				       logptr);
 	if (connect_rc) {
 		printk (KERN_ERR "vmlogrdr: iucv connection to %s "
 			"failed with rc %i \n", logptr->system_service,
 			connect_rc);
-		goto not_connected;
+		goto out_path;
 	}
 
 	/* We've issued the connect and now we must wait for a
@@ -399,35 +363,28 @@ vmlogrdr_open (struct inode *inode, stru
 	 */
 	wait_event(conn_wait_queue, (logptr->connection_established)
 		   || (logptr->iucv_path_severed));
-	if (logptr->iucv_path_severed) {
-		goto not_connected;
-	}
-
+	if (logptr->iucv_path_severed)
+		goto out_record;
  	return nonseekable_open(inode, filp);
 
-not_connected:
-	iucv_unregister_program(logptr->iucv_handle);
-	logptr->iucv_handle = NULL;
-not_registered:
+out_record:
 	if (logptr->autorecording)
 		vmlogrdr_recording(logptr,0,logptr->autopurge);
+out_path:
+	kfree(logptr->path);	/* kfree(NULL) is ok. */
+	logptr->path = NULL;
+out_dev:
 	logptr->dev_in_use = 0;
 	return -EIO;
-
-
 }
 
 
-static int
-vmlogrdr_release (struct inode *inode, struct file *filp)
+static int vmlogrdr_release (struct inode *inode, struct file *filp)
 {
 	int ret;
 
 	struct vmlogrdr_priv_t * logptr = filp->private_data;
 
-	iucv_unregister_program(logptr->iucv_handle);
-	logptr->iucv_handle = NULL;
-
 	if (logptr->autorecording) {
 		ret = vmlogrdr_recording(logptr,0,logptr->autopurge);
 		if (ret)
@@ -440,8 +397,8 @@ vmlogrdr_release (struct inode *inode, s
 }
 
 
-static int
-vmlogrdr_receive_data(struct vmlogrdr_priv_t *priv) {
+static int vmlogrdr_receive_data(struct vmlogrdr_priv_t *priv)
+{
 	int rc, *temp;
 	/* we need to keep track of two data sizes here:
 	 * The number of bytes we need to receive from iucv and
@@ -462,8 +419,7 @@ vmlogrdr_receive_data(struct vmlogrdr_pr
 			 * We need to return the total length of the record
                          * + size of FENCE in the first 4 bytes of the buffer.
 		         */
-			iucv_data_count =
-				priv->local_interrupt_buffer.ln1msg2.ipbfln1f;
+			iucv_data_count = priv->local_interrupt_buffer.length;
 			user_data_count = sizeof(int);
 			temp = (int*)priv->buffer;
 			*temp= iucv_data_count + sizeof(FENCE);
@@ -475,14 +431,10 @@ vmlogrdr_receive_data(struct vmlogrdr_pr
 		 */
 		if (iucv_data_count > NET_BUFFER_SIZE)
 			iucv_data_count = NET_BUFFER_SIZE;
-		rc = iucv_receive(priv->pathid,
-				  priv->local_interrupt_buffer.ipmsgid,
-				  priv->local_interrupt_buffer.iptrgcls,
-				  buffer,
-				  iucv_data_count,
-				  NULL,
-				  NULL,
-				  &priv->residual_length);
+		rc = iucv_message_receive(priv->path,
+					  &priv->local_interrupt_buffer,
+					  0, buffer, iucv_data_count,
+					  &priv->residual_length);
 		spin_unlock_bh(&priv->priv_lock);
 		/* An rc of 5 indicates that the record was bigger then
 		 * the buffer, which is OK for us. A 9 indicates that the
@@ -514,8 +466,8 @@ vmlogrdr_receive_data(struct vmlogrdr_pr
 }
 
 
-static ssize_t
-vmlogrdr_read(struct file *filp, char __user *data, size_t count, loff_t * ppos)
+static ssize_t vmlogrdr_read(struct file *filp, char __user *data,
+			     size_t count, loff_t * ppos)
 {
 	int rc;
 	struct vmlogrdr_priv_t * priv = filp->private_data;
@@ -547,8 +499,10 @@ vmlogrdr_read(struct file *filp, char __
 	return count;
 }
 
-static ssize_t
-vmlogrdr_autopurge_store(struct device * dev, struct device_attribute *attr, const char * buf, size_t count) {
+static ssize_t vmlogrdr_autopurge_store(struct device * dev,
+					struct device_attribute *attr,
+					const char * buf, size_t count)
+{
 	struct vmlogrdr_priv_t *priv = dev->driver_data;
 	ssize_t ret = count;
 
@@ -566,8 +520,10 @@ vmlogrdr_autopurge_store(struct device *
 }
 
 
-static ssize_t
-vmlogrdr_autopurge_show(struct device *dev, struct device_attribute *attr, char *buf) {
+static ssize_t vmlogrdr_autopurge_show(struct device *dev,
+				       struct device_attribute *attr,
+				       char *buf)
+{
 	struct vmlogrdr_priv_t *priv = dev->driver_data;
 	return sprintf(buf, "%u\n", priv->autopurge);
 }
@@ -577,8 +533,10 @@ static DEVICE_ATTR(autopurge, 0644, vmlo
 		   vmlogrdr_autopurge_store);
 
 
-static ssize_t
-vmlogrdr_purge_store(struct device * dev, struct device_attribute *attr, const char * buf, size_t count) {
+static ssize_t vmlogrdr_purge_store(struct device * dev,
+				    struct device_attribute *attr,
+				    const char * buf, size_t count)
+{
 
 	char cp_command[80];
 	char cp_response[80];
@@ -618,9 +576,10 @@ vmlogrdr_purge_store(struct device * dev
 static DEVICE_ATTR(purge, 0200, NULL, vmlogrdr_purge_store);
 
 
-static ssize_t
-vmlogrdr_autorecording_store(struct device *dev, struct device_attribute *attr, const char *buf,
-			     size_t count) {
+static ssize_t vmlogrdr_autorecording_store(struct device *dev,
+					    struct device_attribute *attr,
+					    const char *buf, size_t count)
+{
 	struct vmlogrdr_priv_t *priv = dev->driver_data;
 	ssize_t ret = count;
 
@@ -638,8 +597,10 @@ vmlogrdr_autorecording_store(struct devi
 }
 
 
-static ssize_t
-vmlogrdr_autorecording_show(struct device *dev, struct device_attribute *attr, char *buf) {
+static ssize_t vmlogrdr_autorecording_show(struct device *dev,
+					   struct device_attribute *attr,
+					   char *buf)
+{
 	struct vmlogrdr_priv_t *priv = dev->driver_data;
 	return sprintf(buf, "%u\n", priv->autorecording);
 }
@@ -649,9 +610,10 @@ static DEVICE_ATTR(autorecording, 0644, 
 		   vmlogrdr_autorecording_store);
 
 
-static ssize_t
-vmlogrdr_recording_store(struct device * dev, struct device_attribute *attr, const char * buf, size_t count) {
-
+static ssize_t vmlogrdr_recording_store(struct device * dev,
+					struct device_attribute *attr,
+					const char * buf, size_t count)
+{
 	struct vmlogrdr_priv_t *priv = dev->driver_data;
 	ssize_t ret;
 
@@ -676,8 +638,9 @@ vmlogrdr_recording_store(struct device *
 static DEVICE_ATTR(recording, 0200, NULL, vmlogrdr_recording_store);
 
 
-static ssize_t
-vmlogrdr_recording_status_show(struct device_driver *driver, char *buf) {
+static ssize_t vmlogrdr_recording_status_show(struct device_driver *driver,
+					      char *buf)
+{
 
 	char cp_command[] = "QUERY RECORDING ";
 	int len;
@@ -710,52 +673,63 @@ static struct device_driver vmlogrdr_dri
 };
 
 
-static int
-vmlogrdr_register_driver(void) {
+static int vmlogrdr_register_driver(void)
+{
 	int ret;
 
+	/* Register with iucv driver */
+	ret = iucv_register(&vmlogrdr_iucv_handler, 1);
+	if (ret) {
+		printk (KERN_ERR "vmlogrdr: failed to register with"
+			"iucv driver\n");
+		goto out;
+	}
+
 	ret = driver_register(&vmlogrdr_driver);
 	if (ret) {
 		printk(KERN_ERR "vmlogrdr: failed to register driver.\n");
-		return ret;
+		goto out_iucv;
 	}
 
 	ret = driver_create_file(&vmlogrdr_driver,
 				 &driver_attr_recording_status);
 	if (ret) {
 		printk(KERN_ERR "vmlogrdr: failed to add driver attribute.\n");
-		goto unregdriver;
+		goto out_driver;
 	}
 
 	vmlogrdr_class = class_create(THIS_MODULE, "vmlogrdr");
 	if (IS_ERR(vmlogrdr_class)) {
 		printk(KERN_ERR "vmlogrdr: failed to create class.\n");
-		ret=PTR_ERR(vmlogrdr_class);
-		vmlogrdr_class=NULL;
-		goto unregattr;
+		ret = PTR_ERR(vmlogrdr_class);
+		vmlogrdr_class = NULL;
+		goto out_attr;
 	}
 	return 0;
 
-unregattr:
+out_attr:
 	driver_remove_file(&vmlogrdr_driver, &driver_attr_recording_status);
-unregdriver:
+out_driver:
 	driver_unregister(&vmlogrdr_driver);
+out_iucv:
+	iucv_unregister(&vmlogrdr_iucv_handler, 1);
+out:
 	return ret;
 }
 
 
-static void
-vmlogrdr_unregister_driver(void) {
+static void vmlogrdr_unregister_driver(void)
+{
 	class_destroy(vmlogrdr_class);
 	vmlogrdr_class = NULL;
 	driver_remove_file(&vmlogrdr_driver, &driver_attr_recording_status);
 	driver_unregister(&vmlogrdr_driver);
-	return;
+	iucv_unregister(&vmlogrdr_iucv_handler, 1);
 }
 
 
-static int
-vmlogrdr_register_device(struct vmlogrdr_priv_t *priv) {
+static int vmlogrdr_register_device(struct vmlogrdr_priv_t *priv)
+{
 	struct device *dev;
 	int ret;
 
@@ -804,9 +778,10 @@ vmlogrdr_register_device(struct vmlogrdr
 }
 
 
-static int
-vmlogrdr_unregister_device(struct vmlogrdr_priv_t *priv ) {
-	class_device_destroy(vmlogrdr_class, MKDEV(vmlogrdr_major, priv->minor_num));
+static int vmlogrdr_unregister_device(struct vmlogrdr_priv_t *priv)
+{
+	class_device_destroy(vmlogrdr_class,
+			     MKDEV(vmlogrdr_major, priv->minor_num));
 	if (priv->device != NULL) {
 		sysfs_remove_group(&priv->device->kobj, &vmlogrdr_attr_group);
 		device_unregister(priv->device);
@@ -816,8 +791,8 @@ vmlogrdr_unregister_device(struct vmlogr
 }
 
 
-static int
-vmlogrdr_register_cdev(dev_t dev) {
+static int vmlogrdr_register_cdev(dev_t dev)
+{
 	int rc = 0;
 	vmlogrdr_cdev = cdev_alloc();
 	if (!vmlogrdr_cdev) {
@@ -837,9 +812,10 @@ vmlogrdr_register_cdev(dev_t dev) {
 }
 
 
-static void
-vmlogrdr_cleanup(void) {
+static void vmlogrdr_cleanup(void)
+{
         int i;
+
 	if (vmlogrdr_cdev) {
 		cdev_del(vmlogrdr_cdev);
 		vmlogrdr_cdev=NULL;
@@ -856,8 +832,7 @@ vmlogrdr_cleanup(void) {
 }
 
 
-static int
-vmlogrdr_init(void)
+static int vmlogrdr_init(void)
 {
 	int rc;
 	int i;
@@ -907,8 +882,7 @@ cleanup:
 }
 
 
-static void
-vmlogrdr_exit(void)
+static void vmlogrdr_exit(void)
 {
 	vmlogrdr_cleanup();
 	printk (KERN_INFO "vmlogrdr: driver unloaded\n");
-- 
1.4.2.3

