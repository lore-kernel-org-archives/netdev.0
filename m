From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/20] net: sched: use tc_setup_cb_call to call per-block callbacks
Date: Tue, 17 Oct 2017 22:05:59 +0200
Message-ID: <20171017200615.4530-5-jiri@resnulli.us>
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
Received: from mail-wr0-f195.google.com ([209.85.128.195]:48470 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764043AbdJQUGV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 16:06:21 -0400
Received: by mail-wr0-f195.google.com with SMTP id u5so2906429wrc.5
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 13:06:20 -0700 (PDT)
In-Reply-To: <20171017200615.4530-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Extend the tc_setup_cb_call entrypoint function originally used only for
action egress devices callbacks to call per-block callbacks as well.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h  |  4 ++--
 net/sched/cls_api.c    | 21 ++++++++++++++++++---
 net/sched/cls_flower.c |  9 ++++++---
 3 files changed, 26 insertions(+), 8 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 4bc6b1c..fcca5a9 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -543,8 +543,8 @@ tcf_match_indev(struct sk_buff *skb, int ifindex)
 }
 #endif /* CONFIG_NET_CLS_IND */
 
-int tc_setup_cb_call(struct tcf_exts *exts, enum tc_setup_type type,
-		     void *type_data, bool err_stop);
+int tc_setup_cb_call(struct tcf_block *block, struct tcf_exts *exts,
+		     enum tc_setup_type type, void *type_data, bool err_stop);
 
 enum tc_block_command {
 	TC_BLOCK_BIND,
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index b16c79c..cdfdc24 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -1206,10 +1206,25 @@ static int tc_exts_setup_cb_egdev_call(struct tcf_exts *exts,
 	return ok_count;
 }
 
-int tc_setup_cb_call(struct tcf_exts *exts, enum tc_setup_type type,
-		     void *type_data, bool err_stop)
+int tc_setup_cb_call(struct tcf_block *block, struct tcf_exts *exts,
+		     enum tc_setup_type type, void *type_data, bool err_stop)
 {
-	return tc_exts_setup_cb_egdev_call(exts, type, type_data, err_stop);
+	int ok_count;
+	int ret;
+
+	ret = tcf_block_cb_call(block, type, type_data, err_stop);
+	if (ret < 0)
+		return ret;
+	ok_count = ret;
+
+	if (!exts)
+		return ok_count;
+	ret = tc_exts_setup_cb_egdev_call(exts, type, type_data, err_stop);
+	if (ret < 0)
+		return ret;
+	ok_count += ret;
+
+	return ok_count;
 }
 EXPORT_SYMBOL(tc_setup_cb_call);
 
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 5b7bb96..76b4e0a 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -201,6 +201,7 @@ static void fl_hw_destroy_filter(struct tcf_proto *tp, struct cls_fl_filter *f)
 {
 	struct tc_cls_flower_offload cls_flower = {};
 	struct net_device *dev = tp->q->dev_queue->dev;
+	struct tcf_block *block = tp->chain->block;
 
 	tc_cls_common_offload_init(&cls_flower.common, tp);
 	cls_flower.command = TC_CLSFLOWER_DESTROY;
@@ -209,7 +210,7 @@ static void fl_hw_destroy_filter(struct tcf_proto *tp, struct cls_fl_filter *f)
 	if (tc_can_offload(dev))
 		dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER,
 					      &cls_flower);
-	tc_setup_cb_call(&f->exts, TC_SETUP_CLSFLOWER,
+	tc_setup_cb_call(block, &f->exts, TC_SETUP_CLSFLOWER,
 			 &cls_flower, false);
 }
 
@@ -220,6 +221,7 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_flower_offload cls_flower = {};
+	struct tcf_block *block = tp->chain->block;
 	bool skip_sw = tc_skip_sw(f->flags);
 	int err;
 
@@ -242,7 +244,7 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 		}
 	}
 
-	err = tc_setup_cb_call(&f->exts, TC_SETUP_CLSFLOWER,
+	err = tc_setup_cb_call(block, &f->exts, TC_SETUP_CLSFLOWER,
 			       &cls_flower, skip_sw);
 	if (err < 0) {
 		fl_hw_destroy_filter(tp, f);
@@ -261,6 +263,7 @@ static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
 {
 	struct tc_cls_flower_offload cls_flower = {};
 	struct net_device *dev = tp->q->dev_queue->dev;
+	struct tcf_block *block = tp->chain->block;
 
 	tc_cls_common_offload_init(&cls_flower.common, tp);
 	cls_flower.command = TC_CLSFLOWER_STATS;
@@ -270,7 +273,7 @@ static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
 	if (tc_can_offload(dev))
 		dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER,
 					      &cls_flower);
-	tc_setup_cb_call(&f->exts, TC_SETUP_CLSFLOWER,
+	tc_setup_cb_call(block, &f->exts, TC_SETUP_CLSFLOWER,
 			 &cls_flower, false);
 }
 
-- 
2.9.5
