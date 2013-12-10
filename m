From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next] net_sched: add messages to distinguish errors when modify qdisc
Date: Tue, 10 Dec 2013 16:49:00 +0800
Message-ID: <1386665340-16820-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:16089 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123Ab3LJItS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 03:49:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When tc_modify_qdisc return EINVAL, user cannot distinguish
errors easliy. Add some messages to make it easier.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_api.c | 25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index cd81505..6b0e53c 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -995,8 +995,11 @@ static int qdisc_change(struct Qdisc *sch, struct nlattr **tca)
 	int err = 0;
 
 	if (tca[TCA_OPTIONS]) {
-		if (sch->ops->change == NULL)
+		if (sch->ops->change == NULL) {
+			pr_err_ratelimited("Can't change %s qdisc parameters.\n",
+					   sch->ops->id);
 			return -EINVAL;
+		}
 		err = sch->ops->change(sch, tca[TCA_OPTIONS]);
 		if (err)
 			return err;
@@ -1186,15 +1189,20 @@ replay:
 			if (tcm->tcm_handle) {
 				if (q && !(n->nlmsg_flags & NLM_F_REPLACE))
 					return -EEXIST;
-				if (TC_H_MIN(tcm->tcm_handle))
+				if (TC_H_MIN(tcm->tcm_handle)) {
+					pr_err_ratelimited("Wrong minor handle, it must be 0.\n");
 					return -EINVAL;
+				}
 				q = qdisc_lookup(dev, tcm->tcm_handle);
 				if (!q)
 					goto create_n_graft;
 				if (n->nlmsg_flags & NLM_F_EXCL)
 					return -EEXIST;
-				if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], q->ops->id))
+				if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], q->ops->id)) {
+					pr_err_ratelimited("A different qdisc(%s) with handle %d: already exists.\n",
+							   q->ops->id, TC_H_MAJ(tcm->tcm_handle) >> 16);
 					return -EINVAL;
+				}
 				if (q == p ||
 				    (p && check_loop(q, p, 0)))
 					return -ELOOP;
@@ -1232,8 +1240,10 @@ replay:
 			}
 		}
 	} else {
-		if (!tcm->tcm_handle)
+		if (!tcm->tcm_handle) {
+			pr_err_ratelimited("Wrong handle, it can't be 0.\n");
 			return -EINVAL;
+		}
 		q = qdisc_lookup(dev, tcm->tcm_handle);
 	}
 
@@ -1242,8 +1252,13 @@ replay:
 		return -ENOENT;
 	if (n->nlmsg_flags & NLM_F_EXCL)
 		return -EEXIST;
-	if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], q->ops->id))
+	if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], q->ops->id)) {
+		char name[IFNAMSIZ];
+		nla_strlcpy(name, tca[TCA_KIND], IFNAMSIZ);
+		pr_err_ratelimited("A %s qdisc already exists, can't change its parameters to %s's.\n",
+				   q->ops->id, name);
 		return -EINVAL;
+	}
 	err = qdisc_change(q, tca);
 	if (err == 0)
 		qdisc_notify(net, skb, n, clid, NULL, q);
-- 
1.8.0
