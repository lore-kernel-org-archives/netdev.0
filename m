From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next] net/sched: cls_flower: Introduce support in SKIP SW flag
Date: Mon, 13 Jun 2016 11:58:12 +0300
Message-ID: <20160613085812.30742-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jakub Kicinski <jakub.kicinski@netronome.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34677 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933300AbcFMJCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 05:02:39 -0400
Received: by mail-wm0-f65.google.com with SMTP id n184so13128587wmn.1
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 02:02:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirva@mellanox.com>

In order to make a filter processed only by hardware, skip_sw flag
should be supplied. This is an addition to the already existing skip_hw
flag (filter will be processed by software only). If no flag is
specified, filter will be processed by both software and hardware.

If only hardware offloaded filters exist, fl_classify() will return
without doing anything.

A following userspace patch will be sent once kernel patch is accepted.

Example:

tc filter add dev enp0s9 protocol ip prio 20 parent ffff: \
	flower \
		ip_proto 6 \
		indev enp0s9 \
		skip_sw \
	action skbedit mark 0x1234

Signed-off-by: Amir Vadai <amirva@mellanox.com>
---
 net/sched/cls_flower.c | 31 ++++++++++++++++++++++---------
 1 file changed, 22 insertions(+), 9 deletions(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 730aaca..d737492 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -66,6 +66,7 @@ struct cls_fl_filter {
 	struct fl_flow_key key;
 	struct list_head list;
 	u32 handle;
+	u32 flags;
 	struct rcu_head	rcu;
 };
 
@@ -123,6 +124,9 @@ static int fl_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	struct fl_flow_key skb_key;
 	struct fl_flow_key skb_mkey;
 
+	if (!atomic_read(&head->ht.nelems))
+		return -1;
+
 	fl_clear_masked_range(&skb_key, &head->mask);
 	skb_key.indev_ifindex = skb->skb_iif;
 	/* skb_flow_dissect() does not set n_proto in case an unknown protocol,
@@ -136,7 +140,7 @@ static int fl_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	f = rhashtable_lookup_fast(&head->ht,
 				   fl_key_get_start(&skb_mkey, &head->mask),
 				   head->ht_params);
-	if (f) {
+	if (f && !(f->flags & TCA_CLS_FLAGS_SKIP_SW)) {
 		*res = f->res;
 		return tcf_exts_exec(skb, &f->exts, res);
 	}
@@ -524,7 +528,6 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	struct cls_fl_filter *fnew;
 	struct nlattr *tb[TCA_FLOWER_MAX + 1];
 	struct fl_flow_mask mask = {};
-	u32 flags = 0;
 	int err;
 
 	if (!tca[TCA_OPTIONS])
@@ -552,8 +555,14 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	}
 	fnew->handle = handle;
 
-	if (tb[TCA_FLOWER_FLAGS])
-		flags = nla_get_u32(tb[TCA_FLOWER_FLAGS]);
+	if (tb[TCA_FLOWER_FLAGS]) {
+		fnew->flags = nla_get_u32(tb[TCA_FLOWER_FLAGS]);
+
+		if (!tc_flags_valid(fnew->flags)) {
+			err = -EINVAL;
+			goto errout;
+		}
+	}
 
 	err = fl_set_parms(net, tp, fnew, &mask, base, tb, tca[TCA_RATE], ovr);
 	if (err)
@@ -563,10 +572,12 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	if (err)
 		goto errout;
 
-	err = rhashtable_insert_fast(&head->ht, &fnew->ht_node,
-				     head->ht_params);
-	if (err)
-		goto errout;
+	if (!(fnew->flags & TCA_CLS_FLAGS_SKIP_SW)) {
+		err = rhashtable_insert_fast(&head->ht, &fnew->ht_node,
+					     head->ht_params);
+		if (err)
+			goto errout;
+	}
 
 	fl_hw_replace_filter(tp,
 			     &head->dissector,
@@ -574,7 +585,7 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 			     &fnew->key,
 			     &fnew->exts,
 			     (unsigned long)fnew,
-			     flags);
+			     fnew->flags);
 
 	if (fold) {
 		rhashtable_remove_fast(&head->ht, &fold->ht_node,
@@ -734,6 +745,8 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 				  sizeof(key->tp.dst))))
 		goto nla_put_failure;
 
+	nla_put_u32(skb, TCA_FLOWER_FLAGS, f->flags);
+
 	if (tcf_exts_dump(skb, &f->exts))
 		goto nla_put_failure;
 
-- 
2.8.3
