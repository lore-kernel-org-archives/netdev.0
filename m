From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 02/12] sky2: carrier management
Date: Mon, 09 Jul 2007 15:33:34 -0700
Message-ID: <20070709223453.113252876@linux-foundation.org>
References: <20070709223332.966231494@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60836 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755516AbXGIWgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 18:36:55 -0400
Content-Disposition: inline; filename=sky2-carrier-mgmt.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sky2 handle carrier similar to other drivers,
eliminate some possible races in carrier state transistions.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-07-09 15:30:08.000000000 -0700
+++ b/drivers/net/sky2.c	2007-07-09 15:30:09.000000000 -0700
@@ -1265,6 +1265,8 @@ static int sky2_up(struct net_device *de
 	if (netif_msg_ifup(sky2))
 		printk(KERN_INFO PFX "%s: enabling interface\n", dev->name);
 
+	netif_carrier_off(dev);
+
 	/* must be power of 2 */
 	sky2->tx_le = pci_alloc_consistent(hw->pdev,
 					   TX_RING_SIZE *
@@ -1616,7 +1618,6 @@ static int sky2_down(struct net_device *
 
 	/* Stop more packets from being queued */
 	netif_stop_queue(dev);
-	netif_carrier_off(dev);
 
 	/* Disable port IRQ */
 	imask = sky2_read32(hw, B0_IMSK);
@@ -1668,6 +1669,8 @@ static int sky2_down(struct net_device *
 
 	sky2_phy_power(hw, port, 0);
 
+	netif_carrier_off(dev);
+
 	/* turn off LED's */
 	sky2_write16(hw, B0_Y2LED, LED_STAT_OFF);
 
@@ -1732,7 +1735,6 @@ static void sky2_link_up(struct sky2_por
 	gm_phy_write(hw, port, PHY_MARV_INT_MASK, PHY_M_DEF_MSK);
 
 	netif_carrier_on(sky2->netdev);
-	netif_wake_queue(sky2->netdev);
 
 	/* Turn on link LED */
 	sky2_write8(hw, SK_REG(port, LNK_LED_REG),
@@ -1784,7 +1786,6 @@ static void sky2_link_down(struct sky2_p
 	gma_write16(hw, port, GM_GP_CTRL, reg);
 
 	netif_carrier_off(sky2->netdev);
-	netif_stop_queue(sky2->netdev);
 
 	/* Turn on link LED */
 	sky2_write8(hw, SK_REG(port, LNK_LED_REG), LINKLED_OFF);
@@ -3543,10 +3544,6 @@ static __devinit struct net_device *sky2
 	memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port * 8, ETH_ALEN);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
-	/* device is off until link detection */
-	netif_carrier_off(dev);
-	netif_stop_queue(dev);
-
 	return dev;
 }
 

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

