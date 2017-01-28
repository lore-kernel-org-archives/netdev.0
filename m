From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net] mlx4: xdp_prog becomes inactive after ethtool '-L' or '-G'
Date: Fri, 27 Jan 2017 23:40:51 -0800
Message-ID: <1485589251-3896393-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Brenden Blanco <bblanco@plumgrid.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:34314 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750820AbdA1IhX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2017 03:37:23 -0500
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0S7bpMg025465
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 23:40:54 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 288nrgg6an-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 23:40:54 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.223.100.99) with ESMTP id
 1822190ce52d11e6a12f24be05956610-eff5a50 for <netdev@vger.kernel.org>; Fri,
 27 Jan 2017 23:40:52 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the rx-queues ever get re-initialized (e.g. by changing the
number of rx-queues with ethtool -L), the existing xdp_prog becomes
inactive.

The bug is that the xdp_prog ptr has not been carried over from
the old rx-queues to the new rx-queues

Fixes: 47a38e155037 ("net/mlx4_en: add support for fast rx drop bpf program")
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  4 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  | 52 ++++++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  3 +-
 3 files changed, 47 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index d5a9372ed84d..9aa422691954 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -1099,7 +1099,7 @@ static int mlx4_en_set_ringparam(struct net_device *dev,
 	memcpy(&new_prof, priv->prof, sizeof(struct mlx4_en_port_profile));
 	new_prof.tx_ring_size = tx_size;
 	new_prof.rx_ring_size = rx_size;
-	err = mlx4_en_try_alloc_resources(priv, tmp, &new_prof);
+	err = mlx4_en_try_alloc_resources(priv, tmp, &new_prof, true);
 	if (err)
 		goto out;
 
@@ -1774,7 +1774,7 @@ static int mlx4_en_set_channels(struct net_device *dev,
 	new_prof.tx_ring_num[TX_XDP] = xdp_count;
 	new_prof.rx_ring_num = channel->rx_count;
 
-	err = mlx4_en_try_alloc_resources(priv, tmp, &new_prof);
+	err = mlx4_en_try_alloc_resources(priv, tmp, &new_prof, true);
 	if (err)
 		goto out;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 761f8b12399c..f4179086b3c6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2184,23 +2184,57 @@ static void mlx4_en_update_priv(struct mlx4_en_priv *dst,
 
 int mlx4_en_try_alloc_resources(struct mlx4_en_priv *priv,
 				struct mlx4_en_priv *tmp,
-				struct mlx4_en_port_profile *prof)
+				struct mlx4_en_port_profile *prof,
+				bool carry_xdp_prog)
 {
-	int t;
+	struct bpf_prog *xdp_prog = NULL;
+	int err;
+	int i;
 
 	mlx4_en_copy_priv(tmp, priv, prof);
 
+	if (carry_xdp_prog) {
+		/* All rx_rings has the same xdp_prog.  Pick the first one */
+		xdp_prog = rcu_dereference_protected(
+			priv->rx_ring[0]->xdp_prog,
+			lockdep_is_held(&priv->mdev->state_lock));
+
+		if (xdp_prog) {
+			xdp_prog = bpf_prog_add(xdp_prog, tmp->rx_ring_num);
+			if (IS_ERR(xdp_prog)) {
+				err = PTR_ERR(xdp_prog);
+				xdp_prog = NULL;
+				goto err_free;
+			}
+		}
+	}
+
 	if (mlx4_en_alloc_resources(tmp)) {
 		en_warn(priv,
 			"%s: Resource allocation failed, using previous configuration\n",
 			__func__);
-		for (t = 0; t < MLX4_EN_NUM_TX_TYPES; t++) {
-			kfree(tmp->tx_ring[t]);
-			kfree(tmp->tx_cq[t]);
-		}
-		return -ENOMEM;
+		err = -ENOMEM;
+		goto err_free;
+	}
+
+	if (xdp_prog) {
+		for (i = 0; i < tmp->rx_ring_num; i++)
+			rcu_assign_pointer(tmp->rx_ring[i]->xdp_prog,
+					   xdp_prog);
 	}
+
 	return 0;
+
+err_free:
+	if (xdp_prog)
+		bpf_prog_sub(xdp_prog, tmp->rx_ring_num);
+
+	for (i = 0; i < MLX4_EN_NUM_TX_TYPES; i++) {
+		kfree(tmp->tx_ring[i]);
+		kfree(tmp->tx_cq[i]);
+	}
+
+	return err;
 }
 
 void mlx4_en_safe_replace_resources(struct mlx4_en_priv *priv,
@@ -2755,7 +2789,7 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 		en_warn(priv, "Reducing the number of TX rings, to not exceed the max total rings number.\n");
 	}
 
-	err = mlx4_en_try_alloc_resources(priv, tmp, &new_prof);
+	err = mlx4_en_try_alloc_resources(priv, tmp, &new_prof, false);
 	if (err) {
 		if (prog)
 			bpf_prog_sub(prog, priv->rx_ring_num - 1);
@@ -3499,7 +3533,7 @@ int mlx4_en_reset_config(struct net_device *dev,
 	memcpy(&new_prof, priv->prof, sizeof(struct mlx4_en_port_profile));
 	memcpy(&new_prof.hwtstamp_config, &ts_config, sizeof(ts_config));
 
-	err = mlx4_en_try_alloc_resources(priv, tmp, &new_prof);
+	err = mlx4_en_try_alloc_resources(priv, tmp, &new_prof, true);
 	if (err)
 		goto out;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index ba1c6cd0cc79..cec59bc264c9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -679,7 +679,8 @@ void mlx4_en_set_stats_bitmap(struct mlx4_dev *dev,
 
 int mlx4_en_try_alloc_resources(struct mlx4_en_priv *priv,
 				struct mlx4_en_priv *tmp,
-				struct mlx4_en_port_profile *prof);
+				struct mlx4_en_port_profile *prof,
+				bool carry_xdp_prog);
 void mlx4_en_safe_replace_resources(struct mlx4_en_priv *priv,
 				    struct mlx4_en_priv *tmp);
 
-- 
2.5.1
