From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net_sched: move tcf_lock down after gen_replace_estimator()
Date: Tue, 13 Jun 2017 13:36:24 -0700
Message-ID: <1497386184-14960-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: nicholashuber@gmail.com, labbott@redhat.com,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33761 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752695AbdFMUgh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 16:36:37 -0400
Received: by mail-io0-f194.google.com with SMTP id j200so9783091ioe.0
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 13:36:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Laura reported a sleep-in-atomic kernel warning inside
tcf_act_police_init() which calls gen_replace_estimator() with
spinlock protection.

It is not necessary in this case, we already have RTNL lock here
so it is enough to protect concurrent writers. For the reader,
i.e. tcf_act_police(), it needs to make decision based on this
rate estimator, in the worst case we drop more/less packets than
necessary while changing the rate in parallel, it is still acceptable.

Reported-by: Laura Abbott <labbott@redhat.com>
Reported-by: Nick Huber <nicholashuber@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_police.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index f42008b..b062bc8 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -132,21 +132,21 @@ static int tcf_act_police_init(struct net *net, struct nlattr *nla,
 		}
 	}
 
-	spin_lock_bh(&police->tcf_lock);
 	if (est) {
 		err = gen_replace_estimator(&police->tcf_bstats, NULL,
 					    &police->tcf_rate_est,
 					    &police->tcf_lock,
 					    NULL, est);
 		if (err)
-			goto failure_unlock;
+			goto failure;
 	} else if (tb[TCA_POLICE_AVRATE] &&
 		   (ret == ACT_P_CREATED ||
 		    !gen_estimator_active(&police->tcf_rate_est))) {
 		err = -EINVAL;
-		goto failure_unlock;
+		goto failure;
 	}
 
+	spin_lock_bh(&police->tcf_lock);
 	/* No failure allowed after this point */
 	police->tcfp_mtu = parm->mtu;
 	if (police->tcfp_mtu == 0) {
@@ -192,8 +192,6 @@ static int tcf_act_police_init(struct net *net, struct nlattr *nla,
 
 	return ret;
 
-failure_unlock:
-	spin_unlock_bh(&police->tcf_lock);
 failure:
 	qdisc_put_rtab(P_tab);
 	qdisc_put_rtab(R_tab);
-- 
2.5.5
