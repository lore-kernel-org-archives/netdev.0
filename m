From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH net-next 2/8] net/sched: cls_flower: Try to offload only if skip_hw flag isn't set
Date: Wed, 30 Nov 2016 16:41:29 +0200
Message-ID: <1480516895-29545-3-git-send-email-hadarh@mellanox.com>
References: <1480516895-29545-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45991 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753112AbcK3PhJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 10:37:09 -0500
In-Reply-To: <1480516895-29545-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check skip_hw flag isn't set before calling
fl_hw_{replace/destroy}_filter and fl_hw_update_stats functions.

Replace the call to tc_should_offload with tc_can_offload.
tc_can_offload only checks if the device supports offloading, the check for
skip_hw flag is done earlier in the flow.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_flower.c | 35 ++++++++++++++++++++---------------
 1 file changed, 20 insertions(+), 15 deletions(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index e8dd09a..5e70f65 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -207,7 +207,7 @@ static void fl_hw_destroy_filter(struct tcf_proto *tp, unsigned long cookie)
 	struct tc_cls_flower_offload offload = {0};
 	struct tc_to_netdev tc;
 
-	if (!tc_should_offload(dev, tp, 0))
+	if (!tc_can_offload(dev, tp))
 		return;
 
 	offload.command = TC_CLSFLOWER_DESTROY;
@@ -231,7 +231,7 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 	struct tc_to_netdev tc;
 	int err;
 
-	if (!tc_should_offload(dev, tp, flags))
+	if (!tc_can_offload(dev, tp))
 		return tc_skip_sw(flags) ? -EINVAL : 0;
 
 	offload.command = TC_CLSFLOWER_REPLACE;
@@ -259,7 +259,7 @@ static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
 	struct tc_cls_flower_offload offload = {0};
 	struct tc_to_netdev tc;
 
-	if (!tc_should_offload(dev, tp, 0))
+	if (!tc_can_offload(dev, tp))
 		return;
 
 	offload.command = TC_CLSFLOWER_STATS;
@@ -275,7 +275,8 @@ static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
 static void __fl_delete(struct tcf_proto *tp, struct cls_fl_filter *f)
 {
 	list_del_rcu(&f->list);
-	fl_hw_destroy_filter(tp, (unsigned long)f);
+	if (!tc_skip_hw(f->flags))
+		fl_hw_destroy_filter(tp, (unsigned long)f);
 	tcf_unbind_filter(tp, &f->res);
 	call_rcu(&f->rcu, fl_destroy_filter);
 }
@@ -743,20 +744,23 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 			goto errout;
 	}
 
-	err = fl_hw_replace_filter(tp,
-				   &head->dissector,
-				   &mask.key,
-				   &fnew->key,
-				   &fnew->exts,
-				   (unsigned long)fnew,
-				   fnew->flags);
-	if (err)
-		goto errout;
+	if (!tc_skip_hw(fnew->flags)) {
+		err = fl_hw_replace_filter(tp,
+					   &head->dissector,
+					   &mask.key,
+					   &fnew->key,
+					   &fnew->exts,
+					   (unsigned long)fnew,
+					   fnew->flags);
+		if (err)
+			goto errout;
+	}
 
 	if (fold) {
 		rhashtable_remove_fast(&head->ht, &fold->ht_node,
 				       head->ht_params);
-		fl_hw_destroy_filter(tp, (unsigned long)fold);
+		if (!tc_skip_hw(fold->flags))
+			fl_hw_destroy_filter(tp, (unsigned long)fold);
 	}
 
 	*arg = (unsigned long) fnew;
@@ -879,7 +883,8 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 			goto nla_put_failure;
 	}
 
-	fl_hw_update_stats(tp, f);
+	if (!tc_skip_hw(f->flags))
+		fl_hw_update_stats(tp, f);
 
 	if (fl_dump_key_val(skb, key->eth.dst, TCA_FLOWER_KEY_ETH_DST,
 			    mask->eth.dst, TCA_FLOWER_KEY_ETH_DST_MASK,
-- 
1.8.3.1
