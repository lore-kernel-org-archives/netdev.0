From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/16] i40e/i40evf: Replace header pointers with unions of pointers in Tx checksum path
Date: Thu, 18 Feb 2016 16:31:10 -0800
Message-ID: <1455841881-128892-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48151 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965513AbcBSAb0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 19:31:26 -0500
In-Reply-To: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

The Tx checksum path was maintaining a set of 3 pointers and two lengths in
order to prepare the packet for being checksummed.  The thing is we only
really needed 2 pointers, and the lengths that were being maintained can
easily be computed.

As such we can replace the IPv4 and IPv6 header pointers with one single
union that represents both, or a generic pointer to the start of the
network header.  For the L4 headers we can do the same with TCP and a
generic pointer to the start of the transport header.  The length of the
TCP header is obtained by simply multiplying doff by 4, and the network
header length can be obtained by subtracting the network header pointer
from the transport header pointer.

While I was at it I renamed l4_hdr to l4_proto to make it a bit more clear
and less likely to be confused with l4.hdr which is the transport header
pointer.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 51 +++++++++++++-------------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 52 +++++++++++++--------------
 2 files changed, 52 insertions(+), 51 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index f47f9cb..5cc7e71 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2392,12 +2392,21 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 				struct i40e_ring *tx_ring,
 				u32 *cd_tunneling)
 {
-	struct ipv6hdr *this_ipv6_hdr;
-	unsigned int this_tcp_hdrlen;
-	struct iphdr *this_ip_hdr;
-	u32 network_hdr_len;
-	u8 l4_hdr = 0;
+	union {
+		struct iphdr *v4;
+		struct ipv6hdr *v6;
+		unsigned char *hdr;
+	} ip;
+	union {
+		struct tcphdr *tcp;
+		struct udphdr *udp;
+		unsigned char *hdr;
+	} l4;
 	u32 l4_tunnel = 0;
+	u8 l4_proto = 0;
+
+	ip.hdr = skb_network_header(skb);
+	l4.hdr = skb_transport_header(skb);
 
 	if (skb->encapsulation) {
 		switch (ip_hdr(skb)->protocol) {
@@ -2411,10 +2420,10 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 		default:
 			return;
 		}
-		network_hdr_len = skb_inner_network_header_len(skb);
-		this_ip_hdr = inner_ip_hdr(skb);
-		this_ipv6_hdr = inner_ipv6_hdr(skb);
-		this_tcp_hdrlen = inner_tcp_hdrlen(skb);
+
+		/* switch L4 header pointer from outer to inner */
+		ip.hdr = skb_inner_network_header(skb);
+		l4.hdr = skb_inner_transport_header(skb);
 
 		if (*tx_flags & I40E_TX_FLAGS_IPV4) {
 			if (*tx_flags & I40E_TX_FLAGS_TSO) {
@@ -2434,20 +2443,15 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 				   ((skb_inner_network_offset(skb) -
 					skb_transport_offset(skb)) >> 1) <<
 				   I40E_TXD_CTX_QW0_NATLEN_SHIFT;
-		if (this_ip_hdr->version == 6) {
+		if (ip.v6->version == 6) {
 			*tx_flags &= ~I40E_TX_FLAGS_IPV4;
 			*tx_flags |= I40E_TX_FLAGS_IPV6;
 		}
-	} else {
-		network_hdr_len = skb_network_header_len(skb);
-		this_ip_hdr = ip_hdr(skb);
-		this_ipv6_hdr = ipv6_hdr(skb);
-		this_tcp_hdrlen = tcp_hdrlen(skb);
 	}
 
 	/* Enable IP checksum offloads */
 	if (*tx_flags & I40E_TX_FLAGS_IPV4) {
-		l4_hdr = this_ip_hdr->protocol;
+		l4_proto = ip.v4->protocol;
 		/* the stack computes the IP header already, the only time we
 		 * need the hardware to recompute it is in the case of TSO.
 		 */
@@ -2456,26 +2460,23 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 		} else {
 			*td_cmd |= I40E_TX_DESC_CMD_IIPT_IPV4;
 		}
-		/* Now set the td_offset for IP header length */
-		*td_offset = (network_hdr_len >> 2) <<
-			      I40E_TX_DESC_LENGTH_IPLEN_SHIFT;
 	} else if (*tx_flags & I40E_TX_FLAGS_IPV6) {
-		l4_hdr = this_ipv6_hdr->nexthdr;
+		l4_proto = ip.v6->nexthdr;
 		*td_cmd |= I40E_TX_DESC_CMD_IIPT_IPV6;
-		/* Now set the td_offset for IP header length */
-		*td_offset = (network_hdr_len >> 2) <<
-			      I40E_TX_DESC_LENGTH_IPLEN_SHIFT;
 	}
+
+	/* Now set the td_offset for IP header length */
+	*td_offset = ((l4.hdr - ip.hdr) / 4) << I40E_TX_DESC_LENGTH_IPLEN_SHIFT;
 	/* words in MACLEN + dwords in IPLEN + dwords in L4Len */
 	*td_offset |= (skb_network_offset(skb) >> 1) <<
 		       I40E_TX_DESC_LENGTH_MACLEN_SHIFT;
 
 	/* Enable L4 checksum offloads */
-	switch (l4_hdr) {
+	switch (l4_proto) {
 	case IPPROTO_TCP:
 		/* enable checksum offloads */
 		*td_cmd |= I40E_TX_DESC_CMD_L4T_EOFT_TCP;
-		*td_offset |= (this_tcp_hdrlen >> 2) <<
+		*td_offset |= l4.tcp->doff <<
 			       I40E_TX_DESC_LENGTH_L4_FC_LEN_SHIFT;
 		break;
 	case IPPROTO_SCTP:
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index b5b2527..29af3c9f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1609,12 +1609,21 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 				struct i40e_ring *tx_ring,
 				u32 *cd_tunneling)
 {
-	struct ipv6hdr *this_ipv6_hdr;
-	unsigned int this_tcp_hdrlen;
-	struct iphdr *this_ip_hdr;
-	u32 network_hdr_len;
-	u8 l4_hdr = 0;
+	union {
+		struct iphdr *v4;
+		struct ipv6hdr *v6;
+		unsigned char *hdr;
+	} ip;
+	union {
+		struct tcphdr *tcp;
+		struct udphdr *udp;
+		unsigned char *hdr;
+	} l4;
 	u32 l4_tunnel = 0;
+	u8 l4_proto = 0;
+
+	ip.hdr = skb_network_header(skb);
+	l4.hdr = skb_transport_header(skb);
 
 	if (skb->encapsulation) {
 		switch (ip_hdr(skb)->protocol) {
@@ -1625,10 +1634,10 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 		default:
 			return;
 		}
-		network_hdr_len = skb_inner_network_header_len(skb);
-		this_ip_hdr = inner_ip_hdr(skb);
-		this_ipv6_hdr = inner_ipv6_hdr(skb);
-		this_tcp_hdrlen = inner_tcp_hdrlen(skb);
+
+		/* switch L4 header pointer from outer to inner */
+		ip.hdr = skb_inner_network_header(skb);
+		l4.hdr = skb_inner_transport_header(skb);
 
 		if (*tx_flags & I40E_TX_FLAGS_IPV4) {
 			if (*tx_flags & I40E_TX_FLAGS_TSO) {
@@ -1648,21 +1657,15 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 				   ((skb_inner_network_offset(skb) -
 					skb_transport_offset(skb)) >> 1) <<
 				   I40E_TXD_CTX_QW0_NATLEN_SHIFT;
-		if (this_ip_hdr->version == 6) {
+		if (ip.v6->version == 6) {
 			*tx_flags &= ~I40E_TX_FLAGS_IPV4;
 			*tx_flags |= I40E_TX_FLAGS_IPV6;
 		}
-
-	} else {
-		network_hdr_len = skb_network_header_len(skb);
-		this_ip_hdr = ip_hdr(skb);
-		this_ipv6_hdr = ipv6_hdr(skb);
-		this_tcp_hdrlen = tcp_hdrlen(skb);
 	}
 
 	/* Enable IP checksum offloads */
 	if (*tx_flags & I40E_TX_FLAGS_IPV4) {
-		l4_hdr = this_ip_hdr->protocol;
+		l4_proto = ip.v4->protocol;
 		/* the stack computes the IP header already, the only time we
 		 * need the hardware to recompute it is in the case of TSO.
 		 */
@@ -1671,26 +1674,23 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 		} else {
 			*td_cmd |= I40E_TX_DESC_CMD_IIPT_IPV4;
 		}
-		/* Now set the td_offset for IP header length */
-		*td_offset = (network_hdr_len >> 2) <<
-			      I40E_TX_DESC_LENGTH_IPLEN_SHIFT;
 	} else if (*tx_flags & I40E_TX_FLAGS_IPV6) {
-		l4_hdr = this_ipv6_hdr->nexthdr;
+		l4_proto = ip.v6->nexthdr;
 		*td_cmd |= I40E_TX_DESC_CMD_IIPT_IPV6;
-		/* Now set the td_offset for IP header length */
-		*td_offset = (network_hdr_len >> 2) <<
-			      I40E_TX_DESC_LENGTH_IPLEN_SHIFT;
 	}
+
+	/* Now set the td_offset for IP header length */
+	*td_offset = ((l4.hdr - ip.hdr) / 4) << I40E_TX_DESC_LENGTH_IPLEN_SHIFT;
 	/* words in MACLEN + dwords in IPLEN + dwords in L4Len */
 	*td_offset |= (skb_network_offset(skb) >> 1) <<
 		       I40E_TX_DESC_LENGTH_MACLEN_SHIFT;
 
 	/* Enable L4 checksum offloads */
-	switch (l4_hdr) {
+	switch (l4_proto) {
 	case IPPROTO_TCP:
 		/* enable checksum offloads */
 		*td_cmd |= I40E_TX_DESC_CMD_L4T_EOFT_TCP;
-		*td_offset |= (this_tcp_hdrlen >> 2) <<
+		*td_offset |= l4.tcp->doff <<
 			       I40E_TX_DESC_LENGTH_L4_FC_LEN_SHIFT;
 		break;
 	case IPPROTO_SCTP:
-- 
2.5.0
