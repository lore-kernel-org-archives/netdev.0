From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: [net-next-2.6 PATCH] allow access to sysfs_groups member
Date: Fri, 13 Nov 2009 11:51:57 +0100
Message-ID: <20091113105157.GA322@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.eia.be ([194.78.71.18]:21609 "EHLO mail.eia.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752203AbZKMKv4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 05:51:56 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In a recent post, I asked for way to hold the uevent that adds a
net_device until a driver had added some extra sysfs files.

The use-case for such thing is a (PCMCIA) CAN card, that has 2 (CAN)
network chips. The driver could add a 'channel' sysfs file that
indicates the channel on the card, but this sysfs file is not present
yet when the uevent is generated.

This patch applied to a 2.6.30 kernel did allow to use non-standard
sysfs properties in udev rules (together with a match on device/driver).

I believe the above use-case is not limited to CAN, but any other
network type.

This patch allows adding sysfs attribute groups during netdevice registration.
The idea is that before the register_netdev call, several calls to
netdev_sysfs_add_group can be done.
The existing sysfs groups that are added in netdev_register_kobject use the
same function too.
I did not touch the number of possible groups (currently still 3).

Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
---

 include/linux/netdevice.h |    2 ++
 net/core/net-sysfs.c      |   28 +++++++++++++++++++++++-----
 2 files changed, 25 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8380009..9d16687 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1115,6 +1115,8 @@ extern int		dev_open(struct net_device *dev);
 extern int		dev_close(struct net_device *dev);
 extern void		dev_disable_lro(struct net_device *dev);
 extern int		dev_queue_xmit(struct sk_buff *skb);
+extern int		netdev_sysfs_add_group(struct net_device *net,
+				struct attribute_group *grp);
 extern int		register_netdevice(struct net_device *dev);
 extern void		unregister_netdevice(struct net_device *dev);
 extern void		free_netdev(struct net_device *dev);
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 753c420..2938fdc 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -527,27 +527,45 @@ void netdev_unregister_kobject(struct net_device * net)
 	device_del(dev);
 }
 
+/* Add a sysfs group to the netdev groups */
+int netdev_sysfs_add_group(struct net_device *net,
+		struct attribute_group *grp)
+{
+	struct attribute_group **groups = net->sysfs_groups;
+	struct attribute_group **end;
+
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
+EXPORT_SYMBOL(netdev_sysfs_add_group);
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
