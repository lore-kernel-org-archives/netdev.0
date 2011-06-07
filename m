From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 32/40] ixgbe: add support for modifying UDP RSS flow hash options
Date: Tue,  7 Jun 2011 05:33:07 -0700
Message-ID: <1307449995-9458-33-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:12903 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753350Ab1FGMdb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 08:33:31 -0400
In-Reply-To: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch adds the ability to add or remove the UDP source and destination
ports from the flow hash generated for RSS.  Currently the UDP flow hash is
always disabled.  By adding support for enabling the UDP flow hash we are
now providing the option of generating an RSS hash based on the UDP source
and destination port numbers.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h         |    2 +
 drivers/net/ixgbe/ixgbe_ethtool.c |  152 +++++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_main.c    |    5 +
 3 files changed, 159 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index d6bfb2f..1d80d77 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -382,6 +382,8 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG2_SFP_NEEDS_RESET             (u32)(1 << 5)
 #define IXGBE_FLAG2_RESET_REQUESTED             (u32)(1 << 6)
 #define IXGBE_FLAG2_FDIR_REQUIRES_REINIT        (u32)(1 << 7)
+#define IXGBE_FLAG2_RSS_FIELD_IPV4_UDP          (u32)(1 << 8)
+#define IXGBE_FLAG2_RSS_FIELD_IPV6_UDP          (u32)(1 << 9)
 
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	u16 bd_number;
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index f37c9b8..552cb62 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2426,6 +2426,48 @@ static int ixgbe_get_ethtool_fdir_all(struct ixgbe_adapter *adapter,
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
 			   void *rule_locs)
 {
@@ -2448,6 +2490,9 @@ static int ixgbe_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
 		ret = ixgbe_get_ethtool_fdir_all(adapter, cmd,
 						 (u32 *)rule_locs);
 		break;
+	case ETHTOOL_GRXFH:
+		ret = ixgbe_get_rss_hash_opts(adapter, cmd);
+		break;
 	default:
 		break;
 	}
@@ -2680,6 +2725,110 @@ static int ixgbe_del_ethtool_fdir_entry(struct ixgbe_adapter *adapter,
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
+		    !(nfc->data & RXH_IP_DST))
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
+			netdev_warn(adapter->netdev,
+				"enabling UDP RSS: fragmented packets may "
+				"arrive out of order to the stack above\n");
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
@@ -2692,6 +2841,9 @@ static int ixgbe_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
 	case ETHTOOL_SRXCLSRLDEL:
 		ret = ixgbe_del_ethtool_fdir_entry(adapter, cmd);
 		break;
+	case ETHTOOL_SRXFH:
+		ret = ixgbe_set_rss_hash_opt(adapter, cmd);
+		break;
 	default:
 		break;
 	}
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 472b2c0..c0deed8 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2935,6 +2935,11 @@ static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
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
1.7.5.2

