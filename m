From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 1/2] bonding: call slave_last_rx() only once per slave
Date: Sat,  3 Aug 2013 03:50:35 +0200
Message-ID: <1375494636-7947-2-git-send-email-vfalico@redhat.com>
References: <1375494636-7947-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59100 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754449Ab3HCBuX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Aug 2013 21:50:23 -0400
In-Reply-To: <1375494636-7947-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simple cleanup to not call slave_last_rx() on every time function. It won't
give any measurable boost - but looks cleaner and easier to understand.

There are no time-consuming functions in between these calls, so it's safe
to call it in the beginning only once.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 476df7d..cc13bfe 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2764,7 +2764,7 @@ re_arm:
  */
 static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
 {
-	unsigned long trans_start;
+	unsigned long trans_start, last_rx;
 	struct slave *slave;
 	int extra_ticks;
 	int commit = 0;
@@ -2778,11 +2778,12 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
 
 	bond_for_each_slave(bond, slave) {
 		slave->new_link = BOND_LINK_NOCHANGE;
+		last_rx = slave_last_rx(bond, slave);
 
 		if (slave->link != BOND_LINK_UP) {
 			if (time_in_range(jiffies,
-				slave_last_rx(bond, slave) - delta_in_ticks,
-				slave_last_rx(bond, slave) + delta_in_ticks + extra_ticks)) {
+				last_rx - delta_in_ticks,
+				last_rx + delta_in_ticks + extra_ticks)) {
 
 				slave->new_link = BOND_LINK_UP;
 				commit++;
@@ -2817,8 +2818,8 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
 		if (!bond_is_active_slave(slave) &&
 		    !bond->current_arp_slave &&
 		    !time_in_range(jiffies,
-			slave_last_rx(bond, slave) - delta_in_ticks,
-			slave_last_rx(bond, slave) + 3 * delta_in_ticks + extra_ticks)) {
+			last_rx - delta_in_ticks,
+			last_rx + 3 * delta_in_ticks + extra_ticks)) {
 
 			slave->new_link = BOND_LINK_DOWN;
 			commit++;
@@ -2836,8 +2837,8 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
 			trans_start - delta_in_ticks,
 			trans_start + 2 * delta_in_ticks + extra_ticks) ||
 		     !time_in_range(jiffies,
-			slave_last_rx(bond, slave) - delta_in_ticks,
-			slave_last_rx(bond, slave) + 2 * delta_in_ticks + extra_ticks))) {
+			last_rx - delta_in_ticks,
+			last_rx + 2 * delta_in_ticks + extra_ticks))) {
 
 			slave->new_link = BOND_LINK_DOWN;
 			commit++;
-- 
1.7.1
