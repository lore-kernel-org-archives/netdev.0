From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 31/32] sfc: Implement TSO for TCP/IPv6
Date: Sat, 28 Nov 2009 03:59:02 +0000
Message-ID: <1259380742.2811.76.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:42973 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753696AbZK1D66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 22:58:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c     |    2 +
 drivers/net/sfc/ethtool.c |   20 ++++++++++++++++-
 drivers/net/sfc/tx.c      |   52 +++++++++++++++++++++++++++++++++-----------
 3 files changed, 60 insertions(+), 14 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 4b5c786..3c0d6be 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -2208,6 +2208,8 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 	net_dev->features |= (type->offload_features | NETIF_F_SG |
 			      NETIF_F_HIGHDMA | NETIF_F_TSO |
 			      NETIF_F_GRO);
+	if (type->offload_features & NETIF_F_V6_CSUM)
+		net_dev->features |= NETIF_F_TSO6;
 	/* Mask for features that also apply to VLAN devices */
 	net_dev->vlan_features |= (NETIF_F_ALL_CSUM | NETIF_F_SG |
 				   NETIF_F_HIGHDMA | NETIF_F_TSO);
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 5492b63..f698121 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -471,6 +471,23 @@ static void efx_ethtool_get_stats(struct net_device *net_dev,
 	}
 }
 
+static int efx_ethtool_set_tso(struct net_device *net_dev, u32 enable)
+{
+	struct efx_nic *efx __attribute__ ((unused)) = netdev_priv(net_dev);
+	unsigned long features;
+
+	features = NETIF_F_TSO;
+	if (efx->type->offload_features & NETIF_F_V6_CSUM)
+		features |= NETIF_F_TSO6;
+
+	if (enable)
+		net_dev->features |= features;
+	else
+		net_dev->features &= ~features;
+
+	return 0;
+}
+
 static int efx_ethtool_set_tx_csum(struct net_device *net_dev, u32 enable)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
@@ -834,7 +851,8 @@ const struct ethtool_ops efx_ethtool_ops = {
 	.get_sg			= ethtool_op_get_sg,
 	.set_sg			= ethtool_op_set_sg,
 	.get_tso		= ethtool_op_get_tso,
-	.set_tso		= ethtool_op_set_tso,
+	/* Need to enable/disable TSO-IPv6 too */
+	.set_tso		= efx_ethtool_set_tso,
 	.get_flags		= ethtool_op_get_flags,
 	.set_flags		= ethtool_op_set_flags,
 	.get_sset_count		= efx_ethtool_get_sset_count,
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 389ede4..582fc75 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -12,6 +12,8 @@
 #include <linux/tcp.h>
 #include <linux/ip.h>
 #include <linux/in.h>
+#include <linux/ipv6.h>
+#include <net/ipv6.h>
 #include <linux/if_ether.h>
 #include <linux/highmem.h>
 #include "net_driver.h"
@@ -531,6 +533,7 @@ void efx_remove_tx_queue(struct efx_tx_queue *tx_queue)
 #define ETH_HDR_LEN(skb)  (skb_network_header(skb) - (skb)->data)
 #define SKB_TCP_OFF(skb)  PTR_DIFF(tcp_hdr(skb), (skb)->data)
 #define SKB_IPV4_OFF(skb) PTR_DIFF(ip_hdr(skb), (skb)->data)
+#define SKB_IPV6_OFF(skb) PTR_DIFF(ipv6_hdr(skb), (skb)->data)
 
 /**
  * struct tso_state - TSO state for an SKB
@@ -543,6 +546,7 @@ void efx_remove_tx_queue(struct efx_tx_queue *tx_queue)
  * @unmap_len: Length of SKB fragment
  * @unmap_addr: DMA address of SKB fragment
  * @unmap_single: DMA single vs page mapping flag
+ * @protocol: Network protocol (after any VLAN header)
  * @header_len: Number of bytes of header
  * @full_packet_size: Number of bytes to put in each outgoing segment
  *
@@ -563,6 +567,7 @@ struct tso_state {
 	dma_addr_t unmap_addr;
 	bool unmap_single;
 
+	__be16 protocol;
 	unsigned header_len;
 	int full_packet_size;
 };
@@ -570,9 +575,9 @@ struct tso_state {
 
 /*
  * Verify that our various assumptions about sk_buffs and the conditions
- * under which TSO will be attempted hold true.
+ * under which TSO will be attempted hold true.  Return the protocol number.
  */
-static void efx_tso_check_safe(struct sk_buff *skb)
+static __be16 efx_tso_check_protocol(struct sk_buff *skb)
 {
 	__be16 protocol = skb->protocol;
 
@@ -587,13 +592,22 @@ static void efx_tso_check_safe(struct sk_buff *skb)
 		if (protocol == htons(ETH_P_IP))
 			skb_set_transport_header(skb, sizeof(*veh) +
 						 4 * ip_hdr(skb)->ihl);
+		else if (protocol == htons(ETH_P_IPV6))
+			skb_set_transport_header(skb, sizeof(*veh) +
+						 sizeof(struct ipv6hdr));
 	}
 
-	EFX_BUG_ON_PARANOID(protocol != htons(ETH_P_IP));
-	EFX_BUG_ON_PARANOID(ip_hdr(skb)->protocol != IPPROTO_TCP);
+	if (protocol == htons(ETH_P_IP)) {
+		EFX_BUG_ON_PARANOID(ip_hdr(skb)->protocol != IPPROTO_TCP);
+	} else {
+		EFX_BUG_ON_PARANOID(protocol != htons(ETH_P_IPV6));
+		EFX_BUG_ON_PARANOID(ipv6_hdr(skb)->nexthdr != NEXTHDR_TCP);
+	}
 	EFX_BUG_ON_PARANOID((PTR_DIFF(tcp_hdr(skb), skb->data)
 			     + (tcp_hdr(skb)->doff << 2u)) >
 			    skb_headlen(skb));
+
+	return protocol;
 }
 

@@ -836,7 +850,10 @@ static void tso_start(struct tso_state *st, const struct sk_buff *skb)
 			  + PTR_DIFF(tcp_hdr(skb), skb->data));
 	st->full_packet_size = st->header_len + skb_shinfo(skb)->gso_size;
 
-	st->ipv4_id = ntohs(ip_hdr(skb)->id);
+	if (st->protocol == htons(ETH_P_IP))
+		st->ipv4_id = ntohs(ip_hdr(skb)->id);
+	else
+		st->ipv4_id = 0;
 	st->seqnum = ntohl(tcp_hdr(skb)->seq);
 
 	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->urg);
@@ -951,7 +968,6 @@ static int tso_start_new_packet(struct efx_tx_queue *tx_queue,
 				struct tso_state *st)
 {
 	struct efx_tso_header *tsoh;
-	struct iphdr *tsoh_iph;
 	struct tcphdr *tsoh_th;
 	unsigned ip_length;
 	u8 *header;
@@ -975,7 +991,6 @@ static int tso_start_new_packet(struct efx_tx_queue *tx_queue,
 
 	header = TSOH_BUFFER(tsoh);
 	tsoh_th = (struct tcphdr *)(header + SKB_TCP_OFF(skb));
-	tsoh_iph = (struct iphdr *)(header + SKB_IPV4_OFF(skb));
 
 	/* Copy and update the headers. */
 	memcpy(header, skb->data, st->header_len);
@@ -993,11 +1008,22 @@ static int tso_start_new_packet(struct efx_tx_queue *tx_queue,
 		tsoh_th->fin = tcp_hdr(skb)->fin;
 		tsoh_th->psh = tcp_hdr(skb)->psh;
 	}
-	tsoh_iph->tot_len = htons(ip_length);
 
-	/* Linux leaves suitable gaps in the IP ID space for us to fill. */
-	tsoh_iph->id = htons(st->ipv4_id);
-	st->ipv4_id++;
+	if (st->protocol == htons(ETH_P_IP)) {
+		struct iphdr *tsoh_iph =
+			(struct iphdr *)(header + SKB_IPV4_OFF(skb));
+
+		tsoh_iph->tot_len = htons(ip_length);
+
+		/* Linux leaves suitable gaps in the IP ID space for us to fill. */
+		tsoh_iph->id = htons(st->ipv4_id);
+		st->ipv4_id++;
+	} else {
+		struct ipv6hdr *tsoh_iph =
+			(struct ipv6hdr *)(header + SKB_IPV6_OFF(skb));
+
+		tsoh_iph->payload_len = htons(ip_length - sizeof(*tsoh_iph));
+	}
 
 	st->packet_space = skb_shinfo(skb)->gso_size;
 	++tx_queue->tso_packets;
@@ -1027,8 +1053,8 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 	int frag_i, rc, rc2 = NETDEV_TX_OK;
 	struct tso_state state;
 
-	/* Verify TSO is safe - these checks should never fail. */
-	efx_tso_check_safe(skb);
+	/* Find the packet protocol and sanity-check it */
+	state.protocol = efx_tso_check_protocol(skb);
 
 	EFX_BUG_ON_PARANOID(tx_queue->write_count != tx_queue->insert_count);
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

