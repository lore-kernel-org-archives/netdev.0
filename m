From: Leonard Crestez <leonard.crestez@nxp.com>
Subject: [PATCH 2/2] net: phy: micrel: Restore led_mode and clk_sel on resume
Date: Tue, 30 May 2017 20:34:04 +0300
Message-ID: <a8d0393c977b0d6fdab5d48ad13ca4d1ca893a07.1496164448.git.leonard.crestez@nxp.com>
References: <cover.1496164448.git.leonard.crestez@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Johan Hovold <johan@kernel.org>,
        Alexandre Belloni <alexandre.belloni@free-electrons.com>,
        Philipp Zabel <p.zabel@pengutronix.de>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
        <linux-kernel@vger.kernel.org>
To: Shawn Guo <shawnguo@kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, Andy Duan <fugang.duan@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1496164448.git.leonard.crestez@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These bits seem to be lost after a suspend/resume cycle so just set them
again.

This patch fixes ethernet suspend/resume on imx6ul-14x14-evk boards.

Signed-off-by: Leonard Crestez <leonard.crestez@nxp.com>
---
 drivers/net/phy/micrel.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 6a5fd18..c53ee17 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -700,6 +700,9 @@ static int kszphy_suspend(struct phy_device *phydev)
 
 static int kszphy_resume(struct phy_device *phydev)
 {
+	struct kszphy_priv *priv = phydev->priv;
+	int ret;
+
 	genphy_resume(phydev);
 
 	/* Enable PHY Interrupts */
@@ -709,6 +712,18 @@ static int kszphy_resume(struct phy_device *phydev)
 			phydev->drv->config_intr(phydev);
 	}
 
+	if (priv->rmii_ref_clk_sel) {
+		ret = kszphy_rmii_clk_sel(phydev, priv->rmii_ref_clk_sel_val);
+		if (ret) {
+			phydev_err(phydev,
+				   "failed to set rmii reference clock\n");
+			return ret;
+		}
+	}
+
+	if (priv->led_mode >= 0)
+		kszphy_setup_led(phydev, priv->type->led_mode_reg, priv->led_mode);
+
 	return 0;
 }
 
-- 
2.7.4
