From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 5/5] net: remove dev->trans_start
Date: Tue,  3 May 2016 16:33:14 +0200
Message-ID: <1462285994-31983-2-git-send-email-fw@strlen.de>
References: <1462285862-30946-1-git-send-email-fw@strlen.de>
 <1462285994-31983-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:49850 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933318AbcECPUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 11:20:49 -0400
In-Reply-To: <1462285994-31983-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

previous patches removed all direct accesses to dev->trans_start,
so change the netif_trans_update helper to update trans_start of
netdev queue 0 instead and then remove trans_start from struct net_device.

AFAICS a lot of the netif_trans_update() invocations are now useless
because they occur in ndo_start_xmit and driver doesn't set LLTX
(i.e. stack already took care of the update).

As I can't test any of them it seems better to just leave them alone.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c |  2 +-
 include/linux/netdevice.h                   | 15 +++++----------
 net/sched/sch_generic.c                     | 10 +++-------
 3 files changed, 9 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 8e6c0f2..f6da6b7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -328,7 +328,7 @@ static void i40e_tx_timeout(struct net_device *netdev)
 		unsigned long trans_start;
 
 		q = netdev_get_tx_queue(netdev, i);
-		trans_start = q->trans_start ? : netdev->trans_start;
+		trans_start = q->trans_start;
 		if (netif_xmit_stopped(q) &&
 		    time_after(jiffies,
 			       (trans_start + netdev->watchdog_timeo))) {
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 798f285..fba2faa 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -581,7 +581,7 @@ struct netdev_queue {
 	spinlock_t		_xmit_lock ____cacheline_aligned_in_smp;
 	int			xmit_lock_owner;
 	/*
-	 * please use this field instead of dev->trans_start
+	 * Time (in jiffies) of last Tx
 	 */
 	unsigned long		trans_start;
 
@@ -1545,7 +1545,6 @@ enum netdev_priv_flags {
  *
  *	@offload_fwd_mark:	Offload device fwding mark
  *
- *	@trans_start:		Time (in jiffies) of last Tx
  *	@watchdog_timeo:	Represents the timeout that is used by
  *				the watchdog (see dev_watchdog())
  *	@watchdog_timer:	List of timers
@@ -1794,13 +1793,6 @@ struct net_device {
 #endif
 
 	/* These may be needed for future network-power-down code. */
-
-	/*
-	 * trans_start here is expensive for high speed devices on SMP,
-	 * please use netdev_queue->trans_start instead.
-	 */
-	unsigned long		trans_start;
-
 	struct timer_list	watchdog_timer;
 
 	int __percpu		*pcpu_refcnt;
@@ -3484,7 +3476,10 @@ static inline void txq_trans_update(struct netdev_queue *txq)
 /* legacy drivers only, netdev_start_xmit() sets txq->trans_start */
 static inline void netif_trans_update(struct net_device *dev)
 {
-	dev->trans_start = jiffies;
+	struct netdev_queue *txq = netdev_get_tx_queue(dev, 0);
+
+	if (txq->trans_start != jiffies)
+		txq->trans_start = jiffies;
 }
 
 /**
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 70182cf..269dd71 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -227,13 +227,12 @@ unsigned long dev_trans_start(struct net_device *dev)
 
 	if (is_vlan_dev(dev))
 		dev = vlan_dev_real_dev(dev);
-	res = dev->trans_start;
-	for (i = 0; i < dev->num_tx_queues; i++) {
+	res = netdev_get_tx_queue(dev, 0)->trans_start;
+	for (i = 1; i < dev->num_tx_queues; i++) {
 		val = netdev_get_tx_queue(dev, i)->trans_start;
 		if (val && time_after(val, res))
 			res = val;
 	}
-	dev->trans_start = res;
 
 	return res;
 }
@@ -256,10 +255,7 @@ static void dev_watchdog(unsigned long arg)
 				struct netdev_queue *txq;
 
 				txq = netdev_get_tx_queue(dev, i);
-				/*
-				 * old device drivers set dev->trans_start
-				 */
-				trans_start = txq->trans_start ? : dev->trans_start;
+				trans_start = txq->trans_start;
 				if (netif_xmit_stopped(txq) &&
 				    time_after(jiffies, (trans_start +
 							 dev->watchdog_timeo))) {
-- 
2.7.3
