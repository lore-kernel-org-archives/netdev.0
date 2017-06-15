From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next v5 05/11] net: mvmdio: introduce an ops structure
Date: Thu, 15 Jun 2017 16:43:20 +0200
Message-ID: <20170615144326.24463-6-antoine.tenart@free-electrons.com>
References: <20170615144326.24463-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:34826 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752602AbdFOOoE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 10:44:04 -0400
In-Reply-To: <20170615144326.24463-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce an ops structure to add an indirection on the is_done
function, as this is needed to add the xMDIO support later.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/marvell/mvmdio.c | 30 +++++++++++++++++++-----------
 1 file changed, 19 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index eab625752b12..2a8efc77f5fe 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -62,14 +62,14 @@ struct orion_mdio_dev {
 	wait_queue_head_t smi_busy_wait;
 };
 
-static int orion_mdio_smi_is_done(struct orion_mdio_dev *dev)
-{
-	return !(readl(dev->regs) & MVMDIO_SMI_BUSY);
-}
+struct orion_mdio_ops {
+	int (*is_done)(struct orion_mdio_dev *);
+};
 
 /* Wait for the SMI unit to be ready for another operation
  */
-static int orion_mdio_wait_ready(struct mii_bus *bus)
+static int orion_mdio_wait_ready(const struct orion_mdio_ops *ops,
+				 struct mii_bus *bus)
 {
 	struct orion_mdio_dev *dev = bus->priv;
 	unsigned long timeout = usecs_to_jiffies(MVMDIO_SMI_TIMEOUT);
@@ -77,7 +77,7 @@ static int orion_mdio_wait_ready(struct mii_bus *bus)
 	int timedout = 0;
 
 	while (1) {
-	        if (orion_mdio_smi_is_done(dev))
+	        if (ops->is_done(dev))
 			return 0;
 	        else if (timedout)
 			break;
@@ -96,8 +96,7 @@ static int orion_mdio_wait_ready(struct mii_bus *bus)
 			if (timeout < 2)
 				timeout = 2;
 			wait_event_timeout(dev->smi_busy_wait,
-				           orion_mdio_smi_is_done(dev),
-				           timeout);
+				           ops->is_done(dev), timeout);
 
 			++timedout;
 	        }
@@ -107,6 +106,15 @@ static int orion_mdio_wait_ready(struct mii_bus *bus)
 	return  -ETIMEDOUT;
 }
 
+static int orion_mdio_smi_is_done(struct orion_mdio_dev *dev)
+{
+	return !(readl(dev->regs) & MVMDIO_SMI_BUSY);
+}
+
+static const struct orion_mdio_ops orion_mdio_smi_ops = {
+	.is_done = orion_mdio_smi_is_done,
+};
+
 static int orion_mdio_read(struct mii_bus *bus, int mii_id,
 			   int regnum)
 {
@@ -114,7 +122,7 @@ static int orion_mdio_read(struct mii_bus *bus, int mii_id,
 	u32 val;
 	int ret;
 
-	ret = orion_mdio_wait_ready(bus);
+	ret = orion_mdio_wait_ready(&orion_mdio_smi_ops, bus);
 	if (ret < 0)
 		goto out;
 
@@ -123,7 +131,7 @@ static int orion_mdio_read(struct mii_bus *bus, int mii_id,
 		MVMDIO_SMI_READ_OPERATION),
 	       dev->regs);
 
-	ret = orion_mdio_wait_ready(bus);
+	ret = orion_mdio_wait_ready(&orion_mdio_smi_ops, bus);
 	if (ret < 0)
 		goto out;
 
@@ -145,7 +153,7 @@ static int orion_mdio_write(struct mii_bus *bus, int mii_id,
 	struct orion_mdio_dev *dev = bus->priv;
 	int ret;
 
-	ret = orion_mdio_wait_ready(bus);
+	ret = orion_mdio_wait_ready(&orion_mdio_smi_ops, bus);
 	if (ret < 0)
 		goto out;
 
-- 
2.9.4
