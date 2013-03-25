From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH net-next] netlink: add missing length check of rtnl msg
Date: Tue, 26 Mar 2013 01:22:23 +0800
Message-ID: <1364232143-16754-1-git-send-email-honkiko@gmail.com>
Cc: davem@davemloft.net, stephen@networkplumber.org, tgraf@suug.ch,
	Hong Zhiguo <honkiko@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f48.google.com ([209.85.210.48]:62594 "EHLO
	mail-da0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758012Ab3CYRWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 13:22:42 -0400
Received: by mail-da0-f48.google.com with SMTP id p8so3273498dan.21
        for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 10:22:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the legacy array rtm_min still exists, the length check within these 
functions is covered by rtm_min[RTM_NEWTFILTER], rtm_min[RTM_NEWQDISC] 
and rtm_min[RTM_NEWTCLASS].

But after Thomas Graf removed rtm_min several days ago, these checks are 
missing. 

Other doit functions should be OK.

Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
---
 net/sched/cls_api.c |    4 ++++
 net/sched/sch_api.c |   22 ++++++++++++++++++----
 2 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 9a04b98..01bfa9c 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -141,6 +141,10 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 
 	if ((n->nlmsg_type != RTM_GETTFILTER) && !capable(CAP_NET_ADMIN))
 		return -EPERM;
+
+	if (nlmsg_len(n) < sizeof(*t))
+		return -EINVAL;
+
 replay:
 	t = nlmsg_data(n);
 	protocol = TC_H_MIN(t->tcm_info);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 0bbce22..b30a988 100644
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
@@ -985,6 +985,9 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n)
 	if ((n->nlmsg_type != RTM_GETQDISC) && !capable(CAP_NET_ADMIN))
 		return -EPERM;
 
+	if (nlmsg_len(n) < sizeof(*tcm))
+		return -EINVAL;
+
 	dev = __dev_get_by_index(net, tcm->tcm_ifindex);
 	if (!dev)
 		return -ENODEV;
@@ -993,6 +996,7 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n)
 	if (err < 0)
 		return err;
 
+	clid = tcm->tcm_parent;
 	if (clid) {
 		if (clid != TC_H_ROOT) {
 			if (TC_H_MAJ(clid) != TC_H_MAJ(TC_H_INGRESS)) {
@@ -1051,6 +1055,9 @@ static int tc_modify_qdisc(struct sk_buff *skb, struct nlmsghdr *n)
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
+	if (nlmsg_len(n) < sizeof(*tcm))
+		return -EINVAL;
+
 replay:
 	/* Reinit, just in case something touches this. */
 	tcm = nlmsg_data(n);
@@ -1382,14 +1389,17 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n)
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
 
+	if (nlmsg_len(n) < sizeof(*tcm))
+		return -EINVAL;
+
 	dev = __dev_get_by_index(net, tcm->tcm_ifindex);
 	if (!dev)
 		return -ENODEV;
@@ -1413,6 +1423,10 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n)
 
 	/* Step 1. Determine qdisc handle X:0 */
 
+	portid = tcm->tcm_parent;
+	clid = tcm->tcm_handle;
+	qid = TC_H_MAJ(clid);
+
 	if (portid != TC_H_ROOT) {
 		u32 qid1 = TC_H_MAJ(portid);
 
-- 
1.7.10.4
