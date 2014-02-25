From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 2/6] stmmac: fix and better tune the default buffer sizes
Date: Tue, 25 Feb 2014 10:58:25 +0100
Message-ID: <1393322309-10390-2-git-send-email-peppe.cavallaro@st.com>
References: <1393322309-10390-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog125.obsmtp.com ([207.126.144.159]:47431 "EHLO
	eu1sys200aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750708AbaBYJ75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 04:59:57 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 559CC1C1
	for <netdev@vger.kernel.org>; Tue, 25 Feb 2014 09:59:52 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas22.st.com [10.75.90.92])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 34744B538
	for <netdev@vger.kernel.org>; Tue, 25 Feb 2014 09:59:52 +0000 (GMT)
In-Reply-To: <1393322309-10390-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to fix and tune the default buffer sizes.
It reduces the default bufsize used by the driver from
2048 to 1518 (taking into account the extra 4 bytes in case of VLAN).

Patch has been tested on both ARM and SH4 platform based.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index dc89dc3..a50c8fc 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -92,8 +92,12 @@ static int tc = TC_DEFAULT;
 module_param(tc, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(tc, "DMA threshold control value");
 
-#define DMA_BUFFER_SIZE	BUF_SIZE_4KiB
-static int buf_sz = DMA_BUFFER_SIZE;
+#ifdef STMMAC_VLAN_TAG_USED
+#define	DEFAULT_BUFSIZE	(VLAN_ETH_FRAME_LEN + ETH_FCS_LEN)
+#else
+#define	DEFAULT_BUFSIZE	(ETH_FRAME_LEN + ETH_FCS_LEN)
+#endif
+static int buf_sz = DEFAULT_BUFSIZE;
 module_param(buf_sz, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(buf_sz, "DMA buffer size");
 
@@ -136,8 +140,8 @@ static void stmmac_verify_args(void)
 		dma_rxsize = DMA_RX_SIZE;
 	if (unlikely(dma_txsize < 0))
 		dma_txsize = DMA_TX_SIZE;
-	if (unlikely((buf_sz < DMA_BUFFER_SIZE) || (buf_sz > BUF_SIZE_16KiB)))
-		buf_sz = DMA_BUFFER_SIZE;
+	if (unlikely((buf_sz < DEFAULT_BUFSIZE) || (buf_sz > BUF_SIZE_16KiB)))
+		buf_sz = DEFAULT_BUFSIZE;
 	if (unlikely(flow_ctrl > 1))
 		flow_ctrl = FLOW_AUTO;
 	else if (likely(flow_ctrl < 0))
@@ -901,10 +905,10 @@ static int stmmac_set_bfsize(int mtu, int bufsize)
 		ret = BUF_SIZE_8KiB;
 	else if (mtu >= BUF_SIZE_2KiB)
 		ret = BUF_SIZE_4KiB;
-	else if (mtu >= DMA_BUFFER_SIZE)
+	else if (mtu > DEFAULT_BUFSIZE)
 		ret = BUF_SIZE_2KiB;
 	else
-		ret = DMA_BUFFER_SIZE;
+		ret = DEFAULT_BUFSIZE;
 
 	return ret;
 }
-- 
1.7.4.4
