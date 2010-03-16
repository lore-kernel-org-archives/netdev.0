From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc95xx: wait for PHY to complete reset during init
Date: Tue, 16 Mar 2010 19:03:06 +0000
Message-ID: <1268766186-16014-2-git-send-email-steve.glendinning@smsc.com>
References: <1268766186-16014-1-git-send-email-steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 77-44-110-64.xdsl.murphx.net ([77.44.110.64]:53597 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933891Ab0CPTDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 15:03:10 -0400
Received: from localhost.localdomain (unknown [10.0.20.109])
	by drevil2.shawell.net (Postfix) with ESMTP id EEDAB67E39
	for <netdev@vger.kernel.org>; Tue, 16 Mar 2010 19:03:06 +0000 (GMT)
In-Reply-To: <1268766186-16014-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch ensures the PHY correctly completes its reset before
setting register values.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/usb/smsc95xx.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index df9179a..d222d7e 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -709,6 +709,8 @@ static void smsc95xx_start_rx_path(struct usbnet *dev)
 
 static int smsc95xx_phy_initialize(struct usbnet *dev)
 {
+	int bmcr, timeout = 0;
+
 	/* Initialize MII structure */
 	dev->mii.dev = dev->net;
 	dev->mii.mdio_read = smsc95xx_mdio_read;
@@ -717,7 +719,20 @@ static int smsc95xx_phy_initialize(struct usbnet *dev)
 	dev->mii.reg_num_mask = 0x1f;
 	dev->mii.phy_id = SMSC95XX_INTERNAL_PHY_ID;
 
+	/* reset phy and wait for reset to complete */
 	smsc95xx_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
+
+	do {
+		msleep(10);
+		bmcr = smsc95xx_mdio_read(dev->net, dev->mii.phy_id, MII_BMCR);
+		timeout++;
+	} while ((bmcr & MII_BMCR) && (timeout < 100));
+
+	if (timeout >= 100) {
+		netdev_warn(dev->net, "timeout on PHY Reset");
+		return -EIO;
+	}
+
 	smsc95xx_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
 		ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP |
 		ADVERTISE_PAUSE_ASYM);
-- 
1.6.6.1

