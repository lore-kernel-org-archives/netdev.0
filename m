From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] bugtrap for network drivers that don't register properly.
Date: Thu, 16 Oct 2003 11:04:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031016110417.0774e1c7.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch adds checks for network devices that set there statistics pointer
after registration.  It is a common error and has already burned netdev sysfs
unregister a couple of times.  Rather than trapping it on module unload which
is infrequent and unlikely to be tested on all devices, this patch traps it
when the device is brought up.

Tested on 2.6.0-test7 by buggering the e100 driver.

diff -Nru a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	Thu Oct 16 11:00:47 2003
+++ b/include/linux/netdevice.h	Thu Oct 16 11:00:47 2003
@@ -469,6 +469,7 @@
 
 	/* class/net/name entry */
 	struct class_device	class_dev;
+	struct net_device_stats* (*last_stats)(struct net_device *);
 };
 
 #define SET_MODULE_OWNER(dev) do { } while (0)
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	Thu Oct 16 11:00:47 2003
+++ b/net/core/dev.c	Thu Oct 16 11:00:47 2003
@@ -713,6 +713,19 @@
 	return 1;
 }
 
+
+/*
+ * Some old buggy device drivers change get_stats after registering
+ * the device.  Try and trap them here.
+ * This can be elimnated when all devices are known fixed.
+ */
+static inline int get_stats_changed(struct net_device *dev)
+{
+	int changed = dev->last_stats != dev->get_stats;
+	dev->last_stats = dev->get_stats;
+	return changed;
+}
+
 /**
  *	dev_open	- prepare an interface for use.
  *	@dev:	device to open
@@ -737,6 +750,14 @@
 		return 0;
 
 	/*
+	 *	 Check for broken device drivers.
+	 */
+	if (get_stats_changed(dev) && net_ratelimit()) {
+		printk(KERN_ERR "%s: driver changed get_stats after register\n",
+		       dev->name);
+	}
+
+	/*
 	 *	Is it even present?
 	 */
 	if (!netif_device_present(dev))
@@ -753,6 +774,14 @@
 	}
 
 	/*
+	 * 	Check for more broken device drivers.
+	 */
+	if (get_stats_changed(dev) && net_ratelimit()) {
+		printk(KERN_ERR "%s: driver changed get_stats in open\n",
+		       dev->name);
+	}
+
+ 	/*
 	 *	If it went open OK then:
 	 */
 
diff -Nru a/net/core/net-sysfs.c b/net/core/net-sysfs.c
--- a/net/core/net-sysfs.c	Thu Oct 16 11:00:47 2003
+++ b/net/core/net-sysfs.c	Thu Oct 16 11:00:47 2003
@@ -419,6 +419,7 @@
 	}
 
 
+	net->last_stats = net->get_stats;
 	if (net->get_stats &&
 	    (ret = sysfs_create_group(&class_dev->kobj, &netstat_group)))
 		goto out_unreg; 
