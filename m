From: Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
Subject: [patch 1/2] spidernet: enable support for bcm5461 ethernet phy
Date: Thu, 4 May 2006 05:59:41 -0400
Message-ID: <200605041159.41470.Jens.Osterkamp@de.ibm.com>
References: <20060504155034.486042000@>
Reply-To: Jens.Osterkamp@de.ibm.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arndb@de.ibm.com, utz.bacher@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:37505 "EHLO
	mtagate4.de.ibm.com") by vger.kernel.org with ESMTP
	id S1751471AbWEDJ7n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 05:59:43 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.6/8.13.6) with ESMTP id k449xglm096920
	for <netdev@vger.kernel.org>; Thu, 4 May 2006 09:59:42 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k44A0tYd118010
	for <netdev@vger.kernel.org>; Thu, 4 May 2006 12:00:55 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k449xfPH018108
	for <netdev@vger.kernel.org>; Thu, 4 May 2006 11:59:42 +0200
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jens Osterkamp <Jens.Osterkamp@de.ibm.com>

A newer board revision changed the type of ethernet phy.
Moreover, this generalizes the way that a phy gets switched
into fiber mode when autodetection is not available.

Signed-off-by: Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
Signed-off-by: Arnd Bergmann <arnd.bergmann@de.ibm.com>

---
Index: linus-2.6/drivers/net/sungem_phy.c
===================================================================
--- linus-2.6.orig/drivers/net/sungem_phy.c
+++ linus-2.6/drivers/net/sungem_phy.c
@@ -329,6 +329,30 @@ static int bcm5421_init(struct mii_phy* 
 	return 0;
 }
 
+static int bcm5421_enable_fiber(struct mii_phy* phy)
+{
+	/* enable fiber mode */
+	phy_write(phy, MII_NCONFIG, 0x9020);
+	/* LEDs active in both modes, autosense prio = fiber */
+	phy_write(phy, MII_NCONFIG, 0x945f);
+
+	/* switch off fibre autoneg */
+	phy_write(phy, MII_NCONFIG, 0xfc01);
+	phy_write(phy, 0x0b, 0x0004);
+
+	return 0;
+}
+
+static int bcm5461_enable_fiber(struct mii_phy* phy)
+{
+        phy_write(phy, MII_NCONFIG, 0xfc0c);
+        phy_write(phy, MII_BMCR, 0x4140);
+        phy_write(phy, MII_NCONFIG, 0xfc0b);
+	phy_write(phy, MII_BMCR, 0x0140);
+
+	return 0;
+}
+
 static int bcm54xx_setup_aneg(struct mii_phy *phy, u32 advertise)
 {
 	u16 ctl, adv;
@@ -762,6 +786,7 @@ static struct mii_phy_ops bcm5421_phy_op
 	.setup_forced	= bcm54xx_setup_forced,
 	.poll_link	= genmii_poll_link,
 	.read_link	= bcm54xx_read_link,
+	.enable_fiber   = bcm5421_enable_fiber,
 };
 
 static struct mii_phy_def bcm5421_phy_def = {
@@ -792,6 +817,25 @@ static struct mii_phy_def bcm5421k2_phy_
 	.ops		= &bcm5421k2_phy_ops
 };
 
+static struct mii_phy_ops bcm5461_phy_ops = {
+	.init		= bcm5421_init,
+	.suspend	= generic_suspend,
+	.setup_aneg	= bcm54xx_setup_aneg,
+	.setup_forced	= bcm54xx_setup_forced,
+	.poll_link	= genmii_poll_link,
+	.read_link	= bcm54xx_read_link,
+	.enable_fiber   = bcm5461_enable_fiber,
+};
+
+static struct mii_phy_def bcm5461_phy_def = {
+	.phy_id		= 0x002060c0,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "BCM5461",
+	.features	= MII_GBIT_FEATURES,
+	.magic_aneg	= 1,
+	.ops		= &bcm5461_phy_ops
+};
+
 /* Broadcom BCM 5462 built-in Vesta */
 static struct mii_phy_ops bcm5462V_phy_ops = {
 	.init		= bcm5421_init,
@@ -857,6 +901,7 @@ static struct mii_phy_def* mii_phy_table
 	&bcm5411_phy_def,
 	&bcm5421_phy_def,
 	&bcm5421k2_phy_def,
+	&bcm5461_phy_def,
 	&bcm5462V_phy_def,
 	&marvell_phy_def,
 	&genmii_phy_def,
Index: linus-2.6/drivers/net/spider_net.c
===================================================================
--- linus-2.6.orig/drivers/net/spider_net.c
+++ linus-2.6/drivers/net/spider_net.c
@@ -1792,15 +1792,7 @@ spider_net_setup_phy(struct spider_net_c
 	if (phy->def->ops->setup_forced)
 		phy->def->ops->setup_forced(phy, SPEED_1000, DUPLEX_FULL);
 
-	/* the following two writes could be moved to sungem_phy.c */
-	/* enable fiber mode */
-	spider_net_write_phy(card->netdev, 1, MII_NCONFIG, 0x9020);
-	/* LEDs active in both modes, autosense prio = fiber */
-	spider_net_write_phy(card->netdev, 1, MII_NCONFIG, 0x945f);
-
-	/* switch off fibre autoneg */
-	spider_net_write_phy(card->netdev, 1, MII_NCONFIG, 0xfc01);
-	spider_net_write_phy(card->netdev, 1, 0x0b, 0x0004);
+	phy->def->ops->enable_fiber(phy);
 
 	phy->def->ops->read_link(phy);
 	pr_info("Found %s with %i Mbps, %s-duplex.\n", phy->def->name,
Index: linus-2.6/drivers/net/sungem_phy.h
===================================================================
--- linus-2.6.orig/drivers/net/sungem_phy.h
+++ linus-2.6/drivers/net/sungem_phy.h
@@ -12,6 +12,7 @@ struct mii_phy_ops
 	int		(*setup_forced)(struct mii_phy *phy, int speed, int fd);
 	int		(*poll_link)(struct mii_phy *phy);
 	int		(*read_link)(struct mii_phy *phy);
+	int		(*enable_fiber)(struct mii_phy *phy);
 };
 
 /* Structure used to statically define an mii/gii based PHY */

--

