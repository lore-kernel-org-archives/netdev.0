From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 05/11] net/mlx4_en: Fix vlan mask for ethtool steering rules
Date: Wed, 30 Jan 2013 12:34:21 +0200
Message-ID: <1359542067-10760-6-git-send-email-amirv@mellanox.com>
References: <1359542067-10760-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:39919 "HELO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754489Ab3A3Kev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 05:34:51 -0500
In-Reply-To: <1359542067-10760-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

The vlan mask field should be validated and assigned according to the field
size which is 12 bits. Also replace the numeric 0xfff mask with existing kernel
macro.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index f33049f..f36c219 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -666,12 +666,16 @@ static int mlx4_en_validate_flow(struct net_device *dev,
 
 	if ((cmd->fs.flow_type & FLOW_EXT)) {
 		if (cmd->fs.m_ext.vlan_etype ||
-		    !(cmd->fs.m_ext.vlan_tci == 0 ||
-		      cmd->fs.m_ext.vlan_tci == cpu_to_be16(0xfff)))
+		    !((cmd->fs.m_ext.vlan_tci & cpu_to_be16(VLAN_VID_MASK)) ==
+		      0 ||
+		      (cmd->fs.m_ext.vlan_tci & cpu_to_be16(VLAN_VID_MASK)) ==
+		      cpu_to_be16(VLAN_VID_MASK)))
 			return -EINVAL;
+
 		if (cmd->fs.m_ext.vlan_tci) {
 			if (be16_to_cpu(cmd->fs.h_ext.vlan_tci) >= VLAN_N_VID)
 				return -EINVAL;
+
 		}
 	}
 
@@ -690,9 +694,10 @@ static int mlx4_en_ethtool_add_mac_rule(struct ethtool_rxnfc *cmd,
 	memcpy(spec_l2->eth.dst_mac_msk, &mac_msk, ETH_ALEN);
 	memcpy(spec_l2->eth.dst_mac, mac, ETH_ALEN);
 
-	if ((cmd->fs.flow_type & FLOW_EXT) && cmd->fs.m_ext.vlan_tci) {
+	if ((cmd->fs.flow_type & FLOW_EXT) &&
+	    (cmd->fs.m_ext.vlan_tci & cpu_to_be16(VLAN_VID_MASK))) {
 		spec_l2->eth.vlan_id = cmd->fs.h_ext.vlan_tci;
-		spec_l2->eth.vlan_id_msk = cpu_to_be16(0xfff);
+		spec_l2->eth.vlan_id_msk = cpu_to_be16(VLAN_VID_MASK);
 	}
 
 	list_add_tail(&spec_l2->list, rule_list_h);
-- 
1.7.8.2
