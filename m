From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH v2 net-next 4/9] bonding: make USES_PRIMARY inline function
Date: Thu, 15 May 2014 14:29:22 +0200
Message-ID: <1400156967-8231-5-git-send-email-vfalico@gmail.com>
References: <1400156967-8231-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63403 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754096AbaEOMeJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 08:34:09 -0400
In-Reply-To: <1400156967-8231-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change the name a bit to better reflect its scope, and update some
comments.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bond_main.c    | 38 +++++++++++++++++++-------------------
 drivers/net/bonding/bond_options.c |  2 +-
 drivers/net/bonding/bond_procfs.c  |  2 +-
 drivers/net/bonding/bonding.h      | 12 ++++++------
 4 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2448e28..17b68b5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -497,7 +497,7 @@ static int bond_set_promiscuity(struct bonding *bond, int inc)
 	struct list_head *iter;
 	int err = 0;
 
-	if (USES_PRIMARY(bond->params.mode)) {
+	if (bond_mode_uses_primary(bond->params.mode)) {
 		/* write lock already acquired */
 		if (bond->curr_active_slave) {
 			err = dev_set_promiscuity(bond->curr_active_slave->dev,
@@ -523,7 +523,7 @@ static int bond_set_allmulti(struct bonding *bond, int inc)
 	struct list_head *iter;
 	int err = 0;
 
-	if (USES_PRIMARY(bond->params.mode)) {
+	if (bond_mode_uses_primary(bond->params.mode)) {
 		/* write lock already acquired */
 		if (bond->curr_active_slave) {
 			err = dev_set_allmulti(bond->curr_active_slave->dev,
@@ -585,8 +585,8 @@ static void bond_hw_addr_flush(struct net_device *bond_dev,
 /*--------------------------- Active slave change ---------------------------*/
 
 /* Update the hardware address list and promisc/allmulti for the new and
- * old active slaves (if any).  Modes that are !USES_PRIMARY keep all
- * slaves up date at all times; only the USES_PRIMARY modes need to call
+ * old active slaves (if any).  Modes that are not using primary keep all
+ * slaves up date at all times; only the modes that use primary need to call
  * this function to swap these settings during a failover.
  */
 static void bond_hw_addr_swap(struct bonding *bond, struct slave *new_active,
@@ -801,7 +801,7 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 		new_active->last_link_up = jiffies;
 
 		if (new_active->link == BOND_LINK_BACK) {
-			if (USES_PRIMARY(bond->params.mode)) {
+			if (bond_mode_uses_primary(bond->params.mode)) {
 				pr_info("%s: making interface %s the new active one %d ms earlier\n",
 					bond->dev->name, new_active->dev->name,
 					(bond->params.updelay - new_active->delay) * bond->params.miimon);
@@ -816,14 +816,14 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 			if (bond_is_lb(bond))
 				bond_alb_handle_link_change(bond, new_active, BOND_LINK_UP);
 		} else {
-			if (USES_PRIMARY(bond->params.mode)) {
+			if (bond_mode_uses_primary(bond->params.mode)) {
 				pr_info("%s: making interface %s the new active one\n",
 					bond->dev->name, new_active->dev->name);
 			}
 		}
 	}
 
-	if (USES_PRIMARY(bond->params.mode))
+	if (bond_mode_uses_primary(bond->params.mode))
 		bond_hw_addr_swap(bond, new_active, old_active);
 
 	if (bond_is_lb(bond)) {
@@ -876,7 +876,7 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 	 * resend only if bond is brought up with the affected
 	 * bonding modes and the retransmission is enabled */
 	if (netif_running(bond->dev) && (bond->params.resend_igmp > 0) &&
-	    ((USES_PRIMARY(bond->params.mode) && new_active) ||
+	    ((bond_mode_uses_primary(bond->params.mode) && new_active) ||
 	     bond->params.mode == BOND_MODE_ROUNDROBIN)) {
 		bond->igmp_retrans = bond->params.resend_igmp;
 		queue_delayed_work(bond->wq, &bond->mcast_work, 1);
@@ -1381,10 +1381,10 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 			goto err_close;
 	}
 
-	/* If the mode USES_PRIMARY, then the following is handled by
+	/* If the mode uses primary, then the following is handled by
 	 * bond_change_active_slave().
 	 */
-	if (!USES_PRIMARY(bond->params.mode)) {
+	if (!bond_mode_uses_primary(bond->params.mode)) {
 		/* set promiscuity level to new slave */
 		if (bond_dev->flags & IFF_PROMISC) {
 			res = dev_set_promiscuity(slave_dev, 1);
@@ -1480,7 +1480,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		 new_slave->link == BOND_LINK_DOWN ? "DOWN" :
 		 (new_slave->link == BOND_LINK_UP ? "UP" : "BACK"));
 
-	if (USES_PRIMARY(bond->params.mode) && bond->params.primary[0]) {
+	if (bond_mode_uses_primary(bond->params.mode) && bond->params.primary[0]) {
 		/* if there is a primary slave, remember it */
 		if (strcmp(bond->params.primary, new_slave->dev->name) == 0) {
 			bond->primary_slave = new_slave;
@@ -1569,7 +1569,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	bond_compute_features(bond);
 	bond_set_carrier(bond);
 
-	if (USES_PRIMARY(bond->params.mode)) {
+	if (bond_mode_uses_primary(bond->params.mode)) {
 		block_netpoll_tx();
 		write_lock_bh(&bond->curr_slave_lock);
 		bond_select_active_slave(bond);
@@ -1593,7 +1593,7 @@ err_unregister:
 	netdev_rx_handler_unregister(slave_dev);
 
 err_detach:
-	if (!USES_PRIMARY(bond->params.mode))
+	if (!bond_mode_uses_primary(bond->params.mode))
 		bond_hw_addr_flush(bond_dev, slave_dev);
 
 	vlan_vids_del_by_dev(slave_dev, bond_dev);
@@ -1778,10 +1778,10 @@ static int __bond_release_one(struct net_device *bond_dev,
 	/* must do this from outside any spinlocks */
 	vlan_vids_del_by_dev(slave_dev, bond_dev);
 
-	/* If the mode USES_PRIMARY, then this cases was handled above by
+	/* If the mode uses primary, then this cases was handled above by
 	 * bond_change_active_slave(..., NULL)
 	 */
-	if (!USES_PRIMARY(bond->params.mode)) {
+	if (!bond_mode_uses_primary(bond->params.mode)) {
 		/* unset promiscuity level from slave
 		 * NOTE: The NETDEV_CHANGEADDR call above may change the value
 		 * of the IFF_PROMISC flag in the bond_dev, but we need the
@@ -2915,7 +2915,7 @@ static int bond_slave_netdev_event(unsigned long event,
 		break;
 	case NETDEV_CHANGENAME:
 		/* we don't care if we don't have primary set */
-		if (!USES_PRIMARY(bond->params.mode) ||
+		if (!bond_mode_uses_primary(bond->params.mode) ||
 		    !bond->params.primary[0])
 			break;
 
@@ -3105,7 +3105,7 @@ static int bond_open(struct net_device *bond_dev)
 	if (bond_has_slaves(bond)) {
 		read_lock(&bond->curr_slave_lock);
 		bond_for_each_slave(bond, slave, iter) {
-			if (USES_PRIMARY(bond->params.mode)
+			if (bond_mode_uses_primary(bond->params.mode)
 				&& (slave != bond->curr_active_slave)) {
 				bond_set_slave_inactive_flags(slave,
 							      BOND_SLAVE_NOTIFY_NOW);
@@ -3343,7 +3343,7 @@ static void bond_set_rx_mode(struct net_device *bond_dev)
 
 
 	rcu_read_lock();
-	if (USES_PRIMARY(bond->params.mode)) {
+	if (bond_mode_uses_primary(bond->params.mode)) {
 		slave = rcu_dereference(bond->curr_active_slave);
 		if (slave) {
 			dev_uc_sync(slave->dev, bond_dev);
@@ -4268,7 +4268,7 @@ static int bond_check_params(struct bond_params *params)
 		pr_debug("Warning: either miimon or arp_interval and arp_ip_target module parameters must be specified, otherwise bonding will not detect link failures! see bonding.txt for details\n");
 	}
 
-	if (primary && !USES_PRIMARY(bond_mode)) {
+	if (primary && !bond_mode_uses_primary(bond_mode)) {
 		/* currently, using a primary only makes sense
 		 * in active backup, TLB or ALB modes
 		 */
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 98c8801..afae661 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -693,7 +693,7 @@ int bond_option_mode_set(struct bonding *bond, const struct bond_opt_value *newv
 static struct net_device *__bond_option_active_slave_get(struct bonding *bond,
 							 struct slave *slave)
 {
-	return USES_PRIMARY(bond->params.mode) && slave ? slave->dev : NULL;
+	return bond_mode_uses_primary(bond->params.mode) && slave ? slave->dev : NULL;
 }
 
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond)
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index 6a261c8..7cf55a5 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -91,7 +91,7 @@ static void bond_info_show_master(struct seq_file *seq)
 			   optval->string, bond->params.xmit_policy);
 	}
 
-	if (USES_PRIMARY(bond->params.mode)) {
+	if (bond_mode_uses_primary(bond->params.mode)) {
 		seq_printf(seq, "Primary Slave: %s",
 			   (bond->primary_slave) ?
 			   bond->primary_slave->dev->name : "None");
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 8f9f0df..34a8ed5 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -54,12 +54,6 @@
 		     ((slave)->link == BOND_LINK_UP) && \
 		     bond_is_active_slave(slave))
 
-
-#define USES_PRIMARY(mode)				\
-		(((mode) == BOND_MODE_ACTIVEBACKUP) ||	\
-		 ((mode) == BOND_MODE_TLB)          ||	\
-		 ((mode) == BOND_MODE_ALB))
-
 #define IS_IP_TARGET_UNUSABLE_ADDRESS(a)	\
 	((htonl(INADDR_BROADCAST) == a) ||	\
 	 ipv4_is_zeronet(a))
@@ -293,6 +287,12 @@ static inline bool bond_mode_uses_arp(int mode)
 	       mode == BOND_MODE_ALB;
 }
 
+static inline bool bond_mode_uses_primary(int mode)
+{
+	return mode == BOND_MODE_ACTIVEBACKUP || mode == BOND_MODE_TLB ||
+	       mode == BOND_MODE_ALB;
+}
+
 static inline void bond_set_active_slave(struct slave *slave)
 {
 	if (slave->backup) {
-- 
1.8.4
