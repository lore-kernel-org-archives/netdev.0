From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v5 net-next 12/27] bonding: rework rlb_next_rx_slave() to use bond_for_each_slave()
Date: Wed, 25 Sep 2013 09:20:17 +0200
Message-ID: <1380093632-1842-13-git-send-email-vfalico@redhat.com>
References: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8996 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753912Ab3IYHVu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 03:21:50 -0400
In-Reply-To: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, we're using bond_for_each_slave_from(), which is really hard to
implement under RCU and/or neighbour list.

Remove it and use bond_for_each_slave() instead, taking care of the last
used slave.

Also, rename next_rx_slave to rx_slave and store the current (last)
rx_slave.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v4  -> v5
    No change.
    
    v3  -> v4:
    No change.
    
    v2  -> v3:
    No change.
    
    v1  -> v2:
    No changes.
    
    RFC -> v1:
    New patch.

 drivers/net/bonding/bond_alb.c | 41 +++++++++++++++++++++--------------------
 drivers/net/bonding/bond_alb.h |  4 +---
 2 files changed, 22 insertions(+), 23 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index f4929ce..c5b85ad 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -383,30 +383,31 @@ out:
 static struct slave *rlb_next_rx_slave(struct bonding *bond)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
-	struct slave *rx_slave, *slave, *start_at;
-	int i = 0;
-
-	if (bond_info->next_rx_slave)
-		start_at = bond_info->next_rx_slave;
-	else
-		start_at = bond_first_slave(bond);
-
-	rx_slave = NULL;
+	struct slave *before = NULL, *rx_slave = NULL, *slave;
+	struct list_head *iter;
+	bool found = false;
 
-	bond_for_each_slave_from(bond, slave, i, start_at) {
-		if (SLAVE_IS_OK(slave)) {
-			if (!rx_slave) {
-				rx_slave = slave;
-			} else if (slave->speed > rx_slave->speed) {
+	bond_for_each_slave(bond, slave, iter) {
+		if (!SLAVE_IS_OK(slave))
+			continue;
+		if (!found) {
+			if (!before || before->speed < slave->speed)
+				before = slave;
+		} else {
+			if (!rx_slave || rx_slave->speed < slave->speed)
 				rx_slave = slave;
-			}
 		}
+		if (slave == bond_info->rx_slave)
+			found = true;
 	}
+	/* we didn't find anything after the current or we have something
+	 * better before and up to the current slave
+	 */
+	if (!rx_slave || (before && rx_slave->speed < before->speed))
+		rx_slave = before;
 
-	if (rx_slave) {
-		slave = bond_next_slave(bond, rx_slave);
-		bond_info->next_rx_slave = slave;
-	}
+	if (rx_slave)
+		bond_info->rx_slave = rx_slave;
 
 	return rx_slave;
 }
@@ -1611,7 +1612,7 @@ void bond_alb_deinit_slave(struct bonding *bond, struct slave *slave)
 	tlb_clear_slave(bond, slave, 0);
 
 	if (bond->alb_info.rlb_enabled) {
-		bond->alb_info.next_rx_slave = NULL;
+		bond->alb_info.rx_slave = NULL;
 		rlb_clear_slave(bond, slave);
 	}
 }
diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
index c5eff5d..4226044 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -154,9 +154,7 @@ struct alb_bond_info {
 	u8			rx_ntt;	/* flag - need to transmit
 					 * to all rx clients
 					 */
-	struct slave		*next_rx_slave;/* next slave to be assigned
-						* to a new rx client for
-						*/
+	struct slave		*rx_slave;/* last slave to xmit from */
 	u8			primary_is_promisc;	   /* boolean */
 	u32			rlb_promisc_timeout_counter;/* counts primary
 							     * promiscuity time
-- 
1.8.4
