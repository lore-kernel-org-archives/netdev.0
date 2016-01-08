From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/8] ixgbe: Make ATR recognize IPv6 extended headers
Date: Fri,  8 Jan 2016 05:00:30 -0800
Message-ID: <1452258030-63996-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1452258030-63996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55493 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754842AbcAHNAe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 08:00:34 -0500
In-Reply-To: <1452258030-63996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Right now ATR is not handling IPv6 extended headers, so ATR is not
being performed on such packets. Fix that by skipping extended
headers when they are present. This also fixes a problem where
the ATR code was not checking that the inner protocol was actually
TCP before setting up the signature rules. Since the protocol check
is intimately involved with the extended header processing as well,
this all gets fixed together.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 47 +++++++++++++++++++++------
 1 file changed, 37 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 328d7a8..c4003a8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7573,7 +7573,9 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
 	/* snag network header to get L4 type and address */
 	skb = first->skb;
 	hdr.network = skb_network_header(skb);
-	if (skb->encapsulation) {
+	if (!skb->encapsulation) {
+		th = tcp_hdr(skb);
+	} else {
 #ifdef CONFIG_IXGBE_VXLAN
 		struct ixgbe_adapter *adapter = q_vector->adapter;
 
@@ -7592,14 +7594,34 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
 #else
 		return;
 #endif /* CONFIG_IXGBE_VXLAN */
-	} else {
-		/* Currently only IPv4/IPv6 with TCP is supported */
-		if ((first->protocol != htons(ETH_P_IPV6) ||
-		     hdr.ipv6->nexthdr != IPPROTO_TCP) &&
-		    (first->protocol != htons(ETH_P_IP) ||
-		     hdr.ipv4->protocol != IPPROTO_TCP))
+	}
+
+	/* Currently only IPv4/IPv6 with TCP is supported */
+	switch (hdr.ipv4->version) {
+	case IPVERSION:
+		if (hdr.ipv4->protocol != IPPROTO_TCP)
 			return;
-		th = tcp_hdr(skb);
+		break;
+	case 6:
+		if (likely((unsigned char *)th - hdr.network ==
+			   sizeof(struct ipv6hdr))) {
+			if (hdr.ipv6->nexthdr != IPPROTO_TCP)
+				return;
+		} else {
+			__be16 frag_off;
+			u8 l4_hdr;
+
+			ipv6_skip_exthdr(skb, hdr.network - skb->data +
+					      sizeof(struct ipv6hdr),
+					 &l4_hdr, &frag_off);
+			if (unlikely(frag_off))
+				return;
+			if (l4_hdr != IPPROTO_TCP)
+				return;
+		}
+		break;
+	default:
+		return;
 	}
 
 	/* skip this packet since it is invalid or the socket is closing */
@@ -7634,10 +7656,12 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
 		common.port.src ^= th->dest ^ first->protocol;
 	common.port.dst ^= th->source;
 
-	if (first->protocol == htons(ETH_P_IP)) {
+	switch (hdr.ipv4->version) {
+	case IPVERSION:
 		input.formatted.flow_type = IXGBE_ATR_FLOW_TYPE_TCPV4;
 		common.ip ^= hdr.ipv4->saddr ^ hdr.ipv4->daddr;
-	} else {
+		break;
+	case 6:
 		input.formatted.flow_type = IXGBE_ATR_FLOW_TYPE_TCPV6;
 		common.ip ^= hdr.ipv6->saddr.s6_addr32[0] ^
 			     hdr.ipv6->saddr.s6_addr32[1] ^
@@ -7647,6 +7671,9 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
 			     hdr.ipv6->daddr.s6_addr32[1] ^
 			     hdr.ipv6->daddr.s6_addr32[2] ^
 			     hdr.ipv6->daddr.s6_addr32[3];
+		break;
+	default:
+		break;
 	}
 
 #ifdef CONFIG_IXGBE_VXLAN
-- 
2.5.0
