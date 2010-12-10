From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 07/10] sfc: Use TX push whenever adding
 descriptors to an empty queue
Date: Fri, 10 Dec 2010 17:38:59 +0000
Message-ID: <1292002739.11673.21.camel@bwh-desktop>
References: <1292002527.11673.14.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:26996 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752642Ab0LJRjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 12:39:02 -0500
In-Reply-To: <1292002527.11673.14.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Whenever we add DMA descriptors to a TX ring and update the ring
pointer, the TX DMA engine must first read the new DMA descriptors and
then start reading packet data.  However, all released Solarflare 10G
controllers have a 'TX push' feature that allows us to reduce latency
by writing the first new DMA descriptor along with the pointer update.
This is only useful when the queue is empty.  The hardware should
ignore the pushed descriptor if the queue is not empty, but this check
is buggy, so we must do it in software.

In order to tell whether a TX queue is empty, we need to compare the
previous transmission count (write_count) and completion count
(read_count).  However, if we do that every time we update the ring
pointer then read_count may ping-pong between the caches of two CPUs
running the transmission and completion paths for the queue.
Therefore, we split the check for an empty queue between the
completion path and the transmission path:

- Add an empty_read_count field representing a point at which the
  completion path saw the TX queue as empty.
- Add an old_write_count field for use on the completion path.
- On the completion path, whenever read_count reaches or passes
  old_write_count the TX queue may be empty.  We then read
  write_count, set empty_read_count if read_count == write_count,
  and update old_write_count.
- On the transmission path, we read empty_read_count.  If it's set, we
  compare it with the value of write_count before the current set of
  descriptors was added.  If they match, the queue really is empty and
  we can use TX push.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |   16 ++++++++++++++++
 drivers/net/sfc/nic.c        |   42 ++++++++++++++++++++++++++++++++++++++++--
 drivers/net/sfc/tx.c         |   12 ++++++++++++
 3 files changed, 68 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 60d6371..270e217 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -142,6 +142,12 @@ struct efx_tx_buffer {
  * @flushed: Used when handling queue flushing
  * @read_count: Current read pointer.
  *	This is the number of buffers that have been removed from both rings.
+ * @old_write_count: The value of @write_count when last checked.
+ *	This is here for performance reasons.  The xmit path will
+ *	only get the up-to-date value of @write_count if this
+ *	variable indicates that the queue is empty.  This is to
+ *	avoid cache-line ping-pong between the xmit path and the
+ *	completion path.
  * @stopped: Stopped count.
  *	Set if this TX queue is currently stopping its port.
  * @insert_count: Current insert pointer
@@ -163,6 +169,10 @@ struct efx_tx_buffer {
  * @tso_long_headers: Number of packets with headers too long for standard
  *	blocks
  * @tso_packets: Number of packets via the TSO xmit path
+ * @pushes: Number of times the TX push feature has been used
+ * @empty_read_count: If the completion path has seen the queue as empty
+ *	and the transmission path has not yet checked this, the value of
+ *	@read_count bitwise-added to %EFX_EMPTY_COUNT_VALID; otherwise 0.
  */
 struct efx_tx_queue {
 	/* Members which don't change on the fast path */
@@ -177,6 +187,7 @@ struct efx_tx_queue {
 
 	/* Members used mainly on the completion path */
 	unsigned int read_count ____cacheline_aligned_in_smp;
+	unsigned int old_write_count;
 	int stopped;
 
 	/* Members used only on the xmit path */
@@ -187,6 +198,11 @@ struct efx_tx_queue {
 	unsigned int tso_bursts;
 	unsigned int tso_long_headers;
 	unsigned int tso_packets;
+	unsigned int pushes;
+
+	/* Members shared between paths and sometimes updated */
+	unsigned int empty_read_count ____cacheline_aligned_in_smp;
+#define EFX_EMPTY_COUNT_VALID 0x80000000
 };
 
 /**
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index 9743cff..bda6b1b 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -362,6 +362,35 @@ static inline void efx_notify_tx_desc(struct efx_tx_queue *tx_queue)
 			FR_AZ_TX_DESC_UPD_DWORD_P0, tx_queue->queue);
 }
 
+/* Write pointer and first descriptor for TX descriptor ring */
+static inline void efx_push_tx_desc(struct efx_tx_queue *tx_queue,
+				    const efx_qword_t *txd)
+{
+	unsigned write_ptr;
+	efx_oword_t reg;
+
+	BUILD_BUG_ON(FRF_AZ_TX_DESC_LBN != 0);
+	BUILD_BUG_ON(FR_AA_TX_DESC_UPD_KER != FR_BZ_TX_DESC_UPD_P0);
+
+	write_ptr = tx_queue->write_count & tx_queue->ptr_mask;
+	EFX_POPULATE_OWORD_2(reg, FRF_AZ_TX_DESC_PUSH_CMD, true,
+			     FRF_AZ_TX_DESC_WPTR, write_ptr);
+	reg.qword[0] = *txd;
+	efx_writeo_page(tx_queue->efx, &reg,
+			FR_BZ_TX_DESC_UPD_P0, tx_queue->queue);
+}
+
+static inline bool
+efx_may_push_tx_desc(struct efx_tx_queue *tx_queue, unsigned int write_count)
+{
+	unsigned empty_read_count = ACCESS_ONCE(tx_queue->empty_read_count);
+
+	if (empty_read_count == 0)
+		return false;
+
+	tx_queue->empty_read_count = 0;
+	return ((empty_read_count ^ write_count) & ~EFX_EMPTY_COUNT_VALID) == 0;
+}
 
 /* For each entry inserted into the software descriptor ring, create a
  * descriptor in the hardware TX descriptor ring (in host memory), and
@@ -373,6 +402,7 @@ void efx_nic_push_buffers(struct efx_tx_queue *tx_queue)
 	struct efx_tx_buffer *buffer;
 	efx_qword_t *txd;
 	unsigned write_ptr;
+	unsigned old_write_count = tx_queue->write_count;
 
 	BUG_ON(tx_queue->write_count == tx_queue->insert_count);
 
@@ -391,7 +421,15 @@ void efx_nic_push_buffers(struct efx_tx_queue *tx_queue)
 	} while (tx_queue->write_count != tx_queue->insert_count);
 
 	wmb(); /* Ensure descriptors are written before they are fetched */
-	efx_notify_tx_desc(tx_queue);
+
+	if (efx_may_push_tx_desc(tx_queue, old_write_count)) {
+		txd = efx_tx_desc(tx_queue,
+				  old_write_count & tx_queue->ptr_mask);
+		efx_push_tx_desc(tx_queue, txd);
+		++tx_queue->pushes;
+	} else {
+		efx_notify_tx_desc(tx_queue);
+	}
 }
 
 /* Allocate hardware resources for a TX queue */
@@ -1626,7 +1664,7 @@ void efx_nic_init_common(struct efx_nic *efx)
 	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_RX_SPACER, 0xfe);
 	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_RX_SPACER_EN, 1);
 	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_ONE_PKT_PER_Q, 1);
-	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_PUSH_EN, 0);
+	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_PUSH_EN, 1);
 	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_DIS_NON_IP_EV, 1);
 	/* Enable SW_EV to inherit in char driver - assume harmless here */
 	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_SOFT_EVT_EN, 1);
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index fef2235..bdb92b4 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -428,6 +428,16 @@ void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)
 			__netif_tx_unlock(queue);
 		}
 	}
+
+	/* Check whether the hardware queue is now empty */
+	if ((int)(tx_queue->read_count - tx_queue->old_write_count) >= 0) {
+		tx_queue->old_write_count = ACCESS_ONCE(tx_queue->write_count);
+		if (tx_queue->read_count == tx_queue->old_write_count) {
+			smp_mb();
+			tx_queue->empty_read_count =
+				tx_queue->read_count | EFX_EMPTY_COUNT_VALID;
+		}
+	}
 }
 
 int efx_probe_tx_queue(struct efx_tx_queue *tx_queue)
@@ -473,8 +483,10 @@ void efx_init_tx_queue(struct efx_tx_queue *tx_queue)
 
 	tx_queue->insert_count = 0;
 	tx_queue->write_count = 0;
+	tx_queue->old_write_count = 0;
 	tx_queue->read_count = 0;
 	tx_queue->old_read_count = 0;
+	tx_queue->empty_read_count = 0 | EFX_EMPTY_COUNT_VALID;
 	BUG_ON(tx_queue->stopped);
 
 	/* Set up TX descriptor ring */
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

