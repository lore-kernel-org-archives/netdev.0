From: Jens Kuske <jenskuske-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 3/3] net: allwinner: sun4i-emac: fix emac SRAM mapping
Date: Sun, 25 Jan 2015 16:49:19 +0100
Message-ID: <1422200959-1717-4-git-send-email-jenskuske@gmail.com>
References: <1422200959-1717-1-git-send-email-jenskuske@gmail.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Jens Kuske <jenskuske-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Lee Jones <lee.jones-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-sunxi+bncBCC5XIE2SIHBBCNBSSTAKGQEETWSUZQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1422200959-1717-1-git-send-email-jenskuske-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <http://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

The EMAC needs SRAM block A3_A4 being mapped to EMAC peripheral to
work. This is done by the bootloader most of the time, but U-Boot
Falcon Mode, for example, skips emac initialization and SRAM would
stay mapped to the CPU.

Signed-off-by: Jens Kuske <jenskuske-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ethernet/allwinner/Kconfig      |  1 +
 drivers/net/ethernet/allwinner/sun4i-emac.c | 18 ++++++++++++++++++
 2 files changed, 19 insertions(+)

diff --git a/drivers/net/ethernet/allwinner/Kconfig b/drivers/net/ethernet/allwinner/Kconfig
index d8d95d4..508a288 100644
--- a/drivers/net/ethernet/allwinner/Kconfig
+++ b/drivers/net/ethernet/allwinner/Kconfig
@@ -28,6 +28,7 @@ config SUN4I_EMAC
 	select MII
 	select PHYLIB
 	select MDIO_SUN4I
+	select MFD_SYSCON
         ---help---
           Support for Allwinner A10 EMAC ethernet driver.
 
diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
index 1fcd556..86c891d 100644
--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
@@ -18,6 +18,8 @@
 #include <linux/gpio.h>
 #include <linux/interrupt.h>
 #include <linux/irq.h>
+#include <linux/mfd/syscon.h>
+#include <linux/mfd/syscon/sun4i-sc.h>
 #include <linux/mii.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
@@ -28,6 +30,7 @@
 #include <linux/of_platform.h>
 #include <linux/platform_device.h>
 #include <linux/phy.h>
+#include <linux/regmap.h>
 
 #include "sun4i-emac.h"
 
@@ -78,6 +81,7 @@ struct emac_board_info {
 
 	struct phy_device	*phy_dev;
 	struct device_node	*phy_node;
+	struct regmap		*sc;
 	unsigned int		link;
 	unsigned int		speed;
 	unsigned int		duplex;
@@ -862,6 +866,18 @@ static int emac_probe(struct platform_device *pdev)
 		goto out;
 	}
 
+	/* Map SRAM_A3_A4 to EMAC */
+	db->sc = syscon_regmap_lookup_by_compatible(
+						"allwinner,sun4i-a10-syscon");
+	if (IS_ERR(db->sc)) {
+		dev_err(&pdev->dev, "failed to find syscon regmap\n");
+		ret = PTR_ERR(db->sc);
+		goto out;
+	}
+
+	regmap_update_bits(db->sc, SUN4I_SC1, SUN4I_SC1_SRAM_A3_A4_MAP_MASK,
+						SUN4I_SC1_SRAM_A3_A4_MAP_EMAC);
+
 	/* Read MAC-address from DT */
 	mac_addr = of_get_mac_address(np);
 	if (mac_addr)
@@ -910,7 +926,9 @@ out:
 static int emac_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct emac_board_info *db = netdev_priv(ndev);
 
+	regmap_update_bits(db->sc, SUN4I_SC1, SUN4I_SC1_SRAM_A3_A4_MAP_MASK, 0);
 	unregister_netdev(ndev);
 	free_netdev(ndev);
 
-- 
2.2.2
