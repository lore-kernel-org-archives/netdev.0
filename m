From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 18/25] wimax/i2400m: reserve additional space in the TX queue's buffer while allocating space for a new message header
Date: Fri, 14 May 2010 14:45:17 -0700
Message-ID: <27502908866ba37d03594e7f7ee7b649cb007330.1273708027.git.inaky.perez-gonzalez@intel.com>
References: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Cc: "Prasanna S. Panchamukhi" <prasannax.s.panchamukhi@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:32478 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932545Ab0ENVtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 17:49:18 -0400
In-Reply-To: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>

Increase the possibilities of including at least one payload by reserving
some additional space in the TX queue while allocating TX queue's space
for new message header. Please refer the documentation in the code for details.

Signed-off-by: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>
---
 drivers/net/wimax/i2400m/i2400m.h |    6 ++++++
 drivers/net/wimax/i2400m/tx.c     |   11 ++++++++++-
 2 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index b8c7dbf..1babc55 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -242,6 +242,11 @@ struct i2400m_barker_db;
  *     so we have a tx_blk_size variable that the bus layer sets to
  *     tell the engine how much of that we need.
  *
+ * @bus_tx_room_min: [fill] Minimum room required while allocating
+ *     TX queue's buffer space for message header. SDIO requires
+ *     224 bytes and USB 16 bytes. Refer bus specific driver code
+ *     for details.
+ *
  * @bus_pl_size_max: [fill] Maximum payload size.
  *
  * @bus_setup: [optional fill] Function called by the bus-generic code
@@ -573,6 +578,7 @@ struct i2400m {
 	wait_queue_head_t state_wq;	/* Woken up when on state updates */
 
 	size_t bus_tx_block_size;
+	size_t bus_tx_room_min;
 	size_t bus_pl_size_max;
 	unsigned bus_bm_retries;
 
diff --git a/drivers/net/wimax/i2400m/tx.c b/drivers/net/wimax/i2400m/tx.c
index 609f1ca..3f819ef 100644
--- a/drivers/net/wimax/i2400m/tx.c
+++ b/drivers/net/wimax/i2400m/tx.c
@@ -563,8 +563,17 @@ void i2400m_tx_new(struct i2400m *i2400m)
 	struct i2400m_msg_hdr *tx_msg;
 	bool try_head = 0;
 	BUG_ON(i2400m->tx_msg != NULL);
+	/*
+	 * In certain situations, TX queue might have enough space to
+	 * accommodate the new message header I2400M_TX_PLD_SIZE, but
+	 * might not have enough space to accommodate the payloads.
+	 * Adding bus_tx_room_min padding while allocating a new TX message
+	 * increases the possibilities of including at least one payload of the
+	 * size <= bus_tx_room_min.
+	 */
 try_head:
-	tx_msg = i2400m_tx_fifo_push(i2400m, I2400M_TX_PLD_SIZE, 0, try_head);
+	tx_msg = i2400m_tx_fifo_push(i2400m, I2400M_TX_PLD_SIZE,
+				     i2400m->bus_tx_room_min, try_head);
 	if (tx_msg == NULL)
 		goto out;
 	else if (tx_msg == TAIL_FULL) {
-- 
1.6.6.1

