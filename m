From: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] net: sun4i-emac: Claim emac sram
Date: Sun, 23 Aug 2015 20:31:38 +0200
Message-ID: <1440354698-11144-1-git-send-email-hdegoede@redhat.com>
Reply-To: hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jelle van der Waa <jelle-oJJ1AqDjjO4@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
        Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-sunxi+bncBDRZXY4CYYORBEVD5CXAKGQEVJIUPTQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <http://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

Claim the emac sram ourselves, rather then relying on the bootloader
having mapped the sram to the emac controller during boot.

Signed-off-by: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/allwinner/sun4i-emac.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
index bab01c84..48ce83e 100644
--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
@@ -28,6 +28,7 @@
 #include <linux/of_platform.h>
 #include <linux/platform_device.h>
 #include <linux/phy.h>
+#include <linux/soc/sunxi/sunxi_sram.h>
 
 #include "sun4i-emac.h"
 
@@ -857,11 +858,17 @@ static int emac_probe(struct platform_device *pdev)
 
 	clk_prepare_enable(db->clk);
 
+	ret = sunxi_sram_claim(&pdev->dev);
+	if (ret) {
+		dev_err(&pdev->dev, "Error couldn't map SRAM to device\n");
+		goto out;
+	}
+
 	db->phy_node = of_parse_phandle(np, "phy", 0);
 	if (!db->phy_node) {
 		dev_err(&pdev->dev, "no associated PHY\n");
 		ret = -ENODEV;
-		goto out;
+		goto out_release_sram;
 	}
 
 	/* Read MAC-address from DT */
@@ -893,7 +900,7 @@ static int emac_probe(struct platform_device *pdev)
 	if (ret) {
 		dev_err(&pdev->dev, "Registering netdev failed!\n");
 		ret = -ENODEV;
-		goto out;
+		goto out_release_sram;
 	}
 
 	dev_info(&pdev->dev, "%s: at %p, IRQ %d MAC: %pM\n",
@@ -901,6 +908,8 @@ static int emac_probe(struct platform_device *pdev)
 
 	return 0;
 
+out_release_sram:
+	sunxi_sram_release(&pdev->dev);
 out:
 	dev_err(db->dev, "not found (%d).\n", ret);
 
-- 
2.4.3
