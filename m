From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 08/27] sfc: Update hardware definitions for Siena
Date: Fri, 23 Oct 2009 19:30:36 +0100
Message-ID: <1256322636.2785.19.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8649 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752646AbZJWSah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:30:37 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Siena is still based on the Falcon hardware architecture and will
share many of these definitions, so replace falcon_hwdefs.h with
regs.h.

The new definitions have been generated according to a naming
convention which incorporates the type and revision information.
Update the code accordingly.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c        |  848 ++++++-----
 drivers/net/sfc/falcon_boards.c |   14 +-
 drivers/net/sfc/falcon_gmac.c   |   92 +-
 drivers/net/sfc/falcon_hwdefs.h | 1332 ----------------
 drivers/net/sfc/falcon_xmac.c   |  175 ++--
 drivers/net/sfc/regs.h          | 3180 +++++++++++++++++++++++++++++++++++++++
 drivers/net/sfc/tenxpress.c     |    2 +-
 7 files changed, 3756 insertions(+), 1887 deletions(-)
 delete mode 100644 drivers/net/sfc/falcon_hwdefs.h
 create mode 100644 drivers/net/sfc/regs.h

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index c23e8e2..b35e010 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -22,7 +22,7 @@
 #include "mac.h"
 #include "spi.h"
 #include "falcon.h"
-#include "falcon_hwdefs.h"
+#include "regs.h"
 #include "falcon_io.h"
 #include "mdio_10g.h"
 #include "phy.h"
@@ -109,17 +109,17 @@ module_param(rx_xon_thresh_bytes, int, 0644);
 MODULE_PARM_DESC(rx_xon_thresh_bytes, "RX fifo XON threshold");
 
 /* TX descriptor ring size - min 512 max 4k */
-#define FALCON_TXD_RING_ORDER TX_DESCQ_SIZE_1K
+#define FALCON_TXD_RING_ORDER FFE_AZ_TX_DESCQ_SIZE_1K
 #define FALCON_TXD_RING_SIZE 1024
 #define FALCON_TXD_RING_MASK (FALCON_TXD_RING_SIZE - 1)
 
 /* RX descriptor ring size - min 512 max 4k */
-#define FALCON_RXD_RING_ORDER RX_DESCQ_SIZE_1K
+#define FALCON_RXD_RING_ORDER FFE_AZ_RX_DESCQ_SIZE_1K
 #define FALCON_RXD_RING_SIZE 1024
 #define FALCON_RXD_RING_MASK (FALCON_RXD_RING_SIZE - 1)
 
 /* Event queue size - max 32k */
-#define FALCON_EVQ_ORDER EVQ_SIZE_4K
+#define FALCON_EVQ_ORDER FFE_AZ_EVQ_SIZE_4K
 #define FALCON_EVQ_SIZE 4096
 #define FALCON_EVQ_MASK (FALCON_EVQ_SIZE - 1)
 
@@ -199,9 +199,9 @@ static void falcon_setsda(void *data, int state)
 	struct efx_nic *efx = (struct efx_nic *)data;
 	efx_oword_t reg;
 
-	falcon_read(efx, &reg, GPIO_CTL_REG_KER);
-	EFX_SET_OWORD_FIELD(reg, GPIO3_OEN, !state);
-	falcon_write(efx, &reg, GPIO_CTL_REG_KER);
+	falcon_read(efx, &reg, FR_AB_GPIO_CTL);
+	EFX_SET_OWORD_FIELD(reg, FRF_AB_GPIO3_OEN, !state);
+	falcon_write(efx, &reg, FR_AB_GPIO_CTL);
 }
 
 static void falcon_setscl(void *data, int state)
@@ -209,9 +209,9 @@ static void falcon_setscl(void *data, int state)
 	struct efx_nic *efx = (struct efx_nic *)data;
 	efx_oword_t reg;
 
-	falcon_read(efx, &reg, GPIO_CTL_REG_KER);
-	EFX_SET_OWORD_FIELD(reg, GPIO0_OEN, !state);
-	falcon_write(efx, &reg, GPIO_CTL_REG_KER);
+	falcon_read(efx, &reg, FR_AB_GPIO_CTL);
+	EFX_SET_OWORD_FIELD(reg, FRF_AB_GPIO0_OEN, !state);
+	falcon_write(efx, &reg, FR_AB_GPIO_CTL);
 }
 
 static int falcon_getsda(void *data)
@@ -219,8 +219,8 @@ static int falcon_getsda(void *data)
 	struct efx_nic *efx = (struct efx_nic *)data;
 	efx_oword_t reg;
 
-	falcon_read(efx, &reg, GPIO_CTL_REG_KER);
-	return EFX_OWORD_FIELD(reg, GPIO3_IN);
+	falcon_read(efx, &reg, FR_AB_GPIO_CTL);
+	return EFX_OWORD_FIELD(reg, FRF_AB_GPIO3_IN);
 }
 
 static int falcon_getscl(void *data)
@@ -228,8 +228,8 @@ static int falcon_getscl(void *data)
 	struct efx_nic *efx = (struct efx_nic *)data;
 	efx_oword_t reg;
 
-	falcon_read(efx, &reg, GPIO_CTL_REG_KER);
-	return EFX_OWORD_FIELD(reg, GPIO0_IN);
+	falcon_read(efx, &reg, FR_AB_GPIO_CTL);
+	return EFX_OWORD_FIELD(reg, FRF_AB_GPIO0_IN);
 }
 
 static struct i2c_algo_bit_data falcon_i2c_bit_operations = {
@@ -274,11 +274,10 @@ falcon_init_special_buffer(struct efx_nic *efx,
 		dma_addr = buffer->dma_addr + (i * 4096);
 		EFX_LOG(efx, "mapping special buffer %d at %llx\n",
 			index, (unsigned long long)dma_addr);
-		EFX_POPULATE_QWORD_4(buf_desc,
-				     IP_DAT_BUF_SIZE, IP_DAT_BUF_SIZE_4K,
-				     BUF_ADR_REGION, 0,
-				     BUF_ADR_FBUF, (dma_addr >> 12),
-				     BUF_OWNER_ID_FBUF, 0);
+		EFX_POPULATE_QWORD_3(buf_desc,
+				     FRF_AZ_BUF_ADR_REGION, 0,
+				     FRF_AZ_BUF_ADR_FBUF, dma_addr >> 12,
+				     FRF_AZ_BUF_OWNER_ID_FBUF, 0);
 		falcon_write_sram(efx, &buf_desc, index);
 	}
 }
@@ -299,11 +298,11 @@ falcon_fini_special_buffer(struct efx_nic *efx,
 		buffer->index, buffer->index + buffer->entries - 1);
 
 	EFX_POPULATE_OWORD_4(buf_tbl_upd,
-			     BUF_UPD_CMD, 0,
-			     BUF_CLR_CMD, 1,
-			     BUF_CLR_END_ID, end,
-			     BUF_CLR_START_ID, start);
-	falcon_write(efx, &buf_tbl_upd, BUF_TBL_UPD_REG_KER);
+			     FRF_AZ_BUF_UPD_CMD, 0,
+			     FRF_AZ_BUF_CLR_CMD, 1,
+			     FRF_AZ_BUF_CLR_END_ID, end,
+			     FRF_AZ_BUF_CLR_START_ID, start);
+	falcon_write(efx, &buf_tbl_upd, FR_AZ_BUF_TBL_UPD);
 }
 
 /*
@@ -415,9 +414,9 @@ static inline void falcon_notify_tx_desc(struct efx_tx_queue *tx_queue)
 	efx_dword_t reg;
 
 	write_ptr = tx_queue->write_count & FALCON_TXD_RING_MASK;
-	EFX_POPULATE_DWORD_1(reg, TX_DESC_WPTR_DWORD, write_ptr);
+	EFX_POPULATE_DWORD_1(reg, FRF_AZ_TX_DESC_WPTR_DWORD, write_ptr);
 	falcon_writel_page(tx_queue->efx, &reg,
-			   TX_DESC_UPD_REG_KER_DWORD, tx_queue->queue);
+			   FR_AZ_TX_DESC_UPD_DWORD_P0, tx_queue->queue);
 }
 

@@ -441,12 +440,11 @@ void falcon_push_buffers(struct efx_tx_queue *tx_queue)
 		++tx_queue->write_count;
 
 		/* Create TX descriptor ring entry */
-		EFX_POPULATE_QWORD_5(*txd,
-				     TX_KER_PORT, 0,
-				     TX_KER_CONT, buffer->continuation,
-				     TX_KER_BYTE_CNT, buffer->len,
-				     TX_KER_BUF_REGION, 0,
-				     TX_KER_BUF_ADR, buffer->dma_addr);
+		EFX_POPULATE_QWORD_4(*txd,
+				     FSF_AZ_TX_KER_CONT, buffer->continuation,
+				     FSF_AZ_TX_KER_BYTE_COUNT, buffer->len,
+				     FSF_AZ_TX_KER_BUF_REGION, 0,
+				     FSF_AZ_TX_KER_BUF_ADDR, buffer->dma_addr);
 	} while (tx_queue->write_count != tx_queue->insert_count);
 
 	wmb(); /* Ensure descriptors are written before they are fetched */
@@ -474,21 +472,23 @@ void falcon_init_tx(struct efx_tx_queue *tx_queue)
 
 	/* Push TX descriptor ring to card */
 	EFX_POPULATE_OWORD_10(tx_desc_ptr,
-			      TX_DESCQ_EN, 1,
-			      TX_ISCSI_DDIG_EN, 0,
-			      TX_ISCSI_HDIG_EN, 0,
-			      TX_DESCQ_BUF_BASE_ID, tx_queue->txd.index,
-			      TX_DESCQ_EVQ_ID, tx_queue->channel->channel,
-			      TX_DESCQ_OWNER_ID, 0,
-			      TX_DESCQ_LABEL, tx_queue->queue,
-			      TX_DESCQ_SIZE, FALCON_TXD_RING_ORDER,
-			      TX_DESCQ_TYPE, 0,
-			      TX_NON_IP_DROP_DIS_B0, 1);
+			      FRF_AZ_TX_DESCQ_EN, 1,
+			      FRF_AZ_TX_ISCSI_DDIG_EN, 0,
+			      FRF_AZ_TX_ISCSI_HDIG_EN, 0,
+			      FRF_AZ_TX_DESCQ_BUF_BASE_ID, tx_queue->txd.index,
+			      FRF_AZ_TX_DESCQ_EVQ_ID,
+			      tx_queue->channel->channel,
+			      FRF_AZ_TX_DESCQ_OWNER_ID, 0,
+			      FRF_AZ_TX_DESCQ_LABEL, tx_queue->queue,
+			      FRF_AZ_TX_DESCQ_SIZE, FALCON_TXD_RING_ORDER,
+			      FRF_AZ_TX_DESCQ_TYPE, 0,
+			      FRF_BZ_TX_NON_IP_DROP_DIS, 1);
 
 	if (falcon_rev(efx) >= FALCON_REV_B0) {
 		int csum = tx_queue->queue == EFX_TX_QUEUE_OFFLOAD_CSUM;
-		EFX_SET_OWORD_FIELD(tx_desc_ptr, TX_IP_CHKSM_DIS_B0, !csum);
-		EFX_SET_OWORD_FIELD(tx_desc_ptr, TX_TCP_CHKSM_DIS_B0, !csum);
+		EFX_SET_OWORD_FIELD(tx_desc_ptr, FRF_BZ_TX_IP_CHKSM_DIS, !csum);
+		EFX_SET_OWORD_FIELD(tx_desc_ptr, FRF_BZ_TX_TCP_CHKSM_DIS,
+				    !csum);
 	}
 
 	falcon_write_table(efx, &tx_desc_ptr, efx->type->txd_ptr_tbl_base,
@@ -500,12 +500,12 @@ void falcon_init_tx(struct efx_tx_queue *tx_queue)
 		/* Only 128 bits in this register */
 		BUILD_BUG_ON(EFX_TX_QUEUE_COUNT >= 128);
 
-		falcon_read(efx, &reg, TX_CHKSM_CFG_REG_KER_A1);
+		falcon_read(efx, &reg, FR_AA_TX_CHKSM_CFG);
 		if (tx_queue->queue == EFX_TX_QUEUE_OFFLOAD_CSUM)
 			clear_bit_le(tx_queue->queue, (void *)&reg);
 		else
 			set_bit_le(tx_queue->queue, (void *)&reg);
-		falcon_write(efx, &reg, TX_CHKSM_CFG_REG_KER_A1);
+		falcon_write(efx, &reg, FR_AA_TX_CHKSM_CFG);
 	}
 }
 
@@ -516,9 +516,9 @@ static void falcon_flush_tx_queue(struct efx_tx_queue *tx_queue)
 
 	/* Post a flush command */
 	EFX_POPULATE_OWORD_2(tx_flush_descq,
-			     TX_FLUSH_DESCQ_CMD, 1,
-			     TX_FLUSH_DESCQ, tx_queue->queue);
-	falcon_write(efx, &tx_flush_descq, TX_FLUSH_DESCQ_REG_KER);
+			     FRF_AZ_TX_FLUSH_DESCQ_CMD, 1,
+			     FRF_AZ_TX_FLUSH_DESCQ, tx_queue->queue);
+	falcon_write(efx, &tx_flush_descq, FR_AZ_TX_FLUSH_DESCQ);
 }
 
 void falcon_fini_tx(struct efx_tx_queue *tx_queue)
@@ -567,11 +567,11 @@ static inline void falcon_build_rx_desc(struct efx_rx_queue *rx_queue,
 	rxd = falcon_rx_desc(rx_queue, index);
 	rx_buf = efx_rx_buffer(rx_queue, index);
 	EFX_POPULATE_QWORD_3(*rxd,
-			     RX_KER_BUF_SIZE,
+			     FSF_AZ_RX_KER_BUF_SIZE,
 			     rx_buf->len -
 			     rx_queue->efx->type->rx_buffer_padding,
-			     RX_KER_BUF_REGION, 0,
-			     RX_KER_BUF_ADR, rx_buf->dma_addr);
+			     FSF_AZ_RX_KER_BUF_REGION, 0,
+			     FSF_AZ_RX_KER_BUF_ADDR, rx_buf->dma_addr);
 }
 
 /* This writes to the RX_DESC_WPTR register for the specified receive
@@ -591,9 +591,9 @@ void falcon_notify_rx_desc(struct efx_rx_queue *rx_queue)
 
 	wmb();
 	write_ptr = rx_queue->added_count & FALCON_RXD_RING_MASK;
-	EFX_POPULATE_DWORD_1(reg, RX_DESC_WPTR_DWORD, write_ptr);
+	EFX_POPULATE_DWORD_1(reg, FRF_AZ_RX_DESC_WPTR_DWORD, write_ptr);
 	falcon_writel_page(rx_queue->efx, &reg,
-			   RX_DESC_UPD_REG_KER_DWORD, rx_queue->queue);
+			   FR_AZ_RX_DESC_UPD_DWORD_P0, rx_queue->queue);
 }
 
 int falcon_probe_rx(struct efx_rx_queue *rx_queue)
@@ -622,17 +622,18 @@ void falcon_init_rx(struct efx_rx_queue *rx_queue)
 
 	/* Push RX descriptor ring to card */
 	EFX_POPULATE_OWORD_10(rx_desc_ptr,
-			      RX_ISCSI_DDIG_EN, iscsi_digest_en,
-			      RX_ISCSI_HDIG_EN, iscsi_digest_en,
-			      RX_DESCQ_BUF_BASE_ID, rx_queue->rxd.index,
-			      RX_DESCQ_EVQ_ID, rx_queue->channel->channel,
-			      RX_DESCQ_OWNER_ID, 0,
-			      RX_DESCQ_LABEL, rx_queue->queue,
-			      RX_DESCQ_SIZE, FALCON_RXD_RING_ORDER,
-			      RX_DESCQ_TYPE, 0 /* kernel queue */ ,
+			      FRF_AZ_RX_ISCSI_DDIG_EN, iscsi_digest_en,
+			      FRF_AZ_RX_ISCSI_HDIG_EN, iscsi_digest_en,
+			      FRF_AZ_RX_DESCQ_BUF_BASE_ID, rx_queue->rxd.index,
+			      FRF_AZ_RX_DESCQ_EVQ_ID,
+			      rx_queue->channel->channel,
+			      FRF_AZ_RX_DESCQ_OWNER_ID, 0,
+			      FRF_AZ_RX_DESCQ_LABEL, rx_queue->queue,
+			      FRF_AZ_RX_DESCQ_SIZE, FALCON_RXD_RING_ORDER,
+			      FRF_AZ_RX_DESCQ_TYPE, 0 /* kernel queue */ ,
 			      /* For >=B0 this is scatter so disable */
-			      RX_DESCQ_JUMBO, !is_b0,
-			      RX_DESCQ_EN, 1);
+			      FRF_AZ_RX_DESCQ_JUMBO, !is_b0,
+			      FRF_AZ_RX_DESCQ_EN, 1);
 	falcon_write_table(efx, &rx_desc_ptr, efx->type->rxd_ptr_tbl_base,
 			   rx_queue->queue);
 }
@@ -644,9 +645,9 @@ static void falcon_flush_rx_queue(struct efx_rx_queue *rx_queue)
 
 	/* Post a flush command */
 	EFX_POPULATE_OWORD_2(rx_flush_descq,
-			     RX_FLUSH_DESCQ_CMD, 1,
-			     RX_FLUSH_DESCQ, rx_queue->queue);
-	falcon_write(efx, &rx_flush_descq, RX_FLUSH_DESCQ_REG_KER);
+			     FRF_AZ_RX_FLUSH_DESCQ_CMD, 1,
+			     FRF_AZ_RX_FLUSH_DESCQ, rx_queue->queue);
+	falcon_write(efx, &rx_flush_descq, FR_AZ_RX_FLUSH_DESCQ);
 }
 
 void falcon_fini_rx(struct efx_rx_queue *rx_queue)
@@ -693,7 +694,7 @@ void falcon_eventq_read_ack(struct efx_channel *channel)
 	efx_dword_t reg;
 	struct efx_nic *efx = channel->efx;
 
-	EFX_POPULATE_DWORD_1(reg, EVQ_RPTR_DWORD, channel->eventq_read_ptr);
+	EFX_POPULATE_DWORD_1(reg, FRF_AZ_EVQ_RPTR, channel->eventq_read_ptr);
 	falcon_writel_table(efx, &reg, efx->type->evq_rptr_tbl_base,
 			    channel->channel);
 }
@@ -703,11 +704,14 @@ void falcon_generate_event(struct efx_channel *channel, efx_qword_t *event)
 {
 	efx_oword_t drv_ev_reg;
 
-	EFX_POPULATE_OWORD_2(drv_ev_reg,
-			     DRV_EV_QID, channel->channel,
-			     DRV_EV_DATA,
-			     EFX_QWORD_FIELD64(*event, WHOLE_EVENT));
-	falcon_write(channel->efx, &drv_ev_reg, DRV_EV_REG_KER);
+	BUILD_BUG_ON(FRF_AZ_DRV_EV_DATA_LBN != 0 ||
+		     FRF_AZ_DRV_EV_DATA_WIDTH != 64);
+	drv_ev_reg.u32[0] = event->u32[0];
+	drv_ev_reg.u32[1] = event->u32[1];
+	drv_ev_reg.u32[2] = 0;
+	drv_ev_reg.u32[3] = 0;
+	EFX_SET_OWORD_FIELD(drv_ev_reg, FRF_AZ_DRV_EV_QID, channel->channel);
+	falcon_write(channel->efx, &drv_ev_reg, FR_AZ_DRV_EV);
 }
 
 /* Handle a transmit completion event
@@ -723,18 +727,18 @@ static void falcon_handle_tx_event(struct efx_channel *channel,
 	struct efx_tx_queue *tx_queue;
 	struct efx_nic *efx = channel->efx;
 
-	if (likely(EFX_QWORD_FIELD(*event, TX_EV_COMP))) {
+	if (likely(EFX_QWORD_FIELD(*event, FSF_AZ_TX_EV_COMP))) {
 		/* Transmit completion */
-		tx_ev_desc_ptr = EFX_QWORD_FIELD(*event, TX_EV_DESC_PTR);
-		tx_ev_q_label = EFX_QWORD_FIELD(*event, TX_EV_Q_LABEL);
+		tx_ev_desc_ptr = EFX_QWORD_FIELD(*event, FSF_AZ_TX_EV_DESC_PTR);
+		tx_ev_q_label = EFX_QWORD_FIELD(*event, FSF_AZ_TX_EV_Q_LABEL);
 		tx_queue = &efx->tx_queue[tx_ev_q_label];
 		channel->irq_mod_score +=
 			(tx_ev_desc_ptr - tx_queue->read_count) &
 			efx->type->txd_ring_mask;
 		efx_xmit_done(tx_queue, tx_ev_desc_ptr);
-	} else if (EFX_QWORD_FIELD(*event, TX_EV_WQ_FF_FULL)) {
+	} else if (EFX_QWORD_FIELD(*event, FSF_AZ_TX_EV_WQ_FF_FULL)) {
 		/* Rewrite the FIFO write pointer */
-		tx_ev_q_label = EFX_QWORD_FIELD(*event, TX_EV_Q_LABEL);
+		tx_ev_q_label = EFX_QWORD_FIELD(*event, FSF_AZ_TX_EV_Q_LABEL);
 		tx_queue = &efx->tx_queue[tx_ev_q_label];
 
 		if (efx_dev_registered(efx))
@@ -742,7 +746,7 @@ static void falcon_handle_tx_event(struct efx_channel *channel,
 		falcon_notify_tx_desc(tx_queue);
 		if (efx_dev_registered(efx))
 			netif_tx_unlock(efx->net_dev);
-	} else if (EFX_QWORD_FIELD(*event, TX_EV_PKT_ERR) &&
+	} else if (EFX_QWORD_FIELD(*event, FSF_AZ_TX_EV_PKT_ERR) &&
 		   EFX_WORKAROUND_10727(efx)) {
 		efx_schedule_reset(efx, RESET_TYPE_TX_DESC_FETCH);
 	} else {
@@ -766,22 +770,22 @@ static void falcon_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 	bool rx_ev_ip_frag_err, rx_ev_hdr_type, rx_ev_mcast_pkt;
 	unsigned rx_ev_pkt_type;
 
-	rx_ev_hdr_type = EFX_QWORD_FIELD(*event, RX_EV_HDR_TYPE);
-	rx_ev_mcast_pkt = EFX_QWORD_FIELD(*event, RX_EV_MCAST_PKT);
-	rx_ev_tobe_disc = EFX_QWORD_FIELD(*event, RX_EV_TOBE_DISC);
-	rx_ev_pkt_type = EFX_QWORD_FIELD(*event, RX_EV_PKT_TYPE);
+	rx_ev_hdr_type = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_HDR_TYPE);
+	rx_ev_mcast_pkt = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_MCAST_PKT);
+	rx_ev_tobe_disc = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_TOBE_DISC);
+	rx_ev_pkt_type = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_PKT_TYPE);
 	rx_ev_buf_owner_id_err = EFX_QWORD_FIELD(*event,
-						 RX_EV_BUF_OWNER_ID_ERR);
-	rx_ev_ip_frag_err = EFX_QWORD_FIELD(*event, RX_EV_IF_FRAG_ERR);
+						 FSF_AZ_RX_EV_BUF_OWNER_ID_ERR);
+	rx_ev_ip_frag_err = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_IP_FRAG_ERR);
 	rx_ev_ip_hdr_chksum_err = EFX_QWORD_FIELD(*event,
-						  RX_EV_IP_HDR_CHKSUM_ERR);
+						  FSF_AZ_RX_EV_IP_HDR_CHKSUM_ERR);
 	rx_ev_tcp_udp_chksum_err = EFX_QWORD_FIELD(*event,
-						   RX_EV_TCP_UDP_CHKSUM_ERR);
-	rx_ev_eth_crc_err = EFX_QWORD_FIELD(*event, RX_EV_ETH_CRC_ERR);
-	rx_ev_frm_trunc = EFX_QWORD_FIELD(*event, RX_EV_FRM_TRUNC);
+						   FSF_AZ_RX_EV_TCP_UDP_CHKSUM_ERR);
+	rx_ev_eth_crc_err = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_ETH_CRC_ERR);
+	rx_ev_frm_trunc = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_FRM_TRUNC);
 	rx_ev_drib_nib = ((falcon_rev(efx) >= FALCON_REV_B0) ?
-			  0 : EFX_QWORD_FIELD(*event, RX_EV_DRIB_NIB));
-	rx_ev_pause_frm = EFX_QWORD_FIELD(*event, RX_EV_PAUSE_FRM_ERR);
+			  0 : EFX_QWORD_FIELD(*event, FSF_AA_RX_EV_DRIB_NIB));
+	rx_ev_pause_frm = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_PAUSE_FRM_ERR);
 
 	/* Every error apart from tobe_disc and pause_frm */
 	rx_ev_other_err = (rx_ev_drib_nib | rx_ev_tcp_udp_chksum_err |
@@ -865,16 +869,17 @@ static void falcon_handle_rx_event(struct efx_channel *channel,
 	struct efx_nic *efx = channel->efx;
 
 	/* Basic packet information */
-	rx_ev_byte_cnt = EFX_QWORD_FIELD(*event, RX_EV_BYTE_CNT);
-	rx_ev_pkt_ok = EFX_QWORD_FIELD(*event, RX_EV_PKT_OK);
-	rx_ev_hdr_type = EFX_QWORD_FIELD(*event, RX_EV_HDR_TYPE);
-	WARN_ON(EFX_QWORD_FIELD(*event, RX_EV_JUMBO_CONT));
-	WARN_ON(EFX_QWORD_FIELD(*event, RX_EV_SOP) != 1);
-	WARN_ON(EFX_QWORD_FIELD(*event, RX_EV_Q_LABEL) != channel->channel);
+	rx_ev_byte_cnt = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_BYTE_CNT);
+	rx_ev_pkt_ok = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_PKT_OK);
+	rx_ev_hdr_type = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_HDR_TYPE);
+	WARN_ON(EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_JUMBO_CONT));
+	WARN_ON(EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_SOP) != 1);
+	WARN_ON(EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_Q_LABEL) !=
+		channel->channel);
 
 	rx_queue = &efx->rx_queue[channel->channel];
 
-	rx_ev_desc_ptr = EFX_QWORD_FIELD(*event, RX_EV_DESC_PTR);
+	rx_ev_desc_ptr = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_DESC_PTR);
 	expected_ptr = rx_queue->removed_count & FALCON_RXD_RING_MASK;
 	if (unlikely(rx_ev_desc_ptr != expected_ptr))
 		falcon_handle_rx_bad_index(rx_queue, rx_ev_desc_ptr);
@@ -883,7 +888,9 @@ static void falcon_handle_rx_event(struct efx_channel *channel,
 		/* If packet is marked as OK and packet type is TCP/IPv4 or
 		 * UDP/IPv4, then we can rely on the hardware checksum.
 		 */
-		checksummed = RX_EV_HDR_TYPE_HAS_CHECKSUMS(rx_ev_hdr_type);
+		checksummed =
+			rx_ev_hdr_type == FSE_AB_RX_EV_HDR_TYPE_IPV4_TCP ||
+			rx_ev_hdr_type == FSE_AB_RX_EV_HDR_TYPE_IPV4_UDP;
 	} else {
 		falcon_handle_rx_not_ok(rx_queue, event, &rx_ev_pkt_ok,
 					&discard);
@@ -891,10 +898,10 @@ static void falcon_handle_rx_event(struct efx_channel *channel,
 	}
 
 	/* Detect multicast packets that didn't match the filter */
-	rx_ev_mcast_pkt = EFX_QWORD_FIELD(*event, RX_EV_MCAST_PKT);
+	rx_ev_mcast_pkt = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_MCAST_PKT);
 	if (rx_ev_mcast_pkt) {
 		unsigned int rx_ev_mcast_hash_match =
-			EFX_QWORD_FIELD(*event, RX_EV_MCAST_HASH_MATCH);
+			EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_MCAST_HASH_MATCH);
 
 		if (unlikely(!rx_ev_mcast_hash_match))
 			discard = true;
@@ -914,24 +921,23 @@ static void falcon_handle_global_event(struct efx_channel *channel,
 	struct efx_nic *efx = channel->efx;
 	bool handled = false;
 
-	if (EFX_QWORD_FIELD(*event, G_PHY0_INTR) ||
-	    EFX_QWORD_FIELD(*event, G_PHY1_INTR) ||
-	    EFX_QWORD_FIELD(*event, XG_PHY_INTR) ||
-	    EFX_QWORD_FIELD(*event, XFP_PHY_INTR)) {
+	if (EFX_QWORD_FIELD(*event, FSF_AB_GLB_EV_G_PHY0_INTR) ||
+	    EFX_QWORD_FIELD(*event, FSF_AB_GLB_EV_XG_PHY0_INTR) ||
+	    EFX_QWORD_FIELD(*event, FSF_AB_GLB_EV_XFP_PHY0_INTR)) {
 		efx->phy_op->clear_interrupt(efx);
 		queue_work(efx->workqueue, &efx->phy_work);
 		handled = true;
 	}
 
 	if ((falcon_rev(efx) >= FALCON_REV_B0) &&
-	    EFX_QWORD_FIELD(*event, XG_MNT_INTR_B0)) {
+	    EFX_QWORD_FIELD(*event, FSF_BB_GLB_EV_XG_MGT_INTR)) {
 		queue_work(efx->workqueue, &efx->mac_work);
 		handled = true;
 	}
 
 	if (falcon_rev(efx) <= FALCON_REV_A1 ?
-	    EFX_QWORD_FIELD(*event, RX_RECOVERY_A1) :
-	    EFX_QWORD_FIELD(*event, RX_RECOVERY_B0)) {
+	    EFX_QWORD_FIELD(*event, FSF_AA_GLB_EV_RX_RECOVERY) :
+	    EFX_QWORD_FIELD(*event, FSF_BB_GLB_EV_RX_RECOVERY)) {
 		EFX_ERR(efx, "channel %d seen global RX_RESET "
 			"event. Resetting.\n", channel->channel);
 
@@ -954,35 +960,35 @@ static void falcon_handle_driver_event(struct efx_channel *channel,
 	unsigned int ev_sub_code;
 	unsigned int ev_sub_data;
 
-	ev_sub_code = EFX_QWORD_FIELD(*event, DRIVER_EV_SUB_CODE);
-	ev_sub_data = EFX_QWORD_FIELD(*event, DRIVER_EV_SUB_DATA);
+	ev_sub_code = EFX_QWORD_FIELD(*event, FSF_AZ_DRIVER_EV_SUBCODE);
+	ev_sub_data = EFX_QWORD_FIELD(*event, FSF_AZ_DRIVER_EV_SUBDATA);
 
 	switch (ev_sub_code) {
-	case TX_DESCQ_FLS_DONE_EV_DECODE:
+	case FSE_AZ_TX_DESCQ_FLS_DONE_EV:
 		EFX_TRACE(efx, "channel %d TXQ %d flushed\n",
 			  channel->channel, ev_sub_data);
 		break;
-	case RX_DESCQ_FLS_DONE_EV_DECODE:
+	case FSE_AZ_RX_DESCQ_FLS_DONE_EV:
 		EFX_TRACE(efx, "channel %d RXQ %d flushed\n",
 			  channel->channel, ev_sub_data);
 		break;
-	case EVQ_INIT_DONE_EV_DECODE:
+	case FSE_AZ_EVQ_INIT_DONE_EV:
 		EFX_LOG(efx, "channel %d EVQ %d initialised\n",
 			channel->channel, ev_sub_data);
 		break;
-	case SRM_UPD_DONE_EV_DECODE:
+	case FSE_AZ_SRM_UPD_DONE_EV:
 		EFX_TRACE(efx, "channel %d SRAM update done\n",
 			  channel->channel);
 		break;
-	case WAKE_UP_EV_DECODE:
+	case FSE_AZ_WAKE_UP_EV:
 		EFX_TRACE(efx, "channel %d RXQ %d wakeup event\n",
 			  channel->channel, ev_sub_data);
 		break;
-	case TIMER_EV_DECODE:
+	case FSE_AZ_TIMER_EV:
 		EFX_TRACE(efx, "channel %d RX queue %d timer expired\n",
 			  channel->channel, ev_sub_data);
 		break;
-	case RX_RECOVERY_EV_DECODE:
+	case FSE_AA_RX_RECOVER_EV:
 		EFX_ERR(efx, "channel %d seen DRIVER RX_RESET event. "
 			"Resetting.\n", channel->channel);
 		atomic_inc(&efx->rx_reset);
@@ -991,12 +997,12 @@ static void falcon_handle_driver_event(struct efx_channel *channel,
 				   RESET_TYPE_RX_RECOVERY :
 				   RESET_TYPE_DISABLE);
 		break;
-	case RX_DSC_ERROR_EV_DECODE:
+	case FSE_BZ_RX_DSC_ERROR_EV:
 		EFX_ERR(efx, "RX DMA Q %d reports descriptor fetch error."
 			" RX Q %d is disabled.\n", ev_sub_data, ev_sub_data);
 		efx_schedule_reset(efx, RESET_TYPE_RX_DESC_FETCH);
 		break;
-	case TX_DSC_ERROR_EV_DECODE:
+	case FSE_BZ_TX_DSC_ERROR_EV:
 		EFX_ERR(efx, "TX DMA Q %d reports descriptor fetch error."
 			" TX Q %d is disabled.\n", ev_sub_data, ev_sub_data);
 		efx_schedule_reset(efx, RESET_TYPE_TX_DESC_FETCH);
@@ -1032,27 +1038,27 @@ int falcon_process_eventq(struct efx_channel *channel, int rx_quota)
 		/* Clear this event by marking it all ones */
 		EFX_SET_QWORD(*p_event);
 
-		ev_code = EFX_QWORD_FIELD(event, EV_CODE);
+		ev_code = EFX_QWORD_FIELD(event, FSF_AZ_EV_CODE);
 
 		switch (ev_code) {
-		case RX_IP_EV_DECODE:
+		case FSE_AZ_EV_CODE_RX_EV:
 			falcon_handle_rx_event(channel, &event);
 			++rx_packets;
 			break;
-		case TX_IP_EV_DECODE:
+		case FSE_AZ_EV_CODE_TX_EV:
 			falcon_handle_tx_event(channel, &event);
 			break;
-		case DRV_GEN_EV_DECODE:
-			channel->eventq_magic
-				= EFX_QWORD_FIELD(event, EVQ_MAGIC);
+		case FSE_AZ_EV_CODE_DRV_GEN_EV:
+			channel->eventq_magic = EFX_QWORD_FIELD(
+				event, FSF_AZ_DRV_GEN_EV_MAGIC);
 			EFX_LOG(channel->efx, "channel %d received generated "
 				"event "EFX_QWORD_FMT"\n", channel->channel,
 				EFX_QWORD_VAL(event));
 			break;
-		case GLOBAL_EV_DECODE:
+		case FSE_AZ_EV_CODE_GLOBAL_EV:
 			falcon_handle_global_event(channel, &event);
 			break;
-		case DRIVER_EV_DECODE:
+		case FSE_AZ_EV_CODE_DRIVER_EV:
 			falcon_handle_driver_event(channel, &event);
 			break;
 		default:
@@ -1086,16 +1092,19 @@ void falcon_set_int_moderation(struct efx_channel *channel)
 		if (channel->irq_moderation < FALCON_IRQ_MOD_RESOLUTION)
 			channel->irq_moderation = FALCON_IRQ_MOD_RESOLUTION;
 		EFX_POPULATE_DWORD_2(timer_cmd,
-				     TIMER_MODE, TIMER_MODE_INT_HLDOFF,
-				     TIMER_VAL,
+				     FRF_AB_TC_TIMER_MODE,
+				     FFE_BB_TIMER_MODE_INT_HLDOFF,
+				     FRF_AB_TC_TIMER_VAL,
 				     channel->irq_moderation /
 				     FALCON_IRQ_MOD_RESOLUTION - 1);
 	} else {
 		EFX_POPULATE_DWORD_2(timer_cmd,
-				     TIMER_MODE, TIMER_MODE_DIS,
-				     TIMER_VAL, 0);
+				     FRF_AB_TC_TIMER_MODE,
+				     FFE_BB_TIMER_MODE_DIS,
+				     FRF_AB_TC_TIMER_VAL, 0);
 	}
-	falcon_writel_page_locked(efx, &timer_cmd, TIMER_CMD_REG_KER,
+	BUILD_BUG_ON(FR_AA_TIMER_COMMAND_KER != FR_BZ_TIMER_COMMAND_P0);
+	falcon_writel_page_locked(efx, &timer_cmd, FR_BZ_TIMER_COMMAND_P0,
 				  channel->channel);
 
 }
@@ -1127,9 +1136,9 @@ void falcon_init_eventq(struct efx_channel *channel)
 
 	/* Push event queue to card */
 	EFX_POPULATE_OWORD_3(evq_ptr,
-			     EVQ_EN, 1,
-			     EVQ_SIZE, FALCON_EVQ_ORDER,
-			     EVQ_BUF_BASE_ID, channel->eventq.index);
+			     FRF_AZ_EVQ_EN, 1,
+			     FRF_AZ_EVQ_SIZE, FALCON_EVQ_ORDER,
+			     FRF_AZ_EVQ_BUF_BASE_ID, channel->eventq.index);
 	falcon_write_table(efx, &evq_ptr, efx->type->evq_ptr_tbl_base,
 			   channel->channel);
 
@@ -1165,9 +1174,9 @@ void falcon_generate_test_event(struct efx_channel *channel, unsigned int magic)
 {
 	efx_qword_t test_event;
 
-	EFX_POPULATE_QWORD_2(test_event,
-			     EV_CODE, DRV_GEN_EV_DECODE,
-			     EVQ_MAGIC, magic);
+	EFX_POPULATE_QWORD_2(test_event, FSF_AZ_EV_CODE,
+			     FSE_AZ_EV_CODE_DRV_GEN_EV,
+			     FSF_AZ_DRV_GEN_EV_MAGIC, magic);
 	falcon_generate_event(channel, &test_event);
 }
 
@@ -1175,11 +1184,12 @@ void falcon_sim_phy_event(struct efx_nic *efx)
 {
 	efx_qword_t phy_event;
 
-	EFX_POPULATE_QWORD_1(phy_event, EV_CODE, GLOBAL_EV_DECODE);
+	EFX_POPULATE_QWORD_1(phy_event, FSF_AZ_EV_CODE,
+			     FSE_AZ_EV_CODE_GLOBAL_EV);
 	if (EFX_IS10G(efx))
-		EFX_SET_QWORD_FIELD(phy_event, XG_PHY_INTR, 1);
+		EFX_SET_QWORD_FIELD(phy_event, FSF_AB_GLB_EV_XG_PHY0_INTR, 1);
 	else
-		EFX_SET_QWORD_FIELD(phy_event, G_PHY0_INTR, 1);
+		EFX_SET_QWORD_FIELD(phy_event, FSF_AB_GLB_EV_G_PHY0_INTR, 1);
 
 	falcon_generate_event(&efx->channel[0], &phy_event);
 }
@@ -1207,22 +1217,23 @@ static void falcon_poll_flush_events(struct efx_nic *efx)
 		if (!falcon_event_present(event))
 			break;
 
-		ev_code = EFX_QWORD_FIELD(*event, EV_CODE);
-		ev_sub_code = EFX_QWORD_FIELD(*event, DRIVER_EV_SUB_CODE);
-		if (ev_code == DRIVER_EV_DECODE &&
-		    ev_sub_code == TX_DESCQ_FLS_DONE_EV_DECODE) {
+		ev_code = EFX_QWORD_FIELD(*event, FSF_AZ_EV_CODE);
+		ev_sub_code = EFX_QWORD_FIELD(*event,
+					      FSF_AZ_DRIVER_EV_SUBCODE);
+		if (ev_code == FSE_AZ_EV_CODE_DRIVER_EV &&
+		    ev_sub_code == FSE_AZ_TX_DESCQ_FLS_DONE_EV) {
 			ev_queue = EFX_QWORD_FIELD(*event,
-						   DRIVER_EV_TX_DESCQ_ID);
+						   FSF_AZ_DRIVER_EV_SUBDATA);
 			if (ev_queue < EFX_TX_QUEUE_COUNT) {
 				tx_queue = efx->tx_queue + ev_queue;
 				tx_queue->flushed = true;
 			}
-		} else if (ev_code == DRIVER_EV_DECODE &&
-			   ev_sub_code == RX_DESCQ_FLS_DONE_EV_DECODE) {
-			ev_queue = EFX_QWORD_FIELD(*event,
-						   DRIVER_EV_RX_DESCQ_ID);
-			ev_failed = EFX_QWORD_FIELD(*event,
-						    DRIVER_EV_RX_FLUSH_FAIL);
+		} else if (ev_code == FSE_AZ_EV_CODE_DRIVER_EV &&
+			   ev_sub_code == FSE_AZ_RX_DESCQ_FLS_DONE_EV) {
+			ev_queue = EFX_QWORD_FIELD(
+				*event, FSF_AZ_DRIVER_EV_RX_DESCQ_ID);
+			ev_failed = EFX_QWORD_FIELD(
+				*event, FSF_AZ_DRIVER_EV_RX_FLUSH_FAIL);
 			if (ev_queue < efx->n_rx_queues) {
 				rx_queue = efx->rx_queue + ev_queue;
 
@@ -1312,9 +1323,9 @@ static inline void falcon_interrupts(struct efx_nic *efx, int enabled,
 	efx_oword_t int_en_reg_ker;
 
 	EFX_POPULATE_OWORD_2(int_en_reg_ker,
-			     KER_INT_KER, force,
-			     DRV_INT_EN_KER, enabled);
-	falcon_write(efx, &int_en_reg_ker, INT_EN_REG_KER);
+			     FRF_AZ_KER_INT_KER, force,
+			     FRF_AZ_DRV_INT_EN_KER, enabled);
+	falcon_write(efx, &int_en_reg_ker, FR_AZ_INT_EN_KER);
 }
 
 void falcon_enable_interrupts(struct efx_nic *efx)
@@ -1327,9 +1338,10 @@ void falcon_enable_interrupts(struct efx_nic *efx)
 
 	/* Program address */
 	EFX_POPULATE_OWORD_2(int_adr_reg_ker,
-			     NORM_INT_VEC_DIS_KER, EFX_INT_MODE_USE_MSI(efx),
-			     INT_ADR_KER, efx->irq_status.dma_addr);
-	falcon_write(efx, &int_adr_reg_ker, INT_ADR_REG_KER);
+			     FRF_AZ_NORM_INT_VEC_DIS_KER,
+			     EFX_INT_MODE_USE_MSI(efx),
+			     FRF_AZ_INT_ADR_KER, efx->irq_status.dma_addr);
+	falcon_write(efx, &int_adr_reg_ker, FR_AZ_INT_ADR_KER);
 
 	/* Enable interrupts */
 	falcon_interrupts(efx, 1, 0);
@@ -1369,9 +1381,9 @@ static inline void falcon_irq_ack_a1(struct efx_nic *efx)
 {
 	efx_dword_t reg;
 
-	EFX_POPULATE_DWORD_1(reg, INT_ACK_DUMMY_DATA, 0xb7eb7e);
-	falcon_writel(efx, &reg, INT_ACK_REG_KER_A1);
-	falcon_readl(efx, &reg, WORK_AROUND_BROKEN_PCI_READS_REG_KER_A1);
+	EFX_POPULATE_DWORD_1(reg, FRF_AA_INT_ACK_KER_FIELD, 0xb7eb7e);
+	falcon_writel(efx, &reg, FR_AA_INT_ACK_KER);
+	falcon_readl(efx, &reg, FR_AA_WORK_AROUND_BROKEN_PCI_READS);
 }
 
 /* Process a fatal interrupt
@@ -1384,8 +1396,8 @@ static irqreturn_t falcon_fatal_interrupt(struct efx_nic *efx)
 	efx_oword_t fatal_intr;
 	int error, mem_perr;
 
-	falcon_read(efx, &fatal_intr, FATAL_INTR_REG_KER);
-	error = EFX_OWORD_FIELD(fatal_intr, INT_KER_ERROR);
+	falcon_read(efx, &fatal_intr, FR_AZ_FATAL_INTR_KER);
+	error = EFX_OWORD_FIELD(fatal_intr, FRF_AZ_FATAL_INTR);
 
 	EFX_ERR(efx, "SYSTEM ERROR " EFX_OWORD_FMT " status "
 		EFX_OWORD_FMT ": %s\n", EFX_OWORD_VAL(*int_ker),
@@ -1395,10 +1407,10 @@ static irqreturn_t falcon_fatal_interrupt(struct efx_nic *efx)
 		goto out;
 
 	/* If this is a memory parity error dump which blocks are offending */
-	mem_perr = EFX_OWORD_FIELD(fatal_intr, MEM_PERR_INT_KER);
+	mem_perr = EFX_OWORD_FIELD(fatal_intr, FRF_AZ_MEM_PERR_INT_KER);
 	if (mem_perr) {
 		efx_oword_t reg;
-		falcon_read(efx, &reg, MEM_STAT_REG_KER);
+		falcon_read(efx, &reg, FR_AZ_MEM_STAT);
 		EFX_ERR(efx, "SYSTEM ERROR: memory parity error "
 			EFX_OWORD_FMT "\n", EFX_OWORD_VAL(reg));
 	}
@@ -1442,11 +1454,11 @@ static irqreturn_t falcon_legacy_interrupt_b0(int irq, void *dev_id)
 	int syserr;
 
 	/* Read the ISR which also ACKs the interrupts */
-	falcon_readl(efx, &reg, INT_ISR0_B0);
+	falcon_readl(efx, &reg, FR_BZ_INT_ISR0);
 	queues = EFX_EXTRACT_DWORD(reg, 0, 31);
 
 	/* Check to see if we have a serious error condition */
-	syserr = EFX_OWORD_FIELD(*int_ker, FATAL_INT);
+	syserr = EFX_OWORD_FIELD(*int_ker, FSF_AZ_NET_IVEC_FATAL_INT);
 	if (unlikely(syserr))
 		return falcon_fatal_interrupt(efx);
 
@@ -1492,7 +1504,7 @@ static irqreturn_t falcon_legacy_interrupt_a1(int irq, void *dev_id)
 		  irq, raw_smp_processor_id(), EFX_OWORD_VAL(*int_ker));
 
 	/* Check to see if we have a serious error condition */
-	syserr = EFX_OWORD_FIELD(*int_ker, FATAL_INT);
+	syserr = EFX_OWORD_FIELD(*int_ker, FSF_AZ_NET_IVEC_FATAL_INT);
 	if (unlikely(syserr))
 		return falcon_fatal_interrupt(efx);
 
@@ -1559,10 +1571,10 @@ static void falcon_setup_rss_indir_table(struct efx_nic *efx)
 	if (falcon_rev(efx) < FALCON_REV_B0)
 		return;
 
-	for (offset = RX_RSS_INDIR_TBL_B0;
-	     offset < RX_RSS_INDIR_TBL_B0 + 0x800;
+	for (offset = FR_BZ_RX_INDIRECTION_TBL;
+	     offset < FR_BZ_RX_INDIRECTION_TBL + 0x800;
 	     offset += 0x10) {
-		EFX_POPULATE_DWORD_1(dword, RX_RSS_INDIR_ENT_B0,
+		EFX_POPULATE_DWORD_1(dword, FRF_BZ_IT_QUEUE,
 				     i % efx->n_rx_queues);
 		falcon_writel(efx, &dword, offset);
 		i++;
@@ -1627,7 +1639,7 @@ void falcon_fini_interrupt(struct efx_nic *efx)
 
 	/* ACK legacy interrupt */
 	if (falcon_rev(efx) >= FALCON_REV_B0)
-		falcon_read(efx, &reg, INT_ISR0_B0);
+		falcon_read(efx, &reg, FR_BZ_INT_ISR0);
 	else
 		falcon_irq_ack_a1(efx);
 
@@ -1648,8 +1660,8 @@ void falcon_fini_interrupt(struct efx_nic *efx)
 static int falcon_spi_poll(struct efx_nic *efx)
 {
 	efx_oword_t reg;
-	falcon_read(efx, &reg, EE_SPI_HCMD_REG_KER);
-	return EFX_OWORD_FIELD(reg, EE_SPI_HCMD_CMD_EN) ? -EBUSY : 0;
+	falcon_read(efx, &reg, FR_AB_EE_SPI_HCMD);
+	return EFX_OWORD_FIELD(reg, FRF_AB_EE_SPI_HCMD_CMD_EN) ? -EBUSY : 0;
 }
 
 /* Wait for SPI command completion */
@@ -1701,27 +1713,27 @@ int falcon_spi_cmd(const struct efx_spi_device *spi,
 
 	/* Program address register, if we have an address */
 	if (addressed) {
-		EFX_POPULATE_OWORD_1(reg, EE_SPI_HADR_ADR, address);
-		falcon_write(efx, &reg, EE_SPI_HADR_REG_KER);
+		EFX_POPULATE_OWORD_1(reg, FRF_AB_EE_SPI_HADR_ADR, address);
+		falcon_write(efx, &reg, FR_AB_EE_SPI_HADR);
 	}
 
 	/* Program data register, if we have data */
 	if (in != NULL) {
 		memcpy(&reg, in, len);
-		falcon_write(efx, &reg, EE_SPI_HDATA_REG_KER);
+		falcon_write(efx, &reg, FR_AB_EE_SPI_HDATA);
 	}
 
 	/* Issue read/write command */
 	EFX_POPULATE_OWORD_7(reg,
-			     EE_SPI_HCMD_CMD_EN, 1,
-			     EE_SPI_HCMD_SF_SEL, spi->device_id,
-			     EE_SPI_HCMD_DABCNT, len,
-			     EE_SPI_HCMD_READ, reading,
-			     EE_SPI_HCMD_DUBCNT, 0,
-			     EE_SPI_HCMD_ADBCNT,
+			     FRF_AB_EE_SPI_HCMD_CMD_EN, 1,
+			     FRF_AB_EE_SPI_HCMD_SF_SEL, spi->device_id,
+			     FRF_AB_EE_SPI_HCMD_DABCNT, len,
+			     FRF_AB_EE_SPI_HCMD_READ, reading,
+			     FRF_AB_EE_SPI_HCMD_DUBCNT, 0,
+			     FRF_AB_EE_SPI_HCMD_ADBCNT,
 			     (addressed ? spi->addr_len : 0),
-			     EE_SPI_HCMD_ENC, command);
-	falcon_write(efx, &reg, EE_SPI_HCMD_REG_KER);
+			     FRF_AB_EE_SPI_HCMD_ENC, command);
+	falcon_write(efx, &reg, FR_AB_EE_SPI_HCMD);
 
 	/* Wait for read/write to complete */
 	rc = falcon_spi_wait(efx);
@@ -1730,7 +1742,7 @@ int falcon_spi_cmd(const struct efx_spi_device *spi,
 
 	/* Read data */
 	if (out != NULL) {
-		falcon_read(efx, &reg, EE_SPI_HDATA_REG_KER);
+		falcon_read(efx, &reg, FR_AB_EE_SPI_HDATA);
 		memcpy(out, &reg, len);
 	}
 
@@ -1871,21 +1883,22 @@ static int falcon_reset_macs(struct efx_nic *efx)
 		 * macs, so instead use the internal MAC resets
 		 */
 		if (!EFX_IS10G(efx)) {
-			EFX_POPULATE_OWORD_1(reg, GM_SW_RST, 1);
-			falcon_write(efx, &reg, GM_CFG1_REG);
+			EFX_POPULATE_OWORD_1(reg, FRF_AB_GM_SW_RST, 1);
+			falcon_write(efx, &reg, FR_AB_GM_CFG1);
 			udelay(1000);
 
-			EFX_POPULATE_OWORD_1(reg, GM_SW_RST, 0);
-			falcon_write(efx, &reg, GM_CFG1_REG);
+			EFX_POPULATE_OWORD_1(reg, FRF_AB_GM_SW_RST, 0);
+			falcon_write(efx, &reg, FR_AB_GM_CFG1);
 			udelay(1000);
 			return 0;
 		} else {
-			EFX_POPULATE_OWORD_1(reg, XM_CORE_RST, 1);
-			falcon_write(efx, &reg, XM_GLB_CFG_REG);
+			EFX_POPULATE_OWORD_1(reg, FRF_AB_XM_CORE_RST, 1);
+			falcon_write(efx, &reg, FR_AB_XM_GLB_CFG);
 
 			for (count = 0; count < 10000; count++) {
-				falcon_read(efx, &reg, XM_GLB_CFG_REG);
-				if (EFX_OWORD_FIELD(reg, XM_CORE_RST) == 0)
+				falcon_read(efx, &reg, FR_AB_XM_GLB_CFG);
+				if (EFX_OWORD_FIELD(reg, FRF_AB_XM_CORE_RST) ==
+				    0)
 					return 0;
 				udelay(10);
 			}
@@ -1899,22 +1912,22 @@ static int falcon_reset_macs(struct efx_nic *efx)
 	 * the drain sequence with the statistics fetch */
 	efx_stats_disable(efx);
 
-	falcon_read(efx, &reg, MAC0_CTRL_REG_KER);
-	EFX_SET_OWORD_FIELD(reg, TXFIFO_DRAIN_EN_B0, 1);
-	falcon_write(efx, &reg, MAC0_CTRL_REG_KER);
+	falcon_read(efx, &reg, FR_AB_MAC_CTRL);
+	EFX_SET_OWORD_FIELD(reg, FRF_BB_TXFIFO_DRAIN_EN, 1);
+	falcon_write(efx, &reg, FR_AB_MAC_CTRL);
 
-	falcon_read(efx, &reg, GLB_CTL_REG_KER);
-	EFX_SET_OWORD_FIELD(reg, RST_XGTX, 1);
-	EFX_SET_OWORD_FIELD(reg, RST_XGRX, 1);
-	EFX_SET_OWORD_FIELD(reg, RST_EM, 1);
-	falcon_write(efx, &reg, GLB_CTL_REG_KER);
+	falcon_read(efx, &reg, FR_AB_GLB_CTL);
+	EFX_SET_OWORD_FIELD(reg, FRF_AB_RST_XGTX, 1);
+	EFX_SET_OWORD_FIELD(reg, FRF_AB_RST_XGRX, 1);
+	EFX_SET_OWORD_FIELD(reg, FRF_AB_RST_EM, 1);
+	falcon_write(efx, &reg, FR_AB_GLB_CTL);
 
 	count = 0;
 	while (1) {
-		falcon_read(efx, &reg, GLB_CTL_REG_KER);
-		if (!EFX_OWORD_FIELD(reg, RST_XGTX) &&
-		    !EFX_OWORD_FIELD(reg, RST_XGRX) &&
-		    !EFX_OWORD_FIELD(reg, RST_EM)) {
+		falcon_read(efx, &reg, FR_AB_GLB_CTL);
+		if (!EFX_OWORD_FIELD(reg, FRF_AB_RST_XGTX) &&
+		    !EFX_OWORD_FIELD(reg, FRF_AB_RST_XGRX) &&
+		    !EFX_OWORD_FIELD(reg, FRF_AB_RST_EM)) {
 			EFX_LOG(efx, "Completed MAC reset after %d loops\n",
 				count);
 			break;
@@ -1945,9 +1958,9 @@ void falcon_drain_tx_fifo(struct efx_nic *efx)
 	    (efx->loopback_mode != LOOPBACK_NONE))
 		return;
 
-	falcon_read(efx, &reg, MAC0_CTRL_REG_KER);
+	falcon_read(efx, &reg, FR_AB_MAC_CTRL);
 	/* There is no point in draining more than once */
-	if (EFX_OWORD_FIELD(reg, TXFIFO_DRAIN_EN_B0))
+	if (EFX_OWORD_FIELD(reg, FRF_BB_TXFIFO_DRAIN_EN))
 		return;
 
 	falcon_reset_macs(efx);
@@ -1961,9 +1974,9 @@ void falcon_deconfigure_mac_wrapper(struct efx_nic *efx)
 		return;
 
 	/* Isolate the MAC -> RX */
-	falcon_read(efx, &reg, RX_CFG_REG_KER);
-	EFX_SET_OWORD_FIELD(reg, RX_INGR_EN_B0, 0);
-	falcon_write(efx, &reg, RX_CFG_REG_KER);
+	falcon_read(efx, &reg, FR_AZ_RX_CFG);
+	EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_INGR_EN, 0);
+	falcon_write(efx, &reg, FR_AZ_RX_CFG);
 
 	if (!efx->link_up)
 		falcon_drain_tx_fifo(efx);
@@ -1986,19 +1999,19 @@ void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
 	 * indefinitely held and TX queue can be flushed at any point
 	 * while the link is down. */
 	EFX_POPULATE_OWORD_5(reg,
-			     MAC_XOFF_VAL, 0xffff /* max pause time */,
-			     MAC_BCAD_ACPT, 1,
-			     MAC_UC_PROM, efx->promiscuous,
-			     MAC_LINK_STATUS, 1, /* always set */
-			     MAC_SPEED, link_speed);
+			     FRF_AB_MAC_XOFF_VAL, 0xffff /* max pause time */,
+			     FRF_AB_MAC_BCAD_ACPT, 1,
+			     FRF_AB_MAC_UC_PROM, efx->promiscuous,
+			     FRF_AB_MAC_LINK_STATUS, 1, /* always set */
+			     FRF_AB_MAC_SPEED, link_speed);
 	/* On B0, MAC backpressure can be disabled and packets get
 	 * discarded. */
 	if (falcon_rev(efx) >= FALCON_REV_B0) {
-		EFX_SET_OWORD_FIELD(reg, TXFIFO_DRAIN_EN_B0,
+		EFX_SET_OWORD_FIELD(reg, FRF_BB_TXFIFO_DRAIN_EN,
 				    !efx->link_up);
 	}
 
-	falcon_write(efx, &reg, MAC0_CTRL_REG_KER);
+	falcon_write(efx, &reg, FR_AB_MAC_CTRL);
 
 	/* Restore the multicast hash registers. */
 	falcon_set_multicast_hash(efx);
@@ -2007,13 +2020,13 @@ void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
 	 * covered by RX_XOFF_MAC_EN and XM_TX_CFG_REG:XM_FCNTL.
 	 * Action on receipt of pause frames is controller by XM_DIS_FCNTL */
 	tx_fc = !!(efx->link_fc & EFX_FC_TX);
-	falcon_read(efx, &reg, RX_CFG_REG_KER);
-	EFX_SET_OWORD_FIELD(reg, RX_XOFF_MAC_EN, tx_fc);
+	falcon_read(efx, &reg, FR_AZ_RX_CFG);
+	EFX_SET_OWORD_FIELD(reg, FRF_AZ_RX_XOFF_MAC_EN, tx_fc);
 
 	/* Unisolate the MAC -> RX */
 	if (falcon_rev(efx) >= FALCON_REV_B0)
-		EFX_SET_OWORD_FIELD(reg, RX_INGR_EN_B0, 1);
-	falcon_write(efx, &reg, RX_CFG_REG_KER);
+		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_INGR_EN, 1);
+	falcon_write(efx, &reg, FR_AZ_RX_CFG);
 }
 
 int falcon_dma_stats(struct efx_nic *efx, unsigned int done_offset)
@@ -2028,8 +2041,8 @@ int falcon_dma_stats(struct efx_nic *efx, unsigned int done_offset)
 	/* Statistics fetch will fail if the MAC is in TX drain */
 	if (falcon_rev(efx) >= FALCON_REV_B0) {
 		efx_oword_t temp;
-		falcon_read(efx, &temp, MAC0_CTRL_REG_KER);
-		if (EFX_OWORD_FIELD(temp, TXFIFO_DRAIN_EN_B0))
+		falcon_read(efx, &temp, FR_AB_MAC_CTRL);
+		if (EFX_OWORD_FIELD(temp, FRF_BB_TXFIFO_DRAIN_EN))
 			return 0;
 	}
 
@@ -2039,10 +2052,10 @@ int falcon_dma_stats(struct efx_nic *efx, unsigned int done_offset)
 
 	/* Initiate DMA transfer of stats */
 	EFX_POPULATE_OWORD_2(reg,
-			     MAC_STAT_DMA_CMD, 1,
-			     MAC_STAT_DMA_ADR,
+			     FRF_AB_MAC_STAT_DMA_CMD, 1,
+			     FRF_AB_MAC_STAT_DMA_ADR,
 			     efx->stats_buffer.dma_addr);
-	falcon_write(efx, &reg, MAC0_STAT_DMA_REG_KER);
+	falcon_write(efx, &reg, FR_AB_MAC_STAT_DMA);
 
 	/* Wait for transfer to complete */
 	for (i = 0; i < 400; i++) {
@@ -2072,10 +2085,10 @@ static int falcon_gmii_wait(struct efx_nic *efx)
 
 	/* wait upto 50ms - taken max from datasheet */
 	for (count = 0; count < 5000; count++) {
-		falcon_readl(efx, &md_stat, MD_STAT_REG_KER);
-		if (EFX_DWORD_FIELD(md_stat, MD_BSY) == 0) {
-			if (EFX_DWORD_FIELD(md_stat, MD_LNFL) != 0 ||
-			    EFX_DWORD_FIELD(md_stat, MD_BSERR) != 0) {
+		falcon_readl(efx, &md_stat, FR_AB_MD_STAT);
+		if (EFX_DWORD_FIELD(md_stat, FRF_AB_MD_BSY) == 0) {
+			if (EFX_DWORD_FIELD(md_stat, FRF_AB_MD_LNFL) != 0 ||
+			    EFX_DWORD_FIELD(md_stat, FRF_AB_MD_BSERR) != 0) {
 				EFX_ERR(efx, "error from GMII access "
 					EFX_DWORD_FMT"\n",
 					EFX_DWORD_VAL(md_stat));
@@ -2108,29 +2121,30 @@ static int falcon_mdio_write(struct net_device *net_dev,
 		goto out;
 
 	/* Write the address/ID register */
-	EFX_POPULATE_OWORD_1(reg, MD_PHY_ADR, addr);
-	falcon_write(efx, &reg, MD_PHY_ADR_REG_KER);
+	EFX_POPULATE_OWORD_1(reg, FRF_AB_MD_PHY_ADR, addr);
+	falcon_write(efx, &reg, FR_AB_MD_PHY_ADR);
 
-	EFX_POPULATE_OWORD_2(reg, MD_PRT_ADR, prtad, MD_DEV_ADR, devad);
-	falcon_write(efx, &reg, MD_ID_REG_KER);
+	EFX_POPULATE_OWORD_2(reg, FRF_AB_MD_PRT_ADR, prtad,
+			     FRF_AB_MD_DEV_ADR, devad);
+	falcon_write(efx, &reg, FR_AB_MD_ID);
 
 	/* Write data */
-	EFX_POPULATE_OWORD_1(reg, MD_TXD, value);
-	falcon_write(efx, &reg, MD_TXD_REG_KER);
+	EFX_POPULATE_OWORD_1(reg, FRF_AB_MD_TXD, value);
+	falcon_write(efx, &reg, FR_AB_MD_TXD);
 
 	EFX_POPULATE_OWORD_2(reg,
-			     MD_WRC, 1,
-			     MD_GC, 0);
-	falcon_write(efx, &reg, MD_CS_REG_KER);
+			     FRF_AB_MD_WRC, 1,
+			     FRF_AB_MD_GC, 0);
+	falcon_write(efx, &reg, FR_AB_MD_CS);
 
 	/* Wait for data to be written */
 	rc = falcon_gmii_wait(efx);
 	if (rc) {
 		/* Abort the write operation */
 		EFX_POPULATE_OWORD_2(reg,
-				     MD_WRC, 0,
-				     MD_GC, 1);
-		falcon_write(efx, &reg, MD_CS_REG_KER);
+				     FRF_AB_MD_WRC, 0,
+				     FRF_AB_MD_GC, 1);
+		falcon_write(efx, &reg, FR_AB_MD_CS);
 		udelay(10);
 	}
 
@@ -2154,29 +2168,30 @@ static int falcon_mdio_read(struct net_device *net_dev,
 	if (rc)
 		goto out;
 
-	EFX_POPULATE_OWORD_1(reg, MD_PHY_ADR, addr);
-	falcon_write(efx, &reg, MD_PHY_ADR_REG_KER);
+	EFX_POPULATE_OWORD_1(reg, FRF_AB_MD_PHY_ADR, addr);
+	falcon_write(efx, &reg, FR_AB_MD_PHY_ADR);
 
-	EFX_POPULATE_OWORD_2(reg, MD_PRT_ADR, prtad, MD_DEV_ADR, devad);
-	falcon_write(efx, &reg, MD_ID_REG_KER);
+	EFX_POPULATE_OWORD_2(reg, FRF_AB_MD_PRT_ADR, prtad,
+			     FRF_AB_MD_DEV_ADR, devad);
+	falcon_write(efx, &reg, FR_AB_MD_ID);
 
 	/* Request data to be read */
-	EFX_POPULATE_OWORD_2(reg, MD_RDC, 1, MD_GC, 0);
-	falcon_write(efx, &reg, MD_CS_REG_KER);
+	EFX_POPULATE_OWORD_2(reg, FRF_AB_MD_RDC, 1, FRF_AB_MD_GC, 0);
+	falcon_write(efx, &reg, FR_AB_MD_CS);
 
 	/* Wait for data to become available */
 	rc = falcon_gmii_wait(efx);
 	if (rc == 0) {
-		falcon_read(efx, &reg, MD_RXD_REG_KER);
-		rc = EFX_OWORD_FIELD(reg, MD_RXD);
+		falcon_read(efx, &reg, FR_AB_MD_RXD);
+		rc = EFX_OWORD_FIELD(reg, FRF_AB_MD_RXD);
 		EFX_REGDUMP(efx, "read from MDIO %d register %d.%d, got %04x\n",
 			    prtad, devad, addr, rc);
 	} else {
 		/* Abort the read operation */
 		EFX_POPULATE_OWORD_2(reg,
-				     MD_RIC, 0,
-				     MD_GC, 1);
-		falcon_write(efx, &reg, MD_CS_REG_KER);
+				     FRF_AB_MD_RIC, 0,
+				     FRF_AB_MD_GC, 1);
+		falcon_write(efx, &reg, FR_AB_MD_CS);
 
 		EFX_LOG(efx, "read from MDIO %d register %d.%d, got error %d\n",
 			prtad, devad, addr, rc);
@@ -2243,16 +2258,17 @@ int falcon_switch_mac(struct efx_nic *efx)
 
 	/* Always push the NIC_STAT_REG setting even if the mac hasn't
 	 * changed, because this function is run post online reset */
-	falcon_read(efx, &nic_stat, NIC_STAT_REG);
+	falcon_read(efx, &nic_stat, FR_AB_NIC_STAT);
 	strap_val = EFX_IS10G(efx) ? 5 : 3;
 	if (falcon_rev(efx) >= FALCON_REV_B0) {
-		EFX_SET_OWORD_FIELD(nic_stat, EE_STRAP_EN, 1);
-		EFX_SET_OWORD_FIELD(nic_stat, EE_STRAP_OVR, strap_val);
-		falcon_write(efx, &nic_stat, NIC_STAT_REG);
+		EFX_SET_OWORD_FIELD(nic_stat, FRF_BB_EE_STRAP_EN, 1);
+		EFX_SET_OWORD_FIELD(nic_stat, FRF_BB_EE_STRAP, strap_val);
+		falcon_write(efx, &nic_stat, FR_AB_NIC_STAT);
 	} else {
 		/* Falcon A1 does not support 1G/10G speed switching
 		 * and must not be used with a PHY that does. */
-		BUG_ON(EFX_OWORD_FIELD(nic_stat, STRAP_PINS) != strap_val);
+		BUG_ON(EFX_OWORD_FIELD(nic_stat, FRF_AB_STRAP_PINS) !=
+		       strap_val);
 	}
 
 	if (old_mac_op == efx->mac_op)
@@ -2325,8 +2341,8 @@ void falcon_set_multicast_hash(struct efx_nic *efx)
 	 */
 	set_bit_le(0xff, mc_hash->byte);
 
-	falcon_write(efx, &mc_hash->oword[0], MAC_MCAST_HASH_REG0_KER);
-	falcon_write(efx, &mc_hash->oword[1], MAC_MCAST_HASH_REG1_KER);
+	falcon_write(efx, &mc_hash->oword[0], FR_AB_MAC_MC_HASH_REG0);
+	falcon_write(efx, &mc_hash->oword[1], FR_AB_MAC_MC_HASH_REG1);
 }
 

@@ -2352,7 +2368,7 @@ int falcon_read_nvram(struct efx_nic *efx, struct falcon_nvconfig *nvconfig_out)
 	region = kmalloc(FALCON_NVCONFIG_END, GFP_KERNEL);
 	if (!region)
 		return -ENOMEM;
-	nvconfig = region + NVCONFIG_OFFSET;
+	nvconfig = region + FALCON_NVCONFIG_OFFSET;
 
 	mutex_lock(&efx->spi_lock);
 	rc = falcon_spi_read(spi, 0, FALCON_NVCONFIG_END, NULL, region);
@@ -2368,7 +2384,7 @@ int falcon_read_nvram(struct efx_nic *efx, struct falcon_nvconfig *nvconfig_out)
 	struct_ver = le16_to_cpu(nvconfig->board_struct_ver);
 
 	rc = -EINVAL;
-	if (magic_num != NVCONFIG_BOARD_MAGIC_NUM) {
+	if (magic_num != FALCON_NVCONFIG_BOARD_MAGIC_NUM) {
 		EFX_ERR(efx, "NVRAM bad magic 0x%x\n", magic_num);
 		goto out;
 	}
@@ -2404,41 +2420,41 @@ static struct {
 	unsigned address;
 	efx_oword_t mask;
 } efx_test_registers[] = {
-	{ ADR_REGION_REG_KER,
+	{ FR_AZ_ADR_REGION,
 	  EFX_OWORD32(0x0001FFFF, 0x0001FFFF, 0x0001FFFF, 0x0001FFFF) },
-	{ RX_CFG_REG_KER,
+	{ FR_AZ_RX_CFG,
 	  EFX_OWORD32(0xFFFFFFFE, 0x00017FFF, 0x00000000, 0x00000000) },
-	{ TX_CFG_REG_KER,
+	{ FR_AZ_TX_CFG,
 	  EFX_OWORD32(0x7FFF0037, 0x00000000, 0x00000000, 0x00000000) },
-	{ TX_CFG2_REG_KER,
+	{ FR_AZ_TX_RESERVED,
 	  EFX_OWORD32(0xFFFEFE80, 0x1FFFFFFF, 0x020000FE, 0x007FFFFF) },
-	{ MAC0_CTRL_REG_KER,
+	{ FR_AB_MAC_CTRL,
 	  EFX_OWORD32(0xFFFF0000, 0x00000000, 0x00000000, 0x00000000) },
-	{ SRM_TX_DC_CFG_REG_KER,
+	{ FR_AZ_SRM_TX_DC_CFG,
 	  EFX_OWORD32(0x001FFFFF, 0x00000000, 0x00000000, 0x00000000) },
-	{ RX_DC_CFG_REG_KER,
+	{ FR_AZ_RX_DC_CFG,
 	  EFX_OWORD32(0x0000000F, 0x00000000, 0x00000000, 0x00000000) },
-	{ RX_DC_PF_WM_REG_KER,
+	{ FR_AZ_RX_DC_PF_WM,
 	  EFX_OWORD32(0x000003FF, 0x00000000, 0x00000000, 0x00000000) },
-	{ DP_CTRL_REG,
+	{ FR_BZ_DP_CTRL,
 	  EFX_OWORD32(0x00000FFF, 0x00000000, 0x00000000, 0x00000000) },
-	{ GM_CFG2_REG,
+	{ FR_AB_GM_CFG2,
 	  EFX_OWORD32(0x00007337, 0x00000000, 0x00000000, 0x00000000) },
-	{ GMF_CFG0_REG,
+	{ FR_AB_GMF_CFG0,
 	  EFX_OWORD32(0x00001F1F, 0x00000000, 0x00000000, 0x00000000) },
-	{ XM_GLB_CFG_REG,
+	{ FR_AB_XM_GLB_CFG,
 	  EFX_OWORD32(0x00000C68, 0x00000000, 0x00000000, 0x00000000) },
-	{ XM_TX_CFG_REG,
+	{ FR_AB_XM_TX_CFG,
 	  EFX_OWORD32(0x00080164, 0x00000000, 0x00000000, 0x00000000) },
-	{ XM_RX_CFG_REG,
+	{ FR_AB_XM_RX_CFG,
 	  EFX_OWORD32(0x07100A0C, 0x00000000, 0x00000000, 0x00000000) },
-	{ XM_RX_PARAM_REG,
+	{ FR_AB_XM_RX_PARAM,
 	  EFX_OWORD32(0x00001FF8, 0x00000000, 0x00000000, 0x00000000) },
-	{ XM_FC_REG,
+	{ FR_AB_XM_FC,
 	  EFX_OWORD32(0xFFFF0001, 0x00000000, 0x00000000, 0x00000000) },
-	{ XM_ADR_LO_REG,
+	{ FR_AB_XM_ADR_LO,
 	  EFX_OWORD32(0xFFFFFFFF, 0x00000000, 0x00000000, 0x00000000) },
-	{ XX_SD_CTL_REG,
+	{ FR_AB_XX_SD_CTL,
 	  EFX_OWORD32(0x0003FF0F, 0x00000000, 0x00000000, 0x00000000) },
 };
 
@@ -2538,22 +2554,24 @@ int falcon_reset_hw(struct efx_nic *efx, enum reset_type method)
 		}
 
 		EFX_POPULATE_OWORD_2(glb_ctl_reg_ker,
-				     EXT_PHY_RST_DUR, 0x7,
-				     SWRST, 1);
+				     FRF_AB_EXT_PHY_RST_DUR,
+				     FFE_AB_EXT_PHY_RST_DUR_10240US,
+				     FRF_AB_SWRST, 1);
 	} else {
-		int reset_phy = (method == RESET_TYPE_INVISIBLE ?
-				 EXCLUDE_FROM_RESET : 0);
-
 		EFX_POPULATE_OWORD_7(glb_ctl_reg_ker,
-				     EXT_PHY_RST_CTL, reset_phy,
-				     PCIE_CORE_RST_CTL, EXCLUDE_FROM_RESET,
-				     PCIE_NSTCK_RST_CTL, EXCLUDE_FROM_RESET,
-				     PCIE_SD_RST_CTL, EXCLUDE_FROM_RESET,
-				     EE_RST_CTL, EXCLUDE_FROM_RESET,
-				     EXT_PHY_RST_DUR, 0x7 /* 10ms */,
-				     SWRST, 1);
-	}
-	falcon_write(efx, &glb_ctl_reg_ker, GLB_CTL_REG_KER);
+				     /* exclude PHY from "invisible" reset */
+				     FRF_AB_EXT_PHY_RST_CTL,
+				     method == RESET_TYPE_INVISIBLE,
+				     /* exclude EEPROM/flash and PCIe */
+				     FRF_AB_PCIE_CORE_RST_CTL, 1,
+				     FRF_AB_PCIE_NSTKY_RST_CTL, 1,
+				     FRF_AB_PCIE_SD_RST_CTL, 1,
+				     FRF_AB_EE_RST_CTL, 1,
+				     FRF_AB_EXT_PHY_RST_DUR,
+				     FFE_AB_EXT_PHY_RST_DUR_10240US,
+				     FRF_AB_SWRST, 1);
+	}
+	falcon_write(efx, &glb_ctl_reg_ker, FR_AB_GLB_CTL);
 
 	EFX_LOG(efx, "waiting for hardware reset\n");
 	schedule_timeout_uninterruptible(HZ / 20);
@@ -2578,8 +2596,8 @@ int falcon_reset_hw(struct efx_nic *efx, enum reset_type method)
 	}
 
 	/* Assert that reset complete */
-	falcon_read(efx, &glb_ctl_reg_ker, GLB_CTL_REG_KER);
-	if (EFX_OWORD_FIELD(glb_ctl_reg_ker, SWRST) != 0) {
+	falcon_read(efx, &glb_ctl_reg_ker, FR_AB_GLB_CTL);
+	if (EFX_OWORD_FIELD(glb_ctl_reg_ker, FRF_AB_SWRST) != 0) {
 		rc = -ETIMEDOUT;
 		EFX_ERR(efx, "timed out waiting for hardware reset\n");
 		goto fail5;
@@ -2607,16 +2625,16 @@ static int falcon_reset_sram(struct efx_nic *efx)
 	int count;
 
 	/* Set the SRAM wake/sleep GPIO appropriately. */
-	falcon_read(efx, &gpio_cfg_reg_ker, GPIO_CTL_REG_KER);
-	EFX_SET_OWORD_FIELD(gpio_cfg_reg_ker, GPIO1_OEN, 1);
-	EFX_SET_OWORD_FIELD(gpio_cfg_reg_ker, GPIO1_OUT, 1);
-	falcon_write(efx, &gpio_cfg_reg_ker, GPIO_CTL_REG_KER);
+	falcon_read(efx, &gpio_cfg_reg_ker, FR_AB_GPIO_CTL);
+	EFX_SET_OWORD_FIELD(gpio_cfg_reg_ker, FRF_AB_GPIO1_OEN, 1);
+	EFX_SET_OWORD_FIELD(gpio_cfg_reg_ker, FRF_AB_GPIO1_OUT, 1);
+	falcon_write(efx, &gpio_cfg_reg_ker, FR_AB_GPIO_CTL);
 
 	/* Initiate SRAM reset */
 	EFX_POPULATE_OWORD_2(srm_cfg_reg_ker,
-			     SRAM_OOB_BT_INIT_EN, 1,
-			     SRM_NUM_BANKS_AND_BANK_SIZE, 0);
-	falcon_write(efx, &srm_cfg_reg_ker, SRM_CFG_REG_KER);
+			     FRF_AZ_SRM_INIT_EN, 1,
+			     FRF_AZ_SRM_NB_SZ, 0);
+	falcon_write(efx, &srm_cfg_reg_ker, FR_AZ_SRM_CFG);
 
 	/* Wait for SRAM reset to complete */
 	count = 0;
@@ -2627,8 +2645,8 @@ static int falcon_reset_sram(struct efx_nic *efx)
 		schedule_timeout_uninterruptible(HZ / 50);
 
 		/* Check for reset complete */
-		falcon_read(efx, &srm_cfg_reg_ker, SRM_CFG_REG_KER);
-		if (!EFX_OWORD_FIELD(srm_cfg_reg_ker, SRAM_OOB_BT_INIT_EN)) {
+		falcon_read(efx, &srm_cfg_reg_ker, FR_AZ_SRM_CFG);
+		if (!EFX_OWORD_FIELD(srm_cfg_reg_ker, FRF_AZ_SRM_INIT_EN)) {
 			EFX_LOG(efx, "SRAM reset complete\n");
 
 			return 0;
@@ -2713,16 +2731,16 @@ static int falcon_probe_nvconfig(struct efx_nic *efx)
 		board_rev = le16_to_cpu(v2->board_revision);
 
 		if (le16_to_cpu(nvconfig->board_struct_ver) >= 3) {
-			__le32 fl = v3->spi_device_type[EE_SPI_FLASH];
-			__le32 ee = v3->spi_device_type[EE_SPI_EEPROM];
-			rc = falcon_spi_device_init(efx, &efx->spi_flash,
-						    EE_SPI_FLASH,
-						    le32_to_cpu(fl));
+			rc = falcon_spi_device_init(
+				efx, &efx->spi_flash, FFE_AB_SPI_DEVICE_FLASH,
+				le32_to_cpu(v3->spi_device_type
+					    [FFE_AB_SPI_DEVICE_FLASH]));
 			if (rc)
 				goto fail2;
-			rc = falcon_spi_device_init(efx, &efx->spi_eeprom,
-						    EE_SPI_EEPROM,
-						    le32_to_cpu(ee));
+			rc = falcon_spi_device_init(
+				efx, &efx->spi_eeprom, FFE_AB_SPI_DEVICE_EEPROM,
+				le32_to_cpu(v3->spi_device_type
+					    [FFE_AB_SPI_DEVICE_EEPROM]));
 			if (rc)
 				goto fail2;
 		}
@@ -2753,13 +2771,13 @@ static int falcon_probe_nic_variant(struct efx_nic *efx)
 	efx_oword_t altera_build;
 	efx_oword_t nic_stat;
 
-	falcon_read(efx, &altera_build, ALTERA_BUILD_REG_KER);
-	if (EFX_OWORD_FIELD(altera_build, VER_ALL)) {
+	falcon_read(efx, &altera_build, FR_AZ_ALTERA_BUILD);
+	if (EFX_OWORD_FIELD(altera_build, FRF_AZ_ALTERA_BUILD_VER)) {
 		EFX_ERR(efx, "Falcon FPGA not supported\n");
 		return -ENODEV;
 	}
 
-	falcon_read(efx, &nic_stat, NIC_STAT_REG);
+	falcon_read(efx, &nic_stat, FR_AB_NIC_STAT);
 
 	switch (falcon_rev(efx)) {
 	case FALCON_REV_A0:
@@ -2768,7 +2786,7 @@ static int falcon_probe_nic_variant(struct efx_nic *efx)
 		return -ENODEV;
 
 	case FALCON_REV_A1:
-		if (EFX_OWORD_FIELD(nic_stat, STRAP_PCIE) == 0) {
+		if (EFX_OWORD_FIELD(nic_stat, FRF_AA_STRAP_PCIE) == 0) {
 			EFX_ERR(efx, "Falcon rev A1 PCI-X not supported\n");
 			return -ENODEV;
 		}
@@ -2783,7 +2801,7 @@ static int falcon_probe_nic_variant(struct efx_nic *efx)
 	}
 
 	/* Initial assumed speed */
-	efx->link_speed = EFX_OWORD_FIELD(nic_stat, STRAP_10G) ? 10000 : 1000;
+	efx->link_speed = EFX_OWORD_FIELD(nic_stat, FRF_AB_STRAP_10G) ? 10000 : 1000;
 
 	return 0;
 }
@@ -2794,34 +2812,36 @@ static void falcon_probe_spi_devices(struct efx_nic *efx)
 	efx_oword_t nic_stat, gpio_ctl, ee_vpd_cfg;
 	int boot_dev;
 
-	falcon_read(efx, &gpio_ctl, GPIO_CTL_REG_KER);
-	falcon_read(efx, &nic_stat, NIC_STAT_REG);
-	falcon_read(efx, &ee_vpd_cfg, EE_VPD_CFG_REG_KER);
+	falcon_read(efx, &gpio_ctl, FR_AB_GPIO_CTL);
+	falcon_read(efx, &nic_stat, FR_AB_NIC_STAT);
+	falcon_read(efx, &ee_vpd_cfg, FR_AB_EE_VPD_CFG0);
 
-	if (EFX_OWORD_FIELD(gpio_ctl, BOOTED_USING_NVDEVICE)) {
-		boot_dev = (EFX_OWORD_FIELD(nic_stat, SF_PRST) ?
-			    EE_SPI_FLASH : EE_SPI_EEPROM);
+	if (EFX_OWORD_FIELD(gpio_ctl, FRF_AB_GPIO3_PWRUP_VALUE)) {
+		boot_dev = (EFX_OWORD_FIELD(nic_stat, FRF_AB_SF_PRST) ?
+			    FFE_AB_SPI_DEVICE_FLASH : FFE_AB_SPI_DEVICE_EEPROM);
 		EFX_LOG(efx, "Booted from %s\n",
-			boot_dev == EE_SPI_FLASH ? "flash" : "EEPROM");
+			boot_dev == FFE_AB_SPI_DEVICE_FLASH ? "flash" : "EEPROM");
 	} else {
 		/* Disable VPD and set clock dividers to safe
 		 * values for initial programming. */
 		boot_dev = -1;
 		EFX_LOG(efx, "Booted from internal ASIC settings;"
 			" setting SPI config\n");
-		EFX_POPULATE_OWORD_3(ee_vpd_cfg, EE_VPD_EN, 0,
+		EFX_POPULATE_OWORD_3(ee_vpd_cfg, FRF_AB_EE_VPD_EN, 0,
 				     /* 125 MHz / 7 ~= 20 MHz */
-				     EE_SF_CLOCK_DIV, 7,
+				     FRF_AB_EE_SF_CLOCK_DIV, 7,
 				     /* 125 MHz / 63 ~= 2 MHz */
-				     EE_EE_CLOCK_DIV, 63);
-		falcon_write(efx, &ee_vpd_cfg, EE_VPD_CFG_REG_KER);
+				     FRF_AB_EE_EE_CLOCK_DIV, 63);
+		falcon_write(efx, &ee_vpd_cfg, FR_AB_EE_VPD_CFG0);
 	}
 
-	if (boot_dev == EE_SPI_FLASH)
-		falcon_spi_device_init(efx, &efx->spi_flash, EE_SPI_FLASH,
+	if (boot_dev == FFE_AB_SPI_DEVICE_FLASH)
+		falcon_spi_device_init(efx, &efx->spi_flash,
+				       FFE_AB_SPI_DEVICE_FLASH,
 				       default_flash_type);
-	if (boot_dev == EE_SPI_EEPROM)
-		falcon_spi_device_init(efx, &efx->spi_eeprom, EE_SPI_EEPROM,
+	if (boot_dev == FFE_AB_SPI_DEVICE_EEPROM)
+		falcon_spi_device_init(efx, &efx->spi_eeprom,
+				       FFE_AB_SPI_DEVICE_EEPROM,
 				       large_eeprom_type);
 }
 
@@ -2926,34 +2946,36 @@ static void falcon_init_rx_cfg(struct efx_nic *efx)
 	int data_xoff_thr = rx_xoff_thresh_bytes >> 8;
 	efx_oword_t reg;
 
-	falcon_read(efx, &reg, RX_CFG_REG_KER);
+	falcon_read(efx, &reg, FR_AZ_RX_CFG);
 	if (falcon_rev(efx) <= FALCON_REV_A1) {
 		/* Data FIFO size is 5.5K */
 		if (data_xon_thr < 0)
 			data_xon_thr = 512 >> 8;
 		if (data_xoff_thr < 0)
 			data_xoff_thr = 2048 >> 8;
-		EFX_SET_OWORD_FIELD(reg, RX_DESC_PUSH_EN_A1, 0);
-		EFX_SET_OWORD_FIELD(reg, RX_USR_BUF_SIZE_A1, huge_buf_size);
-		EFX_SET_OWORD_FIELD(reg, RX_XON_MAC_TH_A1, data_xon_thr);
-		EFX_SET_OWORD_FIELD(reg, RX_XOFF_MAC_TH_A1, data_xoff_thr);
-		EFX_SET_OWORD_FIELD(reg, RX_XON_TX_TH_A1, ctrl_xon_thr);
-		EFX_SET_OWORD_FIELD(reg, RX_XOFF_TX_TH_A1, ctrl_xoff_thr);
+		EFX_SET_OWORD_FIELD(reg, FRF_AA_RX_DESC_PUSH_EN, 0);
+		EFX_SET_OWORD_FIELD(reg, FRF_AA_RX_USR_BUF_SIZE,
+				    huge_buf_size);
+		EFX_SET_OWORD_FIELD(reg, FRF_AA_RX_XON_MAC_TH, data_xon_thr);
+		EFX_SET_OWORD_FIELD(reg, FRF_AA_RX_XOFF_MAC_TH, data_xoff_thr);
+		EFX_SET_OWORD_FIELD(reg, FRF_AA_RX_XON_TX_TH, ctrl_xon_thr);
+		EFX_SET_OWORD_FIELD(reg, FRF_AA_RX_XOFF_TX_TH, ctrl_xoff_thr);
 	} else {
 		/* Data FIFO size is 80K; register fields moved */
 		if (data_xon_thr < 0)
 			data_xon_thr = 27648 >> 8; /* ~3*max MTU */
 		if (data_xoff_thr < 0)
 			data_xoff_thr = 54272 >> 8; /* ~80Kb - 3*max MTU */
-		EFX_SET_OWORD_FIELD(reg, RX_DESC_PUSH_EN_B0, 0);
-		EFX_SET_OWORD_FIELD(reg, RX_USR_BUF_SIZE_B0, huge_buf_size);
-		EFX_SET_OWORD_FIELD(reg, RX_XON_MAC_TH_B0, data_xon_thr);
-		EFX_SET_OWORD_FIELD(reg, RX_XOFF_MAC_TH_B0, data_xoff_thr);
-		EFX_SET_OWORD_FIELD(reg, RX_XON_TX_TH_B0, ctrl_xon_thr);
-		EFX_SET_OWORD_FIELD(reg, RX_XOFF_TX_TH_B0, ctrl_xoff_thr);
-		EFX_SET_OWORD_FIELD(reg, RX_INGR_EN_B0, 1);
+		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_DESC_PUSH_EN, 0);
+		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_USR_BUF_SIZE,
+				    huge_buf_size);
+		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_XON_MAC_TH, data_xon_thr);
+		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_XOFF_MAC_TH, data_xoff_thr);
+		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_XON_TX_TH, ctrl_xon_thr);
+		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_XOFF_TX_TH, ctrl_xoff_thr);
+		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_INGR_EN, 1);
 	}
-	falcon_write(efx, &reg, RX_CFG_REG_KER);
+	falcon_write(efx, &reg, FR_AZ_RX_CFG);
 }
 
 /* This call performs hardware-specific global initialisation, such as
@@ -2966,15 +2988,15 @@ int falcon_init_nic(struct efx_nic *efx)
 	int rc;
 
 	/* Use on-chip SRAM */
-	falcon_read(efx, &temp, NIC_STAT_REG);
-	EFX_SET_OWORD_FIELD(temp, ONCHIP_SRAM, 1);
-	falcon_write(efx, &temp, NIC_STAT_REG);
+	falcon_read(efx, &temp, FR_AB_NIC_STAT);
+	EFX_SET_OWORD_FIELD(temp, FRF_AB_ONCHIP_SRAM, 1);
+	falcon_write(efx, &temp, FR_AB_NIC_STAT);
 
 	/* Set the source of the GMAC clock */
 	if (falcon_rev(efx) == FALCON_REV_B0) {
-		falcon_read(efx, &temp, GPIO_CTL_REG_KER);
-		EFX_SET_OWORD_FIELD(temp, GPIO_USE_NIC_CLK, true);
-		falcon_write(efx, &temp, GPIO_CTL_REG_KER);
+		falcon_read(efx, &temp, FR_AB_GPIO_CTL);
+		EFX_SET_OWORD_FIELD(temp, FRF_AB_USE_NIC_CLK, true);
+		falcon_write(efx, &temp, FR_AB_GPIO_CTL);
 	}
 
 	rc = falcon_reset_sram(efx);
@@ -2982,32 +3004,32 @@ int falcon_init_nic(struct efx_nic *efx)
 		return rc;
 
 	/* Set positions of descriptor caches in SRAM. */
-	EFX_POPULATE_OWORD_1(temp, SRM_TX_DC_BASE_ADR, TX_DC_BASE / 8);
-	falcon_write(efx, &temp, SRM_TX_DC_CFG_REG_KER);
-	EFX_POPULATE_OWORD_1(temp, SRM_RX_DC_BASE_ADR, RX_DC_BASE / 8);
-	falcon_write(efx, &temp, SRM_RX_DC_CFG_REG_KER);
+	EFX_POPULATE_OWORD_1(temp, FRF_AZ_SRM_TX_DC_BASE_ADR, TX_DC_BASE / 8);
+	falcon_write(efx, &temp, FR_AZ_SRM_TX_DC_CFG);
+	EFX_POPULATE_OWORD_1(temp, FRF_AZ_SRM_RX_DC_BASE_ADR, RX_DC_BASE / 8);
+	falcon_write(efx, &temp, FR_AZ_SRM_RX_DC_CFG);
 
 	/* Set TX descriptor cache size. */
 	BUILD_BUG_ON(TX_DC_ENTRIES != (16 << TX_DC_ENTRIES_ORDER));
-	EFX_POPULATE_OWORD_1(temp, TX_DC_SIZE, TX_DC_ENTRIES_ORDER);
-	falcon_write(efx, &temp, TX_DC_CFG_REG_KER);
+	EFX_POPULATE_OWORD_1(temp, FRF_AZ_TX_DC_SIZE, TX_DC_ENTRIES_ORDER);
+	falcon_write(efx, &temp, FR_AZ_TX_DC_CFG);
 
 	/* Set RX descriptor cache size.  Set low watermark to size-8, as
 	 * this allows most efficient prefetching.
 	 */
 	BUILD_BUG_ON(RX_DC_ENTRIES != (16 << RX_DC_ENTRIES_ORDER));
-	EFX_POPULATE_OWORD_1(temp, RX_DC_SIZE, RX_DC_ENTRIES_ORDER);
-	falcon_write(efx, &temp, RX_DC_CFG_REG_KER);
-	EFX_POPULATE_OWORD_1(temp, RX_DC_PF_LWM, RX_DC_ENTRIES - 8);
-	falcon_write(efx, &temp, RX_DC_PF_WM_REG_KER);
+	EFX_POPULATE_OWORD_1(temp, FRF_AZ_RX_DC_SIZE, RX_DC_ENTRIES_ORDER);
+	falcon_write(efx, &temp, FR_AZ_RX_DC_CFG);
+	EFX_POPULATE_OWORD_1(temp, FRF_AZ_RX_DC_PF_LWM, RX_DC_ENTRIES - 8);
+	falcon_write(efx, &temp, FR_AZ_RX_DC_PF_WM);
 
 	/* Clear the parity enables on the TX data fifos as
 	 * they produce false parity errors because of timing issues
 	 */
 	if (EFX_WORKAROUND_5129(efx)) {
-		falcon_read(efx, &temp, SPARE_REG_KER);
-		EFX_SET_OWORD_FIELD(temp, MEM_PERR_EN_TX_DATA, 0);
-		falcon_write(efx, &temp, SPARE_REG_KER);
+		falcon_read(efx, &temp, FR_AZ_CSR_SPARE);
+		EFX_SET_OWORD_FIELD(temp, FRF_AB_MEM_PERR_EN_TX_DATA, 0);
+		falcon_write(efx, &temp, FR_AZ_CSR_SPARE);
 	}
 
 	/* Enable all the genuinely fatal interrupts.  (They are still
@@ -3017,64 +3039,65 @@ int falcon_init_nic(struct efx_nic *efx)
 	 * Note: All other fatal interrupts are enabled
 	 */
 	EFX_POPULATE_OWORD_3(temp,
-			     ILL_ADR_INT_KER_EN, 1,
-			     RBUF_OWN_INT_KER_EN, 1,
-			     TBUF_OWN_INT_KER_EN, 1);
+			     FRF_AZ_ILL_ADR_INT_KER_EN, 1,
+			     FRF_AZ_RBUF_OWN_INT_KER_EN, 1,
+			     FRF_AZ_TBUF_OWN_INT_KER_EN, 1);
 	EFX_INVERT_OWORD(temp);
-	falcon_write(efx, &temp, FATAL_INTR_REG_KER);
+	falcon_write(efx, &temp, FR_AZ_FATAL_INTR_KER);
 
 	if (EFX_WORKAROUND_7244(efx)) {
-		falcon_read(efx, &temp, RX_FILTER_CTL_REG);
-		EFX_SET_OWORD_FIELD(temp, UDP_FULL_SRCH_LIMIT, 8);
-		EFX_SET_OWORD_FIELD(temp, UDP_WILD_SRCH_LIMIT, 8);
-		EFX_SET_OWORD_FIELD(temp, TCP_FULL_SRCH_LIMIT, 8);
-		EFX_SET_OWORD_FIELD(temp, TCP_WILD_SRCH_LIMIT, 8);
-		falcon_write(efx, &temp, RX_FILTER_CTL_REG);
+		falcon_read(efx, &temp, FR_BZ_RX_FILTER_CTL);
+		EFX_SET_OWORD_FIELD(temp, FRF_BZ_UDP_FULL_SRCH_LIMIT, 8);
+		EFX_SET_OWORD_FIELD(temp, FRF_BZ_UDP_WILD_SRCH_LIMIT, 8);
+		EFX_SET_OWORD_FIELD(temp, FRF_BZ_TCP_FULL_SRCH_LIMIT, 8);
+		EFX_SET_OWORD_FIELD(temp, FRF_BZ_TCP_WILD_SRCH_LIMIT, 8);
+		falcon_write(efx, &temp, FR_BZ_RX_FILTER_CTL);
 	}
 
 	falcon_setup_rss_indir_table(efx);
 
+	/* XXX This is documented only for Falcon A0/A1 */
 	/* Setup RX.  Wait for descriptor is broken and must
 	 * be disabled.  RXDP recovery shouldn't be needed, but is.
 	 */
-	falcon_read(efx, &temp, RX_SELF_RST_REG_KER);
-	EFX_SET_OWORD_FIELD(temp, RX_NODESC_WAIT_DIS, 1);
-	EFX_SET_OWORD_FIELD(temp, RX_RECOVERY_EN, 1);
+	falcon_read(efx, &temp, FR_AA_RX_SELF_RST);
+	EFX_SET_OWORD_FIELD(temp, FRF_AA_RX_NODESC_WAIT_DIS, 1);
+	EFX_SET_OWORD_FIELD(temp, FRF_AA_RX_SELF_RST_EN, 1);
 	if (EFX_WORKAROUND_5583(efx))
-		EFX_SET_OWORD_FIELD(temp, RX_ISCSI_DIS, 1);
-	falcon_write(efx, &temp, RX_SELF_RST_REG_KER);
+		EFX_SET_OWORD_FIELD(temp, FRF_AA_RX_ISCSI_DIS, 1);
+	falcon_write(efx, &temp, FR_AA_RX_SELF_RST);
 
 	/* Disable the ugly timer-based TX DMA backoff and allow TX DMA to be
 	 * controlled by the RX FIFO fill level. Set arbitration to one pkt/Q.
 	 */
-	falcon_read(efx, &temp, TX_CFG2_REG_KER);
-	EFX_SET_OWORD_FIELD(temp, TX_RX_SPACER, 0xfe);
-	EFX_SET_OWORD_FIELD(temp, TX_RX_SPACER_EN, 1);
-	EFX_SET_OWORD_FIELD(temp, TX_ONE_PKT_PER_Q, 1);
-	EFX_SET_OWORD_FIELD(temp, TX_CSR_PUSH_EN, 0);
-	EFX_SET_OWORD_FIELD(temp, TX_DIS_NON_IP_EV, 1);
+	falcon_read(efx, &temp, FR_AZ_TX_RESERVED);
+	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_RX_SPACER, 0xfe);
+	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_RX_SPACER_EN, 1);
+	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_ONE_PKT_PER_Q, 1);
+	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_PUSH_EN, 0);
+	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_DIS_NON_IP_EV, 1);
 	/* Enable SW_EV to inherit in char driver - assume harmless here */
-	EFX_SET_OWORD_FIELD(temp, TX_SW_EV_EN, 1);
+	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_SOFT_EVT_EN, 1);
 	/* Prefetch threshold 2 => fetch when descriptor cache half empty */
-	EFX_SET_OWORD_FIELD(temp, TX_PREF_THRESHOLD, 2);
+	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_PREF_THRESHOLD, 2);
 	/* Squash TX of packets of 16 bytes or less */
 	if (falcon_rev(efx) >= FALCON_REV_B0 && EFX_WORKAROUND_9141(efx))
-		EFX_SET_OWORD_FIELD(temp, TX_FLUSH_MIN_LEN_EN_B0, 1);
-	falcon_write(efx, &temp, TX_CFG2_REG_KER);
+		EFX_SET_OWORD_FIELD(temp, FRF_BZ_TX_FLUSH_MIN_LEN_EN, 1);
+	falcon_write(efx, &temp, FR_AZ_TX_RESERVED);
 
 	/* Do not enable TX_NO_EOP_DISC_EN, since it limits packets to 16
 	 * descriptors (which is bad).
 	 */
-	falcon_read(efx, &temp, TX_CFG_REG_KER);
-	EFX_SET_OWORD_FIELD(temp, TX_NO_EOP_DISC_EN, 0);
-	falcon_write(efx, &temp, TX_CFG_REG_KER);
+	falcon_read(efx, &temp, FR_AZ_TX_CFG);
+	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_NO_EOP_DISC_EN, 0);
+	falcon_write(efx, &temp, FR_AZ_TX_CFG);
 
 	falcon_init_rx_cfg(efx);
 
 	/* Set destination of both TX and RX Flush events */
 	if (falcon_rev(efx) >= FALCON_REV_B0) {
-		EFX_POPULATE_OWORD_1(temp, FLS_EVQ_ID, 0);
-		falcon_write(efx, &temp, DP_CTRL_REG);
+		EFX_POPULATE_OWORD_1(temp, FRF_BZ_FLS_EVQ_ID, 0);
+		falcon_write(efx, &temp, FR_BZ_DP_CTRL);
 	}
 
 	return 0;
@@ -3110,8 +3133,9 @@ void falcon_update_nic_stats(struct efx_nic *efx)
 {
 	efx_oword_t cnt;
 
-	falcon_read(efx, &cnt, RX_NODESC_DROP_REG_KER);
-	efx->n_rx_nodesc_drop_cnt += EFX_OWORD_FIELD(cnt, RX_NODESC_DROP_CNT);
+	falcon_read(efx, &cnt, FR_AZ_RX_NODESC_DROP);
+	efx->n_rx_nodesc_drop_cnt +=
+		EFX_OWORD_FIELD(cnt, FRF_AB_RX_NODESC_DROP_CNT);
 }
 
 /**************************************************************************
@@ -3124,11 +3148,11 @@ void falcon_update_nic_stats(struct efx_nic *efx)
 struct efx_nic_type falcon_a_nic_type = {
 	.mem_bar = 2,
 	.mem_map_size = 0x20000,
-	.txd_ptr_tbl_base = TX_DESC_PTR_TBL_KER_A1,
-	.rxd_ptr_tbl_base = RX_DESC_PTR_TBL_KER_A1,
-	.buf_tbl_base = BUF_TBL_KER_A1,
-	.evq_ptr_tbl_base = EVQ_PTR_TBL_KER_A1,
-	.evq_rptr_tbl_base = EVQ_RPTR_REG_KER_A1,
+	.txd_ptr_tbl_base = FR_AA_TX_DESC_PTR_TBL_KER,
+	.rxd_ptr_tbl_base = FR_AA_RX_DESC_PTR_TBL_KER,
+	.buf_tbl_base = FR_AA_BUF_FULL_TBL_KER,
+	.evq_ptr_tbl_base = FR_AA_EVQ_PTR_TBL_KER,
+	.evq_rptr_tbl_base = FR_AA_EVQ_RPTR_KER,
 	.txd_ring_mask = FALCON_TXD_RING_MASK,
 	.rxd_ring_mask = FALCON_RXD_RING_MASK,
 	.evq_size = FALCON_EVQ_SIZE,
@@ -3145,12 +3169,14 @@ struct efx_nic_type falcon_b_nic_type = {
 	/* Map everything up to and including the RSS indirection
 	 * table.  Don't map MSI-X table, MSI-X PBA since Linux
 	 * requires that they not be mapped.  */
-	.mem_map_size = RX_RSS_INDIR_TBL_B0 + 0x800,
-	.txd_ptr_tbl_base = TX_DESC_PTR_TBL_KER_B0,
-	.rxd_ptr_tbl_base = RX_DESC_PTR_TBL_KER_B0,
-	.buf_tbl_base = BUF_TBL_KER_B0,
-	.evq_ptr_tbl_base = EVQ_PTR_TBL_KER_B0,
-	.evq_rptr_tbl_base = EVQ_RPTR_REG_KER_B0,
+	.mem_map_size = (FR_BZ_RX_INDIRECTION_TBL +
+			 FR_BZ_RX_INDIRECTION_TBL_STEP *
+			 FR_BZ_RX_INDIRECTION_TBL_ROWS),
+	.txd_ptr_tbl_base = FR_BZ_TX_DESC_PTR_TBL,
+	.rxd_ptr_tbl_base = FR_BZ_RX_DESC_PTR_TBL,
+	.buf_tbl_base = FR_BZ_BUF_FULL_TBL,
+	.evq_ptr_tbl_base = FR_BZ_EVQ_PTR_TBL,
+	.evq_rptr_tbl_base = FR_BZ_EVQ_RPTR,
 	.txd_ring_mask = FALCON_TXD_RING_MASK,
 	.rxd_ring_mask = FALCON_RXD_RING_MASK,
 	.evq_size = FALCON_EVQ_SIZE,
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index ab94075..68ca45c 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -13,7 +13,7 @@
 #include "phy.h"
 #include "efx.h"
 #include "falcon.h"
-#include "falcon_hwdefs.h"
+#include "regs.h"
 #include "falcon_io.h"
 #include "workarounds.h"
 
@@ -332,14 +332,14 @@ static int sfn4111t_reset(struct efx_nic *efx)
 	 * FLASH_CFG_1 strap (GPIO 3) appropriately.  Only change the
 	 * output enables; the output levels should always be 0 (low)
 	 * and we rely on external pull-ups. */
-	falcon_read(efx, &reg, GPIO_CTL_REG_KER);
-	EFX_SET_OWORD_FIELD(reg, GPIO2_OEN, true);
-	falcon_write(efx, &reg, GPIO_CTL_REG_KER);
+	falcon_read(efx, &reg, FR_AB_GPIO_CTL);
+	EFX_SET_OWORD_FIELD(reg, FRF_AB_GPIO2_OEN, true);
+	falcon_write(efx, &reg, FR_AB_GPIO_CTL);
 	msleep(1000);
-	EFX_SET_OWORD_FIELD(reg, GPIO2_OEN, false);
-	EFX_SET_OWORD_FIELD(reg, GPIO3_OEN,
+	EFX_SET_OWORD_FIELD(reg, FRF_AB_GPIO2_OEN, false);
+	EFX_SET_OWORD_FIELD(reg, FRF_AB_GPIO3_OEN,
 			    !!(efx->phy_mode & PHY_MODE_SPECIAL));
-	falcon_write(efx, &reg, GPIO_CTL_REG_KER);
+	falcon_write(efx, &reg, FR_AB_GPIO_CTL);
 	msleep(1);
 
 	mutex_unlock(&efx->i2c_adap.bus_lock);
diff --git a/drivers/net/sfc/falcon_gmac.c b/drivers/net/sfc/falcon_gmac.c
index 36f57b1..0d156c8 100644
--- a/drivers/net/sfc/falcon_gmac.c
+++ b/drivers/net/sfc/falcon_gmac.c
@@ -13,7 +13,7 @@
 #include "efx.h"
 #include "falcon.h"
 #include "mac.h"
-#include "falcon_hwdefs.h"
+#include "regs.h"
 #include "falcon_io.h"
 
 /**************************************************************************
@@ -36,89 +36,89 @@ static void falcon_reconfigure_gmac(struct efx_nic *efx)
 	bytemode = (efx->link_speed == 1000);
 
 	EFX_POPULATE_OWORD_5(reg,
-			     GM_LOOP, loopback,
-			     GM_TX_EN, 1,
-			     GM_TX_FC_EN, tx_fc,
-			     GM_RX_EN, 1,
-			     GM_RX_FC_EN, rx_fc);
-	falcon_write(efx, &reg, GM_CFG1_REG);
+			     FRF_AB_GM_LOOP, loopback,
+			     FRF_AB_GM_TX_EN, 1,
+			     FRF_AB_GM_TX_FC_EN, tx_fc,
+			     FRF_AB_GM_RX_EN, 1,
+			     FRF_AB_GM_RX_FC_EN, rx_fc);
+	falcon_write(efx, &reg, FR_AB_GM_CFG1);
 	udelay(10);
 
 	/* Configuration register 2 */
 	if_mode = (bytemode) ? 2 : 1;
 	EFX_POPULATE_OWORD_5(reg,
-			     GM_IF_MODE, if_mode,
-			     GM_PAD_CRC_EN, 1,
-			     GM_LEN_CHK, 1,
-			     GM_FD, efx->link_fd,
-			     GM_PAMBL_LEN, 0x7/*datasheet recommended */);
+			     FRF_AB_GM_IF_MODE, if_mode,
+			     FRF_AB_GM_PAD_CRC_EN, 1,
+			     FRF_AB_GM_LEN_CHK, 1,
+			     FRF_AB_GM_FD, efx->link_fd,
+			     FRF_AB_GM_PAMBL_LEN, 0x7/*datasheet recommended */);
 
-	falcon_write(efx, &reg, GM_CFG2_REG);
+	falcon_write(efx, &reg, FR_AB_GM_CFG2);
 	udelay(10);
 
 	/* Max frame len register */
 	max_frame_len = EFX_MAX_FRAME_LEN(efx->net_dev->mtu);
-	EFX_POPULATE_OWORD_1(reg, GM_MAX_FLEN, max_frame_len);
-	falcon_write(efx, &reg, GM_MAX_FLEN_REG);
+	EFX_POPULATE_OWORD_1(reg, FRF_AB_GM_MAX_FLEN, max_frame_len);
+	falcon_write(efx, &reg, FR_AB_GM_MAX_FLEN);
 	udelay(10);
 
 	/* FIFO configuration register 0 */
 	EFX_POPULATE_OWORD_5(reg,
-			     GMF_FTFENREQ, 1,
-			     GMF_STFENREQ, 1,
-			     GMF_FRFENREQ, 1,
-			     GMF_SRFENREQ, 1,
-			     GMF_WTMENREQ, 1);
-	falcon_write(efx, &reg, GMF_CFG0_REG);
+			     FRF_AB_GMF_FTFENREQ, 1,
+			     FRF_AB_GMF_STFENREQ, 1,
+			     FRF_AB_GMF_FRFENREQ, 1,
+			     FRF_AB_GMF_SRFENREQ, 1,
+			     FRF_AB_GMF_WTMENREQ, 1);
+	falcon_write(efx, &reg, FR_AB_GMF_CFG0);
 	udelay(10);
 
 	/* FIFO configuration register 1 */
 	EFX_POPULATE_OWORD_2(reg,
-			     GMF_CFGFRTH, 0x12,
-			     GMF_CFGXOFFRTX, 0xffff);
-	falcon_write(efx, &reg, GMF_CFG1_REG);
+			     FRF_AB_GMF_CFGFRTH, 0x12,
+			     FRF_AB_GMF_CFGXOFFRTX, 0xffff);
+	falcon_write(efx, &reg, FR_AB_GMF_CFG1);
 	udelay(10);
 
 	/* FIFO configuration register 2 */
 	EFX_POPULATE_OWORD_2(reg,
-			     GMF_CFGHWM, 0x3f,
-			     GMF_CFGLWM, 0xa);
-	falcon_write(efx, &reg, GMF_CFG2_REG);
+			     FRF_AB_GMF_CFGHWM, 0x3f,
+			     FRF_AB_GMF_CFGLWM, 0xa);
+	falcon_write(efx, &reg, FR_AB_GMF_CFG2);
 	udelay(10);
 
 	/* FIFO configuration register 3 */
 	EFX_POPULATE_OWORD_2(reg,
-			     GMF_CFGHWMFT, 0x1c,
-			     GMF_CFGFTTH, 0x08);
-	falcon_write(efx, &reg, GMF_CFG3_REG);
+			     FRF_AB_GMF_CFGHWMFT, 0x1c,
+			     FRF_AB_GMF_CFGFTTH, 0x08);
+	falcon_write(efx, &reg, FR_AB_GMF_CFG3);
 	udelay(10);
 
 	/* FIFO configuration register 4 */
-	EFX_POPULATE_OWORD_1(reg, GMF_HSTFLTRFRM_PAUSE, 1);
-	falcon_write(efx, &reg, GMF_CFG4_REG);
+	EFX_POPULATE_OWORD_1(reg, FRF_AB_GMF_HSTFLTRFRM_PAUSE, 1);
+	falcon_write(efx, &reg, FR_AB_GMF_CFG4);
 	udelay(10);
 
 	/* FIFO configuration register 5 */
-	falcon_read(efx, &reg, GMF_CFG5_REG);
-	EFX_SET_OWORD_FIELD(reg, GMF_CFGBYTMODE, bytemode);
-	EFX_SET_OWORD_FIELD(reg, GMF_CFGHDPLX, !efx->link_fd);
-	EFX_SET_OWORD_FIELD(reg, GMF_HSTDRPLT64, !efx->link_fd);
-	EFX_SET_OWORD_FIELD(reg, GMF_HSTFLTRFRMDC_PAUSE, 0);
-	falcon_write(efx, &reg, GMF_CFG5_REG);
+	falcon_read(efx, &reg, FR_AB_GMF_CFG5);
+	EFX_SET_OWORD_FIELD(reg, FRF_AB_GMF_CFGBYTMODE, bytemode);
+	EFX_SET_OWORD_FIELD(reg, FRF_AB_GMF_CFGHDPLX, !efx->link_fd);
+	EFX_SET_OWORD_FIELD(reg, FRF_AB_GMF_HSTDRPLT64, !efx->link_fd);
+	EFX_SET_OWORD_FIELD(reg, FRF_AB_GMF_HSTFLTRFRMDC_PAUSE, 0);
+	falcon_write(efx, &reg, FR_AB_GMF_CFG5);
 	udelay(10);
 
 	/* MAC address */
 	EFX_POPULATE_OWORD_4(reg,
-			     GM_HWADDR_5, efx->net_dev->dev_addr[5],
-			     GM_HWADDR_4, efx->net_dev->dev_addr[4],
-			     GM_HWADDR_3, efx->net_dev->dev_addr[3],
-			     GM_HWADDR_2, efx->net_dev->dev_addr[2]);
-	falcon_write(efx, &reg, GM_ADR1_REG);
+			     FRF_AB_GM_ADR_B0, efx->net_dev->dev_addr[5],
+			     FRF_AB_GM_ADR_B1, efx->net_dev->dev_addr[4],
+			     FRF_AB_GM_ADR_B2, efx->net_dev->dev_addr[3],
+			     FRF_AB_GM_ADR_B3, efx->net_dev->dev_addr[2]);
+	falcon_write(efx, &reg, FR_AB_GM_ADR1);
 	udelay(10);
 	EFX_POPULATE_OWORD_2(reg,
-			     GM_HWADDR_1, efx->net_dev->dev_addr[1],
-			     GM_HWADDR_0, efx->net_dev->dev_addr[0]);
-	falcon_write(efx, &reg, GM_ADR2_REG);
+			     FRF_AB_GM_ADR_B4, efx->net_dev->dev_addr[1],
+			     FRF_AB_GM_ADR_B5, efx->net_dev->dev_addr[0]);
+	falcon_write(efx, &reg, FR_AB_GM_ADR2);
 	udelay(10);
 
 	falcon_reconfigure_mac_wrapper(efx);
diff --git a/drivers/net/sfc/falcon_hwdefs.h b/drivers/net/sfc/falcon_hwdefs.h
deleted file mode 100644
index 13f3999..0000000
--- a/drivers/net/sfc/falcon_hwdefs.h
+++ /dev/null
@@ -1,1332 +0,0 @@
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
-#ifndef EFX_FALCON_HWDEFS_H
-#define EFX_FALCON_HWDEFS_H
-
-/*
- * Falcon hardware value definitions.
- * Falcon is the internal codename for the SFC4000 controller that is
- * present in SFE400X evaluation boards
- */
-
-/**************************************************************************
- *
- * Falcon registers
- *
- **************************************************************************
- */
-
-/* Address region register */
-#define ADR_REGION_REG_KER	0x00
-#define ADR_REGION0_LBN	0
-#define ADR_REGION0_WIDTH	18
-#define ADR_REGION1_LBN	32
-#define ADR_REGION1_WIDTH	18
-#define ADR_REGION2_LBN	64
-#define ADR_REGION2_WIDTH	18
-#define ADR_REGION3_LBN	96
-#define ADR_REGION3_WIDTH	18
-
-/* Interrupt enable register */
-#define INT_EN_REG_KER 0x0010
-#define KER_INT_KER_LBN 3
-#define KER_INT_KER_WIDTH 1
-#define DRV_INT_EN_KER_LBN 0
-#define DRV_INT_EN_KER_WIDTH 1
-
-/* Interrupt status address register */
-#define INT_ADR_REG_KER	0x0030
-#define NORM_INT_VEC_DIS_KER_LBN 64
-#define NORM_INT_VEC_DIS_KER_WIDTH 1
-#define INT_ADR_KER_LBN 0
-#define INT_ADR_KER_WIDTH EFX_DMA_TYPE_WIDTH(64) /* not 46 for this one */
-
-/* Interrupt status register (B0 only) */
-#define INT_ISR0_B0 0x90
-#define INT_ISR1_B0 0xA0
-
-/* Interrupt acknowledge register (A0/A1 only) */
-#define INT_ACK_REG_KER_A1 0x0050
-#define INT_ACK_DUMMY_DATA_LBN 0
-#define INT_ACK_DUMMY_DATA_WIDTH 32
-
-/* Interrupt acknowledge work-around register (A0/A1 only )*/
-#define WORK_AROUND_BROKEN_PCI_READS_REG_KER_A1 0x0070
-
-/* SPI host command register */
-#define EE_SPI_HCMD_REG_KER 0x0100
-#define EE_SPI_HCMD_CMD_EN_LBN 31
-#define EE_SPI_HCMD_CMD_EN_WIDTH 1
-#define EE_WR_TIMER_ACTIVE_LBN 28
-#define EE_WR_TIMER_ACTIVE_WIDTH 1
-#define EE_SPI_HCMD_SF_SEL_LBN 24
-#define EE_SPI_HCMD_SF_SEL_WIDTH 1
-#define EE_SPI_EEPROM 0
-#define EE_SPI_FLASH 1
-#define EE_SPI_HCMD_DABCNT_LBN 16
-#define EE_SPI_HCMD_DABCNT_WIDTH 5
-#define EE_SPI_HCMD_READ_LBN 15
-#define EE_SPI_HCMD_READ_WIDTH 1
-#define EE_SPI_READ 1
-#define EE_SPI_WRITE 0
-#define EE_SPI_HCMD_DUBCNT_LBN 12
-#define EE_SPI_HCMD_DUBCNT_WIDTH 2
-#define EE_SPI_HCMD_ADBCNT_LBN 8
-#define EE_SPI_HCMD_ADBCNT_WIDTH 2
-#define EE_SPI_HCMD_ENC_LBN 0
-#define EE_SPI_HCMD_ENC_WIDTH 8
-
-/* SPI host address register */
-#define EE_SPI_HADR_REG_KER 0x0110
-#define EE_SPI_HADR_ADR_LBN 0
-#define EE_SPI_HADR_ADR_WIDTH 24
-
-/* SPI host data register */
-#define EE_SPI_HDATA_REG_KER 0x0120
-
-/* SPI/VPD config register */
-#define EE_VPD_CFG_REG_KER 0x0140
-#define EE_VPD_EN_LBN 0
-#define EE_VPD_EN_WIDTH 1
-#define EE_VPD_EN_AD9_MODE_LBN 1
-#define EE_VPD_EN_AD9_MODE_WIDTH 1
-#define EE_EE_CLOCK_DIV_LBN 112
-#define EE_EE_CLOCK_DIV_WIDTH 7
-#define EE_SF_CLOCK_DIV_LBN 120
-#define EE_SF_CLOCK_DIV_WIDTH 7
-
-/* PCIE CORE ACCESS REG */
-#define PCIE_CORE_ADDR_PCIE_DEVICE_CTRL_STAT 0x68
-#define PCIE_CORE_ADDR_PCIE_LINK_CTRL_STAT 0x70
-#define PCIE_CORE_ADDR_ACK_RPL_TIMER 0x700
-#define PCIE_CORE_ADDR_ACK_FREQ 0x70C
-
-/* NIC status register */
-#define NIC_STAT_REG 0x0200
-#define EE_STRAP_EN_LBN 31
-#define EE_STRAP_EN_WIDTH 1
-#define EE_STRAP_OVR_LBN 24
-#define EE_STRAP_OVR_WIDTH 4
-#define ONCHIP_SRAM_LBN 16
-#define ONCHIP_SRAM_WIDTH 1
-#define SF_PRST_LBN 9
-#define SF_PRST_WIDTH 1
-#define EE_PRST_LBN 8
-#define EE_PRST_WIDTH 1
-#define STRAP_PINS_LBN 0
-#define STRAP_PINS_WIDTH 3
-/* These bit definitions are extrapolated from the list of numerical
- * values for STRAP_PINS.
- */
-#define STRAP_10G_LBN 2
-#define STRAP_10G_WIDTH 1
-#define STRAP_PCIE_LBN 0
-#define STRAP_PCIE_WIDTH 1
-
-#define BOOTED_USING_NVDEVICE_LBN 3
-#define BOOTED_USING_NVDEVICE_WIDTH 1
-
-/* GPIO control register */
-#define GPIO_CTL_REG_KER 0x0210
-#define GPIO_USE_NIC_CLK_LBN (30)
-#define GPIO_USE_NIC_CLK_WIDTH (1)
-#define GPIO_OUTPUTS_LBN   (16)
-#define GPIO_OUTPUTS_WIDTH (4)
-#define GPIO_INPUTS_LBN (8)
-#define GPIO_DIRECTION_LBN (24)
-#define GPIO_DIRECTION_WIDTH (4)
-#define GPIO_DIRECTION_OUT (1)
-#define GPIO_SRAM_SLEEP (1 << 1)
-
-#define GPIO3_OEN_LBN (GPIO_DIRECTION_LBN + 3)
-#define	GPIO3_OEN_WIDTH 1
-#define	GPIO2_OEN_LBN (GPIO_DIRECTION_LBN + 2)
-#define	GPIO2_OEN_WIDTH 1
-#define	GPIO1_OEN_LBN (GPIO_DIRECTION_LBN + 1)
-#define	GPIO1_OEN_WIDTH 1
-#define GPIO0_OEN_LBN (GPIO_DIRECTION_LBN + 0)
-#define	GPIO0_OEN_WIDTH 1
-
-#define	GPIO3_OUT_LBN (GPIO_OUTPUTS_LBN + 3)
-#define	GPIO3_OUT_WIDTH 1
-#define	GPIO2_OUT_LBN (GPIO_OUTPUTS_LBN + 2)
-#define	GPIO2_OUT_WIDTH 1
-#define	GPIO1_OUT_LBN (GPIO_OUTPUTS_LBN + 1)
-#define	GPIO1_OUT_WIDTH 1
-#define	GPIO0_OUT_LBN (GPIO_OUTPUTS_LBN + 0)
-#define	GPIO0_OUT_WIDTH 1
-
-#define GPIO3_IN_LBN (GPIO_INPUTS_LBN + 3)
-#define	GPIO3_IN_WIDTH 1
-#define	GPIO2_IN_WIDTH 1
-#define	GPIO1_IN_WIDTH 1
-#define GPIO0_IN_LBN (GPIO_INPUTS_LBN + 0)
-#define	GPIO0_IN_WIDTH 1
-
-/* Global control register */
-#define GLB_CTL_REG_KER	0x0220
-#define EXT_PHY_RST_CTL_LBN 63
-#define EXT_PHY_RST_CTL_WIDTH 1
-#define PCIE_SD_RST_CTL_LBN 61
-#define PCIE_SD_RST_CTL_WIDTH 1
-
-#define PCIE_NSTCK_RST_CTL_LBN 58
-#define PCIE_NSTCK_RST_CTL_WIDTH 1
-#define PCIE_CORE_RST_CTL_LBN 57
-#define PCIE_CORE_RST_CTL_WIDTH 1
-#define EE_RST_CTL_LBN 49
-#define EE_RST_CTL_WIDTH 1
-#define RST_XGRX_LBN 24
-#define RST_XGRX_WIDTH 1
-#define RST_XGTX_LBN 23
-#define RST_XGTX_WIDTH 1
-#define RST_EM_LBN 22
-#define RST_EM_WIDTH 1
-#define EXT_PHY_RST_DUR_LBN 1
-#define EXT_PHY_RST_DUR_WIDTH 3
-#define SWRST_LBN 0
-#define SWRST_WIDTH 1
-#define INCLUDE_IN_RESET 0
-#define EXCLUDE_FROM_RESET 1
-
-/* Fatal interrupt register */
-#define FATAL_INTR_REG_KER 0x0230
-#define RBUF_OWN_INT_KER_EN_LBN 39
-#define RBUF_OWN_INT_KER_EN_WIDTH 1
-#define TBUF_OWN_INT_KER_EN_LBN 38
-#define TBUF_OWN_INT_KER_EN_WIDTH 1
-#define ILL_ADR_INT_KER_EN_LBN 33
-#define ILL_ADR_INT_KER_EN_WIDTH 1
-#define MEM_PERR_INT_KER_LBN 8
-#define MEM_PERR_INT_KER_WIDTH 1
-#define INT_KER_ERROR_LBN 0
-#define INT_KER_ERROR_WIDTH 12
-
-#define DP_CTRL_REG 0x250
-#define FLS_EVQ_ID_LBN 0
-#define FLS_EVQ_ID_WIDTH 11
-
-#define MEM_STAT_REG_KER 0x260
-
-/* Debug probe register */
-#define DEBUG_BLK_SEL_MISC 7
-#define DEBUG_BLK_SEL_SERDES 6
-#define DEBUG_BLK_SEL_EM 5
-#define DEBUG_BLK_SEL_SR 4
-#define DEBUG_BLK_SEL_EV 3
-#define DEBUG_BLK_SEL_RX 2
-#define DEBUG_BLK_SEL_TX 1
-#define DEBUG_BLK_SEL_BIU 0
-
-/* FPGA build version */
-#define ALTERA_BUILD_REG_KER 0x0300
-#define VER_ALL_LBN 0
-#define VER_ALL_WIDTH 32
-
-/* Spare EEPROM bits register (flash 0x390) */
-#define SPARE_REG_KER 0x310
-#define MEM_PERR_EN_TX_DATA_LBN 72
-#define MEM_PERR_EN_TX_DATA_WIDTH 2
-
-/* Timer table for kernel access */
-#define TIMER_CMD_REG_KER 0x420
-#define TIMER_MODE_LBN 12
-#define TIMER_MODE_WIDTH 2
-#define TIMER_MODE_DIS 0
-#define TIMER_MODE_INT_HLDOFF 2
-#define TIMER_VAL_LBN 0
-#define TIMER_VAL_WIDTH 12
-
-/* Driver generated event register */
-#define DRV_EV_REG_KER 0x440
-#define DRV_EV_QID_LBN 64
-#define DRV_EV_QID_WIDTH 12
-#define DRV_EV_DATA_LBN 0
-#define DRV_EV_DATA_WIDTH 64
-
-/* Buffer table configuration register */
-#define BUF_TBL_CFG_REG_KER 0x600
-#define BUF_TBL_MODE_LBN 3
-#define BUF_TBL_MODE_WIDTH 1
-#define BUF_TBL_MODE_HALF 0
-#define BUF_TBL_MODE_FULL 1
-
-/* SRAM receive descriptor cache configuration register */
-#define SRM_RX_DC_CFG_REG_KER 0x610
-#define SRM_RX_DC_BASE_ADR_LBN 0
-#define SRM_RX_DC_BASE_ADR_WIDTH 21
-
-/* SRAM transmit descriptor cache configuration register */
-#define SRM_TX_DC_CFG_REG_KER 0x620
-#define SRM_TX_DC_BASE_ADR_LBN 0
-#define SRM_TX_DC_BASE_ADR_WIDTH 21
-
-/* SRAM configuration register */
-#define SRM_CFG_REG_KER 0x630
-#define SRAM_OOB_BT_INIT_EN_LBN 3
-#define SRAM_OOB_BT_INIT_EN_WIDTH 1
-#define SRM_NUM_BANKS_AND_BANK_SIZE_LBN 0
-#define SRM_NUM_BANKS_AND_BANK_SIZE_WIDTH 3
-#define SRM_NB_BSZ_1BANKS_2M 0
-#define SRM_NB_BSZ_1BANKS_4M 1
-#define SRM_NB_BSZ_1BANKS_8M 2
-#define SRM_NB_BSZ_DEFAULT 3 /* char driver will set the default */
-#define SRM_NB_BSZ_2BANKS_4M 4
-#define SRM_NB_BSZ_2BANKS_8M 5
-#define SRM_NB_BSZ_2BANKS_16M 6
-#define SRM_NB_BSZ_RESERVED 7
-
-/* Special buffer table update register */
-#define BUF_TBL_UPD_REG_KER 0x0650
-#define BUF_UPD_CMD_LBN 63
-#define BUF_UPD_CMD_WIDTH 1
-#define BUF_CLR_CMD_LBN 62
-#define BUF_CLR_CMD_WIDTH 1
-#define BUF_CLR_END_ID_LBN 32
-#define BUF_CLR_END_ID_WIDTH 20
-#define BUF_CLR_START_ID_LBN 0
-#define BUF_CLR_START_ID_WIDTH 20
-
-/* Receive configuration register */
-#define RX_CFG_REG_KER 0x800
-
-/* B0 */
-#define RX_INGR_EN_B0_LBN 47
-#define RX_INGR_EN_B0_WIDTH 1
-#define RX_DESC_PUSH_EN_B0_LBN 43
-#define RX_DESC_PUSH_EN_B0_WIDTH 1
-#define RX_XON_TX_TH_B0_LBN 33
-#define RX_XON_TX_TH_B0_WIDTH 5
-#define RX_XOFF_TX_TH_B0_LBN 28
-#define RX_XOFF_TX_TH_B0_WIDTH 5
-#define RX_USR_BUF_SIZE_B0_LBN 19
-#define RX_USR_BUF_SIZE_B0_WIDTH 9
-#define RX_XON_MAC_TH_B0_LBN 10
-#define RX_XON_MAC_TH_B0_WIDTH 9
-#define RX_XOFF_MAC_TH_B0_LBN 1
-#define RX_XOFF_MAC_TH_B0_WIDTH 9
-
-/* A1 */
-#define RX_DESC_PUSH_EN_A1_LBN 35
-#define RX_DESC_PUSH_EN_A1_WIDTH 1
-#define RX_XON_TX_TH_A1_LBN 25
-#define RX_XON_TX_TH_A1_WIDTH 5
-#define RX_XOFF_TX_TH_A1_LBN 20
-#define RX_XOFF_TX_TH_A1_WIDTH 5
-#define RX_USR_BUF_SIZE_A1_LBN 11
-#define RX_USR_BUF_SIZE_A1_WIDTH 9
-#define RX_XON_MAC_TH_A1_LBN 6
-#define RX_XON_MAC_TH_A1_WIDTH 5
-#define RX_XOFF_MAC_TH_A1_LBN 1
-#define RX_XOFF_MAC_TH_A1_WIDTH 5
-
-#define RX_XOFF_MAC_EN_LBN 0
-#define RX_XOFF_MAC_EN_WIDTH 1
-
-/* Receive filter control register */
-#define RX_FILTER_CTL_REG 0x810
-#define UDP_FULL_SRCH_LIMIT_LBN 32
-#define UDP_FULL_SRCH_LIMIT_WIDTH 8
-#define NUM_KER_LBN 24
-#define NUM_KER_WIDTH 2
-#define UDP_WILD_SRCH_LIMIT_LBN 16
-#define UDP_WILD_SRCH_LIMIT_WIDTH 8
-#define TCP_WILD_SRCH_LIMIT_LBN 8
-#define TCP_WILD_SRCH_LIMIT_WIDTH 8
-#define TCP_FULL_SRCH_LIMIT_LBN 0
-#define TCP_FULL_SRCH_LIMIT_WIDTH 8
-
-/* RX queue flush register */
-#define RX_FLUSH_DESCQ_REG_KER 0x0820
-#define RX_FLUSH_DESCQ_CMD_LBN 24
-#define RX_FLUSH_DESCQ_CMD_WIDTH 1
-#define RX_FLUSH_DESCQ_LBN 0
-#define RX_FLUSH_DESCQ_WIDTH 12
-
-/* Receive descriptor update register */
-#define RX_DESC_UPD_REG_KER_DWORD (0x830 + 12)
-#define RX_DESC_WPTR_DWORD_LBN 0
-#define RX_DESC_WPTR_DWORD_WIDTH 12
-
-/* Receive descriptor cache configuration register */
-#define RX_DC_CFG_REG_KER 0x840
-#define RX_DC_SIZE_LBN 0
-#define RX_DC_SIZE_WIDTH 2
-
-#define RX_DC_PF_WM_REG_KER 0x850
-#define RX_DC_PF_LWM_LBN 0
-#define RX_DC_PF_LWM_WIDTH 6
-
-/* RX no descriptor drop counter */
-#define RX_NODESC_DROP_REG_KER 0x880
-#define RX_NODESC_DROP_CNT_LBN 0
-#define RX_NODESC_DROP_CNT_WIDTH 16
-
-/* RX black magic register */
-#define RX_SELF_RST_REG_KER 0x890
-#define RX_ISCSI_DIS_LBN 17
-#define RX_ISCSI_DIS_WIDTH 1
-#define RX_NODESC_WAIT_DIS_LBN 9
-#define RX_NODESC_WAIT_DIS_WIDTH 1
-#define RX_RECOVERY_EN_LBN 8
-#define RX_RECOVERY_EN_WIDTH 1
-
-/* TX queue flush register */
-#define TX_FLUSH_DESCQ_REG_KER 0x0a00
-#define TX_FLUSH_DESCQ_CMD_LBN 12
-#define TX_FLUSH_DESCQ_CMD_WIDTH 1
-#define TX_FLUSH_DESCQ_LBN 0
-#define TX_FLUSH_DESCQ_WIDTH 12
-
-/* Transmit descriptor update register */
-#define TX_DESC_UPD_REG_KER_DWORD (0xa10 + 12)
-#define TX_DESC_WPTR_DWORD_LBN 0
-#define TX_DESC_WPTR_DWORD_WIDTH 12
-
-/* Transmit descriptor cache configuration register */
-#define TX_DC_CFG_REG_KER 0xa20
-#define TX_DC_SIZE_LBN 0
-#define TX_DC_SIZE_WIDTH 2
-
-/* Transmit checksum configuration register (A0/A1 only) */
-#define TX_CHKSM_CFG_REG_KER_A1 0xa30
-
-/* Transmit configuration register */
-#define TX_CFG_REG_KER 0xa50
-#define TX_NO_EOP_DISC_EN_LBN 5
-#define TX_NO_EOP_DISC_EN_WIDTH 1
-
-/* Transmit configuration register 2 */
-#define TX_CFG2_REG_KER 0xa80
-#define TX_CSR_PUSH_EN_LBN 89
-#define TX_CSR_PUSH_EN_WIDTH 1
-#define TX_RX_SPACER_LBN 64
-#define TX_RX_SPACER_WIDTH 8
-#define TX_SW_EV_EN_LBN 59
-#define TX_SW_EV_EN_WIDTH 1
-#define TX_RX_SPACER_EN_LBN 57
-#define TX_RX_SPACER_EN_WIDTH 1
-#define TX_PREF_THRESHOLD_LBN 19
-#define TX_PREF_THRESHOLD_WIDTH 2
-#define TX_ONE_PKT_PER_Q_LBN 18
-#define TX_ONE_PKT_PER_Q_WIDTH 1
-#define TX_DIS_NON_IP_EV_LBN 17
-#define TX_DIS_NON_IP_EV_WIDTH 1
-#define TX_FLUSH_MIN_LEN_EN_B0_LBN 7
-#define TX_FLUSH_MIN_LEN_EN_B0_WIDTH 1
-
-/* PHY management transmit data register */
-#define MD_TXD_REG_KER 0xc00
-#define MD_TXD_LBN 0
-#define MD_TXD_WIDTH 16
-
-/* PHY management receive data register */
-#define MD_RXD_REG_KER 0xc10
-#define MD_RXD_LBN 0
-#define MD_RXD_WIDTH 16
-
-/* PHY management configuration & status register */
-#define MD_CS_REG_KER 0xc20
-#define MD_GC_LBN 4
-#define MD_GC_WIDTH 1
-#define MD_RIC_LBN 2
-#define MD_RIC_WIDTH 1
-#define MD_RDC_LBN 1
-#define MD_RDC_WIDTH 1
-#define MD_WRC_LBN 0
-#define MD_WRC_WIDTH 1
-
-/* PHY management PHY address register */
-#define MD_PHY_ADR_REG_KER 0xc30
-#define MD_PHY_ADR_LBN 0
-#define MD_PHY_ADR_WIDTH 16
-
-/* PHY management ID register */
-#define MD_ID_REG_KER 0xc40
-#define MD_PRT_ADR_LBN 11
-#define MD_PRT_ADR_WIDTH 5
-#define MD_DEV_ADR_LBN 6
-#define MD_DEV_ADR_WIDTH 5
-
-/* PHY management status & mask register (DWORD read only) */
-#define MD_STAT_REG_KER 0xc50
-#define MD_BSERR_LBN 2
-#define MD_BSERR_WIDTH 1
-#define MD_LNFL_LBN 1
-#define MD_LNFL_WIDTH 1
-#define MD_BSY_LBN 0
-#define MD_BSY_WIDTH 1
-
-/* Port 0 and 1 MAC stats registers */
-#define MAC0_STAT_DMA_REG_KER 0xc60
-#define MAC_STAT_DMA_CMD_LBN 48
-#define MAC_STAT_DMA_CMD_WIDTH 1
-#define MAC_STAT_DMA_ADR_LBN 0
-#define MAC_STAT_DMA_ADR_WIDTH EFX_DMA_TYPE_WIDTH(46)
-
-/* Port 0 and 1 MAC control registers */
-#define MAC0_CTRL_REG_KER 0xc80
-#define MAC_XOFF_VAL_LBN 16
-#define MAC_XOFF_VAL_WIDTH 16
-#define TXFIFO_DRAIN_EN_B0_LBN 7
-#define TXFIFO_DRAIN_EN_B0_WIDTH 1
-#define MAC_BCAD_ACPT_LBN 4
-#define MAC_BCAD_ACPT_WIDTH 1
-#define MAC_UC_PROM_LBN 3
-#define MAC_UC_PROM_WIDTH 1
-#define MAC_LINK_STATUS_LBN 2
-#define MAC_LINK_STATUS_WIDTH 1
-#define MAC_SPEED_LBN 0
-#define MAC_SPEED_WIDTH 2
-
-/* 10G XAUI XGXS default values */
-#define XX_TXDRV_DEQ_DEFAULT 0xe /* deq=.6 */
-#define XX_TXDRV_DTX_DEFAULT 0x5 /* 1.25 */
-#define XX_SD_CTL_DRV_DEFAULT 0  /* 20mA */
-
-/* Multicast address hash table */
-#define MAC_MCAST_HASH_REG0_KER 0xca0
-#define MAC_MCAST_HASH_REG1_KER 0xcb0
-
-/* GMAC configuration register 1 */
-#define GM_CFG1_REG 0xe00
-#define GM_SW_RST_LBN 31
-#define GM_SW_RST_WIDTH 1
-#define GM_LOOP_LBN 8
-#define GM_LOOP_WIDTH 1
-#define GM_RX_FC_EN_LBN 5
-#define GM_RX_FC_EN_WIDTH 1
-#define GM_TX_FC_EN_LBN 4
-#define GM_TX_FC_EN_WIDTH 1
-#define GM_RX_EN_LBN 2
-#define GM_RX_EN_WIDTH 1
-#define GM_TX_EN_LBN 0
-#define GM_TX_EN_WIDTH 1
-
-/* GMAC configuration register 2 */
-#define GM_CFG2_REG 0xe10
-#define GM_PAMBL_LEN_LBN 12
-#define GM_PAMBL_LEN_WIDTH 4
-#define GM_IF_MODE_LBN 8
-#define GM_IF_MODE_WIDTH 2
-#define GM_LEN_CHK_LBN 4
-#define GM_LEN_CHK_WIDTH 1
-#define GM_PAD_CRC_EN_LBN 2
-#define GM_PAD_CRC_EN_WIDTH 1
-#define GM_FD_LBN 0
-#define GM_FD_WIDTH 1
-
-/* GMAC maximum frame length register */
-#define GM_MAX_FLEN_REG 0xe40
-#define GM_MAX_FLEN_LBN 0
-#define GM_MAX_FLEN_WIDTH 16
-
-/* GMAC station address register 1 */
-#define GM_ADR1_REG 0xf00
-#define GM_HWADDR_5_LBN 24
-#define GM_HWADDR_5_WIDTH 8
-#define GM_HWADDR_4_LBN 16
-#define GM_HWADDR_4_WIDTH 8
-#define GM_HWADDR_3_LBN 8
-#define GM_HWADDR_3_WIDTH 8
-#define GM_HWADDR_2_LBN 0
-#define GM_HWADDR_2_WIDTH 8
-
-/* GMAC station address register 2 */
-#define GM_ADR2_REG 0xf10
-#define GM_HWADDR_1_LBN 24
-#define GM_HWADDR_1_WIDTH 8
-#define GM_HWADDR_0_LBN 16
-#define GM_HWADDR_0_WIDTH 8
-
-/* GMAC FIFO configuration register 0 */
-#define GMF_CFG0_REG 0xf20
-#define GMF_FTFENREQ_LBN 12
-#define GMF_FTFENREQ_WIDTH 1
-#define GMF_STFENREQ_LBN 11
-#define GMF_STFENREQ_WIDTH 1
-#define GMF_FRFENREQ_LBN 10
-#define GMF_FRFENREQ_WIDTH 1
-#define GMF_SRFENREQ_LBN 9
-#define GMF_SRFENREQ_WIDTH 1
-#define GMF_WTMENREQ_LBN 8
-#define GMF_WTMENREQ_WIDTH 1
-
-/* GMAC FIFO configuration register 1 */
-#define GMF_CFG1_REG 0xf30
-#define GMF_CFGFRTH_LBN 16
-#define GMF_CFGFRTH_WIDTH 5
-#define GMF_CFGXOFFRTX_LBN 0
-#define GMF_CFGXOFFRTX_WIDTH 16
-
-/* GMAC FIFO configuration register 2 */
-#define GMF_CFG2_REG 0xf40
-#define GMF_CFGHWM_LBN 16
-#define GMF_CFGHWM_WIDTH 6
-#define GMF_CFGLWM_LBN 0
-#define GMF_CFGLWM_WIDTH 6
-
-/* GMAC FIFO configuration register 3 */
-#define GMF_CFG3_REG 0xf50
-#define GMF_CFGHWMFT_LBN 16
-#define GMF_CFGHWMFT_WIDTH 6
-#define GMF_CFGFTTH_LBN 0
-#define GMF_CFGFTTH_WIDTH 6
-
-/* GMAC FIFO configuration register 4 */
-#define GMF_CFG4_REG 0xf60
-#define GMF_HSTFLTRFRM_PAUSE_LBN 12
-#define GMF_HSTFLTRFRM_PAUSE_WIDTH 12
-
-/* GMAC FIFO configuration register 5 */
-#define GMF_CFG5_REG 0xf70
-#define GMF_CFGHDPLX_LBN 22
-#define GMF_CFGHDPLX_WIDTH 1
-#define GMF_CFGBYTMODE_LBN 19
-#define GMF_CFGBYTMODE_WIDTH 1
-#define GMF_HSTDRPLT64_LBN 18
-#define GMF_HSTDRPLT64_WIDTH 1
-#define GMF_HSTFLTRFRMDC_PAUSE_LBN 12
-#define GMF_HSTFLTRFRMDC_PAUSE_WIDTH 1
-
-/* XGMAC address register low */
-#define XM_ADR_LO_REG 0x1200
-#define XM_ADR_3_LBN 24
-#define XM_ADR_3_WIDTH 8
-#define XM_ADR_2_LBN 16
-#define XM_ADR_2_WIDTH 8
-#define XM_ADR_1_LBN 8
-#define XM_ADR_1_WIDTH 8
-#define XM_ADR_0_LBN 0
-#define XM_ADR_0_WIDTH 8
-
-/* XGMAC address register high */
-#define XM_ADR_HI_REG 0x1210
-#define XM_ADR_5_LBN 8
-#define XM_ADR_5_WIDTH 8
-#define XM_ADR_4_LBN 0
-#define XM_ADR_4_WIDTH 8
-
-/* XGMAC global configuration */
-#define XM_GLB_CFG_REG 0x1220
-#define XM_RX_STAT_EN_LBN 11
-#define XM_RX_STAT_EN_WIDTH 1
-#define XM_TX_STAT_EN_LBN 10
-#define XM_TX_STAT_EN_WIDTH 1
-#define XM_RX_JUMBO_MODE_LBN 6
-#define XM_RX_JUMBO_MODE_WIDTH 1
-#define XM_INTCLR_MODE_LBN 3
-#define XM_INTCLR_MODE_WIDTH 1
-#define XM_CORE_RST_LBN 0
-#define XM_CORE_RST_WIDTH 1
-
-/* XGMAC transmit configuration */
-#define XM_TX_CFG_REG 0x1230
-#define XM_IPG_LBN 16
-#define XM_IPG_WIDTH 4
-#define XM_FCNTL_LBN 10
-#define XM_FCNTL_WIDTH 1
-#define XM_TXCRC_LBN 8
-#define XM_TXCRC_WIDTH 1
-#define XM_AUTO_PAD_LBN 5
-#define XM_AUTO_PAD_WIDTH 1
-#define XM_TX_PRMBL_LBN 2
-#define XM_TX_PRMBL_WIDTH 1
-#define XM_TXEN_LBN 1
-#define XM_TXEN_WIDTH 1
-
-/* XGMAC receive configuration */
-#define XM_RX_CFG_REG 0x1240
-#define XM_PASS_CRC_ERR_LBN 25
-#define XM_PASS_CRC_ERR_WIDTH 1
-#define XM_ACPT_ALL_MCAST_LBN 11
-#define XM_ACPT_ALL_MCAST_WIDTH 1
-#define XM_ACPT_ALL_UCAST_LBN 9
-#define XM_ACPT_ALL_UCAST_WIDTH 1
-#define XM_AUTO_DEPAD_LBN 8
-#define XM_AUTO_DEPAD_WIDTH 1
-#define XM_RXEN_LBN 1
-#define XM_RXEN_WIDTH 1
-
-/* XGMAC management interrupt mask register */
-#define XM_MGT_INT_MSK_REG_B0 0x1250
-#define XM_MSK_PRMBLE_ERR_LBN 2
-#define XM_MSK_PRMBLE_ERR_WIDTH 1
-#define XM_MSK_RMTFLT_LBN 1
-#define XM_MSK_RMTFLT_WIDTH 1
-#define XM_MSK_LCLFLT_LBN 0
-#define XM_MSK_LCLFLT_WIDTH 1
-
-/* XGMAC flow control register */
-#define XM_FC_REG 0x1270
-#define XM_PAUSE_TIME_LBN 16
-#define XM_PAUSE_TIME_WIDTH 16
-#define XM_DIS_FCNTL_LBN 0
-#define XM_DIS_FCNTL_WIDTH 1
-
-/* XGMAC pause time count register */
-#define XM_PAUSE_TIME_REG 0x1290
-
-/* XGMAC transmit parameter register */
-#define XM_TX_PARAM_REG 0x012d0
-#define XM_TX_JUMBO_MODE_LBN 31
-#define XM_TX_JUMBO_MODE_WIDTH 1
-#define XM_MAX_TX_FRM_SIZE_LBN 16
-#define XM_MAX_TX_FRM_SIZE_WIDTH 14
-
-/* XGMAC receive parameter register */
-#define XM_RX_PARAM_REG 0x12e0
-#define XM_MAX_RX_FRM_SIZE_LBN 0
-#define XM_MAX_RX_FRM_SIZE_WIDTH 14
-
-/* XGMAC management interrupt status register */
-#define XM_MGT_INT_REG_B0 0x12f0
-#define XM_PRMBLE_ERR 2
-#define XM_PRMBLE_WIDTH 1
-#define XM_RMTFLT_LBN 1
-#define XM_RMTFLT_WIDTH 1
-#define XM_LCLFLT_LBN 0
-#define XM_LCLFLT_WIDTH 1
-
-/* XGXS/XAUI powerdown/reset register */
-#define XX_PWR_RST_REG 0x1300
-
-#define XX_SD_RST_ACT_LBN 16
-#define XX_SD_RST_ACT_WIDTH 1
-#define XX_PWRDND_EN_LBN 15
-#define XX_PWRDND_EN_WIDTH 1
-#define XX_PWRDNC_EN_LBN 14
-#define XX_PWRDNC_EN_WIDTH 1
-#define XX_PWRDNB_EN_LBN 13
-#define XX_PWRDNB_EN_WIDTH 1
-#define XX_PWRDNA_EN_LBN 12
-#define XX_PWRDNA_EN_WIDTH 1
-#define XX_RSTPLLCD_EN_LBN 9
-#define XX_RSTPLLCD_EN_WIDTH 1
-#define XX_RSTPLLAB_EN_LBN 8
-#define XX_RSTPLLAB_EN_WIDTH 1
-#define XX_RESETD_EN_LBN 7
-#define XX_RESETD_EN_WIDTH 1
-#define XX_RESETC_EN_LBN 6
-#define XX_RESETC_EN_WIDTH 1
-#define XX_RESETB_EN_LBN 5
-#define XX_RESETB_EN_WIDTH 1
-#define XX_RESETA_EN_LBN 4
-#define XX_RESETA_EN_WIDTH 1
-#define XX_RSTXGXSRX_EN_LBN 2
-#define XX_RSTXGXSRX_EN_WIDTH 1
-#define XX_RSTXGXSTX_EN_LBN 1
-#define XX_RSTXGXSTX_EN_WIDTH 1
-#define XX_RST_XX_EN_LBN 0
-#define XX_RST_XX_EN_WIDTH 1
-
-/* XGXS/XAUI powerdown/reset control register */
-#define XX_SD_CTL_REG 0x1310
-#define XX_HIDRVD_LBN 15
-#define XX_HIDRVD_WIDTH 1
-#define XX_LODRVD_LBN 14
-#define XX_LODRVD_WIDTH 1
-#define XX_HIDRVC_LBN 13
-#define XX_HIDRVC_WIDTH 1
-#define XX_LODRVC_LBN 12
-#define XX_LODRVC_WIDTH 1
-#define XX_HIDRVB_LBN 11
-#define XX_HIDRVB_WIDTH 1
-#define XX_LODRVB_LBN 10
-#define XX_LODRVB_WIDTH 1
-#define XX_HIDRVA_LBN 9
-#define XX_HIDRVA_WIDTH 1
-#define XX_LODRVA_LBN 8
-#define XX_LODRVA_WIDTH 1
-#define XX_LPBKD_LBN 3
-#define XX_LPBKD_WIDTH 1
-#define XX_LPBKC_LBN 2
-#define XX_LPBKC_WIDTH 1
-#define XX_LPBKB_LBN 1
-#define XX_LPBKB_WIDTH 1
-#define XX_LPBKA_LBN 0
-#define XX_LPBKA_WIDTH 1
-
-#define XX_TXDRV_CTL_REG 0x1320
-#define XX_DEQD_LBN 28
-#define XX_DEQD_WIDTH 4
-#define XX_DEQC_LBN 24
-#define XX_DEQC_WIDTH 4
-#define XX_DEQB_LBN 20
-#define XX_DEQB_WIDTH 4
-#define XX_DEQA_LBN 16
-#define XX_DEQA_WIDTH 4
-#define XX_DTXD_LBN 12
-#define XX_DTXD_WIDTH 4
-#define XX_DTXC_LBN 8
-#define XX_DTXC_WIDTH 4
-#define XX_DTXB_LBN 4
-#define XX_DTXB_WIDTH 4
-#define XX_DTXA_LBN 0
-#define XX_DTXA_WIDTH 4
-
-/* XAUI XGXS core status register */
-#define XX_CORE_STAT_REG 0x1360
-#define XX_FORCE_SIG_LBN 24
-#define XX_FORCE_SIG_WIDTH 8
-#define XX_FORCE_SIG_DECODE_FORCED 0xff
-#define XX_XGXS_LB_EN_LBN 23
-#define XX_XGXS_LB_EN_WIDTH 1
-#define XX_XGMII_LB_EN_LBN 22
-#define XX_XGMII_LB_EN_WIDTH 1
-#define XX_ALIGN_DONE_LBN 20
-#define XX_ALIGN_DONE_WIDTH 1
-#define XX_SYNC_STAT_LBN 16
-#define XX_SYNC_STAT_WIDTH 4
-#define XX_SYNC_STAT_DECODE_SYNCED 0xf
-#define XX_COMMA_DET_LBN 12
-#define XX_COMMA_DET_WIDTH 4
-#define XX_COMMA_DET_DECODE_DETECTED 0xf
-#define XX_COMMA_DET_RESET 0xf
-#define XX_CHARERR_LBN 4
-#define XX_CHARERR_WIDTH 4
-#define XX_CHARERR_RESET 0xf
-#define XX_DISPERR_LBN 0
-#define XX_DISPERR_WIDTH 4
-#define XX_DISPERR_RESET 0xf
-
-/* Receive filter table */
-#define RX_FILTER_TBL0 0xF00000
-
-/* Receive descriptor pointer table */
-#define RX_DESC_PTR_TBL_KER_A1 0x11800
-#define RX_DESC_PTR_TBL_KER_B0 0xF40000
-#define RX_DESC_PTR_TBL_KER_P0 0x900
-#define RX_ISCSI_DDIG_EN_LBN 88
-#define RX_ISCSI_DDIG_EN_WIDTH 1
-#define RX_ISCSI_HDIG_EN_LBN 87
-#define RX_ISCSI_HDIG_EN_WIDTH 1
-#define RX_DESCQ_BUF_BASE_ID_LBN 36
-#define RX_DESCQ_BUF_BASE_ID_WIDTH 20
-#define RX_DESCQ_EVQ_ID_LBN 24
-#define RX_DESCQ_EVQ_ID_WIDTH 12
-#define RX_DESCQ_OWNER_ID_LBN 10
-#define RX_DESCQ_OWNER_ID_WIDTH 14
-#define RX_DESCQ_LABEL_LBN 5
-#define RX_DESCQ_LABEL_WIDTH 5
-#define RX_DESCQ_SIZE_LBN 3
-#define RX_DESCQ_SIZE_WIDTH 2
-#define RX_DESCQ_SIZE_4K 3
-#define RX_DESCQ_SIZE_2K 2
-#define RX_DESCQ_SIZE_1K 1
-#define RX_DESCQ_SIZE_512 0
-#define RX_DESCQ_TYPE_LBN 2
-#define RX_DESCQ_TYPE_WIDTH 1
-#define RX_DESCQ_JUMBO_LBN 1
-#define RX_DESCQ_JUMBO_WIDTH 1
-#define RX_DESCQ_EN_LBN 0
-#define RX_DESCQ_EN_WIDTH 1
-
-/* Transmit descriptor pointer table */
-#define TX_DESC_PTR_TBL_KER_A1 0x11900
-#define TX_DESC_PTR_TBL_KER_B0 0xF50000
-#define TX_DESC_PTR_TBL_KER_P0 0xa40
-#define TX_NON_IP_DROP_DIS_B0_LBN 91
-#define TX_NON_IP_DROP_DIS_B0_WIDTH 1
-#define TX_IP_CHKSM_DIS_B0_LBN 90
-#define TX_IP_CHKSM_DIS_B0_WIDTH 1
-#define TX_TCP_CHKSM_DIS_B0_LBN 89
-#define TX_TCP_CHKSM_DIS_B0_WIDTH 1
-#define TX_DESCQ_EN_LBN 88
-#define TX_DESCQ_EN_WIDTH 1
-#define TX_ISCSI_DDIG_EN_LBN 87
-#define TX_ISCSI_DDIG_EN_WIDTH 1
-#define TX_ISCSI_HDIG_EN_LBN 86
-#define TX_ISCSI_HDIG_EN_WIDTH 1
-#define TX_DESCQ_BUF_BASE_ID_LBN 36
-#define TX_DESCQ_BUF_BASE_ID_WIDTH 20
-#define TX_DESCQ_EVQ_ID_LBN 24
-#define TX_DESCQ_EVQ_ID_WIDTH 12
-#define TX_DESCQ_OWNER_ID_LBN 10
-#define TX_DESCQ_OWNER_ID_WIDTH 14
-#define TX_DESCQ_LABEL_LBN 5
-#define TX_DESCQ_LABEL_WIDTH 5
-#define TX_DESCQ_SIZE_LBN 3
-#define TX_DESCQ_SIZE_WIDTH 2
-#define TX_DESCQ_SIZE_4K 3
-#define TX_DESCQ_SIZE_2K 2
-#define TX_DESCQ_SIZE_1K 1
-#define TX_DESCQ_SIZE_512 0
-#define TX_DESCQ_TYPE_LBN 1
-#define TX_DESCQ_TYPE_WIDTH 2
-
-/* Event queue pointer */
-#define EVQ_PTR_TBL_KER_A1 0x11a00
-#define EVQ_PTR_TBL_KER_B0 0xf60000
-#define EVQ_PTR_TBL_KER_P0 0x500
-#define EVQ_EN_LBN 23
-#define EVQ_EN_WIDTH 1
-#define EVQ_SIZE_LBN 20
-#define EVQ_SIZE_WIDTH 3
-#define EVQ_SIZE_32K 6
-#define EVQ_SIZE_16K 5
-#define EVQ_SIZE_8K 4
-#define EVQ_SIZE_4K 3
-#define EVQ_SIZE_2K 2
-#define EVQ_SIZE_1K 1
-#define EVQ_SIZE_512 0
-#define EVQ_BUF_BASE_ID_LBN 0
-#define EVQ_BUF_BASE_ID_WIDTH 20
-
-/* Event queue read pointer */
-#define EVQ_RPTR_REG_KER_A1 0x11b00
-#define EVQ_RPTR_REG_KER_B0 0xfa0000
-#define EVQ_RPTR_REG_KER_DWORD (EVQ_RPTR_REG_KER + 0)
-#define EVQ_RPTR_DWORD_LBN 0
-#define EVQ_RPTR_DWORD_WIDTH 14
-
-/* RSS indirection table */
-#define RX_RSS_INDIR_TBL_B0 0xFB0000
-#define RX_RSS_INDIR_ENT_B0_LBN 0
-#define RX_RSS_INDIR_ENT_B0_WIDTH 6
-
-/* Special buffer descriptors (full-mode) */
-#define BUF_FULL_TBL_KER_A1 0x8000
-#define BUF_FULL_TBL_KER_B0 0x800000
-#define IP_DAT_BUF_SIZE_LBN 50
-#define IP_DAT_BUF_SIZE_WIDTH 1
-#define IP_DAT_BUF_SIZE_8K 1
-#define IP_DAT_BUF_SIZE_4K 0
-#define BUF_ADR_REGION_LBN 48
-#define BUF_ADR_REGION_WIDTH 2
-#define BUF_ADR_FBUF_LBN 14
-#define BUF_ADR_FBUF_WIDTH 34
-#define BUF_OWNER_ID_FBUF_LBN 0
-#define BUF_OWNER_ID_FBUF_WIDTH 14
-
-/* Transmit descriptor */
-#define TX_KER_PORT_LBN 63
-#define TX_KER_PORT_WIDTH 1
-#define TX_KER_CONT_LBN 62
-#define TX_KER_CONT_WIDTH 1
-#define TX_KER_BYTE_CNT_LBN 48
-#define TX_KER_BYTE_CNT_WIDTH 14
-#define TX_KER_BUF_REGION_LBN 46
-#define TX_KER_BUF_REGION_WIDTH 2
-#define TX_KER_BUF_REGION0_DECODE 0
-#define TX_KER_BUF_REGION1_DECODE 1
-#define TX_KER_BUF_REGION2_DECODE 2
-#define TX_KER_BUF_REGION3_DECODE 3
-#define TX_KER_BUF_ADR_LBN 0
-#define TX_KER_BUF_ADR_WIDTH EFX_DMA_TYPE_WIDTH(46)
-
-/* Receive descriptor */
-#define RX_KER_BUF_SIZE_LBN 48
-#define RX_KER_BUF_SIZE_WIDTH 14
-#define RX_KER_BUF_REGION_LBN 46
-#define RX_KER_BUF_REGION_WIDTH 2
-#define RX_KER_BUF_REGION0_DECODE 0
-#define RX_KER_BUF_REGION1_DECODE 1
-#define RX_KER_BUF_REGION2_DECODE 2
-#define RX_KER_BUF_REGION3_DECODE 3
-#define RX_KER_BUF_ADR_LBN 0
-#define RX_KER_BUF_ADR_WIDTH EFX_DMA_TYPE_WIDTH(46)
-
-/**************************************************************************
- *
- * Falcon events
- *
- **************************************************************************
- */
-
-/* Event queue entries */
-#define EV_CODE_LBN 60
-#define EV_CODE_WIDTH 4
-#define RX_IP_EV_DECODE 0
-#define TX_IP_EV_DECODE 2
-#define DRIVER_EV_DECODE 5
-#define GLOBAL_EV_DECODE 6
-#define DRV_GEN_EV_DECODE 7
-#define WHOLE_EVENT_LBN 0
-#define WHOLE_EVENT_WIDTH 64
-
-/* Receive events */
-#define RX_EV_PKT_OK_LBN 56
-#define RX_EV_PKT_OK_WIDTH 1
-#define RX_EV_PAUSE_FRM_ERR_LBN 55
-#define RX_EV_PAUSE_FRM_ERR_WIDTH 1
-#define RX_EV_BUF_OWNER_ID_ERR_LBN 54
-#define RX_EV_BUF_OWNER_ID_ERR_WIDTH 1
-#define RX_EV_IF_FRAG_ERR_LBN 53
-#define RX_EV_IF_FRAG_ERR_WIDTH 1
-#define RX_EV_IP_HDR_CHKSUM_ERR_LBN 52
-#define RX_EV_IP_HDR_CHKSUM_ERR_WIDTH 1
-#define RX_EV_TCP_UDP_CHKSUM_ERR_LBN 51
-#define RX_EV_TCP_UDP_CHKSUM_ERR_WIDTH 1
-#define RX_EV_ETH_CRC_ERR_LBN 50
-#define RX_EV_ETH_CRC_ERR_WIDTH 1
-#define RX_EV_FRM_TRUNC_LBN 49
-#define RX_EV_FRM_TRUNC_WIDTH 1
-#define RX_EV_DRIB_NIB_LBN 48
-#define RX_EV_DRIB_NIB_WIDTH 1
-#define RX_EV_TOBE_DISC_LBN 47
-#define RX_EV_TOBE_DISC_WIDTH 1
-#define RX_EV_PKT_TYPE_LBN 44
-#define RX_EV_PKT_TYPE_WIDTH 3
-#define RX_EV_PKT_TYPE_ETH_DECODE 0
-#define RX_EV_PKT_TYPE_LLC_DECODE 1
-#define RX_EV_PKT_TYPE_JUMBO_DECODE 2
-#define RX_EV_PKT_TYPE_VLAN_DECODE 3
-#define RX_EV_PKT_TYPE_VLAN_LLC_DECODE 4
-#define RX_EV_PKT_TYPE_VLAN_JUMBO_DECODE 5
-#define RX_EV_HDR_TYPE_LBN 42
-#define RX_EV_HDR_TYPE_WIDTH 2
-#define RX_EV_HDR_TYPE_TCP_IPV4_DECODE 0
-#define RX_EV_HDR_TYPE_UDP_IPV4_DECODE 1
-#define RX_EV_HDR_TYPE_OTHER_IP_DECODE 2
-#define RX_EV_HDR_TYPE_NON_IP_DECODE 3
-#define RX_EV_HDR_TYPE_HAS_CHECKSUMS(hdr_type) \
-	((hdr_type) <= RX_EV_HDR_TYPE_UDP_IPV4_DECODE)
-#define RX_EV_MCAST_HASH_MATCH_LBN 40
-#define RX_EV_MCAST_HASH_MATCH_WIDTH 1
-#define RX_EV_MCAST_PKT_LBN 39
-#define RX_EV_MCAST_PKT_WIDTH 1
-#define RX_EV_Q_LABEL_LBN 32
-#define RX_EV_Q_LABEL_WIDTH 5
-#define RX_EV_JUMBO_CONT_LBN 31
-#define RX_EV_JUMBO_CONT_WIDTH 1
-#define RX_EV_BYTE_CNT_LBN 16
-#define RX_EV_BYTE_CNT_WIDTH 14
-#define RX_EV_SOP_LBN 15
-#define RX_EV_SOP_WIDTH 1
-#define RX_EV_DESC_PTR_LBN 0
-#define RX_EV_DESC_PTR_WIDTH 12
-
-/* Transmit events */
-#define TX_EV_PKT_ERR_LBN 38
-#define TX_EV_PKT_ERR_WIDTH 1
-#define TX_EV_Q_LABEL_LBN 32
-#define TX_EV_Q_LABEL_WIDTH 5
-#define TX_EV_WQ_FF_FULL_LBN 15
-#define TX_EV_WQ_FF_FULL_WIDTH 1
-#define TX_EV_COMP_LBN 12
-#define TX_EV_COMP_WIDTH 1
-#define TX_EV_DESC_PTR_LBN 0
-#define TX_EV_DESC_PTR_WIDTH 12
-
-/* Driver events */
-#define DRIVER_EV_SUB_CODE_LBN 56
-#define DRIVER_EV_SUB_CODE_WIDTH 4
-#define DRIVER_EV_SUB_DATA_LBN 0
-#define DRIVER_EV_SUB_DATA_WIDTH 14
-#define TX_DESCQ_FLS_DONE_EV_DECODE 0
-#define RX_DESCQ_FLS_DONE_EV_DECODE 1
-#define EVQ_INIT_DONE_EV_DECODE 2
-#define EVQ_NOT_EN_EV_DECODE 3
-#define RX_DESCQ_FLSFF_OVFL_EV_DECODE 4
-#define SRM_UPD_DONE_EV_DECODE 5
-#define WAKE_UP_EV_DECODE 6
-#define TX_PKT_NON_TCP_UDP_DECODE 9
-#define TIMER_EV_DECODE 10
-#define RX_RECOVERY_EV_DECODE 11
-#define RX_DSC_ERROR_EV_DECODE 14
-#define TX_DSC_ERROR_EV_DECODE 15
-#define DRIVER_EV_TX_DESCQ_ID_LBN 0
-#define DRIVER_EV_TX_DESCQ_ID_WIDTH 12
-#define DRIVER_EV_RX_FLUSH_FAIL_LBN 12
-#define DRIVER_EV_RX_FLUSH_FAIL_WIDTH 1
-#define DRIVER_EV_RX_DESCQ_ID_LBN 0
-#define DRIVER_EV_RX_DESCQ_ID_WIDTH 12
-#define SRM_CLR_EV_DECODE 0
-#define SRM_UPD_EV_DECODE 1
-#define SRM_ILLCLR_EV_DECODE 2
-
-/* Global events */
-#define RX_RECOVERY_B0_LBN 12
-#define RX_RECOVERY_B0_WIDTH 1
-#define XG_MNT_INTR_B0_LBN 11
-#define XG_MNT_INTR_B0_WIDTH 1
-#define RX_RECOVERY_A1_LBN 11
-#define RX_RECOVERY_A1_WIDTH 1
-#define XFP_PHY_INTR_LBN 10
-#define XFP_PHY_INTR_WIDTH 1
-#define XG_PHY_INTR_LBN 9
-#define XG_PHY_INTR_WIDTH 1
-#define G_PHY1_INTR_LBN 8
-#define G_PHY1_INTR_WIDTH 1
-#define G_PHY0_INTR_LBN 7
-#define G_PHY0_INTR_WIDTH 1
-
-/* Driver-generated test events */
-#define EVQ_MAGIC_LBN 0
-#define EVQ_MAGIC_WIDTH 32
-
-/**************************************************************************
- *
- * Falcon MAC stats
- *
- **************************************************************************
- *
- */
-
-#define GRxGoodOct_offset 0x0
-#define GRxGoodOct_WIDTH 48
-#define GRxBadOct_offset 0x8
-#define GRxBadOct_WIDTH 48
-#define GRxMissPkt_offset 0x10
-#define GRxMissPkt_WIDTH 32
-#define GRxFalseCRS_offset 0x14
-#define GRxFalseCRS_WIDTH 32
-#define GRxPausePkt_offset 0x18
-#define GRxPausePkt_WIDTH 32
-#define GRxBadPkt_offset 0x1C
-#define GRxBadPkt_WIDTH 32
-#define GRxUcastPkt_offset 0x20
-#define GRxUcastPkt_WIDTH 32
-#define GRxMcastPkt_offset 0x24
-#define GRxMcastPkt_WIDTH 32
-#define GRxBcastPkt_offset 0x28
-#define GRxBcastPkt_WIDTH 32
-#define GRxGoodLt64Pkt_offset 0x2C
-#define GRxGoodLt64Pkt_WIDTH 32
-#define GRxBadLt64Pkt_offset 0x30
-#define GRxBadLt64Pkt_WIDTH 32
-#define GRx64Pkt_offset 0x34
-#define GRx64Pkt_WIDTH 32
-#define GRx65to127Pkt_offset 0x38
-#define GRx65to127Pkt_WIDTH 32
-#define GRx128to255Pkt_offset 0x3C
-#define GRx128to255Pkt_WIDTH 32
-#define GRx256to511Pkt_offset 0x40
-#define GRx256to511Pkt_WIDTH 32
-#define GRx512to1023Pkt_offset 0x44
-#define GRx512to1023Pkt_WIDTH 32
-#define GRx1024to15xxPkt_offset 0x48
-#define GRx1024to15xxPkt_WIDTH 32
-#define GRx15xxtoJumboPkt_offset 0x4C
-#define GRx15xxtoJumboPkt_WIDTH 32
-#define GRxGtJumboPkt_offset 0x50
-#define GRxGtJumboPkt_WIDTH 32
-#define GRxFcsErr64to15xxPkt_offset 0x54
-#define GRxFcsErr64to15xxPkt_WIDTH 32
-#define GRxFcsErr15xxtoJumboPkt_offset 0x58
-#define GRxFcsErr15xxtoJumboPkt_WIDTH 32
-#define GRxFcsErrGtJumboPkt_offset 0x5C
-#define GRxFcsErrGtJumboPkt_WIDTH 32
-#define GTxGoodBadOct_offset 0x80
-#define GTxGoodBadOct_WIDTH 48
-#define GTxGoodOct_offset 0x88
-#define GTxGoodOct_WIDTH 48
-#define GTxSglColPkt_offset 0x90
-#define GTxSglColPkt_WIDTH 32
-#define GTxMultColPkt_offset 0x94
-#define GTxMultColPkt_WIDTH 32
-#define GTxExColPkt_offset 0x98
-#define GTxExColPkt_WIDTH 32
-#define GTxDefPkt_offset 0x9C
-#define GTxDefPkt_WIDTH 32
-#define GTxLateCol_offset 0xA0
-#define GTxLateCol_WIDTH 32
-#define GTxExDefPkt_offset 0xA4
-#define GTxExDefPkt_WIDTH 32
-#define GTxPausePkt_offset 0xA8
-#define GTxPausePkt_WIDTH 32
-#define GTxBadPkt_offset 0xAC
-#define GTxBadPkt_WIDTH 32
-#define GTxUcastPkt_offset 0xB0
-#define GTxUcastPkt_WIDTH 32
-#define GTxMcastPkt_offset 0xB4
-#define GTxMcastPkt_WIDTH 32
-#define GTxBcastPkt_offset 0xB8
-#define GTxBcastPkt_WIDTH 32
-#define GTxLt64Pkt_offset 0xBC
-#define GTxLt64Pkt_WIDTH 32
-#define GTx64Pkt_offset 0xC0
-#define GTx64Pkt_WIDTH 32
-#define GTx65to127Pkt_offset 0xC4
-#define GTx65to127Pkt_WIDTH 32
-#define GTx128to255Pkt_offset 0xC8
-#define GTx128to255Pkt_WIDTH 32
-#define GTx256to511Pkt_offset 0xCC
-#define GTx256to511Pkt_WIDTH 32
-#define GTx512to1023Pkt_offset 0xD0
-#define GTx512to1023Pkt_WIDTH 32
-#define GTx1024to15xxPkt_offset 0xD4
-#define GTx1024to15xxPkt_WIDTH 32
-#define GTx15xxtoJumboPkt_offset 0xD8
-#define GTx15xxtoJumboPkt_WIDTH 32
-#define GTxGtJumboPkt_offset 0xDC
-#define GTxGtJumboPkt_WIDTH 32
-#define GTxNonTcpUdpPkt_offset 0xE0
-#define GTxNonTcpUdpPkt_WIDTH 16
-#define GTxMacSrcErrPkt_offset 0xE4
-#define GTxMacSrcErrPkt_WIDTH 16
-#define GTxIpSrcErrPkt_offset 0xE8
-#define GTxIpSrcErrPkt_WIDTH 16
-#define GDmaDone_offset 0xEC
-#define GDmaDone_WIDTH 32
-
-#define XgRxOctets_offset 0x0
-#define XgRxOctets_WIDTH 48
-#define XgRxOctetsOK_offset 0x8
-#define XgRxOctetsOK_WIDTH 48
-#define XgRxPkts_offset 0x10
-#define XgRxPkts_WIDTH 32
-#define XgRxPktsOK_offset 0x14
-#define XgRxPktsOK_WIDTH 32
-#define XgRxBroadcastPkts_offset 0x18
-#define XgRxBroadcastPkts_WIDTH 32
-#define XgRxMulticastPkts_offset 0x1C
-#define XgRxMulticastPkts_WIDTH 32
-#define XgRxUnicastPkts_offset 0x20
-#define XgRxUnicastPkts_WIDTH 32
-#define XgRxUndersizePkts_offset 0x24
-#define XgRxUndersizePkts_WIDTH 32
-#define XgRxOversizePkts_offset 0x28
-#define XgRxOversizePkts_WIDTH 32
-#define XgRxJabberPkts_offset 0x2C
-#define XgRxJabberPkts_WIDTH 32
-#define XgRxUndersizeFCSerrorPkts_offset 0x30
-#define XgRxUndersizeFCSerrorPkts_WIDTH 32
-#define XgRxDropEvents_offset 0x34
-#define XgRxDropEvents_WIDTH 32
-#define XgRxFCSerrorPkts_offset 0x38
-#define XgRxFCSerrorPkts_WIDTH 32
-#define XgRxAlignError_offset 0x3C
-#define XgRxAlignError_WIDTH 32
-#define XgRxSymbolError_offset 0x40
-#define XgRxSymbolError_WIDTH 32
-#define XgRxInternalMACError_offset 0x44
-#define XgRxInternalMACError_WIDTH 32
-#define XgRxControlPkts_offset 0x48
-#define XgRxControlPkts_WIDTH 32
-#define XgRxPausePkts_offset 0x4C
-#define XgRxPausePkts_WIDTH 32
-#define XgRxPkts64Octets_offset 0x50
-#define XgRxPkts64Octets_WIDTH 32
-#define XgRxPkts65to127Octets_offset 0x54
-#define XgRxPkts65to127Octets_WIDTH 32
-#define XgRxPkts128to255Octets_offset 0x58
-#define XgRxPkts128to255Octets_WIDTH 32
-#define XgRxPkts256to511Octets_offset 0x5C
-#define XgRxPkts256to511Octets_WIDTH 32
-#define XgRxPkts512to1023Octets_offset 0x60
-#define XgRxPkts512to1023Octets_WIDTH 32
-#define XgRxPkts1024to15xxOctets_offset 0x64
-#define XgRxPkts1024to15xxOctets_WIDTH 32
-#define XgRxPkts15xxtoMaxOctets_offset 0x68
-#define XgRxPkts15xxtoMaxOctets_WIDTH 32
-#define XgRxLengthError_offset 0x6C
-#define XgRxLengthError_WIDTH 32
-#define XgTxPkts_offset 0x80
-#define XgTxPkts_WIDTH 32
-#define XgTxOctets_offset 0x88
-#define XgTxOctets_WIDTH 48
-#define XgTxMulticastPkts_offset 0x90
-#define XgTxMulticastPkts_WIDTH 32
-#define XgTxBroadcastPkts_offset 0x94
-#define XgTxBroadcastPkts_WIDTH 32
-#define XgTxUnicastPkts_offset 0x98
-#define XgTxUnicastPkts_WIDTH 32
-#define XgTxControlPkts_offset 0x9C
-#define XgTxControlPkts_WIDTH 32
-#define XgTxPausePkts_offset 0xA0
-#define XgTxPausePkts_WIDTH 32
-#define XgTxPkts64Octets_offset 0xA4
-#define XgTxPkts64Octets_WIDTH 32
-#define XgTxPkts65to127Octets_offset 0xA8
-#define XgTxPkts65to127Octets_WIDTH 32
-#define XgTxPkts128to255Octets_offset 0xAC
-#define XgTxPkts128to255Octets_WIDTH 32
-#define XgTxPkts256to511Octets_offset 0xB0
-#define XgTxPkts256to511Octets_WIDTH 32
-#define XgTxPkts512to1023Octets_offset 0xB4
-#define XgTxPkts512to1023Octets_WIDTH 32
-#define XgTxPkts1024to15xxOctets_offset 0xB8
-#define XgTxPkts1024to15xxOctets_WIDTH 32
-#define XgTxPkts1519toMaxOctets_offset 0xBC
-#define XgTxPkts1519toMaxOctets_WIDTH 32
-#define XgTxUndersizePkts_offset 0xC0
-#define XgTxUndersizePkts_WIDTH 32
-#define XgTxOversizePkts_offset 0xC4
-#define XgTxOversizePkts_WIDTH 32
-#define XgTxNonTcpUdpPkt_offset 0xC8
-#define XgTxNonTcpUdpPkt_WIDTH 16
-#define XgTxMacSrcErrPkt_offset 0xCC
-#define XgTxMacSrcErrPkt_WIDTH 16
-#define XgTxIpSrcErrPkt_offset 0xD0
-#define XgTxIpSrcErrPkt_WIDTH 16
-#define XgDmaDone_offset 0xD4
-
-#define FALCON_STATS_NOT_DONE 0x00000000
-#define FALCON_STATS_DONE 0xffffffff
-
-/* Interrupt status register bits */
-#define FATAL_INT_LBN 64
-#define FATAL_INT_WIDTH 1
-#define INT_EVQS_LBN 40
-#define INT_EVQS_WIDTH 4
-
-/**************************************************************************
- *
- * Falcon non-volatile configuration
- *
- **************************************************************************
- */
-
-/* Board configuration v2 (v1 is obsolete; later versions are compatible) */
-struct falcon_nvconfig_board_v2 {
-	__le16 nports;
-	u8 port0_phy_addr;
-	u8 port0_phy_type;
-	u8 port1_phy_addr;
-	u8 port1_phy_type;
-	__le16 asic_sub_revision;
-	__le16 board_revision;
-} __packed;
-
-/* Board configuration v3 extra information */
-struct falcon_nvconfig_board_v3 {
-	__le32 spi_device_type[2];
-} __packed;
-
-/* Bit numbers for spi_device_type */
-#define SPI_DEV_TYPE_SIZE_LBN 0
-#define SPI_DEV_TYPE_SIZE_WIDTH 5
-#define SPI_DEV_TYPE_ADDR_LEN_LBN 6
-#define SPI_DEV_TYPE_ADDR_LEN_WIDTH 2
-#define SPI_DEV_TYPE_ERASE_CMD_LBN 8
-#define SPI_DEV_TYPE_ERASE_CMD_WIDTH 8
-#define SPI_DEV_TYPE_ERASE_SIZE_LBN 16
-#define SPI_DEV_TYPE_ERASE_SIZE_WIDTH 5
-#define SPI_DEV_TYPE_BLOCK_SIZE_LBN 24
-#define SPI_DEV_TYPE_BLOCK_SIZE_WIDTH 5
-#define SPI_DEV_TYPE_FIELD(type, field)					\
-	(((type) >> EFX_LOW_BIT(field)) & EFX_MASK32(EFX_WIDTH(field)))
-
-#define NVCONFIG_OFFSET 0x300
-
-#define NVCONFIG_BOARD_MAGIC_NUM 0xFA1C
-struct falcon_nvconfig {
-	efx_oword_t ee_vpd_cfg_reg;			/* 0x300 */
-	u8 mac_address[2][8];			/* 0x310 */
-	efx_oword_t pcie_sd_ctl0123_reg;		/* 0x320 */
-	efx_oword_t pcie_sd_ctl45_reg;			/* 0x330 */
-	efx_oword_t pcie_pcs_ctl_stat_reg;		/* 0x340 */
-	efx_oword_t hw_init_reg;			/* 0x350 */
-	efx_oword_t nic_stat_reg;			/* 0x360 */
-	efx_oword_t glb_ctl_reg;			/* 0x370 */
-	efx_oword_t srm_cfg_reg;			/* 0x380 */
-	efx_oword_t spare_reg;				/* 0x390 */
-	__le16 board_magic_num;			/* 0x3A0 */
-	__le16 board_struct_ver;
-	__le16 board_checksum;
-	struct falcon_nvconfig_board_v2 board_v2;
-	efx_oword_t ee_base_page_reg;			/* 0x3B0 */
-	struct falcon_nvconfig_board_v3 board_v3;
-} __packed;
-
-#endif /* EFX_FALCON_HWDEFS_H */
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index b486a2b..44e6558 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -12,7 +12,7 @@
 #include "net_driver.h"
 #include "efx.h"
 #include "falcon.h"
-#include "falcon_hwdefs.h"
+#include "regs.h"
 #include "falcon_io.h"
 #include "mac.h"
 #include "mdio_10g.h"
@@ -35,27 +35,27 @@ static void falcon_setup_xaui(struct efx_nic *efx)
 	if (efx->phy_type == PHY_TYPE_NONE)
 		return;
 
-	falcon_read(efx, &sdctl, XX_SD_CTL_REG);
-	EFX_SET_OWORD_FIELD(sdctl, XX_HIDRVD, XX_SD_CTL_DRV_DEFAULT);
-	EFX_SET_OWORD_FIELD(sdctl, XX_LODRVD, XX_SD_CTL_DRV_DEFAULT);
-	EFX_SET_OWORD_FIELD(sdctl, XX_HIDRVC, XX_SD_CTL_DRV_DEFAULT);
-	EFX_SET_OWORD_FIELD(sdctl, XX_LODRVC, XX_SD_CTL_DRV_DEFAULT);
-	EFX_SET_OWORD_FIELD(sdctl, XX_HIDRVB, XX_SD_CTL_DRV_DEFAULT);
-	EFX_SET_OWORD_FIELD(sdctl, XX_LODRVB, XX_SD_CTL_DRV_DEFAULT);
-	EFX_SET_OWORD_FIELD(sdctl, XX_HIDRVA, XX_SD_CTL_DRV_DEFAULT);
-	EFX_SET_OWORD_FIELD(sdctl, XX_LODRVA, XX_SD_CTL_DRV_DEFAULT);
-	falcon_write(efx, &sdctl, XX_SD_CTL_REG);
+	falcon_read(efx, &sdctl, FR_AB_XX_SD_CTL);
+	EFX_SET_OWORD_FIELD(sdctl, FRF_AB_XX_HIDRVD, FFE_AB_XX_SD_CTL_DRV_DEF);
+	EFX_SET_OWORD_FIELD(sdctl, FRF_AB_XX_LODRVD, FFE_AB_XX_SD_CTL_DRV_DEF);
+	EFX_SET_OWORD_FIELD(sdctl, FRF_AB_XX_HIDRVC, FFE_AB_XX_SD_CTL_DRV_DEF);
+	EFX_SET_OWORD_FIELD(sdctl, FRF_AB_XX_LODRVC, FFE_AB_XX_SD_CTL_DRV_DEF);
+	EFX_SET_OWORD_FIELD(sdctl, FRF_AB_XX_HIDRVB, FFE_AB_XX_SD_CTL_DRV_DEF);
+	EFX_SET_OWORD_FIELD(sdctl, FRF_AB_XX_LODRVB, FFE_AB_XX_SD_CTL_DRV_DEF);
+	EFX_SET_OWORD_FIELD(sdctl, FRF_AB_XX_HIDRVA, FFE_AB_XX_SD_CTL_DRV_DEF);
+	EFX_SET_OWORD_FIELD(sdctl, FRF_AB_XX_LODRVA, FFE_AB_XX_SD_CTL_DRV_DEF);
+	falcon_write(efx, &sdctl, FR_AB_XX_SD_CTL);
 
 	EFX_POPULATE_OWORD_8(txdrv,
-			     XX_DEQD, XX_TXDRV_DEQ_DEFAULT,
-			     XX_DEQC, XX_TXDRV_DEQ_DEFAULT,
-			     XX_DEQB, XX_TXDRV_DEQ_DEFAULT,
-			     XX_DEQA, XX_TXDRV_DEQ_DEFAULT,
-			     XX_DTXD, XX_TXDRV_DTX_DEFAULT,
-			     XX_DTXC, XX_TXDRV_DTX_DEFAULT,
-			     XX_DTXB, XX_TXDRV_DTX_DEFAULT,
-			     XX_DTXA, XX_TXDRV_DTX_DEFAULT);
-	falcon_write(efx, &txdrv, XX_TXDRV_CTL_REG);
+			     FRF_AB_XX_DEQD, FFE_AB_XX_TXDRV_DEQ_DEF,
+			     FRF_AB_XX_DEQC, FFE_AB_XX_TXDRV_DEQ_DEF,
+			     FRF_AB_XX_DEQB, FFE_AB_XX_TXDRV_DEQ_DEF,
+			     FRF_AB_XX_DEQA, FFE_AB_XX_TXDRV_DEQ_DEF,
+			     FRF_AB_XX_DTXD, FFE_AB_XX_TXDRV_DTX_DEF,
+			     FRF_AB_XX_DTXC, FFE_AB_XX_TXDRV_DTX_DEF,
+			     FRF_AB_XX_DTXB, FFE_AB_XX_TXDRV_DTX_DEF,
+			     FRF_AB_XX_DTXA, FFE_AB_XX_TXDRV_DTX_DEF);
+	falcon_write(efx, &txdrv, FR_AB_XX_TXDRV_CTL);
 }
 
 int falcon_reset_xaui(struct efx_nic *efx)
@@ -64,14 +64,14 @@ int falcon_reset_xaui(struct efx_nic *efx)
 	int count;
 
 	/* Start reset sequence */
-	EFX_POPULATE_DWORD_1(reg, XX_RST_XX_EN, 1);
-	falcon_write(efx, &reg, XX_PWR_RST_REG);
+	EFX_POPULATE_DWORD_1(reg, FRF_AB_XX_RST_XX_EN, 1);
+	falcon_write(efx, &reg, FR_AB_XX_PWR_RST);
 
 	/* Wait up to 10 ms for completion, then reinitialise */
 	for (count = 0; count < 1000; count++) {
-		falcon_read(efx, &reg, XX_PWR_RST_REG);
-		if (EFX_OWORD_FIELD(reg, XX_RST_XX_EN) == 0 &&
-		    EFX_OWORD_FIELD(reg, XX_SD_RST_ACT) == 0) {
+		falcon_read(efx, &reg, FR_AB_XX_PWR_RST);
+		if (EFX_OWORD_FIELD(reg, FRF_AB_XX_RST_XX_EN) == 0 &&
+		    EFX_OWORD_FIELD(reg, FRF_AB_XX_SD_RST_ACT) == 0) {
 			falcon_setup_xaui(efx);
 			return 0;
 		}
@@ -99,12 +99,12 @@ static void falcon_mask_status_intr(struct efx_nic *efx, bool enable)
 
 	/* Flush the ISR */
 	if (enable)
-		falcon_read(efx, &reg, XM_MGT_INT_REG_B0);
+		falcon_read(efx, &reg, FR_AB_XM_MGT_INT_MSK);
 
 	EFX_POPULATE_OWORD_2(reg,
-			     XM_MSK_RMTFLT, !enable,
-			     XM_MSK_LCLFLT, !enable);
-	falcon_write(efx, &reg, XM_MGT_INT_MSK_REG_B0);
+			     FRF_AB_XM_MSK_RMTFLT, !enable,
+			     FRF_AB_XM_MSK_LCLFLT, !enable);
+	falcon_write(efx, &reg, FR_AB_XM_MGT_INT_MASK);
 }
 
 /* Get status of XAUI link */
@@ -118,18 +118,18 @@ bool falcon_xaui_link_ok(struct efx_nic *efx)
 		return true;
 
 	/* Read link status */
-	falcon_read(efx, &reg, XX_CORE_STAT_REG);
+	falcon_read(efx, &reg, FR_AB_XX_CORE_STAT);
 
-	align_done = EFX_OWORD_FIELD(reg, XX_ALIGN_DONE);
-	sync_status = EFX_OWORD_FIELD(reg, XX_SYNC_STAT);
-	if (align_done && (sync_status == XX_SYNC_STAT_DECODE_SYNCED))
+	align_done = EFX_OWORD_FIELD(reg, FRF_AB_XX_ALIGN_DONE);
+	sync_status = EFX_OWORD_FIELD(reg, FRF_AB_XX_SYNC_STAT);
+	if (align_done && (sync_status == FFE_AB_XX_STAT_ALL_LANES))
 		link_ok = true;
 
 	/* Clear link status ready for next read */
-	EFX_SET_OWORD_FIELD(reg, XX_COMMA_DET, XX_COMMA_DET_RESET);
-	EFX_SET_OWORD_FIELD(reg, XX_CHARERR, XX_CHARERR_RESET);
-	EFX_SET_OWORD_FIELD(reg, XX_DISPERR, XX_DISPERR_RESET);
-	falcon_write(efx, &reg, XX_CORE_STAT_REG);
+	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_COMMA_DET, FFE_AB_XX_STAT_ALL_LANES);
+	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_CHAR_ERR, FFE_AB_XX_STAT_ALL_LANES);
+	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_DISPERR, FFE_AB_XX_STAT_ALL_LANES);
+	falcon_write(efx, &reg, FR_AB_XX_CORE_STAT);
 
 	/* If the link is up, then check the phy side of the xaui link */
 	if (efx->link_up && link_ok)
@@ -147,55 +147,49 @@ static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
 
 	/* Configure MAC  - cut-thru mode is hard wired on */
 	EFX_POPULATE_DWORD_3(reg,
-			     XM_RX_JUMBO_MODE, 1,
-			     XM_TX_STAT_EN, 1,
-			     XM_RX_STAT_EN, 1);
-	falcon_write(efx, &reg, XM_GLB_CFG_REG);
+			     FRF_AB_XM_RX_JUMBO_MODE, 1,
+			     FRF_AB_XM_TX_STAT_EN, 1,
+			     FRF_AB_XM_RX_STAT_EN, 1);
+	falcon_write(efx, &reg, FR_AB_XM_GLB_CFG);
 
 	/* Configure TX */
 	EFX_POPULATE_DWORD_6(reg,
-			     XM_TXEN, 1,
-			     XM_TX_PRMBL, 1,
-			     XM_AUTO_PAD, 1,
-			     XM_TXCRC, 1,
-			     XM_FCNTL, 1,
-			     XM_IPG, 0x3);
-	falcon_write(efx, &reg, XM_TX_CFG_REG);
+			     FRF_AB_XM_TXEN, 1,
+			     FRF_AB_XM_TX_PRMBL, 1,
+			     FRF_AB_XM_AUTO_PAD, 1,
+			     FRF_AB_XM_TXCRC, 1,
+			     FRF_AB_XM_FCNTL, 1,
+			     FRF_AB_XM_IPG, 0x3);
+	falcon_write(efx, &reg, FR_AB_XM_TX_CFG);
 
 	/* Configure RX */
 	EFX_POPULATE_DWORD_5(reg,
-			     XM_RXEN, 1,
-			     XM_AUTO_DEPAD, 0,
-			     XM_ACPT_ALL_MCAST, 1,
-			     XM_ACPT_ALL_UCAST, efx->promiscuous,
-			     XM_PASS_CRC_ERR, 1);
-	falcon_write(efx, &reg, XM_RX_CFG_REG);
+			     FRF_AB_XM_RXEN, 1,
+			     FRF_AB_XM_AUTO_DEPAD, 0,
+			     FRF_AB_XM_ACPT_ALL_MCAST, 1,
+			     FRF_AB_XM_ACPT_ALL_UCAST, efx->promiscuous,
+			     FRF_AB_XM_PASS_CRC_ERR, 1);
+	falcon_write(efx, &reg, FR_AB_XM_RX_CFG);
 
 	/* Set frame length */
 	max_frame_len = EFX_MAX_FRAME_LEN(efx->net_dev->mtu);
-	EFX_POPULATE_DWORD_1(reg, XM_MAX_RX_FRM_SIZE, max_frame_len);
-	falcon_write(efx, &reg, XM_RX_PARAM_REG);
+	EFX_POPULATE_DWORD_1(reg, FRF_AB_XM_MAX_RX_FRM_SIZE, max_frame_len);
+	falcon_write(efx, &reg, FR_AB_XM_RX_PARAM);
 	EFX_POPULATE_DWORD_2(reg,
-			     XM_MAX_TX_FRM_SIZE, max_frame_len,
-			     XM_TX_JUMBO_MODE, 1);
-	falcon_write(efx, &reg, XM_TX_PARAM_REG);
+			     FRF_AB_XM_MAX_TX_FRM_SIZE, max_frame_len,
+			     FRF_AB_XM_TX_JUMBO_MODE, 1);
+	falcon_write(efx, &reg, FR_AB_XM_TX_PARAM);
 
 	EFX_POPULATE_DWORD_2(reg,
-			     XM_PAUSE_TIME, 0xfffe, /* MAX PAUSE TIME */
-			     XM_DIS_FCNTL, !rx_fc);
-	falcon_write(efx, &reg, XM_FC_REG);
+			     FRF_AB_XM_PAUSE_TIME, 0xfffe, /* MAX PAUSE TIME */
+			     FRF_AB_XM_DIS_FCNTL, !rx_fc);
+	falcon_write(efx, &reg, FR_AB_XM_FC);
 
 	/* Set MAC address */
-	EFX_POPULATE_DWORD_4(reg,
-			     XM_ADR_0, efx->net_dev->dev_addr[0],
-			     XM_ADR_1, efx->net_dev->dev_addr[1],
-			     XM_ADR_2, efx->net_dev->dev_addr[2],
-			     XM_ADR_3, efx->net_dev->dev_addr[3]);
-	falcon_write(efx, &reg, XM_ADR_LO_REG);
-	EFX_POPULATE_DWORD_2(reg,
-			     XM_ADR_4, efx->net_dev->dev_addr[4],
-			     XM_ADR_5, efx->net_dev->dev_addr[5]);
-	falcon_write(efx, &reg, XM_ADR_HI_REG);
+	memcpy(&reg, &efx->net_dev->dev_addr[0], 4);
+	falcon_write(efx, &reg, FR_AB_XM_ADR_LO);
+	memcpy(&reg, &efx->net_dev->dev_addr[4], 2);
+	falcon_write(efx, &reg, FR_AB_XM_ADR_HI);
 }
 
 static void falcon_reconfigure_xgxs_core(struct efx_nic *efx)
@@ -211,12 +205,13 @@ static void falcon_reconfigure_xgxs_core(struct efx_nic *efx)
 		bool old_xgmii_loopback, old_xgxs_loopback, old_xaui_loopback;
 		bool reset_xgxs;
 
-		falcon_read(efx, &reg, XX_CORE_STAT_REG);
-		old_xgxs_loopback = EFX_OWORD_FIELD(reg, XX_XGXS_LB_EN);
-		old_xgmii_loopback = EFX_OWORD_FIELD(reg, XX_XGMII_LB_EN);
+		falcon_read(efx, &reg, FR_AB_XX_CORE_STAT);
+		old_xgxs_loopback = EFX_OWORD_FIELD(reg, FRF_AB_XX_XGXS_LB_EN);
+		old_xgmii_loopback =
+			EFX_OWORD_FIELD(reg, FRF_AB_XX_XGMII_LB_EN);
 
-		falcon_read(efx, &reg, XX_SD_CTL_REG);
-		old_xaui_loopback = EFX_OWORD_FIELD(reg, XX_LPBKA);
+		falcon_read(efx, &reg, FR_AB_XX_SD_CTL);
+		old_xaui_loopback = EFX_OWORD_FIELD(reg, FRF_AB_XX_LPBKA);
 
 		/* The PHY driver may have turned XAUI off */
 		reset_xgxs = ((xgxs_loopback != old_xgxs_loopback) ||
@@ -227,20 +222,20 @@ static void falcon_reconfigure_xgxs_core(struct efx_nic *efx)
 			falcon_reset_xaui(efx);
 	}
 
-	falcon_read(efx, &reg, XX_CORE_STAT_REG);
-	EFX_SET_OWORD_FIELD(reg, XX_FORCE_SIG,
+	falcon_read(efx, &reg, FR_AB_XX_CORE_STAT);
+	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_FORCE_SIG,
 			    (xgxs_loopback || xaui_loopback) ?
-			    XX_FORCE_SIG_DECODE_FORCED : 0);
-	EFX_SET_OWORD_FIELD(reg, XX_XGXS_LB_EN, xgxs_loopback);
-	EFX_SET_OWORD_FIELD(reg, XX_XGMII_LB_EN, xgmii_loopback);
-	falcon_write(efx, &reg, XX_CORE_STAT_REG);
-
-	falcon_read(efx, &reg, XX_SD_CTL_REG);
-	EFX_SET_OWORD_FIELD(reg, XX_LPBKD, xaui_loopback);
-	EFX_SET_OWORD_FIELD(reg, XX_LPBKC, xaui_loopback);
-	EFX_SET_OWORD_FIELD(reg, XX_LPBKB, xaui_loopback);
-	EFX_SET_OWORD_FIELD(reg, XX_LPBKA, xaui_loopback);
-	falcon_write(efx, &reg, XX_SD_CTL_REG);
+			    FFE_AB_XX_FORCE_SIG_ALL_LANES : 0);
+	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_XGXS_LB_EN, xgxs_loopback);
+	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_XGMII_LB_EN, xgmii_loopback);
+	falcon_write(efx, &reg, FR_AB_XX_CORE_STAT);
+
+	falcon_read(efx, &reg, FR_AB_XX_SD_CTL);
+	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_LPBKD, xaui_loopback);
+	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_LPBKC, xaui_loopback);
+	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_LPBKB, xaui_loopback);
+	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_LPBKA, xaui_loopback);
+	falcon_write(efx, &reg, FR_AB_XX_SD_CTL);
 }
 

diff --git a/drivers/net/sfc/regs.h b/drivers/net/sfc/regs.h
new file mode 100644
index 0000000..f336d83
--- /dev/null
+++ b/drivers/net/sfc/regs.h
@@ -0,0 +1,3180 @@
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
+#ifndef EFX_REGS_H
+#define EFX_REGS_H
+
+/*
+ * Falcon hardware architecture definitions have a name prefix following
+ * the format:
+ *
+ *     F<type>_<min-rev><max-rev>_
+ *
+ * The following <type> strings are used:
+ *
+ *             MMIO register  MC register  Host memory structure
+ * -------------------------------------------------------------
+ * Address     R              MCR
+ * Bitfield    RF             MCRF         SF
+ * Enumerator  FE             MCFE         SE
+ *
+ * <min-rev> is the first revision to which the definition applies:
+ *
+ *     A: Falcon A1 (SFC4000AB)
+ *     B: Falcon B0 (SFC4000BA)
+ *     C: Siena A0 (SFL9021AA)
+ *
+ * If the definition has been changed or removed in later revisions
+ * then <max-rev> is the last revision to which the definition applies;
+ * otherwise it is "Z".
+ */
+
+/**************************************************************************
+ *
+ * Falcon/Siena registers and descriptors
+ *
+ **************************************************************************
+ */
+
+/* ADR_REGION_REG: Address region register */
+#define	FR_AZ_ADR_REGION 0x00000000
+#define	FRF_AZ_ADR_REGION3_LBN 96
+#define	FRF_AZ_ADR_REGION3_WIDTH 18
+#define	FRF_AZ_ADR_REGION2_LBN 64
+#define	FRF_AZ_ADR_REGION2_WIDTH 18
+#define	FRF_AZ_ADR_REGION1_LBN 32
+#define	FRF_AZ_ADR_REGION1_WIDTH 18
+#define	FRF_AZ_ADR_REGION0_LBN 0
+#define	FRF_AZ_ADR_REGION0_WIDTH 18
+
+/* INT_EN_REG_KER: Kernel driver Interrupt enable register */
+#define	FR_AZ_INT_EN_KER 0x00000010
+#define	FRF_AZ_KER_INT_LEVE_SEL_LBN 8
+#define	FRF_AZ_KER_INT_LEVE_SEL_WIDTH 6
+#define	FRF_AZ_KER_INT_CHAR_LBN 4
+#define	FRF_AZ_KER_INT_CHAR_WIDTH 1
+#define	FRF_AZ_KER_INT_KER_LBN 3
+#define	FRF_AZ_KER_INT_KER_WIDTH 1
+#define	FRF_AZ_DRV_INT_EN_KER_LBN 0
+#define	FRF_AZ_DRV_INT_EN_KER_WIDTH 1
+
+/* INT_EN_REG_CHAR: Char Driver interrupt enable register */
+#define	FR_BZ_INT_EN_CHAR 0x00000020
+#define	FRF_BZ_CHAR_INT_LEVE_SEL_LBN 8
+#define	FRF_BZ_CHAR_INT_LEVE_SEL_WIDTH 6
+#define	FRF_BZ_CHAR_INT_CHAR_LBN 4
+#define	FRF_BZ_CHAR_INT_CHAR_WIDTH 1
+#define	FRF_BZ_CHAR_INT_KER_LBN 3
+#define	FRF_BZ_CHAR_INT_KER_WIDTH 1
+#define	FRF_BZ_DRV_INT_EN_CHAR_LBN 0
+#define	FRF_BZ_DRV_INT_EN_CHAR_WIDTH 1
+
+/* INT_ADR_REG_KER: Interrupt host address for Kernel driver */
+#define	FR_AZ_INT_ADR_KER 0x00000030
+#define	FRF_AZ_NORM_INT_VEC_DIS_KER_LBN 64
+#define	FRF_AZ_NORM_INT_VEC_DIS_KER_WIDTH 1
+#define	FRF_AZ_INT_ADR_KER_LBN 0
+#define	FRF_AZ_INT_ADR_KER_WIDTH 64
+
+/* INT_ADR_REG_CHAR: Interrupt host address for Char driver */
+#define	FR_BZ_INT_ADR_CHAR 0x00000040
+#define	FRF_BZ_NORM_INT_VEC_DIS_CHAR_LBN 64
+#define	FRF_BZ_NORM_INT_VEC_DIS_CHAR_WIDTH 1
+#define	FRF_BZ_INT_ADR_CHAR_LBN 0
+#define	FRF_BZ_INT_ADR_CHAR_WIDTH 64
+
+/* INT_ACK_KER: Kernel interrupt acknowledge register */
+#define	FR_AA_INT_ACK_KER 0x00000050
+#define	FRF_AA_INT_ACK_KER_FIELD_LBN 0
+#define	FRF_AA_INT_ACK_KER_FIELD_WIDTH 32
+
+/* INT_ISR0_REG: Function 0 Interrupt Acknowlege Status register */
+#define	FR_BZ_INT_ISR0 0x00000090
+#define	FRF_BZ_INT_ISR_REG_LBN 0
+#define	FRF_BZ_INT_ISR_REG_WIDTH 64
+
+/* HW_INIT_REG: Hardware initialization register */
+#define	FR_AZ_HW_INIT 0x000000c0
+#define	FRF_BB_BDMRD_CPLF_FULL_LBN 124
+#define	FRF_BB_BDMRD_CPLF_FULL_WIDTH 1
+#define	FRF_BB_PCIE_CPL_TIMEOUT_CTRL_LBN 121
+#define	FRF_BB_PCIE_CPL_TIMEOUT_CTRL_WIDTH 3
+#define	FRF_CZ_TX_MRG_TAGS_LBN 120
+#define	FRF_CZ_TX_MRG_TAGS_WIDTH 1
+#define	FRF_AB_TRGT_MASK_ALL_LBN 100
+#define	FRF_AB_TRGT_MASK_ALL_WIDTH 1
+#define	FRF_AZ_DOORBELL_DROP_LBN 92
+#define	FRF_AZ_DOORBELL_DROP_WIDTH 8
+#define	FRF_AB_TX_RREQ_MASK_EN_LBN 76
+#define	FRF_AB_TX_RREQ_MASK_EN_WIDTH 1
+#define	FRF_AB_PE_EIDLE_DIS_LBN 75
+#define	FRF_AB_PE_EIDLE_DIS_WIDTH 1
+#define	FRF_AA_FC_BLOCKING_EN_LBN 45
+#define	FRF_AA_FC_BLOCKING_EN_WIDTH 1
+#define	FRF_BZ_B2B_REQ_EN_LBN 45
+#define	FRF_BZ_B2B_REQ_EN_WIDTH 1
+#define	FRF_AA_B2B_REQ_EN_LBN 44
+#define	FRF_AA_B2B_REQ_EN_WIDTH 1
+#define	FRF_BB_FC_BLOCKING_EN_LBN 44
+#define	FRF_BB_FC_BLOCKING_EN_WIDTH 1
+#define	FRF_AZ_POST_WR_MASK_LBN 40
+#define	FRF_AZ_POST_WR_MASK_WIDTH 4
+#define	FRF_AZ_TLP_TC_LBN 34
+#define	FRF_AZ_TLP_TC_WIDTH 3
+#define	FRF_AZ_TLP_ATTR_LBN 32
+#define	FRF_AZ_TLP_ATTR_WIDTH 2
+#define	FRF_AB_INTB_VEC_LBN 24
+#define	FRF_AB_INTB_VEC_WIDTH 5
+#define	FRF_AB_INTA_VEC_LBN 16
+#define	FRF_AB_INTA_VEC_WIDTH 5
+#define	FRF_AZ_WD_TIMER_LBN 8
+#define	FRF_AZ_WD_TIMER_WIDTH 8
+#define	FRF_AZ_US_DISABLE_LBN 5
+#define	FRF_AZ_US_DISABLE_WIDTH 1
+#define	FRF_AZ_TLP_EP_LBN 4
+#define	FRF_AZ_TLP_EP_WIDTH 1
+#define	FRF_AZ_ATTR_SEL_LBN 3
+#define	FRF_AZ_ATTR_SEL_WIDTH 1
+#define	FRF_AZ_TD_SEL_LBN 1
+#define	FRF_AZ_TD_SEL_WIDTH 1
+#define	FRF_AZ_TLP_TD_LBN 0
+#define	FRF_AZ_TLP_TD_WIDTH 1
+
+/* EE_SPI_HCMD_REG: SPI host command register */
+#define	FR_AB_EE_SPI_HCMD 0x00000100
+#define	FRF_AB_EE_SPI_HCMD_CMD_EN_LBN 31
+#define	FRF_AB_EE_SPI_HCMD_CMD_EN_WIDTH 1
+#define	FRF_AB_EE_WR_TIMER_ACTIVE_LBN 28
+#define	FRF_AB_EE_WR_TIMER_ACTIVE_WIDTH 1
+#define	FRF_AB_EE_SPI_HCMD_SF_SEL_LBN 24
+#define	FRF_AB_EE_SPI_HCMD_SF_SEL_WIDTH 1
+#define	FRF_AB_EE_SPI_HCMD_DABCNT_LBN 16
+#define	FRF_AB_EE_SPI_HCMD_DABCNT_WIDTH 5
+#define	FRF_AB_EE_SPI_HCMD_READ_LBN 15
+#define	FRF_AB_EE_SPI_HCMD_READ_WIDTH 1
+#define	FRF_AB_EE_SPI_HCMD_DUBCNT_LBN 12
+#define	FRF_AB_EE_SPI_HCMD_DUBCNT_WIDTH 2
+#define	FRF_AB_EE_SPI_HCMD_ADBCNT_LBN 8
+#define	FRF_AB_EE_SPI_HCMD_ADBCNT_WIDTH 2
+#define	FRF_AB_EE_SPI_HCMD_ENC_LBN 0
+#define	FRF_AB_EE_SPI_HCMD_ENC_WIDTH 8
+
+/* USR_EV_CFG: User Level Event Configuration register */
+#define	FR_CZ_USR_EV_CFG 0x00000100
+#define	FRF_CZ_USREV_DIS_LBN 16
+#define	FRF_CZ_USREV_DIS_WIDTH 1
+#define	FRF_CZ_DFLT_EVQ_LBN 0
+#define	FRF_CZ_DFLT_EVQ_WIDTH 10
+
+/* EE_SPI_HADR_REG: SPI host address register */
+#define	FR_AB_EE_SPI_HADR 0x00000110
+#define	FRF_AB_EE_SPI_HADR_DUBYTE_LBN 24
+#define	FRF_AB_EE_SPI_HADR_DUBYTE_WIDTH 8
+#define	FRF_AB_EE_SPI_HADR_ADR_LBN 0
+#define	FRF_AB_EE_SPI_HADR_ADR_WIDTH 24
+
+/* EE_SPI_HDATA_REG: SPI host data register */
+#define	FR_AB_EE_SPI_HDATA 0x00000120
+#define	FRF_AB_EE_SPI_HDATA3_LBN 96
+#define	FRF_AB_EE_SPI_HDATA3_WIDTH 32
+#define	FRF_AB_EE_SPI_HDATA2_LBN 64
+#define	FRF_AB_EE_SPI_HDATA2_WIDTH 32
+#define	FRF_AB_EE_SPI_HDATA1_LBN 32
+#define	FRF_AB_EE_SPI_HDATA1_WIDTH 32
+#define	FRF_AB_EE_SPI_HDATA0_LBN 0
+#define	FRF_AB_EE_SPI_HDATA0_WIDTH 32
+
+/* EE_BASE_PAGE_REG: Expansion ROM base mirror register */
+#define	FR_AB_EE_BASE_PAGE 0x00000130
+#define	FRF_AB_EE_EXPROM_MASK_LBN 16
+#define	FRF_AB_EE_EXPROM_MASK_WIDTH 13
+#define	FRF_AB_EE_EXP_ROM_WINDOW_BASE_LBN 0
+#define	FRF_AB_EE_EXP_ROM_WINDOW_BASE_WIDTH 13
+
+/* EE_VPD_CFG0_REG: SPI/VPD configuration register 0 */
+#define	FR_AB_EE_VPD_CFG0 0x00000140
+#define	FRF_AB_EE_SF_FASTRD_EN_LBN 127
+#define	FRF_AB_EE_SF_FASTRD_EN_WIDTH 1
+#define	FRF_AB_EE_SF_CLOCK_DIV_LBN 120
+#define	FRF_AB_EE_SF_CLOCK_DIV_WIDTH 7
+#define	FRF_AB_EE_VPD_WIP_POLL_LBN 119
+#define	FRF_AB_EE_VPD_WIP_POLL_WIDTH 1
+#define	FRF_AB_EE_EE_CLOCK_DIV_LBN 112
+#define	FRF_AB_EE_EE_CLOCK_DIV_WIDTH 7
+#define	FRF_AB_EE_EE_WR_TMR_VALUE_LBN 96
+#define	FRF_AB_EE_EE_WR_TMR_VALUE_WIDTH 16
+#define	FRF_AB_EE_VPDW_LENGTH_LBN 80
+#define	FRF_AB_EE_VPDW_LENGTH_WIDTH 15
+#define	FRF_AB_EE_VPDW_BASE_LBN 64
+#define	FRF_AB_EE_VPDW_BASE_WIDTH 15
+#define	FRF_AB_EE_VPD_WR_CMD_EN_LBN 56
+#define	FRF_AB_EE_VPD_WR_CMD_EN_WIDTH 8
+#define	FRF_AB_EE_VPD_BASE_LBN 32
+#define	FRF_AB_EE_VPD_BASE_WIDTH 24
+#define	FRF_AB_EE_VPD_LENGTH_LBN 16
+#define	FRF_AB_EE_VPD_LENGTH_WIDTH 15
+#define	FRF_AB_EE_VPD_AD_SIZE_LBN 8
+#define	FRF_AB_EE_VPD_AD_SIZE_WIDTH 5
+#define	FRF_AB_EE_VPD_ACCESS_ON_LBN 5
+#define	FRF_AB_EE_VPD_ACCESS_ON_WIDTH 1
+#define	FRF_AB_EE_VPD_ACCESS_BLOCK_LBN 4
+#define	FRF_AB_EE_VPD_ACCESS_BLOCK_WIDTH 1
+#define	FRF_AB_EE_VPD_DEV_SF_SEL_LBN 2
+#define	FRF_AB_EE_VPD_DEV_SF_SEL_WIDTH 1
+#define	FRF_AB_EE_VPD_EN_AD9_MODE_LBN 1
+#define	FRF_AB_EE_VPD_EN_AD9_MODE_WIDTH 1
+#define	FRF_AB_EE_VPD_EN_LBN 0
+#define	FRF_AB_EE_VPD_EN_WIDTH 1
+
+/* EE_VPD_SW_CNTL_REG: VPD access SW control register */
+#define	FR_AB_EE_VPD_SW_CNTL 0x00000150
+#define	FRF_AB_EE_VPD_CYCLE_PENDING_LBN 31
+#define	FRF_AB_EE_VPD_CYCLE_PENDING_WIDTH 1
+#define	FRF_AB_EE_VPD_CYC_WRITE_LBN 28
+#define	FRF_AB_EE_VPD_CYC_WRITE_WIDTH 1
+#define	FRF_AB_EE_VPD_CYC_ADR_LBN 0
+#define	FRF_AB_EE_VPD_CYC_ADR_WIDTH 15
+
+/* EE_VPD_SW_DATA_REG: VPD access SW data register */
+#define	FR_AB_EE_VPD_SW_DATA 0x00000160
+#define	FRF_AB_EE_VPD_CYC_DAT_LBN 0
+#define	FRF_AB_EE_VPD_CYC_DAT_WIDTH 32
+
+/* PBMX_DBG_IADDR_REG: Capture Module address register */
+#define	FR_CZ_PBMX_DBG_IADDR 0x000001f0
+#define	FRF_CZ_PBMX_DBG_IADDR_LBN 0
+#define	FRF_CZ_PBMX_DBG_IADDR_WIDTH 32
+
+/* PCIE_CORE_INDIRECT_REG: Indirect Access to PCIE Core registers */
+#define	FR_BB_PCIE_CORE_INDIRECT 0x000001f0
+#define	FRF_BB_PCIE_CORE_TARGET_DATA_LBN 32
+#define	FRF_BB_PCIE_CORE_TARGET_DATA_WIDTH 32
+#define	FRF_BB_PCIE_CORE_INDIRECT_ACCESS_DIR_LBN 15
+#define	FRF_BB_PCIE_CORE_INDIRECT_ACCESS_DIR_WIDTH 1
+#define	FRF_BB_PCIE_CORE_TARGET_REG_ADRS_LBN 0
+#define	FRF_BB_PCIE_CORE_TARGET_REG_ADRS_WIDTH 12
+
+/* PBMX_DBG_IDATA_REG: Capture Module data register */
+#define	FR_CZ_PBMX_DBG_IDATA 0x000001f8
+#define	FRF_CZ_PBMX_DBG_IDATA_LBN 0
+#define	FRF_CZ_PBMX_DBG_IDATA_WIDTH 64
+
+/* NIC_STAT_REG: NIC status register */
+#define	FR_AB_NIC_STAT 0x00000200
+#define	FRF_BB_AER_DIS_LBN 34
+#define	FRF_BB_AER_DIS_WIDTH 1
+#define	FRF_BB_EE_STRAP_EN_LBN 31
+#define	FRF_BB_EE_STRAP_EN_WIDTH 1
+#define	FRF_BB_EE_STRAP_LBN 24
+#define	FRF_BB_EE_STRAP_WIDTH 4
+#define	FRF_BB_REVISION_ID_LBN 17
+#define	FRF_BB_REVISION_ID_WIDTH 7
+#define	FRF_AB_ONCHIP_SRAM_LBN 16
+#define	FRF_AB_ONCHIP_SRAM_WIDTH 1
+#define	FRF_AB_SF_PRST_LBN 9
+#define	FRF_AB_SF_PRST_WIDTH 1
+#define	FRF_AB_EE_PRST_LBN 8
+#define	FRF_AB_EE_PRST_WIDTH 1
+#define	FRF_AB_ATE_MODE_LBN 3
+#define	FRF_AB_ATE_MODE_WIDTH 1
+#define	FRF_AB_STRAP_PINS_LBN 0
+#define	FRF_AB_STRAP_PINS_WIDTH 3
+
+/* GPIO_CTL_REG: GPIO control register */
+#define	FR_AB_GPIO_CTL 0x00000210
+#define	FRF_AB_GPIO_OUT3_LBN 112
+#define	FRF_AB_GPIO_OUT3_WIDTH 16
+#define	FRF_AB_GPIO_IN3_LBN 104
+#define	FRF_AB_GPIO_IN3_WIDTH 8
+#define	FRF_AB_GPIO_PWRUP_VALUE3_LBN 96
+#define	FRF_AB_GPIO_PWRUP_VALUE3_WIDTH 8
+#define	FRF_AB_GPIO_OUT2_LBN 80
+#define	FRF_AB_GPIO_OUT2_WIDTH 16
+#define	FRF_AB_GPIO_IN2_LBN 72
+#define	FRF_AB_GPIO_IN2_WIDTH 8
+#define	FRF_AB_GPIO_PWRUP_VALUE2_LBN 64
+#define	FRF_AB_GPIO_PWRUP_VALUE2_WIDTH 8
+#define	FRF_AB_GPIO15_OEN_LBN 63
+#define	FRF_AB_GPIO15_OEN_WIDTH 1
+#define	FRF_AB_GPIO14_OEN_LBN 62
+#define	FRF_AB_GPIO14_OEN_WIDTH 1
+#define	FRF_AB_GPIO13_OEN_LBN 61
+#define	FRF_AB_GPIO13_OEN_WIDTH 1
+#define	FRF_AB_GPIO12_OEN_LBN 60
+#define	FRF_AB_GPIO12_OEN_WIDTH 1
+#define	FRF_AB_GPIO11_OEN_LBN 59
+#define	FRF_AB_GPIO11_OEN_WIDTH 1
+#define	FRF_AB_GPIO10_OEN_LBN 58
+#define	FRF_AB_GPIO10_OEN_WIDTH 1
+#define	FRF_AB_GPIO9_OEN_LBN 57
+#define	FRF_AB_GPIO9_OEN_WIDTH 1
+#define	FRF_AB_GPIO8_OEN_LBN 56
+#define	FRF_AB_GPIO8_OEN_WIDTH 1
+#define	FRF_AB_GPIO15_OUT_LBN 55
+#define	FRF_AB_GPIO15_OUT_WIDTH 1
+#define	FRF_AB_GPIO14_OUT_LBN 54
+#define	FRF_AB_GPIO14_OUT_WIDTH 1
+#define	FRF_AB_GPIO13_OUT_LBN 53
+#define	FRF_AB_GPIO13_OUT_WIDTH 1
+#define	FRF_AB_GPIO12_OUT_LBN 52
+#define	FRF_AB_GPIO12_OUT_WIDTH 1
+#define	FRF_AB_GPIO11_OUT_LBN 51
+#define	FRF_AB_GPIO11_OUT_WIDTH 1
+#define	FRF_AB_GPIO10_OUT_LBN 50
+#define	FRF_AB_GPIO10_OUT_WIDTH 1
+#define	FRF_AB_GPIO9_OUT_LBN 49
+#define	FRF_AB_GPIO9_OUT_WIDTH 1
+#define	FRF_AB_GPIO8_OUT_LBN 48
+#define	FRF_AB_GPIO8_OUT_WIDTH 1
+#define	FRF_AB_GPIO15_IN_LBN 47
+#define	FRF_AB_GPIO15_IN_WIDTH 1
+#define	FRF_AB_GPIO14_IN_LBN 46
+#define	FRF_AB_GPIO14_IN_WIDTH 1
+#define	FRF_AB_GPIO13_IN_LBN 45
+#define	FRF_AB_GPIO13_IN_WIDTH 1
+#define	FRF_AB_GPIO12_IN_LBN 44
+#define	FRF_AB_GPIO12_IN_WIDTH 1
+#define	FRF_AB_GPIO11_IN_LBN 43
+#define	FRF_AB_GPIO11_IN_WIDTH 1
+#define	FRF_AB_GPIO10_IN_LBN 42
+#define	FRF_AB_GPIO10_IN_WIDTH 1
+#define	FRF_AB_GPIO9_IN_LBN 41
+#define	FRF_AB_GPIO9_IN_WIDTH 1
+#define	FRF_AB_GPIO8_IN_LBN 40
+#define	FRF_AB_GPIO8_IN_WIDTH 1
+#define	FRF_AB_GPIO15_PWRUP_VALUE_LBN 39
+#define	FRF_AB_GPIO15_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO14_PWRUP_VALUE_LBN 38
+#define	FRF_AB_GPIO14_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO13_PWRUP_VALUE_LBN 37
+#define	FRF_AB_GPIO13_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO12_PWRUP_VALUE_LBN 36
+#define	FRF_AB_GPIO12_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO11_PWRUP_VALUE_LBN 35
+#define	FRF_AB_GPIO11_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO10_PWRUP_VALUE_LBN 34
+#define	FRF_AB_GPIO10_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO9_PWRUP_VALUE_LBN 33
+#define	FRF_AB_GPIO9_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO8_PWRUP_VALUE_LBN 32
+#define	FRF_AB_GPIO8_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_CLK156_OUT_EN_LBN 31
+#define	FRF_AB_CLK156_OUT_EN_WIDTH 1
+#define	FRF_AB_USE_NIC_CLK_LBN 30
+#define	FRF_AB_USE_NIC_CLK_WIDTH 1
+#define	FRF_AB_GPIO5_OEN_LBN 29
+#define	FRF_AB_GPIO5_OEN_WIDTH 1
+#define	FRF_AB_GPIO4_OEN_LBN 28
+#define	FRF_AB_GPIO4_OEN_WIDTH 1
+#define	FRF_AB_GPIO3_OEN_LBN 27
+#define	FRF_AB_GPIO3_OEN_WIDTH 1
+#define	FRF_AB_GPIO2_OEN_LBN 26
+#define	FRF_AB_GPIO2_OEN_WIDTH 1
+#define	FRF_AB_GPIO1_OEN_LBN 25
+#define	FRF_AB_GPIO1_OEN_WIDTH 1
+#define	FRF_AB_GPIO0_OEN_LBN 24
+#define	FRF_AB_GPIO0_OEN_WIDTH 1
+#define	FRF_AB_GPIO7_OUT_LBN 23
+#define	FRF_AB_GPIO7_OUT_WIDTH 1
+#define	FRF_AB_GPIO6_OUT_LBN 22
+#define	FRF_AB_GPIO6_OUT_WIDTH 1
+#define	FRF_AB_GPIO5_OUT_LBN 21
+#define	FRF_AB_GPIO5_OUT_WIDTH 1
+#define	FRF_AB_GPIO4_OUT_LBN 20
+#define	FRF_AB_GPIO4_OUT_WIDTH 1
+#define	FRF_AB_GPIO3_OUT_LBN 19
+#define	FRF_AB_GPIO3_OUT_WIDTH 1
+#define	FRF_AB_GPIO2_OUT_LBN 18
+#define	FRF_AB_GPIO2_OUT_WIDTH 1
+#define	FRF_AB_GPIO1_OUT_LBN 17
+#define	FRF_AB_GPIO1_OUT_WIDTH 1
+#define	FRF_AB_GPIO0_OUT_LBN 16
+#define	FRF_AB_GPIO0_OUT_WIDTH 1
+#define	FRF_AB_GPIO7_IN_LBN 15
+#define	FRF_AB_GPIO7_IN_WIDTH 1
+#define	FRF_AB_GPIO6_IN_LBN 14
+#define	FRF_AB_GPIO6_IN_WIDTH 1
+#define	FRF_AB_GPIO5_IN_LBN 13
+#define	FRF_AB_GPIO5_IN_WIDTH 1
+#define	FRF_AB_GPIO4_IN_LBN 12
+#define	FRF_AB_GPIO4_IN_WIDTH 1
+#define	FRF_AB_GPIO3_IN_LBN 11
+#define	FRF_AB_GPIO3_IN_WIDTH 1
+#define	FRF_AB_GPIO2_IN_LBN 10
+#define	FRF_AB_GPIO2_IN_WIDTH 1
+#define	FRF_AB_GPIO1_IN_LBN 9
+#define	FRF_AB_GPIO1_IN_WIDTH 1
+#define	FRF_AB_GPIO0_IN_LBN 8
+#define	FRF_AB_GPIO0_IN_WIDTH 1
+#define	FRF_AB_GPIO7_PWRUP_VALUE_LBN 7
+#define	FRF_AB_GPIO7_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO6_PWRUP_VALUE_LBN 6
+#define	FRF_AB_GPIO6_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO5_PWRUP_VALUE_LBN 5
+#define	FRF_AB_GPIO5_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO4_PWRUP_VALUE_LBN 4
+#define	FRF_AB_GPIO4_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO3_PWRUP_VALUE_LBN 3
+#define	FRF_AB_GPIO3_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO2_PWRUP_VALUE_LBN 2
+#define	FRF_AB_GPIO2_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO1_PWRUP_VALUE_LBN 1
+#define	FRF_AB_GPIO1_PWRUP_VALUE_WIDTH 1
+#define	FRF_AB_GPIO0_PWRUP_VALUE_LBN 0
+#define	FRF_AB_GPIO0_PWRUP_VALUE_WIDTH 1
+
+/* GLB_CTL_REG: Global control register */
+#define	FR_AB_GLB_CTL 0x00000220
+#define	FRF_AB_EXT_PHY_RST_CTL_LBN 63
+#define	FRF_AB_EXT_PHY_RST_CTL_WIDTH 1
+#define	FRF_AB_XAUI_SD_RST_CTL_LBN 62
+#define	FRF_AB_XAUI_SD_RST_CTL_WIDTH 1
+#define	FRF_AB_PCIE_SD_RST_CTL_LBN 61
+#define	FRF_AB_PCIE_SD_RST_CTL_WIDTH 1
+#define	FRF_AA_PCIX_RST_CTL_LBN 60
+#define	FRF_AA_PCIX_RST_CTL_WIDTH 1
+#define	FRF_BB_BIU_RST_CTL_LBN 60
+#define	FRF_BB_BIU_RST_CTL_WIDTH 1
+#define	FRF_AB_PCIE_STKY_RST_CTL_LBN 59
+#define	FRF_AB_PCIE_STKY_RST_CTL_WIDTH 1
+#define	FRF_AB_PCIE_NSTKY_RST_CTL_LBN 58
+#define	FRF_AB_PCIE_NSTKY_RST_CTL_WIDTH 1
+#define	FRF_AB_PCIE_CORE_RST_CTL_LBN 57
+#define	FRF_AB_PCIE_CORE_RST_CTL_WIDTH 1
+#define	FRF_AB_XGRX_RST_CTL_LBN 56
+#define	FRF_AB_XGRX_RST_CTL_WIDTH 1
+#define	FRF_AB_XGTX_RST_CTL_LBN 55
+#define	FRF_AB_XGTX_RST_CTL_WIDTH 1
+#define	FRF_AB_EM_RST_CTL_LBN 54
+#define	FRF_AB_EM_RST_CTL_WIDTH 1
+#define	FRF_AB_EV_RST_CTL_LBN 53
+#define	FRF_AB_EV_RST_CTL_WIDTH 1
+#define	FRF_AB_SR_RST_CTL_LBN 52
+#define	FRF_AB_SR_RST_CTL_WIDTH 1
+#define	FRF_AB_RX_RST_CTL_LBN 51
+#define	FRF_AB_RX_RST_CTL_WIDTH 1
+#define	FRF_AB_TX_RST_CTL_LBN 50
+#define	FRF_AB_TX_RST_CTL_WIDTH 1
+#define	FRF_AB_EE_RST_CTL_LBN 49
+#define	FRF_AB_EE_RST_CTL_WIDTH 1
+#define	FRF_AB_CS_RST_CTL_LBN 48
+#define	FRF_AB_CS_RST_CTL_WIDTH 1
+#define	FRF_AB_HOT_RST_CTL_LBN 40
+#define	FRF_AB_HOT_RST_CTL_WIDTH 2
+#define	FRF_AB_RST_EXT_PHY_LBN 31
+#define	FRF_AB_RST_EXT_PHY_WIDTH 1
+#define	FRF_AB_RST_XAUI_SD_LBN 30
+#define	FRF_AB_RST_XAUI_SD_WIDTH 1
+#define	FRF_AB_RST_PCIE_SD_LBN 29
+#define	FRF_AB_RST_PCIE_SD_WIDTH 1
+#define	FRF_AA_RST_PCIX_LBN 28
+#define	FRF_AA_RST_PCIX_WIDTH 1
+#define	FRF_BB_RST_BIU_LBN 28
+#define	FRF_BB_RST_BIU_WIDTH 1
+#define	FRF_AB_RST_PCIE_STKY_LBN 27
+#define	FRF_AB_RST_PCIE_STKY_WIDTH 1
+#define	FRF_AB_RST_PCIE_NSTKY_LBN 26
+#define	FRF_AB_RST_PCIE_NSTKY_WIDTH 1
+#define	FRF_AB_RST_PCIE_CORE_LBN 25
+#define	FRF_AB_RST_PCIE_CORE_WIDTH 1
+#define	FRF_AB_RST_XGRX_LBN 24
+#define	FRF_AB_RST_XGRX_WIDTH 1
+#define	FRF_AB_RST_XGTX_LBN 23
+#define	FRF_AB_RST_XGTX_WIDTH 1
+#define	FRF_AB_RST_EM_LBN 22
+#define	FRF_AB_RST_EM_WIDTH 1
+#define	FRF_AB_RST_EV_LBN 21
+#define	FRF_AB_RST_EV_WIDTH 1
+#define	FRF_AB_RST_SR_LBN 20
+#define	FRF_AB_RST_SR_WIDTH 1
+#define	FRF_AB_RST_RX_LBN 19
+#define	FRF_AB_RST_RX_WIDTH 1
+#define	FRF_AB_RST_TX_LBN 18
+#define	FRF_AB_RST_TX_WIDTH 1
+#define	FRF_AB_RST_SF_LBN 17
+#define	FRF_AB_RST_SF_WIDTH 1
+#define	FRF_AB_RST_CS_LBN 16
+#define	FRF_AB_RST_CS_WIDTH 1
+#define	FRF_AB_INT_RST_DUR_LBN 4
+#define	FRF_AB_INT_RST_DUR_WIDTH 3
+#define	FRF_AB_EXT_PHY_RST_DUR_LBN 1
+#define	FRF_AB_EXT_PHY_RST_DUR_WIDTH 3
+#define	FFE_AB_EXT_PHY_RST_DUR_10240US 7
+#define	FFE_AB_EXT_PHY_RST_DUR_5120US 6
+#define	FFE_AB_EXT_PHY_RST_DUR_2560US 5
+#define	FFE_AB_EXT_PHY_RST_DUR_1280US 4
+#define	FFE_AB_EXT_PHY_RST_DUR_640US 3
+#define	FFE_AB_EXT_PHY_RST_DUR_320US 2
+#define	FFE_AB_EXT_PHY_RST_DUR_160US 1
+#define	FFE_AB_EXT_PHY_RST_DUR_80US 0
+#define	FRF_AB_SWRST_LBN 0
+#define	FRF_AB_SWRST_WIDTH 1
+
+/* FATAL_INTR_REG_KER: Fatal interrupt register for Kernel */
+#define	FR_AZ_FATAL_INTR_KER 0x00000230
+#define	FRF_CZ_SRAM_PERR_INT_P_KER_EN_LBN 44
+#define	FRF_CZ_SRAM_PERR_INT_P_KER_EN_WIDTH 1
+#define	FRF_AB_PCI_BUSERR_INT_KER_EN_LBN 43
+#define	FRF_AB_PCI_BUSERR_INT_KER_EN_WIDTH 1
+#define	FRF_CZ_MBU_PERR_INT_KER_EN_LBN 43
+#define	FRF_CZ_MBU_PERR_INT_KER_EN_WIDTH 1
+#define	FRF_AZ_SRAM_OOB_INT_KER_EN_LBN 42
+#define	FRF_AZ_SRAM_OOB_INT_KER_EN_WIDTH 1
+#define	FRF_AZ_BUFID_OOB_INT_KER_EN_LBN 41
+#define	FRF_AZ_BUFID_OOB_INT_KER_EN_WIDTH 1
+#define	FRF_AZ_MEM_PERR_INT_KER_EN_LBN 40
+#define	FRF_AZ_MEM_PERR_INT_KER_EN_WIDTH 1
+#define	FRF_AZ_RBUF_OWN_INT_KER_EN_LBN 39
+#define	FRF_AZ_RBUF_OWN_INT_KER_EN_WIDTH 1
+#define	FRF_AZ_TBUF_OWN_INT_KER_EN_LBN 38
+#define	FRF_AZ_TBUF_OWN_INT_KER_EN_WIDTH 1
+#define	FRF_AZ_RDESCQ_OWN_INT_KER_EN_LBN 37
+#define	FRF_AZ_RDESCQ_OWN_INT_KER_EN_WIDTH 1
+#define	FRF_AZ_TDESCQ_OWN_INT_KER_EN_LBN 36
+#define	FRF_AZ_TDESCQ_OWN_INT_KER_EN_WIDTH 1
+#define	FRF_AZ_EVQ_OWN_INT_KER_EN_LBN 35
+#define	FRF_AZ_EVQ_OWN_INT_KER_EN_WIDTH 1
+#define	FRF_AZ_EVF_OFLO_INT_KER_EN_LBN 34
+#define	FRF_AZ_EVF_OFLO_INT_KER_EN_WIDTH 1
+#define	FRF_AZ_ILL_ADR_INT_KER_EN_LBN 33
+#define	FRF_AZ_ILL_ADR_INT_KER_EN_WIDTH 1
+#define	FRF_AZ_SRM_PERR_INT_KER_EN_LBN 32
+#define	FRF_AZ_SRM_PERR_INT_KER_EN_WIDTH 1
+#define	FRF_CZ_SRAM_PERR_INT_P_KER_LBN 12
+#define	FRF_CZ_SRAM_PERR_INT_P_KER_WIDTH 1
+#define	FRF_AB_PCI_BUSERR_INT_KER_LBN 11
+#define	FRF_AB_PCI_BUSERR_INT_KER_WIDTH 1
+#define	FRF_CZ_MBU_PERR_INT_KER_LBN 11
+#define	FRF_CZ_MBU_PERR_INT_KER_WIDTH 1
+#define	FRF_AZ_SRAM_OOB_INT_KER_LBN 10
+#define	FRF_AZ_SRAM_OOB_INT_KER_WIDTH 1
+#define	FRF_AZ_BUFID_DC_OOB_INT_KER_LBN 9
+#define	FRF_AZ_BUFID_DC_OOB_INT_KER_WIDTH 1
+#define	FRF_AZ_MEM_PERR_INT_KER_LBN 8
+#define	FRF_AZ_MEM_PERR_INT_KER_WIDTH 1
+#define	FRF_AZ_RBUF_OWN_INT_KER_LBN 7
+#define	FRF_AZ_RBUF_OWN_INT_KER_WIDTH 1
+#define	FRF_AZ_TBUF_OWN_INT_KER_LBN 6
+#define	FRF_AZ_TBUF_OWN_INT_KER_WIDTH 1
+#define	FRF_AZ_RDESCQ_OWN_INT_KER_LBN 5
+#define	FRF_AZ_RDESCQ_OWN_INT_KER_WIDTH 1
+#define	FRF_AZ_TDESCQ_OWN_INT_KER_LBN 4
+#define	FRF_AZ_TDESCQ_OWN_INT_KER_WIDTH 1
+#define	FRF_AZ_EVQ_OWN_INT_KER_LBN 3
+#define	FRF_AZ_EVQ_OWN_INT_KER_WIDTH 1
+#define	FRF_AZ_EVF_OFLO_INT_KER_LBN 2
+#define	FRF_AZ_EVF_OFLO_INT_KER_WIDTH 1
+#define	FRF_AZ_ILL_ADR_INT_KER_LBN 1
+#define	FRF_AZ_ILL_ADR_INT_KER_WIDTH 1
+#define	FRF_AZ_SRM_PERR_INT_KER_LBN 0
+#define	FRF_AZ_SRM_PERR_INT_KER_WIDTH 1
+
+/* FATAL_INTR_REG_CHAR: Fatal interrupt register for Char */
+#define	FR_BZ_FATAL_INTR_CHAR 0x00000240
+#define	FRF_CZ_SRAM_PERR_INT_P_CHAR_EN_LBN 44
+#define	FRF_CZ_SRAM_PERR_INT_P_CHAR_EN_WIDTH 1
+#define	FRF_BB_PCI_BUSERR_INT_CHAR_EN_LBN 43
+#define	FRF_BB_PCI_BUSERR_INT_CHAR_EN_WIDTH 1
+#define	FRF_CZ_MBU_PERR_INT_CHAR_EN_LBN 43
+#define	FRF_CZ_MBU_PERR_INT_CHAR_EN_WIDTH 1
+#define	FRF_BZ_SRAM_OOB_INT_CHAR_EN_LBN 42
+#define	FRF_BZ_SRAM_OOB_INT_CHAR_EN_WIDTH 1
+#define	FRF_BZ_BUFID_OOB_INT_CHAR_EN_LBN 41
+#define	FRF_BZ_BUFID_OOB_INT_CHAR_EN_WIDTH 1
+#define	FRF_BZ_MEM_PERR_INT_CHAR_EN_LBN 40
+#define	FRF_BZ_MEM_PERR_INT_CHAR_EN_WIDTH 1
+#define	FRF_BZ_RBUF_OWN_INT_CHAR_EN_LBN 39
+#define	FRF_BZ_RBUF_OWN_INT_CHAR_EN_WIDTH 1
+#define	FRF_BZ_TBUF_OWN_INT_CHAR_EN_LBN 38
+#define	FRF_BZ_TBUF_OWN_INT_CHAR_EN_WIDTH 1
+#define	FRF_BZ_RDESCQ_OWN_INT_CHAR_EN_LBN 37
+#define	FRF_BZ_RDESCQ_OWN_INT_CHAR_EN_WIDTH 1
+#define	FRF_BZ_TDESCQ_OWN_INT_CHAR_EN_LBN 36
+#define	FRF_BZ_TDESCQ_OWN_INT_CHAR_EN_WIDTH 1
+#define	FRF_BZ_EVQ_OWN_INT_CHAR_EN_LBN 35
+#define	FRF_BZ_EVQ_OWN_INT_CHAR_EN_WIDTH 1
+#define	FRF_BZ_EVF_OFLO_INT_CHAR_EN_LBN 34
+#define	FRF_BZ_EVF_OFLO_INT_CHAR_EN_WIDTH 1
+#define	FRF_BZ_ILL_ADR_INT_CHAR_EN_LBN 33
+#define	FRF_BZ_ILL_ADR_INT_CHAR_EN_WIDTH 1
+#define	FRF_BZ_SRM_PERR_INT_CHAR_EN_LBN 32
+#define	FRF_BZ_SRM_PERR_INT_CHAR_EN_WIDTH 1
+#define	FRF_CZ_SRAM_PERR_INT_P_CHAR_LBN 12
+#define	FRF_CZ_SRAM_PERR_INT_P_CHAR_WIDTH 1
+#define	FRF_BB_PCI_BUSERR_INT_CHAR_LBN 11
+#define	FRF_BB_PCI_BUSERR_INT_CHAR_WIDTH 1
+#define	FRF_CZ_MBU_PERR_INT_CHAR_LBN 11
+#define	FRF_CZ_MBU_PERR_INT_CHAR_WIDTH 1
+#define	FRF_BZ_SRAM_OOB_INT_CHAR_LBN 10
+#define	FRF_BZ_SRAM_OOB_INT_CHAR_WIDTH 1
+#define	FRF_BZ_BUFID_DC_OOB_INT_CHAR_LBN 9
+#define	FRF_BZ_BUFID_DC_OOB_INT_CHAR_WIDTH 1
+#define	FRF_BZ_MEM_PERR_INT_CHAR_LBN 8
+#define	FRF_BZ_MEM_PERR_INT_CHAR_WIDTH 1
+#define	FRF_BZ_RBUF_OWN_INT_CHAR_LBN 7
+#define	FRF_BZ_RBUF_OWN_INT_CHAR_WIDTH 1
+#define	FRF_BZ_TBUF_OWN_INT_CHAR_LBN 6
+#define	FRF_BZ_TBUF_OWN_INT_CHAR_WIDTH 1
+#define	FRF_BZ_RDESCQ_OWN_INT_CHAR_LBN 5
+#define	FRF_BZ_RDESCQ_OWN_INT_CHAR_WIDTH 1
+#define	FRF_BZ_TDESCQ_OWN_INT_CHAR_LBN 4
+#define	FRF_BZ_TDESCQ_OWN_INT_CHAR_WIDTH 1
+#define	FRF_BZ_EVQ_OWN_INT_CHAR_LBN 3
+#define	FRF_BZ_EVQ_OWN_INT_CHAR_WIDTH 1
+#define	FRF_BZ_EVF_OFLO_INT_CHAR_LBN 2
+#define	FRF_BZ_EVF_OFLO_INT_CHAR_WIDTH 1
+#define	FRF_BZ_ILL_ADR_INT_CHAR_LBN 1
+#define	FRF_BZ_ILL_ADR_INT_CHAR_WIDTH 1
+#define	FRF_BZ_SRM_PERR_INT_CHAR_LBN 0
+#define	FRF_BZ_SRM_PERR_INT_CHAR_WIDTH 1
+
+/* DP_CTRL_REG: Datapath control register */
+#define	FR_BZ_DP_CTRL 0x00000250
+#define	FRF_BZ_FLS_EVQ_ID_LBN 0
+#define	FRF_BZ_FLS_EVQ_ID_WIDTH 12
+
+/* MEM_STAT_REG: Memory status register */
+#define	FR_AZ_MEM_STAT 0x00000260
+#define	FRF_AB_MEM_PERR_VEC_LBN 53
+#define	FRF_AB_MEM_PERR_VEC_WIDTH 38
+#define	FRF_AB_MBIST_CORR_LBN 38
+#define	FRF_AB_MBIST_CORR_WIDTH 15
+#define	FRF_AB_MBIST_ERR_LBN 0
+#define	FRF_AB_MBIST_ERR_WIDTH 40
+#define	FRF_CZ_MEM_PERR_VEC_LBN 0
+#define	FRF_CZ_MEM_PERR_VEC_WIDTH 35
+
+/* CS_DEBUG_REG: Debug register */
+#define	FR_AZ_CS_DEBUG 0x00000270
+#define	FRF_AB_GLB_DEBUG2_SEL_LBN 50
+#define	FRF_AB_GLB_DEBUG2_SEL_WIDTH 3
+#define	FRF_AB_DEBUG_BLK_SEL2_LBN 47
+#define	FRF_AB_DEBUG_BLK_SEL2_WIDTH 3
+#define	FRF_AB_DEBUG_BLK_SEL1_LBN 44
+#define	FRF_AB_DEBUG_BLK_SEL1_WIDTH 3
+#define	FRF_AB_DEBUG_BLK_SEL0_LBN 41
+#define	FRF_AB_DEBUG_BLK_SEL0_WIDTH 3
+#define	FRF_CZ_CS_PORT_NUM_LBN 40
+#define	FRF_CZ_CS_PORT_NUM_WIDTH 2
+#define	FRF_AB_MISC_DEBUG_ADDR_LBN 36
+#define	FRF_AB_MISC_DEBUG_ADDR_WIDTH 5
+#define	FRF_AB_SERDES_DEBUG_ADDR_LBN 31
+#define	FRF_AB_SERDES_DEBUG_ADDR_WIDTH 5
+#define	FRF_CZ_CS_PORT_FPE_LBN 1
+#define	FRF_CZ_CS_PORT_FPE_WIDTH 35
+#define	FRF_AB_EM_DEBUG_ADDR_LBN 26
+#define	FRF_AB_EM_DEBUG_ADDR_WIDTH 5
+#define	FRF_AB_SR_DEBUG_ADDR_LBN 21
+#define	FRF_AB_SR_DEBUG_ADDR_WIDTH 5
+#define	FRF_AB_EV_DEBUG_ADDR_LBN 16
+#define	FRF_AB_EV_DEBUG_ADDR_WIDTH 5
+#define	FRF_AB_RX_DEBUG_ADDR_LBN 11
+#define	FRF_AB_RX_DEBUG_ADDR_WIDTH 5
+#define	FRF_AB_TX_DEBUG_ADDR_LBN 6
+#define	FRF_AB_TX_DEBUG_ADDR_WIDTH 5
+#define	FRF_AB_CS_BIU_DEBUG_ADDR_LBN 1
+#define	FRF_AB_CS_BIU_DEBUG_ADDR_WIDTH 5
+#define	FRF_AZ_CS_DEBUG_EN_LBN 0
+#define	FRF_AZ_CS_DEBUG_EN_WIDTH 1
+
+/* DRIVER_REG: Driver scratch register [0-7] */
+#define	FR_AZ_DRIVER 0x00000280
+#define	FR_AZ_DRIVER_STEP 16
+#define	FR_AZ_DRIVER_ROWS 8
+#define	FRF_AZ_DRIVER_DW0_LBN 0
+#define	FRF_AZ_DRIVER_DW0_WIDTH 32
+
+/* ALTERA_BUILD_REG: Altera build register */
+#define	FR_AZ_ALTERA_BUILD 0x00000300
+#define	FRF_AZ_ALTERA_BUILD_VER_LBN 0
+#define	FRF_AZ_ALTERA_BUILD_VER_WIDTH 32
+
+/* CSR_SPARE_REG: Spare register */
+#define	FR_AZ_CSR_SPARE 0x00000310
+#define	FRF_AB_MEM_PERR_EN_LBN 64
+#define	FRF_AB_MEM_PERR_EN_WIDTH 38
+#define	FRF_CZ_MEM_PERR_EN_LBN 64
+#define	FRF_CZ_MEM_PERR_EN_WIDTH 35
+#define	FRF_AB_MEM_PERR_EN_TX_DATA_LBN 72
+#define	FRF_AB_MEM_PERR_EN_TX_DATA_WIDTH 2
+#define	FRF_AZ_CSR_SPARE_BITS_LBN 0
+#define	FRF_AZ_CSR_SPARE_BITS_WIDTH 32
+
+/* PCIE_SD_CTL0123_REG: PCIE SerDes control register 0 to 3 */
+#define	FR_AB_PCIE_SD_CTL0123 0x00000320
+#define	FRF_AB_PCIE_TESTSIG_H_LBN 96
+#define	FRF_AB_PCIE_TESTSIG_H_WIDTH 19
+#define	FRF_AB_PCIE_TESTSIG_L_LBN 64
+#define	FRF_AB_PCIE_TESTSIG_L_WIDTH 19
+#define	FRF_AB_PCIE_OFFSET_LBN 56
+#define	FRF_AB_PCIE_OFFSET_WIDTH 8
+#define	FRF_AB_PCIE_OFFSETEN_H_LBN 55
+#define	FRF_AB_PCIE_OFFSETEN_H_WIDTH 1
+#define	FRF_AB_PCIE_OFFSETEN_L_LBN 54
+#define	FRF_AB_PCIE_OFFSETEN_L_WIDTH 1
+#define	FRF_AB_PCIE_HIVMODE_H_LBN 53
+#define	FRF_AB_PCIE_HIVMODE_H_WIDTH 1
+#define	FRF_AB_PCIE_HIVMODE_L_LBN 52
+#define	FRF_AB_PCIE_HIVMODE_L_WIDTH 1
+#define	FRF_AB_PCIE_PARRESET_H_LBN 51
+#define	FRF_AB_PCIE_PARRESET_H_WIDTH 1
+#define	FRF_AB_PCIE_PARRESET_L_LBN 50
+#define	FRF_AB_PCIE_PARRESET_L_WIDTH 1
+#define	FRF_AB_PCIE_LPBKWDRV_H_LBN 49
+#define	FRF_AB_PCIE_LPBKWDRV_H_WIDTH 1
+#define	FRF_AB_PCIE_LPBKWDRV_L_LBN 48
+#define	FRF_AB_PCIE_LPBKWDRV_L_WIDTH 1
+#define	FRF_AB_PCIE_LPBK_LBN 40
+#define	FRF_AB_PCIE_LPBK_WIDTH 8
+#define	FRF_AB_PCIE_PARLPBK_LBN 32
+#define	FRF_AB_PCIE_PARLPBK_WIDTH 8
+#define	FRF_AB_PCIE_RXTERMADJ_H_LBN 30
+#define	FRF_AB_PCIE_RXTERMADJ_H_WIDTH 2
+#define	FRF_AB_PCIE_RXTERMADJ_L_LBN 28
+#define	FRF_AB_PCIE_RXTERMADJ_L_WIDTH 2
+#define	FFE_AB_PCIE_RXTERMADJ_MIN15PCNT 3
+#define	FFE_AB_PCIE_RXTERMADJ_PL10PCNT 2
+#define	FFE_AB_PCIE_RXTERMADJ_MIN17PCNT 1
+#define	FFE_AB_PCIE_RXTERMADJ_NOMNL 0
+#define	FRF_AB_PCIE_TXTERMADJ_H_LBN 26
+#define	FRF_AB_PCIE_TXTERMADJ_H_WIDTH 2
+#define	FRF_AB_PCIE_TXTERMADJ_L_LBN 24
+#define	FRF_AB_PCIE_TXTERMADJ_L_WIDTH 2
+#define	FFE_AB_PCIE_TXTERMADJ_MIN15PCNT 3
+#define	FFE_AB_PCIE_TXTERMADJ_PL10PCNT 2
+#define	FFE_AB_PCIE_TXTERMADJ_MIN17PCNT 1
+#define	FFE_AB_PCIE_TXTERMADJ_NOMNL 0
+#define	FRF_AB_PCIE_RXEQCTL_H_LBN 18
+#define	FRF_AB_PCIE_RXEQCTL_H_WIDTH 2
+#define	FRF_AB_PCIE_RXEQCTL_L_LBN 16
+#define	FRF_AB_PCIE_RXEQCTL_L_WIDTH 2
+#define	FFE_AB_PCIE_RXEQCTL_OFF_ALT 3
+#define	FFE_AB_PCIE_RXEQCTL_OFF 2
+#define	FFE_AB_PCIE_RXEQCTL_MIN 1
+#define	FFE_AB_PCIE_RXEQCTL_MAX 0
+#define	FRF_AB_PCIE_HIDRV_LBN 8
+#define	FRF_AB_PCIE_HIDRV_WIDTH 8
+#define	FRF_AB_PCIE_LODRV_LBN 0
+#define	FRF_AB_PCIE_LODRV_WIDTH 8
+
+/* PCIE_SD_CTL45_REG: PCIE SerDes control register 4 and 5 */
+#define	FR_AB_PCIE_SD_CTL45 0x00000330
+#define	FRF_AB_PCIE_DTX7_LBN 60
+#define	FRF_AB_PCIE_DTX7_WIDTH 4
+#define	FRF_AB_PCIE_DTX6_LBN 56
+#define	FRF_AB_PCIE_DTX6_WIDTH 4
+#define	FRF_AB_PCIE_DTX5_LBN 52
+#define	FRF_AB_PCIE_DTX5_WIDTH 4
+#define	FRF_AB_PCIE_DTX4_LBN 48
+#define	FRF_AB_PCIE_DTX4_WIDTH 4
+#define	FRF_AB_PCIE_DTX3_LBN 44
+#define	FRF_AB_PCIE_DTX3_WIDTH 4
+#define	FRF_AB_PCIE_DTX2_LBN 40
+#define	FRF_AB_PCIE_DTX2_WIDTH 4
+#define	FRF_AB_PCIE_DTX1_LBN 36
+#define	FRF_AB_PCIE_DTX1_WIDTH 4
+#define	FRF_AB_PCIE_DTX0_LBN 32
+#define	FRF_AB_PCIE_DTX0_WIDTH 4
+#define	FRF_AB_PCIE_DEQ7_LBN 28
+#define	FRF_AB_PCIE_DEQ7_WIDTH 4
+#define	FRF_AB_PCIE_DEQ6_LBN 24
+#define	FRF_AB_PCIE_DEQ6_WIDTH 4
+#define	FRF_AB_PCIE_DEQ5_LBN 20
+#define	FRF_AB_PCIE_DEQ5_WIDTH 4
+#define	FRF_AB_PCIE_DEQ4_LBN 16
+#define	FRF_AB_PCIE_DEQ4_WIDTH 4
+#define	FRF_AB_PCIE_DEQ3_LBN 12
+#define	FRF_AB_PCIE_DEQ3_WIDTH 4
+#define	FRF_AB_PCIE_DEQ2_LBN 8
+#define	FRF_AB_PCIE_DEQ2_WIDTH 4
+#define	FRF_AB_PCIE_DEQ1_LBN 4
+#define	FRF_AB_PCIE_DEQ1_WIDTH 4
+#define	FRF_AB_PCIE_DEQ0_LBN 0
+#define	FRF_AB_PCIE_DEQ0_WIDTH 4
+
+/* PCIE_PCS_CTL_STAT_REG: PCIE PCS control and status register */
+#define	FR_AB_PCIE_PCS_CTL_STAT 0x00000340
+#define	FRF_AB_PCIE_PRBSERRCOUNT0_H_LBN 52
+#define	FRF_AB_PCIE_PRBSERRCOUNT0_H_WIDTH 4
+#define	FRF_AB_PCIE_PRBSERRCOUNT0_L_LBN 48
+#define	FRF_AB_PCIE_PRBSERRCOUNT0_L_WIDTH 4
+#define	FRF_AB_PCIE_PRBSERR_LBN 40
+#define	FRF_AB_PCIE_PRBSERR_WIDTH 8
+#define	FRF_AB_PCIE_PRBSERRH0_LBN 32
+#define	FRF_AB_PCIE_PRBSERRH0_WIDTH 8
+#define	FRF_AB_PCIE_FASTINIT_H_LBN 15
+#define	FRF_AB_PCIE_FASTINIT_H_WIDTH 1
+#define	FRF_AB_PCIE_FASTINIT_L_LBN 14
+#define	FRF_AB_PCIE_FASTINIT_L_WIDTH 1
+#define	FRF_AB_PCIE_CTCDISABLE_H_LBN 13
+#define	FRF_AB_PCIE_CTCDISABLE_H_WIDTH 1
+#define	FRF_AB_PCIE_CTCDISABLE_L_LBN 12
+#define	FRF_AB_PCIE_CTCDISABLE_L_WIDTH 1
+#define	FRF_AB_PCIE_PRBSSYNC_H_LBN 11
+#define	FRF_AB_PCIE_PRBSSYNC_H_WIDTH 1
+#define	FRF_AB_PCIE_PRBSSYNC_L_LBN 10
+#define	FRF_AB_PCIE_PRBSSYNC_L_WIDTH 1
+#define	FRF_AB_PCIE_PRBSERRACK_H_LBN 9
+#define	FRF_AB_PCIE_PRBSERRACK_H_WIDTH 1
+#define	FRF_AB_PCIE_PRBSERRACK_L_LBN 8
+#define	FRF_AB_PCIE_PRBSERRACK_L_WIDTH 1
+#define	FRF_AB_PCIE_PRBSSEL_LBN 0
+#define	FRF_AB_PCIE_PRBSSEL_WIDTH 8
+
+/* DEBUG_DATA_OUT_REG: Live Debug and Debug 2 out ports */
+#define	FR_BB_DEBUG_DATA_OUT 0x00000350
+#define	FRF_BB_DEBUG2_PORT_LBN 25
+#define	FRF_BB_DEBUG2_PORT_WIDTH 15
+#define	FRF_BB_DEBUG1_PORT_LBN 0
+#define	FRF_BB_DEBUG1_PORT_WIDTH 25
+
+/* EVQ_RPTR_REGP0: Event queue read pointer register */
+#define	FR_BZ_EVQ_RPTR_P0 0x00000400
+#define	FR_BZ_EVQ_RPTR_P0_STEP 8192
+#define	FR_BZ_EVQ_RPTR_P0_ROWS 1024
+/* EVQ_RPTR_REG_KER: Event queue read pointer register */
+#define	FR_AA_EVQ_RPTR_KER 0x00011b00
+#define	FR_AA_EVQ_RPTR_KER_STEP 4
+#define	FR_AA_EVQ_RPTR_KER_ROWS 4
+/* EVQ_RPTR_REG: Event queue read pointer register */
+#define	FR_BZ_EVQ_RPTR 0x00fa0000
+#define	FR_BZ_EVQ_RPTR_STEP 16
+#define	FR_BB_EVQ_RPTR_ROWS 4096
+#define	FR_CZ_EVQ_RPTR_ROWS 1024
+/* EVQ_RPTR_REGP123: Event queue read pointer register */
+#define	FR_BB_EVQ_RPTR_P123 0x01000400
+#define	FR_BB_EVQ_RPTR_P123_STEP 8192
+#define	FR_BB_EVQ_RPTR_P123_ROWS 3072
+#define	FRF_AZ_EVQ_RPTR_VLD_LBN 15
+#define	FRF_AZ_EVQ_RPTR_VLD_WIDTH 1
+#define	FRF_AZ_EVQ_RPTR_LBN 0
+#define	FRF_AZ_EVQ_RPTR_WIDTH 15
+
+/* TIMER_COMMAND_REGP0: Timer Command Registers */
+#define	FR_BZ_TIMER_COMMAND_P0 0x00000420
+#define	FR_BZ_TIMER_COMMAND_P0_STEP 8192
+#define	FR_BZ_TIMER_COMMAND_P0_ROWS 1024
+/* TIMER_COMMAND_REG_KER: Timer Command Registers */
+#define	FR_AA_TIMER_COMMAND_KER 0x00000420
+#define	FR_AA_TIMER_COMMAND_KER_STEP 8192
+#define	FR_AA_TIMER_COMMAND_KER_ROWS 4
+/* TIMER_COMMAND_REGP123: Timer Command Registers */
+#define	FR_BB_TIMER_COMMAND_P123 0x01000420
+#define	FR_BB_TIMER_COMMAND_P123_STEP 8192
+#define	FR_BB_TIMER_COMMAND_P123_ROWS 3072
+#define	FRF_CZ_TC_TIMER_MODE_LBN 14
+#define	FRF_CZ_TC_TIMER_MODE_WIDTH 2
+#define	FRF_AB_TC_TIMER_MODE_LBN 12
+#define	FRF_AB_TC_TIMER_MODE_WIDTH 2
+#define	FRF_CZ_TC_TIMER_VAL_LBN 0
+#define	FRF_CZ_TC_TIMER_VAL_WIDTH 14
+#define	FRF_AB_TC_TIMER_VAL_LBN 0
+#define	FRF_AB_TC_TIMER_VAL_WIDTH 12
+
+/* DRV_EV_REG: Driver generated event register */
+#define	FR_AZ_DRV_EV 0x00000440
+#define	FRF_AZ_DRV_EV_QID_LBN 64
+#define	FRF_AZ_DRV_EV_QID_WIDTH 12
+#define	FRF_AZ_DRV_EV_DATA_LBN 0
+#define	FRF_AZ_DRV_EV_DATA_WIDTH 64
+
+/* EVQ_CTL_REG: Event queue control register */
+#define	FR_AZ_EVQ_CTL 0x00000450
+#define	FRF_CZ_RX_EVQ_WAKEUP_MASK_LBN 15
+#define	FRF_CZ_RX_EVQ_WAKEUP_MASK_WIDTH 10
+#define	FRF_BB_RX_EVQ_WAKEUP_MASK_LBN 15
+#define	FRF_BB_RX_EVQ_WAKEUP_MASK_WIDTH 6
+#define	FRF_AZ_EVQ_OWNERR_CTL_LBN 14
+#define	FRF_AZ_EVQ_OWNERR_CTL_WIDTH 1
+#define	FRF_AZ_EVQ_FIFO_AF_TH_LBN 7
+#define	FRF_AZ_EVQ_FIFO_AF_TH_WIDTH 7
+#define	FRF_AZ_EVQ_FIFO_NOTAF_TH_LBN 0
+#define	FRF_AZ_EVQ_FIFO_NOTAF_TH_WIDTH 7
+
+/* EVQ_CNT1_REG: Event counter 1 register */
+#define	FR_AZ_EVQ_CNT1 0x00000460
+#define	FRF_AZ_EVQ_CNT_PRE_FIFO_LBN 120
+#define	FRF_AZ_EVQ_CNT_PRE_FIFO_WIDTH 7
+#define	FRF_AZ_EVQ_CNT_TOBIU_LBN 100
+#define	FRF_AZ_EVQ_CNT_TOBIU_WIDTH 20
+#define	FRF_AZ_EVQ_TX_REQ_CNT_LBN 80
+#define	FRF_AZ_EVQ_TX_REQ_CNT_WIDTH 20
+#define	FRF_AZ_EVQ_RX_REQ_CNT_LBN 60
+#define	FRF_AZ_EVQ_RX_REQ_CNT_WIDTH 20
+#define	FRF_AZ_EVQ_EM_REQ_CNT_LBN 40
+#define	FRF_AZ_EVQ_EM_REQ_CNT_WIDTH 20
+#define	FRF_AZ_EVQ_CSR_REQ_CNT_LBN 20
+#define	FRF_AZ_EVQ_CSR_REQ_CNT_WIDTH 20
+#define	FRF_AZ_EVQ_ERR_REQ_CNT_LBN 0
+#define	FRF_AZ_EVQ_ERR_REQ_CNT_WIDTH 20
+
+/* EVQ_CNT2_REG: Event counter 2 register */
+#define	FR_AZ_EVQ_CNT2 0x00000470
+#define	FRF_AZ_EVQ_UPD_REQ_CNT_LBN 104
+#define	FRF_AZ_EVQ_UPD_REQ_CNT_WIDTH 20
+#define	FRF_AZ_EVQ_CLR_REQ_CNT_LBN 84
+#define	FRF_AZ_EVQ_CLR_REQ_CNT_WIDTH 20
+#define	FRF_AZ_EVQ_RDY_CNT_LBN 80
+#define	FRF_AZ_EVQ_RDY_CNT_WIDTH 4
+#define	FRF_AZ_EVQ_WU_REQ_CNT_LBN 60
+#define	FRF_AZ_EVQ_WU_REQ_CNT_WIDTH 20
+#define	FRF_AZ_EVQ_WET_REQ_CNT_LBN 40
+#define	FRF_AZ_EVQ_WET_REQ_CNT_WIDTH 20
+#define	FRF_AZ_EVQ_INIT_REQ_CNT_LBN 20
+#define	FRF_AZ_EVQ_INIT_REQ_CNT_WIDTH 20
+#define	FRF_AZ_EVQ_TM_REQ_CNT_LBN 0
+#define	FRF_AZ_EVQ_TM_REQ_CNT_WIDTH 20
+
+/* USR_EV_REG: Event mailbox register */
+#define	FR_CZ_USR_EV 0x00000540
+#define	FR_CZ_USR_EV_STEP 8192
+#define	FR_CZ_USR_EV_ROWS 1024
+#define	FRF_CZ_USR_EV_DATA_LBN 0
+#define	FRF_CZ_USR_EV_DATA_WIDTH 32
+
+/* BUF_TBL_CFG_REG: Buffer table configuration register */
+#define	FR_AZ_BUF_TBL_CFG 0x00000600
+#define	FRF_AZ_BUF_TBL_MODE_LBN 3
+#define	FRF_AZ_BUF_TBL_MODE_WIDTH 1
+
+/* SRM_RX_DC_CFG_REG: SRAM receive descriptor cache configuration register */
+#define	FR_AZ_SRM_RX_DC_CFG 0x00000610
+#define	FRF_AZ_SRM_CLK_TMP_EN_LBN 21
+#define	FRF_AZ_SRM_CLK_TMP_EN_WIDTH 1
+#define	FRF_AZ_SRM_RX_DC_BASE_ADR_LBN 0
+#define	FRF_AZ_SRM_RX_DC_BASE_ADR_WIDTH 21
+
+/* SRM_TX_DC_CFG_REG: SRAM transmit descriptor cache configuration register */
+#define	FR_AZ_SRM_TX_DC_CFG 0x00000620
+#define	FRF_AZ_SRM_TX_DC_BASE_ADR_LBN 0
+#define	FRF_AZ_SRM_TX_DC_BASE_ADR_WIDTH 21
+
+/* SRM_CFG_REG: SRAM configuration register */
+#define	FR_AZ_SRM_CFG 0x00000630
+#define	FRF_AZ_SRM_OOB_ADR_INTEN_LBN 5
+#define	FRF_AZ_SRM_OOB_ADR_INTEN_WIDTH 1
+#define	FRF_AZ_SRM_OOB_BUF_INTEN_LBN 4
+#define	FRF_AZ_SRM_OOB_BUF_INTEN_WIDTH 1
+#define	FRF_AZ_SRM_INIT_EN_LBN 3
+#define	FRF_AZ_SRM_INIT_EN_WIDTH 1
+#define	FRF_AZ_SRM_NUM_BANK_LBN 2
+#define	FRF_AZ_SRM_NUM_BANK_WIDTH 1
+#define	FRF_AZ_SRM_BANK_SIZE_LBN 0
+#define	FRF_AZ_SRM_BANK_SIZE_WIDTH 2
+
+/* BUF_TBL_UPD_REG: Buffer table update register */
+#define	FR_AZ_BUF_TBL_UPD 0x00000650
+#define	FRF_AZ_BUF_UPD_CMD_LBN 63
+#define	FRF_AZ_BUF_UPD_CMD_WIDTH 1
+#define	FRF_AZ_BUF_CLR_CMD_LBN 62
+#define	FRF_AZ_BUF_CLR_CMD_WIDTH 1
+#define	FRF_AZ_BUF_CLR_END_ID_LBN 32
+#define	FRF_AZ_BUF_CLR_END_ID_WIDTH 20
+#define	FRF_AZ_BUF_CLR_START_ID_LBN 0
+#define	FRF_AZ_BUF_CLR_START_ID_WIDTH 20
+
+/* SRM_UPD_EVQ_REG: Buffer table update register */
+#define	FR_AZ_SRM_UPD_EVQ 0x00000660
+#define	FRF_AZ_SRM_UPD_EVQ_ID_LBN 0
+#define	FRF_AZ_SRM_UPD_EVQ_ID_WIDTH 12
+
+/* SRAM_PARITY_REG: SRAM parity register. */
+#define	FR_AZ_SRAM_PARITY 0x00000670
+#define	FRF_CZ_BYPASS_ECC_LBN 3
+#define	FRF_CZ_BYPASS_ECC_WIDTH 1
+#define	FRF_CZ_SEC_INT_LBN 2
+#define	FRF_CZ_SEC_INT_WIDTH 1
+#define	FRF_CZ_FORCE_SRAM_DOUBLE_ERR_LBN 1
+#define	FRF_CZ_FORCE_SRAM_DOUBLE_ERR_WIDTH 1
+#define	FRF_AB_FORCE_SRAM_PERR_LBN 0
+#define	FRF_AB_FORCE_SRAM_PERR_WIDTH 1
+#define	FRF_CZ_FORCE_SRAM_SINGLE_ERR_LBN 0
+#define	FRF_CZ_FORCE_SRAM_SINGLE_ERR_WIDTH 1
+
+/* RX_CFG_REG: Receive configuration register */
+#define	FR_AZ_RX_CFG 0x00000800
+#define	FRF_CZ_RX_MIN_KBUF_SIZE_LBN 72
+#define	FRF_CZ_RX_MIN_KBUF_SIZE_WIDTH 14
+#define	FRF_CZ_RX_HDR_SPLIT_EN_LBN 71
+#define	FRF_CZ_RX_HDR_SPLIT_EN_WIDTH 1
+#define	FRF_CZ_RX_HDR_SPLIT_PLD_BUF_SIZE_LBN 62
+#define	FRF_CZ_RX_HDR_SPLIT_PLD_BUF_SIZE_WIDTH 9
+#define	FRF_CZ_RX_HDR_SPLIT_HDR_BUF_SIZE_LBN 53
+#define	FRF_CZ_RX_HDR_SPLIT_HDR_BUF_SIZE_WIDTH 9
+#define	FRF_CZ_RX_PRE_RFF_IPG_LBN 49
+#define	FRF_CZ_RX_PRE_RFF_IPG_WIDTH 4
+#define	FRF_BZ_RX_TCP_SUP_LBN 48
+#define	FRF_BZ_RX_TCP_SUP_WIDTH 1
+#define	FRF_BZ_RX_INGR_EN_LBN 47
+#define	FRF_BZ_RX_INGR_EN_WIDTH 1
+#define	FRF_BZ_RX_IP_HASH_LBN 46
+#define	FRF_BZ_RX_IP_HASH_WIDTH 1
+#define	FRF_BZ_RX_HASH_ALG_LBN 45
+#define	FRF_BZ_RX_HASH_ALG_WIDTH 1
+#define	FRF_BZ_RX_HASH_INSRT_HDR_LBN 44
+#define	FRF_BZ_RX_HASH_INSRT_HDR_WIDTH 1
+#define	FRF_BZ_RX_DESC_PUSH_EN_LBN 43
+#define	FRF_BZ_RX_DESC_PUSH_EN_WIDTH 1
+#define	FRF_BZ_RX_RDW_PATCH_EN_LBN 42
+#define	FRF_BZ_RX_RDW_PATCH_EN_WIDTH 1
+#define	FRF_BB_RX_PCI_BURST_SIZE_LBN 39
+#define	FRF_BB_RX_PCI_BURST_SIZE_WIDTH 3
+#define	FRF_BZ_RX_OWNERR_CTL_LBN 38
+#define	FRF_BZ_RX_OWNERR_CTL_WIDTH 1
+#define	FRF_BZ_RX_XON_TX_TH_LBN 33
+#define	FRF_BZ_RX_XON_TX_TH_WIDTH 5
+#define	FRF_AA_RX_DESC_PUSH_EN_LBN 35
+#define	FRF_AA_RX_DESC_PUSH_EN_WIDTH 1
+#define	FRF_AA_RX_RDW_PATCH_EN_LBN 34
+#define	FRF_AA_RX_RDW_PATCH_EN_WIDTH 1
+#define	FRF_AA_RX_PCI_BURST_SIZE_LBN 31
+#define	FRF_AA_RX_PCI_BURST_SIZE_WIDTH 3
+#define	FRF_BZ_RX_XOFF_TX_TH_LBN 28
+#define	FRF_BZ_RX_XOFF_TX_TH_WIDTH 5
+#define	FRF_AA_RX_OWNERR_CTL_LBN 30
+#define	FRF_AA_RX_OWNERR_CTL_WIDTH 1
+#define	FRF_AA_RX_XON_TX_TH_LBN 25
+#define	FRF_AA_RX_XON_TX_TH_WIDTH 5
+#define	FRF_BZ_RX_USR_BUF_SIZE_LBN 19
+#define	FRF_BZ_RX_USR_BUF_SIZE_WIDTH 9
+#define	FRF_AA_RX_XOFF_TX_TH_LBN 20
+#define	FRF_AA_RX_XOFF_TX_TH_WIDTH 5
+#define	FRF_AA_RX_USR_BUF_SIZE_LBN 11
+#define	FRF_AA_RX_USR_BUF_SIZE_WIDTH 9
+#define	FRF_BZ_RX_XON_MAC_TH_LBN 10
+#define	FRF_BZ_RX_XON_MAC_TH_WIDTH 9
+#define	FRF_AA_RX_XON_MAC_TH_LBN 6
+#define	FRF_AA_RX_XON_MAC_TH_WIDTH 5
+#define	FRF_BZ_RX_XOFF_MAC_TH_LBN 1
+#define	FRF_BZ_RX_XOFF_MAC_TH_WIDTH 9
+#define	FRF_AA_RX_XOFF_MAC_TH_LBN 1
+#define	FRF_AA_RX_XOFF_MAC_TH_WIDTH 5
+#define	FRF_AZ_RX_XOFF_MAC_EN_LBN 0
+#define	FRF_AZ_RX_XOFF_MAC_EN_WIDTH 1
+
+/* RX_FILTER_CTL_REG: Receive filter control registers */
+#define	FR_BZ_RX_FILTER_CTL 0x00000810
+#define	FRF_CZ_ETHERNET_WILDCARD_SEARCH_LIMIT_LBN 94
+#define	FRF_CZ_ETHERNET_WILDCARD_SEARCH_LIMIT_WIDTH 8
+#define	FRF_CZ_ETHERNET_FULL_SEARCH_LIMIT_LBN 86
+#define	FRF_CZ_ETHERNET_FULL_SEARCH_LIMIT_WIDTH 8
+#define	FRF_CZ_RX_FILTER_ALL_VLAN_ETHERTYPES_LBN 85
+#define	FRF_CZ_RX_FILTER_ALL_VLAN_ETHERTYPES_WIDTH 1
+#define	FRF_CZ_RX_VLAN_MATCH_ETHERTYPE_LBN 69
+#define	FRF_CZ_RX_VLAN_MATCH_ETHERTYPE_WIDTH 16
+#define	FRF_CZ_MULTICAST_NOMATCH_Q_ID_LBN 57
+#define	FRF_CZ_MULTICAST_NOMATCH_Q_ID_WIDTH 12
+#define	FRF_CZ_MULTICAST_NOMATCH_RSS_ENABLED_LBN 56
+#define	FRF_CZ_MULTICAST_NOMATCH_RSS_ENABLED_WIDTH 1
+#define	FRF_CZ_MULTICAST_NOMATCH_IP_OVERRIDE_LBN 55
+#define	FRF_CZ_MULTICAST_NOMATCH_IP_OVERRIDE_WIDTH 1
+#define	FRF_CZ_UNICAST_NOMATCH_Q_ID_LBN 43
+#define	FRF_CZ_UNICAST_NOMATCH_Q_ID_WIDTH 12
+#define	FRF_CZ_UNICAST_NOMATCH_RSS_ENABLED_LBN 42
+#define	FRF_CZ_UNICAST_NOMATCH_RSS_ENABLED_WIDTH 1
+#define	FRF_CZ_UNICAST_NOMATCH_IP_OVERRIDE_LBN 41
+#define	FRF_CZ_UNICAST_NOMATCH_IP_OVERRIDE_WIDTH 1
+#define	FRF_BZ_SCATTER_ENBL_NO_MATCH_Q_LBN 40
+#define	FRF_BZ_SCATTER_ENBL_NO_MATCH_Q_WIDTH 1
+#define	FRF_BZ_UDP_FULL_SRCH_LIMIT_LBN 32
+#define	FRF_BZ_UDP_FULL_SRCH_LIMIT_WIDTH 8
+#define	FRF_BZ_NUM_KER_LBN 24
+#define	FRF_BZ_NUM_KER_WIDTH 2
+#define	FRF_BZ_UDP_WILD_SRCH_LIMIT_LBN 16
+#define	FRF_BZ_UDP_WILD_SRCH_LIMIT_WIDTH 8
+#define	FRF_BZ_TCP_WILD_SRCH_LIMIT_LBN 8
+#define	FRF_BZ_TCP_WILD_SRCH_LIMIT_WIDTH 8
+#define	FRF_BZ_TCP_FULL_SRCH_LIMIT_LBN 0
+#define	FRF_BZ_TCP_FULL_SRCH_LIMIT_WIDTH 8
+
+/* RX_FLUSH_DESCQ_REG: Receive flush descriptor queue register */
+#define	FR_AZ_RX_FLUSH_DESCQ 0x00000820
+#define	FRF_AZ_RX_FLUSH_DESCQ_CMD_LBN 24
+#define	FRF_AZ_RX_FLUSH_DESCQ_CMD_WIDTH 1
+#define	FRF_AZ_RX_FLUSH_DESCQ_LBN 0
+#define	FRF_AZ_RX_FLUSH_DESCQ_WIDTH 12
+
+/* RX_DESC_UPD_REGP0: Receive descriptor update register. */
+#define	FR_BZ_RX_DESC_UPD_P0 0x00000830
+#define	FR_BZ_RX_DESC_UPD_P0_STEP 8192
+#define	FR_BZ_RX_DESC_UPD_P0_ROWS 1024
+/* RX_DESC_UPD_REG_KER: Receive descriptor update register. */
+#define	FR_AA_RX_DESC_UPD_KER 0x00000830
+#define	FR_AA_RX_DESC_UPD_KER_STEP 8192
+#define	FR_AA_RX_DESC_UPD_KER_ROWS 4
+/* RX_DESC_UPD_REGP123: Receive descriptor update register. */
+#define	FR_BB_RX_DESC_UPD_P123 0x01000830
+#define	FR_BB_RX_DESC_UPD_P123_STEP 8192
+#define	FR_BB_RX_DESC_UPD_P123_ROWS 3072
+#define	FRF_AZ_RX_DESC_WPTR_LBN 96
+#define	FRF_AZ_RX_DESC_WPTR_WIDTH 12
+#define	FRF_AZ_RX_DESC_PUSH_CMD_LBN 95
+#define	FRF_AZ_RX_DESC_PUSH_CMD_WIDTH 1
+#define	FRF_AZ_RX_DESC_LBN 0
+#define	FRF_AZ_RX_DESC_WIDTH 64
+
+/* RX_DC_CFG_REG: Receive descriptor cache configuration register */
+#define	FR_AZ_RX_DC_CFG 0x00000840
+#define	FRF_AB_RX_MAX_PF_LBN 2
+#define	FRF_AB_RX_MAX_PF_WIDTH 2
+#define	FRF_AZ_RX_DC_SIZE_LBN 0
+#define	FRF_AZ_RX_DC_SIZE_WIDTH 2
+#define	FFE_AZ_RX_DC_SIZE_64 3
+#define	FFE_AZ_RX_DC_SIZE_32 2
+#define	FFE_AZ_RX_DC_SIZE_16 1
+#define	FFE_AZ_RX_DC_SIZE_8 0
+
+/* RX_DC_PF_WM_REG: Receive descriptor cache pre-fetch watermark register */
+#define	FR_AZ_RX_DC_PF_WM 0x00000850
+#define	FRF_AZ_RX_DC_PF_HWM_LBN 6
+#define	FRF_AZ_RX_DC_PF_HWM_WIDTH 6
+#define	FRF_AZ_RX_DC_PF_LWM_LBN 0
+#define	FRF_AZ_RX_DC_PF_LWM_WIDTH 6
+
+/* RX_RSS_TKEY_REG: RSS Toeplitz hash key */
+#define	FR_BZ_RX_RSS_TKEY 0x00000860
+#define	FRF_BZ_RX_RSS_TKEY_HI_LBN 64
+#define	FRF_BZ_RX_RSS_TKEY_HI_WIDTH 64
+#define	FRF_BZ_RX_RSS_TKEY_LO_LBN 0
+#define	FRF_BZ_RX_RSS_TKEY_LO_WIDTH 64
+
+/* RX_NODESC_DROP_REG: Receive dropped packet counter register */
+#define	FR_AZ_RX_NODESC_DROP 0x00000880
+#define	FRF_CZ_RX_NODESC_DROP_CNT_LBN 0
+#define	FRF_CZ_RX_NODESC_DROP_CNT_WIDTH 32
+#define	FRF_AB_RX_NODESC_DROP_CNT_LBN 0
+#define	FRF_AB_RX_NODESC_DROP_CNT_WIDTH 16
+
+/* RX_SELF_RST_REG: Receive self reset register */
+#define	FR_AA_RX_SELF_RST 0x00000890
+#define	FRF_AA_RX_ISCSI_DIS_LBN 17
+#define	FRF_AA_RX_ISCSI_DIS_WIDTH 1
+#define	FRF_AA_RX_SW_RST_REG_LBN 16
+#define	FRF_AA_RX_SW_RST_REG_WIDTH 1
+#define FRF_AA_RX_NODESC_WAIT_DIS_LBN 9
+#define FRF_AA_RX_NODESC_WAIT_DIS_WIDTH 1
+#define	FRF_AA_RX_SELF_RST_EN_LBN 8
+#define	FRF_AA_RX_SELF_RST_EN_WIDTH 1
+#define	FRF_AA_RX_MAX_PF_LAT_LBN 4
+#define	FRF_AA_RX_MAX_PF_LAT_WIDTH 4
+#define	FRF_AA_RX_MAX_LU_LAT_LBN 0
+#define	FRF_AA_RX_MAX_LU_LAT_WIDTH 4
+
+/* RX_DEBUG_REG: undocumented register */
+#define	FR_AZ_RX_DEBUG 0x000008a0
+#define	FRF_AZ_RX_DEBUG_LBN 0
+#define	FRF_AZ_RX_DEBUG_WIDTH 64
+
+/* RX_PUSH_DROP_REG: Receive descriptor push dropped counter register */
+#define	FR_AZ_RX_PUSH_DROP 0x000008b0
+#define	FRF_AZ_RX_PUSH_DROP_CNT_LBN 0
+#define	FRF_AZ_RX_PUSH_DROP_CNT_WIDTH 32
+
+/* RX_RSS_IPV6_REG1: IPv6 RSS Toeplitz hash key low bytes */
+#define	FR_CZ_RX_RSS_IPV6_REG1 0x000008d0
+#define	FRF_CZ_RX_RSS_IPV6_TKEY_LO_LBN 0
+#define	FRF_CZ_RX_RSS_IPV6_TKEY_LO_WIDTH 128
+
+/* RX_RSS_IPV6_REG2: IPv6 RSS Toeplitz hash key middle bytes */
+#define	FR_CZ_RX_RSS_IPV6_REG2 0x000008e0
+#define	FRF_CZ_RX_RSS_IPV6_TKEY_MID_LBN 0
+#define	FRF_CZ_RX_RSS_IPV6_TKEY_MID_WIDTH 128
+
+/* RX_RSS_IPV6_REG3: IPv6 RSS Toeplitz hash key upper bytes and IPv6 RSS settings */
+#define	FR_CZ_RX_RSS_IPV6_REG3 0x000008f0
+#define	FRF_CZ_RX_RSS_IPV6_THASH_ENABLE_LBN 66
+#define	FRF_CZ_RX_RSS_IPV6_THASH_ENABLE_WIDTH 1
+#define	FRF_CZ_RX_RSS_IPV6_IP_THASH_ENABLE_LBN 65
+#define	FRF_CZ_RX_RSS_IPV6_IP_THASH_ENABLE_WIDTH 1
+#define	FRF_CZ_RX_RSS_IPV6_TCP_SUPPRESS_LBN 64
+#define	FRF_CZ_RX_RSS_IPV6_TCP_SUPPRESS_WIDTH 1
+#define	FRF_CZ_RX_RSS_IPV6_TKEY_HI_LBN 0
+#define	FRF_CZ_RX_RSS_IPV6_TKEY_HI_WIDTH 64
+
+/* TX_FLUSH_DESCQ_REG: Transmit flush descriptor queue register */
+#define	FR_AZ_TX_FLUSH_DESCQ 0x00000a00
+#define	FRF_AZ_TX_FLUSH_DESCQ_CMD_LBN 12
+#define	FRF_AZ_TX_FLUSH_DESCQ_CMD_WIDTH 1
+#define	FRF_AZ_TX_FLUSH_DESCQ_LBN 0
+#define	FRF_AZ_TX_FLUSH_DESCQ_WIDTH 12
+
+/* TX_DESC_UPD_REGP0: Transmit descriptor update register. */
+#define	FR_BZ_TX_DESC_UPD_P0 0x00000a10
+#define	FR_BZ_TX_DESC_UPD_P0_STEP 8192
+#define	FR_BZ_TX_DESC_UPD_P0_ROWS 1024
+/* TX_DESC_UPD_REG_KER: Transmit descriptor update register. */
+#define	FR_AA_TX_DESC_UPD_KER 0x00000a10
+#define	FR_AA_TX_DESC_UPD_KER_STEP 8192
+#define	FR_AA_TX_DESC_UPD_KER_ROWS 8
+/* TX_DESC_UPD_REGP123: Transmit descriptor update register. */
+#define	FR_BB_TX_DESC_UPD_P123 0x01000a10
+#define	FR_BB_TX_DESC_UPD_P123_STEP 8192
+#define	FR_BB_TX_DESC_UPD_P123_ROWS 3072
+#define	FRF_AZ_TX_DESC_WPTR_LBN 96
+#define	FRF_AZ_TX_DESC_WPTR_WIDTH 12
+#define	FRF_AZ_TX_DESC_PUSH_CMD_LBN 95
+#define	FRF_AZ_TX_DESC_PUSH_CMD_WIDTH 1
+#define	FRF_AZ_TX_DESC_LBN 0
+#define	FRF_AZ_TX_DESC_WIDTH 95
+
+/* TX_DC_CFG_REG: Transmit descriptor cache configuration register */
+#define	FR_AZ_TX_DC_CFG 0x00000a20
+#define	FRF_AZ_TX_DC_SIZE_LBN 0
+#define	FRF_AZ_TX_DC_SIZE_WIDTH 2
+#define	FFE_AZ_TX_DC_SIZE_32 2
+#define	FFE_AZ_TX_DC_SIZE_16 1
+#define	FFE_AZ_TX_DC_SIZE_8 0
+
+/* TX_CHKSM_CFG_REG: Transmit checksum configuration register */
+#define	FR_AA_TX_CHKSM_CFG 0x00000a30
+#define	FRF_AA_TX_Q_CHKSM_DIS_96_127_LBN 96
+#define	FRF_AA_TX_Q_CHKSM_DIS_96_127_WIDTH 32
+#define	FRF_AA_TX_Q_CHKSM_DIS_64_95_LBN 64
+#define	FRF_AA_TX_Q_CHKSM_DIS_64_95_WIDTH 32
+#define	FRF_AA_TX_Q_CHKSM_DIS_32_63_LBN 32
+#define	FRF_AA_TX_Q_CHKSM_DIS_32_63_WIDTH 32
+#define	FRF_AA_TX_Q_CHKSM_DIS_0_31_LBN 0
+#define	FRF_AA_TX_Q_CHKSM_DIS_0_31_WIDTH 32
+
+/* TX_CFG_REG: Transmit configuration register */
+#define	FR_AZ_TX_CFG 0x00000a50
+#define	FRF_CZ_TX_CONT_LOOKUP_THRESH_RANGE_LBN 114
+#define	FRF_CZ_TX_CONT_LOOKUP_THRESH_RANGE_WIDTH 8
+#define	FRF_CZ_TX_FILTER_TEST_MODE_BIT_LBN 113
+#define	FRF_CZ_TX_FILTER_TEST_MODE_BIT_WIDTH 1
+#define	FRF_CZ_TX_ETH_FILTER_WILD_SEARCH_RANGE_LBN 105
+#define	FRF_CZ_TX_ETH_FILTER_WILD_SEARCH_RANGE_WIDTH 8
+#define	FRF_CZ_TX_ETH_FILTER_FULL_SEARCH_RANGE_LBN 97
+#define	FRF_CZ_TX_ETH_FILTER_FULL_SEARCH_RANGE_WIDTH 8
+#define	FRF_CZ_TX_UDPIP_FILTER_WILD_SEARCH_RANGE_LBN 89
+#define	FRF_CZ_TX_UDPIP_FILTER_WILD_SEARCH_RANGE_WIDTH 8
+#define	FRF_CZ_TX_UDPIP_FILTER_FULL_SEARCH_RANGE_LBN 81
+#define	FRF_CZ_TX_UDPIP_FILTER_FULL_SEARCH_RANGE_WIDTH 8
+#define	FRF_CZ_TX_TCPIP_FILTER_WILD_SEARCH_RANGE_LBN 73
+#define	FRF_CZ_TX_TCPIP_FILTER_WILD_SEARCH_RANGE_WIDTH 8
+#define	FRF_CZ_TX_TCPIP_FILTER_FULL_SEARCH_RANGE_LBN 65
+#define	FRF_CZ_TX_TCPIP_FILTER_FULL_SEARCH_RANGE_WIDTH 8
+#define	FRF_CZ_TX_FILTER_ALL_VLAN_ETHERTYPES_BIT_LBN 64
+#define	FRF_CZ_TX_FILTER_ALL_VLAN_ETHERTYPES_BIT_WIDTH 1
+#define	FRF_CZ_TX_VLAN_MATCH_ETHERTYPE_RANGE_LBN 48
+#define	FRF_CZ_TX_VLAN_MATCH_ETHERTYPE_RANGE_WIDTH 16
+#define	FRF_CZ_TX_FILTER_EN_BIT_LBN 47
+#define	FRF_CZ_TX_FILTER_EN_BIT_WIDTH 1
+#define	FRF_AZ_TX_IP_ID_P0_OFS_LBN 16
+#define	FRF_AZ_TX_IP_ID_P0_OFS_WIDTH 15
+#define	FRF_AZ_TX_NO_EOP_DISC_EN_LBN 5
+#define	FRF_AZ_TX_NO_EOP_DISC_EN_WIDTH 1
+#define	FRF_AZ_TX_P1_PRI_EN_LBN 4
+#define	FRF_AZ_TX_P1_PRI_EN_WIDTH 1
+#define	FRF_AZ_TX_OWNERR_CTL_LBN 2
+#define	FRF_AZ_TX_OWNERR_CTL_WIDTH 1
+#define	FRF_AA_TX_NON_IP_DROP_DIS_LBN 1
+#define	FRF_AA_TX_NON_IP_DROP_DIS_WIDTH 1
+#define	FRF_AZ_TX_IP_ID_REP_EN_LBN 0
+#define	FRF_AZ_TX_IP_ID_REP_EN_WIDTH 1
+
+/* TX_PUSH_DROP_REG: Transmit push dropped register */
+#define	FR_AZ_TX_PUSH_DROP 0x00000a60
+#define	FRF_AZ_TX_PUSH_DROP_CNT_LBN 0
+#define	FRF_AZ_TX_PUSH_DROP_CNT_WIDTH 32
+
+/* TX_RESERVED_REG: Transmit configuration register */
+#define	FR_AZ_TX_RESERVED 0x00000a80
+#define	FRF_AZ_TX_EVT_CNT_LBN 121
+#define	FRF_AZ_TX_EVT_CNT_WIDTH 7
+#define	FRF_AZ_TX_PREF_AGE_CNT_LBN 119
+#define	FRF_AZ_TX_PREF_AGE_CNT_WIDTH 2
+#define	FRF_AZ_TX_RD_COMP_TMR_LBN 96
+#define	FRF_AZ_TX_RD_COMP_TMR_WIDTH 23
+#define	FRF_AZ_TX_PUSH_EN_LBN 89
+#define	FRF_AZ_TX_PUSH_EN_WIDTH 1
+#define	FRF_AZ_TX_PUSH_CHK_DIS_LBN 88
+#define	FRF_AZ_TX_PUSH_CHK_DIS_WIDTH 1
+#define	FRF_AZ_TX_D_FF_FULL_P0_LBN 85
+#define	FRF_AZ_TX_D_FF_FULL_P0_WIDTH 1
+#define	FRF_AZ_TX_DMAR_ST_P0_LBN 81
+#define	FRF_AZ_TX_DMAR_ST_P0_WIDTH 1
+#define	FRF_AZ_TX_DMAQ_ST_LBN 78
+#define	FRF_AZ_TX_DMAQ_ST_WIDTH 1
+#define	FRF_AZ_TX_RX_SPACER_LBN 64
+#define	FRF_AZ_TX_RX_SPACER_WIDTH 8
+#define	FRF_AZ_TX_DROP_ABORT_EN_LBN 60
+#define	FRF_AZ_TX_DROP_ABORT_EN_WIDTH 1
+#define	FRF_AZ_TX_SOFT_EVT_EN_LBN 59
+#define	FRF_AZ_TX_SOFT_EVT_EN_WIDTH 1
+#define	FRF_AZ_TX_PS_EVT_DIS_LBN 58
+#define	FRF_AZ_TX_PS_EVT_DIS_WIDTH 1
+#define	FRF_AZ_TX_RX_SPACER_EN_LBN 57
+#define	FRF_AZ_TX_RX_SPACER_EN_WIDTH 1
+#define	FRF_AZ_TX_XP_TIMER_LBN 52
+#define	FRF_AZ_TX_XP_TIMER_WIDTH 5
+#define	FRF_AZ_TX_PREF_SPACER_LBN 44
+#define	FRF_AZ_TX_PREF_SPACER_WIDTH 8
+#define	FRF_AZ_TX_PREF_WD_TMR_LBN 22
+#define	FRF_AZ_TX_PREF_WD_TMR_WIDTH 22
+#define	FRF_AZ_TX_ONLY1TAG_LBN 21
+#define	FRF_AZ_TX_ONLY1TAG_WIDTH 1
+#define	FRF_AZ_TX_PREF_THRESHOLD_LBN 19
+#define	FRF_AZ_TX_PREF_THRESHOLD_WIDTH 2
+#define	FRF_AZ_TX_ONE_PKT_PER_Q_LBN 18
+#define	FRF_AZ_TX_ONE_PKT_PER_Q_WIDTH 1
+#define	FRF_AZ_TX_DIS_NON_IP_EV_LBN 17
+#define	FRF_AZ_TX_DIS_NON_IP_EV_WIDTH 1
+#define	FRF_AA_TX_DMA_FF_THR_LBN 16
+#define	FRF_AA_TX_DMA_FF_THR_WIDTH 1
+#define	FRF_AZ_TX_DMA_SPACER_LBN 8
+#define	FRF_AZ_TX_DMA_SPACER_WIDTH 8
+#define	FRF_AA_TX_TCP_DIS_LBN 7
+#define	FRF_AA_TX_TCP_DIS_WIDTH 1
+#define	FRF_BZ_TX_FLUSH_MIN_LEN_EN_LBN 7
+#define	FRF_BZ_TX_FLUSH_MIN_LEN_EN_WIDTH 1
+#define	FRF_AA_TX_IP_DIS_LBN 6
+#define	FRF_AA_TX_IP_DIS_WIDTH 1
+#define	FRF_AZ_TX_MAX_CPL_LBN 2
+#define	FRF_AZ_TX_MAX_CPL_WIDTH 2
+#define	FFE_AZ_TX_MAX_CPL_16 3
+#define	FFE_AZ_TX_MAX_CPL_8 2
+#define	FFE_AZ_TX_MAX_CPL_4 1
+#define	FFE_AZ_TX_MAX_CPL_NOLIMIT 0
+#define	FRF_AZ_TX_MAX_PREF_LBN 0
+#define	FRF_AZ_TX_MAX_PREF_WIDTH 2
+#define	FFE_AZ_TX_MAX_PREF_32 3
+#define	FFE_AZ_TX_MAX_PREF_16 2
+#define	FFE_AZ_TX_MAX_PREF_8 1
+#define	FFE_AZ_TX_MAX_PREF_OFF 0
+
+/* TX_PACE_REG: Transmit pace control register */
+#define	FR_BZ_TX_PACE 0x00000a90
+#define	FRF_BZ_TX_PACE_SB_NOT_AF_LBN 19
+#define	FRF_BZ_TX_PACE_SB_NOT_AF_WIDTH 10
+#define	FRF_BZ_TX_PACE_SB_AF_LBN 9
+#define	FRF_BZ_TX_PACE_SB_AF_WIDTH 10
+#define	FRF_BZ_TX_PACE_FB_BASE_LBN 5
+#define	FRF_BZ_TX_PACE_FB_BASE_WIDTH 4
+#define	FRF_BZ_TX_PACE_BIN_TH_LBN 0
+#define	FRF_BZ_TX_PACE_BIN_TH_WIDTH 5
+
+/* TX_PACE_DROP_QID_REG: PACE Drop QID Counter */
+#define	FR_BZ_TX_PACE_DROP_QID 0x00000aa0
+#define	FRF_BZ_TX_PACE_QID_DRP_CNT_LBN 0
+#define	FRF_BZ_TX_PACE_QID_DRP_CNT_WIDTH 16
+
+/* TX_VLAN_REG: Transmit VLAN tag register */
+#define	FR_BB_TX_VLAN 0x00000ae0
+#define	FRF_BB_TX_VLAN_EN_LBN 127
+#define	FRF_BB_TX_VLAN_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN7_PORT1_EN_LBN 125
+#define	FRF_BB_TX_VLAN7_PORT1_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN7_PORT0_EN_LBN 124
+#define	FRF_BB_TX_VLAN7_PORT0_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN7_LBN 112
+#define	FRF_BB_TX_VLAN7_WIDTH 12
+#define	FRF_BB_TX_VLAN6_PORT1_EN_LBN 109
+#define	FRF_BB_TX_VLAN6_PORT1_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN6_PORT0_EN_LBN 108
+#define	FRF_BB_TX_VLAN6_PORT0_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN6_LBN 96
+#define	FRF_BB_TX_VLAN6_WIDTH 12
+#define	FRF_BB_TX_VLAN5_PORT1_EN_LBN 93
+#define	FRF_BB_TX_VLAN5_PORT1_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN5_PORT0_EN_LBN 92
+#define	FRF_BB_TX_VLAN5_PORT0_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN5_LBN 80
+#define	FRF_BB_TX_VLAN5_WIDTH 12
+#define	FRF_BB_TX_VLAN4_PORT1_EN_LBN 77
+#define	FRF_BB_TX_VLAN4_PORT1_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN4_PORT0_EN_LBN 76
+#define	FRF_BB_TX_VLAN4_PORT0_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN4_LBN 64
+#define	FRF_BB_TX_VLAN4_WIDTH 12
+#define	FRF_BB_TX_VLAN3_PORT1_EN_LBN 61
+#define	FRF_BB_TX_VLAN3_PORT1_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN3_PORT0_EN_LBN 60
+#define	FRF_BB_TX_VLAN3_PORT0_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN3_LBN 48
+#define	FRF_BB_TX_VLAN3_WIDTH 12
+#define	FRF_BB_TX_VLAN2_PORT1_EN_LBN 45
+#define	FRF_BB_TX_VLAN2_PORT1_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN2_PORT0_EN_LBN 44
+#define	FRF_BB_TX_VLAN2_PORT0_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN2_LBN 32
+#define	FRF_BB_TX_VLAN2_WIDTH 12
+#define	FRF_BB_TX_VLAN1_PORT1_EN_LBN 29
+#define	FRF_BB_TX_VLAN1_PORT1_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN1_PORT0_EN_LBN 28
+#define	FRF_BB_TX_VLAN1_PORT0_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN1_LBN 16
+#define	FRF_BB_TX_VLAN1_WIDTH 12
+#define	FRF_BB_TX_VLAN0_PORT1_EN_LBN 13
+#define	FRF_BB_TX_VLAN0_PORT1_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN0_PORT0_EN_LBN 12
+#define	FRF_BB_TX_VLAN0_PORT0_EN_WIDTH 1
+#define	FRF_BB_TX_VLAN0_LBN 0
+#define	FRF_BB_TX_VLAN0_WIDTH 12
+
+/* TX_IPFIL_PORTEN_REG: Transmit filter control register */
+#define	FR_BZ_TX_IPFIL_PORTEN 0x00000af0
+#define	FRF_BZ_TX_MADR0_FIL_EN_LBN 64
+#define	FRF_BZ_TX_MADR0_FIL_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL31_PORT_EN_LBN 62
+#define	FRF_BB_TX_IPFIL31_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL30_PORT_EN_LBN 60
+#define	FRF_BB_TX_IPFIL30_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL29_PORT_EN_LBN 58
+#define	FRF_BB_TX_IPFIL29_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL28_PORT_EN_LBN 56
+#define	FRF_BB_TX_IPFIL28_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL27_PORT_EN_LBN 54
+#define	FRF_BB_TX_IPFIL27_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL26_PORT_EN_LBN 52
+#define	FRF_BB_TX_IPFIL26_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL25_PORT_EN_LBN 50
+#define	FRF_BB_TX_IPFIL25_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL24_PORT_EN_LBN 48
+#define	FRF_BB_TX_IPFIL24_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL23_PORT_EN_LBN 46
+#define	FRF_BB_TX_IPFIL23_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL22_PORT_EN_LBN 44
+#define	FRF_BB_TX_IPFIL22_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL21_PORT_EN_LBN 42
+#define	FRF_BB_TX_IPFIL21_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL20_PORT_EN_LBN 40
+#define	FRF_BB_TX_IPFIL20_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL19_PORT_EN_LBN 38
+#define	FRF_BB_TX_IPFIL19_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL18_PORT_EN_LBN 36
+#define	FRF_BB_TX_IPFIL18_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL17_PORT_EN_LBN 34
+#define	FRF_BB_TX_IPFIL17_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL16_PORT_EN_LBN 32
+#define	FRF_BB_TX_IPFIL16_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL15_PORT_EN_LBN 30
+#define	FRF_BB_TX_IPFIL15_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL14_PORT_EN_LBN 28
+#define	FRF_BB_TX_IPFIL14_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL13_PORT_EN_LBN 26
+#define	FRF_BB_TX_IPFIL13_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL12_PORT_EN_LBN 24
+#define	FRF_BB_TX_IPFIL12_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL11_PORT_EN_LBN 22
+#define	FRF_BB_TX_IPFIL11_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL10_PORT_EN_LBN 20
+#define	FRF_BB_TX_IPFIL10_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL9_PORT_EN_LBN 18
+#define	FRF_BB_TX_IPFIL9_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL8_PORT_EN_LBN 16
+#define	FRF_BB_TX_IPFIL8_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL7_PORT_EN_LBN 14
+#define	FRF_BB_TX_IPFIL7_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL6_PORT_EN_LBN 12
+#define	FRF_BB_TX_IPFIL6_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL5_PORT_EN_LBN 10
+#define	FRF_BB_TX_IPFIL5_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL4_PORT_EN_LBN 8
+#define	FRF_BB_TX_IPFIL4_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL3_PORT_EN_LBN 6
+#define	FRF_BB_TX_IPFIL3_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL2_PORT_EN_LBN 4
+#define	FRF_BB_TX_IPFIL2_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL1_PORT_EN_LBN 2
+#define	FRF_BB_TX_IPFIL1_PORT_EN_WIDTH 1
+#define	FRF_BB_TX_IPFIL0_PORT_EN_LBN 0
+#define	FRF_BB_TX_IPFIL0_PORT_EN_WIDTH 1
+
+/* TX_IPFIL_TBL: Transmit IP source address filter table */
+#define	FR_BB_TX_IPFIL_TBL 0x00000b00
+#define	FR_BB_TX_IPFIL_TBL_STEP 16
+#define	FR_BB_TX_IPFIL_TBL_ROWS 16
+#define	FRF_BB_TX_IPFIL_MASK_1_LBN 96
+#define	FRF_BB_TX_IPFIL_MASK_1_WIDTH 32
+#define	FRF_BB_TX_IP_SRC_ADR_1_LBN 64
+#define	FRF_BB_TX_IP_SRC_ADR_1_WIDTH 32
+#define	FRF_BB_TX_IPFIL_MASK_0_LBN 32
+#define	FRF_BB_TX_IPFIL_MASK_0_WIDTH 32
+#define	FRF_BB_TX_IP_SRC_ADR_0_LBN 0
+#define	FRF_BB_TX_IP_SRC_ADR_0_WIDTH 32
+
+/* MD_TXD_REG: PHY management transmit data register */
+#define	FR_AB_MD_TXD 0x00000c00
+#define	FRF_AB_MD_TXD_LBN 0
+#define	FRF_AB_MD_TXD_WIDTH 16
+
+/* MD_RXD_REG: PHY management receive data register */
+#define	FR_AB_MD_RXD 0x00000c10
+#define	FRF_AB_MD_RXD_LBN 0
+#define	FRF_AB_MD_RXD_WIDTH 16
+
+/* MD_CS_REG: PHY management configuration & status register */
+#define	FR_AB_MD_CS 0x00000c20
+#define	FRF_AB_MD_RD_EN_CMD_LBN 15
+#define	FRF_AB_MD_RD_EN_CMD_WIDTH 1
+#define	FRF_AB_MD_WR_EN_CMD_LBN 14
+#define	FRF_AB_MD_WR_EN_CMD_WIDTH 1
+#define	FRF_AB_MD_ADDR_CMD_LBN 13
+#define	FRF_AB_MD_ADDR_CMD_WIDTH 1
+#define	FRF_AB_MD_PT_LBN 7
+#define	FRF_AB_MD_PT_WIDTH 3
+#define	FRF_AB_MD_PL_LBN 6
+#define	FRF_AB_MD_PL_WIDTH 1
+#define	FRF_AB_MD_INT_CLR_LBN 5
+#define	FRF_AB_MD_INT_CLR_WIDTH 1
+#define	FRF_AB_MD_GC_LBN 4
+#define	FRF_AB_MD_GC_WIDTH 1
+#define	FRF_AB_MD_PRSP_LBN 3
+#define	FRF_AB_MD_PRSP_WIDTH 1
+#define	FRF_AB_MD_RIC_LBN 2
+#define	FRF_AB_MD_RIC_WIDTH 1
+#define	FRF_AB_MD_RDC_LBN 1
+#define	FRF_AB_MD_RDC_WIDTH 1
+#define	FRF_AB_MD_WRC_LBN 0
+#define	FRF_AB_MD_WRC_WIDTH 1
+
+/* MD_PHY_ADR_REG: PHY management PHY address register */
+#define	FR_AB_MD_PHY_ADR 0x00000c30
+#define	FRF_AB_MD_PHY_ADR_LBN 0
+#define	FRF_AB_MD_PHY_ADR_WIDTH 16
+
+/* MD_ID_REG: PHY management ID register */
+#define	FR_AB_MD_ID 0x00000c40
+#define	FRF_AB_MD_PRT_ADR_LBN 11
+#define	FRF_AB_MD_PRT_ADR_WIDTH 5
+#define	FRF_AB_MD_DEV_ADR_LBN 6
+#define	FRF_AB_MD_DEV_ADR_WIDTH 5
+
+/* MD_STAT_REG: PHY management status & mask register */
+#define	FR_AB_MD_STAT 0x00000c50
+#define	FRF_AB_MD_PINT_LBN 4
+#define	FRF_AB_MD_PINT_WIDTH 1
+#define	FRF_AB_MD_DONE_LBN 3
+#define	FRF_AB_MD_DONE_WIDTH 1
+#define	FRF_AB_MD_BSERR_LBN 2
+#define	FRF_AB_MD_BSERR_WIDTH 1
+#define	FRF_AB_MD_LNFL_LBN 1
+#define	FRF_AB_MD_LNFL_WIDTH 1
+#define	FRF_AB_MD_BSY_LBN 0
+#define	FRF_AB_MD_BSY_WIDTH 1
+
+/* MAC_STAT_DMA_REG: Port MAC statistical counter DMA register */
+#define	FR_AB_MAC_STAT_DMA 0x00000c60
+#define	FRF_AB_MAC_STAT_DMA_CMD_LBN 48
+#define	FRF_AB_MAC_STAT_DMA_CMD_WIDTH 1
+#define	FRF_AB_MAC_STAT_DMA_ADR_LBN 0
+#define	FRF_AB_MAC_STAT_DMA_ADR_WIDTH 48
+
+/* MAC_CTRL_REG: Port MAC control register */
+#define	FR_AB_MAC_CTRL 0x00000c80
+#define	FRF_AB_MAC_XOFF_VAL_LBN 16
+#define	FRF_AB_MAC_XOFF_VAL_WIDTH 16
+#define	FRF_BB_TXFIFO_DRAIN_EN_LBN 7
+#define	FRF_BB_TXFIFO_DRAIN_EN_WIDTH 1
+#define	FRF_AB_MAC_XG_DISTXCRC_LBN 5
+#define	FRF_AB_MAC_XG_DISTXCRC_WIDTH 1
+#define	FRF_AB_MAC_BCAD_ACPT_LBN 4
+#define	FRF_AB_MAC_BCAD_ACPT_WIDTH 1
+#define	FRF_AB_MAC_UC_PROM_LBN 3
+#define	FRF_AB_MAC_UC_PROM_WIDTH 1
+#define	FRF_AB_MAC_LINK_STATUS_LBN 2
+#define	FRF_AB_MAC_LINK_STATUS_WIDTH 1
+#define	FRF_AB_MAC_SPEED_LBN 0
+#define	FRF_AB_MAC_SPEED_WIDTH 2
+#define	FFE_AB_MAC_SPEED_10G 3
+#define	FFE_AB_MAC_SPEED_1G 2
+#define	FFE_AB_MAC_SPEED_100M 1
+#define	FFE_AB_MAC_SPEED_10M 0
+
+/* GEN_MODE_REG: General Purpose mode register (external interrupt mask) */
+#define	FR_BB_GEN_MODE 0x00000c90
+#define	FRF_BB_XFP_PHY_INT_POL_SEL_LBN 3
+#define	FRF_BB_XFP_PHY_INT_POL_SEL_WIDTH 1
+#define	FRF_BB_XG_PHY_INT_POL_SEL_LBN 2
+#define	FRF_BB_XG_PHY_INT_POL_SEL_WIDTH 1
+#define	FRF_BB_XFP_PHY_INT_MASK_LBN 1
+#define	FRF_BB_XFP_PHY_INT_MASK_WIDTH 1
+#define	FRF_BB_XG_PHY_INT_MASK_LBN 0
+#define	FRF_BB_XG_PHY_INT_MASK_WIDTH 1
+
+/* MAC_MC_HASH_REG0: Multicast address hash table */
+#define	FR_AB_MAC_MC_HASH_REG0 0x00000ca0
+#define	FRF_AB_MAC_MCAST_HASH0_LBN 0
+#define	FRF_AB_MAC_MCAST_HASH0_WIDTH 128
+
+/* MAC_MC_HASH_REG1: Multicast address hash table */
+#define	FR_AB_MAC_MC_HASH_REG1 0x00000cb0
+#define	FRF_AB_MAC_MCAST_HASH1_LBN 0
+#define	FRF_AB_MAC_MCAST_HASH1_WIDTH 128
+
+/* GM_CFG1_REG: GMAC configuration register 1 */
+#define	FR_AB_GM_CFG1 0x00000e00
+#define	FRF_AB_GM_SW_RST_LBN 31
+#define	FRF_AB_GM_SW_RST_WIDTH 1
+#define	FRF_AB_GM_SIM_RST_LBN 30
+#define	FRF_AB_GM_SIM_RST_WIDTH 1
+#define	FRF_AB_GM_RST_RX_MAC_CTL_LBN 19
+#define	FRF_AB_GM_RST_RX_MAC_CTL_WIDTH 1
+#define	FRF_AB_GM_RST_TX_MAC_CTL_LBN 18
+#define	FRF_AB_GM_RST_TX_MAC_CTL_WIDTH 1
+#define	FRF_AB_GM_RST_RX_FUNC_LBN 17
+#define	FRF_AB_GM_RST_RX_FUNC_WIDTH 1
+#define	FRF_AB_GM_RST_TX_FUNC_LBN 16
+#define	FRF_AB_GM_RST_TX_FUNC_WIDTH 1
+#define	FRF_AB_GM_LOOP_LBN 8
+#define	FRF_AB_GM_LOOP_WIDTH 1
+#define	FRF_AB_GM_RX_FC_EN_LBN 5
+#define	FRF_AB_GM_RX_FC_EN_WIDTH 1
+#define	FRF_AB_GM_TX_FC_EN_LBN 4
+#define	FRF_AB_GM_TX_FC_EN_WIDTH 1
+#define	FRF_AB_GM_SYNC_RXEN_LBN 3
+#define	FRF_AB_GM_SYNC_RXEN_WIDTH 1
+#define	FRF_AB_GM_RX_EN_LBN 2
+#define	FRF_AB_GM_RX_EN_WIDTH 1
+#define	FRF_AB_GM_SYNC_TXEN_LBN 1
+#define	FRF_AB_GM_SYNC_TXEN_WIDTH 1
+#define	FRF_AB_GM_TX_EN_LBN 0
+#define	FRF_AB_GM_TX_EN_WIDTH 1
+
+/* GM_CFG2_REG: GMAC configuration register 2 */
+#define	FR_AB_GM_CFG2 0x00000e10
+#define	FRF_AB_GM_PAMBL_LEN_LBN 12
+#define	FRF_AB_GM_PAMBL_LEN_WIDTH 4
+#define	FRF_AB_GM_IF_MODE_LBN 8
+#define	FRF_AB_GM_IF_MODE_WIDTH 2
+#define	FFE_AB_IF_MODE_BYTE_MODE 2
+#define	FFE_AB_IF_MODE_NIBBLE_MODE 1
+#define	FRF_AB_GM_HUGE_FRM_EN_LBN 5
+#define	FRF_AB_GM_HUGE_FRM_EN_WIDTH 1
+#define	FRF_AB_GM_LEN_CHK_LBN 4
+#define	FRF_AB_GM_LEN_CHK_WIDTH 1
+#define	FRF_AB_GM_PAD_CRC_EN_LBN 2
+#define	FRF_AB_GM_PAD_CRC_EN_WIDTH 1
+#define	FRF_AB_GM_CRC_EN_LBN 1
+#define	FRF_AB_GM_CRC_EN_WIDTH 1
+#define	FRF_AB_GM_FD_LBN 0
+#define	FRF_AB_GM_FD_WIDTH 1
+
+/* GM_IPG_REG: GMAC IPG register */
+#define	FR_AB_GM_IPG 0x00000e20
+#define	FRF_AB_GM_NONB2B_IPG1_LBN 24
+#define	FRF_AB_GM_NONB2B_IPG1_WIDTH 7
+#define	FRF_AB_GM_NONB2B_IPG2_LBN 16
+#define	FRF_AB_GM_NONB2B_IPG2_WIDTH 7
+#define	FRF_AB_GM_MIN_IPG_ENF_LBN 8
+#define	FRF_AB_GM_MIN_IPG_ENF_WIDTH 8
+#define	FRF_AB_GM_B2B_IPG_LBN 0
+#define	FRF_AB_GM_B2B_IPG_WIDTH 7
+
+/* GM_HD_REG: GMAC half duplex register */
+#define	FR_AB_GM_HD 0x00000e30
+#define	FRF_AB_GM_ALT_BOFF_VAL_LBN 20
+#define	FRF_AB_GM_ALT_BOFF_VAL_WIDTH 4
+#define	FRF_AB_GM_ALT_BOFF_EN_LBN 19
+#define	FRF_AB_GM_ALT_BOFF_EN_WIDTH 1
+#define	FRF_AB_GM_BP_NO_BOFF_LBN 18
+#define	FRF_AB_GM_BP_NO_BOFF_WIDTH 1
+#define	FRF_AB_GM_DIS_BOFF_LBN 17
+#define	FRF_AB_GM_DIS_BOFF_WIDTH 1
+#define	FRF_AB_GM_EXDEF_TX_EN_LBN 16
+#define	FRF_AB_GM_EXDEF_TX_EN_WIDTH 1
+#define	FRF_AB_GM_RTRY_LIMIT_LBN 12
+#define	FRF_AB_GM_RTRY_LIMIT_WIDTH 4
+#define	FRF_AB_GM_COL_WIN_LBN 0
+#define	FRF_AB_GM_COL_WIN_WIDTH 10
+
+/* GM_MAX_FLEN_REG: GMAC maximum frame length register */
+#define	FR_AB_GM_MAX_FLEN 0x00000e40
+#define	FRF_AB_GM_MAX_FLEN_LBN 0
+#define	FRF_AB_GM_MAX_FLEN_WIDTH 16
+
+/* GM_TEST_REG: GMAC test register */
+#define	FR_AB_GM_TEST 0x00000e70
+#define	FRF_AB_GM_MAX_BOFF_LBN 3
+#define	FRF_AB_GM_MAX_BOFF_WIDTH 1
+#define	FRF_AB_GM_REG_TX_FLOW_EN_LBN 2
+#define	FRF_AB_GM_REG_TX_FLOW_EN_WIDTH 1
+#define	FRF_AB_GM_TEST_PAUSE_LBN 1
+#define	FRF_AB_GM_TEST_PAUSE_WIDTH 1
+#define	FRF_AB_GM_SHORT_SLOT_LBN 0
+#define	FRF_AB_GM_SHORT_SLOT_WIDTH 1
+
+/* GM_ADR1_REG: GMAC station address register 1 */
+#define	FR_AB_GM_ADR1 0x00000f00
+#define	FRF_AB_GM_ADR_B0_LBN 24
+#define	FRF_AB_GM_ADR_B0_WIDTH 8
+#define	FRF_AB_GM_ADR_B1_LBN 16
+#define	FRF_AB_GM_ADR_B1_WIDTH 8
+#define	FRF_AB_GM_ADR_B2_LBN 8
+#define	FRF_AB_GM_ADR_B2_WIDTH 8
+#define	FRF_AB_GM_ADR_B3_LBN 0
+#define	FRF_AB_GM_ADR_B3_WIDTH 8
+
+/* GM_ADR2_REG: GMAC station address register 2 */
+#define	FR_AB_GM_ADR2 0x00000f10
+#define	FRF_AB_GM_ADR_B4_LBN 24
+#define	FRF_AB_GM_ADR_B4_WIDTH 8
+#define	FRF_AB_GM_ADR_B5_LBN 16
+#define	FRF_AB_GM_ADR_B5_WIDTH 8
+
+/* GMF_CFG0_REG: GMAC FIFO configuration register 0 */
+#define	FR_AB_GMF_CFG0 0x00000f20
+#define	FRF_AB_GMF_FTFENRPLY_LBN 20
+#define	FRF_AB_GMF_FTFENRPLY_WIDTH 1
+#define	FRF_AB_GMF_STFENRPLY_LBN 19
+#define	FRF_AB_GMF_STFENRPLY_WIDTH 1
+#define	FRF_AB_GMF_FRFENRPLY_LBN 18
+#define	FRF_AB_GMF_FRFENRPLY_WIDTH 1
+#define	FRF_AB_GMF_SRFENRPLY_LBN 17
+#define	FRF_AB_GMF_SRFENRPLY_WIDTH 1
+#define	FRF_AB_GMF_WTMENRPLY_LBN 16
+#define	FRF_AB_GMF_WTMENRPLY_WIDTH 1
+#define	FRF_AB_GMF_FTFENREQ_LBN 12
+#define	FRF_AB_GMF_FTFENREQ_WIDTH 1
+#define	FRF_AB_GMF_STFENREQ_LBN 11
+#define	FRF_AB_GMF_STFENREQ_WIDTH 1
+#define	FRF_AB_GMF_FRFENREQ_LBN 10
+#define	FRF_AB_GMF_FRFENREQ_WIDTH 1
+#define	FRF_AB_GMF_SRFENREQ_LBN 9
+#define	FRF_AB_GMF_SRFENREQ_WIDTH 1
+#define	FRF_AB_GMF_WTMENREQ_LBN 8
+#define	FRF_AB_GMF_WTMENREQ_WIDTH 1
+#define	FRF_AB_GMF_HSTRSTFT_LBN 4
+#define	FRF_AB_GMF_HSTRSTFT_WIDTH 1
+#define	FRF_AB_GMF_HSTRSTST_LBN 3
+#define	FRF_AB_GMF_HSTRSTST_WIDTH 1
+#define	FRF_AB_GMF_HSTRSTFR_LBN 2
+#define	FRF_AB_GMF_HSTRSTFR_WIDTH 1
+#define	FRF_AB_GMF_HSTRSTSR_LBN 1
+#define	FRF_AB_GMF_HSTRSTSR_WIDTH 1
+#define	FRF_AB_GMF_HSTRSTWT_LBN 0
+#define	FRF_AB_GMF_HSTRSTWT_WIDTH 1
+
+/* GMF_CFG1_REG: GMAC FIFO configuration register 1 */
+#define	FR_AB_GMF_CFG1 0x00000f30
+#define	FRF_AB_GMF_CFGFRTH_LBN 16
+#define	FRF_AB_GMF_CFGFRTH_WIDTH 5
+#define	FRF_AB_GMF_CFGXOFFRTX_LBN 0
+#define	FRF_AB_GMF_CFGXOFFRTX_WIDTH 16
+
+/* GMF_CFG2_REG: GMAC FIFO configuration register 2 */
+#define	FR_AB_GMF_CFG2 0x00000f40
+#define	FRF_AB_GMF_CFGHWM_LBN 16
+#define	FRF_AB_GMF_CFGHWM_WIDTH 6
+#define	FRF_AB_GMF_CFGLWM_LBN 0
+#define	FRF_AB_GMF_CFGLWM_WIDTH 6
+
+/* GMF_CFG3_REG: GMAC FIFO configuration register 3 */
+#define	FR_AB_GMF_CFG3 0x00000f50
+#define	FRF_AB_GMF_CFGHWMFT_LBN 16
+#define	FRF_AB_GMF_CFGHWMFT_WIDTH 6
+#define	FRF_AB_GMF_CFGFTTH_LBN 0
+#define	FRF_AB_GMF_CFGFTTH_WIDTH 6
+
+/* GMF_CFG4_REG: GMAC FIFO configuration register 4 */
+#define	FR_AB_GMF_CFG4 0x00000f60
+#define	FRF_AB_GMF_HSTFLTRFRM_LBN 0
+#define	FRF_AB_GMF_HSTFLTRFRM_WIDTH 18
+
+/* GMF_CFG5_REG: GMAC FIFO configuration register 5 */
+#define	FR_AB_GMF_CFG5 0x00000f70
+#define	FRF_AB_GMF_CFGHDPLX_LBN 22
+#define	FRF_AB_GMF_CFGHDPLX_WIDTH 1
+#define	FRF_AB_GMF_SRFULL_LBN 21
+#define	FRF_AB_GMF_SRFULL_WIDTH 1
+#define	FRF_AB_GMF_HSTSRFULLCLR_LBN 20
+#define	FRF_AB_GMF_HSTSRFULLCLR_WIDTH 1
+#define	FRF_AB_GMF_CFGBYTMODE_LBN 19
+#define	FRF_AB_GMF_CFGBYTMODE_WIDTH 1
+#define	FRF_AB_GMF_HSTDRPLT64_LBN 18
+#define	FRF_AB_GMF_HSTDRPLT64_WIDTH 1
+#define	FRF_AB_GMF_HSTFLTRFRMDC_LBN 0
+#define	FRF_AB_GMF_HSTFLTRFRMDC_WIDTH 18
+
+/* TX_SRC_MAC_TBL: Transmit IP source address filter table */
+#define	FR_BB_TX_SRC_MAC_TBL 0x00001000
+#define	FR_BB_TX_SRC_MAC_TBL_STEP 16
+#define	FR_BB_TX_SRC_MAC_TBL_ROWS 16
+#define	FRF_BB_TX_SRC_MAC_ADR_1_LBN 64
+#define	FRF_BB_TX_SRC_MAC_ADR_1_WIDTH 48
+#define	FRF_BB_TX_SRC_MAC_ADR_0_LBN 0
+#define	FRF_BB_TX_SRC_MAC_ADR_0_WIDTH 48
+
+/* TX_SRC_MAC_CTL_REG: Transmit MAC source address filter control */
+#define	FR_BB_TX_SRC_MAC_CTL 0x00001100
+#define	FRF_BB_TX_SRC_DROP_CTR_LBN 16
+#define	FRF_BB_TX_SRC_DROP_CTR_WIDTH 16
+#define	FRF_BB_TX_SRC_FLTR_EN_LBN 15
+#define	FRF_BB_TX_SRC_FLTR_EN_WIDTH 1
+#define	FRF_BB_TX_DROP_CTR_CLR_LBN 12
+#define	FRF_BB_TX_DROP_CTR_CLR_WIDTH 1
+#define	FRF_BB_TX_MAC_QID_SEL_LBN 0
+#define	FRF_BB_TX_MAC_QID_SEL_WIDTH 3
+
+/* XM_ADR_LO_REG: XGMAC address register low */
+#define	FR_AB_XM_ADR_LO 0x00001200
+#define	FRF_AB_XM_ADR_LO_LBN 0
+#define	FRF_AB_XM_ADR_LO_WIDTH 32
+
+/* XM_ADR_HI_REG: XGMAC address register high */
+#define	FR_AB_XM_ADR_HI 0x00001210
+#define	FRF_AB_XM_ADR_HI_LBN 0
+#define	FRF_AB_XM_ADR_HI_WIDTH 16
+
+/* XM_GLB_CFG_REG: XGMAC global configuration */
+#define	FR_AB_XM_GLB_CFG 0x00001220
+#define	FRF_AB_XM_RMTFLT_GEN_LBN 17
+#define	FRF_AB_XM_RMTFLT_GEN_WIDTH 1
+#define	FRF_AB_XM_DEBUG_MODE_LBN 16
+#define	FRF_AB_XM_DEBUG_MODE_WIDTH 1
+#define	FRF_AB_XM_RX_STAT_EN_LBN 11
+#define	FRF_AB_XM_RX_STAT_EN_WIDTH 1
+#define	FRF_AB_XM_TX_STAT_EN_LBN 10
+#define	FRF_AB_XM_TX_STAT_EN_WIDTH 1
+#define	FRF_AB_XM_RX_JUMBO_MODE_LBN 6
+#define	FRF_AB_XM_RX_JUMBO_MODE_WIDTH 1
+#define	FRF_AB_XM_WAN_MODE_LBN 5
+#define	FRF_AB_XM_WAN_MODE_WIDTH 1
+#define	FRF_AB_XM_INTCLR_MODE_LBN 3
+#define	FRF_AB_XM_INTCLR_MODE_WIDTH 1
+#define	FRF_AB_XM_CORE_RST_LBN 0
+#define	FRF_AB_XM_CORE_RST_WIDTH 1
+
+/* XM_TX_CFG_REG: XGMAC transmit configuration */
+#define	FR_AB_XM_TX_CFG 0x00001230
+#define	FRF_AB_XM_TX_PROG_LBN 24
+#define	FRF_AB_XM_TX_PROG_WIDTH 1
+#define	FRF_AB_XM_IPG_LBN 16
+#define	FRF_AB_XM_IPG_WIDTH 4
+#define	FRF_AB_XM_FCNTL_LBN 10
+#define	FRF_AB_XM_FCNTL_WIDTH 1
+#define	FRF_AB_XM_TXCRC_LBN 8
+#define	FRF_AB_XM_TXCRC_WIDTH 1
+#define	FRF_AB_XM_EDRC_LBN 6
+#define	FRF_AB_XM_EDRC_WIDTH 1
+#define	FRF_AB_XM_AUTO_PAD_LBN 5
+#define	FRF_AB_XM_AUTO_PAD_WIDTH 1
+#define	FRF_AB_XM_TX_PRMBL_LBN 2
+#define	FRF_AB_XM_TX_PRMBL_WIDTH 1
+#define	FRF_AB_XM_TXEN_LBN 1
+#define	FRF_AB_XM_TXEN_WIDTH 1
+#define	FRF_AB_XM_TX_RST_LBN 0
+#define	FRF_AB_XM_TX_RST_WIDTH 1
+
+/* XM_RX_CFG_REG: XGMAC receive configuration */
+#define	FR_AB_XM_RX_CFG 0x00001240
+#define	FRF_AB_XM_PASS_LENERR_LBN 26
+#define	FRF_AB_XM_PASS_LENERR_WIDTH 1
+#define	FRF_AB_XM_PASS_CRC_ERR_LBN 25
+#define	FRF_AB_XM_PASS_CRC_ERR_WIDTH 1
+#define	FRF_AB_XM_PASS_PRMBLE_ERR_LBN 24
+#define	FRF_AB_XM_PASS_PRMBLE_ERR_WIDTH 1
+#define	FRF_AB_XM_REJ_BCAST_LBN 20
+#define	FRF_AB_XM_REJ_BCAST_WIDTH 1
+#define	FRF_AB_XM_ACPT_ALL_MCAST_LBN 11
+#define	FRF_AB_XM_ACPT_ALL_MCAST_WIDTH 1
+#define	FRF_AB_XM_ACPT_ALL_UCAST_LBN 9
+#define	FRF_AB_XM_ACPT_ALL_UCAST_WIDTH 1
+#define	FRF_AB_XM_AUTO_DEPAD_LBN 8
+#define	FRF_AB_XM_AUTO_DEPAD_WIDTH 1
+#define	FRF_AB_XM_RXCRC_LBN 3
+#define	FRF_AB_XM_RXCRC_WIDTH 1
+#define	FRF_AB_XM_RX_PRMBL_LBN 2
+#define	FRF_AB_XM_RX_PRMBL_WIDTH 1
+#define	FRF_AB_XM_RXEN_LBN 1
+#define	FRF_AB_XM_RXEN_WIDTH 1
+#define	FRF_AB_XM_RX_RST_LBN 0
+#define	FRF_AB_XM_RX_RST_WIDTH 1
+
+/* XM_MGT_INT_MASK: documentation to be written for sum_XM_MGT_INT_MASK */
+#define	FR_AB_XM_MGT_INT_MASK 0x00001250
+#define	FRF_AB_XM_MSK_STA_INTR_LBN 16
+#define	FRF_AB_XM_MSK_STA_INTR_WIDTH 1
+#define	FRF_AB_XM_MSK_STAT_CNTR_HF_LBN 9
+#define	FRF_AB_XM_MSK_STAT_CNTR_HF_WIDTH 1
+#define	FRF_AB_XM_MSK_STAT_CNTR_OF_LBN 8
+#define	FRF_AB_XM_MSK_STAT_CNTR_OF_WIDTH 1
+#define	FRF_AB_XM_MSK_PRMBLE_ERR_LBN 2
+#define	FRF_AB_XM_MSK_PRMBLE_ERR_WIDTH 1
+#define	FRF_AB_XM_MSK_RMTFLT_LBN 1
+#define	FRF_AB_XM_MSK_RMTFLT_WIDTH 1
+#define	FRF_AB_XM_MSK_LCLFLT_LBN 0
+#define	FRF_AB_XM_MSK_LCLFLT_WIDTH 1
+
+/* XM_FC_REG: XGMAC flow control register */
+#define	FR_AB_XM_FC 0x00001270
+#define	FRF_AB_XM_PAUSE_TIME_LBN 16
+#define	FRF_AB_XM_PAUSE_TIME_WIDTH 16
+#define	FRF_AB_XM_RX_MAC_STAT_LBN 11
+#define	FRF_AB_XM_RX_MAC_STAT_WIDTH 1
+#define	FRF_AB_XM_TX_MAC_STAT_LBN 10
+#define	FRF_AB_XM_TX_MAC_STAT_WIDTH 1
+#define	FRF_AB_XM_MCNTL_PASS_LBN 8
+#define	FRF_AB_XM_MCNTL_PASS_WIDTH 2
+#define	FRF_AB_XM_REJ_CNTL_UCAST_LBN 6
+#define	FRF_AB_XM_REJ_CNTL_UCAST_WIDTH 1
+#define	FRF_AB_XM_REJ_CNTL_MCAST_LBN 5
+#define	FRF_AB_XM_REJ_CNTL_MCAST_WIDTH 1
+#define	FRF_AB_XM_ZPAUSE_LBN 2
+#define	FRF_AB_XM_ZPAUSE_WIDTH 1
+#define	FRF_AB_XM_XMIT_PAUSE_LBN 1
+#define	FRF_AB_XM_XMIT_PAUSE_WIDTH 1
+#define	FRF_AB_XM_DIS_FCNTL_LBN 0
+#define	FRF_AB_XM_DIS_FCNTL_WIDTH 1
+
+/* XM_PAUSE_TIME_REG: XGMAC pause time register */
+#define	FR_AB_XM_PAUSE_TIME 0x00001290
+#define	FRF_AB_XM_TX_PAUSE_CNT_LBN 16
+#define	FRF_AB_XM_TX_PAUSE_CNT_WIDTH 16
+#define	FRF_AB_XM_RX_PAUSE_CNT_LBN 0
+#define	FRF_AB_XM_RX_PAUSE_CNT_WIDTH 16
+
+/* XM_TX_PARAM_REG: XGMAC transmit parameter register */
+#define	FR_AB_XM_TX_PARAM 0x000012d0
+#define	FRF_AB_XM_TX_JUMBO_MODE_LBN 31
+#define	FRF_AB_XM_TX_JUMBO_MODE_WIDTH 1
+#define	FRF_AB_XM_MAX_TX_FRM_SIZE_HI_LBN 19
+#define	FRF_AB_XM_MAX_TX_FRM_SIZE_HI_WIDTH 11
+#define	FRF_AB_XM_MAX_TX_FRM_SIZE_LO_LBN 16
+#define	FRF_AB_XM_MAX_TX_FRM_SIZE_LO_WIDTH 3
+#define	FRF_AB_XM_PAD_CHAR_LBN 0
+#define	FRF_AB_XM_PAD_CHAR_WIDTH 8
+
+/* XM_RX_PARAM_REG: XGMAC receive parameter register */
+#define	FR_AB_XM_RX_PARAM 0x000012e0
+#define	FRF_AB_XM_MAX_RX_FRM_SIZE_HI_LBN 3
+#define	FRF_AB_XM_MAX_RX_FRM_SIZE_HI_WIDTH 11
+#define	FRF_AB_XM_MAX_RX_FRM_SIZE_LO_LBN 0
+#define	FRF_AB_XM_MAX_RX_FRM_SIZE_LO_WIDTH 3
+
+/* XM_MGT_INT_MSK_REG: XGMAC management interrupt mask register */
+#define	FR_AB_XM_MGT_INT_MSK 0x000012f0
+#define	FRF_AB_XM_STAT_CNTR_OF_LBN 9
+#define	FRF_AB_XM_STAT_CNTR_OF_WIDTH 1
+#define	FRF_AB_XM_STAT_CNTR_HF_LBN 8
+#define	FRF_AB_XM_STAT_CNTR_HF_WIDTH 1
+#define	FRF_AB_XM_PRMBLE_ERR_LBN 2
+#define	FRF_AB_XM_PRMBLE_ERR_WIDTH 1
+#define	FRF_AB_XM_RMTFLT_LBN 1
+#define	FRF_AB_XM_RMTFLT_WIDTH 1
+#define	FRF_AB_XM_LCLFLT_LBN 0
+#define	FRF_AB_XM_LCLFLT_WIDTH 1
+
+/* XX_PWR_RST_REG: XGXS/XAUI powerdown/reset register */
+#define	FR_AB_XX_PWR_RST 0x00001300
+#define	FRF_AB_XX_PWRDND_SIG_LBN 31
+#define	FRF_AB_XX_PWRDND_SIG_WIDTH 1
+#define	FRF_AB_XX_PWRDNC_SIG_LBN 30
+#define	FRF_AB_XX_PWRDNC_SIG_WIDTH 1
+#define	FRF_AB_XX_PWRDNB_SIG_LBN 29
+#define	FRF_AB_XX_PWRDNB_SIG_WIDTH 1
+#define	FRF_AB_XX_PWRDNA_SIG_LBN 28
+#define	FRF_AB_XX_PWRDNA_SIG_WIDTH 1
+#define	FRF_AB_XX_SIM_MODE_LBN 27
+#define	FRF_AB_XX_SIM_MODE_WIDTH 1
+#define	FRF_AB_XX_RSTPLLCD_SIG_LBN 25
+#define	FRF_AB_XX_RSTPLLCD_SIG_WIDTH 1
+#define	FRF_AB_XX_RSTPLLAB_SIG_LBN 24
+#define	FRF_AB_XX_RSTPLLAB_SIG_WIDTH 1
+#define	FRF_AB_XX_RESETD_SIG_LBN 23
+#define	FRF_AB_XX_RESETD_SIG_WIDTH 1
+#define	FRF_AB_XX_RESETC_SIG_LBN 22
+#define	FRF_AB_XX_RESETC_SIG_WIDTH 1
+#define	FRF_AB_XX_RESETB_SIG_LBN 21
+#define	FRF_AB_XX_RESETB_SIG_WIDTH 1
+#define	FRF_AB_XX_RESETA_SIG_LBN 20
+#define	FRF_AB_XX_RESETA_SIG_WIDTH 1
+#define	FRF_AB_XX_RSTXGXSRX_SIG_LBN 18
+#define	FRF_AB_XX_RSTXGXSRX_SIG_WIDTH 1
+#define	FRF_AB_XX_RSTXGXSTX_SIG_LBN 17
+#define	FRF_AB_XX_RSTXGXSTX_SIG_WIDTH 1
+#define	FRF_AB_XX_SD_RST_ACT_LBN 16
+#define	FRF_AB_XX_SD_RST_ACT_WIDTH 1
+#define	FRF_AB_XX_PWRDND_EN_LBN 15
+#define	FRF_AB_XX_PWRDND_EN_WIDTH 1
+#define	FRF_AB_XX_PWRDNC_EN_LBN 14
+#define	FRF_AB_XX_PWRDNC_EN_WIDTH 1
+#define	FRF_AB_XX_PWRDNB_EN_LBN 13
+#define	FRF_AB_XX_PWRDNB_EN_WIDTH 1
+#define	FRF_AB_XX_PWRDNA_EN_LBN 12
+#define	FRF_AB_XX_PWRDNA_EN_WIDTH 1
+#define	FRF_AB_XX_RSTPLLCD_EN_LBN 9
+#define	FRF_AB_XX_RSTPLLCD_EN_WIDTH 1
+#define	FRF_AB_XX_RSTPLLAB_EN_LBN 8
+#define	FRF_AB_XX_RSTPLLAB_EN_WIDTH 1
+#define	FRF_AB_XX_RESETD_EN_LBN 7
+#define	FRF_AB_XX_RESETD_EN_WIDTH 1
+#define	FRF_AB_XX_RESETC_EN_LBN 6
+#define	FRF_AB_XX_RESETC_EN_WIDTH 1
+#define	FRF_AB_XX_RESETB_EN_LBN 5
+#define	FRF_AB_XX_RESETB_EN_WIDTH 1
+#define	FRF_AB_XX_RESETA_EN_LBN 4
+#define	FRF_AB_XX_RESETA_EN_WIDTH 1
+#define	FRF_AB_XX_RSTXGXSRX_EN_LBN 2
+#define	FRF_AB_XX_RSTXGXSRX_EN_WIDTH 1
+#define	FRF_AB_XX_RSTXGXSTX_EN_LBN 1
+#define	FRF_AB_XX_RSTXGXSTX_EN_WIDTH 1
+#define	FRF_AB_XX_RST_XX_EN_LBN 0
+#define	FRF_AB_XX_RST_XX_EN_WIDTH 1
+
+/* XX_SD_CTL_REG: XGXS/XAUI powerdown/reset control register */
+#define	FR_AB_XX_SD_CTL 0x00001310
+#define	FRF_AB_XX_TERMADJ1_LBN 17
+#define	FRF_AB_XX_TERMADJ1_WIDTH 1
+#define	FRF_AB_XX_TERMADJ0_LBN 16
+#define	FRF_AB_XX_TERMADJ0_WIDTH 1
+#define	FRF_AB_XX_HIDRVD_LBN 15
+#define	FRF_AB_XX_HIDRVD_WIDTH 1
+#define	FRF_AB_XX_LODRVD_LBN 14
+#define	FRF_AB_XX_LODRVD_WIDTH 1
+#define	FRF_AB_XX_HIDRVC_LBN 13
+#define	FRF_AB_XX_HIDRVC_WIDTH 1
+#define	FRF_AB_XX_LODRVC_LBN 12
+#define	FRF_AB_XX_LODRVC_WIDTH 1
+#define	FRF_AB_XX_HIDRVB_LBN 11
+#define	FRF_AB_XX_HIDRVB_WIDTH 1
+#define	FRF_AB_XX_LODRVB_LBN 10
+#define	FRF_AB_XX_LODRVB_WIDTH 1
+#define	FRF_AB_XX_HIDRVA_LBN 9
+#define	FRF_AB_XX_HIDRVA_WIDTH 1
+#define	FRF_AB_XX_LODRVA_LBN 8
+#define	FRF_AB_XX_LODRVA_WIDTH 1
+#define	FRF_AB_XX_LPBKD_LBN 3
+#define	FRF_AB_XX_LPBKD_WIDTH 1
+#define	FRF_AB_XX_LPBKC_LBN 2
+#define	FRF_AB_XX_LPBKC_WIDTH 1
+#define	FRF_AB_XX_LPBKB_LBN 1
+#define	FRF_AB_XX_LPBKB_WIDTH 1
+#define	FRF_AB_XX_LPBKA_LBN 0
+#define	FRF_AB_XX_LPBKA_WIDTH 1
+
+/* XX_TXDRV_CTL_REG: XAUI SerDes transmit drive control register */
+#define	FR_AB_XX_TXDRV_CTL 0x00001320
+#define	FRF_AB_XX_DEQD_LBN 28
+#define	FRF_AB_XX_DEQD_WIDTH 4
+#define	FRF_AB_XX_DEQC_LBN 24
+#define	FRF_AB_XX_DEQC_WIDTH 4
+#define	FRF_AB_XX_DEQB_LBN 20
+#define	FRF_AB_XX_DEQB_WIDTH 4
+#define	FRF_AB_XX_DEQA_LBN 16
+#define	FRF_AB_XX_DEQA_WIDTH 4
+#define	FRF_AB_XX_DTXD_LBN 12
+#define	FRF_AB_XX_DTXD_WIDTH 4
+#define	FRF_AB_XX_DTXC_LBN 8
+#define	FRF_AB_XX_DTXC_WIDTH 4
+#define	FRF_AB_XX_DTXB_LBN 4
+#define	FRF_AB_XX_DTXB_WIDTH 4
+#define	FRF_AB_XX_DTXA_LBN 0
+#define	FRF_AB_XX_DTXA_WIDTH 4
+
+/* XX_PRBS_CTL_REG: documentation to be written for sum_XX_PRBS_CTL_REG */
+#define	FR_AB_XX_PRBS_CTL 0x00001330
+#define	FRF_AB_XX_CH3_RX_PRBS_SEL_LBN 30
+#define	FRF_AB_XX_CH3_RX_PRBS_SEL_WIDTH 2
+#define	FRF_AB_XX_CH3_RX_PRBS_INV_LBN 29
+#define	FRF_AB_XX_CH3_RX_PRBS_INV_WIDTH 1
+#define	FRF_AB_XX_CH3_RX_PRBS_CHKEN_LBN 28
+#define	FRF_AB_XX_CH3_RX_PRBS_CHKEN_WIDTH 1
+#define	FRF_AB_XX_CH2_RX_PRBS_SEL_LBN 26
+#define	FRF_AB_XX_CH2_RX_PRBS_SEL_WIDTH 2
+#define	FRF_AB_XX_CH2_RX_PRBS_INV_LBN 25
+#define	FRF_AB_XX_CH2_RX_PRBS_INV_WIDTH 1
+#define	FRF_AB_XX_CH2_RX_PRBS_CHKEN_LBN 24
+#define	FRF_AB_XX_CH2_RX_PRBS_CHKEN_WIDTH 1
+#define	FRF_AB_XX_CH1_RX_PRBS_SEL_LBN 22
+#define	FRF_AB_XX_CH1_RX_PRBS_SEL_WIDTH 2
+#define	FRF_AB_XX_CH1_RX_PRBS_INV_LBN 21
+#define	FRF_AB_XX_CH1_RX_PRBS_INV_WIDTH 1
+#define	FRF_AB_XX_CH1_RX_PRBS_CHKEN_LBN 20
+#define	FRF_AB_XX_CH1_RX_PRBS_CHKEN_WIDTH 1
+#define	FRF_AB_XX_CH0_RX_PRBS_SEL_LBN 18
+#define	FRF_AB_XX_CH0_RX_PRBS_SEL_WIDTH 2
+#define	FRF_AB_XX_CH0_RX_PRBS_INV_LBN 17
+#define	FRF_AB_XX_CH0_RX_PRBS_INV_WIDTH 1
+#define	FRF_AB_XX_CH0_RX_PRBS_CHKEN_LBN 16
+#define	FRF_AB_XX_CH0_RX_PRBS_CHKEN_WIDTH 1
+#define	FRF_AB_XX_CH3_TX_PRBS_SEL_LBN 14
+#define	FRF_AB_XX_CH3_TX_PRBS_SEL_WIDTH 2
+#define	FRF_AB_XX_CH3_TX_PRBS_INV_LBN 13
+#define	FRF_AB_XX_CH3_TX_PRBS_INV_WIDTH 1
+#define	FRF_AB_XX_CH3_TX_PRBS_CHKEN_LBN 12
+#define	FRF_AB_XX_CH3_TX_PRBS_CHKEN_WIDTH 1
+#define	FRF_AB_XX_CH2_TX_PRBS_SEL_LBN 10
+#define	FRF_AB_XX_CH2_TX_PRBS_SEL_WIDTH 2
+#define	FRF_AB_XX_CH2_TX_PRBS_INV_LBN 9
+#define	FRF_AB_XX_CH2_TX_PRBS_INV_WIDTH 1
+#define	FRF_AB_XX_CH2_TX_PRBS_CHKEN_LBN 8
+#define	FRF_AB_XX_CH2_TX_PRBS_CHKEN_WIDTH 1
+#define	FRF_AB_XX_CH1_TX_PRBS_SEL_LBN 6
+#define	FRF_AB_XX_CH1_TX_PRBS_SEL_WIDTH 2
+#define	FRF_AB_XX_CH1_TX_PRBS_INV_LBN 5
+#define	FRF_AB_XX_CH1_TX_PRBS_INV_WIDTH 1
+#define	FRF_AB_XX_CH1_TX_PRBS_CHKEN_LBN 4
+#define	FRF_AB_XX_CH1_TX_PRBS_CHKEN_WIDTH 1
+#define	FRF_AB_XX_CH0_TX_PRBS_SEL_LBN 2
+#define	FRF_AB_XX_CH0_TX_PRBS_SEL_WIDTH 2
+#define	FRF_AB_XX_CH0_TX_PRBS_INV_LBN 1
+#define	FRF_AB_XX_CH0_TX_PRBS_INV_WIDTH 1
+#define	FRF_AB_XX_CH0_TX_PRBS_CHKEN_LBN 0
+#define	FRF_AB_XX_CH0_TX_PRBS_CHKEN_WIDTH 1
+
+/* XX_PRBS_CHK_REG: documentation to be written for sum_XX_PRBS_CHK_REG */
+#define	FR_AB_XX_PRBS_CHK 0x00001340
+#define	FRF_AB_XX_REV_LB_EN_LBN 16
+#define	FRF_AB_XX_REV_LB_EN_WIDTH 1
+#define	FRF_AB_XX_CH3_DEG_DET_LBN 15
+#define	FRF_AB_XX_CH3_DEG_DET_WIDTH 1
+#define	FRF_AB_XX_CH3_LFSR_LOCK_IND_LBN 14
+#define	FRF_AB_XX_CH3_LFSR_LOCK_IND_WIDTH 1
+#define	FRF_AB_XX_CH3_PRBS_FRUN_LBN 13
+#define	FRF_AB_XX_CH3_PRBS_FRUN_WIDTH 1
+#define	FRF_AB_XX_CH3_ERR_CHK_LBN 12
+#define	FRF_AB_XX_CH3_ERR_CHK_WIDTH 1
+#define	FRF_AB_XX_CH2_DEG_DET_LBN 11
+#define	FRF_AB_XX_CH2_DEG_DET_WIDTH 1
+#define	FRF_AB_XX_CH2_LFSR_LOCK_IND_LBN 10
+#define	FRF_AB_XX_CH2_LFSR_LOCK_IND_WIDTH 1
+#define	FRF_AB_XX_CH2_PRBS_FRUN_LBN 9
+#define	FRF_AB_XX_CH2_PRBS_FRUN_WIDTH 1
+#define	FRF_AB_XX_CH2_ERR_CHK_LBN 8
+#define	FRF_AB_XX_CH2_ERR_CHK_WIDTH 1
+#define	FRF_AB_XX_CH1_DEG_DET_LBN 7
+#define	FRF_AB_XX_CH1_DEG_DET_WIDTH 1
+#define	FRF_AB_XX_CH1_LFSR_LOCK_IND_LBN 6
+#define	FRF_AB_XX_CH1_LFSR_LOCK_IND_WIDTH 1
+#define	FRF_AB_XX_CH1_PRBS_FRUN_LBN 5
+#define	FRF_AB_XX_CH1_PRBS_FRUN_WIDTH 1
+#define	FRF_AB_XX_CH1_ERR_CHK_LBN 4
+#define	FRF_AB_XX_CH1_ERR_CHK_WIDTH 1
+#define	FRF_AB_XX_CH0_DEG_DET_LBN 3
+#define	FRF_AB_XX_CH0_DEG_DET_WIDTH 1
+#define	FRF_AB_XX_CH0_LFSR_LOCK_IND_LBN 2
+#define	FRF_AB_XX_CH0_LFSR_LOCK_IND_WIDTH 1
+#define	FRF_AB_XX_CH0_PRBS_FRUN_LBN 1
+#define	FRF_AB_XX_CH0_PRBS_FRUN_WIDTH 1
+#define	FRF_AB_XX_CH0_ERR_CHK_LBN 0
+#define	FRF_AB_XX_CH0_ERR_CHK_WIDTH 1
+
+/* XX_PRBS_ERR_REG: documentation to be written for sum_XX_PRBS_ERR_REG */
+#define	FR_AB_XX_PRBS_ERR 0x00001350
+#define	FRF_AB_XX_CH3_PRBS_ERR_CNT_LBN 24
+#define	FRF_AB_XX_CH3_PRBS_ERR_CNT_WIDTH 8
+#define	FRF_AB_XX_CH2_PRBS_ERR_CNT_LBN 16
+#define	FRF_AB_XX_CH2_PRBS_ERR_CNT_WIDTH 8
+#define	FRF_AB_XX_CH1_PRBS_ERR_CNT_LBN 8
+#define	FRF_AB_XX_CH1_PRBS_ERR_CNT_WIDTH 8
+#define	FRF_AB_XX_CH0_PRBS_ERR_CNT_LBN 0
+#define	FRF_AB_XX_CH0_PRBS_ERR_CNT_WIDTH 8
+
+/* XX_CORE_STAT_REG: XAUI XGXS core status register */
+#define	FR_AB_XX_CORE_STAT 0x00001360
+#define	FRF_AB_XX_FORCE_SIG3_LBN 31
+#define	FRF_AB_XX_FORCE_SIG3_WIDTH 1
+#define	FRF_AB_XX_FORCE_SIG3_VAL_LBN 30
+#define	FRF_AB_XX_FORCE_SIG3_VAL_WIDTH 1
+#define	FRF_AB_XX_FORCE_SIG2_LBN 29
+#define	FRF_AB_XX_FORCE_SIG2_WIDTH 1
+#define	FRF_AB_XX_FORCE_SIG2_VAL_LBN 28
+#define	FRF_AB_XX_FORCE_SIG2_VAL_WIDTH 1
+#define	FRF_AB_XX_FORCE_SIG1_LBN 27
+#define	FRF_AB_XX_FORCE_SIG1_WIDTH 1
+#define	FRF_AB_XX_FORCE_SIG1_VAL_LBN 26
+#define	FRF_AB_XX_FORCE_SIG1_VAL_WIDTH 1
+#define	FRF_AB_XX_FORCE_SIG0_LBN 25
+#define	FRF_AB_XX_FORCE_SIG0_WIDTH 1
+#define	FRF_AB_XX_FORCE_SIG0_VAL_LBN 24
+#define	FRF_AB_XX_FORCE_SIG0_VAL_WIDTH 1
+#define	FRF_AB_XX_XGXS_LB_EN_LBN 23
+#define	FRF_AB_XX_XGXS_LB_EN_WIDTH 1
+#define	FRF_AB_XX_XGMII_LB_EN_LBN 22
+#define	FRF_AB_XX_XGMII_LB_EN_WIDTH 1
+#define	FRF_AB_XX_MATCH_FAULT_LBN 21
+#define	FRF_AB_XX_MATCH_FAULT_WIDTH 1
+#define	FRF_AB_XX_ALIGN_DONE_LBN 20
+#define	FRF_AB_XX_ALIGN_DONE_WIDTH 1
+#define	FRF_AB_XX_SYNC_STAT3_LBN 19
+#define	FRF_AB_XX_SYNC_STAT3_WIDTH 1
+#define	FRF_AB_XX_SYNC_STAT2_LBN 18
+#define	FRF_AB_XX_SYNC_STAT2_WIDTH 1
+#define	FRF_AB_XX_SYNC_STAT1_LBN 17
+#define	FRF_AB_XX_SYNC_STAT1_WIDTH 1
+#define	FRF_AB_XX_SYNC_STAT0_LBN 16
+#define	FRF_AB_XX_SYNC_STAT0_WIDTH 1
+#define	FRF_AB_XX_COMMA_DET_CH3_LBN 15
+#define	FRF_AB_XX_COMMA_DET_CH3_WIDTH 1
+#define	FRF_AB_XX_COMMA_DET_CH2_LBN 14
+#define	FRF_AB_XX_COMMA_DET_CH2_WIDTH 1
+#define	FRF_AB_XX_COMMA_DET_CH1_LBN 13
+#define	FRF_AB_XX_COMMA_DET_CH1_WIDTH 1
+#define	FRF_AB_XX_COMMA_DET_CH0_LBN 12
+#define	FRF_AB_XX_COMMA_DET_CH0_WIDTH 1
+#define	FRF_AB_XX_CGRP_ALIGN_CH3_LBN 11
+#define	FRF_AB_XX_CGRP_ALIGN_CH3_WIDTH 1
+#define	FRF_AB_XX_CGRP_ALIGN_CH2_LBN 10
+#define	FRF_AB_XX_CGRP_ALIGN_CH2_WIDTH 1
+#define	FRF_AB_XX_CGRP_ALIGN_CH1_LBN 9
+#define	FRF_AB_XX_CGRP_ALIGN_CH1_WIDTH 1
+#define	FRF_AB_XX_CGRP_ALIGN_CH0_LBN 8
+#define	FRF_AB_XX_CGRP_ALIGN_CH0_WIDTH 1
+#define	FRF_AB_XX_CHAR_ERR_CH3_LBN 7
+#define	FRF_AB_XX_CHAR_ERR_CH3_WIDTH 1
+#define	FRF_AB_XX_CHAR_ERR_CH2_LBN 6
+#define	FRF_AB_XX_CHAR_ERR_CH2_WIDTH 1
+#define	FRF_AB_XX_CHAR_ERR_CH1_LBN 5
+#define	FRF_AB_XX_CHAR_ERR_CH1_WIDTH 1
+#define	FRF_AB_XX_CHAR_ERR_CH0_LBN 4
+#define	FRF_AB_XX_CHAR_ERR_CH0_WIDTH 1
+#define	FRF_AB_XX_DISPERR_CH3_LBN 3
+#define	FRF_AB_XX_DISPERR_CH3_WIDTH 1
+#define	FRF_AB_XX_DISPERR_CH2_LBN 2
+#define	FRF_AB_XX_DISPERR_CH2_WIDTH 1
+#define	FRF_AB_XX_DISPERR_CH1_LBN 1
+#define	FRF_AB_XX_DISPERR_CH1_WIDTH 1
+#define	FRF_AB_XX_DISPERR_CH0_LBN 0
+#define	FRF_AB_XX_DISPERR_CH0_WIDTH 1
+
+/* RX_DESC_PTR_TBL_KER: Receive descriptor pointer table */
+#define	FR_AA_RX_DESC_PTR_TBL_KER 0x00011800
+#define	FR_AA_RX_DESC_PTR_TBL_KER_STEP 16
+#define	FR_AA_RX_DESC_PTR_TBL_KER_ROWS 4
+/* RX_DESC_PTR_TBL: Receive descriptor pointer table */
+#define	FR_BZ_RX_DESC_PTR_TBL 0x00f40000
+#define	FR_BZ_RX_DESC_PTR_TBL_STEP 16
+#define	FR_BB_RX_DESC_PTR_TBL_ROWS 4096
+#define	FR_CZ_RX_DESC_PTR_TBL_ROWS 1024
+#define	FRF_CZ_RX_HDR_SPLIT_LBN 90
+#define	FRF_CZ_RX_HDR_SPLIT_WIDTH 1
+#define	FRF_AA_RX_RESET_LBN 89
+#define	FRF_AA_RX_RESET_WIDTH 1
+#define	FRF_AZ_RX_ISCSI_DDIG_EN_LBN 88
+#define	FRF_AZ_RX_ISCSI_DDIG_EN_WIDTH 1
+#define	FRF_AZ_RX_ISCSI_HDIG_EN_LBN 87
+#define	FRF_AZ_RX_ISCSI_HDIG_EN_WIDTH 1
+#define	FRF_AZ_RX_DESC_PREF_ACT_LBN 86
+#define	FRF_AZ_RX_DESC_PREF_ACT_WIDTH 1
+#define	FRF_AZ_RX_DC_HW_RPTR_LBN 80
+#define	FRF_AZ_RX_DC_HW_RPTR_WIDTH 6
+#define	FRF_AZ_RX_DESCQ_HW_RPTR_LBN 68
+#define	FRF_AZ_RX_DESCQ_HW_RPTR_WIDTH 12
+#define	FRF_AZ_RX_DESCQ_SW_WPTR_LBN 56
+#define	FRF_AZ_RX_DESCQ_SW_WPTR_WIDTH 12
+#define	FRF_AZ_RX_DESCQ_BUF_BASE_ID_LBN 36
+#define	FRF_AZ_RX_DESCQ_BUF_BASE_ID_WIDTH 20
+#define	FRF_AZ_RX_DESCQ_EVQ_ID_LBN 24
+#define	FRF_AZ_RX_DESCQ_EVQ_ID_WIDTH 12
+#define	FRF_AZ_RX_DESCQ_OWNER_ID_LBN 10
+#define	FRF_AZ_RX_DESCQ_OWNER_ID_WIDTH 14
+#define	FRF_AZ_RX_DESCQ_LABEL_LBN 5
+#define	FRF_AZ_RX_DESCQ_LABEL_WIDTH 5
+#define	FRF_AZ_RX_DESCQ_SIZE_LBN 3
+#define	FRF_AZ_RX_DESCQ_SIZE_WIDTH 2
+#define	FFE_AZ_RX_DESCQ_SIZE_4K 3
+#define	FFE_AZ_RX_DESCQ_SIZE_2K 2
+#define	FFE_AZ_RX_DESCQ_SIZE_1K 1
+#define	FFE_AZ_RX_DESCQ_SIZE_512 0
+#define	FRF_AZ_RX_DESCQ_TYPE_LBN 2
+#define	FRF_AZ_RX_DESCQ_TYPE_WIDTH 1
+#define	FRF_AZ_RX_DESCQ_JUMBO_LBN 1
+#define	FRF_AZ_RX_DESCQ_JUMBO_WIDTH 1
+#define	FRF_AZ_RX_DESCQ_EN_LBN 0
+#define	FRF_AZ_RX_DESCQ_EN_WIDTH 1
+
+/* TX_DESC_PTR_TBL_KER: Transmit descriptor pointer */
+#define	FR_AA_TX_DESC_PTR_TBL_KER 0x00011900
+#define	FR_AA_TX_DESC_PTR_TBL_KER_STEP 16
+#define	FR_AA_TX_DESC_PTR_TBL_KER_ROWS 8
+/* TX_DESC_PTR_TBL: Transmit descriptor pointer */
+#define	FR_BZ_TX_DESC_PTR_TBL 0x00f50000
+#define	FR_BZ_TX_DESC_PTR_TBL_STEP 16
+#define	FR_BB_TX_DESC_PTR_TBL_ROWS 4096
+#define	FR_CZ_TX_DESC_PTR_TBL_ROWS 1024
+#define	FRF_CZ_TX_DPT_Q_MASK_WIDTH_LBN 94
+#define	FRF_CZ_TX_DPT_Q_MASK_WIDTH_WIDTH 2
+#define	FRF_CZ_TX_DPT_ETH_FILT_EN_LBN 93
+#define	FRF_CZ_TX_DPT_ETH_FILT_EN_WIDTH 1
+#define	FRF_CZ_TX_DPT_IP_FILT_EN_LBN 92
+#define	FRF_CZ_TX_DPT_IP_FILT_EN_WIDTH 1
+#define	FRF_BZ_TX_NON_IP_DROP_DIS_LBN 91
+#define	FRF_BZ_TX_NON_IP_DROP_DIS_WIDTH 1
+#define	FRF_BZ_TX_IP_CHKSM_DIS_LBN 90
+#define	FRF_BZ_TX_IP_CHKSM_DIS_WIDTH 1
+#define	FRF_BZ_TX_TCP_CHKSM_DIS_LBN 89
+#define	FRF_BZ_TX_TCP_CHKSM_DIS_WIDTH 1
+#define	FRF_AZ_TX_DESCQ_EN_LBN 88
+#define	FRF_AZ_TX_DESCQ_EN_WIDTH 1
+#define	FRF_AZ_TX_ISCSI_DDIG_EN_LBN 87
+#define	FRF_AZ_TX_ISCSI_DDIG_EN_WIDTH 1
+#define	FRF_AZ_TX_ISCSI_HDIG_EN_LBN 86
+#define	FRF_AZ_TX_ISCSI_HDIG_EN_WIDTH 1
+#define	FRF_AZ_TX_DC_HW_RPTR_LBN 80
+#define	FRF_AZ_TX_DC_HW_RPTR_WIDTH 6
+#define	FRF_AZ_TX_DESCQ_HW_RPTR_LBN 68
+#define	FRF_AZ_TX_DESCQ_HW_RPTR_WIDTH 12
+#define	FRF_AZ_TX_DESCQ_SW_WPTR_LBN 56
+#define	FRF_AZ_TX_DESCQ_SW_WPTR_WIDTH 12
+#define	FRF_AZ_TX_DESCQ_BUF_BASE_ID_LBN 36
+#define	FRF_AZ_TX_DESCQ_BUF_BASE_ID_WIDTH 20
+#define	FRF_AZ_TX_DESCQ_EVQ_ID_LBN 24
+#define	FRF_AZ_TX_DESCQ_EVQ_ID_WIDTH 12
+#define	FRF_AZ_TX_DESCQ_OWNER_ID_LBN 10
+#define	FRF_AZ_TX_DESCQ_OWNER_ID_WIDTH 14
+#define	FRF_AZ_TX_DESCQ_LABEL_LBN 5
+#define	FRF_AZ_TX_DESCQ_LABEL_WIDTH 5
+#define	FRF_AZ_TX_DESCQ_SIZE_LBN 3
+#define	FRF_AZ_TX_DESCQ_SIZE_WIDTH 2
+#define	FFE_AZ_TX_DESCQ_SIZE_4K 3
+#define	FFE_AZ_TX_DESCQ_SIZE_2K 2
+#define	FFE_AZ_TX_DESCQ_SIZE_1K 1
+#define	FFE_AZ_TX_DESCQ_SIZE_512 0
+#define	FRF_AZ_TX_DESCQ_TYPE_LBN 1
+#define	FRF_AZ_TX_DESCQ_TYPE_WIDTH 2
+#define	FRF_AZ_TX_DESCQ_FLUSH_LBN 0
+#define	FRF_AZ_TX_DESCQ_FLUSH_WIDTH 1
+
+/* EVQ_PTR_TBL_KER: Event queue pointer table */
+#define	FR_AA_EVQ_PTR_TBL_KER 0x00011a00
+#define	FR_AA_EVQ_PTR_TBL_KER_STEP 16
+#define	FR_AA_EVQ_PTR_TBL_KER_ROWS 4
+/* EVQ_PTR_TBL: Event queue pointer table */
+#define	FR_BZ_EVQ_PTR_TBL 0x00f60000
+#define	FR_BZ_EVQ_PTR_TBL_STEP 16
+#define	FR_CZ_EVQ_PTR_TBL_ROWS 1024
+#define	FR_BB_EVQ_PTR_TBL_ROWS 4096
+#define	FRF_BZ_EVQ_RPTR_IGN_LBN 40
+#define	FRF_BZ_EVQ_RPTR_IGN_WIDTH 1
+#define	FRF_AB_EVQ_WKUP_OR_INT_EN_LBN 39
+#define	FRF_AB_EVQ_WKUP_OR_INT_EN_WIDTH 1
+#define	FRF_CZ_EVQ_DOS_PROTECT_EN_LBN 39
+#define	FRF_CZ_EVQ_DOS_PROTECT_EN_WIDTH 1
+#define	FRF_AZ_EVQ_NXT_WPTR_LBN 24
+#define	FRF_AZ_EVQ_NXT_WPTR_WIDTH 15
+#define	FRF_AZ_EVQ_EN_LBN 23
+#define	FRF_AZ_EVQ_EN_WIDTH 1
+#define	FRF_AZ_EVQ_SIZE_LBN 20
+#define	FRF_AZ_EVQ_SIZE_WIDTH 3
+#define	FFE_AZ_EVQ_SIZE_32K 6
+#define	FFE_AZ_EVQ_SIZE_16K 5
+#define	FFE_AZ_EVQ_SIZE_8K 4
+#define	FFE_AZ_EVQ_SIZE_4K 3
+#define	FFE_AZ_EVQ_SIZE_2K 2
+#define	FFE_AZ_EVQ_SIZE_1K 1
+#define	FFE_AZ_EVQ_SIZE_512 0
+#define	FRF_AZ_EVQ_BUF_BASE_ID_LBN 0
+#define	FRF_AZ_EVQ_BUF_BASE_ID_WIDTH 20
+
+/* BUF_HALF_TBL_KER: Buffer table in half buffer table mode direct access by driver */
+#define	FR_AA_BUF_HALF_TBL_KER 0x00018000
+#define	FR_AA_BUF_HALF_TBL_KER_STEP 8
+#define	FR_AA_BUF_HALF_TBL_KER_ROWS 4096
+/* BUF_HALF_TBL: Buffer table in half buffer table mode direct access by driver */
+#define	FR_BZ_BUF_HALF_TBL 0x00800000
+#define	FR_BZ_BUF_HALF_TBL_STEP 8
+#define	FR_CZ_BUF_HALF_TBL_ROWS 147456
+#define	FR_BB_BUF_HALF_TBL_ROWS 524288
+#define	FRF_AZ_BUF_ADR_HBUF_ODD_LBN 44
+#define	FRF_AZ_BUF_ADR_HBUF_ODD_WIDTH 20
+#define	FRF_AZ_BUF_OWNER_ID_HBUF_ODD_LBN 32
+#define	FRF_AZ_BUF_OWNER_ID_HBUF_ODD_WIDTH 12
+#define	FRF_AZ_BUF_ADR_HBUF_EVEN_LBN 12
+#define	FRF_AZ_BUF_ADR_HBUF_EVEN_WIDTH 20
+#define	FRF_AZ_BUF_OWNER_ID_HBUF_EVEN_LBN 0
+#define	FRF_AZ_BUF_OWNER_ID_HBUF_EVEN_WIDTH 12
+
+/* BUF_FULL_TBL_KER: Buffer table in full buffer table mode direct access by driver */
+#define	FR_AA_BUF_FULL_TBL_KER 0x00018000
+#define	FR_AA_BUF_FULL_TBL_KER_STEP 8
+#define	FR_AA_BUF_FULL_TBL_KER_ROWS 4096
+/* BUF_FULL_TBL: Buffer table in full buffer table mode direct access by driver */
+#define	FR_BZ_BUF_FULL_TBL 0x00800000
+#define	FR_BZ_BUF_FULL_TBL_STEP 8
+#define	FR_CZ_BUF_FULL_TBL_ROWS 147456
+#define	FR_BB_BUF_FULL_TBL_ROWS 917504
+#define	FRF_AZ_BUF_FULL_UNUSED_LBN 51
+#define	FRF_AZ_BUF_FULL_UNUSED_WIDTH 13
+#define	FRF_AZ_IP_DAT_BUF_SIZE_LBN 50
+#define	FRF_AZ_IP_DAT_BUF_SIZE_WIDTH 1
+#define	FRF_AZ_BUF_ADR_REGION_LBN 48
+#define	FRF_AZ_BUF_ADR_REGION_WIDTH 2
+#define	FFE_AZ_BUF_ADR_REGN3 3
+#define	FFE_AZ_BUF_ADR_REGN2 2
+#define	FFE_AZ_BUF_ADR_REGN1 1
+#define	FFE_AZ_BUF_ADR_REGN0 0
+#define	FRF_AZ_BUF_ADR_FBUF_LBN 14
+#define	FRF_AZ_BUF_ADR_FBUF_WIDTH 34
+#define	FRF_AZ_BUF_OWNER_ID_FBUF_LBN 0
+#define	FRF_AZ_BUF_OWNER_ID_FBUF_WIDTH 14
+
+/* RX_FILTER_TBL0: TCP/IPv4 Receive filter table */
+#define	FR_BZ_RX_FILTER_TBL0 0x00f00000
+#define	FR_BZ_RX_FILTER_TBL0_STEP 32
+#define	FR_BZ_RX_FILTER_TBL0_ROWS 8192
+/* RX_FILTER_TBL1: TCP/IPv4 Receive filter table */
+#define	FR_BB_RX_FILTER_TBL1 0x00f00010
+#define	FR_BB_RX_FILTER_TBL1_STEP 32
+#define	FR_BB_RX_FILTER_TBL1_ROWS 8192
+#define	FRF_BZ_RSS_EN_LBN 110
+#define	FRF_BZ_RSS_EN_WIDTH 1
+#define	FRF_BZ_SCATTER_EN_LBN 109
+#define	FRF_BZ_SCATTER_EN_WIDTH 1
+#define	FRF_BZ_TCP_UDP_LBN 108
+#define	FRF_BZ_TCP_UDP_WIDTH 1
+#define	FRF_BZ_RXQ_ID_LBN 96
+#define	FRF_BZ_RXQ_ID_WIDTH 12
+#define	FRF_BZ_DEST_IP_LBN 64
+#define	FRF_BZ_DEST_IP_WIDTH 32
+#define	FRF_BZ_DEST_PORT_TCP_LBN 48
+#define	FRF_BZ_DEST_PORT_TCP_WIDTH 16
+#define	FRF_BZ_SRC_IP_LBN 16
+#define	FRF_BZ_SRC_IP_WIDTH 32
+#define	FRF_BZ_SRC_TCP_DEST_UDP_LBN 0
+#define	FRF_BZ_SRC_TCP_DEST_UDP_WIDTH 16
+
+/* RX_MAC_FILTER_TBL0: Receive Ethernet filter table */
+#define	FR_CZ_RX_MAC_FILTER_TBL0 0x00f00010
+#define	FR_CZ_RX_MAC_FILTER_TBL0_STEP 32
+#define	FR_CZ_RX_MAC_FILTER_TBL0_ROWS 512
+#define	FRF_CZ_RMFT_RSS_EN_LBN 75
+#define	FRF_CZ_RMFT_RSS_EN_WIDTH 1
+#define	FRF_CZ_RMFT_SCATTER_EN_LBN 74
+#define	FRF_CZ_RMFT_SCATTER_EN_WIDTH 1
+#define	FRF_CZ_RMFT_IP_OVERRIDE_LBN 73
+#define	FRF_CZ_RMFT_IP_OVERRIDE_WIDTH 1
+#define	FRF_CZ_RMFT_RXQ_ID_LBN 61
+#define	FRF_CZ_RMFT_RXQ_ID_WIDTH 12
+#define	FRF_CZ_RMFT_WILDCARD_MATCH_LBN 60
+#define	FRF_CZ_RMFT_WILDCARD_MATCH_WIDTH 1
+#define	FRF_CZ_RMFT_DEST_MAC_LBN 16
+#define	FRF_CZ_RMFT_DEST_MAC_WIDTH 44
+#define	FRF_CZ_RMFT_VLAN_ID_LBN 0
+#define	FRF_CZ_RMFT_VLAN_ID_WIDTH 12
+
+/* TIMER_TBL: Timer table */
+#define	FR_BZ_TIMER_TBL 0x00f70000
+#define	FR_BZ_TIMER_TBL_STEP 16
+#define	FR_CZ_TIMER_TBL_ROWS 1024
+#define	FR_BB_TIMER_TBL_ROWS 4096
+#define	FRF_CZ_TIMER_Q_EN_LBN 33
+#define	FRF_CZ_TIMER_Q_EN_WIDTH 1
+#define	FRF_CZ_INT_ARMD_LBN 32
+#define	FRF_CZ_INT_ARMD_WIDTH 1
+#define	FRF_CZ_INT_PEND_LBN 31
+#define	FRF_CZ_INT_PEND_WIDTH 1
+#define	FRF_CZ_HOST_NOTIFY_MODE_LBN 30
+#define	FRF_CZ_HOST_NOTIFY_MODE_WIDTH 1
+#define	FRF_CZ_RELOAD_TIMER_VAL_LBN 16
+#define	FRF_CZ_RELOAD_TIMER_VAL_WIDTH 14
+#define	FRF_CZ_TIMER_MODE_LBN 14
+#define	FRF_CZ_TIMER_MODE_WIDTH 2
+#define	FFE_CZ_TIMER_MODE_INT_HLDOFF 3
+#define	FFE_CZ_TIMER_MODE_TRIG_START 2
+#define	FFE_CZ_TIMER_MODE_IMMED_START 1
+#define	FFE_CZ_TIMER_MODE_DIS 0
+#define	FRF_BB_TIMER_MODE_LBN 12
+#define	FRF_BB_TIMER_MODE_WIDTH 2
+#define	FFE_BB_TIMER_MODE_INT_HLDOFF 2
+#define	FFE_BB_TIMER_MODE_TRIG_START 2
+#define	FFE_BB_TIMER_MODE_IMMED_START 1
+#define	FFE_BB_TIMER_MODE_DIS 0
+#define	FRF_CZ_TIMER_VAL_LBN 0
+#define	FRF_CZ_TIMER_VAL_WIDTH 14
+#define	FRF_BB_TIMER_VAL_LBN 0
+#define	FRF_BB_TIMER_VAL_WIDTH 12
+
+/* TX_PACE_TBL: Transmit pacing table */
+#define	FR_BZ_TX_PACE_TBL 0x00f80000
+#define	FR_BZ_TX_PACE_TBL_STEP 16
+#define	FR_CZ_TX_PACE_TBL_ROWS 1024
+#define	FR_BB_TX_PACE_TBL_ROWS 4096
+#define	FRF_BZ_TX_PACE_LBN 0
+#define	FRF_BZ_TX_PACE_WIDTH 5
+
+/* RX_INDIRECTION_TBL: RX Indirection Table */
+#define	FR_BZ_RX_INDIRECTION_TBL 0x00fb0000
+#define	FR_BZ_RX_INDIRECTION_TBL_STEP 16
+#define	FR_BZ_RX_INDIRECTION_TBL_ROWS 128
+#define	FRF_BZ_IT_QUEUE_LBN 0
+#define	FRF_BZ_IT_QUEUE_WIDTH 6
+
+/* TX_FILTER_TBL0: TCP/IPv4 Transmit filter table */
+#define	FR_CZ_TX_FILTER_TBL0 0x00fc0000
+#define	FR_CZ_TX_FILTER_TBL0_STEP 16
+#define	FR_CZ_TX_FILTER_TBL0_ROWS 8192
+#define	FRF_CZ_TIFT_TCP_UDP_LBN 108
+#define	FRF_CZ_TIFT_TCP_UDP_WIDTH 1
+#define	FRF_CZ_TIFT_TXQ_ID_LBN 96
+#define	FRF_CZ_TIFT_TXQ_ID_WIDTH 12
+#define	FRF_CZ_TIFT_DEST_IP_LBN 64
+#define	FRF_CZ_TIFT_DEST_IP_WIDTH 32
+#define	FRF_CZ_TIFT_DEST_PORT_TCP_LBN 48
+#define	FRF_CZ_TIFT_DEST_PORT_TCP_WIDTH 16
+#define	FRF_CZ_TIFT_SRC_IP_LBN 16
+#define	FRF_CZ_TIFT_SRC_IP_WIDTH 32
+#define	FRF_CZ_TIFT_SRC_TCP_DEST_UDP_LBN 0
+#define	FRF_CZ_TIFT_SRC_TCP_DEST_UDP_WIDTH 16
+
+/* TX_MAC_FILTER_TBL0: Transmit Ethernet filter table */
+#define	FR_CZ_TX_MAC_FILTER_TBL0 0x00fe0000
+#define	FR_CZ_TX_MAC_FILTER_TBL0_STEP 16
+#define	FR_CZ_TX_MAC_FILTER_TBL0_ROWS 512
+#define	FRF_CZ_TMFT_TXQ_ID_LBN 61
+#define	FRF_CZ_TMFT_TXQ_ID_WIDTH 12
+#define	FRF_CZ_TMFT_WILDCARD_MATCH_LBN 60
+#define	FRF_CZ_TMFT_WILDCARD_MATCH_WIDTH 1
+#define	FRF_CZ_TMFT_SRC_MAC_LBN 16
+#define	FRF_CZ_TMFT_SRC_MAC_WIDTH 44
+#define	FRF_CZ_TMFT_VLAN_ID_LBN 0
+#define	FRF_CZ_TMFT_VLAN_ID_WIDTH 12
+
+/* MC_TREG_SMEM: MC Shared Memory */
+#define	FR_CZ_MC_TREG_SMEM 0x00ff0000
+#define	FR_CZ_MC_TREG_SMEM_STEP 4
+#define	FR_CZ_MC_TREG_SMEM_ROWS 512
+#define	FRF_CZ_MC_TREG_SMEM_ROW_LBN 0
+#define	FRF_CZ_MC_TREG_SMEM_ROW_WIDTH 32
+
+/* MSIX_VECTOR_TABLE: MSIX Vector Table */
+#define	FR_BB_MSIX_VECTOR_TABLE 0x00ff0000
+#define	FR_BZ_MSIX_VECTOR_TABLE_STEP 16
+#define	FR_BB_MSIX_VECTOR_TABLE_ROWS 64
+/* MSIX_VECTOR_TABLE: MSIX Vector Table */
+#define	FR_CZ_MSIX_VECTOR_TABLE 0x00000000
+/* FR_BZ_MSIX_VECTOR_TABLE_STEP 16 */
+#define	FR_CZ_MSIX_VECTOR_TABLE_ROWS 1024
+#define	FRF_BZ_MSIX_VECTOR_RESERVED_LBN 97
+#define	FRF_BZ_MSIX_VECTOR_RESERVED_WIDTH 31
+#define	FRF_BZ_MSIX_VECTOR_MASK_LBN 96
+#define	FRF_BZ_MSIX_VECTOR_MASK_WIDTH 1
+#define	FRF_BZ_MSIX_MESSAGE_DATA_LBN 64
+#define	FRF_BZ_MSIX_MESSAGE_DATA_WIDTH 32
+#define	FRF_BZ_MSIX_MESSAGE_ADDRESS_HI_LBN 32
+#define	FRF_BZ_MSIX_MESSAGE_ADDRESS_HI_WIDTH 32
+#define	FRF_BZ_MSIX_MESSAGE_ADDRESS_LO_LBN 0
+#define	FRF_BZ_MSIX_MESSAGE_ADDRESS_LO_WIDTH 32
+
+/* MSIX_PBA_TABLE: MSIX Pending Bit Array */
+#define	FR_BB_MSIX_PBA_TABLE 0x00ff2000
+#define	FR_BZ_MSIX_PBA_TABLE_STEP 4
+#define	FR_BB_MSIX_PBA_TABLE_ROWS 2
+/* MSIX_PBA_TABLE: MSIX Pending Bit Array */
+#define	FR_CZ_MSIX_PBA_TABLE 0x00008000
+/* FR_BZ_MSIX_PBA_TABLE_STEP 4 */
+#define	FR_CZ_MSIX_PBA_TABLE_ROWS 32
+#define	FRF_BZ_MSIX_PBA_PEND_DWORD_LBN 0
+#define	FRF_BZ_MSIX_PBA_PEND_DWORD_WIDTH 32
+
+/* SRM_DBG_REG: SRAM debug access */
+#define	FR_BZ_SRM_DBG 0x03000000
+#define	FR_BZ_SRM_DBG_STEP 8
+#define	FR_CZ_SRM_DBG_ROWS 262144
+#define	FR_BB_SRM_DBG_ROWS 2097152
+#define	FRF_BZ_SRM_DBG_LBN 0
+#define	FRF_BZ_SRM_DBG_WIDTH 64
+
+/* TB_MSIX_PBA_TABLE: MSIX Pending Bit Array */
+#define	FR_CZ_TB_MSIX_PBA_TABLE 0x00008000
+#define	FR_CZ_TB_MSIX_PBA_TABLE_STEP 4
+#define	FR_CZ_TB_MSIX_PBA_TABLE_ROWS 1024
+#define	FRF_CZ_TB_MSIX_PBA_PEND_DWORD_LBN 0
+#define	FRF_CZ_TB_MSIX_PBA_PEND_DWORD_WIDTH 32
+
+/* DRIVER_EV */
+#define	FSF_AZ_DRIVER_EV_SUBCODE_LBN 56
+#define	FSF_AZ_DRIVER_EV_SUBCODE_WIDTH 4
+#define	FSE_BZ_TX_DSC_ERROR_EV 15
+#define	FSE_BZ_RX_DSC_ERROR_EV 14
+#define	FSE_AA_RX_RECOVER_EV 11
+#define	FSE_AZ_TIMER_EV 10
+#define	FSE_AZ_TX_PKT_NON_TCP_UDP 9
+#define	FSE_AZ_WAKE_UP_EV 6
+#define	FSE_AZ_SRM_UPD_DONE_EV 5
+#define	FSE_AB_EVQ_NOT_EN_EV 3
+#define	FSE_AZ_EVQ_INIT_DONE_EV 2
+#define	FSE_AZ_RX_DESCQ_FLS_DONE_EV 1
+#define	FSE_AZ_TX_DESCQ_FLS_DONE_EV 0
+#define	FSF_AZ_DRIVER_EV_SUBDATA_LBN 0
+#define	FSF_AZ_DRIVER_EV_SUBDATA_WIDTH 14
+
+/* EVENT_ENTRY */
+#define	FSF_AZ_EV_CODE_LBN 60
+#define	FSF_AZ_EV_CODE_WIDTH 4
+#define	FSE_CZ_EV_CODE_MCDI_EV 12
+#define	FSE_CZ_EV_CODE_USER_EV 8
+#define	FSE_AZ_EV_CODE_DRV_GEN_EV 7
+#define	FSE_AZ_EV_CODE_GLOBAL_EV 6
+#define	FSE_AZ_EV_CODE_DRIVER_EV 5
+#define	FSE_AZ_EV_CODE_TX_EV 2
+#define	FSE_AZ_EV_CODE_RX_EV 0
+#define	FSF_AZ_EV_DATA_LBN 0
+#define	FSF_AZ_EV_DATA_WIDTH 60
+
+/* GLOBAL_EV */
+#define	FSF_BB_GLB_EV_RX_RECOVERY_LBN 12
+#define	FSF_BB_GLB_EV_RX_RECOVERY_WIDTH 1
+#define	FSF_AA_GLB_EV_RX_RECOVERY_LBN 11
+#define	FSF_AA_GLB_EV_RX_RECOVERY_WIDTH 1
+#define	FSF_BB_GLB_EV_XG_MGT_INTR_LBN 11
+#define	FSF_BB_GLB_EV_XG_MGT_INTR_WIDTH 1
+#define	FSF_AB_GLB_EV_XFP_PHY0_INTR_LBN 10
+#define	FSF_AB_GLB_EV_XFP_PHY0_INTR_WIDTH 1
+#define	FSF_AB_GLB_EV_XG_PHY0_INTR_LBN 9
+#define	FSF_AB_GLB_EV_XG_PHY0_INTR_WIDTH 1
+#define	FSF_AB_GLB_EV_G_PHY0_INTR_LBN 7
+#define	FSF_AB_GLB_EV_G_PHY0_INTR_WIDTH 1
+
+/* LEGACY_INT_VEC */
+#define	FSF_AZ_NET_IVEC_FATAL_INT_LBN 64
+#define	FSF_AZ_NET_IVEC_FATAL_INT_WIDTH 1
+#define	FSF_AZ_NET_IVEC_INT_Q_LBN 40
+#define	FSF_AZ_NET_IVEC_INT_Q_WIDTH 4
+#define	FSF_AZ_NET_IVEC_INT_FLAG_LBN 32
+#define	FSF_AZ_NET_IVEC_INT_FLAG_WIDTH 1
+#define	FSF_AZ_NET_IVEC_EVQ_FIFO_HF_LBN 1
+#define	FSF_AZ_NET_IVEC_EVQ_FIFO_HF_WIDTH 1
+#define	FSF_AZ_NET_IVEC_EVQ_FIFO_AF_LBN 0
+#define	FSF_AZ_NET_IVEC_EVQ_FIFO_AF_WIDTH 1
+
+/* MC_XGMAC_FLTR_RULE_DEF */
+#define	FSF_CZ_MC_XFRC_MODE_LBN 416
+#define	FSF_CZ_MC_XFRC_MODE_WIDTH 1
+#define	FSE_CZ_MC_XFRC_MODE_LAYERED 1
+#define	FSE_CZ_MC_XFRC_MODE_SIMPLE 0
+#define	FSF_CZ_MC_XFRC_HASH_LBN 384
+#define	FSF_CZ_MC_XFRC_HASH_WIDTH 32
+#define	FSF_CZ_MC_XFRC_LAYER4_BYTE_MASK_LBN 256
+#define	FSF_CZ_MC_XFRC_LAYER4_BYTE_MASK_WIDTH 128
+#define	FSF_CZ_MC_XFRC_LAYER3_BYTE_MASK_LBN 128
+#define	FSF_CZ_MC_XFRC_LAYER3_BYTE_MASK_WIDTH 128
+#define	FSF_CZ_MC_XFRC_LAYER2_OR_SIMPLE_BYTE_MASK_LBN 0
+#define	FSF_CZ_MC_XFRC_LAYER2_OR_SIMPLE_BYTE_MASK_WIDTH 128
+
+/* RX_EV */
+#define	FSF_CZ_RX_EV_PKT_NOT_PARSED_LBN 58
+#define	FSF_CZ_RX_EV_PKT_NOT_PARSED_WIDTH 1
+#define	FSF_CZ_RX_EV_IPV6_PKT_LBN 57
+#define	FSF_CZ_RX_EV_IPV6_PKT_WIDTH 1
+#define	FSF_AZ_RX_EV_PKT_OK_LBN 56
+#define	FSF_AZ_RX_EV_PKT_OK_WIDTH 1
+#define	FSF_AZ_RX_EV_PAUSE_FRM_ERR_LBN 55
+#define	FSF_AZ_RX_EV_PAUSE_FRM_ERR_WIDTH 1
+#define	FSF_AZ_RX_EV_BUF_OWNER_ID_ERR_LBN 54
+#define	FSF_AZ_RX_EV_BUF_OWNER_ID_ERR_WIDTH 1
+#define	FSF_AZ_RX_EV_IP_FRAG_ERR_LBN 53
+#define	FSF_AZ_RX_EV_IP_FRAG_ERR_WIDTH 1
+#define	FSF_AZ_RX_EV_IP_HDR_CHKSUM_ERR_LBN 52
+#define	FSF_AZ_RX_EV_IP_HDR_CHKSUM_ERR_WIDTH 1
+#define	FSF_AZ_RX_EV_TCP_UDP_CHKSUM_ERR_LBN 51
+#define	FSF_AZ_RX_EV_TCP_UDP_CHKSUM_ERR_WIDTH 1
+#define	FSF_AZ_RX_EV_ETH_CRC_ERR_LBN 50
+#define	FSF_AZ_RX_EV_ETH_CRC_ERR_WIDTH 1
+#define	FSF_AZ_RX_EV_FRM_TRUNC_LBN 49
+#define	FSF_AZ_RX_EV_FRM_TRUNC_WIDTH 1
+#define	FSF_AA_RX_EV_DRIB_NIB_LBN 49
+#define	FSF_AA_RX_EV_DRIB_NIB_WIDTH 1
+#define	FSF_AZ_RX_EV_TOBE_DISC_LBN 47
+#define	FSF_AZ_RX_EV_TOBE_DISC_WIDTH 1
+#define	FSF_AZ_RX_EV_PKT_TYPE_LBN 44
+#define	FSF_AZ_RX_EV_PKT_TYPE_WIDTH 3
+#define	FSE_AZ_RX_EV_PKT_TYPE_VLAN_JUMBO 5
+#define	FSE_AZ_RX_EV_PKT_TYPE_VLAN_LLC 4
+#define	FSE_AZ_RX_EV_PKT_TYPE_VLAN 3
+#define	FSE_AZ_RX_EV_PKT_TYPE_JUMBO 2
+#define	FSE_AZ_RX_EV_PKT_TYPE_LLC 1
+#define	FSE_AZ_RX_EV_PKT_TYPE_ETH 0
+#define	FSF_AZ_RX_EV_HDR_TYPE_LBN 42
+#define	FSF_AZ_RX_EV_HDR_TYPE_WIDTH 2
+#define	FSE_AZ_RX_EV_HDR_TYPE_OTHER 3
+#define	FSE_AB_RX_EV_HDR_TYPE_IPV4_OTHER 2
+#define	FSE_CZ_RX_EV_HDR_TYPE_IPV4V6_OTHER 2
+#define	FSE_AB_RX_EV_HDR_TYPE_IPV4_UDP 1
+#define	FSE_CZ_RX_EV_HDR_TYPE_IPV4V6_UDP 1
+#define	FSE_AB_RX_EV_HDR_TYPE_IPV4_TCP 0
+#define	FSE_CZ_RX_EV_HDR_TYPE_IPV4V6_TCP 0
+#define	FSF_AZ_RX_EV_DESC_Q_EMPTY_LBN 41
+#define	FSF_AZ_RX_EV_DESC_Q_EMPTY_WIDTH 1
+#define	FSF_AZ_RX_EV_MCAST_HASH_MATCH_LBN 40
+#define	FSF_AZ_RX_EV_MCAST_HASH_MATCH_WIDTH 1
+#define	FSF_AZ_RX_EV_MCAST_PKT_LBN 39
+#define	FSF_AZ_RX_EV_MCAST_PKT_WIDTH 1
+#define	FSF_AA_RX_EV_RECOVERY_FLAG_LBN 37
+#define	FSF_AA_RX_EV_RECOVERY_FLAG_WIDTH 1
+#define	FSF_AZ_RX_EV_Q_LABEL_LBN 32
+#define	FSF_AZ_RX_EV_Q_LABEL_WIDTH 5
+#define	FSF_AZ_RX_EV_JUMBO_CONT_LBN 31
+#define	FSF_AZ_RX_EV_JUMBO_CONT_WIDTH 1
+#define	FSF_AZ_RX_EV_PORT_LBN 30
+#define	FSF_AZ_RX_EV_PORT_WIDTH 1
+#define	FSF_AZ_RX_EV_BYTE_CNT_LBN 16
+#define	FSF_AZ_RX_EV_BYTE_CNT_WIDTH 14
+#define	FSF_AZ_RX_EV_SOP_LBN 15
+#define	FSF_AZ_RX_EV_SOP_WIDTH 1
+#define	FSF_AZ_RX_EV_ISCSI_PKT_OK_LBN 14
+#define	FSF_AZ_RX_EV_ISCSI_PKT_OK_WIDTH 1
+#define	FSF_AZ_RX_EV_ISCSI_DDIG_ERR_LBN 13
+#define	FSF_AZ_RX_EV_ISCSI_DDIG_ERR_WIDTH 1
+#define	FSF_AZ_RX_EV_ISCSI_HDIG_ERR_LBN 12
+#define	FSF_AZ_RX_EV_ISCSI_HDIG_ERR_WIDTH 1
+#define	FSF_AZ_RX_EV_DESC_PTR_LBN 0
+#define	FSF_AZ_RX_EV_DESC_PTR_WIDTH 12
+
+/* RX_KER_DESC */
+#define	FSF_AZ_RX_KER_BUF_SIZE_LBN 48
+#define	FSF_AZ_RX_KER_BUF_SIZE_WIDTH 14
+#define	FSF_AZ_RX_KER_BUF_REGION_LBN 46
+#define	FSF_AZ_RX_KER_BUF_REGION_WIDTH 2
+#define	FSF_AZ_RX_KER_BUF_ADDR_LBN 0
+#define	FSF_AZ_RX_KER_BUF_ADDR_WIDTH 46
+
+/* RX_USER_DESC */
+#define	FSF_AZ_RX_USER_2BYTE_OFFSET_LBN 20
+#define	FSF_AZ_RX_USER_2BYTE_OFFSET_WIDTH 12
+#define	FSF_AZ_RX_USER_BUF_ID_LBN 0
+#define	FSF_AZ_RX_USER_BUF_ID_WIDTH 20
+
+/* TX_EV */
+#define	FSF_AZ_TX_EV_PKT_ERR_LBN 38
+#define	FSF_AZ_TX_EV_PKT_ERR_WIDTH 1
+#define	FSF_AZ_TX_EV_PKT_TOO_BIG_LBN 37
+#define	FSF_AZ_TX_EV_PKT_TOO_BIG_WIDTH 1
+#define	FSF_AZ_TX_EV_Q_LABEL_LBN 32
+#define	FSF_AZ_TX_EV_Q_LABEL_WIDTH 5
+#define	FSF_AZ_TX_EV_PORT_LBN 16
+#define	FSF_AZ_TX_EV_PORT_WIDTH 1
+#define	FSF_AZ_TX_EV_WQ_FF_FULL_LBN 15
+#define	FSF_AZ_TX_EV_WQ_FF_FULL_WIDTH 1
+#define	FSF_AZ_TX_EV_BUF_OWNER_ID_ERR_LBN 14
+#define	FSF_AZ_TX_EV_BUF_OWNER_ID_ERR_WIDTH 1
+#define	FSF_AZ_TX_EV_COMP_LBN 12
+#define	FSF_AZ_TX_EV_COMP_WIDTH 1
+#define	FSF_AZ_TX_EV_DESC_PTR_LBN 0
+#define	FSF_AZ_TX_EV_DESC_PTR_WIDTH 12
+
+/* TX_KER_DESC */
+#define	FSF_AZ_TX_KER_CONT_LBN 62
+#define	FSF_AZ_TX_KER_CONT_WIDTH 1
+#define	FSF_AZ_TX_KER_BYTE_COUNT_LBN 48
+#define	FSF_AZ_TX_KER_BYTE_COUNT_WIDTH 14
+#define	FSF_AZ_TX_KER_BUF_REGION_LBN 46
+#define	FSF_AZ_TX_KER_BUF_REGION_WIDTH 2
+#define	FSF_AZ_TX_KER_BUF_ADDR_LBN 0
+#define	FSF_AZ_TX_KER_BUF_ADDR_WIDTH 46
+
+/* TX_USER_DESC */
+#define	FSF_AZ_TX_USER_SW_EV_EN_LBN 48
+#define	FSF_AZ_TX_USER_SW_EV_EN_WIDTH 1
+#define	FSF_AZ_TX_USER_CONT_LBN 46
+#define	FSF_AZ_TX_USER_CONT_WIDTH 1
+#define	FSF_AZ_TX_USER_BYTE_CNT_LBN 33
+#define	FSF_AZ_TX_USER_BYTE_CNT_WIDTH 13
+#define	FSF_AZ_TX_USER_BUF_ID_LBN 13
+#define	FSF_AZ_TX_USER_BUF_ID_WIDTH 20
+#define	FSF_AZ_TX_USER_BYTE_OFS_LBN 0
+#define	FSF_AZ_TX_USER_BYTE_OFS_WIDTH 13
+
+/* USER_EV */
+#define	FSF_CZ_USER_QID_LBN 32
+#define	FSF_CZ_USER_QID_WIDTH 10
+#define	FSF_CZ_USER_EV_REG_VALUE_LBN 0
+#define	FSF_CZ_USER_EV_REG_VALUE_WIDTH 32
+
+/**************************************************************************
+ *
+ * Falcon B0 PCIe core indirect registers
+ *
+ **************************************************************************
+ */
+
+#define FPCR_BB_PCIE_DEVICE_CTRL_STAT 0x68
+
+#define FPCR_BB_PCIE_LINK_CTRL_STAT 0x70
+
+#define FPCR_BB_ACK_RPL_TIMER 0x700
+#define FPCRF_BB_ACK_TL_LBN 0
+#define FPCRF_BB_ACK_TL_WIDTH 16
+#define FPCRF_BB_RPL_TL_LBN 16
+#define FPCRF_BB_RPL_TL_WIDTH 16
+
+#define FPCR_BB_ACK_FREQ 0x70C
+#define FPCRF_BB_ACK_FREQ_LBN 0
+#define FPCRF_BB_ACK_FREQ_WIDTH 7
+
+/**************************************************************************
+ *
+ * Pseudo-registers and fields
+ *
+ **************************************************************************
+ */
+
+/* Interrupt acknowledge work-around register (A0/A1 only) */
+#define FR_AA_WORK_AROUND_BROKEN_PCI_READS 0x0070
+
+/* EE_SPI_HCMD_REG: SPI host command register */
+/* Values for the EE_SPI_HCMD_SF_SEL register field */
+#define FFE_AB_SPI_DEVICE_EEPROM 0
+#define FFE_AB_SPI_DEVICE_FLASH 1
+
+/* NIC_STAT_REG: NIC status register */
+#define FRF_AB_STRAP_10G_LBN 2
+#define FRF_AB_STRAP_10G_WIDTH 1
+#define FRF_AA_STRAP_PCIE_LBN 0
+#define FRF_AA_STRAP_PCIE_WIDTH 1
+
+/* FATAL_INTR_REG_KER: Fatal interrupt register for Kernel */
+#define FRF_AZ_FATAL_INTR_LBN 0
+#define FRF_AZ_FATAL_INTR_WIDTH 12
+
+/* SRM_CFG_REG: SRAM configuration register */
+/* We treat the number of SRAM banks and bank size as a single field */
+#define	FRF_AZ_SRM_NB_SZ_LBN FRF_AZ_SRM_BANK_SIZE_LBN
+#define	FRF_AZ_SRM_NB_SZ_WIDTH \
+	(FRF_AZ_SRM_BANK_SIZE_WIDTH + FRF_AZ_SRM_NUM_BANK_WIDTH)
+#define FFE_AB_SRM_NB1_SZ2M 0
+#define FFE_AB_SRM_NB1_SZ4M 1
+#define FFE_AB_SRM_NB1_SZ8M 2
+#define FFE_AB_SRM_NB_SZ_DEF 3
+#define FFE_AB_SRM_NB2_SZ4M 4
+#define FFE_AB_SRM_NB2_SZ8M 5
+#define FFE_AB_SRM_NB2_SZ16M 6
+#define FFE_AB_SRM_NB_SZ_RES 7
+
+/* RX_DESC_UPD_REGP0: Receive descriptor update register. */
+/* We write just the last dword of these registers */
+#define	FR_AZ_RX_DESC_UPD_DWORD_P0 \
+	(BUILD_BUG_ON_ZERO(FR_AA_RX_DESC_UPD_KER != FR_BZ_RX_DESC_UPD_P0) + \
+	 FR_BZ_RX_DESC_UPD_P0 + 3 * 4)
+#define	FRF_AZ_RX_DESC_WPTR_DWORD_LBN (FRF_AZ_RX_DESC_WPTR_LBN - 3 * 32)
+#define	FRF_AZ_RX_DESC_WPTR_DWORD_WIDTH FRF_AZ_RX_DESC_WPTR_WIDTH
+
+/* TX_DESC_UPD_REGP0: Transmit descriptor update register. */
+#define FR_AZ_TX_DESC_UPD_DWORD_P0 \
+	(BUILD_BUG_ON_ZERO(FR_AA_TX_DESC_UPD_KER != FR_BZ_TX_DESC_UPD_P0) + \
+	 FR_BZ_TX_DESC_UPD_P0 + 3 * 4)
+#define	FRF_AZ_TX_DESC_WPTR_DWORD_LBN (FRF_AZ_TX_DESC_WPTR_LBN - 3 * 32)
+#define	FRF_AZ_TX_DESC_WPTR_DWORD_WIDTH FRF_AZ_TX_DESC_WPTR_WIDTH
+
+/* GMF_CFG4_REG: GMAC FIFO configuration register 4 */
+#define FRF_AB_GMF_HSTFLTRFRM_PAUSE_LBN 12
+#define FRF_AB_GMF_HSTFLTRFRM_PAUSE_WIDTH 1
+
+/* GMF_CFG5_REG: GMAC FIFO configuration register 5 */
+#define FRF_AB_GMF_HSTFLTRFRMDC_PAUSE_LBN 12
+#define FRF_AB_GMF_HSTFLTRFRMDC_PAUSE_WIDTH 1
+
+/* XM_TX_PARAM_REG: XGMAC transmit parameter register */
+#define	FRF_AB_XM_MAX_TX_FRM_SIZE_LBN FRF_AB_XM_MAX_TX_FRM_SIZE_LO_LBN
+#define	FRF_AB_XM_MAX_TX_FRM_SIZE_WIDTH (FRF_AB_XM_MAX_TX_FRM_SIZE_HI_WIDTH + \
+					 FRF_AB_XM_MAX_TX_FRM_SIZE_LO_WIDTH)
+
+/* XM_RX_PARAM_REG: XGMAC receive parameter register */
+#define	FRF_AB_XM_MAX_RX_FRM_SIZE_LBN FRF_AB_XM_MAX_RX_FRM_SIZE_LO_LBN
+#define	FRF_AB_XM_MAX_RX_FRM_SIZE_WIDTH (FRF_AB_XM_MAX_RX_FRM_SIZE_HI_WIDTH + \
+					 FRF_AB_XM_MAX_RX_FRM_SIZE_LO_WIDTH)
+
+/* XX_TXDRV_CTL_REG: XAUI SerDes transmit drive control register */
+/* Default values */
+#define FFE_AB_XX_TXDRV_DEQ_DEF 0xe /* deq=.6 */
+#define FFE_AB_XX_TXDRV_DTX_DEF 0x5 /* 1.25 */
+#define FFE_AB_XX_SD_CTL_DRV_DEF 0  /* 20mA */
+
+/* XX_CORE_STAT_REG: XAUI XGXS core status register */
+/* XGXS all-lanes status fields */
+#define	FRF_AB_XX_SYNC_STAT_LBN FRF_AB_XX_SYNC_STAT0_LBN
+#define	FRF_AB_XX_SYNC_STAT_WIDTH 4
+#define	FRF_AB_XX_COMMA_DET_LBN FRF_AB_XX_COMMA_DET_CH0_LBN
+#define	FRF_AB_XX_COMMA_DET_WIDTH 4
+#define	FRF_AB_XX_CHAR_ERR_LBN FRF_AB_XX_CHAR_ERR_CH0_LBN
+#define	FRF_AB_XX_CHAR_ERR_WIDTH 4
+#define	FRF_AB_XX_DISPERR_LBN FRF_AB_XX_DISPERR_CH0_LBN
+#define	FRF_AB_XX_DISPERR_WIDTH 4
+#define	FFE_AB_XX_STAT_ALL_LANES 0xf
+#define	FRF_AB_XX_FORCE_SIG_LBN FRF_AB_XX_FORCE_SIG0_VAL_LBN
+#define	FRF_AB_XX_FORCE_SIG_WIDTH 8
+#define	FFE_AB_XX_FORCE_SIG_ALL_LANES 0xff
+
+/* DRIVER_EV */
+/* Sub-fields of an RX flush completion event */
+#define FSF_AZ_DRIVER_EV_RX_FLUSH_FAIL_LBN 12
+#define FSF_AZ_DRIVER_EV_RX_FLUSH_FAIL_WIDTH 1
+#define FSF_AZ_DRIVER_EV_RX_DESCQ_ID_LBN 0
+#define FSF_AZ_DRIVER_EV_RX_DESCQ_ID_WIDTH 12
+
+/* EVENT_ENTRY */
+/* Magic number field for event test */
+#define FSF_AZ_DRV_GEN_EV_MAGIC_LBN 0
+#define FSF_AZ_DRV_GEN_EV_MAGIC_WIDTH 32
+
+/**************************************************************************
+ *
+ * Falcon MAC stats
+ *
+ **************************************************************************
+ *
+ */
+
+#define GRxGoodOct_offset 0x0
+#define GRxGoodOct_WIDTH 48
+#define GRxBadOct_offset 0x8
+#define GRxBadOct_WIDTH 48
+#define GRxMissPkt_offset 0x10
+#define GRxMissPkt_WIDTH 32
+#define GRxFalseCRS_offset 0x14
+#define GRxFalseCRS_WIDTH 32
+#define GRxPausePkt_offset 0x18
+#define GRxPausePkt_WIDTH 32
+#define GRxBadPkt_offset 0x1C
+#define GRxBadPkt_WIDTH 32
+#define GRxUcastPkt_offset 0x20
+#define GRxUcastPkt_WIDTH 32
+#define GRxMcastPkt_offset 0x24
+#define GRxMcastPkt_WIDTH 32
+#define GRxBcastPkt_offset 0x28
+#define GRxBcastPkt_WIDTH 32
+#define GRxGoodLt64Pkt_offset 0x2C
+#define GRxGoodLt64Pkt_WIDTH 32
+#define GRxBadLt64Pkt_offset 0x30
+#define GRxBadLt64Pkt_WIDTH 32
+#define GRx64Pkt_offset 0x34
+#define GRx64Pkt_WIDTH 32
+#define GRx65to127Pkt_offset 0x38
+#define GRx65to127Pkt_WIDTH 32
+#define GRx128to255Pkt_offset 0x3C
+#define GRx128to255Pkt_WIDTH 32
+#define GRx256to511Pkt_offset 0x40
+#define GRx256to511Pkt_WIDTH 32
+#define GRx512to1023Pkt_offset 0x44
+#define GRx512to1023Pkt_WIDTH 32
+#define GRx1024to15xxPkt_offset 0x48
+#define GRx1024to15xxPkt_WIDTH 32
+#define GRx15xxtoJumboPkt_offset 0x4C
+#define GRx15xxtoJumboPkt_WIDTH 32
+#define GRxGtJumboPkt_offset 0x50
+#define GRxGtJumboPkt_WIDTH 32
+#define GRxFcsErr64to15xxPkt_offset 0x54
+#define GRxFcsErr64to15xxPkt_WIDTH 32
+#define GRxFcsErr15xxtoJumboPkt_offset 0x58
+#define GRxFcsErr15xxtoJumboPkt_WIDTH 32
+#define GRxFcsErrGtJumboPkt_offset 0x5C
+#define GRxFcsErrGtJumboPkt_WIDTH 32
+#define GTxGoodBadOct_offset 0x80
+#define GTxGoodBadOct_WIDTH 48
+#define GTxGoodOct_offset 0x88
+#define GTxGoodOct_WIDTH 48
+#define GTxSglColPkt_offset 0x90
+#define GTxSglColPkt_WIDTH 32
+#define GTxMultColPkt_offset 0x94
+#define GTxMultColPkt_WIDTH 32
+#define GTxExColPkt_offset 0x98
+#define GTxExColPkt_WIDTH 32
+#define GTxDefPkt_offset 0x9C
+#define GTxDefPkt_WIDTH 32
+#define GTxLateCol_offset 0xA0
+#define GTxLateCol_WIDTH 32
+#define GTxExDefPkt_offset 0xA4
+#define GTxExDefPkt_WIDTH 32
+#define GTxPausePkt_offset 0xA8
+#define GTxPausePkt_WIDTH 32
+#define GTxBadPkt_offset 0xAC
+#define GTxBadPkt_WIDTH 32
+#define GTxUcastPkt_offset 0xB0
+#define GTxUcastPkt_WIDTH 32
+#define GTxMcastPkt_offset 0xB4
+#define GTxMcastPkt_WIDTH 32
+#define GTxBcastPkt_offset 0xB8
+#define GTxBcastPkt_WIDTH 32
+#define GTxLt64Pkt_offset 0xBC
+#define GTxLt64Pkt_WIDTH 32
+#define GTx64Pkt_offset 0xC0
+#define GTx64Pkt_WIDTH 32
+#define GTx65to127Pkt_offset 0xC4
+#define GTx65to127Pkt_WIDTH 32
+#define GTx128to255Pkt_offset 0xC8
+#define GTx128to255Pkt_WIDTH 32
+#define GTx256to511Pkt_offset 0xCC
+#define GTx256to511Pkt_WIDTH 32
+#define GTx512to1023Pkt_offset 0xD0
+#define GTx512to1023Pkt_WIDTH 32
+#define GTx1024to15xxPkt_offset 0xD4
+#define GTx1024to15xxPkt_WIDTH 32
+#define GTx15xxtoJumboPkt_offset 0xD8
+#define GTx15xxtoJumboPkt_WIDTH 32
+#define GTxGtJumboPkt_offset 0xDC
+#define GTxGtJumboPkt_WIDTH 32
+#define GTxNonTcpUdpPkt_offset 0xE0
+#define GTxNonTcpUdpPkt_WIDTH 16
+#define GTxMacSrcErrPkt_offset 0xE4
+#define GTxMacSrcErrPkt_WIDTH 16
+#define GTxIpSrcErrPkt_offset 0xE8
+#define GTxIpSrcErrPkt_WIDTH 16
+#define GDmaDone_offset 0xEC
+#define GDmaDone_WIDTH 32
+
+#define XgRxOctets_offset 0x0
+#define XgRxOctets_WIDTH 48
+#define XgRxOctetsOK_offset 0x8
+#define XgRxOctetsOK_WIDTH 48
+#define XgRxPkts_offset 0x10
+#define XgRxPkts_WIDTH 32
+#define XgRxPktsOK_offset 0x14
+#define XgRxPktsOK_WIDTH 32
+#define XgRxBroadcastPkts_offset 0x18
+#define XgRxBroadcastPkts_WIDTH 32
+#define XgRxMulticastPkts_offset 0x1C
+#define XgRxMulticastPkts_WIDTH 32
+#define XgRxUnicastPkts_offset 0x20
+#define XgRxUnicastPkts_WIDTH 32
+#define XgRxUndersizePkts_offset 0x24
+#define XgRxUndersizePkts_WIDTH 32
+#define XgRxOversizePkts_offset 0x28
+#define XgRxOversizePkts_WIDTH 32
+#define XgRxJabberPkts_offset 0x2C
+#define XgRxJabberPkts_WIDTH 32
+#define XgRxUndersizeFCSerrorPkts_offset 0x30
+#define XgRxUndersizeFCSerrorPkts_WIDTH 32
+#define XgRxDropEvents_offset 0x34
+#define XgRxDropEvents_WIDTH 32
+#define XgRxFCSerrorPkts_offset 0x38
+#define XgRxFCSerrorPkts_WIDTH 32
+#define XgRxAlignError_offset 0x3C
+#define XgRxAlignError_WIDTH 32
+#define XgRxSymbolError_offset 0x40
+#define XgRxSymbolError_WIDTH 32
+#define XgRxInternalMACError_offset 0x44
+#define XgRxInternalMACError_WIDTH 32
+#define XgRxControlPkts_offset 0x48
+#define XgRxControlPkts_WIDTH 32
+#define XgRxPausePkts_offset 0x4C
+#define XgRxPausePkts_WIDTH 32
+#define XgRxPkts64Octets_offset 0x50
+#define XgRxPkts64Octets_WIDTH 32
+#define XgRxPkts65to127Octets_offset 0x54
+#define XgRxPkts65to127Octets_WIDTH 32
+#define XgRxPkts128to255Octets_offset 0x58
+#define XgRxPkts128to255Octets_WIDTH 32
+#define XgRxPkts256to511Octets_offset 0x5C
+#define XgRxPkts256to511Octets_WIDTH 32
+#define XgRxPkts512to1023Octets_offset 0x60
+#define XgRxPkts512to1023Octets_WIDTH 32
+#define XgRxPkts1024to15xxOctets_offset 0x64
+#define XgRxPkts1024to15xxOctets_WIDTH 32
+#define XgRxPkts15xxtoMaxOctets_offset 0x68
+#define XgRxPkts15xxtoMaxOctets_WIDTH 32
+#define XgRxLengthError_offset 0x6C
+#define XgRxLengthError_WIDTH 32
+#define XgTxPkts_offset 0x80
+#define XgTxPkts_WIDTH 32
+#define XgTxOctets_offset 0x88
+#define XgTxOctets_WIDTH 48
+#define XgTxMulticastPkts_offset 0x90
+#define XgTxMulticastPkts_WIDTH 32
+#define XgTxBroadcastPkts_offset 0x94
+#define XgTxBroadcastPkts_WIDTH 32
+#define XgTxUnicastPkts_offset 0x98
+#define XgTxUnicastPkts_WIDTH 32
+#define XgTxControlPkts_offset 0x9C
+#define XgTxControlPkts_WIDTH 32
+#define XgTxPausePkts_offset 0xA0
+#define XgTxPausePkts_WIDTH 32
+#define XgTxPkts64Octets_offset 0xA4
+#define XgTxPkts64Octets_WIDTH 32
+#define XgTxPkts65to127Octets_offset 0xA8
+#define XgTxPkts65to127Octets_WIDTH 32
+#define XgTxPkts128to255Octets_offset 0xAC
+#define XgTxPkts128to255Octets_WIDTH 32
+#define XgTxPkts256to511Octets_offset 0xB0
+#define XgTxPkts256to511Octets_WIDTH 32
+#define XgTxPkts512to1023Octets_offset 0xB4
+#define XgTxPkts512to1023Octets_WIDTH 32
+#define XgTxPkts1024to15xxOctets_offset 0xB8
+#define XgTxPkts1024to15xxOctets_WIDTH 32
+#define XgTxPkts1519toMaxOctets_offset 0xBC
+#define XgTxPkts1519toMaxOctets_WIDTH 32
+#define XgTxUndersizePkts_offset 0xC0
+#define XgTxUndersizePkts_WIDTH 32
+#define XgTxOversizePkts_offset 0xC4
+#define XgTxOversizePkts_WIDTH 32
+#define XgTxNonTcpUdpPkt_offset 0xC8
+#define XgTxNonTcpUdpPkt_WIDTH 16
+#define XgTxMacSrcErrPkt_offset 0xCC
+#define XgTxMacSrcErrPkt_WIDTH 16
+#define XgTxIpSrcErrPkt_offset 0xD0
+#define XgTxIpSrcErrPkt_WIDTH 16
+#define XgDmaDone_offset 0xD4
+#define XgDmaDone_WIDTH 32
+
+#define FALCON_STATS_NOT_DONE 0x00000000
+#define FALCON_STATS_DONE 0xffffffff
+
+/* Interrupt status register bits */
+#define FATAL_INT_LBN 64
+#define FATAL_INT_WIDTH 1
+#define INT_EVQS_LBN 40
+#define INT_EVQS_WIDTH 4
+#define INT_FLAG_LBN 32
+#define INT_FLAG_WIDTH 1
+#define EVQ_FIFO_HF_LBN 1
+#define EVQ_FIFO_HF_WIDTH 1
+#define EVQ_FIFO_AF_LBN 0
+#define EVQ_FIFO_AF_WIDTH 1
+
+/**************************************************************************
+ *
+ * Falcon non-volatile configuration
+ *
+ **************************************************************************
+ */
+
+/* Board configuration v2 (v1 is obsolete; later versions are compatible) */
+struct falcon_nvconfig_board_v2 {
+	__le16 nports;
+	u8 port0_phy_addr;
+	u8 port0_phy_type;
+	u8 port1_phy_addr;
+	u8 port1_phy_type;
+	__le16 asic_sub_revision;
+	__le16 board_revision;
+} __packed;
+
+/* Board configuration v3 extra information */
+struct falcon_nvconfig_board_v3 {
+	__le32 spi_device_type[2];
+} __packed;
+
+/* Bit numbers for spi_device_type */
+#define SPI_DEV_TYPE_SIZE_LBN 0
+#define SPI_DEV_TYPE_SIZE_WIDTH 5
+#define SPI_DEV_TYPE_ADDR_LEN_LBN 6
+#define SPI_DEV_TYPE_ADDR_LEN_WIDTH 2
+#define SPI_DEV_TYPE_ERASE_CMD_LBN 8
+#define SPI_DEV_TYPE_ERASE_CMD_WIDTH 8
+#define SPI_DEV_TYPE_ERASE_SIZE_LBN 16
+#define SPI_DEV_TYPE_ERASE_SIZE_WIDTH 5
+#define SPI_DEV_TYPE_BLOCK_SIZE_LBN 24
+#define SPI_DEV_TYPE_BLOCK_SIZE_WIDTH 5
+#define SPI_DEV_TYPE_FIELD(type, field)					\
+	(((type) >> EFX_LOW_BIT(field)) & EFX_MASK32(EFX_WIDTH(field)))
+
+#define FALCON_NVCONFIG_OFFSET 0x300
+
+#define FALCON_NVCONFIG_BOARD_MAGIC_NUM 0xFA1C
+struct falcon_nvconfig {
+	efx_oword_t ee_vpd_cfg_reg;			/* 0x300 */
+	u8 mac_address[2][8];			/* 0x310 */
+	efx_oword_t pcie_sd_ctl0123_reg;		/* 0x320 */
+	efx_oword_t pcie_sd_ctl45_reg;			/* 0x330 */
+	efx_oword_t pcie_pcs_ctl_stat_reg;		/* 0x340 */
+	efx_oword_t hw_init_reg;			/* 0x350 */
+	efx_oword_t nic_stat_reg;			/* 0x360 */
+	efx_oword_t glb_ctl_reg;			/* 0x370 */
+	efx_oword_t srm_cfg_reg;			/* 0x380 */
+	efx_oword_t spare_reg;				/* 0x390 */
+	__le16 board_magic_num;			/* 0x3A0 */
+	__le16 board_struct_ver;
+	__le16 board_checksum;
+	struct falcon_nvconfig_board_v2 board_v2;
+	efx_oword_t ee_base_page_reg;			/* 0x3B0 */
+	struct falcon_nvconfig_board_v3 board_v3;	/* 0x3C0 */
+} __packed;
+
+#endif /* EFX_REGS_H */
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index f5797a3..390b27b 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -14,7 +14,7 @@
 #include "mdio_10g.h"
 #include "falcon.h"
 #include "phy.h"
-#include "falcon_hwdefs.h"
+#include "regs.h"
 #include "workarounds.h"
 #include "selftest.h"
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

