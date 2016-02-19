From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/16] i40e/i40evf: Add exception handling for Tx checksum
Date: Thu, 18 Feb 2016 16:31:14 -0800
Message-ID: <1455841881-128892-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49646 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965702AbcBSAbf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 19:31:35 -0500
In-Reply-To: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

Add exception handling to the Tx checksum path so that we can handle cases
of TSO where the frame is bad, or Tx checksum where we didn't recognize a
protocol

Drop I40E_TX_FLAGS_CSUM as it is unused, move the CHECKSUM_PARTIAL check
into the function itself so that we can decrease indent.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 34 +++++++++++++++++---------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h   |  1 -
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 35 ++++++++++++++++++---------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h |  1 -
 4 files changed, 45 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 5b591b8..6b08b0f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2387,10 +2387,10 @@ static int i40e_tsyn(struct i40e_ring *tx_ring, struct sk_buff *skb,
  * @tx_ring: Tx descriptor ring
  * @cd_tunneling: ptr to context desc bits
  **/
-static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
-				u32 *td_cmd, u32 *td_offset,
-				struct i40e_ring *tx_ring,
-				u32 *cd_tunneling)
+static int i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
+			       u32 *td_cmd, u32 *td_offset,
+			       struct i40e_ring *tx_ring,
+			       u32 *cd_tunneling)
 {
 	union {
 		struct iphdr *v4;
@@ -2407,6 +2407,9 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 	__be16 frag_off;
 	u8 l4_proto = 0;
 
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		return 0;
+
 	ip.hdr = skb_network_header(skb);
 	l4.hdr = skb_transport_header(skb);
 
@@ -2449,7 +2452,11 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 			*tx_flags |= I40E_TX_FLAGS_UDP_TUNNEL;
 			break;
 		default:
-			return;
+			if (*tx_flags & I40E_TX_FLAGS_TSO)
+				return -1;
+
+			skb_checksum_help(skb);
+			return 0;
 		}
 
 		/* compute tunnel header size */
@@ -2513,11 +2520,16 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 			  I40E_TX_DESC_LENGTH_L4_FC_LEN_SHIFT;
 		break;
 	default:
-		break;
+		if (*tx_flags & I40E_TX_FLAGS_TSO)
+			return -1;
+		skb_checksum_help(skb);
+		return 0;
 	}
 
 	*td_cmd |= cmd;
 	*td_offset |= offset;
+
+	return 1;
 }
 
 /**
@@ -2954,12 +2966,10 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	td_cmd |= I40E_TX_DESC_CMD_ICRC;
 
 	/* Always offload the checksum, since it's in the data descriptor */
-	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		tx_flags |= I40E_TX_FLAGS_CSUM;
-
-		i40e_tx_enable_csum(skb, &tx_flags, &td_cmd, &td_offset,
-				    tx_ring, &cd_tunneling);
-	}
+	tso = i40e_tx_enable_csum(skb, &tx_flags, &td_cmd, &td_offset,
+				  tx_ring, &cd_tunneling);
+	if (tso < 0)
+		goto out_drop;
 
 	i40e_create_tx_ctx(tx_ring, cd_type_cmd_tso_mss,
 			   cd_tunneling, cd_l2tag2);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index fb065d4..fde5f42 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -153,7 +153,6 @@ enum i40e_dyn_idx_t {
 #define DESC_NEEDED (MAX_SKB_FRAGS + 4)
 #define I40E_MIN_DESC_PENDING	4
 
-#define I40E_TX_FLAGS_CSUM		BIT(0)
 #define I40E_TX_FLAGS_HW_VLAN		BIT(1)
 #define I40E_TX_FLAGS_SW_VLAN		BIT(2)
 #define I40E_TX_FLAGS_TSO		BIT(3)
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 0ee13f6..143c570 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1602,12 +1602,13 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
  * @tx_flags: pointer to Tx flags currently set
  * @td_cmd: Tx descriptor command bits to set
  * @td_offset: Tx descriptor header offsets to set
+ * @tx_ring: Tx descriptor ring
  * @cd_tunneling: ptr to context desc bits
  **/
-static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
-				u32 *td_cmd, u32 *td_offset,
-				struct i40e_ring *tx_ring,
-				u32 *cd_tunneling)
+static int i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
+			       u32 *td_cmd, u32 *td_offset,
+			       struct i40e_ring *tx_ring,
+			       u32 *cd_tunneling)
 {
 	union {
 		struct iphdr *v4;
@@ -1624,6 +1625,9 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 	__be16 frag_off;
 	u8 l4_proto = 0;
 
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		return 0;
+
 	ip.hdr = skb_network_header(skb);
 	l4.hdr = skb_transport_header(skb);
 
@@ -1666,7 +1670,11 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 			*tx_flags |= I40E_TX_FLAGS_VXLAN_TUNNEL;
 			break;
 		default:
-			return;
+			if (*tx_flags & I40E_TX_FLAGS_TSO)
+				return -1;
+
+			skb_checksum_help(skb);
+			return 0;
 		}
 
 		/* compute tunnel header size */
@@ -1730,11 +1738,16 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 			  I40E_TX_DESC_LENGTH_L4_FC_LEN_SHIFT;
 		break;
 	default:
-		break;
+		if (*tx_flags & I40E_TX_FLAGS_TSO)
+			return -1;
+		skb_checksum_help(skb);
+		return 0;
 	}
 
 	*td_cmd |= cmd;
 	*td_offset |= offset;
+
+	return 1;
 }
 
 /**
@@ -2150,12 +2163,10 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	td_cmd |= I40E_TX_DESC_CMD_ICRC;
 
 	/* Always offload the checksum, since it's in the data descriptor */
-	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		tx_flags |= I40E_TX_FLAGS_CSUM;
-
-		i40e_tx_enable_csum(skb, &tx_flags, &td_cmd, &td_offset,
-				    tx_ring, &cd_tunneling);
-	}
+	tso = i40e_tx_enable_csum(skb, &tx_flags, &td_cmd, &td_offset,
+				  tx_ring, &cd_tunneling);
+	if (tso < 0)
+		goto out_drop;
 
 	i40e_create_tx_ctx(tx_ring, cd_type_cmd_tso_mss,
 			   cd_tunneling, cd_l2tag2);
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index 043b955..6ea8701 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -153,7 +153,6 @@ enum i40e_dyn_idx_t {
 #define DESC_NEEDED (MAX_SKB_FRAGS + 4)
 #define I40E_MIN_DESC_PENDING	4
 
-#define I40E_TX_FLAGS_CSUM		BIT(0)
 #define I40E_TX_FLAGS_HW_VLAN		BIT(1)
 #define I40E_TX_FLAGS_SW_VLAN		BIT(2)
 #define I40E_TX_FLAGS_TSO		BIT(3)
-- 
2.5.0
