From: Jean Delvare <jdelvare@suse.de>
Subject: [PATCH] bonding: Fix jiffies overflow problems (again)
Date: Thu, 2 Sep 2010 16:19:46 +0200
Message-ID: <201009021619.46206.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jiri Bohac <jbohac@suse.cz>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:49498 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755221Ab0IBOTu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Sep 2010 10:19:50 -0400
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
 drivers/net/bonding/bond_main.c |   48 +++++++++++++++++++++++++++-------------
 1 file changed, 33 insertions(+), 15 deletions(-)

--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2798,8 +2798,12 @@ void bond_loadbalance_arp_mon(struct wor
 	 */
 	bond_for_each_slave(bond, slave, i) {
 		if (slave->link != BOND_LINK_UP) {
-			if (time_before_eq(jiffies, dev_trans_start(slave->dev) + delta_in_ticks) &&
-			    time_before_eq(jiffies, slave->dev->last_rx + delta_in_ticks)) {
+			if (time_in_range(jiffies,
+				dev_trans_start(slave->dev) - delta_in_ticks,
+				dev_trans_start(slave->dev) + delta_in_ticks) &&
+			    time_in_range(jiffies,
+				slave->dev->last_rx - delta_in_ticks,
+				slave->dev->last_rx + delta_in_ticks)) {
 
 				slave->link  = BOND_LINK_UP;
 				slave->state = BOND_STATE_ACTIVE;
@@ -2827,8 +2831,12 @@ void bond_loadbalance_arp_mon(struct wor
 			 * when the source ip is 0, so don't take the link down
 			 * if we don't know our ip yet
 			 */
-			if (time_after_eq(jiffies, dev_trans_start(slave->dev) + 2*delta_in_ticks) ||
-			    (time_after_eq(jiffies, slave->dev->last_rx + 2*delta_in_ticks))) {
+			if (!time_in_range(jiffies,
+				dev_trans_start(slave->dev) - delta_in_ticks,
+				dev_trans_start(slave->dev) + 2*delta_in_ticks) ||
+			    (!time_in_range(jiffies,
+				slave->dev->last_rx - delta_in_ticks,
+				slave->dev->last_rx + 2*delta_in_ticks))) {
 
 				slave->link  = BOND_LINK_DOWN;
 				slave->state = BOND_STATE_BACKUP;
@@ -2888,8 +2896,10 @@ static int bond_ab_arp_inspect(struct bo
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
@@ -2902,8 +2912,9 @@ static int bond_ab_arp_inspect(struct bo
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
@@ -2921,8 +2932,10 @@ static int bond_ab_arp_inspect(struct bo
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
@@ -2934,10 +2947,13 @@ static int bond_ab_arp_inspect(struct bo
 		 *    the bond has an IP address)
 		 */
 		if ((slave->state == BOND_STATE_ACTIVE) &&
-		    (time_after_eq(jiffies, dev_trans_start(slave->dev) +
-				    2 * delta_in_ticks) ||
-		      (time_after_eq(jiffies, slave_last_rx(bond, slave)
-				     + 2 * delta_in_ticks)))) {
+		    (!time_in_range(jiffies,
+			dev_trans_start(slave->dev) - delta_in_ticks,
+			dev_trans_start(slave->dev) + 2 * delta_in_ticks) ||
+		     (!time_in_range(jiffies,
+			slave_last_rx(bond, slave) - delta_in_ticks,
+			slave_last_rx(bond, slave) + 2 * delta_in_ticks)))) {
+
 			slave->new_link = BOND_LINK_DOWN;
 			commit++;
 		}
@@ -2964,7 +2980,9 @@ static void bond_ab_arp_commit(struct bo
 
 		case BOND_LINK_UP:
 			if ((!bond->curr_active_slave &&
-			     time_before_eq(jiffies,
+			     time_in_range(jiffies,
+					    dev_trans_start(slave->dev) -
+					    delta_in_ticks,
 					    dev_trans_start(slave->dev) +
 					    delta_in_ticks)) ||
 			    bond->curr_active_slave != slave) {

-- 
Jean Delvare
Suse L3
