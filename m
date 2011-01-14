From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6 1/2] sfc: Make efx_get_tx_queue() an inline function
Date: Fri, 14 Jan 2011 14:25:29 +0000
Message-ID: <1295015129.5386.2.camel@bwh-desktop>
References: <1295014889.5386.1.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:57879 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756855Ab1ANOZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 09:25:32 -0500
In-Reply-To: <1295014889.5386.1.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   15 +++------------
 drivers/net/sfc/net_driver.h |   10 ++++++++--
 2 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 711449c..c2dc9a5 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1266,27 +1266,18 @@ static void efx_remove_interrupts(struct efx_nic *efx)
 	efx->legacy_irq = 0;
 }
 
-struct efx_tx_queue *
-efx_get_tx_queue(struct efx_nic *efx, unsigned index, unsigned type)
-{
-	unsigned tx_channel_offset =
-		separate_tx_channels ? efx->n_channels - efx->n_tx_channels : 0;
-	EFX_BUG_ON_PARANOID(index >= efx->n_tx_channels ||
-			    type >= EFX_TXQ_TYPES);
-	return &efx->channel[tx_channel_offset + index]->tx_queue[type];
-}
-
 static void efx_set_channels(struct efx_nic *efx)
 {
 	struct efx_channel *channel;
 	struct efx_tx_queue *tx_queue;
-	unsigned tx_channel_offset =
+
+	efx->tx_channel_offset =
 		separate_tx_channels ? efx->n_channels - efx->n_tx_channels : 0;
 
 	/* Channel pointers were set in efx_init_struct() but we now
 	 * need to clear them for TX queues in any RX-only channels. */
 	efx_for_each_channel(channel, efx) {
-		if (channel->channel - tx_channel_offset >=
+		if (channel->channel - efx->tx_channel_offset >=
 		    efx->n_tx_channels) {
 			efx_for_each_channel_tx_queue(tx_queue, channel)
 				tx_queue->channel = NULL;
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index bdce66d..28df866 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -735,6 +735,7 @@ struct efx_nic {
 	unsigned next_buffer_table;
 	unsigned n_channels;
 	unsigned n_rx_channels;
+	unsigned tx_channel_offset;
 	unsigned n_tx_channels;
 	unsigned int rx_buffer_len;
 	unsigned int rx_buffer_order;
@@ -929,8 +930,13 @@ efx_get_channel(struct efx_nic *efx, unsigned index)
 	     _channel = (_channel->channel + 1 < (_efx)->n_channels) ?	\
 		     (_efx)->channel[_channel->channel + 1] : NULL)
 
-extern struct efx_tx_queue *
-efx_get_tx_queue(struct efx_nic *efx, unsigned index, unsigned type);
+static inline struct efx_tx_queue *
+efx_get_tx_queue(struct efx_nic *efx, unsigned index, unsigned type)
+{
+	EFX_BUG_ON_PARANOID(index >= efx->n_tx_channels ||
+			    type >= EFX_TXQ_TYPES);
+	return &efx->channel[efx->tx_channel_offset + index]->tx_queue[type];
+}
 
 static inline struct efx_tx_queue *
 efx_channel_get_tx_queue(struct efx_channel *channel, unsigned type)
-- 
1.7.3.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

