From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH v2 2/4] fs_enet: Revive fixed link support
Date: Fri, 17 Jul 2009 01:31:36 -0600
Message-ID: <20090717073136.15652.80098.stgit@localhost.localdomain>
References: <20090717065220.15652.93331.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: leoli@freescale.com
To: avorontsov@ru.mvista.com, davem@davemloft.net,
	afleming@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f197.google.com ([209.85.222.197]:52484 "EHLO
	mail-pz0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934154AbZGQHbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 03:31:39 -0400
Received: by pzk35 with SMTP id 35so477161pzk.33
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 00:31:39 -0700 (PDT)
In-Reply-To: <20090717065220.15652.93331.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>

Since commit aa73832c5a80d6c52c69b18af858d88fa595dd3c ("Rework
fs_enet driver to use of_mdio infrastructure") the fixed-link support
is broken in the fs_enet driver.

This patch fixes the support by removing a check for phy_node, and adding
a call to of_phy_connect_fixed_link().

Also set netdev parent device via SET_NETDEV_DEV() call, this is needed
so that OF MDIO core could find a node pointer for a device.

Plus, fix "if (IS_ERR(phydev))" check, in case of errors,
of_phy_connect() returns NULL, not ERR_PTR as phy_connect().

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/net/fs_enet/fs_enet-main.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)


diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index b892c3a..2bc2d2b 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -754,17 +754,16 @@ static int fs_init_phy(struct net_device *dev)
 	fep->oldlink = 0;
 	fep->oldspeed = 0;
 	fep->oldduplex = -1;
-	if(fep->fpi->phy_node)
-		phydev = of_phy_connect(dev, fep->fpi->phy_node,
-					&fs_adjust_link, 0,
-					PHY_INTERFACE_MODE_MII);
-	else {
-		printk("No phy bus ID specified in BSP code\n");
-		return -EINVAL;
+
+	phydev = of_phy_connect(dev, fep->fpi->phy_node, &fs_adjust_link, 0,
+				PHY_INTERFACE_MODE_MII);
+	if (!phydev) {
+		phydev = of_phy_connect_fixed_link(dev, &fs_adjust_link,
+						   PHY_INTERFACE_MODE_MII);
 	}
-	if (IS_ERR(phydev)) {
-		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
-		return PTR_ERR(phydev);
+	if (!phydev) {
+		dev_err(&dev->dev, "Could not attach to PHY\n");
+		return -ENODEV;
 	}
 
 	fep->phydev = phydev;
@@ -1005,6 +1004,7 @@ static int __devinit fs_enet_probe(struct of_device *ofdev,
 		goto out_free_fpi;
 	}
 
+	SET_NETDEV_DEV(ndev, &ofdev->dev);
 	dev_set_drvdata(&ofdev->dev, ndev);
 
 	fep = netdev_priv(ndev);

