From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2/6] Convert balance-rr transmit to new locking
Date: Wed, 10 Oct 2007 21:14:05 -0700
Message-ID: <1192076051437-git-send-email-fubar@us.ibm.com>
References: <11920760494096-git-send-email-fubar@us.ibm.com>
 <11920760502756-git-send-email-fubar@us.ibm.com>
Cc: andy@greyhouse.net, Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:40617 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751230AbXJKEOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 00:14:14 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9B4EDlu001797
	for <netdev@vger.kernel.org>; Thu, 11 Oct 2007 00:14:13 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9B4EC6g451938
	for <netdev@vger.kernel.org>; Wed, 10 Oct 2007 22:14:12 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9B4ECIB027169
	for <netdev@vger.kernel.org>; Wed, 10 Oct 2007 22:14:12 -0600
In-Reply-To: <11920760502756-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Change locking in balance-rr transmit processing to use a free
running counter to determine which slave to transmit on.  Instead, a
free-running counter is maintained, and modulo arithmetic used to select
a slave for transmit.

	This removes lock operations from the TX path, and eliminates
a deadlock introduced by the conversion to work queues.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |   25 ++++++++++++-------------
 drivers/net/bonding/bonding.h   |    1 +
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 28ae961..4541a1b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3928,8 +3928,7 @@ static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev
 {
 	struct bonding *bond = bond_dev->priv;
 	struct slave *slave, *start_at;
-	int i;
-	int res = 1;
+	int i, slave_no, res = 1;
 
 	read_lock(&bond->lock);
 
@@ -3937,29 +3936,29 @@ static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev
 		goto out;
 	}
 
-	read_lock(&bond->curr_slave_lock);
-	slave = start_at = bond->curr_active_slave;
-	read_unlock(&bond->curr_slave_lock);
+	/*
+	 * Concurrent TX may collide on rr_tx_counter; we accept that
+	 * as being rare enough not to justify using an atomic op here
+	 */
+	slave_no = bond->rr_tx_counter++ % bond->slave_cnt;
 
-	if (!slave) {
-		goto out;
+	bond_for_each_slave(bond, slave, i) {
+		slave_no--;
+		if (slave_no < 0) {
+			break;
+		}
 	}
 
+	start_at = slave;
 	bond_for_each_slave_from(bond, slave, i, start_at) {
 		if (IS_UP(slave->dev) &&
 		    (slave->link == BOND_LINK_UP) &&
 		    (slave->state == BOND_STATE_ACTIVE)) {
 			res = bond_dev_queue_xmit(bond, skb, slave->dev);
-
-			write_lock(&bond->curr_slave_lock);
-			bond->curr_active_slave = slave->next;
-			write_unlock(&bond->curr_slave_lock);
-
 			break;
 		}
 	}
 
-
 out:
 	if (res) {
 		/* no suitable interface, frame not sent */
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 4986d0f..e7c3671 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -183,6 +183,7 @@ struct bonding {
 	rwlock_t lock;
 	rwlock_t curr_slave_lock;
 	s8       kill_timers;
+	u16      rr_tx_counter;
 	struct   net_device_stats stats;
 #ifdef CONFIG_PROC_FS
 	struct   proc_dir_entry *proc_entry;
-- 
1.5.3.1

