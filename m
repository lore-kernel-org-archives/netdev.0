From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] i40e: Allow RSS Hash set with less than four parameters
Date: Thu, 18 Aug 2016 14:57:33 -0700
Message-ID: <1471557456-136741-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471557456-136741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Kiran Patil <kiran.patil@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:56135 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754154AbcHSAu0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 Aug 2016 20:50:26 -0400
In-Reply-To: <1471557456-136741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch implements a feature change which allows using ethtool to set
RSS hash opts using less than four parameters if desired.

Change-ID: I0fbb91255d81e997c456697c21ac39cc9754821b
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Signed-off-by: Kiran Patil <kiran.patil@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |   3 -
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 208 +++++++++++++++----------
 2 files changed, 130 insertions(+), 81 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 2a88291..8dc98c2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -586,9 +586,6 @@ struct i40e_vsi {
 
 	/* VSI specific handlers */
 	irqreturn_t (*irq_handler)(int irq, void *data);
-
-	/* current rxnfc data */
-	struct ethtool_rxnfc rxnfc; /* current rss hash opts */
 } ____cacheline_internodealigned_in_smp;
 
 struct i40e_netdev_priv {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index a49552f..5bd3848 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2141,41 +2141,72 @@ static int i40e_set_per_queue_coalesce(struct net_device *netdev, u32 queue,
  **/
 static int i40e_get_rss_hash_opts(struct i40e_pf *pf, struct ethtool_rxnfc *cmd)
 {
+	struct i40e_hw *hw = &pf->hw;
+	u8 flow_pctype = 0;
+	u64 i_set = 0;
+
 	cmd->data = 0;
 
-	if (pf->vsi[pf->lan_vsi]->rxnfc.data != 0) {
-		cmd->data = pf->vsi[pf->lan_vsi]->rxnfc.data;
-		cmd->flow_type = pf->vsi[pf->lan_vsi]->rxnfc.flow_type;
-		return 0;
-	}
-	/* Report default options for RSS on i40e */
 	switch (cmd->flow_type) {
 	case TCP_V4_FLOW:
+		flow_pctype = I40E_FILTER_PCTYPE_NONF_IPV4_TCP;
+		break;
 	case UDP_V4_FLOW:
-		cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
-	/* fall through to add IP fields */
+		flow_pctype = I40E_FILTER_PCTYPE_NONF_IPV4_UDP;
+		break;
+	case TCP_V6_FLOW:
+		flow_pctype = I40E_FILTER_PCTYPE_NONF_IPV6_TCP;
+		break;
+	case UDP_V6_FLOW:
+		flow_pctype = I40E_FILTER_PCTYPE_NONF_IPV6_UDP;
+		break;
 	case SCTP_V4_FLOW:
 	case AH_ESP_V4_FLOW:
 	case AH_V4_FLOW:
 	case ESP_V4_FLOW:
 	case IPV4_FLOW:
-		cmd->data |= RXH_IP_SRC | RXH_IP_DST;
-		break;
-	case TCP_V6_FLOW:
-	case UDP_V6_FLOW:
-		cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
-	/* fall through to add IP fields */
 	case SCTP_V6_FLOW:
 	case AH_ESP_V6_FLOW:
 	case AH_V6_FLOW:
 	case ESP_V6_FLOW:
 	case IPV6_FLOW:
+		/* Default is src/dest for IP, no matter the L4 hashing */
 		cmd->data |= RXH_IP_SRC | RXH_IP_DST;
 		break;
 	default:
 		return -EINVAL;
 	}
 
+	/* Read flow based hash input set register */
+	if (flow_pctype) {
+		i_set = (u64)i40e_read_rx_ctl(hw, I40E_GLQF_HASH_INSET(0,
+					      flow_pctype)) |
+			((u64)i40e_read_rx_ctl(hw, I40E_GLQF_HASH_INSET(1,
+					       flow_pctype)) << 32);
+	}
+
+	/* Process bits of hash input set */
+	if (i_set) {
+		if (i_set & I40E_L4_SRC_MASK)
+			cmd->data |= RXH_L4_B_0_1;
+		if (i_set & I40E_L4_DST_MASK)
+			cmd->data |= RXH_L4_B_2_3;
+
+		if (cmd->flow_type == TCP_V4_FLOW ||
+		    cmd->flow_type == UDP_V4_FLOW) {
+			if (i_set & I40E_L3_SRC_MASK)
+				cmd->data |= RXH_IP_SRC;
+			if (i_set & I40E_L3_DST_MASK)
+				cmd->data |= RXH_IP_DST;
+		} else if (cmd->flow_type == TCP_V6_FLOW ||
+			  cmd->flow_type == UDP_V6_FLOW) {
+			if (i_set & I40E_L3_V6_SRC_MASK)
+				cmd->data |= RXH_IP_SRC;
+			if (i_set & I40E_L3_V6_DST_MASK)
+				cmd->data |= RXH_IP_DST;
+		}
+	}
+
 	return 0;
 }
 
@@ -2318,6 +2349,51 @@ static int i40e_get_rxnfc(struct net_device *netdev, struct ethtool_rxnfc *cmd,
 }
 
 /**
+ * i40e_get_rss_hash_bits - Read RSS Hash bits from register
+ * @nfc: pointer to user request
+ * @i_setc bits currently set
+ *
+ * Returns value of bits to be set per user request
+ **/
+static u64 i40e_get_rss_hash_bits(struct ethtool_rxnfc *nfc, u64 i_setc)
+{
+	u64 i_set = i_setc;
+	u64 src_l3 = 0, dst_l3 = 0;
+
+	if (nfc->data & RXH_L4_B_0_1)
+		i_set |= I40E_L4_SRC_MASK;
+	else
+		i_set &= ~I40E_L4_SRC_MASK;
+	if (nfc->data & RXH_L4_B_2_3)
+		i_set |= I40E_L4_DST_MASK;
+	else
+		i_set &= ~I40E_L4_DST_MASK;
+
+	if (nfc->flow_type == TCP_V6_FLOW || nfc->flow_type == UDP_V6_FLOW) {
+		src_l3 = I40E_L3_V6_SRC_MASK;
+		dst_l3 = I40E_L3_V6_DST_MASK;
+	} else if (nfc->flow_type == TCP_V4_FLOW ||
+		  nfc->flow_type == UDP_V4_FLOW) {
+		src_l3 = I40E_L3_SRC_MASK;
+		dst_l3 = I40E_L3_DST_MASK;
+	} else {
+		/* Any other flow type are not supported here */
+		return i_set;
+	}
+
+	if (nfc->data & RXH_IP_SRC)
+		i_set |= src_l3;
+	else
+		i_set &= ~src_l3;
+	if (nfc->data & RXH_IP_DST)
+		i_set |= dst_l3;
+	else
+		i_set &= ~dst_l3;
+
+	return i_set;
+}
+
+/**
  * i40e_set_rss_hash_opt - Enable/Disable flow types for RSS hash
  * @pf: pointer to the physical function struct
  * @cmd: ethtool rxnfc command
@@ -2329,6 +2405,8 @@ static int i40e_set_rss_hash_opt(struct i40e_pf *pf, struct ethtool_rxnfc *nfc)
 	struct i40e_hw *hw = &pf->hw;
 	u64 hena = (u64)i40e_read_rx_ctl(hw, I40E_PFQF_HENA(0)) |
 		   ((u64)i40e_read_rx_ctl(hw, I40E_PFQF_HENA(1)) << 32);
+	u8 flow_pctype = 0;
+	u64 i_set, i_setc;
 
 	/* RSS does not support anything other than hashing
 	 * to queues on src and dst IPs and ports
@@ -2337,75 +2415,39 @@ static int i40e_set_rss_hash_opt(struct i40e_pf *pf, struct ethtool_rxnfc *nfc)
 			  RXH_L4_B_0_1 | RXH_L4_B_2_3))
 		return -EINVAL;
 
-	/* We need at least the IP SRC and DEST fields for hashing */
-	if (!(nfc->data & RXH_IP_SRC) ||
-	    !(nfc->data & RXH_IP_DST))
-		return -EINVAL;
-
 	switch (nfc->flow_type) {
 	case TCP_V4_FLOW:
-		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
-		case 0:
-			return -EINVAL;
-		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
-			if (pf->flags & I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE)
-				hena |=
-			   BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_TCP_SYN_NO_ACK);
-
-			hena |= BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_TCP);
-			break;
-		default:
-			return -EINVAL;
-		}
+		flow_pctype = I40E_FILTER_PCTYPE_NONF_IPV4_TCP;
+		if (pf->flags & I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE)
+			hena |=
+			  BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_TCP_SYN_NO_ACK);
 		break;
 	case TCP_V6_FLOW:
-		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
-		case 0:
-			return -EINVAL;
-		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
-			if (pf->flags & I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE)
-				hena |=
-			   BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_TCP_SYN_NO_ACK);
-
-			hena |= BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_TCP);
-			break;
-		default:
-			return -EINVAL;
-		}
+		flow_pctype = I40E_FILTER_PCTYPE_NONF_IPV6_TCP;
+		if (pf->flags & I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE)
+			hena |=
+			  BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_TCP_SYN_NO_ACK);
+		if (pf->flags & I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE)
+			hena |=
+			  BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_TCP_SYN_NO_ACK);
 		break;
 	case UDP_V4_FLOW:
-		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
-		case 0:
-			return -EINVAL;
-		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
-			if (pf->flags & I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE)
-				hena |=
-			    BIT_ULL(I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP) |
-			    BIT_ULL(I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV4_UDP);
-
-			hena |= (BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV4_UDP) |
-				 BIT_ULL(I40E_FILTER_PCTYPE_FRAG_IPV4));
-			break;
-		default:
-			return -EINVAL;
-		}
+		flow_pctype = I40E_FILTER_PCTYPE_NONF_IPV4_UDP;
+		if (pf->flags & I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE)
+			hena |=
+			  BIT_ULL(I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP) |
+			  BIT_ULL(I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV4_UDP);
+
+		hena |= BIT_ULL(I40E_FILTER_PCTYPE_FRAG_IPV4);
 		break;
 	case UDP_V6_FLOW:
-		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
-		case 0:
-			return -EINVAL;
-		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
-			if (pf->flags & I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE)
-				hena |=
-			    BIT_ULL(I40E_FILTER_PCTYPE_NONF_UNICAST_IPV6_UDP) |
-			    BIT_ULL(I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV6_UDP);
-
-			hena |= (BIT_ULL(I40E_FILTER_PCTYPE_NONF_IPV6_UDP) |
-				 BIT_ULL(I40E_FILTER_PCTYPE_FRAG_IPV6));
-			break;
-		default:
-			return -EINVAL;
-		}
+		flow_pctype = I40E_FILTER_PCTYPE_NONF_IPV6_UDP;
+		if (pf->flags & I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE)
+			hena |=
+			  BIT_ULL(I40E_FILTER_PCTYPE_NONF_UNICAST_IPV6_UDP) |
+			  BIT_ULL(I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV6_UDP);
+
+		hena |= BIT_ULL(I40E_FILTER_PCTYPE_FRAG_IPV6);
 		break;
 	case AH_ESP_V4_FLOW:
 	case AH_V4_FLOW:
@@ -2437,13 +2479,23 @@ static int i40e_set_rss_hash_opt(struct i40e_pf *pf, struct ethtool_rxnfc *nfc)
 		return -EINVAL;
 	}
 
+	if (flow_pctype) {
+		i_setc = (u64)i40e_read_rx_ctl(hw, I40E_GLQF_HASH_INSET(0,
+					       flow_pctype)) |
+			((u64)i40e_read_rx_ctl(hw, I40E_GLQF_HASH_INSET(1,
+					       flow_pctype)) << 32);
+		i_set = i40e_get_rss_hash_bits(nfc, i_setc);
+		i40e_write_rx_ctl(hw, I40E_GLQF_HASH_INSET(0, flow_pctype),
+				  (u32)i_set);
+		i40e_write_rx_ctl(hw, I40E_GLQF_HASH_INSET(1, flow_pctype),
+				  (u32)(i_set >> 32));
+		hena |= BIT_ULL(flow_pctype);
+	}
+
 	i40e_write_rx_ctl(hw, I40E_PFQF_HENA(0), (u32)hena);
 	i40e_write_rx_ctl(hw, I40E_PFQF_HENA(1), (u32)(hena >> 32));
 	i40e_flush(hw);
 
-	/* Save setting for future output/update */
-	pf->vsi[pf->lan_vsi]->rxnfc = *nfc;
-
 	return 0;
 }
 
-- 
2.7.4
