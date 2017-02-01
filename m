From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net v2 2/2] mlx4: xdp_prog becomes inactive after ethtool '-L' or '-G'
Date: Tue, 31 Jan 2017 22:35:33 -0800
Message-ID: <1485930933-4159518-3-git-send-email-kafai@fb.com>
References: <1485930933-4159518-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:40921 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751004AbdBAGfk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 01:35:40 -0500
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v116Wtxp011375
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 22:35:34 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 28b7p18awm-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 22:35:34 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 a1f938d6e84811e6b3ae0002c99293a0-ac1f7a50 for <netdev@vger.kernel.org>;        Tue,
 31 Jan 2017 22:35:33 -0800
In-Reply-To: <1485930933-4159518-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After calling mlx4_en_try_alloc_resources (e.g. by changing the
number of rx-queues with ethtool -L), the existing xdp_prog becomes
inactive.

The bug is that the xdp_prog ptr has not been carried over from
the old rx-queues to the new rx-queues

Fixes: 47a38e155037 ("net/mlx4_en: add support for fast rx drop bpf program")
Cc: Brenden Blanco <bblanco@plumgrid.com>
Cc: Saeed Mahameed <saeedm@mellanox.com>
Cc: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  4 ++--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  | 27 +++++++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  3 ++-
 3 files changed, 27 insertions(+), 7 deletions(-)

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
index 3abcead208d2..3b4961a8e8e4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2186,9 +2186,11 @@ static void mlx4_en_update_priv(struct mlx4_en_priv *dst,
 
 int mlx4_en_try_alloc_resources(struct mlx4_en_priv *priv,
 				struct mlx4_en_priv *tmp,
-				struct mlx4_en_port_profile *prof)
+				struct mlx4_en_port_profile *prof,
+				bool carry_xdp_prog)
 {
-	int t;
+	struct bpf_prog *xdp_prog;
+	int i, t;
 
 	mlx4_en_copy_priv(tmp, priv, prof);
 
@@ -2202,6 +2204,23 @@ int mlx4_en_try_alloc_resources(struct mlx4_en_priv *priv,
 		}
 		return -ENOMEM;
 	}
+
+	/* All rx_rings has the same xdp_prog.  Pick the first one. */
+	xdp_prog = rcu_dereference_protected(
+		priv->rx_ring[0]->xdp_prog,
+		lockdep_is_held(&priv->mdev->state_lock));
+
+	if (xdp_prog && carry_xdp_prog) {
+		xdp_prog = bpf_prog_add(xdp_prog, tmp->rx_ring_num);
+		if (IS_ERR(xdp_prog)) {
+			mlx4_en_free_resources(tmp);
+			return PTR_ERR(xdp_prog);
+		}
+		for (i = 0; i < tmp->rx_ring_num; i++)
+			rcu_assign_pointer(tmp->rx_ring[i]->xdp_prog,
+					   xdp_prog);
+	}
+
 	return 0;
 }
 
@@ -2751,7 +2770,7 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 		en_warn(priv, "Reducing the number of TX rings, to not exceed the max total rings number.\n");
 	}
 
-	err = mlx4_en_try_alloc_resources(priv, tmp, &new_prof);
+	err = mlx4_en_try_alloc_resources(priv, tmp, &new_prof, false);
 	if (err) {
 		if (prog)
 			bpf_prog_sub(prog, priv->rx_ring_num - 1);
@@ -3495,7 +3514,7 @@ int mlx4_en_reset_config(struct net_device *dev,
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
