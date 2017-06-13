From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v2 net-next 3/9] bpf: mlx5e: Report bpf_prog ID during XDP_QUERY_PROG
Date: Tue, 13 Jun 2017 14:08:35 -0700
Message-ID: <20170613210841.509578-4-kafai@fb.com>
References: <20170613210841.509578-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:40850 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754076AbdFMVIu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 17:08:50 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5DL77Tx026736
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 14:08:44 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2b29g4ccn5-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 14:08:44 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.212.236.87) with ESMTP id
 7b240122507c11e7adc70002c9521c9e-587408f0 for <netdev@vger.kernel.org>;        Tue,
 13 Jun 2017 14:08:43 -0700
In-Reply-To: <20170613210841.509578-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to mlx5e to report bpf_prog ID during XDP_QUERY_PROG.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Tariq Toukan <tariqt@mellanox.com>
Cc: Saeed Mahameed <saeedm@mellanox.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 5afec0f4a658..1efbb1e1f78f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3599,11 +3599,19 @@ static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
 	return err;
 }
 
-static bool mlx5e_xdp_attached(struct net_device *dev)
+static u32 mlx5e_xdp_query(struct net_device *dev)
 {
+	const struct bpf_prog *xdp_prog;
 	struct mlx5e_priv *priv = netdev_priv(dev);
+	u32 prog_id = 0;
 
-	return !!priv->channels.params.xdp_prog;
+	mutex_lock(&priv->state_lock);
+	xdp_prog = priv->channels.params.xdp_prog;
+	if (xdp_prog)
+		prog_id = xdp_prog->aux->id;
+	mutex_unlock(&priv->state_lock);
+
+	return prog_id;
 }
 
 static int mlx5e_xdp(struct net_device *dev, struct netdev_xdp *xdp)
@@ -3612,7 +3620,8 @@ static int mlx5e_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 	case XDP_SETUP_PROG:
 		return mlx5e_xdp_set(dev, xdp->prog);
 	case XDP_QUERY_PROG:
-		xdp->prog_attached = mlx5e_xdp_attached(dev);
+		xdp->prog_id = mlx5e_xdp_query(dev);
+		xdp->prog_attached = !!xdp->prog_id;
 		return 0;
 	default:
 		return -EINVAL;
-- 
2.9.3
