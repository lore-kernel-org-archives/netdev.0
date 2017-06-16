From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v3 net-next 3/9] bpf: mlx5e: Report bpf_prog ID during XDP_QUERY_PROG
Date: Thu, 15 Jun 2017 17:29:11 -0700
Message-ID: <20170616002917.2976329-4-kafai@fb.com>
References: <20170616002917.2976329-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:43209 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751869AbdFPA3V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 20:29:21 -0400
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5G0PEwx001935
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 17:29:20 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b42c50dtu-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 17:29:20 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:003b:0000) with ESMTP       id
 d628b1f8522a11e782aa6fbdf6e974f4-a63348f0 for <netdev@vger.kernel.org>;        Thu,
 15 Jun 2017 17:29:19 -0700
In-Reply-To: <20170616002917.2976329-1-kafai@fb.com>
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
index 5afec0f4a658..c8f3aefe735d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3599,11 +3599,19 @@ static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
 	return err;
 }
 
-static bool mlx5e_xdp_attached(struct net_device *dev)
+static u32 mlx5e_xdp_query(struct net_device *dev)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
+	const struct bpf_prog *xdp_prog;
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
