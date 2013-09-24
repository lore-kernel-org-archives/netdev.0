From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v4 net-next 14/27] bonding: rework bond_ab_arp_probe() to use bond_for_each_slave()
Date: Tue, 24 Sep 2013 13:46:54 +0200
Message-ID: <1380023227-9576-15-git-send-email-vfalico@redhat.com>
References: <1380023227-9576-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24309 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753208Ab3IXLsV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 07:48:21 -0400
In-Reply-To: <1380023227-9576-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently it uses the hard-to-rcuify bond_for_each_slave_from(), and also
it doesn't check every slave for disrepencies between the actual
IS_UP(slave) and the slave->link == BOND_LINK_UP, but only till we find the
next suitable slave.

Fix this by using bond_for_each_slave() and storing the first good slave in
*before till we find the current_arp_slave, after that we store the first good
slave in new_slave. If new_slave is empty - use the slave stored in before,
and if it's also empty - then we didn't find any suitable slave.

Also, in the meanwhile, check for each slave status.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v3  -> v4:
    No change.
    
    v2  -> v3:
    No change.
    
    v1  -> v2:
    No changes.
    
    RFC -> v1:
    New patch.

 drivers/net/bonding/bond_main.c | 38 ++++++++++++++++++++++++--------------
 1 file changed, 24 insertions(+), 14 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6abbfac..3c96b1b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2761,8 +2761,9 @@ do_failover:
  */
 static void bond_ab_arp_probe(struct bonding *bond)
 {
-	struct slave *slave, *next_slave;
-	int i;
+	struct slave *slave, *before = NULL, *new_slave = NULL;
+	struct list_head *iter;
+	bool found = false;
 
 	read_lock(&bond->curr_slave_lock);
 
@@ -2792,18 +2793,12 @@ static void bond_ab_arp_probe(struct bonding *bond)
 
 	bond_set_slave_inactive_flags(bond->current_arp_slave);
 
-	/* search for next candidate */
-	next_slave = bond_next_slave(bond, bond->current_arp_slave);
-	bond_for_each_slave_from(bond, slave, i, next_slave) {
-		if (IS_UP(slave->dev)) {
-			slave->link = BOND_LINK_BACK;
-			bond_set_slave_active_flags(slave);
-			bond_arp_send_all(bond, slave);
-			slave->jiffies = jiffies;
-			bond->current_arp_slave = slave;
-			break;
-		}
+	bond_for_each_slave(bond, slave, iter) {
+		if (!found && !before && IS_UP(slave->dev))
+			before = slave;
 
+		if (found && !new_slave && IS_UP(slave->dev))
+			new_slave = slave;
 		/* if the link state is up at this point, we
 		 * mark it down - this can happen if we have
 		 * simultaneous link failures and
@@ -2811,7 +2806,7 @@ static void bond_ab_arp_probe(struct bonding *bond)
 		 * one the current slave so it is still marked
 		 * up when it is actually down
 		 */
-		if (slave->link == BOND_LINK_UP) {
+		if (!IS_UP(slave->dev) && slave->link == BOND_LINK_UP) {
 			slave->link = BOND_LINK_DOWN;
 			if (slave->link_failure_count < UINT_MAX)
 				slave->link_failure_count++;
@@ -2821,7 +2816,22 @@ static void bond_ab_arp_probe(struct bonding *bond)
 			pr_info("%s: backup interface %s is now down.\n",
 				bond->dev->name, slave->dev->name);
 		}
+		if (slave == bond->current_arp_slave)
+			found = true;
 	}
+
+	if (!new_slave && before)
+		new_slave = before;
+
+	if (!new_slave)
+		return;
+
+	new_slave->link = BOND_LINK_BACK;
+	bond_set_slave_active_flags(new_slave);
+	bond_arp_send_all(bond, new_slave);
+	new_slave->jiffies = jiffies;
+	bond->current_arp_slave = new_slave;
+
 }
 
 void bond_activebackup_arp_mon(struct work_struct *work)
-- 
1.8.4
