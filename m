From: Heiko Stuebner <heiko@sntech.de>
Subject: [PATCH] net: ethernet: stmmac: dwmac-rk: make clk enablement first in powerup
Date: Tue, 20 Dec 2016 17:17:06 +0100
Message-ID: <20161220161706.26505-1-heiko@sntech.de>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        wxt@rock-chips.com, briannorris@chromium.org,
        dianders@chromium.org, linux-rockchip@lists.infradead.org,
        Heiko Stuebner <heiko@sntech.de>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gloria.sntech.de ([95.129.55.99]:37376 "EHLO gloria.sntech.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932234AbcLTQRZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Dec 2016 11:17:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Right now the dwmac-rk tries to set up the GRF-specific speed and link
options before enabling clocks, phys etc and on previous socs this works
because the GRF is supplied on the whole by one clock.

On the rk3399 however the GRF (General Register Files) clock-supply
has been split into multiple clocks and while there is no specific
grf-gmac clock like for other sub-blocks, it seems the mac-specific
portions are actually supplied by the general mac clock.

This results in hangs on rk3399 boards if the driver is build as module.
When built in te problem of course doesn't surface, as the clocks
are of course still on at the stage before clock_disable_unused.

To solve this, simply move the clock enablement to the first position
in the powerup callback. This is also a good idea in general to
enable clocks before everything else.

Tested on rk3288, rk3368 and rk3399 the dwmac still works on all of them.

Signed-off-by: Heiko Stuebner <heiko@sntech.de>
---
This should probably be a fix for 4.10-rc, as right now
my rk3399evb hangs on boot with the arm64 defconfig due to this.

 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 77ab0a8..fa6e970 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -864,6 +864,10 @@ static int rk_gmac_powerup(struct rk_priv_data *bsp_priv)
 	int ret;
 	struct device *dev = &bsp_priv->pdev->dev;
 
+	ret = gmac_clk_enable(bsp_priv, true);
+	if (ret)
+		return ret;
+
 	/*rmii or rgmii*/
 	if (bsp_priv->phy_iface == PHY_INTERFACE_MODE_RGMII) {
 		dev_info(dev, "init for RGMII\n");
@@ -880,10 +884,6 @@ static int rk_gmac_powerup(struct rk_priv_data *bsp_priv)
 	if (ret)
 		return ret;
 
-	ret = gmac_clk_enable(bsp_priv, true);
-	if (ret)
-		return ret;
-
 	pm_runtime_enable(dev);
 	pm_runtime_get_sync(dev);
 
-- 
2.10.2
