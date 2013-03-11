From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 15/22] sfc: Wrap __efx_rx_packet() with
 efx_rx_flush_packet()
Date: Mon, 11 Mar 2013 19:56:29 +0000
Message-ID: <1363031789.2608.52.camel@bwh-desktop.uk.solarflarecom.com>
References: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<scrum-linux@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16826 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753885Ab3CKT4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 15:56:33 -0400
In-Reply-To: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The pipeline mechanism will need to change a bit for scattered
packets.  Add a wrapper to insulate efx_process_channel() from this.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |    6 +-----
 drivers/net/ethernet/sfc/efx.h |    7 +++++++
 drivers/net/ethernet/sfc/rx.c  |    3 +--
 3 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 34b56ec..f8013c3 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -250,11 +250,7 @@ static int efx_process_channel(struct efx_channel *channel, int budget)
 		struct efx_rx_queue *rx_queue =
 			efx_channel_get_rx_queue(channel);
 
-		/* Deliver last RX packet. */
-		if (channel->rx_pkt) {
-			__efx_rx_packet(channel, channel->rx_pkt);
-			channel->rx_pkt = NULL;
-		}
+		efx_rx_flush_packet(channel);
 		if (rx_queue->enabled)
 			efx_fast_push_rx_descriptors(rx_queue);
 	}
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 64c555e..00e7077 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -43,6 +43,13 @@ extern void __efx_rx_packet(struct efx_channel *channel,
 			    struct efx_rx_buffer *rx_buf);
 extern void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 			  unsigned int len, u16 flags);
+static inline void efx_rx_flush_packet(struct efx_channel *channel)
+{
+	if (channel->rx_pkt) {
+		__efx_rx_packet(channel, channel->rx_pkt);
+		channel->rx_pkt = NULL;
+	}
+}
 extern void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue);
 
 #define EFX_MAX_DMAQ_SIZE 4096UL
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 31361db..60f4eb7 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -465,8 +465,7 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 	 */
 	rx_buf->len = len - efx->type->rx_buffer_hash_size;
 out:
-	if (channel->rx_pkt)
-		__efx_rx_packet(channel, channel->rx_pkt);
+	efx_rx_flush_packet(channel);
 	channel->rx_pkt = rx_buf;
 }
 
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
