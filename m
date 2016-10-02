From: Krister Johansen <kjlx@templeofstupid.com>
Subject: [PATCH net] Panic when tc_lookup_action_n finds a partially
 initialized action.
Date: Sat, 1 Oct 2016 20:13:49 -0700
Message-ID: <20161002031349.GB2635@templeofstupid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:55817 "EHLO
        hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752041AbcJBDOA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2016 23:14:00 -0400
Received: from homiemail-a79.g.dreamhost.com (sub5.mail.dreamhost.com [208.113.200.129])
        by hapkido.dreamhost.com (Postfix) with ESMTP id 75A43E8FB5
        for <netdev@vger.kernel.org>; Sat,  1 Oct 2016 20:13:59 -0700 (PDT)
Received: from homiemail-a79.g.dreamhost.com (localhost [127.0.0.1])
        by homiemail-a79.g.dreamhost.com (Postfix) with ESMTP id 782AF600275C
        for <netdev@vger.kernel.org>; Sat,  1 Oct 2016 20:13:57 -0700 (PDT)
Received: from kmjvbox (unknown [198.134.93.254])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: kjlx@templeofstupid.com)
        by homiemail-a79.g.dreamhost.com (Postfix) with ESMTPSA id 84BF3600274D
        for <netdev@vger.kernel.org>; Sat,  1 Oct 2016 20:13:56 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A tc_action_ops structure is visibile as soon as it is placed in the
act_base list.  When tcf_regsiter_action adds an item to this list and
drops act_mod_lock, registration is not complete until
register_pernet_subsys() finishes.

If two threads attempt to modify a tc action in a way that triggers a
module load, the thread that wins the race ends up defeferencing a NULL
pointer after tcf_action_init_1() invokes a_o->init().  In the
particular case that this submitter encountered, the panic occurred in
tcf_gact_init() when net_generic() returned a NULL tc_action_net
pointer.  The gact_net_id needed to fetch the correct pointer was not
yet set, because the register_pernet_subsys() call was pending in
another thread.

Fixes: ddf97ccdd7cb ("net_sched: add network namespace support for tc actions")
Signed-off-by: Krister Johansen <kjlx@templeofstupid.com>
---
 include/net/act_api.h |  1 +
 net/sched/act_api.c   | 64 ++++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 57 insertions(+), 8 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 82f3c91..9ede72d 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -107,6 +107,7 @@ struct tc_action_ops {
 	struct list_head head;
 	char    kind[IFNAMSIZ];
 	__u32   type; /* TBD to match kind */
+	__u32   pernet_pending;
 	size_t	size;
 	struct module		*owner;
 	int     (*act)(struct sk_buff *, const struct tc_action *,
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index d09d068..3b51808 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -331,6 +331,7 @@ EXPORT_SYMBOL(tcf_hashinfo_destroy);
 
 static LIST_HEAD(act_base);
 static DEFINE_RWLOCK(act_mod_lock);
+static DECLARE_WAIT_QUEUE_HEAD(act_mod_wait);
 
 int tcf_register_action(struct tc_action_ops *act,
 			struct pernet_operations *ops)
@@ -349,15 +350,18 @@ int tcf_register_action(struct tc_action_ops *act,
 		}
 	}
 	list_add_tail(&act->head, &act_base);
+	act->pernet_pending = 1;
 	write_unlock(&act_mod_lock);
 
 	ret = register_pernet_subsys(ops);
-	if (ret) {
-		tcf_unregister_action(act, ops);
-		return ret;
-	}
+	write_lock(&act_mod_lock);
+	if (ret)
+		list_del(&act->head);
+	act->pernet_pending = 0;
+	write_unlock(&act_mod_lock);
+	wake_up_all(&act_mod_wait);
 
-	return 0;
+	return ret;
 }
 EXPORT_SYMBOL(tcf_register_action);
 
@@ -367,8 +371,6 @@ int tcf_unregister_action(struct tc_action_ops *act,
 	struct tc_action_ops *a;
 	int err = -ENOENT;
 
-	unregister_pernet_subsys(ops);
-
 	write_lock(&act_mod_lock);
 	list_for_each_entry(a, &act_base, head) {
 		if (a == act) {
@@ -378,10 +380,49 @@ int tcf_unregister_action(struct tc_action_ops *act,
 		}
 	}
 	write_unlock(&act_mod_lock);
+
+	if (!err)
+		unregister_pernet_subsys(ops);
+
 	return err;
 }
 EXPORT_SYMBOL(tcf_unregister_action);
 
+static int tcf_module_needed(char *kind)
+{
+	struct tc_action_ops *a;
+	int rc = 0;
+	DEFINE_WAIT_FUNC(wait, woken_wake_function);
+
+	if (!kind)
+		return rc;
+
+	add_wait_queue(&act_mod_wait, &wait);
+	read_lock(&act_mod_lock);
+	for (;;) {
+		list_for_each_entry(a, &act_base, head) {
+			if (strcmp(kind, a->kind) == 0)
+				break;
+		}
+
+		if (!a || strcmp(kind, a->kind) != 0) {
+			rc = 1;
+			break;
+		}
+
+		if  (a->pernet_pending == 0 || signal_pending(current))
+			break;
+
+		read_unlock(&act_mod_lock);
+		wait_woken(&wait, TASK_INTERRUPTIBLE, MAX_SCHEDULE_TIMEOUT);
+		read_lock(&act_mod_lock);
+	}
+	read_unlock(&act_mod_lock);
+	remove_wait_queue(&act_mod_wait, &wait);
+
+	return rc;
+}
+
 /* lookup by name */
 static struct tc_action_ops *tc_lookup_action_n(char *kind)
 {
@@ -391,11 +432,14 @@ static struct tc_action_ops *tc_lookup_action_n(char *kind)
 		read_lock(&act_mod_lock);
 		list_for_each_entry(a, &act_base, head) {
 			if (strcmp(kind, a->kind) == 0) {
+				if (a->pernet_pending != 0)
+					goto out;
 				if (try_module_get(a->owner))
 					res = a;
 				break;
 			}
 		}
+out:
 		read_unlock(&act_mod_lock);
 	}
 	return res;
@@ -410,11 +454,14 @@ static struct tc_action_ops *tc_lookup_action(struct nlattr *kind)
 		read_lock(&act_mod_lock);
 		list_for_each_entry(a, &act_base, head) {
 			if (nla_strcmp(kind, a->kind) == 0) {
+				if (a->pernet_pending != 0)
+					goto out;
 				if (try_module_get(a->owner))
 					res = a;
 				break;
 			}
 		}
+out:
 		read_unlock(&act_mod_lock);
 	}
 	return res;
@@ -549,7 +596,8 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
 	if (a_o == NULL) {
 #ifdef CONFIG_MODULES
 		rtnl_unlock();
-		request_module("act_%s", act_name);
+		if (tcf_module_needed(act_name))
+			request_module("act_%s", act_name);
 		rtnl_lock();
 
 		a_o = tc_lookup_action_n(act_name);
-- 
2.7.4
