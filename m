From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC WIP 3/5] net: bridge: Make the brX interface a member of the bridge
Date: Sat, 26 Aug 2017 22:56:08 +0200
Message-ID: <1503780970-10312-4-git-send-email-andrew@lunn.ch>
References: <1503780970-10312-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        nikolay@cumulusnetworks.com, jiri@mellanox.com,
        roopa@cumulusnetworks.com, stephen@networkplumber.org,
        bridge@lists.linux-foundation.org, Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45158 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751083AbdHZU7E (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 26 Aug 2017 16:59:04 -0400
In-Reply-To: <1503780970-10312-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to perform IGMP snooping on the brX interface, it has to be
part of the bridge, so that the code snooping on normal bridge ports
keeps track of IGMP joins and leaves.

When the brX interface is opened, add the interface to the bridge.
When the brX interface is closed, remove it from the bridge.

This port does however need some special handling. So add a bridge
port flag, BR_SOFT_INTERFACE, indicating a port is the sort interface
of the bridge.

When the port is added to the bridge, the netdev for this port cannot
be linked to the master device, since it is the master device.
Similarly when removing the port, it cannot be unlinked from the
master device.

With the brX interface now being a member of the bridge, and having
all associated structures, we can process IGMP messages sent by the
interface. This is done by the br_multicast_rcv() function, which
takes the bridge_port structure as a parameter. This cannot be easily
found, so keep track of it in the net_bridge structure.
---
 include/linux/if_bridge.h |  1 +
 net/bridge/br_device.c    | 12 ++++++++++--
 net/bridge/br_if.c        | 37 ++++++++++++++++++++++++-------------
 net/bridge/br_mdb.c       |  2 --
 net/bridge/br_multicast.c |  7 ++++---
 net/bridge/br_private.h   |  1 +
 6 files changed, 40 insertions(+), 20 deletions(-)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index 3cd18ac0697f..8a03821d1827 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -49,6 +49,7 @@ struct br_ip_list {
 #define BR_MULTICAST_TO_UNICAST	BIT(12)
 #define BR_VLAN_TUNNEL		BIT(13)
 #define BR_BCAST_FLOOD		BIT(14)
+#define BR_SOFT_INTERFACE	BIT(15)
 
 #define BR_DEFAULT_AGEING_TIME	(300 * HZ)
 
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 861ae2a165f4..f27ca62fd4a5 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -69,7 +69,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 			br_flood(br, skb, BR_PKT_MULTICAST, false, true);
 			goto out;
 		}
-		if (br_multicast_rcv(br, NULL, skb, vid)) {
+		if (br_multicast_rcv(br, br->local_port, skb, vid)) {
 			kfree_skb(skb);
 			goto out;
 		}
@@ -133,6 +133,14 @@ static void br_dev_uninit(struct net_device *dev)
 static int br_dev_open(struct net_device *dev)
 {
 	struct net_bridge *br = netdev_priv(dev);
+	int err;
+
+	err = br_add_if(br, br->dev);
+	if (err)
+		return err;
+
+	br->local_port = list_first_or_null_rcu(&br->port_list,
+						struct net_bridge_port, list);
 
 	netdev_update_features(dev);
 	netif_start_queue(dev);
@@ -161,7 +169,7 @@ static int br_dev_stop(struct net_device *dev)
 
 	netif_stop_queue(dev);
 
-	return 0;
+	return br_del_if(br, br->dev);
 }
 
 static void br_get_stats64(struct net_device *dev,
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index f3aef22931ab..49208e774191 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -284,7 +284,8 @@ static void del_nbp(struct net_bridge_port *p)
 
 	nbp_update_port_count(br);
 
-	netdev_upper_dev_unlink(dev, br->dev);
+	if (!(p->flags & BR_SOFT_INTERFACE))
+		netdev_upper_dev_unlink(dev, br->dev);
 
 	dev->priv_flags &= ~IFF_BRIDGE_PORT;
 
@@ -362,6 +363,8 @@ static struct net_bridge_port *new_nbp(struct net_bridge *br,
 	p->priority = 0x8000 >> BR_PORT_BITS;
 	p->port_no = index;
 	p->flags = BR_LEARNING | BR_FLOOD | BR_MCAST_FLOOD | BR_BCAST_FLOOD;
+	if (br->dev == dev)
+		p->flags |= BR_SOFT_INTERFACE;
 	br_init_port(p);
 	br_set_state(p, BR_STATE_DISABLED);
 	br_stp_port_timer_init(p);
@@ -500,8 +503,11 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 		return -EINVAL;
 
 	/* No bridging of bridges */
-	if (dev->netdev_ops->ndo_start_xmit == br_dev_xmit)
-		return -ELOOP;
+	if (dev->netdev_ops->ndo_start_xmit == br_dev_xmit) {
+		/* Unless it is our own soft interface */
+		if (br->dev != dev)
+			return -ELOOP;
+	}
 
 	/* Device is already being bridged */
 	if (br_port_exists(dev))
@@ -540,9 +546,11 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 
 	dev->priv_flags |= IFF_BRIDGE_PORT;
 
-	err = netdev_master_upper_dev_link(dev, br->dev, NULL, NULL);
-	if (err)
-		goto err5;
+	if (!(p->flags & BR_SOFT_INTERFACE)) {
+		err = netdev_master_upper_dev_link(dev, br->dev, NULL, NULL);
+		if (err)
+			goto err5;
+	}
 
 	err = nbp_switchdev_mark_set(p);
 	if (err)
@@ -563,13 +571,15 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	else
 		netdev_set_rx_headroom(dev, br_hr);
 
-	if (br_fdb_insert(br, p, dev->dev_addr, 0))
-		netdev_err(dev, "failed insert local address bridge forwarding table\n");
+	if (!(p->flags & BR_SOFT_INTERFACE)) {
+		if (br_fdb_insert(br, p, dev->dev_addr, 0))
+			netdev_err(dev, "failed insert local address bridge forwarding table\n");
 
-	err = nbp_vlan_init(p);
-	if (err) {
-		netdev_err(dev, "failed to initialize vlan filtering on this port\n");
-		goto err7;
+		err = nbp_vlan_init(p);
+		if (err) {
+			netdev_err(dev, "failed to initialize vlan filtering on this port\n");
+			goto err7;
+		}
 	}
 
 	spin_lock_bh(&br->lock);
@@ -597,7 +607,8 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	br_fdb_delete_by_port(br, p, 0, 1);
 	nbp_update_port_count(br);
 err6:
-	netdev_upper_dev_unlink(dev, br->dev);
+	if (!(p->flags & BR_SOFT_INTERFACE))
+		netdev_upper_dev_unlink(dev, br->dev);
 err5:
 	dev->priv_flags &= ~IFF_BRIDGE_PORT;
 	netdev_rx_handler_unregister(dev);
diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index a0b11e7d67d9..47f0d9b4221d 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -117,8 +117,6 @@ static int br_mdb_fill_info(struct sk_buff *skb, struct netlink_callback *cb,
 				struct br_mdb_entry e;
 
 				port = p->port;
-				if (!port)
-					continue;
 
 				memset(&e, 0, sizeof(e));
 				e.ifindex = port->dev->ifindex;
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index dae3af1f531a..f1bf9ec15de8 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -915,7 +915,7 @@ static void __br_multicast_send_query(struct net_bridge *br,
 	if (!skb)
 		return;
 
-	if (port) {
+	if (port && !(port->flags & BR_SOFT_INTERFACE)) {
 		skb->dev = port->dev;
 		br_multicast_count(br, port, skb, igmp_type,
 				   BR_MCAST_DIR_TX);
@@ -944,8 +944,9 @@ static void br_multicast_send_query(struct net_bridge *br,
 
 	memset(&br_group.u, 0, sizeof(br_group.u));
 
-	if (port ? (own_query == &port->ip4_own_query) :
-		   (own_query == &br->ip4_own_query)) {
+	if (port && !(port->flags & BR_SOFT_INTERFACE) ?
+	    (own_query == &port->ip4_own_query) :
+	    (own_query == &br->ip4_own_query)) {
 		other_query = &br->ip4_other_query;
 		br_group.proto = htons(ETH_P_IP);
 #if IS_ENABLED(CONFIG_IPV6)
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index fd9ee73e0a6d..c4b99a35abb0 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -296,6 +296,7 @@ struct net_bridge {
 	spinlock_t			lock;
 	spinlock_t			hash_lock;
 	struct list_head		port_list;
+	struct net_bridge_port		*local_port;
 	struct net_device		*dev;
 	struct pcpu_sw_netstats		__percpu *stats;
 	/* These fields are accessed on each packet */
-- 
2.14.1
