From: Roger Luethi <rl@hellgate.ch>
Subject: [2/9][PATCH 2.6] Nuke CanHaveMII and related code
Date: Wed, 2 Jun 2004 13:58:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040602115805.GA17418@k3.hellgate.ch>
References: <20040602115703.GA16079@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040602115703.GA16079@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

All Rhines can have a MII.

Signed-off-by: Roger Luethi <rl@hellgate.ch>

--- orig/drivers/net/via-rhine.c
+++ mod/drivers/net/via-rhine.c
@@ -375,7 +375,7 @@
 
 
 enum chip_capability_flags {
-	CanHaveMII=1, HasESIPhy=2, HasDavicomPhy=4,
+	HasESIPhy=2, HasDavicomPhy=4,
 	ReqTxAlign=0x10, HasWOL=0x20,
 };
 
@@ -391,13 +391,13 @@
 static struct rhine_chip_info rhine_chip_info[] __devinitdata =
 {
 	{ "VIA VT86C100A Rhine", RHINE_IOTYPE, 128,
-	  CanHaveMII | ReqTxAlign | HasDavicomPhy },
+	  ReqTxAlign | HasDavicomPhy },
 	{ "VIA VT6102 Rhine-II", RHINE_IOTYPE, 256,
-	  CanHaveMII | HasWOL },
+	  HasWOL },
 	{ "VIA VT6105 Rhine-III", RHINE_IOTYPE, 256,
-	  CanHaveMII | HasWOL },
+	  HasWOL },
 	{ "VIA VT6105M Rhine-III", RHINE_IOTYPE, 256,
-	  CanHaveMII | HasWOL },
+	  HasWOL },
 };
 
 static struct pci_device_id rhine_pci_tbl[] =
@@ -635,6 +635,7 @@
 	long memaddr;
 	int io_size;
 	int pci_flags;
+	int phy, phy_idx = 0;
 #ifdef USE_MMIO
 	long ioaddr0;
 #endif
@@ -830,32 +831,29 @@
 
 	pci_set_drvdata(pdev, dev);
 
-	if (rp->drv_flags & CanHaveMII) {
-		int phy, phy_idx = 0;
-		rp->phys[0] = 1;		/* Standard for this chip. */
-		for (phy = 1; phy < 32 && phy_idx < MAX_MII_CNT; phy++) {
-			int mii_status = mdio_read(dev, phy, 1);
-			if (mii_status != 0xffff && mii_status != 0x0000) {
-				rp->phys[phy_idx++] = phy;
-				rp->mii_if.advertising = mdio_read(dev, phy, 4);
-				printk(KERN_INFO "%s: MII PHY found at address "
-				       "%d, status 0x%4.4x advertising %4.4x "
-				       "Link %4.4x.\n", dev->name, phy,
-				       mii_status, rp->mii_if.advertising,
-				       mdio_read(dev, phy, 5));
-
-				/* set IFF_RUNNING */
-				if (mii_status & BMSR_LSTATUS)
-					netif_carrier_on(dev);
-				else
-					netif_carrier_off(dev);
+	rp->phys[0] = 1;		/* Standard for this chip. */
+	for (phy = 1; phy < 32 && phy_idx < MAX_MII_CNT; phy++) {
+		int mii_status = mdio_read(dev, phy, 1);
+		if (mii_status != 0xffff && mii_status != 0x0000) {
+			rp->phys[phy_idx++] = phy;
+			rp->mii_if.advertising = mdio_read(dev, phy, 4);
+			printk(KERN_INFO "%s: MII PHY found at address "
+			       "%d, status 0x%4.4x advertising %4.4x "
+			       "Link %4.4x.\n", dev->name, phy,
+			       mii_status, rp->mii_if.advertising,
+			       mdio_read(dev, phy, 5));
+
+			/* set IFF_RUNNING */
+			if (mii_status & BMSR_LSTATUS)
+				netif_carrier_on(dev);
+			else
+				netif_carrier_off(dev);
 
-				break;
-			}
+			break;
 		}
-		rp->mii_cnt = phy_idx;
-		rp->mii_if.phy_id = rp->phys[0];
 	}
+	rp->mii_cnt = phy_idx;
+	rp->mii_if.phy_id = rp->phys[0];
 
 	/* Allow forcing the media type. */
 	if (option > 0) {
@@ -1800,9 +1798,6 @@
 	struct rhine_private *rp = netdev_priv(dev);
 	int rc;
 
-	if (!(rp->drv_flags & CanHaveMII))
-		return -EINVAL;
-
 	spin_lock_irq(&rp->lock);
 	rc = mii_ethtool_gset(&rp->mii_if, cmd);
 	spin_unlock_irq(&rp->lock);
@@ -1815,9 +1810,6 @@
 	struct rhine_private *rp = netdev_priv(dev);
 	int rc;
 
-	if (!(rp->drv_flags & CanHaveMII))
-		return -EINVAL;
-
 	spin_lock_irq(&rp->lock);
 	rc = mii_ethtool_sset(&rp->mii_if, cmd);
 	spin_unlock_irq(&rp->lock);
@@ -1829,9 +1821,6 @@
 {
 	struct rhine_private *rp = netdev_priv(dev);
 
-	if (!(rp->drv_flags & CanHaveMII))
-		return -EINVAL;
-
 	return mii_nway_restart(&rp->mii_if);
 }
 
@@ -1839,9 +1828,6 @@
 {
 	struct rhine_private *rp = netdev_priv(dev);
 
-	if (!(rp->drv_flags & CanHaveMII))
-		return 0;	/* -EINVAL */
-
 	return mii_link_ok(&rp->mii_if);
 }
 
