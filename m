From: Jesse Gross <jesse@nicira.com>
Subject: [RFC PATCH 6/7] bonding: Update bonding for new vlan model.
Date: Wed, 13 Oct 2010 13:02:56 -0700
Message-ID: <1287000177-7126-7-git-send-email-jesse@nicira.com>
References: <1287000177-7126-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:65497 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752876Ab0JMUDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 16:03:10 -0400
Received: by mail-pw0-f46.google.com with SMTP id 4so251540pwi.19
        for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 13:03:09 -0700 (PDT)
In-Reply-To: <1287000177-7126-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is no longer necessary to register vlan groups, so update bonding
to not do that on its slaves.  Although the new vlan accleration
model allows additional flexibility, bonding continues to require vlan
devices since it needs addtional system state to handle ARP/IGMP.  This
also removes fallback code for non-vlan acclerated slaves since core
networking now handles that.

Signed-off-by: Jesse Gross <jesse@nicira.com>
--
This patch can only be applied once all drivers that use vlan acceleration
have been converted over to the new model.
---
 drivers/net/bonding/bond_alb.c  |    8 +--
 drivers/net/bonding/bond_ipv6.c |    5 +-
 drivers/net/bonding/bond_main.c |  134 ++++++++-------------------------------
 drivers/net/bonding/bonding.h   |    1 -
 4 files changed, 30 insertions(+), 118 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 26bb118..c911456 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -685,10 +685,8 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 			client_info->ntt = 0;
 		}
 
-		if (bond->vlgrp) {
-			if (!vlan_get_tag(skb, &client_info->vlan_id))
-				client_info->tag = 1;
-		}
+		if (!vlan_get_tag(skb, &client_info->vlan_id))
+			client_info->tag = 1;
 
 		if (!client_info->assigned) {
 			u32 prev_tbl_head = bond_info->rx_hashtbl_head;
@@ -907,7 +905,7 @@ static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[])
 		skb->priority = TC_PRIO_CONTROL;
 		skb->dev = slave->dev;
 
-		if (bond->vlgrp) {
+		if (!list_empty(&bond->vlan_list)) {
 			struct vlan_entry *vlan;
 
 			vlan = bond_next_vlan(bond,
diff --git a/drivers/net/bonding/bond_ipv6.c b/drivers/net/bonding/bond_ipv6.c
index 121b073..c276b5a 100644
--- a/drivers/net/bonding/bond_ipv6.c
+++ b/drivers/net/bonding/bond_ipv6.c
@@ -178,10 +178,7 @@ static int bond_inet6addr_event(struct notifier_block *this,
 		}
 
 		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
-			if (!bond->vlgrp)
-				continue;
-			vlan_dev = vlan_group_get_device(bond->vlgrp,
-							 vlan->vlan_id);
+			vlan_dev = vlan_find_dev(bond->dev, vlan->vlan_id);
 			if (vlan_dev == event_dev) {
 				switch (event) {
 				case NETDEV_UP:
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7703d35..5600946 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -414,36 +414,11 @@ struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr)
  * @bond: bond device that got this skb for tx.
  * @skb: hw accel VLAN tagged skb to transmit
  * @slave_dev: slave that is supposed to xmit this skbuff
- *
- * When the bond gets an skb to transmit that is
- * already hardware accelerated VLAN tagged, and it
- * needs to relay this skb to a slave that is not
- * hw accel capable, the skb needs to be "unaccelerated",
- * i.e. strip the hwaccel tag and re-insert it as part
- * of the payload.
  */
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
 			struct net_device *slave_dev)
 {
-	unsigned short uninitialized_var(vlan_id);
-
-	/* Test vlan_list not vlgrp to catch and handle 802.1p tags */
-	if (!list_empty(&bond->vlan_list) &&
-	    !(slave_dev->features & NETIF_F_HW_VLAN_TX) &&
-	    vlan_get_tag(skb, &vlan_id) == 0) {
-		skb->dev = slave_dev;
-		skb = vlan_put_tag(skb, vlan_id);
-		if (!skb) {
-			/* vlan_put_tag() frees the skb in case of error,
-			 * so return success here so the calling functions
-			 * won't attempt to free is again.
-			 */
-			return 0;
-		}
-	} else {
-		skb->dev = slave_dev;
-	}
-
+	skb->dev = slave_dev;
 	skb->priority = 1;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	if (unlikely(bond->dev->priv_flags & IFF_IN_NETPOLL)) {
@@ -462,8 +437,8 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
 }
 
 /*
- * In the following 3 functions, bond_vlan_rx_register(), bond_vlan_rx_add_vid
- * and bond_vlan_rx_kill_vid, We don't protect the slave list iteration with a
+ * In the following 2 functions, bond_vlan_rx_add_vid and
+ * bond_vlan_rx_kill_vid, We don't protect the slave list iteration with a
  * lock because:
  * a. This operation is performed in IOCTL context,
  * b. The operation is protected by the RTNL semaphore in the 8021q code,
@@ -480,33 +455,6 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
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
-	write_lock(&bond->lock);
-	bond->vlgrp = grp;
-	write_unlock(&bond->lock);
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
@@ -543,7 +491,6 @@ static void bond_vlan_rx_kill_vid(struct net_device *bond_dev, uint16_t vid)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
-	struct net_device *vlan_dev;
 	int i, res;
 
 	bond_for_each_slave(bond, slave, i) {
@@ -551,14 +498,8 @@ static void bond_vlan_rx_kill_vid(struct net_device *bond_dev, uint16_t vid)
 		const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
 
 		if ((slave_dev->features & NETIF_F_HW_VLAN_FILTER) &&
-		    slave_ops->ndo_vlan_rx_kill_vid) {
-			/* Save and then restore vlan_dev in the grp array,
-			 * since the slave's driver might clear it.
-			 */
-			vlan_dev = vlan_group_get_device(bond->vlgrp, vid);
+		    slave_ops->ndo_vlan_rx_kill_vid)
 			slave_ops->ndo_vlan_rx_kill_vid(slave_dev, vid);
-			vlan_group_set_device(bond->vlgrp, vid, vlan_dev);
-		}
 	}
 
 	res = bond_del_vlan(bond, vid);
@@ -573,13 +514,6 @@ static void bond_add_vlans_on_slave(struct bonding *bond, struct net_device *sla
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
@@ -593,30 +527,17 @@ static void bond_del_vlans_from_slave(struct bonding *bond,
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
+
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
@@ -894,23 +815,22 @@ static void bond_resend_igmp_join_requests(struct bonding *bond)
 	struct vlan_entry *vlan;
 
 	read_lock(&bond->lock);
+	rcu_read_lock();
 
 	/* rejoin all groups on bond device */
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
+		vlan_dev = vlan_find_dev(bond->dev, vlan->vlan_id);
+		if (vlan_dev)
+			__bond_resend_igmp_join_requests(vlan_dev);
 	}
 
 	if (--bond->igmp_retrans > 0)
 		queue_delayed_work(bond->wq, &bond->mcast_work, HZ/5);
 
+	rcu_read_unlock();
 	read_unlock(&bond->lock);
 }
 
@@ -1476,7 +1396,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	/* no need to lock since we're protected by rtnl_lock */
 	if (slave_dev->features & NETIF_F_VLAN_CHALLENGED) {
 		pr_debug("%s: NETIF_F_VLAN_CHALLENGED\n", slave_dev->name);
-		if (bond->vlgrp) {
+		if (!list_empty(&bond->vlan_list)) {
 			pr_err("%s: Error: cannot enslave VLAN challenged slave %s on VLAN enabled bond %s\n",
 			       bond_dev->name, slave_dev->name, bond_dev->name);
 			return -EPERM;
@@ -1975,9 +1895,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 		 */
 		memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
 
-		if (!bond->vlgrp) {
-			bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
-		} else {
+		if (!list_empty(&bond->vlan_list)) {
 			pr_warning("%s: Warning: clearing HW address of %s while it still has VLANs.\n",
 				   bond_dev->name, bond_dev->name);
 			pr_warning("%s: When re-adding slaves, make sure the bond's HW address matches its VLANs'.\n",
@@ -2167,9 +2085,7 @@ static int bond_release_all(struct net_device *bond_dev)
 	 */
 	memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
 
-	if (!bond->vlgrp) {
-		bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
-	} else {
+	if (!list_empty(&bond->vlan_list)) {
 		pr_warning("%s: Warning: clearing HW address of %s while it still has VLANs.\n",
 			   bond_dev->name, bond_dev->name);
 		pr_warning("%s: When re-adding slaves, make sure the bond's HW address matches its VLANs'.\n",
@@ -2601,11 +2517,13 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 	struct flowi fl;
 	struct rtable *rt;
 
+	rcu_read_lock();
+
 	for (i = 0; (i < BOND_MAX_ARP_TARGETS); i++) {
 		if (!targets[i])
 			break;
 		pr_debug("basa: target %x\n", targets[i]);
-		if (!bond->vlgrp) {
+		if (list_empty(&bond->vlan_list)) {
 			pr_debug("basa: empty vlan: arp_send\n");
 			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
 				      bond->master_ip, 0);
@@ -2643,7 +2561,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 
 		vlan_id = 0;
 		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
-			vlan_dev = vlan_group_get_device(bond->vlgrp, vlan->vlan_id);
+			vlan_dev = vlan_find_dev(bond->dev, vlan->vlan_id);
 			if (vlan_dev == rt->dst.dev) {
 				vlan_id = vlan->vlan_id;
 				pr_debug("basa: vlan match on %s %d\n",
@@ -2666,6 +2584,8 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		}
 		ip_rt_put(rt);
 	}
+
+	rcu_read_unlock();
 }
 
 /*
@@ -2694,16 +2614,17 @@ static void bond_send_gratuitous_arp(struct bonding *bond)
 				bond->master_ip, 0);
 	}
 
-	if (!bond->vlgrp)
-		return;
+	rcu_read_lock();
 
 	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
-		vlan_dev = vlan_group_get_device(bond->vlgrp, vlan->vlan_id);
+		vlan_dev = vlan_find_dev(bond->dev, vlan->vlan_id);
 		if (vlan->vlan_ip) {
 			bond_arp_send(slave->dev, ARPOP_REPLY, vlan->vlan_ip,
 				      vlan->vlan_ip, vlan->vlan_id);
 		}
 	}
+
+	rcu_read_unlock();
 }
 
 static void bond_validate_arp(struct bonding *bond, struct slave *slave, __be32 sip, __be32 tip)
@@ -3653,9 +3574,7 @@ static int bond_inetaddr_event(struct notifier_block *this, unsigned long event,
 		}
 
 		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
-			if (!bond->vlgrp)
-				continue;
-			vlan_dev = vlan_group_get_device(bond->vlgrp, vlan->vlan_id);
+			vlan_dev = vlan_find_dev(bond->dev, vlan->vlan_id);
 			if (vlan_dev == event_dev) {
 				switch (event) {
 				case NETDEV_UP:
@@ -4656,7 +4575,6 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_change_mtu		= bond_change_mtu,
 	.ndo_set_mac_address 	= bond_set_mac_address,
 	.ndo_neigh_setup	= bond_neigh_setup,
-	.ndo_vlan_rx_register	= bond_vlan_rx_register,
 	.ndo_vlan_rx_add_vid 	= bond_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= bond_vlan_rx_kill_vid,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index c15f213..999746b 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -218,7 +218,6 @@ struct bonding {
 	struct   alb_bond_info alb_info;
 	struct   bond_params params;
 	struct   list_head vlan_list;
-	struct   vlan_group *vlgrp;
 	struct   packet_type arp_mon_pt;
 	struct   workqueue_struct *wq;
 	struct   delayed_work mii_work;
-- 
1.7.0.4

