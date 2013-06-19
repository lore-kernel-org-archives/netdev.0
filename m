From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 07/11] sfc: Do not pass non-TCP packets into GRO
 code
Date: Wed, 19 Jun 2013 23:19:56 +0100
Message-ID: <1371680396.1956.114.camel@bwh-desktop.uk.level5networks.com>
References: <1371680169.1956.107.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:10462 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964822Ab3FSWUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 18:20:00 -0400
In-Reply-To: <1371680169.1956.107.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GRO can handle non-TCP packets and pass them up without coalescing,
but it has to do some extra work to parse the packet which we can
bypass using the hardware parse result.  (Falcon won't mark TCP/IPv6
packets as TCP, but then it won't validate their checksums either, so
GRO can't coalesce them.)

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
