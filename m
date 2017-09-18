From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2] net: stmmac: dwmac-sun8i: Use reset exclusive
Date: Mon, 18 Sep 2017 20:30:43 +0200
Message-ID: <20170918183043.8028-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        maxime.ripard@free-electrons.com, wens@csie.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current dwmac_sun8i module cannot be rmmod/modprobe due to that
the reset controller was not released when removed.

This patch remove ambiguity, by using of_reset_control_get_exclusive and
add the missing reset_control_put().

Note that we cannot use devm_reset_control_get, since the reset is not
in the device node.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
Changes since v1:
- added a note about devm_reset_control_get in commit message

 drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
index 57bb6dd7b401..1736d7cb0d96 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
@@ -854,6 +854,7 @@ static int sun8i_dwmac_unpower_internal_phy(struct sunxi_priv_data *gmac)
 
 	clk_disable_unprepare(gmac->ephy_clk);
 	reset_control_assert(gmac->rst_ephy);
+	reset_control_put(gmac->rst_ephy);
 	return 0;
 }
 
@@ -1010,7 +1011,7 @@ static int sun8i_dwmac_probe(struct platform_device *pdev)
 			return -EINVAL;
 		}
 
-		gmac->rst_ephy = of_reset_control_get(plat_dat->phy_node, NULL);
+		gmac->rst_ephy = of_reset_control_get_exclusive(plat_dat->phy_node, NULL);
 		if (IS_ERR(gmac->rst_ephy)) {
 			ret = PTR_ERR(gmac->rst_ephy);
 			if (ret == -EPROBE_DEFER)
-- 
2.13.5
