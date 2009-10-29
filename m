From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 3/4] sfc: Feed GRO result into RX allocation policy and
	interrupt moderation
Date: Thu, 29 Oct 2009 17:21:24 +0000
Message-ID: <1256836884.2827.73.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:41214 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756441AbZJ2RVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 13:21:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When GRO is successfully merging received packets, we should allocate
raw page buffers rather than skbs that will be discarded by GRO.
Otherwise, we should allocate skbs.

GRO also benefits from higher interrupt moderation, so increase the
score for mergeable RX packets.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/rx.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 4b65c62..9277e9a 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -445,6 +445,7 @@ static void efx_rx_packet_lro(struct efx_channel *channel,
 			      bool checksummed)
 {
 	struct napi_struct *napi = &channel->napi_str;
+	gro_result_t gro_result;
 
 	/* Pass the skb/page into the LRO engine */
 	if (rx_buf->page) {
@@ -452,6 +453,7 @@ static void efx_rx_packet_lro(struct efx_channel *channel,
 
 		if (!skb) {
 			put_page(rx_buf->page);
+			gro_result = GRO_DROP;
 			goto out;
 		}
 
@@ -467,7 +469,7 @@ static void efx_rx_packet_lro(struct efx_channel *channel,
 		skb->ip_summed =
 			checksummed ? CHECKSUM_UNNECESSARY : CHECKSUM_NONE;
 
-		napi_gro_frags(napi);
+		gro_result = napi_gro_frags(napi);
 
 out:
 		EFX_BUG_ON_PARANOID(rx_buf->skb);
@@ -476,9 +478,16 @@ out:
 		EFX_BUG_ON_PARANOID(!rx_buf->skb);
 		EFX_BUG_ON_PARANOID(!checksummed);
 
-		napi_gro_receive(napi, rx_buf->skb);
+		gro_result = napi_gro_receive(napi, rx_buf->skb);
 		rx_buf->skb = NULL;
 	}
+
+	if (gro_result == GRO_NORMAL) {
+		channel->rx_alloc_level += RX_ALLOC_FACTOR_SKB;
+	} else if (gro_result != GRO_DROP) {
+		channel->rx_alloc_level += RX_ALLOC_FACTOR_LRO;
+		channel->irq_mod_score += 2;
+	}
 }
 
 void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

