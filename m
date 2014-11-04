From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH 12/13] net_sched: remove useless qdisc_stab_lock
Date: Tue,  4 Nov 2014 09:56:35 -0800
Message-ID: <1415123796-8093-13-git-send-email-xiyou.wangcong@gmail.com>
References: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:63927 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752164AbaKDR47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 12:56:59 -0500
Received: by mail-pa0-f44.google.com with SMTP id bj1so14954062pad.31
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 09:56:59 -0800 (PST)
In-Reply-To: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We always acquire rtnl lock when we get or put stab,
so there is no need to use another spinlock.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/sch_api.c | 17 ++++-------------
 1 file changed, 4 insertions(+), 13 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index efc60d6..38c42bd 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -441,7 +441,6 @@ void qdisc_put_rtab(struct qdisc_rate_table *tab)
 EXPORT_SYMBOL(qdisc_put_rtab);
 
 static LIST_HEAD(qdisc_stab_list);
-static DEFINE_SPINLOCK(qdisc_stab_lock);
 
 static const struct nla_policy stab_policy[TCA_STAB_MAX + 1] = {
 	[TCA_STAB_BASE]	= { .len = sizeof(struct tc_sizespec) },
@@ -457,6 +456,8 @@ static struct qdisc_size_table *qdisc_get_stab(struct nlattr *opt)
 	u16 *tab = NULL;
 	int err;
 
+	ASSERT_RTNL();
+
 	err = nla_parse_nested(tb, TCA_STAB_MAX, opt, stab_policy);
 	if (err < 0)
 		return ERR_PTR(err);
@@ -475,20 +476,15 @@ static struct qdisc_size_table *qdisc_get_stab(struct nlattr *opt)
 	if (tsize != s->tsize || (!tab && tsize > 0))
 		return ERR_PTR(-EINVAL);
 
-	spin_lock(&qdisc_stab_lock);
-
 	list_for_each_entry(stab, &qdisc_stab_list, list) {
 		if (memcmp(&stab->szopts, s, sizeof(*s)))
 			continue;
 		if (tsize > 0 && memcmp(stab->data, tab, tsize * sizeof(u16)))
 			continue;
 		stab->refcnt++;
-		spin_unlock(&qdisc_stab_lock);
 		return stab;
 	}
 
-	spin_unlock(&qdisc_stab_lock);
-
 	stab = kmalloc(sizeof(*stab) + tsize * sizeof(u16), GFP_KERNEL);
 	if (!stab)
 		return ERR_PTR(-ENOMEM);
@@ -498,10 +494,7 @@ static struct qdisc_size_table *qdisc_get_stab(struct nlattr *opt)
 	if (tsize > 0)
 		memcpy(stab->data, tab, tsize * sizeof(u16));
 
-	spin_lock(&qdisc_stab_lock);
 	list_add_tail(&stab->list, &qdisc_stab_list);
-	spin_unlock(&qdisc_stab_lock);
-
 	return stab;
 }
 
@@ -512,17 +505,15 @@ static void stab_kfree_rcu(struct rcu_head *head)
 
 void qdisc_put_stab(struct qdisc_size_table *tab)
 {
+	ASSERT_RTNL();
+
 	if (!tab)
 		return;
 
-	spin_lock(&qdisc_stab_lock);
-
 	if (--tab->refcnt == 0) {
 		list_del(&tab->list);
 		call_rcu_bh(&tab->rcu, stab_kfree_rcu);
 	}
-
-	spin_unlock(&qdisc_stab_lock);
 }
 EXPORT_SYMBOL(qdisc_put_stab);
 
-- 
1.8.3.1
