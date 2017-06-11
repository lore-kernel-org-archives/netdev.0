From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 8/9] net/mlx5e: Add support for reading connector type from PTYS
Date: Sun, 11 Jun 2017 17:55:52 +0300
Message-ID: <20170611145553.14180-9-saeedm@mellanox.com>
References: <20170611145553.14180-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46663 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751973AbdFKO4O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 10:56:14 -0400
In-Reply-To: <20170611145553.14180-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Read port connector type from the firmware instead of caching it in the
driver metadata.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 22 ++++++++++++++++++++--
 include/linux/mlx5/mlx5_ifc.h                      |  7 +++++--
 include/linux/mlx5/port.h                          | 13 +++++++++++++
 3 files changed, 38 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index e9e33fd68279..f03c2d088d0c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -809,8 +809,23 @@ static void get_advertising(u32 eth_proto_cap, u8 tx_pause,
 		ethtool_link_ksettings_add_link_mode(link_ksettings, advertising, Asym_Pause);
 }
 
-static u8 get_connector_port(u32 eth_proto)
+static int ptys2connector_type[MLX5E_CONNECTOR_TYPE_NUMBER] = {
+		[MLX5E_PORT_UNKNOWN]            = PORT_OTHER,
+		[MLX5E_PORT_NONE]               = PORT_NONE,
+		[MLX5E_PORT_TP]                 = PORT_TP,
+		[MLX5E_PORT_AUI]                = PORT_AUI,
+		[MLX5E_PORT_BNC]                = PORT_BNC,
+		[MLX5E_PORT_MII]                = PORT_MII,
+		[MLX5E_PORT_FIBRE]              = PORT_FIBRE,
+		[MLX5E_PORT_DA]                 = PORT_DA,
+		[MLX5E_PORT_OTHER]              = PORT_OTHER,
+	};
+
+static u8 get_connector_port(u32 eth_proto, u8 connector_type)
 {
+	if (connector_type && connector_type < MLX5E_CONNECTOR_TYPE_NUMBER)
+		return ptys2connector_type[connector_type];
+
 	if (eth_proto & (MLX5E_PROT_MASK(MLX5E_10GBASE_SR)
 			 | MLX5E_PROT_MASK(MLX5E_40GBASE_SR4)
 			 | MLX5E_PROT_MASK(MLX5E_100GBASE_SR4)
@@ -856,6 +871,7 @@ static int mlx5e_get_link_ksettings(struct net_device *netdev,
 	u32 eth_proto_oper;
 	u8 an_disable_admin;
 	u8 an_status;
+	u8 connector_type;
 	int err;
 
 	err = mlx5_query_port_ptys(mdev, out, sizeof(out), MLX5_PTYS_EN, 1);
@@ -871,6 +887,7 @@ static int mlx5e_get_link_ksettings(struct net_device *netdev,
 	eth_proto_lp     = MLX5_GET(ptys_reg, out, eth_proto_lp_advertise);
 	an_disable_admin = MLX5_GET(ptys_reg, out, an_disable_admin);
 	an_status        = MLX5_GET(ptys_reg, out, an_status);
+	connector_type   = MLX5_GET(ptys_reg, out, connector_type);
 
 	mlx5_query_port_pause(mdev, &rx_pause, &tx_pause);
 
@@ -883,7 +900,8 @@ static int mlx5e_get_link_ksettings(struct net_device *netdev,
 
 	eth_proto_oper = eth_proto_oper ? eth_proto_oper : eth_proto_cap;
 
-	link_ksettings->base.port = get_connector_port(eth_proto_oper);
+	link_ksettings->base.port = get_connector_port(eth_proto_oper,
+						       connector_type);
 	get_lp_advertising(eth_proto_lp, link_ksettings);
 
 	if (an_status == MLX5_AN_COMPLETE)
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index ec308657af3b..32b044e953d2 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -7295,7 +7295,8 @@ struct mlx5_ifc_ptys_reg_bits {
 	u8         ib_link_width_oper[0x10];
 	u8         ib_proto_oper[0x10];
 
-	u8         reserved_at_160[0x20];
+	u8         reserved_at_160[0x1c];
+	u8         connector_type[0x4];
 
 	u8         eth_proto_lp_advertise[0x20];
 
@@ -7698,8 +7699,10 @@ struct mlx5_ifc_peir_reg_bits {
 };
 
 struct mlx5_ifc_pcam_enhanced_features_bits {
-	u8         reserved_at_0[0x7e];
+	u8         reserved_at_0[0x7c];
 
+	u8         ptys_connector_type[0x1];
+	u8         reserved_at_7d[0x1];
 	u8         ppcnt_discard_group[0x1];
 	u8         ppcnt_statistical_group[0x1];
 };
diff --git a/include/linux/mlx5/port.h b/include/linux/mlx5/port.h
index e527732fb31b..c57d4b7de3a8 100644
--- a/include/linux/mlx5/port.h
+++ b/include/linux/mlx5/port.h
@@ -92,6 +92,19 @@ enum mlx5e_link_mode {
 	MLX5E_LINK_MODES_NUMBER,
 };
 
+enum mlx5e_connector_type {
+	MLX5E_PORT_UNKNOWN	= 0,
+	MLX5E_PORT_NONE			= 1,
+	MLX5E_PORT_TP			= 2,
+	MLX5E_PORT_AUI			= 3,
+	MLX5E_PORT_BNC			= 4,
+	MLX5E_PORT_MII			= 5,
+	MLX5E_PORT_FIBRE		= 6,
+	MLX5E_PORT_DA			= 7,
+	MLX5E_PORT_OTHER		= 8,
+	MLX5E_CONNECTOR_TYPE_NUMBER,
+};
+
 #define MLX5E_PROT_MASK(link_mode) (1 << link_mode)
 
 #define PORT_MODULE_EVENT_MODULE_STATUS_MASK 0xF
-- 
2.11.0
