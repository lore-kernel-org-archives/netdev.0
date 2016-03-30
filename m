From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 03/11] ixgbe: Fix ATR so that it correctly handles IPv6 extension headers
Date: Wed, 30 Mar 2016 16:00:47 -0700
Message-ID: <1459378855-139837-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459378855-139837-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49527 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755190AbcC3XBS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Mar 2016 19:01:18 -0400
In-Reply-To: <1459378855-139837-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

The ATR code was assuming that it would be able to use tcp_hdr for
every TCP frame that came through.  However this isn't the case as it
is possible for a frame to arrive that is TCP but sent through something
like a raw socket.  As a result the driver was setting up bad filters in
which tcp_hdr was really pointing to the network header so the data was
all invalid.

In order to correct this I have added a bit of parsing logic that will
determine the TCP header location based off of the network header and
either the offset in the case of the IPv4 header, or a walk through the
IPv6 extension headers until it encounters the header that indicates
IPPROTO_TCP.  In addition I have added checks to verify that the lowest
protocol provided is recognized as IPv4 or IPv6 to help mitigate raw
sockets using ETH_P_ALL from having ATR applied to them.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 45 +++++++++++++--------------
 1 file changed, 21 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index f67c9a6..ee81618 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7558,8 +7558,10 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
 		struct ipv6hdr *ipv6;
 	} hdr;
 	struct tcphdr *th;
+	unsigned int hlen;
 	struct sk_buff *skb;
 	__be16 vlan_id;
+	int l4_proto;
 
 	/* if ring doesn't have a interrupt vector, cannot perform ATR */
 	if (!q_vector)
@@ -7571,10 +7573,14 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
 
 	ring->atr_count++;
 
+	/* currently only IPv4/IPv6 with TCP is supported */
+	if ((first->protocol != htons(ETH_P_IP)) &&
+	    (first->protocol != htons(ETH_P_IPV6)))
+		return;
+
 	/* snag network header to get L4 type and address */
 	skb = first->skb;
 	hdr.network = skb_network_header(skb);
-	th = tcp_hdr(skb);
 #ifdef CONFIG_IXGBE_VXLAN
 	if (skb->encapsulation &&
 	    first->protocol == htons(ETH_P_IP) &&
@@ -7583,43 +7589,34 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
 
 		/* verify the port is recognized as VXLAN */
 		if (adapter->vxlan_port &&
-		    udp_hdr(skb)->dest == adapter->vxlan_port) {
+		    udp_hdr(skb)->dest == adapter->vxlan_port)
 			hdr.network = skb_inner_network_header(skb);
-			th = inner_tcp_hdr(skb);
-		}
 	}
 #endif /* CONFIG_IXGBE_VXLAN */
 
 	/* Currently only IPv4/IPv6 with TCP is supported */
 	switch (hdr.ipv4->version) {
 	case IPVERSION:
-		if (hdr.ipv4->protocol != IPPROTO_TCP)
-			return;
+		/* access ihl as u8 to avoid unaligned access on ia64 */
+		hlen = (hdr.network[0] & 0x0F) << 2;
+		l4_proto = hdr.ipv4->protocol;
 		break;
 	case 6:
-		if (likely((unsigned char *)th - hdr.network ==
-			   sizeof(struct ipv6hdr))) {
-			if (hdr.ipv6->nexthdr != IPPROTO_TCP)
-				return;
-		} else {
-			__be16 frag_off;
-			u8 l4_hdr;
-
-			ipv6_skip_exthdr(skb, hdr.network - skb->data +
-					      sizeof(struct ipv6hdr),
-					 &l4_hdr, &frag_off);
-			if (unlikely(frag_off))
-				return;
-			if (l4_hdr != IPPROTO_TCP)
-				return;
-		}
+		hlen = hdr.network - skb->data;
+		l4_proto = ipv6_find_hdr(skb, &hlen, IPPROTO_TCP, NULL, NULL);
+		hlen -= hdr.network - skb->data;
 		break;
 	default:
 		return;
 	}
 
-	/* skip this packet since it is invalid or the socket is closing */
-	if (!th || th->fin)
+	if (l4_proto != IPPROTO_TCP)
+		return;
+
+	th = (struct tcphdr *)(hdr.network + hlen);
+
+	/* skip this packet since the socket is closing */
+	if (th->fin)
 		return;
 
 	/* sample on all syn packets or once every atr sample count */
-- 
2.5.5
