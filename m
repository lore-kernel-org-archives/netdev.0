From: Greg Ungerer <gerg@snapgear.com>
Subject: [PATCH] net: allow FEC driver to use fixed PHY support
Date: Tue, 12 Oct 2010 17:03:05 +1000
Message-ID: <201010120703.o9C735Jd026818@goober.internal.moreton.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <gerg@uclinux.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dalsmrelay2.nai.com ([205.227.136.216]:64482 "HELO
	dalsmrelay2.nai.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751825Ab0JLHE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 03:04:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At least one board using the FEC driver does not have a conventional
PHY attached to it, it is directly connected to a somewhat simple
ethernet switch (the board is the SnapGear/LITE, and the attached
4-port ethernet switch is a RealTek RTL8305). This switch does not
present the usual register interface of a PHY, it presents nothing.
So a PHY scan will find nothing - it finds ID's of 0 for each PHY
on the attached MII bus.

After the FEC driver was changed to use phylib for supporting PHYs
it no longer works on this particular board/switch setup.

Add code support to use a fixed phy if no PHY is found on the MII bus.
This is based on the way the cpmac.c driver solved this same problem.

Signed-off-by: Greg Ungerer <gerg@uclinux.org>
---
 drivers/net/fec.c |   41 +++++++++++++++++++++++++++--------------
 1 files changed, 27 insertions(+), 14 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 768b840..f45dc63 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -678,24 +678,37 @@ static int fec_enet_mii_probe(struct net_device *dev)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
 	struct phy_device *phy_dev = NULL;
-	int ret;
+	char mdio_bus_id[MII_BUS_ID_SIZE];
+	char phy_name[MII_BUS_ID_SIZE + 3];
+	int phy_id;
 
 	fep->phy_dev = NULL;
 
-	/* find the first phy */
-	phy_dev = phy_find_first(fep->mii_bus);
-	if (!phy_dev) {
-		printk(KERN_ERR "%s: no PHY found\n", dev->name);
-		return -ENODEV;
+	/* check for attached phy */
+	for (phy_id = 0; (phy_id < PHY_MAX_ADDR); phy_id++) {
+		if ((fep->mii_bus->phy_mask & (1 << phy_id)))
+			continue;
+		if (fep->mii_bus->phy_map[phy_id] == NULL)
+			continue;
+		if (fep->mii_bus->phy_map[phy_id]->phy_id == 0)
+			continue;
+		strncpy(mdio_bus_id, fep->mii_bus->id, MII_BUS_ID_SIZE);
+		break;
 	}
 
-	/* attach the mac to the phy */
-	ret = phy_connect_direct(dev, phy_dev,
-			     &fec_enet_adjust_link, 0,
-			     PHY_INTERFACE_MODE_MII);
-	if (ret) {
-		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
-		return ret;
+	if (phy_id >= PHY_MAX_ADDR) {
+		printk(KERN_INFO "%s: no PHY, assuming direct connection "
+			"to switch\n", dev->name);
+		strncpy(mdio_bus_id, "0", MII_BUS_ID_SIZE);
+		phy_id = 0;
+	}
+
+	snprintf(phy_name, MII_BUS_ID_SIZE, PHY_ID_FMT, mdio_bus_id, phy_id);
+	phy_dev = phy_connect(dev, phy_name, &fec_enet_adjust_link, 0,
+		PHY_INTERFACE_MODE_MII);
+	if (IS_ERR(phy_dev)) {
+		printk(KERN_ERR "%s: could not attach to PHY\n", dev->name);
+		return PTR_ERR(phy_dev);
 	}
 
 	/* mask with MAC supported features */
@@ -738,7 +751,7 @@ static int fec_enet_mii_init(struct platform_device *pdev)
 	fep->mii_bus->read = fec_enet_mdio_read;
 	fep->mii_bus->write = fec_enet_mdio_write;
 	fep->mii_bus->reset = fec_enet_mdio_reset;
-	snprintf(fep->mii_bus->id, MII_BUS_ID_SIZE, "%x", pdev->id);
+	snprintf(fep->mii_bus->id, MII_BUS_ID_SIZE, "%x", pdev->id + 1);
 	fep->mii_bus->priv = fep;
 	fep->mii_bus->parent = &pdev->dev;
 
