From: Leigh Brown <leigh@solinno.co.uk>
Subject: [PATCH v3 2/4] net: mvmdio: orion_mdio_ready: remove manual poll
Date: Tue, 29 Oct 2013 09:33:32 +0000
Message-ID: <14db4c777fb90fb5cb85ef074bab42b2a48a5c2e.1383038974.git.leigh@solinno.co.uk>
References: <cover.1383038973.git.leigh@solinno.co.uk>
Cc: Leigh Brown <leigh@solinno.co.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from doppler.thel33t.co.uk ([193.110.88.198]:58155 "EHLO
	doppler.thel33t.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753889Ab3J2JeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 05:34:02 -0400
In-Reply-To: <cover.1383038973.git.leigh@solinno.co.uk>
In-Reply-To: <cover.1383038973.git.leigh@solinno.co.uk>
References: <cover.1382637156.git.leigh@solinno.co.uk> <cover.1383038973.git.leigh@solinno.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace manual poll of MVMDIO_SMI_READ_VALID with a call to
orion_mdio_wait_ready.  This ensures a consistent timeout,
eliminates a busy loop, and allows for use of interrupts on
systems that support them.

Signed-off-by: Leigh Brown <leigh@solinno.co.uk>
---
 drivers/net/ethernet/marvell/mvmdio.c | 34 +++++++++++++---------------------
 1 file changed, 13 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 971a4c1..e3898b3 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -110,43 +110,35 @@ static int orion_mdio_read(struct mii_bus *bus, int mii_id,
 			   int regnum)
 {
 	struct orion_mdio_dev *dev = bus->priv;
-	int count;
 	u32 val;
 	int ret;
 
 	mutex_lock(&dev->lock);
 
 	ret = orion_mdio_wait_ready(bus);
-	if (ret < 0) {
-		mutex_unlock(&dev->lock);
-		return ret;
-	}
+	if (ret < 0)
+		goto out;
 
 	writel(((mii_id << MVMDIO_SMI_PHY_ADDR_SHIFT) |
 		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
 		MVMDIO_SMI_READ_OPERATION),
 	       dev->regs);
 
-	/* Wait for the value to become available */
-	count = 0;
-	while (1) {
-		val = readl(dev->regs);
-		if (val & MVMDIO_SMI_READ_VALID)
-			break;
-
-		if (count > 100) {
-			dev_err(bus->parent, "Timeout when reading PHY\n");
-			mutex_unlock(&dev->lock);
-			return -ETIMEDOUT;
-		}
+	ret = orion_mdio_wait_ready(bus);
+	if (ret < 0)
+		goto out;
 
-		udelay(10);
-		count++;
+	val = readl(dev->regs);
+	if (!(val & MVMDIO_SMI_READ_VALID)) {
+		dev_err(bus->parent, "SMI bus read not valid\n");
+		ret = -ENODEV;
+		goto out;
 	}
 
+	ret = val & 0xFFFF;
+out:
 	mutex_unlock(&dev->lock);
-
-	return val & 0xFFFF;
+	return ret;
 }
 
 static int orion_mdio_write(struct mii_bus *bus, int mii_id,
-- 
1.8.4.rc3
