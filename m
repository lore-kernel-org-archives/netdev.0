From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next v2 4/4] net/sched: cls_flower: allow control of tree traversal on packet parse errors
Date: Fri,  5 May 2017 14:47:06 +0200
Message-ID: <1493988426-22854-5-git-send-email-simon.horman@netronome.com>
References: <1493988426-22854-1-git-send-email-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Benjamin LaHaise <benjamin.lahaise@netronome.com>,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:34991 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753468AbdEEMrW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 08:47:22 -0400
Received: by mail-wm0-f43.google.com with SMTP id w64so22936743wma.0
        for <netdev@vger.kernel.org>; Fri, 05 May 2017 05:47:21 -0700 (PDT)
In-Reply-To: <1493988426-22854-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow control how the tree of qdisc, classes and filters is further
traversed if an error is encountered when parsing the packet in order to
match the cls_flower filters at a particular prio.

By default continue to the next filter, the behaviour without this patch.

A use-case for this is to allow configuration of dropping of packets with
truncated headers.

For example, the following drops IPv4 packets that cannot be parsed by the
flow dissector up to the end of the UDP ports - e.g. because they are
truncated, and instantiates a continue action based on the port for packets
that can be parsed.

 # tc qdisc del dev eth0 ingress; tc qdisc add dev eth0 ingress
 # tc filter add dev eth0 protocol ip parent ffff: flower \
       indev eth0 ip_proto udp dst_port 80 truncated drop action continue

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Benjamin LaHaise <benjamin.lahaise@netronome.com>
---
rfc2
* s/TCA_FLOWER_HEADER_PARSE_ERR_ACT/TCA_FLOWER_META_TRUNCATED/
  after discussion with Jamal
* Clean up whitespace
---
 include/uapi/linux/pkt_cls.h |  2 ++
 net/sched/cls_flower.c       | 45 ++++++++++++++++++++++++++++++++++----------
 2 files changed, 37 insertions(+), 10 deletions(-)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index d613be3b3239..6474d6e55110 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -450,6 +450,8 @@ enum {
 	TCA_FLOWER_KEY_MPLS_TC,		/* u8 - 3 bits */
 	TCA_FLOWER_KEY_MPLS_LABEL,	/* be32 - 20 bits */
 
+	TCA_FLOWER_META_TRUNCATED,
+
 	__TCA_FLOWER_MAX,
 };
 
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 90bfd003176b..000d0e3f44f9 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -67,13 +67,14 @@ struct cls_fl_head {
 	struct fl_flow_mask mask;
 	struct flow_dissector dissector;
 	u32 hgen;
-	bool mask_assigned;
+	bool assigned;
 	struct list_head filters;
 	struct rhashtable_params ht_params;
 	union {
 		struct work_struct work;
 		struct rcu_head	rcu;
 	};
+	int err_action;
 };
 
 struct cls_fl_filter {
@@ -188,7 +189,7 @@ static int fl_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	 */
 	skb_key.basic.n_proto = skb->protocol;
 	if (!skb_flow_dissect(skb, &head->dissector, &skb_key, 0))
-		return -1;
+		return head->err_action;
 
 	fl_set_masked_key(&skb_mkey, &skb_key, &head->mask);
 
@@ -317,7 +318,7 @@ static void fl_destroy_sleepable(struct work_struct *work)
 {
 	struct cls_fl_head *head = container_of(work, struct cls_fl_head,
 						work);
-	if (head->mask_assigned)
+	if (head->assigned)
 		rhashtable_destroy(&head->ht);
 	kfree(head);
 	module_put(THIS_MODULE);
@@ -425,6 +426,7 @@ static const struct nla_policy fl_policy[TCA_FLOWER_MAX + 1] = {
 	[TCA_FLOWER_KEY_MPLS_BOS]	= { .type = NLA_U8 },
 	[TCA_FLOWER_KEY_MPLS_TC]	= { .type = NLA_U8 },
 	[TCA_FLOWER_KEY_MPLS_LABEL]	= { .type = NLA_U32 },
+	[TCA_FLOWER_META_TRUNCATED]	= { .type = NLA_U32 },
 };
 
 static void fl_set_key_val(struct nlattr **tb,
@@ -791,13 +793,15 @@ static void fl_init_dissector(struct cls_fl_head *head,
 	skb_flow_dissector_init(&head->dissector, keys, cnt);
 }
 
-static int fl_check_assign_mask(struct cls_fl_head *head,
-				struct fl_flow_mask *mask)
+static int fl_check_assign_mask_and_err_action(struct cls_fl_head *head,
+					       struct fl_flow_mask *mask,
+					       int err_action)
 {
 	int err;
 
-	if (head->mask_assigned) {
-		if (!fl_mask_eq(&head->mask, mask))
+	if (head->assigned) {
+		if (!fl_mask_eq(&head->mask, mask) ||
+		    head->err_action != err_action)
 			return -EINVAL;
 		else
 			return 0;
@@ -810,7 +814,8 @@ static int fl_check_assign_mask(struct cls_fl_head *head,
 	if (err)
 		return err;
 	memcpy(&head->mask, mask, sizeof(head->mask));
-	head->mask_assigned = true;
+	head->assigned = true;
+	head->err_action = err_action;
 
 	fl_init_dissector(head, mask);
 
@@ -883,7 +888,7 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	struct cls_fl_filter *fnew;
 	struct nlattr **tb;
 	struct fl_flow_mask mask = {};
-	int err;
+	int err, err_action;
 
 	if (!tca[TCA_OPTIONS])
 		return -EINVAL;
@@ -930,11 +935,27 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 		}
 	}
 
+	if (tb[TCA_FLOWER_META_TRUNCATED]) {
+		err_action = nla_get_u32(tb[TCA_FLOWER_META_TRUNCATED]);
+
+		switch (err_action) {
+		case TC_ACT_UNSPEC:
+		case TC_ACT_OK:
+		case TC_ACT_SHOT:
+			break;
+		default:
+			err = -EINVAL;
+			goto errout;
+		}
+	} else {
+		err_action = TC_ACT_UNSPEC;
+	}
+
 	err = fl_set_parms(net, tp, fnew, &mask, base, tb, tca[TCA_RATE], ovr);
 	if (err)
 		goto errout;
 
-	err = fl_check_assign_mask(head, &mask);
+	err = fl_check_assign_mask_and_err_action(head, &mask, err_action);
 	if (err)
 		goto errout;
 
@@ -1321,6 +1342,10 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 	if (f->flags && nla_put_u32(skb, TCA_FLOWER_FLAGS, f->flags))
 		goto nla_put_failure;
 
+	if (head->err_action != TC_ACT_UNSPEC &&
+	    nla_put_u32(skb, TCA_FLOWER_META_TRUNCATED, head->err_action))
+		goto nla_put_failure;
+
 	if (tcf_exts_dump(skb, &f->exts))
 		goto nla_put_failure;
 
-- 
2.1.4
