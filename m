From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 05/15]: act_api: use PTR_ERR in tcf_action_init/tcf_action_get
Date: Wed, 23 Jan 2008 17:36:42 +0100 (MET)
Message-ID: <20080123163601.6459.80065.sendpatchset@localhost.localdomain>
References: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49726 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753975AbYAWQgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 11:36:43 -0500
In-Reply-To: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: act_api: use PTR_ERR in tcf_action_init/tcf_action_get

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 0919ac24aa4bd6978806f35f8daefe32aa997823
tree 95e2c04521d6a09c080eac8735ab0598c3b3ff5b
parent f9f9cbaccb1a58ea02318250192effe1e2e1e715
author Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:12:41 +0100
committer Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:12:41 +0100

 include/net/act_api.h |    4 +--
 net/sched/act_api.c   |   71 +++++++++++++++++++++++++++----------------------
 net/sched/cls_api.c   |   14 +++++-----
 3 files changed, 48 insertions(+), 41 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index c5ac61a..565eed8 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -114,8 +114,8 @@ extern int tcf_register_action(struct tc_action_ops *a);
 extern int tcf_unregister_action(struct tc_action_ops *a);
 extern void tcf_action_destroy(struct tc_action *a, int bind);
 extern int tcf_action_exec(struct sk_buff *skb, struct tc_action *a, struct tcf_result *res);
-extern struct tc_action *tcf_action_init(struct nlattr *nla, struct nlattr *est, char *n, int ovr, int bind, int *err);
-extern struct tc_action *tcf_action_init_1(struct nlattr *nla, struct nlattr *est, char *n, int ovr, int bind, int *err);
+extern struct tc_action *tcf_action_init(struct nlattr *nla, struct nlattr *est, char *n, int ovr, int bind);
+extern struct tc_action *tcf_action_init_1(struct nlattr *nla, struct nlattr *est, char *n, int ovr, int bind);
 extern int tcf_action_dump(struct sk_buff *skb, struct tc_action *a, int, int);
 extern int tcf_action_dump_old(struct sk_buff *skb, struct tc_action *a, int, int);
 extern int tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int, int);
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 2fe0345..ea80f82 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -18,6 +18,7 @@
 #include <linux/skbuff.h>
 #include <linux/init.h>
 #include <linux/kmod.h>
+#include <linux/err.h>
 #include <net/net_namespace.h>
 #include <net/sock.h>
 #include <net/sch_generic.h>
@@ -463,15 +464,16 @@ errout:
 }
 
 struct tc_action *tcf_action_init_1(struct nlattr *nla, struct nlattr *est,
-				    char *name, int ovr, int bind, int *err)
+				    char *name, int ovr, int bind)
 {
 	struct tc_action *a;
 	struct tc_action_ops *a_o;
 	char act_name[IFNAMSIZ];
 	struct nlattr *tb[TCA_ACT_MAX+1];
 	struct nlattr *kind;
+	int err;
 
-	*err = -EINVAL;
+	err = -EINVAL;
 
 	if (name == NULL) {
 		if (nla_parse_nested(tb, TCA_ACT_MAX, nla, NULL) < 0)
@@ -502,36 +504,35 @@ struct tc_action *tcf_action_init_1(struct nlattr *nla, struct nlattr *est,
 		 * indicate this using -EAGAIN.
 		 */
 		if (a_o != NULL) {
-			*err = -EAGAIN;
+			err = -EAGAIN;
 			goto err_mod;
 		}
 #endif
-		*err = -ENOENT;
+		err = -ENOENT;
 		goto err_out;
 	}
 
-	*err = -ENOMEM;
+	err = -ENOMEM;
 	a = kzalloc(sizeof(*a), GFP_KERNEL);
 	if (a == NULL)
 		goto err_mod;
 
 	/* backward compatibility for policer */
 	if (name == NULL)
-		*err = a_o->init(tb[TCA_ACT_OPTIONS], est, a, ovr, bind);
+		err = a_o->init(tb[TCA_ACT_OPTIONS], est, a, ovr, bind);
 	else
-		*err = a_o->init(nla, est, a, ovr, bind);
-	if (*err < 0)
+		err = a_o->init(nla, est, a, ovr, bind);
+	if (err < 0)
 		goto err_free;
 
 	/* module count goes up only when brand new policy is created
 	   if it exists and is only bound to in a_o->init() then
 	   ACT_P_CREATED is not returned (a zero is).
 	*/
-	if (*err != ACT_P_CREATED)
+	if (err != ACT_P_CREATED)
 		module_put(a_o->owner);
 	a->ops = a_o;
 
-	*err = 0;
 	return a;
 
 err_free:
@@ -539,24 +540,22 @@ err_free:
 err_mod:
 	module_put(a_o->owner);
 err_out:
-	return NULL;
+	return ERR_PTR(err);
 }
 
 struct tc_action *tcf_action_init(struct nlattr *nla, struct nlattr *est,
-				  char *name, int ovr, int bind, int *err)
+				  char *name, int ovr, int bind)
 {
 	struct nlattr *tb[TCA_ACT_MAX_PRIO+1];
 	struct tc_action *head = NULL, *act, *act_prev = NULL;
 	int i;
 
-	if (nla_parse_nested(tb, TCA_ACT_MAX_PRIO, nla, NULL) < 0) {
-		*err = -EINVAL;
-		return head;
-	}
+	if (nla_parse_nested(tb, TCA_ACT_MAX_PRIO, nla, NULL) < 0)
+		return ERR_PTR(-EINVAL);
 
 	for (i = 1; i <= TCA_ACT_MAX_PRIO && tb[i]; i++) {
-		act = tcf_action_init_1(tb[i], est, name, ovr, bind, err);
-		if (act == NULL)
+		act = tcf_action_init_1(tb[i], est, name, ovr, bind);
+		if (IS_ERR(act))
 			goto err;
 		act->order = i;
 
@@ -571,7 +570,7 @@ struct tc_action *tcf_action_init(struct nlattr *nla, struct nlattr *est,
 err:
 	if (head != NULL)
 		tcf_action_destroy(head, bind);
-	return NULL;
+	return act;
 }
 
 int tcf_action_copy_stats(struct sk_buff *skb, struct tc_action *a,
@@ -668,44 +667,46 @@ act_get_notify(u32 pid, struct nlmsghdr *n, struct tc_action *a, int event)
 }
 
 static struct tc_action *
-tcf_action_get_1(struct nlattr *nla, struct nlmsghdr *n, u32 pid, int *err)
+tcf_action_get_1(struct nlattr *nla, struct nlmsghdr *n, u32 pid)
 {
 	struct nlattr *tb[TCA_ACT_MAX+1];
 	struct tc_action *a;
 	int index;
+	int err;
 
-	*err = -EINVAL;
+	err = -EINVAL;
 	if (nla_parse_nested(tb, TCA_ACT_MAX, nla, NULL) < 0)
-		return NULL;
+		goto err_out;
 
 	if (tb[TCA_ACT_INDEX] == NULL ||
 	    nla_len(tb[TCA_ACT_INDEX]) < sizeof(index))
-		return NULL;
+		goto err_out;
 	index = *(int *)nla_data(tb[TCA_ACT_INDEX]);
 
-	*err = -ENOMEM;
+	err = -ENOMEM;
 	a = kzalloc(sizeof(struct tc_action), GFP_KERNEL);
 	if (a == NULL)
-		return NULL;
+		goto err_out;
 
-	*err = -EINVAL;
+	err = -EINVAL;
 	a->ops = tc_lookup_action(tb[TCA_ACT_KIND]);
 	if (a->ops == NULL)
 		goto err_free;
 	if (a->ops->lookup == NULL)
 		goto err_mod;
-	*err = -ENOENT;
+	err = -ENOENT;
 	if (a->ops->lookup(a, index) == 0)
 		goto err_mod;
 
 	module_put(a->ops->owner);
-	*err = 0;
 	return a;
+
 err_mod:
 	module_put(a->ops->owner);
 err_free:
 	kfree(a);
-	return NULL;
+err_out:
+	return ERR_PTR(err);
 }
 
 static void cleanup_a(struct tc_action *act)
@@ -816,9 +817,11 @@ tca_action_gd(struct nlattr *nla, struct nlmsghdr *n, u32 pid, int event)
 	}
 
 	for (i = 1; i <= TCA_ACT_MAX_PRIO && tb[i]; i++) {
-		act = tcf_action_get_1(tb[i], n, pid, &ret);
-		if (act == NULL)
+		act = tcf_action_get_1(tb[i], n, pid);
+		if (IS_ERR(act)) {
+			ret = PTR_ERR(act);
 			goto err;
+		}
 		act->order = i;
 
 		if (head == NULL)
@@ -912,9 +915,13 @@ tcf_action_add(struct nlattr *nla, struct nlmsghdr *n, u32 pid, int ovr)
 	struct tc_action *a;
 	u32 seq = n->nlmsg_seq;
 
-	act = tcf_action_init(nla, NULL, NULL, ovr, 0, &ret);
+	act = tcf_action_init(nla, NULL, NULL, ovr, 0);
 	if (act == NULL)
 		goto done;
+	if (IS_ERR(act)) {
+		ret = PTR_ERR(act);
+		goto done;
+	}
 
 	/* dump then free all the actions after update; inserted policy
 	 * stays intact
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index d870478..92fa155 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -23,6 +23,7 @@
 #include <linux/init.h>
 #include <linux/kmod.h>
 #include <linux/netlink.h>
+#include <linux/err.h>
 #include <net/net_namespace.h>
 #include <net/sock.h>
 #include <net/netlink.h>
@@ -487,23 +488,22 @@ int tcf_exts_validate(struct tcf_proto *tp, struct nlattr **tb,
 
 #ifdef CONFIG_NET_CLS_ACT
 	{
-		int err;
 		struct tc_action *act;
 
 		if (map->police && tb[map->police]) {
 			act = tcf_action_init_1(tb[map->police], rate_tlv,
 						"police", TCA_ACT_NOREPLACE,
-						TCA_ACT_BIND, &err);
-			if (act == NULL)
-				return err;
+						TCA_ACT_BIND);
+			if (IS_ERR(act))
+				return PTR_ERR(act);
 
 			act->type = TCA_OLD_COMPAT;
 			exts->action = act;
 		} else if (map->action && tb[map->action]) {
 			act = tcf_action_init(tb[map->action], rate_tlv, NULL,
-				TCA_ACT_NOREPLACE, TCA_ACT_BIND, &err);
-			if (act == NULL)
-				return err;
+					      TCA_ACT_NOREPLACE, TCA_ACT_BIND);
+			if (IS_ERR(act))
+				return PTR_ERR(act);
 
 			exts->action = act;
 		}
