From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH 5/5] net_sched: Fail if missing mandatory action operation methods
Date: Tue,  3 Dec 2013 09:23:19 -0500
Message-ID: <1386080600-4067-6-git-send-email-jhs@mojatatu.com>
References: <1386080600-4067-1-git-send-email-jhs@mojatatu.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	alexander.h.duyck@intel.com, jhs@mojatatu.com,
	ebiederm@xmission.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:47761 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754203Ab3LCOY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 09:24:26 -0500
Received: by mail-ie0-f173.google.com with SMTP id to1so24136454ieb.32
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 06:24:26 -0800 (PST)
In-Reply-To: <1386080600-4067-1-git-send-email-jhs@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_api.c |   16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 401eca8..c708f3b 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -277,8 +277,10 @@ int tcf_register_action(struct tc_action_ops *act)
 			return -EEXIST;
 		}
 	}
-	act->next = NULL;
-	*ap = act;
+
+	/* Must supply act, dump, cleanup and init */
+	if (!act->act || !act->dump || !act->cleanup || !act->init)
+		return -EINVAL;
 
 	/* Supply defaults */
 	if (!act->lookup)
@@ -286,6 +288,8 @@ int tcf_register_action(struct tc_action_ops *act)
 	if (!act->walk)
 		act->walk = tcf_generic_walker;
 
+	act->next = NULL;
+	*ap = act;
 	write_unlock(&act_mod_lock);
 	return 0;
 }
@@ -388,7 +392,7 @@ int tcf_action_exec(struct sk_buff *skb, const struct tc_action *act,
 	}
 	while ((a = act) != NULL) {
 repeat:
-		if (a->ops && a->ops->act) {
+		if (a->ops) {
 			ret = a->ops->act(skb, a, res);
 			if (TC_MUNGED & skb->tc_verd) {
 				/* copied already, allow trampling */
@@ -412,7 +416,7 @@ void tcf_action_destroy(struct tc_action *act, int bind)
 	struct tc_action *a;
 
 	for (a = act; a; a = act) {
-		if (a->ops && a->ops->cleanup) {
+		if (a->ops) {
 			if (a->ops->cleanup(a, bind) == ACT_P_DELETED)
 				module_put(a->ops->owner);
 			act = act->next;
@@ -431,7 +435,7 @@ tcf_action_dump_old(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 {
 	int err = -EINVAL;
 
-	if (a->ops == NULL || a->ops->dump == NULL)
+	if (a->ops == NULL)
 		return err;
 	return a->ops->dump(skb, a, bind, ref);
 }
@@ -443,7 +447,7 @@ tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 	unsigned char *b = skb_tail_pointer(skb);
 	struct nlattr *nest;
 
-	if (a->ops == NULL || a->ops->dump == NULL)
+	if (a->ops == NULL)
 		return err;
 
 	if (nla_put_string(skb, TCA_KIND, a->ops->kind))
-- 
1.7.10.4
