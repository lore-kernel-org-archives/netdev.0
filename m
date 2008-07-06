From: Arjan van de Ven <arjan@infradead.org>
Subject: Printing the driver name as part of the netdev watchdog message
Date: Sun, 6 Jul 2008 13:08:01 -0700
Message-ID: <20080706130801.6bc36cf7@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51992 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755138AbYGFUH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 16:07:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave and co,

a few weeks ago you suggested to print the driver name as part of the WARN_ON for the 
watchdog timeout message; the patch below will do this.

The patch depends on the patch to add WARN(), a WARN_ON() variant taking printk arguments.
With WARN(), the actual message is part of the ==[ cut here ]== so that tools and humans
pick up the message as well when reporting the bugs.

Does this patch look like the right approach for achieving the goal?
If so... on the logistics side, how should we do this, since the WARN() patch is
not in mainline yet. I have a patch series adding it / users of it, and could just fold this patch
into that series assuming you ack the patch. Obviously I'm also open to other ways
of dealing with the logistics


From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Use WARN_ONCE() in the netdev timeout handler (and print module name)

As suggested by Dave:

This patch adds a function to get the driver name from a struct net_device,
and consequently uses this in the watchdog timeout handler to print as 
part of the message. To make this useful, use WARN_ONCE() so that the
message is part of the ===[ cut here ]=== section, meaning that people
are more likely to report it, and automated warning collection will pick it up.

Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---
 include/linux/netdevice.h |    3 +++
 net/core/dev.c            |   22 +++++++++++++++++++---
 net/sched/sch_generic.c   |    9 +++++----
 3 files changed, 27 insertions(+), 7 deletions(-)

Index: linux.trees.git/include/linux/netdevice.h
===================================================================
--- linux.trees.git.orig/include/linux/netdevice.h
+++ linux.trees.git/include/linux/netdevice.h
@@ -1514,6 +1514,9 @@ extern void dev_seq_stop(struct seq_file
 extern int netdev_class_create_file(struct class_attribute *class_attr);
 extern void netdev_class_remove_file(struct class_attribute *class_attr);
 
+extern void netdev_drivername(struct net_device *dev, char *buffer, int len);
+
+
 extern void linkwatch_run_queue(void);
 
 extern int netdev_compute_features(unsigned long all, unsigned long one);
Index: linux.trees.git/net/core/dev.c
===================================================================
--- linux.trees.git.orig/net/core/dev.c
+++ linux.trees.git/net/core/dev.c
@@ -3706,10 +3706,8 @@ static void rollback_registered(struct n
 
 	/* Some devices call without registering for initialization unwind. */
 	if (dev->reg_state == NETREG_UNINITIALIZED) {
-		printk(KERN_DEBUG "unregister_netdevice: device %s/%p never "
+		WARN(1, KERN_DEBUG "unregister_netdevice: device %s/%p never "
 				  "was registered\n", dev->name, dev);
-
-		WARN_ON(1);
 		return;
 	}
 
@@ -4554,6 +4552,24 @@ err_name:
 	return -ENOMEM;
 }
 
+void netdev_drivername(struct net_device *dev, char *buffer, int len)
+{
+	struct device_driver *driver;
+	struct device *parent;
+	if (len <= 0)
+		return;
+	buffer[0] = 0;
+
+	parent = dev->dev.parent;
+
+	if (!parent)
+		return;
+
+	driver = parent->driver;
+	if (driver && driver->name)
+		strlcpy(buffer, driver->name, len);
+}
+
 static void __net_exit netdev_exit(struct net *net)
 {
 	kfree(net->dev_name_head);
Index: linux.trees.git/net/sched/sch_generic.c
===================================================================
--- linux.trees.git.orig/net/sched/sch_generic.c
+++ linux.trees.git/net/sched/sch_generic.c
@@ -215,11 +215,12 @@ static void dev_watchdog(unsigned long a
 		    netif_carrier_ok(dev)) {
 			if (netif_queue_stopped(dev) &&
 			    time_after(jiffies, dev->trans_start + dev->watchdog_timeo)) {
-
-				printk(KERN_INFO "NETDEV WATCHDOG: %s: transmit timed out\n",
-				       dev->name);
+				char drivername[64];
+				netdev_drivername(dev, drivername, 64);
+				WARN_ONCE(1, KERN_INFO
+					"NETDEV WATCHDOG: %s (%s): transmit timed out\n",
+					dev->name, drivername);
 				dev->tx_timeout(dev);
-				WARN_ON_ONCE(1);
 			}
 			if (!mod_timer(&dev->watchdog_timer, round_jiffies(jiffies + dev->watchdog_timeo)))
 				dev_hold(dev);
