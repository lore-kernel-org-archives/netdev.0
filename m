From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: [RFC][PATCH 2.6.19 take2 5/5] add "add" element in /sys/class/misc/netconsole
Date: Thu, 21 Dec 2006 19:13:49 +0900
Message-ID: <458A5E5D.4020505@bx.jp.nec.com>
References: <458A5AAE.30209@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:64736 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422939AbWLUKN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Dec 2006 05:13:59 -0500
To: mpm@selenic.com
In-Reply-To: <458A5AAE.30209@bx.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Keiichi KII <k-keiichi@bx.jp.nec.com>

This patch contains the following changes.

To add port dynamically, create "add" element in /sys/class/misc/netconsole.

ex)
   echo "@/eth0,@192.168.0.1/" > /sys/class/misc/netconsole/add
   then the port is added with the settings sending kernel messages
   to 192.168.0.1 using eth0 device.

-+- /sys/class/misc/
 |-+- netconsole/
   |--- add       [-w-------]  If you write parameter(network interface name
   |                           or one config parameter of netconsole), The
   |                            port related its config is added
   |--- port1/
   |--- port2/
   ...

Signed-off-by: Keiichi KII <k-keiichi@bx.jp.nec.com>
---
[changes]
1. remove unneccesary cast.
2. change config parameter for "add" element.

--- linux-2.6.19/drivers/net/netconsole.c	2006-12-21 18:39:12.719185750 +0900
+++ enhanced-netconsole/drivers/net/netconsole.c.add	2006-12-21 18:39:05.046706250 +0900
@@ -338,6 +338,30 @@ static struct miscdevice netconsole_misc
 	.name = "netconsole",
 };
 
+static ssize_t store_miscdev_add(struct class_device *cdev,
+					const char *buf, size_t count)
+{
+	char *target_param;
+
+	target_param = kmalloc(count+1, GFP_KERNEL);
+	if (!target_param) {
+		printk(KERN_ERR "netconsole: kmalloc() failed!\n");
+		return -ENOMEM;
+	}
+
+	strcpy(target_param, buf);
+	if (target_param[count - 1] == '\n')
+		target_param[count - 1] = '\0';
+
+	printk(KERN_INFO "netconsole: config = [%s]\n", target_param);
+	add_target(target_param);
+	kfree(target_param);
+
+	return count;
+}
+
+static CLASS_DEVICE_ATTR(add, S_IWUSR, NULL, store_miscdev_add);
+
 static struct netpoll np = {
 	.name = "netconsole",
 	.dev_name = "eth0",
@@ -467,6 +491,9 @@ static int __init init_netconsole(void)
 
 	register_console(&netconsole);
 
+	class_device_create_file(netconsole_miscdev.class,
+				 &class_device_attr_add);
+
 	if(!strlen(config)) {
 		printk(KERN_ERR "netconsole: not configured\n");
 		return 0;

-- 
Keiichi KII
NEC Corporation OSS Promotion Center
E-mail: k-keiichi@bx.jp.nec.com
