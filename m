From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 1/4] net: sched: make tc_action_ops->get_dev return dev and avoid passing net
Date: Wed, 11 Oct 2017 09:41:07 +0200
Message-ID: <20171011074110.2800-2-jiri@resnulli.us>
References: <20171011074110.2800-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        mlxsw@mellanox.com, David.Laight@ACULAB.COM, gerlitz.or@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:48663 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756600AbdJKHlO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 03:41:14 -0400
Received: by mail-wm0-f67.google.com with SMTP id i124so2571111wmf.3
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 00:41:13 -0700 (PDT)
In-Reply-To: <20171011074110.2800-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Return dev directly, NULL if not possible. That is enough.

Makes no sense to pass struct net * to get_dev op, as there is only one
net possible, the one the action was created in. So just store it in
mirred priv and use directly.

Rename the mirred op callback function.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/act_api.h          |  3 +--
 include/net/tc_act/tc_mirred.h |  1 +
 net/sched/act_mirred.c         | 13 +++++--------
 net/sched/cls_api.c            |  6 ++----
 4 files changed, 9 insertions(+), 14 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index b944e0e..900168a 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -93,8 +93,7 @@ struct tc_action_ops {
 	int     (*walk)(struct net *, struct sk_buff *,
 			struct netlink_callback *, int, const struct tc_action_ops *);
 	void	(*stats_update)(struct tc_action *, u64, u32, u64);
-	int	(*get_dev)(const struct tc_action *a, struct net *net,
-			   struct net_device **mirred_dev);
+	struct net_device *(*get_dev)(const struct tc_action *a);
 };
 
 struct tc_action_net {
diff --git a/include/net/tc_act/tc_mirred.h b/include/net/tc_act/tc_mirred.h
index 604bc31..21a6565 100644
--- a/include/net/tc_act/tc_mirred.h
+++ b/include/net/tc_act/tc_mirred.h
@@ -10,6 +10,7 @@ struct tcf_mirred {
 	int			tcfm_ifindex;
 	bool			tcfm_mac_header_xmit;
 	struct net_device __rcu	*tcfm_dev;
+	struct net		*net;
 	struct list_head	tcfm_list;
 };
 #define to_mirred(a) ((struct tcf_mirred *)a)
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 416627c..8b3e5938 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -140,6 +140,7 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 	m->tcfm_eaction = parm->eaction;
 	if (dev != NULL) {
 		m->tcfm_ifindex = parm->ifindex;
+		m->net = net;
 		if (ret != ACT_P_CREATED)
 			dev_put(rcu_dereference_protected(m->tcfm_dev, 1));
 		dev_hold(dev);
@@ -313,15 +314,11 @@ static struct notifier_block mirred_device_notifier = {
 	.notifier_call = mirred_device_event,
 };
 
-static int tcf_mirred_device(const struct tc_action *a, struct net *net,
-			     struct net_device **mirred_dev)
+static struct net_device *tcf_mirred_get_dev(const struct tc_action *a)
 {
-	int ifindex = tcf_mirred_ifindex(a);
+	struct tcf_mirred *m = to_mirred(a);
 
-	*mirred_dev = __dev_get_by_index(net, ifindex);
-	if (!*mirred_dev)
-		return -EINVAL;
-	return 0;
+	return __dev_get_by_index(m->net, m->tcfm_ifindex);
 }
 
 static struct tc_action_ops act_mirred_ops = {
@@ -336,7 +333,7 @@ static struct tc_action_ops act_mirred_ops = {
 	.walk		=	tcf_mirred_walker,
 	.lookup		=	tcf_mirred_search,
 	.size		=	sizeof(struct tcf_mirred),
-	.get_dev	=	tcf_mirred_device,
+	.get_dev	=	tcf_mirred_get_dev,
 };
 
 static __net_init int mirred_init_net(struct net *net)
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 0b2219a..450873b 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -1016,10 +1016,8 @@ int tcf_exts_get_dev(struct net_device *dev, struct tcf_exts *exts,
 
 	tcf_exts_to_list(exts, &actions);
 	list_for_each_entry(a, &actions, list) {
-		if (a->ops->get_dev) {
-			a->ops->get_dev(a, dev_net(dev), hw_dev);
-			break;
-		}
+		if (a->ops->get_dev)
+			*hw_dev = a->ops->get_dev(a);
 	}
 	if (*hw_dev)
 		return 0;
-- 
2.9.5
