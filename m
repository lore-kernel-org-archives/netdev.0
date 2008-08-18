From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Kill qdisc rcu freeing...
Date: Sun, 17 Aug 2008 22:34:35 -0700 (PDT)
Message-ID: <20080817.223435.193704624.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32867
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750829AbYHRFeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 01:34:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ok, I flipped the switch.  I've checked in the following to
net-2.6 and it seems to pass a bunch of smoke tests I just
did (flood pings while adding and deleting various qdisc
setups, etc.)

Jarek, I think we can possibly now revert that locking change
you had to make because destroy was outside of RTNL?

pkt_sched: No longer destroy qdiscs from RCU.

We can now kill them synchronously with all of the
previous dev_deactivate() cures.

This makes netdev destruction and shutdown saner as
the qdiscs hold references to the device.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/sch_generic.h |    1 -
 net/sched/sch_generic.c   |   27 +++++++++------------------
 2 files changed, 9 insertions(+), 19 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 757ab08..84d25f2 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -61,7 +61,6 @@ struct Qdisc
 	struct gnet_stats_basic	bstats;
 	struct gnet_stats_queue	qstats;
 	struct gnet_stats_rate_est	rate_est;
-	struct rcu_head 	q_rcu;
 	int			(*reshape_fail)(struct sk_buff *skb,
 					struct Qdisc *q);
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 30b76ae..6f96b7b 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -518,14 +518,19 @@ void qdisc_reset(struct Qdisc *qdisc)
 }
 EXPORT_SYMBOL(qdisc_reset);
 
-/* this is the rcu callback function to clean up a qdisc when there
- * are no further references to it */
+/* Under qdisc_lock(qdisc) and BH! */
 
-static void __qdisc_destroy(struct rcu_head *head)
+void qdisc_destroy(struct Qdisc *qdisc)
 {
-	struct Qdisc *qdisc = container_of(head, struct Qdisc, q_rcu);
 	const struct Qdisc_ops  *ops = qdisc->ops;
 
+	if (qdisc->flags & TCQ_F_BUILTIN ||
+	    !atomic_dec_and_test(&qdisc->refcnt))
+		return;
+
+	if (qdisc->parent)
+		list_del(&qdisc->list);
+
 #ifdef CONFIG_NET_SCHED
 	qdisc_put_stab(qdisc->stab);
 #endif
@@ -542,20 +547,6 @@ static void __qdisc_destroy(struct rcu_head *head)
 
 	kfree((char *) qdisc - qdisc->padded);
 }
-
-/* Under qdisc_lock(qdisc) and BH! */
-
-void qdisc_destroy(struct Qdisc *qdisc)
-{
-	if (qdisc->flags & TCQ_F_BUILTIN ||
-	    !atomic_dec_and_test(&qdisc->refcnt))
-		return;
-
-	if (qdisc->parent)
-		list_del(&qdisc->list);
-
-	call_rcu(&qdisc->q_rcu, __qdisc_destroy);
-}
 EXPORT_SYMBOL(qdisc_destroy);
 
 static bool dev_all_qdisc_sleeping_noop(struct net_device *dev)
-- 
1.5.6.5.GIT

