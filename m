From: Niklas Cassel <niklas.cassel@axis.com>
Subject: [PATCH v5] net: phy: micrel: Fix regression in kszphy_probe
Date: Tue, 12 May 2015 09:43:14 +0200
Message-ID: <1431416594-7758-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <festevam@gmail.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<johan@kernel.org>, Niklas Cassel <niklass@axis.com>,
	stable <stable@vger.kernel.org>
To: <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't do clock-mode-select if clk == NULL,
since when building without CONFIG_HAVE_CLK,
clk_get returns NULL and clk_get_rate returns 0.

Doing clock-mode-select in this cause causes kszphy_probe to
return -EINVAL and thus prevents the device from being probed.

The original code (before regression) would return 0
when building without CONFIG_HAVE_CLK.

Cc: stable <stable@vger.kernel.org> # 3.18+
Fixes: 1fadee0c3645 ("net/phy: micrel: Add clock support for
KSZ8021/KSZ8031")
Reviewed-by: Fabio Estevam <fabio.estevam@freescale.com>
Reviewed-by: Johan Hovold <johan@kernel.org>
Signed-off-by: Niklas Cassel <niklass@axis.com>
---
 drivers/net/phy/micrel.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 1190fd8..ebdc357 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -548,7 +548,8 @@ static int kszphy_probe(struct phy_device *phydev)
 	}
 
 	clk = devm_clk_get(&phydev->dev, "rmii-ref");
-	if (!IS_ERR(clk)) {
+	/* NOTE: clk may be NULL if building without CONFIG_HAVE_CLK */
+	if (!IS_ERR_OR_NULL(clk)) {
 		unsigned long rate = clk_get_rate(clk);
 		bool rmii_ref_clk_sel_25_mhz;
 
-- 
2.1.4
