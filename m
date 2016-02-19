From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/16] i40e/i40evf: Clean-up Rx packet checksum handling
Date: Thu, 18 Feb 2016 16:31:15 -0800
Message-ID: <1455841881-128892-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48151 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965707AbcBSAbg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 19:31:36 -0500
In-Reply-To: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

This is mostly a minor clean-up for the Rx checksum path in order to avoid
some of the unnecessary conditional checks that were being applied.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 23 ++++++++++-------------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 23 ++++++++++-------------
 2 files changed, 20 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 6b08b0f..ded73c0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1389,13 +1389,7 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 				    u16 rx_ptype)
 {
 	struct i40e_rx_ptype_decoded decoded = decode_rx_desc_ptype(rx_ptype);
-	bool ipv4 = false, ipv6 = false;
-	bool ipv4_tunnel, ipv6_tunnel;
-
-	ipv4_tunnel = (rx_ptype >= I40E_RX_PTYPE_GRENAT4_MAC_PAY3) &&
-		     (rx_ptype <= I40E_RX_PTYPE_GRENAT4_MACVLAN_IPV6_ICMP_PAY4);
-	ipv6_tunnel = (rx_ptype >= I40E_RX_PTYPE_GRENAT6_MAC_PAY3) &&
-		     (rx_ptype <= I40E_RX_PTYPE_GRENAT6_MACVLAN_IPV6_ICMP_PAY4);
+	bool ipv4, ipv6, ipv4_tunnel, ipv6_tunnel;
 
 	skb->ip_summed = CHECKSUM_NONE;
 
@@ -1411,12 +1405,10 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 	if (!(decoded.known && decoded.outer_ip))
 		return;
 
-	if (decoded.outer_ip == I40E_RX_PTYPE_OUTER_IP &&
-	    decoded.outer_ip_ver == I40E_RX_PTYPE_OUTER_IPV4)
-		ipv4 = true;
-	else if (decoded.outer_ip == I40E_RX_PTYPE_OUTER_IP &&
-		 decoded.outer_ip_ver == I40E_RX_PTYPE_OUTER_IPV6)
-		ipv6 = true;
+	ipv4 = (decoded.outer_ip == I40E_RX_PTYPE_OUTER_IP) &&
+	       (decoded.outer_ip_ver == I40E_RX_PTYPE_OUTER_IPV4);
+	ipv6 = (decoded.outer_ip == I40E_RX_PTYPE_OUTER_IP) &&
+	       (decoded.outer_ip_ver == I40E_RX_PTYPE_OUTER_IPV6);
 
 	if (ipv4 &&
 	    (rx_error & (BIT(I40E_RX_DESC_ERROR_IPE_SHIFT) |
@@ -1447,6 +1439,11 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 	 * inner checksum report CHECKSUM_UNNECESSARY.
 	 */
 
+	ipv4_tunnel = (rx_ptype >= I40E_RX_PTYPE_GRENAT4_MAC_PAY3) &&
+		     (rx_ptype <= I40E_RX_PTYPE_GRENAT4_MACVLAN_IPV6_ICMP_PAY4);
+	ipv6_tunnel = (rx_ptype >= I40E_RX_PTYPE_GRENAT6_MAC_PAY3) &&
+		     (rx_ptype <= I40E_RX_PTYPE_GRENAT6_MACVLAN_IPV6_ICMP_PAY4);
+
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb->csum_level = ipv4_tunnel || ipv6_tunnel;
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 143c570..3f40e0e 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -861,13 +861,7 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 				    u16 rx_ptype)
 {
 	struct i40e_rx_ptype_decoded decoded = decode_rx_desc_ptype(rx_ptype);
-	bool ipv4 = false, ipv6 = false;
-	bool ipv4_tunnel, ipv6_tunnel;
-
-	ipv4_tunnel = (rx_ptype >= I40E_RX_PTYPE_GRENAT4_MAC_PAY3) &&
-		     (rx_ptype <= I40E_RX_PTYPE_GRENAT4_MACVLAN_IPV6_ICMP_PAY4);
-	ipv6_tunnel = (rx_ptype >= I40E_RX_PTYPE_GRENAT6_MAC_PAY3) &&
-		     (rx_ptype <= I40E_RX_PTYPE_GRENAT6_MACVLAN_IPV6_ICMP_PAY4);
+	bool ipv4, ipv6, ipv4_tunnel, ipv6_tunnel;
 
 	skb->ip_summed = CHECKSUM_NONE;
 
@@ -883,12 +877,10 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 	if (!(decoded.known && decoded.outer_ip))
 		return;
 
-	if (decoded.outer_ip == I40E_RX_PTYPE_OUTER_IP &&
-	    decoded.outer_ip_ver == I40E_RX_PTYPE_OUTER_IPV4)
-		ipv4 = true;
-	else if (decoded.outer_ip == I40E_RX_PTYPE_OUTER_IP &&
-		 decoded.outer_ip_ver == I40E_RX_PTYPE_OUTER_IPV6)
-		ipv6 = true;
+	ipv4 = (decoded.outer_ip == I40E_RX_PTYPE_OUTER_IP) &&
+	       (decoded.outer_ip_ver == I40E_RX_PTYPE_OUTER_IPV4);
+	ipv6 = (decoded.outer_ip == I40E_RX_PTYPE_OUTER_IP) &&
+	       (decoded.outer_ip_ver == I40E_RX_PTYPE_OUTER_IPV6);
 
 	if (ipv4 &&
 	    (rx_error & (BIT(I40E_RX_DESC_ERROR_IPE_SHIFT) |
@@ -919,6 +911,11 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 	 * inner checksum report CHECKSUM_UNNECESSARY.
 	 */
 
+	ipv4_tunnel = (rx_ptype >= I40E_RX_PTYPE_GRENAT4_MAC_PAY3) &&
+		     (rx_ptype <= I40E_RX_PTYPE_GRENAT4_MACVLAN_IPV6_ICMP_PAY4);
+	ipv6_tunnel = (rx_ptype >= I40E_RX_PTYPE_GRENAT6_MAC_PAY3) &&
+		     (rx_ptype <= I40E_RX_PTYPE_GRENAT6_MACVLAN_IPV6_ICMP_PAY4);
+
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb->csum_level = ipv4_tunnel || ipv6_tunnel;
 
-- 
2.5.0
