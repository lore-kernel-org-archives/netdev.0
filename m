From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 09/25] wimax/i2400m: Reset the TX FIFO indices when allocating the TX FIFO in tx_setup()
Date: Fri, 14 May 2010 14:45:08 -0700
Message-ID: <d94401742dc662747db5bb9e444d353a4feba018.1273708027.git.inaky.perez-gonzalez@intel.com>
References: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Cc: Cindy H Kao <cindy.h.kao@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:50303 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759985Ab0ENVtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 17:49:11 -0400
In-Reply-To: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cindy H Kao <cindy.h.kao@intel.com>

This patch makes sure whenever tx_setup() is invoked during driver
initialization or device reset where TX FIFO is released and re-allocated,
the indices tx_in, tx_out, tx_msg_size, tx_sequence, tx_msg are properly
initialized.

When a device reset happens and the TX FIFO is released/re-allocated,
a new block of memory may be allocated for the TX FIFO, therefore tx_msg
should be cleared so that no any TX threads (tx_worker, tx) would access
to the out-of-date addresses.

Also, the TX threads use tx_in and tx_out to decide where to put the new
host-to-device messages and from where to copy them to the device HW FIFO,
these indices have to be cleared so after the TX FIFO is re-allocated during
the reset, the indices both refer to the head of the FIFO, ie. a new start.
The same rational applies to tx_msg_size and tx_sequence.

To protect the indices from being accessed by multiple threads simultaneously,
the lock tx_lock has to be obtained before the initializations and released
afterwards.

Signed-off-by: Cindy H Kao <cindy.h.kao@intel.com>
---
 drivers/net/wimax/i2400m/tx.c |   29 +++++++++++++++++++++--------
 1 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wimax/i2400m/tx.c b/drivers/net/wimax/i2400m/tx.c
index 8561c07..21909e5 100644
--- a/drivers/net/wimax/i2400m/tx.c
+++ b/drivers/net/wimax/i2400m/tx.c
@@ -877,27 +877,40 @@ EXPORT_SYMBOL_GPL(i2400m_tx_msg_sent);
  * i2400m_tx_setup - Initialize the TX queue and infrastructure
  *
  * Make sure we reset the TX sequence to zero, as when this function
- * is called, the firmware has been just restarted.
+ * is called, the firmware has been just restarted. Same rational
+ * for tx_in, tx_out, tx_msg_size and tx_msg. We reset them since
+ * the memory for TX queue is reallocated.
  */
 int i2400m_tx_setup(struct i2400m *i2400m)
 {
-	int result;
+	int result = 0;
+	void *tx_buf;
+	unsigned long flags;
 
 	/* Do this here only once -- can't do on
 	 * i2400m_hard_start_xmit() as we'll cause race conditions if
 	 * the WS was scheduled on another CPU */
 	INIT_WORK(&i2400m->wake_tx_ws, i2400m_wake_tx_work);
 
-	i2400m->tx_sequence = 0;
+	tx_buf = kmalloc(I2400M_TX_BUF_SIZE, GFP_ATOMIC);
+	if (tx_buf == NULL) {
+		result = -ENOMEM;
+		goto error_kmalloc;
+	}
+
 	 /* Warn if the calculated buffer size exceeds I2400M_TX_BUF_SIZE. */
 	BUILD_BUG_ON(I2400M_TX_PDU_TOTAL_SIZE > I2400M_TX_BUF_SIZE);
-	i2400m->tx_buf = kmalloc(I2400M_TX_BUF_SIZE, GFP_KERNEL);
-	if (i2400m->tx_buf == NULL)
-		result = -ENOMEM;
-	else
-		result = 0;
+	spin_lock_irqsave(&i2400m->tx_lock, flags);
+	i2400m->tx_sequence = 0;
+	i2400m->tx_in = 0;
+	i2400m->tx_out = 0;
+	i2400m->tx_msg_size = 0;
+	i2400m->tx_msg = NULL;
+	i2400m->tx_buf = tx_buf;
+	spin_unlock_irqrestore(&i2400m->tx_lock, flags);
 	/* Huh? the bus layer has to define this... */
 	BUG_ON(i2400m->bus_tx_block_size == 0);
+error_kmalloc:
 	return result;
 
 }
-- 
1.6.6.1

