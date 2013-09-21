From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 07/11] sfc: Separate out queue-empty check from
 efx_nic_may_push_tx_desc()
Date: Sat, 21 Sep 2013 19:35:16 +0100
Message-ID: <1379788516.1681.41.camel@bwh-desktop.uk.level5networks.com>
References: <1379788283.1681.34.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:32620 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112Ab3IUSfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 14:35:20 -0400
In-Reply-To: <1379788283.1681.34.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/nic.h | 28 ++++++++++++++++++++++------
 1 file changed, 22 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index a6e4336..53f8cf6 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -71,6 +71,26 @@ efx_tx_desc(struct efx_tx_queue *tx_queue, unsigned int index)
 	return ((efx_qword_t *) (tx_queue->txd.buf.addr)) + index;
 }
 
+/* Report whether the NIC considers this TX queue empty, given the
+ * write_count used for the last doorbell push.  May return false
+ * negative.
+ */
+static inline bool __efx_nic_tx_is_empty(struct efx_tx_queue *tx_queue,
+					 unsigned int write_count)
+{
+	unsigned int empty_read_count = ACCESS_ONCE(tx_queue->empty_read_count);
+
+	if (empty_read_count == 0)
+		return false;
+
+	return ((empty_read_count ^ write_count) & ~EFX_EMPTY_COUNT_VALID) == 0;
+}
+
+static inline bool efx_nic_tx_is_empty(struct efx_tx_queue *tx_queue)
+{
+	return __efx_nic_tx_is_empty(tx_queue, tx_queue->write_count);
+}
+
 /* Decide whether to push a TX descriptor to the NIC vs merely writing
  * the doorbell.  This can reduce latency when we are adding a single
  * descriptor to an empty queue, but is otherwise pointless.  Further,
@@ -80,14 +100,10 @@ efx_tx_desc(struct efx_tx_queue *tx_queue, unsigned int index)
 static inline bool efx_nic_may_push_tx_desc(struct efx_tx_queue *tx_queue,
 					    unsigned int write_count)
 {
-	unsigned empty_read_count = ACCESS_ONCE(tx_queue->empty_read_count);
-
-	if (empty_read_count == 0)
-		return false;
+	bool was_empty = __efx_nic_tx_is_empty(tx_queue, write_count);
 
 	tx_queue->empty_read_count = 0;
-	return ((empty_read_count ^ write_count) & ~EFX_EMPTY_COUNT_VALID) == 0
-		&& tx_queue->write_count - write_count == 1;
+	return was_empty && tx_queue->write_count - write_count == 1;
 }
 
 /* Returns a pointer to the specified descriptor in the RX descriptor queue */


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
