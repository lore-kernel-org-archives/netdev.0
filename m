From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 14/25] wimax/i2400m: fix system freeze caused by an infinite loop [v1]
Date: Fri, 14 May 2010 14:45:13 -0700
Message-ID: <85a19e07e30f67c517266cafe92b7bcd9b98966d.1273708027.git.inaky.perez-gonzalez@intel.com>
References: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Cc: "Prasanna S. Panchamukhi" <prasannax.s.panchamukhi@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:32478 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932531Ab0ENVtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 17:49:14 -0400
In-Reply-To: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>

This patch fixes an infinite loop caused by i2400m_tx_fifo_push() due
to a corner case where there is no tail space in the TX FIFO.
Please refer the documentation in the code for details.

Signed-off-by: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>
---
 drivers/net/wimax/i2400m/tx.c |   65 +++++++++++++++++++++++++++++++++++++---
 1 files changed, 60 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wimax/i2400m/tx.c b/drivers/net/wimax/i2400m/tx.c
index 101550a..609f1ca 100644
--- a/drivers/net/wimax/i2400m/tx.c
+++ b/drivers/net/wimax/i2400m/tx.c
@@ -341,6 +341,14 @@ size_t __i2400m_tx_tail_room(struct i2400m *i2400m)
  * @padding: ensure that there is at least this many bytes of free
  *     contiguous space in the fifo. This is needed because later on
  *     we might need to add padding.
+ * @try_head: specify either to allocate head room or tail room space
+ *     in the TX FIFO. This boolean is required to avoids a system hang
+ *     due to an infinite loop caused by i2400m_tx_fifo_push().
+ *     The caller must always try to allocate tail room space first by
+ *     calling this routine with try_head = 0. In case if there
+ *     is not enough tail room space but there is enough head room space,
+ *     (i2400m_tx_fifo_push() returns TAIL_FULL) try to allocate head
+ *     room space, by calling this routine again with try_head = 1.
  *
  * Returns:
  *
@@ -372,6 +380,48 @@ size_t __i2400m_tx_tail_room(struct i2400m *i2400m)
  * fail and return TAIL_FULL and let the caller figure out if we wants to
  * skip the tail room and try to allocate from the head.
  *
+ * There is a corner case, wherein i2400m_tx_new() can get into
+ * an infinite loop calling i2400m_tx_fifo_push().
+ * In certain situations, tx_in would have reached on the top of TX FIFO
+ * and i2400m_tx_tail_room() returns 0, as described below:
+ *
+ * N  ___________ tail room is zero
+ *   |<-  IN   ->|
+ *   |           |
+ *   |           |
+ *   |           |
+ *   |   data    |
+ *   |<-  OUT  ->|
+ *   |           |
+ *   |           |
+ *   | head room |
+ * 0  -----------
+ * During such a time, where tail room is zero in the TX FIFO and if there
+ * is a request to add a payload to TX FIFO, which calls:
+ * i2400m_tx()
+ *         ->calls i2400m_tx_close()
+ *         ->calls i2400m_tx_skip_tail()
+ *         goto try_new;
+ *         ->calls i2400m_tx_new()
+ *                    |----> [try_head:]
+ *     infinite loop  |     ->calls i2400m_tx_fifo_push()
+ *                    |                if (tail_room < needed)
+ *                    |                   if (head_room => needed)
+ *                    |                       return TAIL_FULL;
+ *                    |<----  goto try_head;
+ *
+ * i2400m_tx() calls i2400m_tx_close() to close the message, since there
+ * is no tail room to accommodate the payload and calls
+ * i2400m_tx_skip_tail() to skip the tail space. Now i2400m_tx() calls
+ * i2400m_tx_new() to allocate space for new message header calling
+ * i2400m_tx_fifo_push() that returns TAIL_FULL, since there is no tail space
+ * to accommodate the message header, but there is enough head space.
+ * The i2400m_tx_new() keeps re-retrying by calling i2400m_tx_fifo_push()
+ * ending up in a loop causing system freeze.
+ *
+ * This corner case is avoided by using a try_head boolean,
+ * as an argument to i2400m_tx_fifo_push().
+ *
  * Note:
  *
  *     Assumes i2400m->tx_lock is taken, and we use that as a barrier
@@ -380,7 +430,8 @@ size_t __i2400m_tx_tail_room(struct i2400m *i2400m)
  *     pop data off the queue
  */
 static
-void *i2400m_tx_fifo_push(struct i2400m *i2400m, size_t size, size_t padding)
+void *i2400m_tx_fifo_push(struct i2400m *i2400m, size_t size,
+			  size_t padding, bool try_head)
 {
 	struct device *dev = i2400m_dev(i2400m);
 	size_t room, tail_room, needed_size;
@@ -395,7 +446,7 @@ void *i2400m_tx_fifo_push(struct i2400m *i2400m, size_t size, size_t padding)
 	}
 	/* Is there space at the tail? */
 	tail_room = __i2400m_tx_tail_room(i2400m);
-	if (tail_room < needed_size) {
+	if (!try_head && tail_room < needed_size) {
 		/*
 		 * If the tail room space is not enough to push the message
 		 * in the TX FIFO, then there are two possibilities:
@@ -510,14 +561,16 @@ void i2400m_tx_new(struct i2400m *i2400m)
 {
 	struct device *dev = i2400m_dev(i2400m);
 	struct i2400m_msg_hdr *tx_msg;
+	bool try_head = 0;
 	BUG_ON(i2400m->tx_msg != NULL);
 try_head:
-	tx_msg = i2400m_tx_fifo_push(i2400m, I2400M_TX_PLD_SIZE, 0);
+	tx_msg = i2400m_tx_fifo_push(i2400m, I2400M_TX_PLD_SIZE, 0, try_head);
 	if (tx_msg == NULL)
 		goto out;
 	else if (tx_msg == TAIL_FULL) {
 		i2400m_tx_skip_tail(i2400m);
 		d_printf(2, dev, "new TX message: tail full, trying head\n");
+		try_head = 1;
 		goto try_head;
 	}
 	memset(tx_msg, 0, I2400M_TX_PLD_SIZE);
@@ -591,7 +644,7 @@ void i2400m_tx_close(struct i2400m *i2400m)
 	aligned_size = ALIGN(tx_msg_moved->size, i2400m->bus_tx_block_size);
 	padding = aligned_size - tx_msg_moved->size;
 	if (padding > 0) {
-		pad_buf = i2400m_tx_fifo_push(i2400m, padding, 0);
+		pad_buf = i2400m_tx_fifo_push(i2400m, padding, 0, 0);
 		if (unlikely(WARN_ON(pad_buf == NULL
 				     || pad_buf == TAIL_FULL))) {
 			/* This should not happen -- append should verify
@@ -657,6 +710,7 @@ int i2400m_tx(struct i2400m *i2400m, const void *buf, size_t buf_len,
 	unsigned long flags;
 	size_t padded_len;
 	void *ptr;
+	bool try_head = 0;
 	unsigned is_singleton = pl_type == I2400M_PT_RESET_WARM
 		|| pl_type == I2400M_PT_RESET_COLD;
 
@@ -702,11 +756,12 @@ try_new:
 	/* So we have a current message header; now append space for
 	 * the message -- if there is not enough, try the head */
 	ptr = i2400m_tx_fifo_push(i2400m, padded_len,
-				  i2400m->bus_tx_block_size);
+				  i2400m->bus_tx_block_size, try_head);
 	if (ptr == TAIL_FULL) {	/* Tail is full, try head */
 		d_printf(2, dev, "pl append: tail full\n");
 		i2400m_tx_close(i2400m);
 		i2400m_tx_skip_tail(i2400m);
+		try_head = 1;
 		goto try_new;
 	} else if (ptr == NULL) {	/* All full */
 		result = -ENOSPC;
-- 
1.6.6.1

