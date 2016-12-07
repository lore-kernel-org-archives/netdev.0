From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: axienet: Utilize of_get_mac_address()
Date: Wed,  7 Dec 2016 13:24:44 +0100
Message-ID: <20161207122444.29306-1-tklauser@distanz.ch>
Cc: anirudh@xilinx.com, John.Linn@xilinx.com, michal.simek@xilinx.com,
        soren.brinkmann@xilinx.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:33092 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751884AbcLGMZd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 07:25:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not open code getting the MAC address exclusively from the
"local-mac-address" property, but instead use of_get_mac_address()
which looks up the MAC address using the 3 typical property names.

Also avoid casting away the const qualifier of the return value by
making axienet_set_mac_address() take a const void* address.

Follows commit b34296a9c047 ("net: ethoc: Utilize
of_get_mac_address()").

Cc: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index c9c8a3be9f1b..b96e96919e31 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -25,6 +25,7 @@
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/of_mdio.h>
+#include <linux/of_net.h>
 #include <linux/of_platform.h>
 #include <linux/of_irq.h>
 #include <linux/of_address.h>
@@ -292,7 +293,8 @@ static int axienet_dma_bd_init(struct net_device *ndev)
  * This function is called to initialize the MAC address of the Axi Ethernet
  * core. It writes to the UAW0 and UAW1 registers of the core.
  */
-static void axienet_set_mac_address(struct net_device *ndev, void *address)
+static void axienet_set_mac_address(struct net_device *ndev,
+				    const void *address)
 {
 	struct axienet_local *lp = netdev_priv(ndev);
 
@@ -1456,7 +1458,7 @@ static int axienet_probe(struct platform_device *pdev)
 	struct device_node *np;
 	struct axienet_local *lp;
 	struct net_device *ndev;
-	u8 mac_addr[6];
+	const void *mac_addr;
 	struct resource *ethres, dmares;
 	u32 value;
 
@@ -1567,13 +1569,12 @@ static int axienet_probe(struct platform_device *pdev)
 	}
 
 	/* Retrieve the MAC address */
-	ret = of_property_read_u8_array(pdev->dev.of_node,
-					"local-mac-address", mac_addr, 6);
-	if (ret) {
+	mac_addr = of_get_mac_address(pdev->dev.of_node);
+	if (!mac_addr) {
 		dev_err(&pdev->dev, "could not find MAC address\n");
 		goto free_netdev;
 	}
-	axienet_set_mac_address(ndev, (void *)mac_addr);
+	axienet_set_mac_address(ndev, mac_addr);
 
 	lp->coalesce_count_rx = XAXIDMA_DFT_RX_THRESHOLD;
 	lp->coalesce_count_tx = XAXIDMA_DFT_TX_THRESHOLD;
-- 
2.11.0
