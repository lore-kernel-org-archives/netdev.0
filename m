From: Gertjan van Wingerde <gwingerde@home.nl>
Subject: Re: [RFC] Wireless extensions rethink
Date: Mon, 07 Jun 2004 21:51:29 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40C4C741.5040708@home.nl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030805080300000304000207"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030805080300000304000207
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Scott,

I was thinking along the same lines, however I was taking the ethtool
interface as the starting point (using a single ioctl for all wireless
operations). The private handlers would just have to be converted to
plain ioctls handled by the driver itself.

The attached patch can be used as a starting point for this.
It is not complete (not by far), but it shows the basic structure.
I've called the structure wlantool_ops, again using the example set by
ethtool.

Comments?

--- Gertjan.

On Mon, 7 Jun 2004 11:33:10 -0700 "Feldman, Scott" <scott.feldman@intel.com> wrote:
 > Jeff suggested in an earlier post that there is an opportunity to
 > totally rethink the wireless extensions now that we have wireless-2.6.
 >
 > Let's get rid of the iotcl and /proc interfaces as Jeff suggests:
 >
 > 1) iw_handler API goes away and is replaced by struct
 >    net_device::wireless_ops (ala ethtool_ops).
 > 2) sysfs get/set mapping for wireless_ops.
 > 3) iw_statistics just becomes one of the wireless_ops.
 > 4) Remove /proc/net/wireless support from wireless.c.  (Already
 >    have sysfs support for the same :)
 > 5) No private handler support.  If you need private support,
 >    pass it in some other way (custom sysfs of modparam).  Or,
 >    better yet, make a case that others could benefit and move
 >    into wireless_ops as standard.
 > 6) Convert drivers from iw_handler and iw_statistics to
 >    wireless_ops.
 > 7) Rewrite iw* tools to use sysfs interface rather than ioctl.
 >    (scriptable tools?)
 > 8) [Optional] Remove iotcl interface.  May want to keep for
 >    backward compat with legacy tools?  Easy to map between
 >    ioctl and wireless_ops in wireless.c.
 > 9) [Open] What to do about wireless events?  Any ideas?
 >
 > Proposed sysfs layout:
 >
 > 	class/
 > 	`-- net
 > 	    |-- eth[x]
 > 	        |-- wireless
 > 	            |-- statistics
 > 	            |   |-- beacon
 > 			|   |-- crypt
 > 	            |   `-- ...
 > 	            `-- control
 > 	                |-- commit
 > 	                |-- name
 > 	                |-- network_id
 > 	                |-- freq
 > 	                `-- ...
 >
 >Is someone already working on this???
 >
 >Comments?
 >
 >-scott




--------------030805080300000304000207
Content-Type: text/plain;
 name="wlantool.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="wlantool.diff"

diff -Nru a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	2004-06-07 21:29:13 +02:00
+++ b/include/linux/netdevice.h	2004-06-07 21:29:13 +02:00
@@ -41,6 +41,7 @@
 struct divert_blk;
 struct vlan_group;
 struct ethtool_ops;
+struct wlantool_ops;
 
 					/* source back-compat hooks */
 #define SET_ETHTOOL_OPS(netdev,ops) \
@@ -308,6 +309,8 @@
 
 	struct ethtool_ops *ethtool_ops;
 
+    struct wlantool_ops *wlantool_ops;
+
 	/*
 	 * This marks the end of the "visible" part of the structure. All
 	 * fields hereafter are internal to the system, and may change at
@@ -678,6 +681,7 @@
 extern int		netif_receive_skb(struct sk_buff *skb);
 extern int		dev_ioctl(unsigned int cmd, void __user *);
 extern int		dev_ethtool(struct ifreq *);
+extern int      dev_wlantool(struct ifreq *);
 extern unsigned		dev_get_flags(const struct net_device *);
 extern int		dev_change_flags(struct net_device *, unsigned);
 extern int		dev_set_mtu(struct net_device *, int);
diff -Nru a/include/linux/sockios.h b/include/linux/sockios.h
--- a/include/linux/sockios.h	2004-06-07 21:29:13 +02:00
+++ b/include/linux/sockios.h	2004-06-07 21:29:13 +02:00
@@ -83,6 +83,8 @@
 
 #define SIOCWANDEV	0x894A		/* get/set netdev parameters	*/
 
+#define SIOCWLANTOOL	0x894B		/* WLANtool interface		*/
+
 /* ARP cache control calls. */
 		    /*  0x8950 - 0x8952  * obsolete calls, don't re-use */
 #define SIOCDARP	0x8953		/* delete ARP table entry	*/
diff -Nru a/include/linux/wlantool.h b/include/linux/wlantool.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/include/linux/wlantool.h	2004-06-07 21:29:13 +02:00
@@ -0,0 +1,72 @@
+/*
+ * wlantool.h: Defines for Linux WLANtool.
+ *
+ * Copyright (C) 2004 Gertjan van Wingerde (gwingerde@home.nl)
+ */
+
+#ifndef _LINUX_WLANTOOL_H
+#define _LINUX_WLANTOOL_H
+
+#include <linux/if.h>       /* For IFNAMSIZ, etc. */
+
+/* This should work for both 32 and 64 bit userland. */
+struct wlantool_name {
+	u32	 cmd;
+    char name[IFNAMSIZ];
+};
+
+struct wlantool_param {
+    u32  cmd;
+    s32  value;
+    u8   fixed;
+    u8   disabled;
+    u16  flags;
+};
+
+struct wlantool_freq {
+    u32  cmd;
+    s32  mantissa;
+    s16  exponent;
+    u8   index;
+    u8   reserved;
+};
+
+struct wlantool_mode {
+    u32 cmd;
+    u32 mode;
+};
+
+struct net_device;
+
+/**
+ * &wlantool_ops - Alter and report network device settings
+ *
+ * Description:
+ *
+ */
+struct wlantool_ops {
+    int  (*commit)(struct net_device *);
+    void (*get_name)(struct net_device *, struct wlantool_name *);
+    int  (*get_nwid)(struct net_device *, struct wlantool_param *);
+    int  (*set_nwid)(struct net_device *, struct wlantool_param *);
+    int  (*get_freq)(struct net_device *, struct wlantool_freq *);
+    int  (*set_freq)(struct net_device *, struct wlantool_freq *);
+    int  (*get_mode)(struct net_device *, struct wlantool_mode *);
+    int  (*set_mode)(struct net_device *, struct wlantool_mode *);
+    int  (*get_sens)(struct net_device *, struct wlantool_param *);
+    int  (*set_sens)(struct net_device *, struct wlantool_param *);
+};
+
+/* CMDs currently supported */
+#define WLANTOOL_COMMIT		0x00000001 /* Commit pending changes. */
+#define WLANTOOL_GNAME		0x00000002 /* Get name (=wireless protocol). */
+#define WLANTOOL_GNWID  	0x00000003 /* Get network ID (the cell). */
+#define WLANTOOL_SNWID		0x00000004 /* Set network ID (pre-802.11). */
+#define WLANTOOL_GFREQ		0x00000005 /* Get channel/frequency (Hz). */
+#define WLANTOOL_SFREQ		0x00000006 /* Set channel/frequency (Hz). */
+#define WLANTOOL_GMODE		0x00000007 /* Get operation mode. */
+#define WLANTOOL_SMODE		0x00000008 /* Set operation mode. */
+#define WLANTOOL_GSENS   	0x00000009 /* Get sensitivity (dBm). */
+#define WLANTOOL_SSENS		0x0000000a /* Set sensitivity (dBm). */
+
+#endif /* _LINUX_WLANTOOL_H */
diff -Nru a/net/core/Makefile b/net/core/Makefile
--- a/net/core/Makefile	2004-06-07 21:29:13 +02:00
+++ b/net/core/Makefile	2004-06-07 21:29:13 +02:00
@@ -7,7 +7,8 @@
 obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
 obj-y		     += flow.o dev.o ethtool.o dev_mcast.o dst.o \
-			neighbour.o rtnetlink.o utils.o link_watch.o filter.o
+			neighbour.o rtnetlink.o utils.o link_watch.o filter.o \
+            wlantool.o
 
 obj-$(CONFIG_SYSFS) += net-sysfs.o
 obj-$(CONFIG_NETFILTER) += netfilter.o
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	2004-06-07 21:29:13 +02:00
+++ b/net/core/dev.c	2004-06-07 21:29:13 +02:00
@@ -2700,6 +2700,20 @@
 		case SIOCSIFLINK:
 			return -EINVAL;
 
+		case SIOCWLANTOOL:
+			dev_load(ifr.ifr_name);
+			rtnl_lock();
+			ret = dev_wlantool(&ifr);
+			rtnl_unlock();
+			if (!ret) {
+				if (colon)
+					*colon = ':';
+				if (copy_to_user(arg, &ifr,
+						 sizeof(struct ifreq)))
+					ret = -EFAULT;
+			}
+			return ret;
+
 		/*
 		 *	Unknown or private ioctl.
 		 */
diff -Nru a/net/core/wlantool.c b/net/core/wlantool.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/net/core/wlantool.c	2004-06-07 21:29:13 +02:00
@@ -0,0 +1,221 @@
+/*
+ * net/core/wlantool.c - WLANtool ioctl handler
+ * Copyright (c) 2004 Gertjan van Wingerde <gwingerde@home.nL>
+ *
+ * This file is where we call all the wlantool_ops commands to get
+ * the information wlantool needs.  We fall back to calling do_ioctl()
+ * for drivers which haven't been converted to wlantool_ops yet.
+ *
+ * It's GPL, stupid.
+ */
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/errno.h>
+#include <linux/wlantool.h>
+#include <linux/netdevice.h>
+#include <asm/uaccess.h>
+
+/* Handlers for each wlantool command */
+
+static int wlantool_commit(struct net_device *dev)
+{
+	int err;
+
+	if (!dev->wlantool_ops->commit)
+		return -EOPNOTSUPP;
+
+	err = dev->wlantool_ops->commit(dev);
+	if (err < 0)
+		return err;
+
+	return 0;
+}
+
+static int wlantool_get_name(struct net_device *dev, void __user *useraddr)
+{
+	struct wlantool_name name;
+
+	if (!dev->wlantool_ops->get_name)
+		return -EOPNOTSUPP;
+
+	dev->wlantool_ops->get_name(dev, &name);
+
+	if (copy_to_user(useraddr, &name, sizeof(name)))
+		return -EFAULT;
+
+    return 0;
+}
+
+static int wlantool_get_nwid(struct net_device *dev, void __user *useraddr)
+{
+	struct wlantool_param param;
+    int err;
+
+	if (!dev->wlantool_ops->get_nwid)
+		return -EOPNOTSUPP;
+
+	err = dev->wlantool_ops->get_nwid(dev, &param);
+
+	if (copy_to_user(useraddr, &param, sizeof(param)))
+		return -EFAULT;
+
+    return 0;
+}
+
+static int wlantool_set_nwid(struct net_device *dev, char __user *useraddr)
+{
+	struct wlantool_param param;
+
+	if (!dev->wlantool_ops->set_nwid)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&param, useraddr, sizeof(param)))
+		return -EFAULT;
+
+	return dev->wlantool_ops->set_nwid(dev, &param);
+}
+
+static int wlantool_get_freq(struct net_device *dev, void __user *useraddr)
+{
+	struct wlantool_freq freq;
+    int err;
+
+	if (!dev->wlantool_ops->get_freq)
+		return -EOPNOTSUPP;
+
+	err = dev->wlantool_ops->get_freq(dev, &freq);
+
+	if (copy_to_user(useraddr, &freq, sizeof(freq)))
+		return -EFAULT;
+
+    return 0;
+}
+
+static int wlantool_set_freq(struct net_device *dev, char __user *useraddr)
+{
+	struct wlantool_freq freq;
+
+	if (!dev->wlantool_ops->set_freq)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&freq, useraddr, sizeof(freq)))
+		return -EFAULT;
+
+	return dev->wlantool_ops->set_freq(dev, &freq);
+}
+
+static int wlantool_get_mode(struct net_device *dev, void __user *useraddr)
+{
+	struct wlantool_mode mode;
+    int err;
+
+	if (!dev->wlantool_ops->get_mode)
+		return -EOPNOTSUPP;
+
+	err = dev->wlantool_ops->get_mode(dev, &mode);
+
+	if (copy_to_user(useraddr, &mode, sizeof(mode)))
+		return -EFAULT;
+
+    return 0;
+}
+
+static int wlantool_set_mode(struct net_device *dev, char __user *useraddr)
+{
+	struct wlantool_mode mode;
+
+	if (!dev->wlantool_ops->set_mode)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&mode, useraddr, sizeof(mode)))
+		return -EFAULT;
+
+	return dev->wlantool_ops->set_mode(dev, &mode);
+}
+
+static int wlantool_get_sens(struct net_device *dev, void __user *useraddr)
+{
+	struct wlantool_param param;
+    int err;
+
+	if (!dev->wlantool_ops->get_sens)
+		return -EOPNOTSUPP;
+
+	err = dev->wlantool_ops->get_sens(dev, &param);
+
+	if (copy_to_user(useraddr, &param, sizeof(param)))
+		return -EFAULT;
+
+    return 0;
+}
+
+static int wlantool_set_sens(struct net_device *dev, char __user *useraddr)
+{
+	struct wlantool_param param;
+
+	if (!dev->wlantool_ops->set_sens)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&param, useraddr, sizeof(param)))
+		return -EFAULT;
+
+	return dev->wlantool_ops->set_sens(dev, &param);
+}
+
+/* The main entry point in this file.  Called from net/core/dev.c */
+
+int dev_wlantool(struct ifreq *ifr)
+{
+	struct net_device *dev = __dev_get_by_name(ifr->ifr_name);
+	void __user *useraddr = (void __user *) ifr->ifr_data;
+	u32 wlancmd;
+
+	/*
+	 * XXX: This can be pushed down into the wlantool_* handlers that
+	 * need it.  Keep existing behaviour for the moment.
+	 */
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (!dev || !netif_device_present(dev))
+		return -ENODEV;
+
+	if (!dev->wlantool_ops)
+		goto ioctl;
+
+	if (copy_from_user(&wlancmd, useraddr, sizeof (wlancmd)))
+		return -EFAULT;
+
+	switch (wlancmd) {
+	case WLANTOOL_COMMIT:
+		return wlantool_commit(dev);
+	case WLANTOOL_GNAME:
+		return wlantool_get_name(dev, useraddr);
+	case WLANTOOL_GNWID:
+		return wlantool_get_nwid(dev, useraddr);
+	case WLANTOOL_SNWID:
+		return wlantool_set_nwid(dev, useraddr);
+	case WLANTOOL_GFREQ:
+		return wlantool_get_freq(dev, useraddr);
+	case WLANTOOL_SFREQ:
+		return wlantool_set_freq(dev, useraddr);
+	case WLANTOOL_GMODE:
+		return wlantool_get_mode(dev, useraddr);
+	case WLANTOOL_SMODE:
+		return wlantool_set_mode(dev, useraddr);
+	case WLANTOOL_GSENS:
+		return wlantool_get_sens(dev, useraddr);
+	case WLANTOOL_SSENS:
+		return wlantool_set_sens(dev, useraddr);
+	default:
+		return -EOPNOTSUPP;
+	}
+
+ ioctl:
+	if (dev->do_ioctl)
+		return dev->do_ioctl(dev, ifr, SIOCWLANTOOL);
+	return -EOPNOTSUPP;
+}
+
+EXPORT_SYMBOL(dev_wlantool);

--------------030805080300000304000207--
