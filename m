From: Ezequiel Garcia <ezequiel@vanguardiasur.com.ar>
Subject: [PATCH] stmmac: hardware TX COE doesn't work when force_thresh_dma_mode is set
Date: Mon, 16 May 2016 12:41:07 -0300
Message-ID: <1463413267-19543-1-git-send-email-ezequiel@vanguardiasur.com.ar>
Cc: Joachim Eastwood <manabian@gmail.com>,
	David Miller <davem@davemloft.net>,
	Ezequiel Garcia <ezequiel@vanguardiasur.com.ar>
To: netdev@vger.kernel.org, peppe.cavallaro@st.com,
	alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:35246 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754032AbcEPPla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 11:41:30 -0400
Received: by mail-qg0-f47.google.com with SMTP id f74so90762542qge.2
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 08:41:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit f748be531d70 ("stmmac: support new GMAC4") reverted a previous fix
by mistake. This commit re-applies said fix:

  commit dec2165ff38a99f937fe61875d102c6c8596c815
  Author: Sonic Zhang <sonic.zhang@analog.com>
  Date:   Thu Jan 22 14:55:57 2015 +0800
  stmmac: hardware TX COE doesn't work when force_thresh_dma_mode is set

  Clear the TX COE bit when force_thresh_dma_mode is set even hardware
  dma capability says support.

  Tested on BF609.

  Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
  Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
  Signed-off-by: David S. Miller <davem@davemloft.net>

Tested on LPC4350 Hitex board.

Fixes: f748be531d70 ("stmmac: support new GMAC4")
Signed-off-by: Ezequiel Garcia <ezequiel@vanguardiasur.com.ar>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index fd5ab7bfdb76..eac45d0c75e2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3131,7 +3131,12 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 		priv->plat->enh_desc = priv->dma_cap.enh_desc;
 		priv->plat->pmt = priv->dma_cap.pmt_remote_wake_up;
 
-		priv->plat->tx_coe = priv->dma_cap.tx_coe;
+		/* TXCOE doesn't work in thresh DMA mode */
+		if (priv->plat->force_thresh_dma_mode)
+			priv->plat->tx_coe = 0;
+		else
+			priv->plat->tx_coe = priv->dma_cap.tx_coe;
+
 		/* In case of GMAC4 rx_coe is from HW cap register. */
 		priv->plat->rx_coe = priv->dma_cap.rx_coe;
 
-- 
2.7.0
