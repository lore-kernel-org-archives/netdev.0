From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 4/4] bnxt_en: Add ethtool -n|-N rx-flow-hash support.
Date: Wed, 16 Nov 2016 21:13:10 -0500
Message-ID: <1479348790-6218-5-git-send-email-michael.chan@broadcom.com>
References: <1479348790-6218-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:34787 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933828AbcKQCNc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 21:13:32 -0500
Received: by mail-pg0-f53.google.com with SMTP id x23so82907968pgx.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 18:13:32 -0800 (PST)
In-Reply-To: <1479348790-6218-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To display and modify the RSS hash.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 167 +++++++++++++++++++++-
 1 file changed, 164 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index a7e04ff..fa6125e 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -542,6 +542,146 @@ static int bnxt_grxclsrule(struct bnxt *bp, struct ethtool_rxnfc *cmd)
 
 	return rc;
 }
+#endif
+
+static u64 get_ethtool_ipv4_rss(struct bnxt *bp)
+{
+	if (bp->rss_hash_cfg & VNIC_RSS_CFG_REQ_HASH_TYPE_IPV4)
+		return RXH_IP_SRC | RXH_IP_DST;
+	return 0;
+}
+
+static u64 get_ethtool_ipv6_rss(struct bnxt *bp)
+{
+	if (bp->rss_hash_cfg & VNIC_RSS_CFG_REQ_HASH_TYPE_IPV6)
+		return RXH_IP_SRC | RXH_IP_DST;
+	return 0;
+}
+
+static int bnxt_grxfh(struct bnxt *bp, struct ethtool_rxnfc *cmd)
+{
+	cmd->data = 0;
+	switch (cmd->flow_type) {
+	case TCP_V4_FLOW:
+		if (bp->rss_hash_cfg & VNIC_RSS_CFG_REQ_HASH_TYPE_TCP_IPV4)
+			cmd->data |= RXH_IP_SRC | RXH_IP_DST |
+				     RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		cmd->data |= get_ethtool_ipv4_rss(bp);
+		break;
+	case UDP_V4_FLOW:
+		if (bp->rss_hash_cfg & VNIC_RSS_CFG_REQ_HASH_TYPE_UDP_IPV4)
+			cmd->data |= RXH_IP_SRC | RXH_IP_DST |
+				     RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		/* fall through */
+	case SCTP_V4_FLOW:
+	case AH_ESP_V4_FLOW:
+	case AH_V4_FLOW:
+	case ESP_V4_FLOW:
+	case IPV4_FLOW:
+		cmd->data |= get_ethtool_ipv4_rss(bp);
+		break;
+
+	case TCP_V6_FLOW:
+		if (bp->rss_hash_cfg & VNIC_RSS_CFG_REQ_HASH_TYPE_TCP_IPV6)
+			cmd->data |= RXH_IP_SRC | RXH_IP_DST |
+				     RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		cmd->data |= get_ethtool_ipv6_rss(bp);
+		break;
+	case UDP_V6_FLOW:
+		if (bp->rss_hash_cfg & VNIC_RSS_CFG_REQ_HASH_TYPE_UDP_IPV6)
+			cmd->data |= RXH_IP_SRC | RXH_IP_DST |
+				     RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		/* fall through */
+	case SCTP_V6_FLOW:
+	case AH_ESP_V6_FLOW:
+	case AH_V6_FLOW:
+	case ESP_V6_FLOW:
+	case IPV6_FLOW:
+		cmd->data |= get_ethtool_ipv6_rss(bp);
+		break;
+	}
+	return 0;
+}
+
+#define RXH_4TUPLE (RXH_IP_SRC | RXH_IP_DST | RXH_L4_B_0_1 | RXH_L4_B_2_3)
+#define RXH_2TUPLE (RXH_IP_SRC | RXH_IP_DST)
+
+static int bnxt_srxfh(struct bnxt *bp, struct ethtool_rxnfc *cmd)
+{
+	u32 rss_hash_cfg = bp->rss_hash_cfg;
+	int tuple, rc = 0;
+
+	if (cmd->data == RXH_4TUPLE)
+		tuple = 4;
+	else if (cmd->data == RXH_2TUPLE)
+		tuple = 2;
+	else if (!cmd->data)
+		tuple = 0;
+	else
+		return -EINVAL;
+
+	if (cmd->flow_type == TCP_V4_FLOW) {
+		rss_hash_cfg &= ~VNIC_RSS_CFG_REQ_HASH_TYPE_TCP_IPV4;
+		if (tuple == 4)
+			rss_hash_cfg |= VNIC_RSS_CFG_REQ_HASH_TYPE_TCP_IPV4;
+	} else if (cmd->flow_type == UDP_V4_FLOW) {
+		if (tuple == 4 && !(bp->flags & BNXT_FLAG_UDP_RSS_CAP))
+			return -EINVAL;
+		rss_hash_cfg &= ~VNIC_RSS_CFG_REQ_HASH_TYPE_UDP_IPV4;
+		if (tuple == 4)
+			rss_hash_cfg |= VNIC_RSS_CFG_REQ_HASH_TYPE_UDP_IPV4;
+	} else if (cmd->flow_type == TCP_V6_FLOW) {
+		rss_hash_cfg &= ~VNIC_RSS_CFG_REQ_HASH_TYPE_TCP_IPV6;
+		if (tuple == 4)
+			rss_hash_cfg |= VNIC_RSS_CFG_REQ_HASH_TYPE_TCP_IPV6;
+	} else if (cmd->flow_type == UDP_V6_FLOW) {
+		if (tuple == 4 && !(bp->flags & BNXT_FLAG_UDP_RSS_CAP))
+			return -EINVAL;
+		rss_hash_cfg &= ~VNIC_RSS_CFG_REQ_HASH_TYPE_UDP_IPV6;
+		if (tuple == 4)
+			rss_hash_cfg |= VNIC_RSS_CFG_REQ_HASH_TYPE_UDP_IPV6;
+	} else if (tuple == 4) {
+		return -EINVAL;
+	}
+
+	switch (cmd->flow_type) {
+	case TCP_V4_FLOW:
+	case UDP_V4_FLOW:
+	case SCTP_V4_FLOW:
+	case AH_ESP_V4_FLOW:
+	case AH_V4_FLOW:
+	case ESP_V4_FLOW:
+	case IPV4_FLOW:
+		if (tuple == 2)
+			rss_hash_cfg |= VNIC_RSS_CFG_REQ_HASH_TYPE_IPV4;
+		else if (!tuple)
+			rss_hash_cfg &= ~VNIC_RSS_CFG_REQ_HASH_TYPE_IPV4;
+		break;
+
+	case TCP_V6_FLOW:
+	case UDP_V6_FLOW:
+	case SCTP_V6_FLOW:
+	case AH_ESP_V6_FLOW:
+	case AH_V6_FLOW:
+	case ESP_V6_FLOW:
+	case IPV6_FLOW:
+		if (tuple == 2)
+			rss_hash_cfg |= VNIC_RSS_CFG_REQ_HASH_TYPE_IPV6;
+		else if (!tuple)
+			rss_hash_cfg &= ~VNIC_RSS_CFG_REQ_HASH_TYPE_IPV6;
+		break;
+	}
+
+	if (bp->rss_hash_cfg == rss_hash_cfg)
+		return 0;
+
+	bp->rss_hash_cfg = rss_hash_cfg;
+	if (netif_running(bp->dev)) {
+		bnxt_close_nic(bp, false, false);
+		rc = bnxt_open_nic(bp, false, false);
+	}
+	return rc;
+}
 
 static int bnxt_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
 			  u32 *rule_locs)
@@ -550,6 +690,7 @@ static int bnxt_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
 	int rc = 0;
 
 	switch (cmd->cmd) {
+#ifdef CONFIG_RFS_ACCEL
 	case ETHTOOL_GRXRINGS:
 		cmd->data = bp->rx_nr_rings;
 		break;
@@ -566,6 +707,11 @@ static int bnxt_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
 	case ETHTOOL_GRXCLSRULE:
 		rc = bnxt_grxclsrule(bp, cmd);
 		break;
+#endif
+
+	case ETHTOOL_GRXFH:
+		rc = bnxt_grxfh(bp, cmd);
+		break;
 
 	default:
 		rc = -EOPNOTSUPP;
@@ -574,7 +720,23 @@ static int bnxt_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
 
 	return rc;
 }
-#endif
+
+static int bnxt_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
+{
+	struct bnxt *bp = netdev_priv(dev);
+	int rc;
+
+	switch (cmd->cmd) {
+	case ETHTOOL_SRXFH:
+		rc = bnxt_srxfh(bp, cmd);
+		break;
+
+	default:
+		rc = -EOPNOTSUPP;
+		break;
+	}
+	return rc;
+}
 
 static u32 bnxt_get_rxfh_indir_size(struct net_device *dev)
 {
@@ -1885,9 +2047,8 @@ static int bnxt_nway_reset(struct net_device *dev)
 	.get_ringparam		= bnxt_get_ringparam,
 	.get_channels		= bnxt_get_channels,
 	.set_channels		= bnxt_set_channels,
-#ifdef CONFIG_RFS_ACCEL
 	.get_rxnfc		= bnxt_get_rxnfc,
-#endif
+	.set_rxnfc		= bnxt_set_rxnfc,
 	.get_rxfh_indir_size    = bnxt_get_rxfh_indir_size,
 	.get_rxfh_key_size      = bnxt_get_rxfh_key_size,
 	.get_rxfh               = bnxt_get_rxfh,
-- 
1.8.3.1
