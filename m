From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 04/16] sfc: Replace tso_state::full_packet_space
 with ip_base_len
Date: Fri, 24 Aug 2012 20:50:21 +0100
Message-ID: <1345837821.2694.26.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56701 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758130Ab2HXTuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 15:50:24 -0400
In-Reply-To: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We only use tso_state::full_packet_space to calculate the IPv4 tot_len
or IPv6 payload_len, not to set tso_state::packet_space.  Replace it
with an ip_base_len field holding the value of tot_len or payload_len
before including the TCP payload, which is much more useful when
constructing the new headers.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/tx.c |   20 +++++++++++---------
 1 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 61bc0ed..d9dbebc 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -631,7 +631,7 @@ void efx_remove_tx_queue(struct efx_tx_queue *tx_queue)
  * @dma_flags: TX buffer flags for DMA mapping - %EFX_TX_BUF_MAP_SINGLE or 0
  * @protocol: Network protocol (after any VLAN header)
  * @header_len: Number of bytes of header
- * @full_packet_size: Number of bytes to put in each outgoing segment
+ * @ip_base_len: IPv4 tot_len or IPv6 payload_len, before TCP payload
  *
  * The state used during segmentation.  It is put into this data structure
  * just to make it easy to pass into inline functions.
@@ -652,7 +652,7 @@ struct tso_state {
 
 	__be16 protocol;
 	unsigned header_len;
-	int full_packet_size;
+	unsigned int ip_base_len;
 };
 

@@ -830,12 +830,14 @@ static void tso_start(struct tso_state *st, const struct sk_buff *skb)
 	 */
 	st->header_len = ((tcp_hdr(skb)->doff << 2u)
 			  + PTR_DIFF(tcp_hdr(skb), skb->data));
-	st->full_packet_size = st->header_len + skb_shinfo(skb)->gso_size;
 
-	if (st->protocol == htons(ETH_P_IP))
+	if (st->protocol == htons(ETH_P_IP)) {
+		st->ip_base_len = st->header_len - ETH_HDR_LEN(skb);
 		st->ipv4_id = ntohs(ip_hdr(skb)->id);
-	else
+	} else {
+		st->ip_base_len = tcp_hdr(skb)->doff << 2u;
 		st->ipv4_id = 0;
+	}
 	st->seqnum = ntohl(tcp_hdr(skb)->seq);
 
 	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->urg);
@@ -966,15 +968,16 @@ static int tso_start_new_packet(struct efx_tx_queue *tx_queue,
 	st->seqnum += skb_shinfo(skb)->gso_size;
 	if (st->out_len > skb_shinfo(skb)->gso_size) {
 		/* This packet will not finish the TSO burst. */
-		ip_length = st->full_packet_size - ETH_HDR_LEN(skb);
+		st->packet_space = skb_shinfo(skb)->gso_size;
 		tsoh_th->fin = 0;
 		tsoh_th->psh = 0;
 	} else {
 		/* This packet will be the last in the TSO burst. */
-		ip_length = st->header_len - ETH_HDR_LEN(skb) + st->out_len;
+		st->packet_space = st->out_len;
 		tsoh_th->fin = tcp_hdr(skb)->fin;
 		tsoh_th->psh = tcp_hdr(skb)->psh;
 	}
+	ip_length = st->ip_base_len + st->packet_space;
 
 	if (st->protocol == htons(ETH_P_IP)) {
 		struct iphdr *tsoh_iph =
@@ -989,14 +992,13 @@ static int tso_start_new_packet(struct efx_tx_queue *tx_queue,
 		struct ipv6hdr *tsoh_iph =
 			(struct ipv6hdr *)(header + SKB_IPV6_OFF(skb));
 
-		tsoh_iph->payload_len = htons(ip_length - sizeof(*tsoh_iph));
+		tsoh_iph->payload_len = htons(ip_length);
 	}
 
 	rc = efx_tso_put_header(tx_queue, buffer, header);
 	if (unlikely(rc))
 		return rc;
 
-	st->packet_space = skb_shinfo(skb)->gso_size;
 	++tx_queue->tso_packets;
 
 	return 0;
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
