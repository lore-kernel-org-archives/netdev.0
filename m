From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 15/17] sfc: When waking a stopped tx_queue,
 only lock that tx_queue
Date: Thu, 02 Dec 2010 23:48:14 +0000
Message-ID: <1291333694.3259.38.camel@bwh-desktop>
References: <1291333490.3259.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:13135 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932318Ab0LBXsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 18:48:17 -0500
In-Reply-To: <1291333490.3259.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/tx.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 1172698..03194f7 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -401,6 +401,7 @@ void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)
 {
 	unsigned fill_level;
 	struct efx_nic *efx = tx_queue->efx;
+	struct netdev_queue *queue;
 
 	EFX_BUG_ON_PARANOID(index > tx_queue->ptr_mask);
 
@@ -417,12 +418,15 @@ void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)
 
 			/* Do this under netif_tx_lock(), to avoid racing
 			 * with efx_xmit(). */
-			netif_tx_lock(efx->net_dev);
+			queue = netdev_get_tx_queue(
+				efx->net_dev,
+				tx_queue->queue / EFX_TXQ_TYPES);
+			__netif_tx_lock(queue, smp_processor_id());
 			if (tx_queue->stopped) {
 				tx_queue->stopped = 0;
 				efx_wake_queue(tx_queue->channel);
 			}
-			netif_tx_unlock(efx->net_dev);
+			__netif_tx_unlock(queue);
 		}
 	}
 }
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

