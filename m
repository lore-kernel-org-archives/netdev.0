From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH v2 07/17] net: sched: drop qdisc_reset from
 dev_graft_qdisc
Date: Tue, 02 May 2017 08:38:19 -0700
Message-ID: <20170502153819.9304.39271.stgit@john-Precision-Tower-5810>
References: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34722 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750791AbdEBPic (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:38:32 -0400
Received: by mail-pf0-f194.google.com with SMTP id g23so33820267pfj.1
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 08:38:32 -0700 (PDT)
In-Reply-To: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In qdisc_graft_qdisc a "new" qdisc is attached and the 'qdisc_destroy'
operation is called on the old qdisc. The destroy operation will wait
a rcu grace period and call qdisc_rcu_free(). At which point
gso_cpu_skb is free'd along with all stats so no need to zero stats
and gso_cpu_skb from the graft operation itself.

Further after dropping the qdisc locks we can not continue to call
qdisc_reset before waiting an rcu grace period so that the qdisc is
detached from all cpus. By removing the qdisc_reset() here we get
the correct property of waiting an rcu grace period and letting the
qdisc_destroy operation clean up the qdisc correctly.

Note, a refcnt greater than 1 would cause the destroy operation to
be aborted however if this ever happened the reference to the qdisc
would be lost and we would have a memory leak.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/sch_generic.c |   28 +++++++++++++++++++---------
 1 file changed, 19 insertions(+), 9 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index f179fc9..37cd54e 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -813,10 +813,6 @@ struct Qdisc *dev_graft_qdisc(struct netdev_queue *dev_queue,
 	root_lock = qdisc_lock(oqdisc);
 	spin_lock_bh(root_lock);
 
-	/* Prune old scheduler */
-	if (oqdisc && atomic_read(&oqdisc->refcnt) <= 1)
-		qdisc_reset(oqdisc);
-
 	/* ... and graft new one */
 	if (qdisc == NULL)
 		qdisc = &noop_qdisc;
@@ -971,6 +967,16 @@ static bool some_qdisc_is_busy(struct net_device *dev)
 	return false;
 }
 
+static void dev_qdisc_reset(struct net_device *dev,
+			    struct netdev_queue *dev_queue,
+			    void *none)
+{
+	struct Qdisc *qdisc = dev_queue->qdisc_sleeping;
+
+	if (qdisc)
+		qdisc_reset(qdisc);
+}
+
 /**
  * 	dev_deactivate_many - deactivate transmissions on several devices
  * 	@head: list of devices to deactivate
@@ -981,7 +987,6 @@ static bool some_qdisc_is_busy(struct net_device *dev)
 void dev_deactivate_many(struct list_head *head)
 {
 	struct net_device *dev;
-	bool sync_needed = false;
 
 	list_for_each_entry(dev, head, close_list) {
 		netdev_for_each_tx_queue(dev, dev_deactivate_queue,
@@ -991,20 +996,25 @@ void dev_deactivate_many(struct list_head *head)
 					     &noop_qdisc);
 
 		dev_watchdog_down(dev);
-		sync_needed |= !dev->dismantle;
 	}
 
 	/* Wait for outstanding qdisc-less dev_queue_xmit calls.
 	 * This is avoided if all devices are in dismantle phase :
 	 * Caller will call synchronize_net() for us
 	 */
-	if (sync_needed)
-		synchronize_net();
+	synchronize_net();
 
 	/* Wait for outstanding qdisc_run calls. */
-	list_for_each_entry(dev, head, close_list)
+	list_for_each_entry(dev, head, close_list) {
 		while (some_qdisc_is_busy(dev))
 			yield();
+		/* The new qdisc is assigned at this point so we can safely
+		 * unwind stale skb lists and qdisc statistics
+		 */
+		netdev_for_each_tx_queue(dev, dev_qdisc_reset, NULL);
+		if (dev_ingress_queue(dev))
+			dev_qdisc_reset(dev, dev_ingress_queue(dev), NULL);
+	}
 }
 
 void dev_deactivate(struct net_device *dev)
