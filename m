From: Jeff Garzik <jgarzik@pobox.com>
Subject: [Fwd: [PATCH] add sysfs class support for raw devices [06/10]]
Date: Thu, 15 Jan 2004 16:11:10 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <400701EE.3060707@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040007080600050907040103"
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040007080600050907040103
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


Regarding the recent discussion on bonding/vlan/bridge/blah configuration...



--------------040007080600050907040103
Content-Type: message/rfc822;
 name="[PATCH] add sysfs class support for raw devices [06/10]"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="[PATCH] add sysfs class support for raw devices [06/10]"

Return-Path: <linux-kernel-owner+jgarzik=40pobox.com@vger.kernel.org>
Delivered-To: garzik@gtf.org
Received: from majesty.pobox.com (majesty.pobox.com [208.210.124.70])
	by havoc.gtf.org (Postfix) with ESMTP id BF2126644
	for <garzik@gtf.org>; Thu, 15 Jan 2004 15:51:36 -0500 (EST)
Received: from majesty.pobox.com (localhost [127.0.0.1])
	by majesty.pobox.com (Postfix) with ESMTP id B481BE3D2
	for <garzik@gtf.org>; Thu, 15 Jan 2004 15:51:36 -0500 (EST)
Delivered-To: jgarzik@pobox.com
Received: from colander (localhost [127.0.0.1])
	by majesty.pobox.com (Postfix) with ESMTP id 25244E408
	for <jgarzik@pobox.com>; Thu, 15 Jan 2004 15:51:36 -0500 (EST)
Received: from vger.kernel.org (vger.kernel.org [67.72.78.212])
	by majesty.pobox.com (Postfix) with ESMTP
	for <jgarzik@pobox.com>; Thu, 15 Jan 2004 15:51:33 -0500 (EST)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
	id S263101AbUAOUqO (ORCPT <rfc822;jgarzik@pobox.com>);
	Thu, 15 Jan 2004 15:46:14 -0500
Received: (majordomo@vger.kernel.org) by vger.kernel.org id S263173AbUAOUoo
	(ORCPT <rfc822;linux-kernel-outgoing>);
	Thu, 15 Jan 2004 15:44:44 -0500
Received: from mail.kroah.org ([65.200.24.183]:14299 "EHLO perch.kroah.org")
	by vger.kernel.org with ESMTP id S262795AbUAOUoF (ORCPT
	<rfc822;linux-kernel@vger.kernel.org>);
	Thu, 15 Jan 2004 15:44:05 -0500
Received: from [9.47.21.222] (bi01p1.nc.us.ibm.com [129.33.49.251])
	(authenticated)
	by perch.kroah.org (8.11.6/8.11.6) with ESMTP id i0FKf0c16992;
	Thu, 15 Jan 2004 12:41:00 -0800
Received: from greg by echidna.kroah.org with local (masqmail 0.2.19)
 id 1AhEK9-5my-00; Thu, 15 Jan 2004 12:42:41 -0800
Date: Thu, 15 Jan 2004 12:42:41 -0800
From: Greg KH <greg@kroah.com>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org,
	linux-hotplug-devel@lists.sourceforge.net
Subject: [PATCH] add sysfs class support for raw devices [06/10]
Message-ID: <20040115204241.GG22199@kroah.com>
References: <20040115204048.GA22199@kroah.com> <20040115204111.GB22199@kroah.com> <20040115204125.GC22199@kroah.com> <20040115204138.GD22199@kroah.com> <20040115204153.GE22199@kroah.com> <20040115204209.GF22199@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040115204209.GF22199@kroah.com>
User-Agent: Mutt/1.4.1i
Sender: linux-kernel-owner@vger.kernel.org
Precedence: bulk
X-Mailing-List: linux-kernel@vger.kernel.org
X-Spam-Checker-Version: SpamAssassin 2.60 (1.212-2003-09-23-exp) on
	havoc.gtf.org
X-Spam-Status: No, hits=-3.2 required=7.0 tests=AWL,BAYES_00,
	REMOVE_REMOVAL_2WORD autolearn=no version=2.60
X-Spam-Level: 


This adds class/raw/ support for all raw devices.  It also provides a
symlink to the block device that the raw device is mapped to.  For
example:

$ tree /sys/class/raw/
/sys/class/raw/
|-- raw1
|   |-- dev
|   `-- device -> ../../../block/sda
|-- raw2
|   |-- dev
|   `-- device -> ../../../block/sda/sda2
`-- rawctl
    `-- dev


Note, in order to get that symlink, I had to export get_gendisk() so that
modules can use it.  I hope this is ok with everyone.

This is based on a patch originally written by 
Leann Ogasawara <ogasawara@osdl.org>



diff -Nru a/drivers/block/genhd.c b/drivers/block/genhd.c
--- a/drivers/block/genhd.c	Thu Jan 15 11:05:57 2004
+++ b/drivers/block/genhd.c	Thu Jan 15 11:05:57 2004
@@ -224,6 +224,8 @@
 	return  kobj ? to_disk(kobj) : NULL;
 }
 
+EXPORT_SYMBOL(get_gendisk);
+
 #ifdef CONFIG_PROC_FS
 /* iterator */
 static void *part_start(struct seq_file *part, loff_t *pos)
diff -Nru a/drivers/char/raw.c b/drivers/char/raw.c
--- a/drivers/char/raw.c	Thu Jan 15 11:05:47 2004
+++ b/drivers/char/raw.c	Thu Jan 15 11:05:47 2004
@@ -17,6 +17,8 @@
 #include <linux/raw.h>
 #include <linux/capability.h>
 #include <linux/uio.h>
+#include <linux/device.h>
+#include <linux/genhd.h>
 
 #include <asm/uaccess.h>
 
@@ -25,6 +27,7 @@
 	int inuse;
 };
 
+static struct class_simple *raw_class;
 static struct raw_device_data raw_devices[MAX_RAW_MINORS];
 static DECLARE_MUTEX(raw_mutex);
 static struct file_operations raw_ctl_fops;	     /* forward declaration */
@@ -119,6 +122,29 @@
 	return ioctl_by_bdev(bdev, command, arg);
 }
 
+static void bind_device(struct raw_config_request rq)
+{
+	int part;
+	struct gendisk *gen;
+	struct class_device *dev;
+	struct kobject *target = NULL;
+
+	gen = get_gendisk(MKDEV(rq.block_major, rq.block_minor), &part);
+	if (gen) {
+		if (part && gen->part[part])
+			target = &gen->part[part]->kobj;
+		else
+			target = &gen->kobj;
+	}
+
+	class_simple_device_remove(MKDEV(RAW_MAJOR, rq.raw_minor));
+	dev = class_simple_device_add(raw_class, MKDEV(RAW_MAJOR, rq.raw_minor),
+				      NULL, "raw%d", rq.raw_minor);
+	if (dev && target) {
+		sysfs_create_link(&dev->kobj, target, "device");
+	}
+}
+
 /*
  * Deal with ioctls against the raw-device control interface, to bind
  * and unbind other raw devices.
@@ -187,12 +213,15 @@
 			if (rq.block_major == 0 && rq.block_minor == 0) {
 				/* unbind */
 				rawdev->binding = NULL;
+				class_simple_device_remove(MKDEV(RAW_MAJOR, rq.raw_minor));
 			} else {
 				rawdev->binding = bdget(dev);
 				if (rawdev->binding == NULL)
 					err = -ENOMEM;
-				else
+				else {
 					__module_get(THIS_MODULE);
+					bind_device(rq);
+				}
 			}
 			up(&raw_mutex);
 		} else {
@@ -262,6 +291,14 @@
 	int i;
 
 	register_chrdev(RAW_MAJOR, "raw", &raw_fops);
+
+	raw_class = class_simple_create(THIS_MODULE, "raw");
+	if (IS_ERR(raw_class)) {
+		printk (KERN_ERR "Error creating raw class.\n");
+		return PTR_ERR(raw_class);
+	}
+	class_simple_device_add(raw_class, MKDEV(RAW_MAJOR, 0), NULL, "rawctl");
+
 	devfs_mk_cdev(MKDEV(RAW_MAJOR, 0),
 		      S_IFCHR | S_IRUGO | S_IWUGO,
 		      "raw/rawctl");
@@ -280,6 +317,8 @@
 		devfs_remove("raw/raw%d", i);
 	devfs_remove("raw/rawctl");
 	devfs_remove("raw");
+	class_simple_device_remove(MKDEV(RAW_MAJOR, 0));
+	class_simple_destroy(raw_class);
 	unregister_chrdev(RAW_MAJOR, "raw");
 }
 
-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/



--------------040007080600050907040103--
