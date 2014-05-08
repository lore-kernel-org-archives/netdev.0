From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 1/2] net: Expose header length compution function
Date: Thu,  8 May 2014 15:50:33 +0300
Message-ID: <1399553434-25617-2-git-send-email-amirv@mellanox.com>
References: <1399553434-25617-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:54163 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753903AbaEHMvM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2014 08:51:12 -0400
In-Reply-To: <1399553434-25617-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

This commit exposes an header length compution generic function,
introduced in some of Intel's Etherent drivers (igb and ixgbe),
to net public namespace under the name __net_get_headlen,
where it can be used by other vendors and removes code duplication.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c     | 109 +-----------------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 116 +-------------------------
 include/linux/net.h                           |   2 +
 net/core/utils.c                              | 104 +++++++++++++++++++++++
 4 files changed, 108 insertions(+), 223 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index bfcda8a..6f3d2a8 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6736,113 +6736,6 @@ static bool igb_is_non_eop(struct igb_ring *rx_ring,
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
@@ -6886,7 +6779,7 @@ static void igb_pull_tail(struct igb_ring *rx_ring,
 	/* we need the header to contain the greater of either ETH_HLEN or
 	 * 60 bytes if the skb->len is less than 60 for skb_pad.
 	 */
-	pull_len = igb_get_headlen(va, IGB_RX_HDR_LEN);
+	pull_len = __net_get_headlen(va, IGB_RX_HDR_LEN);
 
 	/* align pull length to size of long to optimize memcpy performance */
 	skb_copy_to_linear_data(skb, va, ALIGN(pull_len, sizeof(long)));
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 8089ea9..77d1d2e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1527,120 +1527,6 @@ void ixgbe_alloc_rx_buffers(struct ixgbe_ring *rx_ring, u16 cleaned_count)
 		ixgbe_release_rx_desc(rx_ring, i);
 }
 
-/**
- * ixgbe_get_headlen - determine size of header for RSC/LRO/GRO/FCOE
- * @data: pointer to the start of the headers
- * @max_len: total length of section to find headers in
- *
- * This function is meant to determine the length of headers that will
- * be recognized by hardware for LRO, GRO, and RSC offloads.  The main
- * motivation of doing this is to only perform one pull for IPv4 TCP
- * packets so that we can do basic things like calculating the gso_size
- * based on the average data per packet.
- **/
-static unsigned int ixgbe_get_headlen(unsigned char *data,
-				      unsigned int max_len)
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
-#ifdef IXGBE_FCOE
-	} else if (protocol == htons(ETH_P_FCOE)) {
-		if ((hdr.network - data) > (max_len - FCOE_HEADER_LEN))
-			return max_len;
-		hlen = FCOE_HEADER_LEN;
-#endif
-	} else {
-		return hdr.network - data;
-	}
-
-	/* relocate pointer to start of L4 header */
-	hdr.network += hlen;
-
-	/* finally sort out TCP/UDP */
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
-	/*
-	 * If everything has gone correctly hdr.network should be the
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
 static void ixgbe_set_rsc_gso_size(struct ixgbe_ring *ring,
 				   struct sk_buff *skb)
 {
@@ -1799,7 +1685,7 @@ static void ixgbe_pull_tail(struct ixgbe_ring *rx_ring,
 	 * we need the header to contain the greater of either ETH_HLEN or
 	 * 60 bytes if the skb->len is less than 60 for skb_pad.
 	 */
-	pull_len = ixgbe_get_headlen(va, IXGBE_RX_HDR_SIZE);
+	pull_len = __net_get_headlen(va, IXGBE_RX_HDR_SIZE);
 
 	/* align pull length to size of long to optimize memcpy performance */
 	skb_copy_to_linear_data(skb, va, ALIGN(pull_len, sizeof(long)));
diff --git a/include/linux/net.h b/include/linux/net.h
index 94734a6..1ca3776 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -248,6 +248,8 @@ do {								\
 bool __net_get_random_once(void *buf, int nbytes, bool *done,
 			   struct static_key *done_key);
 
+int __net_get_headlen(unsigned char *data, unsigned int max_len);
+
 #ifdef HAVE_JUMP_LABEL
 #define ___NET_RANDOM_STATIC_KEY_INIT ((struct static_key) \
 		{ .enabled = ATOMIC_INIT(0), .entries = (void *)1 })
diff --git a/net/core/utils.c b/net/core/utils.c
index 2f737bf..5189d6f 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -26,13 +26,17 @@
 #include <linux/percpu.h>
 #include <linux/init.h>
 #include <linux/ratelimit.h>
+#include <linux/if_vlan.h>
 
 #include <net/sock.h>
 #include <net/net_ratelimit.h>
+#include <net/ip.h>
 
 #include <asm/byteorder.h>
 #include <asm/uaccess.h>
 
+#include <scsi/fc/fc_fcoe.h>
+
 int net_msg_warn __read_mostly = 1;
 EXPORT_SYMBOL(net_msg_warn);
 
@@ -387,3 +391,103 @@ bool __net_get_random_once(void *buf, int nbytes, bool *done,
 	return true;
 }
 EXPORT_SYMBOL(__net_get_random_once);
+
+int __net_get_headlen(unsigned char *data, unsigned int max_len)
+{
+	union {
+		unsigned char *network;
+		/* l2 headers */
+		struct ethhdr *eth;
+		struct vlan_hdr *vlan;
+		/* l3 headers */
+		struct iphdr *ipv4;
+		struct ipv6hdr *ipv6;
+	} hdr;
+	__be16 protocol;
+	u8 nexthdr = 0;	/* default to not TCP */
+	u8 hlen;
+
+	/* this should never happen, but better safe than sorry */
+	if (max_len < ETH_HLEN)
+		return max_len;
+
+	/* initialize network frame pointer */
+	hdr.network = data;
+
+	/* set first protocol and move network header forward */
+	protocol = hdr.eth->h_proto;
+	hdr.network += ETH_HLEN;
+
+	/* handle any vlan tag if present */
+	if (protocol == htons(ETH_P_8021Q)) {
+		if ((hdr.network - data) > (max_len - VLAN_HLEN))
+			return max_len;
+
+		protocol = hdr.vlan->h_vlan_encapsulated_proto;
+		hdr.network += VLAN_HLEN;
+	}
+
+	/* handle L3 protocols */
+	if (protocol == htons(ETH_P_IP)) {
+		if ((hdr.network - data) > (max_len - sizeof(struct iphdr)))
+			return max_len;
+
+		/* access ihl as a u8 to avoid unaligned access on ia64 */
+		hlen = (hdr.network[0] & 0x0F) << 2;
+
+		/* verify hlen meets minimum size requirements */
+		if (hlen < sizeof(struct iphdr))
+			return hdr.network - data;
+
+		/* record next protocol if header is present */
+		if (!(hdr.ipv4->frag_off & htons(IP_OFFSET)))
+			nexthdr = hdr.ipv4->protocol;
+	} else if (protocol == htons(ETH_P_IPV6)) {
+		if ((hdr.network - data) > (max_len - sizeof(struct ipv6hdr)))
+			return max_len;
+
+		/* record next protocol */
+		nexthdr = hdr.ipv6->nexthdr;
+		hlen = sizeof(struct ipv6hdr);
+	} else if (protocol == htons(ETH_P_FCOE)) {
+		if ((hdr.network - data) > (max_len - FCOE_HEADER_LEN))
+			return max_len;
+		hlen = FCOE_HEADER_LEN;
+	} else {
+		return hdr.network - data;
+	}
+
+	/* relocate pointer to start of L4 header */
+	hdr.network += hlen;
+
+	/* finally sort out TCP/UDP */
+	if (nexthdr == IPPROTO_TCP) {
+		if ((hdr.network - data) > (max_len - sizeof(struct tcphdr)))
+			return max_len;
+
+		/* access doff as a u8 to avoid unaligned access on ia64 */
+		hlen = (hdr.network[12] & 0xF0) >> 2;
+
+		/* verify hlen meets minimum size requirements */
+		if (hlen < sizeof(struct tcphdr))
+			return hdr.network - data;
+
+		hdr.network += hlen;
+	} else if (nexthdr == IPPROTO_UDP) {
+		if ((hdr.network - data) > (max_len - sizeof(struct udphdr)))
+			return max_len;
+
+		hdr.network += sizeof(struct udphdr);
+	}
+
+	/* If everything has gone correctly hdr.network should be the
+	 * data section of the packet and will be the end of the header.
+	 * If not then it probably represents the end of the last recognized
+	 * header.
+	 */
+	if ((hdr.network - data) < max_len)
+		return hdr.network - data;
+	else
+		return max_len;
+}
+EXPORT_SYMBOL(__net_get_headlen);
-- 
1.8.3.4
