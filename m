From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH] [NET] phy/broadcom: add support for BCM5481 PHY
Date: Tue, 4 Mar 2008 19:41:32 +0300
Message-ID: <20080304164132.GA16552@localhost.localdomain>
References: <20080203185804.GA30342@localhost.localdomain> <47A99DA0.3040505@pobox.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: "Maciej W. Rozycki" <macro@linux-mips.org>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:4540 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754066AbYCDQlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 11:41:35 -0500
Content-Disposition: inline
In-Reply-To: <47A99DA0.3040505@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2008 at 06:44:32AM -0500, Jeff Garzik wrote:
> Anton Vorontsov wrote:
> >This patch adds support for BCM5481 PHY. Unfortunately it's hard to
> >get specifications for this PHY, so its special register 0x18 isn't
> >annotated properly (but we know it's used to set up the delays).
> >
> >I've kept the magic numbers, so we'll not forget to fix it at the
> >first opportunity, and will name that register and its bits correctly.
> >
> >Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
[...]
> >+static struct phy_driver bcm5481_driver = {
> >+	.phy_id		= 0x0143bca0,
> >+	.phy_id_mask	= 0xfffffff0,
[...]
> applied

:-) You applied "PHYLIB: Add BCM5482 PHY support", but my
patch is for another PHY -- BCM5481. Here is another try,
rebased on top of previous commit:

- - - -
From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: phylib, broadcom: add support for BCM5481 PHY

This patch adds support for BCM5481 PHY. Unfortunately it's hard to
get specifications for this PHY, so its special register 0x18 isn't
annotated properly (but we know it's used to set up the delays).

I've kept the magic numbers, so we'll not forget to fix it at the
first opportunity, and will name that register and its bits correctly.

p.s. also fixed the line with broken indention, introduced by
commit 03157ac31eb4a8883382a212b161d2e6c5059fbf
    PHYLIB: Add BCM5482 PHY support

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/phy/broadcom.c |   57 +++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 56 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 5b80358..f5310ed 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -99,6 +99,41 @@ static int bcm54xx_config_intr(struct phy_device *phydev)
 	return err;
 }
 
+static int bcm5481_config_aneg(struct phy_device *phydev)
+{
+	int ret;
+
+	/* Aneg firsly. */
+	ret = genphy_config_aneg(phydev);
+
+	/* Then we can set up the delay. */
+	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID) {
+		u16 reg;
+
+		/*
+		 * There is no BCM5481 specification available, so down
+		 * here is everything we know about "register 0x18". This
+		 * at least helps BCM5481 to successfuly receive packets
+		 * on MPC8360E-RDK board. Peter Barada <peterb@logicpd.com>
+		 * says: "This sets delay between the RXD and RXC signals
+		 * instead of using trace lengths to achieve timing".
+		 */
+
+		/* Set RDX clk delay. */
+		reg = 0x7 | (0x7 << 12);
+		phy_write(phydev, 0x18, reg);
+
+		reg = phy_read(phydev, 0x18);
+		/* Set RDX-RXC skew. */
+		reg |= (1 << 8);
+		/* Write bits 14:0. */
+		reg |= (1 << 15);
+		phy_write(phydev, 0x18, reg);
+	}
+
+	return ret;
+}
+
 static struct phy_driver bcm5411_driver = {
 	.phy_id		= 0x00206070,
 	.phy_id_mask	= 0xfffffff0,
@@ -141,8 +176,22 @@ static struct phy_driver bcm5461_driver = {
 	.driver 	= { .owner = THIS_MODULE },
 };
 
+static struct phy_driver bcm5481_driver = {
+	.phy_id		= 0x0143bca0,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Broadcom BCM5481",
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= bcm54xx_config_init,
+	.config_aneg	= bcm5481_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= bcm54xx_ack_interrupt,
+	.config_intr	= bcm54xx_config_intr,
+	.driver 	= { .owner = THIS_MODULE },
+};
+
 static struct phy_driver bcm5482_driver = {
-    .phy_id		= 0x0143bcb0,
+	.phy_id		= 0x0143bcb0,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5482",
 	.features	= PHY_GBIT_FEATURES,
@@ -168,12 +217,17 @@ static int __init broadcom_init(void)
 	ret = phy_driver_register(&bcm5461_driver);
 	if (ret)
 		goto out_5461;
+	ret = phy_driver_register(&bcm5481_driver);
+	if (ret)
+		goto out_5481;
 	ret = phy_driver_register(&bcm5482_driver);
 	if (ret)
 		goto out_5482;
 	return ret;
 
 out_5482:
+	phy_driver_unregister(&bcm5481_driver);
+out_5481:
 	phy_driver_unregister(&bcm5461_driver);
 out_5461:
 	phy_driver_unregister(&bcm5421_driver);
@@ -186,6 +240,7 @@ out_5411:
 static void __exit broadcom_exit(void)
 {
 	phy_driver_unregister(&bcm5482_driver);
+	phy_driver_unregister(&bcm5481_driver);
 	phy_driver_unregister(&bcm5461_driver);
 	phy_driver_unregister(&bcm5421_driver);
 	phy_driver_unregister(&bcm5411_driver);
-- 
1.5.2.2

