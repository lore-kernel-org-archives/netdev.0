From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH] phylib: Add support for the LXT973 phy.
Date: Mon, 31 May 2010 15:09:32 +0200
Message-ID: <20100531130932.GA15845@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:22925 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241Ab0EaNJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 09:09:00 -0400
Received: by fg-out-1718.google.com with SMTP id l26so743369fgb.1
        for <netdev@vger.kernel.org>; Mon, 31 May 2010 06:08:59 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements a work around for Erratum 5, "3.3 V Fiber Speed
Selection." If the hardware wiring does not respect this erratum, then
fiber optic mode will not work properly.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/phy/lxt.c |   51 ++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 50 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/lxt.c b/drivers/net/phy/lxt.c
index 057ecaa..c3de582 100644
--- a/drivers/net/phy/lxt.c
+++ b/drivers/net/phy/lxt.c
@@ -53,6 +53,9 @@
 
 #define MII_LXT971_ISR		19  /* Interrupt Status Register */
 
+/* register definitions for the 973 */
+#define MII_LXT973_PCR 16 /* Port Configuration Register */
+#define PCR_FIBER_SELECT 1
 
 MODULE_DESCRIPTION("Intel LXT PHY driver");
 MODULE_AUTHOR("Andy Fleming");
@@ -119,6 +122,33 @@ static int lxt971_config_intr(struct phy_device *phydev)
 	return err;
 }
 
+static int lxt973_probe(struct phy_device *phydev)
+{
+	int val = phy_read(phydev, MII_LXT973_PCR);
+
+	if (val & PCR_FIBER_SELECT) {
+		/*
+		 * If fiber is selected, then the only correct setting
+		 * is 100Mbps, full duplex, and auto negotiation off.
+		 */
+		val = phy_read(phydev, MII_BMCR);
+		val |= (BMCR_SPEED100 | BMCR_FULLDPLX);
+		val &= ~BMCR_ANENABLE;
+		phy_write(phydev, MII_BMCR, val);
+		/* Remember that the port is in fiber mode. */
+		phydev->priv = lxt973_probe;
+	} else {
+		phydev->priv = NULL;
+	}
+	return 0;
+}
+
+static int lxt973_config_aneg(struct phy_device *phydev)
+{
+	/* Do nothing if port is in fiber mode. */
+	return phydev->priv ? 0 : genphy_config_aneg(phydev);
+}
+
 static struct phy_driver lxt970_driver = {
 	.phy_id		= 0x78100000,
 	.name		= "LXT970",
@@ -146,6 +176,18 @@ static struct phy_driver lxt971_driver = {
 	.driver 	= { .owner = THIS_MODULE,},
 };
 
+static struct phy_driver lxt973_driver = {
+	.phy_id		= 0x00137a10,
+	.name		= "LXT973",
+	.phy_id_mask	= 0xfffffff0,
+	.features	= PHY_BASIC_FEATURES,
+	.flags		= 0,
+	.probe		= lxt973_probe,
+	.config_aneg	= lxt973_config_aneg,
+	.read_status	= genphy_read_status,
+	.driver 	= { .owner = THIS_MODULE,},
+};
+
 static int __init lxt_init(void)
 {
 	int ret;
@@ -157,9 +199,15 @@ static int __init lxt_init(void)
 	ret = phy_driver_register(&lxt971_driver);
 	if (ret)
 		goto err2;
+
+	ret = phy_driver_register(&lxt973_driver);
+	if (ret)
+		goto err3;
 	return 0;
 
- err2:	
+ err3:
+	phy_driver_unregister(&lxt971_driver);
+ err2:
 	phy_driver_unregister(&lxt970_driver);
  err1:
 	return ret;
@@ -169,6 +217,7 @@ static void __exit lxt_exit(void)
 {
 	phy_driver_unregister(&lxt970_driver);
 	phy_driver_unregister(&lxt971_driver);
+	phy_driver_unregister(&lxt973_driver);
 }
 
 module_init(lxt_init);
-- 
1.6.3.3

