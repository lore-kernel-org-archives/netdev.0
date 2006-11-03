From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Pull request for 'jg-20061103-00' tag
Date: Fri, 3 Nov 2006 21:56:06 +0100
Message-ID: <20061103205606.GA5723@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:31913 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932142AbWKCU4i
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 15:56:38 -0500
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from tag 'jg-20061103-00' in repository

git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git jg-20061103-00

to get the changes below.

Distance from 'upstream-fixes'
-----------------------------

17fddc34b36fc26aa8b5f130fe32b446d9d88fa2

Diffstat
--------

 drivers/net/r8169.c |   22 ++++++++++++++++++++--
 1 files changed, 20 insertions(+), 2 deletions(-)

Shortlog
--------

Francois Romieu:
      r8169: perform a PHY reset before any other operation at boot time

Patch
-----

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 27f90b2..50b753d 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -571,8 +571,8 @@ static void rtl8169_xmii_reset_enable(vo
 {
 	unsigned int val;
 
-	val = (mdio_read(ioaddr, MII_BMCR) | BMCR_RESET) & 0xffff;
-	mdio_write(ioaddr, MII_BMCR, val);
+	mdio_write(ioaddr, MII_BMCR, BMCR_RESET);
+	val = mdio_read(ioaddr, MII_BMCR);
 }
 
 static void rtl8169_check_link_status(struct net_device *dev,
@@ -1406,6 +1406,22 @@ static void rtl8169_release_board(struct
 	free_netdev(dev);
 }
 
+static void rtl8169_phy_reset(struct net_device *dev,
+			      struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	int i;
+
+	tp->phy_reset_enable(ioaddr);
+	for (i = 0; i < 100; i++) {
+		if (!tp->phy_reset_pending(ioaddr))
+			return;
+		msleep(1);
+	}
+	if (netif_msg_link(tp))
+		printk(KERN_ERR "%s: PHY reset failed.\n", dev->name);
+}
+
 static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -1434,6 +1450,8 @@ static void rtl8169_init_phy(struct net_
 
 	rtl8169_link_option(board_idx, &autoneg, &speed, &duplex);
 
+	rtl8169_phy_reset(dev, tp);
+
 	rtl8169_set_speed(dev, autoneg, speed, duplex);
 
 	if ((RTL_R8(PHYstatus) & TBI_Enable) && netif_msg_link(tp))
-- 
Ueimor
