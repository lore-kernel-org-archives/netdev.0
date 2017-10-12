From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 18/34] net: sched: cls_u32: call block callbacks for offload
Date: Thu, 12 Oct 2017 19:18:07 +0200
Message-ID: <20171012171823.1431-19-jiri@resnulli.us>
References: <20171012171823.1431-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, edumazet@google.com, dsahern@gmail.com,
        alexander.h.duyck@intel.com, john.fastabend@gmail.com,
        willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:38567 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755086AbdJLRSm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:18:42 -0400
Received: by mail-wm0-f67.google.com with SMTP id q124so4336240wmb.5
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:18:41 -0700 (PDT)
In-Reply-To: <20171012171823.1431-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Use the newly introduced callbacks infrastructure and call block
callbacks alongside with the existing per-netdev ndo_setup_tc.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_u32.c | 72 ++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 52 insertions(+), 20 deletions(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index f407f13..24cc429 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -465,39 +465,57 @@ static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode *key)
 static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
+	struct tcf_block *block = tp->chain->block;
 	struct tc_cls_u32_offload cls_u32 = {};
 
-	if (!tc_should_offload(dev, 0))
-		return;
-
 	tc_cls_common_offload_init(&cls_u32.common, tp);
 	cls_u32.command = TC_CLSU32_DELETE_HNODE;
 	cls_u32.hnode.divisor = h->divisor;
 	cls_u32.hnode.handle = h->handle;
 	cls_u32.hnode.prio = h->prio;
 
-	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, &cls_u32);
+	if (tc_can_offload(dev))
+		dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, &cls_u32);
+	tc_setup_cb_call(block, NULL, TC_SETUP_CLSU32, &cls_u32, false);
 }
 
 static int u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h,
 				u32 flags)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
+	struct tcf_block *block = tp->chain->block;
 	struct tc_cls_u32_offload cls_u32 = {};
+	bool skip_sw = tc_skip_sw(flags);
+	bool offloaded = false;
 	int err;
 
-	if (!tc_should_offload(dev, flags))
-		return tc_skip_sw(flags) ? -EINVAL : 0;
-
 	tc_cls_common_offload_init(&cls_u32.common, tp);
 	cls_u32.command = TC_CLSU32_NEW_HNODE;
 	cls_u32.hnode.divisor = h->divisor;
 	cls_u32.hnode.handle = h->handle;
 	cls_u32.hnode.prio = h->prio;
 
-	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, &cls_u32);
-	if (tc_skip_sw(flags))
+	if (tc_can_offload(dev)) {
+		err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32,
+						    &cls_u32);
+		if (err) {
+			if (skip_sw)
+				return err;
+		} else {
+			offloaded = true;
+		}
+	}
+
+	err = tc_setup_cb_call(block, NULL, TC_SETUP_CLSU32, &cls_u32, skip_sw);
+	if (err < 0) {
+		u32_clear_hw_hnode(tp, h);
 		return err;
+	} else if (err > 0) {
+		offloaded = true;
+	}
+
+	if (skip_sw && !offloaded)
+		return -EINVAL;
 
 	return 0;
 }
@@ -505,28 +523,27 @@ static int u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h,
 static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
+	struct tcf_block *block = tp->chain->block;
 	struct tc_cls_u32_offload cls_u32 = {};
 
-	if (!tc_should_offload(dev, 0))
-		return;
-
 	tc_cls_common_offload_init(&cls_u32.common, tp);
 	cls_u32.command = TC_CLSU32_DELETE_KNODE;
 	cls_u32.knode.handle = handle;
 
-	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, &cls_u32);
+	if (tc_can_offload(dev))
+		dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, &cls_u32);
+	tc_setup_cb_call(block, NULL, TC_SETUP_CLSU32, &cls_u32, false);
 }
 
 static int u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n,
 				u32 flags)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
+	struct tcf_block *block = tp->chain->block;
 	struct tc_cls_u32_offload cls_u32 = {};
+	bool skip_sw = tc_skip_sw(flags);
 	int err;
 
-	if (!tc_should_offload(dev, flags))
-		return tc_skip_sw(flags) ? -EINVAL : 0;
-
 	tc_cls_common_offload_init(&cls_u32.common, tp);
 	cls_u32.command = TC_CLSU32_REPLACE_KNODE;
 	cls_u32.knode.handle = n->handle;
@@ -543,13 +560,28 @@ static int u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n,
 	if (n->ht_down)
 		cls_u32.knode.link_handle = n->ht_down->handle;
 
-	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, &cls_u32);
 
-	if (!err)
-		n->flags |= TCA_CLS_FLAGS_IN_HW;
+	if (tc_can_offload(dev)) {
+		err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32,
+						    &cls_u32);
+		if (err) {
+			if (skip_sw)
+				return err;
+		} else {
+			n->flags |= TCA_CLS_FLAGS_IN_HW;
+		}
+	}
 
-	if (tc_skip_sw(flags))
+	err = tc_setup_cb_call(block, NULL, TC_SETUP_CLSU32, &cls_u32, skip_sw);
+	if (err < 0) {
+		u32_remove_hw_knode(tp, n->handle);
 		return err;
+	} else if (err > 0) {
+		n->flags |= TCA_CLS_FLAGS_IN_HW;
+	}
+
+	if (skip_sw && !(n->flags && TCA_CLS_FLAGS_IN_HW))
+		return -EINVAL;
 
 	return 0;
 }
-- 
2.9.5
