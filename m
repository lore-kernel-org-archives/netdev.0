From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 04/52] sfc: Use separate hardware TX queues to select checksum generation
Date: Mon, 1 Sep 2008 12:44:59 +0100
Message-ID: <20080901114458.GX7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:58533 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753560AbYIALpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:45:03 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Checksum generation is an attribute of our hardware TX queues, not TX
descriptors.  We previously used a single queue and turned checksum
generation on or off as requested through ethtool.  However, this can
result in regenerating checksums in raw packets that should not be
modified.  We now create 2 hardware TX queues with checksum generation
on or off.  They are presented to the net core as one queue since it
does not know how to select between them.

The self-test verifies that a bad checksum is unaltered on the queue
with checksum generation off.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   25 +++++++---------------
 drivers/net/sfc/ethtool.c    |   45 +----------------------------------------
 drivers/net/sfc/falcon.c     |   11 +++++----
 drivers/net/sfc/net_driver.h |   21 ++++++++-----------
 drivers/net/sfc/selftest.c   |   11 ++++++++-
 drivers/net/sfc/selftest.h   |    4 +-
 drivers/net/sfc/tx.c         |   23 +++++++++++----------
 7 files changed, 48 insertions(+), 92 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 4253980..2a23005 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -923,22 +923,13 @@ static void efx_select_used(struct efx_nic *efx)
 	struct efx_rx_queue *rx_queue;
 	int i;
 
-	/* TX queues.  One per port per channel with TX capability
-	 * (more than one per port won't work on Linux, due to out
-	 *  of order issues... but will be fine on Solaris)
-	 */
-	tx_queue = &efx->tx_queue[0];
-
-	/* Perform this for each channel with TX capabilities.
-	 * At the moment, we only support a single TX queue
-	 */
-	tx_queue->used = 1;
-	if ((!EFX_INT_MODE_USE_MSI(efx)) && separate_tx_and_rx_channels)
-		tx_queue->channel = &efx->channel[1];
-	else
-		tx_queue->channel = &efx->channel[0];
-	tx_queue->channel->used_flags |= EFX_USED_BY_TX;
-	tx_queue++;
+	efx_for_each_tx_queue(tx_queue, efx) {
+		if (!EFX_INT_MODE_USE_MSI(efx) && separate_tx_and_rx_channels)
+			tx_queue->channel = &efx->channel[1];
+		else
+			tx_queue->channel = &efx->channel[0];
+		tx_queue->channel->used_flags |= EFX_USED_BY_TX;
+	}
 
 	/* RX queues.  Each has a dedicated channel. */
 	for (i = 0; i < EFX_MAX_RX_QUEUES; i++) {
@@ -1881,7 +1872,7 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 		channel->evqnum = i;
 		channel->work_pending = 0;
 	}
-	for (i = 0; i < EFX_MAX_TX_QUEUES; i++) {
+	for (i = 0; i < EFX_TX_QUEUE_COUNT; i++) {
 		tx_queue = &efx->tx_queue[i];
 		tx_queue->efx = efx;
 		tx_queue->queue = i;
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 8a15be6..ccd82f1 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -32,8 +32,6 @@ const char *efx_loopback_mode_names[] = {
 	[LOOPBACK_NETWORK]	= "NETWORK",
 };
 
-static int efx_ethtool_set_tx_csum(struct net_device *net_dev, u32 enable);
-
 struct ethtool_string {
 	char name[ETH_GSTRING_LEN];
 };
@@ -442,45 +440,6 @@ static void efx_ethtool_get_stats(struct net_device *net_dev,
 	}
 }
 
-static int efx_ethtool_set_tso(struct net_device *net_dev, u32 enable)
-{
-	int rc;
-
-	/* Our TSO requires TX checksumming, so force TX checksumming
-	 * on when TSO is enabled.
-	 */
-	if (enable) {
-		rc = efx_ethtool_set_tx_csum(net_dev, 1);
-		if (rc)
-			return rc;
-	}
-
-	return ethtool_op_set_tso(net_dev, enable);
-}
-
-static int efx_ethtool_set_tx_csum(struct net_device *net_dev, u32 enable)
-{
-	struct efx_nic *efx = netdev_priv(net_dev);
-	int rc;
-
-	rc = ethtool_op_set_tx_csum(net_dev, enable);
-	if (rc)
-		return rc;
-
-	efx_flush_queues(efx);
-
-	/* Our TSO requires TX checksumming, so disable TSO when
-	 * checksumming is disabled
-	 */
-	if (!enable) {
-		rc = efx_ethtool_set_tso(net_dev, 0);
-		if (rc)
-			return rc;
-	}
-
-	return 0;
-}
-
 static int efx_ethtool_set_rx_csum(struct net_device *net_dev, u32 enable)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
@@ -701,11 +660,11 @@ struct ethtool_ops efx_ethtool_ops = {
 	.get_rx_csum		= efx_ethtool_get_rx_csum,
 	.set_rx_csum		= efx_ethtool_set_rx_csum,
 	.get_tx_csum		= ethtool_op_get_tx_csum,
-	.set_tx_csum		= efx_ethtool_set_tx_csum,
+	.set_tx_csum		= ethtool_op_set_tx_csum,
 	.get_sg			= ethtool_op_get_sg,
 	.set_sg			= ethtool_op_set_sg,
 	.get_tso		= ethtool_op_get_tso,
-	.set_tso		= efx_ethtool_set_tso,
+	.set_tso		= ethtool_op_set_tso,
 	.get_flags		= ethtool_op_get_flags,
 	.set_flags		= ethtool_op_set_flags,
 	.self_test_count	= efx_ethtool_self_test_count,
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index c7aa2f6..b73f1ea 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -474,9 +474,9 @@ int falcon_init_tx(struct efx_tx_queue *tx_queue)
 			      TX_NON_IP_DROP_DIS_B0, 1);
 
 	if (falcon_rev(efx) >= FALCON_REV_B0) {
-		int csum = !(efx->net_dev->features & NETIF_F_IP_CSUM);
-		EFX_SET_OWORD_FIELD(tx_desc_ptr, TX_IP_CHKSM_DIS_B0, csum);
-		EFX_SET_OWORD_FIELD(tx_desc_ptr, TX_TCP_CHKSM_DIS_B0, csum);
+		int csum = tx_queue->queue == EFX_TX_QUEUE_OFFLOAD_CSUM;
+		EFX_SET_OWORD_FIELD(tx_desc_ptr, TX_IP_CHKSM_DIS_B0, !csum);
+		EFX_SET_OWORD_FIELD(tx_desc_ptr, TX_TCP_CHKSM_DIS_B0, !csum);
 	}
 
 	falcon_write_table(efx, &tx_desc_ptr, efx->type->txd_ptr_tbl_base,
@@ -485,10 +485,11 @@ int falcon_init_tx(struct efx_tx_queue *tx_queue)
 	if (falcon_rev(efx) < FALCON_REV_B0) {
 		efx_oword_t reg;
 
-		BUG_ON(tx_queue->queue >= 128); /* HW limit */
+		/* Only 128 bits in this register */
+		BUILD_BUG_ON(EFX_TX_QUEUE_COUNT >= 128);
 
 		falcon_read(efx, &reg, TX_CHKSM_CFG_REG_KER_A1);
-		if (efx->net_dev->features & NETIF_F_IP_CSUM)
+		if (tx_queue->queue == EFX_TX_QUEUE_OFFLOAD_CSUM)
 			clear_bit_le(tx_queue->queue, (void *)&reg);
 		else
 			set_bit_le(tx_queue->queue, (void *)&reg);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 628f25e..f539e2e 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -88,9 +88,12 @@ do {if (net_ratelimit()) EFX_LOG(efx, fmt, ##args); } while (0)
  **************************************************************************/
 
 #define EFX_MAX_CHANNELS 32
-#define EFX_MAX_TX_QUEUES 1
 #define EFX_MAX_RX_QUEUES EFX_MAX_CHANNELS
 
+#define EFX_TX_QUEUE_OFFLOAD_CSUM	0
+#define EFX_TX_QUEUE_NO_CSUM		1
+#define EFX_TX_QUEUE_COUNT		2
+
 /**
  * struct efx_special_buffer - An Efx special buffer
  * @addr: CPU base address of the buffer
@@ -156,7 +159,6 @@ struct efx_tx_buffer {
  *
  * @efx: The associated Efx NIC
  * @queue: DMA queue number
- * @used: Queue is used by net driver
  * @channel: The associated channel
  * @buffer: The software buffer ring
  * @txd: The hardware descriptor ring
@@ -188,7 +190,6 @@ struct efx_tx_queue {
 	/* Members which don't change on the fast path */
 	struct efx_nic *efx ____cacheline_aligned_in_smp;
 	int queue;
-	int used;
 	struct efx_channel *channel;
 	struct efx_nic *nic;
 	struct efx_tx_buffer *buffer;
@@ -699,7 +700,7 @@ struct efx_nic {
 	enum nic_state state;
 	enum reset_type reset_pending;
 
-	struct efx_tx_queue tx_queue[EFX_MAX_TX_QUEUES];
+	struct efx_tx_queue tx_queue[EFX_TX_QUEUE_COUNT];
 	struct efx_rx_queue rx_queue[EFX_MAX_RX_QUEUES];
 	struct efx_channel channel[EFX_MAX_CHANNELS];
 
@@ -840,19 +841,15 @@ struct efx_nic_type {
 /* Iterate over all used TX queues */
 #define efx_for_each_tx_queue(_tx_queue, _efx)				\
 	for (_tx_queue = &_efx->tx_queue[0];				\
-	     _tx_queue < &_efx->tx_queue[EFX_MAX_TX_QUEUES];		\
-	     _tx_queue++)						\
-		if (!_tx_queue->used)					\
-			continue;					\
-		else
+	     _tx_queue < &_efx->tx_queue[EFX_TX_QUEUE_COUNT];		\
+	     _tx_queue++)
 
 /* Iterate over all TX queues belonging to a channel */
 #define efx_for_each_channel_tx_queue(_tx_queue, _channel)		\
 	for (_tx_queue = &_channel->efx->tx_queue[0];			\
-	     _tx_queue < &_channel->efx->tx_queue[EFX_MAX_TX_QUEUES];	\
+	     _tx_queue < &_channel->efx->tx_queue[EFX_TX_QUEUE_COUNT];	\
 	     _tx_queue++)						\
-		if ((!_tx_queue->used) ||				\
-		    (_tx_queue->channel != _channel))			\
+		if (_tx_queue->channel != _channel)			\
 			continue;					\
 		else
 
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 3b2de9f..0a47786 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -63,6 +63,10 @@ struct efx_selftest_state {
 	int flush;
 	int packet_count;
 	struct sk_buff **skbs;
+
+	/* Checksums are being offloaded */
+	int offload_csum;
+
 	atomic_t rx_good;
 	atomic_t rx_bad;
 	struct efx_loopback_payload payload;
@@ -292,8 +296,9 @@ void efx_loopback_rx_packet(struct efx_nic *efx,
 	
 	received = (struct efx_loopback_payload *) buf_ptr;
 	received->ip.saddr = payload->ip.saddr;
-	received->ip.check = payload->ip.check;
-	
+	if (state->offload_csum)
+		received->ip.check = payload->ip.check;
+
 	/* Check that header exists */
 	if (pkt_len < sizeof(received->header)) {
 		EFX_ERR(efx, "saw runt RX packet (length %d) in %s loopback "
@@ -634,6 +639,8 @@ static int efx_test_loopbacks(struct efx_nic *efx,
 
 		/* Test every TX queue */
 		efx_for_each_tx_queue(tx_queue, efx) {
+			state->offload_csum = (tx_queue->queue ==
+					       EFX_TX_QUEUE_OFFLOAD_CSUM);
 			rc |= efx_test_loopback(tx_queue,
 						&tests->loopback[mode]);
 			if (rc)
diff --git a/drivers/net/sfc/selftest.h b/drivers/net/sfc/selftest.h
index f6999c2..cd59f00 100644
--- a/drivers/net/sfc/selftest.h
+++ b/drivers/net/sfc/selftest.h
@@ -18,8 +18,8 @@
  */
 
 struct efx_loopback_self_tests {
-	int tx_sent[EFX_MAX_TX_QUEUES];
-	int tx_done[EFX_MAX_TX_QUEUES];
+	int tx_sent[EFX_TX_QUEUE_COUNT];
+	int tx_done[EFX_TX_QUEUE_COUNT];
 	int rx_good;
 	int rx_bad;
 };
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 2a09101..e5e0bab 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -368,7 +368,14 @@ inline int efx_xmit(struct efx_nic *efx,
 int efx_hard_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
-	return efx_xmit(efx, &efx->tx_queue[0], skb);
+	struct efx_tx_queue *tx_queue;
+
+	if (likely(skb->ip_summed == CHECKSUM_PARTIAL))
+		tx_queue = &efx->tx_queue[EFX_TX_QUEUE_OFFLOAD_CSUM];
+	else
+		tx_queue = &efx->tx_queue[EFX_TX_QUEUE_NO_CSUM];
+
+	return efx_xmit(efx, tx_queue, skb);
 }
 
 void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)
@@ -412,26 +419,21 @@ int efx_probe_tx_queue(struct efx_tx_queue *tx_queue)
 	/* Allocate software ring */
 	txq_size = (efx->type->txd_ring_mask + 1) * sizeof(*tx_queue->buffer);
 	tx_queue->buffer = kzalloc(txq_size, GFP_KERNEL);
-	if (!tx_queue->buffer) {
-		rc = -ENOMEM;
-		goto fail1;
-	}
+	if (!tx_queue->buffer)
+		return -ENOMEM;
 	for (i = 0; i <= efx->type->txd_ring_mask; ++i)
 		tx_queue->buffer[i].continuation = 1;
 
 	/* Allocate hardware ring */
 	rc = falcon_probe_tx(tx_queue);
 	if (rc)
-		goto fail2;
+		goto fail;
 
 	return 0;
 
- fail2:
+ fail:
 	kfree(tx_queue->buffer);
 	tx_queue->buffer = NULL;
- fail1:
-	tx_queue->used = 0;
-
 	return rc;
 }
 
@@ -494,7 +496,6 @@ void efx_remove_tx_queue(struct efx_tx_queue *tx_queue)
 
 	kfree(tx_queue->buffer);
 	tx_queue->buffer = NULL;
-	tx_queue->used = 0;
 }
 
 
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

