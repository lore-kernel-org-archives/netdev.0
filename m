From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: eth: altera: Remove sgdmadesclen member from altera_tse_private
Date: Mon, 10 Aug 2015 12:26:32 +0200
Message-ID: <1439202392-6808-1-git-send-email-tklauser@distanz.ch>
Cc: nios2-dev@lists.rocketboards.org
To: Vince Bridgers <vbridger@opensource.altera.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:38509 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933316AbbHJK0i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Aug 2015 06:26:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

altera_tse_private->sgdmadesclen is always assigned assigned the same
value and never changes during runtime.  Remove the struct member and
use a new define for sizeof(struct sgdma_descrip) instead.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/altera/altera_sgdma.c   | 8 +++-----
 drivers/net/ethernet/altera/altera_sgdmahw.h | 1 +
 drivers/net/ethernet/altera/altera_tse.h     | 1 -
 3 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/altera/altera_sgdma.c b/drivers/net/ethernet/altera/altera_sgdma.c
index 580553d..88ef67a 100644
--- a/drivers/net/ethernet/altera/altera_sgdma.c
+++ b/drivers/net/ethernet/altera/altera_sgdma.c
@@ -71,8 +71,6 @@ int sgdma_initialize(struct altera_tse_private *priv)
 		      SGDMA_CTRLREG_INTEN |
 		      SGDMA_CTRLREG_ILASTD;
 
-	priv->sgdmadesclen = sizeof(struct sgdma_descrip);
-
 	INIT_LIST_HEAD(&priv->txlisthd);
 	INIT_LIST_HEAD(&priv->rxlisthd);
 
@@ -254,7 +252,7 @@ u32 sgdma_rx_status(struct altera_tse_private *priv)
 		unsigned int pktstatus = 0;
 		dma_sync_single_for_cpu(priv->device,
 					priv->rxdescphys,
-					priv->sgdmadesclen,
+					SGDMA_DESC_LEN,
 					DMA_FROM_DEVICE);
 
 		pktlength = csrrd16(desc, sgdma_descroffs(bytes_xferred));
@@ -374,7 +372,7 @@ static int sgdma_async_read(struct altera_tse_private *priv)
 
 		dma_sync_single_for_device(priv->device,
 					   priv->rxdescphys,
-					   priv->sgdmadesclen,
+					   SGDMA_DESC_LEN,
 					   DMA_TO_DEVICE);
 
 		csrwr32(lower_32_bits(sgdma_rxphysaddr(priv, cdesc)),
@@ -402,7 +400,7 @@ static int sgdma_async_write(struct altera_tse_private *priv,
 	csrwr32(0x1f, priv->tx_dma_csr, sgdma_csroffs(status));
 
 	dma_sync_single_for_device(priv->device, priv->txdescphys,
-				   priv->sgdmadesclen, DMA_TO_DEVICE);
+				   SGDMA_DESC_LEN, DMA_TO_DEVICE);
 
 	csrwr32(lower_32_bits(sgdma_txphysaddr(priv, desc)),
 		priv->tx_dma_csr,
diff --git a/drivers/net/ethernet/altera/altera_sgdmahw.h b/drivers/net/ethernet/altera/altera_sgdmahw.h
index 85bc33b..bbd52f0 100644
--- a/drivers/net/ethernet/altera/altera_sgdmahw.h
+++ b/drivers/net/ethernet/altera/altera_sgdmahw.h
@@ -50,6 +50,7 @@ struct sgdma_descrip {
 	u8	control;
 } __packed;
 
+#define SGDMA_DESC_LEN	sizeof(struct sgdma_descrip)
 
 #define SGDMA_STATUS_ERR		BIT(0)
 #define SGDMA_STATUS_LENGTH_ERR		BIT(1)
diff --git a/drivers/net/ethernet/altera/altera_tse.h b/drivers/net/ethernet/altera/altera_tse.h
index 2adb24d..103c30d 100644
--- a/drivers/net/ethernet/altera/altera_tse.h
+++ b/drivers/net/ethernet/altera/altera_tse.h
@@ -458,7 +458,6 @@ struct altera_tse_private {
 	u32 rxctrlreg;
 	dma_addr_t rxdescphys;
 	dma_addr_t txdescphys;
-	size_t sgdmadesclen;
 
 	struct list_head txlisthd;
 	struct list_head rxlisthd;
-- 
2.5.0
