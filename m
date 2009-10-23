From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 17/27] sfc: Move shared members of struct falcon_nic_data
	into struct efx_nic
Date: Fri, 23 Oct 2009 19:32:04 +0100
Message-ID: <1256322724.2785.37.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8826 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752870AbZJWScC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:32:02 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These will also be used with Siena NICs.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c     |   23 +++++++----------------
 drivers/net/sfc/net_driver.h |    7 +++++++
 2 files changed, 14 insertions(+), 16 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 34b475e..1582df7 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -35,19 +35,12 @@
 
 /**
  * struct falcon_nic_data - Falcon NIC state
- * @next_buffer_table: First available buffer table id
  * @pci_dev2: The secondary PCI device if present
  * @i2c_data: Operations and state for I2C bit-bashing algorithm
- * @int_error_count: Number of internal errors seen recently
- * @int_error_expire: Time at which error count will be expired
  */
 struct falcon_nic_data {
-	unsigned next_buffer_table;
 	struct pci_dev *pci_dev2;
 	struct i2c_algo_bit_data i2c_data;
-
-	unsigned int_error_count;
-	unsigned long int_error_expire;
 };
 
 /**************************************************************************
@@ -304,8 +297,6 @@ static int falcon_alloc_special_buffer(struct efx_nic *efx,
 				       struct efx_special_buffer *buffer,
 				       unsigned int len)
 {
-	struct falcon_nic_data *nic_data = efx->nic_data;
-
 	len = ALIGN(len, FALCON_BUF_SIZE);
 
 	buffer->addr = pci_alloc_consistent(efx->pci_dev, len,
@@ -320,8 +311,8 @@ static int falcon_alloc_special_buffer(struct efx_nic *efx,
 	memset(buffer->addr, 0xff, len);
 
 	/* Select new buffer ID */
-	buffer->index = nic_data->next_buffer_table;
-	nic_data->next_buffer_table += buffer->entries;
+	buffer->index = efx->next_buffer_table;
+	efx->next_buffer_table += buffer->entries;
 
 	EFX_LOG(efx, "allocating special buffers %d-%d at %llx+%x "
 		"(virt %p phys %llx)\n", buffer->index,
@@ -1411,13 +1402,13 @@ static irqreturn_t falcon_fatal_interrupt(struct efx_nic *efx)
 	falcon_disable_interrupts(efx);
 
 	/* Count errors and reset or disable the NIC accordingly */
-	if (nic_data->int_error_count == 0 ||
-	    time_after(jiffies, nic_data->int_error_expire)) {
-		nic_data->int_error_count = 0;
-		nic_data->int_error_expire =
+	if (efx->int_error_count == 0 ||
+	    time_after(jiffies, efx->int_error_expire)) {
+		efx->int_error_count = 0;
+		efx->int_error_expire =
 			jiffies + FALCON_INT_ERROR_EXPIRE * HZ;
 	}
-	if (++nic_data->int_error_count < FALCON_MAX_INT_ERRORS) {
+	if (++efx->int_error_count < FALCON_MAX_INT_ERRORS) {
 		EFX_ERR(efx, "SYSTEM ERROR - reset scheduled\n");
 		efx_schedule_reset(efx, RESET_TYPE_INT_ERROR);
 	} else {
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 8e7b854..25b7933 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -688,10 +688,13 @@ union efx_multicast_hash {
  * @tx_queue: TX DMA queues
  * @rx_queue: RX DMA queues
  * @channel: Channels
+ * @next_buffer_table: First available buffer table id
  * @n_rx_queues: Number of RX queues
  * @n_channels: Number of channels in use
  * @rx_buffer_len: RX buffer length
  * @rx_buffer_order: Order (log2) of number of pages for each RX buffer
+ * @int_error_count: Number of internal errors seen recently
+ * @int_error_expire: Time at which error count will be expired
  * @irq_status: Interrupt status buffer
  * @last_irq_cpu: Last CPU to handle interrupt.
  *	This register is written with the SMP processor ID whenever an
@@ -775,11 +778,15 @@ struct efx_nic {
 	struct efx_rx_queue rx_queue[EFX_MAX_RX_QUEUES];
 	struct efx_channel channel[EFX_MAX_CHANNELS];
 
+	unsigned next_buffer_table;
 	int n_rx_queues;
 	int n_channels;
 	unsigned int rx_buffer_len;
 	unsigned int rx_buffer_order;
 
+	unsigned int_error_count;
+	unsigned long int_error_expire;
+
 	struct efx_buffer irq_status;
 	volatile signed int last_irq_cpu;
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

