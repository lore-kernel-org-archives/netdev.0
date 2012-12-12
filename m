From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH V1 net-next 3/3] net/mlx4_en: Add support for destination MAC in steering rules
Date: Wed, 12 Dec 2012 14:13:19 +0200
Message-ID: <1355314400-14909-4-git-send-email-amirv@mellanox.com>
References: <1355314400-14909-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Yan Burman <yanb@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:45500 "HELO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751970Ab2LLMNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 07:13:37 -0500
In-Reply-To: <1355314400-14909-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yan Burman <yanb@mellanox.com>

Implement destination MAC rule extension for L3/L4 rules in
flow steering. Usefull for vSwitch/macvlan configurations.

Signed-off-by: Yan Burman <yanb@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index cc7bb25..03447da 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -617,7 +617,13 @@ static int mlx4_en_validate_flow(struct net_device *dev,
 	if (cmd->fs.location >= MAX_NUM_OF_FS_RULES)
 		return -EINVAL;
 
-	switch (cmd->fs.flow_type & ~FLOW_EXT) {
+	if (cmd->fs.flow_type & FLOW_MAC_EXT) {
+		/* dest mac mask must be ff:ff:ff:ff:ff:ff */
+		if (!is_broadcast_ether_addr(cmd->fs.m_ext.h_dest))
+			return -EINVAL;
+	}
+
+	switch (cmd->fs.flow_type & ~(FLOW_EXT | FLOW_MAC_EXT)) {
 	case TCP_V4_FLOW:
 	case UDP_V4_FLOW:
 		if (cmd->fs.m_u.tcp_ip4_spec.tos)
@@ -745,7 +751,6 @@ static int mlx4_en_ethtool_to_net_trans_rule(struct net_device *dev,
 					     struct list_head *rule_list_h)
 {
 	int err;
-	u64 mac;
 	__be64 be_mac;
 	struct ethhdr *eth_spec;
 	struct mlx4_en_priv *priv = netdev_priv(dev);
@@ -760,12 +765,16 @@ static int mlx4_en_ethtool_to_net_trans_rule(struct net_device *dev,
 	if (!spec_l2)
 		return -ENOMEM;
 
-	mac = priv->mac & MLX4_MAC_MASK;
-	be_mac = cpu_to_be64(mac << 16);
+	if (cmd->fs.flow_type & FLOW_MAC_EXT) {
+		memcpy(&be_mac, cmd->fs.h_ext.h_dest, ETH_ALEN);
+	} else {
+		u64 mac = priv->mac & MLX4_MAC_MASK;
+		be_mac = cpu_to_be64(mac << 16);
+	}
 
 	spec_l2->id = MLX4_NET_TRANS_RULE_ID_ETH;
 	memcpy(spec_l2->eth.dst_mac_msk, &mac_msk, ETH_ALEN);
-	if ((cmd->fs.flow_type & ~FLOW_EXT) != ETHER_FLOW)
+	if ((cmd->fs.flow_type & ~(FLOW_EXT | FLOW_MAC_EXT)) != ETHER_FLOW)
 		memcpy(spec_l2->eth.dst_mac, &be_mac, ETH_ALEN);
 
 	if ((cmd->fs.flow_type & FLOW_EXT) && cmd->fs.m_ext.vlan_tci) {
@@ -775,7 +784,7 @@ static int mlx4_en_ethtool_to_net_trans_rule(struct net_device *dev,
 
 	list_add_tail(&spec_l2->list, rule_list_h);
 
-	switch (cmd->fs.flow_type & ~FLOW_EXT) {
+	switch (cmd->fs.flow_type & ~(FLOW_EXT | FLOW_MAC_EXT)) {
 	case ETHER_FLOW:
 		eth_spec = &cmd->fs.h_u.ether_spec;
 		memcpy(&spec_l2->eth.dst_mac, eth_spec->h_dest, ETH_ALEN);
-- 
1.7.11.3
