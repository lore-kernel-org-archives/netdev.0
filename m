From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Wed, 9 Jul 2008 10:56:31 -0700
Message-ID: <20080709105631.492f86bd@infradead.org>
References: <20080708144725.5b663d19@infradead.org>
	<20080708.145738.12692130.davem@davemloft.net>
	<20080708164826.2a2d52c2@infradead.org>
	<20080708.165304.55424424.davem@davemloft.net>
	<20080708184456.52e94b93@infradead.org>
	<20080708201658.2c496b6a@speedy>
	<1215624055.5553.252.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	swise@opengridcomputing.com, rdreier@cisco.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:34989 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751852AbYGIR4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 13:56:49 -0400
In-Reply-To: <1215624055.5553.252.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 09 Jul 2008 10:20:55 -0700
Joe Perches <joe@perches.com> wrote:

> On Tue, 2008-07-08 at 20:16 -0700, Stephen Hemminger wrote:
> > > +void netdev_drivername(struct net_device *dev, char *buffer, int
> > > len)
> > void netdev_drivername(const struct net_device *dev, char *buffer,
> > int len) since net device not changed.
> 
> char *netdev_drivername(const struct net_dev *dev, char *buffer,
> size_t len)
> 
> size_t len and returns *buffer
> 
> allows:
> 
> 	char drivername[64];
>         printk(KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit timed
> out\n", dev->name, netdev_drivername(dev, drivername,
> sizeof(drivername));

I like the return a char * (updated patch below)
I don't like the size_t... size_t is an abstraction to deal with file
sizes.... but there's nothing else wrong with using an int for numbers.
thanks for the suggestion


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
