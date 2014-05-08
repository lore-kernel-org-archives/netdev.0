From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net] Altera TSE: Fix sparse errors and warnings
Date: Thu,  8 May 2014 13:15:40 -0500
Message-ID: <1399572940-32233-2-git-send-email-vbridgers2013@gmail.com>
References: <1399572940-32233-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:49025 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754876AbaEHST7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 14:19:59 -0400
Received: by mail-pa0-f52.google.com with SMTP id kx10so3242884pab.11
        for <netdev@vger.kernel.org>; Thu, 08 May 2014 11:19:58 -0700 (PDT)
In-Reply-To: <1399572940-32233-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the many sparse errors and warnings contained in the
initial submission of the Altera Triple Speed Ethernet driver, and a
few minor cppcheck warnings. Changes are tested on ARM and NIOS2
example designs, and compile tested against multiple architectures.
Typical issues addressed were as follows:

altera_tse_ethtool.c:136:19: warning: incorrect type in argument
    1 (different address spaces)
altera_tse_ethtool.c:136:19:    expected void const volatile
    [noderef] <asn:2>*addr
altera_tse_ethtool.c:136:19:    got unsigned int *<noident>
...
altera_sgdma.c:129:31: warning: cast removes address space of
    expression

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
 drivers/net/ethernet/altera/Makefile             |    1 +
 drivers/net/ethernet/altera/altera_msgdma.c      |  110 ++++++-------
 drivers/net/ethernet/altera/altera_msgdmahw.h    |   13 +-
 drivers/net/ethernet/altera/altera_sgdma.c       |  181 +++++++++++-----------
 drivers/net/ethernet/altera/altera_sgdmahw.h     |   26 ++--
 drivers/net/ethernet/altera/altera_tse.h         |   47 ++++++
 drivers/net/ethernet/altera/altera_tse_ethtool.c |  108 ++++++++-----
 drivers/net/ethernet/altera/altera_tse_main.c    |  133 +++++++++-------
 drivers/net/ethernet/altera/altera_utils.c       |   20 +--
 drivers/net/ethernet/altera/altera_utils.h       |    8 +-
 10 files changed, 372 insertions(+), 275 deletions(-)

diff --git a/drivers/net/ethernet/altera/Makefile b/drivers/net/ethernet/altera/Makefile
index d4a187e..3eff2fd 100644
--- a/drivers/net/ethernet/altera/Makefile
+++ b/drivers/net/ethernet/altera/Makefile
@@ -5,3 +5,4 @@
 obj-$(CONFIG_ALTERA_TSE) += altera_tse.o
 altera_tse-objs := altera_tse_main.o altera_tse_ethtool.o \
 altera_msgdma.o altera_sgdma.o altera_utils.o
+ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/ethernet/altera/altera_msgdma.c b/drivers/net/ethernet/altera/altera_msgdma.c
index 4d1f2fd..0fb986b 100644
--- a/drivers/net/ethernet/altera/altera_msgdma.c
+++ b/drivers/net/ethernet/altera/altera_msgdma.c
@@ -37,18 +37,16 @@ void msgdma_start_rxdma(struct altera_tse_private *priv)
 void msgdma_reset(struct altera_tse_private *priv)
 {
 	int counter;
-	struct msgdma_csr *txcsr =
-		(struct msgdma_csr *)priv->tx_dma_csr;
-	struct msgdma_csr *rxcsr =
-		(struct msgdma_csr *)priv->rx_dma_csr;
 
 	/* Reset Rx mSGDMA */
-	iowrite32(MSGDMA_CSR_STAT_MASK, &rxcsr->status);
-	iowrite32(MSGDMA_CSR_CTL_RESET, &rxcsr->control);
+	csrwr32(MSGDMA_CSR_STAT_MASK, priv->rx_dma_csr,
+		msgdma_csroffs(status));
+	csrwr32(MSGDMA_CSR_CTL_RESET, priv->rx_dma_csr,
+		msgdma_csroffs(control));
 
 	counter = 0;
 	while (counter++ < ALTERA_TSE_SW_RESET_WATCHDOG_CNTR) {
-		if (tse_bit_is_clear(&rxcsr->status,
+		if (tse_bit_is_clear(priv->rx_dma_csr, msgdma_csroffs(status),
 				     MSGDMA_CSR_STAT_RESETTING))
 			break;
 		udelay(1);
@@ -59,15 +57,18 @@ void msgdma_reset(struct altera_tse_private *priv)
 			   "TSE Rx mSGDMA resetting bit never cleared!\n");
 
 	/* clear all status bits */
-	iowrite32(MSGDMA_CSR_STAT_MASK, &rxcsr->status);
+	csrwr32(MSGDMA_CSR_STAT_MASK, priv->rx_dma_csr, msgdma_csroffs(status));
 
 	/* Reset Tx mSGDMA */
-	iowrite32(MSGDMA_CSR_STAT_MASK, &txcsr->status);
-	iowrite32(MSGDMA_CSR_CTL_RESET, &txcsr->control);
+	csrwr32(MSGDMA_CSR_STAT_MASK, priv->tx_dma_csr,
+		msgdma_csroffs(status));
+
+	csrwr32(MSGDMA_CSR_CTL_RESET, priv->tx_dma_csr,
+		msgdma_csroffs(control));
 
 	counter = 0;
 	while (counter++ < ALTERA_TSE_SW_RESET_WATCHDOG_CNTR) {
-		if (tse_bit_is_clear(&txcsr->status,
+		if (tse_bit_is_clear(priv->tx_dma_csr, msgdma_csroffs(status),
 				     MSGDMA_CSR_STAT_RESETTING))
 			break;
 		udelay(1);
@@ -78,58 +79,58 @@ void msgdma_reset(struct altera_tse_private *priv)
 			   "TSE Tx mSGDMA resetting bit never cleared!\n");
 
 	/* clear all status bits */
-	iowrite32(MSGDMA_CSR_STAT_MASK, &txcsr->status);
+	csrwr32(MSGDMA_CSR_STAT_MASK, priv->tx_dma_csr, msgdma_csroffs(status));
 }
 
 void msgdma_disable_rxirq(struct altera_tse_private *priv)
 {
-	struct msgdma_csr *csr = priv->rx_dma_csr;
-	tse_clear_bit(&csr->control, MSGDMA_CSR_CTL_GLOBAL_INTR);
+	tse_clear_bit(priv->rx_dma_csr, msgdma_csroffs(control),
+		      MSGDMA_CSR_CTL_GLOBAL_INTR);
 }
 
 void msgdma_enable_rxirq(struct altera_tse_private *priv)
 {
-	struct msgdma_csr *csr = priv->rx_dma_csr;
-	tse_set_bit(&csr->control, MSGDMA_CSR_CTL_GLOBAL_INTR);
+	tse_set_bit(priv->rx_dma_csr, msgdma_csroffs(control),
+		    MSGDMA_CSR_CTL_GLOBAL_INTR);
 }
 
 void msgdma_disable_txirq(struct altera_tse_private *priv)
 {
-	struct msgdma_csr *csr = priv->tx_dma_csr;
-	tse_clear_bit(&csr->control, MSGDMA_CSR_CTL_GLOBAL_INTR);
+	tse_clear_bit(priv->tx_dma_csr, msgdma_csroffs(control),
+		      MSGDMA_CSR_CTL_GLOBAL_INTR);
 }
 
 void msgdma_enable_txirq(struct altera_tse_private *priv)
 {
-	struct msgdma_csr *csr = priv->tx_dma_csr;
-	tse_set_bit(&csr->control, MSGDMA_CSR_CTL_GLOBAL_INTR);
+	tse_set_bit(priv->tx_dma_csr, msgdma_csroffs(control),
+		    MSGDMA_CSR_CTL_GLOBAL_INTR);
 }
 
 void msgdma_clear_rxirq(struct altera_tse_private *priv)
 {
-	struct msgdma_csr *csr = priv->rx_dma_csr;
-	iowrite32(MSGDMA_CSR_STAT_IRQ, &csr->status);
+	csrwr32(MSGDMA_CSR_STAT_IRQ, priv->rx_dma_csr, msgdma_csroffs(status));
 }
 
 void msgdma_clear_txirq(struct altera_tse_private *priv)
 {
-	struct msgdma_csr *csr = priv->tx_dma_csr;
-	iowrite32(MSGDMA_CSR_STAT_IRQ, &csr->status);
+	csrwr32(MSGDMA_CSR_STAT_IRQ, priv->tx_dma_csr, msgdma_csroffs(status));
 }
 
 /* return 0 to indicate transmit is pending */
 int msgdma_tx_buffer(struct altera_tse_private *priv, struct tse_buffer *buffer)
 {
-	struct msgdma_extended_desc *desc = priv->tx_dma_desc;
-
-	iowrite32(lower_32_bits(buffer->dma_addr), &desc->read_addr_lo);
-	iowrite32(upper_32_bits(buffer->dma_addr), &desc->read_addr_hi);
-	iowrite32(0, &desc->write_addr_lo);
-	iowrite32(0, &desc->write_addr_hi);
-	iowrite32(buffer->len, &desc->len);
-	iowrite32(0, &desc->burst_seq_num);
-	iowrite32(MSGDMA_DESC_TX_STRIDE, &desc->stride);
-	iowrite32(MSGDMA_DESC_CTL_TX_SINGLE, &desc->control);
+	csrwr32(lower_32_bits(buffer->dma_addr), priv->tx_dma_desc,
+		msgdma_descroffs(read_addr_lo));
+	csrwr32(upper_32_bits(buffer->dma_addr), priv->tx_dma_desc,
+		msgdma_descroffs(read_addr_hi));
+	csrwr32(0, priv->tx_dma_desc, msgdma_descroffs(write_addr_lo));
+	csrwr32(0, priv->tx_dma_desc, msgdma_descroffs(write_addr_hi));
+	csrwr32(buffer->len, priv->tx_dma_desc, msgdma_descroffs(len));
+	csrwr32(0, priv->tx_dma_desc, msgdma_descroffs(burst_seq_num));
+	csrwr32(MSGDMA_DESC_TX_STRIDE, priv->tx_dma_desc,
+		msgdma_descroffs(stride));
+	csrwr32(MSGDMA_DESC_CTL_TX_SINGLE, priv->tx_dma_desc,
+		msgdma_descroffs(control));
 	return 0;
 }
 
@@ -138,17 +139,16 @@ u32 msgdma_tx_completions(struct altera_tse_private *priv)
 	u32 ready = 0;
 	u32 inuse;
 	u32 status;
-	struct msgdma_csr *txcsr =
-		(struct msgdma_csr *)priv->tx_dma_csr;
 
 	/* Get number of sent descriptors */
-	inuse = ioread32(&txcsr->rw_fill_level) & 0xffff;
+	inuse = csrrd32(priv->tx_dma_csr, msgdma_csroffs(rw_fill_level))
+			& 0xffff;
 
 	if (inuse) { /* Tx FIFO is not empty */
 		ready = priv->tx_prod - priv->tx_cons - inuse - 1;
 	} else {
 		/* Check for buffered last packet */
-		status = ioread32(&txcsr->status);
+		status = csrrd32(priv->tx_dma_csr, msgdma_csroffs(status));
 		if (status & MSGDMA_CSR_STAT_BUSY)
 			ready = priv->tx_prod - priv->tx_cons - 1;
 		else
@@ -162,7 +162,6 @@ u32 msgdma_tx_completions(struct altera_tse_private *priv)
 void msgdma_add_rx_desc(struct altera_tse_private *priv,
 			struct tse_buffer *rxbuffer)
 {
-	struct msgdma_extended_desc *desc = priv->rx_dma_desc;
 	u32 len = priv->rx_dma_buf_sz;
 	dma_addr_t dma_addr = rxbuffer->dma_addr;
 	u32 control = (MSGDMA_DESC_CTL_END_ON_EOP
@@ -172,14 +171,16 @@ void msgdma_add_rx_desc(struct altera_tse_private *priv,
 			| MSGDMA_DESC_CTL_TR_ERR_IRQ
 			| MSGDMA_DESC_CTL_GO);
 
-	iowrite32(0, &desc->read_addr_lo);
-	iowrite32(0, &desc->read_addr_hi);
-	iowrite32(lower_32_bits(dma_addr), &desc->write_addr_lo);
-	iowrite32(upper_32_bits(dma_addr), &desc->write_addr_hi);
-	iowrite32(len, &desc->len);
-	iowrite32(0, &desc->burst_seq_num);
-	iowrite32(0x00010001, &desc->stride);
-	iowrite32(control, &desc->control);
+	csrwr32(0, priv->rx_dma_desc, msgdma_descroffs(read_addr_lo));
+	csrwr32(0, priv->rx_dma_desc, msgdma_descroffs(read_addr_hi));
+	csrwr32(lower_32_bits(dma_addr), priv->rx_dma_desc,
+		msgdma_descroffs(write_addr_lo));
+	csrwr32(upper_32_bits(dma_addr), priv->rx_dma_desc,
+		msgdma_descroffs(write_addr_hi));
+	csrwr32(len, priv->rx_dma_desc, msgdma_descroffs(len));
+	csrwr32(0, priv->rx_dma_desc, msgdma_descroffs(burst_seq_num));
+	csrwr32(0x00010001, priv->rx_dma_desc, msgdma_descroffs(stride));
+	csrwr32(control, priv->rx_dma_desc, msgdma_descroffs(control));
 }
 
 /* status is returned on upper 16 bits,
@@ -190,14 +191,13 @@ u32 msgdma_rx_status(struct altera_tse_private *priv)
 	u32 rxstatus = 0;
 	u32 pktlength;
 	u32 pktstatus;
-	struct msgdma_csr *rxcsr =
-		(struct msgdma_csr *)priv->rx_dma_csr;
-	struct msgdma_response *rxresp =
-		(struct msgdma_response *)priv->rx_dma_resp;
-
-	if (ioread32(&rxcsr->resp_fill_level) & 0xffff) {
-		pktlength = ioread32(&rxresp->bytes_transferred);
-		pktstatus = ioread32(&rxresp->status);
+
+	if (csrrd32(priv->rx_dma_csr, msgdma_csroffs(resp_fill_level))
+	    & 0xffff) {
+		pktlength = csrrd32(priv->rx_dma_resp,
+				    msgdma_respoffs(bytes_transferred));
+		pktstatus = csrrd32(priv->rx_dma_resp,
+				    msgdma_respoffs(status));
 		rxstatus = pktstatus;
 		rxstatus = rxstatus << 16;
 		rxstatus |= (pktlength & 0xffff);
diff --git a/drivers/net/ethernet/altera/altera_msgdmahw.h b/drivers/net/ethernet/altera/altera_msgdmahw.h
index d7b59ba..e335626 100644
--- a/drivers/net/ethernet/altera/altera_msgdmahw.h
+++ b/drivers/net/ethernet/altera/altera_msgdmahw.h
@@ -17,15 +17,6 @@
 #ifndef __ALTERA_MSGDMAHW_H__
 #define __ALTERA_MSGDMAHW_H__
 
-/* mSGDMA standard descriptor format
- */
-struct msgdma_desc {
-	u32 read_addr;	/* data buffer source address */
-	u32 write_addr;	/* data buffer destination address */
-	u32 len;	/* the number of bytes to transfer per descriptor */
-	u32 control;	/* characteristics of the transfer */
-};
-
 /* mSGDMA extended descriptor format
  */
 struct msgdma_extended_desc {
@@ -159,6 +150,10 @@ struct msgdma_response {
 	u32 status;
 };
 
+#define msgdma_respoffs(a) (offsetof(struct msgdma_response, a))
+#define msgdma_csroffs(a) (offsetof(struct msgdma_csr, a))
+#define msgdma_descroffs(a) (offsetof(struct msgdma_extended_desc, a))
+
 /* mSGDMA response register bit definitions
  */
 #define MSGDMA_RESP_EARLY_TERM	BIT(8)
diff --git a/drivers/net/ethernet/altera/altera_sgdma.c b/drivers/net/ethernet/altera/altera_sgdma.c
index 9ce8630..99cc56f 100644
--- a/drivers/net/ethernet/altera/altera_sgdma.c
+++ b/drivers/net/ethernet/altera/altera_sgdma.c
@@ -20,8 +20,8 @@
 #include "altera_sgdmahw.h"
 #include "altera_sgdma.h"
 
-static void sgdma_setup_descrip(struct sgdma_descrip *desc,
-				struct sgdma_descrip *ndesc,
+static void sgdma_setup_descrip(struct sgdma_descrip __iomem *desc,
+				struct sgdma_descrip __iomem *ndesc,
 				dma_addr_t ndesc_phys,
 				dma_addr_t raddr,
 				dma_addr_t waddr,
@@ -31,17 +31,17 @@ static void sgdma_setup_descrip(struct sgdma_descrip *desc,
 				int wfixed);
 
 static int sgdma_async_write(struct altera_tse_private *priv,
-			      struct sgdma_descrip *desc);
+			      struct sgdma_descrip __iomem *desc);
 
 static int sgdma_async_read(struct altera_tse_private *priv);
 
 static dma_addr_t
 sgdma_txphysaddr(struct altera_tse_private *priv,
-		 struct sgdma_descrip *desc);
+		 struct sgdma_descrip __iomem *desc);
 
 static dma_addr_t
 sgdma_rxphysaddr(struct altera_tse_private *priv,
-		 struct sgdma_descrip *desc);
+		 struct sgdma_descrip __iomem *desc);
 
 static int sgdma_txbusy(struct altera_tse_private *priv);
 
@@ -79,7 +79,8 @@ int sgdma_initialize(struct altera_tse_private *priv)
 	priv->rxdescphys = (dma_addr_t) 0;
 	priv->txdescphys = (dma_addr_t) 0;
 
-	priv->rxdescphys = dma_map_single(priv->device, priv->rx_dma_desc,
+	priv->rxdescphys = dma_map_single(priv->device,
+					  (void __force *)priv->rx_dma_desc,
 					  priv->rxdescmem, DMA_BIDIRECTIONAL);
 
 	if (dma_mapping_error(priv->device, priv->rxdescphys)) {
@@ -88,7 +89,8 @@ int sgdma_initialize(struct altera_tse_private *priv)
 		return -EINVAL;
 	}
 
-	priv->txdescphys = dma_map_single(priv->device, priv->tx_dma_desc,
+	priv->txdescphys = dma_map_single(priv->device,
+					  (void __force *)priv->tx_dma_desc,
 					  priv->txdescmem, DMA_TO_DEVICE);
 
 	if (dma_mapping_error(priv->device, priv->txdescphys)) {
@@ -98,8 +100,8 @@ int sgdma_initialize(struct altera_tse_private *priv)
 	}
 
 	/* Initialize descriptor memory to all 0's, sync memory to cache */
-	memset(priv->tx_dma_desc, 0, priv->txdescmem);
-	memset(priv->rx_dma_desc, 0, priv->rxdescmem);
+	memset_io(priv->tx_dma_desc, 0, priv->txdescmem);
+	memset_io(priv->rx_dma_desc, 0, priv->rxdescmem);
 
 	dma_sync_single_for_device(priv->device, priv->txdescphys,
 				   priv->txdescmem, DMA_TO_DEVICE);
@@ -126,22 +128,15 @@ void sgdma_uninitialize(struct altera_tse_private *priv)
  */
 void sgdma_reset(struct altera_tse_private *priv)
 {
-	u32 *ptxdescripmem = (u32 *)priv->tx_dma_desc;
-	u32 txdescriplen   = priv->txdescmem;
-	u32 *prxdescripmem = (u32 *)priv->rx_dma_desc;
-	u32 rxdescriplen   = priv->rxdescmem;
-	struct sgdma_csr *ptxsgdma = (struct sgdma_csr *)priv->tx_dma_csr;
-	struct sgdma_csr *prxsgdma = (struct sgdma_csr *)priv->rx_dma_csr;
-
 	/* Initialize descriptor memory to 0 */
-	memset(ptxdescripmem, 0, txdescriplen);
-	memset(prxdescripmem, 0, rxdescriplen);
+	memset_io(priv->tx_dma_desc, 0, priv->txdescmem);
+	memset_io(priv->rx_dma_desc, 0, priv->rxdescmem);
 
-	iowrite32(SGDMA_CTRLREG_RESET, &ptxsgdma->control);
-	iowrite32(0, &ptxsgdma->control);
+	csrwr32(SGDMA_CTRLREG_RESET, priv->tx_dma_csr, sgdma_csroffs(control));
+	csrwr32(0, priv->tx_dma_csr, sgdma_csroffs(control));
 
-	iowrite32(SGDMA_CTRLREG_RESET, &prxsgdma->control);
-	iowrite32(0, &prxsgdma->control);
+	csrwr32(SGDMA_CTRLREG_RESET, priv->rx_dma_csr, sgdma_csroffs(control));
+	csrwr32(0, priv->rx_dma_csr, sgdma_csroffs(control));
 }
 
 /* For SGDMA, interrupts remain enabled after initially enabling,
@@ -167,14 +162,14 @@ void sgdma_disable_txirq(struct altera_tse_private *priv)
 
 void sgdma_clear_rxirq(struct altera_tse_private *priv)
 {
-	struct sgdma_csr *csr = (struct sgdma_csr *)priv->rx_dma_csr;
-	tse_set_bit(&csr->control, SGDMA_CTRLREG_CLRINT);
+	tse_set_bit(priv->rx_dma_csr, sgdma_csroffs(control),
+		    SGDMA_CTRLREG_CLRINT);
 }
 
 void sgdma_clear_txirq(struct altera_tse_private *priv)
 {
-	struct sgdma_csr *csr = (struct sgdma_csr *)priv->tx_dma_csr;
-	tse_set_bit(&csr->control, SGDMA_CTRLREG_CLRINT);
+	tse_set_bit(priv->tx_dma_csr, sgdma_csroffs(control),
+		    SGDMA_CTRLREG_CLRINT);
 }
 
 /* transmits buffer through SGDMA. Returns number of buffers
@@ -184,12 +179,11 @@ void sgdma_clear_txirq(struct altera_tse_private *priv)
  */
 int sgdma_tx_buffer(struct altera_tse_private *priv, struct tse_buffer *buffer)
 {
-	int pktstx = 0;
-	struct sgdma_descrip *descbase =
-		(struct sgdma_descrip *)priv->tx_dma_desc;
+	struct sgdma_descrip __iomem *descbase =
+		(struct sgdma_descrip __iomem *)priv->tx_dma_desc;
 
-	struct sgdma_descrip *cdesc = &descbase[0];
-	struct sgdma_descrip *ndesc = &descbase[1];
+	struct sgdma_descrip __iomem *cdesc = &descbase[0];
+	struct sgdma_descrip __iomem *ndesc = &descbase[1];
 
 	/* wait 'til the tx sgdma is ready for the next transmit request */
 	if (sgdma_txbusy(priv))
@@ -205,7 +199,7 @@ int sgdma_tx_buffer(struct altera_tse_private *priv, struct tse_buffer *buffer)
 			    0,				/* read fixed */
 			    SGDMA_CONTROL_WR_FIXED);	/* Generate SOP */
 
-	pktstx = sgdma_async_write(priv, cdesc);
+	sgdma_async_write(priv, cdesc);
 
 	/* enqueue the request to the pending transmit queue */
 	queue_tx(priv, buffer);
@@ -219,10 +213,10 @@ int sgdma_tx_buffer(struct altera_tse_private *priv, struct tse_buffer *buffer)
 u32 sgdma_tx_completions(struct altera_tse_private *priv)
 {
 	u32 ready = 0;
-	struct sgdma_descrip *desc = (struct sgdma_descrip *)priv->tx_dma_desc;
 
 	if (!sgdma_txbusy(priv) &&
-	    ((desc->control & SGDMA_CONTROL_HW_OWNED) == 0) &&
+	    ((csrrd8(priv->tx_dma_desc, sgdma_descroffs(control))
+	     & SGDMA_CONTROL_HW_OWNED) == 0) &&
 	    (dequeue_tx(priv))) {
 		ready = 1;
 	}
@@ -246,32 +240,31 @@ void sgdma_add_rx_desc(struct altera_tse_private *priv,
  */
 u32 sgdma_rx_status(struct altera_tse_private *priv)
 {
-	struct sgdma_csr *csr = (struct sgdma_csr *)priv->rx_dma_csr;
-	struct sgdma_descrip *base = (struct sgdma_descrip *)priv->rx_dma_desc;
-	struct sgdma_descrip *desc = NULL;
-	int pktsrx;
-	unsigned int rxstatus = 0;
-	unsigned int pktlength = 0;
-	unsigned int pktstatus = 0;
+	struct sgdma_descrip __iomem *base =
+		(struct sgdma_descrip __iomem *)priv->rx_dma_desc;
+	struct sgdma_descrip __iomem *desc = NULL;
 	struct tse_buffer *rxbuffer = NULL;
+	unsigned int rxstatus = 0;
 
-	u32 sts = ioread32(&csr->status);
+	u32 sts = csrrd32(priv->rx_dma_csr, sgdma_csroffs(status));
 
 	desc = &base[0];
 	if (sts & SGDMA_STSREG_EOP) {
+		unsigned int pktlength = 0;
+		unsigned int pktstatus = 0;
 		dma_sync_single_for_cpu(priv->device,
 					priv->rxdescphys,
 					priv->sgdmadesclen,
 					DMA_FROM_DEVICE);
 
-		pktlength = desc->bytes_xferred;
-		pktstatus = desc->status & 0x3f;
-		rxstatus = pktstatus;
+		pktlength = csrrd16(desc, sgdma_descroffs(bytes_xferred));
+		pktstatus = csrrd8(desc, sgdma_descroffs(status));
+		rxstatus = pktstatus & ~SGDMA_STATUS_EOP;
 		rxstatus = rxstatus << 16;
 		rxstatus |= (pktlength & 0xffff);
 
 		if (rxstatus) {
-			desc->status = 0;
+			csrwr8(0, desc, sgdma_descroffs(status));
 
 			rxbuffer = dequeue_rx(priv);
 			if (rxbuffer == NULL)
@@ -279,12 +272,12 @@ u32 sgdma_rx_status(struct altera_tse_private *priv)
 					    "sgdma rx and rx queue empty!\n");
 
 			/* Clear control */
-			iowrite32(0, &csr->control);
+			csrwr32(0, priv->rx_dma_csr, sgdma_csroffs(control));
 			/* clear status */
-			iowrite32(0xf, &csr->status);
+			csrwr32(0xf, priv->rx_dma_csr, sgdma_csroffs(status));
 
 			/* kick the rx sgdma after reaping this descriptor */
-			pktsrx = sgdma_async_read(priv);
+			sgdma_async_read(priv);
 
 		} else {
 			/* If the SGDMA indicated an end of packet on recv,
@@ -298,10 +291,11 @@ u32 sgdma_rx_status(struct altera_tse_private *priv)
 			 */
 			netdev_err(priv->dev,
 				   "SGDMA RX Error Info: %x, %x, %x\n",
-				   sts, desc->status, rxstatus);
+				   sts, csrrd8(desc, sgdma_descroffs(status)),
+				   rxstatus);
 		}
 	} else if (sts == 0) {
-		pktsrx = sgdma_async_read(priv);
+		sgdma_async_read(priv);
 	}
 
 	return rxstatus;
@@ -309,8 +303,8 @@ u32 sgdma_rx_status(struct altera_tse_private *priv)
 
 
 /* Private functions */
-static void sgdma_setup_descrip(struct sgdma_descrip *desc,
-				struct sgdma_descrip *ndesc,
+static void sgdma_setup_descrip(struct sgdma_descrip __iomem *desc,
+				struct sgdma_descrip __iomem *ndesc,
 				dma_addr_t ndesc_phys,
 				dma_addr_t raddr,
 				dma_addr_t waddr,
@@ -320,27 +314,30 @@ static void sgdma_setup_descrip(struct sgdma_descrip *desc,
 				int wfixed)
 {
 	/* Clear the next descriptor as not owned by hardware */
-	u32 ctrl = ndesc->control;
+
+	u32 ctrl = csrrd8(ndesc, sgdma_descroffs(control));
 	ctrl &= ~SGDMA_CONTROL_HW_OWNED;
-	ndesc->control = ctrl;
+	csrwr8(ctrl, ndesc, sgdma_descroffs(control));
 
-	ctrl = 0;
 	ctrl = SGDMA_CONTROL_HW_OWNED;
 	ctrl |= generate_eop;
 	ctrl |= rfixed;
 	ctrl |= wfixed;
 
 	/* Channel is implicitly zero, initialized to 0 by default */
-
-	desc->raddr = raddr;
-	desc->waddr = waddr;
-	desc->next = lower_32_bits(ndesc_phys);
-	desc->control = ctrl;
-	desc->status = 0;
-	desc->rburst = 0;
-	desc->wburst = 0;
-	desc->bytes = length;
-	desc->bytes_xferred = 0;
+	csrwr32(lower_32_bits(raddr), desc, sgdma_descroffs(raddr));
+	csrwr32(lower_32_bits(waddr), desc, sgdma_descroffs(waddr));
+
+	csrwr32(0, desc, sgdma_descroffs(pad1));
+	csrwr32(0, desc, sgdma_descroffs(pad2));
+	csrwr32(lower_32_bits(ndesc_phys), desc, sgdma_descroffs(next));
+
+	csrwr8(ctrl, desc, sgdma_descroffs(control));
+	csrwr8(0, desc, sgdma_descroffs(status));
+	csrwr8(0, desc, sgdma_descroffs(wburst));
+	csrwr8(0, desc, sgdma_descroffs(rburst));
+	csrwr16(length, desc, sgdma_descroffs(bytes));
+	csrwr16(0, desc, sgdma_descroffs(bytes_xferred));
 }
 
 /* If hardware is busy, don't restart async read.
@@ -351,12 +348,11 @@ static void sgdma_setup_descrip(struct sgdma_descrip *desc,
  */
 static int sgdma_async_read(struct altera_tse_private *priv)
 {
-	struct sgdma_csr *csr = (struct sgdma_csr *)priv->rx_dma_csr;
-	struct sgdma_descrip *descbase =
-		(struct sgdma_descrip *)priv->rx_dma_desc;
+	struct sgdma_descrip __iomem *descbase =
+		(struct sgdma_descrip __iomem *)priv->rx_dma_desc;
 
-	struct sgdma_descrip *cdesc = &descbase[0];
-	struct sgdma_descrip *ndesc = &descbase[1];
+	struct sgdma_descrip __iomem *cdesc = &descbase[0];
+	struct sgdma_descrip __iomem *ndesc = &descbase[1];
 
 	struct tse_buffer *rxbuffer = NULL;
 
@@ -382,11 +378,13 @@ static int sgdma_async_read(struct altera_tse_private *priv)
 					   priv->sgdmadesclen,
 					   DMA_TO_DEVICE);
 
-		iowrite32(lower_32_bits(sgdma_rxphysaddr(priv, cdesc)),
-			  &csr->next_descrip);
+		csrwr32(lower_32_bits(sgdma_rxphysaddr(priv, cdesc)),
+			priv->rx_dma_csr,
+			sgdma_csroffs(next_descrip));
 
-		iowrite32((priv->rxctrlreg | SGDMA_CTRLREG_START),
-			  &csr->control);
+		csrwr32((priv->rxctrlreg | SGDMA_CTRLREG_START),
+			priv->rx_dma_csr,
+			sgdma_csroffs(control));
 
 		return 1;
 	}
@@ -395,32 +393,32 @@ static int sgdma_async_read(struct altera_tse_private *priv)
 }
 
 static int sgdma_async_write(struct altera_tse_private *priv,
-			     struct sgdma_descrip *desc)
+			     struct sgdma_descrip __iomem *desc)
 {
-	struct sgdma_csr *csr = (struct sgdma_csr *)priv->tx_dma_csr;
-
 	if (sgdma_txbusy(priv))
 		return 0;
 
 	/* clear control and status */
-	iowrite32(0, &csr->control);
-	iowrite32(0x1f, &csr->status);
+	csrwr32(0, priv->tx_dma_csr, sgdma_csroffs(control));
+	csrwr32(0x1f, priv->tx_dma_csr, sgdma_csroffs(status));
 
 	dma_sync_single_for_device(priv->device, priv->txdescphys,
 				   priv->sgdmadesclen, DMA_TO_DEVICE);
 
-	iowrite32(lower_32_bits(sgdma_txphysaddr(priv, desc)),
-		  &csr->next_descrip);
+	csrwr32(lower_32_bits(sgdma_txphysaddr(priv, desc)),
+		priv->tx_dma_csr,
+		sgdma_csroffs(next_descrip));
 
-	iowrite32((priv->txctrlreg | SGDMA_CTRLREG_START),
-		  &csr->control);
+	csrwr32((priv->txctrlreg | SGDMA_CTRLREG_START),
+		priv->tx_dma_csr,
+		sgdma_csroffs(control));
 
 	return 1;
 }
 
 static dma_addr_t
 sgdma_txphysaddr(struct altera_tse_private *priv,
-		 struct sgdma_descrip *desc)
+		 struct sgdma_descrip __iomem *desc)
 {
 	dma_addr_t paddr = priv->txdescmem_busaddr;
 	uintptr_t offs = (uintptr_t)desc - (uintptr_t)priv->tx_dma_desc;
@@ -429,7 +427,7 @@ sgdma_txphysaddr(struct altera_tse_private *priv,
 
 static dma_addr_t
 sgdma_rxphysaddr(struct altera_tse_private *priv,
-		 struct sgdma_descrip *desc)
+		 struct sgdma_descrip __iomem *desc)
 {
 	dma_addr_t paddr = priv->rxdescmem_busaddr;
 	uintptr_t offs = (uintptr_t)desc - (uintptr_t)priv->rx_dma_desc;
@@ -518,8 +516,8 @@ queue_rx_peekhead(struct altera_tse_private *priv)
  */
 static int sgdma_rxbusy(struct altera_tse_private *priv)
 {
-	struct sgdma_csr *csr = (struct sgdma_csr *)priv->rx_dma_csr;
-	return ioread32(&csr->status) & SGDMA_STSREG_BUSY;
+	return csrrd32(priv->rx_dma_csr, sgdma_csroffs(status))
+		       & SGDMA_STSREG_BUSY;
 }
 
 /* waits for the tx sgdma to finish it's current operation, returns 0
@@ -528,13 +526,14 @@ static int sgdma_rxbusy(struct altera_tse_private *priv)
 static int sgdma_txbusy(struct altera_tse_private *priv)
 {
 	int delay = 0;
-	struct sgdma_csr *csr = (struct sgdma_csr *)priv->tx_dma_csr;
 
 	/* if DMA is busy, wait for current transactino to finish */
-	while ((ioread32(&csr->status) & SGDMA_STSREG_BUSY) && (delay++ < 100))
+	while ((csrrd32(priv->tx_dma_csr, sgdma_csroffs(status))
+		& SGDMA_STSREG_BUSY) && (delay++ < 100))
 		udelay(1);
 
-	if (ioread32(&csr->status) & SGDMA_STSREG_BUSY) {
+	if (csrrd32(priv->tx_dma_csr, sgdma_csroffs(status))
+	    & SGDMA_STSREG_BUSY) {
 		netdev_err(priv->dev, "timeout waiting for tx dma\n");
 		return 1;
 	}
diff --git a/drivers/net/ethernet/altera/altera_sgdmahw.h b/drivers/net/ethernet/altera/altera_sgdmahw.h
index ba3334f..85bc33b 100644
--- a/drivers/net/ethernet/altera/altera_sgdmahw.h
+++ b/drivers/net/ethernet/altera/altera_sgdmahw.h
@@ -19,16 +19,16 @@
 
 /* SGDMA descriptor structure */
 struct sgdma_descrip {
-	unsigned int	raddr; /* address of data to be read */
-	unsigned int	pad1;
-	unsigned int	waddr;
-	unsigned int    pad2;
-	unsigned int	next;
-	unsigned int	pad3;
-	unsigned short  bytes;
-	unsigned char   rburst;
-	unsigned char	wburst;
-	unsigned short	bytes_xferred;	/* 16 bits, bytes xferred */
+	u32	raddr; /* address of data to be read */
+	u32	pad1;
+	u32	waddr;
+	u32	pad2;
+	u32	next;
+	u32	pad3;
+	u16	bytes;
+	u8	rburst;
+	u8	wburst;
+	u16	bytes_xferred;	/* 16 bits, bytes xferred */
 
 	/* bit 0: error
 	 * bit 1: length error
@@ -39,7 +39,7 @@ struct sgdma_descrip {
 	 * bit 6: reserved
 	 * bit 7: status eop for recv case
 	 */
-	unsigned char	status;
+	u8	status;
 
 	/* bit 0: eop
 	 * bit 1: read_fixed
@@ -47,7 +47,7 @@ struct sgdma_descrip {
 	 * bits 3,4,5,6: Channel (always 0)
 	 * bit 7: hardware owned
 	 */
-	unsigned char	control;
+	u8	control;
 } __packed;
 
 
@@ -101,6 +101,8 @@ struct sgdma_csr {
 	u32	pad3[3];
 };
 
+#define sgdma_csroffs(a) (offsetof(struct sgdma_csr, a))
+#define sgdma_descroffs(a) (offsetof(struct sgdma_descrip, a))
 
 #define SGDMA_STSREG_ERR	BIT(0) /* Error */
 #define SGDMA_STSREG_EOP	BIT(1) /* EOP */
diff --git a/drivers/net/ethernet/altera/altera_tse.h b/drivers/net/ethernet/altera/altera_tse.h
index 465c4aa..2adb24d 100644
--- a/drivers/net/ethernet/altera/altera_tse.h
+++ b/drivers/net/ethernet/altera/altera_tse.h
@@ -357,6 +357,8 @@ struct altera_tse_mac {
 	u32 reserved5[42];
 };
 
+#define tse_csroffs(a) (offsetof(struct altera_tse_mac, a))
+
 /* Transmit and Receive Command Registers Bit Definitions
  */
 #define ALTERA_TSE_TX_CMD_STAT_OMIT_CRC		BIT(17)
@@ -487,4 +489,49 @@ struct altera_tse_private {
  */
 void altera_tse_set_ethtool_ops(struct net_device *);
 
+static inline
+u32 csrrd32(void __iomem *mac, size_t offs)
+{
+	void __iomem *paddr = (void __iomem *)((uintptr_t)mac + offs);
+	return readl(paddr);
+}
+
+static inline
+u16 csrrd16(void __iomem *mac, size_t offs)
+{
+	void __iomem *paddr = (void __iomem *)((uintptr_t)mac + offs);
+	return readw(paddr);
+}
+
+static inline
+u8 csrrd8(void __iomem *mac, size_t offs)
+{
+	void __iomem *paddr = (void __iomem *)((uintptr_t)mac + offs);
+	return readb(paddr);
+}
+
+static inline
+void csrwr32(u32 val, void __iomem *mac, size_t offs)
+{
+	void __iomem *paddr = (void __iomem *)((uintptr_t)mac + offs);
+
+	writel(val, paddr);
+}
+
+static inline
+void csrwr16(u16 val, void __iomem *mac, size_t offs)
+{
+	void __iomem *paddr = (void __iomem *)((uintptr_t)mac + offs);
+
+	writew(val, paddr);
+}
+
+static inline
+void csrwr8(u8 val, void __iomem *mac, size_t offs)
+{
+	void __iomem *paddr = (void __iomem *)((uintptr_t)mac + offs);
+
+	writeb(val, paddr);
+}
+
 #endif /* __ALTERA_TSE_H__ */
diff --git a/drivers/net/ethernet/altera/altera_tse_ethtool.c b/drivers/net/ethernet/altera/altera_tse_ethtool.c
index 76133ca..54c25ef 100644
--- a/drivers/net/ethernet/altera/altera_tse_ethtool.c
+++ b/drivers/net/ethernet/altera/altera_tse_ethtool.c
@@ -96,54 +96,89 @@ static void tse_fill_stats(struct net_device *dev, struct ethtool_stats *dummy,
 			   u64 *buf)
 {
 	struct altera_tse_private *priv = netdev_priv(dev);
-	struct altera_tse_mac *mac = priv->mac_dev;
 	u64 ext;
 
-	buf[0] = ioread32(&mac->frames_transmitted_ok);
-	buf[1] = ioread32(&mac->frames_received_ok);
-	buf[2] = ioread32(&mac->frames_check_sequence_errors);
-	buf[3] = ioread32(&mac->alignment_errors);
+	buf[0] = csrrd32(priv->mac_dev,
+			 tse_csroffs(frames_transmitted_ok));
+	buf[1] = csrrd32(priv->mac_dev,
+			 tse_csroffs(frames_received_ok));
+	buf[2] = csrrd32(priv->mac_dev,
+			 tse_csroffs(frames_check_sequence_errors));
+	buf[3] = csrrd32(priv->mac_dev,
+			 tse_csroffs(alignment_errors));
 
 	/* Extended aOctetsTransmittedOK counter */
-	ext = (u64) ioread32(&mac->msb_octets_transmitted_ok) << 32;
-	ext |= ioread32(&mac->octets_transmitted_ok);
+	ext = (u64) csrrd32(priv->mac_dev,
+			    tse_csroffs(msb_octets_transmitted_ok)) << 32;
+
+	ext |= csrrd32(priv->mac_dev,
+		       tse_csroffs(octets_transmitted_ok));
 	buf[4] = ext;
 
 	/* Extended aOctetsReceivedOK counter */
-	ext = (u64) ioread32(&mac->msb_octets_received_ok) << 32;
-	ext |= ioread32(&mac->octets_received_ok);
+	ext = (u64) csrrd32(priv->mac_dev,
+			    tse_csroffs(msb_octets_received_ok)) << 32;
+
+	ext |= csrrd32(priv->mac_dev,
+		       tse_csroffs(octets_received_ok));
 	buf[5] = ext;
 
-	buf[6] = ioread32(&mac->tx_pause_mac_ctrl_frames);
-	buf[7] = ioread32(&mac->rx_pause_mac_ctrl_frames);
-	buf[8] = ioread32(&mac->if_in_errors);
-	buf[9] = ioread32(&mac->if_out_errors);
-	buf[10] = ioread32(&mac->if_in_ucast_pkts);
-	buf[11] = ioread32(&mac->if_in_multicast_pkts);
-	buf[12] = ioread32(&mac->if_in_broadcast_pkts);
-	buf[13] = ioread32(&mac->if_out_discards);
-	buf[14] = ioread32(&mac->if_out_ucast_pkts);
-	buf[15] = ioread32(&mac->if_out_multicast_pkts);
-	buf[16] = ioread32(&mac->if_out_broadcast_pkts);
-	buf[17] = ioread32(&mac->ether_stats_drop_events);
+	buf[6] = csrrd32(priv->mac_dev,
+			 tse_csroffs(tx_pause_mac_ctrl_frames));
+	buf[7] = csrrd32(priv->mac_dev,
+			 tse_csroffs(rx_pause_mac_ctrl_frames));
+	buf[8] = csrrd32(priv->mac_dev,
+			 tse_csroffs(if_in_errors));
+	buf[9] = csrrd32(priv->mac_dev,
+			 tse_csroffs(if_out_errors));
+	buf[10] = csrrd32(priv->mac_dev,
+			  tse_csroffs(if_in_ucast_pkts));
+	buf[11] = csrrd32(priv->mac_dev,
+			  tse_csroffs(if_in_multicast_pkts));
+	buf[12] = csrrd32(priv->mac_dev,
+			  tse_csroffs(if_in_broadcast_pkts));
+	buf[13] = csrrd32(priv->mac_dev,
+			  tse_csroffs(if_out_discards));
+	buf[14] = csrrd32(priv->mac_dev,
+			  tse_csroffs(if_out_ucast_pkts));
+	buf[15] = csrrd32(priv->mac_dev,
+			  tse_csroffs(if_out_multicast_pkts));
+	buf[16] = csrrd32(priv->mac_dev,
+			  tse_csroffs(if_out_broadcast_pkts));
+	buf[17] = csrrd32(priv->mac_dev,
+			  tse_csroffs(ether_stats_drop_events));
 
 	/* Extended etherStatsOctets counter */
-	ext = (u64) ioread32(&mac->msb_ether_stats_octets) << 32;
-	ext |= ioread32(&mac->ether_stats_octets);
+	ext = (u64) csrrd32(priv->mac_dev,
+			    tse_csroffs(msb_ether_stats_octets)) << 32;
+	ext |= csrrd32(priv->mac_dev,
+		       tse_csroffs(ether_stats_octets));
 	buf[18] = ext;
 
-	buf[19] = ioread32(&mac->ether_stats_pkts);
-	buf[20] = ioread32(&mac->ether_stats_undersize_pkts);
-	buf[21] = ioread32(&mac->ether_stats_oversize_pkts);
-	buf[22] = ioread32(&mac->ether_stats_pkts_64_octets);
-	buf[23] = ioread32(&mac->ether_stats_pkts_65to127_octets);
-	buf[24] = ioread32(&mac->ether_stats_pkts_128to255_octets);
-	buf[25] = ioread32(&mac->ether_stats_pkts_256to511_octets);
-	buf[26] = ioread32(&mac->ether_stats_pkts_512to1023_octets);
-	buf[27] = ioread32(&mac->ether_stats_pkts_1024to1518_octets);
-	buf[28] = ioread32(&mac->ether_stats_pkts_1519tox_octets);
-	buf[29] = ioread32(&mac->ether_stats_jabbers);
-	buf[30] = ioread32(&mac->ether_stats_fragments);
+	buf[19] = csrrd32(priv->mac_dev,
+			  tse_csroffs(ether_stats_pkts));
+	buf[20] = csrrd32(priv->mac_dev,
+			  tse_csroffs(ether_stats_undersize_pkts));
+	buf[21] = csrrd32(priv->mac_dev,
+			  tse_csroffs(ether_stats_oversize_pkts));
+	buf[22] = csrrd32(priv->mac_dev,
+			  tse_csroffs(ether_stats_pkts_64_octets));
+	buf[23] = csrrd32(priv->mac_dev,
+			  tse_csroffs(ether_stats_pkts_65to127_octets));
+	buf[24] = csrrd32(priv->mac_dev,
+			  tse_csroffs(ether_stats_pkts_128to255_octets));
+	buf[25] = csrrd32(priv->mac_dev,
+			  tse_csroffs(ether_stats_pkts_256to511_octets));
+	buf[26] = csrrd32(priv->mac_dev,
+			  tse_csroffs(ether_stats_pkts_512to1023_octets));
+	buf[27] = csrrd32(priv->mac_dev,
+			  tse_csroffs(ether_stats_pkts_1024to1518_octets));
+	buf[28] = csrrd32(priv->mac_dev,
+			  tse_csroffs(ether_stats_pkts_1519tox_octets));
+	buf[29] = csrrd32(priv->mac_dev,
+			  tse_csroffs(ether_stats_jabbers));
+	buf[30] = csrrd32(priv->mac_dev,
+			  tse_csroffs(ether_stats_fragments));
 }
 
 static int tse_sset_count(struct net_device *dev, int sset)
@@ -178,7 +213,6 @@ static void tse_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 {
 	int i;
 	struct altera_tse_private *priv = netdev_priv(dev);
-	u32 *tse_mac_regs = (u32 *)priv->mac_dev;
 	u32 *buf = regbuf;
 
 	/* Set version to a known value, so ethtool knows
@@ -196,7 +230,7 @@ static void tse_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 	regs->version = 1;
 
 	for (i = 0; i < TSE_NUM_REGS; i++)
-		buf[i] = ioread32(&tse_mac_regs[i]);
+		buf[i] = csrrd32(priv->mac_dev, i * 4);
 }
 
 static int tse_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index e44a4ae..d1d35f5 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -100,29 +100,30 @@ static inline u32 tse_tx_avail(struct altera_tse_private *priv)
  */
 static int altera_tse_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 {
-	struct altera_tse_mac *mac = (struct altera_tse_mac *)bus->priv;
-	unsigned int *mdio_regs = (unsigned int *)&mac->mdio_phy0;
-	u32 data;
+	struct net_device *ndev = bus->priv;
+	struct altera_tse_private *priv = netdev_priv(ndev);
 
 	/* set MDIO address */
-	iowrite32((mii_id & 0x1f), &mac->mdio_phy0_addr);
+	csrwr32((mii_id & 0x1f), priv->mac_dev,
+		tse_csroffs(mdio_phy0_addr));
 
 	/* get the data */
-	data = ioread32(&mdio_regs[regnum]) & 0xffff;
-	return data;
+	return csrrd32(priv->mac_dev,
+		       tse_csroffs(mdio_phy0) + regnum * 4) & 0xffff;
 }
 
 static int altera_tse_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 				 u16 value)
 {
-	struct altera_tse_mac *mac = (struct altera_tse_mac *)bus->priv;
-	unsigned int *mdio_regs = (unsigned int *)&mac->mdio_phy0;
+	struct net_device *ndev = bus->priv;
+	struct altera_tse_private *priv = netdev_priv(ndev);
 
 	/* set MDIO address */
-	iowrite32((mii_id & 0x1f), &mac->mdio_phy0_addr);
+	csrwr32((mii_id & 0x1f), priv->mac_dev,
+		tse_csroffs(mdio_phy0_addr));
 
 	/* write the data */
-	iowrite32((u32) value, &mdio_regs[regnum]);
+	csrwr32(value, priv->mac_dev, tse_csroffs(mdio_phy0) + regnum * 4);
 	return 0;
 }
 
@@ -168,7 +169,7 @@ static int altera_tse_mdio_create(struct net_device *dev, unsigned int id)
 	for (i = 0; i < PHY_MAX_ADDR; i++)
 		mdio->irq[i] = PHY_POLL;
 
-	mdio->priv = priv->mac_dev;
+	mdio->priv = dev;
 	mdio->parent = priv->device;
 
 	ret = of_mdiobus_register(mdio, mdio_node);
@@ -563,7 +564,6 @@ static int tse_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int nopaged_len = skb_headlen(skb);
 	enum netdev_tx ret = NETDEV_TX_OK;
 	dma_addr_t dma_addr;
-	int txcomplete = 0;
 
 	spin_lock_bh(&priv->tx_lock);
 
@@ -599,7 +599,7 @@ static int tse_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	dma_sync_single_for_device(priv->device, buffer->dma_addr,
 				   buffer->len, DMA_TO_DEVICE);
 
-	txcomplete = priv->dmaops->tx_buffer(priv, buffer);
+	priv->dmaops->tx_buffer(priv, buffer);
 
 	skb_tx_timestamp(skb);
 
@@ -698,7 +698,6 @@ static struct phy_device *connect_local_phy(struct net_device *dev)
 	struct altera_tse_private *priv = netdev_priv(dev);
 	struct phy_device *phydev = NULL;
 	char phy_id_fmt[MII_BUS_ID_SIZE + 3];
-	int ret;
 
 	if (priv->phy_addr != POLL_PHY) {
 		snprintf(phy_id_fmt, MII_BUS_ID_SIZE + 3, PHY_ID_FMT,
@@ -712,6 +711,7 @@ static struct phy_device *connect_local_phy(struct net_device *dev)
 			netdev_err(dev, "Could not attach to PHY\n");
 
 	} else {
+		int ret;
 		phydev = phy_find_first(priv->mdio);
 		if (phydev == NULL) {
 			netdev_err(dev, "No PHY found\n");
@@ -791,7 +791,6 @@ static int init_phy(struct net_device *dev)
 
 static void tse_update_mac_addr(struct altera_tse_private *priv, u8 *addr)
 {
-	struct altera_tse_mac *mac = priv->mac_dev;
 	u32 msb;
 	u32 lsb;
 
@@ -799,8 +798,8 @@ static void tse_update_mac_addr(struct altera_tse_private *priv, u8 *addr)
 	lsb = ((addr[5] << 8) | addr[4]) & 0xffff;
 
 	/* Set primary MAC address */
-	iowrite32(msb, &mac->mac_addr_0);
-	iowrite32(lsb, &mac->mac_addr_1);
+	csrwr32(msb, priv->mac_dev, tse_csroffs(mac_addr_0));
+	csrwr32(lsb, priv->mac_dev, tse_csroffs(mac_addr_1));
 }
 
 /* MAC software reset.
@@ -811,26 +810,26 @@ static void tse_update_mac_addr(struct altera_tse_private *priv, u8 *addr)
  */
 static int reset_mac(struct altera_tse_private *priv)
 {
-	void __iomem *cmd_cfg_reg = &priv->mac_dev->command_config;
 	int counter;
 	u32 dat;
 
-	dat = ioread32(cmd_cfg_reg);
+	dat = csrrd32(priv->mac_dev, tse_csroffs(command_config));
 	dat &= ~(MAC_CMDCFG_TX_ENA | MAC_CMDCFG_RX_ENA);
 	dat |= MAC_CMDCFG_SW_RESET | MAC_CMDCFG_CNT_RESET;
-	iowrite32(dat, cmd_cfg_reg);
+	csrwr32(dat, priv->mac_dev, tse_csroffs(command_config));
 
 	counter = 0;
 	while (counter++ < ALTERA_TSE_SW_RESET_WATCHDOG_CNTR) {
-		if (tse_bit_is_clear(cmd_cfg_reg, MAC_CMDCFG_SW_RESET))
+		if (tse_bit_is_clear(priv->mac_dev, tse_csroffs(command_config),
+				     MAC_CMDCFG_SW_RESET))
 			break;
 		udelay(1);
 	}
 
 	if (counter >= ALTERA_TSE_SW_RESET_WATCHDOG_CNTR) {
-		dat = ioread32(cmd_cfg_reg);
+		dat = csrrd32(priv->mac_dev, tse_csroffs(command_config));
 		dat &= ~MAC_CMDCFG_SW_RESET;
-		iowrite32(dat, cmd_cfg_reg);
+		csrwr32(dat, priv->mac_dev, tse_csroffs(command_config));
 		return -1;
 	}
 	return 0;
@@ -840,41 +839,57 @@ static int reset_mac(struct altera_tse_private *priv)
 */
 static int init_mac(struct altera_tse_private *priv)
 {
-	struct altera_tse_mac *mac = priv->mac_dev;
 	unsigned int cmd = 0;
 	u32 frm_length;
 
 	/* Setup Rx FIFO */
-	iowrite32(priv->rx_fifo_depth - ALTERA_TSE_RX_SECTION_EMPTY,
-		  &mac->rx_section_empty);
-	iowrite32(ALTERA_TSE_RX_SECTION_FULL, &mac->rx_section_full);
-	iowrite32(ALTERA_TSE_RX_ALMOST_EMPTY, &mac->rx_almost_empty);
-	iowrite32(ALTERA_TSE_RX_ALMOST_FULL, &mac->rx_almost_full);
+	csrwr32(priv->rx_fifo_depth - ALTERA_TSE_RX_SECTION_EMPTY,
+		priv->mac_dev, tse_csroffs(rx_section_empty));
+
+	csrwr32(ALTERA_TSE_RX_SECTION_FULL, priv->mac_dev,
+		tse_csroffs(rx_section_full));
+
+	csrwr32(ALTERA_TSE_RX_ALMOST_EMPTY, priv->mac_dev,
+		tse_csroffs(rx_almost_empty));
+
+	csrwr32(ALTERA_TSE_RX_ALMOST_FULL, priv->mac_dev,
+		tse_csroffs(rx_almost_full));
 
 	/* Setup Tx FIFO */
-	iowrite32(priv->tx_fifo_depth - ALTERA_TSE_TX_SECTION_EMPTY,
-		  &mac->tx_section_empty);
-	iowrite32(ALTERA_TSE_TX_SECTION_FULL, &mac->tx_section_full);
-	iowrite32(ALTERA_TSE_TX_ALMOST_EMPTY, &mac->tx_almost_empty);
-	iowrite32(ALTERA_TSE_TX_ALMOST_FULL, &mac->tx_almost_full);
+	csrwr32(priv->tx_fifo_depth - ALTERA_TSE_TX_SECTION_EMPTY,
+		priv->mac_dev, tse_csroffs(tx_section_empty));
+
+	csrwr32(ALTERA_TSE_TX_SECTION_FULL, priv->mac_dev,
+		tse_csroffs(tx_section_full));
+
+	csrwr32(ALTERA_TSE_TX_ALMOST_EMPTY, priv->mac_dev,
+		tse_csroffs(tx_almost_empty));
+
+	csrwr32(ALTERA_TSE_TX_ALMOST_FULL, priv->mac_dev,
+		tse_csroffs(tx_almost_full));
 
 	/* MAC Address Configuration */
 	tse_update_mac_addr(priv, priv->dev->dev_addr);
 
 	/* MAC Function Configuration */
 	frm_length = ETH_HLEN + priv->dev->mtu + ETH_FCS_LEN;
-	iowrite32(frm_length, &mac->frm_length);
-	iowrite32(ALTERA_TSE_TX_IPG_LENGTH, &mac->tx_ipg_length);
+	csrwr32(frm_length, priv->mac_dev, tse_csroffs(frm_length));
+
+	csrwr32(ALTERA_TSE_TX_IPG_LENGTH, priv->mac_dev,
+		tse_csroffs(tx_ipg_length));
 
 	/* Disable RX/TX shift 16 for alignment of all received frames on 16-bit
 	 * start address
 	 */
-	tse_set_bit(&mac->rx_cmd_stat, ALTERA_TSE_RX_CMD_STAT_RX_SHIFT16);
-	tse_clear_bit(&mac->tx_cmd_stat, ALTERA_TSE_TX_CMD_STAT_TX_SHIFT16 |
-					 ALTERA_TSE_TX_CMD_STAT_OMIT_CRC);
+	tse_set_bit(priv->mac_dev, tse_csroffs(rx_cmd_stat),
+		    ALTERA_TSE_RX_CMD_STAT_RX_SHIFT16);
+
+	tse_clear_bit(priv->mac_dev, tse_csroffs(tx_cmd_stat),
+		      ALTERA_TSE_TX_CMD_STAT_TX_SHIFT16 |
+		      ALTERA_TSE_TX_CMD_STAT_OMIT_CRC);
 
 	/* Set the MAC options */
-	cmd = ioread32(&mac->command_config);
+	cmd = csrrd32(priv->mac_dev, tse_csroffs(command_config));
 	cmd &= ~MAC_CMDCFG_PAD_EN;	/* No padding Removal on Receive */
 	cmd &= ~MAC_CMDCFG_CRC_FWD;	/* CRC Removal */
 	cmd |= MAC_CMDCFG_RX_ERR_DISC;	/* Automatically discard frames
@@ -889,9 +904,10 @@ static int init_mac(struct altera_tse_private *priv)
 	cmd &= ~MAC_CMDCFG_ETH_SPEED;
 	cmd &= ~MAC_CMDCFG_ENA_10;
 
-	iowrite32(cmd, &mac->command_config);
+	csrwr32(cmd, priv->mac_dev, tse_csroffs(command_config));
 
-	iowrite32(ALTERA_TSE_PAUSE_QUANTA, &mac->pause_quanta);
+	csrwr32(ALTERA_TSE_PAUSE_QUANTA, priv->mac_dev,
+		tse_csroffs(pause_quanta));
 
 	if (netif_msg_hw(priv))
 		dev_dbg(priv->device,
@@ -904,15 +920,14 @@ static int init_mac(struct altera_tse_private *priv)
  */
 static void tse_set_mac(struct altera_tse_private *priv, bool enable)
 {
-	struct altera_tse_mac *mac = priv->mac_dev;
-	u32 value = ioread32(&mac->command_config);
+	u32 value = csrrd32(priv->mac_dev, tse_csroffs(command_config));
 
 	if (enable)
 		value |= MAC_CMDCFG_TX_ENA | MAC_CMDCFG_RX_ENA;
 	else
 		value &= ~(MAC_CMDCFG_TX_ENA | MAC_CMDCFG_RX_ENA);
 
-	iowrite32(value, &mac->command_config);
+	csrwr32(value, priv->mac_dev, tse_csroffs(command_config));
 }
 
 /* Change the MTU
@@ -942,13 +957,12 @@ static int tse_change_mtu(struct net_device *dev, int new_mtu)
 static void altera_tse_set_mcfilter(struct net_device *dev)
 {
 	struct altera_tse_private *priv = netdev_priv(dev);
-	struct altera_tse_mac *mac = priv->mac_dev;
 	int i;
 	struct netdev_hw_addr *ha;
 
 	/* clear the hash filter */
 	for (i = 0; i < 64; i++)
-		iowrite32(0, &(mac->hash_table[i]));
+		csrwr32(0, priv->mac_dev, tse_csroffs(hash_table) + i * 4);
 
 	netdev_for_each_mc_addr(ha, dev) {
 		unsigned int hash = 0;
@@ -964,7 +978,7 @@ static void altera_tse_set_mcfilter(struct net_device *dev)
 
 			hash = (hash << 1) | xor_bit;
 		}
-		iowrite32(1, &(mac->hash_table[hash]));
+		csrwr32(1, priv->mac_dev, tse_csroffs(hash_table) + hash * 4);
 	}
 }
 
@@ -972,12 +986,11 @@ static void altera_tse_set_mcfilter(struct net_device *dev)
 static void altera_tse_set_mcfilterall(struct net_device *dev)
 {
 	struct altera_tse_private *priv = netdev_priv(dev);
-	struct altera_tse_mac *mac = priv->mac_dev;
 	int i;
 
 	/* set the hash filter */
 	for (i = 0; i < 64; i++)
-		iowrite32(1, &(mac->hash_table[i]));
+		csrwr32(1, priv->mac_dev, tse_csroffs(hash_table) + i * 4);
 }
 
 /* Set or clear the multicast filter for this adaptor
@@ -985,12 +998,12 @@ static void altera_tse_set_mcfilterall(struct net_device *dev)
 static void tse_set_rx_mode_hashfilter(struct net_device *dev)
 {
 	struct altera_tse_private *priv = netdev_priv(dev);
-	struct altera_tse_mac *mac = priv->mac_dev;
 
 	spin_lock(&priv->mac_cfg_lock);
 
 	if (dev->flags & IFF_PROMISC)
-		tse_set_bit(&mac->command_config, MAC_CMDCFG_PROMIS_EN);
+		tse_set_bit(priv->mac_dev, tse_csroffs(command_config),
+			    MAC_CMDCFG_PROMIS_EN);
 
 	if (dev->flags & IFF_ALLMULTI)
 		altera_tse_set_mcfilterall(dev);
@@ -1005,15 +1018,16 @@ static void tse_set_rx_mode_hashfilter(struct net_device *dev)
 static void tse_set_rx_mode(struct net_device *dev)
 {
 	struct altera_tse_private *priv = netdev_priv(dev);
-	struct altera_tse_mac *mac = priv->mac_dev;
 
 	spin_lock(&priv->mac_cfg_lock);
 
 	if ((dev->flags & IFF_PROMISC) || (dev->flags & IFF_ALLMULTI) ||
 	    !netdev_mc_empty(dev) || !netdev_uc_empty(dev))
-		tse_set_bit(&mac->command_config, MAC_CMDCFG_PROMIS_EN);
+		tse_set_bit(priv->mac_dev, tse_csroffs(command_config),
+			    MAC_CMDCFG_PROMIS_EN);
 	else
-		tse_clear_bit(&mac->command_config, MAC_CMDCFG_PROMIS_EN);
+		tse_clear_bit(priv->mac_dev, tse_csroffs(command_config),
+			      MAC_CMDCFG_PROMIS_EN);
 
 	spin_unlock(&priv->mac_cfg_lock);
 }
@@ -1362,6 +1376,11 @@ static int altera_tse_probe(struct platform_device *pdev)
 		of_property_read_bool(pdev->dev.of_node,
 				      "altr,has-hash-multicast-filter");
 
+	/* Set hash filter to not set for now until the
+	 * multicast filter receive issue is debugged
+	 */
+	priv->hash_filter = 0;
+
 	/* get supplemental address settings for this instance */
 	priv->added_unicast =
 		of_property_read_bool(pdev->dev.of_node,
@@ -1493,7 +1512,7 @@ static int altera_tse_remove(struct platform_device *pdev)
 	return 0;
 }
 
-struct altera_dmaops altera_dtype_sgdma = {
+static struct altera_dmaops altera_dtype_sgdma = {
 	.altera_dtype = ALTERA_DTYPE_SGDMA,
 	.dmamask = 32,
 	.reset_dma = sgdma_reset,
@@ -1512,7 +1531,7 @@ struct altera_dmaops altera_dtype_sgdma = {
 	.start_rxdma = sgdma_start_rxdma,
 };
 
-struct altera_dmaops altera_dtype_msgdma = {
+static struct altera_dmaops altera_dtype_msgdma = {
 	.altera_dtype = ALTERA_DTYPE_MSGDMA,
 	.dmamask = 64,
 	.reset_dma = msgdma_reset,
diff --git a/drivers/net/ethernet/altera/altera_utils.c b/drivers/net/ethernet/altera/altera_utils.c
index 70fa13f..d7eeb17 100644
--- a/drivers/net/ethernet/altera/altera_utils.c
+++ b/drivers/net/ethernet/altera/altera_utils.c
@@ -17,28 +17,28 @@
 #include "altera_tse.h"
 #include "altera_utils.h"
 
-void tse_set_bit(void __iomem *ioaddr, u32 bit_mask)
+void tse_set_bit(void __iomem *ioaddr, size_t offs, u32 bit_mask)
 {
-	u32 value = ioread32(ioaddr);
+	u32 value = csrrd32(ioaddr, offs);
 	value |= bit_mask;
-	iowrite32(value, ioaddr);
+	csrwr32(value, ioaddr, offs);
 }
 
-void tse_clear_bit(void __iomem *ioaddr, u32 bit_mask)
+void tse_clear_bit(void __iomem *ioaddr, size_t offs, u32 bit_mask)
 {
-	u32 value = ioread32(ioaddr);
+	u32 value = csrrd32(ioaddr, offs);
 	value &= ~bit_mask;
-	iowrite32(value, ioaddr);
+	csrwr32(value, ioaddr, offs);
 }
 
-int tse_bit_is_set(void __iomem *ioaddr, u32 bit_mask)
+int tse_bit_is_set(void __iomem *ioaddr, size_t offs, u32 bit_mask)
 {
-	u32 value = ioread32(ioaddr);
+	u32 value = csrrd32(ioaddr, offs);
 	return (value & bit_mask) ? 1 : 0;
 }
 
-int tse_bit_is_clear(void __iomem *ioaddr, u32 bit_mask)
+int tse_bit_is_clear(void __iomem *ioaddr, size_t offs, u32 bit_mask)
 {
-	u32 value = ioread32(ioaddr);
+	u32 value = csrrd32(ioaddr, offs);
 	return (value & bit_mask) ? 0 : 1;
 }
diff --git a/drivers/net/ethernet/altera/altera_utils.h b/drivers/net/ethernet/altera/altera_utils.h
index ce1db36..baf100c 100644
--- a/drivers/net/ethernet/altera/altera_utils.h
+++ b/drivers/net/ethernet/altera/altera_utils.h
@@ -19,9 +19,9 @@
 #ifndef __ALTERA_UTILS_H__
 #define __ALTERA_UTILS_H__
 
-void tse_set_bit(void __iomem *ioaddr, u32 bit_mask);
-void tse_clear_bit(void __iomem *ioaddr, u32 bit_mask);
-int tse_bit_is_set(void __iomem *ioaddr, u32 bit_mask);
-int tse_bit_is_clear(void __iomem *ioaddr, u32 bit_mask);
+void tse_set_bit(void __iomem *ioaddr, size_t offs, u32 bit_mask);
+void tse_clear_bit(void __iomem *ioaddr, size_t offs, u32 bit_mask);
+int tse_bit_is_set(void __iomem *ioaddr, size_t offs, u32 bit_mask);
+int tse_bit_is_clear(void __iomem *ioaddr, size_t offs, u32 bit_mask);
 
 #endif /* __ALTERA_UTILS_H__*/
-- 
1.7.9.5
