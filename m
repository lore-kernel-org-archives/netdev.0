From: Amir Vadai <amirv@mellanox.com>
Subject: [PATH net-next v1 1/2] net/mlx4_en: Fix error propagation for ethtool helper function
Date: Mon,  4 Feb 2013 15:01:20 +0200
Message-ID: <1359982881-10139-2-git-send-email-amirv@mellanox.com>
References: <1359982881-10139-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:38026 "HELO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754254Ab3BDNBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 08:01:43 -0500
In-Reply-To: <1359982881-10139-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

Propagate return value of mlx4_en_ethtool_add_mac_rule_by_ipv4 in case of
failure.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |   52 +++++++++++++++--------
 1 files changed, 34 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 911d488..3e993d5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -732,6 +732,7 @@ static int add_ip_rule(struct mlx4_en_priv *priv,
 		       struct ethtool_rxnfc *cmd,
 		       struct list_head *list_h)
 {
+	int err;
 	struct mlx4_spec_list *spec_l2 = NULL;
 	struct mlx4_spec_list *spec_l3 = NULL;
 	struct ethtool_usrip4_spec *l3_mask = &cmd->fs.m_u.usr_ip4_spec;
@@ -740,14 +741,15 @@ static int add_ip_rule(struct mlx4_en_priv *priv,
 	spec_l2 = kzalloc(sizeof(*spec_l2), GFP_KERNEL);
 	if (!spec_l2 || !spec_l3) {
 		en_err(priv, "Fail to alloc ethtool rule.\n");
-		kfree(spec_l2);
-		kfree(spec_l3);
-		return -ENOMEM;
+		err = -ENOMEM;
+		goto free_spec;
 	}
 
-	mlx4_en_ethtool_add_mac_rule_by_ipv4(priv, cmd, list_h, spec_l2,
-					     cmd->fs.h_u.
-					     usr_ip4_spec.ip4dst);
+	err = mlx4_en_ethtool_add_mac_rule_by_ipv4(priv, cmd, list_h, spec_l2,
+						   cmd->fs.h_u.
+						   usr_ip4_spec.ip4dst);
+	if (err)
+		goto free_spec;
 	spec_l3->id = MLX4_NET_TRANS_RULE_ID_IPV4;
 	spec_l3->ipv4.src_ip = cmd->fs.h_u.usr_ip4_spec.ip4src;
 	if (l3_mask->ip4src)
@@ -758,12 +760,18 @@ static int add_ip_rule(struct mlx4_en_priv *priv,
 	list_add_tail(&spec_l3->list, list_h);
 
 	return 0;
+
+free_spec:
+	kfree(spec_l2);
+	kfree(spec_l3);
+	return err;
 }
 
 static int add_tcp_udp_rule(struct mlx4_en_priv *priv,
 			     struct ethtool_rxnfc *cmd,
 			     struct list_head *list_h, int proto)
 {
+	int err;
 	struct mlx4_spec_list *spec_l2 = NULL;
 	struct mlx4_spec_list *spec_l3 = NULL;
 	struct mlx4_spec_list *spec_l4 = NULL;
@@ -774,29 +782,31 @@ static int add_tcp_udp_rule(struct mlx4_en_priv *priv,
 	spec_l4 = kzalloc(sizeof(*spec_l4), GFP_KERNEL);
 	if (!spec_l2 || !spec_l3 || !spec_l4) {
 		en_err(priv, "Fail to alloc ethtool rule.\n");
-		kfree(spec_l2);
-		kfree(spec_l3);
-		kfree(spec_l4);
-		return -ENOMEM;
+		err = -ENOMEM;
+		goto free_spec;
 	}
 
 	spec_l3->id = MLX4_NET_TRANS_RULE_ID_IPV4;
 
 	if (proto == TCP_V4_FLOW) {
-		mlx4_en_ethtool_add_mac_rule_by_ipv4(priv, cmd, list_h,
-						     spec_l2,
-						     cmd->fs.h_u.
-						     tcp_ip4_spec.ip4dst);
+		err = mlx4_en_ethtool_add_mac_rule_by_ipv4(priv, cmd, list_h,
+							   spec_l2,
+							   cmd->fs.h_u.
+							   tcp_ip4_spec.ip4dst);
+		if (err)
+			goto free_spec;
 		spec_l4->id = MLX4_NET_TRANS_RULE_ID_TCP;
 		spec_l3->ipv4.src_ip = cmd->fs.h_u.tcp_ip4_spec.ip4src;
 		spec_l3->ipv4.dst_ip = cmd->fs.h_u.tcp_ip4_spec.ip4dst;
 		spec_l4->tcp_udp.src_port = cmd->fs.h_u.tcp_ip4_spec.psrc;
 		spec_l4->tcp_udp.dst_port = cmd->fs.h_u.tcp_ip4_spec.pdst;
 	} else {
-		mlx4_en_ethtool_add_mac_rule_by_ipv4(priv, cmd, list_h,
-						     spec_l2,
-						     cmd->fs.h_u.
-						     udp_ip4_spec.ip4dst);
+		err = mlx4_en_ethtool_add_mac_rule_by_ipv4(priv, cmd, list_h,
+							   spec_l2,
+							   cmd->fs.h_u.
+							   udp_ip4_spec.ip4dst);
+		if (err)
+			goto free_spec;
 		spec_l4->id = MLX4_NET_TRANS_RULE_ID_UDP;
 		spec_l3->ipv4.src_ip = cmd->fs.h_u.udp_ip4_spec.ip4src;
 		spec_l3->ipv4.dst_ip = cmd->fs.h_u.udp_ip4_spec.ip4dst;
@@ -818,6 +828,12 @@ static int add_tcp_udp_rule(struct mlx4_en_priv *priv,
 	list_add_tail(&spec_l4->list, list_h);
 
 	return 0;
+
+free_spec:
+	kfree(spec_l2);
+	kfree(spec_l3);
+	kfree(spec_l4);
+	return err;
 }
 
 static int mlx4_en_ethtool_to_net_trans_rule(struct net_device *dev,
-- 
1.7.8.2
