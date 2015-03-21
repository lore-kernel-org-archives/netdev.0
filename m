From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next v2 4/4] bonding: Do not ignore notifications for ARP-work-queue
Date: Fri, 20 Mar 2015 22:39:25 -0700
Message-ID: <1426916365-18444-1-git-send-email-maheshb@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:34552 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138AbbCUFj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 01:39:28 -0400
Received: by padet14 with SMTP id et14so8061413pad.1
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 22:39:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code to reschedule the ARP-work (aggressively)
to handle the notifications before resuming the regular cycle.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_main.c | 43 ++++++++++++++++++++++++-----------------
 1 file changed, 25 insertions(+), 18 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6da311509a2e..ee417ea16787 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2725,7 +2725,7 @@ do_failover:
  *
  * Called with rcu_read_lock held.
  */
-static bool bond_ab_arp_probe(struct bonding *bond)
+static bool bond_ab_arp_probe(struct bonding *bond, bool do_send_arp)
 {
 	struct slave *slave, *before = NULL, *new_slave = NULL,
 		     *curr_arp_slave = rcu_dereference(bond->current_arp_slave),
@@ -2793,7 +2793,8 @@ static bool bond_ab_arp_probe(struct bonding *bond)
 
 	bond_set_slave_link_state(new_slave, BOND_LINK_BACK);
 	bond_set_slave_active_flags(new_slave, BOND_SLAVE_NOTIFY_LATER);
-	bond_arp_send_all(bond, new_slave);
+	if (do_send_arp)
+		bond_arp_send_all(bond, new_slave);
 	new_slave->last_link_up = jiffies;
 	rcu_assign_pointer(bond->current_arp_slave, new_slave);
 
@@ -2813,7 +2814,8 @@ static void bond_activebackup_arp_mon(struct work_struct *work)
 					    arp_work.work);
 	bool should_notify_peers = false;
 	bool should_notify_rtnl = false;
-	int delta_in_ticks;
+	bool do_send_arp = true;
+	unsigned long delta_in_ticks;
 
 	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
 
@@ -2821,8 +2823,11 @@ static void bond_activebackup_arp_mon(struct work_struct *work)
 		goto re_arm;
 
 	rcu_read_lock();
-
 	should_notify_peers = bond_should_notify_peers(bond);
+	if (bond_get_notif_pending(bond, BOND_ARP_NOTIF)) {
+		do_send_arp = false;
+		goto eval_arp_probe;
+	}
 
 	if (bond_ab_arp_inspect(bond)) {
 		rcu_read_unlock();
@@ -2840,25 +2845,27 @@ static void bond_activebackup_arp_mon(struct work_struct *work)
 		rcu_read_lock();
 	}
 
-	should_notify_rtnl = bond_ab_arp_probe(bond);
+eval_arp_probe:
+	should_notify_rtnl = bond_ab_arp_probe(bond, do_send_arp);
 	rcu_read_unlock();
 
 re_arm:
-	if (bond->params.arp_interval)
-		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
-
 	if (should_notify_peers || should_notify_rtnl) {
-		if (!rtnl_trylock())
-			return;
-
-		if (should_notify_peers)
-			call_netdevice_notifiers(NETDEV_NOTIFY_PEERS,
-						 bond->dev);
-		if (should_notify_rtnl)
-			bond_slave_state_notify(bond);
-
-		rtnl_unlock();
+		if (!rtnl_trylock()) {
+			delta_in_ticks = 1;
+			bond_set_notif_pending(bond, BOND_ARP_NOTIF);
+		} else {
+			if (should_notify_rtnl)
+				bond_slave_state_notify(bond);
+			if (should_notify_peers)
+				call_netdevice_notifiers(NETDEV_NOTIFY_PEERS,
+							 bond->dev);
+			rtnl_unlock();
+		}
 	}
+
+	if (bond->params.arp_interval)
+		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
 }
 
 /*-------------------------- netdev event handling --------------------------*/
-- 
2.2.0.rc0.207.ga3a616c
