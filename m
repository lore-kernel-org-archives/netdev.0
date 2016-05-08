From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH v2 3/6] net sched: mirred action fix late binding
Date: Sun,  8 May 2016 13:26:29 -0400
Message-ID: <1462728392-28489-4-git-send-email-jhs@emojatatu.com>
References: <1462728392-28489-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35823 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894AbcEHR0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 13:26:44 -0400
Received: by mail-io0-f195.google.com with SMTP id u185so19023164iod.2
        for <netdev@vger.kernel.org>; Sun, 08 May 2016 10:26:44 -0700 (PDT)
In-Reply-To: <1462728392-28489-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

The process below was broken and is fixed with this patch.

//add an mirred action and give it an instance id of 1
sudo tc actions add action mirred egress mirror dev $MDEV  index 1
//create a filter which binds to mirred action id 1
sudo tc filter add dev $DEV parent ffff: protocol ip prio 1 u32\
match ip dst 17.0.0.1/32 flowid 1:10 action mirred index 1

Message before bug fix was:
RTNETLINK answers: Invalid argument
We have an error talking to the kernel

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_mirred.c | 22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index dea57c1..9e682c8 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -61,7 +61,7 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 	struct tc_mirred *parm;
 	struct tcf_mirred *m;
 	struct net_device *dev;
-	int ret, ok_push = 0;
+	int ret, ok_push = 0, aexists = 0;
 
 	if (nla == NULL)
 		return -EINVAL;
@@ -71,17 +71,27 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 	if (tb[TCA_MIRRED_PARMS] == NULL)
 		return -EINVAL;
 	parm = nla_data(tb[TCA_MIRRED_PARMS]);
+
+	aexists = tcf_hash_check(tn, parm->index, a, bind);
+	if (aexists && bind)
+		return 0;
+
 	switch (parm->eaction) {
 	case TCA_EGRESS_MIRROR:
 	case TCA_EGRESS_REDIR:
 		break;
 	default:
+		if (aexists)
+			tcf_hash_release(a, bind);
 		return -EINVAL;
 	}
 	if (parm->ifindex) {
 		dev = __dev_get_by_index(net, parm->ifindex);
-		if (dev == NULL)
+		if (dev == NULL) {
+			if (aexists)
+				tcf_hash_release(a, bind);
 			return -ENODEV;
+		}
 		switch (dev->type) {
 		case ARPHRD_TUNNEL:
 		case ARPHRD_TUNNEL6:
@@ -99,7 +109,7 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 		dev = NULL;
 	}
 
-	if (!tcf_hash_check(tn, parm->index, a, bind)) {
+	if (!aexists) {
 		if (dev == NULL)
 			return -EINVAL;
 		ret = tcf_hash_create(tn, parm->index, est, a,
@@ -108,9 +118,6 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 			return ret;
 		ret = ACT_P_CREATED;
 	} else {
-		if (bind)
-			return 0;
-
 		tcf_hash_release(a, bind);
 		if (!ovr)
 			return -EEXIST;
@@ -195,7 +202,8 @@ out:
 	return retval;
 }
 
-static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
+static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind,
+			   int ref)
 {
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tcf_mirred *m = a->priv;
-- 
1.9.1
