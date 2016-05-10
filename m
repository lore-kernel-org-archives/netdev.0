From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net PATCH v2 2/6] net sched: ipt action fix late binding
Date: Tue, 10 May 2016 16:49:27 -0400
Message-ID: <1462913371-9699-3-git-send-email-jhs@emojatatu.com>
References: <1462913371-9699-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, jiri@resnulli.us,
	alexander.duyck@gmail.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36800 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069AbcEJUtn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 16:49:43 -0400
Received: by mail-io0-f194.google.com with SMTP id k129so3119242iof.3
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 13:49:43 -0700 (PDT)
In-Reply-To: <1462913371-9699-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

This was broken and is fixed with this patch.

//add an ipt action and give it an instance id of 1
sudo tc actions add action ipt -j mark --set-mark 2 index 1
//create a filter which binds to ipt action id 1
sudo tc filter add dev $DEV parent ffff: protocol ip prio 1 u32\
match ip dst 17.0.0.1/32 flowid 1:10 action ipt index 1

Message before bug fix was:
RTNETLINK answers: Invalid argument
We have an error talking to the kernel

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_ipt.c | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 350e134..8b52700 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -96,7 +96,7 @@ static int __tcf_ipt_init(struct tc_action_net *tn, struct nlattr *nla,
 	struct tcf_ipt *ipt;
 	struct xt_entry_target *td, *t;
 	char *tname;
-	int ret = 0, err;
+	int ret = 0, err, exists = 0;
 	u32 hook = 0;
 	u32 index = 0;
 
@@ -107,18 +107,23 @@ static int __tcf_ipt_init(struct tc_action_net *tn, struct nlattr *nla,
 	if (err < 0)
 		return err;
 
-	if (tb[TCA_IPT_HOOK] == NULL)
-		return -EINVAL;
-	if (tb[TCA_IPT_TARG] == NULL)
+	if (tb[TCA_IPT_INDEX] != NULL)
+		index = nla_get_u32(tb[TCA_IPT_INDEX]);
+
+	exists = tcf_hash_check(tn, index, a, bind);
+	if (exists && bind)
+		return 0;
+
+	if (tb[TCA_IPT_HOOK] == NULL || tb[TCA_IPT_TARG] == NULL) {
+		if (exists)
+			tcf_hash_release(a, bind);
 		return -EINVAL;
+	}
 
 	td = (struct xt_entry_target *)nla_data(tb[TCA_IPT_TARG]);
 	if (nla_len(tb[TCA_IPT_TARG]) < td->u.target_size)
 		return -EINVAL;
 
-	if (tb[TCA_IPT_INDEX] != NULL)
-		index = nla_get_u32(tb[TCA_IPT_INDEX]);
-
 	if (!tcf_hash_check(tn, index, a, bind)) {
 		ret = tcf_hash_create(tn, index, est, a, sizeof(*ipt), bind,
 				      false);
-- 
1.9.1
