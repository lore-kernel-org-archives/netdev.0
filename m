From: David Miller <davem@davemloft.net>
Subject: Re: bnx2_poll panicking kernel
Date: Fri, 11 Jul 2008 02:56:56 -0700 (PDT)
Message-ID: <20080711.025656.261409874.davem@davemloft.net>
References: <20080710223141.GA2519@orion.carnet.hr>
	<20080710.162007.04790623.davem@davemloft.net>
	<20080711092416.GA26515@orion.carnet.hr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, billfink@mindspring.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	mirrors@debian.org, kaber@trash.net, devik@cdi.cz
To: joy@entuzijast.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50764
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750992AbYGKJ5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2008 05:57:09 -0400
In-Reply-To: <20080711092416.GA26515@orion.carnet.hr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josip Rodin <joy@entuzijast.net>
Date: Fri, 11 Jul 2008 11:24:16 +0200

[ Patrick/Martin, you can simply skip to the final paragraph. ]

> Here we go, it triggered, here are the first few, tell me if you need more:

Thanks for the trace:

> Jul 11 02:15:10 arrakis kernel: Splitting cloned skb
> Jul 11 02:15:10 arrakis kernel: Pid: 0, comm: swapper Not tainted 2.6.25.6 #2
> Jul 11 02:15:10 arrakis kernel: 
> Jul 11 02:15:10 arrakis kernel: Call Trace:
> Jul 11 02:15:10 arrakis kernel:  <IRQ>  [<ffffffff803e5e75>] __alloc_skb+0x85/0x150
> Jul 11 02:15:10 arrakis kernel:  [<ffffffff803e66aa>] skb_split+0x4a/0x300
> Jul 11 02:15:10 arrakis kernel:  [<ffffffff8042700b>] tso_fragment+0xfb/0x180
> Jul 11 02:15:10 arrakis kernel:  [<ffffffff8042716e>] __tcp_push_pending_frames+0xde/0x860
> Jul 11 02:15:10 arrakis kernel:  [<ffffffff80424596>] tcp_rcv_established+0x596/0x9d0

So it's splitting a frame up which should be new data, but for
some reason made it to the device previously.

The comment above tso_fragment() reads:

/* Trim TSO SKB to LEN bytes, put the remaining data into a new packet
 * which is put after SKB on the list.  It is very much like
 * tcp_fragment() except that it may make several kinds of assumptions
 * in order to speed up the splitting operation.  In particular, we
 * know that all the data is in scatter-gather pages, and that the
 * packet has never been sent out before (and thus is not cloned).
 */

Note in particular the final phrase inside the parens. :-)))

There is only one way this situation seen in the trace can develop.
That is if the queueing discipline gave the packet to the device, yet
returned a value that made TCP believe the packet was not.

When TCP sees such a return value, it does not advance the head of the
write queue.  It will retry to send that head packet again later.  And
that's what we seem to be seeing here.

TCP treats any non-zero return value other than NET_XMIT_CN
in this way (see tcp_transmit_skb and how it uses net_xmit_eval).

I notice that HTB does a lot of very queer things wrt. return
values.

For example, it seems that if the class's leaf queue ->enqueue()
returns any non-success value, it gives NET_XMIT_DROP back down to the
call chain.

But what if that leaf ->enqueue() is something that passes back
NET_XMIT_CN?  NET_XMIT_CN can be signalled for things like RED, in
cases where some "other" packet in the same class got dropped but not
necessarily the one you enqueued.

NET_XMIT_CN means backoff, but it does not indicate that the specific
packet being enqueued was dropped.  It just means "some" packet from
the same flow was dropped, and therefore there is congestion on this
flow.

Even more simpler qdiscs such as SFQ use the NET_XMIT_CN return value
when it does a drop.

So this return value munging being done by HTB creates the illegal
situation.

I'm not sure how to fix this, because I'm not sure how these
NET_XMIT_CN situations should be handled wrt. maintaining a proper
parent queue length value.

Patrick/Martin, in HTB's ->enqueue() and ->requeue() we need to
propagate NET_XMIT_CN to the caller if that's what the leaf qdisc
signals to us.  But the question is, should sch->q.qlen be
incremented in that case?  NET_XMIT_CN means that some packet got
dropped, but not necessarily this one.  If, for example, RED
drops another packet already in the queue does it somehow adjust
the parent sch->q.qlen back down?  If not, it's pretty clear how
this bug got created in the first place :)  Below is my idiotic
attempt to cure this, but this whole situation needs an audit:

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 3fb58f4..aa20b47 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -583,6 +583,7 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		if (q->direct_queue.qlen < q->direct_qlen) {
 			__skb_queue_tail(&q->direct_queue, skb);
 			q->direct_pkts++;
+			ret = NET_XMIT_SUCCESS;
 		} else {
 			kfree_skb(skb);
 			sch->qstats.drops++;
@@ -595,22 +596,26 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		kfree_skb(skb);
 		return ret;
 #endif
-	} else if (cl->un.leaf.q->enqueue(skb, cl->un.leaf.q) !=
-		   NET_XMIT_SUCCESS) {
-		sch->qstats.drops++;
-		cl->qstats.drops++;
-		return NET_XMIT_DROP;
 	} else {
-		cl->bstats.packets +=
-			skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
-		cl->bstats.bytes += skb->len;
-		htb_activate(q, cl);
+		ret = cl->un.leaf.q->enqueue(skb, cl->un.leaf.q);
+		if (ret == NET_XMIT_DROP) {
+			sch->qstats.drops++;
+			cl->qstats.drops++;
+		} else {
+			cl->bstats.packets +=
+				skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
+			cl->bstats.bytes += skb->len;
+			htb_activate(q, cl);
+		}
 	}
 
-	sch->q.qlen++;
-	sch->bstats.packets += skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
-	sch->bstats.bytes += skb->len;
-	return NET_XMIT_SUCCESS;
+	if (ret == NET_XMIT_SUCCESS) {
+		sch->q.qlen++;
+		sch->bstats.packets +=
+			skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
+		sch->bstats.bytes += skb->len;
+	}
+	return ret;
 }
 
 /* TODO: requeuing packet charges it to policers again !! */
@@ -625,6 +630,7 @@ static int htb_requeue(struct sk_buff *skb, struct Qdisc *sch)
 		/* enqueue to helper queue */
 		if (q->direct_queue.qlen < q->direct_qlen) {
 			__skb_queue_head(&q->direct_queue, skb);
+			ret = NET_XMIT_SUCCESS;
 		} else {
 			__skb_queue_head(&q->direct_queue, skb);
 			tskb = __skb_dequeue_tail(&q->direct_queue);
@@ -639,17 +645,21 @@ static int htb_requeue(struct sk_buff *skb, struct Qdisc *sch)
 		kfree_skb(skb);
 		return ret;
 #endif
-	} else if (cl->un.leaf.q->ops->requeue(skb, cl->un.leaf.q) !=
-		   NET_XMIT_SUCCESS) {
-		sch->qstats.drops++;
-		cl->qstats.drops++;
-		return NET_XMIT_DROP;
-	} else
-		htb_activate(q, cl);
+	} else {
+		ret = cl->un.leaf.q->ops->requeue(skb, cl->un.leaf.q);
+		if (ret == NET_XMIT_DROP) {
+			sch->qstats.drops++;
+			cl->qstats.drops++;
+		} else {
+			htb_activate(q, cl);
+		}
+	}
 
-	sch->q.qlen++;
-	sch->qstats.requeues++;
-	return NET_XMIT_SUCCESS;
+	if (ret == NET_XMIT_SUCCESS) {
+		sch->q.qlen++;
+		sch->qstats.requeues++;
+	}
+	return ret;
 }
 
 /**

