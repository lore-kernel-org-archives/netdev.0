From: Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
Subject: [PATCH v5 3/6] usb: otg: twl4030: use the new generic PHY framework
Date: Wed, 3 Apr 2013 18:23:51 +0530
Message-ID: <1364993634-6378-4-git-send-email-kishon@ti.com>
References: <1364993634-6378-1-git-send-email-kishon@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org, linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org,
 linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org, kishon-l0cyMroinI0@public.gmane.org,
 eballetbo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, santosh.shilimkar-l0cyMroinI0@public.gmane.org,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org, javier-0uQlZySMnqxg9hUCZPvPmw@public.gmane.org,
 linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, cesarb-PWySMVKUnqmsTnJN9+BGXg@public.gmane.org,
 mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: <balbi-l0cyMroinI0@public.gmane.org>, <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, <arnd-r2nGTMty4D4@public.gmane.org>,
 <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>,
 <sylvester.nawrocki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1364993634-6378-1-git-send-email-kishon-l0cyMroinI0@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Used the generic PHY framework API to create the PHY. twl4030_usb_suspend
and twl4030_usb_resume is added to phy_ops in order to align
with the new framework.

However using the old USB PHY library cannot be completely removed
because OTG is intertwined with PHY and moving to the new
framework completely will break OTG. Once we have a separate OTG state machine,
we can get rid of the USB PHY library.

Signed-off-by: Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
---
 drivers/usb/otg/twl4030-usb.c |   37 +++++++++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/drivers/usb/otg/twl4030-usb.c b/drivers/usb/otg/twl4030-usb.c
index a994715..6dab049 100644
--- a/drivers/usb/otg/twl4030-usb.c
+++ b/drivers/usb/otg/twl4030-usb.c
@@ -33,6 +33,7 @@
 #include <linux/io.h>
 #include <linux/delay.h>
 #include <linux/usb/otg.h>
+#include <linux/phy/phy.h>
 #include <linux/usb/musb-omap.h>
 #include <linux/usb/ulpi.h>
 #include <linux/i2c/twl.h>
@@ -575,10 +576,39 @@ static int twl4030_set_host(struct usb_otg *otg, struct usb_bus *host)
 	return 0;
 }
 
+static int twl4030_usb_suspend(struct phy *phy)
+{
+	struct twl4030_usb *twl = dev_get_drvdata(&phy->dev);
+
+	twl4030_phy_suspend(twl, 1);
+
+	return 0;
+}
+
+static int twl4030_usb_resume(struct phy *phy)
+{
+	struct twl4030_usb *twl = dev_get_drvdata(&phy->dev);
+
+	if (!twl->asleep)
+		return -EBUSY;
+	__twl4030_phy_resume(twl);
+	twl->asleep = 0;
+
+	return 0;
+}
+
+static struct phy_ops ops = {
+	.suspend	= twl4030_usb_suspend,
+	.resume		= twl4030_usb_resume,
+	.of_xlate	= of_phy_xlate,
+	.owner		= THIS_MODULE,
+};
+
 static int twl4030_usb_probe(struct platform_device *pdev)
 {
 	struct twl4030_usb_data *pdata = pdev->dev.platform_data;
 	struct twl4030_usb	*twl;
+	struct phy		*phy;
 	int			status, err;
 	struct usb_otg		*otg;
 	struct device_node	*np = pdev->dev.of_node;
@@ -617,6 +647,13 @@ static int twl4030_usb_probe(struct platform_device *pdev)
 	otg->set_host		= twl4030_set_host;
 	otg->set_peripheral	= twl4030_set_peripheral;
 
+	phy = devm_phy_create(twl->dev, "twl4030", pdev->dev.of_node,
+		USB_PHY_TYPE_USB2, &ops, twl);
+	if (IS_ERR(phy)) {
+		dev_dbg(&pdev->dev, "Failed to create PHY\n");
+		return PTR_ERR(phy);
+	}
+
 	/* init spinlock for workqueue */
 	spin_lock_init(&twl->lock);
 
-- 
1.7.10.4
