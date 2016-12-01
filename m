From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH net-next V2 3/8] net/sched: cls_flower: Provide a filter to replace/destroy hardware filter functions
Date: Thu,  1 Dec 2016 14:06:35 +0200
Message-ID: <1480594000-8428-4-git-send-email-hadarh@mellanox.com>
References: <1480594000-8428-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45345 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1758786AbcLANCb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 08:02:31 -0500
In-Reply-To: <1480594000-8428-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of providing many arguments to fl_hw_{replace/destroy}_filter
functions, just provide cls_fl_filter struct that includes all the relevant
args.

This patches doesn't add any new functionality.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_flower.c | 27 +++++++++++----------------
 1 file changed, 11 insertions(+), 16 deletions(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 5e70f65..13b349f 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -201,7 +201,7 @@ static void fl_destroy_filter(struct rcu_head *head)
 	kfree(f);
 }
 
-static void fl_hw_destroy_filter(struct tcf_proto *tp, unsigned long cookie)
+static void fl_hw_destroy_filter(struct tcf_proto *tp, struct cls_fl_filter *f)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_flower_offload offload = {0};
@@ -211,7 +211,7 @@ static void fl_hw_destroy_filter(struct tcf_proto *tp, unsigned long cookie)
 		return;
 
 	offload.command = TC_CLSFLOWER_DESTROY;
-	offload.cookie = cookie;
+	offload.cookie = (unsigned long)f;
 
 	tc.type = TC_SETUP_CLSFLOWER;
 	tc.cls_flower = &offload;
@@ -222,9 +222,7 @@ static void fl_hw_destroy_filter(struct tcf_proto *tp, unsigned long cookie)
 static int fl_hw_replace_filter(struct tcf_proto *tp,
 				struct flow_dissector *dissector,
 				struct fl_flow_key *mask,
-				struct fl_flow_key *key,
-				struct tcf_exts *actions,
-				unsigned long cookie, u32 flags)
+				struct cls_fl_filter *f)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_flower_offload offload = {0};
@@ -232,14 +230,14 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 	int err;
 
 	if (!tc_can_offload(dev, tp))
-		return tc_skip_sw(flags) ? -EINVAL : 0;
+		return tc_skip_sw(f->flags) ? -EINVAL : 0;
 
 	offload.command = TC_CLSFLOWER_REPLACE;
-	offload.cookie = cookie;
+	offload.cookie = (unsigned long)f;
 	offload.dissector = dissector;
 	offload.mask = mask;
-	offload.key = key;
-	offload.exts = actions;
+	offload.key = &f->key;
+	offload.exts = &f->exts;
 
 	tc.type = TC_SETUP_CLSFLOWER;
 	tc.cls_flower = &offload;
@@ -247,7 +245,7 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol,
 					    &tc);
 
-	if (tc_skip_sw(flags))
+	if (tc_skip_sw(f->flags))
 		return err;
 
 	return 0;
@@ -276,7 +274,7 @@ static void __fl_delete(struct tcf_proto *tp, struct cls_fl_filter *f)
 {
 	list_del_rcu(&f->list);
 	if (!tc_skip_hw(f->flags))
-		fl_hw_destroy_filter(tp, (unsigned long)f);
+		fl_hw_destroy_filter(tp, f);
 	tcf_unbind_filter(tp, &f->res);
 	call_rcu(&f->rcu, fl_destroy_filter);
 }
@@ -748,10 +746,7 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 		err = fl_hw_replace_filter(tp,
 					   &head->dissector,
 					   &mask.key,
-					   &fnew->key,
-					   &fnew->exts,
-					   (unsigned long)fnew,
-					   fnew->flags);
+					   fnew);
 		if (err)
 			goto errout;
 	}
@@ -760,7 +755,7 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 		rhashtable_remove_fast(&head->ht, &fold->ht_node,
 				       head->ht_params);
 		if (!tc_skip_hw(fold->flags))
-			fl_hw_destroy_filter(tp, (unsigned long)fold);
+			fl_hw_destroy_filter(tp, fold);
 	}
 
 	*arg = (unsigned long) fnew;
-- 
1.8.3.1
