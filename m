From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 27/52] sfc: Remove efx_channel::evqnum field
Date: Mon, 1 Sep 2008 12:48:03 +0100
Message-ID: <20080901114803.GU7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:60027 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759630AbYIALsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:48:06 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is redundant with efx_channel::channel.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |    1 -
 drivers/net/sfc/falcon.c     |   14 +++++++-------
 drivers/net/sfc/net_driver.h |    2 --
 3 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index ba4369c..22004a6 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1854,7 +1854,6 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 		channel = &efx->channel[i];
 		channel->efx = efx;
 		channel->channel = i;
-		channel->evqnum = i;
 		channel->work_pending = false;
 	}
 	for (i = 0; i < EFX_TX_QUEUE_COUNT; i++) {
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index bfae082..7b1c387 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -466,7 +466,7 @@ int falcon_init_tx(struct efx_tx_queue *tx_queue)
 			      TX_ISCSI_DDIG_EN, 0,
 			      TX_ISCSI_HDIG_EN, 0,
 			      TX_DESCQ_BUF_BASE_ID, tx_queue->txd.index,
-			      TX_DESCQ_EVQ_ID, tx_queue->channel->evqnum,
+			      TX_DESCQ_EVQ_ID, tx_queue->channel->channel,
 			      TX_DESCQ_OWNER_ID, 0,
 			      TX_DESCQ_LABEL, tx_queue->queue,
 			      TX_DESCQ_SIZE, FALCON_TXD_RING_ORDER,
@@ -661,7 +661,7 @@ int falcon_init_rx(struct efx_rx_queue *rx_queue)
 			      RX_ISCSI_DDIG_EN, iscsi_digest_en,
 			      RX_ISCSI_HDIG_EN, iscsi_digest_en,
 			      RX_DESCQ_BUF_BASE_ID, rx_queue->rxd.index,
-			      RX_DESCQ_EVQ_ID, rx_queue->channel->evqnum,
+			      RX_DESCQ_EVQ_ID, rx_queue->channel->channel,
 			      RX_DESCQ_OWNER_ID, 0,
 			      RX_DESCQ_LABEL, rx_queue->queue,
 			      RX_DESCQ_SIZE, FALCON_RXD_RING_ORDER,
@@ -795,7 +795,7 @@ void falcon_eventq_read_ack(struct efx_channel *channel)
 
 	EFX_POPULATE_DWORD_1(reg, EVQ_RPTR_DWORD, channel->eventq_read_ptr);
 	falcon_writel_table(efx, &reg, efx->type->evq_rptr_tbl_base,
-			    channel->evqnum);
+			    channel->channel);
 }
 
 /* Use HW to insert a SW defined event */
@@ -804,7 +804,7 @@ void falcon_generate_event(struct efx_channel *channel, efx_qword_t *event)
 	efx_oword_t drv_ev_reg;
 
 	EFX_POPULATE_OWORD_2(drv_ev_reg,
-			     DRV_EV_QID, channel->evqnum,
+			     DRV_EV_QID, channel->channel,
 			     DRV_EV_DATA,
 			     EFX_QWORD_FIELD64(*event, WHOLE_EVENT));
 	falcon_write(channel->efx, &drv_ev_reg, DRV_EV_REG_KER);
@@ -1197,7 +1197,7 @@ void falcon_set_int_moderation(struct efx_channel *channel)
 				     TIMER_VAL, 0);
 	}
 	falcon_writel_page_locked(efx, &timer_cmd, TIMER_CMD_REG_KER,
-				  channel->evqnum);
+				  channel->channel);
 
 }
 
@@ -1235,7 +1235,7 @@ int falcon_init_eventq(struct efx_channel *channel)
 			     EVQ_SIZE, FALCON_EVQ_ORDER,
 			     EVQ_BUF_BASE_ID, channel->eventq.index);
 	falcon_write_table(efx, &evq_ptr, efx->type->evq_ptr_tbl_base,
-			   channel->evqnum);
+			   channel->channel);
 
 	falcon_set_int_moderation(channel);
 
@@ -1250,7 +1250,7 @@ void falcon_fini_eventq(struct efx_channel *channel)
 	/* Remove event queue from card */
 	EFX_ZERO_OWORD(eventq_ptr);
 	falcon_write_table(efx, &eventq_ptr, efx->type->evq_ptr_tbl_base,
-			   channel->evqnum);
+			   channel->channel);
 
 	/* Unpin event queue */
 	falcon_fini_special_buffer(efx, &channel->eventq);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 74e934c..e65d661 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -322,7 +322,6 @@ enum efx_rx_alloc_method {
  * queue.
  *
  * @efx: Associated Efx NIC
- * @evqnum: Event queue number
  * @channel: Channel instance number
  * @used_flags: Channel is used by net driver
  * @enabled: Channel enabled indicator
@@ -353,7 +352,6 @@ enum efx_rx_alloc_method {
  */
 struct efx_channel {
 	struct efx_nic *efx;
-	int evqnum;
 	int channel;
 	int used_flags;
 	bool enabled;
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

