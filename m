From: Amir Vadai <amir@vadai.me>
Subject: [RFC net-next 6/9] net/cls_flower: Introduce hardware offloading
Date: Mon,  1 Feb 2016 08:34:42 +0000
Message-ID: <1454315685-32202-7-git-send-email-amir@vadai.me>
References: <1454315685-32202-1-git-send-email-amir@vadai.me>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:32903 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752262AbcBAIgv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2016 03:36:51 -0500
In-Reply-To: <1454315685-32202-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During initialization, tcf_exts_offload_init() is called to initialize
the list of actions description. later on, the classifier description
is prepared and sent to the switchdev using switchdev_port_flow_add().

When offloaded, fl_classify() is a NOP - already done in hardware.

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 include/uapi/linux/pkt_cls.h |  1 +
 net/sched/cls_flower.c       | 54 ++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 53 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 4398737..c18e82d 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -416,6 +416,7 @@ enum {
 	TCA_FLOWER_KEY_TCP_DST,		/* be16 */
 	TCA_FLOWER_KEY_UDP_SRC,		/* be16 */
 	TCA_FLOWER_KEY_UDP_DST,		/* be16 */
+	TCA_FLOWER_OFFLOAD,		/* flag */
 	__TCA_FLOWER_MAX,
 };
 
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 95b0212..e36d408 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -22,6 +22,7 @@
 #include <net/pkt_cls.h>
 #include <net/ip.h>
 #include <net/flow_dissector.h>
+#include <net/switchdev.h>
 
 struct fl_flow_key {
 	int	indev_ifindex;
@@ -56,6 +57,7 @@ struct cls_fl_head {
 	struct list_head filters;
 	struct rhashtable_params ht_params;
 	struct rcu_head rcu;
+	bool offload;
 };
 
 struct cls_fl_filter {
@@ -67,6 +69,7 @@ struct cls_fl_filter {
 	struct list_head list;
 	u32 handle;
 	struct rcu_head	rcu;
+	struct net_device *indev;
 };
 
 static unsigned short int fl_mask_range(const struct fl_flow_mask *mask)
@@ -123,6 +126,9 @@ static int fl_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	struct fl_flow_key skb_key;
 	struct fl_flow_key skb_mkey;
 
+	if (head->offload)
+		return -1;
+
 	fl_clear_masked_range(&skb_key, &head->mask);
 	skb_key.indev_ifindex = skb->skb_iif;
 	/* skb_flow_dissect() does not set n_proto in case an unknown protocol,
@@ -174,6 +180,9 @@ static bool fl_destroy(struct tcf_proto *tp, bool force)
 		return false;
 
 	list_for_each_entry_safe(f, next, &head->filters, list) {
+		if (head->offload)
+			switchdev_port_flow_del(f->indev, (unsigned long)f);
+
 		list_del_rcu(&f->list);
 		call_rcu(&f->rcu, fl_destroy_filter);
 	}
@@ -396,9 +405,11 @@ static int fl_check_assign_mask(struct cls_fl_head *head,
 }
 
 static int fl_set_parms(struct net *net, struct tcf_proto *tp,
+			struct cls_fl_head *head,
 			struct cls_fl_filter *f, struct fl_flow_mask *mask,
 			unsigned long base, struct nlattr **tb,
-			struct nlattr *est, bool ovr)
+			struct nlattr *est, bool ovr,
+			struct switchdev_obj_port_flow_act *actions)
 {
 	struct tcf_exts e;
 	int err;
@@ -413,6 +424,8 @@ static int fl_set_parms(struct net *net, struct tcf_proto *tp,
 		tcf_bind_filter(tp, &f->res, base);
 	}
 
+	head->offload = nla_get_flag(tb[TCA_FLOWER_OFFLOAD]);
+
 	err = fl_set_key(net, tb, &f->key, &mask->key);
 	if (err)
 		goto errout;
@@ -420,6 +433,24 @@ static int fl_set_parms(struct net *net, struct tcf_proto *tp,
 	fl_mask_update_range(mask);
 	fl_set_masked_key(&f->mkey, &f->key, mask);
 
+	if (head->offload) {
+		if (!f->key.indev_ifindex) {
+			pr_err("indev must be set when using offloaded filter\n");
+			err = -EINVAL;
+			goto errout;
+		}
+
+		f->indev = __dev_get_by_index(net, f->key.indev_ifindex);
+		if (!f->indev) {
+			err = -EINVAL;
+			goto errout;
+		}
+
+		err = tcf_exts_offload_init(&e, actions);
+		if (err)
+			goto errout;
+	}
+
 	tcf_exts_change(tp, &f->exts, &e);
 
 	return 0;
@@ -459,6 +490,7 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	struct cls_fl_filter *fnew;
 	struct nlattr *tb[TCA_FLOWER_MAX + 1];
 	struct fl_flow_mask mask = {};
+	struct switchdev_obj_port_flow_act actions = {};
 	int err;
 
 	if (!tca[TCA_OPTIONS])
@@ -486,7 +518,8 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	}
 	fnew->handle = handle;
 
-	err = fl_set_parms(net, tp, fnew, &mask, base, tb, tca[TCA_RATE], ovr);
+	err = fl_set_parms(net, tp, head, fnew, &mask, base, tb,
+			   tca[TCA_RATE], ovr, &actions);
 	if (err)
 		goto errout;
 
@@ -494,6 +527,17 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	if (err)
 		goto errout;
 
+	if (head->offload) {
+		err = switchdev_port_flow_add(fnew->indev,
+					      &head->dissector,
+					      &mask.key,
+					      &fnew->key,
+					      &actions,
+					      (unsigned long)fnew);
+		if (err)
+			goto errout;
+	}
+
 	err = rhashtable_insert_fast(&head->ht, &fnew->ht_node,
 				     head->ht_params);
 	if (err)
@@ -505,6 +549,12 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	*arg = (unsigned long) fnew;
 
 	if (fold) {
+		if (head->offload) {
+			err = switchdev_port_flow_del(fold->indev,
+						      (unsigned long)fold);
+			if (err)
+				goto errout;
+		}
 		list_replace_rcu(&fold->list, &fnew->list);
 		tcf_unbind_filter(tp, &fold->res);
 		call_rcu(&fold->rcu, fl_destroy_filter);
-- 
2.7.0
