From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] phylib: Add support for the LXT973 phy.
Date: Sat, 5 Jun 2010 16:00:17 +0200
Message-ID: <20100605140017.GA2750@riccoc20.at.omicron.at>
References: <20100531130932.GA15845@riccoc20.at.omicron.at>
 <AANLkTilKJVZiKLRUlL7AeaqSnlAs2u5sTW7o2vfvEKns@mail.gmail.com>
 <20100602125527.GA20396@riccoc20.at.omicron.at>
 <20100602.065017.139108801.davem@davemloft.net>
 <AANLkTinR9_VoWX8zZu93MeohHvCbCy_P5XWHH3rxlPuH@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andy Fleming <afleming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:21366 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932660Ab0FEN7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 09:59:41 -0400
Received: by fg-out-1718.google.com with SMTP id d23so1150700fga.1
        for <netdev@vger.kernel.org>; Sat, 05 Jun 2010 06:59:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <AANLkTinR9_VoWX8zZu93MeohHvCbCy_P5XWHH3rxlPuH@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 02, 2010 at 02:32:11PM -0500, Andy Fleming wrote:
> Yeah, I was clearly not thinking clearly.  dev_flags will be
> overwritten, and is not meant for this.  I believe, what we should do
> is add a "port" field to the PHY device, and if PCR_FIBER_SELECT is
> set, then set the port field to PORT_FIBRE.  I'm not entirely clear on
> the semantics of that field in the ethtool cmd, but it seems like the
> right idea.

Here is another try. Is that more like it?

Richard


This patch implements a work around for Erratum 5, "3.3 V Fiber Speed
Selection." If the hardware wiring does not respect this erratum, then
fiber optic mode will not work properly.

As part of the fix, the patch introduces a new field 'port_flags' into
the 'struct phy_device'. This field allows phy drivers to describe
fixed attributes of the port. Only phy drivers should write this field.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/phy/lxt.c |   52 ++++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/phy.h   |    8 +++++++
 2 files changed, 59 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/lxt.c b/drivers/net/phy/lxt.c
index 8ee929b..ef4a320 100644
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
+		phydev->port_flags |= PHY_PORT_FIBER;
+	} else {
+		phydev->port_flags &= ~PHY_PORT_FIBER;
+	}
+	return 0;
+}
+
+static int lxt973_config_aneg(struct phy_device *phydev)
+{
+	/* Do nothing if port is in fiber mode. */
+	return phydev->port_flags & PHY_PORT_FIBER ?
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
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 1c75b6b..602228c 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -234,6 +234,11 @@ enum phy_state {
 	PHY_RESUMING
 };
 
+/*
+ * PHY_PORT_xxx: flags to describe the port's fixed attributes.
+ */
+#define PHY_PORT_FIBER 0x00000001 /* Port has a fiber optic transceiver */
+
 /* phy_device: An instance of a PHY
  *
  * drv: Pointer to the driver for this PHY instance
@@ -246,6 +251,7 @@ enum phy_state {
  * link_timeout: The number of timer firings to wait before the
  * giving up on the current attempt at acquiring a link
  * irq: IRQ number of the PHY's interrupt (-1 if none)
+ * port_flags: Bit field of PHY_PORT_xxx flags
  * phy_timer: The timer for handling the state machine
  * phy_queue: A work_queue for the interrupt
  * attached_dev: The attached enet driver's device instance ptr
@@ -314,6 +320,8 @@ struct phy_device {
 	 */
 	int irq;
 
+	int port_flags;
+
 	/* private data pointer */
 	/* For use by PHYs to maintain extra state */
 	void *priv;
-- 
1.6.3.3

