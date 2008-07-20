From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [GIT]: Networking
Date: Sun, 20 Jul 2008 10:59:41 -0700
Message-ID: <20080720105941.77061d6a@infradead.org>
References: <20080720.104411.81744468.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33609 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757700AbYGTR7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 13:59:35 -0400
In-Reply-To: <20080720.104411.81744468.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

I noticed the patch below isn't in this (yet)
did it slip through or does it still need more work?



From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Print the module name as part of the watchdog message

As suggested by Dave:

This patch adds a function to get the driver name from a struct net_device,
and consequently uses this in the watchdog timeout handler to print as 
part of the message. 

Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---
 include/linux/netdevice.h |    2 ++
 net/core/dev.c            |   20 ++++++++++++++++++++
 net/sched/sch_generic.c   |    6 +++---
 3 files changed, 25 insertions(+), 3 deletions(-)

Index: linux.trees.git/include/linux/netdevice.h
===================================================================
--- linux.trees.git.orig/include/linux/netdevice.h
+++ linux.trees.git/include/linux/netdevice.h
@@ -1516,6 +1516,8 @@ extern void dev_seq_stop(struct seq_file
 extern int netdev_class_create_file(struct class_attribute *class_attr);
 extern void netdev_class_remove_file(struct class_attribute *class_attr);
 
+extern char *netdev_drivername(struct net_device *dev, char *buffer, int len);
+
 extern void linkwatch_run_queue(void);
 
 extern int netdev_compute_features(unsigned long all, unsigned long one);
Index: linux.trees.git/net/core/dev.c
===================================================================
--- linux.trees.git.orig/net/core/dev.c
+++ linux.trees.git/net/core/dev.c
@@ -4554,6 +4554,26 @@ err_name:
 	return -ENOMEM;
 }
 
+char *netdev_drivername(struct net_device *dev, char *buffer, int len)
+{
+	struct device_driver *driver;
+	struct device *parent;
+
+	if (len <= 0 || !buffer)
+		return buffer;
+	buffer[0] = 0;
+
+	parent = dev->dev.parent;
+
+	if (!parent)
+		return buffer;
+
+	driver = parent->driver;
+	if (driver && driver->name)
+		strlcpy(buffer, driver->name, len);
+	return buffer;
+}
+
 static void __net_exit netdev_exit(struct net *net)
 {
 	kfree(net->dev_name_head);
Index: linux.trees.git/net/sched/sch_generic.c
===================================================================
--- linux.trees.git.orig/net/sched/sch_generic.c
+++ linux.trees.git/net/sched/sch_generic.c
@@ -215,9 +215,9 @@ static void dev_watchdog(unsigned long a
 		    netif_carrier_ok(dev)) {
 			if (netif_queue_stopped(dev) &&
 			    time_after(jiffies, dev->trans_start + dev->watchdog_timeo)) {
-
-				printk(KERN_INFO "NETDEV WATCHDOG: %s: transmit timed out\n",
-				       dev->name);
+				char drivername[64];
+				printk(KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit timed out\n",
+				       dev->name, netdev_drivername(dev, drivername, 64));
 				dev->tx_timeout(dev);
 				WARN_ON_ONCE(1);
 			}
