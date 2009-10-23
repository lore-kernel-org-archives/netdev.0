From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 09/27] sfc: Rename register I/O header and functions used
	by both Falcon and Siena
Date: Fri, 23 Oct 2009 19:30:46 +0100
Message-ID: <1256322646.2785.21.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8665 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752705AbZJWSaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:30:46 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While we're at it, use type suffixes of 'd', 'q' and 'o', consistent
with register type names.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c        |  249 +++++++++++++++++++------------------
 drivers/net/sfc/falcon_boards.c |    8 +-
 drivers/net/sfc/falcon_gmac.c   |   26 ++--
 drivers/net/sfc/falcon_io.h     |  258 ---------------------------------------
 drivers/net/sfc/falcon_xmac.c   |   48 ++++----
 drivers/net/sfc/io.h            |  256 ++++++++++++++++++++++++++++++++++++++
 drivers/net/sfc/selftest.c      |    2 +-
 7 files changed, 426 insertions(+), 421 deletions(-)
 delete mode 100644 drivers/net/sfc/falcon_io.h
 create mode 100644 drivers/net/sfc/io.h

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index b35e010..759f55a 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -23,7 +23,7 @@
 #include "spi.h"
 #include "falcon.h"
 #include "regs.h"
-#include "falcon_io.h"
+#include "io.h"
 #include "mdio_10g.h"
 #include "phy.h"
 #include "workarounds.h"
@@ -163,6 +163,13 @@ MODULE_PARM_DESC(rx_xon_thresh_bytes, "RX fifo XON threshold");
  *
  **************************************************************************/
 
+static inline void falcon_write_buf_tbl(struct efx_nic *efx, efx_qword_t *value,
+					unsigned int index)
+{
+	efx_sram_writeq(efx, efx->membase + efx->type->buf_tbl_base,
+			value, index);
+}
+
 /* Read the current event from the event queue */
 static inline efx_qword_t *falcon_event(struct efx_channel *channel,
 					unsigned int index)
@@ -199,9 +206,9 @@ static void falcon_setsda(void *data, int state)
 	struct efx_nic *efx = (struct efx_nic *)data;
 	efx_oword_t reg;
 
-	falcon_read(efx, &reg, FR_AB_GPIO_CTL);
+	efx_reado(efx, &reg, FR_AB_GPIO_CTL);
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_GPIO3_OEN, !state);
-	falcon_write(efx, &reg, FR_AB_GPIO_CTL);
+	efx_writeo(efx, &reg, FR_AB_GPIO_CTL);
 }
 
 static void falcon_setscl(void *data, int state)
@@ -209,9 +216,9 @@ static void falcon_setscl(void *data, int state)
 	struct efx_nic *efx = (struct efx_nic *)data;
 	efx_oword_t reg;
 
-	falcon_read(efx, &reg, FR_AB_GPIO_CTL);
+	efx_reado(efx, &reg, FR_AB_GPIO_CTL);
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_GPIO0_OEN, !state);
-	falcon_write(efx, &reg, FR_AB_GPIO_CTL);
+	efx_writeo(efx, &reg, FR_AB_GPIO_CTL);
 }
 
 static int falcon_getsda(void *data)
@@ -219,7 +226,7 @@ static int falcon_getsda(void *data)
 	struct efx_nic *efx = (struct efx_nic *)data;
 	efx_oword_t reg;
 
-	falcon_read(efx, &reg, FR_AB_GPIO_CTL);
+	efx_reado(efx, &reg, FR_AB_GPIO_CTL);
 	return EFX_OWORD_FIELD(reg, FRF_AB_GPIO3_IN);
 }
 
@@ -228,7 +235,7 @@ static int falcon_getscl(void *data)
 	struct efx_nic *efx = (struct efx_nic *)data;
 	efx_oword_t reg;
 
-	falcon_read(efx, &reg, FR_AB_GPIO_CTL);
+	efx_reado(efx, &reg, FR_AB_GPIO_CTL);
 	return EFX_OWORD_FIELD(reg, FRF_AB_GPIO0_IN);
 }
 
@@ -278,7 +285,7 @@ falcon_init_special_buffer(struct efx_nic *efx,
 				     FRF_AZ_BUF_ADR_REGION, 0,
 				     FRF_AZ_BUF_ADR_FBUF, dma_addr >> 12,
 				     FRF_AZ_BUF_OWNER_ID_FBUF, 0);
-		falcon_write_sram(efx, &buf_desc, index);
+		falcon_write_buf_tbl(efx, &buf_desc, index);
 	}
 }
 
@@ -302,7 +309,7 @@ falcon_fini_special_buffer(struct efx_nic *efx,
 			     FRF_AZ_BUF_CLR_CMD, 1,
 			     FRF_AZ_BUF_CLR_END_ID, end,
 			     FRF_AZ_BUF_CLR_START_ID, start);
-	falcon_write(efx, &buf_tbl_upd, FR_AZ_BUF_TBL_UPD);
+	efx_writeo(efx, &buf_tbl_upd, FR_AZ_BUF_TBL_UPD);
 }
 
 /*
@@ -415,8 +422,8 @@ static inline void falcon_notify_tx_desc(struct efx_tx_queue *tx_queue)
 
 	write_ptr = tx_queue->write_count & FALCON_TXD_RING_MASK;
 	EFX_POPULATE_DWORD_1(reg, FRF_AZ_TX_DESC_WPTR_DWORD, write_ptr);
-	falcon_writel_page(tx_queue->efx, &reg,
-			   FR_AZ_TX_DESC_UPD_DWORD_P0, tx_queue->queue);
+	efx_writed_page(tx_queue->efx, &reg,
+			FR_AZ_TX_DESC_UPD_DWORD_P0, tx_queue->queue);
 }
 

@@ -491,8 +498,8 @@ void falcon_init_tx(struct efx_tx_queue *tx_queue)
 				    !csum);
 	}
 
-	falcon_write_table(efx, &tx_desc_ptr, efx->type->txd_ptr_tbl_base,
-			   tx_queue->queue);
+	efx_writeo_table(efx, &tx_desc_ptr, efx->type->txd_ptr_tbl_base,
+			 tx_queue->queue);
 
 	if (falcon_rev(efx) < FALCON_REV_B0) {
 		efx_oword_t reg;
@@ -500,12 +507,12 @@ void falcon_init_tx(struct efx_tx_queue *tx_queue)
 		/* Only 128 bits in this register */
 		BUILD_BUG_ON(EFX_TX_QUEUE_COUNT >= 128);
 
-		falcon_read(efx, &reg, FR_AA_TX_CHKSM_CFG);
+		efx_reado(efx, &reg, FR_AA_TX_CHKSM_CFG);
 		if (tx_queue->queue == EFX_TX_QUEUE_OFFLOAD_CSUM)
 			clear_bit_le(tx_queue->queue, (void *)&reg);
 		else
 			set_bit_le(tx_queue->queue, (void *)&reg);
-		falcon_write(efx, &reg, FR_AA_TX_CHKSM_CFG);
+		efx_writeo(efx, &reg, FR_AA_TX_CHKSM_CFG);
 	}
 }
 
@@ -518,7 +525,7 @@ static void falcon_flush_tx_queue(struct efx_tx_queue *tx_queue)
 	EFX_POPULATE_OWORD_2(tx_flush_descq,
 			     FRF_AZ_TX_FLUSH_DESCQ_CMD, 1,
 			     FRF_AZ_TX_FLUSH_DESCQ, tx_queue->queue);
-	falcon_write(efx, &tx_flush_descq, FR_AZ_TX_FLUSH_DESCQ);
+	efx_writeo(efx, &tx_flush_descq, FR_AZ_TX_FLUSH_DESCQ);
 }
 
 void falcon_fini_tx(struct efx_tx_queue *tx_queue)
@@ -531,8 +538,8 @@ void falcon_fini_tx(struct efx_tx_queue *tx_queue)
 
 	/* Remove TX descriptor ring from card */
 	EFX_ZERO_OWORD(tx_desc_ptr);
-	falcon_write_table(efx, &tx_desc_ptr, efx->type->txd_ptr_tbl_base,
-			   tx_queue->queue);
+	efx_writeo_table(efx, &tx_desc_ptr, efx->type->txd_ptr_tbl_base,
+			 tx_queue->queue);
 
 	/* Unpin TX descriptor ring */
 	falcon_fini_special_buffer(efx, &tx_queue->txd);
@@ -592,8 +599,8 @@ void falcon_notify_rx_desc(struct efx_rx_queue *rx_queue)
 	wmb();
 	write_ptr = rx_queue->added_count & FALCON_RXD_RING_MASK;
 	EFX_POPULATE_DWORD_1(reg, FRF_AZ_RX_DESC_WPTR_DWORD, write_ptr);
-	falcon_writel_page(rx_queue->efx, &reg,
-			   FR_AZ_RX_DESC_UPD_DWORD_P0, rx_queue->queue);
+	efx_writed_page(rx_queue->efx, &reg,
+			FR_AZ_RX_DESC_UPD_DWORD_P0, rx_queue->queue);
 }
 
 int falcon_probe_rx(struct efx_rx_queue *rx_queue)
@@ -634,8 +641,8 @@ void falcon_init_rx(struct efx_rx_queue *rx_queue)
 			      /* For >=B0 this is scatter so disable */
 			      FRF_AZ_RX_DESCQ_JUMBO, !is_b0,
 			      FRF_AZ_RX_DESCQ_EN, 1);
-	falcon_write_table(efx, &rx_desc_ptr, efx->type->rxd_ptr_tbl_base,
-			   rx_queue->queue);
+	efx_writeo_table(efx, &rx_desc_ptr, efx->type->rxd_ptr_tbl_base,
+			 rx_queue->queue);
 }
 
 static void falcon_flush_rx_queue(struct efx_rx_queue *rx_queue)
@@ -647,7 +654,7 @@ static void falcon_flush_rx_queue(struct efx_rx_queue *rx_queue)
 	EFX_POPULATE_OWORD_2(rx_flush_descq,
 			     FRF_AZ_RX_FLUSH_DESCQ_CMD, 1,
 			     FRF_AZ_RX_FLUSH_DESCQ, rx_queue->queue);
-	falcon_write(efx, &rx_flush_descq, FR_AZ_RX_FLUSH_DESCQ);
+	efx_writeo(efx, &rx_flush_descq, FR_AZ_RX_FLUSH_DESCQ);
 }
 
 void falcon_fini_rx(struct efx_rx_queue *rx_queue)
@@ -660,8 +667,8 @@ void falcon_fini_rx(struct efx_rx_queue *rx_queue)
 
 	/* Remove RX descriptor ring from card */
 	EFX_ZERO_OWORD(rx_desc_ptr);
-	falcon_write_table(efx, &rx_desc_ptr, efx->type->rxd_ptr_tbl_base,
-			   rx_queue->queue);
+	efx_writeo_table(efx, &rx_desc_ptr, efx->type->rxd_ptr_tbl_base,
+			 rx_queue->queue);
 
 	/* Unpin RX descriptor ring */
 	falcon_fini_special_buffer(efx, &rx_queue->rxd);
@@ -695,7 +702,7 @@ void falcon_eventq_read_ack(struct efx_channel *channel)
 	struct efx_nic *efx = channel->efx;
 
 	EFX_POPULATE_DWORD_1(reg, FRF_AZ_EVQ_RPTR, channel->eventq_read_ptr);
-	falcon_writel_table(efx, &reg, efx->type->evq_rptr_tbl_base,
+	efx_writed_table(efx, &reg, efx->type->evq_rptr_tbl_base,
 			    channel->channel);
 }
 
@@ -711,7 +718,7 @@ void falcon_generate_event(struct efx_channel *channel, efx_qword_t *event)
 	drv_ev_reg.u32[2] = 0;
 	drv_ev_reg.u32[3] = 0;
 	EFX_SET_OWORD_FIELD(drv_ev_reg, FRF_AZ_DRV_EV_QID, channel->channel);
-	falcon_write(channel->efx, &drv_ev_reg, FR_AZ_DRV_EV);
+	efx_writeo(channel->efx, &drv_ev_reg, FR_AZ_DRV_EV);
 }
 
 /* Handle a transmit completion event
@@ -1104,8 +1111,8 @@ void falcon_set_int_moderation(struct efx_channel *channel)
 				     FRF_AB_TC_TIMER_VAL, 0);
 	}
 	BUILD_BUG_ON(FR_AA_TIMER_COMMAND_KER != FR_BZ_TIMER_COMMAND_P0);
-	falcon_writel_page_locked(efx, &timer_cmd, FR_BZ_TIMER_COMMAND_P0,
-				  channel->channel);
+	efx_writed_page_locked(efx, &timer_cmd, FR_BZ_TIMER_COMMAND_P0,
+			       channel->channel);
 
 }
 
@@ -1139,8 +1146,8 @@ void falcon_init_eventq(struct efx_channel *channel)
 			     FRF_AZ_EVQ_EN, 1,
 			     FRF_AZ_EVQ_SIZE, FALCON_EVQ_ORDER,
 			     FRF_AZ_EVQ_BUF_BASE_ID, channel->eventq.index);
-	falcon_write_table(efx, &evq_ptr, efx->type->evq_ptr_tbl_base,
-			   channel->channel);
+	efx_writeo_table(efx, &evq_ptr, efx->type->evq_ptr_tbl_base,
+			 channel->channel);
 
 	falcon_set_int_moderation(channel);
 }
@@ -1152,8 +1159,8 @@ void falcon_fini_eventq(struct efx_channel *channel)
 
 	/* Remove event queue from card */
 	EFX_ZERO_OWORD(eventq_ptr);
-	falcon_write_table(efx, &eventq_ptr, efx->type->evq_ptr_tbl_base,
-			   channel->channel);
+	efx_writeo_table(efx, &eventq_ptr, efx->type->evq_ptr_tbl_base,
+			 channel->channel);
 
 	/* Unpin event queue */
 	falcon_fini_special_buffer(efx, &channel->eventq);
@@ -1325,7 +1332,7 @@ static inline void falcon_interrupts(struct efx_nic *efx, int enabled,
 	EFX_POPULATE_OWORD_2(int_en_reg_ker,
 			     FRF_AZ_KER_INT_KER, force,
 			     FRF_AZ_DRV_INT_EN_KER, enabled);
-	falcon_write(efx, &int_en_reg_ker, FR_AZ_INT_EN_KER);
+	efx_writeo(efx, &int_en_reg_ker, FR_AZ_INT_EN_KER);
 }
 
 void falcon_enable_interrupts(struct efx_nic *efx)
@@ -1341,7 +1348,7 @@ void falcon_enable_interrupts(struct efx_nic *efx)
 			     FRF_AZ_NORM_INT_VEC_DIS_KER,
 			     EFX_INT_MODE_USE_MSI(efx),
 			     FRF_AZ_INT_ADR_KER, efx->irq_status.dma_addr);
-	falcon_write(efx, &int_adr_reg_ker, FR_AZ_INT_ADR_KER);
+	efx_writeo(efx, &int_adr_reg_ker, FR_AZ_INT_ADR_KER);
 
 	/* Enable interrupts */
 	falcon_interrupts(efx, 1, 0);
@@ -1382,8 +1389,8 @@ static inline void falcon_irq_ack_a1(struct efx_nic *efx)
 	efx_dword_t reg;
 
 	EFX_POPULATE_DWORD_1(reg, FRF_AA_INT_ACK_KER_FIELD, 0xb7eb7e);
-	falcon_writel(efx, &reg, FR_AA_INT_ACK_KER);
-	falcon_readl(efx, &reg, FR_AA_WORK_AROUND_BROKEN_PCI_READS);
+	efx_writed(efx, &reg, FR_AA_INT_ACK_KER);
+	efx_readd(efx, &reg, FR_AA_WORK_AROUND_BROKEN_PCI_READS);
 }
 
 /* Process a fatal interrupt
@@ -1396,7 +1403,7 @@ static irqreturn_t falcon_fatal_interrupt(struct efx_nic *efx)
 	efx_oword_t fatal_intr;
 	int error, mem_perr;
 
-	falcon_read(efx, &fatal_intr, FR_AZ_FATAL_INTR_KER);
+	efx_reado(efx, &fatal_intr, FR_AZ_FATAL_INTR_KER);
 	error = EFX_OWORD_FIELD(fatal_intr, FRF_AZ_FATAL_INTR);
 
 	EFX_ERR(efx, "SYSTEM ERROR " EFX_OWORD_FMT " status "
@@ -1410,7 +1417,7 @@ static irqreturn_t falcon_fatal_interrupt(struct efx_nic *efx)
 	mem_perr = EFX_OWORD_FIELD(fatal_intr, FRF_AZ_MEM_PERR_INT_KER);
 	if (mem_perr) {
 		efx_oword_t reg;
-		falcon_read(efx, &reg, FR_AZ_MEM_STAT);
+		efx_reado(efx, &reg, FR_AZ_MEM_STAT);
 		EFX_ERR(efx, "SYSTEM ERROR: memory parity error "
 			EFX_OWORD_FMT "\n", EFX_OWORD_VAL(reg));
 	}
@@ -1454,7 +1461,7 @@ static irqreturn_t falcon_legacy_interrupt_b0(int irq, void *dev_id)
 	int syserr;
 
 	/* Read the ISR which also ACKs the interrupts */
-	falcon_readl(efx, &reg, FR_BZ_INT_ISR0);
+	efx_readd(efx, &reg, FR_BZ_INT_ISR0);
 	queues = EFX_EXTRACT_DWORD(reg, 0, 31);
 
 	/* Check to see if we have a serious error condition */
@@ -1576,7 +1583,7 @@ static void falcon_setup_rss_indir_table(struct efx_nic *efx)
 	     offset += 0x10) {
 		EFX_POPULATE_DWORD_1(dword, FRF_BZ_IT_QUEUE,
 				     i % efx->n_rx_queues);
-		falcon_writel(efx, &dword, offset);
+		efx_writed(efx, &dword, offset);
 		i++;
 	}
 }
@@ -1639,7 +1646,7 @@ void falcon_fini_interrupt(struct efx_nic *efx)
 
 	/* ACK legacy interrupt */
 	if (falcon_rev(efx) >= FALCON_REV_B0)
-		falcon_read(efx, &reg, FR_BZ_INT_ISR0);
+		efx_reado(efx, &reg, FR_BZ_INT_ISR0);
 	else
 		falcon_irq_ack_a1(efx);
 
@@ -1660,7 +1667,7 @@ void falcon_fini_interrupt(struct efx_nic *efx)
 static int falcon_spi_poll(struct efx_nic *efx)
 {
 	efx_oword_t reg;
-	falcon_read(efx, &reg, FR_AB_EE_SPI_HCMD);
+	efx_reado(efx, &reg, FR_AB_EE_SPI_HCMD);
 	return EFX_OWORD_FIELD(reg, FRF_AB_EE_SPI_HCMD_CMD_EN) ? -EBUSY : 0;
 }
 
@@ -1714,13 +1721,13 @@ int falcon_spi_cmd(const struct efx_spi_device *spi,
 	/* Program address register, if we have an address */
 	if (addressed) {
 		EFX_POPULATE_OWORD_1(reg, FRF_AB_EE_SPI_HADR_ADR, address);
-		falcon_write(efx, &reg, FR_AB_EE_SPI_HADR);
+		efx_writeo(efx, &reg, FR_AB_EE_SPI_HADR);
 	}
 
 	/* Program data register, if we have data */
 	if (in != NULL) {
 		memcpy(&reg, in, len);
-		falcon_write(efx, &reg, FR_AB_EE_SPI_HDATA);
+		efx_writeo(efx, &reg, FR_AB_EE_SPI_HDATA);
 	}
 
 	/* Issue read/write command */
@@ -1733,7 +1740,7 @@ int falcon_spi_cmd(const struct efx_spi_device *spi,
 			     FRF_AB_EE_SPI_HCMD_ADBCNT,
 			     (addressed ? spi->addr_len : 0),
 			     FRF_AB_EE_SPI_HCMD_ENC, command);
-	falcon_write(efx, &reg, FR_AB_EE_SPI_HCMD);
+	efx_writeo(efx, &reg, FR_AB_EE_SPI_HCMD);
 
 	/* Wait for read/write to complete */
 	rc = falcon_spi_wait(efx);
@@ -1742,7 +1749,7 @@ int falcon_spi_cmd(const struct efx_spi_device *spi,
 
 	/* Read data */
 	if (out != NULL) {
-		falcon_read(efx, &reg, FR_AB_EE_SPI_HDATA);
+		efx_reado(efx, &reg, FR_AB_EE_SPI_HDATA);
 		memcpy(out, &reg, len);
 	}
 
@@ -1884,19 +1891,19 @@ static int falcon_reset_macs(struct efx_nic *efx)
 		 */
 		if (!EFX_IS10G(efx)) {
 			EFX_POPULATE_OWORD_1(reg, FRF_AB_GM_SW_RST, 1);
-			falcon_write(efx, &reg, FR_AB_GM_CFG1);
+			efx_writeo(efx, &reg, FR_AB_GM_CFG1);
 			udelay(1000);
 
 			EFX_POPULATE_OWORD_1(reg, FRF_AB_GM_SW_RST, 0);
-			falcon_write(efx, &reg, FR_AB_GM_CFG1);
+			efx_writeo(efx, &reg, FR_AB_GM_CFG1);
 			udelay(1000);
 			return 0;
 		} else {
 			EFX_POPULATE_OWORD_1(reg, FRF_AB_XM_CORE_RST, 1);
-			falcon_write(efx, &reg, FR_AB_XM_GLB_CFG);
+			efx_writeo(efx, &reg, FR_AB_XM_GLB_CFG);
 
 			for (count = 0; count < 10000; count++) {
-				falcon_read(efx, &reg, FR_AB_XM_GLB_CFG);
+				efx_reado(efx, &reg, FR_AB_XM_GLB_CFG);
 				if (EFX_OWORD_FIELD(reg, FRF_AB_XM_CORE_RST) ==
 				    0)
 					return 0;
@@ -1912,19 +1919,19 @@ static int falcon_reset_macs(struct efx_nic *efx)
 	 * the drain sequence with the statistics fetch */
 	efx_stats_disable(efx);
 
-	falcon_read(efx, &reg, FR_AB_MAC_CTRL);
+	efx_reado(efx, &reg, FR_AB_MAC_CTRL);
 	EFX_SET_OWORD_FIELD(reg, FRF_BB_TXFIFO_DRAIN_EN, 1);
-	falcon_write(efx, &reg, FR_AB_MAC_CTRL);
+	efx_writeo(efx, &reg, FR_AB_MAC_CTRL);
 
-	falcon_read(efx, &reg, FR_AB_GLB_CTL);
+	efx_reado(efx, &reg, FR_AB_GLB_CTL);
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_RST_XGTX, 1);
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_RST_XGRX, 1);
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_RST_EM, 1);
-	falcon_write(efx, &reg, FR_AB_GLB_CTL);
+	efx_writeo(efx, &reg, FR_AB_GLB_CTL);
 
 	count = 0;
 	while (1) {
-		falcon_read(efx, &reg, FR_AB_GLB_CTL);
+		efx_reado(efx, &reg, FR_AB_GLB_CTL);
 		if (!EFX_OWORD_FIELD(reg, FRF_AB_RST_XGTX) &&
 		    !EFX_OWORD_FIELD(reg, FRF_AB_RST_XGRX) &&
 		    !EFX_OWORD_FIELD(reg, FRF_AB_RST_EM)) {
@@ -1958,7 +1965,7 @@ void falcon_drain_tx_fifo(struct efx_nic *efx)
 	    (efx->loopback_mode != LOOPBACK_NONE))
 		return;
 
-	falcon_read(efx, &reg, FR_AB_MAC_CTRL);
+	efx_reado(efx, &reg, FR_AB_MAC_CTRL);
 	/* There is no point in draining more than once */
 	if (EFX_OWORD_FIELD(reg, FRF_BB_TXFIFO_DRAIN_EN))
 		return;
@@ -1974,9 +1981,9 @@ void falcon_deconfigure_mac_wrapper(struct efx_nic *efx)
 		return;
 
 	/* Isolate the MAC -> RX */
-	falcon_read(efx, &reg, FR_AZ_RX_CFG);
+	efx_reado(efx, &reg, FR_AZ_RX_CFG);
 	EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_INGR_EN, 0);
-	falcon_write(efx, &reg, FR_AZ_RX_CFG);
+	efx_writeo(efx, &reg, FR_AZ_RX_CFG);
 
 	if (!efx->link_up)
 		falcon_drain_tx_fifo(efx);
@@ -2011,7 +2018,7 @@ void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
 				    !efx->link_up);
 	}
 
-	falcon_write(efx, &reg, FR_AB_MAC_CTRL);
+	efx_writeo(efx, &reg, FR_AB_MAC_CTRL);
 
 	/* Restore the multicast hash registers. */
 	falcon_set_multicast_hash(efx);
@@ -2020,13 +2027,13 @@ void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
 	 * covered by RX_XOFF_MAC_EN and XM_TX_CFG_REG:XM_FCNTL.
 	 * Action on receipt of pause frames is controller by XM_DIS_FCNTL */
 	tx_fc = !!(efx->link_fc & EFX_FC_TX);
-	falcon_read(efx, &reg, FR_AZ_RX_CFG);
+	efx_reado(efx, &reg, FR_AZ_RX_CFG);
 	EFX_SET_OWORD_FIELD(reg, FRF_AZ_RX_XOFF_MAC_EN, tx_fc);
 
 	/* Unisolate the MAC -> RX */
 	if (falcon_rev(efx) >= FALCON_REV_B0)
 		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_INGR_EN, 1);
-	falcon_write(efx, &reg, FR_AZ_RX_CFG);
+	efx_writeo(efx, &reg, FR_AZ_RX_CFG);
 }
 
 int falcon_dma_stats(struct efx_nic *efx, unsigned int done_offset)
@@ -2041,7 +2048,7 @@ int falcon_dma_stats(struct efx_nic *efx, unsigned int done_offset)
 	/* Statistics fetch will fail if the MAC is in TX drain */
 	if (falcon_rev(efx) >= FALCON_REV_B0) {
 		efx_oword_t temp;
-		falcon_read(efx, &temp, FR_AB_MAC_CTRL);
+		efx_reado(efx, &temp, FR_AB_MAC_CTRL);
 		if (EFX_OWORD_FIELD(temp, FRF_BB_TXFIFO_DRAIN_EN))
 			return 0;
 	}
@@ -2055,7 +2062,7 @@ int falcon_dma_stats(struct efx_nic *efx, unsigned int done_offset)
 			     FRF_AB_MAC_STAT_DMA_CMD, 1,
 			     FRF_AB_MAC_STAT_DMA_ADR,
 			     efx->stats_buffer.dma_addr);
-	falcon_write(efx, &reg, FR_AB_MAC_STAT_DMA);
+	efx_writeo(efx, &reg, FR_AB_MAC_STAT_DMA);
 
 	/* Wait for transfer to complete */
 	for (i = 0; i < 400; i++) {
@@ -2085,7 +2092,7 @@ static int falcon_gmii_wait(struct efx_nic *efx)
 
 	/* wait upto 50ms - taken max from datasheet */
 	for (count = 0; count < 5000; count++) {
-		falcon_readl(efx, &md_stat, FR_AB_MD_STAT);
+		efx_readd(efx, &md_stat, FR_AB_MD_STAT);
 		if (EFX_DWORD_FIELD(md_stat, FRF_AB_MD_BSY) == 0) {
 			if (EFX_DWORD_FIELD(md_stat, FRF_AB_MD_LNFL) != 0 ||
 			    EFX_DWORD_FIELD(md_stat, FRF_AB_MD_BSERR) != 0) {
@@ -2122,20 +2129,20 @@ static int falcon_mdio_write(struct net_device *net_dev,
 
 	/* Write the address/ID register */
 	EFX_POPULATE_OWORD_1(reg, FRF_AB_MD_PHY_ADR, addr);
-	falcon_write(efx, &reg, FR_AB_MD_PHY_ADR);
+	efx_writeo(efx, &reg, FR_AB_MD_PHY_ADR);
 
 	EFX_POPULATE_OWORD_2(reg, FRF_AB_MD_PRT_ADR, prtad,
 			     FRF_AB_MD_DEV_ADR, devad);
-	falcon_write(efx, &reg, FR_AB_MD_ID);
+	efx_writeo(efx, &reg, FR_AB_MD_ID);
 
 	/* Write data */
 	EFX_POPULATE_OWORD_1(reg, FRF_AB_MD_TXD, value);
-	falcon_write(efx, &reg, FR_AB_MD_TXD);
+	efx_writeo(efx, &reg, FR_AB_MD_TXD);
 
 	EFX_POPULATE_OWORD_2(reg,
 			     FRF_AB_MD_WRC, 1,
 			     FRF_AB_MD_GC, 0);
-	falcon_write(efx, &reg, FR_AB_MD_CS);
+	efx_writeo(efx, &reg, FR_AB_MD_CS);
 
 	/* Wait for data to be written */
 	rc = falcon_gmii_wait(efx);
@@ -2144,7 +2151,7 @@ static int falcon_mdio_write(struct net_device *net_dev,
 		EFX_POPULATE_OWORD_2(reg,
 				     FRF_AB_MD_WRC, 0,
 				     FRF_AB_MD_GC, 1);
-		falcon_write(efx, &reg, FR_AB_MD_CS);
+		efx_writeo(efx, &reg, FR_AB_MD_CS);
 		udelay(10);
 	}
 
@@ -2169,20 +2176,20 @@ static int falcon_mdio_read(struct net_device *net_dev,
 		goto out;
 
 	EFX_POPULATE_OWORD_1(reg, FRF_AB_MD_PHY_ADR, addr);
-	falcon_write(efx, &reg, FR_AB_MD_PHY_ADR);
+	efx_writeo(efx, &reg, FR_AB_MD_PHY_ADR);
 
 	EFX_POPULATE_OWORD_2(reg, FRF_AB_MD_PRT_ADR, prtad,
 			     FRF_AB_MD_DEV_ADR, devad);
-	falcon_write(efx, &reg, FR_AB_MD_ID);
+	efx_writeo(efx, &reg, FR_AB_MD_ID);
 
 	/* Request data to be read */
 	EFX_POPULATE_OWORD_2(reg, FRF_AB_MD_RDC, 1, FRF_AB_MD_GC, 0);
-	falcon_write(efx, &reg, FR_AB_MD_CS);
+	efx_writeo(efx, &reg, FR_AB_MD_CS);
 
 	/* Wait for data to become available */
 	rc = falcon_gmii_wait(efx);
 	if (rc == 0) {
-		falcon_read(efx, &reg, FR_AB_MD_RXD);
+		efx_reado(efx, &reg, FR_AB_MD_RXD);
 		rc = EFX_OWORD_FIELD(reg, FRF_AB_MD_RXD);
 		EFX_REGDUMP(efx, "read from MDIO %d register %d.%d, got %04x\n",
 			    prtad, devad, addr, rc);
@@ -2191,7 +2198,7 @@ static int falcon_mdio_read(struct net_device *net_dev,
 		EFX_POPULATE_OWORD_2(reg,
 				     FRF_AB_MD_RIC, 0,
 				     FRF_AB_MD_GC, 1);
-		falcon_write(efx, &reg, FR_AB_MD_CS);
+		efx_writeo(efx, &reg, FR_AB_MD_CS);
 
 		EFX_LOG(efx, "read from MDIO %d register %d.%d, got error %d\n",
 			prtad, devad, addr, rc);
@@ -2258,12 +2265,12 @@ int falcon_switch_mac(struct efx_nic *efx)
 
 	/* Always push the NIC_STAT_REG setting even if the mac hasn't
 	 * changed, because this function is run post online reset */
-	falcon_read(efx, &nic_stat, FR_AB_NIC_STAT);
+	efx_reado(efx, &nic_stat, FR_AB_NIC_STAT);
 	strap_val = EFX_IS10G(efx) ? 5 : 3;
 	if (falcon_rev(efx) >= FALCON_REV_B0) {
 		EFX_SET_OWORD_FIELD(nic_stat, FRF_BB_EE_STRAP_EN, 1);
 		EFX_SET_OWORD_FIELD(nic_stat, FRF_BB_EE_STRAP, strap_val);
-		falcon_write(efx, &nic_stat, FR_AB_NIC_STAT);
+		efx_writeo(efx, &nic_stat, FR_AB_NIC_STAT);
 	} else {
 		/* Falcon A1 does not support 1G/10G speed switching
 		 * and must not be used with a PHY that does. */
@@ -2341,8 +2348,8 @@ void falcon_set_multicast_hash(struct efx_nic *efx)
 	 */
 	set_bit_le(0xff, mc_hash->byte);
 
-	falcon_write(efx, &mc_hash->oword[0], FR_AB_MAC_MC_HASH_REG0);
-	falcon_write(efx, &mc_hash->oword[1], FR_AB_MAC_MC_HASH_REG1);
+	efx_writeo(efx, &mc_hash->oword[0], FR_AB_MAC_MC_HASH_REG0);
+	efx_writeo(efx, &mc_hash->oword[1], FR_AB_MAC_MC_HASH_REG1);
 }
 

@@ -2478,7 +2485,7 @@ int falcon_test_registers(struct efx_nic *efx)
 		mask = imask = efx_test_registers[i].mask;
 		EFX_INVERT_OWORD(imask);
 
-		falcon_read(efx, &original, address);
+		efx_reado(efx, &original, address);
 
 		/* bit sweep on and off */
 		for (j = 0; j < 128; j++) {
@@ -2489,8 +2496,8 @@ int falcon_test_registers(struct efx_nic *efx)
 			EFX_AND_OWORD(reg, original, mask);
 			EFX_SET_OWORD32(reg, j, j, 1);
 
-			falcon_write(efx, &reg, address);
-			falcon_read(efx, &buf, address);
+			efx_writeo(efx, &reg, address);
+			efx_reado(efx, &buf, address);
 
 			if (efx_masked_compare_oword(&reg, &buf, &mask))
 				goto fail;
@@ -2499,14 +2506,14 @@ int falcon_test_registers(struct efx_nic *efx)
 			EFX_OR_OWORD(reg, original, mask);
 			EFX_SET_OWORD32(reg, j, j, 0);
 
-			falcon_write(efx, &reg, address);
-			falcon_read(efx, &buf, address);
+			efx_writeo(efx, &reg, address);
+			efx_reado(efx, &buf, address);
 
 			if (efx_masked_compare_oword(&reg, &buf, &mask))
 				goto fail;
 		}
 
-		falcon_write(efx, &original, address);
+		efx_writeo(efx, &original, address);
 	}
 
 	return 0;
@@ -2571,7 +2578,7 @@ int falcon_reset_hw(struct efx_nic *efx, enum reset_type method)
 				     FFE_AB_EXT_PHY_RST_DUR_10240US,
 				     FRF_AB_SWRST, 1);
 	}
-	falcon_write(efx, &glb_ctl_reg_ker, FR_AB_GLB_CTL);
+	efx_writeo(efx, &glb_ctl_reg_ker, FR_AB_GLB_CTL);
 
 	EFX_LOG(efx, "waiting for hardware reset\n");
 	schedule_timeout_uninterruptible(HZ / 20);
@@ -2596,7 +2603,7 @@ int falcon_reset_hw(struct efx_nic *efx, enum reset_type method)
 	}
 
 	/* Assert that reset complete */
-	falcon_read(efx, &glb_ctl_reg_ker, FR_AB_GLB_CTL);
+	efx_reado(efx, &glb_ctl_reg_ker, FR_AB_GLB_CTL);
 	if (EFX_OWORD_FIELD(glb_ctl_reg_ker, FRF_AB_SWRST) != 0) {
 		rc = -ETIMEDOUT;
 		EFX_ERR(efx, "timed out waiting for hardware reset\n");
@@ -2625,16 +2632,16 @@ static int falcon_reset_sram(struct efx_nic *efx)
 	int count;
 
 	/* Set the SRAM wake/sleep GPIO appropriately. */
-	falcon_read(efx, &gpio_cfg_reg_ker, FR_AB_GPIO_CTL);
+	efx_reado(efx, &gpio_cfg_reg_ker, FR_AB_GPIO_CTL);
 	EFX_SET_OWORD_FIELD(gpio_cfg_reg_ker, FRF_AB_GPIO1_OEN, 1);
 	EFX_SET_OWORD_FIELD(gpio_cfg_reg_ker, FRF_AB_GPIO1_OUT, 1);
-	falcon_write(efx, &gpio_cfg_reg_ker, FR_AB_GPIO_CTL);
+	efx_writeo(efx, &gpio_cfg_reg_ker, FR_AB_GPIO_CTL);
 
 	/* Initiate SRAM reset */
 	EFX_POPULATE_OWORD_2(srm_cfg_reg_ker,
 			     FRF_AZ_SRM_INIT_EN, 1,
 			     FRF_AZ_SRM_NB_SZ, 0);
-	falcon_write(efx, &srm_cfg_reg_ker, FR_AZ_SRM_CFG);
+	efx_writeo(efx, &srm_cfg_reg_ker, FR_AZ_SRM_CFG);
 
 	/* Wait for SRAM reset to complete */
 	count = 0;
@@ -2645,7 +2652,7 @@ static int falcon_reset_sram(struct efx_nic *efx)
 		schedule_timeout_uninterruptible(HZ / 50);
 
 		/* Check for reset complete */
-		falcon_read(efx, &srm_cfg_reg_ker, FR_AZ_SRM_CFG);
+		efx_reado(efx, &srm_cfg_reg_ker, FR_AZ_SRM_CFG);
 		if (!EFX_OWORD_FIELD(srm_cfg_reg_ker, FRF_AZ_SRM_INIT_EN)) {
 			EFX_LOG(efx, "SRAM reset complete\n");
 
@@ -2771,13 +2778,13 @@ static int falcon_probe_nic_variant(struct efx_nic *efx)
 	efx_oword_t altera_build;
 	efx_oword_t nic_stat;
 
-	falcon_read(efx, &altera_build, FR_AZ_ALTERA_BUILD);
+	efx_reado(efx, &altera_build, FR_AZ_ALTERA_BUILD);
 	if (EFX_OWORD_FIELD(altera_build, FRF_AZ_ALTERA_BUILD_VER)) {
 		EFX_ERR(efx, "Falcon FPGA not supported\n");
 		return -ENODEV;
 	}
 
-	falcon_read(efx, &nic_stat, FR_AB_NIC_STAT);
+	efx_reado(efx, &nic_stat, FR_AB_NIC_STAT);
 
 	switch (falcon_rev(efx)) {
 	case FALCON_REV_A0:
@@ -2812,9 +2819,9 @@ static void falcon_probe_spi_devices(struct efx_nic *efx)
 	efx_oword_t nic_stat, gpio_ctl, ee_vpd_cfg;
 	int boot_dev;
 
-	falcon_read(efx, &gpio_ctl, FR_AB_GPIO_CTL);
-	falcon_read(efx, &nic_stat, FR_AB_NIC_STAT);
-	falcon_read(efx, &ee_vpd_cfg, FR_AB_EE_VPD_CFG0);
+	efx_reado(efx, &gpio_ctl, FR_AB_GPIO_CTL);
+	efx_reado(efx, &nic_stat, FR_AB_NIC_STAT);
+	efx_reado(efx, &ee_vpd_cfg, FR_AB_EE_VPD_CFG0);
 
 	if (EFX_OWORD_FIELD(gpio_ctl, FRF_AB_GPIO3_PWRUP_VALUE)) {
 		boot_dev = (EFX_OWORD_FIELD(nic_stat, FRF_AB_SF_PRST) ?
@@ -2832,7 +2839,7 @@ static void falcon_probe_spi_devices(struct efx_nic *efx)
 				     FRF_AB_EE_SF_CLOCK_DIV, 7,
 				     /* 125 MHz / 63 ~= 2 MHz */
 				     FRF_AB_EE_EE_CLOCK_DIV, 63);
-		falcon_write(efx, &ee_vpd_cfg, FR_AB_EE_VPD_CFG0);
+		efx_writeo(efx, &ee_vpd_cfg, FR_AB_EE_VPD_CFG0);
 	}
 
 	if (boot_dev == FFE_AB_SPI_DEVICE_FLASH)
@@ -2946,7 +2953,7 @@ static void falcon_init_rx_cfg(struct efx_nic *efx)
 	int data_xoff_thr = rx_xoff_thresh_bytes >> 8;
 	efx_oword_t reg;
 
-	falcon_read(efx, &reg, FR_AZ_RX_CFG);
+	efx_reado(efx, &reg, FR_AZ_RX_CFG);
 	if (falcon_rev(efx) <= FALCON_REV_A1) {
 		/* Data FIFO size is 5.5K */
 		if (data_xon_thr < 0)
@@ -2975,7 +2982,7 @@ static void falcon_init_rx_cfg(struct efx_nic *efx)
 		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_XOFF_TX_TH, ctrl_xoff_thr);
 		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_INGR_EN, 1);
 	}
-	falcon_write(efx, &reg, FR_AZ_RX_CFG);
+	efx_writeo(efx, &reg, FR_AZ_RX_CFG);
 }
 
 /* This call performs hardware-specific global initialisation, such as
@@ -2988,15 +2995,15 @@ int falcon_init_nic(struct efx_nic *efx)
 	int rc;
 
 	/* Use on-chip SRAM */
-	falcon_read(efx, &temp, FR_AB_NIC_STAT);
+	efx_reado(efx, &temp, FR_AB_NIC_STAT);
 	EFX_SET_OWORD_FIELD(temp, FRF_AB_ONCHIP_SRAM, 1);
-	falcon_write(efx, &temp, FR_AB_NIC_STAT);
+	efx_writeo(efx, &temp, FR_AB_NIC_STAT);
 
 	/* Set the source of the GMAC clock */
 	if (falcon_rev(efx) == FALCON_REV_B0) {
-		falcon_read(efx, &temp, FR_AB_GPIO_CTL);
+		efx_reado(efx, &temp, FR_AB_GPIO_CTL);
 		EFX_SET_OWORD_FIELD(temp, FRF_AB_USE_NIC_CLK, true);
-		falcon_write(efx, &temp, FR_AB_GPIO_CTL);
+		efx_writeo(efx, &temp, FR_AB_GPIO_CTL);
 	}
 
 	rc = falcon_reset_sram(efx);
@@ -3005,31 +3012,31 @@ int falcon_init_nic(struct efx_nic *efx)
 
 	/* Set positions of descriptor caches in SRAM. */
 	EFX_POPULATE_OWORD_1(temp, FRF_AZ_SRM_TX_DC_BASE_ADR, TX_DC_BASE / 8);
-	falcon_write(efx, &temp, FR_AZ_SRM_TX_DC_CFG);
+	efx_writeo(efx, &temp, FR_AZ_SRM_TX_DC_CFG);
 	EFX_POPULATE_OWORD_1(temp, FRF_AZ_SRM_RX_DC_BASE_ADR, RX_DC_BASE / 8);
-	falcon_write(efx, &temp, FR_AZ_SRM_RX_DC_CFG);
+	efx_writeo(efx, &temp, FR_AZ_SRM_RX_DC_CFG);
 
 	/* Set TX descriptor cache size. */
 	BUILD_BUG_ON(TX_DC_ENTRIES != (16 << TX_DC_ENTRIES_ORDER));
 	EFX_POPULATE_OWORD_1(temp, FRF_AZ_TX_DC_SIZE, TX_DC_ENTRIES_ORDER);
-	falcon_write(efx, &temp, FR_AZ_TX_DC_CFG);
+	efx_writeo(efx, &temp, FR_AZ_TX_DC_CFG);
 
 	/* Set RX descriptor cache size.  Set low watermark to size-8, as
 	 * this allows most efficient prefetching.
 	 */
 	BUILD_BUG_ON(RX_DC_ENTRIES != (16 << RX_DC_ENTRIES_ORDER));
 	EFX_POPULATE_OWORD_1(temp, FRF_AZ_RX_DC_SIZE, RX_DC_ENTRIES_ORDER);
-	falcon_write(efx, &temp, FR_AZ_RX_DC_CFG);
+	efx_writeo(efx, &temp, FR_AZ_RX_DC_CFG);
 	EFX_POPULATE_OWORD_1(temp, FRF_AZ_RX_DC_PF_LWM, RX_DC_ENTRIES - 8);
-	falcon_write(efx, &temp, FR_AZ_RX_DC_PF_WM);
+	efx_writeo(efx, &temp, FR_AZ_RX_DC_PF_WM);
 
 	/* Clear the parity enables on the TX data fifos as
 	 * they produce false parity errors because of timing issues
 	 */
 	if (EFX_WORKAROUND_5129(efx)) {
-		falcon_read(efx, &temp, FR_AZ_CSR_SPARE);
+		efx_reado(efx, &temp, FR_AZ_CSR_SPARE);
 		EFX_SET_OWORD_FIELD(temp, FRF_AB_MEM_PERR_EN_TX_DATA, 0);
-		falcon_write(efx, &temp, FR_AZ_CSR_SPARE);
+		efx_writeo(efx, &temp, FR_AZ_CSR_SPARE);
 	}
 
 	/* Enable all the genuinely fatal interrupts.  (They are still
@@ -3043,15 +3050,15 @@ int falcon_init_nic(struct efx_nic *efx)
 			     FRF_AZ_RBUF_OWN_INT_KER_EN, 1,
 			     FRF_AZ_TBUF_OWN_INT_KER_EN, 1);
 	EFX_INVERT_OWORD(temp);
-	falcon_write(efx, &temp, FR_AZ_FATAL_INTR_KER);
+	efx_writeo(efx, &temp, FR_AZ_FATAL_INTR_KER);
 
 	if (EFX_WORKAROUND_7244(efx)) {
-		falcon_read(efx, &temp, FR_BZ_RX_FILTER_CTL);
+		efx_reado(efx, &temp, FR_BZ_RX_FILTER_CTL);
 		EFX_SET_OWORD_FIELD(temp, FRF_BZ_UDP_FULL_SRCH_LIMIT, 8);
 		EFX_SET_OWORD_FIELD(temp, FRF_BZ_UDP_WILD_SRCH_LIMIT, 8);
 		EFX_SET_OWORD_FIELD(temp, FRF_BZ_TCP_FULL_SRCH_LIMIT, 8);
 		EFX_SET_OWORD_FIELD(temp, FRF_BZ_TCP_WILD_SRCH_LIMIT, 8);
-		falcon_write(efx, &temp, FR_BZ_RX_FILTER_CTL);
+		efx_writeo(efx, &temp, FR_BZ_RX_FILTER_CTL);
 	}
 
 	falcon_setup_rss_indir_table(efx);
@@ -3060,17 +3067,17 @@ int falcon_init_nic(struct efx_nic *efx)
 	/* Setup RX.  Wait for descriptor is broken and must
 	 * be disabled.  RXDP recovery shouldn't be needed, but is.
 	 */
-	falcon_read(efx, &temp, FR_AA_RX_SELF_RST);
+	efx_reado(efx, &temp, FR_AA_RX_SELF_RST);
 	EFX_SET_OWORD_FIELD(temp, FRF_AA_RX_NODESC_WAIT_DIS, 1);
 	EFX_SET_OWORD_FIELD(temp, FRF_AA_RX_SELF_RST_EN, 1);
 	if (EFX_WORKAROUND_5583(efx))
 		EFX_SET_OWORD_FIELD(temp, FRF_AA_RX_ISCSI_DIS, 1);
-	falcon_write(efx, &temp, FR_AA_RX_SELF_RST);
+	efx_writeo(efx, &temp, FR_AA_RX_SELF_RST);
 
 	/* Disable the ugly timer-based TX DMA backoff and allow TX DMA to be
 	 * controlled by the RX FIFO fill level. Set arbitration to one pkt/Q.
 	 */
-	falcon_read(efx, &temp, FR_AZ_TX_RESERVED);
+	efx_reado(efx, &temp, FR_AZ_TX_RESERVED);
 	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_RX_SPACER, 0xfe);
 	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_RX_SPACER_EN, 1);
 	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_ONE_PKT_PER_Q, 1);
@@ -3083,21 +3090,21 @@ int falcon_init_nic(struct efx_nic *efx)
 	/* Squash TX of packets of 16 bytes or less */
 	if (falcon_rev(efx) >= FALCON_REV_B0 && EFX_WORKAROUND_9141(efx))
 		EFX_SET_OWORD_FIELD(temp, FRF_BZ_TX_FLUSH_MIN_LEN_EN, 1);
-	falcon_write(efx, &temp, FR_AZ_TX_RESERVED);
+	efx_writeo(efx, &temp, FR_AZ_TX_RESERVED);
 
 	/* Do not enable TX_NO_EOP_DISC_EN, since it limits packets to 16
 	 * descriptors (which is bad).
 	 */
-	falcon_read(efx, &temp, FR_AZ_TX_CFG);
+	efx_reado(efx, &temp, FR_AZ_TX_CFG);
 	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_NO_EOP_DISC_EN, 0);
-	falcon_write(efx, &temp, FR_AZ_TX_CFG);
+	efx_writeo(efx, &temp, FR_AZ_TX_CFG);
 
 	falcon_init_rx_cfg(efx);
 
 	/* Set destination of both TX and RX Flush events */
 	if (falcon_rev(efx) >= FALCON_REV_B0) {
 		EFX_POPULATE_OWORD_1(temp, FRF_BZ_FLS_EVQ_ID, 0);
-		falcon_write(efx, &temp, FR_BZ_DP_CTRL);
+		efx_writeo(efx, &temp, FR_BZ_DP_CTRL);
 	}
 
 	return 0;
@@ -3133,7 +3140,7 @@ void falcon_update_nic_stats(struct efx_nic *efx)
 {
 	efx_oword_t cnt;
 
-	falcon_read(efx, &cnt, FR_AZ_RX_NODESC_DROP);
+	efx_reado(efx, &cnt, FR_AZ_RX_NODESC_DROP);
 	efx->n_rx_nodesc_drop_cnt +=
 		EFX_OWORD_FIELD(cnt, FRF_AB_RX_NODESC_DROP_CNT);
 }
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index 68ca45c..3078c00 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -14,7 +14,7 @@
 #include "efx.h"
 #include "falcon.h"
 #include "regs.h"
-#include "falcon_io.h"
+#include "io.h"
 #include "workarounds.h"
 
 /* Macros for unpacking the board revision */
@@ -332,14 +332,14 @@ static int sfn4111t_reset(struct efx_nic *efx)
 	 * FLASH_CFG_1 strap (GPIO 3) appropriately.  Only change the
 	 * output enables; the output levels should always be 0 (low)
 	 * and we rely on external pull-ups. */
-	falcon_read(efx, &reg, FR_AB_GPIO_CTL);
+	efx_reado(efx, &reg, FR_AB_GPIO_CTL);
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_GPIO2_OEN, true);
-	falcon_write(efx, &reg, FR_AB_GPIO_CTL);
+	efx_writeo(efx, &reg, FR_AB_GPIO_CTL);
 	msleep(1000);
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_GPIO2_OEN, false);
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_GPIO3_OEN,
 			    !!(efx->phy_mode & PHY_MODE_SPECIAL));
-	falcon_write(efx, &reg, FR_AB_GPIO_CTL);
+	efx_writeo(efx, &reg, FR_AB_GPIO_CTL);
 	msleep(1);
 
 	mutex_unlock(&efx->i2c_adap.bus_lock);
diff --git a/drivers/net/sfc/falcon_gmac.c b/drivers/net/sfc/falcon_gmac.c
index 0d156c8..8a1b80d 100644
--- a/drivers/net/sfc/falcon_gmac.c
+++ b/drivers/net/sfc/falcon_gmac.c
@@ -14,7 +14,7 @@
 #include "falcon.h"
 #include "mac.h"
 #include "regs.h"
-#include "falcon_io.h"
+#include "io.h"
 
 /**************************************************************************
  *
@@ -41,7 +41,7 @@ static void falcon_reconfigure_gmac(struct efx_nic *efx)
 			     FRF_AB_GM_TX_FC_EN, tx_fc,
 			     FRF_AB_GM_RX_EN, 1,
 			     FRF_AB_GM_RX_FC_EN, rx_fc);
-	falcon_write(efx, &reg, FR_AB_GM_CFG1);
+	efx_writeo(efx, &reg, FR_AB_GM_CFG1);
 	udelay(10);
 
 	/* Configuration register 2 */
@@ -53,13 +53,13 @@ static void falcon_reconfigure_gmac(struct efx_nic *efx)
 			     FRF_AB_GM_FD, efx->link_fd,
 			     FRF_AB_GM_PAMBL_LEN, 0x7/*datasheet recommended */);
 
-	falcon_write(efx, &reg, FR_AB_GM_CFG2);
+	efx_writeo(efx, &reg, FR_AB_GM_CFG2);
 	udelay(10);
 
 	/* Max frame len register */
 	max_frame_len = EFX_MAX_FRAME_LEN(efx->net_dev->mtu);
 	EFX_POPULATE_OWORD_1(reg, FRF_AB_GM_MAX_FLEN, max_frame_len);
-	falcon_write(efx, &reg, FR_AB_GM_MAX_FLEN);
+	efx_writeo(efx, &reg, FR_AB_GM_MAX_FLEN);
 	udelay(10);
 
 	/* FIFO configuration register 0 */
@@ -69,42 +69,42 @@ static void falcon_reconfigure_gmac(struct efx_nic *efx)
 			     FRF_AB_GMF_FRFENREQ, 1,
 			     FRF_AB_GMF_SRFENREQ, 1,
 			     FRF_AB_GMF_WTMENREQ, 1);
-	falcon_write(efx, &reg, FR_AB_GMF_CFG0);
+	efx_writeo(efx, &reg, FR_AB_GMF_CFG0);
 	udelay(10);
 
 	/* FIFO configuration register 1 */
 	EFX_POPULATE_OWORD_2(reg,
 			     FRF_AB_GMF_CFGFRTH, 0x12,
 			     FRF_AB_GMF_CFGXOFFRTX, 0xffff);
-	falcon_write(efx, &reg, FR_AB_GMF_CFG1);
+	efx_writeo(efx, &reg, FR_AB_GMF_CFG1);
 	udelay(10);
 
 	/* FIFO configuration register 2 */
 	EFX_POPULATE_OWORD_2(reg,
 			     FRF_AB_GMF_CFGHWM, 0x3f,
 			     FRF_AB_GMF_CFGLWM, 0xa);
-	falcon_write(efx, &reg, FR_AB_GMF_CFG2);
+	efx_writeo(efx, &reg, FR_AB_GMF_CFG2);
 	udelay(10);
 
 	/* FIFO configuration register 3 */
 	EFX_POPULATE_OWORD_2(reg,
 			     FRF_AB_GMF_CFGHWMFT, 0x1c,
 			     FRF_AB_GMF_CFGFTTH, 0x08);
-	falcon_write(efx, &reg, FR_AB_GMF_CFG3);
+	efx_writeo(efx, &reg, FR_AB_GMF_CFG3);
 	udelay(10);
 
 	/* FIFO configuration register 4 */
 	EFX_POPULATE_OWORD_1(reg, FRF_AB_GMF_HSTFLTRFRM_PAUSE, 1);
-	falcon_write(efx, &reg, FR_AB_GMF_CFG4);
+	efx_writeo(efx, &reg, FR_AB_GMF_CFG4);
 	udelay(10);
 
 	/* FIFO configuration register 5 */
-	falcon_read(efx, &reg, FR_AB_GMF_CFG5);
+	efx_reado(efx, &reg, FR_AB_GMF_CFG5);
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_GMF_CFGBYTMODE, bytemode);
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_GMF_CFGHDPLX, !efx->link_fd);
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_GMF_HSTDRPLT64, !efx->link_fd);
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_GMF_HSTFLTRFRMDC_PAUSE, 0);
-	falcon_write(efx, &reg, FR_AB_GMF_CFG5);
+	efx_writeo(efx, &reg, FR_AB_GMF_CFG5);
 	udelay(10);
 
 	/* MAC address */
@@ -113,12 +113,12 @@ static void falcon_reconfigure_gmac(struct efx_nic *efx)
 			     FRF_AB_GM_ADR_B1, efx->net_dev->dev_addr[4],
 			     FRF_AB_GM_ADR_B2, efx->net_dev->dev_addr[3],
 			     FRF_AB_GM_ADR_B3, efx->net_dev->dev_addr[2]);
-	falcon_write(efx, &reg, FR_AB_GM_ADR1);
+	efx_writeo(efx, &reg, FR_AB_GM_ADR1);
 	udelay(10);
 	EFX_POPULATE_OWORD_2(reg,
 			     FRF_AB_GM_ADR_B4, efx->net_dev->dev_addr[1],
 			     FRF_AB_GM_ADR_B5, efx->net_dev->dev_addr[0]);
-	falcon_write(efx, &reg, FR_AB_GM_ADR2);
+	efx_writeo(efx, &reg, FR_AB_GM_ADR2);
 	udelay(10);
 
 	falcon_reconfigure_mac_wrapper(efx);
diff --git a/drivers/net/sfc/falcon_io.h b/drivers/net/sfc/falcon_io.h
deleted file mode 100644
index 8883092..0000000
--- a/drivers/net/sfc/falcon_io.h
+++ /dev/null
@@ -1,258 +0,0 @@
-/****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2008 Solarflare Communications Inc.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License version 2 as published
- * by the Free Software Foundation, incorporated herein by reference.
- */
-
-#ifndef EFX_FALCON_IO_H
-#define EFX_FALCON_IO_H
-
-#include <linux/io.h>
-#include <linux/spinlock.h>
-
-/**************************************************************************
- *
- * Falcon hardware access
- *
- **************************************************************************
- *
- * Notes on locking strategy:
- *
- * Most Falcon registers require 16-byte (or 8-byte, for SRAM
- * registers) atomic writes which necessitates locking.
- * Under normal operation few writes to the Falcon BAR are made and these
- * registers (EVQ_RPTR_REG, RX_DESC_UPD_REG and TX_DESC_UPD_REG) are special
- * cased to allow 4-byte (hence lockless) accesses.
- *
- * It *is* safe to write to these 4-byte registers in the middle of an
- * access to an 8-byte or 16-byte register.  We therefore use a
- * spinlock to protect accesses to the larger registers, but no locks
- * for the 4-byte registers.
- *
- * A write barrier is needed to ensure that DW3 is written after DW0/1/2
- * due to the way the 16byte registers are "collected" in the Falcon BIU
- *
- * We also lock when carrying out reads, to ensure consistency of the
- * data (made possible since the BIU reads all 128 bits into a cache).
- * Reads are very rare, so this isn't a significant performance
- * impact.  (Most data transferred from NIC to host is DMAed directly
- * into host memory).
- *
- * I/O BAR access uses locks for both reads and writes (but is only provided
- * for testing purposes).
- */
-
-/* Special buffer descriptors (Falcon SRAM) */
-#define BUF_TBL_KER_A1 0x18000
-#define BUF_TBL_KER_B0 0x800000
-
-
-#if BITS_PER_LONG == 64
-#define FALCON_USE_QWORD_IO 1
-#endif
-
-#ifdef FALCON_USE_QWORD_IO
-static inline void _falcon_writeq(struct efx_nic *efx, __le64 value,
-				  unsigned int reg)
-{
-	__raw_writeq((__force u64)value, efx->membase + reg);
-}
-static inline __le64 _falcon_readq(struct efx_nic *efx, unsigned int reg)
-{
-	return (__force __le64)__raw_readq(efx->membase + reg);
-}
-#endif
-
-static inline void _falcon_writel(struct efx_nic *efx, __le32 value,
-				  unsigned int reg)
-{
-	__raw_writel((__force u32)value, efx->membase + reg);
-}
-static inline __le32 _falcon_readl(struct efx_nic *efx, unsigned int reg)
-{
-	return (__force __le32)__raw_readl(efx->membase + reg);
-}
-
-/* Writes to a normal 16-byte Falcon register, locking as appropriate. */
-static inline void falcon_write(struct efx_nic *efx, efx_oword_t *value,
-				unsigned int reg)
-{
-	unsigned long flags;
-
-	EFX_REGDUMP(efx, "writing register %x with " EFX_OWORD_FMT "\n", reg,
-		    EFX_OWORD_VAL(*value));
-
-	spin_lock_irqsave(&efx->biu_lock, flags);
-#ifdef FALCON_USE_QWORD_IO
-	_falcon_writeq(efx, value->u64[0], reg + 0);
-	wmb();
-	_falcon_writeq(efx, value->u64[1], reg + 8);
-#else
-	_falcon_writel(efx, value->u32[0], reg + 0);
-	_falcon_writel(efx, value->u32[1], reg + 4);
-	_falcon_writel(efx, value->u32[2], reg + 8);
-	wmb();
-	_falcon_writel(efx, value->u32[3], reg + 12);
-#endif
-	mmiowb();
-	spin_unlock_irqrestore(&efx->biu_lock, flags);
-}
-
-/* Writes to an 8-byte Falcon SRAM register, locking as appropriate. */
-static inline void falcon_write_sram(struct efx_nic *efx, efx_qword_t *value,
-				     unsigned int index)
-{
-	unsigned int reg = efx->type->buf_tbl_base + (index * sizeof(*value));
-	unsigned long flags;
-
-	EFX_REGDUMP(efx, "writing SRAM register %x with " EFX_QWORD_FMT "\n",
-		    reg, EFX_QWORD_VAL(*value));
-
-	spin_lock_irqsave(&efx->biu_lock, flags);
-#ifdef FALCON_USE_QWORD_IO
-	_falcon_writeq(efx, value->u64[0], reg + 0);
-#else
-	_falcon_writel(efx, value->u32[0], reg + 0);
-	wmb();
-	_falcon_writel(efx, value->u32[1], reg + 4);
-#endif
-	mmiowb();
-	spin_unlock_irqrestore(&efx->biu_lock, flags);
-}
-
-/* Write dword to Falcon register that allows partial writes
- *
- * Some Falcon registers (EVQ_RPTR_REG, RX_DESC_UPD_REG and
- * TX_DESC_UPD_REG) can be written to as a single dword.  This allows
- * for lockless writes.
- */
-static inline void falcon_writel(struct efx_nic *efx, efx_dword_t *value,
-				 unsigned int reg)
-{
-	EFX_REGDUMP(efx, "writing partial register %x with "EFX_DWORD_FMT"\n",
-		    reg, EFX_DWORD_VAL(*value));
-
-	/* No lock required */
-	_falcon_writel(efx, value->u32[0], reg);
-}
-
-/* Read from a Falcon register
- *
- * This reads an entire 16-byte Falcon register in one go, locking as
- * appropriate.  It is essential to read the first dword first, as this
- * prompts Falcon to load the current value into the shadow register.
- */
-static inline void falcon_read(struct efx_nic *efx, efx_oword_t *value,
-			       unsigned int reg)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&efx->biu_lock, flags);
-	value->u32[0] = _falcon_readl(efx, reg + 0);
-	rmb();
-	value->u32[1] = _falcon_readl(efx, reg + 4);
-	value->u32[2] = _falcon_readl(efx, reg + 8);
-	value->u32[3] = _falcon_readl(efx, reg + 12);
-	spin_unlock_irqrestore(&efx->biu_lock, flags);
-
-	EFX_REGDUMP(efx, "read from register %x, got " EFX_OWORD_FMT "\n", reg,
-		    EFX_OWORD_VAL(*value));
-}
-
-/* This reads an 8-byte Falcon SRAM entry in one go. */
-static inline void falcon_read_sram(struct efx_nic *efx, efx_qword_t *value,
-				    unsigned int index)
-{
-	unsigned int reg = efx->type->buf_tbl_base + (index * sizeof(*value));
-	unsigned long flags;
-
-	spin_lock_irqsave(&efx->biu_lock, flags);
-#ifdef FALCON_USE_QWORD_IO
-	value->u64[0] = _falcon_readq(efx, reg + 0);
-#else
-	value->u32[0] = _falcon_readl(efx, reg + 0);
-	rmb();
-	value->u32[1] = _falcon_readl(efx, reg + 4);
-#endif
-	spin_unlock_irqrestore(&efx->biu_lock, flags);
-
-	EFX_REGDUMP(efx, "read from SRAM register %x, got "EFX_QWORD_FMT"\n",
-		    reg, EFX_QWORD_VAL(*value));
-}
-
-/* Read dword from Falcon register that allows partial writes (sic) */
-static inline void falcon_readl(struct efx_nic *efx, efx_dword_t *value,
-				unsigned int reg)
-{
-	value->u32[0] = _falcon_readl(efx, reg);
-	EFX_REGDUMP(efx, "read from register %x, got "EFX_DWORD_FMT"\n",
-		    reg, EFX_DWORD_VAL(*value));
-}
-
-/* Write to a register forming part of a table */
-static inline void falcon_write_table(struct efx_nic *efx, efx_oword_t *value,
-				      unsigned int reg, unsigned int index)
-{
-	falcon_write(efx, value, reg + index * sizeof(efx_oword_t));
-}
-
-/* Read to a register forming part of a table */
-static inline void falcon_read_table(struct efx_nic *efx, efx_oword_t *value,
-				     unsigned int reg, unsigned int index)
-{
-	falcon_read(efx, value, reg + index * sizeof(efx_oword_t));
-}
-
-/* Write to a dword register forming part of a table */
-static inline void falcon_writel_table(struct efx_nic *efx, efx_dword_t *value,
-				       unsigned int reg, unsigned int index)
-{
-	falcon_writel(efx, value, reg + index * sizeof(efx_oword_t));
-}
-
-/* Page-mapped register block size */
-#define FALCON_PAGE_BLOCK_SIZE 0x2000
-
-/* Calculate offset to page-mapped register block */
-#define FALCON_PAGED_REG(page, reg) \
-	((page) * FALCON_PAGE_BLOCK_SIZE + (reg))
-
-/* As for falcon_write(), but for a page-mapped register. */
-static inline void falcon_write_page(struct efx_nic *efx, efx_oword_t *value,
-				     unsigned int reg, unsigned int page)
-{
-	falcon_write(efx, value, FALCON_PAGED_REG(page, reg));
-}
-
-/* As for falcon_writel(), but for a page-mapped register. */
-static inline void falcon_writel_page(struct efx_nic *efx, efx_dword_t *value,
-				      unsigned int reg, unsigned int page)
-{
-	falcon_writel(efx, value, FALCON_PAGED_REG(page, reg));
-}
-
-/* Write dword to Falcon page-mapped register with an extra lock.
- *
- * As for falcon_writel_page(), but for a register that suffers from
- * SFC bug 3181.  If writing to page 0, take out a lock so the BIU
- * collector cannot be confused.
- */
-static inline void falcon_writel_page_locked(struct efx_nic *efx,
-					     efx_dword_t *value,
-					     unsigned int reg,
-					     unsigned int page)
-{
-	unsigned long flags = 0;
-
-	if (page == 0)
-		spin_lock_irqsave(&efx->biu_lock, flags);
-	falcon_writel(efx, value, FALCON_PAGED_REG(page, reg));
-	if (page == 0)
-		spin_unlock_irqrestore(&efx->biu_lock, flags);
-}
-
-#endif /* EFX_FALCON_IO_H */
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index 44e6558..7e57b4a 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -13,7 +13,7 @@
 #include "efx.h"
 #include "falcon.h"
 #include "regs.h"
-#include "falcon_io.h"
+#include "io.h"
 #include "mac.h"
 #include "mdio_10g.h"
 #include "phy.h"
@@ -35,7 +35,7 @@ static void falcon_setup_xaui(struct efx_nic *efx)
 	if (efx->phy_type == PHY_TYPE_NONE)
 		return;
 
-	falcon_read(efx, &sdctl, FR_AB_XX_SD_CTL);
+	efx_reado(efx, &sdctl, FR_AB_XX_SD_CTL);
 	EFX_SET_OWORD_FIELD(sdctl, FRF_AB_XX_HIDRVD, FFE_AB_XX_SD_CTL_DRV_DEF);
 	EFX_SET_OWORD_FIELD(sdctl, FRF_AB_XX_LODRVD, FFE_AB_XX_SD_CTL_DRV_DEF);
 	EFX_SET_OWORD_FIELD(sdctl, FRF_AB_XX_HIDRVC, FFE_AB_XX_SD_CTL_DRV_DEF);
@@ -44,7 +44,7 @@ static void falcon_setup_xaui(struct efx_nic *efx)
 	EFX_SET_OWORD_FIELD(sdctl, FRF_AB_XX_LODRVB, FFE_AB_XX_SD_CTL_DRV_DEF);
 	EFX_SET_OWORD_FIELD(sdctl, FRF_AB_XX_HIDRVA, FFE_AB_XX_SD_CTL_DRV_DEF);
 	EFX_SET_OWORD_FIELD(sdctl, FRF_AB_XX_LODRVA, FFE_AB_XX_SD_CTL_DRV_DEF);
-	falcon_write(efx, &sdctl, FR_AB_XX_SD_CTL);
+	efx_writeo(efx, &sdctl, FR_AB_XX_SD_CTL);
 
 	EFX_POPULATE_OWORD_8(txdrv,
 			     FRF_AB_XX_DEQD, FFE_AB_XX_TXDRV_DEQ_DEF,
@@ -55,7 +55,7 @@ static void falcon_setup_xaui(struct efx_nic *efx)
 			     FRF_AB_XX_DTXC, FFE_AB_XX_TXDRV_DTX_DEF,
 			     FRF_AB_XX_DTXB, FFE_AB_XX_TXDRV_DTX_DEF,
 			     FRF_AB_XX_DTXA, FFE_AB_XX_TXDRV_DTX_DEF);
-	falcon_write(efx, &txdrv, FR_AB_XX_TXDRV_CTL);
+	efx_writeo(efx, &txdrv, FR_AB_XX_TXDRV_CTL);
 }
 
 int falcon_reset_xaui(struct efx_nic *efx)
@@ -65,11 +65,11 @@ int falcon_reset_xaui(struct efx_nic *efx)
 
 	/* Start reset sequence */
 	EFX_POPULATE_DWORD_1(reg, FRF_AB_XX_RST_XX_EN, 1);
-	falcon_write(efx, &reg, FR_AB_XX_PWR_RST);
+	efx_writeo(efx, &reg, FR_AB_XX_PWR_RST);
 
 	/* Wait up to 10 ms for completion, then reinitialise */
 	for (count = 0; count < 1000; count++) {
-		falcon_read(efx, &reg, FR_AB_XX_PWR_RST);
+		efx_reado(efx, &reg, FR_AB_XX_PWR_RST);
 		if (EFX_OWORD_FIELD(reg, FRF_AB_XX_RST_XX_EN) == 0 &&
 		    EFX_OWORD_FIELD(reg, FRF_AB_XX_SD_RST_ACT) == 0) {
 			falcon_setup_xaui(efx);
@@ -99,12 +99,12 @@ static void falcon_mask_status_intr(struct efx_nic *efx, bool enable)
 
 	/* Flush the ISR */
 	if (enable)
-		falcon_read(efx, &reg, FR_AB_XM_MGT_INT_MSK);
+		efx_reado(efx, &reg, FR_AB_XM_MGT_INT_MSK);
 
 	EFX_POPULATE_OWORD_2(reg,
 			     FRF_AB_XM_MSK_RMTFLT, !enable,
 			     FRF_AB_XM_MSK_LCLFLT, !enable);
-	falcon_write(efx, &reg, FR_AB_XM_MGT_INT_MASK);
+	efx_writeo(efx, &reg, FR_AB_XM_MGT_INT_MASK);
 }
 
 /* Get status of XAUI link */
@@ -118,7 +118,7 @@ bool falcon_xaui_link_ok(struct efx_nic *efx)
 		return true;
 
 	/* Read link status */
-	falcon_read(efx, &reg, FR_AB_XX_CORE_STAT);
+	efx_reado(efx, &reg, FR_AB_XX_CORE_STAT);
 
 	align_done = EFX_OWORD_FIELD(reg, FRF_AB_XX_ALIGN_DONE);
 	sync_status = EFX_OWORD_FIELD(reg, FRF_AB_XX_SYNC_STAT);
@@ -129,7 +129,7 @@ bool falcon_xaui_link_ok(struct efx_nic *efx)
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_COMMA_DET, FFE_AB_XX_STAT_ALL_LANES);
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_CHAR_ERR, FFE_AB_XX_STAT_ALL_LANES);
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_DISPERR, FFE_AB_XX_STAT_ALL_LANES);
-	falcon_write(efx, &reg, FR_AB_XX_CORE_STAT);
+	efx_writeo(efx, &reg, FR_AB_XX_CORE_STAT);
 
 	/* If the link is up, then check the phy side of the xaui link */
 	if (efx->link_up && link_ok)
@@ -150,7 +150,7 @@ static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
 			     FRF_AB_XM_RX_JUMBO_MODE, 1,
 			     FRF_AB_XM_TX_STAT_EN, 1,
 			     FRF_AB_XM_RX_STAT_EN, 1);
-	falcon_write(efx, &reg, FR_AB_XM_GLB_CFG);
+	efx_writeo(efx, &reg, FR_AB_XM_GLB_CFG);
 
 	/* Configure TX */
 	EFX_POPULATE_DWORD_6(reg,
@@ -160,7 +160,7 @@ static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
 			     FRF_AB_XM_TXCRC, 1,
 			     FRF_AB_XM_FCNTL, 1,
 			     FRF_AB_XM_IPG, 0x3);
-	falcon_write(efx, &reg, FR_AB_XM_TX_CFG);
+	efx_writeo(efx, &reg, FR_AB_XM_TX_CFG);
 
 	/* Configure RX */
 	EFX_POPULATE_DWORD_5(reg,
@@ -169,27 +169,27 @@ static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
 			     FRF_AB_XM_ACPT_ALL_MCAST, 1,
 			     FRF_AB_XM_ACPT_ALL_UCAST, efx->promiscuous,
 			     FRF_AB_XM_PASS_CRC_ERR, 1);
-	falcon_write(efx, &reg, FR_AB_XM_RX_CFG);
+	efx_writeo(efx, &reg, FR_AB_XM_RX_CFG);
 
 	/* Set frame length */
 	max_frame_len = EFX_MAX_FRAME_LEN(efx->net_dev->mtu);
 	EFX_POPULATE_DWORD_1(reg, FRF_AB_XM_MAX_RX_FRM_SIZE, max_frame_len);
-	falcon_write(efx, &reg, FR_AB_XM_RX_PARAM);
+	efx_writeo(efx, &reg, FR_AB_XM_RX_PARAM);
 	EFX_POPULATE_DWORD_2(reg,
 			     FRF_AB_XM_MAX_TX_FRM_SIZE, max_frame_len,
 			     FRF_AB_XM_TX_JUMBO_MODE, 1);
-	falcon_write(efx, &reg, FR_AB_XM_TX_PARAM);
+	efx_writeo(efx, &reg, FR_AB_XM_TX_PARAM);
 
 	EFX_POPULATE_DWORD_2(reg,
 			     FRF_AB_XM_PAUSE_TIME, 0xfffe, /* MAX PAUSE TIME */
 			     FRF_AB_XM_DIS_FCNTL, !rx_fc);
-	falcon_write(efx, &reg, FR_AB_XM_FC);
+	efx_writeo(efx, &reg, FR_AB_XM_FC);
 
 	/* Set MAC address */
 	memcpy(&reg, &efx->net_dev->dev_addr[0], 4);
-	falcon_write(efx, &reg, FR_AB_XM_ADR_LO);
+	efx_writeo(efx, &reg, FR_AB_XM_ADR_LO);
 	memcpy(&reg, &efx->net_dev->dev_addr[4], 2);
-	falcon_write(efx, &reg, FR_AB_XM_ADR_HI);
+	efx_writeo(efx, &reg, FR_AB_XM_ADR_HI);
 }
 
 static void falcon_reconfigure_xgxs_core(struct efx_nic *efx)
@@ -205,12 +205,12 @@ static void falcon_reconfigure_xgxs_core(struct efx_nic *efx)
 		bool old_xgmii_loopback, old_xgxs_loopback, old_xaui_loopback;
 		bool reset_xgxs;
 
-		falcon_read(efx, &reg, FR_AB_XX_CORE_STAT);
+		efx_reado(efx, &reg, FR_AB_XX_CORE_STAT);
 		old_xgxs_loopback = EFX_OWORD_FIELD(reg, FRF_AB_XX_XGXS_LB_EN);
 		old_xgmii_loopback =
 			EFX_OWORD_FIELD(reg, FRF_AB_XX_XGMII_LB_EN);
 
-		falcon_read(efx, &reg, FR_AB_XX_SD_CTL);
+		efx_reado(efx, &reg, FR_AB_XX_SD_CTL);
 		old_xaui_loopback = EFX_OWORD_FIELD(reg, FRF_AB_XX_LPBKA);
 
 		/* The PHY driver may have turned XAUI off */
@@ -222,20 +222,20 @@ static void falcon_reconfigure_xgxs_core(struct efx_nic *efx)
 			falcon_reset_xaui(efx);
 	}
 
-	falcon_read(efx, &reg, FR_AB_XX_CORE_STAT);
+	efx_reado(efx, &reg, FR_AB_XX_CORE_STAT);
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_FORCE_SIG,
 			    (xgxs_loopback || xaui_loopback) ?
 			    FFE_AB_XX_FORCE_SIG_ALL_LANES : 0);
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_XGXS_LB_EN, xgxs_loopback);
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_XGMII_LB_EN, xgmii_loopback);
-	falcon_write(efx, &reg, FR_AB_XX_CORE_STAT);
+	efx_writeo(efx, &reg, FR_AB_XX_CORE_STAT);
 
-	falcon_read(efx, &reg, FR_AB_XX_SD_CTL);
+	efx_reado(efx, &reg, FR_AB_XX_SD_CTL);
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_LPBKD, xaui_loopback);
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_LPBKC, xaui_loopback);
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_LPBKB, xaui_loopback);
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_LPBKA, xaui_loopback);
-	falcon_write(efx, &reg, FR_AB_XX_SD_CTL);
+	efx_writeo(efx, &reg, FR_AB_XX_SD_CTL);
 }
 

diff --git a/drivers/net/sfc/io.h b/drivers/net/sfc/io.h
new file mode 100644
index 0000000..b89177c
--- /dev/null
+++ b/drivers/net/sfc/io.h
@@ -0,0 +1,256 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006-2009 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EFX_IO_H
+#define EFX_IO_H
+
+#include <linux/io.h>
+#include <linux/spinlock.h>
+
+/**************************************************************************
+ *
+ * NIC register I/O
+ *
+ **************************************************************************
+ *
+ * Notes on locking strategy:
+ *
+ * Most NIC registers require 16-byte (or 8-byte, for SRAM) atomic writes
+ * which necessitates locking.
+ * Under normal operation few writes to NIC registers are made and these
+ * registers (EVQ_RPTR_REG, RX_DESC_UPD_REG and TX_DESC_UPD_REG) are special
+ * cased to allow 4-byte (hence lockless) accesses.
+ *
+ * It *is* safe to write to these 4-byte registers in the middle of an
+ * access to an 8-byte or 16-byte register.  We therefore use a
+ * spinlock to protect accesses to the larger registers, but no locks
+ * for the 4-byte registers.
+ *
+ * A write barrier is needed to ensure that DW3 is written after DW0/1/2
+ * due to the way the 16byte registers are "collected" in the BIU.
+ *
+ * We also lock when carrying out reads, to ensure consistency of the
+ * data (made possible since the BIU reads all 128 bits into a cache).
+ * Reads are very rare, so this isn't a significant performance
+ * impact.  (Most data transferred from NIC to host is DMAed directly
+ * into host memory).
+ *
+ * I/O BAR access uses locks for both reads and writes (but is only provided
+ * for testing purposes).
+ */
+
+#if BITS_PER_LONG == 64
+#define EFX_USE_QWORD_IO 1
+#endif
+
+#ifdef EFX_USE_QWORD_IO
+static inline void _efx_writeq(struct efx_nic *efx, __le64 value,
+				  unsigned int reg)
+{
+	__raw_writeq((__force u64)value, efx->membase + reg);
+}
+static inline __le64 _efx_readq(struct efx_nic *efx, unsigned int reg)
+{
+	return (__force __le64)__raw_readq(efx->membase + reg);
+}
+#endif
+
+static inline void _efx_writed(struct efx_nic *efx, __le32 value,
+				  unsigned int reg)
+{
+	__raw_writel((__force u32)value, efx->membase + reg);
+}
+static inline __le32 _efx_readd(struct efx_nic *efx, unsigned int reg)
+{
+	return (__force __le32)__raw_readl(efx->membase + reg);
+}
+
+/* Writes to a normal 16-byte Efx register, locking as appropriate. */
+static inline void efx_writeo(struct efx_nic *efx, efx_oword_t *value,
+			      unsigned int reg)
+{
+	unsigned long flags __attribute__ ((unused));
+
+	EFX_REGDUMP(efx, "writing register %x with " EFX_OWORD_FMT "\n", reg,
+		    EFX_OWORD_VAL(*value));
+
+	spin_lock_irqsave(&efx->biu_lock, flags);
+#ifdef EFX_USE_QWORD_IO
+	_efx_writeq(efx, value->u64[0], reg + 0);
+	wmb();
+	_efx_writeq(efx, value->u64[1], reg + 8);
+#else
+	_efx_writed(efx, value->u32[0], reg + 0);
+	_efx_writed(efx, value->u32[1], reg + 4);
+	_efx_writed(efx, value->u32[2], reg + 8);
+	wmb();
+	_efx_writed(efx, value->u32[3], reg + 12);
+#endif
+	mmiowb();
+	spin_unlock_irqrestore(&efx->biu_lock, flags);
+}
+
+/* Write an 8-byte NIC SRAM entry through the supplied mapping,
+ * locking as appropriate. */
+static inline void efx_sram_writeq(struct efx_nic *efx, void __iomem *membase,
+				   efx_qword_t *value, unsigned int index)
+{
+	unsigned int addr = index * sizeof(*value);
+	unsigned long flags __attribute__ ((unused));
+
+	EFX_REGDUMP(efx, "writing SRAM address %x with " EFX_QWORD_FMT "\n",
+		    addr, EFX_QWORD_VAL(*value));
+
+	spin_lock_irqsave(&efx->biu_lock, flags);
+#ifdef EFX_USE_QWORD_IO
+	__raw_writeq((__force u64)value->u64[0], membase + addr);
+#else
+	__raw_writel((__force u32)value->u32[0], membase + addr);
+	wmb();
+	__raw_writel((__force u32)value->u32[1], membase + addr + 4);
+#endif
+	mmiowb();
+	spin_unlock_irqrestore(&efx->biu_lock, flags);
+}
+
+/* Write dword to NIC register that allows partial writes
+ *
+ * Some registers (EVQ_RPTR_REG, RX_DESC_UPD_REG and
+ * TX_DESC_UPD_REG) can be written to as a single dword.  This allows
+ * for lockless writes.
+ */
+static inline void efx_writed(struct efx_nic *efx, efx_dword_t *value,
+			      unsigned int reg)
+{
+	EFX_REGDUMP(efx, "writing partial register %x with "EFX_DWORD_FMT"\n",
+		    reg, EFX_DWORD_VAL(*value));
+
+	/* No lock required */
+	_efx_writed(efx, value->u32[0], reg);
+}
+
+/* Read from a NIC register
+ *
+ * This reads an entire 16-byte register in one go, locking as
+ * appropriate.  It is essential to read the first dword first, as this
+ * prompts the NIC to load the current value into the shadow register.
+ */
+static inline void efx_reado(struct efx_nic *efx, efx_oword_t *value,
+			     unsigned int reg)
+{
+	unsigned long flags __attribute__ ((unused));
+
+	spin_lock_irqsave(&efx->biu_lock, flags);
+	value->u32[0] = _efx_readd(efx, reg + 0);
+	rmb();
+	value->u32[1] = _efx_readd(efx, reg + 4);
+	value->u32[2] = _efx_readd(efx, reg + 8);
+	value->u32[3] = _efx_readd(efx, reg + 12);
+	spin_unlock_irqrestore(&efx->biu_lock, flags);
+
+	EFX_REGDUMP(efx, "read from register %x, got " EFX_OWORD_FMT "\n", reg,
+		    EFX_OWORD_VAL(*value));
+}
+
+/* Read an 8-byte SRAM entry through supplied mapping,
+ * locking as appropriate. */
+static inline void efx_sram_readq(struct efx_nic *efx, void __iomem *membase,
+				  efx_qword_t *value, unsigned int index)
+{
+	unsigned int addr = index * sizeof(*value);
+	unsigned long flags __attribute__ ((unused));
+
+	spin_lock_irqsave(&efx->biu_lock, flags);
+#ifdef EFX_USE_QWORD_IO
+	value->u64[0] = (__force __le64)__raw_readq(membase + addr);
+#else
+	value->u32[0] = (__force __le32)__raw_readl(membase + addr);
+	rmb();
+	value->u32[1] = (__force __le32)__raw_readl(membase + addr + 4);
+#endif
+	spin_unlock_irqrestore(&efx->biu_lock, flags);
+
+	EFX_REGDUMP(efx, "read from SRAM address %x, got "EFX_QWORD_FMT"\n",
+		    addr, EFX_QWORD_VAL(*value));
+}
+
+/* Read dword from register that allows partial writes (sic) */
+static inline void efx_readd(struct efx_nic *efx, efx_dword_t *value,
+				unsigned int reg)
+{
+	value->u32[0] = _efx_readd(efx, reg);
+	EFX_REGDUMP(efx, "read from register %x, got "EFX_DWORD_FMT"\n",
+		    reg, EFX_DWORD_VAL(*value));
+}
+
+/* Write to a register forming part of a table */
+static inline void efx_writeo_table(struct efx_nic *efx, efx_oword_t *value,
+				      unsigned int reg, unsigned int index)
+{
+	efx_writeo(efx, value, reg + index * sizeof(efx_oword_t));
+}
+
+/* Read to a register forming part of a table */
+static inline void efx_reado_table(struct efx_nic *efx, efx_oword_t *value,
+				     unsigned int reg, unsigned int index)
+{
+	efx_reado(efx, value, reg + index * sizeof(efx_oword_t));
+}
+
+/* Write to a dword register forming part of a table */
+static inline void efx_writed_table(struct efx_nic *efx, efx_dword_t *value,
+				       unsigned int reg, unsigned int index)
+{
+	efx_writed(efx, value, reg + index * sizeof(efx_oword_t));
+}
+
+/* Page-mapped register block size */
+#define EFX_PAGE_BLOCK_SIZE 0x2000
+
+/* Calculate offset to page-mapped register block */
+#define EFX_PAGED_REG(page, reg) \
+	((page) * EFX_PAGE_BLOCK_SIZE + (reg))
+
+/* As for efx_writeo(), but for a page-mapped register. */
+static inline void efx_writeo_page(struct efx_nic *efx, efx_oword_t *value,
+				   unsigned int reg, unsigned int page)
+{
+	efx_writeo(efx, value, EFX_PAGED_REG(page, reg));
+}
+
+/* As for efx_writed(), but for a page-mapped register. */
+static inline void efx_writed_page(struct efx_nic *efx, efx_dword_t *value,
+				   unsigned int reg, unsigned int page)
+{
+	efx_writed(efx, value, EFX_PAGED_REG(page, reg));
+}
+
+/* Write dword to page-mapped register with an extra lock.
+ *
+ * As for efx_writed_page(), but for a register that suffers from
+ * SFC bug 3181. Take out a lock so the BIU collector cannot be
+ * confused. */
+static inline void efx_writed_page_locked(struct efx_nic *efx,
+					  efx_dword_t *value,
+					  unsigned int reg,
+					  unsigned int page)
+{
+	unsigned long flags __attribute__ ((unused));
+
+	if (page == 0) {
+		spin_lock_irqsave(&efx->biu_lock, flags);
+		efx_writed(efx, value, EFX_PAGED_REG(page, reg));
+		spin_unlock_irqrestore(&efx->biu_lock, flags);
+	} else {
+		efx_writed(efx, value, EFX_PAGED_REG(page, reg));
+	}
+}
+
+#endif /* EFX_IO_H */
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 4a7be1c..e5c4c9c 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -26,7 +26,7 @@
 #include "selftest.h"
 #include "workarounds.h"
 #include "spi.h"
-#include "falcon_io.h"
+#include "io.h"
 #include "mdio_10g.h"
 
 /*

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

