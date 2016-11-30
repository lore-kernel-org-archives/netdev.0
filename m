From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 5/7] net: ethernet: stmmac: dwmac-meson8b: fix probe error path
Date: Wed, 30 Nov 2016 15:29:53 +0100
Message-ID: <1480516195-27696-6-git-send-email-johan@kernel.org>
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

Make sure to disable clocks before returning on late probe errors.

Fixes: 566e82516253 ("net: stmmac: add a glue driver for the Amlogic
Meson 8b / GXBB DWMAC")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
index 250e4ceafc8d..45e7aaf0170d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
@@ -289,7 +289,16 @@ static int meson8b_dwmac_probe(struct platform_device *pdev)
 
 	plat_dat->bsp_priv = dwmac;
 
-	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+	if (ret)
+		goto err_clk_disable;
+
+	return 0;
+
+err_clk_disable:
+	clk_disable_unprepare(dwmac->m25_div_clk);
+
+	return ret;
 }
 
 static int meson8b_dwmac_remove(struct platform_device *pdev)
-- 
2.7.3
