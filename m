From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH] bonding: don't call update_speed_duplex() under spinlocks
Date: Tue, 12 Mar 2013 17:31:32 +0100
Message-ID: <1363105892-3172-1-git-send-email-vfalico@redhat.com>
Cc: vfalico@redhat.com, lkml@tlinx.org, eric.dumazet@gmail.com,
	fubar@us.ibm.com, jeffrey.t.kirsher@intel.com,
	xiyou.wangcong@gmail.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25397 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755150Ab3CLQbr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Mar 2013 12:31:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bond_update_speed_duplex() might sleep while calling underlying slave's
routines. Move it out of atomic context in bond_enslave() and remove it
from bond_miimon_commit() - it was introduced by commit 546add79, however
when the slave interfaces go up/change state it's their responsibility to
fire NETDEV_UP/NETDEV_CHANGE events so that bonding can properly update
their speed.

I've tested it on all combinations of ifup/ifdown, autoneg/speed/duplex
changes, remote-controlled and local, on (not) MII-based cards. All changes
are visible.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 8b4e96e..6bbd90e 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1746,6 +1746,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	bond_compute_features(bond);
 
+	bond_update_speed_duplex(new_slave);
+
 	read_lock(&bond->lock);
 
 	new_slave->last_arp_rx = jiffies -
@@ -1798,8 +1800,6 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		new_slave->link == BOND_LINK_DOWN ? "DOWN" :
 			(new_slave->link == BOND_LINK_UP ? "UP" : "BACK"));
 
-	bond_update_speed_duplex(new_slave);
-
 	if (USES_PRIMARY(bond->params.mode) && bond->params.primary[0]) {
 		/* if there is a primary slave, remember it */
 		if (strcmp(bond->params.primary, new_slave->dev->name) == 0) {
@@ -2374,8 +2374,6 @@ static void bond_miimon_commit(struct bonding *bond)
 				bond_set_backup_slave(slave);
 			}
 
-			bond_update_speed_duplex(slave);
-
 			pr_info("%s: link status definitely up for interface %s, %u Mbps %s duplex.\n",
 				bond->dev->name, slave->dev->name,
 				slave->speed, slave->duplex ? "full" : "half");
-- 
1.7.1
