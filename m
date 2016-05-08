From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH 1/6] tc vlan action fix late binding
Date: Sun,  8 May 2016 13:16:01 -0400
Message-ID: <1462727766-28359-2-git-send-email-jhs@emojatatu.com>
References: <1462727766-28359-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33439 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863AbcEHRQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 13:16:26 -0400
Received: by mail-io0-f196.google.com with SMTP id x35so16887145ioi.0
        for <netdev@vger.kernel.org>; Sun, 08 May 2016 10:16:25 -0700 (PDT)
In-Reply-To: <1462727766-28359-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Late binding was broken and is fixed with this patch.

//add a vlan action to pop and give it an instance id of 1
sudo tc actions add action vlan pop index 1
//create filter which binds to vlan action id 1
sudo tc filter add dev $DEV parent ffff: protocol ip prio 1 u32 match ip dst 17.0.0.1/32 flowid 1:1 action vlan index 1

current message(before bug fix) was:
RTNETLINK answers: Invalid argument
We have an error talking to the kernel

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_vlan.c | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
index c1682ab..352653f 100644
--- a/net/sched/act_vlan.c
+++ b/net/sched/act_vlan.c
@@ -77,7 +77,7 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
 	int action;
 	__be16 push_vid = 0;
 	__be16 push_proto = 0;
-	int ret = 0;
+	int ret = 0, aexists = 0;
 	int err;
 
 	if (!nla)
@@ -90,15 +90,25 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
 	if (!tb[TCA_VLAN_PARMS])
 		return -EINVAL;
 	parm = nla_data(tb[TCA_VLAN_PARMS]);
+	aexists = tcf_hash_check(tn, parm->index, a, bind);
+	if (aexists && bind)
+		return 0;
+
 	switch (parm->v_action) {
 	case TCA_VLAN_ACT_POP:
 		break;
 	case TCA_VLAN_ACT_PUSH:
-		if (!tb[TCA_VLAN_PUSH_VLAN_ID])
+		if (!tb[TCA_VLAN_PUSH_VLAN_ID]) {
+			if (aexists)
+				tcf_hash_release(a, bind);
 			return -EINVAL;
+		}
 		push_vid = nla_get_u16(tb[TCA_VLAN_PUSH_VLAN_ID]);
-		if (push_vid >= VLAN_VID_MASK)
+		if (push_vid >= VLAN_VID_MASK) {
+			if (aexists)
+				tcf_hash_release(a, bind);
 			return -ERANGE;
+		}
 
 		if (tb[TCA_VLAN_PUSH_VLAN_PROTOCOL]) {
 			push_proto = nla_get_be16(tb[TCA_VLAN_PUSH_VLAN_PROTOCOL]);
@@ -114,11 +124,13 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
 		}
 		break;
 	default:
+		if (aexists)
+			tcf_hash_release(a, bind);
 		return -EINVAL;
 	}
 	action = parm->v_action;
 
-	if (!tcf_hash_check(tn, parm->index, a, bind)) {
+	if (!aexists) {
 		ret = tcf_hash_create(tn, parm->index, est, a,
 				      sizeof(*v), bind, false);
 		if (ret)
@@ -126,8 +138,6 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
 
 		ret = ACT_P_CREATED;
 	} else {
-		if (bind)
-			return 0;
 		tcf_hash_release(a, bind);
 		if (!ovr)
 			return -EEXIST;
-- 
1.9.1
