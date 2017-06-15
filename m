From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next v5 04/11] net: mvmdio: remove duplicate locking
Date: Thu, 15 Jun 2017 16:43:19 +0200
Message-ID: <20170615144326.24463-5-antoine.tenart@free-electrons.com>
References: <20170615144326.24463-1-antoine.tenart@free-electrons.com>
Cc: Russell King <rmk+kernel@armlinux.org.uk>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:34818 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752594AbdFOOoE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 10:44:04 -0400
In-Reply-To: <20170615144326.24463-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk+kernel@armlinux.org.uk>

The MDIO layer already provides per-bus locking, so there's no need for
MDIO bus drivers to do their own internal locking.  Remove this.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/marvell/mvmdio.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 583f1c5753c2..eab625752b12 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -23,7 +23,6 @@
 #include <linux/io.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/mutex.h>
 #include <linux/of_mdio.h>
 #include <linux/phy.h>
 #include <linux/platform_device.h>
@@ -51,7 +50,6 @@
 #define MVMDIO_SMI_POLL_INTERVAL_MAX	55
 
 struct orion_mdio_dev {
-	struct mutex lock;
 	void __iomem *regs;
 	struct clk *clk[3];
 	/*
@@ -116,8 +114,6 @@ static int orion_mdio_read(struct mii_bus *bus, int mii_id,
 	u32 val;
 	int ret;
 
-	mutex_lock(&dev->lock);
-
 	ret = orion_mdio_wait_ready(bus);
 	if (ret < 0)
 		goto out;
@@ -140,7 +136,6 @@ static int orion_mdio_read(struct mii_bus *bus, int mii_id,
 
 	ret = val & GENMASK(15, 0);
 out:
-	mutex_unlock(&dev->lock);
 	return ret;
 }
 
@@ -150,8 +145,6 @@ static int orion_mdio_write(struct mii_bus *bus, int mii_id,
 	struct orion_mdio_dev *dev = bus->priv;
 	int ret;
 
-	mutex_lock(&dev->lock);
-
 	ret = orion_mdio_wait_ready(bus);
 	if (ret < 0)
 		goto out;
@@ -163,7 +156,6 @@ static int orion_mdio_write(struct mii_bus *bus, int mii_id,
 	       dev->regs);
 
 out:
-	mutex_unlock(&dev->lock);
 	return ret;
 }
 
@@ -244,8 +236,6 @@ static int orion_mdio_probe(struct platform_device *pdev)
 		return -EPROBE_DEFER;
 	}
 
-	mutex_init(&dev->lock);
-
 	if (pdev->dev.of_node)
 		ret = of_mdiobus_register(bus, pdev->dev.of_node);
 	else
-- 
2.9.4
