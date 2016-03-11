From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next] net/flower: Fix pointer cast
Date: Fri, 11 Mar 2016 11:08:45 +0200
Message-ID: <1457687325-11214-1-git-send-email-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33203 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752928AbcCKJFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 04:05:10 -0500
Received: by mail-wm0-f66.google.com with SMTP id n186so1175147wmn.0
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 01:05:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cast pointer to unsigned long instead of u64, to fix compilation warning
on 32 bit arch, spotted by 0day build.

Fixes: 5b33f48 ("net/flower: Introduce hardware offload support")
Signed-off-by: Amir Vadai <amir@vadai.me>
---
 include/net/pkt_cls.h  |  2 +-
 net/sched/cls_flower.c | 12 ++++++------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 5b4e8f0..caa5e18 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -416,7 +416,7 @@ enum tc_fl_command {
 
 struct tc_cls_flower_offload {
 	enum tc_fl_command command;
-	u64 cookie;
+	unsigned long cookie;
 	struct flow_dissector *dissector;
 	struct fl_flow_key *mask;
 	struct fl_flow_key *key;
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 25d8766..2181ffc 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -165,7 +165,7 @@ static void fl_destroy_filter(struct rcu_head *head)
 	kfree(f);
 }
 
-static void fl_hw_destroy_filter(struct tcf_proto *tp, u64 cookie)
+static void fl_hw_destroy_filter(struct tcf_proto *tp, unsigned long cookie)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_flower_offload offload = {0};
@@ -188,7 +188,7 @@ static void fl_hw_replace_filter(struct tcf_proto *tp,
 				 struct fl_flow_key *mask,
 				 struct fl_flow_key *key,
 				 struct tcf_exts *actions,
-				 u64 cookie, u32 flags)
+				 unsigned long cookie, u32 flags)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_flower_offload offload = {0};
@@ -219,7 +219,7 @@ static bool fl_destroy(struct tcf_proto *tp, bool force)
 		return false;
 
 	list_for_each_entry_safe(f, next, &head->filters, list) {
-		fl_hw_destroy_filter(tp, (u64)f);
+		fl_hw_destroy_filter(tp, (unsigned long)f);
 		list_del_rcu(&f->list);
 		call_rcu(&f->rcu, fl_destroy_filter);
 	}
@@ -554,13 +554,13 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 			     &mask.key,
 			     &fnew->key,
 			     &fnew->exts,
-			     (u64)fnew,
+			     (unsigned long)fnew,
 			     flags);
 
 	if (fold) {
 		rhashtable_remove_fast(&head->ht, &fold->ht_node,
 				       head->ht_params);
-		fl_hw_destroy_filter(tp, (u64)fold);
+		fl_hw_destroy_filter(tp, (unsigned long)fold);
 	}
 
 	*arg = (unsigned long) fnew;
@@ -588,7 +588,7 @@ static int fl_delete(struct tcf_proto *tp, unsigned long arg)
 	rhashtable_remove_fast(&head->ht, &f->ht_node,
 			       head->ht_params);
 	list_del_rcu(&f->list);
-	fl_hw_destroy_filter(tp, (u64)f);
+	fl_hw_destroy_filter(tp, (unsigned long)f);
 	tcf_unbind_filter(tp, &f->res);
 	call_rcu(&f->rcu, fl_destroy_filter);
 	return 0;
-- 
2.7.0
