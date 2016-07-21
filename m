From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/9] net/sched: Add match-all classifier hw offloading.
Date: Thu, 21 Jul 2016 10:19:15 +0200
Message-ID: <1469089160-4239-5-git-send-email-jiri@resnulli.us>
References: <1469089160-4239-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, eladr@mellanox.com,
	idosch@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34530 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbcGUIT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 04:19:29 -0400
Received: by mail-wm0-f68.google.com with SMTP id q128so1645933wma.1
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 01:19:28 -0700 (PDT)
In-Reply-To: <1469089160-4239-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Following the work that have been done on offloading classifiers like u32
and flower, now the match-all classifier hw offloading is possible. if
the interface supports tc offloading.

To control the offloading, two tc flags have been introduced: skip_sw and
skip_hw. Typical usage:

tc filter add dev eth25 parent ffff: 	\
	matchall skip_sw		\
	action mirred egress mirror	\
	dev eth27

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/netdevice.h    |  2 ++
 include/net/pkt_cls.h        | 11 +++++++
 include/uapi/linux/pkt_cls.h |  1 +
 net/sched/cls_matchall.c     | 76 ++++++++++++++++++++++++++++++++++++++++++--
 4 files changed, 87 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index fab9a1c..63e31a7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -787,6 +787,7 @@ enum {
 	TC_SETUP_MQPRIO,
 	TC_SETUP_CLSU32,
 	TC_SETUP_CLSFLOWER,
+	TC_SETUP_MATCHALL,
 };
 
 struct tc_cls_u32_offload;
@@ -797,6 +798,7 @@ struct tc_to_netdev {
 		u8 tc;
 		struct tc_cls_u32_offload *cls_u32;
 		struct tc_cls_flower_offload *cls_flower;
+		struct tc_cls_matchall_offload *cls_mall;
 	};
 };
 
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 3722dda..6f8d653 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -442,4 +442,15 @@ struct tc_cls_flower_offload {
 	struct tcf_exts *exts;
 };
 
+enum tc_matchall_command {
+	TC_CLSMATCHALL_REPLACE,
+	TC_CLSMATCHALL_DESTROY,
+};
+
+struct tc_cls_matchall_offload {
+	enum tc_matchall_command command;
+	struct tcf_exts *exts;
+	unsigned long cookie;
+};
+
 #endif
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index a324948..d1c1cca 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -439,6 +439,7 @@ enum {
 	TCA_MATCHALL_UNSPEC,
 	TCA_MATCHALL_CLASSID,
 	TCA_MATCHALL_ACT,
+	TCA_MATCHALL_FLAGS,
 	__TCA_MATCHALL_MAX,
 };
 
diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index 8a6b4de..25927b6 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -21,6 +21,7 @@ struct cls_mall_filter {
 	struct tcf_result res;
 	u32 handle;
 	struct rcu_head	rcu;
+	u32 flags;
 };
 
 struct cls_mall_head {
@@ -34,6 +35,9 @@ static int mall_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	struct cls_mall_head *head = rcu_dereference_bh(tp->root);
 	struct cls_mall_filter *f = head->filter;
 
+	if (tc_skip_sw(f->flags))
+		return -1;
+
 	return tcf_exts_exec(skb, &f->exts, res);
 }
 
@@ -55,18 +59,61 @@ static void mall_destroy_filter(struct rcu_head *head)
 	struct cls_mall_filter *f = container_of(head, struct cls_mall_filter, rcu);
 
 	tcf_exts_destroy(&f->exts);
+
 	kfree(f);
 }
 
+static int mall_replace_hw_filter(struct tcf_proto *tp,
+				  struct cls_mall_filter *f,
+				  unsigned long cookie)
+{
+	struct net_device *dev = tp->q->dev_queue->dev;
+	struct tc_to_netdev offload;
+	struct tc_cls_matchall_offload mall_offload = {0};
+
+	offload.type = TC_SETUP_MATCHALL;
+	offload.cls_mall = &mall_offload;
+	offload.cls_mall->command = TC_CLSMATCHALL_REPLACE;
+	offload.cls_mall->exts = &f->exts;
+	offload.cls_mall->cookie = cookie;
+
+	return dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol,
+					     &offload);
+}
+
+static void mall_destroy_hw_filter(struct tcf_proto *tp,
+				   struct cls_mall_filter *f,
+				   unsigned long cookie)
+{
+	struct net_device *dev = tp->q->dev_queue->dev;
+	struct tc_to_netdev offload;
+	struct tc_cls_matchall_offload mall_offload = {0};
+
+	offload.type = TC_SETUP_MATCHALL;
+	offload.cls_mall = &mall_offload;
+	offload.cls_mall->command = TC_CLSMATCHALL_DESTROY;
+	offload.cls_mall->exts = NULL;
+	offload.cls_mall->cookie = cookie;
+
+	dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol,
+					     &offload);
+}
+
 static bool mall_destroy(struct tcf_proto *tp, bool force)
 {
 	struct cls_mall_head *head = rtnl_dereference(tp->root);
+	struct net_device *dev = tp->q->dev_queue->dev;
+	struct cls_mall_filter *f = head->filter;
 
-	if (!force && head->filter)
+	if (!force && f)
 		return false;
 
-	if (head->filter)
-		call_rcu(&head->filter->rcu, mall_destroy_filter);
+	if (f) {
+		if (tc_should_offload(dev, tp, f->flags))
+			mall_destroy_hw_filter(tp, f, (unsigned long) f);
+
+		call_rcu(&f->rcu, mall_destroy_filter);
+	}
 	RCU_INIT_POINTER(tp->root, NULL);
 	kfree_rcu(head, rcu);
 	return true;
@@ -117,8 +164,10 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
 {
 	struct cls_mall_head *head = rtnl_dereference(tp->root);
 	struct cls_mall_filter *fold = (struct cls_mall_filter *) *arg;
+	struct net_device *dev = tp->q->dev_queue->dev;
 	struct cls_mall_filter *f;
 	struct nlattr *tb[TCA_MATCHALL_MAX + 1];
+	u32 flags = 0;
 	int err;
 
 	if (!tca[TCA_OPTIONS])
@@ -135,6 +184,12 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
 	if (err < 0)
 		return err;
 
+	if (tb[TCA_MATCHALL_FLAGS]) {
+		flags = nla_get_u32(tb[TCA_MATCHALL_FLAGS]);
+		if (!tc_flags_valid(flags))
+			return -EINVAL;
+	}
+
 	f = kzalloc(sizeof(*f), GFP_KERNEL);
 	if (!f)
 		return -ENOBUFS;
@@ -144,11 +199,22 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
 	if (!handle)
 		handle = 1;
 	f->handle = handle;
+	f->flags = flags;
 
 	err = mall_set_parms(net, tp, f, base, tb, tca[TCA_RATE], ovr);
 	if (err)
 		goto errout;
 
+	if (tc_should_offload(dev, tp, flags)) {
+		err = mall_replace_hw_filter(tp, f, (unsigned long) f);
+		if (err) {
+			if (tc_skip_sw(flags))
+				goto errout;
+			else
+				err = 0;
+		}
+	}
+
 	*arg = (unsigned long) f;
 	rcu_assign_pointer(head->filter, f);
 
@@ -163,6 +229,10 @@ static int mall_delete(struct tcf_proto *tp, unsigned long arg)
 {
 	struct cls_mall_head *head = rtnl_dereference(tp->root);
 	struct cls_mall_filter *f = (struct cls_mall_filter *) arg;
+	struct net_device *dev = tp->q->dev_queue->dev;
+
+	if (tc_should_offload(dev, tp, f->flags))
+		mall_destroy_hw_filter(tp, f, (unsigned long) f);
 
 	RCU_INIT_POINTER(head->filter, NULL);
 	tcf_unbind_filter(tp, &f->res);
-- 
2.5.5
