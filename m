From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 09/12] net: sched: make cls_u32 per cpu
Date: Fri, 12 Sep 2014 20:08:47 -0700
Message-ID: <20140913030845.6249.5623.stgit@nitbit.x32>
References: <20140913025925.6249.12537.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: xiyou.wangcong@gmail.com, davem@davemloft.net,
	eric.dumazet@gmail.com, jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:60825 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751289AbaIMDJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 23:09:08 -0400
Received: by mail-ob0-f178.google.com with SMTP id va2so1088589obc.23
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 20:09:08 -0700 (PDT)
In-Reply-To: <20140913025925.6249.12537.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This uses per cpu counters in cls_u32 in preparation
to convert over to rcu.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/cls_u32.c |   75 ++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 59 insertions(+), 16 deletions(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 70c0be8..f3227d7 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -55,10 +55,12 @@ struct tc_u_knode {
 	struct tcf_result	res;
 	struct tc_u_hnode	*ht_down;
 #ifdef CONFIG_CLS_U32_PERF
-	struct tc_u32_pcnt	*pf;
+	struct tc_u32_pcnt __percpu *pf;
 #endif
 #ifdef CONFIG_CLS_U32_MARK
-	struct tc_u32_mark	mark;
+	u32			val;
+	u32			mask;
+	u32 __percpu		*pcpu_success;
 #endif
 	struct tc_u32_sel	sel;
 };
@@ -115,16 +117,16 @@ next_knode:
 		struct tc_u32_key *key = n->sel.keys;
 
 #ifdef CONFIG_CLS_U32_PERF
-		n->pf->rcnt += 1;
+		__this_cpu_inc(n->pf->rcnt);
 		j = 0;
 #endif
 
 #ifdef CONFIG_CLS_U32_MARK
-		if ((skb->mark & n->mark.mask) != n->mark.val) {
+		if ((skb->mark & n->mask) != n->val) {
 			n = n->next;
 			goto next_knode;
 		} else {
-			n->mark.success++;
+			__this_cpu_inc(*n->pcpu_success);
 		}
 #endif
 
@@ -143,7 +145,7 @@ next_knode:
 				goto next_knode;
 			}
 #ifdef CONFIG_CLS_U32_PERF
-			n->pf->kcnts[j] += 1;
+			__this_cpu_inc(n->pf->kcnts[j]);
 			j++;
 #endif
 		}
@@ -159,7 +161,7 @@ check_terminal:
 				}
 #endif
 #ifdef CONFIG_CLS_U32_PERF
-				n->pf->rhit += 1;
+				__this_cpu_inc(n->pf->rhit);
 #endif
 				r = tcf_exts_exec(skb, &n->exts, res);
 				if (r < 0) {
@@ -342,7 +344,7 @@ static int u32_destroy_key(struct tcf_proto *tp, struct tc_u_knode *n)
 	if (n->ht_down)
 		n->ht_down->refcnt--;
 #ifdef CONFIG_CLS_U32_PERF
-	kfree(n->pf);
+	free_percpu(n->pf);
 #endif
 	kfree(n);
 	return 0;
@@ -564,6 +566,9 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 	struct nlattr *tb[TCA_U32_MAX + 1];
 	u32 htid;
 	int err;
+#ifdef CONFIG_CLS_U32_PERF
+	size_t size;
+#endif
 
 	if (opt == NULL)
 		return handle ? -EINVAL : 0;
@@ -642,8 +647,9 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 		return -ENOBUFS;
 
 #ifdef CONFIG_CLS_U32_PERF
-	n->pf = kzalloc(sizeof(struct tc_u32_pcnt) + s->nkeys*sizeof(u64), GFP_KERNEL);
-	if (n->pf == NULL) {
+	size = sizeof(struct tc_u32_pcnt) + s->nkeys * sizeof(u64);
+	n->pf = __alloc_percpu(size, __alignof__(struct tc_u32_pcnt));
+	if (!n->pf) {
 		kfree(n);
 		return -ENOBUFS;
 	}
@@ -656,12 +662,14 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 	tcf_exts_init(&n->exts, TCA_U32_ACT, TCA_U32_POLICE);
 
 #ifdef CONFIG_CLS_U32_MARK
+	n->pcpu_success = alloc_percpu(u32);
+
 	if (tb[TCA_U32_MARK]) {
 		struct tc_u32_mark *mark;
 
 		mark = nla_data(tb[TCA_U32_MARK]);
-		memcpy(&n->mark, mark, sizeof(struct tc_u32_mark));
-		n->mark.success = 0;
+		n->val = mark->val;
+		n->mask = mark->mask;
 	}
 #endif
 
@@ -745,6 +753,11 @@ static int u32_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 		if (nla_put_u32(skb, TCA_U32_DIVISOR, divisor))
 			goto nla_put_failure;
 	} else {
+#ifdef CONFIG_CLS_U32_PERF
+		struct tc_u32_pcnt *gpf;
+#endif
+		int cpu;
+
 		if (nla_put(skb, TCA_U32_SEL,
 			    sizeof(n->sel) + n->sel.nkeys*sizeof(struct tc_u32_key),
 			    &n->sel))
@@ -762,9 +775,20 @@ static int u32_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 			goto nla_put_failure;
 
 #ifdef CONFIG_CLS_U32_MARK
-		if ((n->mark.val || n->mark.mask) &&
-		    nla_put(skb, TCA_U32_MARK, sizeof(n->mark), &n->mark))
-			goto nla_put_failure;
+		if ((n->val || n->mask)) {
+			struct tc_u32_mark mark = {.val = n->val,
+						   .mask = n->mask,
+						   .success = 0};
+
+			for_each_possible_cpu(cpu) {
+				__u32 cnt = *per_cpu_ptr(n->pcpu_success, cpu);
+
+				mark.success += cnt;
+			}
+
+			if (nla_put(skb, TCA_U32_MARK, sizeof(mark), &mark))
+				goto nla_put_failure;
+		}
 #endif
 
 		if (tcf_exts_dump(skb, &n->exts) < 0)
@@ -779,10 +803,29 @@ static int u32_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 		}
 #endif
 #ifdef CONFIG_CLS_U32_PERF
+		gpf = kzalloc(sizeof(struct tc_u32_pcnt) +
+			      n->sel.nkeys * sizeof(u64),
+			      GFP_KERNEL);
+		if (!gpf)
+			goto nla_put_failure;
+
+		for_each_possible_cpu(cpu) {
+			int i;
+			struct tc_u32_pcnt *pf = per_cpu_ptr(n->pf, cpu);
+
+			gpf->rcnt += pf->rcnt;
+			gpf->rhit += pf->rhit;
+			for (i = 0; i < n->sel.nkeys; i++)
+				gpf->kcnts[i] += pf->kcnts[i];
+		}
+
 		if (nla_put(skb, TCA_U32_PCNT,
 			    sizeof(struct tc_u32_pcnt) + n->sel.nkeys*sizeof(u64),
-			    n->pf))
+			    gpf)) {
+			kfree(gpf);
 			goto nla_put_failure;
+		}
+		kfree(gpf);
 #endif
 	}
 
