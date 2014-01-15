From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net_sched: act: use tcf_hash_release() in net/sched/act_police.c
Date: Wed, 15 Jan 2014 15:23:26 -0800
Message-ID: <1389828206-9467-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:58879 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752158AbaAOXXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 18:23:36 -0500
Received: by mail-pa0-f42.google.com with SMTP id kl14so1838867pab.29
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 15:23:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_police.c | 30 +++---------------------------
 1 file changed, 3 insertions(+), 27 deletions(-)

diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index a719fdf..5ba467b 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -104,20 +104,6 @@ nla_put_failure:
 	goto done;
 }
 
-static void tcf_police_destroy(struct tcf_police *p)
-{
-	spin_lock_bh(&police_hash_info.lock);
-	hlist_del(&p->tcf_head);
-	spin_unlock_bh(&police_hash_info.lock);
-	gen_kill_estimator(&p->tcf_bstats,
-			   &p->tcf_rate_est);
-	/*
-	 * gen_estimator est_timer() might access p->tcf_lock
-	 * or bstats, wait a RCU grace period before freeing p
-	 */
-	kfree_rcu(p, tcf_rcu);
-}
-
 static const struct nla_policy police_policy[TCA_POLICE_MAX + 1] = {
 	[TCA_POLICE_RATE]	= { .len = TC_RTAB_SIZE },
 	[TCA_POLICE_PEAKRATE]	= { .len = TC_RTAB_SIZE },
@@ -272,19 +258,9 @@ failure:
 static int tcf_act_police_cleanup(struct tc_action *a, int bind)
 {
 	struct tcf_police *p = a->priv;
-	int ret = 0;
-
-	if (p != NULL) {
-		if (bind)
-			p->tcf_bindcnt--;
-
-		p->tcf_refcnt--;
-		if (p->tcf_refcnt <= 0 && !p->tcf_bindcnt) {
-			tcf_police_destroy(p);
-			ret = 1;
-		}
-	}
-	return ret;
+	if (p)
+		return tcf_hash_release(&p->common, bind, &police_hash_info);
+	return 0;
 }
 
 static int tcf_act_police(struct sk_buff *skb, const struct tc_action *a,
-- 
1.8.3.1
