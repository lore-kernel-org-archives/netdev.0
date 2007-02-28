From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: [PATCH 2.6.20] kobject net ifindex + rename
Date: Tue, 27 Feb 2007 17:27:41 -0800
Message-ID: <20070228012741.GA3988@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Greg Kroah-Hartman <gregkh@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	Linux kernel mailing list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:63379 "EHLO madara.hpl.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750883AbXB1Bob (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 20:44:31 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Hi all,

	Various hotplug packages have had trouble dealing with network
interface being renamed. I've decided to tackle this issue from two
angles :
		o export ifindex to those apps, as ifindex is persistent.
		o expose interface renaming as a hotplug event.
	Those two changes are complementary, even an application that
would track interface by ifindex would sometime needs to know about
ifname change. My assumption is that most apps would still use ifname
for a long while to be backward compatible with older kernels.

	The kobject framework is well designed, so adding these
features is trivial change and won't run the risk of breaking anything
(famous last words). Obviously, hotplug apps are free to ignore those
additional features.
	Patch for 2.6.20 is attached. The patch was tested on a system
running the hotplug scripts, and on another system running udev.

	Have fun...

	Jean

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>

---------------------------------------------------------

diff -u -p linux/include/linux/kobject.j1.h linux/include/linux/kobject.h
--- linux/include/linux/kobject.j1.h	2007-02-26 18:37:55.000000000 -0800
+++ linux/include/linux/kobject.h	2007-02-26 18:38:42.000000000 -0800
@@ -48,6 +48,7 @@ enum kobject_action {
 	KOBJ_OFFLINE	= (__force kobject_action_t) 0x06,	/* device offline */
 	KOBJ_ONLINE	= (__force kobject_action_t) 0x07,	/* device online */
 	KOBJ_MOVE	= (__force kobject_action_t) 0x08,	/* device move */
+	KOBJ_RENAME	= (__force kobject_action_t) 0x09,	/* device renamed */
 };
 
 struct kobject {
diff -u -p linux/net/core/net-sysfs.j1.c linux/net/core/net-sysfs.c
--- linux/net/core/net-sysfs.j1.c	2007-02-27 15:01:08.000000000 -0800
+++ linux/net/core/net-sysfs.c	2007-02-27 15:06:49.000000000 -0800
@@ -412,6 +412,17 @@ static int netdev_uevent(struct class_de
 	if ((size <= 0) || (i >= num_envp))
 		return -ENOMEM;
 
+	/* pass ifindex to uevent.
+	 * ifindex is useful as it won't change (interface name may change)
+	 * and is what RtNetlink uses natively. */
+	envp[i++] = buf;
+	n = snprintf(buf, size, "IFINDEX=%d", dev->ifindex) + 1;
+	buf += n;
+	size -= n;
+
+	if ((size <= 0) || (i >= num_envp))
+		return -ENOMEM;
+
 	envp[i] = NULL;
 	return 0;
 }
diff -u -p linux/lib/kobject_uevent.j1.c linux/lib/kobject_uevent.c
--- linux/lib/kobject_uevent.j1.c	2007-02-26 18:38:02.000000000 -0800
+++ linux/lib/kobject_uevent.c	2007-02-26 18:38:42.000000000 -0800
@@ -52,6 +52,8 @@ static char *action_to_string(enum kobje
 		return "online";
 	case KOBJ_MOVE:
 		return "move";
+	case KOBJ_RENAME:
+		return "rename";
 	default:
 		return NULL;
 	}
diff -u -p linux/drivers/base/class.j1.c linux/drivers/base/class.c
--- linux/drivers/base/class.j1.c	2007-02-26 18:38:10.000000000 -0800
+++ linux/drivers/base/class.c	2007-02-27 15:52:37.000000000 -0800
@@ -841,6 +841,8 @@ int class_device_rename(struct class_dev
 {
 	int error = 0;
 	char *old_class_name = NULL, *new_class_name = NULL;
+	char *devname_string = NULL;
+	char *envp[2];
 
 	class_dev = class_device_get(class_dev);
 	if (!class_dev)
@@ -849,6 +851,15 @@ int class_device_rename(struct class_dev
 	pr_debug("CLASS: renaming '%s' to '%s'\n", class_dev->class_id,
 		 new_name);
 
+	devname_string = kmalloc(strlen(class_dev->class_id) + 15, GFP_KERNEL);
+	if (!devname_string) {
+		class_device_put(class_dev);
+		return -ENOMEM;
+	}
+	sprintf(devname_string, "INTERFACE_OLD=%s", class_dev->class_id);
+	envp[0] = devname_string;
+	envp[1] = NULL;
+
 #ifdef CONFIG_SYSFS_DEPRECATED
 	if (class_dev->dev)
 		old_class_name = make_class_name(class_dev->class->name,
@@ -868,8 +879,16 @@ int class_device_rename(struct class_dev
 		sysfs_remove_link(&class_dev->dev->kobj, old_class_name);
 	}
 #endif
+
+	/* This function is only used for network interface.
+	 * Some hotplug package track interfaces by their name and
+	 * therefore want to know when the name is changed by the user. */
+	if(!error)
+		kobject_uevent_env(&class_dev->kobj, KOBJ_RENAME, envp);
+
 	class_device_put(class_dev);
 
+	kfree(devname_string);
 	kfree(old_class_name);
 	kfree(new_class_name);
 
