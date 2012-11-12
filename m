From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: [PATCH v2 1/3] net: Add support for hardware-offloaded encapsulation
Date: Mon, 12 Nov 2012 00:36:56 -0800
Message-ID: <1352709418-28996-2-git-send-email-joseph.gasparakis@intel.com>
References: <1352709418-28996-1-git-send-email-joseph.gasparakis@intel.com>
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dmitry@broadcom.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net, shemminger@vyatta.com, chrisw@sous-sol.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352709418-28996-1-git-send-email-joseph.gasparakis@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support in the kernel for offloading in the NIC Tx and Rx checksumming for encapsulated packets (such as VXLAN and IP GRE)

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
 net/core/skbuff.c                            |  17 ++++
 8 files changed, 161 insertions(+)

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
index 12b4d55..195376b 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -28,6 +28,11 @@ static inline struct ethhdr *eth_hdr(const struct sk_buff *skb)
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
index 58b82a2..e084de7 100644
--- a/include/linux/ip.h
+++ b/include/linux/ip.h
@@ -25,6 +25,11 @@ static inline struct iphdr *ip_hdr(const struct sk_buff *skb)
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
index f2af494..4b9b50b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -379,6 +379,9 @@ typedef unsigned char *sk_buff_data_t;
  *	@transport_header: Transport layer header
  *	@network_header: Network layer header
  *	@mac_header: Link layer header
+ *	@inner_transport_header: Inner transport layer header (encapsulation)
+ *	@inner_network_header: Network layer header (encapsulation)
+ *	@inner_mac_header: Link layer header (encapsulation)
  *	@tail: Tail pointer
  *	@end: End pointer
  *	@head: Head of buffer
@@ -489,6 +492,9 @@ struct sk_buff {
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
index 0b67d77..bd49c56 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -27,6 +27,11 @@ static inline struct udphdr *udp_hdr(const struct sk_buff *skb)
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
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d9addea..4be312b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -259,6 +259,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	skb->end = skb->tail + size;
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 	skb->mac_header = ~0U;
+	skb->inner_mac_header = ~0U;
 #endif
 
 	/* make sure we initialize shinfo sequentially */
@@ -327,6 +328,7 @@ struct sk_buff *build_skb(void *data, unsigned int frag_size)
 	skb->end = skb->tail + size;
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 	skb->mac_header = ~0U;
+	skb->inner_mac_header = ~0U;
 #endif
 
 	/* make sure we initialize shinfo sequentially */
@@ -682,6 +684,9 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->transport_header	= old->transport_header;
 	new->network_header	= old->network_header;
 	new->mac_header		= old->mac_header;
+	new->inner_transport_header = old->inner_transport_header;
+	new->inner_network_header = old->inner_transport_header;
+	new->inner_mac_header = old->inner_mac_header;
 	skb_dst_copy(new, old);
 	new->rxhash		= old->rxhash;
 	new->ooo_okay		= old->ooo_okay;
@@ -892,6 +897,10 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->network_header   += offset;
 	if (skb_mac_header_was_set(new))
 		new->mac_header	      += offset;
+	new->inner_transport_header += offset;
+	new->inner_network_header   += offset;
+	if (skb_inner_mac_header_was_set(new))
+		new->inner_mac_header += offset;
 #endif
 	skb_shinfo(new)->gso_size = skb_shinfo(old)->gso_size;
 	skb_shinfo(new)->gso_segs = skb_shinfo(old)->gso_segs;
@@ -1089,6 +1098,10 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	skb->network_header   += off;
 	if (skb_mac_header_was_set(skb))
 		skb->mac_header += off;
+	skb->inner_transport_header += off;
+	skb->inner_network_header += off;
+	if (skb_inner_mac_header_was_set(skb))
+		skb->inner_mac_header += off;
 	/* Only adjust this if it actually is csum_start rather than csum */
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		skb->csum_start += nhead;
@@ -1188,6 +1201,10 @@ struct sk_buff *skb_copy_expand(const struct sk_buff *skb,
 	n->network_header   += off;
 	if (skb_mac_header_was_set(skb))
 		n->mac_header += off;
+	n->inner_transport_header += off;
+	n->inner_network_header	   += off;
+	if (skb_inner_mac_header_was_set(skb))
+		n->inner_mac_header += off;
 #endif
 
 	return n;
-- 
1.7.11.7
