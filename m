From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH] net: mvneta: read MAC address from hardware when available
Date: Mon,  3 Jun 2013 18:41:47 +0200
Message-ID: <1370277707-2468-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: netdev@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:52227 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758911Ab3FCQlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 12:41:50 -0400
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
---
 drivers/net/ethernet/marvell/mvneta.c | 35 +++++++++++++++++++++++++++--------
 1 file changed, 27 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index c966785..8c05cc5 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2251,6 +2251,20 @@ static int mvneta_change_mtu(struct net_device *dev, int mtu)
 	return 0;
 }
 
+/* Get mac address */
+static void mvneta_get_mac_addr(struct mvneta_port *pp, unsigned char *addr)
+{
+	u32 mac_addr_l, mac_addr_h;
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
@@ -2667,7 +2681,8 @@ static int mvneta_probe(struct platform_device *pdev)
 	u32 phy_addr;
 	struct mvneta_port *pp;
 	struct net_device *dev;
-	const char *mac_addr;
+	const char *dt_mac_addr;
+	char hw_mac_addr[ETH_ALEN];
 	int phy_mode;
 	int err;
 
@@ -2703,13 +2718,6 @@ static int mvneta_probe(struct platform_device *pdev)
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
@@ -2740,6 +2748,17 @@ static int mvneta_probe(struct platform_device *pdev)
 
 	clk_prepare_enable(pp->clk);
 
+	dt_mac_addr = of_get_mac_address(dn);
+	if (dt_mac_addr && is_valid_ether_addr(dt_mac_addr))
+		memcpy(dev->dev_addr, dt_mac_addr, ETH_ALEN);
+	else {
+		mvneta_get_mac_addr(pp, hw_mac_addr);
+		if (is_valid_ether_addr(hw_mac_addr))
+			memcpy(dev->dev_addr, hw_mac_addr, ETH_ALEN);
+		else
+			eth_hw_addr_random(dev);
+	}
+
 	pp->tx_done_timer.data = (unsigned long)dev;
 
 	pp->tx_ring_size = MVNETA_MAX_TXD;
-- 
1.8.1.2
