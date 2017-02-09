From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/6] sched: push TC filter protocol creation into a separate function
Date: Thu,  9 Feb 2017 14:38:57 +0100
Message-ID: <1486647540-14656-4-git-send-email-jiri@resnulli.us>
References: <1486647540-14656-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36148 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752215AbdBIOGY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:06:24 -0500
Received: by mail-wm0-f66.google.com with SMTP id r18so3038562wmd.3
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 06:05:45 -0800 (PST)
In-Reply-To: <1486647540-14656-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Make the long function tc_ctl_tfilter a little bit shorter and easier to
read. Also make the creation of filter proto symmetric to destruction.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_api.c | 110 ++++++++++++++++++++++++++++------------------------
 1 file changed, 59 insertions(+), 51 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 4efa4df..d378a0b 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -19,6 +19,7 @@
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/errno.h>
+#include <linux/err.h>
 #include <linux/skbuff.h>
 #include <linux/init.h>
 #include <linux/kmod.h>
@@ -38,14 +39,14 @@ static DEFINE_RWLOCK(cls_mod_lock);
 
 /* Find classifier type by string name */
 
-static const struct tcf_proto_ops *tcf_proto_lookup_ops(struct nlattr *kind)
+static const struct tcf_proto_ops *tcf_proto_lookup_ops(const char *kind)
 {
 	const struct tcf_proto_ops *t, *res = NULL;
 
 	if (kind) {
 		read_lock(&cls_mod_lock);
 		list_for_each_entry(t, &tcf_proto_base, head) {
-			if (nla_strcmp(kind, t->kind) == 0) {
+			if (strcmp(kind, t->kind) == 0) {
 				if (try_module_get(t->owner))
 					res = t;
 				break;
@@ -127,6 +128,56 @@ static inline u32 tcf_auto_prio(struct tcf_proto *tp)
 	return first;
 }
 
+static struct tcf_proto *tcf_proto_create(const char *kind, u32 protocol,
+					  u32 prio, u32 parent, struct Qdisc *q)
+{
+	struct tcf_proto *tp;
+	int err;
+
+	tp = kzalloc(sizeof(*tp), GFP_KERNEL);
+	if (!tp)
+		return ERR_PTR(-ENOBUFS);
+
+	err = -ENOENT;
+	tp->ops = tcf_proto_lookup_ops(kind);
+	if (!tp->ops) {
+#ifdef CONFIG_MODULES
+		rtnl_unlock();
+		request_module("cls_%s", kind);
+		rtnl_lock();
+		tp->ops = tcf_proto_lookup_ops(kind);
+		/* We dropped the RTNL semaphore in order to perform
+		 * the module load. So, even if we succeeded in loading
+		 * the module we have to replay the request. We indicate
+		 * this using -EAGAIN.
+		 */
+		if (tp->ops) {
+			module_put(tp->ops->owner);
+			err = -EAGAIN;
+		} else {
+			err = -ENOENT;
+		}
+		goto errout;
+#endif
+	}
+	tp->classify = tp->ops->classify;
+	tp->protocol = protocol;
+	tp->prio = prio;
+	tp->classid = parent;
+	tp->q = q;
+
+	err = tp->ops->init(tp);
+	if (err) {
+		module_put(tp->ops->owner);
+		goto errout;
+	}
+	return tp;
+
+errout:
+	kfree(tp);
+	return ERR_PTR(err);
+}
+
 static bool tcf_proto_destroy(struct tcf_proto *tp, bool force)
 {
 	if (tp->ops->destroy(tp, force)) {
@@ -164,7 +215,6 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 	struct tcf_proto __rcu **back;
 	struct tcf_proto __rcu **chain;
 	struct tcf_proto *tp;
-	const struct tcf_proto_ops *tp_ops;
 	const struct Qdisc_class_ops *cops;
 	unsigned long cl;
 	unsigned long fh;
@@ -279,58 +329,16 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 		    !(n->nlmsg_flags & NLM_F_CREATE))
 			goto errout;
 
+		if (!nprio)
+			nprio = TC_H_MAJ(tcf_auto_prio(rtnl_dereference(*back)));
 
-		/* Create new proto tcf */
-
-		err = -ENOBUFS;
-		tp = kzalloc(sizeof(*tp), GFP_KERNEL);
-		if (tp == NULL)
-			goto errout;
-		err = -ENOENT;
-		tp_ops = tcf_proto_lookup_ops(tca[TCA_KIND]);
-		if (tp_ops == NULL) {
-#ifdef CONFIG_MODULES
-			struct nlattr *kind = tca[TCA_KIND];
-			char name[IFNAMSIZ];
-
-			if (kind != NULL &&
-			    nla_strlcpy(name, kind, IFNAMSIZ) < IFNAMSIZ) {
-				rtnl_unlock();
-				request_module("cls_%s", name);
-				rtnl_lock();
-				tp_ops = tcf_proto_lookup_ops(kind);
-				/* We dropped the RTNL semaphore in order to
-				 * perform the module load.  So, even if we
-				 * succeeded in loading the module we have to
-				 * replay the request.  We indicate this using
-				 * -EAGAIN.
-				 */
-				if (tp_ops != NULL) {
-					module_put(tp_ops->owner);
-					err = -EAGAIN;
-				}
-			}
-#endif
-			kfree(tp);
+		tp = tcf_proto_create(nla_data(tca[TCA_KIND]),
+				      protocol, nprio, parent, q);
+		if (IS_ERR(tp)) {
+			err = PTR_ERR(tp);
 			goto errout;
 		}
-		tp->ops = tp_ops;
-		tp->protocol = protocol;
-		tp->prio = nprio ? :
-			       TC_H_MAJ(tcf_auto_prio(rtnl_dereference(*back)));
-		tp->q = q;
-		tp->classify = tp_ops->classify;
-		tp->classid = parent;
-
-		err = tp_ops->init(tp);
-		if (err != 0) {
-			module_put(tp_ops->owner);
-			kfree(tp);
-			goto errout;
-		}
-
 		tp_created = 1;
-
 	} else if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], tp->ops->kind))
 		goto errout;
 
-- 
2.7.4
