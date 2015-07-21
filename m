From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH,v2 net] net: sched: validate that class is found in
 qdisc_tree_decrease_qlen
Date: Tue, 21 Jul 2015 12:52:25 +0200
Message-ID: <1437475945.9913.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1437421248-2796139-1-git-send-email-agartrell@fb.com>
	 <55AE1939.105@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alex Gartrell <agartrell@fb.com>, xiyou.wangcong@gmail.com,
	davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com,
	stable@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <55AE1939.105@mojatatu.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-07-21 at 06:04 -0400, Jamal Hadi Salim wrote:

> It is worrisome to fix the core code for this. The root cause seems to
> be codel. Dont have time but in general, reset would be something like:
> 
> struct fq_codel_sched_data *q = qdisc_priv(sch);
> qdisc_reset(q)

This only works for very simple qdisc with one queue.

> 
> or something along those lines...
> But certainly dequeue semantics dont seem right there..

Well, reset() is trivial to implement like this

while (skb = local_dequeue(sch)) {
	kfree_skb(skb);
}

And I guess I copy/pasted sfq code here, because I was lazy.

But yes, qdisc_tree_decrease_qlen() would have to be not called.

It seems I coded fq_reset() differently.

Alex, please try instead :

diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 21ca33c9f036..3f0320ab6029 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -288,10 +288,21 @@ begin:
 
 static void fq_codel_reset(struct Qdisc *sch)
 {
-	struct sk_buff *skb;
+	struct fq_codel_sched_data *q = qdisc_priv(sch);
+	int i;
 
-	while ((skb = fq_codel_dequeue(sch)) != NULL)
-		kfree_skb(skb);
+	INIT_LIST_HEAD(&q->new_flows);
+	INIT_LIST_HEAD(&q->old_flows);
+	for (i = 0; i < q->flows_cnt; i++) {
+		struct fq_codel_flow *flow = q->flows + i;
+
+		while (flow->head)
+			kfree_skb(dequeue_head(flow));
+
+		INIT_LIST_HEAD(&flow->flowchain);
+	}
+	memset(q->backlogs, 0, q->flows_cnt * sizeof(u32));
+	sch->q.qlen = 0;
 }
 
 static const struct nla_policy fq_codel_policy[TCA_FQ_CODEL_MAX + 1] = {
