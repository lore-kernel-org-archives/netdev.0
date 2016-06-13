From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next] net/sched: flower: Return error when hw can't offload and skip_sw is set
Date: Mon, 13 Jun 2016 12:06:39 +0300
Message-ID: <20160613090639.31110-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jakub Kicinski <jakub.kicinski@netronome.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36010 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161185AbcFMJGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 05:06:51 -0400
Received: by mail-wm0-f68.google.com with SMTP id m124so13120416wme.3
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 02:06:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirva@mellanox.com>

When skip_sw is set and hardware fails to apply filter, return error to
user. This will make error propagation logic similar to the one
currently used in u32 classifier.
Also, changed code to use tc_skip_sw() utility function.

Signed-off-by: Amir Vadai <amirva@mellanox.com>
---
 net/sched/cls_flower.c | 42 +++++++++++++++++++++++++-----------------
 1 file changed, 25 insertions(+), 17 deletions(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 1ea6f76..5060801 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -140,7 +140,7 @@ static int fl_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	f = rhashtable_lookup_fast(&head->ht,
 				   fl_key_get_start(&skb_mkey, &head->mask),
 				   head->ht_params);
-	if (f && !(f->flags & TCA_CLS_FLAGS_SKIP_SW)) {
+	if (f && !tc_skip_sw(f->flags)) {
 		*res = f->res;
 		return tcf_exts_exec(skb, &f->exts, res);
 	}
@@ -187,19 +187,20 @@ static void fl_hw_destroy_filter(struct tcf_proto *tp, unsigned long cookie)
 	dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol, &tc);
 }
 
-static void fl_hw_replace_filter(struct tcf_proto *tp,
-				 struct flow_dissector *dissector,
-				 struct fl_flow_key *mask,
-				 struct fl_flow_key *key,
-				 struct tcf_exts *actions,
-				 unsigned long cookie, u32 flags)
+static int fl_hw_replace_filter(struct tcf_proto *tp,
+				struct flow_dissector *dissector,
+				struct fl_flow_key *mask,
+				struct fl_flow_key *key,
+				struct tcf_exts *actions,
+				unsigned long cookie, u32 flags)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_flower_offload offload = {0};
 	struct tc_to_netdev tc;
+	int err;
 
 	if (!tc_should_offload(dev, tp, flags))
-		return;
+		return tc_skip_sw(flags) ? -EINVAL : 0;
 
 	offload.command = TC_CLSFLOWER_REPLACE;
 	offload.cookie = cookie;
@@ -211,7 +212,12 @@ static void fl_hw_replace_filter(struct tcf_proto *tp,
 	tc.type = TC_SETUP_CLSFLOWER;
 	tc.cls_flower = &offload;
 
-	dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol, &tc);
+	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol, &tc);
+
+	if (tc_skip_sw(flags))
+		return err;
+
+	return 0;
 }
 
 static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
@@ -572,20 +578,22 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	if (err)
 		goto errout;
 
-	if (!(fnew->flags & TCA_CLS_FLAGS_SKIP_SW)) {
+	if (!tc_skip_sw(fnew->flags)) {
 		err = rhashtable_insert_fast(&head->ht, &fnew->ht_node,
 					     head->ht_params);
 		if (err)
 			goto errout;
 	}
 
-	fl_hw_replace_filter(tp,
-			     &head->dissector,
-			     &mask.key,
-			     &fnew->key,
-			     &fnew->exts,
-			     (unsigned long)fnew,
-			     fnew->flags);
+	err = fl_hw_replace_filter(tp,
+				   &head->dissector,
+				   &mask.key,
+				   &fnew->key,
+				   &fnew->exts,
+				   (unsigned long)fnew,
+				   fnew->flags);
+	if (err)
+		goto errout;
 
 	if (fold) {
 		rhashtable_remove_fast(&head->ht, &fold->ht_node,
-- 
2.8.3
