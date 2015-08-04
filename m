From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 8/8] net/mlx5_core: Support physical port counters
Date: Tue,  4 Aug 2015 14:05:47 +0300
Message-ID: <1438686347-17370-9-git-send-email-amirv@mellanox.com>
References: <1438686347-17370-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36418 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932776AbbHDLGN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 07:06:13 -0400
In-Reply-To: <1438686347-17370-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Added physical port counters in the following standard formats to
ethtool statistics:
  - IEEE 802.3
  - RFC2863
  - RFC2819

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       | 75 ++++++++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 10 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 42 ++++++++++++
 include/linux/mlx5/device.h                        | 10 +++
 include/linux/mlx5/driver.h                        |  1 +
 5 files changed, 137 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 35c3390..e9d7d90 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -138,6 +138,80 @@ struct mlx5e_vport_stats {
 #define NUM_VPORT_COUNTERS     31
 };
 
+static const char pport_strings[][ETH_GSTRING_LEN] = {
+	/* IEEE802.3 counters */
+	"frames_tx",
+	"frames_rx",
+	"check_seq_err",
+	"alignment_err",
+	"octets_tx",
+	"octets_received",
+	"multicast_xmitted",
+	"broadcast_xmitted",
+	"multicast_rx",
+	"broadcast_rx",
+	"in_range_len_errors",
+	"out_of_range_len",
+	"too_long_errors",
+	"symbol_err",
+	"mac_control_tx",
+	"mac_control_rx",
+	"unsupported_op_rx",
+	"pause_ctrl_rx",
+	"pause_ctrl_tx",
+
+	/* RFC2863 counters */
+	"in_octets",
+	"in_ucast_pkts",
+	"in_discards",
+	"in_errors",
+	"in_unknown_protos",
+	"out_octets",
+	"out_ucast_pkts",
+	"out_discards",
+	"out_errors",
+	"in_multicast_pkts",
+	"in_broadcast_pkts",
+	"out_multicast_pkts",
+	"out_broadcast_pkts",
+
+	/* RFC2819 counters */
+	"drop_events",
+	"octets",
+	"pkts",
+	"broadcast_pkts",
+	"multicast_pkts",
+	"crc_align_errors",
+	"undersize_pkts",
+	"oversize_pkts",
+	"fragments",
+	"jabbers",
+	"collisions",
+	"p64octets",
+	"p65to127octets",
+	"p128to255octets",
+	"p256to511octets",
+	"p512to1023octets",
+	"p1024to1518octets",
+	"p1519to2047octets",
+	"p2048to4095octets",
+	"p4096to8191octets",
+	"p8192to10239octets",
+};
+
+#define NUM_IEEE_802_3_COUNTERS		19
+#define NUM_RFC_2863_COUNTERS		13
+#define NUM_RFC_2819_COUNTERS		21
+#define NUM_PPORT_COUNTERS		(NUM_IEEE_802_3_COUNTERS + \
+					 NUM_RFC_2863_COUNTERS + \
+					 NUM_RFC_2819_COUNTERS)
+
+struct mlx5e_pport_stats {
+	__be64 IEEE_802_3_counters[NUM_IEEE_802_3_COUNTERS];
+	__be64 RFC_2863_counters[NUM_RFC_2863_COUNTERS];
+	__be64 RFC_2819_counters[NUM_RFC_2819_COUNTERS];
+};
+
 static const char rq_stats_strings[][ETH_GSTRING_LEN] = {
 	"packets",
 	"csum_none",
@@ -180,6 +254,7 @@ struct mlx5e_sq_stats {
 
 struct mlx5e_stats {
 	struct mlx5e_vport_stats   vport;
+	struct mlx5e_pport_stats   pport;
 };
 
 struct mlx5e_params {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index b95aa33..b549797 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -171,7 +171,7 @@ static int mlx5e_get_sset_count(struct net_device *dev, int sset)
 
 	switch (sset) {
 	case ETH_SS_STATS:
-		return NUM_VPORT_COUNTERS +
+		return NUM_VPORT_COUNTERS + NUM_PPORT_COUNTERS +
 		       priv->params.num_channels * NUM_RQ_STATS +
 		       priv->params.num_channels * priv->params.num_tc *
 						   NUM_SQ_STATS;
@@ -200,6 +200,11 @@ static void mlx5e_get_strings(struct net_device *dev,
 			strcpy(data + (idx++) * ETH_GSTRING_LEN,
 			       vport_strings[i]);
 
+		/* PPORT counters */
+		for (i = 0; i < NUM_PPORT_COUNTERS; i++)
+			strcpy(data + (idx++) * ETH_GSTRING_LEN,
+			       pport_strings[i]);
+
 		/* per channel counters */
 		for (i = 0; i < priv->params.num_channels; i++)
 			for (j = 0; j < NUM_RQ_STATS; j++)
@@ -234,6 +239,9 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 	for (i = 0; i < NUM_VPORT_COUNTERS; i++)
 		data[idx++] = ((u64 *)&priv->stats.vport)[i];
 
+	for (i = 0; i < NUM_PPORT_COUNTERS; i++)
+		data[idx++] = be64_to_cpu(((__be64 *)&priv->stats.pport)[i]);
+
 	/* per channel counters */
 	for (i = 0; i < priv->params.num_channels; i++)
 		for (j = 0; j < NUM_RQ_STATS; j++)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index b8023a7..111427b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -82,6 +82,47 @@ static void mlx5e_update_carrier_work(struct work_struct *work)
 	mutex_unlock(&priv->state_lock);
 }
 
+static void mlx5e_update_pport_counters(struct mlx5e_priv *priv)
+{
+	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5e_pport_stats *s = &priv->stats.pport;
+	u32 *in;
+	u32 *out;
+	int sz = MLX5_ST_SZ_BYTES(ppcnt_reg);
+
+	in  = mlx5_vzalloc(sz);
+	out = mlx5_vzalloc(sz);
+	if (!in || !out)
+		goto free_out;
+
+	MLX5_SET(ppcnt_reg, in, local_port, 1);
+
+	MLX5_SET(ppcnt_reg, in, grp, MLX5_IEEE_802_3_COUNTERS_GROUP);
+	mlx5_core_access_reg(mdev, in, sz, out,
+			     sz, MLX5_REG_PPCNT, 0, 0);
+	memcpy(s->IEEE_802_3_counters,
+	       MLX5_ADDR_OF(ppcnt_reg, out, counter_set),
+	       sizeof(s->IEEE_802_3_counters));
+
+	MLX5_SET(ppcnt_reg, in, grp, MLX5_RFC_2863_COUNTERS_GROUP);
+	mlx5_core_access_reg(mdev, in, sz, out,
+			     sz, MLX5_REG_PPCNT, 0, 0);
+	memcpy(s->RFC_2863_counters,
+	       MLX5_ADDR_OF(ppcnt_reg, out, counter_set),
+	       sizeof(s->RFC_2863_counters));
+
+	MLX5_SET(ppcnt_reg, in, grp, MLX5_RFC_2819_COUNTERS_GROUP);
+	mlx5_core_access_reg(mdev, in, sz, out,
+			     sz, MLX5_REG_PPCNT, 0, 0);
+	memcpy(s->RFC_2819_counters,
+	       MLX5_ADDR_OF(ppcnt_reg, out, counter_set),
+	       sizeof(s->RFC_2819_counters));
+
+free_out:
+	kvfree(in);
+	kvfree(out);
+}
+
 void mlx5e_update_stats(struct mlx5e_priv *priv)
 {
 	struct mlx5_core_dev *mdev = priv->mdev;
@@ -202,6 +243,7 @@ void mlx5e_update_stats(struct mlx5e_priv *priv)
 	s->tx_csum_offload = s->tx_packets - tx_offload_none;
 	s->rx_csum_good    = s->rx_packets - s->rx_csum_none;
 
+	mlx5e_update_pport_counters(priv);
 free_out:
 	kvfree(out);
 }
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index b943cd9..250b1ff 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -1182,6 +1182,16 @@ enum {
 	MLX5_CMD_STAT_BAD_SIZE_OUTS_CQES_ERR	= 0x40,
 };
 
+enum {
+	MLX5_IEEE_802_3_COUNTERS_GROUP	      = 0x0,
+	MLX5_RFC_2863_COUNTERS_GROUP	      = 0x1,
+	MLX5_RFC_2819_COUNTERS_GROUP	      = 0x2,
+	MLX5_RFC_3635_COUNTERS_GROUP	      = 0x3,
+	MLX5_ETHERNET_EXTENDED_COUNTERS_GROUP = 0x5,
+	MLX5_PER_PRIORITY_COUNTERS_GROUP      = 0x10,
+	MLX5_PER_TRAFFIC_CLASS_COUNTERS_GROUP = 0x11
+};
+
 static inline u16 mlx5_to_sw_pkey_sz(int pkey_sz)
 {
 	if (pkey_sz > MLX5_MAX_LOG_PKEY_TABLE)
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 5fe0cae..2039546 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -103,6 +103,7 @@ enum {
 	MLX5_REG_PMTU		 = 0x5003,
 	MLX5_REG_PTYS		 = 0x5004,
 	MLX5_REG_PAOS		 = 0x5006,
+	MLX5_REG_PPCNT		 = 0x5008,
 	MLX5_REG_PMAOS		 = 0x5012,
 	MLX5_REG_PUDE		 = 0x5009,
 	MLX5_REG_PMPE		 = 0x5010,
-- 
2.4.3.413.ga5fe668
