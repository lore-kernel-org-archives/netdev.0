From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH v2 4/8] net: mvmdio: move the read valid check into its own function
Date: Thu,  8 Jun 2017 11:26:49 +0200
Message-ID: <20170608092653.25221-5-antoine.tenart@free-electrons.com>
References: <20170608092653.25221-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:48814 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdFHKAW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 06:00:22 -0400
In-Reply-To: <20170608092653.25221-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the read valid check in its own function. This is needed as a
requirement to factorize the driver to add the xMDIO support in the
future.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvmdio.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 96af8d57d9e5..6cbdb221c1ab 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -69,6 +69,11 @@ static int orion_mdio_smi_is_done(struct orion_mdio_dev *dev)
 	return !(readl(dev->regs) & MVMDIO_SMI_BUSY);
 }
 
+static int orion_mdio_smi_is_read_valid(struct orion_mdio_dev *dev)
+{
+	return readl(dev->regs) & MVMDIO_SMI_READ_VALID;
+}
+
 /* Wait for the SMI unit to be ready for another operation
  */
 static int orion_mdio_wait_ready(struct mii_bus *bus)
@@ -113,7 +118,6 @@ static int orion_mdio_read(struct mii_bus *bus, int mii_id,
 			   int regnum)
 {
 	struct orion_mdio_dev *dev = bus->priv;
-	u32 val;
 	int ret;
 
 	mutex_lock(&dev->lock);
@@ -131,14 +135,13 @@ static int orion_mdio_read(struct mii_bus *bus, int mii_id,
 	if (ret < 0)
 		goto out;
 
-	val = readl(dev->regs);
-	if (!(val & MVMDIO_SMI_READ_VALID)) {
+	if (!orion_mdio_smi_is_read_valid(dev)) {
 		dev_err(bus->parent, "SMI bus read not valid\n");
 		ret = -ENODEV;
 		goto out;
 	}
 
-	ret = val & GENMASK(15,0);
+	ret = readl(dev->regs) & GENMASK(15,0);
 out:
 	mutex_unlock(&dev->lock);
 	return ret;
-- 
2.9.4
