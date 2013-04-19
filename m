From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v2 net-next 3/6] bridge: Implement IFF_UNICAST_FLT.
Date: Fri, 19 Apr 2013 16:52:47 -0400
Message-ID: <1366404770-28523-4-git-send-email-vyasevic@redhat.com>
References: <1366404770-28523-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, mst@redhat.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22063 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754374Ab3DSUw4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 16:52:56 -0400
In-Reply-To: <1366404770-28523-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement IFF_UNICAST_FLT on the bridge.  Unicast addresses added
to the bridge device are synched to the uplink devices.  When the uplinks
change, current bridge device addresses are added/removed depending on
the change of the BR_UPLINK flag.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_device.c   |   17 ++++++++++++++---
 net/bridge/br_if.c       |   24 ++++++++++++++++++++++++
 net/bridge/br_netlink.c  |    3 +++
 net/bridge/br_private.h  |    1 +
 net/bridge/br_sysfs_if.c |   21 ++++++++++++++++++++-
 5 files changed, 62 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 9673128..5c3c904 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -104,8 +104,19 @@ static int br_dev_open(struct net_device *dev)
 	return 0;
 }
 
-static void br_dev_set_multicast_list(struct net_device *dev)
+static void br_dev_set_rx_mode(struct net_device *dev)
 {
+	struct net_bridge *br = netdev_priv(dev);
+	struct net_bridge_port *port;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(port, &br->port_list, list) {
+		if (port->flags & BR_UPLINK) {
+			dev_uc_sync_multiple(port->dev, dev);
+			dev_mc_sync_multiple(port->dev, dev);
+		}
+	}
+	rcu_read_unlock();
 }
 
 static int br_dev_stop(struct net_device *dev)
@@ -301,7 +312,7 @@ static const struct net_device_ops br_netdev_ops = {
 	.ndo_start_xmit		 = br_dev_xmit,
 	.ndo_get_stats64	 = br_get_stats64,
 	.ndo_set_mac_address	 = br_set_mac_address,
-	.ndo_set_rx_mode	 = br_dev_set_multicast_list,
+	.ndo_set_rx_mode	 = br_dev_set_rx_mode,
 	.ndo_change_mtu		 = br_change_mtu,
 	.ndo_do_ioctl		 = br_dev_ioctl,
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -344,7 +355,7 @@ void br_dev_setup(struct net_device *dev)
 	SET_ETHTOOL_OPS(dev, &br_ethtool_ops);
 	SET_NETDEV_DEVTYPE(dev, &br_type);
 	dev->tx_queue_len = 0;
-	dev->priv_flags = IFF_EBRIDGE;
+	dev->priv_flags = IFF_EBRIDGE | IFF_UNICAST_FLT;
 
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
 			NETIF_F_GSO_MASK | NETIF_F_HW_CSUM | NETIF_F_LLTX |
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index f17fcb3..7c74cd5 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -142,6 +142,10 @@ static void del_nbp(struct net_bridge_port *p)
 
 	nbp_vlan_flush(p);
 	br_fdb_delete_by_port(br, p, 1);
+	if (p->flags & BR_UPLINK) {
+		dev_uc_unsync(dev, br->dev);
+		dev_mc_unsync(dev, br->dev);
+	}
 
 	list_del_rcu(&p->list);
 
@@ -448,6 +452,26 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
 	return 0;
 }
 
+void br_manage_uplinks(struct net_bridge_port *p, unsigned long mask)
+{
+	struct net_bridge *br = p->br;
+
+	if (!(mask & BR_UPLINK))
+		return;
+
+	if (p->flags & BR_UPLINK) {
+		/* Newly marked uplink port.  Sync all of device addresses
+		 * to it.
+		 */
+		dev_uc_sync(p->dev, br->dev);
+		dev_mc_sync(p->dev, br->dev);
+	} else {
+		/* Uplink was unmakred.  Remove device addresses */
+		dev_uc_unsync(p->dev, br->dev);
+		dev_mc_unsync(p->dev, br->dev);
+	}
+}
+
 void __net_exit br_net_exit(struct net *net)
 {
 	struct net_device *dev;
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 1767d15..5286903 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -323,6 +323,7 @@ static void br_set_port_flag(struct net_bridge_port *p, struct nlattr *tb[],
 /* Process bridge protocol info on port */
 static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 {
+	unsigned long flags = p->flags;
 	int err;
 
 	br_set_port_flag(p, tb, IFLA_BRPORT_MODE, BR_HAIRPIN_MODE);
@@ -348,6 +349,8 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 		if (err)
 			return err;
 	}
+
+	br_manage_uplinks(p, flags ^ p->flags);
 	return 0;
 }
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index c90ec57..c43374a 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -427,6 +427,7 @@ extern int br_del_if(struct net_bridge *br,
 extern int br_min_mtu(const struct net_bridge *br);
 extern netdev_features_t br_features_recompute(struct net_bridge *br,
 	netdev_features_t features);
+extern void br_manage_uplinks(struct net_bridge_port *p, unsigned long mask);
 
 /* br_input.c */
 extern int br_handle_frame_finish(struct sk_buff *skb);
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 606362c..575ad9a 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -175,7 +175,26 @@ static BRPORT_ATTR(flush, S_IWUSR, NULL, store_flush);
 BRPORT_ATTR_FLAG(hairpin_mode, BR_HAIRPIN_MODE);
 BRPORT_ATTR_FLAG(bpdu_guard, BR_BPDU_GUARD);
 BRPORT_ATTR_FLAG(root_block, BR_ROOT_BLOCK);
-BRPORT_ATTR_FLAG(uplink, BR_UPLINK);
+
+static ssize_t show_uplink(struct net_bridge_port *p, char *buf)
+{
+	return show_flag(p, buf, BR_UPLINK);
+}
+
+static int set_uplink(struct net_bridge_port *p, unsigned long v)
+{
+	unsigned long oflags = p->flags;
+	int err;
+
+	err = store_flag(p, v, BR_UPLINK);
+
+	if (oflags != p->flags)
+		br_manage_uplinks(p, oflags ^ p->flags);
+
+	return err;
+}
+
+BRPORT_ATTR(uplink, S_IRUSR | S_IWUSR, show_uplink, set_uplink);
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 static ssize_t show_multicast_router(struct net_bridge_port *p, char *buf)
-- 
1.7.7.6
