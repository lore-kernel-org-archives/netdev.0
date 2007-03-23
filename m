From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET_SCHED 11/11]: qdisc: avoid dequeue while throttled
Date: Fri, 23 Mar 2007 15:39:42 +0100
Message-ID: <4603E6AE.6000606@trash.net>
References: <20070323133513.10264.16515.sendpatchset@localhost.localdomain> <20070323133528.10264.68156.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010105060009090405040308"
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62677 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109AbXCWOkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 10:40:12 -0400
In-Reply-To: <20070323133528.10264.68156.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010105060009090405040308
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> [NET_SCHED]: qdisc: avoid dequeue while throttled


It just occured to me that this doesn't work properly with qdiscs
that have multiple classes since they all don't properly maintain
the TCQ_F_THROTTLED flag. They set it on dequeue when no active
class is willing to give out packets, but when enqueueing to a
non-active class (thereby activating it) it is still set even though
we don't know if that class could be dequeued.

So this updated patch unsets the TCQ_F_THROTTLED flag whenever we
activate a class. Additionally it removes the unsetting of
TCQ_F_THROTTLED on successful dequeue since we're now guaranteed
that it was not set before.


--------------010105060009090405040308
Content-Type: text/x-diff;
 name="11.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="11.diff"

[NET_SCHED]: qdisc: avoid dequeue while throttled

Avoid dequeueing while the device is throttled.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 073456c84a46736a3aa1ae4cc9d953a9e97b327c
tree 805a29224001180c88a429e65812b97a489c427a
parent e2459acd7dee06fb4d5e980f26c23d31db0e5de1
author Patrick McHardy <kaber@trash.net> Fri, 23 Mar 2007 15:37:51 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 23 Mar 2007 15:37:51 +0100

 net/sched/sch_cbq.c     |    5 +++--
 net/sched/sch_generic.c |    4 ++++
 net/sched/sch_hfsc.c    |    5 +++--
 net/sched/sch_htb.c     |    6 ++++--
 net/sched/sch_netem.c   |    4 ----
 net/sched/sch_tbf.c     |    1 -
 6 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index a294542..151f8e3 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -424,8 +424,10 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		sch->bstats.packets++;
 		sch->bstats.bytes+=len;
 		cbq_mark_toplevel(q, cl);
-		if (!cl->next_alive)
+		if (!cl->next_alive) {
 			cbq_activate_class(cl);
+			sch->flags &= ~TCQ_F_THROTTLED;
+		}
 		return ret;
 	}
 
@@ -1030,7 +1032,6 @@ cbq_dequeue(struct Qdisc *sch)
 		skb = cbq_dequeue_1(sch);
 		if (skb) {
 			sch->q.qlen--;
-			sch->flags &= ~TCQ_F_THROTTLED;
 			return skb;
 		}
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 52eb343..39c5312 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -93,6 +93,10 @@ static inline int qdisc_restart(struct net_device *dev)
 	struct Qdisc *q = dev->qdisc;
 	struct sk_buff *skb;
 
+	smp_rmb();
+	if (q->flags & TCQ_F_THROTTLED)
+		return q->q.qlen;
+
 	/* Dequeue packet */
 	if (((skb = dev->gso_skb)) || ((skb = q->dequeue(q)))) {
 		unsigned nolock = (dev->features & NETIF_F_LLTX);
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 22cec11..c6da436 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1597,8 +1597,10 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return err;
 	}
 
-	if (cl->qdisc->q.qlen == 1)
+	if (cl->qdisc->q.qlen == 1) {
 		set_active(cl, len);
+		sch->flags &= ~TCQ_F_THROTTLED;
+	}
 
 	cl->bstats.packets++;
 	cl->bstats.bytes += len;
@@ -1672,7 +1674,6 @@ hfsc_dequeue(struct Qdisc *sch)
 	}
 
  out:
-	sch->flags &= ~TCQ_F_THROTTLED;
 	sch->q.qlen--;
 
 	return skb;
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 71db121..1387b7b 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -615,6 +615,8 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		/* enqueue to helper queue */
 		if (q->direct_queue.qlen < q->direct_qlen) {
 			__skb_queue_tail(&q->direct_queue, skb);
+			if (q->direct_queue.qlen == 1)
+				sch->flags &= ~TCQ_F_THROTTLED;
 			q->direct_pkts++;
 		} else {
 			kfree_skb(skb);
@@ -637,6 +639,8 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		cl->bstats.packets++;
 		cl->bstats.bytes += skb->len;
 		htb_activate(q, cl);
+		if (cl->un.leaf.q->q.qlen == 1)
+			sch->flags &= ~TCQ_F_THROTTLED;
 	}
 
 	sch->q.qlen++;
@@ -958,7 +962,6 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 	/* try to dequeue direct packets as high prio (!) to minimize cpu work */
 	skb = __skb_dequeue(&q->direct_queue);
 	if (skb != NULL) {
-		sch->flags &= ~TCQ_F_THROTTLED;
 		sch->q.qlen--;
 		return skb;
 	}
@@ -991,7 +994,6 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 			skb = htb_dequeue_tree(q, prio, level);
 			if (likely(skb != NULL)) {
 				sch->q.qlen--;
-				sch->flags &= ~TCQ_F_THROTTLED;
 				goto fin;
 			}
 		}
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 5d9d8bc..4c7a8d8 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -273,10 +273,6 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 	struct netem_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
 
-	smp_mb();
-	if (sch->flags & TCQ_F_THROTTLED)
-		return NULL;
-
 	skb = q->qdisc->dequeue(q->qdisc);
 	if (skb) {
 		const struct netem_skb_cb *cb
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 5386295..ed7e581 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -218,7 +218,6 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 			q->tokens = toks;
 			q->ptokens = ptoks;
 			sch->q.qlen--;
-			sch->flags &= ~TCQ_F_THROTTLED;
 			return skb;
 		}
 

--------------010105060009090405040308--
