From: Heiko Schocher <hs@denx.de>
Subject: [PATCH] Make EN2 pin optional in the TRF7970A driver
Date: Tue,  7 Feb 2017 06:22:04 +0100
Message-ID: <1486444924-18444-1-git-send-email-hs@denx.de>
Cc: Guan Ben <ben.guan@cn.bosch.com>,
        Mark Jonas <mark.jonas@de.bosch.com>,
        Heiko Schocher <hs@denx.de>, devicetree@vger.kernel.org,
        linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
        Rob Herring <robh+dt@kernel.org>,
        Samuel Ortiz <sameo@linux.intel.com>,
        Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
        Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
        Mark Rutland <mark.rutland@arm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:35581 "EHLO
        mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752149AbdBGFWN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 00:22:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guan Ben <ben.guan@cn.bosch.com>

Make the EN2 pin optional. This is useful for boards,
which have this pin fix wired, for example to ground.

Signed-off-by: Guan Ben <ben.guan@cn.bosch.com>
Signed-off-by: Mark Jonas <mark.jonas@de.bosch.com>
Signed-off-by: Heiko Schocher <hs@denx.de>

---

 .../devicetree/bindings/net/nfc/trf7970a.txt       |  4 ++--
 drivers/nfc/trf7970a.c                             | 26 ++++++++++++----------
 2 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/nfc/trf7970a.txt b/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
index 32b35a0..5889a3d 100644
--- a/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
+++ b/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
@@ -5,8 +5,8 @@ Required properties:
 - spi-max-frequency: Maximum SPI frequency (<= 2000000).
 - interrupt-parent: phandle of parent interrupt handler.
 - interrupts: A single interrupt specifier.
-- ti,enable-gpios: Two GPIO entries used for 'EN' and 'EN2' pins on the
-  TRF7970A.
+- ti,enable-gpios: One or two GPIO entries used for 'EN' and 'EN2' pins on the
+  TRF7970A. EN2 is optional.
 - vin-supply: Regulator for supply voltage to VIN pin
 
 Optional SoC Specific Properties:
diff --git a/drivers/nfc/trf7970a.c b/drivers/nfc/trf7970a.c
index 26c9dbb..75079fb 100644
--- a/drivers/nfc/trf7970a.c
+++ b/drivers/nfc/trf7970a.c
@@ -1885,8 +1885,10 @@ static int trf7970a_power_up(struct trf7970a *trf)
 	usleep_range(5000, 6000);
 
 	if (!(trf->quirks & TRF7970A_QUIRK_EN2_MUST_STAY_LOW)) {
-		gpio_set_value(trf->en2_gpio, 1);
-		usleep_range(1000, 2000);
+		if (gpio_is_valid(trf->en2_gpio)) {
+			gpio_set_value(trf->en2_gpio, 1);
+			usleep_range(1000, 2000);
+		}
 	}
 
 	gpio_set_value(trf->en_gpio, 1);
@@ -1914,7 +1916,8 @@ static int trf7970a_power_down(struct trf7970a *trf)
 	}
 
 	gpio_set_value(trf->en_gpio, 0);
-	gpio_set_value(trf->en2_gpio, 0);
+	if (gpio_is_valid(trf->en2_gpio))
+		gpio_set_value(trf->en2_gpio, 0);
 
 	ret = regulator_disable(trf->regulator);
 	if (ret)
@@ -2032,15 +2035,14 @@ static int trf7970a_probe(struct spi_device *spi)
 
 	trf->en2_gpio = of_get_named_gpio(np, "ti,enable-gpios", 1);
 	if (!gpio_is_valid(trf->en2_gpio)) {
-		dev_err(trf->dev, "No EN2 GPIO property\n");
-		return trf->en2_gpio;
-	}
-
-	ret = devm_gpio_request_one(trf->dev, trf->en2_gpio,
-			GPIOF_DIR_OUT | GPIOF_INIT_LOW, "trf7970a EN2");
-	if (ret) {
-		dev_err(trf->dev, "Can't request EN2 GPIO: %d\n", ret);
-		return ret;
+		dev_info(trf->dev, "No EN2 GPIO property\n");
+	} else {
+		ret = devm_gpio_request_one(trf->dev, trf->en2_gpio,
+				GPIOF_DIR_OUT | GPIOF_INIT_LOW, "trf7970a EN2");
+		if (ret) {
+			dev_err(trf->dev, "Can't request EN2 GPIO: %d\n", ret);
+			return ret;
+		}
 	}
 
 	if (of_property_read_bool(np, "en2-rf-quirk"))
-- 
2.7.4
