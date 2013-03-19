From: Ben Hutchings <bhutchings@solarflare.com>
Subject: sfc fixes for stable
Date: Tue, 19 Mar 2013 15:38:01 +0000
Message-ID: <1363707481.3491.6.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-JoKlq4P+CI6IELemF1bE"
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>,
	scrum-linux <scrum-linux@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:37287 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932081Ab3CSPiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 11:38:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-JoKlq4P+CI6IELemF1bE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

David,

Please consider the attached patchsets for 3.0.y, 3.2.y, 3.4.y and 3.8.y
respectively.

They contain backports of the following fixes, respectively:

3.0             4017dbdc14af sfc: Fix loop condition for efx_filter_search() when !for_insert
3.0             a659b2a94d87 sfc: Fix Siena mac statistics on big endian platforms
3.0 3.2 3.4     3dca9d2dc285 sfc: Do not attempt to flush queues if DMA is disabled
3.0 3.2 3.4     bfeed902946a sfc: Convert firmware subtypes to native byte order in efx_mcdi_get_board_cfg()
        3.4     9724a8504c87 sfc: Add parentheses around use of bitfield macro arguments
        3.4     0a6e5008a9df sfc: Fix MCDI structure field lookup
3.0 3.2         a606f4325dca sfc: Disable flow control during flushes
3.0 3.2 3.4     d5e8cc6c946e sfc: Really disable flow control while flushing
3.0 3.2 3.4     525d9e824018 sfc: Work-around flush timeout when flushes have completed
3.0 3.2 3.4     c2f3b8e3a44b sfc: lock TX queues when calling netif_device_detach()
3.0 3.2 3.4     ebf98e797b4e sfc: Fix timekeeping in efx_mcdi_poll()
        3.4     d4f2cecce138 sfc: Disable VF queues during register self-test
        3.4     450783747f42 sfc: Avoid generating over-length MC_CMD_FLUSH_RX_QUEUES request
        3.4     ef492f11efed sfc: Correctly initialise reset_method in siena_test_chip()
            3.8 56567c6f8751 drivers/net/ethernet/sfc/ptp.c: adjust duplicate test
3.0 3.2 3.4 3.8 3a68f19d7afb sfc: Properly sync RX DMA buffer when it is not the last in the page
3.0 3.2 3.4 3.8 b590ace09d51 sfc: Fix efx_rx_buf_offset() in the presence of swiotlb
3.0 3.2 3.4 3.8 c73e787a8db9 sfc: Correct efx_rx_buffer::page_offset when EFX_PAGE_IP_ALIGN != 0
3.0 3.2 3.4 3.8 29c69a488264 sfc: Detach net device when stopping queues for reconfiguration
3.0 3.2 3.4 3.8 35205b211c8d sfc: Disable soft interrupt handling during efx_device_detach_sync()
3.0 3.2 3.4 3.8 fae8563b25f7 sfc: Only use TX push if a single descriptor is to be written

The last is not yet in Linus's tree but I assume you will ask him to
pull from net soon.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--=-JoKlq4P+CI6IELemF1bE
Content-Type: application/mbox; name="sfc_3.0.mbox"
Content-Disposition: attachment; filename="sfc_3.0.mbox"
Content-Transfer-Encoding: 7bit

>From 7b3a5b52371da30ff3d493bb977063d3781009af Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 24 Jun 2011 20:26:44 +0100
Subject: [PATCH 01/12] sfc: Fix loop condition for efx_filter_search() when
 !for_insert

[ Upstream commit 4017dbdc14af1903dc9fcba4d08b89c02325069d ]

efx_filter_remove_filter() fails to remove inserted filters in some cases.

For example:

  1. Two filters A and B have specifications that result in an initial
     hash collision.
  2. A is inserted first, followed by B.
  3. An attempt to remove B first succeeds, but if A is removed first
     a subsequent attempt to remove B fails.

When searching for an existing filter (!for_insert),
efx_filter_search() must always continue to the maximum search depth
for the given type rather than stopping at the first unused entry.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/filter.c |   41 ++++++++++++++++++++++++-----------------
 1 files changed, 24 insertions(+), 17 deletions(-)

diff --git a/drivers/net/sfc/filter.c b/drivers/net/sfc/filter.c
index 95a980f..08addc9 100644
--- a/drivers/net/sfc/filter.c
+++ b/drivers/net/sfc/filter.c
@@ -335,28 +335,35 @@ static int efx_filter_search(struct efx_filter_table *table,
 			     bool for_insert, int *depth_required)
 {
 	unsigned hash, incr, filter_idx, depth, depth_max;
-	struct efx_filter_spec *cmp;
 
 	hash = efx_filter_hash(key);
 	incr = efx_filter_increment(key);
-	depth_max = (spec->priority <= EFX_FILTER_PRI_HINT ?
-		     FILTER_CTL_SRCH_HINT_MAX : FILTER_CTL_SRCH_MAX);
-
-	for (depth = 1, filter_idx = hash & (table->size - 1);
-	     depth <= depth_max && test_bit(filter_idx, table->used_bitmap);
-	     ++depth) {
-		cmp = &table->spec[filter_idx];
-		if (efx_filter_equal(spec, cmp))
-			goto found;
+
+	filter_idx = hash & (table->size - 1);
+	depth = 1;
+	depth_max = (for_insert ?
+		     (spec->priority <= EFX_FILTER_PRI_HINT ?
+		      FILTER_CTL_SRCH_HINT_MAX : FILTER_CTL_SRCH_MAX) :
+		     table->search_depth[spec->type]);
+
+	for (;;) {
+		/* Return success if entry is used and matches this spec
+		 * or entry is unused and we are trying to insert.
+		 */
+		if (test_bit(filter_idx, table->used_bitmap) ?
+		    efx_filter_equal(spec, &table->spec[filter_idx]) :
+		    for_insert) {
+			*depth_required = depth;
+			return filter_idx;
+		}
+
+		/* Return failure if we reached the maximum search depth */
+		if (depth == depth_max)
+			return for_insert ? -EBUSY : -ENOENT;
+
 		filter_idx = (filter_idx + incr) & (table->size - 1);
+		++depth;
 	}
-	if (!for_insert)
-		return -ENOENT;
-	if (depth > depth_max)
-		return -EBUSY;
-found:
-	*depth_required = depth;
-	return filter_idx;
 }
 
 /* Construct/deconstruct external filter IDs */
-- 
1.7.7.6


>From d80db992a3537c0c71289f4a982f657c05bbe72c Mon Sep 17 00:00:00 2001
From: Steve Hodgson <shodgson@solarflare.com>
Date: Wed, 22 Jun 2011 12:11:33 +0100
Subject: [PATCH 02/12] sfc: Fix Siena mac statistics on big endian platforms

[ Upstream commit a659b2a94d87add999229ecd9f2f56817d5d737b ]

[bwh: Use __force in the one place it's needed]
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/siena.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index ceac1c9..407f50b 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -372,14 +372,13 @@ static void siena_remove_nic(struct efx_nic *efx)
 	efx->nic_data = NULL;
 }
 
-#define STATS_GENERATION_INVALID ((u64)(-1))
+#define STATS_GENERATION_INVALID ((__force __le64)(-1))
 
 static int siena_try_update_nic_stats(struct efx_nic *efx)
 {
-	u64 *dma_stats;
+	__le64 *dma_stats;
 	struct efx_mac_stats *mac_stats;
-	u64 generation_start;
-	u64 generation_end;
+	__le64 generation_start, generation_end;
 
 	mac_stats = &efx->mac_stats;
 	dma_stats = (u64 *)efx->stats_buffer.addr;
@@ -390,7 +389,7 @@ static int siena_try_update_nic_stats(struct efx_nic *efx)
 	rmb();
 
 #define MAC_STAT(M, D) \
-	mac_stats->M = dma_stats[MC_CMD_MAC_ ## D]
+	mac_stats->M = le64_to_cpu(dma_stats[MC_CMD_MAC_ ## D])
 
 	MAC_STAT(tx_bytes, TX_BYTES);
 	MAC_STAT(tx_bad_bytes, TX_BAD_BYTES);
@@ -460,7 +459,8 @@ static int siena_try_update_nic_stats(struct efx_nic *efx)
 	MAC_STAT(rx_internal_error, RX_INTERNAL_ERROR_PKTS);
 	mac_stats->rx_good_lt64 = 0;
 
-	efx->n_rx_nodesc_drop_cnt = dma_stats[MC_CMD_MAC_RX_NODESC_DROPS];
+	efx->n_rx_nodesc_drop_cnt =
+		le64_to_cpu(dma_stats[MC_CMD_MAC_RX_NODESC_DROPS]);
 
 #undef MAC_STAT
 
@@ -489,7 +489,7 @@ static void siena_update_nic_stats(struct efx_nic *efx)
 
 static void siena_start_nic_stats(struct efx_nic *efx)
 {
-	u64 *dma_stats = (u64 *)efx->stats_buffer.addr;
+	__le64 *dma_stats = efx->stats_buffer.addr;
 
 	dma_stats[MC_CMD_MAC_GENERATION_END] = STATS_GENERATION_INVALID;
 
-- 
1.7.7.6


>From b59e9a085a4c0b4653812b2bdd13c5e9c9fcd792 Mon Sep 17 00:00:00 2001
From: Stuart Hodgson <smhodgson@solarflare.com>
Date: Fri, 30 Mar 2012 13:04:51 +0100
Subject: [PATCH 03/12] sfc: Do not attempt to flush queues if DMA is disabled

[ Upstream commit 3dca9d2dc285faf1910d405b65df845cab061356 ]

efx_nic_fatal_interrupt() disables DMA before scheduling a reset.
After this, we need not and *cannot* flush queues.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |   33 +++++++++++++++++++--------------
 1 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index be3cade..f2bdc50 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -651,25 +651,30 @@ static void efx_fini_channels(struct efx_nic *efx)
 	struct efx_channel *channel;
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
+	struct pci_dev *dev = efx->pci_dev;
 	int rc;
 
 	EFX_ASSERT_RESET_SERIALISED(efx);
 	BUG_ON(efx->port_enabled);
 
-	rc = efx_nic_flush_queues(efx);
-	if (rc && EFX_WORKAROUND_7803(efx)) {
-		/* Schedule a reset to recover from the flush failure. The
-		 * descriptor caches reference memory we're about to free,
-		 * but falcon_reconfigure_mac_wrapper() won't reconnect
-		 * the MACs because of the pending reset. */
-		netif_err(efx, drv, efx->net_dev,
-			  "Resetting to recover from flush failure\n");
-		efx_schedule_reset(efx, RESET_TYPE_ALL);
-	} else if (rc) {
-		netif_err(efx, drv, efx->net_dev, "failed to flush queues\n");
-	} else {
-		netif_dbg(efx, drv, efx->net_dev,
-			  "successfully flushed all queues\n");
+	/* Only perform flush if dma is enabled */
+	if (dev->is_busmaster) {
+		rc = efx_nic_flush_queues(efx);
+
+		if (rc && EFX_WORKAROUND_7803(efx)) {
+			/* Schedule a reset to recover from the flush failure. The
+			 * descriptor caches reference memory we're about to free,
+			 * but falcon_reconfigure_mac_wrapper() won't reconnect
+			 * the MACs because of the pending reset. */
+			netif_err(efx, drv, efx->net_dev,
+				  "Resetting to recover from flush failure\n");
+			efx_schedule_reset(efx, RESET_TYPE_ALL);
+		} else if (rc) {
+			netif_err(efx, drv, efx->net_dev, "failed to flush queues\n");
+		} else {
+			netif_dbg(efx, drv, efx->net_dev,
+				  "successfully flushed all queues\n");
+		}
 	}
 
 	efx_for_each_channel(channel, efx) {
-- 
1.7.7.6


>From 24bfd36b6486da521486ccabf920789112ae3628 Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 7 Sep 2012 00:58:10 +0100
Subject: [PATCH 04/12] sfc: Convert firmware subtypes to native byte order in
 efx_mcdi_get_board_cfg()

[ Upstream commit bfeed902946a31692e7a24ed355b6d13ac37d014 ]

On big-endian systems the MTD partition names currently have mangled
subtype numbers and are not recognised by the firmware update tool
(sfupdate).

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
[bwh: Backported to 3.0: use old macros for length of firmware subtype array]
---
 drivers/net/sfc/mcdi.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sfc/mcdi.c b/drivers/net/sfc/mcdi.c
index 81a4253..85e070e 100644
--- a/drivers/net/sfc/mcdi.c
+++ b/drivers/net/sfc/mcdi.c
@@ -666,9 +666,8 @@ int efx_mcdi_get_board_cfg(struct efx_nic *efx, u8 *mac_address,
 			   u16 *fw_subtype_list)
 {
 	uint8_t outbuf[MC_CMD_GET_BOARD_CFG_OUT_LEN];
-	size_t outlen;
+	size_t outlen, offset, i;
 	int port_num = efx_port_num(efx);
-	int offset;
 	int rc;
 
 	BUILD_BUG_ON(MC_CMD_GET_BOARD_CFG_IN_LEN != 0);
@@ -688,10 +687,16 @@ int efx_mcdi_get_board_cfg(struct efx_nic *efx, u8 *mac_address,
 		: MC_CMD_GET_BOARD_CFG_OUT_MAC_ADDR_BASE_PORT0_OFST;
 	if (mac_address)
 		memcpy(mac_address, outbuf + offset, ETH_ALEN);
-	if (fw_subtype_list)
-		memcpy(fw_subtype_list,
-		       outbuf + MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_OFST,
-		       MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_LEN);
+	if (fw_subtype_list) {
+		offset = MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_OFST;
+		for (i = 0;
+		     i < MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_LEN / 2;
+		     i++) {
+			fw_subtype_list[i] =
+				le16_to_cpup((__le16 *)(outbuf + offset));
+			offset += 2;
+		}
+	}
 
 	return 0;
 
-- 
1.7.7.6


>From 6debf9cb68fb04952f660179e91dfdc8982adf83 Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 23 May 2011 12:18:45 +0100
Subject: [PATCH 05/12] sfc: Fix two causes of flush failure

[ Upstream commits a606f4325dca6950996abbae452d33f2af095f39,
  d5e8cc6c946e0857826dcfbb3585068858445bfe,
  525d9e824018cd7cc8d8d44832ddcd363abfe6e1 ]

The TX DMA engine issues upstream read requests when there is room in
the TX FIFO for the completion. However, the fetches for the rest of
the packet might be delayed by any back pressure.  Since a flush must
wait for an EOP, the entire flush may be delayed by back pressure.

Mitigate this by disabling flow control before the flushes are
started.  Since PF and VF flushes run in parallel introduce
fc_disable, a reference count of the number of flushes outstanding.

The same principle could be applied to Falcon, but that
would bring with it its own testing.

We sometimes hit a "failed to flush" timeout on some TX queues, but the
flushes have completed and the flush completion events seem to go missing.
In this case, we can check the TX_DESC_PTR_TBL register and drain the
queues if the flushes had finished.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
[bwh: Backported to 3.0:
 - Call efx_nic_type::finish_flush() on both success and failure paths
 - Check the TX_DESC_PTR_TBL registers in the polling loop
 - Declare efx_mcdi_set_mac() extern]
---
 drivers/net/sfc/falcon.c     |    2 ++
 drivers/net/sfc/mcdi.h       |    1 +
 drivers/net/sfc/mcdi_mac.c   |    4 +++-
 drivers/net/sfc/net_driver.h |    6 ++++++
 drivers/net/sfc/nic.c        |   21 ++++++++++++++++++---
 drivers/net/sfc/nic.h        |    2 ++
 drivers/net/sfc/siena.c      |   15 ++++++++++++++-
 7 files changed, 46 insertions(+), 5 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 60176e8..19b996b3 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1714,6 +1714,7 @@ const struct efx_nic_type falcon_a1_nic_type = {
 	.remove_port = falcon_remove_port,
 	.handle_global_event = falcon_handle_global_event,
 	.prepare_flush = falcon_prepare_flush,
+	.finish_flush = efx_port_dummy_op_void,
 	.update_stats = falcon_update_nic_stats,
 	.start_stats = falcon_start_nic_stats,
 	.stop_stats = falcon_stop_nic_stats,
@@ -1755,6 +1756,7 @@ const struct efx_nic_type falcon_b0_nic_type = {
 	.remove_port = falcon_remove_port,
 	.handle_global_event = falcon_handle_global_event,
 	.prepare_flush = falcon_prepare_flush,
+	.finish_flush = efx_port_dummy_op_void,
 	.update_stats = falcon_update_nic_stats,
 	.start_stats = falcon_start_nic_stats,
 	.stop_stats = falcon_stop_nic_stats,
diff --git a/drivers/net/sfc/mcdi.h b/drivers/net/sfc/mcdi.h
index aced2a7..b61eea0 100644
--- a/drivers/net/sfc/mcdi.h
+++ b/drivers/net/sfc/mcdi.h
@@ -126,5 +126,6 @@ extern int efx_mcdi_wol_filter_set_magic(struct efx_nic *efx,
 extern int efx_mcdi_wol_filter_get_magic(struct efx_nic *efx, int *id_out);
 extern int efx_mcdi_wol_filter_remove(struct efx_nic *efx, int id);
 extern int efx_mcdi_wol_filter_reset(struct efx_nic *efx);
+extern int efx_mcdi_set_mac(struct efx_nic *efx);
 
 #endif /* EFX_MCDI_H */
diff --git a/drivers/net/sfc/mcdi_mac.c b/drivers/net/sfc/mcdi_mac.c
index 50c2077..da269d7 100644
--- a/drivers/net/sfc/mcdi_mac.c
+++ b/drivers/net/sfc/mcdi_mac.c
@@ -13,7 +13,7 @@
 #include "mcdi.h"
 #include "mcdi_pcol.h"
 
-static int efx_mcdi_set_mac(struct efx_nic *efx)
+int efx_mcdi_set_mac(struct efx_nic *efx)
 {
 	u32 reject, fcntl;
 	u8 cmdbytes[MC_CMD_SET_MAC_IN_LEN];
@@ -45,6 +45,8 @@ static int efx_mcdi_set_mac(struct efx_nic *efx)
 	}
 	if (efx->wanted_fc & EFX_FC_AUTO)
 		fcntl = MC_CMD_FCNTL_AUTO;
+	if (efx->fc_disable)
+		fcntl = MC_CMD_FCNTL_OFF;
 
 	MCDI_SET_DWORD(cmdbytes, SET_MAC_IN_FCNTL, fcntl);
 
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index e8d5f03..47aff8e 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -690,6 +690,9 @@ struct efx_filter_state;
  * @promiscuous: Promiscuous flag. Protected by netif_tx_lock.
  * @multicast_hash: Multicast hash table
  * @wanted_fc: Wanted flow control flags
+ * @fc_disable: When non-zero flow control is disabled. Typically used to
+ *	ensure that network back pressure doesn't delay dma queue flushes.
+ *	Serialised by the rtnl lock.
  * @mac_work: Work item for changing MAC promiscuity and multicast hash
  * @loopback_mode: Loopback status
  * @loopback_modes: Supported loopback mode bitmask
@@ -783,6 +786,7 @@ struct efx_nic {
 	bool promiscuous;
 	union efx_multicast_hash multicast_hash;
 	u8 wanted_fc;
+	unsigned fc_disable;
 
 	atomic_t rx_reset;
 	enum efx_loopback_mode loopback_mode;
@@ -834,6 +838,7 @@ static inline unsigned int efx_port_num(struct efx_nic *efx)
  * @remove_port: Free resources allocated by probe_port()
  * @handle_global_event: Handle a "global" event (may be %NULL)
  * @prepare_flush: Prepare the hardware for flushing the DMA queues
+ * @finish_flush: Clean up after flushing the DMA queues
  * @update_stats: Update statistics not provided by event handling
  * @start_stats: Start the regular fetching of statistics
  * @stop_stats: Stop the regular fetching of statistics
@@ -879,6 +884,7 @@ struct efx_nic_type {
 	void (*remove_port)(struct efx_nic *efx);
 	bool (*handle_global_event)(struct efx_channel *channel, efx_qword_t *);
 	void (*prepare_flush)(struct efx_nic *efx);
+	void (*finish_flush)(struct efx_nic *efx);
 	void (*update_stats)(struct efx_nic *efx);
 	void (*start_stats)(struct efx_nic *efx);
 	void (*stop_stats)(struct efx_nic *efx);
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index 5ac9fa2..854df4e 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -1260,13 +1260,27 @@ int efx_nic_flush_queues(struct efx_nic *efx)
 			}
 			efx_for_each_possible_channel_tx_queue(tx_queue, channel) {
 				if (tx_queue->initialised &&
-				    tx_queue->flushed != FLUSH_DONE)
-					++tx_pending;
+				    tx_queue->flushed != FLUSH_DONE) {
+					efx_oword_t txd_ptr_tbl;
+
+					efx_reado_table(efx, &txd_ptr_tbl,
+							FR_BZ_TX_DESC_PTR_TBL,
+							tx_queue->queue);
+					if (EFX_OWORD_FIELD(txd_ptr_tbl,
+							    FRF_AZ_TX_DESCQ_FLUSH) ||
+					    EFX_OWORD_FIELD(txd_ptr_tbl,
+							    FRF_AZ_TX_DESCQ_EN))
+						++tx_pending;
+					else
+						tx_queue->flushed = FLUSH_DONE;
+				}
 			}
 		}
 
-		if (rx_pending == 0 && tx_pending == 0)
+		if (rx_pending == 0 && tx_pending == 0) {
+			efx->type->finish_flush(efx);
 			return 0;
+		}
 
 		msleep(EFX_FLUSH_INTERVAL);
 		efx_poll_flush_events(efx);
@@ -1292,6 +1306,7 @@ int efx_nic_flush_queues(struct efx_nic *efx)
 		}
 	}
 
+	efx->type->finish_flush(efx);
 	return -ETIMEDOUT;
 }
 
diff --git a/drivers/net/sfc/nic.h b/drivers/net/sfc/nic.h
index d2405ce..8a2c4f5 100644
--- a/drivers/net/sfc/nic.h
+++ b/drivers/net/sfc/nic.h
@@ -211,6 +211,8 @@ extern void falcon_irq_ack_a1(struct efx_nic *efx);
 
 /* Global Resources */
 extern int efx_nic_flush_queues(struct efx_nic *efx);
+extern void siena_prepare_flush(struct efx_nic *efx);
+extern void siena_finish_flush(struct efx_nic *efx);
 extern void falcon_start_nic_stats(struct efx_nic *efx);
 extern void falcon_stop_nic_stats(struct efx_nic *efx);
 extern void falcon_setup_xaui(struct efx_nic *efx);
diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index 407f50b..062494a 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -135,6 +135,18 @@ static void siena_remove_port(struct efx_nic *efx)
 	efx_nic_free_buffer(efx, &efx->stats_buffer);
 }
 
+void siena_prepare_flush(struct efx_nic *efx)
+{
+	if (efx->fc_disable++ == 0)
+		efx_mcdi_set_mac(efx);
+}
+
+void siena_finish_flush(struct efx_nic *efx)
+{
+	if (--efx->fc_disable == 0)
+		efx_mcdi_set_mac(efx);
+}
+
 static const struct efx_nic_register_test siena_register_tests[] = {
 	{ FR_AZ_ADR_REGION,
 	  EFX_OWORD32(0x0003FFFF, 0x0003FFFF, 0x0003FFFF, 0x0003FFFF) },
@@ -590,7 +602,8 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.reset = siena_reset_hw,
 	.probe_port = siena_probe_port,
 	.remove_port = siena_remove_port,
-	.prepare_flush = efx_port_dummy_op_void,
+	.prepare_flush = siena_prepare_flush,
+	.finish_flush = siena_finish_flush,
 	.update_stats = siena_update_nic_stats,
 	.start_stats = siena_start_nic_stats,
 	.stop_stats = siena_stop_nic_stats,
-- 
1.7.7.6


>From a16182b32f9ba94b510483aa3fc4ce64801ee486 Mon Sep 17 00:00:00 2001
From: Daniel Pieczko <dpieczko@solarflare.com>
Date: Wed, 17 Oct 2012 13:21:23 +0100
Subject: [PATCH 06/12] sfc: lock TX queues when calling netif_device_detach()

[ Upstream commit c2f3b8e3a44b6fe9e36704e30157ebe1a88c08b1 ]

The assertion of netif_device_present() at the top of
efx_hard_start_xmit() may fail if we don't do this.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
[bwh: Backported to 3.0: adjust context]
---
 drivers/net/sfc/efx.c      |    4 ++--
 drivers/net/sfc/efx.h      |   13 +++++++++++++
 drivers/net/sfc/selftest.c |    2 +-
 3 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index f2bdc50..7157a33 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -2106,7 +2106,7 @@ int efx_reset(struct efx_nic *efx, enum reset_type method)
 	netif_info(efx, drv, efx->net_dev, "resetting (%s)\n",
 		   RESET_TYPE(method));
 
-	netif_device_detach(efx->net_dev);
+	efx_device_detach_sync(efx);
 	efx_reset_down(efx, method);
 
 	rc = efx->type->reset(efx, method);
@@ -2565,7 +2565,7 @@ static int efx_pm_freeze(struct device *dev)
 
 	efx->state = STATE_FINI;
 
-	netif_device_detach(efx->net_dev);
+	efx_device_detach_sync(efx);
 
 	efx_stop_all(efx);
 	efx_fini_channels(efx);
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index a5d1c60d..dabde2c 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -150,4 +150,17 @@ extern void efx_link_status_changed(struct efx_nic *efx);
 extern void efx_link_set_advertising(struct efx_nic *efx, u32);
 extern void efx_link_set_wanted_fc(struct efx_nic *efx, u8);
 
+static inline void efx_device_detach_sync(struct efx_nic *efx)
+{
+	struct net_device *dev = efx->net_dev;
+
+	/* Lock/freeze all TX queues so that we can be sure the
+	 * TX scheduler is stopped when we're done and before
+	 * netif_device_present() becomes false.
+	 */
+	netif_tx_lock(dev);
+	netif_device_detach(dev);
+	netif_tx_unlock(dev);
+}
+
 #endif /* EFX_EFX_H */
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 822f6c2..4907885 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -698,7 +698,7 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 	/* Detach the device so the kernel doesn't transmit during the
 	 * loopback test and the watchdog timeout doesn't fire.
 	 */
-	netif_device_detach(efx->net_dev);
+	efx_device_detach_sync(efx);
 
 	mutex_lock(&efx->mac_lock);
 	if (efx->loopback_modes) {
-- 
1.7.7.6


>From 8311837fe602b8ef468d64e12484ca8c18839bf7 Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 1 Dec 2012 02:21:17 +0000
Subject: [PATCH 07/12] sfc: Fix timekeeping in efx_mcdi_poll()

[ Upstream commit ebf98e797b4e26ad52ace1511a0b503ee60a6cd4 ]

efx_mcdi_poll() uses get_seconds() to read the current time and to
implement a polling timeout.  The use of this function was chosen
partly because it could easily be replaced in a co-sim environment
with a macro that read the simulated time.

Unfortunately the real get_seconds() returns the system time (real
time) which is subject to adjustment by e.g. ntpd.  If the system time
is adjusted forward during a polled MCDI operation, the effective
timeout can be shorter than the intended 10 seconds, resulting in a
spurious failure.  It is also possible for a backward adjustment to
delay detection of a areal failure.

Use jiffies instead, and change MCDI_RPC_TIMEOUT to be denominated in
jiffies.  Also correct rounding of the timeout: check time > finish
(or rather time_after(time, finish)) and not time >= finish.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
[bwh: Backported to 3.0: adjust context]
---
 drivers/net/sfc/mcdi.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sfc/mcdi.c b/drivers/net/sfc/mcdi.c
index 85e070e..c1000ce 100644
--- a/drivers/net/sfc/mcdi.c
+++ b/drivers/net/sfc/mcdi.c
@@ -30,7 +30,7 @@
 #define REBOOT_FLAG_PORT0 0x3f8
 #define REBOOT_FLAG_PORT1 0x3fc
 
-#define MCDI_RPC_TIMEOUT       10 /*seconds */
+#define MCDI_RPC_TIMEOUT       (10 * HZ)
 
 #define MCDI_PDU(efx)							\
 	(efx_port_num(efx) ? CMD_PDU_PORT1 : CMD_PDU_PORT0)
@@ -120,7 +120,7 @@ static void efx_mcdi_copyout(struct efx_nic *efx, u8 *outbuf, size_t outlen)
 static int efx_mcdi_poll(struct efx_nic *efx)
 {
 	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
-	unsigned int time, finish;
+	unsigned long time, finish;
 	unsigned int respseq, respcmd, error;
 	unsigned int pdu = FR_CZ_MC_TREG_SMEM + MCDI_PDU(efx);
 	unsigned int rc, spins;
@@ -136,7 +136,7 @@ static int efx_mcdi_poll(struct efx_nic *efx)
 	 * and poll once a jiffy (approximately)
 	 */
 	spins = TICK_USEC;
-	finish = get_seconds() + MCDI_RPC_TIMEOUT;
+	finish = jiffies + MCDI_RPC_TIMEOUT;
 
 	while (1) {
 		if (spins != 0) {
@@ -146,7 +146,7 @@ static int efx_mcdi_poll(struct efx_nic *efx)
 			schedule_timeout_uninterruptible(1);
 		}
 
-		time = get_seconds();
+		time = jiffies;
 
 		rmb();
 		efx_readd(efx, &reg, pdu);
@@ -158,7 +158,7 @@ static int efx_mcdi_poll(struct efx_nic *efx)
 		    EFX_DWORD_FIELD(reg, MCDI_HEADER_RESPONSE))
 			break;
 
-		if (time >= finish)
+		if (time_after(time, finish))
 			return -ETIMEDOUT;
 	}
 
@@ -250,7 +250,7 @@ static int efx_mcdi_await_completion(struct efx_nic *efx)
 	if (wait_event_timeout(
 		    mcdi->wq,
 		    atomic_read(&mcdi->state) == MCDI_STATE_COMPLETED,
-		    msecs_to_jiffies(MCDI_RPC_TIMEOUT * 1000)) == 0)
+		    MCDI_RPC_TIMEOUT) == 0)
 		return -ETIMEDOUT;
 
 	/* Check if efx_mcdi_set_mode() switched us back to polled completions.
-- 
1.7.7.6


>From 767ca89658a40ab706fc08eaf9700b077150efc4 Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 20 Dec 2012 18:48:20 +0000
Subject: [PATCH 08/12] sfc: Properly sync RX DMA buffer when it is not the
 last in the page

[ Upstream commit 3a68f19d7afb80f548d016effbc6ed52643a8085 ]

We may currently allocate two RX DMA buffers to a page, and only unmap
the page when the second is completed.  We do not sync the first RX
buffer to be completed; this can result in packet loss or corruption
if the last RX buffer completed in a NAPI poll is the first in a page
and is not DMA-coherent.  (In the middle of a NAPI poll, we will
handle the following RX completion and unmap the page *before* looking
at the content of the first buffer.)

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
[bwh: Backported to 3.0: adjust context]
---
 drivers/net/sfc/rx.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 4004fc2..ce6f53f 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -245,7 +245,8 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 }
 
 static void efx_unmap_rx_buffer(struct efx_nic *efx,
-				struct efx_rx_buffer *rx_buf)
+				struct efx_rx_buffer *rx_buf,
+				unsigned int used_len)
 {
 	if (rx_buf->is_page && rx_buf->u.page) {
 		struct efx_rx_page_state *state;
@@ -256,6 +257,10 @@ static void efx_unmap_rx_buffer(struct efx_nic *efx,
 				       state->dma_addr,
 				       efx_rx_buf_size(efx),
 				       PCI_DMA_FROMDEVICE);
+		} else if (used_len) {
+			dma_sync_single_for_cpu(&efx->pci_dev->dev,
+						rx_buf->dma_addr, used_len,
+						DMA_FROM_DEVICE);
 		}
 	} else if (!rx_buf->is_page && rx_buf->u.skb) {
 		pci_unmap_single(efx->pci_dev, rx_buf->dma_addr,
@@ -278,7 +283,7 @@ static void efx_free_rx_buffer(struct efx_nic *efx,
 static void efx_fini_rx_buffer(struct efx_rx_queue *rx_queue,
 			       struct efx_rx_buffer *rx_buf)
 {
-	efx_unmap_rx_buffer(rx_queue->efx, rx_buf);
+	efx_unmap_rx_buffer(rx_queue->efx, rx_buf, 0);
 	efx_free_rx_buffer(rx_queue->efx, rx_buf);
 }
 
@@ -549,10 +554,10 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 		goto out;
 	}
 
-	/* Release card resources - assumes all RX buffers consumed in-order
-	 * per RX queue
+	/* Release and/or sync DMA mapping - assumes all RX buffers
+	 * consumed in-order per RX queue
 	 */
-	efx_unmap_rx_buffer(efx, rx_buf);
+	efx_unmap_rx_buffer(efx, rx_buf, len);
 
 	/* Prefetch nice and early so data will (hopefully) be in cache by
 	 * the time we look at it.
-- 
1.7.7.6


>From ac4778169b1859a1c59569998fa6448811aad8bd Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 10 Jan 2013 23:51:54 +0000
Subject: [PATCH 09/12] sfc: Fix efx_rx_buf_offset() in the presence of
 swiotlb

[ Upstream commits 06e63c57acbb1df7c35ebe846ae416a8b88dfafa,
  b590ace09d51cd39744e0f7662c5e4a0d1b5d952 and
  c73e787a8db9117d59b5180baf83203a42ecadca ]

We assume that the mapping between DMA and virtual addresses is done
on whole pages, so we can find the page offset of an RX buffer using
the lower bits of the DMA address.  However, swiotlb maps in units of
2K, breaking this assumption.

Add an explicit page_offset field to struct efx_rx_buffer.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
[bwh: Backported to 3.0: adjust context]
---
 drivers/net/sfc/net_driver.h |    4 +++-
 drivers/net/sfc/rx.c         |   10 +++++-----
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 47aff8e..2f932c5 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -214,6 +214,7 @@ struct efx_tx_queue {
  *	If both this and page are %NULL, the buffer slot is currently free.
  * @page: The associated page buffer, if any.
  *	If both this and skb are %NULL, the buffer slot is currently free.
+ * @page_offset: Offset within page. Valid iff @flags & %EFX_RX_BUF_PAGE.
  * @len: Buffer length, in bytes.
  * @is_page: Indicates if @page is valid. If false, @skb is valid.
  */
@@ -223,7 +224,8 @@ struct efx_rx_buffer {
 		struct sk_buff *skb;
 		struct page *page;
 	} u;
-	unsigned int len;
+	u16 page_offset;
+	u16 len;
 	bool is_page;
 };
 
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index ce6f53f..d429f0a 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -94,11 +94,7 @@ static unsigned int rx_refill_limit = 95;
 static inline unsigned int efx_rx_buf_offset(struct efx_nic *efx,
 					     struct efx_rx_buffer *buf)
 {
-	/* Offset is always within one page, so we don't need to consider
-	 * the page order.
-	 */
-	return (((__force unsigned long) buf->dma_addr & (PAGE_SIZE - 1)) +
-		efx->type->rx_buffer_hash_size);
+	return buf->page_offset + efx->type->rx_buffer_hash_size;
 }
 static inline unsigned int efx_rx_buf_size(struct efx_nic *efx)
 {
@@ -193,6 +189,7 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 	struct efx_rx_buffer *rx_buf;
 	struct page *page;
 	void *page_addr;
+	unsigned int page_offset;
 	struct efx_rx_page_state *state;
 	dma_addr_t dma_addr;
 	unsigned index, count;
@@ -219,12 +216,14 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 
 		page_addr += sizeof(struct efx_rx_page_state);
 		dma_addr += sizeof(struct efx_rx_page_state);
+		page_offset = sizeof(struct efx_rx_page_state);
 
 	split:
 		index = rx_queue->added_count & rx_queue->ptr_mask;
 		rx_buf = efx_rx_buffer(rx_queue, index);
 		rx_buf->dma_addr = dma_addr + EFX_PAGE_IP_ALIGN;
 		rx_buf->u.page = page;
+		rx_buf->page_offset = page_offset + EFX_PAGE_IP_ALIGN;
 		rx_buf->len = efx->rx_buffer_len - EFX_PAGE_IP_ALIGN;
 		rx_buf->is_page = true;
 		++rx_queue->added_count;
@@ -236,6 +235,7 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 			get_page(page);
 			dma_addr += (PAGE_SIZE >> 1);
 			page_addr += (PAGE_SIZE >> 1);
+			page_offset += (PAGE_SIZE >> 1);
 			++count;
 			goto split;
 		}
-- 
1.7.7.6


>From cdd2734372f19f20a499c8337df11f7716aab3fd Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 28 Jan 2013 19:01:06 +0000
Subject: [PATCH 10/12] sfc: Detach net device when stopping queues for
 reconfiguration

[ Upstream commit 29c69a4882641285a854d6d03ca5adbba68c0034 ]

We must only ever stop TX queues when they are full or the net device
is not 'ready' so far as the net core, and specifically the watchdog,
is concerned.  Otherwise, the watchdog may fire *immediately* if no
packets have been added to the queue in the last 5 seconds.

The device is ready if all the following are true:

(a) It has a qdisc
(b) It is marked present
(c) It is running
(d) The link is reported up

(a) and (c) are normally true, and must not be changed by a driver.
(d) is under our control, but fake link changes may disturb userland.
This leaves (b).  We already mark the device absent during reset
and self-test, but we need to do the same during MTU changes and ring
reallocation.  We don't need to do this when the device is brought
down because then (c) is already false.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
[bwh: Backported to 3.0: adjust context]
---
 drivers/net/sfc/efx.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 7157a33..07e526d 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -720,6 +720,7 @@ efx_realloc_channels(struct efx_nic *efx, u32 rxq_entries, u32 txq_entries)
 	unsigned i;
 	int rc;
 
+	efx_device_detach_sync(efx);
 	efx_stop_all(efx);
 	efx_fini_channels(efx);
 
@@ -763,6 +764,7 @@ out:
 
 	efx_init_channels(efx);
 	efx_start_all(efx);
+	netif_device_attach(efx->net_dev);
 	return rc;
 
 rollback:
@@ -1530,8 +1532,12 @@ static void efx_stop_all(struct efx_nic *efx)
 	/* Flush efx_mac_work(), refill_workqueue, monitor_work */
 	efx_flush_all(efx);
 
-	/* Stop the kernel transmit interface late, so the watchdog
-	 * timer isn't ticking over the flush */
+	/* Stop the kernel transmit interface.  This is only valid if
+	 * the device is stopped or detached; otherwise the watchdog
+	 * may fire immediately.
+	 */
+	WARN_ON(netif_running(efx->net_dev) &&
+		netif_device_present(efx->net_dev));
 	if (efx_dev_registered(efx)) {
 		netif_tx_stop_all_queues(efx->net_dev);
 		netif_tx_lock_bh(efx->net_dev);
@@ -1801,10 +1807,11 @@ static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
 	if (new_mtu > EFX_MAX_MTU)
 		return -EINVAL;
 
-	efx_stop_all(efx);
-
 	netif_dbg(efx, drv, efx->net_dev, "changing MTU to %d\n", new_mtu);
 
+	efx_device_detach_sync(efx);
+	efx_stop_all(efx);
+
 	efx_fini_channels(efx);
 
 	mutex_lock(&efx->mac_lock);
@@ -1817,6 +1824,7 @@ static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
 	efx_init_channels(efx);
 
 	efx_start_all(efx);
+	netif_device_attach(efx->net_dev);
 	return rc;
 }
 
-- 
1.7.7.6


>From 358aef776f04098a98b0307f4976703eeb0ee938 Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 5 Mar 2013 01:03:47 +0000
Subject: [PATCH 11/12] sfc: Disable soft interrupt handling during
 efx_device_detach_sync()

[ Upstream commit 35205b211c8d17a8a0b5e8926cb7c73e9a7ef1ad ]

efx_device_detach_sync() locks all TX queues before marking the device
detached and thus disabling further TX scheduling.  But it can still
be interrupted by TX completions which then result in TX scheduling in
soft interrupt context.  This will deadlock when it tries to acquire
a TX queue lock that efx_device_detach_sync() already acquired.

To avoid deadlock, we must use netif_tx_{,un}lock_bh().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index dabde2c..76e891e 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -158,9 +158,9 @@ static inline void efx_device_detach_sync(struct efx_nic *efx)
 	 * TX scheduler is stopped when we're done and before
 	 * netif_device_present() becomes false.
 	 */
-	netif_tx_lock(dev);
+	netif_tx_lock_bh(dev);
 	netif_device_detach(dev);
-	netif_tx_unlock(dev);
+	netif_tx_unlock_bh(dev);
 }
 
 #endif /* EFX_EFX_H */
-- 
1.7.7.6


>From ac3f3ed559611cb34d16899b0cfd53e1b4cfd35b Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 27 Feb 2013 16:50:38 +0000
Subject: [PATCH 12/12] sfc: Only use TX push if a single descriptor is to be
 written

Using TX push when notifying the NIC of multiple new descriptors in
the ring will very occasionally cause the TX DMA engine to re-use an
old descriptor.  This can result in a duplicated or partly duplicated
packet (new headers with old data), or an IOMMU page fault.  This does
not happen when the pushed descriptor is the only one written.

TX push also provides little latency benefit when a packet requires
more than one descriptor.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/nic.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index 854df4e..4949004 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -370,7 +370,8 @@ efx_may_push_tx_desc(struct efx_tx_queue *tx_queue, unsigned int write_count)
 		return false;
 
 	tx_queue->empty_read_count = 0;
-	return ((empty_read_count ^ write_count) & ~EFX_EMPTY_COUNT_VALID) == 0;
+	return ((empty_read_count ^ write_count) & ~EFX_EMPTY_COUNT_VALID) == 0
+		&& tx_queue->write_count - write_count == 1;
 }
 
 /* For each entry inserted into the software descriptor ring, create a
-- 
1.7.7.6


--=-JoKlq4P+CI6IELemF1bE
Content-Type: application/mbox; name="sfc_3.2.mbox"
Content-Disposition: attachment; filename="sfc_3.2.mbox"
Content-Transfer-Encoding: 7bit

>From 2e2238ab9d062a11fe1572ec11ef8330db815354 Mon Sep 17 00:00:00 2001
From: Stuart Hodgson <smhodgson@solarflare.com>
Date: Fri, 30 Mar 2012 13:04:51 +0100
Subject: [PATCH 01/10] sfc: Do not attempt to flush queues if DMA is disabled

[ Upstream commit 3dca9d2dc285faf1910d405b65df845cab061356 ]

efx_nic_fatal_interrupt() disables DMA before scheduling a reset.
After this, we need not and *cannot* flush queues.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |   33 +++++++++++++++++++--------------
 1 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index a6611f1..aa20047 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -650,25 +650,30 @@ static void efx_fini_channels(struct efx_nic *efx)
 	struct efx_channel *channel;
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
+	struct pci_dev *dev = efx->pci_dev;
 	int rc;
 
 	EFX_ASSERT_RESET_SERIALISED(efx);
 	BUG_ON(efx->port_enabled);
 
-	rc = efx_nic_flush_queues(efx);
-	if (rc && EFX_WORKAROUND_7803(efx)) {
-		/* Schedule a reset to recover from the flush failure. The
-		 * descriptor caches reference memory we're about to free,
-		 * but falcon_reconfigure_mac_wrapper() won't reconnect
-		 * the MACs because of the pending reset. */
-		netif_err(efx, drv, efx->net_dev,
-			  "Resetting to recover from flush failure\n");
-		efx_schedule_reset(efx, RESET_TYPE_ALL);
-	} else if (rc) {
-		netif_err(efx, drv, efx->net_dev, "failed to flush queues\n");
-	} else {
-		netif_dbg(efx, drv, efx->net_dev,
-			  "successfully flushed all queues\n");
+	/* Only perform flush if dma is enabled */
+	if (dev->is_busmaster) {
+		rc = efx_nic_flush_queues(efx);
+
+		if (rc && EFX_WORKAROUND_7803(efx)) {
+			/* Schedule a reset to recover from the flush failure. The
+			 * descriptor caches reference memory we're about to free,
+			 * but falcon_reconfigure_mac_wrapper() won't reconnect
+			 * the MACs because of the pending reset. */
+			netif_err(efx, drv, efx->net_dev,
+				  "Resetting to recover from flush failure\n");
+			efx_schedule_reset(efx, RESET_TYPE_ALL);
+		} else if (rc) {
+			netif_err(efx, drv, efx->net_dev, "failed to flush queues\n");
+		} else {
+			netif_dbg(efx, drv, efx->net_dev,
+				  "successfully flushed all queues\n");
+		}
 	}
 
 	efx_for_each_channel(channel, efx) {
-- 
1.7.7.6


>From 866a7fd45d42cd397b8de85de592191f0b09ea43 Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 7 Sep 2012 00:58:10 +0100
Subject: [PATCH 02/10] sfc: Convert firmware subtypes to native byte order in
 efx_mcdi_get_board_cfg()

[ Upstream commit bfeed902946a31692e7a24ed355b6d13ac37d014 ]

On big-endian systems the MTD partition names currently have mangled
subtype numbers and are not recognised by the firmware update tool
(sfupdate).

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
[bwh: Backported to 3.2: use old macros for length of firmware subtype array]
---
 drivers/net/ethernet/sfc/mcdi.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 81a4253..85e070e 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -666,9 +666,8 @@ int efx_mcdi_get_board_cfg(struct efx_nic *efx, u8 *mac_address,
 			   u16 *fw_subtype_list)
 {
 	uint8_t outbuf[MC_CMD_GET_BOARD_CFG_OUT_LEN];
-	size_t outlen;
+	size_t outlen, offset, i;
 	int port_num = efx_port_num(efx);
-	int offset;
 	int rc;
 
 	BUILD_BUG_ON(MC_CMD_GET_BOARD_CFG_IN_LEN != 0);
@@ -688,10 +687,16 @@ int efx_mcdi_get_board_cfg(struct efx_nic *efx, u8 *mac_address,
 		: MC_CMD_GET_BOARD_CFG_OUT_MAC_ADDR_BASE_PORT0_OFST;
 	if (mac_address)
 		memcpy(mac_address, outbuf + offset, ETH_ALEN);
-	if (fw_subtype_list)
-		memcpy(fw_subtype_list,
-		       outbuf + MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_OFST,
-		       MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_LEN);
+	if (fw_subtype_list) {
+		offset = MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_OFST;
+		for (i = 0;
+		     i < MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_LEN / 2;
+		     i++) {
+			fw_subtype_list[i] =
+				le16_to_cpup((__le16 *)(outbuf + offset));
+			offset += 2;
+		}
+	}
 
 	return 0;
 
-- 
1.7.7.6


>From ee003df5f1a4c668a742943d6eb0db2e0bf4fba0 Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 23 May 2011 12:18:45 +0100
Subject: [PATCH 03/10] sfc: Fix two causes of flush failure

[ Upstream commits a606f4325dca6950996abbae452d33f2af095f39,
  d5e8cc6c946e0857826dcfbb3585068858445bfe,
  525d9e824018cd7cc8d8d44832ddcd363abfe6e1 ]

The TX DMA engine issues upstream read requests when there is room in
the TX FIFO for the completion. However, the fetches for the rest of
the packet might be delayed by any back pressure.  Since a flush must
wait for an EOP, the entire flush may be delayed by back pressure.

Mitigate this by disabling flow control before the flushes are
started.  Since PF and VF flushes run in parallel introduce
fc_disable, a reference count of the number of flushes outstanding.

The same principle could be applied to Falcon, but that
would bring with it its own testing.

We sometimes hit a "failed to flush" timeout on some TX queues, but the
flushes have completed and the flush completion events seem to go missing.
In this case, we can check the TX_DESC_PTR_TBL register and drain the
queues if the flushes had finished.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
[bwh: Backported to 3.2:
 - Call efx_nic_type::finish_flush() on both success and failure paths
 - Check the TX_DESC_PTR_TBL registers in the polling loop
 - Declare efx_mcdi_set_mac() extern]
---
 drivers/net/ethernet/sfc/falcon.c     |    2 ++
 drivers/net/ethernet/sfc/mcdi.h       |    1 +
 drivers/net/ethernet/sfc/mcdi_mac.c   |    4 +++-
 drivers/net/ethernet/sfc/net_driver.h |    6 ++++++
 drivers/net/ethernet/sfc/nic.c        |   21 ++++++++++++++++++---
 drivers/net/ethernet/sfc/nic.h        |    2 ++
 drivers/net/ethernet/sfc/siena.c      |   15 ++++++++++++++-
 7 files changed, 46 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 97b606b..26cd6c0 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -1762,6 +1762,7 @@ const struct efx_nic_type falcon_a1_nic_type = {
 	.remove_port = falcon_remove_port,
 	.handle_global_event = falcon_handle_global_event,
 	.prepare_flush = falcon_prepare_flush,
+	.finish_flush = efx_port_dummy_op_void,
 	.update_stats = falcon_update_nic_stats,
 	.start_stats = falcon_start_nic_stats,
 	.stop_stats = falcon_stop_nic_stats,
@@ -1804,6 +1805,7 @@ const struct efx_nic_type falcon_b0_nic_type = {
 	.remove_port = falcon_remove_port,
 	.handle_global_event = falcon_handle_global_event,
 	.prepare_flush = falcon_prepare_flush,
+	.finish_flush = efx_port_dummy_op_void,
 	.update_stats = falcon_update_nic_stats,
 	.start_stats = falcon_start_nic_stats,
 	.stop_stats = falcon_stop_nic_stats,
diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index aced2a7..b61eea0 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -126,5 +126,6 @@ extern int efx_mcdi_wol_filter_set_magic(struct efx_nic *efx,
 extern int efx_mcdi_wol_filter_get_magic(struct efx_nic *efx, int *id_out);
 extern int efx_mcdi_wol_filter_remove(struct efx_nic *efx, int id);
 extern int efx_mcdi_wol_filter_reset(struct efx_nic *efx);
+extern int efx_mcdi_set_mac(struct efx_nic *efx);
 
 #endif /* EFX_MCDI_H */
diff --git a/drivers/net/ethernet/sfc/mcdi_mac.c b/drivers/net/ethernet/sfc/mcdi_mac.c
index 50c2077..da269d7 100644
--- a/drivers/net/ethernet/sfc/mcdi_mac.c
+++ b/drivers/net/ethernet/sfc/mcdi_mac.c
@@ -13,7 +13,7 @@
 #include "mcdi.h"
 #include "mcdi_pcol.h"
 
-static int efx_mcdi_set_mac(struct efx_nic *efx)
+int efx_mcdi_set_mac(struct efx_nic *efx)
 {
 	u32 reject, fcntl;
 	u8 cmdbytes[MC_CMD_SET_MAC_IN_LEN];
@@ -45,6 +45,8 @@ static int efx_mcdi_set_mac(struct efx_nic *efx)
 	}
 	if (efx->wanted_fc & EFX_FC_AUTO)
 		fcntl = MC_CMD_FCNTL_AUTO;
+	if (efx->fc_disable)
+		fcntl = MC_CMD_FCNTL_OFF;
 
 	MCDI_SET_DWORD(cmdbytes, SET_MAC_IN_FCNTL, fcntl);
 
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index b8e251a..9e2e802 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -689,6 +689,9 @@ struct efx_filter_state;
  * @promiscuous: Promiscuous flag. Protected by netif_tx_lock.
  * @multicast_hash: Multicast hash table
  * @wanted_fc: Wanted flow control flags
+ * @fc_disable: When non-zero flow control is disabled. Typically used to
+ *	ensure that network back pressure doesn't delay dma queue flushes.
+ *	Serialised by the rtnl lock.
  * @mac_work: Work item for changing MAC promiscuity and multicast hash
  * @loopback_mode: Loopback status
  * @loopback_modes: Supported loopback mode bitmask
@@ -782,6 +785,7 @@ struct efx_nic {
 	bool promiscuous;
 	union efx_multicast_hash multicast_hash;
 	u8 wanted_fc;
+	unsigned fc_disable;
 
 	atomic_t rx_reset;
 	enum efx_loopback_mode loopback_mode;
@@ -835,6 +839,7 @@ static inline unsigned int efx_port_num(struct efx_nic *efx)
  * @remove_port: Free resources allocated by probe_port()
  * @handle_global_event: Handle a "global" event (may be %NULL)
  * @prepare_flush: Prepare the hardware for flushing the DMA queues
+ * @finish_flush: Clean up after flushing the DMA queues
  * @update_stats: Update statistics not provided by event handling
  * @start_stats: Start the regular fetching of statistics
  * @stop_stats: Stop the regular fetching of statistics
@@ -880,6 +885,7 @@ struct efx_nic_type {
 	void (*remove_port)(struct efx_nic *efx);
 	bool (*handle_global_event)(struct efx_channel *channel, efx_qword_t *);
 	void (*prepare_flush)(struct efx_nic *efx);
+	void (*finish_flush)(struct efx_nic *efx);
 	void (*update_stats)(struct efx_nic *efx);
 	void (*start_stats)(struct efx_nic *efx);
 	void (*stop_stats)(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 3edfbaf..9cca2a6 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -1261,13 +1261,27 @@ int efx_nic_flush_queues(struct efx_nic *efx)
 			}
 			efx_for_each_possible_channel_tx_queue(tx_queue, channel) {
 				if (tx_queue->initialised &&
-				    tx_queue->flushed != FLUSH_DONE)
-					++tx_pending;
+				    tx_queue->flushed != FLUSH_DONE) {
+					efx_oword_t txd_ptr_tbl;
+
+					efx_reado_table(efx, &txd_ptr_tbl,
+							FR_BZ_TX_DESC_PTR_TBL,
+							tx_queue->queue);
+					if (EFX_OWORD_FIELD(txd_ptr_tbl,
+							    FRF_AZ_TX_DESCQ_FLUSH) ||
+					    EFX_OWORD_FIELD(txd_ptr_tbl,
+							    FRF_AZ_TX_DESCQ_EN))
+						++tx_pending;
+					else
+						tx_queue->flushed = FLUSH_DONE;
+				}
 			}
 		}
 
-		if (rx_pending == 0 && tx_pending == 0)
+		if (rx_pending == 0 && tx_pending == 0) {
+			efx->type->finish_flush(efx);
 			return 0;
+		}
 
 		msleep(EFX_FLUSH_INTERVAL);
 		efx_poll_flush_events(efx);
@@ -1293,6 +1307,7 @@ int efx_nic_flush_queues(struct efx_nic *efx)
 		}
 	}
 
+	efx->type->finish_flush(efx);
 	return -ETIMEDOUT;
 }
 
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 66ece48..58302a2 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -210,6 +210,8 @@ extern void falcon_irq_ack_a1(struct efx_nic *efx);
 
 /* Global Resources */
 extern int efx_nic_flush_queues(struct efx_nic *efx);
+extern void siena_prepare_flush(struct efx_nic *efx);
+extern void siena_finish_flush(struct efx_nic *efx);
 extern void falcon_start_nic_stats(struct efx_nic *efx);
 extern void falcon_stop_nic_stats(struct efx_nic *efx);
 extern void falcon_setup_xaui(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index cc2549c..c58b973 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -137,6 +137,18 @@ static void siena_remove_port(struct efx_nic *efx)
 	efx_nic_free_buffer(efx, &efx->stats_buffer);
 }
 
+void siena_prepare_flush(struct efx_nic *efx)
+{
+	if (efx->fc_disable++ == 0)
+		efx_mcdi_set_mac(efx);
+}
+
+void siena_finish_flush(struct efx_nic *efx)
+{
+	if (--efx->fc_disable == 0)
+		efx_mcdi_set_mac(efx);
+}
+
 static const struct efx_nic_register_test siena_register_tests[] = {
 	{ FR_AZ_ADR_REGION,
 	  EFX_OWORD32(0x0003FFFF, 0x0003FFFF, 0x0003FFFF, 0x0003FFFF) },
@@ -624,7 +636,8 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.reset = siena_reset_hw,
 	.probe_port = siena_probe_port,
 	.remove_port = siena_remove_port,
-	.prepare_flush = efx_port_dummy_op_void,
+	.prepare_flush = siena_prepare_flush,
+	.finish_flush = siena_finish_flush,
 	.update_stats = siena_update_nic_stats,
 	.start_stats = siena_start_nic_stats,
 	.stop_stats = siena_stop_nic_stats,
-- 
1.7.7.6


>From bb3685bcce397839fa484bd9845b8fd310a3fdaf Mon Sep 17 00:00:00 2001
From: Daniel Pieczko <dpieczko@solarflare.com>
Date: Wed, 17 Oct 2012 13:21:23 +0100
Subject: [PATCH 04/10] sfc: lock TX queues when calling netif_device_detach()

[ Upstream commit c2f3b8e3a44b6fe9e36704e30157ebe1a88c08b1 ]

The assertion of netif_device_present() at the top of
efx_hard_start_xmit() may fail if we don't do this.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
[bwh: Backported to 3.2: adjust context]
---
 drivers/net/ethernet/sfc/efx.c      |    4 ++--
 drivers/net/ethernet/sfc/efx.h      |   13 +++++++++++++
 drivers/net/ethernet/sfc/selftest.c |    2 +-
 3 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index aa20047..34e51f3 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2137,7 +2137,7 @@ int efx_reset(struct efx_nic *efx, enum reset_type method)
 	netif_info(efx, drv, efx->net_dev, "resetting (%s)\n",
 		   RESET_TYPE(method));
 
-	netif_device_detach(efx->net_dev);
+	efx_device_detach_sync(efx);
 	efx_reset_down(efx, method);
 
 	rc = efx->type->reset(efx, method);
@@ -2585,7 +2585,7 @@ static int efx_pm_freeze(struct device *dev)
 
 	efx->state = STATE_FINI;
 
-	netif_device_detach(efx->net_dev);
+	efx_device_detach_sync(efx);
 
 	efx_stop_all(efx);
 	efx_fini_channels(efx);
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 1355245..55e72af 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -149,4 +149,17 @@ extern void efx_link_status_changed(struct efx_nic *efx);
 extern void efx_link_set_advertising(struct efx_nic *efx, u32);
 extern void efx_link_set_wanted_fc(struct efx_nic *efx, u8);
 
+static inline void efx_device_detach_sync(struct efx_nic *efx)
+{
+	struct net_device *dev = efx->net_dev;
+
+	/* Lock/freeze all TX queues so that we can be sure the
+	 * TX scheduler is stopped when we're done and before
+	 * netif_device_present() becomes false.
+	 */
+	netif_tx_lock(dev);
+	netif_device_detach(dev);
+	netif_tx_unlock(dev);
+}
+
 #endif /* EFX_EFX_H */
diff --git a/drivers/net/ethernet/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
index 822f6c2..4907885 100644
--- a/drivers/net/ethernet/sfc/selftest.c
+++ b/drivers/net/ethernet/sfc/selftest.c
@@ -698,7 +698,7 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 	/* Detach the device so the kernel doesn't transmit during the
 	 * loopback test and the watchdog timeout doesn't fire.
 	 */
-	netif_device_detach(efx->net_dev);
+	efx_device_detach_sync(efx);
 
 	mutex_lock(&efx->mac_lock);
 	if (efx->loopback_modes) {
-- 
1.7.7.6


>From 14c6eed2e4c9405d4585f7419f2401e68141b509 Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 1 Dec 2012 02:21:17 +0000
Subject: [PATCH 05/10] sfc: Fix timekeeping in efx_mcdi_poll()

[ Upstream commit ebf98e797b4e26ad52ace1511a0b503ee60a6cd4 ]

efx_mcdi_poll() uses get_seconds() to read the current time and to
implement a polling timeout.  The use of this function was chosen
partly because it could easily be replaced in a co-sim environment
with a macro that read the simulated time.

Unfortunately the real get_seconds() returns the system time (real
time) which is subject to adjustment by e.g. ntpd.  If the system time
is adjusted forward during a polled MCDI operation, the effective
timeout can be shorter than the intended 10 seconds, resulting in a
spurious failure.  It is also possible for a backward adjustment to
delay detection of a areal failure.

Use jiffies instead, and change MCDI_RPC_TIMEOUT to be denominated in
jiffies.  Also correct rounding of the timeout: check time > finish
(or rather time_after(time, finish)) and not time >= finish.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
[bwh: Backported to 3.2: adjust context]
---
 drivers/net/ethernet/sfc/mcdi.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 85e070e..c1000ce 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -30,7 +30,7 @@
 #define REBOOT_FLAG_PORT0 0x3f8
 #define REBOOT_FLAG_PORT1 0x3fc
 
-#define MCDI_RPC_TIMEOUT       10 /*seconds */
+#define MCDI_RPC_TIMEOUT       (10 * HZ)
 
 #define MCDI_PDU(efx)							\
 	(efx_port_num(efx) ? CMD_PDU_PORT1 : CMD_PDU_PORT0)
@@ -120,7 +120,7 @@ static void efx_mcdi_copyout(struct efx_nic *efx, u8 *outbuf, size_t outlen)
 static int efx_mcdi_poll(struct efx_nic *efx)
 {
 	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
-	unsigned int time, finish;
+	unsigned long time, finish;
 	unsigned int respseq, respcmd, error;
 	unsigned int pdu = FR_CZ_MC_TREG_SMEM + MCDI_PDU(efx);
 	unsigned int rc, spins;
@@ -136,7 +136,7 @@ static int efx_mcdi_poll(struct efx_nic *efx)
 	 * and poll once a jiffy (approximately)
 	 */
 	spins = TICK_USEC;
-	finish = get_seconds() + MCDI_RPC_TIMEOUT;
+	finish = jiffies + MCDI_RPC_TIMEOUT;
 
 	while (1) {
 		if (spins != 0) {
@@ -146,7 +146,7 @@ static int efx_mcdi_poll(struct efx_nic *efx)
 			schedule_timeout_uninterruptible(1);
 		}
 
-		time = get_seconds();
+		time = jiffies;
 
 		rmb();
 		efx_readd(efx, &reg, pdu);
@@ -158,7 +158,7 @@ static int efx_mcdi_poll(struct efx_nic *efx)
 		    EFX_DWORD_FIELD(reg, MCDI_HEADER_RESPONSE))
 			break;
 
-		if (time >= finish)
+		if (time_after(time, finish))
 			return -ETIMEDOUT;
 	}
 
@@ -250,7 +250,7 @@ static int efx_mcdi_await_completion(struct efx_nic *efx)
 	if (wait_event_timeout(
 		    mcdi->wq,
 		    atomic_read(&mcdi->state) == MCDI_STATE_COMPLETED,
-		    msecs_to_jiffies(MCDI_RPC_TIMEOUT * 1000)) == 0)
+		    MCDI_RPC_TIMEOUT) == 0)
 		return -ETIMEDOUT;
 
 	/* Check if efx_mcdi_set_mode() switched us back to polled completions.
-- 
1.7.7.6


>From f65c13f740d7e4fd37573b403703f9977e80f39b Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 20 Dec 2012 18:48:20 +0000
Subject: [PATCH 06/10] sfc: Properly sync RX DMA buffer when it is not the
 last in the page

[ Upstream commit 3a68f19d7afb80f548d016effbc6ed52643a8085 ]

We may currently allocate two RX DMA buffers to a page, and only unmap
the page when the second is completed.  We do not sync the first RX
buffer to be completed; this can result in packet loss or corruption
if the last RX buffer completed in a NAPI poll is the first in a page
and is not DMA-coherent.  (In the middle of a NAPI poll, we will
handle the following RX completion and unmap the page *before* looking
at the content of the first buffer.)

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
[bwh: Backported to 3.2: adjust context]
---
 drivers/net/ethernet/sfc/rx.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 5ef4cc0..b4d3cd5 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -246,7 +246,8 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 }
 
 static void efx_unmap_rx_buffer(struct efx_nic *efx,
-				struct efx_rx_buffer *rx_buf)
+				struct efx_rx_buffer *rx_buf,
+				unsigned int used_len)
 {
 	if (rx_buf->is_page && rx_buf->u.page) {
 		struct efx_rx_page_state *state;
@@ -257,6 +258,10 @@ static void efx_unmap_rx_buffer(struct efx_nic *efx,
 				       state->dma_addr,
 				       efx_rx_buf_size(efx),
 				       PCI_DMA_FROMDEVICE);
+		} else if (used_len) {
+			dma_sync_single_for_cpu(&efx->pci_dev->dev,
+						rx_buf->dma_addr, used_len,
+						DMA_FROM_DEVICE);
 		}
 	} else if (!rx_buf->is_page && rx_buf->u.skb) {
 		pci_unmap_single(efx->pci_dev, rx_buf->dma_addr,
@@ -279,7 +284,7 @@ static void efx_free_rx_buffer(struct efx_nic *efx,
 static void efx_fini_rx_buffer(struct efx_rx_queue *rx_queue,
 			       struct efx_rx_buffer *rx_buf)
 {
-	efx_unmap_rx_buffer(rx_queue->efx, rx_buf);
+	efx_unmap_rx_buffer(rx_queue->efx, rx_buf, 0);
 	efx_free_rx_buffer(rx_queue->efx, rx_buf);
 }
 
@@ -550,10 +555,10 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 		goto out;
 	}
 
-	/* Release card resources - assumes all RX buffers consumed in-order
-	 * per RX queue
+	/* Release and/or sync DMA mapping - assumes all RX buffers
+	 * consumed in-order per RX queue
 	 */
-	efx_unmap_rx_buffer(efx, rx_buf);
+	efx_unmap_rx_buffer(efx, rx_buf, len);
 
 	/* Prefetch nice and early so data will (hopefully) be in cache by
 	 * the time we look at it.
-- 
1.7.7.6


>From 0640d519e24ca06bb11a4d37d07cf42f0958f67d Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 10 Jan 2013 23:51:54 +0000
Subject: [PATCH 07/10] sfc: Fix efx_rx_buf_offset() in the presence of
 swiotlb

[ Upstream commits 06e63c57acbb1df7c35ebe846ae416a8b88dfafa,
  b590ace09d51cd39744e0f7662c5e4a0d1b5d952 and
  c73e787a8db9117d59b5180baf83203a42ecadca ]

We assume that the mapping between DMA and virtual addresses is done
on whole pages, so we can find the page offset of an RX buffer using
the lower bits of the DMA address.  However, swiotlb maps in units of
2K, breaking this assumption.

Add an explicit page_offset field to struct efx_rx_buffer.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
[bwh: Backported to 3.2: adjust context]
---
 drivers/net/ethernet/sfc/net_driver.h |    4 +++-
 drivers/net/ethernet/sfc/rx.c         |   10 +++++-----
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 9e2e802..8bcb8fd 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -213,6 +213,7 @@ struct efx_tx_queue {
  *	If both this and page are %NULL, the buffer slot is currently free.
  * @page: The associated page buffer, if any.
  *	If both this and skb are %NULL, the buffer slot is currently free.
+ * @page_offset: Offset within page. Valid iff @flags & %EFX_RX_BUF_PAGE.
  * @len: Buffer length, in bytes.
  * @is_page: Indicates if @page is valid. If false, @skb is valid.
  */
@@ -222,7 +223,8 @@ struct efx_rx_buffer {
 		struct sk_buff *skb;
 		struct page *page;
 	} u;
-	unsigned int len;
+	u16 page_offset;
+	u16 len;
 	bool is_page;
 };
 
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index b4d3cd5..9ce8665 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -95,11 +95,7 @@ static unsigned int rx_refill_limit = 95;
 static inline unsigned int efx_rx_buf_offset(struct efx_nic *efx,
 					     struct efx_rx_buffer *buf)
 {
-	/* Offset is always within one page, so we don't need to consider
-	 * the page order.
-	 */
-	return (((__force unsigned long) buf->dma_addr & (PAGE_SIZE - 1)) +
-		efx->type->rx_buffer_hash_size);
+	return buf->page_offset + efx->type->rx_buffer_hash_size;
 }
 static inline unsigned int efx_rx_buf_size(struct efx_nic *efx)
 {
@@ -194,6 +190,7 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 	struct efx_rx_buffer *rx_buf;
 	struct page *page;
 	void *page_addr;
+	unsigned int page_offset;
 	struct efx_rx_page_state *state;
 	dma_addr_t dma_addr;
 	unsigned index, count;
@@ -220,12 +217,14 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 
 		page_addr += sizeof(struct efx_rx_page_state);
 		dma_addr += sizeof(struct efx_rx_page_state);
+		page_offset = sizeof(struct efx_rx_page_state);
 
 	split:
 		index = rx_queue->added_count & rx_queue->ptr_mask;
 		rx_buf = efx_rx_buffer(rx_queue, index);
 		rx_buf->dma_addr = dma_addr + EFX_PAGE_IP_ALIGN;
 		rx_buf->u.page = page;
+		rx_buf->page_offset = page_offset + EFX_PAGE_IP_ALIGN;
 		rx_buf->len = efx->rx_buffer_len - EFX_PAGE_IP_ALIGN;
 		rx_buf->is_page = true;
 		++rx_queue->added_count;
@@ -237,6 +236,7 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 			get_page(page);
 			dma_addr += (PAGE_SIZE >> 1);
 			page_addr += (PAGE_SIZE >> 1);
+			page_offset += (PAGE_SIZE >> 1);
 			++count;
 			goto split;
 		}
-- 
1.7.7.6


>From be376cf7a30276fa7903f234fe666a5df9032477 Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 28 Jan 2013 19:01:06 +0000
Subject: [PATCH 08/10] sfc: Detach net device when stopping queues for
 reconfiguration

[ Upstream commit 29c69a4882641285a854d6d03ca5adbba68c0034 ]

We must only ever stop TX queues when they are full or the net device
is not 'ready' so far as the net core, and specifically the watchdog,
is concerned.  Otherwise, the watchdog may fire *immediately* if no
packets have been added to the queue in the last 5 seconds.

The device is ready if all the following are true:

(a) It has a qdisc
(b) It is marked present
(c) It is running
(d) The link is reported up

(a) and (c) are normally true, and must not be changed by a driver.
(d) is under our control, but fake link changes may disturb userland.
This leaves (b).  We already mark the device absent during reset
and self-test, but we need to do the same during MTU changes and ring
reallocation.  We don't need to do this when the device is brought
down because then (c) is already false.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
[bwh: Backported to 3.2: adjust context]
---
 drivers/net/ethernet/sfc/efx.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 34e51f3..5d5a05f 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -719,6 +719,7 @@ efx_realloc_channels(struct efx_nic *efx, u32 rxq_entries, u32 txq_entries)
 	unsigned i;
 	int rc;
 
+	efx_device_detach_sync(efx);
 	efx_stop_all(efx);
 	efx_fini_channels(efx);
 
@@ -762,6 +763,7 @@ out:
 
 	efx_init_channels(efx);
 	efx_start_all(efx);
+	netif_device_attach(efx->net_dev);
 	return rc;
 
 rollback:
@@ -1530,8 +1532,12 @@ static void efx_stop_all(struct efx_nic *efx)
 	/* Flush efx_mac_work(), refill_workqueue, monitor_work */
 	efx_flush_all(efx);
 
-	/* Stop the kernel transmit interface late, so the watchdog
-	 * timer isn't ticking over the flush */
+	/* Stop the kernel transmit interface.  This is only valid if
+	 * the device is stopped or detached; otherwise the watchdog
+	 * may fire immediately.
+	 */
+	WARN_ON(netif_running(efx->net_dev) &&
+		netif_device_present(efx->net_dev));
 	if (efx_dev_registered(efx)) {
 		netif_tx_stop_all_queues(efx->net_dev);
 		netif_tx_lock_bh(efx->net_dev);
@@ -1832,10 +1838,11 @@ static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
 	if (new_mtu > EFX_MAX_MTU)
 		return -EINVAL;
 
-	efx_stop_all(efx);
-
 	netif_dbg(efx, drv, efx->net_dev, "changing MTU to %d\n", new_mtu);
 
+	efx_device_detach_sync(efx);
+	efx_stop_all(efx);
+
 	efx_fini_channels(efx);
 
 	mutex_lock(&efx->mac_lock);
@@ -1848,6 +1855,7 @@ static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
 	efx_init_channels(efx);
 
 	efx_start_all(efx);
+	netif_device_attach(efx->net_dev);
 	return rc;
 }
 
-- 
1.7.7.6


>From 8e65b664711374bce098b585c74d82cadb0fd53b Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 5 Mar 2013 01:03:47 +0000
Subject: [PATCH 09/10] sfc: Disable soft interrupt handling during
 efx_device_detach_sync()

[ Upstream commit 35205b211c8d17a8a0b5e8926cb7c73e9a7ef1ad ]

efx_device_detach_sync() locks all TX queues before marking the device
detached and thus disabling further TX scheduling.  But it can still
be interrupted by TX completions which then result in TX scheduling in
soft interrupt context.  This will deadlock when it tries to acquire
a TX queue lock that efx_device_detach_sync() already acquired.

To avoid deadlock, we must use netif_tx_{,un}lock_bh().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 55e72af..9668d29 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -157,9 +157,9 @@ static inline void efx_device_detach_sync(struct efx_nic *efx)
 	 * TX scheduler is stopped when we're done and before
 	 * netif_device_present() becomes false.
 	 */
-	netif_tx_lock(dev);
+	netif_tx_lock_bh(dev);
 	netif_device_detach(dev);
-	netif_tx_unlock(dev);
+	netif_tx_unlock_bh(dev);
 }
 
 #endif /* EFX_EFX_H */
-- 
1.7.7.6


>From 43390a6066d78d5e51b80b3592686c42654487cd Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 27 Feb 2013 16:50:38 +0000
Subject: [PATCH 10/10] sfc: Only use TX push if a single descriptor is to be
 written

[ Upstream commit fae8563b25f73dc584a07bcda7a82750ff4f7672 ]

Using TX push when notifying the NIC of multiple new descriptors in
the ring will very occasionally cause the TX DMA engine to re-use an
old descriptor.  This can result in a duplicated or partly duplicated
packet (new headers with old data), or an IOMMU page fault.  This does
not happen when the pushed descriptor is the only one written.

TX push also provides little latency benefit when a packet requires
more than one descriptor.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/nic.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 9cca2a6..2e9ca10 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -371,7 +371,8 @@ efx_may_push_tx_desc(struct efx_tx_queue *tx_queue, unsigned int write_count)
 		return false;
 
 	tx_queue->empty_read_count = 0;
-	return ((empty_read_count ^ write_count) & ~EFX_EMPTY_COUNT_VALID) == 0;
+	return ((empty_read_count ^ write_count) & ~EFX_EMPTY_COUNT_VALID) == 0
+		&& tx_queue->write_count - write_count == 1;
 }
 
 /* For each entry inserted into the software descriptor ring, create a
-- 
1.7.7.6


--=-JoKlq4P+CI6IELemF1bE
Content-Type: application/mbox; name="sfc_3.4.mbox"
Content-Disposition: attachment; filename="sfc_3.4.mbox"
Content-Transfer-Encoding: 7bit

>From 42405aab44d07ecaa13b38eac9e6fd0cd4b2e68d Mon Sep 17 00:00:00 2001
From: Stuart Hodgson <smhodgson@solarflare.com>
Date: Fri, 30 Mar 2012 13:04:51 +0100
Subject: [PATCH 01/16] sfc: Do not attempt to flush queues if DMA is disabled

[ Upstream commit 3dca9d2dc285faf1910d405b65df845cab061356 ]

efx_nic_fatal_interrupt() disables DMA before scheduling a reset.
After this, we need not and *cannot* flush queues.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |   33 +++++++++++++++++++--------------
 1 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 954b885..e7ac397 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -656,25 +656,30 @@ static void efx_stop_datapath(struct efx_nic *efx)
 	struct efx_channel *channel;
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
+	struct pci_dev *dev = efx->pci_dev;
 	int rc;
 
 	EFX_ASSERT_RESET_SERIALISED(efx);
 	BUG_ON(efx->port_enabled);
 
-	rc = efx_nic_flush_queues(efx);
-	if (rc && EFX_WORKAROUND_7803(efx)) {
-		/* Schedule a reset to recover from the flush failure. The
-		 * descriptor caches reference memory we're about to free,
-		 * but falcon_reconfigure_mac_wrapper() won't reconnect
-		 * the MACs because of the pending reset. */
-		netif_err(efx, drv, efx->net_dev,
-			  "Resetting to recover from flush failure\n");
-		efx_schedule_reset(efx, RESET_TYPE_ALL);
-	} else if (rc) {
-		netif_err(efx, drv, efx->net_dev, "failed to flush queues\n");
-	} else {
-		netif_dbg(efx, drv, efx->net_dev,
-			  "successfully flushed all queues\n");
+	/* Only perform flush if dma is enabled */
+	if (dev->is_busmaster) {
+		rc = efx_nic_flush_queues(efx);
+
+		if (rc && EFX_WORKAROUND_7803(efx)) {
+			/* Schedule a reset to recover from the flush failure. The
+			 * descriptor caches reference memory we're about to free,
+			 * but falcon_reconfigure_mac_wrapper() won't reconnect
+			 * the MACs because of the pending reset. */
+			netif_err(efx, drv, efx->net_dev,
+				  "Resetting to recover from flush failure\n");
+			efx_schedule_reset(efx, RESET_TYPE_ALL);
+		} else if (rc) {
+			netif_err(efx, drv, efx->net_dev, "failed to flush queues\n");
+		} else {
+			netif_dbg(efx, drv, efx->net_dev,
+				  "successfully flushed all queues\n");
+		}
 	}
 
 	efx_for_each_channel(channel, efx) {
-- 
1.7.7.6


>From 3b508f67e39f60c0ae25c1f14cae2553e0bda68e Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 7 Sep 2012 00:58:10 +0100
Subject: [PATCH 02/16] sfc: Convert firmware subtypes to native byte order in
 efx_mcdi_get_board_cfg()

[ Upstream commit bfeed902946a31692e7a24ed355b6d13ac37d014 ]

On big-endian systems the MTD partition names currently have mangled
subtype numbers and are not recognised by the firmware update tool
(sfupdate).

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 17b6463..b49012d 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -641,9 +641,8 @@ int efx_mcdi_get_board_cfg(struct efx_nic *efx, u8 *mac_address,
 			   u16 *fw_subtype_list, u32 *capabilities)
 {
 	uint8_t outbuf[MC_CMD_GET_BOARD_CFG_OUT_LENMIN];
-	size_t outlen;
+	size_t outlen, offset, i;
 	int port_num = efx_port_num(efx);
-	int offset;
 	int rc;
 
 	BUILD_BUG_ON(MC_CMD_GET_BOARD_CFG_IN_LEN != 0);
@@ -663,11 +662,16 @@ int efx_mcdi_get_board_cfg(struct efx_nic *efx, u8 *mac_address,
 		: MC_CMD_GET_BOARD_CFG_OUT_MAC_ADDR_BASE_PORT0_OFST;
 	if (mac_address)
 		memcpy(mac_address, outbuf + offset, ETH_ALEN);
-	if (fw_subtype_list)
-		memcpy(fw_subtype_list,
-		       outbuf + MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_OFST,
-		       MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_MINNUM *
-		       sizeof(fw_subtype_list[0]));
+	if (fw_subtype_list) {
+		offset = MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_OFST;
+		for (i = 0;
+		     i < MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_MINNUM;
+		     i++) {
+			fw_subtype_list[i] =
+				le16_to_cpup((__le16 *)(outbuf + offset));
+			offset += 2;
+		}
+	}
 	if (capabilities) {
 		if (port_num)
 			*capabilities = MCDI_DWORD(outbuf,
-- 
1.7.7.6


>From 5b00f2e28370304cdc17d9a2983263b6dd95c4f2 Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 11 Sep 2012 21:37:36 +0100
Subject: [PATCH 03/16] sfc: Add parentheses around use of bitfield macro
 arguments

[ Upstream commit 9724a8504c875145f5a513bb8eca50671cee23b4 ]

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/bitfield.h |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/sfc/bitfield.h b/drivers/net/ethernet/sfc/bitfield.h
index b26a954..5400a33 100644
--- a/drivers/net/ethernet/sfc/bitfield.h
+++ b/drivers/net/ethernet/sfc/bitfield.h
@@ -120,10 +120,10 @@ typedef union efx_oword {
  * [0,high-low), with garbage in bits [high-low+1,...).
  */
 #define EFX_EXTRACT_NATIVE(native_element, min, max, low, high)		\
-	(((low > max) || (high < min)) ? 0 :				\
-	 ((low > min) ?							\
-	  ((native_element) >> (low - min)) :				\
-	  ((native_element) << (min - low))))
+	((low) > (max) || (high) < (min) ? 0 :				\
+	 (low) > (min) ?						\
+	 (native_element) >> ((low) - (min)) :				\
+	 (native_element) << ((min) - (low)))
 
 /*
  * Extract bit field portion [low,high) from the 64-bit little-endian
@@ -142,27 +142,27 @@ typedef union efx_oword {
 #define EFX_EXTRACT_OWORD64(oword, low, high)				\
 	((EFX_EXTRACT64((oword).u64[0], 0, 63, low, high) |		\
 	  EFX_EXTRACT64((oword).u64[1], 64, 127, low, high)) &		\
-	 EFX_MASK64(high + 1 - low))
+	 EFX_MASK64((high) + 1 - (low)))
 
 #define EFX_EXTRACT_QWORD64(qword, low, high)				\
 	(EFX_EXTRACT64((qword).u64[0], 0, 63, low, high) &		\
-	 EFX_MASK64(high + 1 - low))
+	 EFX_MASK64((high) + 1 - (low)))
 
 #define EFX_EXTRACT_OWORD32(oword, low, high)				\
 	((EFX_EXTRACT32((oword).u32[0], 0, 31, low, high) |		\
 	  EFX_EXTRACT32((oword).u32[1], 32, 63, low, high) |		\
 	  EFX_EXTRACT32((oword).u32[2], 64, 95, low, high) |		\
 	  EFX_EXTRACT32((oword).u32[3], 96, 127, low, high)) &		\
-	 EFX_MASK32(high + 1 - low))
+	 EFX_MASK32((high) + 1 - (low)))
 
 #define EFX_EXTRACT_QWORD32(qword, low, high)				\
 	((EFX_EXTRACT32((qword).u32[0], 0, 31, low, high) |		\
 	  EFX_EXTRACT32((qword).u32[1], 32, 63, low, high)) &		\
-	 EFX_MASK32(high + 1 - low))
+	 EFX_MASK32((high) + 1 - (low)))
 
 #define EFX_EXTRACT_DWORD(dword, low, high)			\
 	(EFX_EXTRACT32((dword).u32[0], 0, 31, low, high) &	\
-	 EFX_MASK32(high + 1 - low))
+	 EFX_MASK32((high) + 1 - (low)))
 
 #define EFX_OWORD_FIELD64(oword, field)				\
 	EFX_EXTRACT_OWORD64(oword, EFX_LOW_BIT(field),		\
@@ -442,10 +442,10 @@ typedef union efx_oword {
 	cpu_to_le32(EFX_INSERT_NATIVE(min, max, low, high, value))
 
 #define EFX_INPLACE_MASK64(min, max, low, high)				\
-	EFX_INSERT64(min, max, low, high, EFX_MASK64(high + 1 - low))
+	EFX_INSERT64(min, max, low, high, EFX_MASK64((high) + 1 - (low)))
 
 #define EFX_INPLACE_MASK32(min, max, low, high)				\
-	EFX_INSERT32(min, max, low, high, EFX_MASK32(high + 1 - low))
+	EFX_INSERT32(min, max, low, high, EFX_MASK32((high) + 1 - (low)))
 
 #define EFX_SET_OWORD64(oword, low, high, value) do {			\
 	(oword).u64[0] = (((oword).u64[0]				\
-- 
1.7.7.6


>From bf3ab149c6086c5b1c6759e03f4d173241fc22eb Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 11 Sep 2012 21:46:41 +0100
Subject: [PATCH 04/16] sfc: Fix MCDI structure field lookup

[ Upstream commit 0a6e5008a9df678b48f8d4e57601aa4270df6c14 ]

The least significant bit number (LBN) of a field within an MCDI
structure is counted from the start of the structure, not the
containing dword.  In MCDI_ARRAY_FIELD() we need to mask it rather
than using the usual EFX_DWORD_FIELD() macro.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.h |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index 0bdf3e3..96f43d2 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -107,11 +107,13 @@ extern void efx_mcdi_sensor_event(struct efx_nic *efx, efx_qword_t *ev);
 #define MCDI_EVENT_FIELD(_ev, _field)			\
 	EFX_QWORD_FIELD(_ev, MCDI_EVENT_ ## _field)
 #define MCDI_ARRAY_FIELD(_buf, _field1, _type, _index, _field2)		\
-	EFX_DWORD_FIELD(						\
+	EFX_EXTRACT_DWORD(						\
 		*((efx_dword_t *)					\
 		  (MCDI_ARRAY_PTR(_buf, _field1, _type, _index) +	\
 		   (MC_CMD_ ## _type ## _TYPEDEF_ ## _field2 ## _OFST & ~3))), \
-		MC_CMD_ ## _type ## _TYPEDEF_ ## _field2)
+		MC_CMD_ ## _type ## _TYPEDEF_ ## _field2 ## _LBN & 0x1f, \
+		(MC_CMD_ ## _type ## _TYPEDEF_ ## _field2 ## _LBN & 0x1f) + \
+		MC_CMD_ ## _type ## _TYPEDEF_ ## _field2 ## _WIDTH - 1)
 
 extern void efx_mcdi_print_fwver(struct efx_nic *efx, char *buf, size_t len);
 extern int efx_mcdi_drv_attach(struct efx_nic *efx, bool driver_operating,
-- 
1.7.7.6


>From b6c1b842889040734dd3ec8324debc8f2686e63a Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 6 Sep 2012 16:52:31 +0100
Subject: [PATCH 05/16] sfc: Really disable flow control while flushing

[ Upstream commit d5e8cc6c946e0857826dcfbb3585068858445bfe ]

Receiving pause frames can block TX queue flushes.  Earlier changes
work around this by reconfiguring the MAC during flushes for VFs, but
during flushes for the PF we would only change the fc_disable counter.
Unless the MAC is reconfigured for some other reason during the flush
(which I would not expect to happen) this had no effect at all.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/falcon.c      |    2 ++
 drivers/net/ethernet/sfc/net_driver.h  |    2 ++
 drivers/net/ethernet/sfc/nic.c         |    3 +--
 drivers/net/ethernet/sfc/nic.h         |    2 ++
 drivers/net/ethernet/sfc/siena.c       |   15 ++++++++++++++-
 drivers/net/ethernet/sfc/siena_sriov.c |    6 ++----
 6 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 3a1ca2b..6dfcbb7 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -1765,6 +1765,7 @@ const struct efx_nic_type falcon_a1_nic_type = {
 	.remove_port = falcon_remove_port,
 	.handle_global_event = falcon_handle_global_event,
 	.prepare_flush = falcon_prepare_flush,
+	.finish_flush = efx_port_dummy_op_void,
 	.update_stats = falcon_update_nic_stats,
 	.start_stats = falcon_start_nic_stats,
 	.stop_stats = falcon_stop_nic_stats,
@@ -1807,6 +1808,7 @@ const struct efx_nic_type falcon_b0_nic_type = {
 	.remove_port = falcon_remove_port,
 	.handle_global_event = falcon_handle_global_event,
 	.prepare_flush = falcon_prepare_flush,
+	.finish_flush = efx_port_dummy_op_void,
 	.update_stats = falcon_update_nic_stats,
 	.start_stats = falcon_start_nic_stats,
 	.stop_stats = falcon_stop_nic_stats,
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index f0385e1..49bf99a 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -887,6 +887,7 @@ static inline unsigned int efx_port_num(struct efx_nic *efx)
  * @remove_port: Free resources allocated by probe_port()
  * @handle_global_event: Handle a "global" event (may be %NULL)
  * @prepare_flush: Prepare the hardware for flushing the DMA queues
+ * @finish_flush: Clean up after flushing the DMA queues
  * @update_stats: Update statistics not provided by event handling
  * @start_stats: Start the regular fetching of statistics
  * @stop_stats: Stop the regular fetching of statistics
@@ -933,6 +934,7 @@ struct efx_nic_type {
 	void (*remove_port)(struct efx_nic *efx);
 	bool (*handle_global_event)(struct efx_channel *channel, efx_qword_t *);
 	void (*prepare_flush)(struct efx_nic *efx);
+	void (*finish_flush)(struct efx_nic *efx);
 	void (*update_stats)(struct efx_nic *efx);
 	void (*start_stats)(struct efx_nic *efx);
 	void (*stop_stats)(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 4a9a5be..95f19af 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -681,7 +681,6 @@ int efx_nic_flush_queues(struct efx_nic *efx)
 	struct efx_tx_queue *tx_queue;
 	int rc = 0;
 
-	efx->fc_disable++;
 	efx->type->prepare_flush(efx);
 
 	efx_for_each_channel(channel, efx) {
@@ -743,7 +742,7 @@ int efx_nic_flush_queues(struct efx_nic *efx)
 		atomic_set(&efx->rxq_flush_outstanding, 0);
 	}
 
-	efx->fc_disable--;
+	efx->type->finish_flush(efx);
 
 	return rc;
 }
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index f48ccf6..bbdfcd6 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -316,6 +316,8 @@ static inline int efx_nic_irq_test_irq_cpu(struct efx_nic *efx)
 
 /* Global Resources */
 extern int efx_nic_flush_queues(struct efx_nic *efx);
+extern void siena_prepare_flush(struct efx_nic *efx);
+extern void siena_finish_flush(struct efx_nic *efx);
 extern void falcon_start_nic_stats(struct efx_nic *efx);
 extern void falcon_stop_nic_stats(struct efx_nic *efx);
 extern void falcon_setup_xaui(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 9f8d7ce..7b87266 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -125,6 +125,18 @@ static void siena_remove_port(struct efx_nic *efx)
 	efx_nic_free_buffer(efx, &efx->stats_buffer);
 }
 
+void siena_prepare_flush(struct efx_nic *efx)
+{
+	if (efx->fc_disable++ == 0)
+		efx_mcdi_set_mac(efx);
+}
+
+void siena_finish_flush(struct efx_nic *efx)
+{
+	if (--efx->fc_disable == 0)
+		efx_mcdi_set_mac(efx);
+}
+
 static const struct efx_nic_register_test siena_register_tests[] = {
 	{ FR_AZ_ADR_REGION,
 	  EFX_OWORD32(0x0003FFFF, 0x0003FFFF, 0x0003FFFF, 0x0003FFFF) },
@@ -637,7 +649,8 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.reset = siena_reset_hw,
 	.probe_port = siena_probe_port,
 	.remove_port = siena_remove_port,
-	.prepare_flush = efx_port_dummy_op_void,
+	.prepare_flush = siena_prepare_flush,
+	.finish_flush = siena_finish_flush,
 	.update_stats = siena_update_nic_stats,
 	.start_stats = siena_start_nic_stats,
 	.stop_stats = siena_stop_nic_stats,
diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index 9cb3b84..78f5408 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -688,8 +688,7 @@ static int efx_vfdi_fini_all_queues(struct efx_vf *vf)
 		return VFDI_RC_ENOMEM;
 
 	rtnl_lock();
-	if (efx->fc_disable++ == 0)
-		efx_mcdi_set_mac(efx);
+	siena_prepare_flush(efx);
 	rtnl_unlock();
 
 	/* Flush all the initialized queues */
@@ -726,8 +725,7 @@ static int efx_vfdi_fini_all_queues(struct efx_vf *vf)
 	}
 
 	rtnl_lock();
-	if (--efx->fc_disable == 0)
-		efx_mcdi_set_mac(efx);
+	siena_finish_flush(efx);
 	rtnl_unlock();
 
 	/* Irrespective of success/failure, fini the queues */
-- 
1.7.7.6


>From 8a0a0f513c7917dd1692fcbb05282beabae3e457 Mon Sep 17 00:00:00 2001
From: Daniel Pieczko <dpieczko@solarflare.com>
Date: Tue, 2 Oct 2012 13:36:18 +0100
Subject: [PATCH 06/16] sfc: Work-around flush timeout when flushes have
 completed

[ Upstream commit 525d9e824018cd7cc8d8d44832ddcd363abfe6e1 ]

We sometimes hit a "failed to flush" timeout on some TX queues, but the
flushes have completed and the flush completion events seem to go missing.
In this case, we can check the TX_DESC_PTR_TBL register and drain the
queues if the flushes had finished.

[bwh: Minor fixes to coding style]
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h |    1 +
 drivers/net/ethernet/sfc/nic.c        |   56 ++++++++++++++++++++++++++++++--
 2 files changed, 53 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 49bf99a..6986be0 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -194,6 +194,7 @@ struct efx_tx_queue {
 	/* Members shared between paths and sometimes updated */
 	unsigned int empty_read_count ____cacheline_aligned_in_smp;
 #define EFX_EMPTY_COUNT_VALID 0x80000000
+	atomic_t flush_outstanding;
 };
 
 /**
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 95f19af..3a59a73 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -73,6 +73,8 @@
 	_EFX_CHANNEL_MAGIC(_EFX_CHANNEL_MAGIC_TX_DRAIN,			\
 			   (_tx_queue)->queue)
 
+static void efx_magic_event(struct efx_channel *channel, u32 magic);
+
 /**************************************************************************
  *
  * Solarstorm hardware access
@@ -495,6 +497,9 @@ static void efx_flush_tx_queue(struct efx_tx_queue *tx_queue)
 	struct efx_nic *efx = tx_queue->efx;
 	efx_oword_t tx_flush_descq;
 
+	WARN_ON(atomic_read(&tx_queue->flush_outstanding));
+	atomic_set(&tx_queue->flush_outstanding, 1);
+
 	EFX_POPULATE_OWORD_2(tx_flush_descq,
 			     FRF_AZ_TX_FLUSH_DESCQ_CMD, 1,
 			     FRF_AZ_TX_FLUSH_DESCQ, tx_queue->queue);
@@ -670,6 +675,47 @@ static bool efx_flush_wake(struct efx_nic *efx)
 		 && atomic_read(&efx->rxq_flush_pending) > 0));
 }
 
+static bool efx_check_tx_flush_complete(struct efx_nic *efx)
+{
+	bool i = true;
+	efx_oword_t txd_ptr_tbl;
+	struct efx_channel *channel;
+	struct efx_tx_queue *tx_queue;
+
+	efx_for_each_channel(channel, efx) {
+		efx_for_each_channel_tx_queue(tx_queue, channel) {
+			efx_reado_table(efx, &txd_ptr_tbl,
+					FR_BZ_TX_DESC_PTR_TBL, tx_queue->queue);
+			if (EFX_OWORD_FIELD(txd_ptr_tbl,
+					    FRF_AZ_TX_DESCQ_FLUSH) ||
+			    EFX_OWORD_FIELD(txd_ptr_tbl,
+					    FRF_AZ_TX_DESCQ_EN)) {
+				netif_dbg(efx, hw, efx->net_dev,
+					  "flush did not complete on TXQ %d\n",
+					  tx_queue->queue);
+				i = false;
+			} else if (atomic_cmpxchg(&tx_queue->flush_outstanding,
+						  1, 0)) {
+				/* The flush is complete, but we didn't
+				 * receive a flush completion event
+				 */
+				netif_dbg(efx, hw, efx->net_dev,
+					  "flush complete on TXQ %d, so drain "
+					  "the queue\n", tx_queue->queue);
+				/* Don't need to increment drain_pending as it
+				 * has already been incremented for the queues
+				 * which did not drain
+				 */
+				efx_magic_event(channel,
+						EFX_CHANNEL_MAGIC_TX_DRAIN(
+							tx_queue));
+			}
+		}
+	}
+
+	return i;
+}
+
 /* Flush all the transmit queues, and continue flushing receive queues until
  * they're all flushed. Wait for the DRAIN events to be recieved so that there
  * are no more RX and TX events left on any channel. */
@@ -730,7 +776,8 @@ int efx_nic_flush_queues(struct efx_nic *efx)
 					     timeout);
 	}
 
-	if (atomic_read(&efx->drain_pending)) {
+	if (atomic_read(&efx->drain_pending) &&
+	    !efx_check_tx_flush_complete(efx)) {
 		netif_err(efx, hw, efx->net_dev, "failed to flush %d queues "
 			  "(rx %d+%d)\n", atomic_read(&efx->drain_pending),
 			  atomic_read(&efx->rxq_flush_outstanding),
@@ -1017,9 +1064,10 @@ efx_handle_tx_flush_done(struct efx_nic *efx, efx_qword_t *event)
 	if (qid < EFX_TXQ_TYPES * efx->n_tx_channels) {
 		tx_queue = efx_get_tx_queue(efx, qid / EFX_TXQ_TYPES,
 					    qid % EFX_TXQ_TYPES);
-
-		efx_magic_event(tx_queue->channel,
-				EFX_CHANNEL_MAGIC_TX_DRAIN(tx_queue));
+		if (atomic_cmpxchg(&tx_queue->flush_outstanding, 1, 0)) {
+			efx_magic_event(tx_queue->channel,
+					EFX_CHANNEL_MAGIC_TX_DRAIN(tx_queue));
+		}
 	}
 }
 
-- 
1.7.7.6


>From 4705dff243560360f616ee409cafa68382014a93 Mon Sep 17 00:00:00 2001
From: Daniel Pieczko <dpieczko@solarflare.com>
Date: Wed, 17 Oct 2012 13:21:23 +0100
Subject: [PATCH 07/16] sfc: lock TX queues when calling netif_device_detach()

[ Upstream commit c2f3b8e3a44b6fe9e36704e30157ebe1a88c08b1 ]

The assertion of netif_device_present() at the top of
efx_hard_start_xmit() may fail if we don't do this.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
[bwh: Backported to 3.4: adjust context]
---
 drivers/net/ethernet/sfc/efx.c      |    4 ++--
 drivers/net/ethernet/sfc/efx.h      |   13 +++++++++++++
 drivers/net/ethernet/sfc/selftest.c |    2 +-
 3 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index e7ac397..8c81d1c 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2224,7 +2224,7 @@ int efx_reset(struct efx_nic *efx, enum reset_type method)
 	netif_info(efx, drv, efx->net_dev, "resetting (%s)\n",
 		   RESET_TYPE(method));
 
-	netif_device_detach(efx->net_dev);
+	efx_device_detach_sync(efx);
 	efx_reset_down(efx, method);
 
 	rc = efx->type->reset(efx, method);
@@ -2718,7 +2718,7 @@ static int efx_pm_freeze(struct device *dev)
 
 	efx->state = STATE_FINI;
 
-	netif_device_detach(efx->net_dev);
+	efx_device_detach_sync(efx);
 
 	efx_stop_all(efx);
 	efx_stop_interrupts(efx, false);
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 70755c9..320cf7b 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -162,4 +162,17 @@ extern void efx_link_status_changed(struct efx_nic *efx);
 extern void efx_link_set_advertising(struct efx_nic *efx, u32);
 extern void efx_link_set_wanted_fc(struct efx_nic *efx, u8);
 
+static inline void efx_device_detach_sync(struct efx_nic *efx)
+{
+	struct net_device *dev = efx->net_dev;
+
+	/* Lock/freeze all TX queues so that we can be sure the
+	 * TX scheduler is stopped when we're done and before
+	 * netif_device_present() becomes false.
+	 */
+	netif_tx_lock(dev);
+	netif_device_detach(dev);
+	netif_tx_unlock(dev);
+}
+
 #endif /* EFX_EFX_H */
diff --git a/drivers/net/ethernet/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
index de4c006..0686791 100644
--- a/drivers/net/ethernet/sfc/selftest.c
+++ b/drivers/net/ethernet/sfc/selftest.c
@@ -735,7 +735,7 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 	/* Detach the device so the kernel doesn't transmit during the
 	 * loopback test and the watchdog timeout doesn't fire.
 	 */
-	netif_device_detach(efx->net_dev);
+	efx_device_detach_sync(efx);
 
 	mutex_lock(&efx->mac_lock);
 	if (efx->loopback_modes) {
-- 
1.7.7.6


>From c1e3e8c594bdb95e50a0c631b0d7c9dd656d36b9 Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 1 Dec 2012 02:21:17 +0000
Subject: [PATCH 08/16] sfc: Fix timekeeping in efx_mcdi_poll()

[ Upstream commit ebf98e797b4e26ad52ace1511a0b503ee60a6cd4 ]

efx_mcdi_poll() uses get_seconds() to read the current time and to
implement a polling timeout.  The use of this function was chosen
partly because it could easily be replaced in a co-sim environment
with a macro that read the simulated time.

Unfortunately the real get_seconds() returns the system time (real
time) which is subject to adjustment by e.g. ntpd.  If the system time
is adjusted forward during a polled MCDI operation, the effective
timeout can be shorter than the intended 10 seconds, resulting in a
spurious failure.  It is also possible for a backward adjustment to
delay detection of a areal failure.

Use jiffies instead, and change MCDI_RPC_TIMEOUT to be denominated in
jiffies.  Also correct rounding of the timeout: check time > finish
(or rather time_after(time, finish)) and not time >= finish.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index b49012d..7e39dcc 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -22,7 +22,7 @@
  **************************************************************************
  */
 
-#define MCDI_RPC_TIMEOUT       10 /*seconds */
+#define MCDI_RPC_TIMEOUT       (10 * HZ)
 
 #define MCDI_PDU(efx)							\
 	(efx_port_num(efx) ? MC_SMEM_P1_PDU_OFST : MC_SMEM_P0_PDU_OFST)
@@ -120,7 +120,7 @@ static void efx_mcdi_copyout(struct efx_nic *efx, u8 *outbuf, size_t outlen)
 static int efx_mcdi_poll(struct efx_nic *efx)
 {
 	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
-	unsigned int time, finish;
+	unsigned long time, finish;
 	unsigned int respseq, respcmd, error;
 	unsigned int pdu = FR_CZ_MC_TREG_SMEM + MCDI_PDU(efx);
 	unsigned int rc, spins;
@@ -136,7 +136,7 @@ static int efx_mcdi_poll(struct efx_nic *efx)
 	 * and poll once a jiffy (approximately)
 	 */
 	spins = TICK_USEC;
-	finish = get_seconds() + MCDI_RPC_TIMEOUT;
+	finish = jiffies + MCDI_RPC_TIMEOUT;
 
 	while (1) {
 		if (spins != 0) {
@@ -146,7 +146,7 @@ static int efx_mcdi_poll(struct efx_nic *efx)
 			schedule_timeout_uninterruptible(1);
 		}
 
-		time = get_seconds();
+		time = jiffies;
 
 		rmb();
 		efx_readd(efx, &reg, pdu);
@@ -158,7 +158,7 @@ static int efx_mcdi_poll(struct efx_nic *efx)
 		    EFX_DWORD_FIELD(reg, MCDI_HEADER_RESPONSE))
 			break;
 
-		if (time >= finish)
+		if (time_after(time, finish))
 			return -ETIMEDOUT;
 	}
 
@@ -250,7 +250,7 @@ static int efx_mcdi_await_completion(struct efx_nic *efx)
 	if (wait_event_timeout(
 		    mcdi->wq,
 		    atomic_read(&mcdi->state) == MCDI_STATE_COMPLETED,
-		    msecs_to_jiffies(MCDI_RPC_TIMEOUT * 1000)) == 0)
+		    MCDI_RPC_TIMEOUT) == 0)
 		return -ETIMEDOUT;
 
 	/* Check if efx_mcdi_set_mode() switched us back to polled completions.
-- 
1.7.7.6


>From 4d81714f936330473c8df1356060f20d3eca0c98 Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 4 Jul 2012 03:58:33 +0100
Subject: [PATCH 09/16] sfc: Disable VF queues during register self-test

[ Upstream commit d4f2cecce138c34960c467d0ae38a6d4bcd6af7b ]

Currently VF queues and drivers may remain active during this test.
This could cause memory corruption or spurious test failures.
Therefore we reset the port/function before running these tests on
Siena.

On Falcon this doesn't work: we have to do some additional
initialisation before some blocks will work again.  So refactor the
reset/register-test sequence into an efx_nic_type method so
efx_selftest() doesn't have to consider such quirks.

In the process, fix another minor bug: Siena does not have an
'invisible' reset and the self-test currently fails to push the PHY
configuration after resetting.  Passing RESET_TYPE_ALL to
efx_reset_{down,up}() fixes this.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/falcon.c     |   35 ++++++++++++++++--
 drivers/net/ethernet/sfc/net_driver.h |    7 +++-
 drivers/net/ethernet/sfc/nic.c        |    3 --
 drivers/net/ethernet/sfc/selftest.c   |   62 ++++++++-------------------------
 drivers/net/ethernet/sfc/siena.c      |   29 +++++++++++++--
 5 files changed, 76 insertions(+), 60 deletions(-)

diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 6dfcbb7..49bcd19 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -25,9 +25,12 @@
 #include "io.h"
 #include "phy.h"
 #include "workarounds.h"
+#include "selftest.h"
 
 /* Hardware control for SFC4000 (aka Falcon). */
 
+static int falcon_reset_hw(struct efx_nic *efx, enum reset_type method);
+
 static const unsigned int
 /* "Large" EEPROM device: Atmel AT25640 or similar
  * 8 KB, 16-bit address, 32 B write block */
@@ -1034,10 +1037,34 @@ static const struct efx_nic_register_test falcon_b0_register_tests[] = {
 	  EFX_OWORD32(0x0003FF0F, 0x00000000, 0x00000000, 0x00000000) },
 };
 
-static int falcon_b0_test_registers(struct efx_nic *efx)
+static int
+falcon_b0_test_chip(struct efx_nic *efx, struct efx_self_tests *tests)
 {
-	return efx_nic_test_registers(efx, falcon_b0_register_tests,
-				      ARRAY_SIZE(falcon_b0_register_tests));
+	enum reset_type reset_method = RESET_TYPE_INVISIBLE;
+	int rc, rc2;
+
+	mutex_lock(&efx->mac_lock);
+	if (efx->loopback_modes) {
+		/* We need the 312 clock from the PHY to test the XMAC
+		 * registers, so move into XGMII loopback if available */
+		if (efx->loopback_modes & (1 << LOOPBACK_XGMII))
+			efx->loopback_mode = LOOPBACK_XGMII;
+		else
+			efx->loopback_mode = __ffs(efx->loopback_modes);
+	}
+	__efx_reconfigure_port(efx);
+	mutex_unlock(&efx->mac_lock);
+
+	efx_reset_down(efx, reset_method);
+
+	tests->registers =
+		efx_nic_test_registers(efx, falcon_b0_register_tests,
+				       ARRAY_SIZE(falcon_b0_register_tests))
+		? -1 : 1;
+
+	rc = falcon_reset_hw(efx, reset_method);
+	rc2 = efx_reset_up(efx, reset_method, rc == 0);
+	return rc ? rc : rc2;
 }
 
 /**************************************************************************
@@ -1820,7 +1847,7 @@ const struct efx_nic_type falcon_b0_nic_type = {
 	.get_wol = falcon_get_wol,
 	.set_wol = falcon_set_wol,
 	.resume_wol = efx_port_dummy_op_void,
-	.test_registers = falcon_b0_test_registers,
+	.test_chip = falcon_b0_test_chip,
 	.test_nvram = falcon_test_nvram,
 
 	.revision = EFX_REV_FALCON_B0,
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 6986be0..9c32e05 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -68,6 +68,8 @@
 #define EFX_TXQ_TYPES		4
 #define EFX_MAX_TX_QUEUES	(EFX_TXQ_TYPES * EFX_MAX_CHANNELS)
 
+struct efx_self_tests;
+
 /**
  * struct efx_special_buffer - An Efx special buffer
  * @addr: CPU base address of the buffer
@@ -901,7 +903,8 @@ static inline unsigned int efx_port_num(struct efx_nic *efx)
  * @get_wol: Get WoL configuration from driver state
  * @set_wol: Push WoL configuration to the NIC
  * @resume_wol: Synchronise WoL state between driver and MC (e.g. after resume)
- * @test_registers: Test read/write functionality of control registers
+ * @test_chip: Test registers.  Should use efx_nic_test_registers(), and is
+ *	expected to reset the NIC.
  * @test_nvram: Test validity of NVRAM contents
  * @revision: Hardware architecture revision
  * @mem_map_size: Memory BAR mapped size
@@ -947,7 +950,7 @@ struct efx_nic_type {
 	void (*get_wol)(struct efx_nic *efx, struct ethtool_wolinfo *wol);
 	int (*set_wol)(struct efx_nic *efx, u32 type);
 	void (*resume_wol)(struct efx_nic *efx);
-	int (*test_registers)(struct efx_nic *efx);
+	int (*test_chip)(struct efx_nic *efx, struct efx_self_tests *tests);
 	int (*test_nvram)(struct efx_nic *efx);
 
 	int revision;
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 3a59a73..76f16b7 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -126,9 +126,6 @@ int efx_nic_test_registers(struct efx_nic *efx,
 	unsigned address = 0, i, j;
 	efx_oword_t mask, imask, original, reg, buf;
 
-	/* Falcon should be in loopback to isolate the XMAC from the PHY */
-	WARN_ON(!LOOPBACK_INTERNAL(efx));
-
 	for (i = 0; i < n_regs; ++i) {
 		address = regs[i].address;
 		mask = imask = regs[i].mask;
diff --git a/drivers/net/ethernet/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
index 0686791..4a51ea3 100644
--- a/drivers/net/ethernet/sfc/selftest.c
+++ b/drivers/net/ethernet/sfc/selftest.c
@@ -120,19 +120,6 @@ static int efx_test_nvram(struct efx_nic *efx, struct efx_self_tests *tests)
 	return rc;
 }
 
-static int efx_test_chip(struct efx_nic *efx, struct efx_self_tests *tests)
-{
-	int rc = 0;
-
-	/* Test register access */
-	if (efx->type->test_registers) {
-		rc = efx->type->test_registers(efx);
-		tests->registers = rc ? -1 : 1;
-	}
-
-	return rc;
-}
-
 /**************************************************************************
  *
  * Interrupt and event queue testing
@@ -699,8 +686,7 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 {
 	enum efx_loopback_mode loopback_mode = efx->loopback_mode;
 	int phy_mode = efx->phy_mode;
-	enum reset_type reset_method = RESET_TYPE_INVISIBLE;
-	int rc_test = 0, rc_reset = 0, rc;
+	int rc_test = 0, rc_reset, rc;
 
 	efx_selftest_async_cancel(efx);
 
@@ -737,44 +723,26 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 	 */
 	efx_device_detach_sync(efx);
 
-	mutex_lock(&efx->mac_lock);
-	if (efx->loopback_modes) {
-		/* We need the 312 clock from the PHY to test the XMAC
-		 * registers, so move into XGMII loopback if available */
-		if (efx->loopback_modes & (1 << LOOPBACK_XGMII))
-			efx->loopback_mode = LOOPBACK_XGMII;
-		else
-			efx->loopback_mode = __ffs(efx->loopback_modes);
-	}
-
-	__efx_reconfigure_port(efx);
-	mutex_unlock(&efx->mac_lock);
-
-	/* free up all consumers of SRAM (including all the queues) */
-	efx_reset_down(efx, reset_method);
-
-	rc = efx_test_chip(efx, tests);
-	if (rc && !rc_test)
-		rc_test = rc;
+	if (efx->type->test_chip) {
+		rc_reset = efx->type->test_chip(efx, tests);
+		if (rc_reset) {
+			netif_err(efx, hw, efx->net_dev,
+				  "Unable to recover from chip test\n");
+			efx_schedule_reset(efx, RESET_TYPE_DISABLE);
+			return rc_reset;
+		}
 
-	/* reset the chip to recover from the register test */
-	rc_reset = efx->type->reset(efx, reset_method);
+		if ((tests->registers < 0) && !rc_test)
+			rc_test = -EIO;
+	}
 
 	/* Ensure that the phy is powered and out of loopback
 	 * for the bist and loopback tests */
+	mutex_lock(&efx->mac_lock);
 	efx->phy_mode &= ~PHY_MODE_LOW_POWER;
 	efx->loopback_mode = LOOPBACK_NONE;
-
-	rc = efx_reset_up(efx, reset_method, rc_reset == 0);
-	if (rc && !rc_reset)
-		rc_reset = rc;
-
-	if (rc_reset) {
-		netif_err(efx, drv, efx->net_dev,
-			  "Unable to recover from chip test\n");
-		efx_schedule_reset(efx, RESET_TYPE_DISABLE);
-		return rc_reset;
-	}
+	__efx_reconfigure_port(efx);
+	mutex_unlock(&efx->mac_lock);
 
 	rc = efx_test_phy(efx, tests, flags);
 	if (rc && !rc_test)
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 7b87266..2011319 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -25,10 +25,12 @@
 #include "workarounds.h"
 #include "mcdi.h"
 #include "mcdi_pcol.h"
+#include "selftest.h"
 
 /* Hardware control for SFC9000 family including SFL9021 (aka Siena). */
 
 static void siena_init_wol(struct efx_nic *efx);
+static int siena_reset_hw(struct efx_nic *efx, enum reset_type method);
 
 
 static void siena_push_irq_moderation(struct efx_channel *channel)
@@ -166,10 +168,29 @@ static const struct efx_nic_register_test siena_register_tests[] = {
 	  EFX_OWORD32(0xFFFFFFFF, 0xFFFFFFFF, 0x00000007, 0x00000000) },
 };
 
-static int siena_test_registers(struct efx_nic *efx)
+static int siena_test_chip(struct efx_nic *efx, struct efx_self_tests *tests)
 {
-	return efx_nic_test_registers(efx, siena_register_tests,
-				      ARRAY_SIZE(siena_register_tests));
+	enum reset_type reset_method = reset_method;
+	int rc, rc2;
+
+	efx_reset_down(efx, reset_method);
+
+	/* Reset the chip immediately so that it is completely
+	 * quiescent regardless of what any VF driver does.
+	 */
+	rc = siena_reset_hw(efx, reset_method);
+	if (rc)
+		goto out;
+
+	tests->registers =
+		efx_nic_test_registers(efx, siena_register_tests,
+				       ARRAY_SIZE(siena_register_tests))
+		? -1 : 1;
+
+	rc = siena_reset_hw(efx, reset_method);
+out:
+	rc2 = efx_reset_up(efx, reset_method, rc == 0);
+	return rc ? rc : rc2;
 }
 
 /**************************************************************************
@@ -662,7 +683,7 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.get_wol = siena_get_wol,
 	.set_wol = siena_set_wol,
 	.resume_wol = siena_init_wol,
-	.test_registers = siena_test_registers,
+	.test_chip = siena_test_chip,
 	.test_nvram = efx_mcdi_nvram_test_all,
 
 	.revision = EFX_REV_SIENA_A0,
-- 
1.7.7.6


>From 396cad11fb1929f817b18c14f224481d7baae4f1 Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 19 Sep 2012 02:53:34 +0100
Subject: [PATCH 10/16] sfc: Avoid generating over-length
 MC_CMD_FLUSH_RX_QUEUES request

[ Upstream commit 450783747f42dfa3883920acfad4acdd93ce69af ]

MCDI supports requests up to 252 bytes long, which is only enough to
pass 63 RX queue IDs to MC_CMD_FLUSH_RX_QUEUES.  However a VF may have
up to 64 RX queues, and if we try to flush them all we will generate
an over-length request and BUG() in efx_mcdi_copyin().  Currently
all VF drivers limit themselves to 32 RX queues, so reducing the
limit to 63 does no harm.

Also add a BUILD_BUG_ON in efx_mcdi_flush_rxqs() so we remember to
deal with the same problem there if EFX_MAX_CHANNELS is increased.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c        |    3 +++
 drivers/net/ethernet/sfc/siena_sriov.c |    7 +++++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 7e39dcc..eb85217 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -1168,6 +1168,9 @@ int efx_mcdi_flush_rxqs(struct efx_nic *efx)
 	__le32 *qid;
 	int rc, count;
 
+	BUILD_BUG_ON(EFX_MAX_CHANNELS >
+		     MC_CMD_FLUSH_RX_QUEUES_IN_QID_OFST_MAXNUM);
+
 	qid = kmalloc(EFX_MAX_CHANNELS * sizeof(*qid), GFP_KERNEL);
 	if (qid == NULL)
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index 78f5408..4ad8082 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -21,6 +21,9 @@
 /* Number of longs required to track all the VIs in a VF */
 #define VI_MASK_LENGTH BITS_TO_LONGS(1 << EFX_VI_SCALE_MAX)
 
+/* Maximum number of RX queues supported */
+#define VF_MAX_RX_QUEUES 63
+
 /**
  * enum efx_vf_tx_filter_mode - TX MAC filtering behaviour
  * @VF_TX_FILTER_OFF: Disabled
@@ -578,6 +581,7 @@ static int efx_vfdi_init_rxq(struct efx_vf *vf)
 	efx_oword_t reg;
 
 	if (bad_vf_index(efx, vf_evq) || bad_vf_index(efx, vf_rxq) ||
+	    vf_rxq >= VF_MAX_RX_QUEUES ||
 	    bad_buf_count(buf_count, EFX_MAX_DMAQ_SIZE)) {
 		if (net_ratelimit())
 			netif_err(efx, hw, efx->net_dev,
@@ -683,6 +687,9 @@ static int efx_vfdi_fini_all_queues(struct efx_vf *vf)
 	__le32 *rxqs;
 	int rc;
 
+	BUILD_BUG_ON(VF_MAX_RX_QUEUES >
+		     MC_CMD_FLUSH_RX_QUEUES_IN_QID_OFST_MAXNUM);
+
 	rxqs = kmalloc(count * sizeof(*rxqs), GFP_KERNEL);
 	if (rxqs == NULL)
 		return VFDI_RC_ENOMEM;
-- 
1.7.7.6


>From a42b56f7b70e8de7f2a675824abbea4f4df0e1c8 Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 1 Dec 2012 01:55:27 +0000
Subject: [PATCH 11/16] sfc: Correctly initialise reset_method in
 siena_test_chip()

[ Upstream commit ef492f11efed9a6a1686bf914fb74468df59385c ]

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/siena.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 2011319..b09ff79 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -170,7 +170,7 @@ static const struct efx_nic_register_test siena_register_tests[] = {
 
 static int siena_test_chip(struct efx_nic *efx, struct efx_self_tests *tests)
 {
-	enum reset_type reset_method = reset_method;
+	enum reset_type reset_method = RESET_TYPE_ALL;
 	int rc, rc2;
 
 	efx_reset_down(efx, reset_method);
-- 
1.7.7.6


>From ef38de042dc92a6581a4c62c97dc2811dd8adece Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 20 Dec 2012 18:48:20 +0000
Subject: [PATCH 12/16] sfc: Properly sync RX DMA buffer when it is not the
 last in the page

[ Upstream commit 3a68f19d7afb80f548d016effbc6ed52643a8085 ]

We may currently allocate two RX DMA buffers to a page, and only unmap
the page when the second is completed.  We do not sync the first RX
buffer to be completed; this can result in packet loss or corruption
if the last RX buffer completed in a NAPI poll is the first in a page
and is not DMA-coherent.  (In the middle of a NAPI poll, we will
handle the following RX completion and unmap the page *before* looking
at the content of the first buffer.)

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
[bwh: Backported to 3.4: adjust context]
---
 drivers/net/ethernet/sfc/rx.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 763fa2f..c9766ca 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -245,7 +245,8 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 }
 
 static void efx_unmap_rx_buffer(struct efx_nic *efx,
-				struct efx_rx_buffer *rx_buf)
+				struct efx_rx_buffer *rx_buf,
+				unsigned int used_len)
 {
 	if ((rx_buf->flags & EFX_RX_BUF_PAGE) && rx_buf->u.page) {
 		struct efx_rx_page_state *state;
@@ -256,6 +257,10 @@ static void efx_unmap_rx_buffer(struct efx_nic *efx,
 				       state->dma_addr,
 				       efx_rx_buf_size(efx),
 				       PCI_DMA_FROMDEVICE);
+		} else if (used_len) {
+			dma_sync_single_for_cpu(&efx->pci_dev->dev,
+						rx_buf->dma_addr, used_len,
+						DMA_FROM_DEVICE);
 		}
 	} else if (!(rx_buf->flags & EFX_RX_BUF_PAGE) && rx_buf->u.skb) {
 		pci_unmap_single(efx->pci_dev, rx_buf->dma_addr,
@@ -278,7 +283,7 @@ static void efx_free_rx_buffer(struct efx_nic *efx,
 static void efx_fini_rx_buffer(struct efx_rx_queue *rx_queue,
 			       struct efx_rx_buffer *rx_buf)
 {
-	efx_unmap_rx_buffer(rx_queue->efx, rx_buf);
+	efx_unmap_rx_buffer(rx_queue->efx, rx_buf, 0);
 	efx_free_rx_buffer(rx_queue->efx, rx_buf);
 }
 
@@ -544,10 +549,10 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 		goto out;
 	}
 
-	/* Release card resources - assumes all RX buffers consumed in-order
-	 * per RX queue
+	/* Release and/or sync DMA mapping - assumes all RX buffers
+	 * consumed in-order per RX queue
 	 */
-	efx_unmap_rx_buffer(efx, rx_buf);
+	efx_unmap_rx_buffer(efx, rx_buf, len);
 
 	/* Prefetch nice and early so data will (hopefully) be in cache by
 	 * the time we look at it.
-- 
1.7.7.6


>From dda518e6cdd06c04018761e89f2bf702fa85f678 Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 10 Jan 2013 23:51:54 +0000
Subject: [PATCH 13/16] sfc: Fix efx_rx_buf_offset() in the presence of
 swiotlb

[ Upstream commits b590ace09d51cd39744e0f7662c5e4a0d1b5d952 and
  c73e787a8db9117d59b5180baf83203a42ecadca ]

We assume that the mapping between DMA and virtual addresses is done
on whole pages, so we can find the page offset of an RX buffer using
the lower bits of the DMA address.  However, swiotlb maps in units of
2K, breaking this assumption.

Add an explicit page_offset field to struct efx_rx_buffer.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h |    4 +++-
 drivers/net/ethernet/sfc/rx.c         |   10 +++++-----
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 9c32e05..b71ef14 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -206,6 +206,7 @@ struct efx_tx_queue {
  *	Will be %NULL if the buffer slot is currently free.
  * @page: The associated page buffer. Valif iff @flags & %EFX_RX_BUF_PAGE.
  *	Will be %NULL if the buffer slot is currently free.
+ * @page_offset: Offset within page. Valid iff @flags & %EFX_RX_BUF_PAGE.
  * @len: Buffer length, in bytes.
  * @flags: Flags for buffer and packet state.
  */
@@ -215,7 +216,8 @@ struct efx_rx_buffer {
 		struct sk_buff *skb;
 		struct page *page;
 	} u;
-	unsigned int len;
+	u16 page_offset;
+	u16 len;
 	u16 flags;
 };
 #define EFX_RX_BUF_PAGE		0x0001
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index c9766ca..7b3c068 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -95,11 +95,7 @@ static unsigned int rx_refill_limit = 95;
 static inline unsigned int efx_rx_buf_offset(struct efx_nic *efx,
 					     struct efx_rx_buffer *buf)
 {
-	/* Offset is always within one page, so we don't need to consider
-	 * the page order.
-	 */
-	return ((unsigned int) buf->dma_addr & (PAGE_SIZE - 1)) +
-		efx->type->rx_buffer_hash_size;
+	return buf->page_offset + efx->type->rx_buffer_hash_size;
 }
 static inline unsigned int efx_rx_buf_size(struct efx_nic *efx)
 {
@@ -193,6 +189,7 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 	struct efx_rx_buffer *rx_buf;
 	struct page *page;
 	void *page_addr;
+	unsigned int page_offset;
 	struct efx_rx_page_state *state;
 	dma_addr_t dma_addr;
 	unsigned index, count;
@@ -219,12 +216,14 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 
 		page_addr += sizeof(struct efx_rx_page_state);
 		dma_addr += sizeof(struct efx_rx_page_state);
+		page_offset = sizeof(struct efx_rx_page_state);
 
 	split:
 		index = rx_queue->added_count & rx_queue->ptr_mask;
 		rx_buf = efx_rx_buffer(rx_queue, index);
 		rx_buf->dma_addr = dma_addr + EFX_PAGE_IP_ALIGN;
 		rx_buf->u.page = page;
+		rx_buf->page_offset = page_offset + EFX_PAGE_IP_ALIGN;
 		rx_buf->len = efx->rx_buffer_len - EFX_PAGE_IP_ALIGN;
 		rx_buf->flags = EFX_RX_BUF_PAGE;
 		++rx_queue->added_count;
@@ -236,6 +235,7 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 			get_page(page);
 			dma_addr += (PAGE_SIZE >> 1);
 			page_addr += (PAGE_SIZE >> 1);
+			page_offset += (PAGE_SIZE >> 1);
 			++count;
 			goto split;
 		}
-- 
1.7.7.6


>From dc13a81d15d46c66bbfc87138a5561490e8ab0b6 Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 28 Jan 2013 19:01:06 +0000
Subject: [PATCH 14/16] sfc: Detach net device when stopping queues for
 reconfiguration

[ Upstream commit 29c69a4882641285a854d6d03ca5adbba68c0034 ]

We must only ever stop TX queues when they are full or the net device
is not 'ready' so far as the net core, and specifically the watchdog,
is concerned.  Otherwise, the watchdog may fire *immediately* if no
packets have been added to the queue in the last 5 seconds.

The device is ready if all the following are true:

(a) It has a qdisc
(b) It is marked present
(c) It is running
(d) The link is reported up

(a) and (c) are normally true, and must not be changed by a driver.
(d) is under our control, but fake link changes may disturb userland.
This leaves (b).  We already mark the device absent during reset
and self-test, but we need to do the same during MTU changes and ring
reallocation.  We don't need to do this when the device is brought
down because then (c) is already false.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 8c81d1c..a87f351 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -754,6 +754,7 @@ efx_realloc_channels(struct efx_nic *efx, u32 rxq_entries, u32 txq_entries)
 						tx_queue->txd.entries);
 	}
 
+	efx_device_detach_sync(efx);
 	efx_stop_all(efx);
 	efx_stop_interrupts(efx, true);
 
@@ -807,6 +808,7 @@ out:
 
 	efx_start_interrupts(efx, true);
 	efx_start_all(efx);
+	netif_device_attach(efx->net_dev);
 	return rc;
 
 rollback:
@@ -1601,8 +1603,12 @@ static void efx_stop_all(struct efx_nic *efx)
 	/* Flush efx_mac_work(), refill_workqueue, monitor_work */
 	efx_flush_all(efx);
 
-	/* Stop the kernel transmit interface late, so the watchdog
-	 * timer isn't ticking over the flush */
+	/* Stop the kernel transmit interface.  This is only valid if
+	 * the device is stopped or detached; otherwise the watchdog
+	 * may fire immediately.
+	 */
+	WARN_ON(netif_running(efx->net_dev) &&
+		netif_device_present(efx->net_dev));
 	netif_tx_disable(efx->net_dev);
 
 	efx_stop_datapath(efx);
@@ -1921,10 +1927,11 @@ static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
 	if (new_mtu > EFX_MAX_MTU)
 		return -EINVAL;
 
-	efx_stop_all(efx);
-
 	netif_dbg(efx, drv, efx->net_dev, "changing MTU to %d\n", new_mtu);
 
+	efx_device_detach_sync(efx);
+	efx_stop_all(efx);
+
 	mutex_lock(&efx->mac_lock);
 	/* Reconfigure the MAC before enabling the dma queues so that
 	 * the RX buffers don't overflow */
@@ -1933,6 +1940,7 @@ static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
 	mutex_unlock(&efx->mac_lock);
 
 	efx_start_all(efx);
+	netif_device_attach(efx->net_dev);
 	return 0;
 }
 
-- 
1.7.7.6


>From 87ab544c0f27be8c0f24e642823e91816496e938 Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 5 Mar 2013 01:03:47 +0000
Subject: [PATCH 15/16] sfc: Disable soft interrupt handling during
 efx_device_detach_sync()

[ Upstream commit 35205b211c8d17a8a0b5e8926cb7c73e9a7ef1ad ]

efx_device_detach_sync() locks all TX queues before marking the device
detached and thus disabling further TX scheduling.  But it can still
be interrupted by TX completions which then result in TX scheduling in
soft interrupt context.  This will deadlock when it tries to acquire
a TX queue lock that efx_device_detach_sync() already acquired.

To avoid deadlock, we must use netif_tx_{,un}lock_bh().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 320cf7b..7db0e5b 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -170,9 +170,9 @@ static inline void efx_device_detach_sync(struct efx_nic *efx)
 	 * TX scheduler is stopped when we're done and before
 	 * netif_device_present() becomes false.
 	 */
-	netif_tx_lock(dev);
+	netif_tx_lock_bh(dev);
 	netif_device_detach(dev);
-	netif_tx_unlock(dev);
+	netif_tx_unlock_bh(dev);
 }
 
 #endif /* EFX_EFX_H */
-- 
1.7.7.6


>From 8bde5142a743f28012688341cc5a1f62efa57580 Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 27 Feb 2013 16:50:38 +0000
Subject: [PATCH 16/16] sfc: Only use TX push if a single descriptor is to be
 written

[ Upstream commit fae8563b25f73dc584a07bcda7a82750ff4f7672 ]

Using TX push when notifying the NIC of multiple new descriptors in
the ring will very occasionally cause the TX DMA engine to re-use an
old descriptor.  This can result in a duplicated or partly duplicated
packet (new headers with old data), or an IOMMU page fault.  This does
not happen when the pushed descriptor is the only one written.

TX push also provides little latency benefit when a packet requires
more than one descriptor.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/nic.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 76f16b7..578e52a6 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -379,7 +379,8 @@ efx_may_push_tx_desc(struct efx_tx_queue *tx_queue, unsigned int write_count)
 		return false;
 
 	tx_queue->empty_read_count = 0;
-	return ((empty_read_count ^ write_count) & ~EFX_EMPTY_COUNT_VALID) == 0;
+	return ((empty_read_count ^ write_count) & ~EFX_EMPTY_COUNT_VALID) == 0
+		&& tx_queue->write_count - write_count == 1;
 }
 
 /* For each entry inserted into the software descriptor ring, create a
-- 
1.7.7.6


--=-JoKlq4P+CI6IELemF1bE
Content-Type: application/mbox; name="sfc_3.8.mbox"
Content-Disposition: attachment; filename="sfc_3.8.mbox"
Content-Transfer-Encoding: 7bit

>From f8708fc7d0ab2ca558f4d222c5749c2ce74bf6f7 Mon Sep 17 00:00:00 2001
From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Mon, 21 Jan 2013 03:02:48 +0000
Subject: [PATCH 1/6] drivers/net/ethernet/sfc/ptp.c: adjust duplicate test

[ Upstream commit 56567c6f8751c633581ca7c8e1cf08eed503f5ea ]

Delete successive tests to the same location.  rc was previously tested and
not subsequently updated.  efx_phc_adjtime can return an error code, so the
call is updated so that is tested instead.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@s exists@
local idexpression y;
expression x,e;
@@

*if ( \(x == NULL\|IS_ERR(x)\|y != 0\) )
 { ... when forall
   return ...; }
... when != \(y = e\|y += e\|y -= e\|y |= e\|y &= e\|y++\|y--\|&y\)
    when != \(XT_GETPAGE(...,y)\|WMI_CMD_BUF(...)\)
*if ( \(x == NULL\|IS_ERR(x)\|y != 0\) )
 { ... when forall
   return ...; }
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
Acked-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/sfc/ptp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 0767043f..3f93624 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -1439,7 +1439,7 @@ static int efx_phc_settime(struct ptp_clock_info *ptp,
 
 	delta = timespec_sub(*e_ts, time_now);
 
-	efx_phc_adjtime(ptp, timespec_to_ns(&delta));
+	rc = efx_phc_adjtime(ptp, timespec_to_ns(&delta));
 	if (rc != 0)
 		return rc;
 
-- 
1.7.7.6


>From c81bc83e177c5d103f66c8bf4cfd7871128f5b9f Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 20 Dec 2012 18:48:20 +0000
Subject: [PATCH 2/6] sfc: Properly sync RX DMA buffer when it is not the last
 in the page

[ Upstream commit 3a68f19d7afb80f548d016effbc6ed52643a8085 ]

We may currently allocate two RX DMA buffers to a page, and only unmap
the page when the second is completed.  We do not sync the first RX
buffer to be completed; this can result in packet loss or corruption
if the last RX buffer completed in a NAPI poll is the first in a page
and is not DMA-coherent.  (In the middle of a NAPI poll, we will
handle the following RX completion and unmap the page *before* looking
at the content of the first buffer.)

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/rx.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index d780a0d..a575491 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -236,7 +236,8 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 }
 
 static void efx_unmap_rx_buffer(struct efx_nic *efx,
-				struct efx_rx_buffer *rx_buf)
+				struct efx_rx_buffer *rx_buf,
+				unsigned int used_len)
 {
 	if ((rx_buf->flags & EFX_RX_BUF_PAGE) && rx_buf->u.page) {
 		struct efx_rx_page_state *state;
@@ -247,6 +248,10 @@ static void efx_unmap_rx_buffer(struct efx_nic *efx,
 				       state->dma_addr,
 				       efx_rx_buf_size(efx),
 				       DMA_FROM_DEVICE);
+		} else if (used_len) {
+			dma_sync_single_for_cpu(&efx->pci_dev->dev,
+						rx_buf->dma_addr, used_len,
+						DMA_FROM_DEVICE);
 		}
 	} else if (!(rx_buf->flags & EFX_RX_BUF_PAGE) && rx_buf->u.skb) {
 		dma_unmap_single(&efx->pci_dev->dev, rx_buf->dma_addr,
@@ -269,7 +274,7 @@ static void efx_free_rx_buffer(struct efx_nic *efx,
 static void efx_fini_rx_buffer(struct efx_rx_queue *rx_queue,
 			       struct efx_rx_buffer *rx_buf)
 {
-	efx_unmap_rx_buffer(rx_queue->efx, rx_buf);
+	efx_unmap_rx_buffer(rx_queue->efx, rx_buf, 0);
 	efx_free_rx_buffer(rx_queue->efx, rx_buf);
 }
 
@@ -535,10 +540,10 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 		goto out;
 	}
 
-	/* Release card resources - assumes all RX buffers consumed in-order
-	 * per RX queue
+	/* Release and/or sync DMA mapping - assumes all RX buffers
+	 * consumed in-order per RX queue
 	 */
-	efx_unmap_rx_buffer(efx, rx_buf);
+	efx_unmap_rx_buffer(efx, rx_buf, len);
 
 	/* Prefetch nice and early so data will (hopefully) be in cache by
 	 * the time we look at it.
-- 
1.7.7.6


>From 672f50d29915faab10fb139951b7839e63d86603 Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 10 Jan 2013 23:51:54 +0000
Subject: [PATCH 3/6] sfc: Fix efx_rx_buf_offset() in the presence of swiotlb

[ Upstream commits b590ace09d51cd39744e0f7662c5e4a0d1b5d952 and
  c73e787a8db9117d59b5180baf83203a42ecadca ]

We assume that the mapping between DMA and virtual addresses is done
on whole pages, so we can find the page offset of an RX buffer using
the lower bits of the DMA address.  However, swiotlb maps in units of
2K, breaking this assumption.

Add an explicit page_offset field to struct efx_rx_buffer.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h |    4 +++-
 drivers/net/ethernet/sfc/rx.c         |   10 +++++-----
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 2d756c1..0a90abd 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -210,6 +210,7 @@ struct efx_tx_queue {
  *	Will be %NULL if the buffer slot is currently free.
  * @page: The associated page buffer. Valif iff @flags & %EFX_RX_BUF_PAGE.
  *	Will be %NULL if the buffer slot is currently free.
+ * @page_offset: Offset within page. Valid iff @flags & %EFX_RX_BUF_PAGE.
  * @len: Buffer length, in bytes.
  * @flags: Flags for buffer and packet state.
  */
@@ -219,7 +220,8 @@ struct efx_rx_buffer {
 		struct sk_buff *skb;
 		struct page *page;
 	} u;
-	unsigned int len;
+	u16 page_offset;
+	u16 len;
 	u16 flags;
 };
 #define EFX_RX_BUF_PAGE		0x0001
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index a575491..bb579a6 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -90,11 +90,7 @@ static unsigned int rx_refill_threshold;
 static inline unsigned int efx_rx_buf_offset(struct efx_nic *efx,
 					     struct efx_rx_buffer *buf)
 {
-	/* Offset is always within one page, so we don't need to consider
-	 * the page order.
-	 */
-	return ((unsigned int) buf->dma_addr & (PAGE_SIZE - 1)) +
-		efx->type->rx_buffer_hash_size;
+	return buf->page_offset + efx->type->rx_buffer_hash_size;
 }
 static inline unsigned int efx_rx_buf_size(struct efx_nic *efx)
 {
@@ -187,6 +183,7 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 	struct efx_nic *efx = rx_queue->efx;
 	struct efx_rx_buffer *rx_buf;
 	struct page *page;
+	unsigned int page_offset;
 	struct efx_rx_page_state *state;
 	dma_addr_t dma_addr;
 	unsigned index, count;
@@ -211,12 +208,14 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 		state->dma_addr = dma_addr;
 
 		dma_addr += sizeof(struct efx_rx_page_state);
+		page_offset = sizeof(struct efx_rx_page_state);
 
 	split:
 		index = rx_queue->added_count & rx_queue->ptr_mask;
 		rx_buf = efx_rx_buffer(rx_queue, index);
 		rx_buf->dma_addr = dma_addr + EFX_PAGE_IP_ALIGN;
 		rx_buf->u.page = page;
+		rx_buf->page_offset = page_offset + EFX_PAGE_IP_ALIGN;
 		rx_buf->len = efx->rx_buffer_len - EFX_PAGE_IP_ALIGN;
 		rx_buf->flags = EFX_RX_BUF_PAGE;
 		++rx_queue->added_count;
@@ -227,6 +226,7 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 			/* Use the second half of the page */
 			get_page(page);
 			dma_addr += (PAGE_SIZE >> 1);
+			page_offset += (PAGE_SIZE >> 1);
 			++count;
 			goto split;
 		}
-- 
1.7.7.6


>From b503bbd0cdd5290fb6ca4402f776c1484d660bb8 Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 28 Jan 2013 19:01:06 +0000
Subject: [PATCH 4/6] sfc: Detach net device when stopping queues for
 reconfiguration

[ Upstream commit 29c69a4882641285a854d6d03ca5adbba68c0034 ]

We must only ever stop TX queues when they are full or the net device
is not 'ready' so far as the net core, and specifically the watchdog,
is concerned.  Otherwise, the watchdog may fire *immediately* if no
packets have been added to the queue in the last 5 seconds.

The device is ready if all the following are true:

(a) It has a qdisc
(b) It is marked present
(c) It is running
(d) The link is reported up

(a) and (c) are normally true, and must not be changed by a driver.
(d) is under our control, but fake link changes may disturb userland.
This leaves (b).  We already mark the device absent during reset
and self-test, but we need to do the same during MTU changes and ring
reallocation.  We don't need to do this when the device is brought
down because then (c) is already false.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index bf57b3c..0bc0099 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -779,6 +779,7 @@ efx_realloc_channels(struct efx_nic *efx, u32 rxq_entries, u32 txq_entries)
 						tx_queue->txd.entries);
 	}
 
+	efx_device_detach_sync(efx);
 	efx_stop_all(efx);
 	efx_stop_interrupts(efx, true);
 
@@ -832,6 +833,7 @@ out:
 
 	efx_start_interrupts(efx, true);
 	efx_start_all(efx);
+	netif_device_attach(efx->net_dev);
 	return rc;
 
 rollback:
@@ -1641,8 +1643,12 @@ static void efx_stop_all(struct efx_nic *efx)
 	/* Flush efx_mac_work(), refill_workqueue, monitor_work */
 	efx_flush_all(efx);
 
-	/* Stop the kernel transmit interface late, so the watchdog
-	 * timer isn't ticking over the flush */
+	/* Stop the kernel transmit interface.  This is only valid if
+	 * the device is stopped or detached; otherwise the watchdog
+	 * may fire immediately.
+	 */
+	WARN_ON(netif_running(efx->net_dev) &&
+		netif_device_present(efx->net_dev));
 	netif_tx_disable(efx->net_dev);
 
 	efx_stop_datapath(efx);
@@ -1963,16 +1969,18 @@ static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
 	if (new_mtu > EFX_MAX_MTU)
 		return -EINVAL;
 
-	efx_stop_all(efx);
-
 	netif_dbg(efx, drv, efx->net_dev, "changing MTU to %d\n", new_mtu);
 
+	efx_device_detach_sync(efx);
+	efx_stop_all(efx);
+
 	mutex_lock(&efx->mac_lock);
 	net_dev->mtu = new_mtu;
 	efx->type->reconfigure_mac(efx);
 	mutex_unlock(&efx->mac_lock);
 
 	efx_start_all(efx);
+	netif_device_attach(efx->net_dev);
 	return 0;
 }
 
-- 
1.7.7.6


>From 3fc9a1bc60500746d007534f7f65946670c8dcfe Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 5 Mar 2013 01:03:47 +0000
Subject: [PATCH 5/6] sfc: Disable soft interrupt handling during
 efx_device_detach_sync()

[ Upstream commit 35205b211c8d17a8a0b5e8926cb7c73e9a7ef1ad ]

efx_device_detach_sync() locks all TX queues before marking the device
detached and thus disabling further TX scheduling.  But it can still
be interrupted by TX completions which then result in TX scheduling in
soft interrupt context.  This will deadlock when it tries to acquire
a TX queue lock that efx_device_detach_sync() already acquired.

To avoid deadlock, we must use netif_tx_{,un}lock_bh().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 50247df..d2f790d 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -171,9 +171,9 @@ static inline void efx_device_detach_sync(struct efx_nic *efx)
 	 * TX scheduler is stopped when we're done and before
 	 * netif_device_present() becomes false.
 	 */
-	netif_tx_lock(dev);
+	netif_tx_lock_bh(dev);
 	netif_device_detach(dev);
-	netif_tx_unlock(dev);
+	netif_tx_unlock_bh(dev);
 }
 
 #endif /* EFX_EFX_H */
-- 
1.7.7.6


>From 4414e3ab5a473a027f542b7d8e920a9297f95135 Mon Sep 17 00:00:00 2001
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 27 Feb 2013 16:50:38 +0000
Subject: [PATCH 6/6] sfc: Only use TX push if a single descriptor is to be
 written

[ Upstream commit fae8563b25f73dc584a07bcda7a82750ff4f7672 ]

Using TX push when notifying the NIC of multiple new descriptors in
the ring will very occasionally cause the TX DMA engine to re-use an
old descriptor.  This can result in a duplicated or partly duplicated
packet (new headers with old data), or an IOMMU page fault.  This does
not happen when the pushed descriptor is the only one written.

TX push also provides little latency benefit when a packet requires
more than one descriptor.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/nic.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 0ad790c..eaa8e87 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -376,7 +376,8 @@ efx_may_push_tx_desc(struct efx_tx_queue *tx_queue, unsigned int write_count)
 		return false;
 
 	tx_queue->empty_read_count = 0;
-	return ((empty_read_count ^ write_count) & ~EFX_EMPTY_COUNT_VALID) == 0;
+	return ((empty_read_count ^ write_count) & ~EFX_EMPTY_COUNT_VALID) == 0
+		&& tx_queue->write_count - write_count == 1;
 }
 
 /* For each entry inserted into the software descriptor ring, create a
-- 
1.7.7.6


--=-JoKlq4P+CI6IELemF1bE--
