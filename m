From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH net-next v4 6/8] net_sched: convert tcf_hashinfo to hlist and use spinlock
Date: Sun, 15 Dec 2013 20:15:09 -0800
Message-ID: <1387167311-14763-7-git-send-email-xiyou.wangcong@gmail.com>
References: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:50642 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752556Ab3LPEPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 23:15:33 -0500
Received: by mail-pa0-f41.google.com with SMTP id lf10so2410822pab.0
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 20:15:33 -0800 (PST)
In-Reply-To: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So that we don't need to play with singly linked list,
and since the code is not on hot path, we can use spinlock
instead of rwlock.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h  | 16 +++++++-----
 net/sched/act_api.c    | 69 ++++++++++++++++++++++----------------------------
 net/sched/act_police.c | 45 +++++++++++++-------------------
 3 files changed, 58 insertions(+), 72 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 2b5ec5a..22418d1 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -9,7 +9,7 @@
 #include <net/pkt_sched.h>
 
 struct tcf_common {
-	struct tcf_common		*tcfc_next;
+	struct hlist_node		tcfc_head;
 	u32				tcfc_index;
 	int				tcfc_refcnt;
 	int				tcfc_bindcnt;
@@ -22,7 +22,7 @@ struct tcf_common {
 	spinlock_t			tcfc_lock;
 	struct rcu_head			tcfc_rcu;
 };
-#define tcf_next	common.tcfc_next
+#define tcf_head	common.tcfc_head
 #define tcf_index	common.tcfc_index
 #define tcf_refcnt	common.tcfc_refcnt
 #define tcf_bindcnt	common.tcfc_bindcnt
@@ -36,9 +36,9 @@ struct tcf_common {
 #define tcf_rcu		common.tcfc_rcu
 
 struct tcf_hashinfo {
-	struct tcf_common	**htab;
+	struct hlist_head	*htab;
 	unsigned int		hmask;
-	rwlock_t		lock;
+	spinlock_t		lock;
 };
 
 static inline unsigned int tcf_hash(u32 index, unsigned int hmask)
@@ -48,12 +48,16 @@ static inline unsigned int tcf_hash(u32 index, unsigned int hmask)
 
 static inline int tcf_hashinfo_init(struct tcf_hashinfo *hf, unsigned int mask)
 {
-	rwlock_init(&hf->lock);
+	int i;
+
+	spin_lock_init(&hf->lock);
 	hf->hmask = mask;
-	hf->htab = kzalloc((mask + 1) * sizeof(struct tcf_common *),
+	hf->htab = kzalloc((mask + 1) * sizeof(struct hlist_head),
 			   GFP_KERNEL);
 	if (!hf->htab)
 		return -ENOMEM;
+	for (i = 0; i < mask + 1; i++)
+		INIT_HLIST_HEAD(&hf->htab[i]);
 	return 0;
 }
 
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 125673d..dc457c9 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -29,25 +29,16 @@
 
 void tcf_hash_destroy(struct tcf_common *p, struct tcf_hashinfo *hinfo)
 {
-	unsigned int h = tcf_hash(p->tcfc_index, hinfo->hmask);
-	struct tcf_common **p1p;
-
-	for (p1p = &hinfo->htab[h]; *p1p; p1p = &(*p1p)->tcfc_next) {
-		if (*p1p == p) {
-			write_lock_bh(&hinfo->lock);
-			*p1p = p->tcfc_next;
-			write_unlock_bh(&hinfo->lock);
-			gen_kill_estimator(&p->tcfc_bstats,
-					   &p->tcfc_rate_est);
-			/*
-			 * gen_estimator est_timer() might access p->tcfc_lock
-			 * or bstats, wait a RCU grace period before freeing p
-			 */
-			kfree_rcu(p, tcfc_rcu);
-			return;
-		}
-	}
-	WARN_ON(1);
+	spin_lock_bh(&hinfo->lock);
+	hlist_del(&p->tcfc_head);
+	spin_unlock_bh(&hinfo->lock);
+	gen_kill_estimator(&p->tcfc_bstats,
+			   &p->tcfc_rate_est);
+	/*
+	 * gen_estimator est_timer() might access p->tcfc_lock
+	 * or bstats, wait a RCU grace period before freeing p
+	 */
+	kfree_rcu(p, tcfc_rcu);
 }
 EXPORT_SYMBOL(tcf_hash_destroy);
 
@@ -73,18 +64,19 @@ EXPORT_SYMBOL(tcf_hash_release);
 static int tcf_dump_walker(struct sk_buff *skb, struct netlink_callback *cb,
 			   struct tc_action *a, struct tcf_hashinfo *hinfo)
 {
+	struct hlist_head *head;
 	struct tcf_common *p;
 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
 	struct nlattr *nest;
 
-	read_lock_bh(&hinfo->lock);
+	spin_lock_bh(&hinfo->lock);
 
 	s_i = cb->args[0];
 
 	for (i = 0; i < (hinfo->hmask + 1); i++) {
-		p = hinfo->htab[tcf_hash(i, hinfo->hmask)];
+		head = &hinfo->htab[tcf_hash(i, hinfo->hmask)];
 
-		for (; p; p = p->tcfc_next) {
+		hlist_for_each_entry_rcu(p, head, tcfc_head) {
 			index++;
 			if (index < s_i)
 				continue;
@@ -107,7 +99,7 @@ static int tcf_dump_walker(struct sk_buff *skb, struct netlink_callback *cb,
 		}
 	}
 done:
-	read_unlock_bh(&hinfo->lock);
+	spin_unlock_bh(&hinfo->lock);
 	if (n_i)
 		cb->args[0] += n_i;
 	return n_i;
@@ -120,7 +112,9 @@ nla_put_failure:
 static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a,
 			  struct tcf_hashinfo *hinfo)
 {
-	struct tcf_common *p, *s_p;
+	struct hlist_head *head;
+	struct hlist_node *n;
+	struct tcf_common *p;
 	struct nlattr *nest;
 	int i = 0, n_i = 0;
 
@@ -130,14 +124,11 @@ static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a,
 	if (nla_put_string(skb, TCA_KIND, a->ops->kind))
 		goto nla_put_failure;
 	for (i = 0; i < (hinfo->hmask + 1); i++) {
-		p = hinfo->htab[tcf_hash(i, hinfo->hmask)];
-
-		while (p != NULL) {
-			s_p = p->tcfc_next;
+		head = &hinfo->htab[tcf_hash(i, hinfo->hmask)];
+		hlist_for_each_entry_safe(p, n, head, tcfc_head) {
 			if (ACT_P_DELETED == tcf_hash_release(p, 0, hinfo))
 				module_put(a->ops->owner);
 			n_i++;
-			p = s_p;
 		}
 	}
 	if (nla_put_u32(skb, TCA_FCNT, n_i))
@@ -168,15 +159,15 @@ EXPORT_SYMBOL(tcf_generic_walker);
 
 struct tcf_common *tcf_hash_lookup(u32 index, struct tcf_hashinfo *hinfo)
 {
-	struct tcf_common *p;
+	struct tcf_common *p = NULL;
+	struct hlist_head *head;
 
-	read_lock_bh(&hinfo->lock);
-	for (p = hinfo->htab[tcf_hash(index, hinfo->hmask)]; p;
-	     p = p->tcfc_next) {
+	spin_lock_bh(&hinfo->lock);
+	head = &hinfo->htab[tcf_hash(index, hinfo->hmask)];
+	hlist_for_each_entry_rcu(p, head, tcfc_head)
 		if (p->tcfc_index == index)
 			break;
-	}
-	read_unlock_bh(&hinfo->lock);
+	spin_unlock_bh(&hinfo->lock);
 
 	return p;
 }
@@ -236,6 +227,7 @@ struct tcf_common *tcf_hash_create(u32 index, struct nlattr *est,
 		p->tcfc_bindcnt = 1;
 
 	spin_lock_init(&p->tcfc_lock);
+	INIT_HLIST_NODE(&p->tcfc_head);
 	p->tcfc_index = index ? index : tcf_hash_new_index(idx_gen, hinfo);
 	p->tcfc_tm.install = jiffies;
 	p->tcfc_tm.lastuse = jiffies;
@@ -257,10 +249,9 @@ void tcf_hash_insert(struct tcf_common *p, struct tcf_hashinfo *hinfo)
 {
 	unsigned int h = tcf_hash(p->tcfc_index, hinfo->hmask);
 
-	write_lock_bh(&hinfo->lock);
-	p->tcfc_next = hinfo->htab[h];
-	hinfo->htab[h] = p;
-	write_unlock_bh(&hinfo->lock);
+	spin_lock_bh(&hinfo->lock);
+	hlist_add_head(&p->tcfc_head, &hinfo->htab[h]);
+	spin_unlock_bh(&hinfo->lock);
 }
 EXPORT_SYMBOL(tcf_hash_insert);
 
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index f201576..0cc305e 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -60,18 +60,19 @@ struct tc_police_compat {
 static int tcf_act_police_walker(struct sk_buff *skb, struct netlink_callback *cb,
 			      int type, struct tc_action *a)
 {
+	struct hlist_head *head;
 	struct tcf_common *p;
 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
 	struct nlattr *nest;
 
-	read_lock_bh(&police_hash_info.lock);
+	spin_lock_bh(&police_hash_info.lock);
 
 	s_i = cb->args[0];
 
 	for (i = 0; i < (POL_TAB_MASK + 1); i++) {
-		p = police_hash_info.htab[tcf_hash(i, POL_TAB_MASK)];
+		head = &police_hash_info.htab[tcf_hash(i, POL_TAB_MASK)];
 
-		for (; p; p = p->tcfc_next) {
+		hlist_for_each_entry_rcu(p, head, tcfc_head) {
 			index++;
 			if (index < s_i)
 				continue;
@@ -94,7 +95,7 @@ static int tcf_act_police_walker(struct sk_buff *skb, struct netlink_callback *c
 		}
 	}
 done:
-	read_unlock_bh(&police_hash_info.lock);
+	spin_unlock_bh(&police_hash_info.lock);
 	if (n_i)
 		cb->args[0] += n_i;
 	return n_i;
@@ -106,25 +107,16 @@ nla_put_failure:
 
 static void tcf_police_destroy(struct tcf_police *p)
 {
-	unsigned int h = tcf_hash(p->tcf_index, POL_TAB_MASK);
-	struct tcf_common **p1p;
-
-	for (p1p = &police_hash_info.htab[h]; *p1p; p1p = &(*p1p)->tcfc_next) {
-		if (*p1p == &p->common) {
-			write_lock_bh(&police_hash_info.lock);
-			*p1p = p->tcf_next;
-			write_unlock_bh(&police_hash_info.lock);
-			gen_kill_estimator(&p->tcf_bstats,
-					   &p->tcf_rate_est);
-			/*
-			 * gen_estimator est_timer() might access p->tcf_lock
-			 * or bstats, wait a RCU grace period before freeing p
-			 */
-			kfree_rcu(p, tcf_rcu);
-			return;
-		}
-	}
-	WARN_ON(1);
+	spin_lock_bh(&police_hash_info.lock);
+	hlist_del(&p->tcf_head);
+	spin_unlock_bh(&police_hash_info.lock);
+	gen_kill_estimator(&p->tcf_bstats,
+			   &p->tcf_rate_est);
+	/*
+	 * gen_estimator est_timer() might access p->tcf_lock
+	 * or bstats, wait a RCU grace period before freeing p
+	 */
+	kfree_rcu(p, tcf_rcu);
 }
 
 static const struct nla_policy police_policy[TCA_POLICE_MAX + 1] = {
@@ -259,10 +251,9 @@ override:
 	police->tcf_index = parm->index ? parm->index :
 		tcf_hash_new_index(&police_idx_gen, &police_hash_info);
 	h = tcf_hash(police->tcf_index, POL_TAB_MASK);
-	write_lock_bh(&police_hash_info.lock);
-	police->tcf_next = police_hash_info.htab[h];
-	police_hash_info.htab[h] = &police->common;
-	write_unlock_bh(&police_hash_info.lock);
+	spin_lock_bh(&police_hash_info.lock);
+	hlist_add_head(&police->tcf_head, &police_hash_info.htab[h]);
+	spin_unlock_bh(&police_hash_info.lock);
 
 	a->priv = police;
 	return ret;
-- 
1.8.1.4
