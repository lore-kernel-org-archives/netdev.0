From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Tue, 8 Jul 2008 18:44:56 -0700
Message-ID: <20080708184456.52e94b93@infradead.org>
References: <20080708144725.5b663d19@infradead.org>
	<20080708.145738.12692130.davem@davemloft.net>
	<20080708164826.2a2d52c2@infradead.org>
	<20080708.165304.55424424.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: swise@opengridcomputing.com, rdreier@cisco.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:36790 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381AbYGIBpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 21:45:18 -0400
In-Reply-To: <20080708.165304.55424424.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 08 Jul 2008 16:53:04 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Arjan van de Ven <arjan@infradead.org>
> Date: Tue, 8 Jul 2008 16:48:26 -0700
> 
> > On Tue, 08 Jul 2008 14:57:38 -0700 (PDT)
> > David Miller <davem@davemloft.net> wrote:
> > 
> > > What we need instead is to cache the info block into the netdev
> > > struct when the driver is ->open()'d, and then you can fetch it
> > > out of there however you like.
> > 
> > but.. isn't that like almost the same as using the object model
> > data at that point?
> 
> You're right, this is getting silly
> 
> To be honest, the more I think about this, the driver->name should
> be sufficient.
> 

ok here it is:

From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Print the module name as part of the watchdog message

As suggested by Dave:

This patch adds a function to get the driver name from a struct net_device,
and consequently uses this in the watchdog timeout handler to print as 
part of the message. 

Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---
 include/linux/netdevice.h |    2 ++
 net/core/dev.c            |   19 +++++++++++++++++++
 net/sched/sch_generic.c   |    7 ++++---
 3 files changed, 25 insertions(+), 3 deletions(-)

Index: linux.trees.git/include/linux/netdevice.h
===================================================================
--- linux.trees.git.orig/include/linux/netdevice.h
+++ linux.trees.git/include/linux/netdevice.h
@@ -1516,6 +1516,8 @@ extern void dev_seq_stop(struct seq_file
 extern int netdev_class_create_file(struct class_attribute *class_attr);
 extern void netdev_class_remove_file(struct class_attribute *class_attr);
 
+extern void netdev_drivername(struct net_device *dev, char *buffer, int len);
+
 extern void linkwatch_run_queue(void);
 
 extern int netdev_compute_features(unsigned long all, unsigned long one);
Index: linux.trees.git/net/core/dev.c
===================================================================
--- linux.trees.git.orig/net/core/dev.c
+++ linux.trees.git/net/core/dev.c
@@ -4554,6 +4554,25 @@ err_name:
 	return -ENOMEM;
 }
 
+void netdev_drivername(struct net_device *dev, char *buffer, int len)
+{
+	struct device_driver *driver;
+	struct device *parent;
+
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
@@ -215,9 +215,10 @@ static void dev_watchdog(unsigned long a
 		    netif_carrier_ok(dev)) {
 			if (netif_queue_stopped(dev) &&
 			    time_after(jiffies, dev->trans_start + dev->watchdog_timeo)) {
-
-				printk(KERN_INFO "NETDEV WATCHDOG: %s: transmit timed out\n",
-				       dev->name);
+				char drivername[64];
+				netdev_drivername(dev, drivername, 64);
+				printk(KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit timed out\n",
+				       dev->name, drivername);
 				dev->tx_timeout(dev);
 				WARN_ON_ONCE(1);
 			}
