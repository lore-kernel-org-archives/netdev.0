From: Jiri Bohac <jbohac@suse.cz>
Subject: [PATCH] bonding: add some slack to arp monitoring time limits
Date: Fri, 31 Aug 2012 00:02:47 +0200
Message-ID: <20120830220247.GB17263@midget.suse.cz>
References: <20120822174534.GA20260@midget.suse.cz>
 <50351CC5.3030109@genband.com>
 <24655.1345660922@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Friesen <chris.friesen@genband.com>,
	Jiri Bohac <jbohac@suse.cz>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	Petr Tesarik <ptesarik@suse.cz>, davem@davemloft.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33564 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751598Ab2H3WCz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Aug 2012 18:02:55 -0400
Content-Disposition: inline
In-Reply-To: <24655.1345660922@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, all the time limits in the bonding ARP monitor are in
multiples of arp_interval -- the time interval at which the ARP
monitor is periodically scheduled.

With a fast network round-trip and a little scheduling latency
of the ARP monitor work, a limit of n*delta_in_ticks may
effectively mean (n-1)*delta_in_ticks.

This is fatal in case of n==1  (the link will stay down
forever) and makes the behaviour non-deterministic in all the
other cases.

Add a delta_in_ticks/2 time slack to all the time limits.

Signed-off-by: Jiri Bohac <jbohac@suse.cz>

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6fae5f3..0f04115 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2813,12 +2813,13 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 					    arp_work.work);
 	struct slave *slave, *oldcurrent;
 	int do_failover = 0;
-	int delta_in_ticks;
+	int delta_in_ticks, extra_ticks;
 	int i;
 
 	read_lock(&bond->lock);
 
 	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
+	extra_ticks = delta_in_ticks / 2;
 
 	if (bond->slave_cnt == 0)
 		goto re_arm;
@@ -2841,10 +2842,10 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 		if (slave->link != BOND_LINK_UP) {
 			if (time_in_range(jiffies,
 				trans_start - delta_in_ticks,
-				trans_start + delta_in_ticks) &&
+				trans_start + delta_in_ticks + extra_ticks) &&
 			    time_in_range(jiffies,
 				slave->dev->last_rx - delta_in_ticks,
-				slave->dev->last_rx + delta_in_ticks)) {
+				slave->dev->last_rx + delta_in_ticks + extra_ticks)) {
 
 				slave->link  = BOND_LINK_UP;
 				bond_set_active_slave(slave);
@@ -2874,10 +2875,10 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 			 */
 			if (!time_in_range(jiffies,
 				trans_start - delta_in_ticks,
-				trans_start + 2 * delta_in_ticks) ||
+				trans_start + 2 * delta_in_ticks + extra_ticks) ||
 			    !time_in_range(jiffies,
 				slave->dev->last_rx - delta_in_ticks,
-				slave->dev->last_rx + 2 * delta_in_ticks)) {
+				slave->dev->last_rx + 2 * delta_in_ticks + extra_ticks)) {
 
 				slave->link  = BOND_LINK_DOWN;
 				bond_set_backup_slave(slave);
@@ -2935,6 +2936,14 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
 	struct slave *slave;
 	int i, commit = 0;
 	unsigned long trans_start;
+	int extra_ticks;
+
+	/* All the time comparisons below need some extra time. Otherwise, on
+	 * fast networks the ARP probe/reply may arrive within the same jiffy
+	 * as it was sent.  Then, the next time the ARP monitor is run, one
+	 * arp_interval will already have passed in the comparisons.
+	 */
+	extra_ticks = delta_in_ticks / 2;
 
 	bond_for_each_slave(bond, slave, i) {
 		slave->new_link = BOND_LINK_NOCHANGE;
@@ -2942,7 +2951,7 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
 		if (slave->link != BOND_LINK_UP) {
 			if (time_in_range(jiffies,
 				slave_last_rx(bond, slave) - delta_in_ticks,
-				slave_last_rx(bond, slave) + delta_in_ticks)) {
+				slave_last_rx(bond, slave) + delta_in_ticks + extra_ticks)) {
 
 				slave->new_link = BOND_LINK_UP;
 				commit++;
@@ -2958,7 +2967,7 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
 		 */
 		if (time_in_range(jiffies,
 				  slave->jiffies - delta_in_ticks,
-				  slave->jiffies + 2 * delta_in_ticks))
+				  slave->jiffies + 2 * delta_in_ticks + extra_ticks))
 			continue;
 
 		/*
@@ -2978,7 +2987,7 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
 		    !bond->current_arp_slave &&
 		    !time_in_range(jiffies,
 			slave_last_rx(bond, slave) - delta_in_ticks,
-			slave_last_rx(bond, slave) + 3 * delta_in_ticks)) {
+			slave_last_rx(bond, slave) + 3 * delta_in_ticks + extra_ticks)) {
 
 			slave->new_link = BOND_LINK_DOWN;
 			commit++;
@@ -2994,10 +3003,10 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
 		if (bond_is_active_slave(slave) &&
 		    (!time_in_range(jiffies,
 			trans_start - delta_in_ticks,
-			trans_start + 2 * delta_in_ticks) ||
+			trans_start + 2 * delta_in_ticks + extra_ticks) ||
 		     !time_in_range(jiffies,
 			slave_last_rx(bond, slave) - delta_in_ticks,
-			slave_last_rx(bond, slave) + 2 * delta_in_ticks))) {
+			slave_last_rx(bond, slave) + 2 * delta_in_ticks + extra_ticks))) {
 
 			slave->new_link = BOND_LINK_DOWN;
 			commit++;
@@ -3029,7 +3038,7 @@ static void bond_ab_arp_commit(struct bonding *bond, int delta_in_ticks)
 			if ((!bond->curr_active_slave &&
 			     time_in_range(jiffies,
 					   trans_start - delta_in_ticks,
-					   trans_start + delta_in_ticks)) ||
+					   trans_start + delta_in_ticks + delta_in_ticks / 2)) ||
 			    bond->curr_active_slave != slave) {
 				slave->link = BOND_LINK_UP;
 				if (bond->current_arp_slave) {
-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
