From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH RFC net-next 15/21] bonding: use neighbour list for bond_for_each_slave_continue()
Date: Mon,  2 Sep 2013 23:39:19 +0200
Message-ID: <1378157965-17537-16-git-send-email-vfalico@redhat.com>
References: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2333 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932259Ab3IBVjd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 17:39:33 -0400
In-Reply-To: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_for_each_lower_neigh_private_continue() macro to iterate through
bonding slaves. It needs a struct list_head *, so add where needed.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_3ad.c  | 3 +--
 drivers/net/bonding/bond_alb.c  | 4 ++--
 drivers/net/bonding/bond_main.c | 8 ++++----
 drivers/net/bonding/bonding.h   | 7 +++----
 4 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 7430cbb..325ce90 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2423,7 +2423,6 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 	int slave_agg_no;
 	int slaves_in_agg;
 	int agg_id;
-	int i;
 	struct ad_info ad_info;
 	int res = 1;
 
@@ -2463,7 +2462,7 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 
 	start_at = slave;
 
-	bond_for_each_slave_from(bond, slave, i, start_at) {
+	bond_for_each_slave_from(bond, slave, iter, start_at) {
 		int slave_agg_id = 0;
 		struct aggregator *agg = SLAVE_AD_INFO(slave).port.aggregator;
 
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 738eeae..9633ca2 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -384,7 +384,7 @@ static struct slave *rlb_next_rx_slave(struct bonding *bond)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 	struct slave *rx_slave, *slave, *start_at;
-	int i = 0;
+	struct list_head *iter;
 
 	if (bond_info->next_rx_slave)
 		start_at = bond_info->next_rx_slave;
@@ -393,7 +393,7 @@ static struct slave *rlb_next_rx_slave(struct bonding *bond)
 
 	rx_slave = NULL;
 
-	bond_for_each_slave_from(bond, slave, i, start_at) {
+	bond_for_each_slave_from(bond, slave, iter, start_at) {
 		if (SLAVE_IS_OK(slave)) {
 			if (!rx_slave) {
 				rx_slave = slave;
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 297b910..59814c9 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -792,8 +792,8 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
 {
 	struct slave *new_active, *old_active;
 	struct slave *bestslave = NULL;
+	struct list_head *iter;
 	int mintime = bond->params.updelay;
-	int i;
 
 	new_active = bond->curr_active_slave;
 
@@ -812,7 +812,7 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
 	/* remember where to stop iterating over the slaves */
 	old_active = new_active;
 
-	bond_for_each_slave_from(bond, new_active, i, old_active) {
+	bond_for_each_slave_from(bond, new_active, iter, old_active) {
 		if (new_active->link == BOND_LINK_UP) {
 			return new_active;
 		} else if (new_active->link == BOND_LINK_BACK &&
@@ -2783,7 +2783,7 @@ do_failover:
 static void bond_ab_arp_probe(struct bonding *bond)
 {
 	struct slave *slave, *next_slave;
-	int i;
+	struct list_head *iter;
 
 	read_lock(&bond->curr_slave_lock);
 
@@ -2815,7 +2815,7 @@ static void bond_ab_arp_probe(struct bonding *bond)
 
 	/* search for next candidate */
 	next_slave = bond_next_slave(bond, bond->current_arp_slave);
-	bond_for_each_slave_from(bond, slave, i, next_slave) {
+	bond_for_each_slave_from(bond, slave, iter, next_slave) {
 		if (IS_UP(slave->dev)) {
 			slave->link = BOND_LINK_BACK;
 			bond_set_slave_active_flags(slave);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index b6dc9db..583077d 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -99,14 +99,13 @@
  * bond_for_each_slave_from - iterate the slaves list from a starting point
  * @bond:	the bond holding this list.
  * @pos:	current slave.
- * @cnt:	counter for max number of moves
+ * @iter:	list_head * iterator
  * @start:	starting point.
  *
  * Caller must hold bond->lock
  */
-#define bond_for_each_slave_from(bond, pos, cnt, start) \
-	for (cnt = 0, pos = start; pos && cnt < (bond)->slave_cnt; \
-	     cnt++, pos = bond_next_slave(bond, pos))
+#define bond_for_each_slave_from(bond, pos, iter, start) \
+	netdev_for_each_lower_neigh_private_continue((bond)->dev, pos, start, iter)
 
 /**
  * bond_for_each_slave - iterate over all slaves
-- 
1.8.4
