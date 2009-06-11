From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [2.6.31 09/21] wimax/i2400m: fix panic due to missed corner cases on tail_room calculation
Date: Thu, 11 Jun 2009 14:35:46 -0700
Message-ID: <2971a5bac8cab3cb56f19e9c494ecb3b120c5199.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27879 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756055AbZFKVgq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 17:36:46 -0400
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i2400m_tx_skip_tail() needs to handle the special case of being called
when the tail room that is left over in the FIFO is zero.

This happens when a TX message header was opened at the very end of
the FIFO (without payloads). The i2400m_tx_close() code already marked
said TX message (header) to be skipped and this function should be
doing nothing.

It is called anyway because it is part of a common "corner case" path
handling which takes care of more cases than only this one.

The tail room computation was also improved to take care of the case
when tx_in is at the end of the buffer boundary; tail_room has to be
modded (%) to the buffer size. To do that in a single well-documented
place, __i2400m_tx_tail_room() is introduced and used.

Treat i2400m->tx_in == 0 as a corner case and handle it accordingly.

Found and diagnosed by Cindy H. Kao.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/tx.c |   58 +++++++++++++++++++++++++++++++++++++++-
 1 files changed, 56 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wimax/i2400m/tx.c b/drivers/net/wimax/i2400m/tx.c
index 7c46c05..4295dcf 100644
--- a/drivers/net/wimax/i2400m/tx.c
+++ b/drivers/net/wimax/i2400m/tx.c
@@ -278,6 +278,48 @@ enum {
 #define TAIL_FULL ((void *)~(unsigned long)NULL)
 
 /*
+ * Calculate how much tail room is available
+ *
+ * Note the trick here. This path is ONLY caleed for Case A (see
+ * i2400m_tx_fifo_push() below), where we have:
+ *
+ *       Case A
+ * N  ___________
+ *   | tail room |
+ *   |           |
+ *   |<-  IN   ->|
+ *   |           |
+ *   |   data    |
+ *   |           |
+ *   |<-  OUT  ->|
+ *   |           |
+ *   | head room |
+ * 0  -----------
+ *
+ * When calculating the tail_room, tx_in might get to be zero if
+ * i2400m->tx_in is right at the end of the buffer (really full
+ * buffer) if there is no head room. In this case, tail_room would be
+ * I2400M_TX_BUF_SIZE, although it is actually zero. Hence the final
+ * mod (%) operation. However, when doing this kind of optimization,
+ * i2400m->tx_in being zero would fail, so we treat is an a special
+ * case.
+ */
+static inline
+size_t __i2400m_tx_tail_room(struct i2400m *i2400m)
+{
+	size_t tail_room;
+	size_t tx_in;
+
+	if (unlikely(i2400m->tx_in) == 0)
+		return I2400M_TX_BUF_SIZE;
+	tx_in = i2400m->tx_in % I2400M_TX_BUF_SIZE;
+	tail_room = I2400M_TX_BUF_SIZE - tx_in;
+	tail_room %= I2400M_TX_BUF_SIZE;
+	return tail_room;
+}
+
+
+/*
  * Allocate @size bytes in the TX fifo, return a pointer to it
  *
  * @i2400m: device descriptor
@@ -338,7 +380,7 @@ void *i2400m_tx_fifo_push(struct i2400m *i2400m, size_t size, size_t padding)
 		return NULL;
 	}
 	/* Is there space at the tail? */
-	tail_room = I2400M_TX_BUF_SIZE - i2400m->tx_in % I2400M_TX_BUF_SIZE;
+	tail_room = __i2400m_tx_tail_room(i2400m);
 	if (tail_room < needed_size) {
 		if (i2400m->tx_out % I2400M_TX_BUF_SIZE
 		    < i2400m->tx_in % I2400M_TX_BUF_SIZE) {
@@ -367,17 +409,29 @@ void *i2400m_tx_fifo_push(struct i2400m *i2400m, size_t size, size_t padding)
  * (I2400M_PL_PAD for the payloads, I2400M_TX_PLD_SIZE for the
  * header).
  *
+ * Tail room can get to be zero if a message was opened when there was
+ * space only for a header. _tx_close() will mark it as to-skip (as it
+ * will have no payloads) and there will be no more space to flush, so
+ * nothing has to be done here. This is probably cheaper than ensuring
+ * in _tx_new() that there is some space for payloads...as we could
+ * always possibly hit the same problem if the payload wouldn't fit.
+ *
  * Note:
  *
  *     Assumes i2400m->tx_lock is taken, and we use that as a barrier
+ *
+ *     This path is only taken for Case A FIFO situations [see
+ *     i2400m_tx_fifo_push()]
  */
 static
 void i2400m_tx_skip_tail(struct i2400m *i2400m)
 {
 	struct device *dev = i2400m_dev(i2400m);
 	size_t tx_in = i2400m->tx_in % I2400M_TX_BUF_SIZE;
-	size_t tail_room = I2400M_TX_BUF_SIZE - tx_in;
+	size_t tail_room = __i2400m_tx_tail_room(i2400m);
 	struct i2400m_msg_hdr *msg = i2400m->tx_buf + tx_in;
+	if (unlikely(tail_room == 0))
+		return;
 	BUG_ON(tail_room < sizeof(*msg));
 	msg->size = tail_room | I2400M_TX_SKIP;
 	d_printf(2, dev, "skip tail: skipping %zu bytes @%zu\n",
-- 
1.6.2.3

