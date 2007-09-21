From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: SFQ qdisc crashes with limit of 2 packets
Date: Fri, 21 Sep 2007 19:55:22 +0400
Message-ID: <20070921155522.GA6755@ms2.inr.ac.ru>
References: <46F0087A.3080104@redhat.com> <46F00B80.7050901@trash.net> <46F0117A.4060807@trash.net> <46F023D0.7030307@trash.net> <20070919094803.GA17740@ms2.inr.ac.ru> <46F11F46.8060108@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Ebbert <cebbert@redhat.com>, Netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:54418 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1758393AbXIUPzg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2007 11:55:36 -0400
Content-Disposition: inline
In-Reply-To: <46F11F46.8060108@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

Remove artificial limitation for sfq queue limit.

This is followup to Patrick's patch. A little optimization to enqueue
routine allows to remove artificial limitation on queue length.

Plus, testing showed that hash function used by SFQ is too bad or even worse.
It does not even sweep the whole range of hash values.
Switched to Jenkins' hash.


Signed-off-by: Alexey Kuznetsov <kaber@ms2.inr.ac.ru>


diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 3a23e30..b542c87 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -19,6 +19,7 @@
 #include <linux/init.h>
 #include <linux/ipv6.h>
 #include <linux/skbuff.h>
+#include <linux/jhash.h>
 #include <net/ip.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
@@ -95,7 +96,7 @@ struct sfq_sched_data
 
 /* Variables */
 	struct timer_list perturb_timer;
-	int		perturbation;
+	u32		perturbation;
 	sfq_index	tail;		/* Index of current slot in round */
 	sfq_index	max_depth;	/* Maximal depth */
 
@@ -109,12 +110,7 @@ struct sfq_sched_data
 
 static __inline__ unsigned sfq_fold_hash(struct sfq_sched_data *q, u32 h, u32 h1)
 {
-	int pert = q->perturbation;
-
-	/* Have we any rotation primitives? If not, WHY? */
-	h ^= (h1<<pert) ^ (h1>>(0x1F - pert));
-	h ^= h>>10;
-	return h & 0x3FF;
+	return jhash_2words(h, h1, q->perturbation) & (SFQ_HASH_DIVISOR - 1);
 }
 
 static unsigned sfq_hash(struct sfq_sched_data *q, struct sk_buff *skb)
@@ -256,6 +252,13 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 		q->ht[hash] = x = q->dep[SFQ_DEPTH].next;
 		q->hash[x] = hash;
 	}
+	/* If selected queue has length q->limit, this means that
+	 * all another queues are empty and that we do simple tail drop,
+	 * i.e. drop _this_ packet.
+	 */
+	if (q->qs[x].qlen >= q->limit)
+		return qdisc_drop(skb, sch);
+
 	sch->qstats.backlog += skb->len;
 	__skb_queue_tail(&q->qs[x], skb);
 	sfq_inc(q, x);
@@ -294,6 +297,19 @@ sfq_requeue(struct sk_buff *skb, struct Qdisc* sch)
 	}
 	sch->qstats.backlog += skb->len;
 	__skb_queue_head(&q->qs[x], skb);
+	/* If selected queue has length q->limit+1, this means that
+	 * all another queues are empty and we do simple tail drop.
+	 * This packet is still requeued at head of queue, tail packet
+	 * is dropped.
+	 */
+	if (q->qs[x].qlen > q->limit) {
+		skb = q->qs[x].prev;
+		__skb_unlink(skb, &q->qs[x]);
+		sch->qstats.drops++;
+		sch->qstats.backlog -= skb->len;
+		kfree_skb(skb);
+		return NET_XMIT_CN;
+	}
 	sfq_inc(q, x);
 	if (q->qs[x].qlen == 1) {		/* The flow is new */
 		if (q->tail == SFQ_DEPTH) {	/* It is the first flow */
@@ -370,12 +386,10 @@ static void sfq_perturbation(unsigned long arg)
 	struct Qdisc *sch = (struct Qdisc*)arg;
 	struct sfq_sched_data *q = qdisc_priv(sch);
 
-	q->perturbation = net_random()&0x1F;
+	get_random_bytes(&q->perturbation, 4);
 
-	if (q->perturb_period) {
-		q->perturb_timer.expires = jiffies + q->perturb_period;
-		add_timer(&q->perturb_timer);
-	}
+	if (q->perturb_period)
+		mod_timer(&q->perturb_timer, jiffies + q->perturb_period);
 }
 
 static int sfq_change(struct Qdisc *sch, struct rtattr *opt)
@@ -391,7 +405,7 @@ static int sfq_change(struct Qdisc *sch, struct rtattr *opt)
 	q->quantum = ctl->quantum ? : psched_mtu(sch->dev);
 	q->perturb_period = ctl->perturb_period*HZ;
 	if (ctl->limit)
-		q->limit = min_t(u32, ctl->limit, SFQ_DEPTH - 2);
+		q->limit = min_t(u32, ctl->limit, SFQ_DEPTH - 1);
 
 	qlen = sch->q.qlen;
 	while (sch->q.qlen > q->limit)
@@ -400,8 +414,8 @@ static int sfq_change(struct Qdisc *sch, struct rtattr *opt)
 
 	del_timer(&q->perturb_timer);
 	if (q->perturb_period) {
-		q->perturb_timer.expires = jiffies + q->perturb_period;
-		add_timer(&q->perturb_timer);
+		mod_timer(&q->perturb_timer, jiffies + q->perturb_period);
+		get_random_bytes(&q->perturbation, 4);
 	}
 	sch_tree_unlock(sch);
 	return 0;
@@ -423,12 +437,13 @@ static int sfq_init(struct Qdisc *sch, struct rtattr *opt)
 		q->dep[i+SFQ_DEPTH].next = i+SFQ_DEPTH;
 		q->dep[i+SFQ_DEPTH].prev = i+SFQ_DEPTH;
 	}
-	q->limit = SFQ_DEPTH - 2;
+	q->limit = SFQ_DEPTH - 1;
 	q->max_depth = 0;
 	q->tail = SFQ_DEPTH;
 	if (opt == NULL) {
 		q->quantum = psched_mtu(sch->dev);
 		q->perturb_period = 0;
+		get_random_bytes(&q->perturbation, 4);
 	} else {
 		int err = sfq_change(sch, opt);
 		if (err)
