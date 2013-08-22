From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 19/32] sfc: Make struct efx_special_buffer less
 special
Date: Thu, 22 Aug 2013 13:55:11 +0100
Message-ID: <1377176111.1703.24.camel@bwh-desktop.uk.level5networks.com>
References: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:14059 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752473Ab3HVMzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 08:55:14 -0400
In-Reply-To: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On EF10, the firmware is in charge of allocating buffer table entries.
Change struct efx_special_buffer to use a struct efx_buffer member,
so that it can be used with efx_nic_{alloc,free}_buffer() in that
case.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h | 47 +++++++++++++++++------------------
 drivers/net/ethernet/sfc/nic.c        | 33 +++++++++++-------------
 2 files changed, 37 insertions(+), 43 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index fb9361f..ea64cd8 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -93,21 +93,36 @@ struct efx_ptp_data;
 struct efx_self_tests;
 
 /**
- * struct efx_special_buffer - An Efx special buffer
- * @addr: CPU base address of the buffer
+ * struct efx_buffer - A general-purpose DMA buffer
+ * @addr: host base address of the buffer
  * @dma_addr: DMA base address of the buffer
  * @len: Buffer length, in bytes
- * @index: Buffer index within controller;s buffer table
- * @entries: Number of buffer table entries
  *
- * Special buffers are used for the event queues and the TX and RX
- * descriptor queues for each channel.  They are *not* used for the
- * actual transmit and receive buffers.
+ * The NIC uses these buffers for its interrupt status registers and
+ * MAC stats dumps.
  */
-struct efx_special_buffer {
+struct efx_buffer {
 	void *addr;
 	dma_addr_t dma_addr;
 	unsigned int len;
+};
+
+/**
+ * struct efx_special_buffer - DMA buffer entered into buffer table
+ * @buf: Standard &struct efx_buffer
+ * @index: Buffer index within controller;s buffer table
+ * @entries: Number of buffer table entries
+ *
+ * The NIC has a buffer table that maps buffers of size %EFX_BUF_SIZE.
+ * Event and descriptor rings are addressed via one or more buffer
+ * table entries (and so can be physically non-contiguous, although we
+ * currently do not take advantage of that).  On Falcon and Siena we
+ * have to take care of allocating and initialising the entries
+ * ourselves.  On later hardware this is managed by the firmware and
+ * @index and @entries are left as 0.
+ */
+struct efx_special_buffer {
+	struct efx_buffer buf;
 	unsigned int index;
 	unsigned int entries;
 };
@@ -325,22 +340,6 @@ struct efx_rx_queue {
 	unsigned int slow_fill_count;
 };
 
-/**
- * struct efx_buffer - An Efx general-purpose buffer
- * @addr: host base address of the buffer
- * @dma_addr: DMA base address of the buffer
- * @len: Buffer length, in bytes
- *
- * The NIC uses these buffers for its interrupt status registers and
- * MAC stats dumps.
- */
-struct efx_buffer {
-	void *addr;
-	dma_addr_t dma_addr;
-	unsigned int len;
-};
-
-
 enum efx_rx_alloc_method {
 	RX_ALLOC_METHOD_AUTO = 0,
 	RX_ALLOC_METHOD_SKB = 1,
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index efe2773..372891c 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -93,7 +93,7 @@ static inline void efx_write_buf_tbl(struct efx_nic *efx, efx_qword_t *value,
 static inline efx_qword_t *efx_event(struct efx_channel *channel,
 				     unsigned int index)
 {
-	return ((efx_qword_t *) (channel->eventq.addr)) +
+	return ((efx_qword_t *) (channel->eventq.buf.addr)) +
 		(index & channel->eventq_mask);
 }
 
@@ -196,12 +196,12 @@ efx_init_special_buffer(struct efx_nic *efx, struct efx_special_buffer *buffer)
 	dma_addr_t dma_addr;
 	int i;
 
-	EFX_BUG_ON_PARANOID(!buffer->addr);
+	EFX_BUG_ON_PARANOID(!buffer->buf.addr);
 
 	/* Write buffer descriptors to NIC */
 	for (i = 0; i < buffer->entries; i++) {
 		index = buffer->index + i;
-		dma_addr = buffer->dma_addr + (i * EFX_BUF_SIZE);
+		dma_addr = buffer->buf.dma_addr + (i * EFX_BUF_SIZE);
 		netif_dbg(efx, probe, efx->net_dev,
 			  "mapping special buffer %d at %llx\n",
 			  index, (unsigned long long)dma_addr);
@@ -250,13 +250,10 @@ static int efx_alloc_special_buffer(struct efx_nic *efx,
 {
 	len = ALIGN(len, EFX_BUF_SIZE);
 
-	buffer->addr = dma_alloc_coherent(&efx->pci_dev->dev, len,
-					  &buffer->dma_addr, GFP_KERNEL);
-	if (!buffer->addr)
+	if (efx_nic_alloc_buffer(efx, &buffer->buf, len, GFP_KERNEL))
 		return -ENOMEM;
-	buffer->len = len;
 	buffer->entries = len / EFX_BUF_SIZE;
-	BUG_ON(buffer->dma_addr & (EFX_BUF_SIZE - 1));
+	BUG_ON(buffer->buf.dma_addr & (EFX_BUF_SIZE - 1));
 
 	/* Select new buffer ID */
 	buffer->index = efx->next_buffer_table;
@@ -270,8 +267,8 @@ static int efx_alloc_special_buffer(struct efx_nic *efx,
 		  "allocating special buffers %d-%d at %llx+%x "
 		  "(virt %p phys %llx)\n", buffer->index,
 		  buffer->index + buffer->entries - 1,
-		  (u64)buffer->dma_addr, len,
-		  buffer->addr, (u64)virt_to_phys(buffer->addr));
+		  (u64)buffer->buf.dma_addr, len,
+		  buffer->buf.addr, (u64)virt_to_phys(buffer->buf.addr));
 
 	return 0;
 }
@@ -279,19 +276,17 @@ static int efx_alloc_special_buffer(struct efx_nic *efx,
 static void
 efx_free_special_buffer(struct efx_nic *efx, struct efx_special_buffer *buffer)
 {
-	if (!buffer->addr)
+	if (!buffer->buf.addr)
 		return;
 
 	netif_dbg(efx, hw, efx->net_dev,
 		  "deallocating special buffers %d-%d at %llx+%x "
 		  "(virt %p phys %llx)\n", buffer->index,
 		  buffer->index + buffer->entries - 1,
-		  (u64)buffer->dma_addr, buffer->len,
-		  buffer->addr, (u64)virt_to_phys(buffer->addr));
+		  (u64)buffer->buf.dma_addr, buffer->buf.len,
+		  buffer->buf.addr, (u64)virt_to_phys(buffer->buf.addr));
 
-	dma_free_coherent(&efx->pci_dev->dev, buffer->len, buffer->addr,
-			  buffer->dma_addr);
-	buffer->addr = NULL;
+	efx_nic_free_buffer(efx, &buffer->buf);
 	buffer->entries = 0;
 }
 
@@ -335,7 +330,7 @@ void efx_nic_free_buffer(struct efx_nic *efx, struct efx_buffer *buffer)
 static inline efx_qword_t *
 efx_tx_desc(struct efx_tx_queue *tx_queue, unsigned int index)
 {
-	return ((efx_qword_t *) (tx_queue->txd.addr)) + index;
+	return ((efx_qword_t *) (tx_queue->txd.buf.addr)) + index;
 }
 
 /* This writes to the TX_DESC_WPTR; write pointer for TX descriptor ring */
@@ -534,7 +529,7 @@ void efx_nic_remove_tx(struct efx_tx_queue *tx_queue)
 static inline efx_qword_t *
 efx_rx_desc(struct efx_rx_queue *rx_queue, unsigned int index)
 {
-	return ((efx_qword_t *) (rx_queue->rxd.addr)) + index;
+	return ((efx_qword_t *) (rx_queue->rxd.buf.addr)) + index;
 }
 
 /* This creates an entry in the RX descriptor queue */
@@ -1415,7 +1410,7 @@ void efx_nic_init_eventq(struct efx_channel *channel)
 	efx_init_special_buffer(efx, &channel->eventq);
 
 	/* Fill event queue with all ones (i.e. empty events) */
-	memset(channel->eventq.addr, 0xff, channel->eventq.len);
+	memset(channel->eventq.buf.addr, 0xff, channel->eventq.buf.len);
 
 	/* Push event queue to card */
 	EFX_POPULATE_OWORD_3(reg,


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
