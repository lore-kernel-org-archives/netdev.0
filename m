From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 3/8] net: irda/sa1100_ir: add gpiod APIs for controlling IrDA
 transceiver
Date: Mon, 29 Aug 2016 12:26:15 +0100
Message-ID: <E1beKhj-0001Gz-HL@rmk-PC.armlinux.org.uk>
References: <20160829112540.GF1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Dan Williams <dan.j.williams@intel.com>,
        Samuel Ortiz <samuel@sortiz.org>,
        Vinod Koul <vinod.koul@intel.com>
To: dmaengine@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:56844 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756977AbcH2L0Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 07:26:25 -0400
In-Reply-To: <20160829112540.GF1041@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add GPIO support using the gpiod APIs for controlling the IrDA
transceiver modes (FIR vs SIR), power and range.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/irda/sa1100_ir.c | 58 ++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 56 insertions(+), 2 deletions(-)

diff --git a/drivers/net/irda/sa1100_ir.c b/drivers/net/irda/sa1100_ir.c
index 7bc9c2955d4b..25c63c9ff33c 100644
--- a/drivers/net/irda/sa1100_ir.c
+++ b/drivers/net/irda/sa1100_ir.c
@@ -23,6 +23,7 @@
 #include <linux/types.h>
 #include <linux/init.h>
 #include <linux/errno.h>
+#include <linux/gpio/consumer.h>
 #include <linux/netdevice.h>
 #include <linux/slab.h>
 #include <linux/rtnetlink.h>
@@ -72,6 +73,10 @@ struct sa1100_irda {
 
 	int (*tx_start)(struct sk_buff *, struct net_device *, struct sa1100_irda *);
 	irqreturn_t (*irq)(struct net_device *, struct sa1100_irda *);
+
+	struct gpio_desc	*fsel_gpio;
+	struct gpio_desc	*pwr_gpio;
+	struct gpio_desc	*md_gpio[2];
 };
 
 static int sa1100_irda_set_speed(struct sa1100_irda *, int);
@@ -574,6 +579,8 @@ static int sa1100_irda_set_speed(struct sa1100_irda *si, int speed)
 
 		if (si->pdata->set_speed)
 			si->pdata->set_speed(si->dev, speed);
+		if (si->fsel_gpio)
+			gpiod_set_value(si->fsel_gpio, 0);
 
 		si->speed = speed;
 		si->tx_start = sa1100_irda_sir_tx_start;
@@ -600,6 +607,8 @@ static int sa1100_irda_set_speed(struct sa1100_irda *si, int speed)
 
 		if (si->pdata->set_speed)
 			si->pdata->set_speed(si->dev, speed);
+		if (si->fsel_gpio)
+			gpiod_set_value(si->fsel_gpio, 1);
 
 		sa1100_irda_rx_alloc(si);
 		sa1100_irda_rx_dma_start(si);
@@ -629,9 +638,19 @@ static int
 __sa1100_irda_set_power(struct sa1100_irda *si, unsigned int state)
 {
 	int ret = 0;
-	if (si->pdata->set_power)
+	if (si->pdata->set_power) {
 		ret = si->pdata->set_power(si->dev, state);
-	return ret;
+	} else if (si->pwr_gpio) {
+		gpiod_set_value_cansleep(si->pwr_gpio, state);
+	} else if (si->md_gpio[0] && si->md_gpio[1]) {
+		int vals[2];
+
+		vals[0] = state < 2;
+		vals[1] = state == 1 || state == 2;
+
+		gpiod_set_array_value_cansleep(2, si->md_gpio, vals);
+	}
+	return 0;
 }
 
 static inline int
@@ -914,6 +933,21 @@ static const struct net_device_ops sa1100_irda_netdev_ops = {
 	.ndo_do_ioctl		= sa1100_irda_ioctl,
 };
 
+static int sa1100_irda_get_gpio(struct device *dev, struct gpio_desc **descp,
+	const char *name, enum gpiod_flags flags)
+{
+	struct gpio_desc *desc = devm_gpiod_get_optional(dev, name, flags);
+
+	if (IS_ERR(desc)) {
+		int err = PTR_ERR(desc);
+		dev_err(dev, "unable to get %s gpio: %d\n", name, err);
+		return err;
+	}
+
+	*descp = desc;
+	return 0;
+}
+
 static int sa1100_irda_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
@@ -950,6 +984,26 @@ static int sa1100_irda_probe(struct platform_device *pdev)
 	si->dev = &pdev->dev;
 	si->pdata = pdev->dev.platform_data;
 
+	err = sa1100_irda_get_gpio(&pdev->dev, &si->fsel_gpio, "ir-fsel",
+				   GPIOD_OUT_LOW);
+	if (err)
+		goto err_mem_5;
+
+	err = sa1100_irda_get_gpio(&pdev->dev, &si->pwr_gpio, "ir-power",
+				   GPIOD_OUT_LOW);
+	if (err)
+		goto err_mem_5;
+
+	err = sa1100_irda_get_gpio(&pdev->dev, &si->md_gpio[0], "ir-md0",
+				   GPIOD_OUT_HIGH);
+	if (err)
+		goto err_mem_5;
+
+	err = sa1100_irda_get_gpio(&pdev->dev, &si->md_gpio[1], "ir-md1",
+				   GPIOD_OUT_LOW);
+	if (err)
+		goto err_mem_5;
+
 	sg_init_table(&si->dma_rx.sg, 1);
 	sg_init_table(&si->dma_tx.sg, 1);
 
-- 
2.1.0
