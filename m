From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH net-next v4 8/8] net_sched: convert tcf_proto_ops to use struct list_head
Date: Sun, 15 Dec 2013 20:15:11 -0800
Message-ID: <1387167311-14763-9-git-send-email-xiyou.wangcong@gmail.com>
References: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36744 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313Ab3LPEPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 23:15:38 -0500
Received: by mail-pa0-f41.google.com with SMTP id lf10so2404965pab.14
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 20:15:37 -0800 (PST)
In-Reply-To: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't need to maintain our own singly linked list code.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/sch_generic.h |  2 +-
 net/sched/cls_api.c       | 18 ++++++++----------
 2 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index d0a6321..013d96d 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -185,7 +185,7 @@ struct tcf_result {
 };
 
 struct tcf_proto_ops {
-	struct tcf_proto_ops	*next;
+	struct list_head	head;
 	char			kind[IFNAMSIZ];
 
 	int			(*classify)(struct sk_buff *,
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 028c980..6b085cf 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -31,8 +31,7 @@
 #include <net/pkt_cls.h>
 
 /* The list of all installed classifier types */
-
-static struct tcf_proto_ops *tcf_proto_base __read_mostly;
+static LIST_HEAD(tcf_proto_base);
 
 /* Protects list of registered TC modules. It is pure SMP lock. */
 static DEFINE_RWLOCK(cls_mod_lock);
@@ -45,7 +44,7 @@ static const struct tcf_proto_ops *tcf_proto_lookup_ops(struct nlattr *kind)
 
 	if (kind) {
 		read_lock(&cls_mod_lock);
-		for (t = tcf_proto_base; t; t = t->next) {
+		list_for_each_entry(t, &tcf_proto_base, head) {
 			if (nla_strcmp(kind, t->kind) == 0) {
 				if (!try_module_get(t->owner))
 					t = NULL;
@@ -61,16 +60,15 @@ static const struct tcf_proto_ops *tcf_proto_lookup_ops(struct nlattr *kind)
 
 int register_tcf_proto_ops(struct tcf_proto_ops *ops)
 {
-	struct tcf_proto_ops *t, **tp;
+	struct tcf_proto_ops *t;
 	int rc = -EEXIST;
 
 	write_lock(&cls_mod_lock);
-	for (tp = &tcf_proto_base; (t = *tp) != NULL; tp = &t->next)
+	list_for_each_entry(t, &tcf_proto_base, head)
 		if (!strcmp(ops->kind, t->kind))
 			goto out;
 
-	ops->next = NULL;
-	*tp = ops;
+	list_add_tail(&ops->head, &tcf_proto_base);
 	rc = 0;
 out:
 	write_unlock(&cls_mod_lock);
@@ -80,17 +78,17 @@ EXPORT_SYMBOL(register_tcf_proto_ops);
 
 int unregister_tcf_proto_ops(struct tcf_proto_ops *ops)
 {
-	struct tcf_proto_ops *t, **tp;
+	struct tcf_proto_ops *t;
 	int rc = -ENOENT;
 
 	write_lock(&cls_mod_lock);
-	for (tp = &tcf_proto_base; (t = *tp) != NULL; tp = &t->next)
+	list_for_each_entry(t, &tcf_proto_base, head)
 		if (t == ops)
 			break;
 
 	if (!t)
 		goto out;
-	*tp = t->next;
+	list_del(&t->head);
 	rc = 0;
 out:
 	write_unlock(&cls_mod_lock);
-- 
1.8.1.4
