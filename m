From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 05/16] sfc: Stash header offsets for TSO in struct
 tso_state
Date: Fri, 24 Aug 2012 20:50:38 +0100
Message-ID: <1345837838.2694.27.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56716 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758130Ab2HXTum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 15:50:42 -0400
In-Reply-To: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/tx.c |   28 ++++++++++++----------------
 1 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index d9dbebc..ebca75e 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -613,10 +613,6 @@ void efx_remove_tx_queue(struct efx_tx_queue *tx_queue)
 #endif
 
 #define PTR_DIFF(p1, p2)  ((u8 *)(p1) - (u8 *)(p2))
-#define ETH_HDR_LEN(skb)  (skb_network_header(skb) - (skb)->data)
-#define SKB_TCP_OFF(skb)  PTR_DIFF(tcp_hdr(skb), (skb)->data)
-#define SKB_IPV4_OFF(skb) PTR_DIFF(ip_hdr(skb), (skb)->data)
-#define SKB_IPV6_OFF(skb) PTR_DIFF(ipv6_hdr(skb), (skb)->data)
 
 /**
  * struct tso_state - TSO state for an SKB
@@ -630,6 +626,8 @@ void efx_remove_tx_queue(struct efx_tx_queue *tx_queue)
  * @unmap_addr: DMA address of SKB fragment
  * @dma_flags: TX buffer flags for DMA mapping - %EFX_TX_BUF_MAP_SINGLE or 0
  * @protocol: Network protocol (after any VLAN header)
+ * @ip_off: Offset of IP header
+ * @tcp_off: Offset of TCP header
  * @header_len: Number of bytes of header
  * @ip_base_len: IPv4 tot_len or IPv6 payload_len, before TCP payload
  *
@@ -651,6 +649,8 @@ struct tso_state {
 	unsigned short dma_flags;
 
 	__be16 protocol;
+	unsigned int ip_off;
+	unsigned int tcp_off;
 	unsigned header_len;
 	unsigned int ip_base_len;
 };
@@ -825,17 +825,14 @@ static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue)
 /* Parse the SKB header and initialise state. */
 static void tso_start(struct tso_state *st, const struct sk_buff *skb)
 {
-	/* All ethernet/IP/TCP headers combined size is TCP header size
-	 * plus offset of TCP header relative to start of packet.
-	 */
-	st->header_len = ((tcp_hdr(skb)->doff << 2u)
-			  + PTR_DIFF(tcp_hdr(skb), skb->data));
-
+	st->ip_off = skb_network_header(skb) - skb->data;
+	st->tcp_off = skb_transport_header(skb) - skb->data;
+	st->header_len = st->tcp_off + (tcp_hdr(skb)->doff << 2u);
 	if (st->protocol == htons(ETH_P_IP)) {
-		st->ip_base_len = st->header_len - ETH_HDR_LEN(skb);
+		st->ip_base_len = st->header_len - st->ip_off;
 		st->ipv4_id = ntohs(ip_hdr(skb)->id);
 	} else {
-		st->ip_base_len = tcp_hdr(skb)->doff << 2u;
+		st->ip_base_len = st->header_len - st->tcp_off;
 		st->ipv4_id = 0;
 	}
 	st->seqnum = ntohl(tcp_hdr(skb)->seq);
@@ -959,7 +956,7 @@ static int tso_start_new_packet(struct efx_tx_queue *tx_queue,
 	if (!header)
 		return -ENOMEM;
 
-	tsoh_th = (struct tcphdr *)(header + SKB_TCP_OFF(skb));
+	tsoh_th = (struct tcphdr *)(header + st->tcp_off);
 
 	/* Copy and update the headers. */
 	memcpy(header, skb->data, st->header_len);
@@ -980,8 +977,7 @@ static int tso_start_new_packet(struct efx_tx_queue *tx_queue,
 	ip_length = st->ip_base_len + st->packet_space;
 
 	if (st->protocol == htons(ETH_P_IP)) {
-		struct iphdr *tsoh_iph =
-			(struct iphdr *)(header + SKB_IPV4_OFF(skb));
+		struct iphdr *tsoh_iph = (struct iphdr *)(header + st->ip_off);
 
 		tsoh_iph->tot_len = htons(ip_length);
 
@@ -990,7 +986,7 @@ static int tso_start_new_packet(struct efx_tx_queue *tx_queue,
 		st->ipv4_id++;
 	} else {
 		struct ipv6hdr *tsoh_iph =
-			(struct ipv6hdr *)(header + SKB_IPV6_OFF(skb));
+			(struct ipv6hdr *)(header + st->ip_off);
 
 		tsoh_iph->payload_len = htons(ip_length);
 	}
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
