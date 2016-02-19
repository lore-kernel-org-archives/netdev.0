From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/16] i40e/i40evf: Add support for IPv4 encapsulated in IPv6
Date: Thu, 18 Feb 2016 16:31:11 -0800
Message-ID: <1455841881-128892-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49646 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965677AbcBSAbe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 19:31:34 -0500
In-Reply-To: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

This patch fixes two issues.  First was the fact that iphdr(skb)->protocl
was being used to test for the outer transport protocol.  This completely
breaks IPv6 support.  Second was the fact that we cleared the flag for v4
going to v6, but we didn't take care of txflags going the other way.  As
such we would have the v6 flag still set even if the inner header was v4.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 38 +++++++++++++++----------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 41 +++++++++++++++++----------
 2 files changed, 49 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 5cc7e71..1404cae 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2409,13 +2409,28 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 	l4.hdr = skb_transport_header(skb);
 
 	if (skb->encapsulation) {
-		switch (ip_hdr(skb)->protocol) {
+		/* define outer network header type */
+		if (*tx_flags & I40E_TX_FLAGS_IPV4) {
+			if (*tx_flags & I40E_TX_FLAGS_TSO)
+				*cd_tunneling |= I40E_TX_CTX_EXT_IP_IPV4;
+			else
+				*cd_tunneling |=
+					 I40E_TX_CTX_EXT_IP_IPV4_NO_CSUM;
+			l4_proto = ip.v4->protocol;
+		} else if (*tx_flags & I40E_TX_FLAGS_IPV6) {
+			*cd_tunneling |= I40E_TX_CTX_EXT_IP_IPV6;
+			l4_proto = ip.v6->nexthdr;
+		}
+
+		/* define outer transport */
+		switch (l4_proto) {
 		case IPPROTO_UDP:
 			l4_tunnel = I40E_TXD_CTX_UDP_TUNNELING;
 			*tx_flags |= I40E_TX_FLAGS_UDP_TUNNEL;
 			break;
 		case IPPROTO_GRE:
 			l4_tunnel = I40E_TXD_CTX_GRE_TUNNELING;
+			*tx_flags |= I40E_TX_FLAGS_UDP_TUNNEL;
 			break;
 		default:
 			return;
@@ -2424,17 +2439,7 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 		/* switch L4 header pointer from outer to inner */
 		ip.hdr = skb_inner_network_header(skb);
 		l4.hdr = skb_inner_transport_header(skb);
-
-		if (*tx_flags & I40E_TX_FLAGS_IPV4) {
-			if (*tx_flags & I40E_TX_FLAGS_TSO) {
-				*cd_tunneling |= I40E_TX_CTX_EXT_IP_IPV4;
-			} else {
-				*cd_tunneling |=
-					 I40E_TX_CTX_EXT_IP_IPV4_NO_CSUM;
-			}
-		} else if (*tx_flags & I40E_TX_FLAGS_IPV6) {
-			*cd_tunneling |= I40E_TX_CTX_EXT_IP_IPV6;
-		}
+		l4_proto = 0;
 
 		/* Now set the ctx descriptor fields */
 		*cd_tunneling |= (skb_network_header_len(skb) >> 2) <<
@@ -2443,10 +2448,13 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 				   ((skb_inner_network_offset(skb) -
 					skb_transport_offset(skb)) >> 1) <<
 				   I40E_TXD_CTX_QW0_NATLEN_SHIFT;
-		if (ip.v6->version == 6) {
-			*tx_flags &= ~I40E_TX_FLAGS_IPV4;
+
+		/* reset type as we transition from outer to inner headers */
+		*tx_flags &= ~(I40E_TX_FLAGS_IPV4 | I40E_TX_FLAGS_IPV6);
+		if (ip.v4->version == 4)
+			*tx_flags |= I40E_TX_FLAGS_IPV4;
+		if (ip.v6->version == 6)
 			*tx_flags |= I40E_TX_FLAGS_IPV6;
-		}
 	}
 
 	/* Enable IP checksum offloads */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 29af3c9f..39d5f80 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1626,11 +1626,29 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 	l4.hdr = skb_transport_header(skb);
 
 	if (skb->encapsulation) {
-		switch (ip_hdr(skb)->protocol) {
+		/* define outer network header type */
+		if (*tx_flags & I40E_TX_FLAGS_IPV4) {
+			if (*tx_flags & I40E_TX_FLAGS_TSO)
+				*cd_tunneling |= I40E_TX_CTX_EXT_IP_IPV4;
+			else
+				*cd_tunneling |=
+					 I40E_TX_CTX_EXT_IP_IPV4_NO_CSUM;
+			l4_proto = ip.v4->protocol;
+		} else if (*tx_flags & I40E_TX_FLAGS_IPV6) {
+			*cd_tunneling |= I40E_TX_CTX_EXT_IP_IPV6;
+			l4_proto = ip.v6->nexthdr;
+		}
+
+		/* define outer transport */
+		switch (l4_proto) {
 		case IPPROTO_UDP:
 			l4_tunnel = I40E_TXD_CTX_UDP_TUNNELING;
 			*tx_flags |= I40E_TX_FLAGS_VXLAN_TUNNEL;
 			break;
+		case IPPROTO_GRE:
+			l4_tunnel = I40E_TXD_CTX_GRE_TUNNELING;
+			*tx_flags |= I40E_TX_FLAGS_VXLAN_TUNNEL;
+			break;
 		default:
 			return;
 		}
@@ -1638,17 +1656,7 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 		/* switch L4 header pointer from outer to inner */
 		ip.hdr = skb_inner_network_header(skb);
 		l4.hdr = skb_inner_transport_header(skb);
-
-		if (*tx_flags & I40E_TX_FLAGS_IPV4) {
-			if (*tx_flags & I40E_TX_FLAGS_TSO) {
-				*cd_tunneling |= I40E_TX_CTX_EXT_IP_IPV4;
-			} else {
-				*cd_tunneling |=
-					 I40E_TX_CTX_EXT_IP_IPV4_NO_CSUM;
-			}
-		} else if (*tx_flags & I40E_TX_FLAGS_IPV6) {
-			*cd_tunneling |= I40E_TX_CTX_EXT_IP_IPV6;
-		}
+		l4_proto = 0;
 
 		/* Now set the ctx descriptor fields */
 		*cd_tunneling |= (skb_network_header_len(skb) >> 2) <<
@@ -1657,10 +1665,13 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 				   ((skb_inner_network_offset(skb) -
 					skb_transport_offset(skb)) >> 1) <<
 				   I40E_TXD_CTX_QW0_NATLEN_SHIFT;
-		if (ip.v6->version == 6) {
-			*tx_flags &= ~I40E_TX_FLAGS_IPV4;
+
+		/* reset type as we transition from outer to inner headers */
+		*tx_flags &= ~(I40E_TX_FLAGS_IPV4 | I40E_TX_FLAGS_IPV6);
+		if (ip.v4->version == 4)
+			*tx_flags |= I40E_TX_FLAGS_IPV4;
+		if (ip.v6->version == 6)
 			*tx_flags |= I40E_TX_FLAGS_IPV6;
-		}
 	}
 
 	/* Enable IP checksum offloads */
-- 
2.5.0
