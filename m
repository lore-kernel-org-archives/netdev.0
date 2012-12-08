From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: [PATCH v4 1/5] net: Add support for hardware-offloaded encapsulation
Date: Fri,  7 Dec 2012 16:14:14 -0800
Message-ID: <1354925658-24115-2-git-send-email-joseph.gasparakis@intel.com>
References: <1354925658-24115-1-git-send-email-joseph.gasparakis@intel.com>
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dmitry@broadcom.com, saeed.bishara@gmail.com,
	bhutchings@solarflare.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: davem@davemloft.net, shemminger@vyatta.com, chrisw@sous-sol.org,
	gospo@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354925658-24115-1-git-send-email-joseph.gasparakis@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support in the kernel for offloading in the NIC Tx and Rx
checksumming for encapsulated packets (such as VXLAN and IP GRE).

For Tx encapsulation offload, the driver will need to set the right bits
in netdev->hw_enc_features. The protocol driver will have to set the
skb->encapsulation bit and populate the inner headers, so the NIC driver will
use those inner headers to calculate the csum in hardware.

For Rx encapsulation offload, the driver will need to set again the
skb->encapsulation flag and the skb->ip_csum to CHECKSUM_UNNECESSARY.
In that case the protocol driver should push the decapsulated packet up
to the stack, again with CHECKSUM_UNNECESSARY. In ether case, the protocol
driver should set the skb->encapsulation flag back to zero. Fianlly the
protocol driver should have NETIF_F_RXCSUM flag set in its features.

Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 include/linux/ip.h        |  5 +++
 include/linux/ipv6.h      |  5 +++
 include/linux/netdevice.h |  6 +++
 include/linux/skbuff.h    | 95 ++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/tcp.h       | 10 +++++
 include/linux/udp.h       |  5 +++
 net/core/skbuff.c         |  9 +++++
 7 files changed, 134 insertions(+), 1 deletion(-)

diff --git a/include/linux/ip.h b/include/linux/ip.h
index 58b82a2..492bc65 100644
--- a/include/linux/ip.h
+++ b/include/linux/ip.h
@@ -25,6 +25,11 @@ static inline struct iphdr *ip_hdr(const struct sk_buff *skb)
 	return (struct iphdr *)skb_network_header(skb);
 }
 
+static inline struct iphdr *inner_ip_hdr(const struct sk_buff *skb)
+{
+	return (struct iphdr *)skb_inner_network_header(skb);
+}
+
 static inline struct iphdr *ipip_hdr(const struct sk_buff *skb)
 {
 	return (struct iphdr *)skb_transport_header(skb);
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 12729e9..faed1e3 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -67,6 +67,11 @@ static inline struct ipv6hdr *ipv6_hdr(const struct sk_buff *skb)
 	return (struct ipv6hdr *)skb_network_header(skb);
 }
 
+static inline struct ipv6hdr *inner_ipv6_hdr(const struct sk_buff *skb)
+{
+	return (struct ipv6hdr *)skb_inner_network_header(skb);
+}
+
 static inline struct ipv6hdr *ipipv6_hdr(const struct sk_buff *skb)
 {
 	return (struct ipv6hdr *)skb_transport_header(skb);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 18c5dc9..c6a14d4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1063,6 +1063,12 @@ struct net_device {
 	netdev_features_t	wanted_features;
 	/* mask of features inheritable by VLAN devices */
 	netdev_features_t	vlan_features;
+	/* mask of features inherited by encapsulating devices
+	 * This field indicates what encapsulation offloads
+	 * the hardware is capable of doing, and drivers will
+	 * need to set them appropriately.
+	 */
+	netdev_features_t	hw_enc_features;
 
 	/* Interface index. Unique device identifier	*/
 	int			ifindex;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f2af494..320e976 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -376,6 +376,8 @@ typedef unsigned char *sk_buff_data_t;
  *	@mark: Generic packet mark
  *	@dropcount: total number of sk_receive_queue overflows
  *	@vlan_tci: vlan tag control information
+ *	@inner_transport_header: Inner transport layer header (encapsulation)
+ *	@inner_network_header: Network layer header (encapsulation)
  *	@transport_header: Transport layer header
  *	@network_header: Network layer header
  *	@mac_header: Link layer header
@@ -471,7 +473,13 @@ struct sk_buff {
 	__u8			wifi_acked:1;
 	__u8			no_fcs:1;
 	__u8			head_frag:1;
-	/* 8/10 bit hole (depending on ndisc_nodetype presence) */
+	/* Encapsulation protocol and NIC drivers should use
+	 * this flag to indicate to each other if the skb contains
+	 * encapsulated packet or not and maybe use the inner packet
+	 * headers if needed
+	 */
+	__u8			encapsulation:1;
+	/* 7/9 bit hole (depending on ndisc_nodetype presence) */
 	kmemcheck_bitfield_end(flags2);
 
 #ifdef CONFIG_NET_DMA
@@ -486,6 +494,8 @@ struct sk_buff {
 		__u32		avail_size;
 	};
 
+	sk_buff_data_t		inner_transport_header;
+	sk_buff_data_t		inner_network_header;
 	sk_buff_data_t		transport_header;
 	sk_buff_data_t		network_header;
 	sk_buff_data_t		mac_header;
@@ -1435,12 +1445,53 @@ static inline void skb_reserve(struct sk_buff *skb, int len)
 	skb->tail += len;
 }
 
+static inline void skb_reset_inner_headers(struct sk_buff *skb)
+{
+	skb->inner_network_header = skb->network_header;
+	skb->inner_transport_header = skb->transport_header;
+}
+
 static inline void skb_reset_mac_len(struct sk_buff *skb)
 {
 	skb->mac_len = skb->network_header - skb->mac_header;
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
 static inline unsigned char *skb_transport_header(const struct sk_buff *skb)
 {
 	return skb->head + skb->transport_header;
@@ -1496,6 +1547,38 @@ static inline void skb_set_mac_header(struct sk_buff *skb, const int offset)
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
 
 static inline unsigned char *skb_transport_header(const struct sk_buff *skb)
 {
@@ -1574,11 +1657,21 @@ static inline u32 skb_network_header_len(const struct sk_buff *skb)
 	return skb->transport_header - skb->network_header;
 }
 
+static inline u32 skb_inner_network_header_len(const struct sk_buff *skb)
+{
+	return skb->inner_transport_header - skb->inner_network_header;
+}
+
 static inline int skb_network_offset(const struct sk_buff *skb)
 {
 	return skb_network_header(skb) - skb->data;
 }
 
+static inline int skb_inner_network_offset(const struct sk_buff *skb)
+{
+	return skb_inner_network_header(skb) - skb->data;
+}
+
 static inline int pskb_network_may_pull(struct sk_buff *skb, unsigned int len)
 {
 	return pskb_may_pull(skb, skb_network_offset(skb) + len);
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 60b7aac..4e1d228 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -35,6 +35,16 @@ static inline unsigned int tcp_hdrlen(const struct sk_buff *skb)
 	return tcp_hdr(skb)->doff * 4;
 }
 
+static inline struct tcphdr *inner_tcp_hdr(const struct sk_buff *skb)
+{
+	return (struct tcphdr *)skb_inner_transport_header(skb);
+}
+
+static inline unsigned int inner_tcp_hdrlen(const struct sk_buff *skb)
+{
+	return inner_tcp_hdr(skb)->doff * 4;
+}
+
 static inline unsigned int tcp_optlen(const struct sk_buff *skb)
 {
 	return (tcp_hdr(skb)->doff - 5) * 4;
diff --git a/include/linux/udp.h b/include/linux/udp.h
index 0b67d77..9d81de1 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -27,6 +27,11 @@ static inline struct udphdr *udp_hdr(const struct sk_buff *skb)
 	return (struct udphdr *)skb_transport_header(skb);
 }
 
+static inline struct udphdr *inner_udp_hdr(const struct sk_buff *skb)
+{
+	return (struct udphdr *)skb_inner_transport_header(skb);
+}
+
 #define UDP_HTABLE_SIZE_MIN		(CONFIG_BASE_SMALL ? 128 : 256)
 
 static inline int udp_hashfn(struct net *net, unsigned num, unsigned mask)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 880722e2..ccbabf5 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -682,11 +682,14 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->transport_header	= old->transport_header;
 	new->network_header	= old->network_header;
 	new->mac_header		= old->mac_header;
+	new->inner_transport_header = old->inner_transport_header;
+	new->inner_network_header = old->inner_transport_header;
 	skb_dst_copy(new, old);
 	new->rxhash		= old->rxhash;
 	new->ooo_okay		= old->ooo_okay;
 	new->l4_rxhash		= old->l4_rxhash;
 	new->no_fcs		= old->no_fcs;
+	new->encapsulation	= old->encapsulation;
 #ifdef CONFIG_XFRM
 	new->sp			= secpath_get(old->sp);
 #endif
@@ -892,6 +895,8 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->network_header   += offset;
 	if (skb_mac_header_was_set(new))
 		new->mac_header	      += offset;
+	new->inner_transport_header += offset;
+	new->inner_network_header   += offset;
 #endif
 	skb_shinfo(new)->gso_size = skb_shinfo(old)->gso_size;
 	skb_shinfo(new)->gso_segs = skb_shinfo(old)->gso_segs;
@@ -1089,6 +1094,8 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	skb->network_header   += off;
 	if (skb_mac_header_was_set(skb))
 		skb->mac_header += off;
+	skb->inner_transport_header += off;
+	skb->inner_network_header += off;
 	/* Only adjust this if it actually is csum_start rather than csum */
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		skb->csum_start += nhead;
@@ -1188,6 +1195,8 @@ struct sk_buff *skb_copy_expand(const struct sk_buff *skb,
 	n->network_header   += off;
 	if (skb_mac_header_was_set(skb))
 		n->mac_header += off;
+	n->inner_transport_header += off;
+	n->inner_network_header	   += off;
 #endif
 
 	return n;
-- 
1.7.11.7
