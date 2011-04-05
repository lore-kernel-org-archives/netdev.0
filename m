From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 6/7] bridge: allow creating bridge devices with netlink
Date: Mon, 04 Apr 2011 17:03:32 -0700
Message-ID: <20110405000537.465352687@vyatta.com>
References: <20110405000326.714524584@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42826 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750930Ab1DEAJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 20:09:50 -0400
Content-Disposition: inline; filename=br-newlink.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add netlink device ops to allow creating bridge device via netlink.
This works in a manner similar to vlan, macvlan and bonding.

Example:
  # ip link add link dev br0 type bridge
  # ip link del dev br0

The change required rearranging initializtion code to deal with
being called by create link. Most of the initialization happens
in br_dev_setup, but allocation of stats is done in ndo_init callback
to deal with allocation failure. Sysfs setup has to wait until
after the network device kobject is registered.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/bridge/br.c         |    1 
 net/bridge/br_device.c  |   41 +++++++++++++++++++++++
 net/bridge/br_if.c      |   83 ++----------------------------------------------
 net/bridge/br_netlink.c |   55 +++++++++++++++++++++++++++----
 net/bridge/br_notify.c  |    6 +++
 5 files changed, 100 insertions(+), 86 deletions(-)

--- a/net/bridge/br_device.c	2011-03-22 10:14:12.669553975 -0700
+++ b/net/bridge/br_device.c	2011-03-22 10:25:05.369243058 -0700
@@ -74,6 +74,17 @@ out:
 	return NETDEV_TX_OK;
 }
 
+static int br_dev_init(struct net_device *dev)
+{
+	struct net_bridge *br = netdev_priv(dev);
+
+	br->stats = alloc_percpu(struct br_cpu_netstats);
+	if (!br->stats)
+		return -ENOMEM;
+
+	return 0;
+}
+
 static int br_dev_open(struct net_device *dev)
 {
 	struct net_bridge *br = netdev_priv(dev);
@@ -334,6 +345,7 @@ static const struct ethtool_ops br_ethto
 static const struct net_device_ops br_netdev_ops = {
 	.ndo_open		 = br_dev_open,
 	.ndo_stop		 = br_dev_stop,
+	.ndo_init		 = br_dev_init,
 	.ndo_start_xmit		 = br_dev_xmit,
 	.ndo_get_stats64	 = br_get_stats64,
 	.ndo_set_mac_address	 = br_set_mac_address,
@@ -357,18 +369,47 @@ static void br_dev_free(struct net_devic
 	free_netdev(dev);
 }
 
+static struct device_type br_type = {
+	.name	= "bridge",
+};
+
 void br_dev_setup(struct net_device *dev)
 {
+	struct net_bridge *br = netdev_priv(dev);
+
 	random_ether_addr(dev->dev_addr);
 	ether_setup(dev);
 
 	dev->netdev_ops = &br_netdev_ops;
 	dev->destructor = br_dev_free;
 	SET_ETHTOOL_OPS(dev, &br_ethtool_ops);
+	SET_NETDEV_DEVTYPE(dev, &br_type);
 	dev->tx_queue_len = 0;
 	dev->priv_flags = IFF_EBRIDGE;
 
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
 			NETIF_F_GSO_MASK | NETIF_F_NO_CSUM | NETIF_F_LLTX |
 			NETIF_F_NETNS_LOCAL | NETIF_F_GSO | NETIF_F_HW_VLAN_TX;
+
+	br->dev = dev;
+	spin_lock_init(&br->lock);
+	INIT_LIST_HEAD(&br->port_list);
+	spin_lock_init(&br->hash_lock);
+
+	br->bridge_id.prio[0] = 0x80;
+	br->bridge_id.prio[1] = 0x00;
+
+	memcpy(br->group_addr, br_group_address, ETH_ALEN);
+
+	br->feature_mask = dev->features;
+	br->stp_enabled = BR_NO_STP;
+	br->designated_root = br->bridge_id;
+	br->bridge_max_age = br->max_age = 20 * HZ;
+	br->bridge_hello_time = br->hello_time = 2 * HZ;
+	br->bridge_forward_delay = br->forward_delay = 15 * HZ;
+	br->ageing_time = 300 * HZ;
+
+	br_netfilter_rtable_init(br);
+	br_stp_timer_init(br);
+	br_multicast_init(br);
 }
--- a/net/bridge/br_netlink.c	2011-03-22 10:25:01.057042585 -0700
+++ b/net/bridge/br_netlink.c	2011-03-22 10:25:05.369243058 -0700
@@ -12,9 +12,11 @@
 
 #include <linux/kernel.h>
 #include <linux/slab.h>
+#include <linux/etherdevice.h>
 #include <net/rtnetlink.h>
 #include <net/net_namespace.h>
 #include <net/sock.h>
+
 #include "br_private.h"
 
 static inline size_t br_nlmsg_size(void)
@@ -188,24 +190,61 @@ static int br_rtm_setlink(struct sk_buff
 	return 0;
 }
 
+static int br_validate(struct nlattr *tb[], struct nlattr *data[])
+{
+	if (tb[IFLA_ADDRESS]) {
+		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
+			return -EINVAL;
+		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
+			return -EADDRNOTAVAIL;
+	}
+
+	return 0;
+}
+
+static struct rtnl_link_ops br_link_ops __read_mostly = {
+	.kind		= "bridge",
+	.priv_size	= sizeof(struct net_bridge),
+	.setup		= br_dev_setup,
+	.validate	= br_validate,
+};
 
 int __init br_netlink_init(void)
 {
-	if (__rtnl_register(PF_BRIDGE, RTM_GETLINK, NULL, br_dump_ifinfo))
-		return -ENOBUFS;
+	int err;
 
-	/* Only the first call to __rtnl_register can fail */
-	__rtnl_register(PF_BRIDGE, RTM_SETLINK, br_rtm_setlink, NULL);
+	err = rtnl_link_register(&br_link_ops);
+	if (err < 0)
+		goto err1;
 
-	__rtnl_register(PF_BRIDGE, RTM_NEWNEIGH, br_fdb_add, NULL);
-	__rtnl_register(PF_BRIDGE, RTM_DELNEIGH, br_fdb_delete, NULL);
-	__rtnl_register(PF_BRIDGE, RTM_GETNEIGH, NULL, br_fdb_dump);
+	err = __rtnl_register(PF_BRIDGE, RTM_GETLINK, NULL, br_dump_ifinfo);
+	if (err)
+		goto err2;
+	err = __rtnl_register(PF_BRIDGE, RTM_SETLINK, br_rtm_setlink, NULL);
+	if (err)
+		goto err3;
+	err = __rtnl_register(PF_BRIDGE, RTM_NEWNEIGH, br_fdb_add, NULL);
+	if (err)
+		goto err3;
+	err = __rtnl_register(PF_BRIDGE, RTM_DELNEIGH, br_fdb_delete, NULL);
+	if (err)
+		goto err3;
+	err = __rtnl_register(PF_BRIDGE, RTM_GETNEIGH, NULL, br_fdb_dump);
+	if (err)
+		goto err3;
 
 	return 0;
+
+err3:
+	rtnl_unregister_all(PF_BRIDGE);
+err2:
+	rtnl_link_unregister(&br_link_ops);
+err1:
+	return err;
 }
 
 void __exit br_netlink_fini(void)
 {
+	rtnl_link_unregister(&br_link_ops);
 	rtnl_unregister_all(PF_BRIDGE);
 }
-
--- a/net/bridge/br_if.c	2011-03-22 10:24:50.420524900 -0700
+++ b/net/bridge/br_if.c	2011-03-22 10:25:05.369243058 -0700
@@ -175,56 +175,6 @@ static void del_br(struct net_bridge *br
 	unregister_netdevice_queue(br->dev, head);
 }
 
-static struct net_device *new_bridge_dev(struct net *net, const char *name)
-{
-	struct net_bridge *br;
-	struct net_device *dev;
-
-	dev = alloc_netdev(sizeof(struct net_bridge), name,
-			   br_dev_setup);
-
-	if (!dev)
-		return NULL;
-	dev_net_set(dev, net);
-
-	br = netdev_priv(dev);
-	br->dev = dev;
-
-	br->stats = alloc_percpu(struct br_cpu_netstats);
-	if (!br->stats) {
-		free_netdev(dev);
-		return NULL;
-	}
-
-	spin_lock_init(&br->lock);
-	INIT_LIST_HEAD(&br->port_list);
-	spin_lock_init(&br->hash_lock);
-
-	br->bridge_id.prio[0] = 0x80;
-	br->bridge_id.prio[1] = 0x00;
-
-	memcpy(br->group_addr, br_group_address, ETH_ALEN);
-
-	br->feature_mask = dev->features;
-	br->stp_enabled = BR_NO_STP;
-	br->designated_root = br->bridge_id;
-	br->root_path_cost = 0;
-	br->root_port = 0;
-	br->bridge_max_age = br->max_age = 20 * HZ;
-	br->bridge_hello_time = br->hello_time = 2 * HZ;
-	br->bridge_forward_delay = br->forward_delay = 15 * HZ;
-	br->topology_change = 0;
-	br->topology_change_detected = 0;
-	br->ageing_time = 300 * HZ;
-
-	br_netfilter_rtable_init(br);
-
-	br_stp_timer_init(br);
-	br_multicast_init(br);
-
-	return dev;
-}
-
 /* find an available port number */
 static int find_portno(struct net_bridge *br)
 {
@@ -277,42 +227,19 @@ static struct net_bridge_port *new_nbp(s
 	return p;
 }
 
-static struct device_type br_type = {
-	.name	= "bridge",
-};
-
 int br_add_bridge(struct net *net, const char *name)
 {
 	struct net_device *dev;
-	int ret;
 
-	dev = new_bridge_dev(net, name);
+	dev = alloc_netdev(sizeof(struct net_bridge), name,
+			   br_dev_setup);
+
 	if (!dev)
 		return -ENOMEM;
 
-	rtnl_lock();
-	if (strchr(dev->name, '%')) {
-		ret = dev_alloc_name(dev, dev->name);
-		if (ret < 0)
-			goto out_free;
-	}
-
-	SET_NETDEV_DEVTYPE(dev, &br_type);
+	dev_net_set(dev, net);
 
-	ret = register_netdevice(dev);
-	if (ret)
-		goto out_free;
-
-	ret = br_sysfs_addbr(dev);
-	if (ret)
-		unregister_netdevice(dev);
- out:
-	rtnl_unlock();
-	return ret;
-
-out_free:
-	free_netdev(dev);
-	goto out;
+	return register_netdev(dev);
 }
 
 int br_del_bridge(struct net *net, const char *name)
--- a/net/bridge/br.c	2011-03-22 10:13:27.074313779 -0700
+++ b/net/bridge/br.c	2011-03-22 10:25:05.369243058 -0700
@@ -104,3 +104,4 @@ module_init(br_init)
 module_exit(br_deinit)
 MODULE_LICENSE("GPL");
 MODULE_VERSION(BR_VERSION);
+MODULE_ALIAS_RTNL_LINK("bridge");
--- a/net/bridge/br_notify.c	2011-03-22 10:13:27.090305095 -0700
+++ b/net/bridge/br_notify.c	2011-03-22 10:25:05.369243058 -0700
@@ -36,6 +36,12 @@ static int br_device_event(struct notifi
 	struct net_bridge *br;
 	int err;
 
+	/* register of bridge completed, add sysfs entries */
+	if ((dev->priv_flags && IFF_EBRIDGE) && event == NETDEV_REGISTER) {
+		br_sysfs_addbr(dev);
+		return NOTIFY_DONE;
+	}
+
 	/* not a port of a bridge */
 	p = br_port_get_rtnl(dev);
 	if (!p)


