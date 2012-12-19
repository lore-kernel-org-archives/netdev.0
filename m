From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next V3 02/13] bridge: Add vlan filtering infrastructure
Date: Wed, 19 Dec 2012 12:30:37 -0500
Message-ID: <1355938248-8407-3-git-send-email-vyasevic@redhat.com>
References: <1355938248-8407-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, davem@davemloft.net, or.gerlitz@gmail.com,
	jhs@mojatatu.com, mst@redhat.com, erdnetdev@gmail.com,
	jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21482 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755723Ab2LSRbD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2012 12:31:03 -0500
In-Reply-To: <1355938248-8407-1-git-send-email-vyasevic@redhat.com>
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
 net/bridge/br_device.c  |    3 +
 net/bridge/br_if.c      |  243 +++++++++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_private.h |   33 +++++++
 3 files changed, 279 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 7c78e26..9546742 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -332,6 +332,7 @@ static struct device_type br_type = {
 void br_dev_setup(struct net_device *dev)
 {
 	struct net_bridge *br = netdev_priv(dev);
+	int i;
 
 	eth_hw_addr_random(dev);
 	ether_setup(dev);
@@ -354,6 +355,8 @@ void br_dev_setup(struct net_device *dev)
 	spin_lock_init(&br->lock);
 	INIT_LIST_HEAD(&br->port_list);
 	spin_lock_init(&br->hash_lock);
+	for (i = 0; i < BR_VID_HASH_SIZE; i++)
+		INIT_HLIST_HEAD(&br->vlan_hlist[i]);
 
 	br->bridge_id.prio[0] = 0x80;
 	br->bridge_id.prio[1] = 0x00;
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 1c8fdc3..f7641dd6 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -83,6 +83,246 @@ void br_port_carrier_check(struct net_bridge_port *p)
 	spin_unlock_bh(&br->lock);
 }
 
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
+struct net_bridge_vlan *br_vlan_add(struct net_bridge *br, u16 vid,
+				    u16 flags)
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
+	if (flags & BRIDGE_FLAGS_SELF) {
+		/* Set bit 0 that is associated with the bridge master
+		 * device.  Port numbers start with 1.
+		 */
+		set_bit(0, vlan->port_bitmap);
+	}
+
+	hlist_add_head_rcu(&vlan->hlist, &br->vlan_hlist[br_vlan_hash(vid)]);
+	return vlan;
+}
+
+/* Must be protected by RTNL */
+static void br_vlan_del(struct net_bridge_vlan *vlan, u16 flags)
+{
+	ASSERT_RTNL();
+
+	if (flags & BRIDGE_FLAGS_SELF) {
+		/* Clear bit 0 that is associated with the bridge master
+		 * device.
+		 */
+		clear_bit(0, vlan->port_bitmap);
+	}
+
+	/* Try to remove the vlan, but only once all the ports have
+	 * been removed from the port bitmap
+	 */
+	if (!bitmap_empty(vlan->port_bitmap, PORT_BITMAP_LEN))
+		return;
+
+	vlan->vid = BR_INVALID_VID;
+
+	/* Drop the self-ref to trigger descrution. */
+	br_vlan_put(vlan);
+}
+
+/* Must be protected by RTNL */
+int br_vlan_delete(struct net_bridge *br, u16 vid, u16 flags)
+{
+	struct net_bridge_vlan *vlan;
+
+	ASSERT_RTNL();
+
+	vlan = br_vlan_find(br, vid);
+	if (!vlan)
+		return -ENOENT;
+
+	br_vlan_del(vlan, flags);
+	return 0;
+}
+
+static void br_vlan_flush(struct net_bridge *br)
+{
+	struct net_bridge_vlan *vlan;
+	struct hlist_node *node;
+	struct hlist_node *tmp;
+	int i;
+
+	/* Make sure that there are no vlans left in the bridge after
+	 * all the ports have been removed.
+	 */
+	for (i = 0; i < BR_VID_HASH_SIZE; i++) {
+		hlist_for_each_entry_safe(vlan, node, tmp,
+					  &br->vlan_hlist[i], hlist) {
+			br_vlan_del(vlan, BRIDGE_FLAGS_SELF);
+		}
+	}
+}
+
+struct net_port_vlan *nbp_vlan_find(const struct net_bridge_port *p, u16 vid)
+{
+	struct net_port_vlan *pve;
+
+	/* Must be done either in rcu critical section or with RTNL held */
+	WARN_ON_ONCE(!rcu_read_lock_held() && !rtnl_is_locked());
+
+	list_for_each_entry_rcu(pve, &p->vlan_list, list) {
+		if (pve->vid == vid)
+			return pve;
+	}
+
+	return NULL;
+}
+
+/* Must be protected by RTNL */
+int nbp_vlan_add(struct net_bridge_port *p, u16 vid, u16 flags)
+{
+	struct net_port_vlan *pve;
+	struct net_bridge_vlan *vlan;
+	struct net_device *dev = p->dev;
+	int err;
+
+	ASSERT_RTNL();
+
+	/* Find a vlan in the bridge vlan list.  If it isn't there,
+	 * create it
+	 */
+	vlan = br_vlan_add(p->br, vid, flags);
+	if (!vlan)
+		return -ENOMEM;
+
+	/* Check to see if this port is already part of the vlan.  If
+	 * it is, there is nothing more to do.
+	 */
+	if (test_bit(p->port_no, vlan->port_bitmap))
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
+	if (!vlan_hw_buggy(dev)) {
+		err = vlan_add_vid_hw(dev, vid);
+		if (err)
+			goto clean_up;
+	}
+
+	pve->vid = vid;
+	pve->vlan = vlan;
+	br_vlan_hold(vlan);
+	set_bit(p->port_no, vlan->port_bitmap);
+
+	list_add_tail_rcu(&pve->list, &p->vlan_list);
+	return 0;
+
+clean_up:
+	kfree(pve);
+	br_vlan_del(vlan, flags);
+	return err;
+}
+
+/* Must be protected by RTNL */
+int nbp_vlan_delete(struct net_bridge_port *p, u16 vid, u16 flags)
+{
+	struct net_device *dev = p->dev;
+	struct net_port_vlan *pve;
+	struct net_bridge_vlan *vlan;
+
+	ASSERT_RTNL();
+
+	pve = nbp_vlan_find(p, vid);
+	if (!pve)
+		return -ENOENT;
+
+	/* Remove VLAN from the device filter if it is supported. */
+	if (vlan_vid_del_hw(dev, vid))
+		pr_warn("failed to kill vid %d for device %s\n",
+			vid, dev->name);
+
+	pve->vid = BR_INVALID_VID;
+
+	vlan = pve->vlan;
+	pve->vlan = NULL;
+	clear_bit(p->port_no, vlan->port_bitmap);
+	br_vlan_put(vlan);
+
+	list_del_rcu(&pve->list);
+	kfree_rcu(pve, rcu);
+
+	br_vlan_del(vlan, flags);
+
+	return 0;
+}
+
+static void nbp_vlan_flush(struct net_bridge_port *p)
+{
+	struct net_port_vlan *pve;
+	struct net_port_vlan *tmp;
+
+	ASSERT_RTNL();
+
+	list_for_each_entry_safe(pve, tmp, &p->vlan_list, list)
+		nbp_vlan_delete(p, pve->vid, BRIDGE_FLAGS_SELF);
+}
+
 static void release_nbp(struct kobject *kobj)
 {
 	struct net_bridge_port *p
@@ -139,6 +379,7 @@ static void del_nbp(struct net_bridge_port *p)
 
 	br_ifinfo_notify(RTM_DELLINK, p);
 
+	nbp_vlan_flush(p);
 	br_fdb_delete_by_port(br, p, 1);
 
 	list_del_rcu(&p->list);
@@ -170,6 +411,7 @@ void br_dev_delete(struct net_device *dev, struct list_head *head)
 		del_nbp(p);
 	}
 
+	br_vlan_flush(br);
 	del_timer_sync(&br->gc_timer);
 
 	br_sysfs_delbr(br->dev);
@@ -222,6 +464,7 @@ static struct net_bridge_port *new_nbp(struct net_bridge *br,
 	p->flags = 0;
 	br_init_port(p);
 	p->state = BR_STATE_DISABLED;
+	INIT_LIST_HEAD(&p->vlan_list);
 	br_stp_port_timer_init(p);
 	br_multicast_add_port(p);
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index ae0a6ec..76d9fbc 100644
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
 
@@ -63,6 +65,27 @@ struct br_ip
 	__be16		proto;
 };
 
+#define BR_INVALID_VID	(1<<15)
+#define BR_UNTAGGED_VID (1<<14)
+
+#define BR_VID_HASH_SIZE (1<<6)
+#define br_vlan_hash(vid) ((vid) % (BR_VID_HASH_SIZE - 1))
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
+	struct net_bridge_vlan		*vlan;
+	struct rcu_head			rcu;
+	u16				vid;
+};
+
 struct net_bridge_fdb_entry
 {
 	struct hlist_node		hlist;
@@ -155,6 +178,7 @@ struct net_bridge_port
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	struct netpoll			*np;
 #endif
+	struct list_head		vlan_list;
 };
 
 #define br_port_exists(dev) (dev->priv_flags & IFF_BRIDGE_PORT)
@@ -259,6 +283,7 @@ struct net_bridge
 	struct timer_list		topology_change_timer;
 	struct timer_list		gc_timer;
 	struct kobject			*ifobj;
+	struct hlist_head		vlan_hlist[BR_VID_HASH_SIZE];
 };
 
 struct br_input_skb_cb {
@@ -400,6 +425,14 @@ extern int br_del_if(struct net_bridge *br,
 extern int br_min_mtu(const struct net_bridge *br);
 extern netdev_features_t br_features_recompute(struct net_bridge *br,
 	netdev_features_t features);
+extern struct net_bridge_vlan *br_vlan_add(struct net_bridge *br, u16 vid,
+					   u16 flags);
+extern int br_vlan_delete(struct net_bridge *br, u16 vid, u16 flags);
+extern struct net_bridge_vlan *br_vlan_find(struct net_bridge *br, u16 vid);
+extern int nbp_vlan_add(struct net_bridge_port *p, u16 vid, u16 flags);
+extern int nbp_vlan_delete(struct net_bridge_port *p, u16 vid, u16 flags);
+extern struct net_port_vlan *nbp_vlan_find(const struct net_bridge_port *p,
+					   u16 vid);
 
 /* br_input.c */
 extern int br_handle_frame_finish(struct sk_buff *skb);
-- 
1.7.7.6
