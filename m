From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/10] ixgbe: Add support for enabling UDP RSS via the ethtool rx-flow-hash command
Date: Mon, 19 Mar 2012 14:22:36 -0700
Message-ID: <1332192158-14771-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1332192158-14771-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:5166 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755503Ab2CSVWo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2012 17:22:44 -0400
In-Reply-To: <1332192158-14771-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch adds support for enabling or disabling UDP RSS via the
ethtool -N rx-flow-hash command.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  153 ++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |    5 +
 3 files changed, 160 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 8620414..4ceac3a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -438,7 +438,8 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG2_SFP_NEEDS_RESET             (u32)(1 << 5)
 #define IXGBE_FLAG2_RESET_REQUESTED             (u32)(1 << 6)
 #define IXGBE_FLAG2_FDIR_REQUIRES_REINIT        (u32)(1 << 7)
-
+#define IXGBE_FLAG2_RSS_FIELD_IPV4_UDP		(u32)(1 << 8)
+#define IXGBE_FLAG2_RSS_FIELD_IPV6_UDP		(u32)(1 << 9)
 
 	/* Tx fast path data */
 	int num_tx_queues;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index b09e67c..b64d8a2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2328,6 +2328,48 @@ static int ixgbe_get_ethtool_fdir_all(struct ixgbe_adapter *adapter,
 	return 0;
 }
 
+static int ixgbe_get_rss_hash_opts(struct ixgbe_adapter *adapter,
+				   struct ethtool_rxnfc *cmd)
+{
+	cmd->data = 0;
+
+	/* if RSS is disabled then report no hashing */
+	if (!(adapter->flags & IXGBE_FLAG_RSS_ENABLED))
+		return 0;
+
+	/* Report default options for RSS on ixgbe */
+	switch (cmd->flow_type) {
+	case TCP_V4_FLOW:
+		cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+	case UDP_V4_FLOW:
+		if (adapter->flags2 & IXGBE_FLAG2_RSS_FIELD_IPV4_UDP)
+			cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+	case SCTP_V4_FLOW:
+	case AH_ESP_V4_FLOW:
+	case AH_V4_FLOW:
+	case ESP_V4_FLOW:
+	case IPV4_FLOW:
+		cmd->data |= RXH_IP_SRC | RXH_IP_DST;
+		break;
+	case TCP_V6_FLOW:
+		cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+	case UDP_V6_FLOW:
+		if (adapter->flags2 & IXGBE_FLAG2_RSS_FIELD_IPV6_UDP)
+			cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+	case SCTP_V6_FLOW:
+	case AH_ESP_V6_FLOW:
+	case AH_V6_FLOW:
+	case ESP_V6_FLOW:
+	case IPV6_FLOW:
+		cmd->data |= RXH_IP_SRC | RXH_IP_DST;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
 static int ixgbe_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
 			   u32 *rule_locs)
 {
@@ -2349,6 +2391,9 @@ static int ixgbe_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
 	case ETHTOOL_GRXCLSRLALL:
 		ret = ixgbe_get_ethtool_fdir_all(adapter, cmd, rule_locs);
 		break;
+	case ETHTOOL_GRXFH:
+		ret = ixgbe_get_rss_hash_opts(adapter, cmd);
+		break;
 	default:
 		break;
 	}
@@ -2583,6 +2628,111 @@ static int ixgbe_del_ethtool_fdir_entry(struct ixgbe_adapter *adapter,
 	return err;
 }
 
+#define UDP_RSS_FLAGS (IXGBE_FLAG2_RSS_FIELD_IPV4_UDP | \
+		       IXGBE_FLAG2_RSS_FIELD_IPV6_UDP)
+static int ixgbe_set_rss_hash_opt(struct ixgbe_adapter *adapter,
+				  struct ethtool_rxnfc *nfc)
+{
+	u32 flags2 = adapter->flags2;
+
+	/*
+	 * RSS does not support anything other than hashing
+	 * to queues on src and dst IPs and ports
+	 */
+	if (nfc->data & ~(RXH_IP_SRC | RXH_IP_DST |
+			  RXH_L4_B_0_1 | RXH_L4_B_2_3))
+		return -EINVAL;
+
+	switch (nfc->flow_type) {
+	case TCP_V4_FLOW:
+	case TCP_V6_FLOW:
+		if (!(nfc->data & RXH_IP_SRC) ||
+		    !(nfc->data & RXH_IP_DST) ||
+		    !(nfc->data & RXH_L4_B_0_1) ||
+		    !(nfc->data & RXH_L4_B_2_3))
+			return -EINVAL;
+		break;
+	case UDP_V4_FLOW:
+		if (!(nfc->data & RXH_IP_SRC) ||
+		    !(nfc->data & RXH_IP_DST))
+			return -EINVAL;
+		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
+		case 0:
+			flags2 &= ~IXGBE_FLAG2_RSS_FIELD_IPV4_UDP;
+			break;
+		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
+			flags2 |= IXGBE_FLAG2_RSS_FIELD_IPV4_UDP;
+			break;
+		default:
+			return -EINVAL;
+		}
+		break;
+	case UDP_V6_FLOW:
+		if (!(nfc->data & RXH_IP_SRC) ||
+		    !(nfc->data & RXH_IP_DST))
+			return -EINVAL;
+		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
+		case 0:
+			flags2 &= ~IXGBE_FLAG2_RSS_FIELD_IPV6_UDP;
+			break;
+		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
+			flags2 |= IXGBE_FLAG2_RSS_FIELD_IPV6_UDP;
+			break;
+		default:
+			return -EINVAL;
+		}
+		break;
+	case AH_ESP_V4_FLOW:
+	case AH_V4_FLOW:
+	case ESP_V4_FLOW:
+	case SCTP_V4_FLOW:
+	case AH_ESP_V6_FLOW:
+	case AH_V6_FLOW:
+	case ESP_V6_FLOW:
+	case SCTP_V6_FLOW:
+		if (!(nfc->data & RXH_IP_SRC) ||
+		    !(nfc->data & RXH_IP_DST) ||
+		    (nfc->data & RXH_L4_B_0_1) ||
+		    (nfc->data & RXH_L4_B_2_3))
+			return -EINVAL;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	/* if we changed something we need to update flags */
+	if (flags2 != adapter->flags2) {
+		struct ixgbe_hw *hw = &adapter->hw;
+		u32 mrqc = IXGBE_READ_REG(hw, IXGBE_MRQC);
+
+		if ((flags2 & UDP_RSS_FLAGS) &&
+		    !(adapter->flags2 & UDP_RSS_FLAGS))
+			e_warn(drv, "enabling UDP RSS: fragmented packets"
+			       " may arrive out of order to the stack above\n");
+
+		adapter->flags2 = flags2;
+
+		/* Perform hash on these packet types */
+		mrqc |= IXGBE_MRQC_RSS_FIELD_IPV4
+		      | IXGBE_MRQC_RSS_FIELD_IPV4_TCP
+		      | IXGBE_MRQC_RSS_FIELD_IPV6
+		      | IXGBE_MRQC_RSS_FIELD_IPV6_TCP;
+
+		mrqc &= ~(IXGBE_MRQC_RSS_FIELD_IPV4_UDP |
+			  IXGBE_MRQC_RSS_FIELD_IPV6_UDP);
+
+		if (flags2 & IXGBE_FLAG2_RSS_FIELD_IPV4_UDP)
+			mrqc |= IXGBE_MRQC_RSS_FIELD_IPV4_UDP;
+
+		if (flags2 & IXGBE_FLAG2_RSS_FIELD_IPV6_UDP)
+			mrqc |= IXGBE_MRQC_RSS_FIELD_IPV6_UDP;
+
+		IXGBE_WRITE_REG(hw, IXGBE_MRQC, mrqc);
+	}
+
+	return 0;
+}
+
 static int ixgbe_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
@@ -2595,6 +2745,9 @@ static int ixgbe_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
 	case ETHTOOL_SRXCLSRLDEL:
 		ret = ixgbe_del_ethtool_fdir_entry(adapter, cmd);
 		break;
+	case ETHTOOL_SRXFH:
+		ret = ixgbe_set_rss_hash_opt(adapter, cmd);
+		break;
 	default:
 		break;
 	}
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 1d22c9f..5c7e7d8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2856,6 +2856,11 @@ static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 	      | IXGBE_MRQC_RSS_FIELD_IPV6
 	      | IXGBE_MRQC_RSS_FIELD_IPV6_TCP;
 
+	if (adapter->flags2 & IXGBE_FLAG2_RSS_FIELD_IPV4_UDP)
+		mrqc |= IXGBE_MRQC_RSS_FIELD_IPV4_UDP;
+	if (adapter->flags2 & IXGBE_FLAG2_RSS_FIELD_IPV6_UDP)
+		mrqc |= IXGBE_MRQC_RSS_FIELD_IPV6_UDP;
+
 	IXGBE_WRITE_REG(hw, IXGBE_MRQC, mrqc);
 }
 
-- 
1.7.7.6
