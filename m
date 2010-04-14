From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 3/7] stmmac: fix Transmit FIFO flush operation
Date: Wed, 14 Apr 2010 08:21:13 +0200
Message-ID: <1271226077-25882-3-git-send-email-peppe.cavallaro@st.com>
References: <1271226077-25882-1-git-send-email-peppe.cavallaro@st.com>
 <1271226077-25882-2-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:38203 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753569Ab0DNGVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 02:21:39 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 2001AFE
	for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 06:21:33 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 3392011BB
	for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 06:21:33 +0000 (GMT)
In-Reply-To: <1271226077-25882-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the Transmit FIFO flush operation; it was
disabled while reworking the descriptor structures.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/common.h        |    1 +
 drivers/net/stmmac/dwmac1000.h     |    1 -
 drivers/net/stmmac/dwmac1000_dma.c |    9 ---------
 drivers/net/stmmac/dwmac_dma.h     |    1 +
 drivers/net/stmmac/dwmac_lib.c     |    7 +++++++
 drivers/net/stmmac/enh_desc.c      |    6 +++---
 6 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/net/stmmac/common.h b/drivers/net/stmmac/common.h
index bd3b785..27a05b4 100644
--- a/drivers/net/stmmac/common.h
+++ b/drivers/net/stmmac/common.h
@@ -244,3 +244,4 @@ extern void stmmac_set_mac_addr(unsigned long ioaddr, u8 addr[6],
 				unsigned int high, unsigned int low);
 extern void stmmac_get_mac_addr(unsigned long ioaddr, unsigned char *addr,
 				unsigned int high, unsigned int low);
+extern void dwmac_dma_flush_tx_fifo(unsigned long ioaddr);
diff --git a/drivers/net/stmmac/dwmac1000.h b/drivers/net/stmmac/dwmac1000.h
index 3b784fc..d8d0f35 100644
--- a/drivers/net/stmmac/dwmac1000.h
+++ b/drivers/net/stmmac/dwmac1000.h
@@ -172,7 +172,6 @@ enum rfd {
 	deac_full_minus_4 = 0x00401800,
 };
 #define DMA_CONTROL_TSF		0x00200000 /* Transmit  Store and Forward */
-#define DMA_CONTROL_FTF		0x00100000 /* Flush transmit FIFO */
 
 enum ttc_control {
 	DMA_CONTROL_TTC_64 = 0x00000000,
diff --git a/drivers/net/stmmac/dwmac1000_dma.c b/drivers/net/stmmac/dwmac1000_dma.c
index 8d3ea99..a547aa9 100644
--- a/drivers/net/stmmac/dwmac1000_dma.c
+++ b/drivers/net/stmmac/dwmac1000_dma.c
@@ -58,15 +58,6 @@ static int dwmac1000_dma_init(unsigned long ioaddr, int pbl, u32 dma_tx,
 	return 0;
 }
 
-/* Transmit FIFO flush operation */
-static void dwmac1000_flush_tx_fifo(unsigned long ioaddr)
-{
-	u32 csr6 = readl(ioaddr + DMA_CONTROL);
-	writel((csr6 | DMA_CONTROL_FTF), ioaddr + DMA_CONTROL);
-
-	do {} while ((readl(ioaddr + DMA_CONTROL) & DMA_CONTROL_FTF));
-}
-
 static void dwmac1000_dma_operation_mode(unsigned long ioaddr, int txmode,
 				    int rxmode)
 {
diff --git a/drivers/net/stmmac/dwmac_dma.h b/drivers/net/stmmac/dwmac_dma.h
index de848d9..7b815a1 100644
--- a/drivers/net/stmmac/dwmac_dma.h
+++ b/drivers/net/stmmac/dwmac_dma.h
@@ -95,6 +95,7 @@
 #define DMA_STATUS_TU	0x00000004	/* Transmit Buffer Unavailable */
 #define DMA_STATUS_TPS	0x00000002	/* Transmit Process Stopped */
 #define DMA_STATUS_TI	0x00000001	/* Transmit Interrupt */
+#define DMA_CONTROL_FTF		0x00100000 /* Flush transmit FIFO */
 
 extern void dwmac_enable_dma_transmission(unsigned long ioaddr);
 extern void dwmac_enable_dma_irq(unsigned long ioaddr);
diff --git a/drivers/net/stmmac/dwmac_lib.c b/drivers/net/stmmac/dwmac_lib.c
index d4adb1e..0a504ad 100644
--- a/drivers/net/stmmac/dwmac_lib.c
+++ b/drivers/net/stmmac/dwmac_lib.c
@@ -227,6 +227,13 @@ int dwmac_dma_interrupt(unsigned long ioaddr,
 	return ret;
 }
 
+void dwmac_dma_flush_tx_fifo(unsigned long ioaddr)
+{
+	u32 csr6 = readl(ioaddr + DMA_CONTROL);
+	writel((csr6 | DMA_CONTROL_FTF), ioaddr + DMA_CONTROL);
+
+	do {} while ((readl(ioaddr + DMA_CONTROL) & DMA_CONTROL_FTF));
+}
 
 void stmmac_set_mac_addr(unsigned long ioaddr, u8 addr[6],
 			 unsigned int high, unsigned int low)
diff --git a/drivers/net/stmmac/enh_desc.c b/drivers/net/stmmac/enh_desc.c
index e5ac259..eb5684a 100644
--- a/drivers/net/stmmac/enh_desc.c
+++ b/drivers/net/stmmac/enh_desc.c
@@ -40,7 +40,7 @@ static int enh_desc_get_tx_status(void *data, struct stmmac_extra_stats *x,
 		if (unlikely(p->des01.etx.frame_flushed)) {
 			CHIP_DBG(KERN_ERR "\tframe_flushed error\n");
 			x->tx_frame_flushed++;
-			/*enh_desc_flush_tx_fifo(ioaddr);*/
+			dwmac_dma_flush_tx_fifo(ioaddr);
 		}
 
 		if (unlikely(p->des01.etx.loss_carrier)) {
@@ -68,7 +68,7 @@ static int enh_desc_get_tx_status(void *data, struct stmmac_extra_stats *x,
 
 		if (unlikely(p->des01.etx.underflow_error)) {
 			CHIP_DBG(KERN_ERR "\tunderflow error\n");
-			/*enh_desc_flush_tx_fifo(ioaddr);*/
+			dwmac_dma_flush_tx_fifo(ioaddr);
 			x->tx_underflow++;
 		}
 
@@ -80,7 +80,7 @@ static int enh_desc_get_tx_status(void *data, struct stmmac_extra_stats *x,
 		if (unlikely(p->des01.etx.payload_error)) {
 			CHIP_DBG(KERN_ERR "\tAddr/Payload csum error\n");
 			x->tx_payload_error++;
-			/*enh_desc_flush_tx_fifo(ioaddr);*/
+			dwmac_dma_flush_tx_fifo(ioaddr);
 		}
 
 		ret = -1;
-- 
1.6.0.4

