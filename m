From: Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH 2/4] ravb: Add optional PHY reset during system resume
Date: Thu, 28 Sep 2017 17:53:32 +0200
Message-ID: <1506614014-4398-3-git-send-email-geert+renesas@glider.be>
References: <1506614014-4398-1-git-send-email-geert+renesas@glider.be>
Cc: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas-1zkq55x86MTxsAP9Fp7wbw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-renesas-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>
To: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>,
        Magnus Damm <magnus.damm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1506614014-4398-1-git-send-email-geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

If the optional "reset-gpios" property is specified in DT, the generic
MDIO bus code takes care of resetting the PHY during device probe.
However, the PHY may still have to be reset explicitly after system
resume.

This allows to restore Ethernet operation after resume from s2ram on
Salvator-XS, where the enable pin of the regulator providing PHY power
is connected to PRESETn, and PSCI suspend powers down the SoC.

Signed-off-by: Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>
---
 drivers/net/ethernet/renesas/ravb_main.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index fdf30bfa403bf416..96d1d48e302f8c9a 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -19,6 +19,7 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
+#include <linux/gpio/consumer.h>
 #include <linux/kernel.h>
 #include <linux/list.h>
 #include <linux/module.h>
@@ -2268,6 +2269,7 @@ static int __maybe_unused ravb_resume(struct device *dev)
 {
 	struct net_device *ndev = dev_get_drvdata(dev);
 	struct ravb_private *priv = netdev_priv(ndev);
+	struct mii_bus *bus = priv->mii_bus;
 	int ret = 0;
 
 	if (priv->wol_enabled) {
@@ -2302,6 +2304,13 @@ static int __maybe_unused ravb_resume(struct device *dev)
 	 * reopen device if it was running before system suspended.
 	 */
 
+	/* PHY reset */
+	if (bus->reset_gpiod) {
+		gpiod_set_value_cansleep(bus->reset_gpiod, 1);
+		udelay(bus->reset_delay_us);
+		gpiod_set_value_cansleep(bus->reset_gpiod, 0);
+	}
+
 	/* Set AVB config mode */
 	ravb_set_config_mode(ndev);
 
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
