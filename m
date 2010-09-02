From: Jean Delvare <jdelvare@suse.de>
Subject: [PATCH v2] bonding: Fix jiffies overflow problems (again)
Date: Thu, 2 Sep 2010 17:45:54 +0200
Message-ID: <201009021745.55038.jdelvare@suse.de>
References: <201009021619.46206.jdelvare@suse.de> <1283438186.2454.856.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jiri Bohac <jbohac@suse.cz>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:52767 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752433Ab0IBPp5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Sep 2010 11:45:57 -0400
In-Reply-To: <1283438186.2454.856.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Bohac <jbohac@suse.cz>

The time_before_eq()/time_after_eq() functions operate on unsigned
long and only work if the difference between the two compared values
is smaller than half the range of unsigned long (31 bits on i386).

Some of the variables (slave->jiffies, dev->trans_start, dev->last_rx)
used by bonding store a copy of jiffies and may not be updated for a
long time. With HZ=1000, time_before_eq()/time_after_eq() will start
giving bad results after ~25 days.

jiffies will never be before slave->jiffies, dev->trans_start,
dev->last_rx by more than possibly a couple ticks caused by preemption
of this code. This allows us to detect/prevent these overflows by
replacing time_before_eq()/time_after_eq() with time_in_range().

Signed-off-by: Jiri Bohac <jbohac@suse.cz>
Signed-off-by: Jean Delvare <jdelvare@suse.de>
---
 drivers/net/bonding/bond_main.c |   56 +++++++++++++++++++++++++++------------
 1 file changed, 39 insertions(+), 17 deletions(-)

Changes in V2:
* Cache dev_trans_start() result as this function can be slow
  (as suggested by Eric Dumazet.)

--- linux-2.6.36-rc3.orig/drivers/net/bonding/bond_main.c	2010-08-17 09:39:12.000000000 +0200
+++ linux-2.6.36-rc3/drivers/net/bonding/bond_main.c	2010-09-02 17:06:48.000000000 +0200
@@ -2797,9 +2797,15 @@ void bond_loadbalance_arp_mon(struct wor
 	 *       so it can wait
 	 */
 	bond_for_each_slave(bond, slave, i) {
+		unsigned long trans_start = dev_trans_start(slave->dev);
+
 		if (slave->link != BOND_LINK_UP) {
-			if (time_before_eq(jiffies, dev_trans_start(slave->dev) + delta_in_ticks) &&
-			    time_before_eq(jiffies, slave->dev->last_rx + delta_in_ticks)) {
+			if (time_in_range(jiffies,
+				trans_start - delta_in_ticks,
+				trans_start + delta_in_ticks) &&
+			    time_in_range(jiffies,
+				slave->dev->last_rx - delta_in_ticks,
+				slave->dev->last_rx + delta_in_ticks)) {
 
 				slave->link  = BOND_LINK_UP;
 				slave->state = BOND_STATE_ACTIVE;
@@ -2827,8 +2833,12 @@ void bond_loadbalance_arp_mon(struct wor
 			 * when the source ip is 0, so don't take the link down
 			 * if we don't know our ip yet
 			 */
-			if (time_after_eq(jiffies, dev_trans_start(slave->dev) + 2*delta_in_ticks) ||
-			    (time_after_eq(jiffies, slave->dev->last_rx + 2*delta_in_ticks))) {
+			if (!time_in_range(jiffies,
+				trans_start - delta_in_ticks,
+				trans_start + 2 * delta_in_ticks) ||
+			    !time_in_range(jiffies,
+				slave->dev->last_rx - delta_in_ticks,
+				slave->dev->last_rx + 2 * delta_in_ticks)) {
 
 				slave->link  = BOND_LINK_DOWN;
 				slave->state = BOND_STATE_BACKUP;
@@ -2883,13 +2893,16 @@ static int bond_ab_arp_inspect(struct bo
 {
 	struct slave *slave;
 	int i, commit = 0;
+	unsigned long trans_start;
 
 	bond_for_each_slave(bond, slave, i) {
 		slave->new_link = BOND_LINK_NOCHANGE;
 
 		if (slave->link != BOND_LINK_UP) {
-			if (time_before_eq(jiffies, slave_last_rx(bond, slave) +
-					   delta_in_ticks)) {
+			if (time_in_range(jiffies,
+				slave_last_rx(bond, slave) - delta_in_ticks,
+				slave_last_rx(bond, slave) + delta_in_ticks)) {
+
 				slave->new_link = BOND_LINK_UP;
 				commit++;
 			}
@@ -2902,8 +2915,9 @@ static int bond_ab_arp_inspect(struct bo
 		 * active.  This avoids bouncing, as the last receive
 		 * times need a full ARP monitor cycle to be updated.
 		 */
-		if (!time_after_eq(jiffies, slave->jiffies +
-				   2 * delta_in_ticks))
+		if (time_in_range(jiffies,
+				  slave->jiffies - delta_in_ticks,
+				  slave->jiffies + 2 * delta_in_ticks))
 			continue;
 
 		/*
@@ -2921,8 +2935,10 @@ static int bond_ab_arp_inspect(struct bo
 		 */
 		if (slave->state == BOND_STATE_BACKUP &&
 		    !bond->current_arp_slave &&
-		    time_after(jiffies, slave_last_rx(bond, slave) +
-			       3 * delta_in_ticks)) {
+		    !time_in_range(jiffies,
+			slave_last_rx(bond, slave) - delta_in_ticks,
+			slave_last_rx(bond, slave) + 3 * delta_in_ticks)) {
+
 			slave->new_link = BOND_LINK_DOWN;
 			commit++;
 		}
@@ -2933,11 +2949,15 @@ static int bond_ab_arp_inspect(struct bo
 		 * - (more than 2*delta since receive AND
 		 *    the bond has an IP address)
 		 */
+		trans_start = dev_trans_start(slave->dev);
 		if ((slave->state == BOND_STATE_ACTIVE) &&
-		    (time_after_eq(jiffies, dev_trans_start(slave->dev) +
-				    2 * delta_in_ticks) ||
-		      (time_after_eq(jiffies, slave_last_rx(bond, slave)
-				     + 2 * delta_in_ticks)))) {
+		    (!time_in_range(jiffies,
+			trans_start - delta_in_ticks,
+			trans_start + 2 * delta_in_ticks) ||
+		     !time_in_range(jiffies,
+			slave_last_rx(bond, slave) - delta_in_ticks,
+			slave_last_rx(bond, slave) + 2 * delta_in_ticks))) {
+
 			slave->new_link = BOND_LINK_DOWN;
 			commit++;
 		}
@@ -2956,6 +2976,7 @@ static void bond_ab_arp_commit(struct bo
 {
 	struct slave *slave;
 	int i;
+	unsigned long trans_start;
 
 	bond_for_each_slave(bond, slave, i) {
 		switch (slave->new_link) {
@@ -2963,10 +2984,11 @@ static void bond_ab_arp_commit(struct bo
 			continue;
 
 		case BOND_LINK_UP:
+			trans_start = dev_trans_start(slave->dev);
 			if ((!bond->curr_active_slave &&
-			     time_before_eq(jiffies,
-					    dev_trans_start(slave->dev) +
-					    delta_in_ticks)) ||
+			     time_in_range(jiffies,
+					   trans_start - delta_in_ticks,
+					   trans_start + delta_in_ticks)) ||
 			    bond->curr_active_slave != slave) {
 				slave->link = BOND_LINK_UP;
 				bond->current_arp_slave = NULL;

-- 
Jean Delvare
Suse L3
