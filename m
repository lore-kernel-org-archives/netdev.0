From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [RFC Patch net-next 1/6] net_sched: use RCU for action hash table
Date: Thu,  1 Sep 2016 22:57:15 -0700
Message-ID: <1472795840-31901-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: jhs@mojatatu.com, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36181 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751821AbcIBF5q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 01:57:46 -0400
Received: by mail-pf0-f196.google.com with SMTP id a143so2068052pfa.3
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 22:57:46 -0700 (PDT)
In-Reply-To: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We already free tc actions in a RCU callback, so here
we just need to convert the hash table operations to
RCU API's.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_api.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index d09d068..06111aa 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -39,7 +39,7 @@ static void free_tcf(struct rcu_head *head)
 static void tcf_hash_destroy(struct tcf_hashinfo *hinfo, struct tc_action *p)
 {
 	spin_lock_bh(&hinfo->lock);
-	hlist_del(&p->tcfa_head);
+	hlist_del_rcu(&p->tcfa_head);
 	spin_unlock_bh(&hinfo->lock);
 	gen_kill_estimator(&p->tcfa_bstats,
 			   &p->tcfa_rate_est);
@@ -79,10 +79,10 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
 	struct nlattr *nest;
 
-	spin_lock_bh(&hinfo->lock);
-
 	s_i = cb->args[0];
 
+	rcu_read_lock_bh();
+
 	for (i = 0; i < (hinfo->hmask + 1); i++) {
 		struct hlist_head *head;
 		struct tc_action *p;
@@ -110,7 +110,7 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
 		}
 	}
 done:
-	spin_unlock_bh(&hinfo->lock);
+	rcu_read_unlock_bh();
 	if (n_i)
 		cb->args[0] += n_i;
 	return n_i;
@@ -179,12 +179,12 @@ static struct tc_action *tcf_hash_lookup(u32 index, struct tcf_hashinfo *hinfo)
 	struct tc_action *p = NULL;
 	struct hlist_head *head;
 
-	spin_lock_bh(&hinfo->lock);
+	rcu_read_lock_bh();
 	head = &hinfo->htab[tcf_hash(index, hinfo->hmask)];
 	hlist_for_each_entry_rcu(p, head, tcfa_head)
 		if (p->tcfa_index == index)
 			break;
-	spin_unlock_bh(&hinfo->lock);
+	rcu_read_unlock_bh();
 
 	return p;
 }
@@ -301,7 +301,7 @@ void tcf_hash_insert(struct tc_action_net *tn, struct tc_action *a)
 	unsigned int h = tcf_hash(a->tcfa_index, hinfo->hmask);
 
 	spin_lock_bh(&hinfo->lock);
-	hlist_add_head(&a->tcfa_head, &hinfo->htab[h]);
+	hlist_add_head_rcu(&a->tcfa_head, &hinfo->htab[h]);
 	spin_unlock_bh(&hinfo->lock);
 }
 EXPORT_SYMBOL(tcf_hash_insert);
-- 
2.1.0
