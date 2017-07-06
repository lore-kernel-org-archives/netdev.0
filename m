From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH net-next] sunvnet: add support for IPv6 checksum offloads
Date: Thu,  6 Jul 2017 16:57:10 -0700
Message-ID: <1499385430-11659-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <sparclinux-owner@vger.kernel.org>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The original code didn't handle non-IPv4 packets very well, so the
offload advertising had to be scaled back down to just IP.  Here we
add the bits needed to support TCP and UDP packets over IPv6 and
turn the offload advertising back on.

Orabug: 26289579

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 drivers/net/ethernet/sun/ldmvsw.c         |    2 +-
 drivers/net/ethernet/sun/sunvnet.c        |    2 +-
 drivers/net/ethernet/sun/sunvnet_common.c |   90 +++++++++++++++++++++++++----
 3 files changed, 81 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/sun/ldmvsw.c b/drivers/net/ethernet/sun/ldmvsw.c
index 8603e39..5b56c24 100644
--- a/drivers/net/ethernet/sun/ldmvsw.c
+++ b/drivers/net/ethernet/sun/ldmvsw.c
@@ -248,7 +248,7 @@ static void vsw_poll_controller(struct net_device *dev)
 	dev->ethtool_ops = &vsw_ethtool_ops;
 	dev->watchdog_timeo = VSW_TX_TIMEOUT;
 
-	dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG;
+	dev->hw_features = NETIF_F_HW_CSUM | NETIF_F_SG;
 	dev->features = dev->hw_features;
 
 	/* MTU range: 68 - 65535 */
diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 75b167e..0b95105 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -312,7 +312,7 @@ static void vnet_poll_controller(struct net_device *dev)
 	dev->watchdog_timeo = VNET_TX_TIMEOUT;
 
 	dev->hw_features = NETIF_F_TSO | NETIF_F_GSO | NETIF_F_GSO_SOFTWARE |
-			   NETIF_F_IP_CSUM | NETIF_F_SG;
+			   NETIF_F_HW_CSUM | NETIF_F_SG;
 	dev->features = dev->hw_features;
 
 	/* MTU range: 68 - 65535 */
diff --git a/drivers/net/ethernet/sun/sunvnet_common.c b/drivers/net/ethernet/sun/sunvnet_common.c
index 9e86833..ecf456c 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.c
+++ b/drivers/net/ethernet/sun/sunvnet_common.c
@@ -303,7 +303,7 @@ void sunvnet_handshake_complete_common(struct vio_driver_state *vio)
 	return skb;
 }
 
-static inline void vnet_fullcsum(struct sk_buff *skb)
+static inline void vnet_fullcsum_ipv4(struct sk_buff *skb)
 {
 	struct iphdr *iph = ip_hdr(skb);
 	int offset = skb_transport_offset(skb);
@@ -335,6 +335,40 @@ static inline void vnet_fullcsum(struct sk_buff *skb)
 	}
 }
 
+#if IS_ENABLED(CONFIG_IPV6)
+static inline void vnet_fullcsum_ipv6(struct sk_buff *skb)
+{
+	struct ipv6hdr *ip6h = ipv6_hdr(skb);
+	int offset = skb_transport_offset(skb);
+
+	if (skb->protocol != htons(ETH_P_IPV6))
+		return;
+	if (ip6h->nexthdr != IPPROTO_TCP &&
+	    ip6h->nexthdr != IPPROTO_UDP)
+		return;
+	skb->ip_summed = CHECKSUM_NONE;
+	skb->csum_level = 1;
+	skb->csum = 0;
+	if (ip6h->nexthdr == IPPROTO_TCP) {
+		struct tcphdr *ptcp = tcp_hdr(skb);
+
+		ptcp->check = 0;
+		skb->csum = skb_checksum(skb, offset, skb->len - offset, 0);
+		ptcp->check = csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr,
+					      skb->len - offset, IPPROTO_TCP,
+					      skb->csum);
+	} else if (ip6h->nexthdr == IPPROTO_UDP) {
+		struct udphdr *pudp = udp_hdr(skb);
+
+		pudp->check = 0;
+		skb->csum = skb_checksum(skb, offset, skb->len - offset, 0);
+		pudp->check = csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr,
+					      skb->len - offset, IPPROTO_UDP,
+					      skb->csum);
+	}
+}
+#endif
+
 static int vnet_rx_one(struct vnet_port *port, struct vio_net_desc *desc)
 {
 	struct net_device *dev = VNET_PORT_TO_NET_DEVICE(port);
@@ -394,9 +428,14 @@ static int vnet_rx_one(struct vnet_port *port, struct vio_net_desc *desc)
 				struct iphdr *iph = ip_hdr(skb);
 				int ihl = iph->ihl * 4;
 
-				skb_reset_transport_header(skb);
 				skb_set_transport_header(skb, ihl);
-				vnet_fullcsum(skb);
+				vnet_fullcsum_ipv4(skb);
+#if IS_ENABLED(CONFIG_IPV6)
+			} else if (skb->protocol == htons(ETH_P_IPV6)) {
+				skb_set_transport_header(skb,
+							 sizeof(struct ipv6hdr));
+				vnet_fullcsum_ipv6(skb);
+#endif
 			}
 		}
 		if (dext->flags & VNET_PKT_HCK_IPV4_HDRCKSUM_OK) {
@@ -1115,24 +1154,47 @@ static inline int vnet_skb_map(struct ldc_channel *lp, struct sk_buff *skb,
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			start = skb_checksum_start_offset(skb);
 		if (start) {
-			struct iphdr *iph = ip_hdr(nskb);
 			int offset = start + nskb->csum_offset;
 
+			/* copy the headers, no csum here */
 			if (skb_copy_bits(skb, 0, nskb->data, start)) {
 				dev_kfree_skb(nskb);
 				dev_kfree_skb(skb);
 				return NULL;
 			}
+
+			/* copy the rest, with csum calculation */
 			*(__sum16 *)(skb->data + offset) = 0;
 			csum = skb_copy_and_csum_bits(skb, start,
 						      nskb->data + start,
 						      skb->len - start, 0);
-			if (iph->protocol == IPPROTO_TCP ||
-			    iph->protocol == IPPROTO_UDP) {
-				csum = csum_tcpudp_magic(iph->saddr, iph->daddr,
-							 skb->len - start,
-							 iph->protocol, csum);
+
+			/* add in the header checksums */
+			if (skb->protocol == htons(ETH_P_IP)) {
+				struct iphdr *iph = ip_hdr(nskb);
+
+				if (iph->protocol == IPPROTO_TCP ||
+				    iph->protocol == IPPROTO_UDP) {
+					csum = csum_tcpudp_magic(iph->saddr,
+								 iph->daddr,
+								 skb->len - start,
+								 iph->protocol,
+								 csum);
+				}
+			} else if (skb->protocol == htons(ETH_P_IPV6)) {
+				struct ipv6hdr *ip6h = ipv6_hdr(nskb);
+
+				if (ip6h->nexthdr == IPPROTO_TCP ||
+				    ip6h->nexthdr == IPPROTO_UDP) {
+					csum = csum_ipv6_magic(&ip6h->saddr,
+							       &ip6h->daddr,
+							       skb->len - start,
+							       ip6h->nexthdr,
+							       csum);
+				}
 			}
+
+			/* save the final result */
 			*(__sum16 *)(nskb->data + offset) = csum;
 
 			nskb->ip_summed = CHECKSUM_NONE;
@@ -1318,8 +1380,14 @@ int sunvnet_start_xmit_common(struct sk_buff *skb, struct net_device *dev,
 	if (unlikely(!skb))
 		goto out_dropped;
 
-	if (skb->ip_summed == CHECKSUM_PARTIAL)
-		vnet_fullcsum(skb);
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		if (skb->protocol == htons(ETH_P_IP))
+			vnet_fullcsum_ipv4(skb);
+#if IS_ENABLED(CONFIG_IPV6)
+		else if (skb->protocol == htons(ETH_P_IPV6))
+			vnet_fullcsum_ipv6(skb);
+#endif
+	}
 
 	dr = &port->vio.drings[VIO_DRIVER_TX_RING];
 	i = skb_get_queue_mapping(skb);
-- 
1.7.1

