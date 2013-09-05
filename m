From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v3 5/6] bonding: restructure and add rcu for bond_for_each_slave_next()
Date: Thu, 5 Sep 2013 15:49:01 +0800
Message-ID: <5228376D.2040608@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:51841 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762687Ab3IEHtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 03:49:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the wordy int and add bond_for_each_slave_next_rcu() for future use.

Suggested-by: Nikolay Aleksandrov <nikolay@redhat.com>
Suggested-by: Veaceslav Falico <vfalico@redhat.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_alb.c  |  3 +--
 drivers/net/bonding/bond_main.c |  6 ++----
 drivers/net/bonding/bonding.h   | 23 +++++++++++++++++++----
 3 files changed, 22 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 91f179d..c75d383 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -383,7 +383,6 @@ static struct slave *rlb_next_rx_slave(struct bonding *bond)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 	struct slave *rx_slave, *slave, *start_at;
-	int i = 0;
 
 	if (bond_info->next_rx_slave)
 		start_at = bond_info->next_rx_slave;
@@ -392,7 +391,7 @@ static struct slave *rlb_next_rx_slave(struct bonding *bond)
 
 	rx_slave = NULL;
 
-	bond_for_each_slave_from(bond, slave, i, start_at) {
+	bond_for_each_slave_from(bond, slave, start_at) {
 		if (SLAVE_IS_OK(slave)) {
 			if (!rx_slave) {
 				rx_slave = slave;
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 39e5b1c..4190389 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -782,7 +782,6 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
 	struct slave *new_active, *old_active;
 	struct slave *bestslave = NULL;
 	int mintime = bond->params.updelay;
-	int i;
 
 	new_active = bond->curr_active_slave;
 
@@ -801,7 +800,7 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
 	/* remember where to stop iterating over the slaves */
 	old_active = new_active;
 
-	bond_for_each_slave_from(bond, new_active, i, old_active) {
+	bond_for_each_slave_from(bond, new_active, old_active) {
 		if (new_active->link == BOND_LINK_UP) {
 			return new_active;
 		} else if (new_active->link == BOND_LINK_BACK &&
@@ -2756,7 +2755,6 @@ do_failover:
 static void bond_ab_arp_probe(struct bonding *bond)
 {
 	struct slave *slave, *next_slave;
-	int i;
 
 	read_lock(&bond->curr_slave_lock);
 
@@ -2788,7 +2786,7 @@ static void bond_ab_arp_probe(struct bonding *bond)
 
 	/* search for next candidate */
 	next_slave = bond_next_slave(bond, bond->current_arp_slave);
-	bond_for_each_slave_from(bond, slave, i, next_slave) {
+	bond_for_each_slave_from(bond, slave, next_slave) {
 		if (IS_UP(slave->dev)) {
 			slave->link = BOND_LINK_BACK;
 			bond_set_slave_active_flags(slave);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index f013b12..48fd41a 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -123,18 +123,33 @@
 	(bond_is_first_slave(bond, pos) ? bond_last_slave_rcu(bond) : \
 					  bond_to_slave_rcu((pos)->list.prev))
 
+/* Check whether the slave is the only one in bond */
+
 /**
  * bond_for_each_slave_from - iterate the slaves list from a starting point
  * @bond:	the bond holding this list.
  * @pos:	current slave.
- * @cnt:	counter for max number of moves
  * @start:	starting point.
  *
  * Caller must hold bond->lock
  */
-#define bond_for_each_slave_from(bond, pos, cnt, start) \
-	for (cnt = 0, pos = start; pos && cnt < (bond)->slave_cnt; \
-	     cnt++, pos = bond_next_slave(bond, pos))
+#define bond_for_each_slave_from(bond, pos, start) \
+	for (pos = start; pos && &pos->list != &bond->slave_list; \
+	    (pos = bond_next_slave(bond, pos)) != start ? pos : \
+	    (pos = list_entry(&bond->slave_list, typeof(*pos), list)))
+
+/**
+ * bond_for_each_slave_from_rcu - iterate the slaves list from a starting point
+ * @bond:	the bond holding this list.
+ * @pos:	current slave.
+ * @start:	starting point.
+ *
+ * Caller must hold rcu_read_lock
+ */
+#define bond_for_each_slave_from_rcu(bond, pos, start) \
+	for (pos = start; pos && &pos->list != &bond->slave_list; \
+	    (pos = bond_next_slave_rcu(bond, pos)) != start ? pos : \
+	    (pos = list_entry_rcu(&bond->slave_list, typeof(*pos), list)))
 
 /**
  * bond_for_each_slave - iterate over all slaves
-- 
1.8.2.1
