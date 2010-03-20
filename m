From: Tom Goff <thomas.goff@boeing.com>
Subject: [PATCH] net_sched: make traffic control network namespace aware
Date: Fri, 19 Mar 2010 18:40:13 -0700
Message-ID: <20100320014013.GC13239@boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from blv-smtpout-01.boeing.com ([130.76.32.69]:55805 "EHLO
	blv-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751867Ab0CTByh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 21:54:37 -0400
Received: from stl-av-01.boeing.com (stl-av-01.boeing.com [192.76.190.6])
	by blv-smtpout-01.ns.cs.boeing.com (8.14.4/8.14.4/8.14.4/SMTPOUT) with ESMTP id o2K1eFHx017055
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Fri, 19 Mar 2010 18:40:16 -0700 (PDT)
Received: from stl-av-01.boeing.com (localhost [127.0.0.1])
	by stl-av-01.boeing.com (8.14.4/8.14.4/DOWNSTREAM_RELAY) with ESMTP id o2K1eFwH016842
	for <netdev@vger.kernel.org>; Fri, 19 Mar 2010 20:40:15 -0500 (CDT)
Received: from packet.blv.boeing.com (packet.blv.boeing.com [130.42.97.136])
	by stl-av-01.boeing.com (8.14.4/8.14.4/UPSTREAM_RELAY) with SMTP id o2K1eDhl016822
	for <netdev@vger.kernel.org>; Fri, 19 Mar 2010 20:40:13 -0500 (CDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mostly minor changes to add a net argument to various functions and
remove initial network namespace checks.

Make /proc/net/psched per network namespace.

Signed-off-by: Tom Goff <thomas.goff@boeing.com>
---
 net/sched/act_api.c |   45 ++++++++++----------
 net/sched/cls_api.c |   30 ++++++--------
 net/sched/sch_api.c |  112 ++++++++++++++++++++++++++++++++------------------
 3 files changed, 107 insertions(+), 80 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 64f5e32..7a558da 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -667,7 +667,8 @@ nlmsg_failure:
 }
 
 static int
-act_get_notify(u32 pid, struct nlmsghdr *n, struct tc_action *a, int event)
+act_get_notify(struct net *net, u32 pid, struct nlmsghdr *n,
+	       struct tc_action *a, int event)
 {
 	struct sk_buff *skb;
 
@@ -679,7 +680,7 @@ act_get_notify(u32 pid, struct nlmsghdr *n, struct tc_action *a, int event)
 		return -EINVAL;
 	}
 
-	return rtnl_unicast(skb, &init_net, pid);
+	return rtnl_unicast(skb, net, pid);
 }
 
 static struct tc_action *
@@ -749,7 +750,8 @@ static struct tc_action *create_a(int i)
 	return act;
 }
 
-static int tca_action_flush(struct nlattr *nla, struct nlmsghdr *n, u32 pid)
+static int tca_action_flush(struct net *net, struct nlattr *nla,
+			    struct nlmsghdr *n, u32 pid)
 {
 	struct sk_buff *skb;
 	unsigned char *b;
@@ -808,7 +810,7 @@ static int tca_action_flush(struct nlattr *nla, struct nlmsghdr *n, u32 pid)
 	nlh->nlmsg_flags |= NLM_F_ROOT;
 	module_put(a->ops->owner);
 	kfree(a);
-	err = rtnetlink_send(skb, &init_net, pid, RTNLGRP_TC, n->nlmsg_flags&NLM_F_ECHO);
+	err = rtnetlink_send(skb, net, pid, RTNLGRP_TC, n->nlmsg_flags&NLM_F_ECHO);
 	if (err > 0)
 		return 0;
 
@@ -825,7 +827,8 @@ noflush_out:
 }
 
 static int
-tca_action_gd(struct nlattr *nla, struct nlmsghdr *n, u32 pid, int event)
+tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
+	      u32 pid, int event)
 {
 	int i, ret;
 	struct nlattr *tb[TCA_ACT_MAX_PRIO+1];
@@ -837,7 +840,7 @@ tca_action_gd(struct nlattr *nla, struct nlmsghdr *n, u32 pid, int event)
 
 	if (event == RTM_DELACTION && n->nlmsg_flags&NLM_F_ROOT) {
 		if (tb[1] != NULL)
-			return tca_action_flush(tb[1], n, pid);
+			return tca_action_flush(net, tb[1], n, pid);
 		else
 			return -EINVAL;
 	}
@@ -858,7 +861,7 @@ tca_action_gd(struct nlattr *nla, struct nlmsghdr *n, u32 pid, int event)
 	}
 
 	if (event == RTM_GETACTION)
-		ret = act_get_notify(pid, n, head, event);
+		ret = act_get_notify(net, pid, n, head, event);
 	else { /* delete */
 		struct sk_buff *skb;
 
@@ -877,7 +880,7 @@ tca_action_gd(struct nlattr *nla, struct nlmsghdr *n, u32 pid, int event)
 
 		/* now do the delete */
 		tcf_action_destroy(head, 0);
-		ret = rtnetlink_send(skb, &init_net, pid, RTNLGRP_TC,
+		ret = rtnetlink_send(skb, net, pid, RTNLGRP_TC,
 				     n->nlmsg_flags&NLM_F_ECHO);
 		if (ret > 0)
 			return 0;
@@ -888,8 +891,8 @@ err:
 	return ret;
 }
 
-static int tcf_add_notify(struct tc_action *a, u32 pid, u32 seq, int event,
-			  u16 flags)
+static int tcf_add_notify(struct net *net, struct tc_action *a,
+			  u32 pid, u32 seq, int event, u16 flags)
 {
 	struct tcamsg *t;
 	struct nlmsghdr *nlh;
@@ -922,7 +925,7 @@ static int tcf_add_notify(struct tc_action *a, u32 pid, u32 seq, int event,
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	NETLINK_CB(skb).dst_group = RTNLGRP_TC;
 
-	err = rtnetlink_send(skb, &init_net, pid, RTNLGRP_TC, flags&NLM_F_ECHO);
+	err = rtnetlink_send(skb, net, pid, RTNLGRP_TC, flags&NLM_F_ECHO);
 	if (err > 0)
 		err = 0;
 	return err;
@@ -935,7 +938,8 @@ nlmsg_failure:
 
 
 static int
-tcf_action_add(struct nlattr *nla, struct nlmsghdr *n, u32 pid, int ovr)
+tcf_action_add(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
+	       u32 pid, int ovr)
 {
 	int ret = 0;
 	struct tc_action *act;
@@ -953,7 +957,7 @@ tcf_action_add(struct nlattr *nla, struct nlmsghdr *n, u32 pid, int ovr)
 	/* dump then free all the actions after update; inserted policy
 	 * stays intact
 	 * */
-	ret = tcf_add_notify(act, pid, seq, RTM_NEWACTION, n->nlmsg_flags);
+	ret = tcf_add_notify(net, act, pid, seq, RTM_NEWACTION, n->nlmsg_flags);
 	for (a = act; a; a = act) {
 		act = a->next;
 		kfree(a);
@@ -969,9 +973,6 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	u32 pid = skb ? NETLINK_CB(skb).pid : 0;
 	int ret = 0, ovr = 0;
 
-	if (!net_eq(net, &init_net))
-		return -EINVAL;
-
 	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCA_ACT_MAX, NULL);
 	if (ret < 0)
 		return ret;
@@ -994,15 +995,17 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 		if (n->nlmsg_flags&NLM_F_REPLACE)
 			ovr = 1;
 replay:
-		ret = tcf_action_add(tca[TCA_ACT_TAB], n, pid, ovr);
+		ret = tcf_action_add(net, tca[TCA_ACT_TAB], n, pid, ovr);
 		if (ret == -EAGAIN)
 			goto replay;
 		break;
 	case RTM_DELACTION:
-		ret = tca_action_gd(tca[TCA_ACT_TAB], n, pid, RTM_DELACTION);
+		ret = tca_action_gd(net, tca[TCA_ACT_TAB], n,
+				    pid, RTM_DELACTION);
 		break;
 	case RTM_GETACTION:
-		ret = tca_action_gd(tca[TCA_ACT_TAB], n, pid, RTM_GETACTION);
+		ret = tca_action_gd(net, tca[TCA_ACT_TAB], n,
+				    pid, RTM_GETACTION);
 		break;
 	default:
 		BUG();
@@ -1042,7 +1045,6 @@ find_dump_kind(const struct nlmsghdr *n)
 static int
 tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = sock_net(skb->sk);
 	struct nlmsghdr *nlh;
 	unsigned char *b = skb_tail_pointer(skb);
 	struct nlattr *nest;
@@ -1052,9 +1054,6 @@ tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	struct tcamsg *t = (struct tcamsg *) NLMSG_DATA(cb->nlh);
 	struct nlattr *kind = find_dump_kind(cb->nlh);
 
-	if (!net_eq(net, &init_net))
-		return 0;
-
 	if (kind == NULL) {
 		printk("tc_dump_action: action bad kind\n");
 		return 0;
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 3725d8f..4a795d9 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -98,8 +98,9 @@ out:
 }
 EXPORT_SYMBOL(unregister_tcf_proto_ops);
 
-static int tfilter_notify(struct sk_buff *oskb, struct nlmsghdr *n,
-			  struct tcf_proto *tp, unsigned long fh, int event);
+static int tfilter_notify(struct net *net, struct sk_buff *oskb,
+			  struct nlmsghdr *n, struct tcf_proto *tp,
+			  unsigned long fh, int event);
 
 
 /* Select new prio value from the range, managed by kernel. */
@@ -137,9 +138,6 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	int err;
 	int tp_created = 0;
 
-	if (!net_eq(net, &init_net))
-		return -EINVAL;
-
 replay:
 	t = NLMSG_DATA(n);
 	protocol = TC_H_MIN(t->tcm_info);
@@ -158,7 +156,7 @@ replay:
 	/* Find head of filter chain. */
 
 	/* Find link */
-	dev = __dev_get_by_index(&init_net, t->tcm_ifindex);
+	dev = __dev_get_by_index(net, t->tcm_ifindex);
 	if (dev == NULL)
 		return -ENODEV;
 
@@ -282,7 +280,7 @@ replay:
 			*back = tp->next;
 			spin_unlock_bh(root_lock);
 
-			tfilter_notify(skb, n, tp, fh, RTM_DELTFILTER);
+			tfilter_notify(net, skb, n, tp, fh, RTM_DELTFILTER);
 			tcf_destroy(tp);
 			err = 0;
 			goto errout;
@@ -305,10 +303,10 @@ replay:
 		case RTM_DELTFILTER:
 			err = tp->ops->delete(tp, fh);
 			if (err == 0)
-				tfilter_notify(skb, n, tp, fh, RTM_DELTFILTER);
+				tfilter_notify(net, skb, n, tp, fh, RTM_DELTFILTER);
 			goto errout;
 		case RTM_GETTFILTER:
-			err = tfilter_notify(skb, n, tp, fh, RTM_NEWTFILTER);
+			err = tfilter_notify(net, skb, n, tp, fh, RTM_NEWTFILTER);
 			goto errout;
 		default:
 			err = -EINVAL;
@@ -324,7 +322,7 @@ replay:
 			*back = tp;
 			spin_unlock_bh(root_lock);
 		}
-		tfilter_notify(skb, n, tp, fh, RTM_NEWTFILTER);
+		tfilter_notify(net, skb, n, tp, fh, RTM_NEWTFILTER);
 	} else {
 		if (tp_created)
 			tcf_destroy(tp);
@@ -370,8 +368,9 @@ nla_put_failure:
 	return -1;
 }
 
-static int tfilter_notify(struct sk_buff *oskb, struct nlmsghdr *n,
-			  struct tcf_proto *tp, unsigned long fh, int event)
+static int tfilter_notify(struct net *net, struct sk_buff *oskb,
+			  struct nlmsghdr *n, struct tcf_proto *tp,
+			  unsigned long fh, int event)
 {
 	struct sk_buff *skb;
 	u32 pid = oskb ? NETLINK_CB(oskb).pid : 0;
@@ -385,7 +384,7 @@ static int tfilter_notify(struct sk_buff *oskb, struct nlmsghdr *n,
 		return -EINVAL;
 	}
 
-	return rtnetlink_send(skb, &init_net, pid, RTNLGRP_TC,
+	return rtnetlink_send(skb, net, pid, RTNLGRP_TC,
 			      n->nlmsg_flags & NLM_F_ECHO);
 }
 
@@ -418,12 +417,9 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	const struct Qdisc_class_ops *cops;
 	struct tcf_dump_args arg;
 
-	if (!net_eq(net, &init_net))
-		return 0;
-
 	if (cb->nlh->nlmsg_len < NLMSG_LENGTH(sizeof(*tcm)))
 		return skb->len;
-	if ((dev = __dev_get_by_index(&init_net, tcm->tcm_ifindex)) == NULL)
+	if ((dev = __dev_get_by_index(net, tcm->tcm_ifindex)) == NULL)
 		return skb->len;
 
 	if (!tcm->tcm_parent)
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 6cd4910..6d6fe16 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -34,10 +34,12 @@
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
 
-static int qdisc_notify(struct sk_buff *oskb, struct nlmsghdr *n, u32 clid,
+static int qdisc_notify(struct net *net, struct sk_buff *oskb,
+			struct nlmsghdr *n, u32 clid,
 			struct Qdisc *old, struct Qdisc *new);
-static int tclass_notify(struct sk_buff *oskb, struct nlmsghdr *n,
-			 struct Qdisc *q, unsigned long cl, int event);
+static int tclass_notify(struct net *net, struct sk_buff *oskb,
+			 struct nlmsghdr *n, struct Qdisc *q,
+			 unsigned long cl, int event);
 
 /*
 
@@ -638,11 +640,12 @@ void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
 }
 EXPORT_SYMBOL(qdisc_tree_decrease_qlen);
 
-static void notify_and_destroy(struct sk_buff *skb, struct nlmsghdr *n, u32 clid,
+static void notify_and_destroy(struct net *net, struct sk_buff *skb,
+			       struct nlmsghdr *n, u32 clid,
 			       struct Qdisc *old, struct Qdisc *new)
 {
 	if (new || old)
-		qdisc_notify(skb, n, clid, old, new);
+		qdisc_notify(net, skb, n, clid, old, new);
 
 	if (old)
 		qdisc_destroy(old);
@@ -662,6 +665,7 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
 		       struct Qdisc *new, struct Qdisc *old)
 {
 	struct Qdisc *q = old;
+	struct net *net = dev_net(dev);
 	int err = 0;
 
 	if (parent == NULL) {
@@ -698,12 +702,13 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
 		}
 
 		if (!ingress) {
-			notify_and_destroy(skb, n, classid, dev->qdisc, new);
+			notify_and_destroy(net, skb, n, classid,
+					   dev->qdisc, new);
 			if (new && !new->ops->attach)
 				atomic_inc(&new->refcnt);
 			dev->qdisc = new ? : &noop_qdisc;
 		} else {
-			notify_and_destroy(skb, n, classid, old, new);
+			notify_and_destroy(net, skb, n, classid, old, new);
 		}
 
 		if (dev->flags & IFF_UP)
@@ -721,7 +726,7 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
 				err = -ENOENT;
 		}
 		if (!err)
-			notify_and_destroy(skb, n, classid, old, new);
+			notify_and_destroy(net, skb, n, classid, old, new);
 	}
 	return err;
 }
@@ -947,10 +952,7 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	struct Qdisc *p = NULL;
 	int err;
 
-	if (!net_eq(net, &init_net))
-		return -EINVAL;
-
-	if ((dev = __dev_get_by_index(&init_net, tcm->tcm_ifindex)) == NULL)
+	if ((dev = __dev_get_by_index(net, tcm->tcm_ifindex)) == NULL)
 		return -ENODEV;
 
 	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL);
@@ -990,7 +992,7 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 		if ((err = qdisc_graft(dev, p, skb, n, clid, NULL, q)) != 0)
 			return err;
 	} else {
-		qdisc_notify(skb, n, clid, NULL, q);
+		qdisc_notify(net, skb, n, clid, NULL, q);
 	}
 	return 0;
 }
@@ -1009,16 +1011,13 @@ static int tc_modify_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	struct Qdisc *q, *p;
 	int err;
 
-	if (!net_eq(net, &init_net))
-		return -EINVAL;
-
 replay:
 	/* Reinit, just in case something touches this. */
 	tcm = NLMSG_DATA(n);
 	clid = tcm->tcm_parent;
 	q = p = NULL;
 
-	if ((dev = __dev_get_by_index(&init_net, tcm->tcm_ifindex)) == NULL)
+	if ((dev = __dev_get_by_index(net, tcm->tcm_ifindex)) == NULL)
 		return -ENODEV;
 
 	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL);
@@ -1105,7 +1104,7 @@ replay:
 		return -EINVAL;
 	err = qdisc_change(q, tca);
 	if (err == 0)
-		qdisc_notify(skb, n, clid, NULL, q);
+		qdisc_notify(net, skb, n, clid, NULL, q);
 	return err;
 
 create_n_graft:
@@ -1195,8 +1194,9 @@ nla_put_failure:
 	return -1;
 }
 
-static int qdisc_notify(struct sk_buff *oskb, struct nlmsghdr *n,
-			u32 clid, struct Qdisc *old, struct Qdisc *new)
+static int qdisc_notify(struct net *net, struct sk_buff *oskb,
+			struct nlmsghdr *n, u32 clid,
+			struct Qdisc *old, struct Qdisc *new)
 {
 	struct sk_buff *skb;
 	u32 pid = oskb ? NETLINK_CB(oskb).pid : 0;
@@ -1215,7 +1215,7 @@ static int qdisc_notify(struct sk_buff *oskb, struct nlmsghdr *n,
 	}
 
 	if (skb->len)
-		return rtnetlink_send(skb, &init_net, pid, RTNLGRP_TC, n->nlmsg_flags&NLM_F_ECHO);
+		return rtnetlink_send(skb, net, pid, RTNLGRP_TC, n->nlmsg_flags&NLM_F_ECHO);
 
 err_out:
 	kfree_skb(skb);
@@ -1274,15 +1274,12 @@ static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
 	int s_idx, s_q_idx;
 	struct net_device *dev;
 
-	if (!net_eq(net, &init_net))
-		return 0;
-
 	s_idx = cb->args[0];
 	s_q_idx = q_idx = cb->args[1];
 
 	rcu_read_lock();
 	idx = 0;
-	for_each_netdev_rcu(&init_net, dev) {
+	for_each_netdev_rcu(net, dev) {
 		struct netdev_queue *dev_queue;
 
 		if (idx < s_idx)
@@ -1334,10 +1331,7 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	u32 qid = TC_H_MAJ(clid);
 	int err;
 
-	if (!net_eq(net, &init_net))
-		return -EINVAL;
-
-	if ((dev = __dev_get_by_index(&init_net, tcm->tcm_ifindex)) == NULL)
+	if ((dev = __dev_get_by_index(net, tcm->tcm_ifindex)) == NULL)
 		return -ENODEV;
 
 	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL);
@@ -1418,10 +1412,10 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 			if (cops->delete)
 				err = cops->delete(q, cl);
 			if (err == 0)
-				tclass_notify(skb, n, q, cl, RTM_DELTCLASS);
+				tclass_notify(net, skb, n, q, cl, RTM_DELTCLASS);
 			goto out;
 		case RTM_GETTCLASS:
-			err = tclass_notify(skb, n, q, cl, RTM_NEWTCLASS);
+			err = tclass_notify(net, skb, n, q, cl, RTM_NEWTCLASS);
 			goto out;
 		default:
 			err = -EINVAL;
@@ -1434,7 +1428,7 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	if (cops->change)
 		err = cops->change(q, clid, pid, tca, &new_cl);
 	if (err == 0)
-		tclass_notify(skb, n, q, new_cl, RTM_NEWTCLASS);
+		tclass_notify(net, skb, n, q, new_cl, RTM_NEWTCLASS);
 
 out:
 	if (cl)
@@ -1486,8 +1480,9 @@ nla_put_failure:
 	return -1;
 }
 
-static int tclass_notify(struct sk_buff *oskb, struct nlmsghdr *n,
-			  struct Qdisc *q, unsigned long cl, int event)
+static int tclass_notify(struct net *net, struct sk_buff *oskb,
+			 struct nlmsghdr *n, struct Qdisc *q,
+			 unsigned long cl, int event)
 {
 	struct sk_buff *skb;
 	u32 pid = oskb ? NETLINK_CB(oskb).pid : 0;
@@ -1501,7 +1496,7 @@ static int tclass_notify(struct sk_buff *oskb, struct nlmsghdr *n,
 		return -EINVAL;
 	}
 
-	return rtnetlink_send(skb, &init_net, pid, RTNLGRP_TC, n->nlmsg_flags&NLM_F_ECHO);
+	return rtnetlink_send(skb, net, pid, RTNLGRP_TC, n->nlmsg_flags&NLM_F_ECHO);
 }
 
 struct qdisc_dump_args
@@ -1576,12 +1571,9 @@ static int tc_dump_tclass(struct sk_buff *skb, struct netlink_callback *cb)
 	struct net_device *dev;
 	int t, s_t;
 
-	if (!net_eq(net, &init_net))
-		return 0;
-
 	if (cb->nlh->nlmsg_len < NLMSG_LENGTH(sizeof(*tcm)))
 		return 0;
-	if ((dev = dev_get_by_index(&init_net, tcm->tcm_ifindex)) == NULL)
+	if ((dev = dev_get_by_index(net, tcm->tcm_ifindex)) == NULL)
 		return 0;
 
 	s_t = cb->args[0];
@@ -1701,15 +1693,55 @@ static const struct file_operations psched_fops = {
 	.llseek = seq_lseek,
 	.release = single_release,
 };
+
+static int __net_init psched_net_init(struct net *net)
+{
+	struct proc_dir_entry *e;
+
+	e = proc_net_fops_create(net, "psched", 0, &psched_fops);
+	if (e == NULL)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void __net_exit psched_net_exit(struct net *net)
+{
+	proc_net_remove(net, "psched");
+
+	return;
+}
+#else
+static int __net_init psched_net_init(struct net *net)
+{
+	return 0;
+}
+
+static void __net_exit psched_net_exit(struct net *net)
+{
+}
 #endif
 
+static struct pernet_operations psched_net_ops = {
+	.init = psched_net_init,
+	.exit = psched_net_exit,
+};
+
 static int __init pktsched_init(void)
 {
+	int err;
+
+	err = register_pernet_subsys(&psched_net_ops);
+	if (err) {
+		printk(KERN_ERR "pktsched_init: "
+		       "cannot initialize per netns operations\n");
+		return err;
+	}
+
 	register_qdisc(&pfifo_qdisc_ops);
 	register_qdisc(&bfifo_qdisc_ops);
 	register_qdisc(&pfifo_head_drop_qdisc_ops);
 	register_qdisc(&mq_qdisc_ops);
-	proc_net_fops_create(&init_net, "psched", 0, &psched_fops);
 
 	rtnl_register(PF_UNSPEC, RTM_NEWQDISC, tc_modify_qdisc, NULL);
 	rtnl_register(PF_UNSPEC, RTM_DELQDISC, tc_get_qdisc, NULL);
-- 
1.6.3.3

