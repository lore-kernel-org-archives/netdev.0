From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 35/52] sfc: Remove some unreachable error paths
Date: Mon, 1 Sep 2008 12:48:46 +0100
Message-ID: <20080901114845.GC7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:59380 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758250AbYIALst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:48:49 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some functions return an error code which is always 0.  Change their
return types to void and simplify their callers accordingly.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c     |   76 ++++++++++----------------------------------
 drivers/net/sfc/efx.h     |    2 +-
 drivers/net/sfc/ethtool.c |    8 ++--
 drivers/net/sfc/falcon.c  |   30 ++++-------------
 drivers/net/sfc/falcon.h  |    6 ++--
 drivers/net/sfc/rx.c      |    4 +-
 drivers/net/sfc/rx.h      |    2 +-
 drivers/net/sfc/tx.c      |    4 +-
 drivers/net/sfc/tx.h      |    2 +-
 9 files changed, 39 insertions(+), 95 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index c41035a..f226dcf 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -282,13 +282,13 @@ static int efx_probe_eventq(struct efx_channel *channel)
 }
 
 /* Prepare channel's event queue */
-static int efx_init_eventq(struct efx_channel *channel)
+static void efx_init_eventq(struct efx_channel *channel)
 {
 	EFX_LOG(channel->efx, "chan %d init event queue\n", channel->channel);
 
 	channel->eventq_read_ptr = 0;
 
-	return falcon_init_eventq(channel);
+	falcon_init_eventq(channel);
 }
 
 static void efx_fini_eventq(struct efx_channel *channel)
@@ -354,12 +354,11 @@ static int efx_probe_channel(struct efx_channel *channel)
  * to propagate configuration changes (mtu, checksum offload), or
  * to clear hardware error conditions
  */
-static int efx_init_channels(struct efx_nic *efx)
+static void efx_init_channels(struct efx_nic *efx)
 {
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
 	struct efx_channel *channel;
-	int rc = 0;
 
 	/* Calculate the rx buffer allocation parameters required to
 	 * support the current MTU, including padding for header
@@ -374,36 +373,20 @@ static int efx_init_channels(struct efx_nic *efx)
 	efx_for_each_channel(channel, efx) {
 		EFX_LOG(channel->efx, "init chan %d\n", channel->channel);
 
-		rc = efx_init_eventq(channel);
-		if (rc)
-			goto err;
+		efx_init_eventq(channel);
 
-		efx_for_each_channel_tx_queue(tx_queue, channel) {
-			rc = efx_init_tx_queue(tx_queue);
-			if (rc)
-				goto err;
-		}
+		efx_for_each_channel_tx_queue(tx_queue, channel)
+			efx_init_tx_queue(tx_queue);
 
 		/* The rx buffer allocation strategy is MTU dependent */
 		efx_rx_strategy(channel);
 
-		efx_for_each_channel_rx_queue(rx_queue, channel) {
-			rc = efx_init_rx_queue(rx_queue);
-			if (rc)
-				goto err;
-		}
+		efx_for_each_channel_rx_queue(rx_queue, channel)
+			efx_init_rx_queue(rx_queue);
 
 		WARN_ON(channel->rx_pkt != NULL);
 		efx_rx_strategy(channel);
 	}
-
-	return 0;
-
- err:
-	EFX_ERR(efx, "failed to initialise channel %d\n",
-		channel ? channel->channel : -1);
-	efx_fini_channels(efx);
-	return rc;
 }
 
 /* This enables event queue processing and packet transmission.
@@ -1121,24 +1104,16 @@ static void efx_remove_all(struct efx_nic *efx)
 }
 
 /* A convinience function to safely flush all the queues */
-int efx_flush_queues(struct efx_nic *efx)
+void efx_flush_queues(struct efx_nic *efx)
 {
-	int rc;
-
 	EFX_ASSERT_RESET_SERIALISED(efx);
 
 	efx_stop_all(efx);
 
 	efx_fini_channels(efx);
-	rc = efx_init_channels(efx);
-	if (rc) {
-		efx_schedule_reset(efx, RESET_TYPE_DISABLE);
-		return rc;
-	}
+	efx_init_channels(efx);
 
 	efx_start_all(efx);
-
-	return 0;
 }
 
 /**************************************************************************
@@ -1311,7 +1286,6 @@ static int efx_net_open(struct net_device *net_dev)
 static int efx_net_stop(struct net_device *net_dev)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
-	int rc;
 
 	EFX_LOG(efx, "closing %s on CPU %d\n", net_dev->name,
 		raw_smp_processor_id());
@@ -1319,9 +1293,7 @@ static int efx_net_stop(struct net_device *net_dev)
 	/* Stop the device and flush all the channels */
 	efx_stop_all(efx);
 	efx_fini_channels(efx);
-	rc = efx_init_channels(efx);
-	if (rc)
-		efx_schedule_reset(efx, RESET_TYPE_DISABLE);
+	efx_init_channels(efx);
 
 	return 0;
 }
@@ -1404,16 +1376,10 @@ static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
 
 	efx_fini_channels(efx);
 	net_dev->mtu = new_mtu;
-	rc = efx_init_channels(efx);
-	if (rc)
-		goto fail;
+	efx_init_channels(efx);
 
 	efx_start_all(efx);
 	return rc;
-
- fail:
-	efx_schedule_reset(efx, RESET_TYPE_DISABLE);
-	return rc;
 }
 
 static int efx_set_mac_address(struct net_device *net_dev, void *data)
@@ -1588,22 +1554,19 @@ static int efx_reset_up(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 {
 	int rc;
 
-	rc = efx_init_channels(efx);
-	if (rc)
-		goto fail1;
+	efx_init_channels(efx);
 
 	/* Restore MAC and PHY settings. */
 	rc = falcon_xmac_set_settings(efx, ecmd);
 	if (rc) {
 		EFX_ERR(efx, "could not restore PHY settings\n");
-		goto fail2;
+		goto fail;
 	}
 
 	return 0;
 
- fail2:
+ fail:
 	efx_fini_channels(efx);
- fail1:
 	return rc;
 }
 
@@ -2023,19 +1986,16 @@ static int efx_pci_probe_main(struct efx_nic *efx)
 		goto fail5;
 	}
 
-	rc = efx_init_channels(efx);
-	if (rc)
-		goto fail6;
+	efx_init_channels(efx);
 
 	rc = falcon_init_interrupt(efx);
 	if (rc)
-		goto fail7;
+		goto fail6;
 
 	return 0;
 
- fail7:
-	efx_fini_channels(efx);
  fail6:
+	efx_fini_channels(efx);
 	efx_fini_port(efx);
  fail5:
  fail4:
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index 29a1c58..9a8c283 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -33,7 +33,7 @@ extern void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue, int delay);
 
 /* Channels */
 extern void efx_process_channel_now(struct efx_channel *channel);
-extern int efx_flush_queues(struct efx_nic *efx);
+extern void efx_flush_queues(struct efx_nic *efx);
 
 /* Ports */
 extern void efx_reconfigure_port(struct efx_nic *efx);
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 906d18a..7989416 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -503,10 +503,10 @@ static void efx_ethtool_self_test(struct net_device *net_dev,
 	if (offline) {
 		/* Stop the kernel from sending packets during the test. */
 		efx_stop_queue(efx);
-		rc = efx_flush_queues(efx);
-		if (!rc)
-			rc = efx_offline_test(efx, &efx_tests,
-					      efx->loopback_modes);
+		efx_flush_queues(efx);
+
+		rc = efx_offline_test(efx, &efx_tests,
+				      efx->loopback_modes);
 		efx_wake_queue(efx);
 	}
 
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 96cb5d0..e66d6cf 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -242,7 +242,7 @@ static struct i2c_algo_bit_data falcon_i2c_bit_operations = {
  * falcon_alloc_special_buffer()) in Falcon's buffer table, allowing
  * it to be used for event queues, descriptor rings etc.
  */
-static int
+static void
 falcon_init_special_buffer(struct efx_nic *efx,
 			   struct efx_special_buffer *buffer)
 {
@@ -266,8 +266,6 @@ falcon_init_special_buffer(struct efx_nic *efx,
 				     BUF_OWNER_ID_FBUF, 0);
 		falcon_write_sram(efx, &buf_desc, index);
 	}
-
-	return 0;
 }
 
 /* Unmaps a buffer from Falcon and clears the buffer table entries */
@@ -449,16 +447,13 @@ int falcon_probe_tx(struct efx_tx_queue *tx_queue)
 					   sizeof(efx_qword_t));
 }
 
-int falcon_init_tx(struct efx_tx_queue *tx_queue)
+void falcon_init_tx(struct efx_tx_queue *tx_queue)
 {
 	efx_oword_t tx_desc_ptr;
 	struct efx_nic *efx = tx_queue->efx;
-	int rc;
 
 	/* Pin TX descriptor ring */
-	rc = falcon_init_special_buffer(efx, &tx_queue->txd);
-	if (rc)
-		return rc;
+	falcon_init_special_buffer(efx, &tx_queue->txd);
 
 	/* Push TX descriptor ring to card */
 	EFX_POPULATE_OWORD_10(tx_desc_ptr,
@@ -495,8 +490,6 @@ int falcon_init_tx(struct efx_tx_queue *tx_queue)
 			set_bit_le(tx_queue->queue, (void *)&reg);
 		falcon_write(efx, &reg, TX_CHKSM_CFG_REG_KER_A1);
 	}
-
-	return 0;
 }
 
 static int falcon_flush_tx_queue(struct efx_tx_queue *tx_queue)
@@ -639,11 +632,10 @@ int falcon_probe_rx(struct efx_rx_queue *rx_queue)
 					   sizeof(efx_qword_t));
 }
 
-int falcon_init_rx(struct efx_rx_queue *rx_queue)
+void falcon_init_rx(struct efx_rx_queue *rx_queue)
 {
 	efx_oword_t rx_desc_ptr;
 	struct efx_nic *efx = rx_queue->efx;
-	int rc;
 	bool is_b0 = falcon_rev(efx) >= FALCON_REV_B0;
 	bool iscsi_digest_en = is_b0;
 
@@ -652,9 +644,7 @@ int falcon_init_rx(struct efx_rx_queue *rx_queue)
 		rx_queue->rxd.index + rx_queue->rxd.entries - 1);
 
 	/* Pin RX descriptor ring */
-	rc = falcon_init_special_buffer(efx, &rx_queue->rxd);
-	if (rc)
-		return rc;
+	falcon_init_special_buffer(efx, &rx_queue->rxd);
 
 	/* Push RX descriptor ring to card */
 	EFX_POPULATE_OWORD_10(rx_desc_ptr,
@@ -671,7 +661,6 @@ int falcon_init_rx(struct efx_rx_queue *rx_queue)
 			      RX_DESCQ_EN, 1);
 	falcon_write_table(efx, &rx_desc_ptr, efx->type->rxd_ptr_tbl_base,
 			   rx_queue->queue);
-	return 0;
 }
 
 static int falcon_flush_rx_queue(struct efx_rx_queue *rx_queue)
@@ -1205,20 +1194,17 @@ int falcon_probe_eventq(struct efx_channel *channel)
 	return falcon_alloc_special_buffer(efx, &channel->eventq, evq_size);
 }
 
-int falcon_init_eventq(struct efx_channel *channel)
+void falcon_init_eventq(struct efx_channel *channel)
 {
 	efx_oword_t evq_ptr;
 	struct efx_nic *efx = channel->efx;
-	int rc;
 
 	EFX_LOG(efx, "channel %d event queue in special buffers %d-%d\n",
 		channel->channel, channel->eventq.index,
 		channel->eventq.index + channel->eventq.entries - 1);
 
 	/* Pin event queue buffer */
-	rc = falcon_init_special_buffer(efx, &channel->eventq);
-	if (rc)
-		return rc;
+	falcon_init_special_buffer(efx, &channel->eventq);
 
 	/* Fill event queue with all ones (i.e. empty events) */
 	memset(channel->eventq.addr, 0xff, channel->eventq.len);
@@ -1232,8 +1218,6 @@ int falcon_init_eventq(struct efx_channel *channel)
 			   channel->channel);
 
 	falcon_set_int_moderation(channel);
-
-	return 0;
 }
 
 void falcon_fini_eventq(struct efx_channel *channel)
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index 4cf05d0..41b388b 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -40,21 +40,21 @@ extern struct efx_nic_type falcon_b_nic_type;
 
 /* TX data path */
 extern int falcon_probe_tx(struct efx_tx_queue *tx_queue);
-extern int falcon_init_tx(struct efx_tx_queue *tx_queue);
+extern void falcon_init_tx(struct efx_tx_queue *tx_queue);
 extern void falcon_fini_tx(struct efx_tx_queue *tx_queue);
 extern void falcon_remove_tx(struct efx_tx_queue *tx_queue);
 extern void falcon_push_buffers(struct efx_tx_queue *tx_queue);
 
 /* RX data path */
 extern int falcon_probe_rx(struct efx_rx_queue *rx_queue);
-extern int falcon_init_rx(struct efx_rx_queue *rx_queue);
+extern void falcon_init_rx(struct efx_rx_queue *rx_queue);
 extern void falcon_fini_rx(struct efx_rx_queue *rx_queue);
 extern void falcon_remove_rx(struct efx_rx_queue *rx_queue);
 extern void falcon_notify_rx_desc(struct efx_rx_queue *rx_queue);
 
 /* Event data path */
 extern int falcon_probe_eventq(struct efx_channel *channel);
-extern int falcon_init_eventq(struct efx_channel *channel);
+extern void falcon_init_eventq(struct efx_channel *channel);
 extern void falcon_fini_eventq(struct efx_channel *channel);
 extern void falcon_remove_eventq(struct efx_channel *channel);
 extern int falcon_process_eventq(struct efx_channel *channel, int rx_quota);
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 7d2dc20..0f805da 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -800,7 +800,7 @@ int efx_probe_rx_queue(struct efx_rx_queue *rx_queue)
 	return rc;
 }
 
-int efx_init_rx_queue(struct efx_rx_queue *rx_queue)
+void efx_init_rx_queue(struct efx_rx_queue *rx_queue)
 {
 	struct efx_nic *efx = rx_queue->efx;
 	unsigned int max_fill, trigger, limit;
@@ -824,7 +824,7 @@ int efx_init_rx_queue(struct efx_rx_queue *rx_queue)
 	rx_queue->fast_fill_limit = limit;
 
 	/* Set up RX descriptor ring */
-	return falcon_init_rx(rx_queue);
+	falcon_init_rx(rx_queue);
 }
 
 void efx_fini_rx_queue(struct efx_rx_queue *rx_queue)
diff --git a/drivers/net/sfc/rx.h b/drivers/net/sfc/rx.h
index 187b110..0e88a9d 100644
--- a/drivers/net/sfc/rx.h
+++ b/drivers/net/sfc/rx.h
@@ -14,7 +14,7 @@
 
 int efx_probe_rx_queue(struct efx_rx_queue *rx_queue);
 void efx_remove_rx_queue(struct efx_rx_queue *rx_queue);
-int efx_init_rx_queue(struct efx_rx_queue *rx_queue);
+void efx_init_rx_queue(struct efx_rx_queue *rx_queue);
 void efx_fini_rx_queue(struct efx_rx_queue *rx_queue);
 
 int efx_lro_init(struct net_lro_mgr *lro_mgr, struct efx_nic *efx);
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index a3a3edd..cdee7c2 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -443,7 +443,7 @@ int efx_probe_tx_queue(struct efx_tx_queue *tx_queue)
 	return rc;
 }
 
-int efx_init_tx_queue(struct efx_tx_queue *tx_queue)
+void efx_init_tx_queue(struct efx_tx_queue *tx_queue)
 {
 	EFX_LOG(tx_queue->efx, "initialising TX queue %d\n", tx_queue->queue);
 
@@ -454,7 +454,7 @@ int efx_init_tx_queue(struct efx_tx_queue *tx_queue)
 	BUG_ON(tx_queue->stopped);
 
 	/* Set up TX descriptor ring */
-	return falcon_init_tx(tx_queue);
+	falcon_init_tx(tx_queue);
 }
 
 void efx_release_tx_buffers(struct efx_tx_queue *tx_queue)
diff --git a/drivers/net/sfc/tx.h b/drivers/net/sfc/tx.h
index 1526a73..5e1cc23 100644
--- a/drivers/net/sfc/tx.h
+++ b/drivers/net/sfc/tx.h
@@ -15,7 +15,7 @@
 
 int efx_probe_tx_queue(struct efx_tx_queue *tx_queue);
 void efx_remove_tx_queue(struct efx_tx_queue *tx_queue);
-int efx_init_tx_queue(struct efx_tx_queue *tx_queue);
+void efx_init_tx_queue(struct efx_tx_queue *tx_queue);
 void efx_fini_tx_queue(struct efx_tx_queue *tx_queue);
 
 int efx_hard_start_xmit(struct sk_buff *skb, struct net_device *net_dev);
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

