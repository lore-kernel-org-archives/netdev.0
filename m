From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 4/5] sfc: Distinguish queue lookup from test
 for queue existence
Date: Tue, 15 Feb 2011 20:14:51 +0000
Message-ID: <1297800891.2584.19.camel@bwh-desktop>
References: <1297800733.2584.15.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:26558 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726Ab1BOUO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Feb 2011 15:14:57 -0500
In-Reply-To: <1297800733.2584.15.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_channel_get_{rx,tx}_queue() currently return NULL if the channel
isn't used for traffic in that direction.  In most cases this is a
bug, but some callers rely on it as an existence test.

Add existence test functions efx_channel_has_{rx_queue,tx_queues}()
and use them as appropriate.

Change efx_channel_get_{rx,tx}_queue() to assert that the requested
queue exists.

Remove now-redundant initialisation from efx_set_channels().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   17 ++---------------
 drivers/net/sfc/ethtool.c    |    6 +++---
 drivers/net/sfc/net_driver.h |   39 ++++++++++++++++++++++++++++-----------
 3 files changed, 33 insertions(+), 29 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index c559bc3..6189d30 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1271,21 +1271,8 @@ static void efx_remove_interrupts(struct efx_nic *efx)
 
 static void efx_set_channels(struct efx_nic *efx)
 {
-	struct efx_channel *channel;
-	struct efx_tx_queue *tx_queue;
-
 	efx->tx_channel_offset =
 		separate_tx_channels ? efx->n_channels - efx->n_tx_channels : 0;
-
-	/* Channel pointers were set in efx_init_struct() but we now
-	 * need to clear them for TX queues in any RX-only channels. */
-	efx_for_each_channel(channel, efx) {
-		if (channel->channel - efx->tx_channel_offset >=
-		    efx->n_tx_channels) {
-			efx_for_each_channel_tx_queue(tx_queue, channel)
-				tx_queue->channel = NULL;
-		}
-	}
 }
 
 static int efx_probe_nic(struct efx_nic *efx)
@@ -1531,9 +1518,9 @@ void efx_init_irq_moderation(struct efx_nic *efx, int tx_usecs, int rx_usecs,
 	efx->irq_rx_adaptive = rx_adaptive;
 	efx->irq_rx_moderation = rx_ticks;
 	efx_for_each_channel(channel, efx) {
-		if (efx_channel_get_rx_queue(channel))
+		if (efx_channel_has_rx_queue(channel))
 			channel->irq_moderation = rx_ticks;
-		else if (efx_channel_get_tx_queue(channel, 0))
+		else if (efx_channel_has_tx_queues(channel))
 			channel->irq_moderation = tx_ticks;
 	}
 }
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 713969a..272cfe7 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -631,7 +631,7 @@ static int efx_ethtool_get_coalesce(struct net_device *net_dev,
 	/* Find lowest IRQ moderation across all used TX queues */
 	coalesce->tx_coalesce_usecs_irq = ~((u32) 0);
 	efx_for_each_channel(channel, efx) {
-		if (!efx_channel_get_tx_queue(channel, 0))
+		if (!efx_channel_has_tx_queues(channel))
 			continue;
 		if (channel->irq_moderation < coalesce->tx_coalesce_usecs_irq) {
 			if (channel->channel < efx->n_rx_channels)
@@ -676,8 +676,8 @@ static int efx_ethtool_set_coalesce(struct net_device *net_dev,
 
 	/* If the channel is shared only allow RX parameters to be set */
 	efx_for_each_channel(channel, efx) {
-		if (efx_channel_get_rx_queue(channel) &&
-		    efx_channel_get_tx_queue(channel, 0) &&
+		if (efx_channel_has_rx_queue(channel) &&
+		    efx_channel_has_tx_queues(channel) &&
 		    tx_usecs) {
 			netif_err(efx, drv, efx->net_dev, "Channel is shared. "
 				  "Only RX coalescing may be set\n");
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index c652702..77b7ce4 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -938,19 +938,28 @@ efx_get_tx_queue(struct efx_nic *efx, unsigned index, unsigned type)
 	return &efx->channel[efx->tx_channel_offset + index]->tx_queue[type];
 }
 
+static inline bool efx_channel_has_tx_queues(struct efx_channel *channel)
+{
+	return channel->channel - channel->efx->tx_channel_offset <
+		channel->efx->n_tx_channels;
+}
+
 static inline struct efx_tx_queue *
 efx_channel_get_tx_queue(struct efx_channel *channel, unsigned type)
 {
-	struct efx_tx_queue *tx_queue = channel->tx_queue;
-	EFX_BUG_ON_PARANOID(type >= EFX_TXQ_TYPES);
-	return tx_queue->channel ? tx_queue + type : NULL;
+	EFX_BUG_ON_PARANOID(!efx_channel_has_tx_queues(channel) ||
+			    type >= EFX_TXQ_TYPES);
+	return &channel->tx_queue[type];
 }
 
 /* Iterate over all TX queues belonging to a channel */
 #define efx_for_each_channel_tx_queue(_tx_queue, _channel)		\
-	for (_tx_queue = efx_channel_get_tx_queue(channel, 0);		\
-	     _tx_queue && _tx_queue < (_channel)->tx_queue + EFX_TXQ_TYPES; \
-	     _tx_queue++)
+	if (!efx_channel_has_tx_queues(_channel))			\
+		;							\
+	else								\
+		for (_tx_queue = (_channel)->tx_queue;			\
+		     _tx_queue < (_channel)->tx_queue + EFX_TXQ_TYPES;	\
+		     _tx_queue++)
 
 static inline struct efx_rx_queue *
 efx_get_rx_queue(struct efx_nic *efx, unsigned index)
@@ -959,18 +968,26 @@ efx_get_rx_queue(struct efx_nic *efx, unsigned index)
 	return &efx->channel[index]->rx_queue;
 }
 
+static inline bool efx_channel_has_rx_queue(struct efx_channel *channel)
+{
+	return channel->channel < channel->efx->n_rx_channels;
+}
+
 static inline struct efx_rx_queue *
 efx_channel_get_rx_queue(struct efx_channel *channel)
 {
-	return channel->channel < channel->efx->n_rx_channels ?
-		&channel->rx_queue : NULL;
+	EFX_BUG_ON_PARANOID(!efx_channel_has_rx_queue(channel));
+	return &channel->rx_queue;
 }
 
 /* Iterate over all RX queues belonging to a channel */
 #define efx_for_each_channel_rx_queue(_rx_queue, _channel)		\
-	for (_rx_queue = efx_channel_get_rx_queue(channel);		\
-	     _rx_queue;							\
-	     _rx_queue = NULL)
+	if (!efx_channel_has_rx_queue(_channel))			\
+		;							\
+	else								\
+		for (_rx_queue = &(_channel)->rx_queue;			\
+		     _rx_queue;						\
+		     _rx_queue = NULL)
 
 static inline struct efx_channel *
 efx_rx_queue_channel(struct efx_rx_queue *rx_queue)
-- 
1.7.3.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

