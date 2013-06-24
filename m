From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 7/9] sfc: Do not pass non-TCP packets into GRO code
Date: Mon, 24 Jun 2013 21:14:46 +0100
Message-ID: <1372104886.1896.36.camel@bwh-desktop.uk.level5networks.com>
References: <1372104708.1896.29.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17341 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784Ab3FXUOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 16:14:50 -0400
In-Reply-To: <1372104708.1896.29.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GRO can handle non-TCP packets and pass them up without coalescing,
but it has to do some extra work to parse the packet which we can
bypass using the hardware parse result.  (This condition yields a
false negative for TCP/IPv6 packets received by Falcon, but its
performance is already poor in that case due to lack of checksum
offload.)

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/rx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 6efff3d..5c45118 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -629,7 +629,7 @@ void __efx_rx_packet(struct efx_channel *channel)
 	if (unlikely(!(efx->net_dev->features & NETIF_F_RXCSUM)))
 		rx_buf->flags &= ~EFX_RX_PKT_CSUMMED;
 
-	if (!channel->type->receive_skb)
+	if ((rx_buf->flags & EFX_RX_PKT_TCP) && !channel->type->receive_skb)
 		efx_rx_packet_gro(channel, rx_buf, channel->rx_pkt_n_frags, eh);
 	else
 		efx_rx_deliver(channel, eh, rx_buf, channel->rx_pkt_n_frags);


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
