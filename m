From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH 1/5] net_sched: Fail if missing mandatory action operation methods
Date: Wed,  4 Dec 2013 09:26:52 -0500
Message-ID: <1386167216-30281-2-git-send-email-jhs@mojatatu.com>
References: <1386167216-30281-1-git-send-email-jhs@mojatatu.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	alexander.h.duyck@intel.com, jhs@mojatatu.com,
	ebiederm@xmission.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:56476 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932298Ab3LDO1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 09:27:37 -0500
Received: by mail-ie0-f180.google.com with SMTP id tp5so26670656ieb.11
        for <netdev@vger.kernel.org>; Wed, 04 Dec 2013 06:27:37 -0800 (PST)
In-Reply-To: <1386167216-30281-1-git-send-email-jhs@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_api.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index fd70728..618695e 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -270,6 +270,10 @@ int tcf_register_action(struct tc_action_ops *act)
 {
 	struct tc_action_ops *a, **ap;
 
+	/* Must supply act, dump, cleanup and init */
+	if (!act->act || !act->dump || !act->cleanup || !act->init)
+		return -EINVAL;
+
 	write_lock(&act_mod_lock);
 	for (ap = &act_base; (a = *ap) != NULL; ap = &a->next) {
 		if (act->type == a->type || (strcmp(act->kind, a->kind) == 0)) {
@@ -381,7 +385,7 @@ int tcf_action_exec(struct sk_buff *skb, const struct tc_action *act,
 	}
 	while ((a = act) != NULL) {
 repeat:
-		if (a->ops && a->ops->act) {
+		if (a->ops) {
 			ret = a->ops->act(skb, a, res);
 			if (TC_MUNGED & skb->tc_verd) {
 				/* copied already, allow trampling */
@@ -405,7 +409,7 @@ void tcf_action_destroy(struct tc_action *act, int bind)
 	struct tc_action *a;
 
 	for (a = act; a; a = act) {
-		if (a->ops && a->ops->cleanup) {
+		if (a->ops) {
 			if (a->ops->cleanup(a, bind) == ACT_P_DELETED)
 				module_put(a->ops->owner);
 			act = act->next;
@@ -424,7 +428,7 @@ tcf_action_dump_old(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 {
 	int err = -EINVAL;
 
-	if (a->ops == NULL || a->ops->dump == NULL)
+	if (a->ops == NULL)
 		return err;
 	return a->ops->dump(skb, a, bind, ref);
 }
@@ -436,7 +440,7 @@ tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 	unsigned char *b = skb_tail_pointer(skb);
 	struct nlattr *nest;
 
-	if (a->ops == NULL || a->ops->dump == NULL)
+	if (a->ops == NULL)
 		return err;
 
 	if (nla_put_string(skb, TCA_KIND, a->ops->kind))
-- 
1.7.10.4
