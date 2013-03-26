From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH v2 net-next] netlink: have length check of rtnl msg before deref
Date: Tue, 26 Mar 2013 11:36:33 +0800
Message-ID: <1364268993-19947-1-git-send-email-honkiko@gmail.com>
References: <1364232143-16754-1-git-send-email-honkiko@gmail.com>
Cc: davem@davemloft.net, stephen@networkplumber.org, tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:58414 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756255Ab3CZDgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 23:36:50 -0400
Received: by mail-pa0-f42.google.com with SMTP id kq13so741783pab.15
        for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 20:36:49 -0700 (PDT)
In-Reply-To: <1364232143-16754-1-git-send-email-honkiko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the legacy array rtm_min still exists, the length check within
these functions is covered by rtm_min[RTM_NEWTFILTER],
rtm_min[RTM_NEWQDISC] and rtm_min[RTM_NEWTCLASS].

But after Thomas Graf removed rtm_min several days ago, these checks
are missing. Other doit functions should be OK.

Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
---
 net/sched/cls_api.c |    9 +++++----
 net/sched/sch_api.c |   36 +++++++++++++++++++++---------------
 2 files changed, 26 insertions(+), 19 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 9a04b98..9d71d4d 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -141,7 +141,12 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 
 	if ((n->nlmsg_type != RTM_GETTFILTER) && !capable(CAP_NET_ADMIN))
 		return -EPERM;
+
 replay:
+	err = nlmsg_parse(n, sizeof(*t), tca, TCA_MAX, NULL);
+	if (err < 0)
+		return err;
+
 	t = nlmsg_data(n);
 	protocol = TC_H_MIN(t->tcm_info);
 	prio = TC_H_MAJ(t->tcm_info);
@@ -164,10 +169,6 @@ replay:
 	if (dev == NULL)
 		return -ENODEV;
 
-	err = nlmsg_parse(n, sizeof(*t), tca, TCA_MAX, NULL);
-	if (err < 0)
-		return err;
-
 	/* Find qdisc */
 	if (!parent) {
 		q = dev->qdisc;
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 0bbce22..d7468ba 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -977,7 +977,7 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n)
 	struct tcmsg *tcm = nlmsg_data(n);
 	struct nlattr *tca[TCA_MAX + 1];
 	struct net_device *dev;
-	u32 clid = tcm->tcm_parent;
+	u32 clid;
 	struct Qdisc *q = NULL;
 	struct Qdisc *p = NULL;
 	int err;
@@ -985,14 +985,15 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n)
 	if ((n->nlmsg_type != RTM_GETQDISC) && !capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	dev = __dev_get_by_index(net, tcm->tcm_ifindex);
-	if (!dev)
-		return -ENODEV;
-
 	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL);
 	if (err < 0)
 		return err;
 
+	dev = __dev_get_by_index(net, tcm->tcm_ifindex);
+	if (!dev)
+		return -ENODEV;
+
+	clid = tcm->tcm_parent;
 	if (clid) {
 		if (clid != TC_H_ROOT) {
 			if (TC_H_MAJ(clid) != TC_H_MAJ(TC_H_INGRESS)) {
@@ -1053,6 +1054,10 @@ static int tc_modify_qdisc(struct sk_buff *skb, struct nlmsghdr *n)
 
 replay:
 	/* Reinit, just in case something touches this. */
+	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL);
+	if (err < 0)
+		return err;
+
 	tcm = nlmsg_data(n);
 	clid = tcm->tcm_parent;
 	q = p = NULL;
@@ -1061,9 +1066,6 @@ replay:
 	if (!dev)
 		return -ENODEV;
 
-	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL);
-	if (err < 0)
-		return err;
 
 	if (clid) {
 		if (clid != TC_H_ROOT) {
@@ -1382,22 +1384,22 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n)
 	const struct Qdisc_class_ops *cops;
 	unsigned long cl = 0;
 	unsigned long new_cl;
-	u32 portid = tcm->tcm_parent;
-	u32 clid = tcm->tcm_handle;
-	u32 qid = TC_H_MAJ(clid);
+	u32 portid;
+	u32 clid;
+	u32 qid;
 	int err;
 
 	if ((n->nlmsg_type != RTM_GETTCLASS) && !capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	dev = __dev_get_by_index(net, tcm->tcm_ifindex);
-	if (!dev)
-		return -ENODEV;
-
 	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL);
 	if (err < 0)
 		return err;
 
+	dev = __dev_get_by_index(net, tcm->tcm_ifindex);
+	if (!dev)
+		return -ENODEV;
+
 	/*
 	   parent == TC_H_UNSPEC - unspecified parent.
 	   parent == TC_H_ROOT   - class is root, which has no parent.
@@ -1413,6 +1415,10 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n)
 
 	/* Step 1. Determine qdisc handle X:0 */
 
+	portid = tcm->tcm_parent;
+	clid = tcm->tcm_handle;
+	qid = TC_H_MAJ(clid);
+
 	if (portid != TC_H_ROOT) {
 		u32 qid1 = TC_H_MAJ(portid);
 
-- 
1.7.10.4
