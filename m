From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 1/5] bonding: restructure arp-monitor
Date: Wed,  8 Mar 2017 10:55:51 -0800
Message-ID: <20170308185551.22934-1-mahesh@bandewar.net>
Cc: netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Veaceslav Falico <vfalico@gmail.com>,
        Nikolay Aleksandrov <nikolay@redhat.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35119 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753949AbdCHTEA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 14:04:00 -0500
Received: by mail-pg0-f66.google.com with SMTP id 187so4221882pgb.2
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 11:03:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

In preparation to move the work-queue initialization to port creation
from current port_open phase. Work-queue initialization does not make
sense every time we do 'ifup/ifdown'. So moving to port creation phase.

Arp monitoring work depends on the bonding mode and that is not tied
to the port creation and can change anytime during the life after port
creation. So this restructuring allows us to move the initialization
at creation without losing the ability to arm the correct work for the
mode user has selected.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_main.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 8a4ba8b88e52..619f0c65f18a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2575,10 +2575,8 @@ static bool bond_time_in_interval(struct bonding *bond, unsigned long last_act,
  * arp is transmitted to generate traffic. see activebackup_arp_monitor for
  * arp monitoring in active backup mode.
  */
-static void bond_loadbalance_arp_mon(struct work_struct *work)
+static void bond_loadbalance_arp_mon(struct bonding *bond)
 {
-	struct bonding *bond = container_of(work, struct bonding,
-					    arp_work.work);
 	struct slave *slave, *oldcurrent;
 	struct list_head *iter;
 	int do_failover = 0, slave_state_changed = 0;
@@ -2916,10 +2914,8 @@ static bool bond_ab_arp_probe(struct bonding *bond)
 	return should_notify_rtnl;
 }
 
-static void bond_activebackup_arp_mon(struct work_struct *work)
+static void bond_activebackup_arp_mon(struct bonding *bond)
 {
-	struct bonding *bond = container_of(work, struct bonding,
-					    arp_work.work);
 	bool should_notify_peers = false;
 	bool should_notify_rtnl = false;
 	int delta_in_ticks;
@@ -2972,6 +2968,17 @@ static void bond_activebackup_arp_mon(struct work_struct *work)
 	}
 }
 
+static void bond_arp_monitor(struct work_struct *work)
+{
+	struct bonding *bond = container_of(work, struct bonding,
+					    arp_work.work);
+
+	if (BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP)
+		bond_activebackup_arp_mon(bond);
+	else
+		bond_loadbalance_arp_mon(bond);
+}
+
 /*-------------------------- netdev event handling --------------------------*/
 
 /* Change device name */
@@ -3228,10 +3235,7 @@ static void bond_work_init_all(struct bonding *bond)
 			  bond_resend_igmp_join_requests_delayed);
 	INIT_DELAYED_WORK(&bond->alb_work, bond_alb_monitor);
 	INIT_DELAYED_WORK(&bond->mii_work, bond_mii_monitor);
-	if (BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP)
-		INIT_DELAYED_WORK(&bond->arp_work, bond_activebackup_arp_mon);
-	else
-		INIT_DELAYED_WORK(&bond->arp_work, bond_loadbalance_arp_mon);
+	INIT_DELAYED_WORK(&bond->arp_work, bond_arp_monitor);
 	INIT_DELAYED_WORK(&bond->ad_work, bond_3ad_state_machine_handler);
 	INIT_DELAYED_WORK(&bond->slave_arr_work, bond_slave_arr_handler);
 }
-- 
2.12.0.246.ga2ecc84866-goog
