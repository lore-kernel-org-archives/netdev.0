From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: [RFC PATCH v2 1/2] net: Add support for hardware-offloaded encapsulation
Date: Thu, 25 Oct 2012 12:38:59 -0700
Message-ID: <1351193940-11427-2-git-send-email-joseph.gasparakis@intel.com>
References: <1351193940-11427-1-git-send-email-joseph.gasparakis@intel.com>
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net, shemminger@vyatta.com, chrisw@sous-sol.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:15190 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965575Ab2JYUBz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2012 16:01:55 -0400
In-Reply-To: <1351193940-11427-1-git-send-email-joseph.gasparakis@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds suport in the kernel for offloading in the NIC Tx and Rx checksuming for encapsulated packets (such as VXLAN and IP GRE)

Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---
 Documentation/networking/netdev-features.txt |  10 +++
 include/linux/if_ether.h                     |   5 ++
 include/linux/ip.h                           |   5 ++
 include/linux/netdev_features.h              |   3 +
 include/linux/skbuff.h                       | 114 +++++++++++++++++++++++++++
 include/linux/udp.h                          |   5 ++
 net/core/ethtool.c                           |   2 +
 7 files changed, 144 insertions(+)

diff --git a/Documentation/networking/netdev-features.txt b/Documentation/networking/netdev-features.txt
index 4164f5c..82695c0 100644
--- a/Documentation/networking/netdev-features.txt
+++ b/Documentation/networking/netdev-features.txt
@@ -165,3 +165,13 @@ This requests that the NIC receive all possible frames, including errored
 frames (such as bad FCS, etc).  This can be helpful when sniffing a link with
 bad packets on it.  Some NICs may receive more packets if also put into normal
 PROMISC mdoe.
+
+*  tx-enc-checksum-offload
+
+This feature implies that the NIC will be able to calculate the Tx checksums
+for both inner and outer packets in the case of vxlan and ipgre encapsulation.
+
+*  rx-enc-checksum-offload
+
+This feature implies that the NIC will be able to verify the Rx checksums
+for both inner and outer packets in the case of vxlan and ipgre encapsulation.
diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 167ce5b..b6ebb4b5 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -139,6 +139,11 @@ static inline struct ethhdr *eth_hdr(const struct sk_buff *skb)
 	return (struct ethhdr *)skb_mac_header(skb);
 }
 
+static inline struct ethhdr *eth_inner_hdr(const struct sk_buff *skb)
+{
+	return (struct ethhdr *)skb_inner_mac_header(skb);
+}
+
 int eth_header_parse(const struct sk_buff *skb, unsigned char *haddr);
 
 int mac_pton(const char *s, u8 *mac);
diff --git a/include/linux/ip.h b/include/linux/ip.h
index bd0a2a8..e94f000 100644
--- a/include/linux/ip.h
+++ b/include/linux/ip.h
@@ -112,6 +112,11 @@ static inline struct iphdr *ip_hdr(const struct sk_buff *skb)
 	return (struct iphdr *)skb_network_header(skb);
 }
 
+static inline struct iphdr *ip_inner_hdr(const struct sk_buff *skb)
+{
+	return (struct iphdr *)skb_inner_network_header(skb);
+}
+
 static inline struct iphdr *ipip_hdr(const struct sk_buff *skb)
 {
 	return (struct iphdr *)skb_transport_header(skb);
diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 5ac3212..6dd59a5 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -19,6 +19,7 @@ enum {
 	NETIF_F_IP_CSUM_BIT,		/* Can checksum TCP/UDP over IPv4. */
 	__UNUSED_NETIF_F_1,
 	NETIF_F_HW_CSUM_BIT,		/* Can checksum all the packets. */
+	NETIF_F_HW_CSUM_ENC_BIT,	/* Can checksum all inner headers */
 	NETIF_F_IPV6_CSUM_BIT,		/* Can checksum TCP/UDP over IPV6 */
 	NETIF_F_HIGHDMA_BIT,		/* Can DMA to high memory. */
 	NETIF_F_FRAGLIST_BIT,		/* Scatter/gather IO. */
@@ -52,6 +53,8 @@ enum {
 	NETIF_F_NTUPLE_BIT,		/* N-tuple filters supported */
 	NETIF_F_RXHASH_BIT,		/* Receive hashing offload */
 	NETIF_F_RXCSUM_BIT,		/* Receive checksumming offload */
+	NETIF_F_RXCSUM_ENC_BIT,		/* Receive checksuming offload */
+					/* for encapsulation */
 	NETIF_F_NOCACHE_COPY_BIT,	/* Use no-cache copyfromuser */
 	NETIF_F_LOOPBACK_BIT,		/* Enable loopback */
 	NETIF_F_RXFCS_BIT,		/* Append FCS to skb pkt data */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b33a3a1..aaa17a8 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -377,6 +377,9 @@ typedef unsigned char *sk_buff_data_t;
  *	@transport_header: Transport layer header
  *	@network_header: Network layer header
  *	@mac_header: Link layer header
+ *	@inner_transport_header: Inner transport layer header (encapsulation)
+ *	@inner_network_header: Network layer header (encapsulation)
+ *	@inner_mac_header: Link layer header (encapsulation)
  *	@tail: Tail pointer
  *	@end: End pointer
  *	@head: Head of buffer
@@ -487,6 +490,9 @@ struct sk_buff {
 	sk_buff_data_t		transport_header;
 	sk_buff_data_t		network_header;
 	sk_buff_data_t		mac_header;
+	sk_buff_data_t		inner_transport_header;
+	sk_buff_data_t		inner_network_header;
+	sk_buff_data_t		inner_mac_header;
 	/* These elements must be at the end, see alloc_skb() for details.  */
 	sk_buff_data_t		tail;
 	sk_buff_data_t		end;
@@ -1441,6 +1447,63 @@ static inline void skb_reset_mac_len(struct sk_buff *skb)
 }
 
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
+static inline unsigned char *skb_inner_transport_header(const struct sk_buff
+							*skb)
+{
+	return skb->head + skb->inner_transport_header;
+}
+
+static inline void skb_reset_inner_transport_header(struct sk_buff *skb)
+{
+	skb->inner_transport_header = skb->data - skb->head;
+}
+
+static inline void skb_set_inner_transport_header(struct sk_buff *skb,
+						   const int offset)
+{
+	skb_reset_inner_transport_header(skb);
+	skb->inner_transport_header += offset;
+}
+
+static inline unsigned char *skb_inner_network_header(const struct sk_buff *skb)
+{
+	return skb->head + skb->inner_network_header;
+}
+
+static inline void skb_reset_inner_network_header(struct sk_buff *skb)
+{
+	skb->inner_network_header = skb->data - skb->head;
+}
+
+static inline void skb_set_inner_network_header(struct sk_buff *skb,
+						const int offset)
+{
+	skb_reset_inner_network_header(skb);
+	skb->inner_network_header += offset;
+}
+
+static inline unsigned char *skb_inner_mac_header(const struct sk_buff *skb)
+{
+	return skb->head + skb->inner_mac_header;
+}
+
+static inline int skb_inner_mac_header_was_set(const struct sk_buff *skb)
+{
+	return skb->inner_mac_header != ~0U;
+}
+
+static inline void skb_reset_inner_mac_header(struct sk_buff *skb)
+{
+	skb->inner_mac_header = skb->data - skb->head;
+}
+
+static inline void skb_set_inner_mac_header(struct sk_buff *skb,
+					    const int offset)
+{
+	skb_reset_inner_mac_header(skb);
+	skb->inner_mac_header += offset;
+}
+
 static inline unsigned char *skb_transport_header(const struct sk_buff *skb)
 {
 	return skb->head + skb->transport_header;
@@ -1496,7 +1559,58 @@ static inline void skb_set_mac_header(struct sk_buff *skb, const int offset)
 }
 
 #else /* NET_SKBUFF_DATA_USES_OFFSET */
+static inline unsigned char *skb_inner_transport_header(const struct sk_buff
+							*skb)
+{
+	return skb->inner_transport_header;
+}
+
+static inline void skb_reset_inner_transport_header(struct sk_buff *skb)
+{
+	skb->inner_transport_header = skb->data;
+}
+
+static inline void skb_set_inner_transport_header(struct sk_buff *skb,
+						   const int offset)
+{
+	skb->inner_transport_header = skb->data + offset;
+}
+
+static inline unsigned char *skb_inner_network_header(const struct sk_buff *skb)
+{
+	return skb->inner_network_header;
+}
+
+static inline void skb_reset_inner_network_header(struct sk_buff *skb)
+{
+	skb->inner_network_header = skb->data;
+}
+
+static inline void skb_set_inner_network_header(struct sk_buff *skb,
+						const int offset)
+{
+	skb->inner_network_header = skb->data + offset;
+}
+
+static inline unsigned char *skb_inner_mac_header(const struct sk_buff *skb)
+{
+	return skb->inner_mac_header;
+}
+
+static inline int skb_inner_mac_header_was_set(const struct sk_buff *skb)
+{
+	return skb->inner_mac_header != NULL;
+}
 
+static inline void skb_reset_mac_header(struct sk_buff *skb)
+{
+	skb->inner_mac_header = skb->data;
+}
+
+static inline void skb_set_mac_header(struct sk_buff *skb, const int offset)
+{
+	skb->inner_mac_header = skb->data + offset;
+}
 static inline unsigned char *skb_transport_header(const struct sk_buff *skb)
 {
 	return skb->transport_header;
diff --git a/include/linux/udp.h b/include/linux/udp.h
index 03f72a2..e3294fd 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -45,6 +45,11 @@ static inline struct udphdr *udp_hdr(const struct sk_buff *skb)
 	return (struct udphdr *)skb_transport_header(skb);
 }
 
+static inline struct udphdr *udp_inner_hdr(const struct sk_buff *skb)
+{
+	return (struct udphdr *)skb_inner_transport_header(skb);
+}
+
 #define UDP_HTABLE_SIZE_MIN		(CONFIG_BASE_SMALL ? 128 : 256)
 
 static inline int udp_hashfn(struct net *net, unsigned num, unsigned mask)
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 4d64cc2..11f928d 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -58,6 +58,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_IP_CSUM_BIT] =          "tx-checksum-ipv4",
 	[NETIF_F_HW_CSUM_BIT] =          "tx-checksum-ip-generic",
 	[NETIF_F_IPV6_CSUM_BIT] =        "tx-checksum-ipv6",
+	[NETIF_F_HW_CSUM_ENC_BIT] =	 "tx-checksum-enc-offload",
 	[NETIF_F_HIGHDMA_BIT] =          "highdma",
 	[NETIF_F_FRAGLIST_BIT] =         "tx-scatter-gather-fraglist",
 	[NETIF_F_HW_VLAN_TX_BIT] =       "tx-vlan-hw-insert",
@@ -84,6 +85,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_NTUPLE_BIT] =           "rx-ntuple-filter",
 	[NETIF_F_RXHASH_BIT] =           "rx-hashing",
 	[NETIF_F_RXCSUM_BIT] =           "rx-checksum",
+	[NETIF_F_RXCSUM_ENC_BIT] =	 "rx-enc-checksum-offload",
 	[NETIF_F_NOCACHE_COPY_BIT] =     "tx-nocache-copy",
 	[NETIF_F_LOOPBACK_BIT] =         "loopback",
 	[NETIF_F_RXFCS_BIT] =            "rx-fcs",
-- 
1.7.11.7
