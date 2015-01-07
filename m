From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net v2 2/3] i40e: Fix Rx checksum error counter
Date: Tue,  6 Jan 2015 17:31:56 -0800
Message-ID: <1420594317-6191-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1420594317-6191-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai <anjali.singhai@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:43210 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754748AbbAGBcG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2015 20:32:06 -0500
In-Reply-To: <1420594317-6191-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai <anjali.singhai@intel.com>

The Rx port checksum error counter was incrementing incorrectly with
UDP encapsulated tunneled traffic.  This patch fixes the problem so that
the port_rx_csum counter will show accurate statistics.

Signed-off-by: Anjali Singhai <anjali.singhai@intel.com>
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index f145aaf..38c7638 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1325,9 +1325,7 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 	 * so the total length of IPv4 header is IHL*4 bytes
 	 * The UDP_0 bit *may* bet set if the *inner* header is UDP
 	 */
-	if (ipv4_tunnel &&
-	    (decoded.inner_prot != I40E_RX_PTYPE_INNER_PROT_UDP) &&
-	    !(rx_status & (1 << I40E_RX_DESC_STATUS_UDP_0_SHIFT))) {
+	if (ipv4_tunnel) {
 		skb->transport_header = skb->mac_header +
 					sizeof(struct ethhdr) +
 					(ip_hdr(skb)->ihl * 4);
@@ -1337,15 +1335,19 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 					  skb->protocol == htons(ETH_P_8021AD))
 					  ? VLAN_HLEN : 0;
 
-		rx_udp_csum = udp_csum(skb);
-		iph = ip_hdr(skb);
-		csum = csum_tcpudp_magic(
-				iph->saddr, iph->daddr,
-				(skb->len - skb_transport_offset(skb)),
-				IPPROTO_UDP, rx_udp_csum);
+		if ((ip_hdr(skb)->protocol == IPPROTO_UDP) &&
+		    (udp_hdr(skb)->check != 0)) {
+			rx_udp_csum = udp_csum(skb);
+			iph = ip_hdr(skb);
+			csum = csum_tcpudp_magic(
+					iph->saddr, iph->daddr,
+					(skb->len - skb_transport_offset(skb)),
+					IPPROTO_UDP, rx_udp_csum);
 
-		if (udp_hdr(skb)->check != csum)
-			goto checksum_fail;
+			if (udp_hdr(skb)->check != csum)
+				goto checksum_fail;
+
+		} /* else its GRE and so no outer UDP header */
 	}
 
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
-- 
1.9.3
