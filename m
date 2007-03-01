From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH 2.6.20] kobject net ifindex + rename
Date: Wed, 28 Feb 2007 16:26:47 -0800
Message-ID: <20070301002647.GA7045@bougret.hpl.hp.com>
References: <20070228012741.GA3988@bougret.hpl.hp.com> <20070228153617.GA5670@suse.de>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Jarek Poplawski <jarkao2@o2.pl>,
	"David S. Miller" <davem@davemloft.net>,
	Linux kernel mailing list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Greg KH <gregkh@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932857AbXCAA3R@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070228153617.GA5670@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 28, 2007 at 07:36:17AM -0800, Greg KH wrote:
> On Tue, Feb 27, 2007 at 05:27:41PM -0800, Jean Tourrilhes wrote:
> > diff -u -p linux/drivers/base/class.j1.c linux/drivers/base/class.c
> > --- linux/drivers/base/class.j1.c	2007-02-26 18:38:10.000000000 -0800
> > +++ linux/drivers/base/class.c	2007-02-27 15:52:37.000000000 -0800
> > @@ -841,6 +841,8 @@ int class_device_rename(struct class_dev
> 
> This function is not in the 2.6.21-rc2 kernel, so you might want to
> rework this patch a bit :)

	Thanks for all you good comments. I ported my patch to
2.6.21-rc2, and tested it both on a hotplug and a udev system. Patch
is attached, I would be glad if you could push that through the usual
channels.

	Also, I realised that I forgot to say in my original e-mail
that migrating udev to use ifindex instead of ifname would fix the
remove/add race condition for network devices. But that's not going to
happen overnight...

	Have fun...

	Jean

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>

---------------------------------------------------------

diff -u -p linux/include/linux/kobject.j1.h linux/include/linux/kobject.h
--- linux/include/linux/kobject.j1.h	2007-02-28 14:26:29.000000000 -0800
+++ linux/include/linux/kobject.h	2007-02-28 14:27:54.000000000 -0800
@@ -48,6 +48,7 @@ enum kobject_action {
 	KOBJ_OFFLINE	= (__force kobject_action_t) 0x06,	/* device offline */
 	KOBJ_ONLINE	= (__force kobject_action_t) 0x07,	/* device online */
 	KOBJ_MOVE	= (__force kobject_action_t) 0x08,	/* device move */
+	KOBJ_RENAME	= (__force kobject_action_t) 0x09,	/* device renamed */
 };
 
 struct kobject {
diff -u -p linux/net/core/net-sysfs.j1.c linux/net/core/net-sysfs.c
--- linux/net/core/net-sysfs.j1.c	2007-02-28 14:26:45.000000000 -0800
+++ linux/net/core/net-sysfs.c	2007-02-28 14:27:54.000000000 -0800
@@ -424,6 +424,17 @@ static int netdev_uevent(struct device *
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
--- linux/lib/kobject_uevent.j1.c	2007-02-28 14:26:58.000000000 -0800
+++ linux/lib/kobject_uevent.c	2007-02-28 14:27:54.000000000 -0800
@@ -52,6 +52,8 @@ static char *action_to_string(enum kobje
 		return "online";
 	case KOBJ_MOVE:
 		return "move";
+	case KOBJ_RENAME:
+		return "rename";
 	default:
 		return NULL;
 	}
diff -u -p linux/drivers/base/core.j1.c linux/drivers/base/core.c
--- linux/drivers/base/core.j1.c	2007-02-28 15:45:45.000000000 -0800
+++ linux/drivers/base/core.c	2007-02-28 15:47:30.000000000 -0800
@@ -1007,6 +1007,8 @@ int device_rename(struct device *dev, ch
 	char *new_class_name = NULL;
 	char *old_symlink_name = NULL;
 	int error;
+	char *devname_string = NULL;
+	char *envp[2];
 
 	dev = get_device(dev);
 	if (!dev)
@@ -1014,6 +1016,15 @@ int device_rename(struct device *dev, ch
 
 	pr_debug("DEVICE: renaming '%s' to '%s'\n", dev->bus_id, new_name);
 
+	devname_string = kmalloc(strlen(dev->bus_id) + 15, GFP_KERNEL);
+	if (!devname_string) {
+		put_device(dev);
+		return -ENOMEM;
+	}
+	sprintf(devname_string, "INTERFACE_OLD=%s", dev->bus_id);
+	envp[0] = devname_string;
+	envp[1] = NULL;
+
 #ifdef CONFIG_SYSFS_DEPRECATED
 	if ((dev->class) && (dev->parent))
 		old_class_name = make_class_name(dev->class->name, &dev->kobj);
@@ -1049,12 +1060,20 @@ int device_rename(struct device *dev, ch
 		sysfs_create_link(&dev->class->subsys.kset.kobj, &dev->kobj,
 				  dev->bus_id);
 	}
+
+	/* This function is only used for network interface.
+	 * Some hotplug package track interfaces by their name and
+	 * therefore want to know when the name is changed by the user. */
+	if(!error)
+		kobject_uevent_env(&dev->kobj, KOBJ_RENAME, envp);
+
 	put_device(dev);
 
 	kfree(new_class_name);
 	kfree(old_symlink_name);
  out_free_old_class:
 	kfree(old_class_name);
+	kfree(devname_string);
 
 	return error;
 }
