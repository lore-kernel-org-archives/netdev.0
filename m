From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/20] net: sched: cls_matchall: call block callbacks for offload
Date: Tue, 17 Oct 2017 22:06:00 +0200
Message-ID: <20171017200615.4530-6-jiri@resnulli.us>
References: <20171017200615.4530-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, alexander.h.duyck@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:54180 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763310AbdJQUGW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 16:06:22 -0400
Received: by mail-wm0-f67.google.com with SMTP id q132so6160196wmd.2
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 13:06:21 -0700 (PDT)
In-Reply-To: <20171017200615.4530-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Use the newly introduced callbacks infrastructure and call block
callbacks alongside with the existing per-netdev ndo_setup_tc.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_matchall.c | 72 ++++++++++++++++++++++++++++++------------------
 1 file changed, 45 insertions(+), 27 deletions(-)

diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index eeac606..5278534 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -50,50 +50,73 @@ static void mall_destroy_rcu(struct rcu_head *rcu)
 	kfree(head);
 }
 
-static int mall_replace_hw_filter(struct tcf_proto *tp,
-				  struct cls_mall_head *head,
-				  unsigned long cookie)
+static void mall_destroy_hw_filter(struct tcf_proto *tp,
+				   struct cls_mall_head *head,
+				   unsigned long cookie)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_matchall_offload cls_mall = {};
-	int err;
+	struct tcf_block *block = tp->chain->block;
 
 	tc_cls_common_offload_init(&cls_mall.common, tp);
-	cls_mall.command = TC_CLSMATCHALL_REPLACE;
-	cls_mall.exts = &head->exts;
+	cls_mall.command = TC_CLSMATCHALL_DESTROY;
 	cls_mall.cookie = cookie;
 
-	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSMATCHALL,
-					    &cls_mall);
-	if (!err)
-		head->flags |= TCA_CLS_FLAGS_IN_HW;
-
-	return err;
+	if (tc_can_offload(dev))
+		dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSMATCHALL,
+					      &cls_mall);
+	tc_setup_cb_call(block, NULL, TC_SETUP_CLSMATCHALL, &cls_mall, false);
 }
 
-static void mall_destroy_hw_filter(struct tcf_proto *tp,
-				   struct cls_mall_head *head,
-				   unsigned long cookie)
+static int mall_replace_hw_filter(struct tcf_proto *tp,
+				  struct cls_mall_head *head,
+				  unsigned long cookie)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_matchall_offload cls_mall = {};
+	struct tcf_block *block = tp->chain->block;
+	bool skip_sw = tc_skip_sw(head->flags);
+	int err;
 
 	tc_cls_common_offload_init(&cls_mall.common, tp);
-	cls_mall.command = TC_CLSMATCHALL_DESTROY;
+	cls_mall.command = TC_CLSMATCHALL_REPLACE;
+	cls_mall.exts = &head->exts;
 	cls_mall.cookie = cookie;
 
-	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSMATCHALL, &cls_mall);
+	if (tc_can_offload(dev)) {
+		err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSMATCHALL,
+						    &cls_mall);
+		if (err) {
+			if (skip_sw)
+				return err;
+		} else {
+			head->flags |= TCA_CLS_FLAGS_IN_HW;
+		}
+	}
+
+	err = tc_setup_cb_call(block, NULL, TC_SETUP_CLSMATCHALL,
+			       &cls_mall, skip_sw);
+	if (err < 0) {
+		mall_destroy_hw_filter(tp, head, cookie);
+		return err;
+	} else if (err > 0) {
+		head->flags |= TCA_CLS_FLAGS_IN_HW;
+	}
+
+	if (skip_sw && !(head->flags & TCA_CLS_FLAGS_IN_HW))
+		return -EINVAL;
+
+	return 0;
 }
 
 static void mall_destroy(struct tcf_proto *tp)
 {
 	struct cls_mall_head *head = rtnl_dereference(tp->root);
-	struct net_device *dev = tp->q->dev_queue->dev;
 
 	if (!head)
 		return;
 
-	if (tc_should_offload(dev, head->flags))
+	if (!tc_skip_hw(head->flags))
 		mall_destroy_hw_filter(tp, head, (unsigned long) head);
 
 	call_rcu(&head->rcu, mall_destroy_rcu);
@@ -133,7 +156,6 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
 		       void **arg, bool ovr)
 {
 	struct cls_mall_head *head = rtnl_dereference(tp->root);
-	struct net_device *dev = tp->q->dev_queue->dev;
 	struct nlattr *tb[TCA_MATCHALL_MAX + 1];
 	struct cls_mall_head *new;
 	u32 flags = 0;
@@ -173,14 +195,10 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
 	if (err)
 		goto err_set_parms;
 
-	if (tc_should_offload(dev, flags)) {
+	if (!tc_skip_hw(new->flags)) {
 		err = mall_replace_hw_filter(tp, new, (unsigned long) new);
-		if (err) {
-			if (tc_skip_sw(flags))
-				goto err_replace_hw_filter;
-			else
-				err = 0;
-		}
+		if (err)
+			goto err_replace_hw_filter;
 	}
 
 	if (!tc_in_hw(new->flags))
-- 
2.9.5
