From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: ll_temac: Utilize of_get_mac_address()
Date: Wed,  7 Dec 2016 13:25:29 +0100
Message-ID: <20161207122529.29508-2-tklauser@distanz.ch>
References: <20161207122529.29508-1-tklauser@distanz.ch>
Cc: michal.simek@xilinx.com, soren.brinkmann@xilinx.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:33118 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752184AbcLGMZd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 07:25:33 -0500
In-Reply-To: <20161207122529.29508-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not open code getting the MAC address exclusively from the
"local-mac-address" property, but instead use of_get_mac_address()
which looks up the MAC address using the 3 typical property names.

Also avoid casting away the const qualifier of the return value by
making temac_init_mac_address() take a const void* address.

Follows commit b34296a9c047 ("net: ethoc: Utilize
of_get_mac_address()").

Cc: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/xilinx/ll_temac_main.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index bcd7b76dde9f..d73da8afe08e 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -37,6 +37,7 @@
 #include <linux/of_device.h>
 #include <linux/of_irq.h>
 #include <linux/of_mdio.h>
+#include <linux/of_net.h>
 #include <linux/of_platform.h>
 #include <linux/of_address.h>
 #include <linux/skbuff.h>
@@ -332,7 +333,7 @@ static void temac_do_set_mac_address(struct net_device *ndev)
 	mutex_unlock(&lp->indirect_mutex);
 }
 
-static int temac_init_mac_address(struct net_device *ndev, void *address)
+static int temac_init_mac_address(struct net_device *ndev, const void *address)
 {
 	memcpy(ndev->dev_addr, address, ETH_ALEN);
 	if (!is_valid_ether_addr(ndev->dev_addr))
@@ -982,7 +983,7 @@ static int temac_of_probe(struct platform_device *op)
 	struct net_device *ndev;
 	const void *addr;
 	__be32 *p;
-	int size, rc = 0;
+	int rc = 0;
 
 	/* Init network device structure */
 	ndev = alloc_etherdev(sizeof(*lp));
@@ -1074,13 +1075,13 @@ static int temac_of_probe(struct platform_device *op)
 
 
 	/* Retrieve the MAC address */
-	addr = of_get_property(op->dev.of_node, "local-mac-address", &size);
-	if ((!addr) || (size != 6)) {
+	addr = of_get_mac_address(op->dev.of_node);
+	if (!addr) {
 		dev_err(&op->dev, "could not find MAC address\n");
 		rc = -ENODEV;
 		goto err_iounmap_2;
 	}
-	temac_init_mac_address(ndev, (void *)addr);
+	temac_init_mac_address(ndev, addr);
 
 	rc = temac_mdio_setup(lp, op->dev.of_node);
 	if (rc)
-- 
2.11.0
