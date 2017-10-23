From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 08/15] net_sched: remove RCU callbacks in tcindex filter
Date: Mon, 23 Oct 2017 15:02:57 -0700
Message-ID: <20171023220304.2268-9-xiyou.wangcong@gmail.com>
References: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Cc: paulmck@linux.vnet.ibm.com, jhs@mojatatu.com,
        john.fastabend@gmail.com, Chris Mi <chrism@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:54748 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751220AbdJWWDl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 18:03:41 -0400
Received: by mail-pf0-f193.google.com with SMTP id n89so18090951pfk.11
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:03:41 -0700 (PDT)
In-Reply-To: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace call_rcu() with synchronize_rcu().

Reported-by: Chris Mi <chrism@mellanox.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_tcindex.c | 35 +++++++++++++----------------------
 1 file changed, 13 insertions(+), 22 deletions(-)

diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 14a7e08b2fa9..32aaa5e459d3 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -27,14 +27,12 @@
 struct tcindex_filter_result {
 	struct tcf_exts		exts;
 	struct tcf_result	res;
-	struct rcu_head		rcu;
 };
 
 struct tcindex_filter {
 	u16 key;
 	struct tcindex_filter_result result;
 	struct tcindex_filter __rcu *next;
-	struct rcu_head rcu;
 };
 
 
@@ -47,7 +45,6 @@ struct tcindex_data {
 	u32 hash;		/* hash table size; 0 if undefined */
 	u32 alloc_hash;		/* allocated size */
 	u32 fall_through;	/* 0: only classify if explicit match */
-	struct rcu_head rcu;
 };
 
 static inline int tcindex_filter_is_set(struct tcindex_filter_result *r)
@@ -133,19 +130,13 @@ static int tcindex_init(struct tcf_proto *tp)
 	return 0;
 }
 
-static void tcindex_destroy_rexts(struct rcu_head *head)
+static void tcindex_destroy_rexts(struct tcindex_filter_result *r)
 {
-	struct tcindex_filter_result *r;
-
-	r = container_of(head, struct tcindex_filter_result, rcu);
 	tcf_exts_destroy(&r->exts);
 }
 
-static void tcindex_destroy_fexts(struct rcu_head *head)
+static void tcindex_destroy_fexts(struct tcindex_filter *f)
 {
-	struct tcindex_filter *f = container_of(head, struct tcindex_filter,
-						rcu);
-
 	tcf_exts_destroy(&f->result.exts);
 	kfree(f);
 }
@@ -182,10 +173,11 @@ static int tcindex_delete(struct tcf_proto *tp, void *arg, bool *last)
 	 * grace period, since converted-to-rcu actions are relying on that
 	 * in cleanup() callback
 	 */
+	synchronize_rcu();
 	if (f)
-		call_rcu(&f->rcu, tcindex_destroy_fexts);
+		tcindex_destroy_fexts(f);
 	else
-		call_rcu(&r->rcu, tcindex_destroy_rexts);
+		tcindex_destroy_rexts(r);
 
 	*last = false;
 	return 0;
@@ -199,10 +191,8 @@ static int tcindex_destroy_element(struct tcf_proto *tp,
 	return tcindex_delete(tp, arg, &last);
 }
 
-static void __tcindex_destroy(struct rcu_head *head)
+static void __tcindex_destroy(struct tcindex_data *p)
 {
-	struct tcindex_data *p = container_of(head, struct tcindex_data, rcu);
-
 	kfree(p->perfect);
 	kfree(p->h);
 	kfree(p);
@@ -228,10 +218,8 @@ static int tcindex_filter_result_init(struct tcindex_filter_result *r)
 	return tcf_exts_init(&r->exts, TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
 }
 
-static void __tcindex_partial_destroy(struct rcu_head *head)
+static void __tcindex_partial_destroy(struct tcindex_data *p)
 {
-	struct tcindex_data *p = container_of(head, struct tcindex_data, rcu);
-
 	kfree(p->perfect);
 	kfree(p);
 }
@@ -449,8 +437,10 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 		rcu_assign_pointer(*fp, f);
 	}
 
-	if (oldp)
-		call_rcu(&oldp->rcu, __tcindex_partial_destroy);
+	if (oldp) {
+		synchronize_rcu();
+		 __tcindex_partial_destroy(oldp);
+	}
 	return 0;
 
 errout_alloc:
@@ -540,7 +530,8 @@ static void tcindex_destroy(struct tcf_proto *tp)
 	walker.fn = tcindex_destroy_element;
 	tcindex_walk(tp, &walker);
 
-	call_rcu(&p->rcu, __tcindex_destroy);
+	synchronize_rcu();
+	__tcindex_destroy(p);
 }
 
 
-- 
2.13.0
