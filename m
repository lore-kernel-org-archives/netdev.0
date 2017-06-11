From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 9/9] net/mlx5e: Fill advertised and supported port data from Hardware info
Date: Sun, 11 Jun 2017 17:55:53 +0300
Message-ID: <20170611145553.14180-10-saeedm@mellanox.com>
References: <20170611145553.14180-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46654 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751912AbdFKO4O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 10:56:14 -0400
In-Reply-To: <20170611145553.14180-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Translate hardware port connector type data into link mode supported and
advertised info instead of caching it in driver.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 90 ++++++++++++++++++----
 1 file changed, 74 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index f03c2d088d0c..b4514f247402 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -723,24 +723,81 @@ static void ptys2ethtool_adver_link(unsigned long *advertising_modes,
 			  __ETHTOOL_LINK_MODE_MASK_NBITS);
 }
 
-static void ptys2ethtool_supported_port(struct ethtool_link_ksettings *link_ksettings,
-					u32 eth_proto_cap)
+static void ptys2ethtool_supported_advertised_port(struct ethtool_link_ksettings *link_ksettings,
+						   u32 eth_proto_cap,
+						   u8 connector_type)
 {
-	if (eth_proto_cap & (MLX5E_PROT_MASK(MLX5E_10GBASE_CR)
-			   | MLX5E_PROT_MASK(MLX5E_10GBASE_SR)
-			   | MLX5E_PROT_MASK(MLX5E_40GBASE_CR4)
-			   | MLX5E_PROT_MASK(MLX5E_40GBASE_SR4)
-			   | MLX5E_PROT_MASK(MLX5E_100GBASE_SR4)
-			   | MLX5E_PROT_MASK(MLX5E_1000BASE_CX_SGMII))) {
-		ethtool_link_ksettings_add_link_mode(link_ksettings, supported, FIBRE);
+	if (!connector_type || connector_type >= MLX5E_CONNECTOR_TYPE_NUMBER) {
+		if (eth_proto_cap & (MLX5E_PROT_MASK(MLX5E_10GBASE_CR)
+				   | MLX5E_PROT_MASK(MLX5E_10GBASE_SR)
+				   | MLX5E_PROT_MASK(MLX5E_40GBASE_CR4)
+				   | MLX5E_PROT_MASK(MLX5E_40GBASE_SR4)
+				   | MLX5E_PROT_MASK(MLX5E_100GBASE_SR4)
+				   | MLX5E_PROT_MASK(MLX5E_1000BASE_CX_SGMII))) {
+			ethtool_link_ksettings_add_link_mode(link_ksettings,
+							     supported,
+							     FIBRE);
+			ethtool_link_ksettings_add_link_mode(link_ksettings,
+							     advertising,
+							     FIBRE);
+		}
+
+		if (eth_proto_cap & (MLX5E_PROT_MASK(MLX5E_100GBASE_KR4)
+				   | MLX5E_PROT_MASK(MLX5E_40GBASE_KR4)
+				   | MLX5E_PROT_MASK(MLX5E_10GBASE_KR)
+				   | MLX5E_PROT_MASK(MLX5E_10GBASE_KX4)
+				   | MLX5E_PROT_MASK(MLX5E_1000BASE_KX))) {
+			ethtool_link_ksettings_add_link_mode(link_ksettings,
+							     supported,
+							     Backplane);
+			ethtool_link_ksettings_add_link_mode(link_ksettings,
+							     advertising,
+							     Backplane);
+		}
+		return;
 	}
 
-	if (eth_proto_cap & (MLX5E_PROT_MASK(MLX5E_100GBASE_KR4)
-			   | MLX5E_PROT_MASK(MLX5E_40GBASE_KR4)
-			   | MLX5E_PROT_MASK(MLX5E_10GBASE_KR)
-			   | MLX5E_PROT_MASK(MLX5E_10GBASE_KX4)
-			   | MLX5E_PROT_MASK(MLX5E_1000BASE_KX))) {
-		ethtool_link_ksettings_add_link_mode(link_ksettings, supported, Backplane);
+	switch (connector_type) {
+	case MLX5E_PORT_TP:
+		ethtool_link_ksettings_add_link_mode(link_ksettings,
+						     supported, TP);
+		ethtool_link_ksettings_add_link_mode(link_ksettings,
+						     advertising, TP);
+		break;
+	case MLX5E_PORT_AUI:
+		ethtool_link_ksettings_add_link_mode(link_ksettings,
+						     supported, AUI);
+		ethtool_link_ksettings_add_link_mode(link_ksettings,
+						     advertising, AUI);
+		break;
+	case MLX5E_PORT_BNC:
+		ethtool_link_ksettings_add_link_mode(link_ksettings,
+						     supported, BNC);
+		ethtool_link_ksettings_add_link_mode(link_ksettings,
+						     advertising, BNC);
+		break;
+	case MLX5E_PORT_MII:
+		ethtool_link_ksettings_add_link_mode(link_ksettings,
+						     supported, MII);
+		ethtool_link_ksettings_add_link_mode(link_ksettings,
+						     advertising, MII);
+		break;
+	case MLX5E_PORT_FIBRE:
+		ethtool_link_ksettings_add_link_mode(link_ksettings,
+						     supported, FIBRE);
+		ethtool_link_ksettings_add_link_mode(link_ksettings,
+						     advertising, FIBRE);
+		break;
+	case MLX5E_PORT_DA:
+		ethtool_link_ksettings_add_link_mode(link_ksettings,
+						     supported, Backplane);
+		ethtool_link_ksettings_add_link_mode(link_ksettings,
+						     advertising, Backplane);
+		break;
+	case MLX5E_PORT_NONE:
+	case MLX5E_PORT_OTHER:
+	default:
+		break;
 	}
 }
 
@@ -791,7 +848,6 @@ static void get_supported(u32 eth_proto_cap,
 {
 	unsigned long *supported = link_ksettings->link_modes.supported;
 
-	ptys2ethtool_supported_port(link_ksettings, eth_proto_cap);
 	ptys2ethtool_supported_link(supported, eth_proto_cap);
 	ethtool_link_ksettings_add_link_mode(link_ksettings, supported, Pause);
 }
@@ -902,6 +958,8 @@ static int mlx5e_get_link_ksettings(struct net_device *netdev,
 
 	link_ksettings->base.port = get_connector_port(eth_proto_oper,
 						       connector_type);
+	ptys2ethtool_supported_advertised_port(link_ksettings, eth_proto_admin,
+					       connector_type);
 	get_lp_advertising(eth_proto_lp, link_ksettings);
 
 	if (an_status == MLX5_AN_COMPLETE)
-- 
2.11.0
