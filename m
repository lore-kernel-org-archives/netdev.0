From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 3/5] sfc: Move TX queue core queue mapping
 into tx.c
Date: Tue, 15 Feb 2011 20:14:36 +0000
Message-ID: <1297800876.2584.18.camel@bwh-desktop>
References: <1297800733.2584.15.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:26524 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753667Ab1BOUOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Feb 2011 15:14:39 -0500
In-Reply-To: <1297800733.2584.15.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_hard_start_xmit() needs to implement a mapping which is the
inverse of tx_queue::core_txq.  Move the initialisation of
tx_queue::core_txq next to efx_hard_start_xmit() to make the
connection more obvious.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    6 ++----
 drivers/net/sfc/efx.h |    1 +
 drivers/net/sfc/tx.c  |    7 +++++++
 3 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 002bac7..c559bc3 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1910,10 +1910,8 @@ static int efx_register_netdev(struct efx_nic *efx)
 
 	efx_for_each_channel(channel, efx) {
 		struct efx_tx_queue *tx_queue;
-		efx_for_each_channel_tx_queue(tx_queue, channel) {
-			tx_queue->core_txq = netdev_get_tx_queue(
-				efx->net_dev, tx_queue->queue / EFX_TXQ_TYPES);
-		}
+		efx_for_each_channel_tx_queue(tx_queue, channel)
+			efx_init_tx_queue_core_txq(tx_queue);
 	}
 
 	/* Always start with carrier off; PHY events will detect the link */
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index d43a7e5..1162070 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -29,6 +29,7 @@
 extern int efx_probe_tx_queue(struct efx_tx_queue *tx_queue);
 extern void efx_remove_tx_queue(struct efx_tx_queue *tx_queue);
 extern void efx_init_tx_queue(struct efx_tx_queue *tx_queue);
+extern void efx_init_tx_queue_core_txq(struct efx_tx_queue *tx_queue);
 extern void efx_fini_tx_queue(struct efx_tx_queue *tx_queue);
 extern void efx_release_tx_buffers(struct efx_tx_queue *tx_queue);
 extern netdev_tx_t
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 2f5e9da..7e463fb 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -347,6 +347,13 @@ netdev_tx_t efx_hard_start_xmit(struct sk_buff *skb,
 	return efx_enqueue_skb(tx_queue, skb);
 }
 
+void efx_init_tx_queue_core_txq(struct efx_tx_queue *tx_queue)
+{
+	/* Must be inverse of queue lookup in efx_hard_start_xmit() */
+	tx_queue->core_txq = netdev_get_tx_queue(
+		tx_queue->efx->net_dev, tx_queue->queue / EFX_TXQ_TYPES);
+}
+
 void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)
 {
 	unsigned fill_level;
-- 
1.7.3.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

