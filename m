From: Chen-Yu Tsai <wens@csie.org>
Subject: [PATCH net] stmmac: dwmac-sunxi: Call exit cleanup function in probe error path
Date: Fri, 11 Dec 2015 18:03:49 +0800
Message-ID: <1449828229-10720-1-git-send-email-wens@csie.org>
Cc: Chen-Yu Tsai <wens@csie.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	Joachim Eastwood <manabian@gmail.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Maxime Ripard <maxime.ripard@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dwmac-sunxi has 2 callbacks that were called from stmmac_platform as
part of the probe and remove sequences.

Ater the conversion of dwmac-sunxi into a standalone platform driver,
the .init function is called before calling into the stmmac driver
core, but .exit is not called to clean up if stmmac returns an error.

This patch fixes the probe error path. This properly cleans up and
releases resources when the driver core fails to probe.

Cc: Joachim Eastwood <manabian@gmail.com>
Fixes: 9a9e9a1edee8 ("stmmac: dwmac-sunxi: turn setup callback into a
		      probe function")
Signed-off-by: Chen-Yu Tsai <wens@csie.org>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c
index 52b8ed9bd87c..adff46375a32 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c
@@ -153,7 +153,11 @@ static int sun7i_gmac_probe(struct platform_device *pdev)
 	if (ret)
 		return ret;
 
-	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+	if (ret)
+		sun7i_gmac_exit(pdev, plat_dat->bsp_priv);
+
+	return ret;
 }
 
 static const struct of_device_id sun7i_dwmac_match[] = {
-- 
2.6.3
