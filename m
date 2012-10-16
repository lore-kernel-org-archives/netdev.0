From: Michal Vanka <mv@vanka.net>
Subject: [PATCH] Devicetree support for enc28j60 SPI Ethernet chip
Date: Tue, 16 Oct 2012 18:50:00 +0200
Message-ID: <507D9038.9080408@vanka.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lanconelli.claudio@eptar.com, devicetree-discuss@lists.ozlabs.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from email2.cablenet.cz ([81.200.48.21]:38937 "EHLO
	email2.cablenet.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753391Ab2JPQ6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 12:58:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
the following patch adds generic openfirmware/devicetree support to 
enc28j60 driver.

It also adds support for custom hardware based (FPGA) "interrupt line 
deasserter" for processors with level triggered interrupts
(for example Altera Nios2), as the enc28j60 works only with
processors with edge triggered interrupt.

The patch was tested on custom Altera Nios2 system.

Signed-off-by: Michal Vanka <mv@vanka.net>

diff -uprN 
a/Documentation/devicetree/bindings/net/microchip-enc28j60.txt 
b/Documentation/devicetree/bindings/net/microchip-enc28j60.txt
--- a/Documentation/devicetree/bindings/net/microchip-enc28j60.txt 
1969-12-31 19:00:00.000000000 -0500
+++ b/Documentation/devicetree/bindings/net/microchip-enc28j60.txt 
2011-10-16 11:38:33.000000000 -0400
@@ -0,0 +1,30 @@
+* Microchip enc28j60 Ethernet
+
+Required properties:
+- compatible : Should be "microchip,enc28j60"
+- interrupts : Should contain 1 interrupt.
+- reg : Should be 0
+
+Optional properties:
+- interrupt_deassert_reg : should contain address of additional (FPGA)
+  interrupt deassert hardware for processors with level triggered 
interrupts
+
+
+Example (for enc28j60 under opencores tinyspi controller):
+
+tiny_spi_1: spi@0x2160 {
+	compatible = "opencores,tiny-spi-1.0", "opencores,tiny-spi-rtlsvn2";
+	reg = < 0x00002160 0x00000020 >;
+	interrupt-parent = < &cpu >;
+	interrupts = < 2 >;
+	clock-frequency = < 100000000 >;
+	baud-width = < 8 >;	/* BAUD_WIDTH type NUMBER */
+	gpios = < &spi1_cs 0 0 >;
+	ethernet: enc28j60@0 {
+		compatible = "microchip,enc28j60";
+		spi-max-frequency = < 20000000 >;
+		reg = < 0 >;
+		interrupts = < 4 >;
+		interrupt_deassert_reg = < 0x00003000 >;
+	};
+}; //end spi@0x2160 (tiny_spi_1)
diff -uprN a/drivers/net/ethernet/microchip/enc28j60.c 
b/drivers/net/ethernet/microchip/enc28j60.c
--- a/drivers/net/ethernet/microchip/enc28j60.c	2011-10-02 
07:31:43.000000000 -0400
+++ b/drivers/net/ethernet/microchip/enc28j60.c	2011-10-16 
11:36:44.000000000 -0400
@@ -32,7 +32,7 @@
  #include "enc28j60_hw.h"

  #define DRV_NAME	"enc28j60"
-#define DRV_VERSION	"1.01"
+#define DRV_VERSION	"1.02"

  #define SPI_OPLEN	1

@@ -73,6 +73,7 @@ struct enc28j60_net {
  	int rxfilter;
  	u32 msg_enable;
  	u8 spi_transfer_buf[SPI_TRANSFER_BUF_LEN];
+	u8 *interrupt_deassert_reg;
  };

  /* use ethtool to change the level for any given device */
@@ -1320,6 +1321,10 @@ static irqreturn_t enc28j60_irq(int irq,
  	 * Remember that we access enc28j60 registers through SPI bus
  	 * via spi_sync() call.
  	 */
+
+	if (priv->interrupt_deassert_reg)
+		writeb(1, priv->interrupt_deassert_reg);
+
  	schedule_work(&priv->irq_work);

  	return IRQ_HANDLED;
@@ -1541,6 +1546,37 @@ static const struct net_device_ops enc28
  	.ndo_validate_addr	= eth_validate_addr,
  };

+#ifdef CONFIG_OF
+#include <linux/of.h>
+#include <linux/ioport.h>
+#include <linux/io.h>
+
+static int __devinit enc28j60_of_probe(struct spi_device *spi,
+					struct enc28j60_net *priv)
+{
+	u8 *reg;
+	const __be32 *prop;
+	int len;
+
+	if (!of_device_is_available(spi->dev.of_node))
+		return -ENODEV;
+
+	prop = of_get_property(spi->dev.of_node,
+					"interrupt_deassert_reg", &len);
+
+	if (prop && len >= sizeof(__be32))
+		reg = be32_to_cpup(prop);
+	else
+		return -ENODEV;
+
+	if (!devm_request_mem_region(&spi->dev, reg, 4, DRV_NAME))
+		return -ENOMEM;
+
+	priv->interrupt_deassert_reg = devm_ioremap_nocache(&spi->dev, reg, 4);
+	return 0;
+}
+#endif
+
  static int __devinit enc28j60_probe(struct spi_device *spi)
  {
  	struct net_device *dev;
@@ -1569,6 +1605,10 @@ static int __devinit enc28j60_probe(stru
  	INIT_WORK(&priv->restart_work, enc28j60_restart_work_handler);
  	dev_set_drvdata(&spi->dev, priv);	/* spi to priv reference */
  	SET_NETDEV_DEV(dev, &spi->dev);
+	priv->interrupt_deassert_reg = 0;
+#ifdef CONFIG_OF
+	enc28j60_of_probe(spi, priv);
+#endif

  	if (!enc28j60_chipset_init(dev)) {
  		if (netif_msg_probe(priv))
@@ -1631,10 +1671,20 @@ static int __devexit enc28j60_remove(str
  	return 0;
  }

+#ifdef CONFIG_OF
+static const struct of_device_id enc28j60_dt_ids[] = {
+	{ .compatible = "microchip,enc28j60", },
+	{ /* sentinel */ }
+};
+#else
+#define enc28j60_dt_ids NULL
+#endif
+
  static struct spi_driver enc28j60_driver = {
  	.driver = {
  		   .name = DRV_NAME,
  		   .owner = THIS_MODULE,
+		   .of_match_table = enc28j60_dt_ids,
  	 },
  	.probe = enc28j60_probe,
  	.remove = __devexit_p(enc28j60_remove),
