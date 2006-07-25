From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Can we have GET_NETDEV_DEV?
Date: Tue, 25 Jul 2006 10:20:05 -0700
Message-ID: <20060725102005.7edb5509@localhost.localdomain>
References: <1153803145.23803.19.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:21484 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750739AbWGYRVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2006 13:21:21 -0400
To: Pavel Roskin <proski@gnu.org>
In-Reply-To: <1153803145.23803.19.camel@dv>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 25 Jul 2006 00:52:25 -0400
Pavel Roskin <proski@gnu.org> wrote:

> Hello!
> 
> gregkh-driver-network-class_device-to-device.patch, which briefly
> appeared in Linux 2.6.18-rc1-mm1 broke MadWifi, which is copying the
> physical device information from the master network device to the
> virtual network devices:
> 
> SET_NETDEV_DEV(dev, mdev->class_dev.dev);
>

I would rather see SET_NETDEV_DEV go away. It was done for source
compatibility between 2.4 and 2.6 network device drivers. This is
no longer really important.

It would be better to either access the network device directly.
BUT, there are plans to get rid of class_dev so that would mean
source changes to all the drivers again...

So how about these wrappers.

--- a/include/linux/netdevice.h	2006-07-24 10:56:59.000000000 -0700
+++ b/include/linux/netdevice.h	2006-07-25 10:18:12.000000000 -0700
@@ -535,10 +535,23 @@
 }
 
 #define SET_MODULE_OWNER(dev) do { } while (0)
+
 /* Set the sysfs physical device reference for the network logical device
  * if set prior to registration will cause a symlink during initialization.
  */
-#define SET_NETDEV_DEV(net, pdev)	((net)->class_dev.dev = (pdev))
+static inline void netdev_set_pdev(struct net_device *dev, struct device *pdev)
+{
+	dev->class_dev.dev = pdev;
+}
+
+static inline struct device *netdev_get_pdev(struct net_device *dev)
+{
+	return dev->class_dev.dev;
+}
+
+
+/* old style macro for compatiablity */
+#define SET_NETDEV_DEV(net, pdev)	netdev_set_pdev(net, pdev)
 
 struct packet_type {
 	__be16			type;	/* This is really htons(ether_type). */
