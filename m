From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 2/2] bonding: add bond_time_in_interval() and use it for time comparison
Date: Sat,  3 Aug 2013 03:50:36 +0200
Message-ID: <1375494636-7947-3-git-send-email-vfalico@redhat.com>
References: <1375494636-7947-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51048 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754249Ab3HCBuW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Aug 2013 21:50:22 -0400
In-Reply-To: <1375494636-7947-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we use a lot of time comparison math for arp_interval
comparisons, which are sometimes quite hard to read and understand.

All the time comparisons have one pattern:
(time - arp_interval_jiffies) <= jiffies <= (time + mod *
arp_interval_jiffies + arp_interval_jiffies/2)

Introduce a new helper - bond_time_in_interval(), which will do the math in
one place and, thus, will clean up the logical code. This helper introduces
a bit of overhead (by always calculating the jiffies from arp_interval),
however it's really not visible, considering that functions using it
usually run once in arp_interval milliseconds.

There are several lines slightly over 80 chars, however breaking them would
result in more hard-to-read code than several character after the 80 mark.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c |   85 +++++++++++++++------------------------
 1 files changed, 32 insertions(+), 53 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index cc13bfe..d58237b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2635,6 +2635,20 @@ out_unlock:
 	return RX_HANDLER_ANOTHER;
 }
 
+/* function to verify if we're in the arp_interval timeslice, returns true if
+ * (last_act - arp_interval) <= jiffies <= (last_act + mod * arp_interval +
+ * arp_interval/2) . the arp_interval/2 is needed for really fast networks.
+ */
+static bool bond_time_in_interval(struct bonding *bond, unsigned long last_act,
+				  int mod)
+{
+	int delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
+
+	return time_in_range(jiffies,
+			     last_act - delta_in_ticks,
+			     last_act + mod * delta_in_ticks + delta_in_ticks/2);
+}
+
 /*
  * this function is called regularly to monitor each slave's link
  * ensuring that traffic is being sent and received when arp monitoring
@@ -2648,13 +2662,9 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 					    arp_work.work);
 	struct slave *slave, *oldcurrent;
 	int do_failover = 0;
-	int delta_in_ticks, extra_ticks;
 
 	read_lock(&bond->lock);
 
-	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
-	extra_ticks = delta_in_ticks / 2;
-
 	if (list_empty(&bond->slave_list))
 		goto re_arm;
 
@@ -2671,12 +2681,8 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 		unsigned long trans_start = dev_trans_start(slave->dev);
 
 		if (slave->link != BOND_LINK_UP) {
-			if (time_in_range(jiffies,
-				trans_start - delta_in_ticks,
-				trans_start + delta_in_ticks + extra_ticks) &&
-			    time_in_range(jiffies,
-				slave->dev->last_rx - delta_in_ticks,
-				slave->dev->last_rx + delta_in_ticks + extra_ticks)) {
+			if (bond_time_in_interval(bond, trans_start, 1) &&
+			    bond_time_in_interval(bond, slave->dev->last_rx, 1)) {
 
 				slave->link  = BOND_LINK_UP;
 				bond_set_active_slave(slave);
@@ -2704,12 +2710,8 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 			 * when the source ip is 0, so don't take the link down
 			 * if we don't know our ip yet
 			 */
-			if (!time_in_range(jiffies,
-				trans_start - delta_in_ticks,
-				trans_start + 2 * delta_in_ticks + extra_ticks) ||
-			    !time_in_range(jiffies,
-				slave->dev->last_rx - delta_in_ticks,
-				slave->dev->last_rx + 2 * delta_in_ticks + extra_ticks)) {
+			if (!bond_time_in_interval(bond, trans_start, 2) ||
+			    !bond_time_in_interval(bond, slave->dev->last_rx, 2)) {
 
 				slave->link  = BOND_LINK_DOWN;
 				bond_set_backup_slave(slave);
@@ -2749,7 +2751,8 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 
 re_arm:
 	if (bond->params.arp_interval)
-		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
+		queue_delayed_work(bond->wq, &bond->arp_work,
+				   msecs_to_jiffies(bond->params.arp_interval));
 
 	read_unlock(&bond->lock);
 }
@@ -2762,33 +2765,21 @@ re_arm:
  *
  * Called with bond->lock held for read.
  */
-static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
+static int bond_ab_arp_inspect(struct bonding *bond)
 {
 	unsigned long trans_start, last_rx;
 	struct slave *slave;
-	int extra_ticks;
 	int commit = 0;
 
-	/* All the time comparisons below need some extra time. Otherwise, on
-	 * fast networks the ARP probe/reply may arrive within the same jiffy
-	 * as it was sent.  Then, the next time the ARP monitor is run, one
-	 * arp_interval will already have passed in the comparisons.
-	 */
-	extra_ticks = delta_in_ticks / 2;
-
 	bond_for_each_slave(bond, slave) {
 		slave->new_link = BOND_LINK_NOCHANGE;
 		last_rx = slave_last_rx(bond, slave);
 
 		if (slave->link != BOND_LINK_UP) {
-			if (time_in_range(jiffies,
-				last_rx - delta_in_ticks,
-				last_rx + delta_in_ticks + extra_ticks)) {
-
+			if (bond_time_in_interval(bond, last_rx, 1)) {
 				slave->new_link = BOND_LINK_UP;
 				commit++;
 			}
-
 			continue;
 		}
 
@@ -2797,9 +2788,7 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
 		 * active.  This avoids bouncing, as the last receive
 		 * times need a full ARP monitor cycle to be updated.
 		 */
-		if (time_in_range(jiffies,
-				  slave->jiffies - delta_in_ticks,
-				  slave->jiffies + 2 * delta_in_ticks + extra_ticks))
+		if (bond_time_in_interval(bond, slave->jiffies, 2))
 			continue;
 
 		/*
@@ -2817,10 +2806,7 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
 		 */
 		if (!bond_is_active_slave(slave) &&
 		    !bond->current_arp_slave &&
-		    !time_in_range(jiffies,
-			last_rx - delta_in_ticks,
-			last_rx + 3 * delta_in_ticks + extra_ticks)) {
-
+		    !bond_time_in_interval(bond, last_rx, 3)) {
 			slave->new_link = BOND_LINK_DOWN;
 			commit++;
 		}
@@ -2833,13 +2819,8 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
 		 */
 		trans_start = dev_trans_start(slave->dev);
 		if (bond_is_active_slave(slave) &&
-		    (!time_in_range(jiffies,
-			trans_start - delta_in_ticks,
-			trans_start + 2 * delta_in_ticks + extra_ticks) ||
-		     !time_in_range(jiffies,
-			last_rx - delta_in_ticks,
-			last_rx + 2 * delta_in_ticks + extra_ticks))) {
-
+		    (!bond_time_in_interval(bond, trans_start, 2) ||
+		     !bond_time_in_interval(bond, last_rx, 2))) {
 			slave->new_link = BOND_LINK_DOWN;
 			commit++;
 		}
@@ -2854,7 +2835,7 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
  *
  * Called with RTNL and bond->lock for read.
  */
-static void bond_ab_arp_commit(struct bonding *bond, int delta_in_ticks)
+static void bond_ab_arp_commit(struct bonding *bond)
 {
 	unsigned long trans_start;
 	struct slave *slave;
@@ -2866,11 +2847,9 @@ static void bond_ab_arp_commit(struct bonding *bond, int delta_in_ticks)
 
 		case BOND_LINK_UP:
 			trans_start = dev_trans_start(slave->dev);
-			if ((!bond->curr_active_slave &&
-			     time_in_range(jiffies,
-					   trans_start - delta_in_ticks,
-					   trans_start + delta_in_ticks + delta_in_ticks / 2)) ||
-			    bond->curr_active_slave != slave) {
+			if (bond->curr_active_slave != slave ||
+			    (!bond->curr_active_slave &&
+			     bond_time_in_interval(bond, trans_start, 1))) {
 				slave->link = BOND_LINK_UP;
 				if (bond->current_arp_slave) {
 					bond_set_slave_inactive_flags(
@@ -3011,7 +2990,7 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 
 	should_notify_peers = bond_should_notify_peers(bond);
 
-	if (bond_ab_arp_inspect(bond, delta_in_ticks)) {
+	if (bond_ab_arp_inspect(bond)) {
 		read_unlock(&bond->lock);
 
 		/* Race avoidance with bond_close flush of workqueue */
@@ -3024,7 +3003,7 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 
 		read_lock(&bond->lock);
 
-		bond_ab_arp_commit(bond, delta_in_ticks);
+		bond_ab_arp_commit(bond);
 
 		read_unlock(&bond->lock);
 		rtnl_unlock();
-- 
1.7.1
