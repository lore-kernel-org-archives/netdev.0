From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next 4/4] bonding: Do not ignore notifications for ARP-work-queue
Date: Wed, 11 Mar 2015 22:54:39 -0700
Message-ID: <1426139679-27249-1-git-send-email-maheshb@google.com>
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
Received: from mail-oi0-f74.google.com ([209.85.218.74]:34159 "EHLO
	mail-oi0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833AbbCLFym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 01:54:42 -0400
Received: by oifu20 with SMTP id u20so3834381oif.1
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 22:54:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code to reschedule the ARP-work (aggressively)
to handle the notifications before resuming the regular cycle.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_main.c | 38 ++++++++++++++++++++++----------------
 1 file changed, 22 insertions(+), 16 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 54ecb7a22bae..882974d543d2 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2814,17 +2814,20 @@ static void bond_activebackup_arp_mon(struct work_struct *work)
 					    arp_work.work);
 	bool should_notify_peers = false;
 	bool should_notify_rtnl = false;
-	int delta_in_ticks;
+	unsigned long delta_in_ticks;
 
 	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
 
 	if (!bond_has_slaves(bond))
 		goto re_arm;
 
-	rcu_read_lock();
-
 	should_notify_peers = bond_should_notify_peers(bond);
+	if (bond_get_notif_pending(bond, BOND_ARP_NOTIF)) {
+		rcu_read_lock();
+		goto eval_arp_probe;
+	}
 
+	rcu_read_lock();
 	if (bond_ab_arp_inspect(bond)) {
 		rcu_read_unlock();
 
@@ -2841,25 +2844,28 @@ static void bond_activebackup_arp_mon(struct work_struct *work)
 		rcu_read_lock();
 	}
 
+eval_arp_probe:
 	should_notify_rtnl = bond_ab_arp_probe(bond);
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
+			bond_set_notif_pending(bond, BOND_ARP_NOTIF, 1);
+		} else {
+			if (should_notify_rtnl)
+				bond_slave_state_notify(bond);
+			if (should_notify_peers)
+				call_netdevice_notifiers(NETDEV_NOTIFY_PEERS,
+							 bond->dev);
+			rtnl_unlock();
+			bond_set_notif_pending(bond, BOND_ARP_NOTIF, 0);
+		}
 	}
+
+	if (bond->params.arp_interval)
+		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
 }
 
 /*-------------------------- netdev event handling --------------------------*/
-- 
2.2.0.rc0.207.ga3a616c
