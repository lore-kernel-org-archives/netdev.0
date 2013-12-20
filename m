From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net_sched: fix regression in tc_action_ops
Date: Fri, 20 Dec 2013 12:32:32 -0800
Message-ID: <1387571552.19078.468.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387526931-21814-1-git-send-email-xiyou.wangcong@gmail.com>
	 <52B434FA.8080309@mojatatu.com>
	 <1387550222.19078.434.camel@edumazet-glaptop2.roam.corp.google.com>
	 <52B45851.90208@mojatatu.com>
	 <1387555659.19078.439.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1387560028.19078.442.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1387560578.19078.443.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1387562658.19078.448.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAM_iQpUQ3iaq+X+CngqJCGWq5Ep_XhcfWEKqrCQcZ3iC6Uz_qA@mail.gmail.com>
	 <1387568188.19078.453.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAM_iQpV+WJdeOHOyGENT2XWn=ytjBirBo1G4H2b_QziKHWFw0g@mail.gmail.com>
	 <1387570492.19078.463.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f49.google.com ([209.85.128.49]:32948 "EHLO
	mail-qe0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751838Ab3LTUcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 15:32:35 -0500
Received: by mail-qe0-f49.google.com with SMTP id w7so2849095qeb.22
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 12:32:35 -0800 (PST)
In-Reply-To: <1387570492.19078.463.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

list_for_each_entry(a, &act_base, head) doesn't
exit with a = NULL if we reached the end of the list.

tcf_unregister_action(), tc_lookup_action_n() and tc_lookup_action()
need fixes.

Remove tc_lookup_action_id() as its unused and not worth 'fixing'

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: 1f747c26c48b ("net_sched: convert tc_action_ops to use struct list_head")
Cc: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_api.c |   53 ++++++++++--------------------------------
 1 file changed, 13 insertions(+), 40 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 8114fef308d9..dce2b6ecdbd8 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -291,12 +291,12 @@ int tcf_unregister_action(struct tc_action_ops *act)
 	int err = -ENOENT;
 
 	write_lock(&act_mod_lock);
-	list_for_each_entry(a, &act_base, head)
-		if (a == act)
+	list_for_each_entry(a, &act_base, head) {
+		if (a == act) {
+			list_del(&act->head);
+			err = 0;
 			break;
-	if (a) {
-		list_del(&act->head);
-		err = 0;
+		}
 	}
 	write_unlock(&act_mod_lock);
 	return err;
@@ -306,68 +306,41 @@ EXPORT_SYMBOL(tcf_unregister_action);
 /* lookup by name */
 static struct tc_action_ops *tc_lookup_action_n(char *kind)
 {
-	struct tc_action_ops *a = NULL;
+	struct tc_action_ops *a, *res = NULL;
 
 	if (kind) {
 		read_lock(&act_mod_lock);
 		list_for_each_entry(a, &act_base, head) {
 			if (strcmp(kind, a->kind) == 0) {
-				if (!try_module_get(a->owner)) {
-					read_unlock(&act_mod_lock);
-					return NULL;
-				}
+				if (try_module_get(a->owner))
+					res = a;
 				break;
 			}
 		}
 		read_unlock(&act_mod_lock);
 	}
-	return a;
+	return res;
 }
 
 /* lookup by nlattr */
 static struct tc_action_ops *tc_lookup_action(struct nlattr *kind)
 {
-	struct tc_action_ops *a = NULL;
+	struct tc_action_ops *a, *res = NULL;
 
 	if (kind) {
 		read_lock(&act_mod_lock);
 		list_for_each_entry(a, &act_base, head) {
 			if (nla_strcmp(kind, a->kind) == 0) {
-				if (!try_module_get(a->owner)) {
-					read_unlock(&act_mod_lock);
-					return NULL;
-				}
+				if (try_module_get(a->owner))
+					res = a;
 				break;
 			}
 		}
 		read_unlock(&act_mod_lock);
 	}
-	return a;
+	return res;
 }
 
-#if 0
-/* lookup by id */
-static struct tc_action_ops *tc_lookup_action_id(u32 type)
-{
-	struct tc_action_ops *a = NULL;
-
-	if (type) {
-		read_lock(&act_mod_lock);
-		for (a = act_base; a; a = a->next) {
-			if (a->type == type) {
-				if (!try_module_get(a->owner)) {
-					read_unlock(&act_mod_lock);
-					return NULL;
-				}
-				break;
-			}
-		}
-		read_unlock(&act_mod_lock);
-	}
-	return a;
-}
-#endif
-
 int tcf_action_exec(struct sk_buff *skb, const struct list_head *actions,
 		    struct tcf_result *res)
 {
