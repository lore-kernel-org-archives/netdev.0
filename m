From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 4/7] net: ethernet: stmmac: dwmac-generic: fix probe error path
Date: Wed, 30 Nov 2016 15:29:52 +0100
Message-ID: <1480516195-27696-5-git-send-email-johan@kernel.org>
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

Make sure to call any exit() callback to undo the effect of init()
before returning on late probe errors.

Fixes: cf3f047b9af4 ("stmmac: move hw init in the probe (v2)")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
index b1e5f24708c9..05e46a82cdb1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
@@ -53,7 +53,17 @@ static int dwmac_generic_probe(struct platform_device *pdev)
 			return ret;
 	}
 
-	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+	if (ret)
+		goto err_exit;
+
+	return 0;
+
+err_exit:
+	if (plat_dat->exit)
+		plat_dat->exit(pdev, plat_dat->bsp_priv);
+
+	return ret;
 }
 
 static const struct of_device_id dwmac_generic_match[] = {
-- 
2.7.3
