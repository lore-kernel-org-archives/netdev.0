From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sky bugs in 2.6.22-rc5
Date: Mon, 18 Jun 2007 13:04:14 -0700
Message-ID: <20070618130414.35801913@localhost.localdomain>
References: <4676E1DD.1060007@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39461 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761818AbXFRUE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 16:04:27 -0400
In-Reply-To: <4676E1DD.1060007@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Does this fix it?  It was possible for the PHY interrupt to race
while bringing link up.


--- a/drivers/net/sky2.c	2007-06-18 12:56:29.000000000 -0700
+++ b/drivers/net/sky2.c	2007-06-18 13:02:11.000000000 -0700
@@ -652,7 +652,6 @@ static void sky2_wol_init(struct sky2_po
 
 static void sky2_mac_init(struct sky2_hw *hw, unsigned port)
 {
-	struct sky2_port *sky2 = netdev_priv(hw->dev[port]);
 	u16 reg;
 	int i;
 	const u8 *addr = hw->dev[port]->dev_addr;
@@ -679,9 +678,7 @@ static void sky2_mac_init(struct sky2_hw
 	/* Enable Transmit FIFO Underrun */
 	sky2_write8(hw, SK_REG(port, GMAC_IRQ_MSK), GMAC_DEF_MSK);
 
-	spin_lock_bh(&sky2->phy_lock);
 	sky2_phy_init(hw, port);
-	spin_unlock_bh(&sky2->phy_lock);
 
 	/* MIB clear */
 	reg = gma_read16(hw, port, GM_PHY_ADDR);
@@ -1259,6 +1256,7 @@ static int sky2_up(struct net_device *de
 	if (!sky2->rx_ring)
 		goto err_out;
 
+	spin_lock_bh(&sky2->phy_lock);
 	sky2_phy_power(hw, port, 1);
 
 	sky2_mac_init(hw, port);
@@ -1295,15 +1293,18 @@ static int sky2_up(struct net_device *de
 
 	err = sky2_rx_start(sky2);
 	if (err)
-		goto err_out;
+		goto err_out_unlock;
 
 	/* Enable interrupts from phy/mac for port */
 	imask = sky2_read32(hw, B0_IMSK);
 	imask |= portirq_msk[port];
 	sky2_write32(hw, B0_IMSK, imask);
 
+	spin_unlock_bh(&sky2->phy_lock);
 	return 0;
 
+err_out_unlock:
+	spin_unlock_bh(&sky2->phy_lock);
 err_out:
 	if (sky2->rx_le) {
 		pci_free_consistent(hw->pdev, RX_LE_BYTES,
@@ -1571,6 +1572,8 @@ static int sky2_down(struct net_device *
 	if (netif_msg_ifdown(sky2))
 		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);
 
+	spin_lock_bh(&sky2->phy_lock);
+
 	/* Stop more packets from being queued */
 	netif_stop_queue(dev);
 	netif_carrier_off(dev);
@@ -1647,6 +1650,7 @@ static int sky2_down(struct net_device *
 
 	sky2->rx_ring = NULL;
 	sky2->tx_ring = NULL;
+	spin_unlock_bh(&sky2->phy_lock);
 
 	return 0;
 }
@@ -1830,10 +1834,10 @@ static void sky2_phy_intr(struct sky2_hw
 	struct sky2_port *sky2 = netdev_priv(dev);
 	u16 istatus, phystat;
 
+	spin_lock(&sky2->phy_lock);
 	if (!netif_running(dev))
-		return;
+		goto out;
 
-	spin_lock(&sky2->phy_lock);
 	istatus = gm_phy_read(hw, port, PHY_MARV_INT_STAT);
 	phystat = gm_phy_read(hw, port, PHY_MARV_PHY_STAT);
 
