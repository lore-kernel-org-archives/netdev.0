From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH v2] net: mvneta: read MAC address from hardware when available
Date: Tue,  4 Jun 2013 16:52:23 +0200
Message-ID: <1370357543-23332-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: netdev@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	linux-arm-kernel@lists.infradead.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Joe Perches <joe@perches.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:58149 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754471Ab3FDOxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 10:53:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch improves the logic used by the mvneta driver to find a MAC
address for a particular interface. Until now, it was only looking at
the Device Tree, and if no address was found, was falling back to
generating a random MAC address.

This patch adds the intermediate solution of reading the MAC address
from the hardware registers, in case it has been set by the
bootloader. So the order is now:

 1) MAC address from the Device Tree
 2) MAC address from the hardware registers
 3) Random MAC address

This requires moving the MAC address initialization a little bit later
in the ->probe() code, because it now requires the hardware registers
to be remapped.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Cc: Joe Perches <joe@perches.com>
---
v1 -> v2:
 * Added an empty line between the variable declaration and the first
   statement in mvneta_get_mac_addr(), as suggested by Sergei
   Shtylyov.
 * Added missing braces on arms of an if statement, when the if
   statement as multiple lines in the else part, as suggested by
   Sergei Shtylyov.
 * Improve the message that shows the MAC address to show from where
   the MAC address was taken (from hardware, from DT, or
   random). Suggested by Joe Perches.

 drivers/net/ethernet/marvell/mvneta.c | 44 ++++++++++++++++++++++++++++-------
 1 file changed, 35 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index c966785..92818d1 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2251,6 +2251,21 @@ static int mvneta_change_mtu(struct net_device *dev, int mtu)
 	return 0;
 }
 
+/* Get mac address */
+static void mvneta_get_mac_addr(struct mvneta_port *pp, unsigned char *addr)
+{
+	u32 mac_addr_l, mac_addr_h;
+
+	mac_addr_l = mvreg_read(pp, MVNETA_MAC_ADDR_LOW);
+	mac_addr_h = mvreg_read(pp, MVNETA_MAC_ADDR_HIGH);
+	addr[0] = (mac_addr_h >> 24) & 0xFF;
+	addr[1] = (mac_addr_h >> 16) & 0xFF;
+	addr[2] = (mac_addr_h >> 8) & 0xFF;
+	addr[3] = mac_addr_h & 0xFF;
+	addr[4] = (mac_addr_l >> 8) & 0xFF;
+	addr[5] = mac_addr_l & 0xFF;
+}
+
 /* Handle setting mac address */
 static int mvneta_set_mac_addr(struct net_device *dev, void *addr)
 {
@@ -2667,7 +2682,9 @@ static int mvneta_probe(struct platform_device *pdev)
 	u32 phy_addr;
 	struct mvneta_port *pp;
 	struct net_device *dev;
-	const char *mac_addr;
+	const char *dt_mac_addr;
+	char hw_mac_addr[ETH_ALEN];
+	const char *mac_from;
 	int phy_mode;
 	int err;
 
@@ -2703,13 +2720,6 @@ static int mvneta_probe(struct platform_device *pdev)
 		goto err_free_irq;
 	}
 
-	mac_addr = of_get_mac_address(dn);
-
-	if (!mac_addr || !is_valid_ether_addr(mac_addr))
-		eth_hw_addr_random(dev);
-	else
-		memcpy(dev->dev_addr, mac_addr, ETH_ALEN);
-
 	dev->tx_queue_len = MVNETA_MAX_TXD;
 	dev->watchdog_timeo = 5 * HZ;
 	dev->netdev_ops = &mvneta_netdev_ops;
@@ -2740,6 +2750,21 @@ static int mvneta_probe(struct platform_device *pdev)
 
 	clk_prepare_enable(pp->clk);
 
+	dt_mac_addr = of_get_mac_address(dn);
+	if (dt_mac_addr && is_valid_ether_addr(dt_mac_addr)) {
+		mac_from = "device tree";
+		memcpy(dev->dev_addr, dt_mac_addr, ETH_ALEN);
+	} else {
+		mvneta_get_mac_addr(pp, hw_mac_addr);
+		if (is_valid_ether_addr(hw_mac_addr)) {
+			mac_from = "hardware";
+			memcpy(dev->dev_addr, hw_mac_addr, ETH_ALEN);
+		} else {
+			mac_from = "random";
+			eth_hw_addr_random(dev);
+		}
+	}
+
 	pp->tx_done_timer.data = (unsigned long)dev;
 
 	pp->tx_ring_size = MVNETA_MAX_TXD;
@@ -2772,7 +2797,8 @@ static int mvneta_probe(struct platform_device *pdev)
 		goto err_deinit;
 	}
 
-	netdev_info(dev, "mac: %pM\n", dev->dev_addr);
+	netdev_info(dev, "Using %s mac address %pM\n", mac_from,
+		    dev->dev_addr);
 
 	platform_set_drvdata(pdev, pp->dev);
 
-- 
1.8.1.2
