From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 07/10] sky2: Refactor sky2_up into two functions
Date: Fri, 12 Feb 2010 08:58:04 -0800
Message-ID: <20100212165938.003565152@vyatta.com>
References: <20100212165757.767062851@vyatta.com>
Cc: netdev@vger.kernel.org, Mike McCormack <mikem@ring3k.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49508 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757423Ab0BLRI1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2010 12:08:27 -0500
Content-Disposition: inline; filename=sky2-mike3.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike McCormack <mikem@ring3k.org>

Move hardware initialization into sky2_hw_up.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
---
 drivers/net/sky2.c |   41 +++++++++++++++++++++++++----------------
 1 files changed, 25 insertions(+), 16 deletions(-)

--- a/drivers/net/sky2.c	2010-02-11 15:33:40.351545123 -0800
+++ b/drivers/net/sky2.c	2010-02-11 15:33:44.579670361 -0800
@@ -1525,16 +1525,16 @@ static void sky2_free_buffers(struct sky
 	sky2->rx_ring = NULL;
 }
 
-/* Bring up network interface. */
-static int sky2_up(struct net_device *dev)
+static void sky2_hw_up(struct sky2_port *sky2)
 {
-	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
-	u32 imask, ramsize;
-	int cap, err;
+	u32 ramsize;
+	int cap;
 	struct net_device *otherdev = hw->dev[sky2->port^1];
 
+	tx_init(sky2);
+
 	/*
  	 * On dual port PCI-X card, there is an problem where status
 	 * can be received out of order due to split transactions
@@ -1546,16 +1546,7 @@ static int sky2_up(struct net_device *de
 		cmd = sky2_pci_read16(hw, cap + PCI_X_CMD);
  		cmd &= ~PCI_X_CMD_MAX_SPLIT;
  		sky2_pci_write16(hw, cap + PCI_X_CMD, cmd);
-
- 	}
-
-	netif_carrier_off(dev);
-
-	err = sky2_alloc_buffers(sky2);
-	if (err)
-		goto err_out;
-
-	tx_init(sky2);
+	}
 
 	sky2_mac_init(hw, port);
 
@@ -1564,7 +1555,7 @@ static int sky2_up(struct net_device *de
 	if (ramsize > 0) {
 		u32 rxspace;
 
-		pr_debug(PFX "%s: ram buffer %dK\n", dev->name, ramsize);
+		pr_debug(PFX "%s: ram buffer %dK\n", sky2->netdev->name, ramsize);
 		if (ramsize < 16)
 			rxspace = ramsize / 2;
 		else
@@ -1597,6 +1588,24 @@ static int sky2_up(struct net_device *de
 #endif
 
 	sky2_rx_start(sky2);
+}
+
+/* Bring up network interface. */
+static int sky2_up(struct net_device *dev)
+{
+	struct sky2_port *sky2 = netdev_priv(dev);
+	struct sky2_hw *hw = sky2->hw;
+	unsigned port = sky2->port;
+	u32 imask;
+	int err;
+
+	netif_carrier_off(dev);
+
+	err = sky2_alloc_buffers(sky2);
+	if (err)
+		goto err_out;
+
+	sky2_hw_up(sky2);
 
 	/* Enable interrupts from phy/mac for port */
 	imask = sky2_read32(hw, B0_IMSK);

-- 

