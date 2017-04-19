From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net v2] net/mlx5e: Fix race in mlx5e_sw_stats and mlx5e_vport_stats
Date: Wed, 19 Apr 2017 16:32:59 -0700
Message-ID: <20170419233259.2255806-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Eric Dumazet <eric.dumazet@gmail.com>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:42105 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S967234AbdDSXdC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 19:33:02 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3JNVahe001778
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 16:33:01 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 29xg398cpd-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 16:33:01 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.222.219.45) with ESMTP id
 8632c5b6255811e7b4b224be05904660-e39f29a0 for <netdev@vger.kernel.org>;        Wed,
 19 Apr 2017 16:32:59 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have observed a sudden spike in rx/tx_packets and rx/tx_bytes
reported under /proc/net/dev.  There is a race in mlx5e_update_stats()
and some of the get-stats functions (the one that we hit is the
mlx5e_get_stats() which is called by ndo_get_stats64()).

In particular, the very first thing mlx5e_update_sw_counters()
does is 'memset(s, 0, sizeof(*s))'.  For example, if mlx5e_get_stats()
is unlucky at one point, rx_bytes and rx_packets could be 0.  One second
later, a normal (and much bigger than 0) value will be reported.

This patch is to use a 'struct mlx5e_sw_stats temp' to avoid
a direct memset zero on priv->stats.sw.

mlx5e_update_vport_counters() has a similar race.  Hence, addressed
together.

I am lucky enough to catch this 0-reset in rx multicast:
eth0: 41457665   76804   70    0    0    70          0     47085 15586634   87502    3    0    0     0       3          0
eth0: 41459860   76815   70    0    0    70          0     47094 15588376   87516    3    0    0     0       3          0
eth0: 41460577   76822   70    0    0    70          0         0 15589083   87521    3    0    0     0       3          0
eth0: 41463293   76838   70    0    0    70          0     47108 15595872   87538    3    0    0     0       3          0
eth0: 41463379   76839   70    0    0    70          0     47116 15596138   87539    3    0    0     0       3          0

Cc: Saeed Mahameed <saeedm@mellanox.com>
Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 66c133757a5e..246786bb861b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -174,7 +174,7 @@ static void mlx5e_tx_timeout_work(struct work_struct *work)
 
 static void mlx5e_update_sw_counters(struct mlx5e_priv *priv)
 {
-	struct mlx5e_sw_stats *s = &priv->stats.sw;
+	struct mlx5e_sw_stats temp, *s = &temp;
 	struct mlx5e_rq_stats *rq_stats;
 	struct mlx5e_sq_stats *sq_stats;
 	u64 tx_offload_none = 0;
@@ -229,12 +229,14 @@ static void mlx5e_update_sw_counters(struct mlx5e_priv *priv)
 	s->link_down_events_phy = MLX5_GET(ppcnt_reg,
 				priv->stats.pport.phy_counters,
 				counter_set.phys_layer_cntrs.link_down_events);
+	memcpy(&priv->stats.sw, s, sizeof(*s));
 }
 
 static void mlx5e_update_vport_counters(struct mlx5e_priv *priv)
 {
+	struct mlx5e_vport_stats temp;
 	int outlen = MLX5_ST_SZ_BYTES(query_vport_counter_out);
-	u32 *out = (u32 *)priv->stats.vport.query_vport_out;
+	u32 *out = (u32 *)temp.query_vport_out;
 	u32 in[MLX5_ST_SZ_DW(query_vport_counter_in)] = {0};
 	struct mlx5_core_dev *mdev = priv->mdev;
 
@@ -245,6 +247,7 @@ static void mlx5e_update_vport_counters(struct mlx5e_priv *priv)
 
 	memset(out, 0, outlen);
 	mlx5_cmd_exec(mdev, in, sizeof(in), out, outlen);
+	memcpy(priv->stats.vport.query_vport_out, out, outlen);
 }
 
 static void mlx5e_update_pport_counters(struct mlx5e_priv *priv)
-- 
2.9.3
