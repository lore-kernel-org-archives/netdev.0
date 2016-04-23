From: Michael Heimpold <mhei@heimpold.de>
Subject: [PATCH net-next 2/2] net: ethernet: enc28j60: add device tree support
Date: Sat, 23 Apr 2016 23:43:20 +0200
Message-ID: <1461447800-11381-3-git-send-email-mhei@heimpold.de>
References: <1461447800-11381-1-git-send-email-mhei@heimpold.de>
Cc: Michael Heimpold <mhei@heimpold.de>
To: Jonathan Cameron <jic23@kernel.org>,
	"Andrew F . Davis" <afd@ti.com>, Mark Brown <broonie@kernel.org>,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Claudio Lanconelli <lanconelli.claudio@eptar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.217]:39473 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455AbcDWVoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Apr 2016 17:44:15 -0400
In-Reply-To: <1461447800-11381-1-git-send-email-mhei@heimpold.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch adds the required match table for device tree support
(and while at, fix the indent).

Also add the corresponding binding documentation file.

Signed-off-by: Michael Heimpold <mhei@heimpold.de>
---
 .../devicetree/bindings/net/microchip-enc28j60.txt | 49 ++++++++++++++++++++++
 drivers/net/ethernet/microchip/enc28j60.c          | 13 +++++-
 2 files changed, 61 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/devicetree/bindings/net/microchip-enc28j60.txt

diff --git a/Documentation/devicetree/bindings/net/microchip-enc28j60.txt b/Documentation/devicetree/bindings/net/microchip-enc28j60.txt
new file mode 100644
index 0000000..c472427
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/microchip-enc28j60.txt
@@ -0,0 +1,49 @@
+* Microchip ENC28J60
+
+This is a standalone 10 MBit ethernet controller with SPI interface.
+
+For each device connected to a SPI bus, define a child node within
+the SPI master node.
+
+Required properties:
+- compatible: Should be "microchip,enc28j60"
+- reg: Specify the SPI chip select the ENC28J60 is wired to
+- interrupts: Specify the interrupt and interrupt type (usually falling edge)
+
+Optional properties:
+- interrupt-parent: Specify the pHandle of the source interrupt
+- spi-max-frequency: Maximum frequency of the SPI bus when accessing the ENC28J60.
+  According to the ENC28J80 datasheet, the chip allows a maximum of 20 MHz, however,
+  board designs may need to limit this value.
+
+
+Example (for NXP i.MX28 with pin control stuff for GPIO irq):
+
+        ssp2: ssp@80014000 {
+                compatible = "fsl,imx28-spi";
+                pinctrl-names = "default";
+                pinctrl-0 = <&spi2_pins_b &spi2_sck_cfg>;
+                status = "okay";
+
+                enc28j60: ethernet@0 {
+                        compatible = "microchip,enc28j60";
+                        pinctrl-names = "default";
+                        pinctrl-0 = <&enc28j60_pins>;
+                        reg = <0>;
+                        interrupt-parent = <&gpio3>;
+                        interrupts = <3 IRQ_TYPE_EDGE_FALLING>;
+                        spi-max-frequency = <12000000>;
+                };
+        };
+
+        pinctrl@80018000 {
+                enc28j60_pins: enc28j60_pins@0 {
+                        reg = <0>;
+                        fsl,pinmux-ids = <
+                                MX28_PAD_AUART0_RTS__GPIO_3_3    /* Interrupt */
+                        >;
+                        fsl,drive-strength = <MXS_DRIVE_4mA>;
+                        fsl,voltage = <MXS_VOLTAGE_HIGH>;
+                        fsl,pull-up = <MXS_PULL_DISABLE>;
+                };
+        };
diff --git a/drivers/net/ethernet/microchip/enc28j60.c b/drivers/net/ethernet/microchip/enc28j60.c
index b723622..49635d7 100644
--- a/drivers/net/ethernet/microchip/enc28j60.c
+++ b/drivers/net/ethernet/microchip/enc28j60.c
@@ -1634,9 +1634,20 @@ static int enc28j60_remove(struct spi_device *spi)
 	return 0;
 }
 
+#ifdef CONFIG_OF
+static const struct of_device_id enc28j60_dt_ids[] = {
+	{ .compatible = "microchip,enc28j60" },
+	{ /* sentinel */ }
+};
+MODULE_DEVICE_TABLE(of, enc28j60_dt_ids);
+#else
+#define enc28j60_dt_ids NULL
+#endif
+
 static struct spi_driver enc28j60_driver = {
 	.driver = {
-		   .name = DRV_NAME,
+		.name = DRV_NAME,
+		.of_match_table = enc28j60_dt_ids,
 	 },
 	.probe = enc28j60_probe,
 	.remove = enc28j60_remove,
-- 
2.5.0
