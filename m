From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next V6 02/14] bridge: Add vlan filtering infrastructure
Date: Wed, 16 Jan 2013 13:17:57 -0500
Message-ID: <1358360289-23249-3-git-send-email-vyasevic@redhat.com>
References: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	shemminger@vyatta.com, mst@redhat.com, shmulik.ladkani@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6302 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755583Ab3APSSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 13:18:16 -0500
In-Reply-To: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an infrastructure patch.  It adds 2 structures types:
  net_bridge_vlan - list element of all vlans that have been configured
                    on the bridge.
  net_port_vlan - list element of all vlans configured on a specific port.
                  references net_bridge_vlan.

In this implementation, bridge has a hash list of all vlans that have
been added to the bridge.  Each vlan element holds a vid and port_bitmap
where each port sets its bit if a given vlan is added to the port.

Each port has its own list of vlans.  Each element here refrences a vlan
from the bridge list.

Write access to both lists is protected by RTNL, and read access is
protected by RCU.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/Kconfig      |   14 +++
 net/bridge/Makefile     |    2 +
 net/bridge/br_device.c  |    5 +
 net/bridge/br_if.c      |    4 +
 net/bridge/br_private.h |   95 ++++++++++++++++++++
 net/bridge/br_vlan.c    |  223 +++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 343 insertions(+), 0 deletions(-)
 create mode 100644 net/bridge/br_vlan.c

diff --git a/net/bridge/Kconfig b/net/bridge/Kconfig
index 6dee7bf..c0283c1 100644
--- a/net/bridge/Kconfig
+++ b/net/bridge/Kconfig
@@ -46,3 +46,17 @@ config BRIDGE_IGMP_SNOOPING
 	  Say N to exclude this support and reduce the binary size.
 
 	  If unsure, say Y.
+
+config BRIDGE_VLAN_FILTERING
+	bool "VLAN filtering"
+	depends on BRIDGE
+	depends on VLAN_8021Q
+	default y
+	---help---
+	  If you say Y here, then the Ethernet bridge will be able selectively
+	  receive and forward traffic based on VLAN information in the packet
+	  any VLAN information configured on the bridge port or bridge device.
+
+	  Say N to exclude this support and reduce the binary size.
+
+	  If unsure, say Y.
diff --git a/net/bridge/Makefile b/net/bridge/Makefile
index e859098..e85498b2f 100644
--- a/net/bridge/Makefile
+++ b/net/bridge/Makefile
@@ -14,4 +14,6 @@ bridge-$(CONFIG_BRIDGE_NETFILTER) += br_netfilter.o
 
 bridge-$(CONFIG_BRIDGE_IGMP_SNOOPING) += br_multicast.o br_mdb.o
 
+bridge-$(CONFIG_BRIDGE_VLAN_FILTERING) += br_vlan.o
+
 obj-$(CONFIG_BRIDGE_NF_EBTABLES) += netfilter/
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index e1bc090..b64b5c8 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -331,6 +331,7 @@ static struct device_type br_type = {
 void br_dev_setup(struct net_device *dev)
 {
 	struct net_bridge *br = netdev_priv(dev);
+	int i;
 
 	eth_hw_addr_random(dev);
 	ether_setup(dev);
@@ -353,6 +354,8 @@ void br_dev_setup(struct net_device *dev)
 	spin_lock_init(&br->lock);
 	INIT_LIST_HEAD(&br->port_list);
 	spin_lock_init(&br->hash_lock);
+	for (i = 0; i < BR_VID_HASH_SIZE; i++)
+		INIT_HLIST_HEAD(&br->vlan_hlist[i]);
 
 	br->bridge_id.prio[0] = 0x80;
 	br->bridge_id.prio[1] = 0x00;
@@ -367,6 +370,8 @@ void br_dev_setup(struct net_device *dev)
 	br->bridge_hello_time = br->hello_time = 2 * HZ;
 	br->bridge_forward_delay = br->forward_delay = 15 * HZ;
 	br->ageing_time = 300 * HZ;
+	br->vlan_info.port_idx = 0;
+	INIT_LIST_HEAD(&br->vlan_info.vlan_list);
 
 	br_netfilter_rtable_init(br);
 	br_stp_timer_init(br);
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 2148d47..2427a21 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -139,6 +139,7 @@ static void del_nbp(struct net_bridge_port *p)
 
 	br_ifinfo_notify(RTM_DELLINK, p);
 
+	nbp_vlan_flush(&p->vlan_info);
 	br_fdb_delete_by_port(br, p, 1);
 
 	list_del_rcu(&p->list);
@@ -170,6 +171,7 @@ void br_dev_delete(struct net_device *dev, struct list_head *head)
 		del_nbp(p);
 	}
 
+	br_vlan_flush(br);
 	del_timer_sync(&br->gc_timer);
 
 	br_sysfs_delbr(br->dev);
@@ -222,6 +224,8 @@ static struct net_bridge_port *new_nbp(struct net_bridge *br,
 	p->flags = 0;
 	br_init_port(p);
 	p->state = BR_STATE_DISABLED;
+	p->vlan_info.port_idx = index;
+	INIT_LIST_HEAD(&p->vlan_info.vlan_list);
 	br_stp_port_timer_init(p);
 	br_multicast_add_port(p);
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 8d83be5..615f10c 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -18,6 +18,7 @@
 #include <linux/netpoll.h>
 #include <linux/u64_stats_sync.h>
 #include <net/route.h>
+#include <linux/if_vlan.h>
 
 #define BR_HASH_BITS 8
 #define BR_HASH_SIZE (1 << BR_HASH_BITS)
@@ -26,6 +27,7 @@
 
 #define BR_PORT_BITS	10
 #define BR_MAX_PORTS	(1<<BR_PORT_BITS)
+#define PORT_BITMAP_LEN	BITS_TO_LONGS(BR_MAX_PORTS)
 
 #define BR_VERSION	"2.3"
 
@@ -63,6 +65,31 @@ struct br_ip
 	__be16		proto;
 };
 
+#define BR_INVALID_VID	(1<<15)
+
+#define BR_VID_HASH_SIZE (1<<6)
+#define br_vlan_hash(vid) ((vid) & (BR_VID_HASH_SIZE - 1))
+
+struct net_bridge_vlan {
+	struct hlist_node		hlist;
+	atomic_t			refcnt;
+	struct rcu_head			rcu;
+	u16				vid;
+	unsigned long			port_bitmap[PORT_BITMAP_LEN];
+};
+
+struct net_port_vlan {
+	struct list_head		list;
+	struct net_bridge_vlan __rcu	*vlan;
+	struct rcu_head			rcu;
+	u16				vid;
+};
+
+struct net_port_vlans {
+	u16				port_idx;
+	struct list_head		vlan_list;
+};
+
 struct net_bridge_fdb_entry
 {
 	struct hlist_node		hlist;
@@ -156,6 +183,7 @@ struct net_bridge_port
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	struct netpoll			*np;
 #endif
+	struct net_port_vlans		vlan_info;
 };
 
 #define br_port_exists(dev) (dev->priv_flags & IFF_BRIDGE_PORT)
@@ -174,6 +202,16 @@ static inline struct net_bridge_port *br_port_get_rtnl(struct net_device *dev)
 		rtnl_dereference(dev->rx_handler_data) : NULL;
 }
 
+static inline struct net_bridge_port *vlans_to_port(struct net_port_vlans *vlans)
+{
+	struct net_bridge_port *p = NULL;
+
+	if (vlans->port_idx)
+		p = container_of((vlans), struct net_bridge_port, vlan_info);
+
+	return p;
+}
+
 struct br_cpu_netstats {
 	u64			rx_packets;
 	u64			rx_bytes;
@@ -260,8 +298,22 @@ struct net_bridge
 	struct timer_list		topology_change_timer;
 	struct timer_list		gc_timer;
 	struct kobject			*ifobj;
+	struct hlist_head		vlan_hlist[BR_VID_HASH_SIZE];
+	struct net_port_vlans		vlan_info;
 };
 
+static inline struct net_bridge *vlans_to_bridge(struct net_port_vlans *vlans)
+{
+	struct net_bridge *br;
+
+	if (!vlans->port_idx)
+		br = container_of((vlans), struct net_bridge, vlan_info);
+	else
+		br = vlans_to_port(vlans)->br;
+
+	return br;
+}
+
 struct br_input_skb_cb {
 	struct net_device *brdev;
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
@@ -528,6 +580,49 @@ static inline bool br_multicast_is_router(struct net_bridge *br)
 }
 #endif
 
+/* br_vlan.c */
+#ifdef CONFIG_BRIDGE_VLAN_FILTERING
+extern struct net_bridge_vlan *br_vlan_find(struct net_bridge *br, u16 vid);
+extern void br_vlan_flush(struct net_bridge *br);
+extern int nbp_vlan_add(struct net_port_vlans *v, u16 vid);
+extern int nbp_vlan_delete(struct net_port_vlans *v, u16 vid);
+extern struct net_port_vlan *nbp_vlan_find(const struct net_port_vlans *v,
+					   u16 vid);
+extern void nbp_vlan_flush(struct net_port_vlans *vlans);
+#else
+static inline struct net_bridge_vlan *br_vlan_find(struct net_bridge *br,
+						   u16 vid)
+{
+	return NULL;
+}
+
+static inline void br_vlan_flush(struct net_bridge *br)
+{
+}
+
+static inline int nbp_vlan_add(struct net_port_vlans *v, u16 vid)
+{
+	return -EINVAL;
+}
+
+static inline int nbp_vlan_delete(struct net_port_vlans *v, u16 vid)
+{
+	return -EINVAL;
+}
+
+static inline struct net_port_vlan *nbp_vlan_find(
+					   const struct net_port_vlans *v,
+					   u16 vid)
+{
+	return NULL;
+}
+
+static inline void nbp_vlan_flush(struct net_port_vlans *vlans)
+{
+}
+
+#endif
+
 /* br_netfilter.c */
 #ifdef CONFIG_BRIDGE_NETFILTER
 extern int br_netfilter_init(void);
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
new file mode 100644
index 0000000..816e85e
--- /dev/null
+++ b/net/bridge/br_vlan.c
@@ -0,0 +1,223 @@
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/rtnetlink.h>
+#include <linux/slab.h>
+
+#include "br_private.h"
+
+static void br_vlan_destroy(struct net_bridge_vlan *vlan)
+{
+	if (!bitmap_empty(vlan->port_bitmap, PORT_BITMAP_LEN)) {
+		pr_err("Attempt to delete a VLAN %d from the bridge with "
+		       "non-empty port bitmap (%p)\n", vlan->vid, vlan);
+		BUG();
+	}
+
+	hlist_del_rcu(&vlan->hlist);
+	kfree_rcu(vlan, rcu);
+}
+
+static void br_vlan_hold(struct net_bridge_vlan *vlan)
+{
+	atomic_inc(&vlan->refcnt);
+}
+
+static void br_vlan_put(struct net_bridge_vlan *vlan)
+{
+	if (atomic_dec_and_test(&vlan->refcnt))
+		br_vlan_destroy(vlan);
+}
+
+struct net_bridge_vlan *br_vlan_find(struct net_bridge *br, u16 vid)
+{
+	struct net_bridge_vlan *vlan;
+	struct hlist_node *node;
+
+	hlist_for_each_entry_rcu(vlan, node,
+				 &br->vlan_hlist[br_vlan_hash(vid)], hlist) {
+		if (vlan->vid == vid)
+			return vlan;
+	}
+
+	return NULL;
+}
+
+/* Must be protected by RTNL */
+static struct net_bridge_vlan *br_vlan_add(struct net_bridge *br, u16 vid)
+{
+	struct net_bridge_vlan *vlan;
+
+	ASSERT_RTNL();
+
+	vlan = br_vlan_find(br, vid);
+	if (vlan)
+		return vlan;
+
+	vlan = kzalloc(sizeof(struct net_bridge_vlan), GFP_KERNEL);
+	if (!vlan)
+		return NULL;
+
+	vlan->vid = vid;
+	atomic_set(&vlan->refcnt, 1);
+
+	hlist_add_head_rcu(&vlan->hlist, &br->vlan_hlist[br_vlan_hash(vid)]);
+	return vlan;
+}
+
+/* Must be protected by RTNL */
+static void br_vlan_del(struct net_bridge_vlan *vlan)
+{
+	ASSERT_RTNL();
+
+	/* Try to remove the vlan, but only once all the ports have
+	 * been removed from the port bitmap
+	 */
+	if (!bitmap_empty(vlan->port_bitmap, PORT_BITMAP_LEN))
+		return;
+
+	vlan->vid = BR_INVALID_VID;
+
+	/* Drop the self-ref to trigger destruction. */
+	br_vlan_put(vlan);
+}
+
+void br_vlan_flush(struct net_bridge *br)
+{
+	struct net_bridge_vlan *vlan;
+	struct hlist_node *node;
+	struct hlist_node *tmp;
+	int i;
+
+	nbp_vlan_flush(&br->vlan_info);
+
+	/* Make sure that there are no vlans left in the bridge after
+	* all the ports have been removed.
+	*/
+	for (i = 0; i < BR_VID_HASH_SIZE; i++) {
+		hlist_for_each_entry_safe(vlan, node, tmp,
+					  &br->vlan_hlist[i], hlist) {
+			br_vlan_del(vlan);
+		}
+	}
+}
+
+struct net_port_vlan *nbp_vlan_find(const struct net_port_vlans *v, u16 vid)
+{
+	struct net_port_vlan *pve;
+
+	/* Must be done either in rcu critical section or with RTNL held */
+	WARN_ON_ONCE(!rcu_read_lock_held() && !rtnl_is_locked());
+
+	list_for_each_entry_rcu(pve, &v->vlan_list, list) {
+		if (pve->vid == vid)
+			return pve;
+	}
+
+	return NULL;
+}
+
+/* Must be protected by RTNL */
+int nbp_vlan_add(struct net_port_vlans *v, u16 vid)
+{
+	struct net_port_vlan *pve = NULL;
+	struct net_bridge_vlan *vlan;
+	struct net_bridge *br = vlans_to_bridge(v);
+	struct net_bridge_port *p = vlans_to_port(v);
+	int err;
+
+	ASSERT_RTNL();
+
+	/* Find a vlan in the bridge vlan list.  If it isn't there,
+	 * create it
+	 */
+	vlan = br_vlan_add(br, vid);
+	if (!vlan)
+		return -ENOMEM;
+
+	/* Check to see if this port is already part of the vlan.  If
+	 * it is, there is nothing more to do.
+	 */
+	if (test_bit(v->port_idx, vlan->port_bitmap))
+		return -EEXIST;
+
+	/* Create port vlan, link it to bridge vlan list, and add port the
+	 * portgroup.
+	 */
+	pve = kmalloc(sizeof(*pve), GFP_KERNEL);
+	if (!pve) {
+		err = -ENOMEM;
+		goto clean_up;
+	}
+
+	/* Add VLAN to the device filter if it is supported.
+	 * Stricly speaking, this is not necessary now, since devices
+	 * are made promiscuous by the bridge, but if that ever changes
+	 * this code will allow tagged traffic to enter the bridge.
+	 */
+	if (p && !vlan_hw_buggy(p->dev)) {
+		err = vlan_vid_add_hw(p->dev, vid);
+		if (err)
+			goto clean_up;
+	}
+
+	pve->vid = vid;
+	rcu_assign_pointer(pve->vlan, vlan);
+	br_vlan_hold(vlan);
+	set_bit(v->port_idx, vlan->port_bitmap);
+
+	list_add_tail_rcu(&pve->list, &v->vlan_list);
+	return 0;
+
+clean_up:
+	kfree(pve);
+	br_vlan_del(vlan);
+	return err;
+}
+
+/* Must be protected by RTNL */
+int nbp_vlan_delete(struct net_port_vlans *v, u16 vid)
+{
+	struct net_port_vlan *pve;
+	struct net_bridge_vlan *vlan;
+
+	ASSERT_RTNL();
+
+	pve = nbp_vlan_find(v, vid);
+	if (!pve)
+		return -ENOENT;
+
+	if (v->port_idx) {
+		/* A valid port index means this is a port.
+		 * Remove VLAN from the port device filter if it is supported.
+		 */
+		struct net_device *dev = vlans_to_port(v)->dev;
+
+		if (vlan_vid_del_hw(dev, vid))
+			pr_warn("failed to kill vid %d for device %s\n",
+				vid, dev->name);
+	}
+	pve->vid = BR_INVALID_VID;
+
+	vlan = rtnl_dereference(pve->vlan);
+	rcu_assign_pointer(pve->vlan, NULL);
+	clear_bit(v->port_idx, vlan->port_bitmap);
+	br_vlan_put(vlan);
+
+	list_del_rcu(&pve->list);
+	kfree_rcu(pve, rcu);
+
+	br_vlan_del(vlan);
+
+	return 0;
+}
+
+void nbp_vlan_flush(struct net_port_vlans *vlans)
+{
+	struct net_port_vlan *pve;
+	struct net_port_vlan *tmp;
+
+	ASSERT_RTNL();
+
+	list_for_each_entry_safe(pve, tmp, &vlans->vlan_list, list)
+		nbp_vlan_delete(vlans, pve->vid);
+}
-- 
1.7.7.6
