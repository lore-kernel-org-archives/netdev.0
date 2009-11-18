From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: Re: [net-next-2.6 PATCH v2] allow access to sysfs_groups member
Date: Wed, 18 Nov 2009 17:41:26 +0100
Message-ID: <20091118164126.GF325@e-circ.dyndns.org>
References: <20091114165408.GA283@e-circ.dyndns.org> <20091116084612.3654bdd1@nehalam> <20091118154313.GE325@e-circ.dyndns.org> <20091118.080849.196755366.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.eia.be ([194.78.71.18]:40283 "EHLO mail.eia.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755835AbZKRQlX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2009 11:41:23 -0500
Content-Disposition: inline
In-Reply-To: <20091118.080849.196755366.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows adding sysfs attribute groups during netdevice registration.
The idea is that before the register_netdev call, several calls to
netdev_sysfs_add_group can be done. These attributes are accessible (by
udev) during the uevent.

Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
---
 include/linux/netdevice.h |    2 ++
 net/core/net-sysfs.c      |   29 ++++++++++++++++++++++++-----
 2 files changed, 26 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8380009..ebfc789 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1115,6 +1115,8 @@ extern int                dev_open(struct net_device *dev);
 extern int             dev_close(struct net_device *dev);
 extern void            dev_disable_lro(struct net_device *dev);
 extern int             dev_queue_xmit(struct sk_buff *skb);
+extern int             netdev_sysfs_add_group(struct net_device *net,
+                               const struct attribute_group *grp);
 extern int             register_netdevice(struct net_device *dev);
 extern void            unregister_netdevice(struct net_device *dev);
 extern void            free_netdev(struct net_device *dev);
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 753c420..6451e9a 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -527,27 +527,46 @@ void netdev_unregister_kobject(struct net_device * net)
        device_del(dev);
 }

+/* Add a sysfs group to the netdev groups */
+int netdev_sysfs_add_group(struct net_device *net,
+               const struct attribute_group *grp)
+{
+       struct attribute_group **groups = net->sysfs_groups;
+       struct attribute_group **end;
+
+       BUG_ON(net->reg_state >= NETREG_REGISTERED);
+       /* end pointer, with room for null terminator */
+       end = &net->sysfs_groups[ARRAY_SIZE(net->sysfs_groups) - 1];
+       for (; groups < end; ++groups) {
+               if (!*groups) {
+                       *groups = grp;
+                       return 0;
+               }
+       }
+       return -ENOSPC;
+}
+EXPORT_SYMBOL_GPL(netdev_sysfs_add_group);
+
 /* Create sysfs entries for network device. */
 int netdev_register_kobject(struct net_device *net)
 {
        struct device *dev = &(net->dev);
-       const struct attribute_group **groups = net->sysfs_groups;

        dev->class = &net_class;
        dev->platform_data = net;
-       dev->groups = groups;
+       dev->groups = net->sysfs_groups;

        dev_set_name(dev, "%s", net->name);

 #ifdef CONFIG_SYSFS
-       *groups++ = &netstat_group;
+       netdev_sysfs_add_group(net, &netstat_group);

 #ifdef CONFIG_WIRELESS_EXT_SYSFS
        if (net->ieee80211_ptr)
-               *groups++ = &wireless_group;
+               netdev_sysfs_add_group(net, &wireless_group);
 #ifdef CONFIG_WIRELESS_EXT
        else if (net->wireless_handlers)
-               *groups++ = &wireless_group;
+               netdev_sysfs_add_group(net, &wireless_group);
 #endif
 #endif
 #endif /* CONFIG_SYSFS */

