From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 03/10] bpf: mlx5e: Report bpf_prog ID during XDP_QUERY_PROG
Date: Mon, 12 Jun 2017 18:00:18 -0700
Message-ID: <20170613010025.2983342-4-kafai@fb.com>
References: <20170613010025.2983342-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:45634 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753222AbdFMBAa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 21:00:30 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v5D0x5C9003743
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 18:00:29 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 2b22rt8gxu-4
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 18:00:29 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:003b:0000) with ESMTP       id
 b05b9d184fd311e7bb7877a337fa907c-71b328f0 for <netdev@vger.kernel.org>;        Mon,
 12 Jun 2017 18:00:27 -0700
In-Reply-To: <20170613010025.2983342-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to mlx5e to report bpf_prog ID during XDP_QUERY_PROG.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Tariq Toukan <tariqt@mellanox.com>
Cc: Saeed Mahameed <saeedm@mellanox.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 5afec0f4a658..c3ed2e122e12 100644
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
+	xdp_prog = READ_ONCE(priv->channels.params.xdp_prog);
+	if (xdp_prog)
+		prog_id = xdp_prog->aux->id;
+	mutex_unlock(&priv->state_lock);
+
+	return prog_id;
 }
 
 static int mlx5e_xdp(struct net_device *dev, struct netdev_xdp *xdp)
@@ -3612,7 +3620,7 @@ static int mlx5e_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 	case XDP_SETUP_PROG:
 		return mlx5e_xdp_set(dev, xdp->prog);
 	case XDP_QUERY_PROG:
-		xdp->prog_attached = mlx5e_xdp_attached(dev);
+		xdp->prog_id = mlx5e_xdp_query(dev);
 		return 0;
 	default:
 		return -EINVAL;
-- 
2.9.3
