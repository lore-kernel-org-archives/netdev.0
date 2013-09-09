From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 16/26] bonding: add bond_has_slaves() and use it
Date: Mon,  9 Sep 2013 22:16:34 +0200
Message-ID: <1378757804-3159-17-git-send-email-vfalico@redhat.com>
References: <1378757804-3159-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48276 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756024Ab3IIUQ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Sep 2013 16:16:58 -0400
In-Reply-To: <1378757804-3159-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we verify if we have slaves by checking if bond->slave_list is
empty. Create a define bond_has_slaves() and use it, a bit more readable
and easier to change in the future.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_3ad.c   |  2 +-
 drivers/net/bonding/bond_alb.c   |  8 ++++----
 drivers/net/bonding/bond_main.c  | 32 ++++++++++++++++----------------
 drivers/net/bonding/bond_sysfs.c |  4 ++--
 drivers/net/bonding/bonding.h    |  2 ++
 5 files changed, 25 insertions(+), 23 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index c861ee7..1337eaf 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2117,7 +2117,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	read_lock(&bond->lock);
 
 	//check if there are any slaves
-	if (list_empty(&bond->slave_list))
+	if (!bond_has_slaves(bond))
 		goto re_arm;
 
 	// check if agg_select_timer timer after initialize is timed out
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 1172474..f3e8114 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1178,7 +1178,7 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
 	struct slave *tmp_slave1, *free_mac_slave = NULL;
 	struct list_head *iter;
 
-	if (list_empty(&bond->slave_list)) {
+	if (!bond_has_slaves(bond)) {
 		/* this is the first slave */
 		return 0;
 	}
@@ -1469,7 +1469,7 @@ void bond_alb_monitor(struct work_struct *work)
 
 	read_lock(&bond->lock);
 
-	if (list_empty(&bond->slave_list)) {
+	if (!bond_has_slaves(bond)) {
 		bond_info->tx_rebalance_counter = 0;
 		bond_info->lp_counter = 0;
 		goto re_arm;
@@ -1606,7 +1606,7 @@ int bond_alb_init_slave(struct bonding *bond, struct slave *slave)
  */
 void bond_alb_deinit_slave(struct bonding *bond, struct slave *slave)
 {
-	if (!list_empty(&bond->slave_list))
+	if (bond_has_slaves(bond))
 		alb_change_hw_addr_on_detach(bond, slave);
 
 	tlb_clear_slave(bond, slave, 0);
@@ -1676,7 +1676,7 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 	swap_slave = bond->curr_active_slave;
 	rcu_assign_pointer(bond->curr_active_slave, new_slave);
 
-	if (!new_slave || list_empty(&bond->slave_list))
+	if (!new_slave || !bond_has_slaves(bond))
 		return;
 
 	/* set the new curr_active_slave to the bonds mac address
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index eedfa8f..c91b754 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -391,7 +391,7 @@ static int bond_set_carrier(struct bonding *bond)
 	struct list_head *iter;
 	struct slave *slave;
 
-	if (list_empty(&bond->slave_list))
+	if (!bond_has_slaves(bond))
 		goto down;
 
 	if (bond->params.mode == BOND_MODE_8023AD)
@@ -1085,7 +1085,7 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
 	netdev_features_t mask;
 	struct slave *slave;
 
-	if (list_empty(&bond->slave_list)) {
+	if (!bond_has_slaves(bond)) {
 		/* Disable adding VLANs to empty bond. But why? --mq */
 		features |= NETIF_F_VLAN_CHALLENGED;
 		return features;
@@ -1120,7 +1120,7 @@ static void bond_compute_features(struct bonding *bond)
 	unsigned int gso_max_size = GSO_MAX_SIZE;
 	u16 gso_max_segs = GSO_MAX_SEGS;
 
-	if (list_empty(&bond->slave_list))
+	if (!bond_has_slaves(bond))
 		goto done;
 
 	bond_for_each_slave(bond, slave, iter) {
@@ -1310,7 +1310,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	 * bond ether type mutual exclusion - don't allow slaves of dissimilar
 	 * ether type (eg ARPHRD_ETHER and ARPHRD_INFINIBAND) share the same bond
 	 */
-	if (list_empty(&bond->slave_list)) {
+	if (!bond_has_slaves(bond)) {
 		if (bond_dev->type != slave_dev->type) {
 			pr_debug("%s: change device type from %d to %d\n",
 				 bond_dev->name,
@@ -1349,7 +1349,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	}
 
 	if (slave_ops->ndo_set_mac_address == NULL) {
-		if (list_empty(&bond->slave_list)) {
+		if (!bond_has_slaves(bond)) {
 			pr_warning("%s: Warning: The first slave device specified does not support setting the MAC address. Setting fail_over_mac to active.",
 				   bond_dev->name);
 			bond->params.fail_over_mac = BOND_FOM_ACTIVE;
@@ -1365,7 +1365,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	/* If this is the first slave, then we need to set the master's hardware
 	 * address to be the same as the slave's. */
-	if (list_empty(&bond->slave_list) &&
+	if (!bond_has_slaves(bond) &&
 	    bond->dev->addr_assign_type == NET_ADDR_RANDOM)
 		bond_set_dev_addr(bond->dev, slave_dev);
 
@@ -1696,7 +1696,7 @@ err_free:
 err_undo_flags:
 	bond_compute_features(bond);
 	/* Enslave of first slave has failed and we need to fix master's mac */
-	if (list_empty(&bond->slave_list) &&
+	if (!bond_has_slaves(bond) &&
 	    ether_addr_equal(bond_dev->dev_addr, slave_dev->dev_addr))
 		eth_hw_addr_random(bond_dev);
 
@@ -1776,7 +1776,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 
 	if (!all && !bond->params.fail_over_mac) {
 		if (ether_addr_equal(bond_dev->dev_addr, slave->perm_hwaddr) &&
-		    !list_empty(&bond->slave_list))
+		    bond_has_slaves(bond))
 			pr_warn("%s: Warning: the permanent HWaddr of %s - %pM - is still in use by %s. Set the HWaddr of %s to a different address to avoid conflicts.\n",
 				   bond_dev->name, slave_dev->name,
 				   slave->perm_hwaddr,
@@ -1819,7 +1819,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 		write_lock_bh(&bond->lock);
 	}
 
-	if (list_empty(&bond->slave_list)) {
+	if (!bond_has_slaves(bond)) {
 		bond_set_carrier(bond);
 		eth_hw_addr_random(bond_dev);
 
@@ -1835,7 +1835,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 	unblock_netpoll_tx();
 	synchronize_rcu();
 
-	if (list_empty(&bond->slave_list)) {
+	if (!bond_has_slaves(bond)) {
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);
 		call_netdevice_notifiers(NETDEV_RELEASE, bond->dev);
 	}
@@ -1904,7 +1904,7 @@ static int  bond_release_and_destroy(struct net_device *bond_dev,
 	int ret;
 
 	ret = bond_release(bond_dev, slave_dev);
-	if (ret == 0 && list_empty(&bond->slave_list)) {
+	if (ret == 0 && !bond_has_slaves(bond)) {
 		bond_dev->priv_flags |= IFF_DISABLE_NETPOLL;
 		pr_info("%s: destroying bond %s.\n",
 			bond_dev->name, bond_dev->name);
@@ -2219,7 +2219,7 @@ void bond_mii_monitor(struct work_struct *work)
 
 	delay = msecs_to_jiffies(bond->params.miimon);
 
-	if (list_empty(&bond->slave_list))
+	if (!bond_has_slaves(bond))
 		goto re_arm;
 
 	should_notify_peers = bond_should_notify_peers(bond);
@@ -2513,7 +2513,7 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 
 	read_lock(&bond->lock);
 
-	if (list_empty(&bond->slave_list))
+	if (!bond_has_slaves(bond))
 		goto re_arm;
 
 	oldcurrent = bond->curr_active_slave;
@@ -2845,7 +2845,7 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 
 	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
 
-	if (list_empty(&bond->slave_list))
+	if (!bond_has_slaves(bond))
 		goto re_arm;
 
 	should_notify_peers = bond_should_notify_peers(bond);
@@ -3169,7 +3169,7 @@ static int bond_open(struct net_device *bond_dev)
 
 	/* reset slave->backup and slave->inactive */
 	read_lock(&bond->lock);
-	if (!list_empty(&bond->slave_list)) {
+	if (bond_has_slaves(bond)) {
 		read_lock(&bond->curr_slave_lock);
 		bond_for_each_slave(bond, slave, iter) {
 			if ((bond->params.mode == BOND_MODE_ACTIVEBACKUP)
@@ -3892,7 +3892,7 @@ static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 
 	rcu_read_lock();
-	if (!list_empty(&bond->slave_list))
+	if (bond_has_slaves(bond))
 		ret = __bond_start_xmit(skb, dev);
 	else
 		kfree_skb(skb);
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 939148a..5d40889 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -327,7 +327,7 @@ static ssize_t bonding_store_mode(struct device *d,
 		goto out;
 	}
 
-	if (!list_empty(&bond->slave_list)) {
+	if (bond_has_slaves(bond)) {
 		pr_err("unable to update mode of %s because it has slaves.\n",
 			bond->dev->name);
 		ret = -EPERM;
@@ -509,7 +509,7 @@ static ssize_t bonding_store_fail_over_mac(struct device *d,
 	if (!rtnl_trylock())
 		return restart_syscall();
 
-	if (!list_empty(&bond->slave_list)) {
+	if (bond_has_slaves(bond)) {
 		pr_err("%s: Can't alter fail_over_mac with slaves in bond.\n",
 		       bond->dev->name);
 		ret = -EPERM;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index e484c38..2908bd2 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -72,6 +72,8 @@
 	res; })
 
 /* slave list primitives */
+#define bond_has_slaves(bond) !list_empty(&(bond)->slave_list)
+
 #define bond_to_slave(ptr) list_entry(ptr, struct slave, list)
 
 /* IMPORTANT: bond_first/last_slave can return NULL in case of an empty list */
-- 
1.8.4
