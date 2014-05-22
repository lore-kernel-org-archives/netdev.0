From: Stephen Boyd <sboyd@codeaurora.org>
Subject: [PATCH 4/5] net: ks8851: Add optional vdd_io regulator and reset gpio
Date: Thu, 22 May 2014 14:00:12 -0700
Message-ID: <1400792413-21618-5-git-send-email-sboyd@codeaurora.org>
References: <1400792413-21618-1-git-send-email-sboyd@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Nishanth Menon <nm@ti.com>, linux-arm-msm@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1400792413-21618-1-git-send-email-sboyd@codeaurora.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Allow the ks8851 driver to enable an optional 1.8V vdd_io
regulator and assert the reset pin to the phy if a reset gpio is
present in device tree.

Cc: Nishanth Menon <nm@ti.com>
Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>
---
 drivers/net/ethernet/micrel/ks8851.c | 54 +++++++++++++++++++++++++++++++++++-
 1 file changed, 53 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index f2bfc708880c..3a322daba5ff 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -26,6 +26,8 @@
 #include <linux/regulator/consumer.h>
 
 #include <linux/spi/spi.h>
+#include <linux/gpio.h>
+#include <linux/of_gpio.h>
 
 #include "ks8851.h"
 
@@ -85,6 +87,8 @@ union ks8851_tx_hdr {
  * @eeprom_size: Companion eeprom size in Bytes, 0 if no eeprom
  * @eeprom: 93CX6 EEPROM state for accessing on-board EEPROM.
  * @vdd_reg:	Optional regulator supplying the chip
+ * @vdd_io: Optional digital power supply for IO
+ * @gpio: Optional reset_n gpio
  *
  * The @lock ensures that the chip is protected when certain operations are
  * in progress. When the read or write packet transfer is in progress, most
@@ -133,6 +137,8 @@ struct ks8851_net {
 
 	struct eeprom_93cx6	eeprom;
 	struct regulator	*vdd_reg;
+	struct regulator	*vdd_io;
+	int			gpio;
 };
 
 static int msg_enable;
@@ -1404,6 +1410,7 @@ static int ks8851_probe(struct spi_device *spi)
 	struct ks8851_net *ks;
 	int ret;
 	unsigned cider;
+	int gpio;
 
 	ndev = alloc_etherdev(sizeof(struct ks8851_net));
 	if (!ndev)
@@ -1417,6 +1424,37 @@ static int ks8851_probe(struct spi_device *spi)
 	ks->spidev = spi;
 	ks->tx_space = 6144;
 
+	gpio = of_get_named_gpio_flags(spi->dev.of_node, "reset-gpios",
+				       0, NULL);
+	if (gpio == -EPROBE_DEFER) {
+		ret = gpio;
+		goto err_gpio;
+	}
+
+	ks->gpio = gpio;
+	if (gpio_is_valid(gpio)) {
+		ret = devm_gpio_request_one(&spi->dev, gpio,
+					    GPIOF_OUT_INIT_LOW, "ks8851_rst_n");
+		if (ret) {
+			dev_err(&spi->dev, "reset gpio request failed\n");
+			goto err_gpio;
+		}
+	}
+
+	ks->vdd_io = devm_regulator_get_optional(&spi->dev, "vdd-io");
+	if (IS_ERR(ks->vdd_io)) {
+		ret = PTR_ERR(ks->vdd_io);
+		if (ret == -EPROBE_DEFER)
+			goto err_reg_io;
+	} else {
+		ret = regulator_enable(ks->vdd_io);
+		if (ret) {
+			dev_err(&spi->dev, "regulator vdd_io enable fail: %d\n",
+				ret);
+			goto err_reg_io;
+		}
+	}
+
 	ks->vdd_reg = devm_regulator_get_optional(&spi->dev, "vdd");
 	if (IS_ERR(ks->vdd_reg)) {
 		ret = PTR_ERR(ks->vdd_reg);
@@ -1425,12 +1463,16 @@ static int ks8851_probe(struct spi_device *spi)
 	} else {
 		ret = regulator_enable(ks->vdd_reg);
 		if (ret) {
-			dev_err(&spi->dev, "regulator enable fail: %d\n",
+			dev_err(&spi->dev, "regulator vdd enable fail: %d\n",
 				ret);
 			goto err_reg;
 		}
 	}
 
+	if (gpio_is_valid(gpio)) {
+		usleep_range(10000, 11000);
+		gpio_set_value(gpio, 1);
+	}
 
 	mutex_init(&ks->lock);
 	spin_lock_init(&ks->statelock);
@@ -1527,10 +1569,16 @@ err_netdev:
 	free_irq(ndev->irq, ks);
 
 err_irq:
+	if (gpio_is_valid(gpio))
+		gpio_set_value(gpio, 0);
 err_id:
 	if (!IS_ERR(ks->vdd_reg))
 		regulator_disable(ks->vdd_reg);
 err_reg:
+	if (!IS_ERR(ks->vdd_io))
+		regulator_disable(ks->vdd_io);
+err_reg_io:
+err_gpio:
 	free_netdev(ndev);
 	return ret;
 }
@@ -1544,8 +1592,12 @@ static int ks8851_remove(struct spi_device *spi)
 
 	unregister_netdev(priv->netdev);
 	free_irq(spi->irq, priv);
+	if (gpio_is_valid(priv->gpio))
+		gpio_set_value(priv->gpio, 0);
 	if (!IS_ERR(priv->vdd_reg))
 		regulator_disable(priv->vdd_reg);
+	if (!IS_ERR(priv->vdd_io))
+		regulator_disable(priv->vdd_io);
 	free_netdev(priv->netdev);
 
 	return 0;
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation
