From: Leann Ogasawara <ogasawara@osdl.org>
Subject: [PATCH 2.6.4-rc2] sysfs simple class support for netlink
Date: Thu, 04 Mar 2004 15:02:36 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1078441356.11562.18.camel@ibm-d.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Hanna Linder <hannal@us.ibm.com>, Greg KH <greg@kroah.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi All,

Patch adds sysfs simple class support for netlink character device
(Major 36).  Feedback appreciated.  Thanks,

Leann

===== net/netlink/netlink_dev.c 1.19 vs edited =====
--- 1.19/net/netlink/netlink_dev.c	Tue Aug 26 09:25:41 2003
+++ edited/net/netlink/netlink_dev.c	Thu Mar  4 12:42:44 2004
@@ -27,6 +27,7 @@
 #include <linux/init.h>
 #include <linux/devfs_fs_kernel.h>
 #include <linux/smp_lock.h>
+#include <linux/device.h>
 
 #include <asm/bitops.h>
 #include <asm/system.h>
@@ -34,6 +35,7 @@
 
 static long open_map;
 static struct socket *netlink_user[MAX_LINKS];
+static struct class_simple *netlink_class;
 
 /*
  *	Device operations
@@ -229,17 +231,26 @@
 		return -EIO;
 	}
 
+	netlink_class = class_simple_create(THIS_MODULE, "netlink");
+	if (IS_ERR(netlink_class)) {
+		printk (KERN_ERR "Error creating netlink class.\n");
+		unregister_chrdev(NETLINK_MAJOR, "netlink");
+		return PTR_ERR(netlink_class);
+	}
+
 	devfs_mk_dir("netlink");
 
 	/*  Someone tell me the official names for the uppercase ones  */
 	for (i = 0; i < ARRAY_SIZE(entries); i++) {
 		devfs_mk_cdev(MKDEV(NETLINK_MAJOR, entries[i].minor),
 			S_IFCHR|S_IRUSR|S_IWUSR, "netlink/%s", entries[i].name);
+		class_simple_device_add(netlink_class, MKDEV(NETLINK_MAJOR, entries[i].minor), NULL, "%s", entries[i].name);
 	}
 
 	for (i = 0; i < 16; i++) {
 		devfs_mk_cdev(MKDEV(NETLINK_MAJOR, i + 16),
 			S_IFCHR|S_IRUSR|S_IWUSR, "netlink/tap%d", i);
+		class_simple_device_add(netlink_class, MKDEV(NETLINK_MAJOR, i + 16), NULL, "tap%d", i);
 	}
 
 	return 0;
@@ -249,11 +260,16 @@
 {
 	int i;
 
-	for (i = 0; i < ARRAY_SIZE(entries); i++)
+	for (i = 0; i < ARRAY_SIZE(entries); i++) {
 		devfs_remove("netlink/%s", entries[i].name);
-	for (i = 0; i < 16; i++)
+		class_simple_device_remove(MKDEV(NETLINK_MAJOR, entries[i].minor));
+	}
+	for (i = 0; i < 16; i++) {
 		devfs_remove("netlink/tap%d", i);
+		class_simple_device_remove(MKDEV(NETLINK_MAJOR, i + 16));
+	}
 	devfs_remove("netlink");
+	class_simple_destroy(netlink_class);
 	unregister_chrdev(NETLINK_MAJOR, "netlink");
 }
 
