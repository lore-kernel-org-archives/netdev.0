From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/16] i40evf: Support RSS option in ethtool
Date: Mon, 17 Mar 2014 05:45:03 -0700
Message-ID: <1395060316-16897-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395060316-16897-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:9205 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756297AbaCQMpV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 08:45:21 -0400
In-Reply-To: <1395060316-16897-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Add support for viewing and modifying RSS hash options and RSS hash
look-up table programming through ethtool. Because the lookup table is
so small for the VFs (only 16 registers), we don't bother to maintain a
shadow table in memory, we just read and write the registers directly.

Change-ID: Ib5a6924da78c540789f21d26b5e8086d71c29384
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 315 +++++++++++++++++++++
 1 file changed, 315 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index 8b0db1c..6a169aa 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -365,6 +365,315 @@ static int i40evf_set_coalesce(struct net_device *netdev,
 	return 0;
 }
 
+/**
+ * i40evf_get_rss_hash_opts - Get RSS hash Input Set for each flow type
+ * @adapter: board private structure
+ * @cmd: ethtool rxnfc command
+ *
+ * Returns Success if the flow is supported, else Invalid Input.
+ **/
+static int i40evf_get_rss_hash_opts(struct i40evf_adapter *adapter,
+				    struct ethtool_rxnfc *cmd)
+{
+	cmd->data = 0;
+
+	/* Report default options for RSS on i40e */
+	switch (cmd->flow_type) {
+	case TCP_V4_FLOW:
+	case UDP_V4_FLOW:
+		cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+	/* fall through to add IP fields */
+	case SCTP_V4_FLOW:
+	case AH_ESP_V4_FLOW:
+	case AH_V4_FLOW:
+	case ESP_V4_FLOW:
+	case IPV4_FLOW:
+		cmd->data |= RXH_IP_SRC | RXH_IP_DST;
+		break;
+	case TCP_V6_FLOW:
+	case UDP_V6_FLOW:
+		cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+	/* fall through to add IP fields */
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
+/**
+ * i40evf_get_rxnfc - command to get RX flow classification rules
+ * @netdev: network interface device structure
+ * @cmd: ethtool rxnfc command
+ *
+ * Returns Success if the command is supported.
+ **/
+static int i40evf_get_rxnfc(struct net_device *netdev,
+			    struct ethtool_rxnfc *cmd,
+			    u32 *rule_locs)
+{
+	struct i40evf_adapter *adapter = netdev_priv(netdev);
+	int ret = -EOPNOTSUPP;
+
+	switch (cmd->cmd) {
+	case ETHTOOL_GRXRINGS:
+		cmd->data = adapter->vsi_res->num_queue_pairs;
+		ret = 0;
+		break;
+	case ETHTOOL_GRXFH:
+		ret = i40evf_get_rss_hash_opts(adapter, cmd);
+		break;
+	default:
+		break;
+	}
+
+	return ret;
+}
+
+/**
+ * i40evf_set_rss_hash_opt - Enable/Disable flow types for RSS hash
+ * @adapter: board private structure
+ * @cmd: ethtool rxnfc command
+ *
+ * Returns Success if the flow input set is supported.
+ **/
+static int i40evf_set_rss_hash_opt(struct i40evf_adapter *adapter,
+				   struct ethtool_rxnfc *nfc)
+{
+	struct i40e_hw *hw = &adapter->hw;
+	u64 hena = (u64)rd32(hw, I40E_VFQF_HENA(0)) |
+		   ((u64)rd32(hw, I40E_VFQF_HENA(1)) << 32);
+
+	/* RSS does not support anything other than hashing
+	 * to queues on src and dst IPs and ports
+	 */
+	if (nfc->data & ~(RXH_IP_SRC | RXH_IP_DST |
+			  RXH_L4_B_0_1 | RXH_L4_B_2_3))
+		return -EINVAL;
+
+	/* We need at least the IP SRC and DEST fields for hashing */
+	if (!(nfc->data & RXH_IP_SRC) ||
+	    !(nfc->data & RXH_IP_DST))
+		return -EINVAL;
+
+	switch (nfc->flow_type) {
+	case TCP_V4_FLOW:
+		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
+		case 0:
+			hena &= ~((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_TCP);
+			break;
+		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
+			hena |= ((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_TCP);
+			break;
+		default:
+			return -EINVAL;
+		}
+		break;
+	case TCP_V6_FLOW:
+		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
+		case 0:
+			hena &= ~((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_TCP);
+			break;
+		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
+			hena |= ((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_TCP);
+			break;
+		default:
+			return -EINVAL;
+		}
+		break;
+	case UDP_V4_FLOW:
+		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
+		case 0:
+			hena &=
+			~(((u64)1 << I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP) |
+			((u64)1 << I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV4_UDP) |
+			((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV4));
+			break;
+		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
+			hena |=
+			(((u64)1 << I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP)  |
+			((u64)1 << I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV4_UDP) |
+			((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV4));
+			break;
+		default:
+			return -EINVAL;
+		}
+		break;
+	case UDP_V6_FLOW:
+		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
+		case 0:
+			hena &=
+			~(((u64)1 << I40E_FILTER_PCTYPE_NONF_UNICAST_IPV6_UDP) |
+			((u64)1 << I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV6_UDP) |
+			((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV6));
+			break;
+		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
+			hena |=
+			(((u64)1 << I40E_FILTER_PCTYPE_NONF_UNICAST_IPV6_UDP)  |
+			((u64)1 << I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV6_UDP) |
+			((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV6));
+			break;
+		default:
+			return -EINVAL;
+		}
+		break;
+	case AH_ESP_V4_FLOW:
+	case AH_V4_FLOW:
+	case ESP_V4_FLOW:
+	case SCTP_V4_FLOW:
+		if ((nfc->data & RXH_L4_B_0_1) ||
+		    (nfc->data & RXH_L4_B_2_3))
+			return -EINVAL;
+		hena |= ((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_OTHER);
+		break;
+	case AH_ESP_V6_FLOW:
+	case AH_V6_FLOW:
+	case ESP_V6_FLOW:
+	case SCTP_V6_FLOW:
+		if ((nfc->data & RXH_L4_B_0_1) ||
+		    (nfc->data & RXH_L4_B_2_3))
+			return -EINVAL;
+		hena |= ((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_OTHER);
+		break;
+	case IPV4_FLOW:
+		hena |= ((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV4_OTHER) |
+			((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV4);
+		break;
+	case IPV6_FLOW:
+		hena |= ((u64)1 << I40E_FILTER_PCTYPE_NONF_IPV6_OTHER) |
+			((u64)1 << I40E_FILTER_PCTYPE_FRAG_IPV6);
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	wr32(hw, I40E_VFQF_HENA(0), (u32)hena);
+	wr32(hw, I40E_VFQF_HENA(1), (u32)(hena >> 32));
+	i40e_flush(hw);
+
+	return 0;
+}
+
+/**
+ * i40evf_set_rxnfc - command to set RX flow classification rules
+ * @netdev: network interface device structure
+ * @cmd: ethtool rxnfc command
+ *
+ * Returns Success if the command is supported.
+ **/
+static int i40evf_set_rxnfc(struct net_device *netdev,
+			    struct ethtool_rxnfc *cmd)
+{
+	struct i40evf_adapter *adapter = netdev_priv(netdev);
+	int ret = -EOPNOTSUPP;
+
+	switch (cmd->cmd) {
+	case ETHTOOL_SRXFH:
+		ret = i40evf_set_rss_hash_opt(adapter, cmd);
+		break;
+	default:
+		break;
+	}
+
+	return ret;
+}
+
+/**
+ * i40evf_get_channels: get the number of channels supported by the device
+ * @netdev: network interface device structure
+ * @ch: channel information structure
+ *
+ * For the purposes of our device, we only use combined channels, i.e. a tx/rx
+ * queue pair. Report one extra channel to match our "other" MSI-X vector.
+ **/
+static void i40evf_get_channels(struct net_device *netdev,
+				struct ethtool_channels *ch)
+{
+	struct i40evf_adapter *adapter = netdev_priv(netdev);
+
+	/* Report maximum channels */
+	ch->max_combined = adapter->vsi_res->num_queue_pairs;
+
+	ch->max_other = NONQ_VECS;
+	ch->other_count = NONQ_VECS;
+
+	ch->combined_count = adapter->vsi_res->num_queue_pairs;
+}
+
+/**
+ * i40evf_get_rxfh_indir_size - get the rx flow hash indirection table size
+ * @netdev: network interface device structure
+ *
+ * Returns the table size.
+ **/
+static u32 i40evf_get_rxfh_indir_size(struct net_device *netdev)
+{
+	return (I40E_VFQF_HLUT_MAX_INDEX + 1) * 4;
+}
+
+/**
+ * i40evf_get_rxfh_indir - get the rx flow hash indirection table
+ * @netdev: network interface device structure
+ * @indir: indirection table
+ *
+ * Reads the indirection table directly from the hardware. Always returns 0.
+ **/
+static int i40evf_get_rxfh_indir(struct net_device *netdev, u32 *indir)
+{
+	struct i40evf_adapter *adapter = netdev_priv(netdev);
+	struct i40e_hw *hw = &adapter->hw;
+	u32 hlut_val;
+	int i, j;
+
+	for (i = 0, j = 0; i < I40E_VFQF_HLUT_MAX_INDEX; i++) {
+		hlut_val = rd32(hw, I40E_VFQF_HLUT(i));
+		indir[j++] = hlut_val & 0xff;
+		indir[j++] = (hlut_val >> 8) & 0xff;
+		indir[j++] = (hlut_val >> 16) & 0xff;
+		indir[j++] = (hlut_val >> 24) & 0xff;
+	}
+	return 0;
+}
+
+/**
+ * i40evf_set_rxfh_indir - set the rx flow hash indirection table
+ * @netdev: network interface device structure
+ * @indir: indirection table
+ *
+ * Returns -EINVAL if the table specifies an inavlid queue id, otherwise
+ * returns 0 after programming the table.
+ **/
+static int i40evf_set_rxfh_indir(struct net_device *netdev, const u32 *indir)
+{
+	struct i40evf_adapter *adapter = netdev_priv(netdev);
+	struct i40e_hw *hw = &adapter->hw;
+	u32 hlut_val;
+	int i, j;
+
+	/* Verify user input. */
+	for (i = 0; i < (I40E_VFQF_HLUT_MAX_INDEX + 1) * 4; i++) {
+		if (indir[i] >= adapter->vsi_res->num_queue_pairs)
+			return -EINVAL;
+	}
+
+	for (i = 0, j = 0; i < I40E_VFQF_HLUT_MAX_INDEX + 1; i++) {
+		hlut_val = indir[j++];
+		hlut_val |= indir[j++] << 8;
+		hlut_val |= indir[j++] << 16;
+		hlut_val |= indir[j++] << 24;
+		wr32(hw, I40E_VFQF_HLUT(i), hlut_val);
+	}
+
+	return 0;
+}
+
 static struct ethtool_ops i40evf_ethtool_ops = {
 	.get_settings		= i40evf_get_settings,
 	.get_drvinfo		= i40evf_get_drvinfo,
@@ -378,6 +687,12 @@ static struct ethtool_ops i40evf_ethtool_ops = {
 	.set_msglevel		= i40evf_set_msglevel,
 	.get_coalesce		= i40evf_get_coalesce,
 	.set_coalesce		= i40evf_set_coalesce,
+	.get_rxnfc		= i40evf_get_rxnfc,
+	.set_rxnfc		= i40evf_set_rxnfc,
+	.get_rxfh_indir_size	= i40evf_get_rxfh_indir_size,
+	.get_rxfh_indir		= i40evf_get_rxfh_indir,
+	.set_rxfh_indir		= i40evf_set_rxfh_indir,
+	.get_channels		= i40evf_get_channels,
 };
 
 /**
-- 
1.8.3.1
