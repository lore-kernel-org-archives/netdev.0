From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 44/47] bonding: do vlan cleanup
Date: Wed, 20 Jul 2011 16:54:46 +0200
Message-ID: <1311173689-17419-45-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com,
	fubar@us.ibm.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52274 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752474Ab1GTO4d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:56:33 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now when all devices are cleaned up, bond can be cleaned up as well

- remove bond->vlgrp
- remove bond_vlan_rx_register
- substitute necessary occurences of vlan_group_get_device

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bonding/bond_alb.c  |    4 +-
 drivers/net/bonding/bond_ipv6.c |    8 ++--
 drivers/net/bonding/bond_main.c |   98 +++++++++------------------------------
 drivers/net/bonding/bonding.h   |    6 ++-
 4 files changed, 33 insertions(+), 83 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 2df9276..7f8b20a 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -635,7 +635,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 			client_info->ntt = 0;
 		}
 
-		if (bond->vlgrp) {
+		if (bond_vlan_used(bond)) {
 			if (!vlan_get_tag(skb, &client_info->vlan_id))
 				client_info->tag = 1;
 		}
@@ -847,7 +847,7 @@ static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[])
 		skb->priority = TC_PRIO_CONTROL;
 		skb->dev = slave->dev;
 
-		if (bond->vlgrp) {
+		if (bond_vlan_used(bond)) {
 			struct vlan_entry *vlan;
 
 			vlan = bond_next_vlan(bond,
diff --git a/drivers/net/bonding/bond_ipv6.c b/drivers/net/bonding/bond_ipv6.c
index 84fbd4e..027a0ee 100644
--- a/drivers/net/bonding/bond_ipv6.c
+++ b/drivers/net/bonding/bond_ipv6.c
@@ -183,10 +183,10 @@ static int bond_inet6addr_event(struct notifier_block *this,
 		}
 
 		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
-			if (!bond->vlgrp)
-				continue;
-			vlan_dev = vlan_group_get_device(bond->vlgrp,
-							 vlan->vlan_id);
+			rcu_read_lock();
+			vlan_dev = __vlan_find_dev_deep(bond->dev,
+							vlan->vlan_id);
+			rcu_read_unlock();
 			if (vlan_dev == event_dev) {
 				switch (event) {
 				case NETDEV_UP:
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 61265f7..d5542d3 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -408,9 +408,8 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
 }
 
 /*
- * In the following 3 functions, bond_vlan_rx_register(), bond_vlan_rx_add_vid
- * and bond_vlan_rx_kill_vid, We don't protect the slave list iteration with a
- * lock because:
+ * In the following 2 functions, bond_vlan_rx_add_vid and bond_vlan_rx_kill_vid,
+ * We don't protect the slave list iteration with a lock because:
  * a. This operation is performed in IOCTL context,
  * b. The operation is protected by the RTNL semaphore in the 8021q code,
  * c. Holding a lock with BH disabled while directly calling a base driver
@@ -426,33 +425,6 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
 */
 
 /**
- * bond_vlan_rx_register - Propagates registration to slaves
- * @bond_dev: bonding net device that got called
- * @grp: vlan group being registered
- */
-static void bond_vlan_rx_register(struct net_device *bond_dev,
-				  struct vlan_group *grp)
-{
-	struct bonding *bond = netdev_priv(bond_dev);
-	struct slave *slave;
-	int i;
-
-	write_lock_bh(&bond->lock);
-	bond->vlgrp = grp;
-	write_unlock_bh(&bond->lock);
-
-	bond_for_each_slave(bond, slave, i) {
-		struct net_device *slave_dev = slave->dev;
-		const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
-
-		if ((slave_dev->features & NETIF_F_HW_VLAN_RX) &&
-		    slave_ops->ndo_vlan_rx_register) {
-			slave_ops->ndo_vlan_rx_register(slave_dev, grp);
-		}
-	}
-}
-
-/**
  * bond_vlan_rx_add_vid - Propagates adding an id to slaves
  * @bond_dev: bonding net device that got called
  * @vid: vlan id being added
@@ -489,7 +461,6 @@ static void bond_vlan_rx_kill_vid(struct net_device *bond_dev, uint16_t vid)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
-	struct net_device *vlan_dev;
 	int i, res;
 
 	bond_for_each_slave(bond, slave, i) {
@@ -498,12 +469,7 @@ static void bond_vlan_rx_kill_vid(struct net_device *bond_dev, uint16_t vid)
 
 		if ((slave_dev->features & NETIF_F_HW_VLAN_FILTER) &&
 		    slave_ops->ndo_vlan_rx_kill_vid) {
-			/* Save and then restore vlan_dev in the grp array,
-			 * since the slave's driver might clear it.
-			 */
-			vlan_dev = vlan_group_get_device(bond->vlgrp, vid);
 			slave_ops->ndo_vlan_rx_kill_vid(slave_dev, vid);
-			vlan_group_set_device(bond->vlgrp, vid, vlan_dev);
 		}
 	}
 
@@ -519,13 +485,6 @@ static void bond_add_vlans_on_slave(struct bonding *bond, struct net_device *sla
 	struct vlan_entry *vlan;
 	const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
 
-	if (!bond->vlgrp)
-		return;
-
-	if ((slave_dev->features & NETIF_F_HW_VLAN_RX) &&
-	    slave_ops->ndo_vlan_rx_register)
-		slave_ops->ndo_vlan_rx_register(slave_dev, bond->vlgrp);
-
 	if (!(slave_dev->features & NETIF_F_HW_VLAN_FILTER) ||
 	    !(slave_ops->ndo_vlan_rx_add_vid))
 		return;
@@ -539,30 +498,16 @@ static void bond_del_vlans_from_slave(struct bonding *bond,
 {
 	const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
 	struct vlan_entry *vlan;
-	struct net_device *vlan_dev;
-
-	if (!bond->vlgrp)
-		return;
 
 	if (!(slave_dev->features & NETIF_F_HW_VLAN_FILTER) ||
 	    !(slave_ops->ndo_vlan_rx_kill_vid))
-		goto unreg;
+		return;
 
 	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 		if (!vlan->vlan_id)
 			continue;
-		/* Save and then restore vlan_dev in the grp array,
-		 * since the slave's driver might clear it.
-		 */
-		vlan_dev = vlan_group_get_device(bond->vlgrp, vlan->vlan_id);
 		slave_ops->ndo_vlan_rx_kill_vid(slave_dev, vlan->vlan_id);
-		vlan_group_set_device(bond->vlgrp, vlan->vlan_id, vlan_dev);
 	}
-
-unreg:
-	if ((slave_dev->features & NETIF_F_HW_VLAN_RX) &&
-	    slave_ops->ndo_vlan_rx_register)
-		slave_ops->ndo_vlan_rx_register(slave_dev, NULL);
 }
 
 /*------------------------------- Link status -------------------------------*/
@@ -836,13 +781,13 @@ static void bond_resend_igmp_join_requests(struct bonding *bond)
 	__bond_resend_igmp_join_requests(bond->dev);
 
 	/* rejoin all groups on vlan devices */
-	if (bond->vlgrp) {
-		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
-			vlan_dev = vlan_group_get_device(bond->vlgrp,
-							 vlan->vlan_id);
-			if (vlan_dev)
-				__bond_resend_igmp_join_requests(vlan_dev);
-		}
+	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
+		rcu_read_lock();
+		vlan_dev = __vlan_find_dev_deep(bond->dev,
+						vlan->vlan_id);
+		rcu_read_unlock();
+		if (vlan_dev)
+			__bond_resend_igmp_join_requests(vlan_dev);
 	}
 
 	if (--bond->igmp_retrans > 0)
@@ -1557,7 +1502,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	/* no need to lock since we're protected by rtnl_lock */
 	if (slave_dev->features & NETIF_F_VLAN_CHALLENGED) {
 		pr_debug("%s: NETIF_F_VLAN_CHALLENGED\n", slave_dev->name);
-		if (bond->vlgrp) {
+		if (bond_vlan_used(bond)) {
 			pr_err("%s: Error: cannot enslave VLAN challenged slave %s on VLAN enabled bond %s\n",
 			       bond_dev->name, slave_dev->name, bond_dev->name);
 			return -EPERM;
@@ -2065,7 +2010,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 		 */
 		memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
 
-		if (bond->vlgrp) {
+		if (bond_vlan_used(bond)) {
 			pr_warning("%s: Warning: clearing HW address of %s while it still has VLANs.\n",
 				   bond_dev->name, bond_dev->name);
 			pr_warning("%s: When re-adding slaves, make sure the bond's HW address matches its VLANs'.\n",
@@ -2247,7 +2192,7 @@ static int bond_release_all(struct net_device *bond_dev)
 	 */
 	memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
 
-	if (bond->vlgrp) {
+	if (bond_vlan_used(bond)) {
 		pr_warning("%s: Warning: clearing HW address of %s while it still has VLANs.\n",
 			   bond_dev->name, bond_dev->name);
 		pr_warning("%s: When re-adding slaves, make sure the bond's HW address matches its VLANs'.\n",
@@ -2685,7 +2630,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		if (!targets[i])
 			break;
 		pr_debug("basa: target %x\n", targets[i]);
-		if (!bond->vlgrp) {
+		if (!bond_vlan_used(bond)) {
 			pr_debug("basa: empty vlan: arp_send\n");
 			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
 				      bond->master_ip, 0);
@@ -2720,7 +2665,10 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 
 		vlan_id = 0;
 		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
-			vlan_dev = vlan_group_get_device(bond->vlgrp, vlan->vlan_id);
+			rcu_read_lock();
+			vlan_dev = __vlan_find_dev_deep(bond->dev,
+							vlan->vlan_id);
+			rcu_read_unlock();
 			if (vlan_dev == rt->dst.dev) {
 				vlan_id = vlan->vlan_id;
 				pr_debug("basa: vlan match on %s %d\n",
@@ -3381,9 +3329,8 @@ static int bond_inetaddr_event(struct notifier_block *this, unsigned long event,
 		}
 
 		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
-			if (!bond->vlgrp)
-				continue;
-			vlan_dev = vlan_group_get_device(bond->vlgrp, vlan->vlan_id);
+			vlan_dev = __vlan_find_dev_deep(bond->dev,
+							vlan->vlan_id);
 			if (vlan_dev == event_dev) {
 				switch (event) {
 				case NETDEV_UP:
@@ -4335,10 +4282,9 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_do_ioctl		= bond_do_ioctl,
 	.ndo_set_multicast_list	= bond_set_multicast_list,
 	.ndo_change_mtu		= bond_change_mtu,
-	.ndo_set_mac_address 	= bond_set_mac_address,
+	.ndo_set_mac_address	= bond_set_mac_address,
 	.ndo_neigh_setup	= bond_neigh_setup,
-	.ndo_vlan_rx_register	= bond_vlan_rx_register,
-	.ndo_vlan_rx_add_vid 	= bond_vlan_rx_add_vid,
+	.ndo_vlan_rx_add_vid	= bond_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= bond_vlan_rx_kill_vid,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_netpoll_setup	= bond_netpoll_setup,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 2936171..43526a2 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -240,7 +240,6 @@ struct bonding {
 	struct   alb_bond_info alb_info;
 	struct   bond_params params;
 	struct   list_head vlan_list;
-	struct   vlan_group *vlgrp;
 	struct   workqueue_struct *wq;
 	struct   delayed_work mii_work;
 	struct   delayed_work arp_work;
@@ -253,6 +252,11 @@ struct bonding {
 #endif /* CONFIG_DEBUG_FS */
 };
 
+static inline bool bond_vlan_used(struct bonding *bond)
+{
+	return !list_empty(&bond->vlan_list);
+}
+
 #define bond_slave_get_rcu(dev) \
 	((struct slave *) rcu_dereference(dev->rx_handler_data))
 
-- 
1.7.6

