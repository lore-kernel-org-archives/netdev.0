From: fgao@ikuai8.com
Subject: [PATCH net-next 1/1] pkt_sched: Remove useless qdisc_stab_lock
Date: Fri, 17 Feb 2017 14:34:19 +0800
Message-ID: <1487313259-103328-1-git-send-email-fgao@ikuai8.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, jhs@mojatatu.com, netdev@vger.kernel.org,
        gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMTPBG252.QQ.COM ([183.60.52.105]:57654 "EHLO smtpbg252.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750866AbdBQGnP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Feb 2017 01:43:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

The qdisc_stab_lock is used in qdisc_get_stab and qdisc_put_stab.
These two functions are invoked in qdisc_create, qdisc_change, and
qdisc_destroy which run fully under RTNL.

So it already makes sure only one could access the qdisc_stab_list at
the same time. Then it is unnecessary to use qdisc_stab_lock now.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 net/sched/sch_api.c | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index a13c15e..bcf49cd 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -440,7 +440,6 @@ void qdisc_put_rtab(struct qdisc_rate_table *tab)
 EXPORT_SYMBOL(qdisc_put_rtab);
 
 static LIST_HEAD(qdisc_stab_list);
-static DEFINE_SPINLOCK(qdisc_stab_lock);
 
 static const struct nla_policy stab_policy[TCA_STAB_MAX + 1] = {
 	[TCA_STAB_BASE]	= { .len = sizeof(struct tc_sizespec) },
@@ -474,20 +473,15 @@ static struct qdisc_size_table *qdisc_get_stab(struct nlattr *opt)
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
@@ -497,9 +491,7 @@ static struct qdisc_size_table *qdisc_get_stab(struct nlattr *opt)
 	if (tsize > 0)
 		memcpy(stab->data, tab, tsize * sizeof(u16));
 
-	spin_lock(&qdisc_stab_lock);
 	list_add_tail(&stab->list, &qdisc_stab_list);
-	spin_unlock(&qdisc_stab_lock);
 
 	return stab;
 }
@@ -514,14 +506,10 @@ void qdisc_put_stab(struct qdisc_size_table *tab)
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
1.9.1
