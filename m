From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 5/7] smsc75xx: fix phy interrupt acknowledge
Date: Mon, 30 Apr 2012 18:56:54 +0100
Message-ID: <1335808616-22513-6-git-send-email-steve.glendinning@shawell.net>
References: <1335808616-22513-1-git-send-email-steve.glendinning@shawell.net>
Cc: David Miller <davem@davemloft.net>,
	Stephane Fillod <fillods@users.sf.net>,
	Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:49413 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756520Ab2D3R5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 13:57:15 -0400
In-Reply-To: <1335808616-22513-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

smsc75xx phy interrupt acknowledge needs an mdio_write to clear
PHY_INT_SRC instead of just a read like in smsc95xx.

Signed-off-by: Stephane Fillod <fillods@users.sf.net>
Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc75xx.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index cc23a58..4941782 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -508,9 +508,10 @@ static int smsc75xx_link_reset(struct usbnet *dev)
 	u16 lcladv, rmtadv;
 	int ret;
 
-	/* clear interrupt status */
+	/* read and write to clear phy interrupt status */
 	ret = smsc75xx_mdio_read(dev->net, mii->phy_id, PHY_INT_SRC);
 	check_warn_return(ret, "Error reading PHY_INT_SRC");
+	smsc75xx_mdio_write(dev->net, mii->phy_id, PHY_INT_SRC, 0xffff);
 
 	ret = smsc75xx_write_reg(dev, INT_STS, INT_STS_CLEAR_ALL);
 	check_warn_return(ret, "Error writing INT_STS");
@@ -643,7 +644,7 @@ static int smsc75xx_set_mac_address(struct usbnet *dev)
 
 static int smsc75xx_phy_initialize(struct usbnet *dev)
 {
-	int bmcr, timeout = 0;
+	int bmcr, ret, timeout = 0;
 
 	/* Initialize MII structure */
 	dev->mii.dev = dev->net;
@@ -672,9 +673,10 @@ static int smsc75xx_phy_initialize(struct usbnet *dev)
 		ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP |
 		ADVERTISE_PAUSE_ASYM);
 
-	/* read to clear */
-	smsc75xx_mdio_read(dev->net, dev->mii.phy_id, PHY_INT_SRC);
-	check_warn_return(bmcr, "Error reading PHY_INT_SRC");
+	/* read and write to clear phy interrupt status */
+	ret = smsc75xx_mdio_read(dev->net, dev->mii.phy_id, PHY_INT_SRC);
+	check_warn_return(ret, "Error reading PHY_INT_SRC");
+	smsc75xx_mdio_write(dev->net, dev->mii.phy_id, PHY_INT_SRC, 0xffff);
 
 	smsc75xx_mdio_write(dev->net, dev->mii.phy_id, PHY_INT_MASK,
 		PHY_INT_MASK_DEFAULT);
-- 
1.7.9.5
