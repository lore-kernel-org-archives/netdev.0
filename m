From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net PATCH v2 5/6] net sched: skbedit action fix late binding
Date: Tue, 10 May 2016 16:49:30 -0400
Message-ID: <1462913371-9699-6-git-send-email-jhs@emojatatu.com>
References: <1462913371-9699-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, jiri@resnulli.us,
	alexander.duyck@gmail.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36833 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473AbcEJUtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 16:49:47 -0400
Received: by mail-io0-f193.google.com with SMTP id k129so3119471iof.3
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 13:49:46 -0700 (PDT)
In-Reply-To: <1462913371-9699-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

The process below was broken and is fixed with this patch.

//add a skbedit action and give it an instance id of 1
sudo tc actions add action skbedit mark 10 index 1
//create a filter which binds to skbedit action id 1
sudo tc filter add dev $DEV parent ffff: protocol ip prio 1 u32\
match ip dst 17.0.0.1/32 flowid 1:10 action skbedit index 1

Message before fix was:
RTNETLINK answers: Invalid argument
We have an error talking to the kernel

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_skbedit.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index cfcdbdc..69da5a8 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -69,7 +69,7 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 	struct tcf_skbedit *d;
 	u32 flags = 0, *priority = NULL, *mark = NULL;
 	u16 *queue_mapping = NULL;
-	int ret = 0, err;
+	int ret = 0, err, exists = 0;
 
 	if (nla == NULL)
 		return -EINVAL;
@@ -96,12 +96,18 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 		mark = nla_data(tb[TCA_SKBEDIT_MARK]);
 	}
 
-	if (!flags)
-		return -EINVAL;
-
 	parm = nla_data(tb[TCA_SKBEDIT_PARMS]);
 
-	if (!tcf_hash_check(tn, parm->index, a, bind)) {
+	exists = tcf_hash_check(tn, parm->index, a, bind);
+	if (exists && bind)
+		return 0;
+
+	if (!flags) {
+		tcf_hash_release(a, bind);
+		return -EINVAL;
+	}
+
+	if (!exists) {
 		ret = tcf_hash_create(tn, parm->index, est, a,
 				      sizeof(*d), bind, false);
 		if (ret)
@@ -111,8 +117,6 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 		ret = ACT_P_CREATED;
 	} else {
 		d = to_skbedit(a);
-		if (bind)
-			return 0;
 		tcf_hash_release(a, bind);
 		if (!ovr)
 			return -EEXIST;
-- 
1.9.1
