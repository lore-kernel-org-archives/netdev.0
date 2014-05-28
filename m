From: Stephen Boyd <sboyd@codeaurora.org>
Subject: [PATCH] net: ks8851: Don't use regulator_get_optional()
Date: Wed, 28 May 2014 13:11:12 -0700
Message-ID: <1401307872-23190-1-git-send-email-sboyd@codeaurora.org>
Cc: linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Nishanth Menon <nm@ti.com>, Mark Brown <broonie@kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We shouldn't be using regulator_get_optional() here. These
regulators are always present as part of the physical design and
there isn't any way to use an internal regulator or change the
source of the reference voltage via software. Given that the only
users of this driver in the kernel are DT based, this change
should be transparent to them even if they don't specify any
supplies because the regulator framework will insert dummy
supplies as needed.

Cc: Nishanth Menon <nm@ti.com>
Cc: Mark Brown <broonie@kernel.org>
Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>
---
 drivers/net/ethernet/micrel/ks8851.c | 50 ++++++++++++++++--------------------
 1 file changed, 22 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index e72918970a58..66d4ab703f45 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -1441,32 +1441,30 @@ static int ks8851_probe(struct spi_device *spi)
 		}
 	}
 
-	ks->vdd_io = devm_regulator_get_optional(&spi->dev, "vdd-io");
+	ks->vdd_io = devm_regulator_get(&spi->dev, "vdd-io");
 	if (IS_ERR(ks->vdd_io)) {
 		ret = PTR_ERR(ks->vdd_io);
-		if (ret == -EPROBE_DEFER)
-			goto err_reg_io;
-	} else {
-		ret = regulator_enable(ks->vdd_io);
-		if (ret) {
-			dev_err(&spi->dev, "regulator vdd_io enable fail: %d\n",
-				ret);
-			goto err_reg_io;
-		}
+		goto err_reg_io;
+	}
+
+	ret = regulator_enable(ks->vdd_io);
+	if (ret) {
+		dev_err(&spi->dev, "regulator vdd_io enable fail: %d\n",
+			ret);
+		goto err_reg_io;
 	}
 
-	ks->vdd_reg = devm_regulator_get_optional(&spi->dev, "vdd");
+	ks->vdd_reg = devm_regulator_get(&spi->dev, "vdd");
 	if (IS_ERR(ks->vdd_reg)) {
 		ret = PTR_ERR(ks->vdd_reg);
-		if (ret == -EPROBE_DEFER)
-			goto err_reg;
-	} else {
-		ret = regulator_enable(ks->vdd_reg);
-		if (ret) {
-			dev_err(&spi->dev, "regulator vdd enable fail: %d\n",
-				ret);
-			goto err_reg;
-		}
+		goto err_reg;
+	}
+
+	ret = regulator_enable(ks->vdd_reg);
+	if (ret) {
+		dev_err(&spi->dev, "regulator vdd enable fail: %d\n",
+			ret);
+		goto err_reg;
 	}
 
 	if (gpio_is_valid(gpio)) {
@@ -1572,11 +1570,9 @@ err_irq:
 	if (gpio_is_valid(gpio))
 		gpio_set_value(gpio, 0);
 err_id:
-	if (!IS_ERR(ks->vdd_reg))
-		regulator_disable(ks->vdd_reg);
+	regulator_disable(ks->vdd_reg);
 err_reg:
-	if (!IS_ERR(ks->vdd_io))
-		regulator_disable(ks->vdd_io);
+	regulator_disable(ks->vdd_io);
 err_reg_io:
 err_gpio:
 	free_netdev(ndev);
@@ -1594,10 +1590,8 @@ static int ks8851_remove(struct spi_device *spi)
 	free_irq(spi->irq, priv);
 	if (gpio_is_valid(priv->gpio))
 		gpio_set_value(priv->gpio, 0);
-	if (!IS_ERR(priv->vdd_reg))
-		regulator_disable(priv->vdd_reg);
-	if (!IS_ERR(priv->vdd_io))
-		regulator_disable(priv->vdd_io);
+	regulator_disable(priv->vdd_reg);
+	regulator_disable(priv->vdd_io);
 	free_netdev(priv->netdev);
 
 	return 0;
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation
