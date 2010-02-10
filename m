From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH 3/5] sky2: Refactor sky2_up into two functions
Date: Wed, 10 Feb 2010 23:12:11 +0900
Message-ID: <4B72BEBB.2000402@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f187.google.com ([209.85.222.187]:55858 "EHLO
	mail-pz0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754038Ab0BJORU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 09:17:20 -0500
Received: by mail-pz0-f187.google.com with SMTP id 17so24824pzk.4
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 06:17:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move hardware initialization into sky2_hw_up.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   41 +++++++++++++++++++++++++----------------
 1 files changed, 25 insertions(+), 16 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index ee091d1..c41a2ed 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1543,16 +1543,16 @@ static void sky2_free_buffers(struct sky2_port *sky2)
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
@@ -1564,16 +1564,7 @@ static int sky2_up(struct net_device *dev)
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
 
@@ -1582,7 +1573,7 @@ static int sky2_up(struct net_device *dev)
 	if (ramsize > 0) {
 		u32 rxspace;
 
-		pr_debug(PFX "%s: ram buffer %dK\n", dev->name, ramsize);
+		pr_debug(PFX "%s: ram buffer %dK\n", sky2->netdev->name, ramsize);
 		if (ramsize < 16)
 			rxspace = ramsize / 2;
 		else
@@ -1615,6 +1606,24 @@ static int sky2_up(struct net_device *dev)
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
1.5.6.5


