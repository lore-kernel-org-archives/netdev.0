From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in RCU.
Date: Thu, 17 Jul 2008 05:17:26 -0700 (PDT)
Message-ID: <20080717.051726.226040470.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


This allows less strict control of access to the qdisc attached to a
netdev_queue.  It is even allowed to enqueue into a qdisc which is
in the process of being destroyed.  The RCU handler will toss out
those packets.

We will need this to handle sharing of a qdisc amongst multiple
TX queues.  In such a setup the lock has to be shared, so will
be inside of the qdisc itself.  At which point the netdev_queue
lock cannot be used to hard synchronize access to the ->qdisc
pointer.

One operation we have to keep inside of qdisc_destroy() is the list
deletion.  It is the only piece of state visible after the RCU quiesce
period, so we have to undo it early and under the appropriate locking.

The operations in the RCU handler do not need any looking because the
qdisc tree is no longer visible to anything at that point.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 net/sched/sch_generic.c |   20 +++++++++++---------
 1 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 7e078c5..082db8a 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -545,6 +545,17 @@ EXPORT_SYMBOL(qdisc_reset);
 static void __qdisc_destroy(struct rcu_head *head)
 {
 	struct Qdisc *qdisc = container_of(head, struct Qdisc, q_rcu);
+	const struct Qdisc_ops  *ops = qdisc->ops;
+
+	gen_kill_estimator(&qdisc->bstats, &qdisc->rate_est);
+	if (ops->reset)
+		ops->reset(qdisc);
+	if (ops->destroy)
+		ops->destroy(qdisc);
+
+	module_put(ops->owner);
+	dev_put(qdisc_dev(qdisc));
+
 	kfree((char *) qdisc - qdisc->padded);
 }
 
@@ -552,21 +563,12 @@ static void __qdisc_destroy(struct rcu_head *head)
 
 void qdisc_destroy(struct Qdisc *qdisc)
 {
-	const struct Qdisc_ops  *ops = qdisc->ops;
