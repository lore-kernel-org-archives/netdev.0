From: Christoph Fritz <chf.fritz@googlemail.com>
Subject: [PATCH] net: smsc911x: adopt pinctrl support
Date: Sat, 13 Apr 2013 19:22:25 +0200
Message-ID: <1365873745.3812.37.camel@mars>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Javier Martinez Canillas <martinez.javier@gmail.com>,
	Sebastien Guiriec <s-guiriec@ti.com>,
	Daniel Mack <daniel@zonque.org>,
	"Hans J. Koch" <hjk@hansjkoch.de>, linux-omap@vger.kernel.org
To: Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is derived from 2d4b4520a "i2c: omap: adopt pinctrl support":
Some GPIO expanders need some early pin control muxing. Due to
legacy boards sometimes the driver uses subsys_initcall instead of
module_init. This patch takes advantage of defer probe feature
and pin control in order to wait until pin control probing before
GPIO driver probing.

Signed-off-by: Christoph Fritz <chf.fritz@googlemail.com>
---
 drivers/net/ethernet/smsc/smsc911x.c |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index da5cc9a..3e3547c 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -59,6 +59,7 @@
 #include <linux/of_device.h>
 #include <linux/of_gpio.h>
 #include <linux/of_net.h>
+#include <linux/pinctrl/consumer.h>
 #include "smsc911x.h"
 
 #define SMSC_CHIPNAME		"smsc911x"
@@ -144,6 +145,8 @@ struct smsc911x_data {
 
 	/* regulators */
 	struct regulator_bulk_data supplies[SMSC911X_NUM_SUPPLIES];
+
+	struct pinctrl *pins;
 };
 
 /* Easy access to information */
@@ -2433,6 +2436,18 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
 	if (retval < 0)
 		goto out_disable_resources;
 
+	pdata->pins = devm_pinctrl_get_select_default(&pdev->dev);
+	if (IS_ERR(pdata->pins)) {
+		if (PTR_ERR(pdata->pins) == -EPROBE_DEFER) {
+			retval = -EPROBE_DEFER;
+			goto out_disable_resources;
+		}
+
+		dev_warn(&pdev->dev, "No pins for smsc911x error: %li\n",
+			 PTR_ERR(pdata->pins));
+		pdata->pins = NULL;
+	}
+
 	/* configure irq polarity and type before connecting isr */
 	if (pdata->config.irq_polarity == SMSC911X_IRQ_POLARITY_ACTIVE_HIGH)
 		intcfg |= INT_CFG_IRQ_POL_;
-- 
1.7.10.4



