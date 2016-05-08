From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH v2 4/6] net sched: simple action fix late binding
Date: Sun,  8 May 2016 13:26:30 -0400
Message-ID: <1462728392-28489-5-git-send-email-jhs@emojatatu.com>
References: <1462728392-28489-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36130 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885AbcEHR0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 13:26:45 -0400
Received: by mail-io0-f194.google.com with SMTP id k129so16828260iof.3
        for <netdev@vger.kernel.org>; Sun, 08 May 2016 10:26:45 -0700 (PDT)
In-Reply-To: <1462728392-28489-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

The process below was broken and is fixed with this patch.

//add a simple action and give it an instance id of 1
sudo tc actions add action simple sdata "foobar" index 1
//create a filter which binds to simple action id 1
sudo tc filter add dev $DEV parent ffff: protocol ip prio 1 u32\
match ip dst 17.0.0.1/32 flowid 1:10 action simple index 1

Message before fix was:
RTNETLINK answers: Invalid argument
We have an error talking to the kernel

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_simple.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index 2057fd56..d9f44be 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -87,7 +87,7 @@ static int tcf_simp_init(struct net *net, struct nlattr *nla,
 	struct tc_defact *parm;
 	struct tcf_defact *d;
 	char *defdata;
-	int ret = 0, err;
+	int ret = 0, err, aexists = 0;
 
 	if (nla == NULL)
 		return -EINVAL;
@@ -99,13 +99,21 @@ static int tcf_simp_init(struct net *net, struct nlattr *nla,
 	if (tb[TCA_DEF_PARMS] == NULL)
 		return -EINVAL;
 
-	if (tb[TCA_DEF_DATA] == NULL)
-		return -EINVAL;
 
 	parm = nla_data(tb[TCA_DEF_PARMS]);
+	aexists = tcf_hash_check(tn, parm->index, a, bind);
+	if (aexists && bind)
+		return 0;
+
+	if (tb[TCA_DEF_DATA] == NULL) {
+		if (aexists)
+			tcf_hash_release(a, bind);
+		return -EINVAL;
+	}
+
 	defdata = nla_data(tb[TCA_DEF_DATA]);
 
-	if (!tcf_hash_check(tn, parm->index, a, bind)) {
+	if (!aexists) {
 		ret = tcf_hash_create(tn, parm->index, est, a,
 				      sizeof(*d), bind, false);
 		if (ret)
@@ -122,8 +130,6 @@ static int tcf_simp_init(struct net *net, struct nlattr *nla,
 	} else {
 		d = to_defact(a);
 
-		if (bind)
-			return 0;
 		tcf_hash_release(a, bind);
 		if (!ovr)
 			return -EEXIST;
-- 
1.9.1
