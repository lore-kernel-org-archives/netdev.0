From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net PATCH v2 1/6] net sched: vlan action fix late binding
Date: Tue, 10 May 2016 16:49:26 -0400
Message-ID: <1462913371-9699-2-git-send-email-jhs@emojatatu.com>
References: <1462913371-9699-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, jiri@resnulli.us,
	alexander.duyck@gmail.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33996 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473AbcEJUtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 16:49:42 -0400
Received: by mail-io0-f195.google.com with SMTP id d62so3143865iof.1
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 13:49:41 -0700 (PDT)
In-Reply-To: <1462913371-9699-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Late vlan action binding was broken and is fixed with this patch.

//add a vlan action to pop and give it an instance id of 1
sudo tc actions add action vlan pop index 1
//create filter which binds to vlan action id 1
sudo tc filter add dev $DEV parent ffff: protocol ip prio 1 u32 \
match ip dst 17.0.0.1/32 flowid 1:1 action vlan index 1

current message(before bug fix) was:
RTNETLINK answers: Invalid argument
We have an error talking to the kernel

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_vlan.c | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
index bab8ae0..c45f926 100644
--- a/net/sched/act_vlan.c
+++ b/net/sched/act_vlan.c
@@ -77,7 +77,7 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
 	int action;
 	__be16 push_vid = 0;
 	__be16 push_proto = 0;
-	int ret = 0;
+	int ret = 0, exists = 0;
 	int err;
 
 	if (!nla)
@@ -90,15 +90,25 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
 	if (!tb[TCA_VLAN_PARMS])
 		return -EINVAL;
 	parm = nla_data(tb[TCA_VLAN_PARMS]);
+	exists = tcf_hash_check(tn, parm->index, a, bind);
+	if (exists && bind)
+		return 0;
+
 	switch (parm->v_action) {
 	case TCA_VLAN_ACT_POP:
 		break;
 	case TCA_VLAN_ACT_PUSH:
-		if (!tb[TCA_VLAN_PUSH_VLAN_ID])
+		if (!tb[TCA_VLAN_PUSH_VLAN_ID]) {
+			if (exists)
+				tcf_hash_release(a, bind);
 			return -EINVAL;
+		}
 		push_vid = nla_get_u16(tb[TCA_VLAN_PUSH_VLAN_ID]);
-		if (push_vid >= VLAN_VID_MASK)
+		if (push_vid >= VLAN_VID_MASK) {
+			if (exists)
+				tcf_hash_release(a, bind);
 			return -ERANGE;
+		}
 
 		if (tb[TCA_VLAN_PUSH_VLAN_PROTOCOL]) {
 			push_proto = nla_get_be16(tb[TCA_VLAN_PUSH_VLAN_PROTOCOL]);
@@ -114,11 +124,13 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
 		}
 		break;
 	default:
+		if (exists)
+			tcf_hash_release(a, bind);
 		return -EINVAL;
 	}
 	action = parm->v_action;
 
-	if (!tcf_hash_check(tn, parm->index, a, bind)) {
+	if (!exists) {
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
