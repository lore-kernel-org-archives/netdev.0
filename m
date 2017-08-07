From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 14/16] net: sched: move prio into cls_common
Date: Mon,  7 Aug 2017 10:15:30 +0200
Message-ID: <20170807081532.32760-15-jiri@resnulli.us>
References: <20170807081532.32760-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        dirk.vandermerwe@netronome.com, alexander.h.duyck@intel.com,
        amritha.nambiar@intel.com, oss-drivers@netronome.com,
        yisen.zhuang@huawei.com, salil.mehta@huawei.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33394 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752510AbdHGIP5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 04:15:57 -0400
Received: by mail-wm0-f68.google.com with SMTP id q189so152796wmd.0
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 01:15:56 -0700 (PDT)
In-Reply-To: <20170807081532.32760-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

prio is not cls_flower specific, but it is meaningful for all
classifiers. Seems that only mlxsw cares about the value. Obviously,
cls offload in other drivers is broken.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c | 2 +-
 include/net/pkt_cls.h                                 | 3 ++-
 net/sched/cls_flower.c                                | 3 ---
 3 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
index 021b6c0..95428b4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
@@ -270,7 +270,7 @@ static int mlxsw_sp_flower_parse(struct mlxsw_sp *mlxsw_sp,
 		return -EOPNOTSUPP;
 	}
 
-	mlxsw_sp_acl_rulei_priority(rulei, f->prio);
+	mlxsw_sp_acl_rulei_priority(rulei, f->common.prio);
 
 	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_CONTROL)) {
 		struct flow_dissector_key_control *key =
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index ffaddf7..572083a 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -409,6 +409,7 @@ struct tc_cls_common_offload {
 	u32 handle;
 	u32 chain_index;
 	__be16 protocol;
+	u32 prio;
 };
 
 static inline void
@@ -418,6 +419,7 @@ tc_cls_common_offload_init(struct tc_cls_common_offload *cls_common,
 	cls_common->handle = tp->q->handle;
 	cls_common->chain_index = tp->chain->index;
 	cls_common->protocol = tp->protocol;
+	cls_common->prio = tp->prio;
 }
 
 struct tc_cls_u32_knode {
@@ -515,7 +517,6 @@ enum tc_fl_command {
 struct tc_cls_flower_offload {
 	struct tc_cls_common_offload common;
 	enum tc_fl_command command;
-	u32 prio;
 	unsigned long cookie;
 	struct flow_dissector *dissector;
 	struct fl_flow_key *mask;
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 1fdf288..ccdf2f5 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -234,7 +234,6 @@ static void fl_hw_destroy_filter(struct tcf_proto *tp, struct cls_fl_filter *f)
 
 	tc_cls_common_offload_init(&offload.common, tp);
 	offload.command = TC_CLSFLOWER_DESTROY;
-	offload.prio = tp->prio;
 	offload.cookie = (unsigned long)f;
 
 	tc->cls_flower = &offload;
@@ -266,7 +265,6 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 
 	tc_cls_common_offload_init(&offload.common, tp);
 	offload.command = TC_CLSFLOWER_REPLACE;
-	offload.prio = tp->prio;
 	offload.cookie = (unsigned long)f;
 	offload.dissector = dissector;
 	offload.mask = mask;
@@ -295,7 +293,6 @@ static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
 
 	tc_cls_common_offload_init(&offload.common, tp);
 	offload.command = TC_CLSFLOWER_STATS;
-	offload.prio = tp->prio;
 	offload.cookie = (unsigned long)f;
 	offload.exts = &f->exts;
 
-- 
2.9.3
