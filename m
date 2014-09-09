From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 5/7] bonding: procfs: clean bond->lock usage and use RCU
Date: Tue,  9 Sep 2014 23:17:01 +0200
Message-ID: <1410297423-26624-6-git-send-email-nikolay@redhat.com>
References: <1410297423-26624-1-git-send-email-nikolay@redhat.com>
Cc: hariprasad@chelsio.com, vfalico@gmail.com, j.vosburgh@gmail.com,
	andy@greyhouse.net, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45049 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751857AbaIIVRY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2014 17:17:24 -0400
In-Reply-To: <1410297423-26624-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use RCU to protect against slave release, the proc show function will sync
with the bond destruction by the proc locks and the fact that the bond is
released after NETDEV_UNREGISTER which causes the bonding to remove the
proc entry.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_procfs.c | 16 +++-------------
 1 file changed, 3 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index 1a9fe1ba4c60..bb09d0442aa8 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -7,21 +7,18 @@
 
 static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(RCU)
-	__acquires(&bond->lock)
 {
 	struct bonding *bond = seq->private;
 	struct list_head *iter;
 	struct slave *slave;
 	loff_t off = 0;
 
-	/* make sure the bond won't be taken away */
 	rcu_read_lock();
-	read_lock(&bond->lock);
 
 	if (*pos == 0)
 		return SEQ_START_TOKEN;
 
-	bond_for_each_slave(bond, slave, iter)
+	bond_for_each_slave_rcu(bond, slave, iter)
 		if (++off == *pos)
 			return slave;
 
@@ -37,12 +34,9 @@ static void *bond_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 
 	++*pos;
 	if (v == SEQ_START_TOKEN)
-		return bond_first_slave(bond);
+		return bond_first_slave_rcu(bond);
 
-	if (bond_is_last_slave(bond, v))
-		return NULL;
-
-	bond_for_each_slave(bond, slave, iter) {
+	bond_for_each_slave_rcu(bond, slave, iter) {
 		if (found)
 			return slave;
 		if (slave == v)
@@ -53,12 +47,8 @@ static void *bond_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void bond_info_seq_stop(struct seq_file *seq, void *v)
-	__releases(&bond->lock)
 	__releases(RCU)
 {
-	struct bonding *bond = seq->private;
-
-	read_unlock(&bond->lock);
 	rcu_read_unlock();
 }
 
-- 
1.9.3
