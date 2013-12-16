From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH net-next v4 7/8] net_sched: convert tc_action_ops to use struct list_head
Date: Sun, 15 Dec 2013 20:15:10 -0800
Message-ID: <1387167311-14763-8-git-send-email-xiyou.wangcong@gmail.com>
References: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:56214 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752556Ab3LPEPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 23:15:35 -0500
Received: by mail-pb0-f50.google.com with SMTP id rr13so4967848pbb.9
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 20:15:35 -0800 (PST)
In-Reply-To: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't need to maintain our own singly linked list code.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h |  2 +-
 net/sched/act_api.c   | 20 +++++++++-----------
 2 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 22418d1..77d5d81 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -85,7 +85,7 @@ struct tc_action {
 
 #define TCA_CAP_NONE 0
 struct tc_action_ops {
-	struct tc_action_ops *next;
+	struct list_head head;
 	struct tcf_hashinfo *hinfo;
 	char    kind[IFNAMSIZ];
 	__u32   type; /* TBD to match kind */
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index dc457c9..8114fef 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -255,12 +255,12 @@ void tcf_hash_insert(struct tcf_common *p, struct tcf_hashinfo *hinfo)
 }
 EXPORT_SYMBOL(tcf_hash_insert);
 
-static struct tc_action_ops *act_base = NULL;
+static LIST_HEAD(act_base);
 static DEFINE_RWLOCK(act_mod_lock);
 
 int tcf_register_action(struct tc_action_ops *act)
 {
-	struct tc_action_ops *a, **ap;
+	struct tc_action_ops *a;
 
 	/* Must supply act, dump, cleanup and init */
 	if (!act->act || !act->dump || !act->cleanup || !act->init)
@@ -273,14 +273,13 @@ int tcf_register_action(struct tc_action_ops *act)
 		act->walk = tcf_generic_walker;
 
 	write_lock(&act_mod_lock);
-	for (ap = &act_base; (a = *ap) != NULL; ap = &a->next) {
+	list_for_each_entry(a, &act_base, head) {
 		if (act->type == a->type || (strcmp(act->kind, a->kind) == 0)) {
 			write_unlock(&act_mod_lock);
 			return -EEXIST;
 		}
 	}
-	act->next = NULL;
-	*ap = act;
+	list_add_tail(&act->head, &act_base);
 	write_unlock(&act_mod_lock);
 	return 0;
 }
@@ -288,16 +287,15 @@ EXPORT_SYMBOL(tcf_register_action);
 
 int tcf_unregister_action(struct tc_action_ops *act)
 {
-	struct tc_action_ops *a, **ap;
+	struct tc_action_ops *a;
 	int err = -ENOENT;
 
 	write_lock(&act_mod_lock);
-	for (ap = &act_base; (a = *ap) != NULL; ap = &a->next)
+	list_for_each_entry(a, &act_base, head)
 		if (a == act)
 			break;
 	if (a) {
-		*ap = a->next;
-		a->next = NULL;
+		list_del(&act->head);
 		err = 0;
 	}
 	write_unlock(&act_mod_lock);
@@ -312,7 +310,7 @@ static struct tc_action_ops *tc_lookup_action_n(char *kind)
 
 	if (kind) {
 		read_lock(&act_mod_lock);
-		for (a = act_base; a; a = a->next) {
+		list_for_each_entry(a, &act_base, head) {
 			if (strcmp(kind, a->kind) == 0) {
 				if (!try_module_get(a->owner)) {
 					read_unlock(&act_mod_lock);
@@ -333,7 +331,7 @@ static struct tc_action_ops *tc_lookup_action(struct nlattr *kind)
 
 	if (kind) {
 		read_lock(&act_mod_lock);
-		for (a = act_base; a; a = a->next) {
+		list_for_each_entry(a, &act_base, head) {
 			if (nla_strcmp(kind, a->kind) == 0) {
 				if (!try_module_get(a->owner)) {
 					read_unlock(&act_mod_lock);
-- 
1.8.1.4
