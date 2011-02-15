From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 5/5] sfc: Add TX queues for high-priority
 traffic
Date: Tue, 15 Feb 2011 20:15:08 +0000
Message-ID: <1297800908.2584.20.camel@bwh-desktop>
References: <1297800733.2584.15.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:26620 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755639Ab1BOUPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Feb 2011 15:15:11 -0500
In-Reply-To: <1297800733.2584.15.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement the ndo_setup_tc() operation with 2 traffic classes.

Current Solarstorm controllers do not implement TX queue priority, but
they do allow queues to be 'paced' with an enforced delay between
packets.  Paced and unpaced queues are scheduled in round-robin within
two separate hardware bins (paced queues with a large delay may be
placed into a third bin temporarily, but we won't use that).  If there
are queues in both bins, the TX scheduler will alternate between them.

If we make high-priority queues unpaced and best-effort queues paced,
and high-priority queues are mostly empty, a single high-priority queue
can then instantly take 50% of the packet rate regardless of how many
of the best-effort queues have descriptors outstanding.

We do not actually want an enforced delay between packets on best-
effort queues, so we set the pace value to a reserved value that
actually results in a delay of 0.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |    8 ++-
 drivers/net/sfc/efx.h        |    1 +
 drivers/net/sfc/net_driver.h |   29 +++++++++++---
 drivers/net/sfc/nic.c        |   51 ++++++++++++++++++------
 drivers/net/sfc/regs.h       |    6 +++
 drivers/net/sfc/selftest.c   |    2 +-
 drivers/net/sfc/tx.c         |   87 +++++++++++++++++++++++++++++++++++++++--
 7 files changed, 156 insertions(+), 28 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 6189d30..d4e0425 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -673,7 +673,7 @@ static void efx_fini_channels(struct efx_nic *efx)
 
 		efx_for_each_channel_rx_queue(rx_queue, channel)
 			efx_fini_rx_queue(rx_queue);
-		efx_for_each_channel_tx_queue(tx_queue, channel)
+		efx_for_each_possible_channel_tx_queue(tx_queue, channel)
 			efx_fini_tx_queue(tx_queue);
 		efx_fini_eventq(channel);
 	}
@@ -689,7 +689,7 @@ static void efx_remove_channel(struct efx_channel *channel)
 
 	efx_for_each_channel_rx_queue(rx_queue, channel)
 		efx_remove_rx_queue(rx_queue);
-	efx_for_each_channel_tx_queue(tx_queue, channel)
+	efx_for_each_possible_channel_tx_queue(tx_queue, channel)
 		efx_remove_tx_queue(tx_queue);
 	efx_remove_eventq(channel);
 }
@@ -1836,6 +1836,7 @@ static const struct net_device_ops efx_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = efx_netpoll,
 #endif
+	.ndo_setup_tc		= efx_setup_tc,
 };
 
 static void efx_update_name(struct efx_nic *efx)
@@ -2386,7 +2387,8 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 	int i, rc;
 
 	/* Allocate and initialise a struct net_device and struct efx_nic */
-	net_dev = alloc_etherdev_mq(sizeof(*efx), EFX_MAX_CORE_TX_QUEUES);
+	net_dev = alloc_etherdev_mqs(sizeof(*efx), EFX_MAX_CORE_TX_QUEUES,
+				     EFX_MAX_RX_QUEUES);
 	if (!net_dev)
 		return -ENOMEM;
 	net_dev->features |= (type->offload_features | NETIF_F_SG |
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index 1162070..0cb198a 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -37,6 +37,7 @@ efx_hard_start_xmit(struct sk_buff *skb, struct net_device *net_dev);
 extern netdev_tx_t
 efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb);
 extern void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index);
+extern int efx_setup_tc(struct net_device *net_dev, u8 num_tc);
 
 /* RX */
 extern int efx_probe_rx_queue(struct efx_rx_queue *rx_queue);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 77b7ce4..96e22ad 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -63,10 +63,12 @@
 /* Checksum generation is a per-queue option in hardware, so each
  * queue visible to the networking core is backed by two hardware TX
  * queues. */
-#define EFX_MAX_CORE_TX_QUEUES	EFX_MAX_CHANNELS
-#define EFX_TXQ_TYPE_OFFLOAD	1
-#define EFX_TXQ_TYPES		2
-#define EFX_MAX_TX_QUEUES	(EFX_TXQ_TYPES * EFX_MAX_CORE_TX_QUEUES)
+#define EFX_MAX_TX_TC		2
+#define EFX_MAX_CORE_TX_QUEUES	(EFX_MAX_TX_TC * EFX_MAX_CHANNELS)
+#define EFX_TXQ_TYPE_OFFLOAD	1	/* flag */
+#define EFX_TXQ_TYPE_HIGHPRI	2	/* flag */
+#define EFX_TXQ_TYPES		4
+#define EFX_MAX_TX_QUEUES	(EFX_TXQ_TYPES * EFX_MAX_CHANNELS)
 
 /**
  * struct efx_special_buffer - An Efx special buffer
@@ -140,6 +142,7 @@ struct efx_tx_buffer {
  * @buffer: The software buffer ring
  * @txd: The hardware descriptor ring
  * @ptr_mask: The size of the ring minus 1.
+ * @initialised: Has hardware queue been initialised?
  * @flushed: Used when handling queue flushing
  * @read_count: Current read pointer.
  *	This is the number of buffers that have been removed from both rings.
@@ -182,6 +185,7 @@ struct efx_tx_queue {
 	struct efx_tx_buffer *buffer;
 	struct efx_special_buffer txd;
 	unsigned int ptr_mask;
+	bool initialised;
 	enum efx_flush_state flushed;
 
 	/* Members used mainly on the completion path */
@@ -377,7 +381,7 @@ struct efx_channel {
 	bool rx_pkt_csummed;
 
 	struct efx_rx_queue rx_queue;
-	struct efx_tx_queue tx_queue[2];
+	struct efx_tx_queue tx_queue[EFX_TXQ_TYPES];
 };
 
 enum efx_led_mode {
@@ -952,15 +956,28 @@ efx_channel_get_tx_queue(struct efx_channel *channel, unsigned type)
 	return &channel->tx_queue[type];
 }
 
+static inline bool efx_tx_queue_used(struct efx_tx_queue *tx_queue)
+{
+	return !(tx_queue->efx->net_dev->num_tc < 2 &&
+		 tx_queue->queue & EFX_TXQ_TYPE_HIGHPRI);
+}
+
 /* Iterate over all TX queues belonging to a channel */
 #define efx_for_each_channel_tx_queue(_tx_queue, _channel)		\
 	if (!efx_channel_has_tx_queues(_channel))			\
 		;							\
 	else								\
 		for (_tx_queue = (_channel)->tx_queue;			\
-		     _tx_queue < (_channel)->tx_queue + EFX_TXQ_TYPES;	\
+		     _tx_queue < (_channel)->tx_queue + EFX_TXQ_TYPES && \
+			     efx_tx_queue_used(_tx_queue);		\
 		     _tx_queue++)
 
+/* Iterate over all possible TX queues belonging to a channel */
+#define efx_for_each_possible_channel_tx_queue(_tx_queue, _channel)	\
+	for (_tx_queue = (_channel)->tx_queue;				\
+	     _tx_queue < (_channel)->tx_queue + EFX_TXQ_TYPES;		\
+	     _tx_queue++)
+
 static inline struct efx_rx_queue *
 efx_get_rx_queue(struct efx_nic *efx, unsigned index)
 {
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index da38659..1d0b8b6 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -445,8 +445,8 @@ int efx_nic_probe_tx(struct efx_tx_queue *tx_queue)
 
 void efx_nic_init_tx(struct efx_tx_queue *tx_queue)
 {
-	efx_oword_t tx_desc_ptr;
 	struct efx_nic *efx = tx_queue->efx;
+	efx_oword_t reg;
 
 	tx_queue->flushed = FLUSH_NONE;
 
@@ -454,7 +454,7 @@ void efx_nic_init_tx(struct efx_tx_queue *tx_queue)
 	efx_init_special_buffer(efx, &tx_queue->txd);
 
 	/* Push TX descriptor ring to card */
-	EFX_POPULATE_OWORD_10(tx_desc_ptr,
+	EFX_POPULATE_OWORD_10(reg,
 			      FRF_AZ_TX_DESCQ_EN, 1,
 			      FRF_AZ_TX_ISCSI_DDIG_EN, 0,
 			      FRF_AZ_TX_ISCSI_HDIG_EN, 0,
@@ -470,17 +470,15 @@ void efx_nic_init_tx(struct efx_tx_queue *tx_queue)
 
 	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0) {
 		int csum = tx_queue->queue & EFX_TXQ_TYPE_OFFLOAD;
-		EFX_SET_OWORD_FIELD(tx_desc_ptr, FRF_BZ_TX_IP_CHKSM_DIS, !csum);
-		EFX_SET_OWORD_FIELD(tx_desc_ptr, FRF_BZ_TX_TCP_CHKSM_DIS,
+		EFX_SET_OWORD_FIELD(reg, FRF_BZ_TX_IP_CHKSM_DIS, !csum);
+		EFX_SET_OWORD_FIELD(reg, FRF_BZ_TX_TCP_CHKSM_DIS,
 				    !csum);
 	}
 
-	efx_writeo_table(efx, &tx_desc_ptr, efx->type->txd_ptr_tbl_base,
+	efx_writeo_table(efx, &reg, efx->type->txd_ptr_tbl_base,
 			 tx_queue->queue);
 
 	if (efx_nic_rev(efx) < EFX_REV_FALCON_B0) {
-		efx_oword_t reg;
-
 		/* Only 128 bits in this register */
 		BUILD_BUG_ON(EFX_MAX_TX_QUEUES > 128);
 
@@ -491,6 +489,16 @@ void efx_nic_init_tx(struct efx_tx_queue *tx_queue)
 			set_bit_le(tx_queue->queue, (void *)&reg);
 		efx_writeo(efx, &reg, FR_AA_TX_CHKSM_CFG);
 	}
+
+	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0) {
+		EFX_POPULATE_OWORD_1(reg,
+				     FRF_BZ_TX_PACE,
+				     (tx_queue->queue & EFX_TXQ_TYPE_HIGHPRI) ?
+				     FFE_BZ_TX_PACE_OFF :
+				     FFE_BZ_TX_PACE_RESERVED);
+		efx_writeo_table(efx, &reg, FR_BZ_TX_PACE_TBL,
+				 tx_queue->queue);
+	}
 }
 
 static void efx_flush_tx_queue(struct efx_tx_queue *tx_queue)
@@ -1238,8 +1246,10 @@ int efx_nic_flush_queues(struct efx_nic *efx)
 
 	/* Flush all tx queues in parallel */
 	efx_for_each_channel(channel, efx) {
-		efx_for_each_channel_tx_queue(tx_queue, channel)
-			efx_flush_tx_queue(tx_queue);
+		efx_for_each_possible_channel_tx_queue(tx_queue, channel) {
+			if (tx_queue->initialised)
+				efx_flush_tx_queue(tx_queue);
+		}
 	}
 
 	/* The hardware supports four concurrent rx flushes, each of which may
@@ -1262,8 +1272,9 @@ int efx_nic_flush_queues(struct efx_nic *efx)
 					++rx_pending;
 				}
 			}
-			efx_for_each_channel_tx_queue(tx_queue, channel) {
-				if (tx_queue->flushed != FLUSH_DONE)
+			efx_for_each_possible_channel_tx_queue(tx_queue, channel) {
+				if (tx_queue->initialised &&
+				    tx_queue->flushed != FLUSH_DONE)
 					++tx_pending;
 			}
 		}
@@ -1278,8 +1289,9 @@ int efx_nic_flush_queues(struct efx_nic *efx)
 	/* Mark the queues as all flushed. We're going to return failure
 	 * leading to a reset, or fake up success anyway */
 	efx_for_each_channel(channel, efx) {
-		efx_for_each_channel_tx_queue(tx_queue, channel) {
-			if (tx_queue->flushed != FLUSH_DONE)
+		efx_for_each_possible_channel_tx_queue(tx_queue, channel) {
+			if (tx_queue->initialised &&
+			    tx_queue->flushed != FLUSH_DONE)
 				netif_err(efx, hw, efx->net_dev,
 					  "tx queue %d flush command timed out\n",
 					  tx_queue->queue);
@@ -1682,6 +1694,19 @@ void efx_nic_init_common(struct efx_nic *efx)
 	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0)
 		EFX_SET_OWORD_FIELD(temp, FRF_BZ_TX_FLUSH_MIN_LEN_EN, 1);
 	efx_writeo(efx, &temp, FR_AZ_TX_RESERVED);
+
+	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0) {
+		EFX_POPULATE_OWORD_4(temp,
+				     /* Default values */
+				     FRF_BZ_TX_PACE_SB_NOT_AF, 0x15,
+				     FRF_BZ_TX_PACE_SB_AF, 0xb,
+				     FRF_BZ_TX_PACE_FB_BASE, 0,
+				     /* Allow large pace values in the
+				      * fast bin. */
+				     FRF_BZ_TX_PACE_BIN_TH,
+				     FFE_BZ_TX_PACE_RESERVED);
+		efx_writeo(efx, &temp, FR_BZ_TX_PACE);
+	}
 }
 
 /* Register dump */
diff --git a/drivers/net/sfc/regs.h b/drivers/net/sfc/regs.h
index 96430ed..8227de6 100644
--- a/drivers/net/sfc/regs.h
+++ b/drivers/net/sfc/regs.h
@@ -2907,6 +2907,12 @@
 #define FRF_CZ_TMFT_SRC_MAC_HI_LBN 44
 #define FRF_CZ_TMFT_SRC_MAC_HI_WIDTH 16
 
+/* TX_PACE_TBL */
+/* Values >20 are documented as reserved, but will result in a queue going
+ * into the fast bin with a pace value of zero. */
+#define FFE_BZ_TX_PACE_OFF 0
+#define FFE_BZ_TX_PACE_RESERVED 21
+
 /* DRIVER_EV */
 /* Sub-fields of an RX flush completion event */
 #define FSF_AZ_DRIVER_EV_RX_FLUSH_FAIL_LBN 12
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 0ebfb99..f936892 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -644,7 +644,7 @@ static int efx_test_loopbacks(struct efx_nic *efx, struct efx_self_tests *tests,
 			goto out;
 		}
 
-		/* Test both types of TX queue */
+		/* Test all enabled types of TX queue */
 		efx_for_each_channel_tx_queue(tx_queue, channel) {
 			state->offload_csum = (tx_queue->queue &
 					       EFX_TXQ_TYPE_OFFLOAD);
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 7e463fb..1a51653 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -336,22 +336,89 @@ netdev_tx_t efx_hard_start_xmit(struct sk_buff *skb,
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_tx_queue *tx_queue;
+	unsigned index, type;
 
 	if (unlikely(efx->port_inhibited))
 		return NETDEV_TX_BUSY;
 
-	tx_queue = efx_get_tx_queue(efx, skb_get_queue_mapping(skb),
-				    skb->ip_summed == CHECKSUM_PARTIAL ?
-				    EFX_TXQ_TYPE_OFFLOAD : 0);
+	index = skb_get_queue_mapping(skb);
+	type = skb->ip_summed == CHECKSUM_PARTIAL ? EFX_TXQ_TYPE_OFFLOAD : 0;
+	if (index >= efx->n_tx_channels) {
+		index -= efx->n_tx_channels;
+		type |= EFX_TXQ_TYPE_HIGHPRI;
+	}
+	tx_queue = efx_get_tx_queue(efx, index, type);
 
 	return efx_enqueue_skb(tx_queue, skb);
 }
 
 void efx_init_tx_queue_core_txq(struct efx_tx_queue *tx_queue)
 {
+	struct efx_nic *efx = tx_queue->efx;
+
 	/* Must be inverse of queue lookup in efx_hard_start_xmit() */
-	tx_queue->core_txq = netdev_get_tx_queue(
-		tx_queue->efx->net_dev, tx_queue->queue / EFX_TXQ_TYPES);
+	tx_queue->core_txq =
+		netdev_get_tx_queue(efx->net_dev,
+				    tx_queue->queue / EFX_TXQ_TYPES +
+				    ((tx_queue->queue & EFX_TXQ_TYPE_HIGHPRI) ?
+				     efx->n_tx_channels : 0));
+}
+
+int efx_setup_tc(struct net_device *net_dev, u8 num_tc)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+	struct efx_channel *channel;
+	struct efx_tx_queue *tx_queue;
+	unsigned tc;
+	int rc;
+
+	if (efx_nic_rev(efx) < EFX_REV_FALCON_B0 || num_tc > EFX_MAX_TX_TC)
+		return -EINVAL;
+
+	if (num_tc == net_dev->num_tc)
+		return 0;
+
+	for (tc = 0; tc < num_tc; tc++) {
+		net_dev->tc_to_txq[tc].offset = tc * efx->n_tx_channels;
+		net_dev->tc_to_txq[tc].count = efx->n_tx_channels;
+	}
+
+	if (num_tc > net_dev->num_tc) {
+		/* Initialise high-priority queues as necessary */
+		efx_for_each_channel(channel, efx) {
+			efx_for_each_possible_channel_tx_queue(tx_queue,
+							       channel) {
+				if (!(tx_queue->queue & EFX_TXQ_TYPE_HIGHPRI))
+					continue;
+				if (!tx_queue->buffer) {
+					rc = efx_probe_tx_queue(tx_queue);
+					if (rc)
+						return rc;
+				}
+				if (!tx_queue->initialised)
+					efx_init_tx_queue(tx_queue);
+				efx_init_tx_queue_core_txq(tx_queue);
+			}
+		}
+	} else {
+		/* Reduce number of classes before number of queues */
+		net_dev->num_tc = num_tc;
+	}
+
+	rc = netif_set_real_num_tx_queues(net_dev,
+					  max_t(int, num_tc, 1) *
+					  efx->n_tx_channels);
+	if (rc)
+		return rc;
+
+	/* Do not destroy high-priority queues when they become
+	 * unused.  We would have to flush them first, and it is
+	 * fairly difficult to flush a subset of TX queues.  Leave
+	 * it to efx_fini_channels().
+	 */
+
+	net_dev->num_tc = num_tc;
+	return 0;
 }
 
 void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)
@@ -437,6 +504,8 @@ void efx_init_tx_queue(struct efx_tx_queue *tx_queue)
 
 	/* Set up TX descriptor ring */
 	efx_nic_init_tx(tx_queue);
+
+	tx_queue->initialised = true;
 }
 
 void efx_release_tx_buffers(struct efx_tx_queue *tx_queue)
@@ -459,9 +528,14 @@ void efx_release_tx_buffers(struct efx_tx_queue *tx_queue)
 
 void efx_fini_tx_queue(struct efx_tx_queue *tx_queue)
 {
+	if (!tx_queue->initialised)
+		return;
+
 	netif_dbg(tx_queue->efx, drv, tx_queue->efx->net_dev,
 		  "shutting down TX queue %d\n", tx_queue->queue);
 
+	tx_queue->initialised = false;
+
 	/* Flush TX queue, remove descriptor ring */
 	efx_nic_fini_tx(tx_queue);
 
@@ -473,6 +547,9 @@ void efx_fini_tx_queue(struct efx_tx_queue *tx_queue)
 
 void efx_remove_tx_queue(struct efx_tx_queue *tx_queue)
 {
+	if (!tx_queue->buffer)
+		return;
+
 	netif_dbg(tx_queue->efx, drv, tx_queue->efx->net_dev,
 		  "destroying TX queue %d\n", tx_queue->queue);
 	efx_nic_remove_tx(tx_queue);
-- 
1.7.3.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

