From: Andrew Victor <andrew@sanpeople.com>
Subject: [PATCH 2.6.17] AT91RM9200 Ethernet #2: MII interface
Date: 20 Jun 2006 11:59:05 +0200
Message-ID: <1150797544.15586.339.camel@fuzzie.sanpeople.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sanpeople.com ([196.41.13.122]:40203 "EHLO
	za-gw.sanpeople.com") by vger.kernel.org with ESMTP
	id S1030218AbWFTKEO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 06:04:14 -0400
To: jgarzik@pobox.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds support for the MII ioctls via generic_mii_ioctl().
Patch from Brian Stafford.

Set the mii.phy_id to the detected PHY address, otherwise ethtool cannot
access PHYs other than 0.
Patch from Roman Kolesnikov.


Signed-off-by: Andrew Victor <andrew@sanpeople.com>


diff -urN linux-2.6.17-rmk.orig/drivers/net/arm/at91_ether.c linux-2.6.17-rmk/drivers/net/arm/at91_ether.c
--- linux-2.6.17-rmk.orig/drivers/net/arm/at91_ether.c	Tue Jun 20 11:03:13 2006
+++ linux-2.6.17-rmk/drivers/net/arm/at91_ether.c	Tue Jun 20 11:03:00 2006
@@ -660,6 +660,22 @@
 	.get_link	= ethtool_op_get_link,
 };
 
+static int at91ether_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+{
+	struct at91_private *lp = (struct at91_private *) dev->priv;
+	int res;
+
+	if (!netif_running(dev))
+		return -EINVAL;
+
+	spin_lock_irq(&lp->lock);
+	enable_mdi();
+	res = generic_mii_ioctl(&lp->mii, if_mii(rq), cmd, NULL);
+	disable_mdi();
+	spin_unlock_irq(&lp->lock);
+
+	return res;
+}
 
 /* ................................ MAC ................................ */
 
@@ -963,6 +979,7 @@
 	dev->set_multicast_list = at91ether_set_rx_mode;
 	dev->set_mac_address = set_mac_address;
 	dev->ethtool_ops = &at91ether_ethtool_ops;
+	dev->do_ioctl = at91ether_ioctl;
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
@@ -993,6 +1010,9 @@
 	lp->mii.dev = dev;		/* Support for ethtool */
 	lp->mii.mdio_read = mdio_read;
 	lp->mii.mdio_write = mdio_write;
+	lp->mii.phy_id = phy_address;
+	lp->mii.phy_id_mask = 0x1f;
+	lp->mii.reg_num_mask = 0x1f;
 
 	lp->phy_type = phy_type;	/* Type of PHY connected */
 	lp->phy_address = phy_address;	/* MDI address of PHY */



