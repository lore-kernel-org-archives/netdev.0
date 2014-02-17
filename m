From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v3 net-next 11/12] bonding: trivial: rename slave->jiffies to ->last_link_up
Date: Mon, 17 Feb 2014 14:39:20 +0100
Message-ID: <1392644361-8510-12-git-send-email-vfalico@redhat.com>
References: <1392644361-8510-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40039 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753370AbaBQNog (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Feb 2014 08:44:36 -0500
In-Reply-To: <1392644361-8510-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

slave->jiffies is updated every time the slave becomes active, which, for
bonding, means that its link is 'up'.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c | 20 ++++++++++----------
 drivers/net/bonding/bonding.h   |  3 ++-
 2 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 14e023d..f6d56d9 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -798,7 +798,7 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 		return;
 
 	if (new_active) {
-		new_active->jiffies = jiffies;
+		new_active->last_link_up = jiffies;
 
 		if (new_active->link == BOND_LINK_BACK) {
 			if (USES_PRIMARY(bond->params.mode)) {
@@ -1444,7 +1444,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	}
 
 	if (new_slave->link != BOND_LINK_DOWN)
-		new_slave->jiffies = jiffies;
+		new_slave->last_link_up = jiffies;
 	pr_debug("Initial state of slave_dev is BOND_LINK_%s\n",
 		 new_slave->link == BOND_LINK_DOWN ? "DOWN" :
 		 (new_slave->link == BOND_LINK_UP ? "UP" : "BACK"));
@@ -1891,7 +1891,7 @@ static int bond_miimon_inspect(struct bonding *bond)
 				 * recovered before downdelay expired
 				 */
 				slave->link = BOND_LINK_UP;
-				slave->jiffies = jiffies;
+				slave->last_link_up = jiffies;
 				pr_info("%s: link status up again after %d ms for interface %s\n",
 					bond->dev->name,
 					(bond->params.downdelay - slave->delay) *
@@ -1966,7 +1966,7 @@ static void bond_miimon_commit(struct bonding *bond)
 
 		case BOND_LINK_UP:
 			slave->link = BOND_LINK_UP;
-			slave->jiffies = jiffies;
+			slave->last_link_up = jiffies;
 
 			if (bond->params.mode == BOND_MODE_8023AD) {
 				/* prevent it from being the active one */
@@ -2312,7 +2312,7 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
 		bond_validate_arp(bond, slave, sip, tip);
 	else if (bond->curr_active_slave &&
 		 time_after(slave_last_rx(bond, bond->curr_active_slave),
-			    bond->curr_active_slave->jiffies))
+			    bond->curr_active_slave->last_link_up))
 		bond_validate_arp(bond, slave, tip, sip);
 
 out_unlock:
@@ -2358,9 +2358,9 @@ static void bond_loadbalance_arp_mon(struct work_struct *work)
 	oldcurrent = ACCESS_ONCE(bond->curr_active_slave);
 	/* see if any of the previous devices are up now (i.e. they have
 	 * xmt and rcv traffic). the curr_active_slave does not come into
-	 * the picture unless it is null. also, slave->jiffies is not needed
-	 * here because we send an arp on each slave and give a slave as
-	 * long as it needs to get the tx/rx within the delta.
+	 * the picture unless it is null. also, slave->last_link_up is not
+	 * needed here because we send an arp on each slave and give a slave
+	 * as long as it needs to get the tx/rx within the delta.
 	 * TODO: what about up/down delay in arp mode? it wasn't here before
 	 *       so it can wait
 	 */
@@ -2486,7 +2486,7 @@ static int bond_ab_arp_inspect(struct bonding *bond)
 		 * active.  This avoids bouncing, as the last receive
 		 * times need a full ARP monitor cycle to be updated.
 		 */
-		if (bond_time_in_interval(bond, slave->jiffies, 2))
+		if (bond_time_in_interval(bond, slave->last_link_up, 2))
 			continue;
 
 		/*
@@ -2687,7 +2687,7 @@ static bool bond_ab_arp_probe(struct bonding *bond)
 	new_slave->link = BOND_LINK_BACK;
 	bond_set_slave_active_flags(new_slave);
 	bond_arp_send_all(bond, new_slave);
-	new_slave->jiffies = jiffies;
+	new_slave->last_link_up = jiffies;
 	rcu_assign_pointer(bond->current_arp_slave, new_slave);
 	rtnl_unlock();
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index ae20c5a..36db702 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -188,7 +188,8 @@ struct slave {
 	struct net_device *dev; /* first - useful for panic debug */
 	struct bonding *bond; /* our master */
 	int    delay;
-	unsigned long jiffies;
+	/* all three in jiffies */
+	unsigned long last_link_up;
 	unsigned long last_arp_rx;
 	unsigned long target_last_arp_rx[BOND_MAX_ARP_TARGETS];
 	s8     link;    /* one of BOND_LINK_XXXX */
-- 
1.8.4
