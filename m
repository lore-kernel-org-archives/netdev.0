From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 04/11] sfc: Fold tso_get_head_fragment() into
 tso_start()
Date: Sat, 21 Sep 2013 19:34:05 +0100
Message-ID: <1379788445.1681.38.camel@bwh-desktop.uk.level5networks.com>
References: <1379788283.1681.34.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:32589 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752619Ab3IUSeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 14:34:09 -0400
In-Reply-To: <1379788283.1681.34.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/tx.c | 62 +++++++++++++++++++++----------------------
 1 file changed, 31 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 2ac91c5..9025356 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -822,11 +822,17 @@ static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue)
 

 /* Parse the SKB header and initialise state. */
-static void tso_start(struct tso_state *st, const struct sk_buff *skb)
+static int tso_start(struct tso_state *st, struct efx_nic *efx,
+		     const struct sk_buff *skb)
 {
+	unsigned int header_len, in_len;
+
 	st->ip_off = skb_network_header(skb) - skb->data;
 	st->tcp_off = skb_transport_header(skb) - skb->data;
-	st->header_len = st->tcp_off + (tcp_hdr(skb)->doff << 2u);
+	header_len = st->tcp_off + (tcp_hdr(skb)->doff << 2u);
+	in_len = skb_headlen(skb) - header_len;
+	st->header_len = header_len;
+	st->in_len = in_len;
 	if (st->protocol == htons(ETH_P_IP)) {
 		st->ip_base_len = st->header_len - st->ip_off;
 		st->ipv4_id = ntohs(ip_hdr(skb)->id);
@@ -840,9 +846,24 @@ static void tso_start(struct tso_state *st, const struct sk_buff *skb)
 	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->syn);
 	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->rst);
 
-	st->out_len = skb->len - st->header_len;
-	st->unmap_len = 0;
-	st->dma_flags = 0;
+	st->out_len = skb->len - header_len;
+
+	if (likely(in_len == 0)) {
+		st->unmap_len = 0;
+		st->dma_flags = 0;
+		return 0;
+	}
+
+	st->unmap_addr = dma_map_single(&efx->pci_dev->dev,
+					skb->data + header_len, in_len,
+					DMA_TO_DEVICE);
+	if (unlikely(dma_mapping_error(&efx->pci_dev->dev, st->unmap_addr)))
+		return -ENOMEM;
+
+	st->dma_flags = EFX_TX_BUF_MAP_SINGLE;
+	st->unmap_len = in_len;
+	st->dma_addr = st->unmap_addr;
+	return 0;
 }
 
 static int tso_get_fragment(struct tso_state *st, struct efx_nic *efx,
@@ -860,24 +881,6 @@ static int tso_get_fragment(struct tso_state *st, struct efx_nic *efx,
 	return -ENOMEM;
 }
 
-static int tso_get_head_fragment(struct tso_state *st, struct efx_nic *efx,
-				 const struct sk_buff *skb)
-{
-	int hl = st->header_len;
-	int len = skb_headlen(skb) - hl;
-
-	st->unmap_addr = dma_map_single(&efx->pci_dev->dev, skb->data + hl,
-					len, DMA_TO_DEVICE);
-	if (likely(!dma_mapping_error(&efx->pci_dev->dev, st->unmap_addr))) {
-		st->dma_flags = EFX_TX_BUF_MAP_SINGLE;
-		st->unmap_len = len;
-		st->in_len = len;
-		st->dma_addr = st->unmap_addr;
-		return 0;
-	}
-	return -ENOMEM;
-}
-
 
 /**
  * tso_fill_packet_with_fragment - form descriptors for the current fragment
@@ -1023,12 +1026,11 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 
 	EFX_BUG_ON_PARANOID(tx_queue->write_count != tx_queue->insert_count);
 
-	tso_start(&state, skb);
+	rc = tso_start(&state, efx, skb);
+	if (rc)
+		goto mem_err;
 
-	/* Assume that skb header area contains exactly the headers, and
-	 * all payload is in the frag list.
-	 */
-	if (skb_headlen(skb) == state.header_len) {
+	if (likely(state.in_len == 0)) {
 		/* Grab the first payload fragment. */
 		EFX_BUG_ON_PARANOID(skb_shinfo(skb)->nr_frags < 1);
 		frag_i = 0;
@@ -1037,9 +1039,7 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 		if (rc)
 			goto mem_err;
 	} else {
-		rc = tso_get_head_fragment(&state, efx, skb);
-		if (rc)
-			goto mem_err;
+		/* Payload starts in the header area. */
 		frag_i = -1;
 	}
 


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
