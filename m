From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/11] i40e/i40evf: Refactor tunnel interpretation
Date: Fri,  6 May 2016 00:03:38 -0700
Message-ID: <1462518228-30527-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462518228-30527-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:40771 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752084AbcEFHG2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2016 03:06:28 -0400
In-Reply-To: <1462518228-30527-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Refactor the interpretation of a tunnel.  This removes
some code and lets us start using the hardware's parsing.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 13 ++++++-------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 13 ++++++-------
 2 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 2765d7e..dab733c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1392,7 +1392,7 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 				    u16 rx_ptype)
 {
 	struct i40e_rx_ptype_decoded decoded = decode_rx_desc_ptype(rx_ptype);
-	bool ipv4, ipv6, ipv4_tunnel, ipv6_tunnel;
+	bool ipv4, ipv6, tunnel = false;
 
 	skb->ip_summed = CHECKSUM_NONE;
 
@@ -1441,14 +1441,13 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 	 * doesn't make it a hard requirement so if we have validated the
 	 * inner checksum report CHECKSUM_UNNECESSARY.
 	 */
-
-	ipv4_tunnel = (rx_ptype >= I40E_RX_PTYPE_GRENAT4_MAC_PAY3) &&
-		     (rx_ptype <= I40E_RX_PTYPE_GRENAT4_MACVLAN_IPV6_ICMP_PAY4);
-	ipv6_tunnel = (rx_ptype >= I40E_RX_PTYPE_GRENAT6_MAC_PAY3) &&
-		     (rx_ptype <= I40E_RX_PTYPE_GRENAT6_MACVLAN_IPV6_ICMP_PAY4);
+	if (decoded.inner_prot & (I40E_RX_PTYPE_INNER_PROT_TCP |
+				  I40E_RX_PTYPE_INNER_PROT_UDP |
+				  I40E_RX_PTYPE_INNER_PROT_SCTP))
+		tunnel = true;
 
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
-	skb->csum_level = ipv4_tunnel || ipv6_tunnel;
+	skb->csum_level = tunnel ? 1 : 0;
 
 	return;
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index ede8dfc..a37a3f3 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -864,7 +864,7 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 				    u16 rx_ptype)
 {
 	struct i40e_rx_ptype_decoded decoded = decode_rx_desc_ptype(rx_ptype);
-	bool ipv4, ipv6, ipv4_tunnel, ipv6_tunnel;
+	bool ipv4, ipv6, tunnel = false;
 
 	skb->ip_summed = CHECKSUM_NONE;
 
@@ -913,14 +913,13 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 	 * doesn't make it a hard requirement so if we have validated the
 	 * inner checksum report CHECKSUM_UNNECESSARY.
 	 */
-
-	ipv4_tunnel = (rx_ptype >= I40E_RX_PTYPE_GRENAT4_MAC_PAY3) &&
-		     (rx_ptype <= I40E_RX_PTYPE_GRENAT4_MACVLAN_IPV6_ICMP_PAY4);
-	ipv6_tunnel = (rx_ptype >= I40E_RX_PTYPE_GRENAT6_MAC_PAY3) &&
-		     (rx_ptype <= I40E_RX_PTYPE_GRENAT6_MACVLAN_IPV6_ICMP_PAY4);
+	if (decoded.inner_prot & (I40E_RX_PTYPE_INNER_PROT_TCP |
+				  I40E_RX_PTYPE_INNER_PROT_UDP |
+				  I40E_RX_PTYPE_INNER_PROT_SCTP))
+		tunnel = true;
 
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
-	skb->csum_level = ipv4_tunnel || ipv6_tunnel;
+	skb->csum_level = tunnel ? 1 : 0;
 
 	return;
 
-- 
2.5.5
