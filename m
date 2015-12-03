From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 17/28] bonding: allow notifications for bond_set_slave_link_state
Date: Thu,  3 Dec 2015 12:12:19 +0100
Message-ID: <1449141150-8172-18-git-send-email-jiri@resnulli.us>
References: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:38793 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759873AbbLCLM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 06:12:58 -0500
Received: by wmec201 with SMTP id c201so17318779wme.1
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 03:12:57 -0800 (PST)
In-Reply-To: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
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
v1->v2:
- s/indicateds/indicates/ typo in comment suggested by Nik
---
 drivers/net/bonding/bond_main.c | 54 +++++++++++++++++++++++++++--------------
 include/net/bonding.h           | 32 +++++++++++++++++++++---
 2 files changed, 65 insertions(+), 21 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e94e79a..7695490 100644
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
@@ -1580,21 +1581,26 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
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
@@ -2013,7 +2019,8 @@ static int bond_miimon_inspect(struct bonding *bond)
 			if (link_state)
 				continue;
 
-			bond_set_slave_link_state(slave, BOND_LINK_FAIL);
+			bond_set_slave_link_state(slave, BOND_LINK_FAIL,
+						  BOND_SLAVE_NOTIFY_LATER);
 			slave->delay = bond->params.downdelay;
 			if (slave->delay) {
 				netdev_info(bond->dev, "link status down for %sinterface %s, disabling it in %d ms\n",
@@ -2028,7 +2035,8 @@ static int bond_miimon_inspect(struct bonding *bond)
 		case BOND_LINK_FAIL:
 			if (link_state) {
 				/* recovered before downdelay expired */
-				bond_set_slave_link_state(slave, BOND_LINK_UP);
+				bond_set_slave_link_state(slave, BOND_LINK_UP,
+							  BOND_SLAVE_NOTIFY_LATER);
 				slave->last_link_up = jiffies;
 				netdev_info(bond->dev, "link status up again after %d ms for interface %s\n",
 					    (bond->params.downdelay - slave->delay) *
@@ -2050,7 +2058,8 @@ static int bond_miimon_inspect(struct bonding *bond)
 			if (!link_state)
 				continue;
 
-			bond_set_slave_link_state(slave, BOND_LINK_BACK);
+			bond_set_slave_link_state(slave, BOND_LINK_BACK,
+						  BOND_SLAVE_NOTIFY_LATER);
 			slave->delay = bond->params.updelay;
 
 			if (slave->delay) {
@@ -2064,7 +2073,8 @@ static int bond_miimon_inspect(struct bonding *bond)
 		case BOND_LINK_BACK:
 			if (!link_state) {
 				bond_set_slave_link_state(slave,
-							  BOND_LINK_DOWN);
+							  BOND_LINK_DOWN,
+							  BOND_SLAVE_NOTIFY_LATER);
 				netdev_info(bond->dev, "link status down again after %d ms for interface %s\n",
 					    (bond->params.updelay - slave->delay) *
 					    bond->params.miimon,
@@ -2102,7 +2112,8 @@ static void bond_miimon_commit(struct bonding *bond)
 			continue;
 
 		case BOND_LINK_UP:
-			bond_set_slave_link_state(slave, BOND_LINK_UP);
+			bond_set_slave_link_state(slave, BOND_LINK_UP,
+						  BOND_SLAVE_NOTIFY_NOW);
 			slave->last_link_up = jiffies;
 
 			primary = rtnl_dereference(bond->primary_slave);
@@ -2142,7 +2153,8 @@ static void bond_miimon_commit(struct bonding *bond)
 			if (slave->link_failure_count < UINT_MAX)
 				slave->link_failure_count++;
 
-			bond_set_slave_link_state(slave, BOND_LINK_DOWN);
+			bond_set_slave_link_state(slave, BOND_LINK_DOWN,
+						  BOND_SLAVE_NOTIFY_NOW);
 
 			if (BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP ||
 			    BOND_MODE(bond) == BOND_MODE_8023AD)
@@ -2725,7 +2737,8 @@ static void bond_ab_arp_commit(struct bonding *bond)
 				struct slave *current_arp_slave;
 
 				current_arp_slave = rtnl_dereference(bond->current_arp_slave);
-				bond_set_slave_link_state(slave, BOND_LINK_UP);
+				bond_set_slave_link_state(slave, BOND_LINK_UP,
+							  BOND_SLAVE_NOTIFY_NOW);
 				if (current_arp_slave) {
 					bond_set_slave_inactive_flags(
 						current_arp_slave,
@@ -2748,7 +2761,8 @@ static void bond_ab_arp_commit(struct bonding *bond)
 			if (slave->link_failure_count < UINT_MAX)
 				slave->link_failure_count++;
 
-			bond_set_slave_link_state(slave, BOND_LINK_DOWN);
+			bond_set_slave_link_state(slave, BOND_LINK_DOWN,
+						  BOND_SLAVE_NOTIFY_NOW);
 			bond_set_slave_inactive_flags(slave,
 						      BOND_SLAVE_NOTIFY_NOW);
 
@@ -2827,7 +2841,8 @@ static bool bond_ab_arp_probe(struct bonding *bond)
 		 * up when it is actually down
 		 */
 		if (!bond_slave_is_up(slave) && slave->link == BOND_LINK_UP) {
-			bond_set_slave_link_state(slave, BOND_LINK_DOWN);
+			bond_set_slave_link_state(slave, BOND_LINK_DOWN,
+						  BOND_SLAVE_NOTIFY_LATER);
 			if (slave->link_failure_count < UINT_MAX)
 				slave->link_failure_count++;
 
@@ -2847,7 +2862,8 @@ static bool bond_ab_arp_probe(struct bonding *bond)
 	if (!new_slave)
 		goto check_state;
 
-	bond_set_slave_link_state(new_slave, BOND_LINK_BACK);
+	bond_set_slave_link_state(new_slave, BOND_LINK_BACK,
+				  BOND_SLAVE_NOTIFY_LATER);
 	bond_set_slave_active_flags(new_slave, BOND_SLAVE_NOTIFY_LATER);
 	bond_arp_send_all(bond, new_slave);
 	new_slave->last_link_up = jiffies;
@@ -2855,7 +2871,7 @@ static bool bond_ab_arp_probe(struct bonding *bond)
 
 check_state:
 	bond_for_each_slave_rcu(bond, slave, iter) {
-		if (slave->should_notify) {
+		if (slave->should_notify || slave->should_notify_link) {
 			should_notify_rtnl = BOND_SLAVE_NOTIFY_NOW;
 			break;
 		}
@@ -2910,8 +2926,10 @@ re_arm:
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
index c1740a2..1df4377 100644
--- a/include/net/bonding.h
+++ b/include/net/bonding.h
@@ -165,7 +165,8 @@ struct slave {
 	u8     backup:1,   /* indicates backup slave. Value corresponds with
 			      BOND_STATE_ACTIVE and BOND_STATE_BACKUP */
 	       inactive:1, /* indicates inactive slave */
-	       should_notify:1; /* indicateds whether the state changed */
+	       should_notify:1, /* indicates whether the state changed */
+	       should_notify_link:1; /* indicates whether the link changed */
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
