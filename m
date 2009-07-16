From: Wolfgang Denk <wd@denx.de>
Subject: [PATCH 2/2 v2] MPC52xx FEC: be more conservative when setting MII_SPEED register
Date: Thu, 16 Jul 2009 23:42:26 +0200
Message-ID: <1247780546-4426-2-git-send-email-wd@denx.de>
References: <1247671133-12148-1-git-send-email-wd@denx.de>
Cc: Wolfgang Denk <wd@denx.de>,
	Grant Likely <grant.likely@secretlab.ca>,
	Kumar Gala <galak@kernel.crashing.org>,
	<netdev@vger.kernel.org>
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:42896 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932906AbZGPVm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 17:42:29 -0400
In-Reply-To: <1247671133-12148-1-git-send-email-wd@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds error checking and prevents clobbering unrelated bits
(reserved bits or the DIS_PREAMBLE bit) when writing the MII_SPEED
register on MPC52xx systems.

Signed-off-by: Wolfgang Denk <wd@denx.de>
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: Kumar Gala <galak@kernel.crashing.org>
Cc: <netdev@vger.kernel.org>
---
 drivers/net/fec_mpc52xx.c     |    2 +-
 drivers/net/fec_mpc52xx_phy.c |   21 ++++++++++++++++++---
 2 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index cc78633..b69d440 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -639,7 +639,7 @@ static void mpc52xx_fec_hw_init(struct net_device *dev)
 	/* set phy speed.
 	 * this can't be done in phy driver, since it needs to be called
 	 * before fec stuff (even on resume) */
-	out_be32(&fec->mii_speed, priv->mdio_speed);
+	clrsetbits_be32(&fec->mii_speed, 0x7E, priv->mdio_speed);
 }
 
 /**
diff --git a/drivers/net/fec_mpc52xx_phy.c b/drivers/net/fec_mpc52xx_phy.c
index 31e6d62..4c33dc5 100644
--- a/drivers/net/fec_mpc52xx_phy.c
+++ b/drivers/net/fec_mpc52xx_phy.c
@@ -70,7 +70,7 @@ static int mpc52xx_fec_mdio_probe(struct of_device *of,
 	struct mpc52xx_fec_mdio_priv *priv;
 	struct resource res = {};
 	int err;
-	int i;
+	int i, clock, speed;
 
 	bus = mdiobus_alloc();
 	if (bus == NULL)
@@ -105,8 +105,23 @@ static int mpc52xx_fec_mdio_probe(struct of_device *of,
 	dev_set_drvdata(dev, bus);
 
 	/* set MII speed */
-	out_be32(&priv->regs->mii_speed,
-		((mpc5xxx_get_bus_frequency(of->node) >> 20) / 5) << 1);
+	clock = mpc5xxx_get_bus_frequency(of->node);
+	if (!clock) {
+		dev_err(&of->dev, "could not determine IPS/IPB clock\n");
+		goto out_unmap;
+	}
+
+	/* scale for a MII clock <= 2.5 MHz */
+	speed = (clock + 2499999) / 2500000;
+
+	/* only 6 bits (25:30) available for MII speed */
+	if (speed > 0x3F) {
+		speed = 0x3F;
+		dev_err(&of->dev, "MII clock (%d Hz) exceeds max (2.5 MHz)\n",
+			clock / speed);
+	}
+
+	clrsetbits_be32(&priv->regs->mii_speed, 0x7E, speed << 1);
 
 	err = of_mdiobus_register(bus, np);
 	if (err)
-- 
1.6.0.6

