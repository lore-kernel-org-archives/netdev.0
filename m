From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] phylib: Add support for the LXT973 phy.
Date: Wed, 2 Jun 2010 14:55:27 +0200
Message-ID: <20100602125527.GA20396@riccoc20.at.omicron.at>
References: <20100531130932.GA15845@riccoc20.at.omicron.at>
 <AANLkTilKJVZiKLRUlL7AeaqSnlAs2u5sTW7o2vfvEKns@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:38789 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757942Ab0FBMy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 08:54:59 -0400
Received: by fg-out-1718.google.com with SMTP id l26so1638994fgb.1
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 05:54:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <AANLkTilKJVZiKLRUlL7AeaqSnlAs2u5sTW7o2vfvEKns@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 01, 2010 at 05:39:22PM -0500, Andy Fleming wrote:
> That's a bit hacky.  There is a dev_flags field, which could be used
> for this.  Probably, we should add a more general way of saying what
> sort of port this is.  But don't use the presence and absence of
> "priv", as it could one day get used for a different purpose, and this
> seems like it would leave us open to strange bugs.

Okay, I changed it.

At first, I was worried about using 'dev_flags' because I couldn't
tell exactly who may write to this field. Looking at tg.c and
broadcom.c, it appears that the MAC drivers may also write this
field. In contrast, the 'priv' field is surely private.

> Also, is this erratum true for all lxt973 models, or is it fixed in
> some revisions?

The documentation http://www.cortina-systems.com/products/download/266
says, "Status: This erratum has been previously fixed." However, I
could not find a reference to when this was fixed.

Richard

Date: Wed, 2 Jun 2010 13:47:02 +0200
Subject: [PATCH] phylib: Add support for the LXT973 phy.

This patch implements a work around for Erratum 5, "3.3 V Fiber Speed
Selection." If the hardware wiring does not respect this erratum, then
fiber optic mode will not work properly.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/phy/lxt.c |   52 ++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 51 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/lxt.c b/drivers/net/phy/lxt.c
index 8ee929b..4f97fdc 100644
--- a/drivers/net/phy/lxt.c
+++ b/drivers/net/phy/lxt.c
@@ -53,6 +53,9 @@
 
 #define MII_LXT971_ISR		19  /* Interrupt Status Register */
 
+/* register definitions for the 973 */
+#define MII_LXT973_PCR 16 /* Port Configuration Register */
+#define PCR_FIBER_SELECT 1
 
 MODULE_DESCRIPTION("Intel LXT PHY driver");
 MODULE_AUTHOR("Andy Fleming");
@@ -119,6 +122,34 @@ static int lxt971_config_intr(struct phy_device *phydev)
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
+		phydev->dev_flags = PCR_FIBER_SELECT;
+	} else {
+		phydev->dev_flags = 0;
+	}
+	return 0;
+}
+
+static int lxt973_config_aneg(struct phy_device *phydev)
+{
+	/* Do nothing if port is in fiber mode. */
+	return PCR_FIBER_SELECT == phydev->dev_flags ?
+		0 : genphy_config_aneg(phydev);
+}
+
 static struct phy_driver lxt970_driver = {
 	.phy_id		= 0x78100000,
 	.name		= "LXT970",
@@ -146,6 +177,18 @@ static struct phy_driver lxt971_driver = {
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
+	.driver		= { .owner = THIS_MODULE,},
+};
+
 static int __init lxt_init(void)
 {
 	int ret;
@@ -157,9 +200,15 @@ static int __init lxt_init(void)
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
@@ -169,6 +218,7 @@ static void __exit lxt_exit(void)
 {
 	phy_driver_unregister(&lxt970_driver);
 	phy_driver_unregister(&lxt971_driver);
+	phy_driver_unregister(&lxt973_driver);
 }
 
 module_init(lxt_init);
-- 
1.6.3.3


