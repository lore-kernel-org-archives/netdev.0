From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH v2 net-next 5/9] bonding: create a macro for bond mode and use it
Date: Thu, 15 May 2014 14:29:23 +0200
Message-ID: <1400156967-8231-6-git-send-email-vfalico@gmail.com>
References: <1400156967-8231-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29254 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754202AbaEOMeK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 08:34:10 -0400
In-Reply-To: <1400156967-8231-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bond_alb.c         |  4 +-
 drivers/net/bonding/bond_debugfs.c     |  2 +-
 drivers/net/bonding/bond_main.c        | 94 +++++++++++++++++-----------------
 drivers/net/bonding/bond_netlink.c     |  6 +--
 drivers/net/bonding/bond_options.c     |  2 +-
 drivers/net/bonding/bond_procfs.c      | 14 ++---
 drivers/net/bonding/bond_sysfs.c       | 14 ++---
 drivers/net/bonding/bond_sysfs_slave.c |  2 +-
 drivers/net/bonding/bonding.h          |  6 ++-
 9 files changed, 73 insertions(+), 71 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 70de039..efacb0e 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1057,7 +1057,7 @@ static int alb_set_slave_mac_addr(struct slave *slave, u8 addr[])
 	struct net_device *dev = slave->dev;
 	struct sockaddr s_addr;
 
-	if (slave->bond->params.mode == BOND_MODE_TLB) {
+	if (BOND_MODE(slave->bond) == BOND_MODE_TLB) {
 		memcpy(dev->dev_addr, addr, dev->addr_len);
 		return 0;
 	}
@@ -1745,7 +1745,7 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 	/* in TLB mode, the slave might flip down/up with the old dev_addr,
 	 * and thus filter bond->dev_addr's packets, so force bond's mac
 	 */
-	if (bond->params.mode == BOND_MODE_TLB) {
+	if (BOND_MODE(bond) == BOND_MODE_TLB) {
 		struct sockaddr sa;
 		u8 tmp_addr[ETH_ALEN];
 
diff --git a/drivers/net/bonding/bond_debugfs.c b/drivers/net/bonding/bond_debugfs.c
index 2d3f7fa..658e761 100644
--- a/drivers/net/bonding/bond_debugfs.c
+++ b/drivers/net/bonding/bond_debugfs.c
@@ -23,7 +23,7 @@ static int bond_debug_rlb_hash_show(struct seq_file *m, void *v)
 	struct rlb_client_info *client_info;
 	u32 hash_index;
 
-	if (bond->params.mode != BOND_MODE_ALB)
+	if (BOND_MODE(bond) != BOND_MODE_ALB)
 		return 0;
 
 	seq_printf(m, "SourceIP        DestinationIP   "
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 17b68b5..7b8e121 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -343,7 +343,7 @@ static int bond_set_carrier(struct bonding *bond)
 	if (!bond_has_slaves(bond))
 		goto down;
 
-	if (bond->params.mode == BOND_MODE_8023AD)
+	if (BOND_MODE(bond) == BOND_MODE_8023AD)
 		return bond_3ad_set_carrier(bond);
 
 	bond_for_each_slave(bond, slave, iter) {
@@ -497,7 +497,7 @@ static int bond_set_promiscuity(struct bonding *bond, int inc)
 	struct list_head *iter;
 	int err = 0;
 
-	if (bond_mode_uses_primary(bond->params.mode)) {
+	if (bond_mode_uses_primary(BOND_MODE(bond))) {
 		/* write lock already acquired */
 		if (bond->curr_active_slave) {
 			err = dev_set_promiscuity(bond->curr_active_slave->dev,
@@ -523,7 +523,7 @@ static int bond_set_allmulti(struct bonding *bond, int inc)
 	struct list_head *iter;
 	int err = 0;
 
-	if (bond_mode_uses_primary(bond->params.mode)) {
+	if (bond_mode_uses_primary(BOND_MODE(bond))) {
 		/* write lock already acquired */
 		if (bond->curr_active_slave) {
 			err = dev_set_allmulti(bond->curr_active_slave->dev,
@@ -574,7 +574,7 @@ static void bond_hw_addr_flush(struct net_device *bond_dev,
 	dev_uc_unsync(slave_dev, bond_dev);
 	dev_mc_unsync(slave_dev, bond_dev);
 
-	if (bond->params.mode == BOND_MODE_8023AD) {
+	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
 		/* del lacpdu mc addr from mc list */
 		u8 lacpdu_multicast[ETH_ALEN] = MULTICAST_LACPDU_ADDR;
 
@@ -801,7 +801,7 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 		new_active->last_link_up = jiffies;
 
 		if (new_active->link == BOND_LINK_BACK) {
-			if (bond_mode_uses_primary(bond->params.mode)) {
+			if (bond_mode_uses_primary(BOND_MODE(bond))) {
 				pr_info("%s: making interface %s the new active one %d ms earlier\n",
 					bond->dev->name, new_active->dev->name,
 					(bond->params.updelay - new_active->delay) * bond->params.miimon);
@@ -810,20 +810,20 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 			new_active->delay = 0;
 			new_active->link = BOND_LINK_UP;
 
-			if (bond->params.mode == BOND_MODE_8023AD)
+			if (BOND_MODE(bond) == BOND_MODE_8023AD)
 				bond_3ad_handle_link_change(new_active, BOND_LINK_UP);
 
 			if (bond_is_lb(bond))
 				bond_alb_handle_link_change(bond, new_active, BOND_LINK_UP);
 		} else {
-			if (bond_mode_uses_primary(bond->params.mode)) {
+			if (bond_mode_uses_primary(BOND_MODE(bond))) {
 				pr_info("%s: making interface %s the new active one\n",
 					bond->dev->name, new_active->dev->name);
 			}
 		}
 	}
 
-	if (bond_mode_uses_primary(bond->params.mode))
+	if (bond_mode_uses_primary(BOND_MODE(bond)))
 		bond_hw_addr_swap(bond, new_active, old_active);
 
 	if (bond_is_lb(bond)) {
@@ -838,7 +838,7 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 		rcu_assign_pointer(bond->curr_active_slave, new_active);
 	}
 
-	if (bond->params.mode == BOND_MODE_ACTIVEBACKUP) {
+	if (BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP) {
 		if (old_active)
 			bond_set_slave_inactive_flags(old_active,
 						      BOND_SLAVE_NOTIFY_NOW);
@@ -876,8 +876,8 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 	 * resend only if bond is brought up with the affected
 	 * bonding modes and the retransmission is enabled */
 	if (netif_running(bond->dev) && (bond->params.resend_igmp > 0) &&
-	    ((bond_mode_uses_primary(bond->params.mode) && new_active) ||
-	     bond->params.mode == BOND_MODE_ROUNDROBIN)) {
+	    ((bond_mode_uses_primary(BOND_MODE(bond)) && new_active) ||
+	     BOND_MODE(bond) == BOND_MODE_ROUNDROBIN)) {
 		bond->igmp_retrans = bond->params.resend_igmp;
 		queue_delayed_work(bond->wq, &bond->mcast_work, 1);
 	}
@@ -1084,7 +1084,7 @@ static bool bond_should_deliver_exact_match(struct sk_buff *skb,
 					    struct bonding *bond)
 {
 	if (bond_is_slave_inactive(slave)) {
-		if (bond->params.mode == BOND_MODE_ALB &&
+		if (BOND_MODE(bond) == BOND_MODE_ALB &&
 		    skb->pkt_type != PACKET_BROADCAST &&
 		    skb->pkt_type != PACKET_MULTICAST)
 			return false;
@@ -1126,7 +1126,7 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
 
 	skb->dev = bond->dev;
 
-	if (bond->params.mode == BOND_MODE_ALB &&
+	if (BOND_MODE(bond) == BOND_MODE_ALB &&
 	    bond->dev->priv_flags & IFF_BRIDGE_PORT &&
 	    skb->pkt_type == PACKET_HOST) {
 
@@ -1171,7 +1171,7 @@ static struct slave *bond_alloc_slave(struct bonding *bond)
 	if (!slave)
 		return NULL;
 
-	if (bond->params.mode == BOND_MODE_8023AD) {
+	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
 		SLAVE_AD_INFO(slave) = kzalloc(sizeof(struct ad_slave_info),
 					       GFP_KERNEL);
 		if (!SLAVE_AD_INFO(slave)) {
@@ -1186,7 +1186,7 @@ static void bond_free_slave(struct slave *slave)
 {
 	struct bonding *bond = bond_get_bond_by_slave(slave);
 
-	if (bond->params.mode == BOND_MODE_8023AD)
+	if (BOND_MODE(bond) == BOND_MODE_8023AD)
 		kfree(SLAVE_AD_INFO(slave));
 
 	kfree(slave);
@@ -1298,7 +1298,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		if (!bond_has_slaves(bond)) {
 			pr_warn("%s: Warning: The first slave device specified does not support setting the MAC address\n",
 				bond_dev->name);
-			if (bond->params.mode == BOND_MODE_ACTIVEBACKUP) {
+			if (BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP) {
 				bond->params.fail_over_mac = BOND_FOM_ACTIVE;
 				pr_warn("%s: Setting fail_over_mac to active for active-backup mode\n",
 					bond_dev->name);
@@ -1347,7 +1347,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	ether_addr_copy(new_slave->perm_hwaddr, slave_dev->dev_addr);
 
 	if (!bond->params.fail_over_mac ||
-	    bond->params.mode != BOND_MODE_ACTIVEBACKUP) {
+	    BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
 		/*
 		 * Set slave to master's mac address.  The application already
 		 * set the master's mac address to that of the first slave
@@ -1384,7 +1384,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	/* If the mode uses primary, then the following is handled by
 	 * bond_change_active_slave().
 	 */
-	if (!bond_mode_uses_primary(bond->params.mode)) {
+	if (!bond_mode_uses_primary(BOND_MODE(bond))) {
 		/* set promiscuity level to new slave */
 		if (bond_dev->flags & IFF_PROMISC) {
 			res = dev_set_promiscuity(slave_dev, 1);
@@ -1407,7 +1407,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		netif_addr_unlock_bh(bond_dev);
 	}
 
-	if (bond->params.mode == BOND_MODE_8023AD) {
+	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
 		/* add lacpdu mc addr to mc list */
 		u8 lacpdu_multicast[ETH_ALEN] = MULTICAST_LACPDU_ADDR;
 
@@ -1480,7 +1480,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		 new_slave->link == BOND_LINK_DOWN ? "DOWN" :
 		 (new_slave->link == BOND_LINK_UP ? "UP" : "BACK"));
 
-	if (bond_mode_uses_primary(bond->params.mode) && bond->params.primary[0]) {
+	if (bond_mode_uses_primary(BOND_MODE(bond)) && bond->params.primary[0]) {
 		/* if there is a primary slave, remember it */
 		if (strcmp(bond->params.primary, new_slave->dev->name) == 0) {
 			bond->primary_slave = new_slave;
@@ -1488,7 +1488,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		}
 	}
 
-	switch (bond->params.mode) {
+	switch (BOND_MODE(bond)) {
 	case BOND_MODE_ACTIVEBACKUP:
 		bond_set_slave_inactive_flags(new_slave,
 					      BOND_SLAVE_NOTIFY_NOW);
@@ -1569,7 +1569,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	bond_compute_features(bond);
 	bond_set_carrier(bond);
 
-	if (bond_mode_uses_primary(bond->params.mode)) {
+	if (bond_mode_uses_primary(BOND_MODE(bond))) {
 		block_netpoll_tx();
 		write_lock_bh(&bond->curr_slave_lock);
 		bond_select_active_slave(bond);
@@ -1593,7 +1593,7 @@ err_unregister:
 	netdev_rx_handler_unregister(slave_dev);
 
 err_detach:
-	if (!bond_mode_uses_primary(bond->params.mode))
+	if (!bond_mode_uses_primary(BOND_MODE(bond)))
 		bond_hw_addr_flush(bond_dev, slave_dev);
 
 	vlan_vids_del_by_dev(slave_dev, bond_dev);
@@ -1615,7 +1615,7 @@ err_close:
 
 err_restore_mac:
 	if (!bond->params.fail_over_mac ||
-	    bond->params.mode != BOND_MODE_ACTIVEBACKUP) {
+	    BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
 		/* XXX TODO - fom follow mode needs to change master's
 		 * MAC if this slave's MAC is in use by the bond, or at
 		 * least print a warning.
@@ -1691,7 +1691,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 	write_lock_bh(&bond->lock);
 
 	/* Inform AD package of unbinding of slave. */
-	if (bond->params.mode == BOND_MODE_8023AD)
+	if (BOND_MODE(bond) == BOND_MODE_8023AD)
 		bond_3ad_unbind_slave(slave);
 
 	write_unlock_bh(&bond->lock);
@@ -1706,7 +1706,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 	bond->current_arp_slave = NULL;
 
 	if (!all && (!bond->params.fail_over_mac ||
-		     bond->params.mode != BOND_MODE_ACTIVEBACKUP)) {
+		     BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP)) {
 		if (ether_addr_equal_64bits(bond_dev->dev_addr, slave->perm_hwaddr) &&
 		    bond_has_slaves(bond))
 			pr_warn("%s: Warning: the permanent HWaddr of %s - %pM - is still in use by %s - set the HWaddr of %s to a different address to avoid conflicts\n",
@@ -1781,7 +1781,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 	/* If the mode uses primary, then this cases was handled above by
 	 * bond_change_active_slave(..., NULL)
 	 */
-	if (!bond_mode_uses_primary(bond->params.mode)) {
+	if (!bond_mode_uses_primary(BOND_MODE(bond))) {
 		/* unset promiscuity level from slave
 		 * NOTE: The NETDEV_CHANGEADDR call above may change the value
 		 * of the IFF_PROMISC flag in the bond_dev, but we need the
@@ -1805,7 +1805,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 	dev_close(slave_dev);
 
 	if (bond->params.fail_over_mac != BOND_FOM_ACTIVE ||
-	    bond->params.mode != BOND_MODE_ACTIVEBACKUP) {
+	    BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
 		/* restore original ("permanent") mac address */
 		ether_addr_copy(addr.sa_data, slave->perm_hwaddr);
 		addr.sa_family = slave_dev->type;
@@ -1851,7 +1851,7 @@ static int bond_info_query(struct net_device *bond_dev, struct ifbond *info)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 
-	info->bond_mode = bond->params.mode;
+	info->bond_mode = BOND_MODE(bond);
 	info->miimon = bond->params.miimon;
 
 	info->num_slaves = bond->slave_cnt;
@@ -1907,7 +1907,7 @@ static int bond_miimon_inspect(struct bonding *bond)
 			if (slave->delay) {
 				pr_info("%s: link status down for %sinterface %s, disabling it in %d ms\n",
 					bond->dev->name,
-					(bond->params.mode ==
+					(BOND_MODE(bond) ==
 					 BOND_MODE_ACTIVEBACKUP) ?
 					(bond_is_active_slave(slave) ?
 					 "active " : "backup ") : "",
@@ -1998,10 +1998,10 @@ static void bond_miimon_commit(struct bonding *bond)
 			slave->link = BOND_LINK_UP;
 			slave->last_link_up = jiffies;
 
-			if (bond->params.mode == BOND_MODE_8023AD) {
+			if (BOND_MODE(bond) == BOND_MODE_8023AD) {
 				/* prevent it from being the active one */
 				bond_set_backup_slave(slave);
-			} else if (bond->params.mode != BOND_MODE_ACTIVEBACKUP) {
+			} else if (BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
 				/* make it immediately active */
 				bond_set_active_slave(slave);
 			} else if (slave != bond->primary_slave) {
@@ -2015,7 +2015,7 @@ static void bond_miimon_commit(struct bonding *bond)
 				slave->duplex ? "full" : "half");
 
 			/* notify ad that the link status has changed */
-			if (bond->params.mode == BOND_MODE_8023AD)
+			if (BOND_MODE(bond) == BOND_MODE_8023AD)
 				bond_3ad_handle_link_change(slave, BOND_LINK_UP);
 
 			if (bond_is_lb(bond))
@@ -2034,15 +2034,15 @@ static void bond_miimon_commit(struct bonding *bond)
 
 			slave->link = BOND_LINK_DOWN;
 
-			if (bond->params.mode == BOND_MODE_ACTIVEBACKUP ||
-			    bond->params.mode == BOND_MODE_8023AD)
+			if (BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP ||
+			    BOND_MODE(bond) == BOND_MODE_8023AD)
 				bond_set_slave_inactive_flags(slave,
 							      BOND_SLAVE_NOTIFY_NOW);
 
 			pr_info("%s: link status definitely down for interface %s, disabling it\n",
 				bond->dev->name, slave->dev->name);
 
-			if (bond->params.mode == BOND_MODE_8023AD)
+			if (BOND_MODE(bond) == BOND_MODE_8023AD)
 				bond_3ad_handle_link_change(slave,
 							    BOND_LINK_DOWN);
 
@@ -2887,7 +2887,7 @@ static int bond_slave_netdev_event(unsigned long event,
 
 		bond_update_speed_duplex(slave);
 
-		if (bond->params.mode == BOND_MODE_8023AD) {
+		if (BOND_MODE(bond) == BOND_MODE_8023AD) {
 			if (old_speed != slave->speed)
 				bond_3ad_adapter_speed_changed(slave);
 			if (old_duplex != slave->duplex)
@@ -2915,7 +2915,7 @@ static int bond_slave_netdev_event(unsigned long event,
 		break;
 	case NETDEV_CHANGENAME:
 		/* we don't care if we don't have primary set */
-		if (!bond_mode_uses_primary(bond->params.mode) ||
+		if (!bond_mode_uses_primary(BOND_MODE(bond)) ||
 		    !bond->params.primary[0])
 			break;
 
@@ -3078,7 +3078,7 @@ static void bond_work_init_all(struct bonding *bond)
 			  bond_resend_igmp_join_requests_delayed);
 	INIT_DELAYED_WORK(&bond->alb_work, bond_alb_monitor);
 	INIT_DELAYED_WORK(&bond->mii_work, bond_mii_monitor);
-	if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
+	if (BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP)
 		INIT_DELAYED_WORK(&bond->arp_work, bond_activebackup_arp_mon);
 	else
 		INIT_DELAYED_WORK(&bond->arp_work, bond_loadbalance_arp_mon);
@@ -3105,7 +3105,7 @@ static int bond_open(struct net_device *bond_dev)
 	if (bond_has_slaves(bond)) {
 		read_lock(&bond->curr_slave_lock);
 		bond_for_each_slave(bond, slave, iter) {
-			if (bond_mode_uses_primary(bond->params.mode)
+			if (bond_mode_uses_primary(BOND_MODE(bond))
 				&& (slave != bond->curr_active_slave)) {
 				bond_set_slave_inactive_flags(slave,
 							      BOND_SLAVE_NOTIFY_NOW);
@@ -3124,7 +3124,7 @@ static int bond_open(struct net_device *bond_dev)
 		/* bond_alb_initialize must be called before the timer
 		 * is started.
 		 */
-		if (bond_alb_initialize(bond, (bond->params.mode == BOND_MODE_ALB)))
+		if (bond_alb_initialize(bond, (BOND_MODE(bond) == BOND_MODE_ALB)))
 			return -ENOMEM;
 		if (bond->params.tlb_dynamic_lb)
 			queue_delayed_work(bond->wq, &bond->alb_work, 0);
@@ -3138,7 +3138,7 @@ static int bond_open(struct net_device *bond_dev)
 		bond->recv_probe = bond_arp_rcv;
 	}
 
-	if (bond->params.mode == BOND_MODE_8023AD) {
+	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
 		queue_delayed_work(bond->wq, &bond->ad_work, 0);
 		/* register to receive LACPDUs */
 		bond->recv_probe = bond_3ad_lacpdu_recv;
@@ -3343,7 +3343,7 @@ static void bond_set_rx_mode(struct net_device *bond_dev)
 
 
 	rcu_read_lock();
-	if (bond_mode_uses_primary(bond->params.mode)) {
+	if (bond_mode_uses_primary(BOND_MODE(bond))) {
 		slave = rcu_dereference(bond->curr_active_slave);
 		if (slave) {
 			dev_uc_sync(slave->dev, bond_dev);
@@ -3497,7 +3497,7 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 	struct list_head *iter;
 	int res = 0;
 
-	if (bond->params.mode == BOND_MODE_ALB)
+	if (BOND_MODE(bond) == BOND_MODE_ALB)
 		return bond_alb_set_mac_address(bond_dev, addr);
 
 
@@ -3508,7 +3508,7 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 	 * Returning an error causes ifenslave to fail.
 	 */
 	if (bond->params.fail_over_mac &&
-	    bond->params.mode == BOND_MODE_ACTIVEBACKUP)
+	    BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP)
 		return 0;
 
 	if (!is_valid_ether_addr(sa->sa_data))
@@ -3792,7 +3792,7 @@ static netdev_tx_t __bond_start_xmit(struct sk_buff *skb, struct net_device *dev
 	    !bond_slave_override(bond, skb))
 		return NETDEV_TX_OK;
 
-	switch (bond->params.mode) {
+	switch (BOND_MODE(bond)) {
 	case BOND_MODE_ROUNDROBIN:
 		return bond_xmit_roundrobin(skb, dev);
 	case BOND_MODE_ACTIVEBACKUP:
@@ -3810,7 +3810,7 @@ static netdev_tx_t __bond_start_xmit(struct sk_buff *skb, struct net_device *dev
 	default:
 		/* Should never happen, mode already checked */
 		pr_err("%s: Error: Unknown bonding mode %d\n",
-		       dev->name, bond->params.mode);
+		       dev->name, BOND_MODE(bond));
 		WARN_ON_ONCE(1);
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 0d06e75..5ab3c18 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -56,7 +56,7 @@ static int bond_fill_slave_info(struct sk_buff *skb,
 	if (nla_put_u16(skb, IFLA_BOND_SLAVE_QUEUE_ID, slave->queue_id))
 		goto nla_put_failure;
 
-	if (slave->bond->params.mode == BOND_MODE_8023AD) {
+	if (BOND_MODE(slave->bond) == BOND_MODE_8023AD) {
 		const struct aggregator *agg;
 
 		agg = SLAVE_AD_INFO(slave)->port.aggregator;
@@ -407,7 +407,7 @@ static int bond_fill_info(struct sk_buff *skb,
 	unsigned int packets_per_slave;
 	int i, targets_added;
 
-	if (nla_put_u8(skb, IFLA_BOND_MODE, bond->params.mode))
+	if (nla_put_u8(skb, IFLA_BOND_MODE, BOND_MODE(bond)))
 		goto nla_put_failure;
 
 	if (slave_dev &&
@@ -505,7 +505,7 @@ static int bond_fill_info(struct sk_buff *skb,
 		       bond->params.ad_select))
 		goto nla_put_failure;
 
-	if (bond->params.mode == BOND_MODE_8023AD) {
+	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
 		struct ad_info info;
 
 		if (!bond_3ad_get_active_agg_info(bond, &info)) {
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index afae661..ed11c6f 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -693,7 +693,7 @@ int bond_option_mode_set(struct bonding *bond, const struct bond_opt_value *newv
 static struct net_device *__bond_option_active_slave_get(struct bonding *bond,
 							 struct slave *slave)
 {
-	return bond_mode_uses_primary(bond->params.mode) && slave ? slave->dev : NULL;
+	return bond_mode_uses_primary(BOND_MODE(bond)) && slave ? slave->dev : NULL;
 }
 
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond)
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index 7cf55a5..dc1291f 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -72,9 +72,9 @@ static void bond_info_show_master(struct seq_file *seq)
 	curr = rcu_dereference(bond->curr_active_slave);
 
 	seq_printf(seq, "Bonding Mode: %s",
-		   bond_mode_name(bond->params.mode));
+		   bond_mode_name(BOND_MODE(bond)));
 
-	if (bond->params.mode == BOND_MODE_ACTIVEBACKUP &&
+	if (BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP &&
 	    bond->params.fail_over_mac) {
 		optval = bond_opt_get_val(BOND_OPT_FAIL_OVER_MAC,
 					  bond->params.fail_over_mac);
@@ -83,15 +83,15 @@ static void bond_info_show_master(struct seq_file *seq)
 
 	seq_printf(seq, "\n");
 
-	if (bond->params.mode == BOND_MODE_XOR ||
-		bond->params.mode == BOND_MODE_8023AD) {
+	if (BOND_MODE(bond) == BOND_MODE_XOR ||
+	    BOND_MODE(bond) == BOND_MODE_8023AD) {
 		optval = bond_opt_get_val(BOND_OPT_XMIT_HASH,
 					  bond->params.xmit_policy);
 		seq_printf(seq, "Transmit Hash Policy: %s (%d)\n",
 			   optval->string, bond->params.xmit_policy);
 	}
 
-	if (bond_mode_uses_primary(bond->params.mode)) {
+	if (bond_mode_uses_primary(BOND_MODE(bond))) {
 		seq_printf(seq, "Primary Slave: %s",
 			   (bond->primary_slave) ?
 			   bond->primary_slave->dev->name : "None");
@@ -134,7 +134,7 @@ static void bond_info_show_master(struct seq_file *seq)
 		seq_printf(seq, "\n");
 	}
 
-	if (bond->params.mode == BOND_MODE_8023AD) {
+	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
 
 		seq_puts(seq, "\n802.3ad info\n");
@@ -188,7 +188,7 @@ static void bond_info_show_slave(struct seq_file *seq,
 
 	seq_printf(seq, "Permanent HW addr: %pM\n", slave->perm_hwaddr);
 
-	if (bond->params.mode == BOND_MODE_8023AD) {
+	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
 		const struct aggregator *agg
 			= SLAVE_AD_INFO(slave)->port.aggregator;
 
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 39c4d8d..daed52f 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -214,9 +214,9 @@ static ssize_t bonding_show_mode(struct device *d,
 	struct bonding *bond = to_bond(d);
 	const struct bond_opt_value *val;
 
-	val = bond_opt_get_val(BOND_OPT_MODE, bond->params.mode);
+	val = bond_opt_get_val(BOND_OPT_MODE, BOND_MODE(bond));
 
-	return sprintf(buf, "%s %d\n", val->string, bond->params.mode);
+	return sprintf(buf, "%s %d\n", val->string, BOND_MODE(bond));
 }
 static DEVICE_ATTR(mode, S_IRUGO | S_IWUSR,
 		   bonding_show_mode, bonding_sysfs_store_option);
@@ -505,7 +505,7 @@ static ssize_t bonding_show_ad_aggregator(struct device *d,
 	int count = 0;
 	struct bonding *bond = to_bond(d);
 
-	if (bond->params.mode == BOND_MODE_8023AD) {
+	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
 		count = sprintf(buf, "%d\n",
 				bond_3ad_get_active_agg_info(bond, &ad_info)
@@ -525,7 +525,7 @@ static ssize_t bonding_show_ad_num_ports(struct device *d,
 	int count = 0;
 	struct bonding *bond = to_bond(d);
 
-	if (bond->params.mode == BOND_MODE_8023AD) {
+	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
 		count = sprintf(buf, "%d\n",
 				bond_3ad_get_active_agg_info(bond, &ad_info)
@@ -545,7 +545,7 @@ static ssize_t bonding_show_ad_actor_key(struct device *d,
 	int count = 0;
 	struct bonding *bond = to_bond(d);
 
-	if (bond->params.mode == BOND_MODE_8023AD) {
+	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
 		count = sprintf(buf, "%d\n",
 				bond_3ad_get_active_agg_info(bond, &ad_info)
@@ -565,7 +565,7 @@ static ssize_t bonding_show_ad_partner_key(struct device *d,
 	int count = 0;
 	struct bonding *bond = to_bond(d);
 
-	if (bond->params.mode == BOND_MODE_8023AD) {
+	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
 		count = sprintf(buf, "%d\n",
 				bond_3ad_get_active_agg_info(bond, &ad_info)
@@ -585,7 +585,7 @@ static ssize_t bonding_show_ad_partner_mac(struct device *d,
 	int count = 0;
 	struct bonding *bond = to_bond(d);
 
-	if (bond->params.mode == BOND_MODE_8023AD) {
+	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
 		if (!bond_3ad_get_active_agg_info(bond, &ad_info))
 			count = sprintf(buf, "%pM\n", ad_info.partner_system);
diff --git a/drivers/net/bonding/bond_sysfs_slave.c b/drivers/net/bonding/bond_sysfs_slave.c
index 89bc3b3..198677f 100644
--- a/drivers/net/bonding/bond_sysfs_slave.c
+++ b/drivers/net/bonding/bond_sysfs_slave.c
@@ -69,7 +69,7 @@ static ssize_t ad_aggregator_id_show(struct slave *slave, char *buf)
 {
 	const struct aggregator *agg;
 
-	if (slave->bond->params.mode == BOND_MODE_8023AD) {
+	if (BOND_MODE(slave->bond) == BOND_MODE_8023AD) {
 		agg = SLAVE_AD_INFO(slave)->port.aggregator;
 		if (agg)
 			return sprintf(buf, "%d\n",
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 34a8ed5..4494fb9 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -70,6 +70,8 @@
 	set_fs(fs);			\
 	res; })
 
+#define BOND_MODE(bond) ((bond)->params.mode)
+
 /* slave list primitives */
 #define bond_slave_list(bond) (&(bond)->dev->adj_list.lower)
 
@@ -277,8 +279,8 @@ static inline bool bond_should_override_tx_queue(struct bonding *bond)
 
 static inline bool bond_is_lb(const struct bonding *bond)
 {
-	return bond->params.mode == BOND_MODE_TLB ||
-	       bond->params.mode == BOND_MODE_ALB;
+	return BOND_MODE(bond) == BOND_MODE_TLB ||
+	       BOND_MODE(bond) == BOND_MODE_ALB;
 }
 
 static inline bool bond_mode_uses_arp(int mode)
-- 
1.8.4
