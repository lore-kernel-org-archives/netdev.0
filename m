From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 3/6] Convert miimon to new locking
Date: Wed, 17 Oct 2007 17:37:48 -0700
Message-ID: <11926678773102-git-send-email-fubar@us.ibm.com>
References: <1192667871139-git-send-email-fubar@us.ibm.com>
 <1192667875793-git-send-email-fubar@us.ibm.com>
 <11926678763205-git-send-email-fubar@us.ibm.com>
 <11926678762641-git-send-email-fubar@us.ibm.com>
Cc: andy@greyhouse.net, Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:44656 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762042AbXJRAh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 20:37:59 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9I0bwB9020900
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 20:37:58 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9I0bw39500134
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 18:37:58 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9I0bvWv021342
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 18:37:58 -0600
In-Reply-To: <11926678762641-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Convert mii (link state) monitor to acquire correct locks for
failover events.  In particular, failovers generally require RTNL at a low
level (when manipulating device MAC addresses, for example) and no other
locks.  The high level monitor is responsible for acquiring a known set
of locks, RTNL, the bond->lock for read and the slave_lock for write, and
the low level failover processing can then release appropriate locks as
needed.  This patch provides the high level portion.

	As it is undesirable to acquire RTNL for every monitor pass (which
may occur as often as every 10 ms), the miimon has been converted to
do conditional locking.  A first pass inspects all slaves to determine
if any action is required, and if so, a second pass (after acquring RTNL)
is done to perform any actions (doing a complete rescan, as the situation
may have changed when all locks were released).

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |   70 ++++++++++++++++++++++++++++----------
 1 files changed, 51 insertions(+), 19 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 862ed8e..a357727 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2088,27 +2088,25 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
 
 /*-------------------------------- Monitoring -------------------------------*/
 
-/* this function is called regularly to monitor each slave's link. */
-void bond_mii_monitor(struct work_struct *work)
+/*
+ * if !have_locks, return nonzero if a failover is necessary.  if
+ * have_locks, do whatever failover activities are needed.
+ *
+ * This is to separate the inspection and failover steps for locking
+ * purposes; failover requires rtnl, but acquiring it for every
+ * inspection is undesirable, so a wrapper first does inspection, and
+ * the acquires the necessary locks and calls again to perform
+ * failover if needed.  Since all locks are dropped, a complete
+ * restart is needed between calls.
+ */
+static int __bond_mii_monitor(struct bonding *bond, int have_locks)
 {
-	struct bonding *bond = container_of(work, struct bonding,
-					    mii_work.work);
 	struct slave *slave, *oldcurrent;
 	int do_failover = 0;
-	int delta_in_ticks;
 	int i;
 
-	read_lock(&bond->lock);
-
-	delta_in_ticks = (bond->params.miimon * HZ) / 1000;
-
-	if (bond->kill_timers) {
+	if (bond->slave_cnt == 0)
 		goto out;
-	}
-
-	if (bond->slave_cnt == 0) {
-		goto re_arm;
-	}
 
 	/* we will try to read the link status of each of our slaves, and
 	 * set their IFF_RUNNING flag appropriately. For each slave not
@@ -2175,6 +2173,9 @@ void bond_mii_monitor(struct work_struct *work)
 			if (link_state != BMSR_LSTATUS) {
 				/* link stays down */
 				if (slave->delay <= 0) {
+					if (!have_locks)
+						return 1;
+
 					/* link down for too long time */
 					slave->link = BOND_LINK_DOWN;
 
@@ -2258,6 +2259,9 @@ void bond_mii_monitor(struct work_struct *work)
 			} else {
 				/* link stays up */
 				if (slave->delay == 0) {
+					if (!have_locks)
+						return 1;
+
 					/* now the link has been up for long time enough */
 					slave->link = BOND_LINK_UP;
 					slave->jiffies = jiffies;
@@ -2331,13 +2335,41 @@ void bond_mii_monitor(struct work_struct *work)
 	} else
 		bond_set_carrier(bond);
 
-re_arm:
-	if (bond->params.miimon)
-		queue_delayed_work(bond->wq, &bond->mii_work, delta_in_ticks);
 out:
-	read_unlock(&bond->lock);
+	return 0;
 }
 
+/*
+ * bond_mii_monitor
+ *
+ * Really a wrapper that splits the mii monitor into two phases: an
+ * inspection, then (if inspection indicates something needs to be
+ * done) an acquisition of appropriate locks followed by another pass
+ * to implement whatever link state changes are indicated.
+ */
+void bond_mii_monitor(struct work_struct *work)
+{
+	struct bonding *bond = container_of(work, struct bonding,
+					    mii_work.work);
+	unsigned long delay;
+
+	read_lock(&bond->lock);
+	if (bond->kill_timers) {
+		read_unlock(&bond->lock);
+		return;
+	}
+	if (__bond_mii_monitor(bond, 0)) {
+		read_unlock(&bond->lock);
+		rtnl_lock();
+		read_lock(&bond->lock);
+		__bond_mii_monitor(bond, 1);
+		rtnl_unlock();
+	}
+
+	delay = ((bond->params.miimon * HZ) / 1000) ? : 1;
+	read_unlock(&bond->lock);
+	queue_delayed_work(bond->wq, &bond->mii_work, delay);
+}
 
 static __be32 bond_glean_dev_ip(struct net_device *dev)
 {
-- 
1.5.3.4.206.g58ba4-dirty

