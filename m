From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 1/7] net: ethernet: stmmac: dwmac-socfpga: fix use-after-free on probe errors
Date: Wed, 30 Nov 2016 15:29:49 +0100
Message-ID: <1480516195-27696-2-git-send-email-johan@kernel.org>
References: <1480516195-27696-1-git-send-email-johan@kernel.org>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Joachim Eastwood <manabian@gmail.com>,
        Carlo Caione <carlo@caione.org>,
        Kevin Hilman <khilman@baylibre.com>,
        Maxime Coquelin <mcoquelin.stm32@gmail.com>,
        Maxime Ripard <maxime.ripard@free-electrons.com>,
        Chen-Yu Tsai <wens@csie.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480516195-27696-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to call stmmac_dvr_remove() before returning on late probe
errors so that memory is freed, clocks are disabled, and the netdev is
deregistered before its resources go away.

Fixes: 3c201b5a84ed ("net: stmmac: socfpga: Remove re-registration of
reset controller")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    | 29 ++++++++++++++--------
 1 file changed, 19 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index bec6963ac71e..47db157da3e8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -304,6 +304,8 @@ static int socfpga_dwmac_probe(struct platform_device *pdev)
 	struct device		*dev = &pdev->dev;
 	int			ret;
 	struct socfpga_dwmac	*dwmac;
+	struct net_device	*ndev;
+	struct stmmac_priv	*stpriv;
 
 	ret = stmmac_get_platform_resources(pdev, &stmmac_res);
 	if (ret)
@@ -327,19 +329,26 @@ static int socfpga_dwmac_probe(struct platform_device *pdev)
 	plat_dat->fix_mac_speed = socfpga_dwmac_fix_mac_speed;
 
 	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+	if (ret)
+		return ret;
 
-	if (!ret) {
-		struct net_device *ndev = platform_get_drvdata(pdev);
-		struct stmmac_priv *stpriv = netdev_priv(ndev);
+	ndev = platform_get_drvdata(pdev);
+	stpriv = netdev_priv(ndev);
 
-		/* The socfpga driver needs to control the stmmac reset to
-		 * set the phy mode. Create a copy of the core reset handel
-		 * so it can be used by the driver later.
-		 */
-		dwmac->stmmac_rst = stpriv->stmmac_rst;
+	/* The socfpga driver needs to control the stmmac reset to set the phy
+	 * mode. Create a copy of the core reset handle so it can be used by
+	 * the driver later.
+	 */
+	dwmac->stmmac_rst = stpriv->stmmac_rst;
 
-		ret = socfpga_dwmac_set_phy_mode(dwmac);
-	}
+	ret = socfpga_dwmac_set_phy_mode(dwmac);
+	if (ret)
+		goto err_dvr_remove;
+
+	return 0;
+
+err_dvr_remove:
+	stmmac_dvr_remove(&pdev->dev);
 
 	return ret;
 }
-- 
2.7.3
