From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 3/6] net: introduce vlan_vid_[add/del] and use them instead of direct [add/kill]_vid ndo calls
Date: Thu,  8 Dec 2011 15:11:17 +0100
Message-ID: <1323353480-1900-4-git-send-email-jpirko@redhat.com>
References: <1323353480-1900-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	ebiederm@xmission.com, mirqus@gmail.com, kaber@trash.net,
	greearb@candelatech.com, jesse@nicira.com, fubar@us.ibm.com,
	andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7298 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751404Ab1LHOLr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 09:11:47 -0500
In-Reply-To: <1323353480-1900-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds wrapper for ndo_vlan_rx_add_vid/ndo_vlan_rx_kill_vid
functions. Check for NETIF_F_HW_VLAN_FILTER feature is done in this
wrapper.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bonding/bond_main.c |   53 +++++++++++++++++----------------------
 drivers/net/macvlan.c           |   10 ++-----
 drivers/net/team/team.c         |   34 +++++++++++++++---------
 include/linux/if_vlan.h         |   12 +++++++++
 net/8021q/vlan.c                |   14 +++------
 net/8021q/vlan_core.c           |   23 +++++++++++++++++
 6 files changed, 87 insertions(+), 59 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d72c37f..0c0dacb 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -431,17 +431,13 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
 static int bond_vlan_rx_add_vid(struct net_device *bond_dev, uint16_t vid)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
-	struct slave *slave;
+	struct slave *slave, *stop_at;
 	int i, res;
 
 	bond_for_each_slave(bond, slave, i) {
-		struct net_device *slave_dev = slave->dev;
-		const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
-
-		if ((slave_dev->features & NETIF_F_HW_VLAN_FILTER) &&
-		    slave_ops->ndo_vlan_rx_add_vid) {
-			slave_ops->ndo_vlan_rx_add_vid(slave_dev, vid);
-		}
+		res = vlan_vid_add(slave->dev, vid);
+		if (res)
+			goto unwind;
 	}
 
 	res = bond_add_vlan(bond, vid);
@@ -452,6 +448,14 @@ static int bond_vlan_rx_add_vid(struct net_device *bond_dev, uint16_t vid)
 	}
 
 	return 0;
+
+unwind:
+	/* unwind from head to the slave that failed */
+	stop_at = slave;
+	bond_for_each_slave_from_to(bond, slave, i, bond->first_slave, stop_at)
+		vlan_vid_del(slave->dev, vid);
+
+	return res;
 }
 
 /**
@@ -465,15 +469,8 @@ static int bond_vlan_rx_kill_vid(struct net_device *bond_dev, uint16_t vid)
 	struct slave *slave;
 	int i, res;
 
-	bond_for_each_slave(bond, slave, i) {
-		struct net_device *slave_dev = slave->dev;
-		const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
-
-		if ((slave_dev->features & NETIF_F_HW_VLAN_FILTER) &&
-		    slave_ops->ndo_vlan_rx_kill_vid) {
-			slave_ops->ndo_vlan_rx_kill_vid(slave_dev, vid);
-		}
-	}
+	bond_for_each_slave(bond, slave, i)
+		vlan_vid_del(slave->dev, vid);
 
 	res = bond_del_vlan(bond, vid);
 	if (res) {
@@ -488,30 +485,26 @@ static int bond_vlan_rx_kill_vid(struct net_device *bond_dev, uint16_t vid)
 static void bond_add_vlans_on_slave(struct bonding *bond, struct net_device *slave_dev)
 {
 	struct vlan_entry *vlan;
-	const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
-
-	if (!(slave_dev->features & NETIF_F_HW_VLAN_FILTER) ||
-	    !(slave_ops->ndo_vlan_rx_add_vid))
-		return;
+	int res;
 
-	list_for_each_entry(vlan, &bond->vlan_list, vlan_list)
-		slave_ops->ndo_vlan_rx_add_vid(slave_dev, vlan->vlan_id);
+	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
+		res = vlan_vid_add(slave_dev, vlan->vlan_id);
+		if (res)
+			pr_warning("%s: Failed to add vlan id %d to device %s\n",
+				   bond->dev->name, vlan->vlan_id,
+				   slave_dev->name);
+	}
 }
 
 static void bond_del_vlans_from_slave(struct bonding *bond,
 				      struct net_device *slave_dev)
 {
-	const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
 	struct vlan_entry *vlan;
 
-	if (!(slave_dev->features & NETIF_F_HW_VLAN_FILTER) ||
-	    !(slave_ops->ndo_vlan_rx_kill_vid))
-		return;
-
 	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 		if (!vlan->vlan_id)
 			continue;
-		slave_ops->ndo_vlan_rx_kill_vid(slave_dev, vlan->vlan_id);
+		vlan_vid_del(slave_dev, vlan->vlan_id);
 	}
 }
 
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 2511bc5..f2f820c 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -26,6 +26,7 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/if_arp.h>
+#include <linux/if_vlan.h>
 #include <linux/if_link.h>
 #include <linux/if_macvlan.h>
 #include <net/rtnetlink.h>
@@ -525,11 +526,8 @@ static int macvlan_vlan_rx_add_vid(struct net_device *dev,
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct net_device *lowerdev = vlan->lowerdev;
-	const struct net_device_ops *ops = lowerdev->netdev_ops;
 
-	if (ops->ndo_vlan_rx_add_vid)
-		return ops->ndo_vlan_rx_add_vid(lowerdev, vid);
-	return 0;
+	return vlan_vid_add(lowerdev, vid);
 }
 
 static int macvlan_vlan_rx_kill_vid(struct net_device *dev,
@@ -537,10 +535,8 @@ static int macvlan_vlan_rx_kill_vid(struct net_device *dev,
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct net_device *lowerdev = vlan->lowerdev;
-	const struct net_device_ops *ops = lowerdev->netdev_ops;
 
-	if (ops->ndo_vlan_rx_kill_vid)
-		return ops->ndo_vlan_rx_kill_vid(lowerdev, vid);
+	vlan_vid_del(lowerdev, vid);
 	return 0;
 }
 
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 8e8bf95..79c2d1b 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -18,6 +18,7 @@
 #include <linux/ctype.h>
 #include <linux/notifier.h>
 #include <linux/netdevice.h>
+#include <linux/if_vlan.h>
 #include <linux/if_arp.h>
 #include <linux/socket.h>
 #include <linux/etherdevice.h>
@@ -906,17 +907,28 @@ static int team_vlan_rx_add_vid(struct net_device *dev, uint16_t vid)
 {
 	struct team *team = netdev_priv(dev);
 	struct team_port *port;
+	int err;
 
-	rcu_read_lock();
-	list_for_each_entry_rcu(port, &team->port_list, list) {
-		const struct net_device_ops *ops = port->dev->netdev_ops;
-
-		if (ops->ndo_vlan_rx_add_vid)
-			ops->ndo_vlan_rx_add_vid(port->dev, vid);
+	/*
+	 * Alhough this is reader, it's guarded by team lock. It's not possible
+	 * to traverse list in reverse under rcu_read_lock
+	 */
+	mutex_lock(&team->lock);
+	list_for_each_entry(port, &team->port_list, list) {
+		err = vlan_vid_add(port->dev, vid);
+		if (err)
+			goto unwind;
 	}
-	rcu_read_unlock();
+	mutex_unlock(&team->lock);
 
 	return 0;
+
+unwind:
+	list_for_each_entry_continue_reverse(port, &team->port_list, list)
+		vlan_vid_del(port->dev, vid);
+	mutex_unlock(&team->lock);
+
+	return err;
 }
 
 static int team_vlan_rx_kill_vid(struct net_device *dev, uint16_t vid)
@@ -925,12 +937,8 @@ static int team_vlan_rx_kill_vid(struct net_device *dev, uint16_t vid)
 	struct team_port *port;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(port, &team->port_list, list) {
-		const struct net_device_ops *ops = port->dev->netdev_ops;
-
-		if (ops->ndo_vlan_rx_kill_vid)
-			ops->ndo_vlan_rx_kill_vid(port->dev, vid);
-	}
+	list_for_each_entry_rcu(port, &team->port_list, list)
+		vlan_vid_del(port->dev, vid);
 	rcu_read_unlock();
 
 	return 0;
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 31d7c97..71168a6 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -109,6 +109,9 @@ extern u16 vlan_dev_vlan_id(const struct net_device *dev);
 extern bool vlan_do_receive(struct sk_buff **skb, bool last_handler);
 extern struct sk_buff *vlan_untag(struct sk_buff *skb);
 
+extern int vlan_vid_add(struct net_device *dev, unsigned short vid);
+extern void vlan_vid_del(struct net_device *dev, unsigned short vid);
+
 #else
 static inline struct net_device *
 __vlan_find_dev_deep(struct net_device *real_dev, u16 vlan_id)
@@ -139,6 +142,15 @@ static inline struct sk_buff *vlan_untag(struct sk_buff *skb)
 {
 	return skb;
 }
+
+static inline int vlan_vid_add(struct net_device *dev, unsigned short vid)
+{
+	return 0;
+}
+
+static inline void vlan_vid_del(struct net_device *dev, unsigned short vid)
+{
+}
 #endif
 
 /**
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index e075625..dd9aa40 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -101,7 +101,6 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 {
 	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	struct net_device *real_dev = vlan->real_dev;
-	const struct net_device_ops *ops = real_dev->netdev_ops;
 	struct vlan_group *grp;
 	u16 vlan_id = vlan->vlan_id;
 
@@ -114,8 +113,8 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 	 * HW accelerating devices or SW vlan input packet processing if
 	 * VLAN is not 0 (leave it there for 802.1p).
 	 */
-	if (vlan_id && (real_dev->features & NETIF_F_HW_VLAN_FILTER))
-		ops->ndo_vlan_rx_kill_vid(real_dev, vlan_id);
+	if (vlan_id)
+		vlan_vid_del(real_dev, vlan_id);
 
 	grp->nr_vlans--;
 
@@ -169,7 +168,6 @@ int register_vlan_dev(struct net_device *dev)
 {
 	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	struct net_device *real_dev = vlan->real_dev;
-	const struct net_device_ops *ops = real_dev->netdev_ops;
 	u16 vlan_id = vlan->vlan_id;
 	struct vlan_group *grp, *ngrp = NULL;
 	int err;
@@ -207,8 +205,7 @@ int register_vlan_dev(struct net_device *dev)
 	if (ngrp) {
 		rcu_assign_pointer(real_dev->vlgrp, ngrp);
 	}
-	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
-		ops->ndo_vlan_rx_add_vid(real_dev, vlan_id);
+	vlan_vid_add(real_dev, vlan_id);
 
 	return 0;
 
@@ -369,11 +366,10 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		__vlan_device_event(dev, event);
 
 	if ((event == NETDEV_UP) &&
-	    (dev->features & NETIF_F_HW_VLAN_FILTER) &&
-	    dev->netdev_ops->ndo_vlan_rx_add_vid) {
+	    (dev->features & NETIF_F_HW_VLAN_FILTER)) {
 		pr_info("adding VLAN 0 to HW filter on device %s\n",
 			dev->name);
-		dev->netdev_ops->ndo_vlan_rx_add_vid(dev, 0);
+		vlan_vid_add(dev, 0);
 	}
 
 	grp = rtnl_dereference(dev->vlgrp);
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 85241f0..544f9cb 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -146,3 +146,26 @@ err_free:
 	kfree_skb(skb);
 	return NULL;
 }
+
+int vlan_vid_add(struct net_device *dev, unsigned short vid)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if ((dev->features & NETIF_F_HW_VLAN_FILTER) &&
+	     ops->ndo_vlan_rx_add_vid) {
+		return ops->ndo_vlan_rx_add_vid(dev, vid);
+	}
+	return 0;
+}
+EXPORT_SYMBOL(vlan_vid_add);
+
+void vlan_vid_del(struct net_device *dev, unsigned short vid)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if ((dev->features & NETIF_F_HW_VLAN_FILTER) &&
+	     ops->ndo_vlan_rx_kill_vid) {
+		ops->ndo_vlan_rx_kill_vid(dev, vid);
+	}
+}
+EXPORT_SYMBOL(vlan_vid_del);
-- 
1.7.6
