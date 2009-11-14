From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: [net-next-2.6 PATCH v2] allow access to sysfs_groups member
Date: Sat, 14 Nov 2009 17:54:09 +0100
Message-ID: <20091114165408.GA283@e-circ.dyndns.org>
References: <20091113105157.GA322@e-circ.dyndns.org> <20091113142738.1aa81a03@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay010.isp.belgacom.be ([195.238.6.177]:28703 "EHLO
	mailrelay010.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752905AbZKNQyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2009 11:54:05 -0500
Content-Disposition: inline
In-Reply-To: <20091113142738.1aa81a03@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2009 at 02:27:38PM -0800, Stephen Hemminger wrote:
> On Fri, 13 Nov 2009 11:51:57 +0100
> Kurt Van Dijck <kurt.van.dijck@eia.be> wrote:
[...]
> EXPORT_SYMBOL_GPL() for all device/sysfs related stuff.
Ok, no problem
> 
> Also, need some way to BUG() if this is done after device has
> been registered.  
Ok. I gave it a try. I _think_ I did it write, but a second look would
not harm :-). I was not able to run a real test yet.
> 
> Another way to add sub-directories which is what bridge, bonding,
> and others do is to use another kobject. I think this is what you
> want for the case of two CAN objects under one netdevice.
In fact, I wanted to add this for cards that have multiple seperate CAN
network device, combined on 1 PCI or PCMCIA device.
In the 'add network' uevent, a udev rule could find properties of the
card (device/ symlink). Right now, there is no way to tell if a network
device is bus 1 or 2 on the card. in CAN, there's no such thing as a MAC
address.
I encountered this issue with a softing CAN card (not yet in mainline),
and there are other drivers in the socketCAN queue that have the same
problem.

The ethernet cards with multiple busses (that I've seen yet :-) )
combine multiple PCI devices on 1 card, and identification of the
'instance on the card' can happen with the sysfs properties delivered by
the PCI bus.
CAN devices with multiple busses typically are combined all together on
1 single device on the PCI or PCMCIA bus.

So, I wanted to add a 'channel' property in /sys/class/net/canX, which
could indicate the instance on the device. Such property must be
installed by the driver, not the bus the device is on.
This patch allows me to have this channel property present at the moment
of the uevent.

I can imagine other subsystems may benefit from this too.

Regards,
Kurt Van Dijck
---

This patch allows adding sysfs attribute groups during netdevice registration.
The idea is that before the register_netdev call, several calls to
netdev_sysfs_add_group can be done.

Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
---
 include/linux/netdevice.h |    2 ++
 net/core/net-sysfs.c      |   29 ++++++++++++++++++++++++-----
 2 files changed, 26 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8380009..ebfc789 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1115,6 +1115,8 @@ extern int		dev_open(struct net_device *dev);
 extern int		dev_close(struct net_device *dev);
 extern void		dev_disable_lro(struct net_device *dev);
 extern int		dev_queue_xmit(struct sk_buff *skb);
+extern int		netdev_sysfs_add_group(struct net_device *net,
+				const struct attribute_group *grp);
 extern int		register_netdevice(struct net_device *dev);
 extern void		unregister_netdevice(struct net_device *dev);
 extern void		free_netdev(struct net_device *dev);
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 753c420..6451e9a 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -527,27 +527,46 @@ void netdev_unregister_kobject(struct net_device * net)
 	device_del(dev);
 }
 
+/* Add a sysfs group to the netdev groups */
+int netdev_sysfs_add_group(struct net_device *net,
+		const struct attribute_group *grp)
+{
+	struct attribute_group **groups = net->sysfs_groups;
+	struct attribute_group **end;
+
+	BUG_ON(net->reg_state >= NETREG_REGISTERED);
+	/* end pointer, with room for null terminator */
+	end = &net->sysfs_groups[ARRAY_SIZE(net->sysfs_groups) - 1];
+	for (; groups < end; ++groups) {
+		if (!*groups) {
+			*groups = grp;
+			return 0;
+		}
+	}
+	return -ENOSPC;
+}
+EXPORT_SYMBOL_GPL(netdev_sysfs_add_group);
+
 /* Create sysfs entries for network device. */
 int netdev_register_kobject(struct net_device *net)
 {
 	struct device *dev = &(net->dev);
-	const struct attribute_group **groups = net->sysfs_groups;
 
 	dev->class = &net_class;
 	dev->platform_data = net;
-	dev->groups = groups;
+	dev->groups = net->sysfs_groups;
 
 	dev_set_name(dev, "%s", net->name);
 
 #ifdef CONFIG_SYSFS
-	*groups++ = &netstat_group;
+	netdev_sysfs_add_group(net, &netstat_group);
 
 #ifdef CONFIG_WIRELESS_EXT_SYSFS
 	if (net->ieee80211_ptr)
-		*groups++ = &wireless_group;
+		netdev_sysfs_add_group(net, &wireless_group);
 #ifdef CONFIG_WIRELESS_EXT
 	else if (net->wireless_handlers)
-		*groups++ = &wireless_group;
+		netdev_sysfs_add_group(net, &wireless_group);
 #endif
 #endif
 #endif /* CONFIG_SYSFS */
