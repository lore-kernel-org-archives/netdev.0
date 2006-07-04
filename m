From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Tue, 04 Jul 2006 15:29:09 +0200
Message-ID: <44AA6D25.9000707@trash.net>
References: <1150278004.26181.35.camel@localhost.localdomain>	 <1150286766.5233.15.camel@jzny2>	 <1150287983.3246.27.camel@ras.pc.brisbane.lube>	 <1150292693.5197.1.camel@jzny2>	 <1150843471.17455.2.camel@ras.pc.brisbane.lube>	 <15653CE98281AD4FBD7F70BCEE3666E53CD54A@comxexch01.comx.local>	 <1151000966.5392.34.camel@jzny2>	 <1151066247.4217.254.camel@ras.pc.brisbane.lube>	 <449C06E3.3090406@trash.net> <1151282720.4210.46.camel@ras.pc.brisbane.lube> <449FC0AF.1050904@trash.net> <44A0CE01.4010109@stuart.id.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000104010102010909030303"
Cc: Russell Stuart <russell-tcatm@stuart.id.au>, hadi@cyberus.ca,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Stephen Hemminger <shemminger@osdl.org>,
	netdev@vger.kernel.org, Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:11710 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932236AbWGDN3M
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jul 2006 09:29:12 -0400
To: Russell Stuart <russell@stuart.id.au>
In-Reply-To: <44A0CE01.4010109@stuart.id.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000104010102010909030303
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Russell Stuart wrote:
> On 26/06/2006 9:10 PM, Patrick McHardy wrote:
> 
>>> 5.  We still did have to modify the kernel for ATM.  That was
>>>    because of its rather unusual characteristics.  However,
>>>    it you look at the size of modifications made to the kernel
>>>    verses the size made to the user space tool, (37 lines
>>>    versus 303 lines,) the bulk of the work was does in user
>>>    space.
>>
>>
>> I'm sorry, but arguing that a limited special case solution is
>> better because it needs slightly less code is just not reasonable.
> 
> 
> Without seeing your actual proposal it is difficult to
> judge whether this is a reasonable trade-off or not.
> Hopefully we will see your code soon.  Do you have any
> idea when?

Unfortunately I still didn't got to cleaning them up, so I'm sending
them in their preliminary state. Its not much that is missing, but
the netem usage of skb->cb needs to be integrated better, I failed
to move it to the qdisc_skb_cb so far because of circular includes.
But nothing unfixable. I'm mostly interested if the current size-tables
can express what you need for ATM, I wasn't able to understand the
big comment in tc_core.c in your patch.


--------------000104010102010909030303
Content-Type: text/plain;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

[NET_SCHED]: Add accessor function for packet length for qdiscs

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 2a6508576111d82246ee018edbcc4b0f0d18acad
tree 8be27ab6040ea90ed11728763e5b8fcf9e221b67
parent 31304c909e6945b005af62cd55a582e9c010a0b4
author Patrick McHardy <kaber@trash.net> Tue, 04 Jul 2006 15:03:01 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 04 Jul 2006 15:03:01 +0200

 include/net/sch_generic.h |    9 +++++++--
 net/sched/sch_atm.c       |    4 ++--
 net/sched/sch_cbq.c       |   12 ++++++------
 net/sched/sch_dsmark.c    |    2 +-
 net/sched/sch_fifo.c      |    2 +-
 net/sched/sch_gred.c      |   12 ++++++------
 net/sched/sch_hfsc.c      |    8 ++++----
 net/sched/sch_htb.c       |    8 ++++----
 net/sched/sch_netem.c     |    6 +++---
 net/sched/sch_prio.c      |    2 +-
 net/sched/sch_red.c       |    2 +-
 net/sched/sch_sfq.c       |   14 +++++++-------
 net/sched/sch_tbf.c       |    6 +++---
 net/sched/sch_teql.c      |    4 ++--
 14 files changed, 48 insertions(+), 43 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index b0e9108..75d7a55 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -184,12 +184,17 @@ tcf_destroy(struct tcf_proto *tp)
 	kfree(tp);
 }
 
+static inline unsigned int qdisc_tx_len(struct sk_buff *skb)
+{
+	return skb->len;
+}
+
 static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
 				       struct sk_buff_head *list)
 {
 	__skb_queue_tail(list, skb);
-	sch->qstats.backlog += skb->len;
-	sch->bstats.bytes += skb->len;
+	sch->qstats.backlog += qdisc_tx_len(skb);
+	sch->bstats.bytes += qdisc_tx_len(skb);
 	sch->bstats.packets++;
 
 	return NET_XMIT_SUCCESS;
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index dbf44da..4df305e 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -453,9 +453,9 @@ #endif
 		if (flow) flow->qstats.drops++;
 		return ret;
 	}
-	sch->bstats.bytes += skb->len;
+	sch->bstats.bytes += qdisc_tx_len(skb);
 	sch->bstats.packets++;
-	flow->bstats.bytes += skb->len;
+	flow->bstats.bytes += qdisc_tx_len(skb);
 	flow->bstats.packets++;
 	/*
 	 * Okay, this may seem weird. We pretend we've dropped the packet if
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 80b7f6a..5d705e2 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -404,7 +404,7 @@ static int
 cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
-	int len = skb->len;
+	int len = qdisc_tx_len(skb);
 	int ret;
 	struct cbq_class *cl = cbq_classify(skb, sch, &ret);
 
@@ -688,7 +688,7 @@ #ifdef CONFIG_NET_CLS_POLICE
 
 static int cbq_reshape_fail(struct sk_buff *skb, struct Qdisc *child)
 {
-	int len = skb->len;
+	int len = qdisc_tx_len(skb);
 	struct Qdisc *sch = child->__parent;
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl = q->rx_class;
@@ -915,7 +915,7 @@ cbq_dequeue_prio(struct Qdisc *sch, int 
 			if (skb == NULL)
 				goto skip_class;
 
-			cl->deficit -= skb->len;
+			cl->deficit -= qdisc_tx_len(skb);
 			q->tx_class = cl;
 			q->tx_borrowed = borrow;
 			if (borrow != cl) {
@@ -923,11 +923,11 @@ #ifndef CBQ_XSTATS_BORROWS_BYTES
 				borrow->xstats.borrows++;
 				cl->xstats.borrows++;
 #else
-				borrow->xstats.borrows += skb->len;
-				cl->xstats.borrows += skb->len;
+				borrow->xstats.borrows += qdisc_tx_len(skb);
+				cl->xstats.borrows += qdisc_tx_len(skb);
 #endif
 			}
-			q->tx_len = skb->len;
+			q->tx_len = qdisc_tx_len(skb);
 
 			if (cl->deficit <= 0) {
 				q->active[prio] = cl;
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 11c8a21..53346c6 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -265,7 +265,7 @@ #endif
 		return err;
 	}
 
-	sch->bstats.bytes += skb->len;
+	sch->bstats.bytes += qdisc_tx_len(skb);
 	sch->bstats.packets++;
 	sch->q.qlen++;
 
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index c2689f4..ec99321 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -28,7 +28,7 @@ static int bfifo_enqueue(struct sk_buff 
 {
 	struct fifo_sched_data *q = qdisc_priv(sch);
 
-	if (likely(sch->qstats.backlog + skb->len <= q->limit))
+	if (likely(sch->qstats.backlog + qdisc_tx_len(skb) <= q->limit))
 		return qdisc_enqueue_tail(skb, sch);
 
 	return qdisc_reshape_fail(skb, sch);
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index 0cafdd5..f0bf5d7 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -189,7 +189,7 @@ static int gred_enqueue(struct sk_buff *
 	}
 
 	q->packetsin++;
-	q->bytesin += skb->len;
+	q->bytesin += qdisc_tx_len(skb);
 
 	if (gred_wred_mode(t))
 		gred_load_wred_set(t, q);
@@ -227,8 +227,8 @@ static int gred_enqueue(struct sk_buff *
 			break;
 	}
 
-	if (q->backlog + skb->len <= q->limit) {
-		q->backlog += skb->len;
+	if (q->backlog + qdisc_tx_len(skb) <= q->limit) {
+		q->backlog += qdisc_tx_len(skb);
 		return qdisc_enqueue_tail(skb, sch);
 	}
 
@@ -255,7 +255,7 @@ static int gred_requeue(struct sk_buff *
 	} else {
 		if (red_is_idling(&q->parms))
 			red_end_of_idle_period(&q->parms);
-		q->backlog += skb->len;
+		q->backlog += qdisc_tx_len(skb);
 	}
 
 	return qdisc_requeue(skb, sch);
@@ -278,7 +278,7 @@ static struct sk_buff *gred_dequeue(stru
 				       "VQ 0x%x after dequeue, screwing up "
 				       "backlog.\n", tc_index_to_dp(skb));
 		} else {
-			q->backlog -= skb->len;
+			q->backlog -= qdisc_tx_len(skb);
 
 			if (!q->backlog && !gred_wred_mode(t))
 				red_start_of_idle_period(&q->parms);
@@ -300,7 +300,7 @@ static unsigned int gred_drop(struct Qdi
 
 	skb = qdisc_dequeue_tail(sch);
 	if (skb) {
-		unsigned int len = skb->len;
+		unsigned int len = qdisc_tx_len(skb);
 		struct gred_sched_data *q;
 		u16 dp = tc_index_to_dp(skb);
 
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 6b1b4a9..3fc8351 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -942,7 +942,7 @@ qdisc_peek_len(struct Qdisc *sch)
 			printk("qdisc_peek_len: non work-conserving qdisc ?\n");
 		return 0;
 	}
-	len = skb->len;
+	len = qdisc_tx_len(skb);
 	if (unlikely(sch->ops->requeue(skb, sch) != NET_XMIT_SUCCESS)) {
 		if (net_ratelimit())
 			printk("qdisc_peek_len: failed to requeue\n");
@@ -1648,7 +1648,7 @@ hfsc_enqueue(struct sk_buff *skb, struct
 		return err;
 	}
 
-	len = skb->len;
+	len = qdisc_tx_len(skb);
 	err = cl->qdisc->enqueue(skb, cl->qdisc);
 	if (unlikely(err != NET_XMIT_SUCCESS)) {
 		cl->qstats.drops++;
@@ -1712,9 +1712,9 @@ hfsc_dequeue(struct Qdisc *sch)
 		return NULL;
 	}
 
-	update_vf(cl, skb->len, cur_time);
+	update_vf(cl, qdisc_tx_len(skb), cur_time);
 	if (realtime)
-		cl->cl_cumul += skb->len;
+		cl->cl_cumul += qdisc_tx_len(skb);
 
 	if (cl->qdisc->q.qlen != 0) {
 		if (cl->cl_flags & HFSC_RSC) {
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 34afe41..b26fa9a 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -733,12 +733,12 @@ #endif
 	cl->qstats.drops++;
 	return NET_XMIT_DROP;
     } else {
-	cl->bstats.packets++; cl->bstats.bytes += skb->len;
+	cl->bstats.packets++; cl->bstats.bytes += qdisc_tx_len(skb);
 	htb_activate (q,cl);
     }
 
     sch->q.qlen++;
-    sch->bstats.packets++; sch->bstats.bytes += skb->len;
+    sch->bstats.packets++; sch->bstats.bytes += qdisc_tx_len(skb);
     HTB_DBG(1,1,"htb_enq_ok cl=%X skb=%p\n",(cl && cl != HTB_DIRECT)?cl->classid:0,skb);
     return NET_XMIT_SUCCESS;
 }
@@ -1067,7 +1067,7 @@ next:
 	} while (cl != start);
 
 	if (likely(skb != NULL)) {
-		if ((cl->un.leaf.deficit[level] -= skb->len) < 0) {
+		if ((cl->un.leaf.deficit[level] -= qdisc_tx_len(skb)) < 0) {
 			HTB_DBG(4,2,"htb_next_cl oldptr=%p quant_add=%d\n",
 				level?cl->parent->un.inner.ptr[prio]:q->ptr[0][prio],cl->un.leaf.quantum);
 			cl->un.leaf.deficit[level] += cl->un.leaf.quantum;
@@ -1077,7 +1077,7 @@ next:
 		   gives us slightly better performance */
 		if (!cl->un.leaf.q->q.qlen)
 			htb_deactivate (q,cl);
-		htb_charge_class (q,cl,level,skb->len);
+		htb_charge_class (q,cl,level,qdisc_tx_len(skb));
 	}
 	return skb;
 }
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index c5bd806..aa97ecb 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -225,7 +225,7 @@ static int netem_enqueue(struct sk_buff 
 
 	if (likely(ret == NET_XMIT_SUCCESS)) {
 		sch->q.qlen++;
-		sch->bstats.bytes += skb->len;
+		sch->bstats.bytes += qdisc_tx_len(skb);
 		sch->bstats.packets++;
 	} else
 		sch->qstats.drops++;
@@ -507,8 +507,8 @@ static int tfifo_enqueue(struct sk_buff 
 
 		__skb_queue_after(list, skb, nskb);
 
-		sch->qstats.backlog += nskb->len;
-		sch->bstats.bytes += nskb->len;
+		sch->qstats.backlog += qdisc_tx_len(nskb);
+		sch->bstats.bytes += qdisc_tx_len(nskb);
 		sch->bstats.packets++;
 
 		return NET_XMIT_SUCCESS;
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index a5fa03c..2175732 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -99,7 +99,7 @@ #ifdef CONFIG_NET_CLS_ACT
 #endif
 
 	if ((ret = qdisc->enqueue(skb, qdisc)) == NET_XMIT_SUCCESS) {
-		sch->bstats.bytes += skb->len;
+		sch->bstats.bytes += qdisc_tx_len(skb);
 		sch->bstats.packets++;
 		sch->q.qlen++;
 		return NET_XMIT_SUCCESS;
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index d65cadd..24ec0b2 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -95,7 +95,7 @@ static int red_enqueue(struct sk_buff *s
 
 	ret = child->enqueue(skb, child);
 	if (likely(ret == NET_XMIT_SUCCESS)) {
-		sch->bstats.bytes += skb->len;
+		sch->bstats.bytes += qdisc_tx_len(skb);
 		sch->bstats.packets++;
 		sch->q.qlen++;
 	} else {
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index d0d6e59..2a57d0d 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -225,7 +225,7 @@ static unsigned int sfq_drop(struct Qdis
 	if (d > 1) {
 		sfq_index x = q->dep[d+SFQ_DEPTH].next;
 		skb = q->qs[x].prev;
-		len = skb->len;
+		len = qdisc_tx_len(skb);
 		__skb_unlink(skb, &q->qs[x]);
 		kfree_skb(skb);
 		sfq_dec(q, x);
@@ -241,7 +241,7 @@ static unsigned int sfq_drop(struct Qdis
 		q->next[q->tail] = q->next[d];
 		q->allot[q->next[d]] += q->quantum;
 		skb = q->qs[d].prev;
-		len = skb->len;
+		len = qdisc_tx_len(skb);
 		__skb_unlink(skb, &q->qs[d]);
 		kfree_skb(skb);
 		sfq_dec(q, d);
@@ -267,7 +267,7 @@ sfq_enqueue(struct sk_buff *skb, struct 
 		q->ht[hash] = x = q->dep[SFQ_DEPTH].next;
 		q->hash[x] = hash;
 	}
-	sch->qstats.backlog += skb->len;
+	sch->qstats.backlog += qdisc_tx_len(skb);
 	__skb_queue_tail(&q->qs[x], skb);
 	sfq_inc(q, x);
 	if (q->qs[x].qlen == 1) {		/* The flow is new */
@@ -282,7 +282,7 @@ sfq_enqueue(struct sk_buff *skb, struct 
 		}
 	}
 	if (++sch->q.qlen < q->limit-1) {
-		sch->bstats.bytes += skb->len;
+		sch->bstats.bytes += qdisc_tx_len(skb);
 		sch->bstats.packets++;
 		return 0;
 	}
@@ -303,7 +303,7 @@ sfq_requeue(struct sk_buff *skb, struct 
 		q->ht[hash] = x = q->dep[SFQ_DEPTH].next;
 		q->hash[x] = hash;
 	}
-	sch->qstats.backlog += skb->len;
+	sch->qstats.backlog += qdisc_tx_len(skb);
 	__skb_queue_head(&q->qs[x], skb);
 	sfq_inc(q, x);
 	if (q->qs[x].qlen == 1) {		/* The flow is new */
@@ -347,7 +347,7 @@ sfq_dequeue(struct Qdisc* sch)
 	skb = __skb_dequeue(&q->qs[a]);
 	sfq_dec(q, a);
 	sch->q.qlen--;
-	sch->qstats.backlog -= skb->len;
+	sch->qstats.backlog -= qdisc_tx_len(skb);
 
 	/* Is the slot empty? */
 	if (q->qs[a].qlen == 0) {
@@ -359,7 +359,7 @@ sfq_dequeue(struct Qdisc* sch)
 		}
 		q->next[q->tail] = a;
 		q->allot[a] += q->quantum;
-	} else if ((q->allot[a] -= skb->len) <= 0) {
+	} else if ((q->allot[a] -= qdisc_tx_len(skb)) <= 0) {
 		q->tail = a;
 		a = q->next[a];
 		q->allot[a] += q->quantum;
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index d9a5d29..c87b0e6 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -139,7 +139,7 @@ static int tbf_enqueue(struct sk_buff *s
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	int ret;
 
-	if (skb->len > q->max_size) {
+	if (qdisc_tx_len(skb) > q->max_size) {
 		sch->qstats.drops++;
 #ifdef CONFIG_NET_CLS_POLICE
 		if (sch->reshape_fail == NULL || sch->reshape_fail(skb, sch))
@@ -155,7 +155,7 @@ #endif
 	}
 
 	sch->q.qlen++;
-	sch->bstats.bytes += skb->len;
+	sch->bstats.bytes += qdisc_tx_len(skb);
 	sch->bstats.packets++;
 	return 0;
 }
@@ -204,7 +204,7 @@ static struct sk_buff *tbf_dequeue(struc
 		psched_time_t now;
 		long toks, delay;
 		long ptoks = 0;
-		unsigned int len = skb->len;
+		unsigned int len = qdisc_tx_len(skb);
 
 		PSCHED_GET_TIME(now);
 
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 4c16ad5..538f63f 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -97,7 +97,7 @@ teql_enqueue(struct sk_buff *skb, struct
 
 	__skb_queue_tail(&q->q, skb);
 	if (q->q.qlen <= dev->tx_queue_len) {
-		sch->bstats.bytes += skb->len;
+		sch->bstats.bytes += qdisc_tx_len(skb);
 		sch->bstats.packets++;
 		return 0;
 	}
@@ -278,7 +278,7 @@ static int teql_master_xmit(struct sk_bu
 	struct Qdisc *start, *q;
 	int busy;
 	int nores;
-	int len = skb->len;
+	int len = qdisc_tx_len(skb);
 	struct sk_buff *skb_res = NULL;
 
 	start = master->slaves;

--------------000104010102010909030303
Content-Type: text/plain;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

[NET_SCHED]: Move top-level device queueing code to seperate function

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit a39585afe71dafab96208515a8fa99c92b108fee
tree fbb7672a3061a38edc9f75d3fb8f34652796b109
parent 2a6508576111d82246ee018edbcc4b0f0d18acad
author Patrick McHardy <kaber@trash.net> Tue, 04 Jul 2006 15:03:28 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 04 Jul 2006 15:03:28 +0200

 include/net/pkt_sched.h |    1 +
 net/core/dev.c          |   10 +---------
 net/sched/sch_generic.c |   12 ++++++++++++
 3 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 1925c65..44cf69e 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -224,6 +224,7 @@ extern struct qdisc_rate_table *qdisc_ge
 		struct rtattr *tab);
 extern void qdisc_put_rtab(struct qdisc_rate_table *tab);
 
+extern int qdisc_enqueue_root(struct net_device *dev, struct sk_buff *skb);
 extern void __qdisc_run(struct net_device *dev);
 
 static inline void qdisc_run(struct net_device *dev)
diff --git a/net/core/dev.c b/net/core/dev.c
index 066a60a..8599120 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1449,15 +1449,7 @@ #ifdef CONFIG_NET_CLS_ACT
 	skb->tc_verd = SET_TC_AT(skb->tc_verd,AT_EGRESS);
 #endif
 	if (q->enqueue) {
-		/* Grab device queue */
-		spin_lock(&dev->queue_lock);
-
-		rc = q->enqueue(skb, q);
-
-		qdisc_run(dev);
-
-		spin_unlock(&dev->queue_lock);
-		rc = rc == NET_XMIT_BYPASS ? NET_XMIT_SUCCESS : rc;
+		rc = qdisc_enqueue_root(dev, skb);
 		goto out;
 	}
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index d735f51..2bab466 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -77,6 +77,18 @@ void qdisc_unlock_tree(struct net_device
    if one is grabbed, another must be free.
  */
 
+int qdisc_enqueue_root(struct net_device *dev, struct sk_buff *skb)
+{
+	int ret;
+
+	spin_lock(&dev->queue_lock);
+	ret = dev->qdisc->enqueue(skb, dev->qdisc);
+	qdisc_run(dev);
+	spin_unlock(&dev->queue_lock);
+
+	return ret == NET_XMIT_BYPASS ? NET_XMIT_SUCCESS : ret;
+}
+
 
 /* Kick device.
    Note, that this procedure can be called by a watchdog timer, so that

--------------000104010102010909030303
Content-Type: text/plain;
 name="03.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="03.diff"

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index d10f353..2ce55d5 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -83,6 +83,21 @@ struct tc_ratespec
 	__u32		rate;
 };
 
+struct tc_sizespec
+{
+	unsigned int	cell_log;
+	unsigned int	addend;
+};
+
+enum {
+	TCA_STAB_UNSPEC,
+	TCA_STAB_BASE,
+	TCA_STAB_DATA,
+	__TCA_STAB_MAX
+};
+
+#define TCA_STAB_MAX (__TCA_STAB_MAX - 1)
+
 /* FIFO section */
 
 struct tc_fifo_qopt
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index facd9ee..167cc22 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -821,6 +821,7 @@ enum
 	TCA_RATE,
 	TCA_FCNT,
 	TCA_STATS2,
+	TCA_STAB,
 	__TCA_MAX
 };
 
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 44cf69e..8fd9a42 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -223,6 +223,7 @@ extern struct Qdisc *qdisc_lookup_class(
 extern struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r,
 		struct rtattr *tab);
 extern void qdisc_put_rtab(struct qdisc_rate_table *tab);
+extern void qdisc_put_stab(struct qdisc_size_table *tab);
 
 extern int qdisc_enqueue_root(struct net_device *dev, struct sk_buff *skb);
 extern void __qdisc_run(struct net_device *dev);
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 75d7a55..76c50a1 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -23,6 +23,15 @@ struct qdisc_rate_table
 	int		refcnt;
 };
 
+struct qdisc_size_table
+{
+	struct list_head	list;
+	struct tc_sizespec	size;
+	int			refcnt;
+	unsigned int		tsize;
+	u32			data[];
+};
+
 struct Qdisc
 {
 	int 			(*enqueue)(struct sk_buff *skb, struct Qdisc *dev);
@@ -33,6 +42,7 @@ #define TCQ_F_THROTTLED	2
 #define TCQ_F_INGRESS	4
 	int			padded;
 	struct Qdisc_ops	*ops;
+	struct qdisc_size_table	*stab;
 	u32			handle;
 	u32			parent;
 	atomic_t		refcnt;
@@ -184,9 +194,19 @@ tcf_destroy(struct tcf_proto *tp)
 	kfree(tp);
 }
 
+struct qdisc_skb_cb {
+	unsigned int	len;
+	char		data[];
+};
+
+static inline struct qdisc_skb_cb *qdisc_skb_cb(struct sk_buff *skb)
+{
+	return (struct qdisc_skb_cb *)skb->cb;
+}
+
 static inline unsigned int qdisc_tx_len(struct sk_buff *skb)
 {
-	return skb->len;
+	return qdisc_skb_cb(skb)->len;
 }
 
 static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index c7844ba..479fc85 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -286,6 +286,78 @@ void qdisc_put_rtab(struct qdisc_rate_ta
 	}
 }
 
+static LIST_HEAD(qdisc_stab_list);
+
+static struct qdisc_size_table *qdisc_get_stab(struct rtattr *tab, int *err)
+{
+	struct qdisc_size_table *stab;
+	struct rtattr *tb[TCA_STAB_MAX];
+	unsigned int tsize;
+
+	*err = -EINVAL;
+	if (rtattr_parse_nested(tb, TCA_STAB_MAX, tab))
+		return NULL;
+	if (tb[TCA_STAB_BASE-1] == NULL ||
+	    RTA_PAYLOAD(tb[TCA_STAB_BASE-1]) < sizeof(struct tc_sizespec))
+	    	return NULL;
+
+	tsize = 0;
+	if (tb[TCA_STAB_DATA-1] != NULL)
+		tsize = RTA_PAYLOAD(tb[TCA_STAB_DATA-1]) / sizeof(u32);
+
+	list_for_each_entry(stab, &qdisc_stab_list, list) {
+		if (stab->tsize != tsize)
+			continue;
+		if (memcmp(&stab->size, RTA_DATA(tb[TCA_STAB_BASE-1]),
+		           sizeof(stab->size)))
+			continue;
+		if (tsize > 0  &&
+		    memcmp(stab->data, RTA_DATA(tb[TCA_STAB_DATA-1]),
+		    	   sizeof(u32) * tsize));
+			continue;
+		stab->refcnt++;
+		return stab;
+	}
+
+	*err = -ENOMEM;
+	stab = kmalloc(sizeof(*stab) + sizeof(u32) * tsize, GFP_KERNEL);
+	if (stab == NULL)
+		return stab;
+	memcpy(&stab->size, RTA_DATA(tb[TCA_STAB_BASE-1]), sizeof(stab->size));
+	stab->tsize = tsize;
+	if (tsize > 0)
+		memcpy(stab->data, RTA_DATA(tb[TCA_STAB_DATA-1]),
+		       sizeof(u32) * tsize);
+	list_add_tail(&stab->list, &qdisc_stab_list);
+	*err = 0;
+	return stab;
+}
+
+void qdisc_put_stab(struct qdisc_size_table *stab)
+{
+	if (!stab || --stab->refcnt)
+		return;
+	list_del(&stab->list);
+	kfree(stab);
+}
+
+static int
+qdisc_dump_stab(struct sk_buff *skb, struct qdisc_size_table *stab)
+{
+	unsigned char *b = skb->tail;
+	struct rtattr *rta = (struct rtattr *)b;
+
+	RTA_PUT(skb, TCA_STAB, 0, NULL);
+	RTA_PUT(skb, TCA_STAB_BASE, sizeof(stab->size), &stab->size);
+	RTA_PUT(skb, TCA_STAB_DATA, sizeof(stab->data[0]) * stab->tsize,
+		stab->data);
+	rta->rta_len = skb->tail - b;
+	return skb->len;
+
+rtattr_failure:
+	skb_trim(skb, b - skb->data);
+	return -1;
+}
 
 /* Allocate an unique handle from space managed by kernel */
 
@@ -453,6 +525,11 @@ #endif
 	sch->handle = handle;
 
 	if (!ops->init || (err = ops->init(sch, tca[TCA_OPTIONS-1])) == 0) {
+		if (tca[TCA_STAB-1]) {
+			sch->stab = qdisc_get_stab(tca[TCA_STAB-1], &err);
+			if (sch->stab == NULL)
+				goto err_out3;
+		}
 #ifdef CONFIG_NET_ESTIMATOR
 		if (tca[TCA_RATE-1]) {
 			err = gen_new_estimator(&sch->bstats, &sch->rate_est,
@@ -477,6 +554,7 @@ #endif
 		return sch;
 	}
 err_out3:
+	qdisc_put_stab(sch->stab);
 	dev_put(dev);
 	kfree((char *) sch - sch->padded);
 err_out2:
@@ -488,15 +566,26 @@ err_out:
 
 static int qdisc_change(struct Qdisc *sch, struct rtattr **tca)
 {
-	if (tca[TCA_OPTIONS-1]) {
-		int err;
+	int err;
 
+	if (tca[TCA_OPTIONS-1]) {
 		if (sch->ops->change == NULL)
 			return -EINVAL;
 		err = sch->ops->change(sch, tca[TCA_OPTIONS-1]);
 		if (err)
 			return err;
 	}
+	if (tca[TCA_STAB-1]) {
+		struct qdisc_size_table *stab;
+
+		stab = qdisc_get_stab(tca[TCA_STAB-1], &err);
+		if (stab == NULL)
+			return err;
+		spin_lock_bh(&sch->dev->queue_lock);
+		qdisc_put_stab(sch->stab);
+		sch->stab = stab;
+		spin_unlock_bh(&sch->dev->queue_lock);
+	}
 #ifdef CONFIG_NET_ESTIMATOR
 	if (tca[TCA_RATE-1])
 		gen_replace_estimator(&sch->bstats, &sch->rate_est,
@@ -769,6 +858,9 @@ static int tc_fill_qdisc(struct sk_buff 
 		goto rtattr_failure;
 	q->qstats.qlen = q->q.qlen;
 
+	if (q->stab != NULL && qdisc_dump_stab(skb, q->stab) < 0)
+		goto rtattr_failure;
+
 	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS,
 			TCA_XSTATS, q->stats_lock, &d) < 0)
 		goto rtattr_failure;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 2bab466..9022650 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -67,6 +67,21 @@ void qdisc_unlock_tree(struct net_device
 	write_unlock_bh(&qdisc_tree_lock);
 }
 
+static void qdisc_init_len(struct sk_buff *skb, struct Qdisc *q)
+{
+	unsigned int idx, len = skb->len;
+	struct qdisc_size_table *stab = q->stab;
+
+	if (stab == NULL)
+		goto out;
+	idx = len >> stab->size.cell_log;
+	if (idx < stab->tsize)
+		len = stab->data[idx];
+	len += stab->size.addend;
+out:
+	((struct qdisc_skb_cb *)skb->cb)->len = len;
+}
+
 /* 
    dev->queue_lock serializes queue accesses for this device
    AND dev->qdisc pointer itself.
@@ -82,6 +97,7 @@ int qdisc_enqueue_root(struct net_device
 	int ret;
 
 	spin_lock(&dev->queue_lock);
+	qdisc_init_len(skb, dev->qdisc);
 	ret = dev->qdisc->enqueue(skb, dev->qdisc);
 	qdisc_run(dev);
 	spin_unlock(&dev->queue_lock);
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index aa97ecb..15dde88 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -148,7 +148,7 @@ static long tabledist(unsigned long mu, 
 static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
-	struct netem_skb_cb *cb = (struct netem_skb_cb *)skb->cb;
+	struct netem_skb_cb *cb = (struct netem_skb_cb *)qdisc_skb_cb(skb)->data;
 	struct sk_buff *skb2;
 	int ret;
 	int count = 1;
@@ -268,7 +268,7 @@ static struct sk_buff *netem_dequeue(str
 	skb = q->qdisc->dequeue(q->qdisc);
 	if (skb) {
 		const struct netem_skb_cb *cb
-			= (const struct netem_skb_cb *)skb->cb;
+			= (const struct netem_skb_cb *)qdisc_skb_cb(skb)->data;
 		psched_time_t now;
 
 		/* if more time remaining? */
@@ -493,13 +493,13 @@ static int tfifo_enqueue(struct sk_buff 
 	struct fifo_sched_data *q = qdisc_priv(sch);
 	struct sk_buff_head *list = &sch->q;
 	const struct netem_skb_cb *ncb
-		= (const struct netem_skb_cb *)nskb->cb;
+		= (const struct netem_skb_cb *)qdisc_skb_cb(nskb)->data;
 	struct sk_buff *skb;
 
 	if (likely(skb_queue_len(list) < q->limit)) {
 		skb_queue_reverse_walk(list, skb) {
 			const struct netem_skb_cb *cb
-				= (const struct netem_skb_cb *)skb->cb;
+				= (const struct netem_skb_cb *)qdisc_skb_cb(skb)->data;
 
 			if (!PSCHED_TLESS(ncb->time_to_send, cb->time_to_send))
 				break;

--------------000104010102010909030303
Content-Type: text/plain;
 name="iproute.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="iproute.diff"

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index d10f353..2ce55d5 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -83,6 +83,21 @@ struct tc_ratespec
 	__u32		rate;
 };
 
+struct tc_sizespec
+{
+	unsigned int	cell_log;
+	unsigned int	addend;
+};
+
+enum {
+	TCA_STAB_UNSPEC,
+	TCA_STAB_BASE,
+	TCA_STAB_DATA,
+	__TCA_STAB_MAX
+};
+
+#define TCA_STAB_MAX (__TCA_STAB_MAX - 1)
+
 /* FIFO section */
 
 struct tc_fifo_qopt
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 5e33a20..addf5fb 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -821,6 +821,7 @@ enum
 	TCA_RATE,
 	TCA_FCNT,
 	TCA_STATS2,
+	TCA_STAB,
 	__TCA_MAX
 };
 
diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
index e9174ab..c38fa87 100644
--- a/tc/tc_qdisc.c
+++ b/tc/tc_qdisc.c
@@ -41,10 +41,79 @@ static int usage(void)
 	return -1;
 }
 
+static int parse_stab(int *argcp, char ***argvp, struct tc_sizespec *stab,
+		      __u32 **datap)
+{
+	int argc = *argcp;
+	char **argv = *argvp;
+
+	NEXT_ARG();
+	while (argc > 0) {
+		if (matches("overhead", *argv) == 0) {
+			NEXT_ARG();
+			if (stab->addend)
+				duparg("overhead", *argv);
+			if (get_size(&stab->addend, *argv))
+				return -1;
+			NEXT_ARG();
+		} else if (matches("cell_log", *argv) == 0) {
+			NEXT_ARG();
+			if (stab->cell_log)
+				duparg("cell_log", *argv);
+			if (get_u32(&stab->cell_log, *argv, 0))
+				return -1;
+			NEXT_ARG();
+		} else if (get_size(*datap, *argv) == 0) {
+			argv++, argc--;
+			++*datap;
+		} else
+			break;
+	}
+	if (!stab->addend && !stab->cell_log)
+		return -1;
+	*argcp = argc;
+	*argvp = argv;
+	return 0;
+}
+
+static void print_stab(FILE *f, char *prefix, struct rtattr *tab)
+{
+	struct rtattr *tb[TCA_STAB_MAX+1];
+	struct tc_sizespec *size;
+	unsigned int i;
+	__u32 *data;
+	SPRINT_BUF(buf);
+
+	parse_rtattr_nested(tb, TCA_STAB_MAX, tab);
+	if (tb[TCA_STAB_BASE] == NULL ||
+	    RTA_PAYLOAD(tb[TCA_STAB_BASE]) < sizeof(struct tc_sizespec))
+		return;
+	fprintf(f, "%s", prefix);
+	size = RTA_DATA(tb[TCA_STAB_BASE]);
+	if (size->addend) {
+		print_size(buf, SPRINT_BSIZE-1, size->addend);
+		fprintf(f, "overhead %s ", buf);
+	}
+       	if (size->cell_log)
+		fprintf(f, "cell_log %u ", size->cell_log);
+	if (tb[TCA_STAB_DATA] == NULL)
+		return;
+	data = RTA_DATA(tb[TCA_STAB_DATA]);
+	for (i = 0; i < RTA_PAYLOAD(tb[TCA_STAB_DATA]) / sizeof(__u32); i++) {
+		print_size(buf, SPRINT_BSIZE-1, data[i]);
+		fprintf(f, "%s ", buf);
+	}
+}
+
 int tc_qdisc_modify(int cmd, unsigned flags, int argc, char **argv)
 {
 	struct qdisc_util *q = NULL;
 	struct tc_estimator est;
+	struct {
+		struct tc_sizespec size;
+		__u32 data[256];
+	} stab;
+	__u32 *stabdata = &stab.data[0];
 	char  d[16];
 	char  k[16];
 	struct {
@@ -55,6 +124,7 @@ int tc_qdisc_modify(int cmd, unsigned fl
 
 	memset(&req, 0, sizeof(req));
 	memset(&est, 0, sizeof(est));
+	memset(&stab, 0, sizeof(stab));
 	memset(&d, 0, sizeof(d));
 	memset(&k, 0, sizeof(k));
 
@@ -108,6 +178,10 @@ #endif
 		} else if (matches(*argv, "estimator") == 0) {
 			if (parse_estimator(&argc, &argv, &est))
 				return -1;
+		} else if (matches(*argv, "stab") == 0) {
+			if (parse_stab(&argc, &argv, &stab.size, &stabdata))
+				return -1;
+			continue;
 		} else if (matches(*argv, "help") == 0) {
 			usage();
 		} else {
@@ -124,6 +198,16 @@ #endif
 		addattr_l(&req.n, sizeof(req), TCA_KIND, k, strlen(k)+1);
 	if (est.ewma_log)
 		addattr_l(&req.n, sizeof(req), TCA_RATE, &est, sizeof(est));
+	if (stab.size.addend || stab.size.cell_log) {
+		struct rtattr *tail = NLMSG_TAIL(&req.n);
+
+		addattr_l(&req.n, sizeof(req), TCA_STAB, NULL, 0);
+		addattr_l(&req.n, sizeof(req), TCA_STAB_BASE, &stab.size,
+			  sizeof(stab.size));
+		addattr_l(&req.n, sizeof(req), TCA_STAB_DATA, stab.data,
+		          (void *)stabdata - (void *)stab.data);
+		tail->rta_len = (void *)NLMSG_TAIL(&req.n) - (void *)tail;
+	}
 
 	if (q) {
 		if (!q->parse_qopt) {
@@ -215,7 +299,7 @@ static int print_qdisc(const struct sock
 		q = get_qdisc_kind("prio");
 	else
 		q = get_qdisc_kind(RTA_DATA(tb[TCA_KIND]));
-	
+
 	if (tb[TCA_OPTIONS]) {
 		if (q)
 			q->print_qopt(q, fp, tb[TCA_OPTIONS]);
@@ -223,6 +307,12 @@ static int print_qdisc(const struct sock
 			fprintf(fp, "[cannot parse qdisc parameters]");
 	}
 	fprintf(fp, "\n");
+
+	if (tb[TCA_STAB]) {
+		print_stab(fp, " ", tb[TCA_STAB]);
+		fprintf(fp, "\n");
+	}
+
 	if (show_stats) {
 		struct rtattr *xstats = NULL;
 

--------------000104010102010909030303--
