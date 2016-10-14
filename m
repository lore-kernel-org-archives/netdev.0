From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: bug in ixgbe_atr
Date: Thu, 13 Oct 2016 18:44:22 -0700
Message-ID: <20161014014422.GA14253@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: alexander.h.duyck@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:17570 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751375AbcJNBo3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 21:44:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I was playing around with TPACKET_V2, I think I ran
into a bug in ixgbe_atr(): if I get here with an 
sk_buff that has, e.g., just 14 bytes in the header, then 
the skb_network_header is invalid. I found my kernel sometimes
wandering off into  ipv6_find_hdr() in an attempt to get the 
l4_proto, and then complaining that "IPv6 header not found\n"
(this was an ipv4 packet). 

I think we want to use skb_header_pointer in ixgbe_atr to get 
the network header itself.. I tried the patch below, and it 
works for simple (non-vlan, basic) ethernet header, but probably
needs more refinement to work for more complex encapsulations?

And other drivers may need a similar fix too, I've not checked yet.

--Sowmini

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index a244d9a..be453c6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7627,6 +7627,10 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
 		struct iphdr *ipv4;
 		struct ipv6hdr *ipv6;
 	} hdr;
+	union {
+		struct iphdr ipv4;
+		struct ipv6hdr ipv6;
+	} ip_hdr;
 	struct tcphdr *th;
 	unsigned int hlen;
 	struct sk_buff *skb;
@@ -7667,13 +7671,15 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
 	}
 
 	/* Currently only IPv4/IPv6 with TCP is supported */
-	switch (hdr.ipv4->version) {
-	case IPVERSION:
+	switch (ntohs(first->protocol)) {
+	case ETH_P_IP:
+		skb_header_pointer(skb, ETH_HLEN, sizeof (struct iphdr),
+				   &ip_hdr);
 		/* access ihl as u8 to avoid unaligned access on ia64 */
-		hlen = (hdr.network[0] & 0x0F) << 2;
-		l4_proto = hdr.ipv4->protocol;
+		hlen = ip_hdr.ipv4.ihl << 2;
+		l4_proto = ip_hdr.ipv4.protocol;
 		break;
-	case 6:
+	case ETH_P_IPV6:
 		hlen = hdr.network - skb->data;
 		l4_proto = ipv6_find_hdr(skb, &hlen, IPPROTO_TCP, NULL, NULL);
 		hlen -= hdr.network - skb->data;
