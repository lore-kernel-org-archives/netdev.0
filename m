From: Kishon Vijay Abraham I <kishon@ti.com>
Subject: [PATCH v2 3/5] usb: otg: twl4030: use the new generic PHY framework
Date: Tue, 19 Feb 2013 11:23:16 +0530
Message-ID: <1361253198-7401-4-git-send-email-kishon@ti.com>
References: <1361253198-7401-1-git-send-email-kishon@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <rob@landley.net>, <tony@atomide.com>, <linux@arm.linux.org.uk>,
	<eballetbo@gmail.com>, <javier@dowhile0.org>, <kishon@ti.com>,
	<balbi@ti.com>, <gregkh@linuxfoundation.org>,
	<akpm@linux-foundation.org>, <mchehab@redhat.com>,
	<cesarb@cesarb.net>, <davem@davemloft.net>, <arnd@arndb.de>,
	<santosh.shilimkar@ti.com>, <broonie@opensource.wolfsonmicro.com>,
	<swarren@nvidia.com>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:50915 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757183Ab3BSFyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 00:54:14 -0500
In-Reply-To: <1361253198-7401-1-git-send-email-kishon@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Used the generic PHY framework API to create the PHY. twl4030_usb_suspend
and twl4030_usb_resume is added to phy_ops in order to align
with the new framework.

However using the old USB PHY library cannot be completely removed
because OTG is intertwined with PHY and moving to the new
framework completely will break OTG. Once we have a separate OTG state machine,
we can get rid of the USB PHY library.

Signed-off-by: Kishon Vijay Abraham I <kishon@ti.com>
---
 drivers/usb/otg/twl4030-usb.c |   41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/drivers/usb/otg/twl4030-usb.c b/drivers/usb/otg/twl4030-usb.c
index a994715..b79c319 100644
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
@@ -145,6 +146,7 @@
 
 struct twl4030_usb {
 	struct usb_phy		phy;
+	struct phy_descriptor	desc;
 	struct device		*dev;
 
 	/* TWL4030 internal USB regulator supplies */
@@ -167,6 +169,7 @@ struct twl4030_usb {
 
 /* internal define on top of container_of */
 #define phy_to_twl(x)		container_of((x), struct twl4030_usb, phy)
+#define desc_to_twl(x)		container_of((x), struct twl4030_usb, desc)
 
 /*-------------------------------------------------------------------------*/
 
@@ -575,10 +578,38 @@ static int twl4030_set_host(struct usb_otg *otg, struct usb_bus *host)
 	return 0;
 }
 
+static int twl4030_usb_suspend(struct phy_descriptor *desc)
+{
+	struct twl4030_usb *twl = desc_to_twl(desc);
+
+	twl4030_phy_suspend(twl, 1);
+
+	return 0;
+}
+
+static int twl4030_usb_resume(struct phy_descriptor *desc)
+{
+	struct twl4030_usb *twl = desc_to_twl(desc);
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
@@ -617,6 +648,16 @@ static int twl4030_usb_probe(struct platform_device *pdev)
 	otg->set_host		= twl4030_set_host;
 	otg->set_peripheral	= twl4030_set_peripheral;
 
+	twl->desc.ops		= &ops;
+	twl->desc.label		= "twl4030";
+	twl->desc.of_node	= pdev->dev.of_node;
+
+	phy = devm_phy_create(twl->dev, &twl->desc);
+	if (IS_ERR(phy)) {
+		dev_dbg(&pdev->dev, "Failed to create PHY\n");
+		return PTR_ERR(phy);
+	}
+
 	/* init spinlock for workqueue */
 	spin_lock_init(&twl->lock);
 
-- 
1.7.10.4
