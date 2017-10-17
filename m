From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 18/20] net: sched: avoid ndo_setup_tc calls for TC_SETUP_CLS*
Date: Tue, 17 Oct 2017 22:06:13 +0200
Message-ID: <20171017200615.4530-19-jiri@resnulli.us>
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
Received: from mail-wr0-f195.google.com ([209.85.128.195]:54467 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764044AbdJQUGd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 16:06:33 -0400
Received: by mail-wr0-f195.google.com with SMTP id o44so2901039wrf.11
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 13:06:32 -0700 (PDT)
In-Reply-To: <20171017200615.4530-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

All drivers are converted to use block callbacks for TC_SETUP_CLS*.
So it is now safe to remove the calls to ndo_setup_tc from cls_*

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c          |  2 --
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c      |  2 --
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  3 ---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  2 --
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  2 --
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   |  2 --
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  3 ---
 drivers/net/ethernet/netronome/nfp/bpf/main.c      |  2 --
 .../net/ethernet/netronome/nfp/flower/offload.c    |  2 --
 net/dsa/slave.c                                    |  2 --
 net/sched/cls_bpf.c                                | 14 ----------
 net/sched/cls_flower.c                             | 20 --------------
 net/sched/cls_matchall.c                           | 16 -----------
 net/sched/cls_u32.c                                | 31 ----------------------
 14 files changed, 103 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 4dde2b8..22a94b1 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7335,8 +7335,6 @@ static int bnxt_setup_tc(struct net_device *dev, enum tc_setup_type type,
 			 void *type_data)
 {
 	switch (type) {
-	case TC_SETUP_CLSFLOWER:
-		return 0; /* will be removed after conversion from ndo */
 	case TC_SETUP_BLOCK:
 		return bnxt_setup_tc_block(dev, type_data);
 	case TC_SETUP_MQPRIO: {
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
index cc278d7..6dff5aa 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
@@ -158,8 +158,6 @@ static int bnxt_vf_rep_setup_tc(struct net_device *dev, enum tc_setup_type type,
 				void *type_data)
 {
 	switch (type) {
-	case TC_SETUP_CLSFLOWER:
-		return 0; /* will be removed after conversion from ndo */
 	case TC_SETUP_BLOCK:
 		return bnxt_vf_rep_setup_tc_block(dev, type_data);
 	default:
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index ca0b96b..6edbf54 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2964,9 +2964,6 @@ static int cxgb_setup_tc(struct net_device *dev, enum tc_setup_type type,
 			 void *type_data)
 {
 	switch (type) {
-	case TC_SETUP_CLSU32:
-	case TC_SETUP_CLSFLOWER:
-		return 0; /* will be removed after conversion from ndo */
 	case TC_SETUP_BLOCK:
 		return cxgb_setup_tc_block(dev, type_data);
 	default:
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 6b52cfd..3c85120 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9432,8 +9432,6 @@ static int __ixgbe_setup_tc(struct net_device *dev, enum tc_setup_type type,
 			    void *type_data)
 {
 	switch (type) {
-	case TC_SETUP_CLSU32:
-		return 0; /* will be removed after conversion from ndo */
 	case TC_SETUP_BLOCK:
 		return ixgbe_setup_tc_block(dev, type_data);
 	case TC_SETUP_MQPRIO:
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index e810868..560b208 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3141,8 +3141,6 @@ int mlx5e_setup_tc(struct net_device *dev, enum tc_setup_type type,
 {
 	switch (type) {
 #ifdef CONFIG_MLX5_ESWITCH
-	case TC_SETUP_CLSFLOWER:
-		return 0; /* will be removed after conversion from ndo */
 	case TC_SETUP_BLOCK:
 		return mlx5e_setup_tc_block(dev, type_data);
 #endif
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index f59d81a..0edb706 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -714,8 +714,6 @@ static int mlx5e_rep_setup_tc(struct net_device *dev, enum tc_setup_type type,
 			      void *type_data)
 {
 	switch (type) {
-	case TC_SETUP_CLSFLOWER:
-		return 0; /* will be removed after conversion from ndo */
 	case TC_SETUP_BLOCK:
 		return mlx5e_rep_setup_tc_block(dev, type_data);
 	default:
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 08e321a..9fe51a6 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1792,9 +1792,6 @@ static int mlxsw_sp_setup_tc(struct net_device *dev, enum tc_setup_type type,
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 
 	switch (type) {
-	case TC_SETUP_CLSMATCHALL:
-	case TC_SETUP_CLSFLOWER:
-		return 0; /* will be removed after conversion from ndo */
 	case TC_SETUP_BLOCK:
 		return mlxsw_sp_setup_tc_block(mlxsw_sp_port, type_data);
 	default:
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.c b/drivers/net/ethernet/netronome/nfp/bpf/main.c
index 64f97b3..fa0ac90 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.c
@@ -159,8 +159,6 @@ static int nfp_bpf_setup_tc(struct nfp_app *app, struct net_device *netdev,
 			    enum tc_setup_type type, void *type_data)
 {
 	switch (type) {
-	case TC_SETUP_CLSBPF:
-		return 0; /* will be removed after conversion from ndo */
 	case TC_SETUP_BLOCK:
 		return nfp_bpf_setup_tc_block(netdev, type_data);
 	default:
diff --git a/drivers/net/ethernet/netronome/nfp/flower/offload.c b/drivers/net/ethernet/netronome/nfp/flower/offload.c
index f8523df..c47753f 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
@@ -506,8 +506,6 @@ int nfp_flower_setup_tc(struct nfp_app *app, struct net_device *netdev,
 			enum tc_setup_type type, void *type_data)
 {
 	switch (type) {
-	case TC_SETUP_CLSFLOWER:
-		return 0; /* will be removed after conversion from ndo */
 	case TC_SETUP_BLOCK:
 		return nfp_flower_setup_tc_block(netdev, type_data);
 	default:
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 0a20b19..db36975 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -857,8 +857,6 @@ static int dsa_slave_setup_tc(struct net_device *dev, enum tc_setup_type type,
 			      void *type_data)
 {
 	switch (type) {
-	case TC_SETUP_CLSMATCHALL:
-		return 0; /* will be removed after conversion from ndo */
 	case TC_SETUP_BLOCK:
 		return dsa_slave_setup_tc_block(dev, type_data);
 	default:
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index e379fdf..0f8b510 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -148,7 +148,6 @@ static int cls_bpf_offload_cmd(struct tcf_proto *tp, struct cls_bpf_prog *prog,
 			       enum tc_clsbpf_command cmd)
 {
 	bool addorrep = cmd == TC_CLSBPF_ADD || cmd == TC_CLSBPF_REPLACE;
-	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tcf_block *block = tp->chain->block;
 	bool skip_sw = tc_skip_sw(prog->gen_flags);
 	struct tc_cls_bpf_offload cls_bpf = {};
@@ -162,19 +161,6 @@ static int cls_bpf_offload_cmd(struct tcf_proto *tp, struct cls_bpf_prog *prog,
 	cls_bpf.exts_integrated = prog->exts_integrated;
 	cls_bpf.gen_flags = prog->gen_flags;
 
-	if (tc_can_offload(dev)) {
-		err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSBPF,
-						    &cls_bpf);
-		if (addorrep) {
-			if (err) {
-				if (skip_sw)
-					return err;
-			} else {
-				prog->gen_flags |= TCA_CLS_FLAGS_IN_HW;
-			}
-		}
-	}
-
 	err = tc_setup_cb_call(block, NULL, TC_SETUP_CLSBPF, &cls_bpf, skip_sw);
 	if (addorrep) {
 		if (err < 0) {
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 76b4e0a..16f58ab 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -200,16 +200,12 @@ static void fl_destroy_filter(struct rcu_head *head)
 static void fl_hw_destroy_filter(struct tcf_proto *tp, struct cls_fl_filter *f)
 {
 	struct tc_cls_flower_offload cls_flower = {};
-	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tcf_block *block = tp->chain->block;
 
 	tc_cls_common_offload_init(&cls_flower.common, tp);
 	cls_flower.command = TC_CLSFLOWER_DESTROY;
 	cls_flower.cookie = (unsigned long) f;
 
-	if (tc_can_offload(dev))
-		dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER,
-					      &cls_flower);
 	tc_setup_cb_call(block, &f->exts, TC_SETUP_CLSFLOWER,
 			 &cls_flower, false);
 }
@@ -219,7 +215,6 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 				struct fl_flow_key *mask,
 				struct cls_fl_filter *f)
 {
-	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_flower_offload cls_flower = {};
 	struct tcf_block *block = tp->chain->block;
 	bool skip_sw = tc_skip_sw(f->flags);
@@ -233,17 +228,6 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 	cls_flower.key = &f->mkey;
 	cls_flower.exts = &f->exts;
 
-	if (tc_can_offload(dev)) {
-		err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER,
-						    &cls_flower);
-		if (err) {
-			if (skip_sw)
-				return err;
-		} else {
-			f->flags |= TCA_CLS_FLAGS_IN_HW;
-		}
-	}
-
 	err = tc_setup_cb_call(block, &f->exts, TC_SETUP_CLSFLOWER,
 			       &cls_flower, skip_sw);
 	if (err < 0) {
@@ -262,7 +246,6 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
 {
 	struct tc_cls_flower_offload cls_flower = {};
-	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tcf_block *block = tp->chain->block;
 
 	tc_cls_common_offload_init(&cls_flower.common, tp);
@@ -270,9 +253,6 @@ static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
 	cls_flower.cookie = (unsigned long) f;
 	cls_flower.exts = &f->exts;
 
-	if (tc_can_offload(dev))
-		dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER,
-					      &cls_flower);
 	tc_setup_cb_call(block, &f->exts, TC_SETUP_CLSFLOWER,
 			 &cls_flower, false);
 }
diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index 5278534..70e78d7 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -54,7 +54,6 @@ static void mall_destroy_hw_filter(struct tcf_proto *tp,
 				   struct cls_mall_head *head,
 				   unsigned long cookie)
 {
-	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_matchall_offload cls_mall = {};
 	struct tcf_block *block = tp->chain->block;
 
@@ -62,9 +61,6 @@ static void mall_destroy_hw_filter(struct tcf_proto *tp,
 	cls_mall.command = TC_CLSMATCHALL_DESTROY;
 	cls_mall.cookie = cookie;
 
-	if (tc_can_offload(dev))
-		dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSMATCHALL,
-					      &cls_mall);
 	tc_setup_cb_call(block, NULL, TC_SETUP_CLSMATCHALL, &cls_mall, false);
 }
 
@@ -72,7 +68,6 @@ static int mall_replace_hw_filter(struct tcf_proto *tp,
 				  struct cls_mall_head *head,
 				  unsigned long cookie)
 {
-	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_matchall_offload cls_mall = {};
 	struct tcf_block *block = tp->chain->block;
 	bool skip_sw = tc_skip_sw(head->flags);
@@ -83,17 +78,6 @@ static int mall_replace_hw_filter(struct tcf_proto *tp,
 	cls_mall.exts = &head->exts;
 	cls_mall.cookie = cookie;
 
-	if (tc_can_offload(dev)) {
-		err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSMATCHALL,
-						    &cls_mall);
-		if (err) {
-			if (skip_sw)
-				return err;
-		} else {
-			head->flags |= TCA_CLS_FLAGS_IN_HW;
-		}
-	}
-
 	err = tc_setup_cb_call(block, NULL, TC_SETUP_CLSMATCHALL,
 			       &cls_mall, skip_sw);
 	if (err < 0) {
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 24cc429..0e4bd30 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -464,7 +464,6 @@ static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode *key)
 
 static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 {
-	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tcf_block *block = tp->chain->block;
 	struct tc_cls_u32_offload cls_u32 = {};
 
@@ -474,15 +473,12 @@ static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 	cls_u32.hnode.handle = h->handle;
 	cls_u32.hnode.prio = h->prio;
 
-	if (tc_can_offload(dev))
-		dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, &cls_u32);
 	tc_setup_cb_call(block, NULL, TC_SETUP_CLSU32, &cls_u32, false);
 }
 
 static int u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h,
 				u32 flags)
 {
-	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tcf_block *block = tp->chain->block;
 	struct tc_cls_u32_offload cls_u32 = {};
 	bool skip_sw = tc_skip_sw(flags);
@@ -495,17 +491,6 @@ static int u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h,
 	cls_u32.hnode.handle = h->handle;
 	cls_u32.hnode.prio = h->prio;
 
-	if (tc_can_offload(dev)) {
-		err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32,
-						    &cls_u32);
-		if (err) {
-			if (skip_sw)
-				return err;
-		} else {
-			offloaded = true;
-		}
-	}
-
 	err = tc_setup_cb_call(block, NULL, TC_SETUP_CLSU32, &cls_u32, skip_sw);
 	if (err < 0) {
 		u32_clear_hw_hnode(tp, h);
@@ -522,7 +507,6 @@ static int u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h,
 
 static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
 {
-	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tcf_block *block = tp->chain->block;
 	struct tc_cls_u32_offload cls_u32 = {};
 
@@ -530,15 +514,12 @@ static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
 	cls_u32.command = TC_CLSU32_DELETE_KNODE;
 	cls_u32.knode.handle = handle;
 
-	if (tc_can_offload(dev))
-		dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, &cls_u32);
 	tc_setup_cb_call(block, NULL, TC_SETUP_CLSU32, &cls_u32, false);
 }
 
 static int u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n,
 				u32 flags)
 {
-	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tcf_block *block = tp->chain->block;
 	struct tc_cls_u32_offload cls_u32 = {};
 	bool skip_sw = tc_skip_sw(flags);
@@ -560,18 +541,6 @@ static int u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n,
 	if (n->ht_down)
 		cls_u32.knode.link_handle = n->ht_down->handle;
 
-
-	if (tc_can_offload(dev)) {
-		err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32,
-						    &cls_u32);
-		if (err) {
-			if (skip_sw)
-				return err;
-		} else {
-			n->flags |= TCA_CLS_FLAGS_IN_HW;
-		}
-	}
-
 	err = tc_setup_cb_call(block, NULL, TC_SETUP_CLSU32, &cls_u32, skip_sw);
 	if (err < 0) {
 		u32_remove_hw_knode(tp, n->handle);
-- 
2.9.5
