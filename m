From: Christoph Fritz <chf.fritz@googlemail.com>
Subject: [PATCH v2] can: sja1000: fix endian on arm
Date: Thu, 11 Apr 2013 20:44:44 +0200
Message-ID: <1365705884.4136.5.camel@mars>
References: <1365428932.5760.52.camel@lovely>
	 <5162CCB5.3000605@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Rob Herring <rob.herring@calxeda.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	linux-can@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andreas Larsson <andreas@gaisler.com>,
	"Hans J. Koch" <hjk@hansjkoch.de>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f42.google.com ([209.85.214.42]:34840 "EHLO
	mail-bk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932892Ab3DKSot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 14:44:49 -0400
In-Reply-To: <5162CCB5.3000605@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To get correct endian on arm cpus while reading device tree properties,
this patch replaces of_get_property() with of_property_read_u32().

Signed-off-by: Christoph Fritz <chf.fritz@googlemail.com>
---
 drivers/net/can/sja1000/sja1000_of_platform.c |   32 ++++++++++++-------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/can/sja1000/sja1000_of_platform.c b/drivers/net/can/sja1000/sja1000_of_platform.c
index 6433b81..dd8b031 100644
--- a/drivers/net/can/sja1000/sja1000_of_platform.c
+++ b/drivers/net/can/sja1000/sja1000_of_platform.c
@@ -96,8 +96,8 @@ static int sja1000_ofp_probe(struct platform_device *ofdev)
 	struct net_device *dev;
 	struct sja1000_priv *priv;
 	struct resource res;
-	const u32 *prop;
-	int err, irq, res_size, prop_size;
+	u32 prop;
+	int err, irq, res_size;
 	void __iomem *base;
 
 	err = of_address_to_resource(np, 0, &res);
@@ -138,27 +138,27 @@ static int sja1000_ofp_probe(struct platform_device *ofdev)
 	priv->read_reg = sja1000_ofp_read_reg;
 	priv->write_reg = sja1000_ofp_write_reg;
 
-	prop = of_get_property(np, "nxp,external-clock-frequency", &prop_size);
-	if (prop && (prop_size ==  sizeof(u32)))
-		priv->can.clock.freq = *prop / 2;
+	err = of_property_read_u32(np, "nxp,external-clock-frequency", &prop);
+	if (!err)
+		priv->can.clock.freq = prop / 2;
 	else
 		priv->can.clock.freq = SJA1000_OFP_CAN_CLOCK; /* default */
 
-	prop = of_get_property(np, "nxp,tx-output-mode", &prop_size);
-	if (prop && (prop_size == sizeof(u32)))
-		priv->ocr |= *prop & OCR_MODE_MASK;
+	err = of_property_read_u32(np, "nxp,tx-output-mode", &prop);
+	if (!err)
+		priv->ocr |= prop & OCR_MODE_MASK;
 	else
 		priv->ocr |= OCR_MODE_NORMAL; /* default */
 
-	prop = of_get_property(np, "nxp,tx-output-config", &prop_size);
-	if (prop && (prop_size == sizeof(u32)))
-		priv->ocr |= (*prop << OCR_TX_SHIFT) & OCR_TX_MASK;
+	err = of_property_read_u32(np, "nxp,tx-output-config", &prop);
+	if (!err)
+		priv->ocr |= (prop << OCR_TX_SHIFT) & OCR_TX_MASK;
 	else
 		priv->ocr |= OCR_TX0_PULLDOWN; /* default */
 
-	prop = of_get_property(np, "nxp,clock-out-frequency", &prop_size);
-	if (prop && (prop_size == sizeof(u32)) && *prop) {
-		u32 divider = priv->can.clock.freq * 2 / *prop;
+	err = of_property_read_u32(np, "nxp,clock-out-frequency", &prop);
+	if (!err) {
+		u32 divider = priv->can.clock.freq * 2 / prop;
 
 		if (divider > 1)
 			priv->cdr |= divider / 2 - 1;
@@ -168,8 +168,8 @@ static int sja1000_ofp_probe(struct platform_device *ofdev)
 		priv->cdr |= CDR_CLK_OFF; /* default */
 	}
 
-	prop = of_get_property(np, "nxp,no-comparator-bypass", NULL);
-	if (!prop)
+	err = of_property_read_u32(np, "nxp,no-comparator-bypass", &prop);
+	if (err)
 		priv->cdr |= CDR_CBP; /* default */
 
 	priv->irq_flags = IRQF_SHARED;
-- 
1.7.10.4
