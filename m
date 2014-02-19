From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net v2 1/2] bonding: Fix RTNL: assertion failed at net/core/rtnetlink.c for 802.3ad mode
Date: Wed, 19 Feb 2014 17:05:10 +0800
Message-ID: <1392800711-19264-2-git-send-email-dingtianhong@huawei.com>
References: <1392800711-19264-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <cwang@twopensource.com>, <jiri@resnulli.us>,
	<thomas@glanzmann.de>, <eric.dumazet@gmail.com>,
	<sfeldma@cumulusnetworks.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:39940 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752190AbaBSJGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 04:06:41 -0500
In-Reply-To: <1392800711-19264-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The problem was introduced by the commit 1d3ee88ae0d
(bonding: add netlink attributes to slave link dev).
The bond_set_active_slave() and bond_set_backup_slave()
will use rtmsg_ifinfo to send slave's states, so these
two functions should be called in RTNL.

In 802.3ad mode, acquiring RTNL for the __enable_port and
__disable_port cases is difficult, as those calls generally
already hold the state machine lock, and cannot unconditionally
call rtnl_lock because either they already hold RTNL (for calls
via bond_3ad_unbind_slave) or due to the potential for deadlock
with bond_3ad_adapter_speed_changed, bond_3ad_adapter_duplex_changed,
bond_3ad_link_change, or bond_3ad_update_lacp_rate.  All four of
those are called with RTNL held, and acquire the state machine lock
second.  The calling contexts for __enable_port and __disable_port
already hold the state machine lock, and may or may not need RTNL.

According to the Jay's opinion, I don't think it is a problem that
the slave don't send notify message synchronously when the status
changed, normally the state machine is running every 100 ms, send
the notify message at the end of the state machine if the slave's
state changed should be better.

I fix the problem through these steps:

1). add a new function bond_set_slave_state() which could change
    the slave's state and call rtmsg_ifinfo() according to the input
    parameters called notify.

2). Add a new slave parameter which called should_notify, if the slave's state
    changed and don't notify yet, the parameter will be set to 1, and then if
    the slave's state changed again, the param will be set to 0, it indicate that
    the slave's state has been restored, no need to notify any one.

3). the __enable_port and __disable_port should not call rtmsg_ifinfo
    in the state machine lock, any change in the state of slave could
    set a flag in the slave, it will indicated that an rtmsg_ifinfo
    should be called at the end of the state machine.

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_3ad.c  | 22 ++++++++++++++++++++--
 drivers/net/bonding/bond_main.c | 41 ++++++++++++++++++++++++++---------------
 drivers/net/bonding/bonding.h   | 34 +++++++++++++++++++++++++++++-----
 3 files changed, 75 insertions(+), 22 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 6d20fbd..d4ace0b 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -181,7 +181,7 @@ static inline int __agg_has_partner(struct aggregator *agg)
  */
 static inline void __disable_port(struct port *port)
 {
-	bond_set_slave_inactive_flags(port->slave);
+	bond_set_slave_inactive_flags(port->slave, BOND_SLAVE_NOTIFY_LATER);
 }
 
 /**
@@ -193,7 +193,7 @@ static inline void __enable_port(struct port *port)
 	struct slave *slave = port->slave;
 
 	if ((slave->link == BOND_LINK_UP) && IS_UP(slave->dev))
-		bond_set_slave_active_flags(slave);
+		bond_set_slave_active_flags(slave, BOND_SLAVE_NOTIFY_LATER);
 }
 
 /**
@@ -2062,6 +2062,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	struct list_head *iter;
 	struct slave *slave;
 	struct port *port;
+	int slave_should_notify = 0;
 
 	read_lock(&bond->lock);
 	rcu_read_lock();
@@ -2119,8 +2120,25 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	}
 
 re_arm:
+	bond_for_each_slave_rcu(bond, slave, iter) {
+		if (slave->should_notify) {
+			slave_should_notify = 1;
+			break;
+		}
+	}
 	rcu_read_unlock();
 	read_unlock(&bond->lock);
+
+	if (slave_should_notify && rtnl_trylock()) {
+		bond_for_each_slave(bond, slave, iter) {
+			if (slave->should_notify) {
+				rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0,
+					     GFP_KERNEL);
+				slave->should_notify = 0;
+			}
+		}
+		rtnl_unlock();
+	}
 	queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
 }
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1c6104d..e02029b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -829,21 +829,25 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 	if (bond_is_lb(bond)) {
 		bond_alb_handle_active_change(bond, new_active);
 		if (old_active)
-			bond_set_slave_inactive_flags(old_active);
+			bond_set_slave_inactive_flags(old_active,
+						      BOND_SLAVE_NOTIFY_NOW);
 		if (new_active)
-			bond_set_slave_active_flags(new_active);
+			bond_set_slave_active_flags(new_active,
+						    BOND_SLAVE_NOTIFY_NOW);
 	} else {
 		rcu_assign_pointer(bond->curr_active_slave, new_active);
 	}
 
 	if (bond->params.mode == BOND_MODE_ACTIVEBACKUP) {
 		if (old_active)
-			bond_set_slave_inactive_flags(old_active);
+			bond_set_slave_inactive_flags(old_active,
+						      BOND_SLAVE_NOTIFY_NOW);
 
 		if (new_active) {
 			bool should_notify_peers = false;
 
-			bond_set_slave_active_flags(new_active);
+			bond_set_slave_active_flags(new_active,
+						    BOND_SLAVE_NOTIFY_NOW);
 
 			if (bond->params.fail_over_mac)
 				bond_do_fail_over_mac(bond, new_active,
@@ -1463,14 +1467,15 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	switch (bond->params.mode) {
 	case BOND_MODE_ACTIVEBACKUP:
-		bond_set_slave_inactive_flags(new_slave);
+		bond_set_slave_inactive_flags(new_slave,
+					      BOND_SLAVE_NOTIFY_NOW);
 		break;
 	case BOND_MODE_8023AD:
 		/* in 802.3ad mode, the internal mechanism
 		 * will activate the slaves in the selected
 		 * aggregator
 		 */
-		bond_set_slave_inactive_flags(new_slave);
+		bond_set_slave_inactive_flags(new_slave, BOND_SLAVE_NOTIFY_NOW);
 		/* if this is the first slave */
 		if (!prev_slave) {
 			SLAVE_AD_INFO(new_slave).id = 1;
@@ -1488,7 +1493,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	case BOND_MODE_TLB:
 	case BOND_MODE_ALB:
 		bond_set_active_slave(new_slave);
-		bond_set_slave_inactive_flags(new_slave);
+		bond_set_slave_inactive_flags(new_slave, BOND_SLAVE_NOTIFY_NOW);
 		break;
 	default:
 		pr_debug("This slave is always active in trunk mode\n");
@@ -2015,7 +2020,8 @@ static void bond_miimon_commit(struct bonding *bond)
 
 			if (bond->params.mode == BOND_MODE_ACTIVEBACKUP ||
 			    bond->params.mode == BOND_MODE_8023AD)
-				bond_set_slave_inactive_flags(slave);
+				bond_set_slave_inactive_flags(slave,
+							      BOND_SLAVE_NOTIFY_NOW);
 
 			pr_info("%s: link status definitely down for interface %s, disabling it\n",
 				bond->dev->name, slave->dev->name);
@@ -2562,7 +2568,8 @@ static void bond_ab_arp_commit(struct bonding *bond)
 				slave->link = BOND_LINK_UP;
 				if (bond->current_arp_slave) {
 					bond_set_slave_inactive_flags(
-						bond->current_arp_slave);
+						bond->current_arp_slave,
+						BOND_SLAVE_NOTIFY_NOW);
 					bond->current_arp_slave = NULL;
 				}
 
@@ -2582,7 +2589,8 @@ static void bond_ab_arp_commit(struct bonding *bond)
 				slave->link_failure_count++;
 
 			slave->link = BOND_LINK_DOWN;
-			bond_set_slave_inactive_flags(slave);
+			bond_set_slave_inactive_flags(slave,
+						      BOND_SLAVE_NOTIFY_NOW);
 
 			pr_info("%s: link status definitely down for interface %s, disabling it\n",
 				bond->dev->name, slave->dev->name);
@@ -2657,7 +2665,7 @@ static bool bond_ab_arp_probe(struct bonding *bond)
 		}
 	}
 
-	bond_set_slave_inactive_flags(curr_arp_slave);
+	bond_set_slave_inactive_flags(curr_arp_slave, BOND_SLAVE_NOTIFY_NOW);
 
 	bond_for_each_slave(bond, slave, iter) {
 		if (!found && !before && IS_UP(slave->dev))
@@ -2677,7 +2685,8 @@ static bool bond_ab_arp_probe(struct bonding *bond)
 			if (slave->link_failure_count < UINT_MAX)
 				slave->link_failure_count++;
 
-			bond_set_slave_inactive_flags(slave);
+			bond_set_slave_inactive_flags(slave,
+						      BOND_SLAVE_NOTIFY_NOW);
 
 			pr_info("%s: backup interface %s is now down.\n",
 				bond->dev->name, slave->dev->name);
@@ -2695,7 +2704,7 @@ static bool bond_ab_arp_probe(struct bonding *bond)
 	}
 
 	new_slave->link = BOND_LINK_BACK;
-	bond_set_slave_active_flags(new_slave);
+	bond_set_slave_active_flags(new_slave, BOND_SLAVE_NOTIFY_NOW);
 	bond_arp_send_all(bond, new_slave);
 	new_slave->jiffies = jiffies;
 	rcu_assign_pointer(bond->current_arp_slave, new_slave);
@@ -3046,9 +3055,11 @@ static int bond_open(struct net_device *bond_dev)
 		bond_for_each_slave(bond, slave, iter) {
 			if ((bond->params.mode == BOND_MODE_ACTIVEBACKUP)
 				&& (slave != bond->curr_active_slave)) {
-				bond_set_slave_inactive_flags(slave);
+				bond_set_slave_inactive_flags(slave,
+							      BOND_SLAVE_NOTIFY_NOW);
 			} else {
-				bond_set_slave_active_flags(slave);
+				bond_set_slave_active_flags(slave,
+							    BOND_SLAVE_NOTIFY_NOW);
 			}
 		}
 		read_unlock(&bond->curr_slave_lock);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 86ccfb9..b4e6c53 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -195,7 +195,8 @@ struct slave {
 	s8     new_link;
 	u8     backup:1,   /* indicates backup slave. Value corresponds with
 			      BOND_STATE_ACTIVE and BOND_STATE_BACKUP */
-	       inactive:1; /* indicates inactive slave */
+	       inactive:1, /* indicates inactive slave */
+	       should_notify:1; /* indicateds whether the state changed */
 	u8     duplex;
 	u32    original_mtu;
 	u32    link_failure_count;
@@ -303,6 +304,24 @@ static inline void bond_set_backup_slave(struct slave *slave)
 	}
 }
 
+static inline void bond_set_slave_state(struct slave *slave,
+					int slave_state, bool notify)
+{
+	if (slave->backup == slave_state)
+		return;
+
+	slave->backup = slave_state;
+	if (notify) {
+		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_KERNEL);
+		slave->should_notify = 0;
+	} else {
+		if (slave->should_notify)
+			slave->should_notify = 0;
+		else
+			slave->should_notify = 1;
+	}
+}
+
 static inline void bond_slave_state_change(struct bonding *bond)
 {
 	struct list_head *iter;
@@ -343,6 +362,9 @@ static inline bool bond_is_active_slave(struct slave *slave)
 #define BOND_ARP_VALIDATE_ALL		(BOND_ARP_VALIDATE_ACTIVE | \
 					 BOND_ARP_VALIDATE_BACKUP)
 
+#define BOND_SLAVE_NOTIFY_NOW		true
+#define BOND_SLAVE_NOTIFY_LATER	false
+
 static inline int slave_do_arp_validate(struct bonding *bond,
 					struct slave *slave)
 {
@@ -394,17 +416,19 @@ static inline void bond_netpoll_send_skb(const struct slave *slave,
 }
 #endif
 
-static inline void bond_set_slave_inactive_flags(struct slave *slave)
+static inline void bond_set_slave_inactive_flags(struct slave *slave,
+						 bool notify)
 {
 	if (!bond_is_lb(slave->bond))
-		bond_set_backup_slave(slave);
+		bond_set_slave_state(slave, BOND_STATE_BACKUP, notify);
 	if (!slave->bond->params.all_slaves_active)
 		slave->inactive = 1;
 }
 
-static inline void bond_set_slave_active_flags(struct slave *slave)
+static inline void bond_set_slave_active_flags(struct slave *slave,
+					       bool notify)
 {
-	bond_set_active_slave(slave);
+	bond_set_slave_state(slave, BOND_STATE_ACTIVE, notify);
 	slave->inactive = 0;
 }
 
-- 
1.8.0
