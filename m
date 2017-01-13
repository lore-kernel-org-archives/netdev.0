From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 2/2] sfc: get PIO buffer size from the NIC
Date: Fri, 13 Jan 2017 21:20:29 +0000
Message-ID: <816909d6-70f6-0a92-feff-9f13fd057b13@solarflare.com>
References: <eae20bb1-89d4-0e81-6c56-0c7058d06ada@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:25663 "EHLO
        nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751104AbdAMVUr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 16:20:47 -0500
In-Reply-To: <eae20bb1-89d4-0e81-6c56-0c7058d06ada@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 8000 series SFC NICs have 4K PIO buffers, rather than the 2K of
 the 7000 series.  Rather than having a hard-coded PIO buffer size
 (ER_DZ_TX_PIOBUF_SIZE), read it from the GET_CAPABILITIES_V2 MCDI
 response.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 16 ++++++++++------
 drivers/net/ethernet/sfc/nic.h  |  2 ++
 drivers/net/ethernet/sfc/tx.c   |  1 -
 3 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index f6e29a9..2ce5769 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -197,11 +197,15 @@ static int efx_ef10_init_datapath_caps(struct efx_nic *efx)
 	nic_data->datapath_caps =
 		MCDI_DWORD(outbuf, GET_CAPABILITIES_OUT_FLAGS1);
 
-	if (outlen >= MC_CMD_GET_CAPABILITIES_V2_OUT_LEN)
+	if (outlen >= MC_CMD_GET_CAPABILITIES_V2_OUT_LEN) {
 		nic_data->datapath_caps2 = MCDI_DWORD(outbuf,
 				GET_CAPABILITIES_V2_OUT_FLAGS2);
-	else
+		nic_data->piobuf_size = MCDI_WORD(outbuf,
+				GET_CAPABILITIES_V2_OUT_SIZE_PIO_BUFF);
+	} else {
 		nic_data->datapath_caps2 = 0;
+		nic_data->piobuf_size = ER_DZ_TX_PIOBUF_SIZE;
+	}
 
 	/* record the DPCPU firmware IDs to determine VEB vswitching support.
 	 */
@@ -823,8 +827,8 @@ static int efx_ef10_link_piobufs(struct efx_nic *efx)
 			offset = ((efx->tx_channel_offset + efx->n_tx_channels -
 				   tx_queue->channel->channel - 1) *
 				  efx_piobuf_size);
-			index = offset / ER_DZ_TX_PIOBUF_SIZE;
-			offset = offset % ER_DZ_TX_PIOBUF_SIZE;
+			index = offset / nic_data->piobuf_size;
+			offset = offset % nic_data->piobuf_size;
 
 			/* When the host page size is 4K, the first
 			 * host page in the WC mapping may be within
@@ -1159,11 +1163,11 @@ static int efx_ef10_dimension_resources(struct efx_nic *efx)
 	 * functions of the controller.
 	 */
 	if (efx_piobuf_size != 0 &&
-	    ER_DZ_TX_PIOBUF_SIZE / efx_piobuf_size * EF10_TX_PIOBUF_COUNT >=
+	    nic_data->piobuf_size / efx_piobuf_size * EF10_TX_PIOBUF_COUNT >=
 	    efx->n_tx_channels) {
 		unsigned int n_piobufs =
 			DIV_ROUND_UP(efx->n_tx_channels,
-				     ER_DZ_TX_PIOBUF_SIZE / efx_piobuf_size);
+				     nic_data->piobuf_size / efx_piobuf_size);
 
 		rc = efx_ef10_alloc_piobufs(efx, n_piobufs);
 		if (rc)
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 6a69aa3..383ff6e 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -343,6 +343,7 @@ enum {
  * @pio_write_base: Base address for writing PIO buffers
  * @pio_write_vi_base: Relative VI number for @pio_write_base
  * @piobuf_handle: Handle of each PIO buffer allocated
+ * @piobuf_size: size of a single PIO buffer
  * @must_restore_piobufs: Flag: PIO buffers have yet to be restored after MC
  *	reboot
  * @rx_rss_context: Firmware handle for our RSS context
@@ -380,6 +381,7 @@ struct efx_ef10_nic_data {
 	void __iomem *wc_membase, *pio_write_base;
 	unsigned int pio_write_vi_base;
 	unsigned int piobuf_handle[EF10_TX_PIOBUF_COUNT];
+	u16 piobuf_size;
 	bool must_restore_piobufs;
 	u32 rx_rss_context;
 	bool rx_rss_context_exclusive;
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index beaf980..ff88d60 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -28,7 +28,6 @@
 
 #ifdef EFX_USE_PIO
 
-#define EFX_PIOBUF_SIZE_MAX ER_DZ_TX_PIOBUF_SIZE
 #define EFX_PIOBUF_SIZE_DEF ALIGN(256, L1_CACHE_BYTES)
 unsigned int efx_piobuf_size __read_mostly = EFX_PIOBUF_SIZE_DEF;
 
