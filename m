From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 3/4] net: sched: convert cls_flower->egress_dev users to tc_setup_cb_egdev infra
Date: Wed, 11 Oct 2017 09:41:09 +0200
Message-ID: <20171011074110.2800-4-jiri@resnulli.us>
References: <20171011074110.2800-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        mlxsw@mellanox.com, David.Laight@ACULAB.COM, gerlitz.or@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33921 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751952AbdJKHlP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 03:41:15 -0400
Received: by mail-wr0-f196.google.com with SMTP id l1so536797wrc.1
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 00:41:15 -0700 (PDT)
In-Reply-To: <20171011074110.2800-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The only user of cls_flower->egress_dev is mlx5. So do the conversion
there alongside with the code originating the call in cls_flower
function fl_hw_replace_filter to the newly introduced egress device
callback infrastucture.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  3 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c  | 31 +++++++----
 include/net/pkt_cls.h                             |  5 +-
 net/sched/cls_api.c                               | 13 +++--
 net/sched/cls_flower.c                            | 63 ++++++++++++-----------
 6 files changed, 73 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index cc13d3d..5ec6d3e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -1081,6 +1081,9 @@ int mlx5e_ethtool_get_ts_info(struct mlx5e_priv *priv,
 int mlx5e_ethtool_flash_device(struct mlx5e_priv *priv,
 			       struct ethtool_flash *flash);
 
+int mlx5e_setup_tc(struct net_device *dev, enum tc_setup_type type,
+		   void *type_data);
+
 /* mlx5e generic netdev management API */
 struct net_device*
 mlx5e_create_netdev(struct mlx5_core_dev *mdev, const struct mlx5e_profile *profile,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index cc11bbb..2a32102 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3108,8 +3108,8 @@ static int mlx5e_setup_tc_cls_flower(struct net_device *dev,
 }
 #endif
 
-static int mlx5e_setup_tc(struct net_device *dev, enum tc_setup_type type,
-			  void *type_data)
+int mlx5e_setup_tc(struct net_device *dev, enum tc_setup_type type,
+		   void *type_data)
 {
 	switch (type) {
 #ifdef CONFIG_MLX5_ESWITCH
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 45e03c4..765fc74 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -34,6 +34,7 @@
 #include <linux/mlx5/fs.h>
 #include <net/switchdev.h>
 #include <net/pkt_cls.h>
+#include <net/act_api.h>
 #include <net/netevent.h>
 #include <net/arp.h>
 
@@ -667,14 +668,6 @@ mlx5e_rep_setup_tc_cls_flower(struct net_device *dev,
 	    cls_flower->common.chain_index)
 		return -EOPNOTSUPP;
 
-	if (cls_flower->egress_dev) {
-		struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
-
-		dev = mlx5_eswitch_get_uplink_netdev(esw);
-		return dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER,
-						     cls_flower);
-	}
-
 	switch (cls_flower->command) {
 	case TC_CLSFLOWER_REPLACE:
 		return mlx5e_configure_flower(priv, cls_flower);
@@ -698,6 +691,14 @@ static int mlx5e_rep_setup_tc(struct net_device *dev, enum tc_setup_type type,
 	}
 }
 
+static int mlx5e_rep_setup_tc_cb(enum tc_setup_type type, void *type_data,
+				 void *cb_priv)
+{
+	struct net_device *dev = cb_priv;
+
+	return mlx5e_setup_tc(dev, type, type_data);
+}
+
 bool mlx5e_is_uplink_rep(struct mlx5e_priv *priv)
 {
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
@@ -1017,15 +1018,24 @@ mlx5e_vport_rep_load(struct mlx5_eswitch *esw, struct mlx5_eswitch_rep *rep)
 		goto err_detach_netdev;
 	}
 
+	err = tc_setup_cb_egdev_register(netdev, mlx5e_rep_setup_tc_cb,
+					 mlx5_eswitch_get_uplink_netdev(esw));
+	if (err)
+		goto err_neigh_cleanup;
+
 	err = register_netdev(netdev);
 	if (err) {
 		pr_warn("Failed to register representor netdev for vport %d\n",
 			rep->vport);
-		goto err_neigh_cleanup;
+		goto err_egdev_cleanup;
 	}
 
 	return 0;
 
+err_egdev_cleanup:
+	tc_setup_cb_egdev_unregister(netdev, mlx5e_rep_setup_tc_cb,
+				     mlx5_eswitch_get_uplink_netdev(esw));
+
 err_neigh_cleanup:
 	mlx5e_rep_neigh_cleanup(rpriv);
 
@@ -1047,7 +1057,8 @@ mlx5e_vport_rep_unload(struct mlx5_eswitch *esw, struct mlx5_eswitch_rep *rep)
 	void *ppriv = priv->ppriv;
 
 	unregister_netdev(rep->netdev);
-
+	tc_setup_cb_egdev_unregister(netdev, mlx5e_rep_setup_tc_cb,
+				     mlx5_eswitch_get_uplink_netdev(esw));
 	mlx5e_rep_neigh_cleanup(rpriv);
 	mlx5e_detach_netdev(priv);
 	mlx5e_destroy_netdev(priv);
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 6f8149c..c0bdf5c 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -206,8 +206,6 @@ int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts);
 int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts);
 int tcf_exts_get_dev(struct net_device *dev, struct tcf_exts *exts,
 		     struct net_device **hw_dev);
-int tcf_exts_egdev_cb_call(struct tcf_exts *exts, enum tc_setup_type type,
-			   void *type_data, bool err_stop);
 
 /**
  * struct tcf_pkt_info - packet information
@@ -407,6 +405,9 @@ tcf_match_indev(struct sk_buff *skb, int ifindex)
 }
 #endif /* CONFIG_NET_CLS_IND */
 
+int tc_setup_cb_call(struct tcf_exts *exts, enum tc_setup_type type,
+		     void *type_data, bool err_stop);
+
 struct tc_cls_common_offload {
 	u32 chain_index;
 	__be16 protocol;
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 99f9432..51994a2 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -1026,8 +1026,9 @@ int tcf_exts_get_dev(struct net_device *dev, struct tcf_exts *exts,
 }
 EXPORT_SYMBOL(tcf_exts_get_dev);
 
-int tcf_exts_egdev_cb_call(struct tcf_exts *exts, enum tc_setup_type type,
-			   void *type_data, bool err_stop)
+static int tc_exts_setup_cb_egdev_call(struct tcf_exts *exts,
+				       enum tc_setup_type type,
+				       void *type_data, bool err_stop)
 {
 	int ok_count = 0;
 #ifdef CONFIG_NET_CLS_ACT
@@ -1054,7 +1055,13 @@ int tcf_exts_egdev_cb_call(struct tcf_exts *exts, enum tc_setup_type type,
 #endif
 	return ok_count;
 }
-EXPORT_SYMBOL(tcf_exts_egdev_cb_call);
+
+int tc_setup_cb_call(struct tcf_exts *exts, enum tc_setup_type type,
+		     void *type_data, bool err_stop)
+{
+	return tc_exts_setup_cb_egdev_call(exts, type, type_data, err_stop);
+}
+EXPORT_SYMBOL(tc_setup_cb_call);
 
 static int __init tc_filter_init(void)
 {
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index db831ac..5b7bb96 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -88,7 +88,6 @@ struct cls_fl_filter {
 	u32 handle;
 	u32 flags;
 	struct rcu_head	rcu;
-	struct net_device *hw_dev;
 };
 
 static unsigned short int fl_mask_range(const struct fl_flow_mask *mask)
@@ -201,16 +200,17 @@ static void fl_destroy_filter(struct rcu_head *head)
 static void fl_hw_destroy_filter(struct tcf_proto *tp, struct cls_fl_filter *f)
 {
 	struct tc_cls_flower_offload cls_flower = {};
-	struct net_device *dev = f->hw_dev;
-
-	if (!tc_can_offload(dev))
-		return;
+	struct net_device *dev = tp->q->dev_queue->dev;
 
 	tc_cls_common_offload_init(&cls_flower.common, tp);
 	cls_flower.command = TC_CLSFLOWER_DESTROY;
 	cls_flower.cookie = (unsigned long) f;
 
-	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER, &cls_flower);
+	if (tc_can_offload(dev))
+		dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER,
+					      &cls_flower);
+	tc_setup_cb_call(&f->exts, TC_SETUP_CLSFLOWER,
+			 &cls_flower, false);
 }
 
 static int fl_hw_replace_filter(struct tcf_proto *tp,
@@ -220,20 +220,9 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_flower_offload cls_flower = {};
+	bool skip_sw = tc_skip_sw(f->flags);
 	int err;
 
-	if (!tc_can_offload(dev)) {
-		if (tcf_exts_get_dev(dev, &f->exts, &f->hw_dev) ||
-		    (f->hw_dev && !tc_can_offload(f->hw_dev))) {
-			f->hw_dev = dev;
-			return tc_skip_sw(f->flags) ? -EINVAL : 0;
-		}
-		dev = f->hw_dev;
-		cls_flower.egress_dev = true;
-	} else {
-		f->hw_dev = dev;
-	}
-
 	tc_cls_common_offload_init(&cls_flower.common, tp);
 	cls_flower.command = TC_CLSFLOWER_REPLACE;
 	cls_flower.cookie = (unsigned long) f;
@@ -242,31 +231,47 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 	cls_flower.key = &f->mkey;
 	cls_flower.exts = &f->exts;
 
-	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER,
-					    &cls_flower);
-	if (!err)
-		f->flags |= TCA_CLS_FLAGS_IN_HW;
+	if (tc_can_offload(dev)) {
+		err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER,
+						    &cls_flower);
+		if (err) {
+			if (skip_sw)
+				return err;
+		} else {
+			f->flags |= TCA_CLS_FLAGS_IN_HW;
+		}
+	}
 
-	if (tc_skip_sw(f->flags))
+	err = tc_setup_cb_call(&f->exts, TC_SETUP_CLSFLOWER,
+			       &cls_flower, skip_sw);
+	if (err < 0) {
+		fl_hw_destroy_filter(tp, f);
 		return err;
+	} else if (err > 0) {
+		f->flags |= TCA_CLS_FLAGS_IN_HW;
+	}
+
+	if (skip_sw && !(f->flags & TCA_CLS_FLAGS_IN_HW))
+		return -EINVAL;
+
 	return 0;
 }
 
 static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
 {
 	struct tc_cls_flower_offload cls_flower = {};
-	struct net_device *dev = f->hw_dev;
-
-	if (!tc_can_offload(dev))
-		return;
+	struct net_device *dev = tp->q->dev_queue->dev;
 
 	tc_cls_common_offload_init(&cls_flower.common, tp);
 	cls_flower.command = TC_CLSFLOWER_STATS;
 	cls_flower.cookie = (unsigned long) f;
 	cls_flower.exts = &f->exts;
 
-	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER,
-				      &cls_flower);
+	if (tc_can_offload(dev))
+		dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER,
+					      &cls_flower);
+	tc_setup_cb_call(&f->exts, TC_SETUP_CLSFLOWER,
+			 &cls_flower, false);
 }
 
 static void __fl_delete(struct tcf_proto *tp, struct cls_fl_filter *f)
-- 
2.9.5
