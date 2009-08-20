From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/3] r6040: move down second PHY detection to r6040_init_one
Date: Thu, 20 Aug 2009 13:26:20 +0200
Message-ID: <200908201326.21438.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mark@bifferos.com,
	bifferos <bifferos@yahoo.co.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:39465 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753912AbZHTL0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 07:26:23 -0400
Received: by mail-fx0-f217.google.com with SMTP id 17so380883fxm.37
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2009 04:26:24 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Kelly <mark@bifferos.com>

Instead of fully initializing an unusable second r6040
device, perform the PHY detection earlier and bail out
in r6040_init_one when we could not read the PHY identifier.

Signed-off-by: Mark Kelly <mark@bifferos.com>
Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 60bd010..7238a6f 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -750,14 +750,6 @@ static int r6040_up(struct net_device *dev)
 	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
 	int ret;
-	u16 val;
-
-	/* Check presence of a second PHY */
-	val = r6040_phy_read(ioaddr, lp->phy_addr, 2);
-	if (val == 0xFFFF) {
-		printk(KERN_ERR DRV_NAME " no second PHY attached\n");
-		return -EIO;
-	}
 
 	/* Initialise and alloc RX/TX buffers */
 	r6040_init_txbufs(dev);
@@ -1194,6 +1186,13 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 	lp->mii_if.phy_id_mask = 0x1f;
 	lp->mii_if.reg_num_mask = 0x1f;
 
+	/* Check the vendor ID on the PHY, if 0xffff assume none attached */
+	if (r6040_phy_read(ioaddr, lp->phy_addr, 2) == 0xffff) {
+		printk(KERN_ERR DRV_NAME ": Failed to detect an attached PHY\n");
+		err = -ENODEV;
+		goto err_out_unmap;
+	}
+
 	/* Register net device. After this dev->name assign */
 	err = register_netdev(dev);
 	if (err) {
