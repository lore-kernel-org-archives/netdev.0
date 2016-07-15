From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/4] i40e/i40evf: Fix i40e_rx_checksum
Date: Fri, 15 Jul 2016 00:02:01 -0700
Message-ID: <1468566124-63101-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1468566124-63101-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:56902 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752533AbcGOHCr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2016 03:02:47 -0400
In-Reply-To: <1468566124-63101-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

There are a couple of issues I found in i40e_rx_checksum while doing some
recent testing.  As a result I have found the Rx checksum logic is pretty
much broken and returning that the checksum is valid for tunnels in cases
where it is not.

First the inner types are not the correct values to use to test for if a
tunnel is present or not.  In addition the inner protocol types are not a
bitmask as such performing an OR of the values doesn't make sense.  I have
instead changed the code so that the inner protocol types are used to
determine if we report CHECKSUM_UNNECESSARY or not.  For anything that does
not end in UDP, TCP, or SCTP it doesn't make much sense to report a
checksum offload since it won't contain a checksum anyway.

This leaves us with the need to set the csum_level based on some value.
For that purpose I am using the tunnel_type field.  If the tunnel type is
GRENAT or greater then this means we have a GRE or UDP tunnel with an inner
header.  In the case of GRE or UDP we will have a possible checksum present
so for this reason it should be safe to set the csum_level to 1 to indicate
that we are reporting the state of the inner header.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 30 +++++++++++++++------------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 30 +++++++++++++++------------
 2 files changed, 34 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 55f151f..a8868e1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1280,8 +1280,8 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 				    union i40e_rx_desc *rx_desc)
 {
 	struct i40e_rx_ptype_decoded decoded;
-	bool ipv4, ipv6, tunnel = false;
 	u32 rx_error, rx_status;
+	bool ipv4, ipv6;
 	u8 ptype;
 	u64 qword;
 
@@ -1336,19 +1336,23 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 	if (rx_error & BIT(I40E_RX_DESC_ERROR_PPRS_SHIFT))
 		return;
 
-	/* The hardware supported by this driver does not validate outer
-	 * checksums for tunneled VXLAN or GENEVE frames.  I don't agree
-	 * with it but the specification states that you "MAY validate", it
-	 * doesn't make it a hard requirement so if we have validated the
-	 * inner checksum report CHECKSUM_UNNECESSARY.
+	/* If there is an outer header present that might contain a checksum
+	 * we need to bump the checksum level by 1 to reflect the fact that
+	 * we are indicating we validated the inner checksum.
 	 */
-	if (decoded.inner_prot & (I40E_RX_PTYPE_INNER_PROT_TCP |
-				  I40E_RX_PTYPE_INNER_PROT_UDP |
-				  I40E_RX_PTYPE_INNER_PROT_SCTP))
-		tunnel = true;
-
-	skb->ip_summed = CHECKSUM_UNNECESSARY;
-	skb->csum_level = tunnel ? 1 : 0;
+	if (decoded.tunnel_type >= I40E_RX_PTYPE_TUNNEL_IP_GRENAT)
+		skb->csum_level = 1;
+
+	/* Only report checksum unnecessary for TCP, UDP, or SCTP */
+	switch (decoded.inner_prot) {
+	case I40E_RX_PTYPE_INNER_PROT_TCP:
+	case I40E_RX_PTYPE_INNER_PROT_UDP:
+	case I40E_RX_PTYPE_INNER_PROT_SCTP:
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		/* fall though */
+	default:
+		break;
+	}
 
 	return;
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index be99189..79d99cd 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -752,8 +752,8 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 				    union i40e_rx_desc *rx_desc)
 {
 	struct i40e_rx_ptype_decoded decoded;
-	bool ipv4, ipv6, tunnel = false;
 	u32 rx_error, rx_status;
+	bool ipv4, ipv6;
 	u8 ptype;
 	u64 qword;
 
@@ -808,19 +808,23 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 	if (rx_error & BIT(I40E_RX_DESC_ERROR_PPRS_SHIFT))
 		return;
 
-	/* The hardware supported by this driver does not validate outer
-	 * checksums for tunneled VXLAN or GENEVE frames.  I don't agree
-	 * with it but the specification states that you "MAY validate", it
-	 * doesn't make it a hard requirement so if we have validated the
-	 * inner checksum report CHECKSUM_UNNECESSARY.
+	/* If there is an outer header present that might contain a checksum
+	 * we need to bump the checksum level by 1 to reflect the fact that
+	 * we are indicating we validated the inner checksum.
 	 */
-	if (decoded.inner_prot & (I40E_RX_PTYPE_INNER_PROT_TCP |
-				  I40E_RX_PTYPE_INNER_PROT_UDP |
-				  I40E_RX_PTYPE_INNER_PROT_SCTP))
-		tunnel = true;
-
-	skb->ip_summed = CHECKSUM_UNNECESSARY;
-	skb->csum_level = tunnel ? 1 : 0;
+	if (decoded.tunnel_type >= I40E_RX_PTYPE_TUNNEL_IP_GRENAT)
+		skb->csum_level = 1;
+
+	/* Only report checksum unnecessary for TCP, UDP, or SCTP */
+	switch (decoded.inner_prot) {
+	case I40E_RX_PTYPE_INNER_PROT_TCP:
+	case I40E_RX_PTYPE_INNER_PROT_UDP:
+	case I40E_RX_PTYPE_INNER_PROT_SCTP:
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		/* fall though */
+	default:
+		break;
+	}
 
 	return;
 
-- 
2.5.5
