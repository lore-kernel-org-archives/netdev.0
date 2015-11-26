From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git)] stmmac: fix resource management when resume
Date: Thu, 26 Nov 2015 11:32:04 +0100
Message-ID: <1448533924-20684-1-git-send-email-peppe.cavallaro@st.com>
References: <1448181858-5935-1-git-send-email-zhengsq@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:43268 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750801AbbKZKYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 05:24:38 -0500
In-Reply-To: <1448181858-5935-1-git-send-email-zhengsq@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a memleak when suspend/resume this driver version.
Currently the stmmac, during resume step, reallocates all the resources
but they are not released when suspend.
The patch is not to release these resources but the logic has been changed.
In fact, it is not necessary to free and reallocate all from scratch
because the memory data will be always preserved.
As final solution, the patch just reinit the descriptors and the rx/tx
pointers only when resume. Tested done on STi boxes.

Reported-by: ZhengShunQian <zhengsq@rock-chips.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 64d8aa4..5a1abc0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3040,8 +3040,6 @@ int stmmac_suspend(struct net_device *ndev)
 	priv->hw->dma->stop_tx(priv->ioaddr);
 	priv->hw->dma->stop_rx(priv->ioaddr);
 
-	stmmac_clear_descriptors(priv);
-
 	/* Enable Power down mode by programming the PMT regs */
 	if (device_may_wakeup(priv->device)) {
 		priv->hw->mac->pmt(priv->hw, priv->wolopts);
@@ -3099,7 +3097,12 @@ int stmmac_resume(struct net_device *ndev)
 
 	netif_device_attach(ndev);
 
-	init_dma_desc_rings(ndev, GFP_ATOMIC);
+	priv->cur_rx = 0;
+	priv->dirty_rx = 0;
+	priv->dirty_tx = 0;
+	priv->cur_tx = 0;
+	stmmac_clear_descriptors(priv);
+
 	stmmac_hw_setup(ndev, false);
 	stmmac_init_tx_coalesce(priv);
 
-- 
1.7.4.4
