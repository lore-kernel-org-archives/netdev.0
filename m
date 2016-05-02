From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] i40evf: RSS Hash Option parameters
Date: Sun,  1 May 2016 17:06:11 -0700
Message-ID: <1462147581-135254-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462147581-135254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:1786 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752463AbcEBAG0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 May 2016 20:06:26 -0400
In-Reply-To: <1462147581-135254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch syncs the VF code for the changes made to the PF for the RSS
hash tuple settings.  Since the VF still cannot change the RSS hash
settings, change the code to make this clear to the user.  Previously,
the default settings were returned in this function. However, the
default can be changed by the PF so this does not make sense anymore.

Change-Id: I085eaf005fc7978b440d2a1bf2b2dd7cadaff39b
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 201 +--------------------
 1 file changed, 2 insertions(+), 199 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index 9f7657c..5a48ee0 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -378,59 +378,6 @@ static int i40evf_set_coalesce(struct net_device *netdev,
 }
 
 /**
- * i40e_get_rss_hash_opts - Get RSS hash Input Set for each flow type
- * @adapter: board private structure
- * @cmd: ethtool rxnfc command
- *
- * Returns Success if the flow is supported, else Invalid Input.
- **/
-static int i40evf_get_rss_hash_opts(struct i40evf_adapter *adapter,
-				    struct ethtool_rxnfc *cmd)
-{
-	/* We always hash on IP src and dest addresses */
-	cmd->data = RXH_IP_SRC | RXH_IP_DST;
-
-	switch (cmd->flow_type) {
-	case TCP_V4_FLOW:
-		if (adapter->hena & BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_TCP))
-			cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
-		break;
-	case UDP_V4_FLOW:
-		if (adapter->hena & BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_UDP))
-			cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
-		break;
-
-	case SCTP_V4_FLOW:
-	case AH_ESP_V4_FLOW:
-	case AH_V4_FLOW:
-	case ESP_V4_FLOW:
-	case IPV4_FLOW:
-		break;
-
-	case TCP_V6_FLOW:
-		if (adapter->hena & BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_TCP))
-			cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
-		break;
-	case UDP_V6_FLOW:
-		if (adapter->hena & BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_UDP))
-			cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
-		break;
-
-	case SCTP_V6_FLOW:
-	case AH_ESP_V6_FLOW:
-	case AH_V6_FLOW:
-	case ESP_V6_FLOW:
-	case IPV6_FLOW:
-		break;
-	default:
-		cmd->data = 0;
-		return -EINVAL;
-	}
-
-	return 0;
-}
-
-/**
  * i40evf_get_rxnfc - command to get RX flow classification rules
  * @netdev: network interface device structure
  * @cmd: ethtool rxnfc command
@@ -450,150 +397,8 @@ static int i40evf_get_rxnfc(struct net_device *netdev,
 		ret = 0;
 		break;
 	case ETHTOOL_GRXFH:
-		ret = i40evf_get_rss_hash_opts(adapter, cmd);
-		break;
-	default:
-		break;
-	}
-
-	return ret;
-}
-
-/**
- * i40evf_set_rss_hash_opt - Enable/Disable flow types for RSS hash
- * @adapter: board private structure
- * @cmd: ethtool rxnfc command
- *
- * Returns Success if the flow input set is supported.
- **/
-static int i40evf_set_rss_hash_opt(struct i40evf_adapter *adapter,
-				   struct ethtool_rxnfc *nfc)
-{
-	struct i40e_hw *hw = &adapter->hw;
-	u32 flags = adapter->vf_res->vf_offload_flags;
-
-	/* RSS does not support anything other than hashing
-	 * to queues on src and dst IPs and ports
-	 */
-	if (nfc->data & ~(RXH_IP_SRC | RXH_IP_DST |
-			  RXH_L4_B_0_1 | RXH_L4_B_2_3))
-		return -EINVAL;
-
-	/* We need at least the IP SRC and DEST fields for hashing */
-	if (!(nfc->data & RXH_IP_SRC) ||
-	    !(nfc->data & RXH_IP_DST))
-		return -EINVAL;
-
-	switch (nfc->flow_type) {
-	case TCP_V4_FLOW:
-		if (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
-			if (flags & I40E_VIRTCHNL_VF_OFFLOAD_RSS_PCTYPE_V2)
-				adapter->hena |=
-			   BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_TCP_SYN_NO_ACK);
-
-			adapter->hena |=
-		 BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_TCP);
-		} else {
-			return -EINVAL;
-		}
-		break;
-	case TCP_V6_FLOW:
-		if (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
-			if (flags & I40E_VIRTCHNL_VF_OFFLOAD_RSS_PCTYPE_V2)
-				adapter->hena |=
-			   BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_TCP_SYN_NO_ACK);
-
-			adapter->hena |=
-		 BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_TCP);
-		} else {
-			return -EINVAL;
-		}
-		break;
-	case UDP_V4_FLOW:
-		if (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
-			if (flags & I40E_VIRTCHNL_VF_OFFLOAD_RSS_PCTYPE_V2)
-				adapter->hena |=
-			    BIT_ULL(I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP) |
-			    BIT_ULL(I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV4_UDP);
-
-			adapter->hena |=
-				(BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_UDP) |
-				 BIT_ULL(I40E_FILTER_PCTYPE_FRAG_IPV4));
-		} else {
-			return -EINVAL;
-		}
-		break;
-	case UDP_V6_FLOW:
-		if (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
-			if (flags & I40E_VIRTCHNL_VF_OFFLOAD_RSS_PCTYPE_V2)
-				adapter->hena |=
-			    BIT_ULL(I40E_FILTER_PCTYPE_NONF_UNICAST_IPV6_UDP) |
-			    BIT_ULL(I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV6_UDP);
-
-			adapter->hena |=
-				(BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_UDP) |
-				 BIT_ULL(I40E_FILTER_PCTYPE_FRAG_IPV6));
-		} else {
-			return -EINVAL;
-		}
-		break;
-	case AH_ESP_V4_FLOW:
-	case AH_V4_FLOW:
-	case ESP_V4_FLOW:
-	case SCTP_V4_FLOW:
-		if ((nfc->data & RXH_L4_B_0_1) ||
-		    (nfc->data & RXH_L4_B_2_3))
-			return -EINVAL;
-		adapter->hena |= BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_OTHER);
-		break;
-	case AH_ESP_V6_FLOW:
-	case AH_V6_FLOW:
-	case ESP_V6_FLOW:
-	case SCTP_V6_FLOW:
-		if ((nfc->data & RXH_L4_B_0_1) ||
-		    (nfc->data & RXH_L4_B_2_3))
-			return -EINVAL;
-		adapter->hena |= BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_OTHER);
-		break;
-	case IPV4_FLOW:
-		adapter->hena |= (BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_OTHER) |
-				  BIT_ULL(I40E_FILTER_PCTYPE_FRAG_IPV4));
-		break;
-	case IPV6_FLOW:
-		adapter->hena |= (BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_OTHER) |
-				  BIT_ULL(I40E_FILTER_PCTYPE_FRAG_IPV6));
-		break;
-	default:
-		return -EINVAL;
-	}
-
-	if (RSS_PF(adapter)) {
-		adapter->aq_required = I40EVF_FLAG_AQ_SET_HENA;
-	} else {
-		wr32(hw, I40E_VFQF_HENA(0), (u32)adapter->hena);
-		wr32(hw, I40E_VFQF_HENA(1), (u32)(adapter->hena >> 32));
-		i40e_flush(hw);
-	}
-
-	return 0;
-}
-
-/**
- * i40evf_set_rxnfc - command to set RX flow classification rules
- * @netdev: network interface device structure
- * @cmd: ethtool rxnfc command
- *
- * Returns Success if the command is supported.
- **/
-static int i40evf_set_rxnfc(struct net_device *netdev,
-			    struct ethtool_rxnfc *cmd)
-{
-	struct i40evf_adapter *adapter = netdev_priv(netdev);
-	int ret = -EOPNOTSUPP;
-
-	switch (cmd->cmd) {
-	case ETHTOOL_SRXFH:
-		ret = i40evf_set_rss_hash_opt(adapter, cmd);
+		netdev_info(netdev,
+			    "RSS hash info is not available to vf, use pf.\n");
 		break;
 	default:
 		break;
@@ -601,7 +406,6 @@ static int i40evf_set_rxnfc(struct net_device *netdev,
 
 	return ret;
 }
-
 /**
  * i40evf_get_channels: get the number of channels supported by the device
  * @netdev: network interface device structure
@@ -775,7 +579,6 @@ static const struct ethtool_ops i40evf_ethtool_ops = {
 	.get_coalesce		= i40evf_get_coalesce,
 	.set_coalesce		= i40evf_set_coalesce,
 	.get_rxnfc		= i40evf_get_rxnfc,
-	.set_rxnfc		= i40evf_set_rxnfc,
 	.get_rxfh_indir_size	= i40evf_get_rxfh_indir_size,
 	.get_rxfh		= i40evf_get_rxfh,
 	.set_rxfh		= i40evf_set_rxfh,
-- 
2.5.5
