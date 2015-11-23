From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 17/18] net/mlx5: E-Switch, Introduce get vf statistics
Date: Mon, 23 Nov 2015 13:11:50 +0200
Message-ID: <1448277111-16474-18-git-send-email-ogerlitz@mellanox.com>
References: <1448277111-16474-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Don Dutile <ddutile@redhat.com>,
	Doug Ledford <dledford@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37149 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750941AbbKWLM3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 06:12:29 -0500
In-Reply-To: <1448277111-16474-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Add support to get VF statistics using query vport
counter command.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 67 +++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h |  3 +
 2 files changed, 70 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index ea14664..8f428bf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -1213,3 +1213,70 @@ int mlx5_eswitch_set_vport_vlan(struct mlx5_eswitch *esw,
 
 	return modify_esw_vport_cvlan(esw->dev, vport, vlan, qos, set);
 }
+
+int mlx5_eswitch_get_vport_stats(struct mlx5_eswitch *esw,
+				 int vport,
+				 struct ifla_vf_stats *vf_stats)
+{
+	int outlen = MLX5_ST_SZ_BYTES(query_vport_counter_out);
+	u32 in[MLX5_ST_SZ_DW(query_vport_counter_in)];
+	int err = 0;
+	u32 *out;
+
+	if (!ESW_ALLOWED(esw))
+		return -EPERM;
+	if (!LEGAL_VPORT(esw, vport))
+		return -EINVAL;
+
+	out = mlx5_vzalloc(outlen);
+	if (!out)
+		return -ENOMEM;
+
+	memset(in, 0, sizeof(in));
+
+	MLX5_SET(query_vport_counter_in, in, opcode,
+		 MLX5_CMD_OP_QUERY_VPORT_COUNTER);
+	MLX5_SET(query_vport_counter_in, in, op_mod, 0);
+	MLX5_SET(query_vport_counter_in, in, vport_number, vport);
+	if (vport)
+		MLX5_SET(query_vport_counter_in, in, other_vport, 1);
+
+	memset(out, 0, outlen);
+	err = mlx5_cmd_exec(esw->dev, in, sizeof(in), out, outlen);
+	if (err)
+		goto free_out;
+
+	#define MLX5_GET_CTR(p, x) \
+		MLX5_GET64(query_vport_counter_out, p, x)
+
+	memset(vf_stats, 0, sizeof(*vf_stats));
+	vf_stats->rx_packets =
+		MLX5_GET_CTR(out, received_eth_unicast.packets) +
+		MLX5_GET_CTR(out, received_eth_multicast.packets) +
+		MLX5_GET_CTR(out, received_eth_broadcast.packets);
+
+	vf_stats->rx_bytes =
+		MLX5_GET_CTR(out, received_eth_unicast.octets) +
+		MLX5_GET_CTR(out, received_eth_multicast.octets) +
+		MLX5_GET_CTR(out, received_eth_broadcast.octets);
+
+	vf_stats->tx_packets =
+		MLX5_GET_CTR(out, transmitted_eth_unicast.packets) +
+		MLX5_GET_CTR(out, transmitted_eth_multicast.packets) +
+		MLX5_GET_CTR(out, transmitted_eth_broadcast.packets);
+
+	vf_stats->tx_bytes =
+		MLX5_GET_CTR(out, transmitted_eth_unicast.octets) +
+		MLX5_GET_CTR(out, transmitted_eth_multicast.octets) +
+		MLX5_GET_CTR(out, transmitted_eth_broadcast.octets);
+
+	vf_stats->multicast =
+		MLX5_GET_CTR(out, received_eth_multicast.packets);
+
+	vf_stats->broadcast =
+		MLX5_GET_CTR(out, received_eth_broadcast.packets);
+
+free_out:
+	kvfree(out);
+	return err;
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index b4284a4..9bac542 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -154,5 +154,8 @@ int mlx5_eswitch_set_vport_vlan(struct mlx5_eswitch *esw,
 				int vport, u16 vlan, u8 qos);
 int mlx5_eswitch_get_vport_config(struct mlx5_eswitch *esw,
 				  int vport, struct ifla_vf_info *ivi);
+int mlx5_eswitch_get_vport_stats(struct mlx5_eswitch *esw,
+				 int vport,
+				 struct ifla_vf_stats *vf_stats);
 #endif /* __MLX5_ESWITCH_H__ */
 
-- 
2.3.7
