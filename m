From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next 1/8] net/flower: Introduce hardware offload support
Date: Tue,  1 Mar 2016 16:24:43 +0200
Message-ID: <1456842290-7844-2-git-send-email-amir@vadai.me>
References: <1456842290-7844-1-git-send-email-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>, Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34136 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753745AbcCAOVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 09:21:36 -0500
Received: by mail-wm0-f66.google.com with SMTP id p65so4362053wmp.1
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 06:21:36 -0800 (PST)
In-Reply-To: <1456842290-7844-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is based on a patch made by John Fastabend.
It adds support for offloading cls_flower.
A filter that is offloaded successfuly by hardware, will not be added to
the hashtable and won't be processed by software.

Suggested-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Amir Vadai <amir@vadai.me>
---
 include/linux/netdevice.h    |  2 ++
 include/net/pkt_cls.h        | 14 +++++++++
 include/uapi/linux/pkt_cls.h |  2 ++
 net/sched/cls_flower.c       | 75 +++++++++++++++++++++++++++++++++++++++++---
 4 files changed, 88 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e52077f..0fd329a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -785,6 +785,7 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
 enum {
 	TC_SETUP_MQPRIO,
 	TC_SETUP_CLSU32,
+	TC_SETUP_CLSFLOWER,
 };
 
 struct tc_cls_u32_offload;
@@ -794,6 +795,7 @@ struct tc_to_netdev {
 	union {
 		u8 tc;
 		struct tc_cls_u32_offload *cls_u32;
+		struct tc_cls_flower_offload *cls_flower;
 	};
 };
 
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index bea14ee..beb2ee1 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -409,4 +409,18 @@ static inline bool tc_should_offload(struct net_device *dev, u32 flags)
 	return true;
 }
 
+enum {
+	TC_CLSFLOWER_REPLACE,
+	TC_CLSFLOWER_DESTROY,
+};
+
+struct tc_cls_flower_offload {
+	int command;
+	u64 cookie;
+	struct flow_dissector *dissector;
+	struct fl_flow_key *mask;
+	struct fl_flow_key *key;
+	struct tcf_exts *exts;
+};
+
 #endif
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 9874f568..c43c5f7 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -417,6 +417,8 @@ enum {
 	TCA_FLOWER_KEY_TCP_DST,		/* be16 */
 	TCA_FLOWER_KEY_UDP_SRC,		/* be16 */
 	TCA_FLOWER_KEY_UDP_DST,		/* be16 */
+
+	TCA_FLOWER_FLAGS,
 	__TCA_FLOWER_MAX,
 };
 
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 95b0212..e599bea 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -165,6 +165,53 @@ static void fl_destroy_filter(struct rcu_head *head)
 	kfree(f);
 }
 
+static int fl_hw_destroy_filter(struct tcf_proto *tp, u64 cookie)
+{
+	struct net_device *dev = tp->q->dev_queue->dev;
+	struct tc_cls_flower_offload offload = {0};
+	struct tc_to_netdev tc;
+
+	if (!tc_should_offload(dev, 0))
+		return -ENOTSUPP;
+
+	offload.command = TC_CLSFLOWER_DESTROY;
+	offload.cookie = cookie;
+
+	tc.type = TC_SETUP_CLSFLOWER;
+	tc.cls_flower = &offload;
+
+	return dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol,
+					     &tc);
+}
+
+static int fl_hw_replace_filter(struct tcf_proto *tp,
+				struct flow_dissector *dissector,
+				struct fl_flow_key *mask,
+				struct fl_flow_key *key,
+				struct tcf_exts *actions,
+				u64 cookie, u32 flags)
+{
+	struct net_device *dev = tp->q->dev_queue->dev;
+	struct tc_cls_flower_offload offload = {0};
+	struct tc_to_netdev tc;
+
+	if (!tc_should_offload(dev, flags))
+		return -ENOTSUPP;
+
+	offload.command = TC_CLSFLOWER_REPLACE;
+	offload.cookie = cookie;
+	offload.dissector = dissector;
+	offload.mask = mask;
+	offload.key = key;
+	offload.exts = actions;
+
+	tc.type = TC_SETUP_CLSFLOWER;
+	tc.cls_flower = &offload;
+
+	return dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol,
+					     &tc);
+}
+
 static bool fl_destroy(struct tcf_proto *tp, bool force)
 {
 	struct cls_fl_head *head = rtnl_dereference(tp->root);
@@ -174,6 +221,7 @@ static bool fl_destroy(struct tcf_proto *tp, bool force)
 		return false;
 
 	list_for_each_entry_safe(f, next, &head->filters, list) {
+		fl_hw_destroy_filter(tp, (u64)f);
 		list_del_rcu(&f->list);
 		call_rcu(&f->rcu, fl_destroy_filter);
 	}
@@ -459,6 +507,7 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	struct cls_fl_filter *fnew;
 	struct nlattr *tb[TCA_FLOWER_MAX + 1];
 	struct fl_flow_mask mask = {};
+	u32 flags = 0;
 	int err;
 
 	if (!tca[TCA_OPTIONS])
@@ -494,13 +543,28 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	if (err)
 		goto errout;
 
-	err = rhashtable_insert_fast(&head->ht, &fnew->ht_node,
-				     head->ht_params);
-	if (err)
-		goto errout;
-	if (fold)
+	if (tb[TCA_FLOWER_FLAGS])
+		flags = nla_get_u32(tb[TCA_FLOWER_FLAGS]);
+
+	err = fl_hw_replace_filter(tp,
+				   &head->dissector,
+				   &mask.key,
+				   &fnew->key,
+				   &fnew->exts,
+				   (u64)fnew,
+				   flags);
+	if (err) {
+		err = rhashtable_insert_fast(&head->ht, &fnew->ht_node,
+					     head->ht_params);
+		if (err)
+			goto errout;
+	}
+
+	if (fold) {
 		rhashtable_remove_fast(&head->ht, &fold->ht_node,
 				       head->ht_params);
+		fl_hw_destroy_filter(tp, (u64)fold);
+	}
 
 	*arg = (unsigned long) fnew;
 
@@ -527,6 +591,7 @@ static int fl_delete(struct tcf_proto *tp, unsigned long arg)
 	rhashtable_remove_fast(&head->ht, &f->ht_node,
 			       head->ht_params);
 	list_del_rcu(&f->list);
+	fl_hw_destroy_filter(tp, (u64)f);
 	tcf_unbind_filter(tp, &f->res);
 	call_rcu(&f->rcu, fl_destroy_filter);
 	return 0;
-- 
2.7.0
