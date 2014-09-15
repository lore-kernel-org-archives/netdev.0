From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH v3 6/9] net: pxa168_eth: rework the MAC address setup
Date: Mon, 15 Sep 2014 16:01:50 +0200
Message-ID: <1410789713-15341-7-git-send-email-antoine.tenart@free-electrons.com>
References: <1410789713-15341-1-git-send-email-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
	alexandre.belloni@free-electrons.com,
	thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
	jszhang@marvell.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sebastian.hesselbarth@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410789713-15341-1-git-send-email-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch rework the way the MAC address is retrieved. The MAC address
can now, in addition to being random, be set in the device tree or
retrieved from the Ethernet controller MAC address registers. The
probing function will try to get a MAC address in the following order:
- From the device tree.
- From the Ethernet controller MAC address registers.
- Generate a random one.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/pxa168_eth.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index d9f4f7d05a1e..4a57f640b424 100644
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
@@ -1481,6 +1482,7 @@ static int pxa168_eth_probe(struct platform_device *pdev)
 	struct net_device *dev = NULL;
 	struct resource *res;
 	struct clk *clk;
+	const unsigned char *mac_addr = NULL;
 	int err;
 
 	printk(KERN_NOTICE "PXA168 10/100 Ethernet Driver\n");
@@ -1522,8 +1524,19 @@ static int pxa168_eth_probe(struct platform_device *pdev)
 
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
