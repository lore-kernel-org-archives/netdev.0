From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/5] net: mvmdio: rename base register cookie from smireg to
 regs
Date: Tue, 29 Jan 2013 16:24:05 +0100
Message-ID: <1359473048-26551-3-git-send-email-florian@openwrt.org>
References: <1359473048-26551-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Andrew Lunn <andrew@lunn.ch>, Russell King <linux@arm.linux.org.uk>,
 Jason Cooper <jason@lakedaemon.net>, linux-doc@vger.kernel.org,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 devicetree-discuss@lists.ozlabs.org, linux-kernel@vger.kernel.org,
 Rob Herring <rob.herring@calxeda.com>,
 Grant Likely <grant.likely@secretlab.ca>, netdev@vger.kernel.org,
 Paul Mackerras <paulus@samba.org>, linux-arm-kernel@lists.infradead.org,
 Rob Landley <rob@landley.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 linuxppc-dev@lists.ozlabs.org, Florian Fainelli <florian@openwrt.org>,
 Lennert Buytenhek <buytenh@wantstofly.org>
To: davem@davemloft.net
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1359473048-26551-1-git-send-email-florian@openwrt.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This patch renames the base register cookie in the mvmdio drive from
"smireg" to "regs" since a subsequent patch is going to use an ioremap()
cookie whose size is larger than a single register of 4 bytes. No
functionnal code change introduced.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/marvell/mvmdio.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index be5c690..5ecda58 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -39,7 +39,7 @@
 
 struct orion_mdio_dev {
 	struct mutex lock;
-	void __iomem *smireg;
+	void __iomem *regs;
 };
 
 /* Wait for the SMI unit to be ready for another operation
@@ -52,7 +52,7 @@ static int orion_mdio_wait_ready(struct mii_bus *bus)
 
 	count = 0;
 	while (1) {
-		val = readl(dev->smireg);
+		val = readl(dev->regs);
 		if (!(val & MVMDIO_SMI_BUSY))
 			break;
 
@@ -87,12 +87,12 @@ static int orion_mdio_read(struct mii_bus *bus, int mii_id,
 	writel(((mii_id << MVMDIO_SMI_PHY_ADDR_SHIFT) |
 		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
 		MVMDIO_SMI_READ_OPERATION),
-	       dev->smireg);
+	       dev->regs);
 
 	/* Wait for the value to become available */
 	count = 0;
 	while (1) {
-		val = readl(dev->smireg);
+		val = readl(dev->regs);
 		if (val & MVMDIO_SMI_READ_VALID)
 			break;
 
@@ -129,7 +129,7 @@ static int orion_mdio_write(struct mii_bus *bus, int mii_id,
 		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
 		MVMDIO_SMI_WRITE_OPERATION            |
 		(value << MVMDIO_SMI_DATA_SHIFT)),
-	       dev->smireg);
+	       dev->regs);
 
 	mutex_unlock(&dev->lock);
 
@@ -173,8 +173,8 @@ static int orion_mdio_probe(struct platform_device *pdev)
 		bus->irq[i] = PHY_POLL;
 
 	dev = bus->priv;
-	dev->smireg = of_iomap(pdev->dev.of_node, 0);
-	if (!dev->smireg) {
+	dev->regs = of_iomap(pdev->dev.of_node, 0);
+	if (!dev->regs) {
 		dev_err(&pdev->dev, "No SMI register address given in DT\n");
 		kfree(bus->irq);
 		mdiobus_free(bus);
@@ -186,7 +186,7 @@ static int orion_mdio_probe(struct platform_device *pdev)
 	ret = of_mdiobus_register(bus, np);
 	if (ret < 0) {
 		dev_err(&pdev->dev, "Cannot register MDIO bus (%d)\n", ret);
-		iounmap(dev->smireg);
+		iounmap(dev->regs);
 		kfree(bus->irq);
 		mdiobus_free(bus);
 		return ret;
@@ -205,7 +205,7 @@ static int orion_mdio_remove(struct platform_device *pdev)
 	mdiobus_unregister(bus);
 	kfree(bus->irq);
 	mdiobus_free(bus);
-	iounmap(dev->smireg);
+	iounmap(dev->regs);
 	return 0;
 }
 
-- 
1.7.10.4
