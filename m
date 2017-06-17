From: Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
Subject: [PATCH 3/4] net-next: stmmac: dwmac-sun8i: force EPHY
 clock freq to 24MHz
Date: Sat, 17 Jun 2017 22:07:36 +0800
Message-ID: <20170617140737.41951-4-icenowy@aosc.io>
References: <20170617140737.41951-1-icenowy@aosc.io>
Reply-To: icenowy-h8G6r0blFSE@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Return-path: <linux-sunxi+bncBDS6XAN6ZADRBFXQSTFAKGQE7373MEI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20170617140737.41951-1-icenowy-h8G6r0blFSE@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

The EPHY control part of the EMAC syscon register has a bit called
CLK_SEL. On the datasheet it says that if it's 0 the EPHY clock is 25MHz
and if it's 1 the clock is 24MHz.

However, according to the datasheets, no Allwinner SoC with EPHY has any
extra xtal input pins for the EPHY, and the system xtal is 24MHz.

That means the EPHY is not possible to get a 25MHz xtal input, and thus
the frequency can only be 24MHz.

It doesn't matter on H3 as the default value of H3 is 24MHz, however on
V3s the default value is wrongly set to 25MHz, which prevented the EPHY
from working properly.

Force the EPHY clock frequency to 24MHz.

Signed-off-by: Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
index 54f93ee53ef7..61ce3b54f0c6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
@@ -185,6 +185,7 @@ static const struct emac_variant emac_variant_a64 = {
 
 /* H3 specific bits for EPHY */
 #define H3_EPHY_ADDR_SHIFT	20
+#define H3_EPHY_CLK_SEL		BIT(18) /* 1: 24MHz, 0: 25MHz */
 #define H3_EPHY_LED_POL		BIT(17) /* 1: active low, 0: active high */
 #define H3_EPHY_SHUTDOWN	BIT(16) /* 1: shutdown, 0: power up */
 #define H3_EPHY_SELECT		BIT(15) /* 1: internal PHY, 0: external PHY */
@@ -656,6 +657,9 @@ static int sun8i_dwmac_set_syscon(struct stmmac_priv *priv)
 			else
 				reg &= ~H3_EPHY_LED_POL;
 
+			/* Force EPHY xtal frequency to 24MHz. */
+			reg |= H3_EPHY_CLK_SEL;
+
 			ret = of_mdio_parse_addr(priv->device,
 						 priv->plat->phy_node);
 			if (ret < 0) {
-- 
2.13.0
