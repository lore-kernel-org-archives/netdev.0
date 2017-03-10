From: Thierry Reding <thierry.reding@gmail.com>
Subject: [PATCH v2 2/9] net: stmmac: Stop PHY and remove TX timer on error
Date: Fri, 10 Mar 2017 17:34:54 +0100
Message-ID: <20170310163501.31811-3-thierry.reding@gmail.com>
References: <20170310163501.31811-1-thierry.reding@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Jon Hunter <jonathanh@nvidia.com>,
        Mikko Perttunen <cyndis@kapsi.fi>, netdev@vger.kernel.org,
        linux-tegra@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34541 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932691AbdCJQfJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 11:35:09 -0500
In-Reply-To: <20170310163501.31811-1-thierry.reding@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thierry Reding <treding@nvidia.com>

If an error occurs while opening the device, make sure that both the TX
timer and the PHY are properly cleaned up.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 4498a3861aa3..7c38c9baf238 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1821,7 +1821,7 @@ static int stmmac_open(struct net_device *dev)
 		netdev_err(priv->dev,
 			   "%s: ERROR: allocating the IRQ %d (error: %d)\n",
 			   __func__, dev->irq, ret);
-		goto init_error;
+		goto irq_error;
 	}
 
 	/* Request the Wake IRQ in case of another line is used for WoL */
@@ -1858,7 +1858,11 @@ static int stmmac_open(struct net_device *dev)
 		free_irq(priv->wol_irq, dev);
 wolirq_error:
 	free_irq(dev->irq, dev);
+irq_error:
+	if (dev->phydev)
+		phy_stop(dev->phydev);
 
+	del_timer_sync(&priv->txtimer);
 init_error:
 	free_dma_desc_resources(priv);
 dma_desc_error:
-- 
2.12.0
