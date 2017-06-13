From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 02/10] bpf: mlx4: Report bpf_prog ID during XDP_QUERY_PROG
Date: Mon, 12 Jun 2017 18:00:17 -0700
Message-ID: <20170613010025.2983342-3-kafai@fb.com>
References: <20170613010025.2983342-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33210 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752927AbdFMBA2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 21:00:28 -0400
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5D0vNuZ024155
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 18:00:28 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b22448tgy-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 18:00:28 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.212.232.59) with ESMTP id
 aff7f3da4fd311e79aa20002c991e86a-89376b0 for <netdev@vger.kernel.org>; Mon,
 12 Jun 2017 18:00:26 -0700
In-Reply-To: <20170613010025.2983342-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to mlx4 to report bpf_prog ID during XDP_QUERY_PROG.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Tariq Toukan <tariqt@mellanox.com>
Cc: Saeed Mahameed <saeedm@mellanox.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index c1de75fc399a..ba5233d6e19b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2821,11 +2821,25 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 	return err;
 }
 
-static bool mlx4_xdp_attached(struct net_device *dev)
+static u32 mlx4_xdp_query(struct net_device *dev)
 {
+	const struct bpf_prog *xdp_prog;
 	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
+	u32 prog_id = 0;
+
+	if (!priv->tx_ring_num[TX_XDP])
+		return prog_id;
+
+	mutex_lock(&mdev->state_lock);
+	xdp_prog = rcu_dereference_protected(
+		priv->rx_ring[0]->xdp_prog,
+		lockdep_is_held(&mdev->state_lock));
+	if (xdp_prog)
+		prog_id = xdp_prog->aux->id;
+	mutex_unlock(&mdev->state_lock);
 
-	return !!priv->tx_ring_num[TX_XDP];
+	return prog_id;
 }
 
 static int mlx4_xdp(struct net_device *dev, struct netdev_xdp *xdp)
@@ -2834,7 +2848,7 @@ static int mlx4_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 	case XDP_SETUP_PROG:
 		return mlx4_xdp_set(dev, xdp->prog);
 	case XDP_QUERY_PROG:
-		xdp->prog_attached = mlx4_xdp_attached(dev);
+		xdp->prog_id = mlx4_xdp_query(dev);
 		return 0;
 	default:
 		return -EINVAL;
-- 
2.9.3
