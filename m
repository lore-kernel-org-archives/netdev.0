From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net v4 6/7] net_sched: unify the init logic for act_police
Date: Sat, 13 Aug 2016 22:35:01 -0700
Message-ID: <1471152902-12444-7-git-send-email-xiyou.wangcong@gmail.com>
References: <1471152902-12444-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: jhs@mojatatu.com, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34017 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbcHNJO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 05:14:59 -0400
Received: by mail-pf0-f194.google.com with SMTP id g202so2033545pfb.1
        for <netdev@vger.kernel.org>; Sun, 14 Aug 2016 02:14:58 -0700 (PDT)
In-Reply-To: <1471152902-12444-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jamal reported a crash when we create a police action
with a specific index, this is because the init logic
is not correct, we should always create one for this
case. Just unify the logic with other tc actions.

Fixes: a03e6fe56971 ("act_police: fix a crash during removal")
Reported-by: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_police.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index b3c7e97..259352d 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -125,6 +125,7 @@ static int tcf_act_police_init(struct net *net, struct nlattr *nla,
 	struct tcf_police *police;
 	struct qdisc_rate_table *R_tab = NULL, *P_tab = NULL;
 	struct tc_action_net *tn = net_generic(net, police_net_id);
+	bool exists = false;
 	int size;
 
 	if (nla == NULL)
@@ -139,24 +140,24 @@ static int tcf_act_police_init(struct net *net, struct nlattr *nla,
 	size = nla_len(tb[TCA_POLICE_TBF]);
 	if (size != sizeof(*parm) && size != sizeof(struct tc_police_compat))
 		return -EINVAL;
+
 	parm = nla_data(tb[TCA_POLICE_TBF]);
+	exists = tcf_hash_check(tn, parm->index, a, bind);
+	if (exists && bind)
+		return 0;
 
-	if (parm->index) {
-		if (tcf_hash_check(tn, parm->index, a, bind)) {
-			if (ovr)
-				goto override;
-			/* not replacing */
-			return -EEXIST;
-		}
-	} else {
+	if (!exists) {
 		ret = tcf_hash_create(tn, parm->index, NULL, a,
 				      &act_police_ops, bind, false);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
+	} else {
+		tcf_hash_release(*a, bind);
+		if (!ovr)
+			return -EEXIST;
 	}
 
-override:
 	police = to_police(*a);
 	if (parm->rate.rate) {
 		err = -ENOMEM;
-- 
1.8.4.5
