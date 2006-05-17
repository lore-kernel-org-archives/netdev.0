From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/5] sky2: allow dual port usage
Date: Wed, 17 May 2006 14:37:03 -0700
Message-ID: <20060517213801.841172000@localhost.localdomain>
References: <20060517213702.322762000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:50104 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751152AbWEQVld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 May 2006 17:41:33 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-dual-port.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If both ports are receiving on the SysKonnect dual port cards,
then it appears the bus interface unit can give an interrupt status
for frame before DMA has completed.  This leads to bogus frames
and general confusion. This is why receive checksumming is also
messed up on dual port cards.

A workaround for the out of order receive problem is to eliminating
split transactions on PCI-X.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- sky2.orig/drivers/net/sky2.c	2006-05-17 14:33:28.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-05-17 14:34:57.000000000 -0700
@@ -1020,7 +1020,25 @@
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
 	u32 ramsize, rxspace, imask;
-	int err = -ENOMEM;
+	int cap, err = -ENOMEM;
+	struct net_device *otherdev = hw->dev[sky2->port^1];
+
+	/*
+	 * On dual port PCI-X card, there is an problem where status
+	 * can be received out of order due to split transactions
+	 */
+	if (otherdev && netif_running(otherdev) &&
+	    (cap = pci_find_capability(hw->pdev, PCI_CAP_ID_PCIX))) {
+		struct sky2_port *osky2 = netdev_priv(otherdev);
+		u16 cmd;
+
+		cmd = sky2_pci_read16(hw, cap + PCI_X_CMD);
+		cmd &= ~PCI_X_CMD_MAX_SPLIT;
+		sky2_pci_write16(hw, cap + PCI_X_CMD, cmd);
+
+		sky2->rx_csum = 0;
+		osky2->rx_csum = 0;
+	}
 
 	if (netif_msg_ifup(sky2))
 		printk(KERN_INFO PFX "%s: enabling interface\n", dev->name);
@@ -3067,12 +3085,7 @@
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

--

