From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH v5 06/10] net: pxa168_eth: rework the MAC address setup
Date: Fri, 26 Sep 2014 16:33:52 +0200
Message-ID: <1411742036-23520-7-git-send-email-antoine.tenart@free-electrons.com>
References: <1411742036-23520-1-git-send-email-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
	alexandre.belloni@free-electrons.com,
	thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
	jszhang@marvell.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:35008 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755180AbaIZOeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 10:34:04 -0400
In-Reply-To: <1411742036-23520-1-git-send-email-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch rework the way the MAC address is retrieved. The MAC address
can now, in addition to being random, be set in the device tree or
retrieved from the Ethernet controller MAC address registers. The
probing function will try to get a MAC address in the following order:
- From the device tree.
- From the Ethernet controller MAC address registers.
- Generate a random one.

This patch also adds a function to read the MAC address from the
Ethernet Controller registers.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
Acked-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/marvell/pxa168_eth.c | 32 +++++++++++++++++++++++++++++--
 1 file changed, 30 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 34f17dde1cb0..3da8c5af15de 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -35,6 +35,7 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/of.h>
+#include <linux/of_net.h>
 #include <linux/phy.h>
 #include <linux/platform_device.h>
 #include <linux/pxa168_eth.h>
@@ -606,6 +607,21 @@ static void pxa168_eth_set_rx_mode(struct net_device *dev)
 		update_hash_table_mac_address(pep, NULL, ha->addr);
 }
 
+static void pxa168_eth_get_mac_address(struct net_device *dev,
+				       unsigned char *addr)
+{
+	struct pxa168_eth_private *pep = netdev_priv(dev);
+	unsigned int mac_h = rdl(pep, MAC_ADDR_HIGH);
+	unsigned int mac_l = rdl(pep, MAC_ADDR_LOW);
+
+	addr[0] = (mac_h >> 24) & 0xff;
+	addr[1] = (mac_h >> 16) & 0xff;
+	addr[2] = (mac_h >> 8) & 0xff;
+	addr[3] = mac_h & 0xff;
+	addr[4] = (mac_l >> 8) & 0xff;
+	addr[5] = mac_l & 0xff;
+}
+
 static int pxa168_eth_set_mac_address(struct net_device *dev, void *addr)
 {
 	struct sockaddr *sa = addr;
@@ -1467,6 +1483,7 @@ static int pxa168_eth_probe(struct platform_device *pdev)
 	struct resource *res;
 	struct clk *clk;
 	struct device_node *np;
+	const unsigned char *mac_addr = NULL;
 	int err;
 
 	printk(KERN_NOTICE "PXA168 10/100 Ethernet Driver\n");
@@ -1508,8 +1525,19 @@ static int pxa168_eth_probe(struct platform_device *pdev)
 
 	INIT_WORK(&pep->tx_timeout_task, pxa168_eth_tx_timeout_task);
 
-	dev_info(&pdev->dev, "Using random mac address\n");
-	eth_hw_addr_random(dev);
+	if (pdev->dev.of_node)
+		mac_addr = of_get_mac_address(pdev->dev.of_node);
+
+	if (mac_addr && is_valid_ether_addr(mac_addr)) {
+		ether_addr_copy(dev->dev_addr, mac_addr);
+	} else {
+		/* try reading the mac address, if set by the bootloader */
+		pxa168_eth_get_mac_address(dev, dev->dev_addr);
+		if (!is_valid_ether_addr(dev->dev_addr)) {
+			dev_info(&pdev->dev, "Using random mac address\n");
+			eth_hw_addr_random(dev);
+		}
+	}
 
 	pep->rx_ring_size = NUM_RX_DESCS;
 	pep->tx_ring_size = NUM_TX_DESCS;
-- 
1.9.1
