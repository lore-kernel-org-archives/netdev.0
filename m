From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Mon, 7 Jul 2008 08:23:51 -0700
Message-ID: <20080707082351.0cf77eda@infradead.org>
References: <20080706213427.406e8f29@infradead.org>
	<20080706.214915.255106355.davem@davemloft.net>
	<20080706215711.135a8524@infradead.org>
	<20080706.234433.172895242.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51955 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753133AbYGGPXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 11:23:53 -0400
In-Reply-To: <20080706.234433.172895242.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 06 Jul 2008 23:44:33 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Arjan van de Ven <arjan@infradead.org>
> Date: Sun, 6 Jul 2008 21:57:11 -0700
> 
> > one option is that I carry this patch in the WARN tree (which I
> > plan to submit for -next tomorrow)
> 
> It's going to be a conflict field day with net-next-2.6 especially
> with some changes I have coming in there soon, otherwise I'd say
> that yes that would be the way to do.

ok

if you merge the piece below (which is just the core), I can do the WARN()
part later when the dust has settled (it's a one liner anyway pretty much)

--

From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Print the driver name as part of the WATCHDOG message

As suggested by Dave:

This patch adds a function to get the driver name from a struct net_device,
and consequently uses this in the watchdog timeout handler to print as 
part of the message. 

Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---
 include/linux/netdevice.h |    3 +++
 net/core/dev.c            |   37 +++++++++++++++++++++++++++++++++++++
 net/sched/sch_generic.c   |    7 ++++---
 3 files changed, 44 insertions(+), 3 deletions(-)

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
@@ -4554,6 +4554,43 @@ err_name:
 	return -ENOMEM;
 }
 
+void netdev_drivername(struct net_device *dev, char *buffer, int len)
+{
+	struct device_driver *driver;
+	struct device *parent;
+	struct ethtool_drvinfo info;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+
+	if (len <= 0)
+		return;
+	buffer[0] = 0;
+
+	/*
+	 * Note: in principle ethtool ops need to be called
+	 * with the RTNL mutex held, while this function is called
+	 * from IRQ context. However, get_drvinfo is a special exception
+	 * (confirmed by Dave and Jeff) and doesn't need the mutex.
+	 */
+	if (ops && ops->get_drvinfo) {
+		memset(&info, 0, sizeof(info));
+		info.cmd = ETHTOOL_GDRVINFO;
+		ops->get_drvinfo(dev, &info);
+		if (strlen(info.driver) > 0) {
+			strlcpy(buffer, info.driver, len);
+			return;
+		}
+	}
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
