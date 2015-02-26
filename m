From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 09/13] i40evf: TCP/IPv6 over Vxlan Tx checksum offload fix
Date: Thu, 26 Feb 2015 07:03:45 -0800
Message-ID: <1424963029-4612-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424963029-4612-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai <anjali.singhai@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:40565 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753950AbbBZPD5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2015 10:03:57 -0500
In-Reply-To: <1424963029-4612-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai <anjali.singhai@intel.com>

We were checking the outer Protocol flags and deciding the flow for
inner header. This patch fixes that.
This fixes the Tx checksum offload for TCP/IPv6 over vxlan.

Change-ID: I837aaea921d34f71b24c2bc32aaadea5001ddf78
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index be05829..7088915 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1212,17 +1212,16 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	if (err < 0)
 		return err;
 
-	if (protocol == htons(ETH_P_IP)) {
-		iph = skb->encapsulation ? inner_ip_hdr(skb) : ip_hdr(skb);
+	iph = skb->encapsulation ? inner_ip_hdr(skb) : ip_hdr(skb);
+	ipv6h = skb->encapsulation ? inner_ipv6_hdr(skb) : ipv6_hdr(skb);
+
+	if (iph->version == 4) {
 		tcph = skb->encapsulation ? inner_tcp_hdr(skb) : tcp_hdr(skb);
 		iph->tot_len = 0;
 		iph->check = 0;
 		tcph->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
 						 0, IPPROTO_TCP, 0);
-	} else if (skb_is_gso_v6(skb)) {
-
-		ipv6h = skb->encapsulation ? inner_ipv6_hdr(skb)
-					   : ipv6_hdr(skb);
+	} else if (ipv6h->version == 6) {
 		tcph = skb->encapsulation ? inner_tcp_hdr(skb) : tcp_hdr(skb);
 		ipv6h->payload_len = 0;
 		tcph->check = ~csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr,
@@ -1280,13 +1279,9 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 tx_flags,
 					 I40E_TX_CTX_EXT_IP_IPV4_NO_CSUM;
 			}
 		} else if (tx_flags & I40E_TX_FLAGS_IPV6) {
-			if (tx_flags & I40E_TX_FLAGS_TSO) {
-				*cd_tunneling |= I40E_TX_CTX_EXT_IP_IPV6;
+			*cd_tunneling |= I40E_TX_CTX_EXT_IP_IPV6;
+			if (tx_flags & I40E_TX_FLAGS_TSO)
 				ip_hdr(skb)->check = 0;
-			} else {
-				*cd_tunneling |=
-					 I40E_TX_CTX_EXT_IP_IPV4_NO_CSUM;
-			}
 		}
 
 		/* Now set the ctx descriptor fields */
@@ -1296,6 +1291,11 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 tx_flags,
 				   ((skb_inner_network_offset(skb) -
 					skb_transport_offset(skb)) >> 1) <<
 				   I40E_TXD_CTX_QW0_NATLEN_SHIFT;
+		if (this_ip_hdr->version == 6) {
+			tx_flags &= ~I40E_TX_FLAGS_IPV4;
+			tx_flags |= I40E_TX_FLAGS_IPV6;
+		}
+
 
 	} else {
 		network_hdr_len = skb_network_header_len(skb);
-- 
1.9.3
