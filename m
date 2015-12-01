From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 15/26] bonding: allow notifications for bond_set_slave_link_state
Date: Tue,  1 Dec 2015 14:48:53 +0100
Message-ID: <1448977744-17930-16-git-send-email-jiri@resnulli.us>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:38894 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756177AbbLANt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 08:49:27 -0500
Received: by wmec201 with SMTP id c201so14236411wme.1
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 05:49:26 -0800 (PST)
In-Reply-To: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Similar to state notifications.

We allow caller to indicate if the notification should happen now or later,
depending on if he holds rtnl mutex or not. Introduce bond_slave_link_notify
function (similar to bond_slave_state_notify) which is later on called
with rtnl mutex and goes over slaves and executes delayed notification.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/bonding/bond_main.c | 54 +++++++++++++++++++++++++++--------------
 include/net/bonding.h           | 32 +++++++++++++++++++++---
 2 files changed, 65 insertions(+), 21 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 8747746..c9943fc 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -830,7 +830,8 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 			}
 
 			new_active->delay = 0;
-			bond_set_slave_link_state(new_active, BOND_LINK_UP);
+			bond_set_slave_link_state(new_active, BOND_LINK_UP,
+						  BOND_SLAVE_NOTIFY_NOW);
 
 			if (BOND_MODE(bond) == BOND_MODE_8023AD)
 				bond_3ad_handle_link_change(new_active, BOND_LINK_UP);
@@ -1578,21 +1579,26 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		if (bond_check_dev_link(bond, slave_dev, 0) == BMSR_LSTATUS) {
 			if (bond->params.updelay) {
 				bond_set_slave_link_state(new_slave,
-							  BOND_LINK_BACK);
+							  BOND_LINK_BACK,
+							  BOND_SLAVE_NOTIFY_NOW);
 				new_slave->delay = bond->params.updelay;
 			} else {
 				bond_set_slave_link_state(new_slave,
-							  BOND_LINK_UP);
+							  BOND_LINK_UP,
+							  BOND_SLAVE_NOTIFY_NOW);
 			}
 		} else {
-			bond_set_slave_link_state(new_slave, BOND_LINK_DOWN);
+			bond_set_slave_link_state(new_slave, BOND_LINK_DOWN,
+						  BOND_SLAVE_NOTIFY_NOW);
 		}
 	} else if (bond->params.arp_interval) {
 		bond_set_slave_link_state(new_slave,
 					  (netif_carrier_ok(slave_dev) ?
-					  BOND_LINK_UP : BOND_LINK_DOWN));
+					  BOND_LINK_UP : BOND_LINK_DOWN),
+					  BOND_SLAVE_NOTIFY_NOW);
 	} else {
-		bond_set_slave_link_state(new_slave, BOND_LINK_UP);
+		bond_set_slave_link_state(new_slave, BOND_LINK_UP,
+					  BOND_SLAVE_NOTIFY_NOW);
 	}
 
 	if (new_slave->link != BOND_LINK_DOWN)
@@ -2011,7 +2017,8 @@ static int bond_miimon_inspect(struct bonding *bond)
 			if (link_state)
 				continue;
 
-			bond_set_slave_link_state(slave, BOND_LINK_FAIL);
+			bond_set_slave_link_state(slave, BOND_LINK_FAIL,
+						  BOND_SLAVE_NOTIFY_LATER);
 			slave->delay = bond->params.downdelay;
 			if (slave->delay) {
 				netdev_info(bond->dev, "link status down for %sinterface %s, disabling it in %d ms\n",
@@ -2026,7 +2033,8 @@ static int bond_miimon_inspect(struct bonding *bond)
 		case BOND_LINK_FAIL:
 			if (link_state) {
 				/* recovered before downdelay expired */
-				bond_set_slave_link_state(slave, BOND_LINK_UP);
+				bond_set_slave_link_state(slave, BOND_LINK_UP,
+							  BOND_SLAVE_NOTIFY_LATER);
 				slave->last_link_up = jiffies;
 				netdev_info(bond->dev, "link status up again after %d ms for interface %s\n",
 					    (bond->params.downdelay - slave->delay) *
@@ -2048,7 +2056,8 @@ static int bond_miimon_inspect(struct bonding *bond)
 			if (!link_state)
 				continue;
 
-			bond_set_slave_link_state(slave, BOND_LINK_BACK);
+			bond_set_slave_link_state(slave, BOND_LINK_BACK,
+						  BOND_SLAVE_NOTIFY_LATER);
 			slave->delay = bond->params.updelay;
 
 			if (slave->delay) {
@@ -2062,7 +2071,8 @@ static int bond_miimon_inspect(struct bonding *bond)
 		case BOND_LINK_BACK:
 			if (!link_state) {
 				bond_set_slave_link_state(slave,
-							  BOND_LINK_DOWN);
+							  BOND_LINK_DOWN,
+							  BOND_SLAVE_NOTIFY_LATER);
 				netdev_info(bond->dev, "link status down again after %d ms for interface %s\n",
 					    (bond->params.updelay - slave->delay) *
 					    bond->params.miimon,
@@ -2100,7 +2110,8 @@ static void bond_miimon_commit(struct bonding *bond)
 			continue;
 
 		case BOND_LINK_UP:
-			bond_set_slave_link_state(slave, BOND_LINK_UP);
+			bond_set_slave_link_state(slave, BOND_LINK_UP,
+						  BOND_SLAVE_NOTIFY_NOW);
 			slave->last_link_up = jiffies;
 
 			primary = rtnl_dereference(bond->primary_slave);
@@ -2140,7 +2151,8 @@ static void bond_miimon_commit(struct bonding *bond)
 			if (slave->link_failure_count < UINT_MAX)
 				slave->link_failure_count++;
 
-			bond_set_slave_link_state(slave, BOND_LINK_DOWN);
+			bond_set_slave_link_state(slave, BOND_LINK_DOWN,
+						  BOND_SLAVE_NOTIFY_NOW);
 
 			if (BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP ||
 			    BOND_MODE(bond) == BOND_MODE_8023AD)
@@ -2723,7 +2735,8 @@ static void bond_ab_arp_commit(struct bonding *bond)
 				struct slave *current_arp_slave;
 
 				current_arp_slave = rtnl_dereference(bond->current_arp_slave);
-				bond_set_slave_link_state(slave, BOND_LINK_UP);
+				bond_set_slave_link_state(slave, BOND_LINK_UP,
+							  BOND_SLAVE_NOTIFY_NOW);
 				if (current_arp_slave) {
 					bond_set_slave_inactive_flags(
 						current_arp_slave,
@@ -2746,7 +2759,8 @@ static void bond_ab_arp_commit(struct bonding *bond)
 			if (slave->link_failure_count < UINT_MAX)
 				slave->link_failure_count++;
 
-			bond_set_slave_link_state(slave, BOND_LINK_DOWN);
+			bond_set_slave_link_state(slave, BOND_LINK_DOWN,
+						  BOND_SLAVE_NOTIFY_NOW);
 			bond_set_slave_inactive_flags(slave,
 						      BOND_SLAVE_NOTIFY_NOW);
 
@@ -2825,7 +2839,8 @@ static bool bond_ab_arp_probe(struct bonding *bond)
 		 * up when it is actually down
 		 */
 		if (!bond_slave_is_up(slave) && slave->link == BOND_LINK_UP) {
-			bond_set_slave_link_state(slave, BOND_LINK_DOWN);
+			bond_set_slave_link_state(slave, BOND_LINK_DOWN,
+						  BOND_SLAVE_NOTIFY_LATER);
 			if (slave->link_failure_count < UINT_MAX)
 				slave->link_failure_count++;
 
@@ -2845,7 +2860,8 @@ static bool bond_ab_arp_probe(struct bonding *bond)
 	if (!new_slave)
 		goto check_state;
 
-	bond_set_slave_link_state(new_slave, BOND_LINK_BACK);
+	bond_set_slave_link_state(new_slave, BOND_LINK_BACK,
+				  BOND_SLAVE_NOTIFY_LATER);
 	bond_set_slave_active_flags(new_slave, BOND_SLAVE_NOTIFY_LATER);
 	bond_arp_send_all(bond, new_slave);
 	new_slave->last_link_up = jiffies;
@@ -2853,7 +2869,7 @@ static bool bond_ab_arp_probe(struct bonding *bond)
 
 check_state:
 	bond_for_each_slave_rcu(bond, slave, iter) {
-		if (slave->should_notify) {
+		if (slave->should_notify || slave->should_notify_link) {
 			should_notify_rtnl = BOND_SLAVE_NOTIFY_NOW;
 			break;
 		}
@@ -2908,8 +2924,10 @@ re_arm:
 		if (should_notify_peers)
 			call_netdevice_notifiers(NETDEV_NOTIFY_PEERS,
 						 bond->dev);
-		if (should_notify_rtnl)
+		if (should_notify_rtnl) {
 			bond_slave_state_notify(bond);
+			bond_slave_link_notify(bond);
+		}
 
 		rtnl_unlock();
 	}
diff --git a/include/net/bonding.h b/include/net/bonding.h
index c1740a2..50496ec 100644
--- a/include/net/bonding.h
+++ b/include/net/bonding.h
@@ -165,7 +165,8 @@ struct slave {
 	u8     backup:1,   /* indicates backup slave. Value corresponds with
 			      BOND_STATE_ACTIVE and BOND_STATE_BACKUP */
 	       inactive:1, /* indicates inactive slave */
-	       should_notify:1; /* indicateds whether the state changed */
+	       should_notify:1, /* indicateds whether the state changed */
+	       should_notify_link:1; /* indicateds whether the link changed */
 	u8     duplex;
 	u32    original_mtu;
 	u32    link_failure_count;
@@ -504,10 +505,35 @@ static inline bool bond_is_slave_inactive(struct slave *slave)
 	return slave->inactive;
 }
 
-static inline void bond_set_slave_link_state(struct slave *slave, int state)
+static inline void bond_set_slave_link_state(struct slave *slave, int state,
+					     bool notify)
 {
+	if (slave->link == state)
+		return;
+
 	slave->link = state;
-	bond_queue_slave_event(slave);
+	if (notify) {
+		bond_queue_slave_event(slave);
+		slave->should_notify_link = 0;
+	} else {
+		if (slave->should_notify_link)
+			slave->should_notify_link = 0;
+		else
+			slave->should_notify_link = 1;
+	}
+}
+
+static inline void bond_slave_link_notify(struct bonding *bond)
+{
+	struct list_head *iter;
+	struct slave *tmp;
+
+	bond_for_each_slave(bond, tmp, iter) {
+		if (tmp->should_notify_link) {
+			bond_queue_slave_event(tmp);
+			tmp->should_notify_link = 0;
+		}
+	}
 }
 
 static inline __be32 bond_confirm_addr(struct net_device *dev, __be32 dst, __be32 local)
-- 
1.9.3
