From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 06/12] net: sched: support qdisc_reset on NOLOCK qdisc
Date: Wed, 30 Dec 2015 09:53:13 -0800
Message-ID: <20151230175313.26257.46445.stgit@john-Precision-Tower-5810>
References: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com
To: daniel@iogearbox.net, eric.dumazet@gmail.com, jhs@mojatatu.com,
	aduyck@mirantis.com, brouer@redhat.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35095 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754423AbbL3Rx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 12:53:29 -0500
Received: by mail-pa0-f46.google.com with SMTP id do7so110016pab.2
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 09:53:29 -0800 (PST)
In-Reply-To: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The qdisc_reset operation depends on the qdisc lock at the moment
to halt any additions to gso_skb and statistics while the list is
free'd and the stats zeroed.

Without the qdisc lock we can not guarantee another cpu is not in
the process of adding a skb to one of the "cells". Here are the
two cases we have to handle.

 case 1: qdisc_graft operation. In this case a "new" qdisc is attached
	 and the 'qdisc_destroy' operation is called on the old qdisc.
	 The destroy operation will wait a rcu grace period and call
	 qdisc_rcu_free(). At which point gso_cpu_skb is free'd along
	 with all stats so no need to zero stats and gso_cpu_skb from
	 the reset operation itself.

	 Because we can not continue to call qdisc_reset before waiting
	 an rcu grace period so that the qdisc is detached from all
	 cpus simply do not call qdisc_reset() at all and let the
	 qdisc_destroy operation clean up the qdisc. Note, a refcnt
	 greater than 1 would cause the destroy operation to be
	 aborted however if this ever happened the reference to the
	 qdisc would be lost and we would have a memory leak.

 case 2: dev_deactivate sequence. This can come from a user bringing
	 the interface down which causes the gso_skb list to be flushed
	 and the qlen zero'd. At the moment this is protected by the
	 qdisc lock so while we clear the qlen/gso_skb fields we are
	 guaranteed no new skbs are added. For the lockless case
	 though this is not true. To resolve this move the qdisc_reset
	 call after the new qdisc is assigned and a grace period is
	 exercised to ensure no new skbs can be enqueued. Further
	 the RTNL lock is held so we can not get another call to
	 activate the qdisc while the skb lists are being free'd.

	 Finally, fix qdisc_reset to handle the per cpu stats and
	 skb lists.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/sch_generic.c |   42 +++++++++++++++++++++++++++++++++++-------
 1 file changed, 35 insertions(+), 7 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 9aeb51f..134fb95 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -666,6 +666,18 @@ void qdisc_reset(struct Qdisc *qdisc)
 	if (ops->reset)
 		ops->reset(qdisc);
 
+	if (qdisc->gso_cpu_skb) {
+		int i;
+
+		for_each_possible_cpu(i) {
+			struct gso_cell *cell;
+
+			cell = per_cpu_ptr(qdisc->gso_cpu_skb, i);
+			if (cell)
+				kfree_skb_list(cell->skb);
+		}
+	}
+
 	if (qdisc->gso_skb) {
 		kfree_skb_list(qdisc->gso_skb);
 		qdisc->gso_skb = NULL;
@@ -740,10 +752,6 @@ struct Qdisc *dev_graft_qdisc(struct netdev_queue *dev_queue,
 	root_lock = qdisc_lock(oqdisc);
 	spin_lock_bh(root_lock);
 
-	/* Prune old scheduler */
-	if (oqdisc && atomic_read(&oqdisc->refcnt) <= 1)
-		qdisc_reset(oqdisc);
-
 	/* ... and graft new one */
 	if (qdisc == NULL)
 		qdisc = &noop_qdisc;
@@ -857,7 +865,6 @@ static void dev_deactivate_queue(struct net_device *dev,
 			set_bit(__QDISC_STATE_DEACTIVATED, &qdisc->state);
 
 		rcu_assign_pointer(dev_queue->qdisc, qdisc_default);
-		qdisc_reset(qdisc);
 
 		spin_unlock_bh(qdisc_lock(qdisc));
 	}
@@ -890,6 +897,18 @@ static bool some_qdisc_is_busy(struct net_device *dev)
 	return false;
 }
 
+static void dev_qdisc_reset(struct net_device *dev,
+			    struct netdev_queue *dev_queue,
+			    void *none)
+{
+	struct Qdisc *qdisc = dev_queue->qdisc_sleeping;
+
+	WARN_ON(!qdisc);
+
+	if (qdisc)
+		qdisc_reset(qdisc);
+}
+
 /**
  * 	dev_deactivate_many - deactivate transmissions on several devices
  * 	@head: list of devices to deactivate
@@ -910,7 +929,7 @@ void dev_deactivate_many(struct list_head *head)
 					     &noop_qdisc);
 
 		dev_watchdog_down(dev);
-		sync_needed |= !dev->dismantle;
+		sync_needed = true;
 	}
 
 	/* Wait for outstanding qdisc-less dev_queue_xmit calls.
@@ -921,9 +940,18 @@ void dev_deactivate_many(struct list_head *head)
 		synchronize_net();
 
 	/* Wait for outstanding qdisc_run calls. */
-	list_for_each_entry(dev, head, close_list)
+	list_for_each_entry(dev, head, close_list) {
 		while (some_qdisc_is_busy(dev))
 			yield();
+
+		/* The new qdisc is assigned at this point so we can safely
+		 * unwind stale skb lists and qdisc statistics
+		 */
+		netdev_for_each_tx_queue(dev, dev_qdisc_reset, NULL);
+		if (dev_ingress_queue(dev))
+			dev_qdisc_reset(dev, dev_ingress_queue(dev), NULL);
+	}
+
 }
 
 void dev_deactivate(struct net_device *dev)
