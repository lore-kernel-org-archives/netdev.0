From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH 3/7] bridge: Add addresses from static fdbs to bridge address list
Date: Wed, 26 Feb 2014 10:18:21 -0500
Message-ID: <1393427905-6811-4-git-send-email-vyasevic@redhat.com>
References: <1393427905-6811-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, shemminger@vyatta.com,
	mst@redhat.com, jhs@mojatatu.com, john.r.fastabend@intel.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2747 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752659AbaBZPSt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Feb 2014 10:18:49 -0500
In-Reply-To: <1393427905-6811-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a static fdb entry is created, add the mac address to the bridge
address list.  This list is used to program the proper port's
address list.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/linux/netdevice.h |   6 +++
 net/bridge/br_device.c    |   2 +
 net/bridge/br_fdb.c       | 110 +++++++++++++++++++++++++++++++++++++++++++---
 net/bridge/br_if.c        |  14 ++++--
 net/bridge/br_private.h   |   3 ++
 net/core/dev.c            |   1 +
 net/core/dev_addr_lists.c |  14 +++---
 7 files changed, 134 insertions(+), 16 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 440a02e..e29cce1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2881,6 +2881,12 @@ int register_netdev(struct net_device *dev);
 void unregister_netdev(struct net_device *dev);
 
 /* General hardware address lists handling functions */
+int __hw_addr_add(struct netdev_hw_addr_list *list,
+		  const unsigned char *addr, int addr_len,
+		  unsigned char addr_type);
+int __hw_addr_del(struct netdev_hw_addr_list *list,
+		  const unsigned char *addr, int addr_len,
+		  unsigned char addr_type);
 int __hw_addr_sync(struct netdev_hw_addr_list *to_list,
 		   struct netdev_hw_addr_list *from_list, int addr_len);
 void __hw_addr_unsync(struct netdev_hw_addr_list *to_list,
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 63f0455..1521db6 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -100,6 +100,8 @@ static int br_dev_init(struct net_device *dev)
 		u64_stats_init(&br_dev_stats->syncp);
 	}
 
+	__hw_addr_init(&br->conf_addrs);
+
 	return 0;
 }
 
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 9203d5a..ef95e81 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -35,6 +35,9 @@ static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 static void fdb_notify(struct net_bridge *br,
 		       const struct net_bridge_fdb_entry *, int);
 
+static int br_addr_add(struct net_bridge *br, const unsigned char *addr);
+static int br_addr_del(struct net_bridge *br, const unsigned char *addr);
+
 static u32 fdb_salt __read_mostly;
 
 int __init br_fdb_init(void)
@@ -87,6 +90,9 @@ static void fdb_rcu_free(struct rcu_head *head)
 
 static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
 {
+	if (f->is_static)
+		br_addr_del(br, f->addr.addr);
+
 	hlist_del_rcu(&f->hlist);
 	fdb_notify(br, f, RTM_DELNEIGH);
 	call_rcu(&f->rcu, fdb_rcu_free);
@@ -466,6 +472,7 @@ static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		return -ENOMEM;
 
 	fdb->is_local = fdb->is_static = 1;
+	br_addr_add(br, addr);
 	fdb_notify(br, fdb, RTM_NEWNEIGH);
 	return 0;
 }
@@ -678,16 +685,29 @@ static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
 	}
 
 	if (fdb_to_nud(fdb) != state) {
-		if (state & NUD_PERMANENT)
-			fdb->is_local = fdb->is_static = 1;
-		else if (state & NUD_NOARP) {
+		if (state & NUD_PERMANENT) {
+			fdb->is_local = 1;
+			if (!fdb->is_static) {
+				fdb->is_static = 1;
+				br_addr_add(br, addr);
+			}
+		} else if (state & NUD_NOARP) {
+			fdb->is_local = 0;
+			if (!fdb->is_static) {
+				fdb->is_static = 1;
+				br_addr_add(br, addr);
+			}
+		} else {
 			fdb->is_local = 0;
-			fdb->is_static = 1;
-		} else
-			fdb->is_local = fdb->is_static = 0;
+			if (fdb->is_static) {
+				fdb->is_static = 0;
+				br_addr_del(br, addr);
+			}
+		}
 
 		modified = true;
 	}
+
 	fdb->added_by_user = 1;
 
 	fdb->used = jiffies;
@@ -874,3 +894,81 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 out:
 	return err;
 }
+
+
+/* Sync the current list to the correct flood port.  */
+void br_fdb_addrs_sync(struct net_bridge *br)
+{
+	struct net_bridge_port *p;
+	int err;
+
+	/* This function has to run under RTNL.
+	 * Program the user added addresses into the proper port.  This
+	 * fuction follows the following algorithm:
+	 *   a)  If only 1 port is flooding:
+	 *       - write all the addresses to this one port.
+	 */
+	if (br->n_flood_ports == 1) {
+		p = br->c_flood_port;
+		netif_addr_lock(p->dev);
+		err = __hw_addr_sync(&p->dev->uc, &br->conf_addrs,
+				     p->dev->addr_len);
+		if (!err)
+			__dev_set_rx_mode(p->dev);
+		netif_addr_unlock(p->dev);
+
+	}
+}
+
+void br_fdb_addrs_unsync(struct net_bridge *br)
+{
+	struct net_bridge_port *p = br->c_flood_port;
+
+	if (!p)
+		return;
+
+	netif_addr_lock(p->dev);
+	__hw_addr_unsync(&p->dev->uc, &br->conf_addrs, p->dev->addr_len);
+	__dev_set_rx_mode(p->dev);
+	netif_addr_unlock(p->dev);
+}
+
+/* When a static FDB entry is added, the mac address from the entry is
+ * added to the bridge private HW address list and all required ports
+ * are then updated with the new information.
+ * Called under RTNL.
+ */
+static int br_addr_add(struct net_bridge *br, const unsigned char *addr)
+{
+	int err;
+
+	ASSERT_RTNL();
+
+	err = __hw_addr_add(&br->conf_addrs, addr, br->dev->addr_len,
+			    NETDEV_HW_ADDR_T_UNICAST);
+
+	if (!err)
+		br_fdb_addrs_sync(br);
+
+	return err;
+}
+
+/* When a static FDB entry is deleted, the HW address from that entry is
+ * also removed from the bridge private HW address list and updates all
+ * the ports with needed information.
+ * Called under RTNL.
+ */
+static int br_addr_del(struct net_bridge *br, const unsigned char *addr)
+{
+	int err;
+
+	ASSERT_RTNL();
+
+	err = __hw_addr_del(&br->conf_addrs, addr, br->dev->addr_len,
+			    NETDEV_HW_ADDR_T_UNICAST);
+	if (!err)
+		br_fdb_addrs_sync(br);
+
+	return err;
+}
+
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index f072b34..e782c2e 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -144,7 +144,7 @@ static void del_nbp(struct net_bridge_port *p)
 
 	br_ifinfo_notify(RTM_DELLINK, p);
 
-	list_del_rcu(&p->list);
+	dev->priv_flags &= ~IFF_BRIDGE_PORT;
 
 	if (p->flags & BR_FLOOD)
 		br_del_flood_port(p, br);
@@ -152,7 +152,7 @@ static void del_nbp(struct net_bridge_port *p)
 	nbp_vlan_flush(p);
 	br_fdb_delete_by_port(br, p, 1);
 
-	dev->priv_flags &= ~IFF_BRIDGE_PORT;
+	list_del_rcu(&p->list);
 
 	netdev_rx_handler_unregister(dev);
 
@@ -473,6 +473,8 @@ static void br_add_flood_port(struct net_bridge_port *p, struct net_bridge *br)
 	br->n_flood_ports++;
 	if (br->n_flood_ports == 1)
 		br->c_flood_port = p;
+
+	br_fdb_addrs_sync(br);
 }
 
 static void br_del_flood_port(struct net_bridge_port *p, struct net_bridge *br)
@@ -485,13 +487,17 @@ static void br_del_flood_port(struct net_bridge_port *p, struct net_bridge *br)
 	 * set it if it is not set.
 	 */
 	br->n_flood_ports--;
-	if (p == br->c_flood_port)
+	if (p == br->c_flood_port) {
+		br_fdb_addrs_unsync(br);
 		br->c_flood_port = NULL;
+	}
 
 	if (br->n_flood_ports == 1) {
 		list_for_each_entry(port, &p->br->port_list, list) {
-			if (port->flags & BR_FLOOD) {
+			if (br_port_exists(port->dev) &&
+			    (port->flags & BR_FLOOD)) {
 				br->c_flood_port = port;
+				br_fdb_addrs_sync(br);
 				break;
 			}
 		}
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 26a3987..40a6927 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -296,6 +296,7 @@ struct net_bridge
 	u8				vlan_enabled;
 	struct net_port_vlans __rcu	*vlan_info;
 #endif
+	struct netdev_hw_addr_list	conf_addrs;
 };
 
 struct br_input_skb_cb {
@@ -397,6 +398,8 @@ int br_fdb_add(struct ndmsg *nlh, struct nlattr *tb[], struct net_device *dev,
 	       const unsigned char *addr, u16 nlh_flags);
 int br_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 		struct net_device *dev, int idx);
+void br_fdb_addrs_sync(struct net_bridge *br);
+void br_fdb_addrs_unsync(struct net_bridge *br);
 
 /* br_forward.c */
 void br_deliver(const struct net_bridge_port *to, struct sk_buff *skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index 4ad1b78..eca4d476 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5212,6 +5212,7 @@ void __dev_set_rx_mode(struct net_device *dev)
 	if (ops->ndo_set_rx_mode)
 		ops->ndo_set_rx_mode(dev);
 }
+EXPORT_SYMBOL(__dev_set_rx_mode);
 
 void dev_set_rx_mode(struct net_device *dev)
 {
diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index 329d579..3de44a3 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -81,13 +81,14 @@ static int __hw_addr_add_ex(struct netdev_hw_addr_list *list,
 				   sync);
 }
 
-static int __hw_addr_add(struct netdev_hw_addr_list *list,
-			 const unsigned char *addr, int addr_len,
-			 unsigned char addr_type)
+int __hw_addr_add(struct netdev_hw_addr_list *list,
+		  const unsigned char *addr, int addr_len,
+		  unsigned char addr_type)
 {
 	return __hw_addr_add_ex(list, addr, addr_len, addr_type, false, false,
 				0);
 }
+EXPORT_SYMBOL(__hw_addr_add);
 
 static int __hw_addr_del_entry(struct netdev_hw_addr_list *list,
 			       struct netdev_hw_addr *ha, bool global,
@@ -127,12 +128,13 @@ static int __hw_addr_del_ex(struct netdev_hw_addr_list *list,
 	return -ENOENT;
 }
 
-static int __hw_addr_del(struct netdev_hw_addr_list *list,
-			 const unsigned char *addr, int addr_len,
-			 unsigned char addr_type)
+int __hw_addr_del(struct netdev_hw_addr_list *list,
+		  const unsigned char *addr, int addr_len,
+		  unsigned char addr_type)
 {
 	return __hw_addr_del_ex(list, addr, addr_len, addr_type, false, false);
 }
+EXPORT_SYMBOL(__hw_addr_del);
 
 static int __hw_addr_sync_one(struct netdev_hw_addr_list *to_list,
 			       struct netdev_hw_addr *ha,
-- 
1.8.5.3
