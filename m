From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net] sfc: Fix assignment of ip_summed for pre-allocated skbs
Date: Sat, 25 Feb 2012 01:12:34 +0000
Message-ID: <1330132354.2397.18.camel@bwh-desktop>
References: <1330132277.2397.17.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:24134 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757074Ab2BYBMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2012 20:12:37 -0500
In-Reply-To: <1330132277.2397.17.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When pre-allocating skbs for received packets, we set ip_summed =
CHECKSUM_UNNCESSARY.  We used to change it back to CHECKSUM_NONE when
the received packet had an incorrect checksum or unhandled protocol.

Commit bc8acf2c8c3e43fcc192762a9f964b3e9a17748b ('drivers/net: avoid
some skb->ip_summed initializations') mistakenly replaced the latter
assignment with a DEBUG-only assertion that ip_summed ==
CHECKSUM_NONE.  This assertion is always false, but it seems no-one
has exercised this code path in a DEBUG build.

Fix this by moving our assignment of CHECKSUM_UNNECESSARY into
efx_rx_packet_gro().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/rx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index aca3498..fc52fca 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -156,11 +156,10 @@ static int efx_init_rx_buffers_skb(struct efx_rx_queue *rx_queue)
 		if (unlikely(!skb))
 			return -ENOMEM;
 
-		/* Adjust the SKB for padding and checksum */
+		/* Adjust the SKB for padding */
 		skb_reserve(skb, NET_IP_ALIGN);
 		rx_buf->len = skb_len - NET_IP_ALIGN;
 		rx_buf->is_page = false;
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 		rx_buf->dma_addr = pci_map_single(efx->pci_dev,
 						  skb->data, rx_buf->len,
@@ -496,6 +495,7 @@ static void efx_rx_packet_gro(struct efx_channel *channel,
 
 		EFX_BUG_ON_PARANOID(!checksummed);
 		rx_buf->u.skb = NULL;
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 		gro_result = napi_gro_receive(napi, skb);
 	}
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
