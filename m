From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/16] i40e/i40evf: Do not write to descriptor unless we complete
Date: Thu, 18 Feb 2016 16:31:13 -0800
Message-ID: <1455841881-128892-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48151 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965684AbcBSAbe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 19:31:34 -0500
In-Reply-To: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

This patch defers writing to the Tx descriptor bits until we know we have
successfully completed a given operation.  So for example we defer updating
the tunnelling portion of the context descriptor until we have fully
identified the type.

The advantage to this approach is that we can assemble values as we go
instead of having to try and kludge everything together all at once.  As a
result we can significantly clean up the tunneling configuration for
instance as we can just do a pointer walk and do the math for the distance
between each set of points.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 80 ++++++++++++++-------------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 80 ++++++++++++++-------------
 2 files changed, 84 insertions(+), 76 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index e49fe8f..5b591b8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2403,24 +2403,26 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 		unsigned char *hdr;
 	} l4;
 	unsigned char *exthdr;
-	u32 l4_tunnel = 0;
+	u32 offset, cmd = 0, tunnel = 0;
 	__be16 frag_off;
 	u8 l4_proto = 0;
 
 	ip.hdr = skb_network_header(skb);
 	l4.hdr = skb_transport_header(skb);
 
+	/* compute outer L2 header size */
+	offset = ((ip.hdr - skb->data) / 2) << I40E_TX_DESC_LENGTH_MACLEN_SHIFT;
+
 	if (skb->encapsulation) {
 		/* define outer network header type */
 		if (*tx_flags & I40E_TX_FLAGS_IPV4) {
-			if (*tx_flags & I40E_TX_FLAGS_TSO)
-				*cd_tunneling |= I40E_TX_CTX_EXT_IP_IPV4;
-			else
-				*cd_tunneling |=
-					 I40E_TX_CTX_EXT_IP_IPV4_NO_CSUM;
+			tunnel |= (*tx_flags & I40E_TX_FLAGS_TSO) ?
+				  I40E_TX_CTX_EXT_IP_IPV4 :
+				  I40E_TX_CTX_EXT_IP_IPV4_NO_CSUM;
+
 			l4_proto = ip.v4->protocol;
 		} else if (*tx_flags & I40E_TX_FLAGS_IPV6) {
-			*cd_tunneling |= I40E_TX_CTX_EXT_IP_IPV6;
+			tunnel |= I40E_TX_CTX_EXT_IP_IPV6;
 
 			exthdr = ip.hdr + sizeof(*ip.v6);
 			l4_proto = ip.v6->nexthdr;
@@ -2429,33 +2431,38 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 						 &l4_proto, &frag_off);
 		}
 
+		/* compute outer L3 header size */
+		tunnel |= ((l4.hdr - ip.hdr) / 4) <<
+			  I40E_TXD_CTX_QW0_EXT_IPLEN_SHIFT;
+
+		/* switch IP header pointer from outer to inner header */
+		ip.hdr = skb_inner_network_header(skb);
+
 		/* define outer transport */
 		switch (l4_proto) {
 		case IPPROTO_UDP:
-			l4_tunnel = I40E_TXD_CTX_UDP_TUNNELING;
+			tunnel |= I40E_TXD_CTX_UDP_TUNNELING;
 			*tx_flags |= I40E_TX_FLAGS_UDP_TUNNEL;
 			break;
 		case IPPROTO_GRE:
-			l4_tunnel = I40E_TXD_CTX_GRE_TUNNELING;
+			tunnel |= I40E_TXD_CTX_GRE_TUNNELING;
 			*tx_flags |= I40E_TX_FLAGS_UDP_TUNNEL;
 			break;
 		default:
 			return;
 		}
 
+		/* compute tunnel header size */
+		tunnel |= ((ip.hdr - l4.hdr) / 2) <<
+			  I40E_TXD_CTX_QW0_NATLEN_SHIFT;
+
+		/* record tunnel offload values */
+		*cd_tunneling |= tunnel;
+
 		/* switch L4 header pointer from outer to inner */
-		ip.hdr = skb_inner_network_header(skb);
 		l4.hdr = skb_inner_transport_header(skb);
 		l4_proto = 0;
 
-		/* Now set the ctx descriptor fields */
-		*cd_tunneling |= (skb_network_header_len(skb) >> 2) <<
-				   I40E_TXD_CTX_QW0_EXT_IPLEN_SHIFT      |
-				   l4_tunnel                             |
-				   ((skb_inner_network_offset(skb) -
-					skb_transport_offset(skb)) >> 1) <<
-				   I40E_TXD_CTX_QW0_NATLEN_SHIFT;
-
 		/* reset type as we transition from outer to inner headers */
 		*tx_flags &= ~(I40E_TX_FLAGS_IPV4 | I40E_TX_FLAGS_IPV6);
 		if (ip.v4->version == 4)
@@ -2470,13 +2477,11 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 		/* the stack computes the IP header already, the only time we
 		 * need the hardware to recompute it is in the case of TSO.
 		 */
-		if (*tx_flags & I40E_TX_FLAGS_TSO) {
-			*td_cmd |= I40E_TX_DESC_CMD_IIPT_IPV4_CSUM;
-		} else {
-			*td_cmd |= I40E_TX_DESC_CMD_IIPT_IPV4;
-		}
+		cmd |= (*tx_flags & I40E_TX_FLAGS_TSO) ?
+		       I40E_TX_DESC_CMD_IIPT_IPV4_CSUM :
+		       I40E_TX_DESC_CMD_IIPT_IPV4;
 	} else if (*tx_flags & I40E_TX_FLAGS_IPV6) {
-		*td_cmd |= I40E_TX_DESC_CMD_IIPT_IPV6;
+		cmd |= I40E_TX_DESC_CMD_IIPT_IPV6;
 
 		exthdr = ip.hdr + sizeof(*ip.v6);
 		l4_proto = ip.v6->nexthdr;
@@ -2485,35 +2490,34 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 					 &l4_proto, &frag_off);
 	}
 
-	/* Now set the td_offset for IP header length */
-	*td_offset = ((l4.hdr - ip.hdr) / 4) << I40E_TX_DESC_LENGTH_IPLEN_SHIFT;
-	/* words in MACLEN + dwords in IPLEN + dwords in L4Len */
-	*td_offset |= (skb_network_offset(skb) >> 1) <<
-		       I40E_TX_DESC_LENGTH_MACLEN_SHIFT;
+	/* compute inner L3 header size */
+	offset |= ((l4.hdr - ip.hdr) / 4) << I40E_TX_DESC_LENGTH_IPLEN_SHIFT;
 
 	/* Enable L4 checksum offloads */
 	switch (l4_proto) {
 	case IPPROTO_TCP:
 		/* enable checksum offloads */
-		*td_cmd |= I40E_TX_DESC_CMD_L4T_EOFT_TCP;
-		*td_offset |= l4.tcp->doff <<
-			       I40E_TX_DESC_LENGTH_L4_FC_LEN_SHIFT;
+		cmd |= I40E_TX_DESC_CMD_L4T_EOFT_TCP;
+		offset |= l4.tcp->doff << I40E_TX_DESC_LENGTH_L4_FC_LEN_SHIFT;
 		break;
 	case IPPROTO_SCTP:
 		/* enable SCTP checksum offload */
-		*td_cmd |= I40E_TX_DESC_CMD_L4T_EOFT_SCTP;
-		*td_offset |= (sizeof(struct sctphdr) >> 2) <<
-			       I40E_TX_DESC_LENGTH_L4_FC_LEN_SHIFT;
+		cmd |= I40E_TX_DESC_CMD_L4T_EOFT_SCTP;
+		offset |= (sizeof(struct sctphdr) >> 2) <<
+			  I40E_TX_DESC_LENGTH_L4_FC_LEN_SHIFT;
 		break;
 	case IPPROTO_UDP:
 		/* enable UDP checksum offload */
-		*td_cmd |= I40E_TX_DESC_CMD_L4T_EOFT_UDP;
-		*td_offset |= (sizeof(struct udphdr) >> 2) <<
-			       I40E_TX_DESC_LENGTH_L4_FC_LEN_SHIFT;
+		cmd |= I40E_TX_DESC_CMD_L4T_EOFT_UDP;
+		offset |= (sizeof(struct udphdr) >> 2) <<
+			  I40E_TX_DESC_LENGTH_L4_FC_LEN_SHIFT;
 		break;
 	default:
 		break;
 	}
+
+	*td_cmd |= cmd;
+	*td_offset |= offset;
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 48ec763..0ee13f6 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1620,24 +1620,26 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 		unsigned char *hdr;
 	} l4;
 	unsigned char *exthdr;
-	u32 l4_tunnel = 0;
+	u32 offset, cmd = 0, tunnel = 0;
 	__be16 frag_off;
 	u8 l4_proto = 0;
 
 	ip.hdr = skb_network_header(skb);
 	l4.hdr = skb_transport_header(skb);
 
+	/* compute outer L2 header size */
+	offset = ((ip.hdr - skb->data) / 2) << I40E_TX_DESC_LENGTH_MACLEN_SHIFT;
+
 	if (skb->encapsulation) {
 		/* define outer network header type */
 		if (*tx_flags & I40E_TX_FLAGS_IPV4) {
-			if (*tx_flags & I40E_TX_FLAGS_TSO)
-				*cd_tunneling |= I40E_TX_CTX_EXT_IP_IPV4;
-			else
-				*cd_tunneling |=
-					 I40E_TX_CTX_EXT_IP_IPV4_NO_CSUM;
+			tunnel |= (*tx_flags & I40E_TX_FLAGS_TSO) ?
+				  I40E_TX_CTX_EXT_IP_IPV4 :
+				  I40E_TX_CTX_EXT_IP_IPV4_NO_CSUM;
+
 			l4_proto = ip.v4->protocol;
 		} else if (*tx_flags & I40E_TX_FLAGS_IPV6) {
-			*cd_tunneling |= I40E_TX_CTX_EXT_IP_IPV6;
+			tunnel |= I40E_TX_CTX_EXT_IP_IPV6;
 
 			exthdr = ip.hdr + sizeof(*ip.v6);
 			l4_proto = ip.v6->nexthdr;
@@ -1646,33 +1648,38 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 						 &l4_proto, &frag_off);
 		}
 
+		/* compute outer L3 header size */
+		tunnel |= ((l4.hdr - ip.hdr) / 4) <<
+			  I40E_TXD_CTX_QW0_EXT_IPLEN_SHIFT;
+
+		/* switch IP header pointer from outer to inner header */
+		ip.hdr = skb_inner_network_header(skb);
+
 		/* define outer transport */
 		switch (l4_proto) {
 		case IPPROTO_UDP:
-			l4_tunnel = I40E_TXD_CTX_UDP_TUNNELING;
+			tunnel |= I40E_TXD_CTX_UDP_TUNNELING;
 			*tx_flags |= I40E_TX_FLAGS_VXLAN_TUNNEL;
 			break;
 		case IPPROTO_GRE:
-			l4_tunnel = I40E_TXD_CTX_GRE_TUNNELING;
+			tunnel |= I40E_TXD_CTX_GRE_TUNNELING;
 			*tx_flags |= I40E_TX_FLAGS_VXLAN_TUNNEL;
 			break;
 		default:
 			return;
 		}
 
+		/* compute tunnel header size */
+		tunnel |= ((ip.hdr - l4.hdr) / 2) <<
+			  I40E_TXD_CTX_QW0_NATLEN_SHIFT;
+
+		/* record tunnel offload values */
+		*cd_tunneling |= tunnel;
+
 		/* switch L4 header pointer from outer to inner */
-		ip.hdr = skb_inner_network_header(skb);
 		l4.hdr = skb_inner_transport_header(skb);
 		l4_proto = 0;
 
-		/* Now set the ctx descriptor fields */
-		*cd_tunneling |= (skb_network_header_len(skb) >> 2) <<
-				   I40E_TXD_CTX_QW0_EXT_IPLEN_SHIFT      |
-				   l4_tunnel                             |
-				   ((skb_inner_network_offset(skb) -
-					skb_transport_offset(skb)) >> 1) <<
-				   I40E_TXD_CTX_QW0_NATLEN_SHIFT;
-
 		/* reset type as we transition from outer to inner headers */
 		*tx_flags &= ~(I40E_TX_FLAGS_IPV4 | I40E_TX_FLAGS_IPV6);
 		if (ip.v4->version == 4)
@@ -1687,13 +1694,11 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 		/* the stack computes the IP header already, the only time we
 		 * need the hardware to recompute it is in the case of TSO.
 		 */
-		if (*tx_flags & I40E_TX_FLAGS_TSO) {
-			*td_cmd |= I40E_TX_DESC_CMD_IIPT_IPV4_CSUM;
-		} else {
-			*td_cmd |= I40E_TX_DESC_CMD_IIPT_IPV4;
-		}
+		cmd |= (*tx_flags & I40E_TX_FLAGS_TSO) ?
+		       I40E_TX_DESC_CMD_IIPT_IPV4_CSUM :
+		       I40E_TX_DESC_CMD_IIPT_IPV4;
 	} else if (*tx_flags & I40E_TX_FLAGS_IPV6) {
-		*td_cmd |= I40E_TX_DESC_CMD_IIPT_IPV6;
+		cmd |= I40E_TX_DESC_CMD_IIPT_IPV6;
 
 		exthdr = ip.hdr + sizeof(*ip.v6);
 		l4_proto = ip.v6->nexthdr;
@@ -1702,35 +1707,34 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 					 &l4_proto, &frag_off);
 	}
 
-	/* Now set the td_offset for IP header length */
-	*td_offset = ((l4.hdr - ip.hdr) / 4) << I40E_TX_DESC_LENGTH_IPLEN_SHIFT;
-	/* words in MACLEN + dwords in IPLEN + dwords in L4Len */
-	*td_offset |= (skb_network_offset(skb) >> 1) <<
-		       I40E_TX_DESC_LENGTH_MACLEN_SHIFT;
+	/* compute inner L3 header size */
+	offset |= ((l4.hdr - ip.hdr) / 4) << I40E_TX_DESC_LENGTH_IPLEN_SHIFT;
 
 	/* Enable L4 checksum offloads */
 	switch (l4_proto) {
 	case IPPROTO_TCP:
 		/* enable checksum offloads */
-		*td_cmd |= I40E_TX_DESC_CMD_L4T_EOFT_TCP;
-		*td_offset |= l4.tcp->doff <<
-			       I40E_TX_DESC_LENGTH_L4_FC_LEN_SHIFT;
+		cmd |= I40E_TX_DESC_CMD_L4T_EOFT_TCP;
+		offset |= l4.tcp->doff << I40E_TX_DESC_LENGTH_L4_FC_LEN_SHIFT;
 		break;
 	case IPPROTO_SCTP:
 		/* enable SCTP checksum offload */
-		*td_cmd |= I40E_TX_DESC_CMD_L4T_EOFT_SCTP;
-		*td_offset |= (sizeof(struct sctphdr) >> 2) <<
-			       I40E_TX_DESC_LENGTH_L4_FC_LEN_SHIFT;
+		cmd |= I40E_TX_DESC_CMD_L4T_EOFT_SCTP;
+		offset |= (sizeof(struct sctphdr) >> 2) <<
+			  I40E_TX_DESC_LENGTH_L4_FC_LEN_SHIFT;
 		break;
 	case IPPROTO_UDP:
 		/* enable UDP checksum offload */
-		*td_cmd |= I40E_TX_DESC_CMD_L4T_EOFT_UDP;
-		*td_offset |= (sizeof(struct udphdr) >> 2) <<
-			       I40E_TX_DESC_LENGTH_L4_FC_LEN_SHIFT;
+		cmd |= I40E_TX_DESC_CMD_L4T_EOFT_UDP;
+		offset |= (sizeof(struct udphdr) >> 2) <<
+			  I40E_TX_DESC_LENGTH_L4_FC_LEN_SHIFT;
 		break;
 	default:
 		break;
 	}
+
+	*td_cmd |= cmd;
+	*td_offset |= offset;
 }
 
 /**
-- 
2.5.0
