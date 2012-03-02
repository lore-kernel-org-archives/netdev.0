From: Deepak Sikri <deepak.sikri@st.com>
Subject: [PATCH 5/6] stmmac: configure burst related GMAC DMA parameters
Date: Fri, 2 Mar 2012 18:25:27 +0530
Message-ID: <1330692928-30330-6-git-send-email-deepak.sikri@st.com>
References: <1330692928-30330-1-git-send-email-deepak.sikri@st.com>
 <1330692928-30330-2-git-send-email-deepak.sikri@st.com>
 <1330692928-30330-3-git-send-email-deepak.sikri@st.com>
 <1330692928-30330-4-git-send-email-deepak.sikri@st.com>
 <1330692928-30330-5-git-send-email-deepak.sikri@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <spear-devel@list.st.com>, <netdev@vger.kernel.org>,
	Deepak Sikri <deepak.sikri@st.com>,
	Shiraz Hashim <shiraz.hashim@st.com>,
	Vikas Manocha <vikas.manocha@st.com>
To: <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:57372 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755798Ab2CBM4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2012 07:56:06 -0500
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 5D8B9D8
	for <netdev@vger.kernel.org>; Fri,  2 Mar 2012 12:47:36 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas1.st.com [10.80.176.8])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 286A175E
	for <netdev@vger.kernel.org>; Fri,  2 Mar 2012 12:56:01 +0000 (GMT)
In-Reply-To: <1330692928-30330-5-git-send-email-deepak.sikri@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SPEAr1340 GMAC is a different version (3.61a) of Synopsys IP where
instead of 4xPBL we have 8xPBL, hence pbl value supplied by platform
data in
	- SPEAr1340 results in 8 * pbl
	- rest devices result in 4 * pbl

Further it is observed that rest of the devices (older version) which
have an AXI wrapper over AHB are limited  to incr 32 burst where as this
can go up to incr 128 in case of SPEAr1340.

Also, with fixed burst configuration we need to program permissible
burst values in newer versions (AXI supported) of gmac. This
AXI_BUS_MODE) register is reserved for earlier versions of gmac and
writing to them has no impact.

Signed-off-by: Shiraz Hashim <shiraz.hashim@st.com>
Signed-off-by: Vikas Manocha <vikas.manocha@st.com>
Signed-off-by: Deepak Sikri <deepak.sikri@st.com>
---
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |   14 +++++++++++++-
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |    1 +
 2 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
index 4d5402a..ed6ffa3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
@@ -48,7 +48,7 @@ static int dwmac1000_dma_init(void __iomem *ioaddr, int pbl, u32 dma_tx,
 	if (limit < 0)
 		return -EBUSY;
 
-	value = /* DMA_BUS_MODE_FB | */ DMA_BUS_MODE_4PBL |
+	value = DMA_BUS_MODE_FB | DMA_BUS_MODE_4PBL |
 	    ((pbl << DMA_BUS_MODE_PBL_SHIFT) |
 	     (pbl << DMA_BUS_MODE_RPBL_SHIFT));
 
@@ -56,6 +56,18 @@ static int dwmac1000_dma_init(void __iomem *ioaddr, int pbl, u32 dma_tx,
 	value |= DMA_BUS_MODE_DA;	/* Rx has priority over tx */
 #endif
 	writel(value, ioaddr + DMA_BUS_MODE);
+	/*
+	 * We need to program DMA_AXI_BUS_MODE for supported bursts in
+	 * case DMA_BUS_MODE_FB mode is selected
+	 * Note: This is applicable only for revision GMACv3.61a. For
+	 * older version this register is reserved and shall have no
+	 * effect.
+	 * Further we directly write 0xFF to this register. This would
+	 * ensure that all bursts supported by platform is set and those
+	 * which are not supported would remain ineffective.
+	 */
+	if (value & DMA_BUS_MODE_FB)
+		writel(0xFF, ioaddr + DMA_AXI_BUS_MODE);
 
 	/* Mask interrupts by writing to CSR7 */
 	writel(DMA_INTR_DEFAULT_MASK, ioaddr + DMA_INTR_ENA);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
index 437edac..6e0360f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
@@ -32,6 +32,7 @@
 #define DMA_CONTROL		0x00001018	/* Ctrl (Operational Mode) */
 #define DMA_INTR_ENA		0x0000101c	/* Interrupt Enable */
 #define DMA_MISSED_FRAME_CTR	0x00001020	/* Missed Frame Counter */
+#define DMA_AXI_BUS_MODE       0x00001028      /* AXI Bus Mode */
 #define DMA_CUR_TX_BUF_ADDR	0x00001050	/* Current Host Tx Buffer */
 #define DMA_CUR_RX_BUF_ADDR	0x00001054	/* Current Host Rx Buffer */
 #define DMA_HW_FEATURE		0x00001058	/* HW Feature Register */
-- 
1.6.0.2
