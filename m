From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net v2 3/3] i40e: Fix bug with TCP over IPv6 over VXLAN
Date: Tue,  6 Jan 2015 17:31:57 -0800
Message-ID: <1420594317-6191-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1420594317-6191-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai <anjali.singhai@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:43210 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756520AbbAGBcH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2015 20:32:07 -0500
In-Reply-To: <1420594317-6191-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai <anjali.singhai@intel.com>

The driver was examining the outer protocol layer to set the inner protocol
layer checksum offload.  In the case of TCP over IPV6 over an IPv4 based
VXLAN the inner checksum offloads would be set to look for IPv4/UDP instead
of IPv6/TCP.  This code fixes that so that the driver will look at the
proper layer for encapsulation offload settings.

Signed-off-by: Anjali Singhai <anjali.singhai@intel.com>
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 38c7638..cecb340 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1883,17 +1883,16 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
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
@@ -1989,13 +1988,9 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 tx_flags,
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
@@ -2005,7 +2000,10 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 tx_flags,
 				   ((skb_inner_network_offset(skb) -
 					skb_transport_offset(skb)) >> 1) <<
 				   I40E_TXD_CTX_QW0_NATLEN_SHIFT;
-
+		if (this_ip_hdr->version == 6) {
+			tx_flags &= ~I40E_TX_FLAGS_IPV4;
+			tx_flags |= I40E_TX_FLAGS_IPV6;
+		}
 	} else {
 		network_hdr_len = skb_network_header_len(skb);
 		this_ip_hdr = ip_hdr(skb);
-- 
1.9.3
