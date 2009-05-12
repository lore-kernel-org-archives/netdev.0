From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: tx scalability works : trans_start
Date: Tue, 12 May 2009 21:47:53 +0200
Message-ID: <4A09D269.60703@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw2.cosmosbay.com ([86.64.20.130]:34703 "EHLO gw2.cosmosbay.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751991AbZELTrz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 May 2009 15:47:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct net_device trans_start field is a hot spot on SMP and high performance
devices, particularly multi queues ones, because every transmitter dirties
it. Is main use is tx watchdog and bonding alive checks.

But as most devices dont use NETIF_F_LLTX, we have to lock
a netdev_queue before calling their ndo_start_xmit(). So it makes
sense to move trans_start from net_device to netdev_queue. Its update
will occur on a already present (and in exclusive state) cache line, for
free.

We can do this transition smoothly. An old driver continue to
update dev->trans_start, while an updated one updates txq->trans_start.

Further patches could also put tx_bytes/tx_packets counters in 
netdev_queue to avoid dirtying dev->stats (vlan device comes to mind)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 drivers/net/bonding/bond_main.c |    8 +++---
 include/linux/netdevice.h       |   11 ++++++++
 net/sched/sch_generic.c         |   40 +++++++++++++++++++++++-------
 3 files changed, 46 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 815191d..30b9ea6 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2795,7 +2795,7 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 	 */
 	bond_for_each_slave(bond, slave, i) {
 		if (slave->link != BOND_LINK_UP) {
-			if (time_before_eq(jiffies, slave->dev->trans_start + delta_in_ticks) &&
+			if (time_before_eq(jiffies, dev_trans_start(slave->dev) + delta_in_ticks) &&
 			    time_before_eq(jiffies, slave->dev->last_rx + delta_in_ticks)) {
 
 				slave->link  = BOND_LINK_UP;
@@ -2827,7 +2827,7 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 			 * when the source ip is 0, so don't take the link down
 			 * if we don't know our ip yet
 			 */
-			if (time_after_eq(jiffies, slave->dev->trans_start + 2*delta_in_ticks) ||
+			if (time_after_eq(jiffies, dev_trans_start(slave->dev) + 2*delta_in_ticks) ||
 			    (time_after_eq(jiffies, slave->dev->last_rx + 2*delta_in_ticks))) {
 
 				slave->link  = BOND_LINK_DOWN;
@@ -2938,7 +2938,7 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
 		 *    the bond has an IP address)
 		 */
 		if ((slave->state == BOND_STATE_ACTIVE) &&
-		    (time_after_eq(jiffies, slave->dev->trans_start +
+		    (time_after_eq(jiffies, dev_trans_start(slave->dev) +
 				    2 * delta_in_ticks) ||
 		      (time_after_eq(jiffies, slave_last_rx(bond, slave)
 				     + 2 * delta_in_ticks)))) {
@@ -2982,7 +2982,7 @@ static void bond_ab_arp_commit(struct bonding *bond, int delta_in_ticks)
 			write_lock_bh(&bond->curr_slave_lock);
 
 			if (!bond->curr_active_slave &&
-			    time_before_eq(jiffies, slave->dev->trans_start +
+			    time_before_eq(jiffies, dev_trans_start(slave->dev) +
 					   delta_in_ticks)) {
 				slave->link = BOND_LINK_UP;
 				bond_change_active_slave(bond, slave);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2af89b6..cd547d0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -470,6 +470,10 @@ struct netdev_queue {
  */
 	spinlock_t		_xmit_lock ____cacheline_aligned_in_smp;
 	int			xmit_lock_owner;
+	/*
+	 * please use this field instead of dev->trans_start
+	 */
+	unsigned long		trans_start;
 } ____cacheline_aligned_in_smp;
 
 
@@ -819,6 +823,11 @@ struct net_device
  * One part is mostly used on xmit path (device)
  */
 	/* These may be needed for future network-power-down code. */
+
+	/*
+	 * trans_start here is expensive for high speed devices on SMP,
+	 * please use netdev_queue->trans_start instead.
+	 */
 	unsigned long		trans_start;	/* Time (in jiffies) of last Tx	*/
 
 	int			watchdog_timeo; /* used by dev_watchdog() */
@@ -1541,6 +1550,8 @@ static inline int netif_carrier_ok(const struct net_device *dev)
 	return !test_bit(__LINK_STATE_NOCARRIER, &dev->state);
 }
 
+extern unsigned long dev_trans_start(struct net_device *dev);
+
 extern void __netdev_watchdog_up(struct net_device *dev);
 
 extern void netif_carrier_on(struct net_device *dev);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 5f5efe4..abdad6c 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -196,6 +196,21 @@ void __qdisc_run(struct Qdisc *q)
 	clear_bit(__QDISC_STATE_RUNNING, &q->state);
 }
 
+unsigned long dev_trans_start(struct net_device *dev)
+{
+	unsigned long val, res = dev->trans_start;
+	unsigned int i;
+
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		val = netdev_get_tx_queue(dev, i)->trans_start;
+		if (val && time_after(val, res))
+			res = val;
+	}
+	dev->trans_start = res;
+	return res;
+}
+EXPORT_SYMBOL(dev_trans_start);
+
 static void dev_watchdog(unsigned long arg)
 {
 	struct net_device *dev = (struct net_device *)arg;
@@ -205,25 +220,30 @@ static void dev_watchdog(unsigned long arg)
 		if (netif_device_present(dev) &&
 		    netif_running(dev) &&
 		    netif_carrier_ok(dev)) {
-			int some_queue_stopped = 0;
+			int some_queue_timedout = 0;
 			unsigned int i;
+			unsigned long trans_start;
 
 			for (i = 0; i < dev->num_tx_queues; i++) {
 				struct netdev_queue *txq;
 
 				txq = netdev_get_tx_queue(dev, i);
-				if (netif_tx_queue_stopped(txq)) {
-					some_queue_stopped = 1;
+				/*
+				 * old device drivers set dev->trans_start
+				 */
+				trans_start = txq->trans_start ? : dev->trans_start;
+				if (netif_tx_queue_stopped(txq) && 
+				    time_after(jiffies, (trans_start +
+							 dev->watchdog_timeo))) {
+					some_queue_timedout = 1;
 					break;
 				}
 			}
 
-			if (some_queue_stopped &&
-			    time_after(jiffies, (dev->trans_start +
-						 dev->watchdog_timeo))) {
+			if (some_queue_timedout) {
 				char drivername[64];
-				WARN_ONCE(1, KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit timed out\n",
-				       dev->name, netdev_drivername(dev, drivername, 64));
+				WARN_ONCE(1, KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit queue %u timed out\n",
+				       dev->name, netdev_drivername(dev, drivername, 64), i);
 				dev->netdev_ops->ndo_tx_timeout(dev);
 			}
 			if (!mod_timer(&dev->watchdog_timer,
@@ -602,8 +622,10 @@ static void transition_one_qdisc(struct net_device *dev,
 		clear_bit(__QDISC_STATE_DEACTIVATED, &new_qdisc->state);
 
 	rcu_assign_pointer(dev_queue->qdisc, new_qdisc);
-	if (need_watchdog_p && new_qdisc != &noqueue_qdisc)
+	if (need_watchdog_p && new_qdisc != &noqueue_qdisc) {
+		dev_queue->trans_start = 0;
 		*need_watchdog_p = 1;
+	}
 }
 
 void dev_activate(struct net_device *dev)
