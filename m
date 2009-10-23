From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 07/27] sfc: Move RX data FIFO thresholds out of struct
	efx_nic_type
Date: Fri, 23 Oct 2009 19:30:17 +0100
Message-ID: <1256322617.2785.17.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8619 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752828AbZJWSaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:30:15 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since there are now separate blocks of code to set the thresholds for
each NIC type, it is no longer useful to include them in the NIC type
description.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c     |   23 ++++++++++++-----------
 drivers/net/sfc/net_driver.h |    4 ----
 2 files changed, 12 insertions(+), 15 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 4cb98d4..c23e8e2 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2922,16 +2922,17 @@ static void falcon_init_rx_cfg(struct efx_nic *efx)
 	const unsigned ctrl_xon_thr = 20;
 	const unsigned ctrl_xoff_thr = 25;
 	/* RX data FIFO thresholds (256-byte units; size varies) */
-	unsigned data_xon_thr =
-		((rx_xon_thresh_bytes >= 0) ?
-		 rx_xon_thresh_bytes : efx->type->rx_xon_thresh) >> 8;
-	unsigned data_xoff_thr =
-		((rx_xoff_thresh_bytes >= 0) ?
-		 rx_xoff_thresh_bytes : efx->type->rx_xoff_thresh) >> 8;
+	int data_xon_thr = rx_xon_thresh_bytes >> 8;
+	int data_xoff_thr = rx_xoff_thresh_bytes >> 8;
 	efx_oword_t reg;
 
 	falcon_read(efx, &reg, RX_CFG_REG_KER);
 	if (falcon_rev(efx) <= FALCON_REV_A1) {
+		/* Data FIFO size is 5.5K */
+		if (data_xon_thr < 0)
+			data_xon_thr = 512 >> 8;
+		if (data_xoff_thr < 0)
+			data_xoff_thr = 2048 >> 8;
 		EFX_SET_OWORD_FIELD(reg, RX_DESC_PUSH_EN_A1, 0);
 		EFX_SET_OWORD_FIELD(reg, RX_USR_BUF_SIZE_A1, huge_buf_size);
 		EFX_SET_OWORD_FIELD(reg, RX_XON_MAC_TH_A1, data_xon_thr);
@@ -2939,7 +2940,11 @@ static void falcon_init_rx_cfg(struct efx_nic *efx)
 		EFX_SET_OWORD_FIELD(reg, RX_XON_TX_TH_A1, ctrl_xon_thr);
 		EFX_SET_OWORD_FIELD(reg, RX_XOFF_TX_TH_A1, ctrl_xoff_thr);
 	} else {
-		/* Register fields moved */
+		/* Data FIFO size is 80K; register fields moved */
+		if (data_xon_thr < 0)
+			data_xon_thr = 27648 >> 8; /* ~3*max MTU */
+		if (data_xoff_thr < 0)
+			data_xoff_thr = 54272 >> 8; /* ~80Kb - 3*max MTU */
 		EFX_SET_OWORD_FIELD(reg, RX_DESC_PUSH_EN_B0, 0);
 		EFX_SET_OWORD_FIELD(reg, RX_USR_BUF_SIZE_B0, huge_buf_size);
 		EFX_SET_OWORD_FIELD(reg, RX_XON_MAC_TH_B0, data_xon_thr);
@@ -3130,8 +3135,6 @@ struct efx_nic_type falcon_a_nic_type = {
 	.max_dma_mask = FALCON_DMA_MASK,
 	.tx_dma_mask = FALCON_TX_DMA_MASK,
 	.bug5391_mask = 0xf,
-	.rx_xoff_thresh = 2048,
-	.rx_xon_thresh = 512,
 	.rx_buffer_padding = 0x24,
 	.max_interrupt_mode = EFX_INT_MODE_MSI,
 	.phys_addr_channels = 4,
@@ -3154,8 +3157,6 @@ struct efx_nic_type falcon_b_nic_type = {
 	.max_dma_mask = FALCON_DMA_MASK,
 	.tx_dma_mask = FALCON_TX_DMA_MASK,
 	.bug5391_mask = 0,
-	.rx_xoff_thresh = 54272, /* ~80Kb - 3*max MTU */
-	.rx_xon_thresh = 27648,  /* ~3*max MTU */
 	.rx_buffer_padding = 0,
 	.max_interrupt_mode = EFX_INT_MODE_MSIX,
 	.phys_addr_channels = 32, /* Hardware limit is 64, but the legacy
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 298566d..479a6fe 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -875,8 +875,6 @@ static inline const char *efx_dev_name(struct efx_nic *efx)
  * @max_dma_mask: Maximum possible DMA mask
  * @tx_dma_mask: TX DMA mask
  * @bug5391_mask: Address mask for bug 5391 workaround
- * @rx_xoff_thresh: RX FIFO XOFF watermark (bytes)
- * @rx_xon_thresh: RX FIFO XON watermark (bytes)
  * @rx_buffer_padding: Padding added to each RX buffer
  * @max_interrupt_mode: Highest capability interrupt mode supported
  *	from &enum efx_init_mode.
@@ -899,8 +897,6 @@ struct efx_nic_type {
 	unsigned int tx_dma_mask;
 	unsigned bug5391_mask;
 
-	int rx_xoff_thresh;
-	int rx_xon_thresh;
 	unsigned int rx_buffer_padding;
 	unsigned int max_interrupt_mode;
 	unsigned int phys_addr_channels;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

