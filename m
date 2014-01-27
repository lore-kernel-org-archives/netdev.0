From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v3 net-next 1/2] bonding: RCUify bond_ab_arp_probe
Date: Mon, 27 Jan 2014 14:33:32 +0100
Message-ID: <1390829613-1842-2-git-send-email-vfalico@redhat.com>
References: <1390829613-1842-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24491 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751431AbaA0Nhw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jan 2014 08:37:52 -0500
In-Reply-To: <1390829613-1842-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently bond_ab_arp_probe() is always called under rcu_read_lock(),
however to work with curr_active_slave we're still holding the
curr_slave_lock.

To remove that curr_slave_lock - rcu_dereference the bond's
curr_active_slave and use it further - so that we're sure the slave won't
go away, and we don't care if it will change in the meanwhile.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c | 16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a7db819..27e6fdd 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2605,25 +2605,21 @@ do_failover:
 static void bond_ab_arp_probe(struct bonding *bond)
 {
 	struct slave *slave, *before = NULL, *new_slave = NULL,
-		     *curr_arp_slave = rcu_dereference(bond->current_arp_slave);
+		     *curr_arp_slave = rcu_dereference(bond->current_arp_slave),
+		     *curr_active_slave = rcu_dereference(bond->curr_active_slave);
 	struct list_head *iter;
 	bool found = false;
 
-	read_lock(&bond->curr_slave_lock);
-
-	if (curr_arp_slave && bond->curr_active_slave)
+	if (curr_arp_slave && curr_active_slave)
 		pr_info("PROBE: c_arp %s && cas %s BAD\n",
 			curr_arp_slave->dev->name,
-			bond->curr_active_slave->dev->name);
+			curr_active_slave->dev->name);
 
-	if (bond->curr_active_slave) {
-		bond_arp_send_all(bond, bond->curr_active_slave);
-		read_unlock(&bond->curr_slave_lock);
+	if (curr_active_slave) {
+		bond_arp_send_all(bond, curr_active_slave);
 		return;
 	}
 
-	read_unlock(&bond->curr_slave_lock);
-
 	/* if we don't have a curr_active_slave, search for the next available
 	 * backup slave from the current_arp_slave and make it the candidate
 	 * for becoming the curr_active_slave
-- 
1.8.4
