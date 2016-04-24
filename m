From: Michael Heimpold <mhei@heimpold.de>
Subject: [PATCH v2 net-next] net: ethernet: enc28j60: add device tree support
Date: Sun, 24 Apr 2016 23:28:03 +0200
Message-ID: <1461533283-24852-1-git-send-email-mhei@heimpold.de>
References: <31567588.rB9VrggOb6@wuerfel>
Cc: Michael Heimpold <mhei@heimpold.de>
To: Jonathan Cameron <jic23@kernel.org>,
	"Andrew F . Davis" <afd@ti.com>, Mark Brown <broonie@kernel.org>,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.219]:39594 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753124AbcDXV2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 17:28:36 -0400
In-Reply-To: <31567588.rB9VrggOb6@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch adds the required match table for device tree support
(and while at, fix the indent). It's also possible to specify the
MAC address in the DT blob.

Also add the corresponding binding documentation file.

Signed-off-by: Michael Heimpold <mhei@heimpold.de>
---

v2: * took care of Arnd Bergmann's review comments
      - allow to specify MAC address via DT
      - unconditionally define DT id table
    * increased the driver version minor number
    * driver author's email address bounces, removed from address list

 .../devicetree/bindings/net/microchip-enc28j60.txt | 50 ++++++++++++++++++++++
 drivers/net/ethernet/microchip/enc28j60.c          | 20 +++++++--
 2 files changed, 67 insertions(+), 3 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/microchip-enc28j60.txt

diff --git a/Documentation/devicetree/bindings/net/microchip-enc28j60.txt b/Documentation/devicetree/bindings/net/microchip-enc28j60.txt
new file mode 100644
index 0000000..847a97b
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/microchip-enc28j60.txt
@@ -0,0 +1,50 @@
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
+- local-mac-address: See ethernet.txt in the same directory.
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
index b723622..7066954 100644
--- a/drivers/net/ethernet/microchip/enc28j60.c
+++ b/drivers/net/ethernet/microchip/enc28j60.c
@@ -28,11 +28,12 @@
 #include <linux/skbuff.h>
 #include <linux/delay.h>
 #include <linux/spi/spi.h>
+#include <linux/of_net.h>
 
 #include "enc28j60_hw.h"
 
 #define DRV_NAME	"enc28j60"
-#define DRV_VERSION	"1.01"
+#define DRV_VERSION	"1.02"
 
 #define SPI_OPLEN	1
 
@@ -1548,6 +1549,7 @@ static int enc28j60_probe(struct spi_device *spi)
 {
 	struct net_device *dev;
 	struct enc28j60_net *priv;
+	const void *macaddr;
 	int ret = 0;
 
 	if (netif_msg_drv(&debug))
@@ -1579,7 +1581,12 @@ static int enc28j60_probe(struct spi_device *spi)
 		ret = -EIO;
 		goto error_irq;
 	}
-	eth_hw_addr_random(dev);
+
+	macaddr = of_get_mac_address(spi->dev.of_node);
+	if (macaddr)
+		ether_addr_copy(dev->dev_addr, macaddr);
+	else
+		eth_hw_addr_random(dev);
 	enc28j60_set_hw_macaddr(dev);
 
 	/* Board setup must set the relevant edge trigger type;
@@ -1634,9 +1641,16 @@ static int enc28j60_remove(struct spi_device *spi)
 	return 0;
 }
 
+static const struct of_device_id enc28j60_dt_ids[] = {
+	{ .compatible = "microchip,enc28j60" },
+	{ /* sentinel */ }
+};
+MODULE_DEVICE_TABLE(of, enc28j60_dt_ids);
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
