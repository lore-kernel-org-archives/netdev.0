From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1a/5] sky2: allow dual port usage
Date: Thu, 18 May 2006 11:16:21 -0700
Message-ID: <20060518111621.54bcb901@localhost.localdomain>
References: <20060517213702.322762000@localhost.localdomain>
	<20060517213801.841172000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:4546 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932123AbWERSQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 May 2006 14:16:28 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20060517213801.841172000@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If both ports are receiving on the SysKonnect dual port cards,
then it appears the bus interface unit can give an interrupt status
for frame before DMA has completed.  This leads to bogus frames
and general confusion. This is why receive checksumming is also
messed up on dual port cards.

A workaround for the out of order receive problem is to eliminating
split transactions on PCI-X.

This version is based of the current linux-2.6.git including earlier
patch to disable dual ports.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/sky2.c	2006-05-18 11:08:10.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-05-18 11:11:48.000000000 -0700
@@ -1020,19 +1020,26 @@
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
 	u32 ramsize, rxspace, imask;
-	int err;
+	int cap, err = -ENOMEM;
 	struct net_device *otherdev = hw->dev[sky2->port^1];
 
-	/* Block bringing up both ports at the same time on a dual port card.
-	 * There is an unfixed bug where receiver gets confused and picks up
-	 * packets out of order. Until this is fixed, prevent data corruption.
+	/*
+ 	 * On dual port PCI-X card, there is an problem where status
+	 * can be received out of order due to split transactions
 	 */
-	if (otherdev && netif_running(otherdev)) {
-		printk(KERN_INFO PFX "dual port support is disabled.\n");
-		return -EBUSY;
-	}
-
-	err = -ENOMEM;
+	if (otherdev && netif_running(otherdev) &&
+ 	    (cap = pci_find_capability(hw->pdev, PCI_CAP_ID_PCIX))) {
+ 		struct sky2_port *osky2 = netdev_priv(otherdev);
+ 		u16 cmd;
+
+ 		cmd = sky2_pci_read16(hw, cap + PCI_X_CMD);
+ 		cmd &= ~PCI_X_CMD_MAX_SPLIT;
+ 		sky2_pci_write16(hw, cap + PCI_X_CMD, cmd);
+
+ 		sky2->rx_csum = 0;
+ 		osky2->rx_csum = 0;
+ 	}
+
 	if (netif_msg_ifup(sky2))
 		printk(KERN_INFO PFX "%s: enabling interface\n", dev->name);
 
@@ -3078,12 +3085,7 @@
 	sky2->duplex = -1;
 	sky2->speed = -1;
 	sky2->advertising = sky2_supported_modes(hw);
-
-	/* Receive checksum disabled for Yukon XL
-	 * because of observed problems with incorrect
-	 * values when multiple packets are received in one interrupt
-	 */
-	sky2->rx_csum = (hw->chip_id != CHIP_ID_YUKON_XL);
+	sky2->rx_csum = 1;
 
 	spin_lock_init(&sky2->phy_lock);
 	sky2->tx_pending = TX_DEF_PENDING;
