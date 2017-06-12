From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH v3 7/9] net: mvmdio: add xmdio xsmi support
Date: Mon, 12 Jun 2017 11:42:18 +0100
Message-ID: <20170612104218.GA10223@n2100.armlinux.org.uk>
References: <20170612095745.11300-1-antoine.tenart@free-electrons.com>
 <20170612095745.11300-8-antoine.tenart@free-electrons.com>
 <20170612101739.GA4902@n2100.armlinux.org.uk>
 <20170612104126.GB4902@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: thomas.petazzoni@free-electrons.com, andrew@lunn.ch,
        f.fainelli@gmail.com, jason@lakedaemon.net, netdev@vger.kernel.org,
        nadavh@marvell.com, gregory.clement@free-electrons.com,
        mw@semihalf.com, davem@davemloft.net,
        linux-arm-kernel@lists.infradead.org,
        sebastian.hesselbarth@gmail.com
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:37074 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751718AbdFLKm3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 06:42:29 -0400
Content-Disposition: inline
In-Reply-To: <20170612104126.GB4902@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 1/2] net: mvmdio: remove duplicate locking

The MDIO layer already provides per-bus locking, so there's no need for
MDIO bus drivers to do their own internal locking.  Remove this.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/ethernet/marvell/mvmdio.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index c43747f0be0b..d6770217965e 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -23,7 +23,6 @@
 #include <linux/io.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/mutex.h>
 #include <linux/of_device.h>
 #include <linux/of_mdio.h>
 #include <linux/phy.h>
@@ -69,7 +68,6 @@ enum orion_mdio_bus_type {
 };
 
 struct orion_mdio_dev {
-	struct mutex lock;
 	void __iomem *regs;
 	struct clk *clk[3];
 	/*
@@ -254,8 +252,6 @@ static int orion_mdio_read(struct mii_bus *bus, int mii_id,
 	if (IS_ERR(ops))
 		return PTR_ERR(ops);
 
-	mutex_lock(&dev->lock);
-
 	ret = orion_mdio_wait_ready(ops, bus);
 	if (ret < 0)
 		goto out;
@@ -274,7 +270,6 @@ static int orion_mdio_read(struct mii_bus *bus, int mii_id,
 
 	ret = ops->read(dev);
 out:
-	mutex_unlock(&dev->lock);
 	return ret;
 }
 
@@ -289,8 +284,6 @@ static int orion_mdio_write(struct mii_bus *bus, int mii_id,
 	if (IS_ERR(ops))
 		return PTR_ERR(ops);
 
-	mutex_lock(&dev->lock);
-
 	ret = orion_mdio_wait_ready(ops, bus);
 	if (ret < 0)
 		goto out;
@@ -298,7 +291,6 @@ static int orion_mdio_write(struct mii_bus *bus, int mii_id,
 	ops->write(dev, mii_id, regnum, value);
 
 out:
-	mutex_unlock(&dev->lock);
 	return ret;
 }
 
@@ -382,8 +374,6 @@ static int orion_mdio_probe(struct platform_device *pdev)
 	dev->bus_type =
 		(enum orion_mdio_bus_type)of_device_get_match_data(&pdev->dev);
 
-	mutex_init(&dev->lock);
-
 	if (pdev->dev.of_node)
 		ret = of_mdiobus_register(bus, pdev->dev.of_node);
 	else
-- 
2.7.4


-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
