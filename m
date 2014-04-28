From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] Altera TSE: Fix DMA secriptor length initialization
Date: Mon, 28 Apr 2014 11:33:47 +0200
Message-ID: <1398677627-6525-1-git-send-email-tklauser@distanz.ch>
Cc: nios2-dev@lists.rocketboards.org
To: Vince Bridgers <vbridgers2013@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:46156 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754307AbaD1Jdv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2014 05:33:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sgdma_descrip is a function name as well as the name of a struct. In
sgdma_initialize(), we should initialize the descriptor length field
with the actual length of a descriptor not with the size of the
function. In order to prevent such things from happening in the future,
rename the function to sgdma_setup_descrip().

Found by sparse which yields the following warning:

drivers/net/ethernet/altera/altera_sgdma.c:74:30: warning: expression using sizeof on a function

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/altera/altera_sgdma.c |   75 ++++++++++++++--------------
 1 file changed, 37 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/altera/altera_sgdma.c b/drivers/net/ethernet/altera/altera_sgdma.c
index 5358aa6..7e23987 100644
--- a/drivers/net/ethernet/altera/altera_sgdma.c
+++ b/drivers/net/ethernet/altera/altera_sgdma.c
@@ -20,15 +20,15 @@
 #include "altera_sgdmahw.h"
 #include "altera_sgdma.h"
 
-static void sgdma_descrip(struct sgdma_descrip *desc,
-			  struct sgdma_descrip *ndesc,
-			  dma_addr_t ndesc_phys,
-			  dma_addr_t raddr,
-			  dma_addr_t waddr,
-			  u16 length,
-			  int generate_eop,
-			  int rfixed,
-			  int wfixed);
+static void sgdma_setup_descrip(struct sgdma_descrip *desc,
+				struct sgdma_descrip *ndesc,
+				dma_addr_t ndesc_phys,
+				dma_addr_t raddr,
+				dma_addr_t waddr,
+				u16 length,
+				int generate_eop,
+				int rfixed,
+				int wfixed);
 
 static int sgdma_async_write(struct altera_tse_private *priv,
 			      struct sgdma_descrip *desc);
@@ -71,7 +71,7 @@ int sgdma_initialize(struct altera_tse_private *priv)
 		      SGDMA_CTRLREG_INTEN |
 		      SGDMA_CTRLREG_ILASTD;
 
-	priv->sgdmadesclen = sizeof(sgdma_descrip);
+	priv->sgdmadesclen = sizeof(struct sgdma_descrip);
 
 	INIT_LIST_HEAD(&priv->txlisthd);
 	INIT_LIST_HEAD(&priv->rxlisthd);
@@ -186,7 +186,6 @@ int sgdma_tx_buffer(struct altera_tse_private *priv, struct tse_buffer *buffer)
 {
 	int pktstx = 0;
 	struct sgdma_descrip *descbase = priv->tx_dma_desc;
-
 	struct sgdma_descrip *cdesc = &descbase[0];
 	struct sgdma_descrip *ndesc = &descbase[1];
 
@@ -194,15 +193,15 @@ int sgdma_tx_buffer(struct altera_tse_private *priv, struct tse_buffer *buffer)
 	if (sgdma_txbusy(priv))
 		return 0;
 
-	sgdma_descrip(cdesc,			/* current descriptor */
-		      ndesc,			/* next descriptor */
-		      sgdma_txphysaddr(priv, ndesc),
-		      buffer->dma_addr,		/* address of packet to xmit */
-		      0,			/* write addr 0 for tx dma */
-		      buffer->len,		/* length of packet */
-		      SGDMA_CONTROL_EOP,	/* Generate EOP */
-		      0,			/* read fixed */
-		      SGDMA_CONTROL_WR_FIXED);	/* Generate SOP */
+	sgdma_setup_descrip(cdesc,			/* current descriptor */
+			    ndesc,			/* next descriptor */
+			    sgdma_txphysaddr(priv, ndesc),
+			    buffer->dma_addr,		/* address of packet to xmit */
+			    0,				/* write addr 0 for tx dma */
+			    buffer->len,		/* length of packet */
+			    SGDMA_CONTROL_EOP,		/* Generate EOP */
+			    0,				/* read fixed */
+			    SGDMA_CONTROL_WR_FIXED);	/* Generate SOP */
 
 	pktstx = sgdma_async_write(priv, cdesc);
 
@@ -308,15 +307,15 @@ u32 sgdma_rx_status(struct altera_tse_private *priv)
 
 
 /* Private functions */
-static void sgdma_descrip(struct sgdma_descrip *desc,
-			  struct sgdma_descrip *ndesc,
-			  dma_addr_t ndesc_phys,
-			  dma_addr_t raddr,
-			  dma_addr_t waddr,
-			  u16 length,
-			  int generate_eop,
-			  int rfixed,
-			  int wfixed)
+static void sgdma_setup_descrip(struct sgdma_descrip *desc,
+				struct sgdma_descrip *ndesc,
+				dma_addr_t ndesc_phys,
+				dma_addr_t raddr,
+				dma_addr_t waddr,
+				u16 length,
+				int generate_eop,
+				int rfixed,
+				int wfixed)
 {
 	/* Clear the next descriptor as not owned by hardware */
 	u32 ctrl = ndesc->control;
@@ -364,15 +363,15 @@ static int sgdma_async_read(struct altera_tse_private *priv)
 			return 0;
 		}
 
-		sgdma_descrip(cdesc,		/* current descriptor */
-			      ndesc,		/* next descriptor */
-			      sgdma_rxphysaddr(priv, ndesc),
-			      0,		/* read addr 0 for rx dma */
-			      rxbuffer->dma_addr, /* write addr for rx dma */
-			      0,		/* read 'til EOP */
-			      0,		/* EOP: NA for rx dma */
-			      0,		/* read fixed: NA for rx dma */
-			      0);		/* SOP: NA for rx DMA */
+		sgdma_setup_descrip(cdesc,		/* current descriptor */
+				    ndesc,		/* next descriptor */
+				    sgdma_rxphysaddr(priv, ndesc),
+				    0,			/* read addr 0 for rx dma */
+				    rxbuffer->dma_addr, /* write addr for rx dma */
+				    0,			/* read 'til EOP */
+				    0,			/* EOP: NA for rx dma */
+				    0,			/* read fixed: NA for rx dma */
+				    0);			/* SOP: NA for rx DMA */
 
 		dma_sync_single_for_device(priv->device,
 					   priv->rxdescphys,
-- 
1.7.9.5
