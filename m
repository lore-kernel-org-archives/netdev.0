From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 03/10] sky2: phy irq on shutdown
Date: Wed, 11 Oct 2006 14:22:28 -0700
Message-ID: <20061011212310.492971897@osdl.org>
References: <20061011212225.941046083@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:10957 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161488AbWJKVZu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 17:25:50 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-phy-read-shut.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When PHY is turned off on shutdown, it causes the IRQ to get stuck on.
Make sure and disable the IRQ first, and if IRQ occurs when device
is not running, don't access PHY because that will hang.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- sky2.orig/drivers/net/sky2.c	2006-10-11 11:43:40.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-10-11 11:43:43.000000000 -0700
@@ -1499,6 +1499,11 @@
 	/* Stop more packets from being queued */
 	netif_stop_queue(dev);
 
+	/* Disable port IRQ */
+	imask = sky2_read32(hw, B0_IMSK);
+	imask &= ~portirq_msk[port];
+	sky2_write32(hw, B0_IMSK, imask);
+
 	sky2_gmac_reset(hw, port);
 
 	/* Stop transmitter */
@@ -1549,11 +1554,6 @@
 	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_SET);
 	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_SET);
 
-	/* Disable port IRQ */
-	imask = sky2_read32(hw, B0_IMSK);
-	imask &= ~portirq_msk[port];
-	sky2_write32(hw, B0_IMSK, imask);
-
 	sky2_phy_power(hw, port, 0);
 
 	/* turn off LED's */
@@ -1750,13 +1750,13 @@
 	struct sky2_port *sky2 = netdev_priv(dev);
 	u16 istatus, phystat;
 
+	if (!netif_running(dev))
+		return;
+
 	spin_lock(&sky2->phy_lock);
 	istatus = gm_phy_read(hw, port, PHY_MARV_INT_STAT);
 	phystat = gm_phy_read(hw, port, PHY_MARV_PHY_STAT);
 
-	if (!netif_running(dev))
-		goto out;
-
 	if (netif_msg_intr(sky2))
 		printk(KERN_INFO PFX "%s: phy interrupt status 0x%x 0x%x\n",
 		       sky2->netdev->name, istatus, phystat);

--
Stephen Hemminger <shemminger@osdl.org>

