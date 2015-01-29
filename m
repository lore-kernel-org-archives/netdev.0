From: Sonic Zhang <sonic.adi@gmail.com>
Subject: [PATCH] stmmac: DMA threshold mode or SF mode can be different among multiple device instance
Date: Thu, 29 Jan 2015 16:54:59 +0800
Message-ID: <1422521699-14096-1-git-send-email-sonic.adi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<adi-buildroot-devel@lists.sourceforge.net>,
	Sonic Zhang <sonic.zhang@analog.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0088.outbound.protection.outlook.com ([207.46.100.88]:35264
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753751AbbA2Jaf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2015 04:30:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.zhang@analog.com>

- In tx_hard_error_bump_tc interrupt, tc should be bumped only when current
device instance is in DMA threshold mode. Check per device xstats.threshold
other than global tc.

- Set per device xstats.threshold to SF_DMA_MODE when current device
instance is set to SF mode.

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index cd6ebda..6c87850 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1287,7 +1287,7 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 		 *    that needs to not insert csum in the TDES.
 		 */
 		priv->hw->dma->dma_mode(priv->ioaddr, SF_DMA_MODE, SF_DMA_MODE);
-		tc = SF_DMA_MODE;
+		priv->xstats.threshold = SF_DMA_MODE;
 	} else
 		priv->hw->dma->dma_mode(priv->ioaddr, tc, SF_DMA_MODE);
 }
@@ -1444,7 +1444,8 @@ static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 	}
 	if (unlikely(status & tx_hard_error_bump_tc)) {
 		/* Try to bump up the dma threshold on this failure */
-		if (unlikely(tc != SF_DMA_MODE) && (tc <= 256)) {
+		if (unlikely(priv->xstats.threshold != SF_DMA_MODE) &&
+			(tc <= 256)) {
 			tc += 64;
 			if (priv->plat->force_thresh_dma_mode)
 				priv->hw->dma->dma_mode(priv->ioaddr, tc, tc);
-- 
1.7.9.5
