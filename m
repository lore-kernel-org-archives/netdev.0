From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] propogate errors from misc_register to caller
Date: Fri, 13 Feb 2004 11:21:00 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040213112100.4f42abc2@dell_ss3.pdx.osdl.net>
References: <20040213102755.27cf4fcd.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Leann Ogasawara <ogasawara@osdl.org>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommi Virtanen <tv@tv.debian.net>, Greg KH <greg@kroah.com>
In-Reply-To: <20040213102755.27cf4fcd.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The patch to check for / in class_device is not enough.
The misc_register function needs to check return value of the things it calls!

diff -Nru a/drivers/char/misc.c b/drivers/char/misc.c
--- a/drivers/char/misc.c	Fri Feb 13 11:15:29 2004
+++ b/drivers/char/misc.c	Fri Feb 13 11:15:29 2004
@@ -212,6 +212,9 @@
 int misc_register(struct miscdevice * misc)
 {
 	struct miscdevice *c;
+	struct class_device *class;
+	dev_t dev;
+	int err;
 	
 	down(&misc_sem);
 	list_for_each_entry(c, &misc_list, list) {
@@ -240,19 +243,30 @@
 		snprintf(misc->devfs_name, sizeof(misc->devfs_name),
 				"misc/%s", misc->name);
 	}
+	dev = MKDEV(MISC_MAJOR, misc->minor);
 
-	class_simple_device_add(misc_class, MKDEV(MISC_MAJOR, misc->minor),
-				misc->dev, misc->name);
-	devfs_mk_cdev(MKDEV(MISC_MAJOR, misc->minor),
-			S_IFCHR|S_IRUSR|S_IWUSR|S_IRGRP, misc->devfs_name);
+	class = class_simple_device_add(misc_class, dev,
+					misc->dev, misc->name);
+	if (IS_ERR(class)) {
+		err = PTR_ERR(class);
+		goto out;
+	}
+
+	err = devfs_mk_cdev(dev, S_IFCHR|S_IRUSR|S_IWUSR|S_IRGRP, 
+			    misc->devfs_name);
+	if (err) {
+		class_simple_device_remove(dev);
+		goto out;
+	}
 
 	/*
 	 * Add it to the front, so that later devices can "override"
 	 * earlier defaults
 	 */
 	list_add(&misc->list, &misc_list);
+ out:
 	up(&misc_sem);
-	return 0;
+	return err;
 }
 
 /**
