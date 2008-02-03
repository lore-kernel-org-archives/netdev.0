From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] [NET] phy/broadcom: add support for BCM5481 PHY
Date: Sun, 3 Feb 2008 21:58:04 +0300
Message-ID: <20080203185804.GA30342@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: "Maciej W. Rozycki" <macro@linux-mips.org>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:42432 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750813AbYBCS6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2008 13:58:16 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for BCM5481 PHY. Unfortunately it's hard to
get specifications for this PHY, so its special register 0x18 isn't
annotated properly (but we know it's used to set up the delays).

I've kept the magic numbers, so we'll not forget to fix it at the
first opportunity, and will name that register and its bits correctly.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/phy/broadcom.c |   54 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 54 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 29666c8..d15280e 100644
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
+	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) {
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
@@ -141,6 +176,20 @@ static struct phy_driver bcm5461_driver = {
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
 static int __init broadcom_init(void)
 {
 	int ret;
@@ -154,8 +203,13 @@ static int __init broadcom_init(void)
 	ret = phy_driver_register(&bcm5461_driver);
 	if (ret)
 		goto out_5461;
+	ret = phy_driver_register(&bcm5481_driver);
+	if (ret)
+		goto out_5481;
 	return ret;
 
+out_5481:
+	phy_driver_unregister(&bcm5461_driver);
 out_5461:
 	phy_driver_unregister(&bcm5421_driver);
 out_5421:
-- 
1.5.2.2
