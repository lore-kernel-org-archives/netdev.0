From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 03/11] net/mlx4_en: Fix ip/udp steering rules multicast mac when attached via ethtool
Date: Wed, 30 Jan 2013 12:34:19 +0200
Message-ID: <1359542067-10760-4-git-send-email-amirv@mellanox.com>
References: <1359542067-10760-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:46011 "HELO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753726Ab3A3Ket (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 05:34:49 -0500
In-Reply-To: <1359542067-10760-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

Destination mac is a mandatory specification for ip/udp steering rules.
When attaching multicast steering rules via ethtool the unicast mac of the
interface was added to the rule specification instead of the multicast mac.
The following commit sets the corresponding multicast mac for the rule multicast ip.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  119 ++++++++++++++++-------
 1 files changed, 82 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 03447da..86afb5b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -35,6 +35,8 @@
 #include <linux/ethtool.h>
 #include <linux/netdevice.h>
 #include <linux/mlx4/driver.h>
+#include <linux/in.h>
+#include <net/ip.h>
 
 #include "mlx4_en.h"
 #include "en_port.h"
@@ -672,19 +674,71 @@ static int mlx4_en_validate_flow(struct net_device *dev,
 	return 0;
 }
 
+static int mlx4_en_ethtool_add_mac_rule(struct ethtool_rxnfc *cmd,
+					struct list_head *rule_list_h,
+					struct mlx4_spec_list *spec_l2,
+					unsigned char *mac)
+{
+	int err = 0;
+	__be64 mac_msk = cpu_to_be64(MLX4_MAC_MASK << 16);
+
+	spec_l2->id = MLX4_NET_TRANS_RULE_ID_ETH;
+	memcpy(spec_l2->eth.dst_mac_msk, &mac_msk, ETH_ALEN);
+	memcpy(spec_l2->eth.dst_mac, mac, ETH_ALEN);
+
+	if ((cmd->fs.flow_type & FLOW_EXT) && cmd->fs.m_ext.vlan_tci) {
+		spec_l2->eth.vlan_id = cmd->fs.h_ext.vlan_tci;
+		spec_l2->eth.vlan_id_msk = cpu_to_be16(0xfff);
+	}
+
+	list_add_tail(&spec_l2->list, rule_list_h);
+
+	return err;
+}
+
+static int mlx4_en_ethtool_add_mac_rule_by_ipv4(struct mlx4_en_priv *priv,
+						struct ethtool_rxnfc *cmd,
+						struct list_head *rule_list_h,
+						struct mlx4_spec_list *spec_l2,
+						__be32 ipv4_dst)
+{
+	__be64 be_mac = 0;
+	unsigned char mac[ETH_ALEN];
+
+	if (!ipv4_is_multicast(ipv4_dst)) {
+		if (cmd->fs.flow_type & FLOW_MAC_EXT) {
+			memcpy(&mac, cmd->fs.h_ext.h_dest, ETH_ALEN);
+		} else {
+			be_mac = cpu_to_be64((priv->mac & MLX4_MAC_MASK) << 16);
+			memcpy(&mac, &be_mac, ETH_ALEN);
+		}
+	} else {
+		ip_eth_mc_map(ipv4_dst, mac);
+	}
+
+	return mlx4_en_ethtool_add_mac_rule(cmd, rule_list_h, spec_l2, &mac[0]);
+}
+
 static int add_ip_rule(struct mlx4_en_priv *priv,
-			struct ethtool_rxnfc *cmd,
-			struct list_head *list_h)
+		       struct ethtool_rxnfc *cmd,
+		       struct list_head *list_h)
 {
-	struct mlx4_spec_list *spec_l3;
+	struct mlx4_spec_list *spec_l2 = NULL;
+	struct mlx4_spec_list *spec_l3 = NULL;
 	struct ethtool_usrip4_spec *l3_mask = &cmd->fs.m_u.usr_ip4_spec;
 
-	spec_l3 = kzalloc(sizeof *spec_l3, GFP_KERNEL);
-	if (!spec_l3) {
+	spec_l3 = kzalloc(sizeof(*spec_l3), GFP_KERNEL);
+	spec_l2 = kzalloc(sizeof(*spec_l2), GFP_KERNEL);
+	if (!spec_l2 || !spec_l3) {
 		en_err(priv, "Fail to alloc ethtool rule.\n");
+		kfree(spec_l2);
+		kfree(spec_l3);
 		return -ENOMEM;
 	}
 
+	mlx4_en_ethtool_add_mac_rule_by_ipv4(priv, cmd, list_h, spec_l2,
+					     cmd->fs.h_u.
+					     usr_ip4_spec.ip4dst);
 	spec_l3->id = MLX4_NET_TRANS_RULE_ID_IPV4;
 	spec_l3->ipv4.src_ip = cmd->fs.h_u.usr_ip4_spec.ip4src;
 	if (l3_mask->ip4src)
@@ -701,14 +755,17 @@ static int add_tcp_udp_rule(struct mlx4_en_priv *priv,
 			     struct ethtool_rxnfc *cmd,
 			     struct list_head *list_h, int proto)
 {
-	struct mlx4_spec_list *spec_l3;
-	struct mlx4_spec_list *spec_l4;
+	struct mlx4_spec_list *spec_l2 = NULL;
+	struct mlx4_spec_list *spec_l3 = NULL;
+	struct mlx4_spec_list *spec_l4 = NULL;
 	struct ethtool_tcpip4_spec *l4_mask = &cmd->fs.m_u.tcp_ip4_spec;
 
-	spec_l3 = kzalloc(sizeof *spec_l3, GFP_KERNEL);
-	spec_l4 = kzalloc(sizeof *spec_l4, GFP_KERNEL);
-	if (!spec_l4 || !spec_l3) {
+	spec_l2 = kzalloc(sizeof(*spec_l2), GFP_KERNEL);
+	spec_l3 = kzalloc(sizeof(*spec_l3), GFP_KERNEL);
+	spec_l4 = kzalloc(sizeof(*spec_l4), GFP_KERNEL);
+	if (!spec_l2 || !spec_l3 || !spec_l4) {
 		en_err(priv, "Fail to alloc ethtool rule.\n");
+		kfree(spec_l2);
 		kfree(spec_l3);
 		kfree(spec_l4);
 		return -ENOMEM;
@@ -717,12 +774,20 @@ static int add_tcp_udp_rule(struct mlx4_en_priv *priv,
 	spec_l3->id = MLX4_NET_TRANS_RULE_ID_IPV4;
 
 	if (proto == TCP_V4_FLOW) {
+		mlx4_en_ethtool_add_mac_rule_by_ipv4(priv, cmd, list_h,
+						     spec_l2,
+						     cmd->fs.h_u.
+						     tcp_ip4_spec.ip4dst);
 		spec_l4->id = MLX4_NET_TRANS_RULE_ID_TCP;
 		spec_l3->ipv4.src_ip = cmd->fs.h_u.tcp_ip4_spec.ip4src;
 		spec_l3->ipv4.dst_ip = cmd->fs.h_u.tcp_ip4_spec.ip4dst;
 		spec_l4->tcp_udp.src_port = cmd->fs.h_u.tcp_ip4_spec.psrc;
 		spec_l4->tcp_udp.dst_port = cmd->fs.h_u.tcp_ip4_spec.pdst;
 	} else {
+		mlx4_en_ethtool_add_mac_rule_by_ipv4(priv, cmd, list_h,
+						     spec_l2,
+						     cmd->fs.h_u.
+						     udp_ip4_spec.ip4dst);
 		spec_l4->id = MLX4_NET_TRANS_RULE_ID_UDP;
 		spec_l3->ipv4.src_ip = cmd->fs.h_u.udp_ip4_spec.ip4src;
 		spec_l3->ipv4.dst_ip = cmd->fs.h_u.udp_ip4_spec.ip4dst;
@@ -751,43 +816,23 @@ static int mlx4_en_ethtool_to_net_trans_rule(struct net_device *dev,
 					     struct list_head *rule_list_h)
 {
 	int err;
-	__be64 be_mac;
 	struct ethhdr *eth_spec;
-	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_spec_list *spec_l2;
-	__be64 mac_msk = cpu_to_be64(MLX4_MAC_MASK << 16);
+	struct mlx4_en_priv *priv = netdev_priv(dev);
 
 	err = mlx4_en_validate_flow(dev, cmd);
 	if (err)
 		return err;
 
-	spec_l2 = kzalloc(sizeof *spec_l2, GFP_KERNEL);
-	if (!spec_l2)
-		return -ENOMEM;
-
-	if (cmd->fs.flow_type & FLOW_MAC_EXT) {
-		memcpy(&be_mac, cmd->fs.h_ext.h_dest, ETH_ALEN);
-	} else {
-		u64 mac = priv->mac & MLX4_MAC_MASK;
-		be_mac = cpu_to_be64(mac << 16);
-	}
-
-	spec_l2->id = MLX4_NET_TRANS_RULE_ID_ETH;
-	memcpy(spec_l2->eth.dst_mac_msk, &mac_msk, ETH_ALEN);
-	if ((cmd->fs.flow_type & ~(FLOW_EXT | FLOW_MAC_EXT)) != ETHER_FLOW)
-		memcpy(spec_l2->eth.dst_mac, &be_mac, ETH_ALEN);
-
-	if ((cmd->fs.flow_type & FLOW_EXT) && cmd->fs.m_ext.vlan_tci) {
-		spec_l2->eth.vlan_id = cmd->fs.h_ext.vlan_tci;
-		spec_l2->eth.vlan_id_msk = cpu_to_be16(0xfff);
-	}
-
-	list_add_tail(&spec_l2->list, rule_list_h);
-
 	switch (cmd->fs.flow_type & ~(FLOW_EXT | FLOW_MAC_EXT)) {
 	case ETHER_FLOW:
+		spec_l2 = kzalloc(sizeof(*spec_l2), GFP_KERNEL);
+		if (!spec_l2)
+			return -ENOMEM;
+
 		eth_spec = &cmd->fs.h_u.ether_spec;
-		memcpy(&spec_l2->eth.dst_mac, eth_spec->h_dest, ETH_ALEN);
+		mlx4_en_ethtool_add_mac_rule(cmd, rule_list_h, spec_l2,
+					     &eth_spec->h_dest[0]);
 		spec_l2->eth.ether_type = eth_spec->h_proto;
 		if (eth_spec->h_proto)
 			spec_l2->eth.ether_type_enable = 1;
-- 
1.7.8.2
