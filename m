From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] i40e/i40evf: Simplify tunnel selection logic
Date: Sat,  7 Mar 2015 07:03:19 -0800
Message-ID: <1425740603-11280-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425740603-11280-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:38815 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751528AbbCGPDb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Mar 2015 10:03:31 -0500
In-Reply-To: <1425740603-11280-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Use l4_tunnel type generically to keep code flow simple.

Change-ID: Ic52287e3b1ca4204e6b6e13431890c1a6ae9c422
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 12 ++++++++++--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 12 ++++++++++--
 2 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index cdd5cc1..a60b840 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2216,8 +2216,16 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 tx_flags,
 	struct iphdr *this_ip_hdr;
 	u32 network_hdr_len;
 	u8 l4_hdr = 0;
+	u32 l4_tunnel = 0;
 
 	if (skb->encapsulation) {
+		switch (ip_hdr(skb)->protocol) {
+		case IPPROTO_UDP:
+			l4_tunnel = I40E_TXD_CTX_UDP_TUNNELING;
+			break;
+		default:
+			return;
+		}
 		network_hdr_len = skb_inner_network_header_len(skb);
 		this_ip_hdr = inner_ip_hdr(skb);
 		this_ipv6_hdr = inner_ipv6_hdr(skb);
@@ -2240,8 +2248,8 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 tx_flags,
 
 		/* Now set the ctx descriptor fields */
 		*cd_tunneling |= (skb_network_header_len(skb) >> 2) <<
-					I40E_TXD_CTX_QW0_EXT_IPLEN_SHIFT |
-				   I40E_TXD_CTX_UDP_TUNNELING            |
+				   I40E_TXD_CTX_QW0_EXT_IPLEN_SHIFT      |
+				   l4_tunnel                             |
 				   ((skb_inner_network_offset(skb) -
 					skb_transport_offset(skb)) >> 1) <<
 				   I40E_TXD_CTX_QW0_NATLEN_SHIFT;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 021b0d4..1c2637b 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1461,8 +1461,16 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 tx_flags,
 	struct iphdr *this_ip_hdr;
 	u32 network_hdr_len;
 	u8 l4_hdr = 0;
+	u32 l4_tunnel = 0;
 
 	if (skb->encapsulation) {
+		switch (ip_hdr(skb)->protocol) {
+		case IPPROTO_UDP:
+			l4_tunnel = I40E_TXD_CTX_UDP_TUNNELING;
+			break;
+		default:
+			return;
+		}
 		network_hdr_len = skb_inner_network_header_len(skb);
 		this_ip_hdr = inner_ip_hdr(skb);
 		this_ipv6_hdr = inner_ipv6_hdr(skb);
@@ -1485,8 +1493,8 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 tx_flags,
 
 		/* Now set the ctx descriptor fields */
 		*cd_tunneling |= (skb_network_header_len(skb) >> 2) <<
-					I40E_TXD_CTX_QW0_EXT_IPLEN_SHIFT |
-				   I40E_TXD_CTX_UDP_TUNNELING            |
+				   I40E_TXD_CTX_QW0_EXT_IPLEN_SHIFT      |
+				   l4_tunnel                             |
 				   ((skb_inner_network_offset(skb) -
 					skb_transport_offset(skb)) >> 1) <<
 				   I40E_TXD_CTX_QW0_NATLEN_SHIFT;
-- 
1.9.3
