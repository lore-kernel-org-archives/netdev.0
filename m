From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 08/16] mlxsw: spectrum: push cls_flower and cls_matchall setup_tc processing into separate functions
Date: Mon,  7 Aug 2017 10:15:24 +0200
Message-ID: <20170807081532.32760-9-jiri@resnulli.us>
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
Received: from mail-wr0-f193.google.com ([209.85.128.193]:35282 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752006AbdHGIPs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 04:15:48 -0400
Received: by mail-wr0-f193.google.com with SMTP id c24so7109716wra.2
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 01:15:47 -0700 (PDT)
In-Reply-To: <20170807081532.32760-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Let mlxsw_sp_setup_tc be a splitter for specific setup_tc types and push
out cls_flower and cls_matchall specific codes into separate functions.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 81 ++++++++++++++++----------
 1 file changed, 51 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 6438c38..9f8ba37 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1693,46 +1693,67 @@ static void mlxsw_sp_port_del_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 	kfree(mall_tc_entry);
 }
 
-static int mlxsw_sp_setup_tc(struct net_device *dev, enum tc_setup_type type,
+static int mlxsw_sp_setup_tc_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
+					  u32 handle, u32 chain_index,
+					  __be16 proto,
+					  struct tc_cls_matchall_offload *f)
+{
+	bool ingress = TC_H_MAJ(handle) == TC_H_MAJ(TC_H_INGRESS);
+
+	if (chain_index)
+		return -EOPNOTSUPP;
+
+	switch (f->command) {
+	case TC_CLSMATCHALL_REPLACE:
+		return mlxsw_sp_port_add_cls_matchall(mlxsw_sp_port, proto, f,
+						      ingress);
+	case TC_CLSMATCHALL_DESTROY:
+		mlxsw_sp_port_del_cls_matchall(mlxsw_sp_port, f);
+		return 0;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static int
+mlxsw_sp_setup_tc_cls_flower(struct mlxsw_sp_port *mlxsw_sp_port,
 			     u32 handle, u32 chain_index, __be16 proto,
-			     struct tc_to_netdev *tc)
+			     struct tc_cls_flower_offload *f)
 {
-	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	bool ingress = TC_H_MAJ(handle) == TC_H_MAJ(TC_H_INGRESS);
 
 	if (chain_index)
 		return -EOPNOTSUPP;
 
+	switch (f->command) {
+	case TC_CLSFLOWER_REPLACE:
+		return mlxsw_sp_flower_replace(mlxsw_sp_port, ingress,
+					       proto, f);
+	case TC_CLSFLOWER_DESTROY:
+		mlxsw_sp_flower_destroy(mlxsw_sp_port, ingress, f);
+		return 0;
+	case TC_CLSFLOWER_STATS:
+		return mlxsw_sp_flower_stats(mlxsw_sp_port, ingress, f);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static int mlxsw_sp_setup_tc(struct net_device *dev, enum tc_setup_type type,
+			     u32 handle, u32 chain_index, __be16 proto,
+			     struct tc_to_netdev *tc)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+
 	switch (type) {
 	case TC_SETUP_CLSMATCHALL:
-		switch (tc->cls_mall->command) {
-		case TC_CLSMATCHALL_REPLACE:
-			return mlxsw_sp_port_add_cls_matchall(mlxsw_sp_port,
-							      proto,
-							      tc->cls_mall,
-							      ingress);
-		case TC_CLSMATCHALL_DESTROY:
-			mlxsw_sp_port_del_cls_matchall(mlxsw_sp_port,
-						       tc->cls_mall);
-			return 0;
-		default:
-			return -EOPNOTSUPP;
-		}
+		return mlxsw_sp_setup_tc_cls_matchall(mlxsw_sp_port, handle,
+						      chain_index, proto,
+						      tc->cls_mall);
 	case TC_SETUP_CLSFLOWER:
-		switch (tc->cls_flower->command) {
-		case TC_CLSFLOWER_REPLACE:
-			return mlxsw_sp_flower_replace(mlxsw_sp_port, ingress,
-						       proto, tc->cls_flower);
-		case TC_CLSFLOWER_DESTROY:
-			mlxsw_sp_flower_destroy(mlxsw_sp_port, ingress,
-						tc->cls_flower);
-			return 0;
-		case TC_CLSFLOWER_STATS:
-			return mlxsw_sp_flower_stats(mlxsw_sp_port, ingress,
-						     tc->cls_flower);
-		default:
-			return -EOPNOTSUPP;
-		}
+		return mlxsw_sp_setup_tc_cls_flower(mlxsw_sp_port, handle,
+						    chain_index, proto,
+						    tc->cls_flower);
 	default:
 		return -EOPNOTSUPP;
 	}
-- 
2.9.3
