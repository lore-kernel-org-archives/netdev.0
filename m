From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH 2/3] igb: use new eth_get_headlen interface
Date: Thu, 04 Sep 2014 19:13:38 -0400
Message-ID: <20140904231338.12376.62871.stgit@ahduyck-bv4.jf.intel.com>
References: <20140904230958.12376.2845.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:18804 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754222AbaIDXVf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2014 19:21:35 -0400
In-Reply-To: <20140904230958.12376.2845.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update igb to drop the igb_get_headlen function in favor of eth_get_headlen.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |  109 -----------------------------
 1 file changed, 1 insertion(+), 108 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 89de7fe..4c023f0 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6769,113 +6769,6 @@ static bool igb_is_non_eop(struct igb_ring *rx_ring,
 }
 
 /**
- *  igb_get_headlen - determine size of header for LRO/GRO
- *  @data: pointer to the start of the headers
- *  @max_len: total length of section to find headers in
- *
- *  This function is meant to determine the length of headers that will
- *  be recognized by hardware for LRO, and GRO offloads.  The main
- *  motivation of doing this is to only perform one pull for IPv4 TCP
- *  packets so that we can do basic things like calculating the gso_size
- *  based on the average data per packet.
- **/
-static unsigned int igb_get_headlen(unsigned char *data,
-				    unsigned int max_len)
-{
-	union {
-		unsigned char *network;
-		/* l2 headers */
-		struct ethhdr *eth;
-		struct vlan_hdr *vlan;
-		/* l3 headers */
-		struct iphdr *ipv4;
-		struct ipv6hdr *ipv6;
-	} hdr;
-	__be16 protocol;
-	u8 nexthdr = 0;	/* default to not TCP */
-	u8 hlen;
-
-	/* this should never happen, but better safe than sorry */
-	if (max_len < ETH_HLEN)
-		return max_len;
-
-	/* initialize network frame pointer */
-	hdr.network = data;
-
-	/* set first protocol and move network header forward */
-	protocol = hdr.eth->h_proto;
-	hdr.network += ETH_HLEN;
-
-	/* handle any vlan tag if present */
-	if (protocol == htons(ETH_P_8021Q)) {
-		if ((hdr.network - data) > (max_len - VLAN_HLEN))
-			return max_len;
-
-		protocol = hdr.vlan->h_vlan_encapsulated_proto;
-		hdr.network += VLAN_HLEN;
-	}
-
-	/* handle L3 protocols */
-	if (protocol == htons(ETH_P_IP)) {
-		if ((hdr.network - data) > (max_len - sizeof(struct iphdr)))
-			return max_len;
-
-		/* access ihl as a u8 to avoid unaligned access on ia64 */
-		hlen = (hdr.network[0] & 0x0F) << 2;
-
-		/* verify hlen meets minimum size requirements */
-		if (hlen < sizeof(struct iphdr))
-			return hdr.network - data;
-
-		/* record next protocol if header is present */
-		if (!(hdr.ipv4->frag_off & htons(IP_OFFSET)))
-			nexthdr = hdr.ipv4->protocol;
-	} else if (protocol == htons(ETH_P_IPV6)) {
-		if ((hdr.network - data) > (max_len - sizeof(struct ipv6hdr)))
-			return max_len;
-
-		/* record next protocol */
-		nexthdr = hdr.ipv6->nexthdr;
-		hlen = sizeof(struct ipv6hdr);
-	} else {
-		return hdr.network - data;
-	}
-
-	/* relocate pointer to start of L4 header */
-	hdr.network += hlen;
-
-	/* finally sort out TCP */
-	if (nexthdr == IPPROTO_TCP) {
-		if ((hdr.network - data) > (max_len - sizeof(struct tcphdr)))
-			return max_len;
-
-		/* access doff as a u8 to avoid unaligned access on ia64 */
-		hlen = (hdr.network[12] & 0xF0) >> 2;
-
-		/* verify hlen meets minimum size requirements */
-		if (hlen < sizeof(struct tcphdr))
-			return hdr.network - data;
-
-		hdr.network += hlen;
-	} else if (nexthdr == IPPROTO_UDP) {
-		if ((hdr.network - data) > (max_len - sizeof(struct udphdr)))
-			return max_len;
-
-		hdr.network += sizeof(struct udphdr);
-	}
-
-	/* If everything has gone correctly hdr.network should be the
-	 * data section of the packet and will be the end of the header.
-	 * If not then it probably represents the end of the last recognized
-	 * header.
-	 */
-	if ((hdr.network - data) < max_len)
-		return hdr.network - data;
-	else
-		return max_len;
-}
-
-/**
  *  igb_pull_tail - igb specific version of skb_pull_tail
  *  @rx_ring: rx descriptor ring packet is being transacted on
  *  @rx_desc: pointer to the EOP Rx descriptor
@@ -6919,7 +6812,7 @@ static void igb_pull_tail(struct igb_ring *rx_ring,
 	/* we need the header to contain the greater of either ETH_HLEN or
 	 * 60 bytes if the skb->len is less than 60 for skb_pad.
 	 */
-	pull_len = igb_get_headlen(va, IGB_RX_HDR_LEN);
+	pull_len = eth_get_headlen(va, IGB_RX_HDR_LEN);
 
 	/* align pull length to size of long to optimize memcpy performance */
 	skb_copy_to_linear_data(skb, va, ALIGN(pull_len, sizeof(long)));
