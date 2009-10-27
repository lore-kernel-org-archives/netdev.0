From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6] sfc: Set ip_summed correctly for page buffers
	passed to GRO
Date: Tue, 27 Oct 2009 14:50:57 +0000
Message-ID: <1256655057.2794.4.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:39240 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754991AbZJ0Ouz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 10:50:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Page buffers containing packets with an incorrect checksum or using a
protocol not handled by hardware checksum offload were previously not
passed to LRO.  The conversion to GRO changed this, but did not set
the ip_summed value accordingly.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Cc: stable@kernel.org
---
This affects 2.6.31 and seems like a candidate for a stable update.

Ben.

 drivers/net/sfc/rx.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index ea59ed2..4b65c62 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -441,7 +441,8 @@ static void efx_rx_packet__check_len(struct efx_rx_queue *rx_queue,
  * the appropriate LRO method
  */
 static void efx_rx_packet_lro(struct efx_channel *channel,
-			      struct efx_rx_buffer *rx_buf)
+			      struct efx_rx_buffer *rx_buf,
+			      bool checksummed)
 {
 	struct napi_struct *napi = &channel->napi_str;
 
@@ -463,7 +464,8 @@ static void efx_rx_packet_lro(struct efx_channel *channel,
 		skb->len = rx_buf->len;
 		skb->data_len = rx_buf->len;
 		skb->truesize += rx_buf->len;
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		skb->ip_summed =
+			checksummed ? CHECKSUM_UNNECESSARY : CHECKSUM_NONE;
 
 		napi_gro_frags(napi);
 
@@ -472,6 +474,7 @@ out:
 		rx_buf->page = NULL;
 	} else {
 		EFX_BUG_ON_PARANOID(!rx_buf->skb);
+		EFX_BUG_ON_PARANOID(!checksummed);
 
 		napi_gro_receive(napi, rx_buf->skb);
 		rx_buf->skb = NULL;
@@ -567,7 +570,7 @@ void __efx_rx_packet(struct efx_channel *channel,
 	}
 
 	if (likely(checksummed || rx_buf->page)) {
-		efx_rx_packet_lro(channel, rx_buf);
+		efx_rx_packet_lro(channel, rx_buf, checksummed);
 		goto done;
 	}
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

