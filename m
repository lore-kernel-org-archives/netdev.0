From: Antoine Tenart <antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: [PATCH v6 06/10] net: pxa168_eth: rework the MAC address setup
Date: Tue, 30 Sep 2014 16:28:12 +0200
Message-ID: <1412087296-18475-7-git-send-email-antoine.tenart@free-electrons.com>
References: <1412087296-18475-1-git-send-email-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, zmxu-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org,
	jszhang-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1412087296-18475-1-git-send-email-antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch rework the way the MAC address is retrieved. The MAC address
can now, in addition to being random, be set in the device tree or
retrieved from the Ethernet controller MAC address registers. The
probing function will try to get a MAC address in the following order:
- From the device tree.
- From the Ethernet controller MAC address registers.
- Generate a random one.

This patch also adds a function to read the MAC address from the
Ethernet Controller registers.

Signed-off-by: Antoine Tenart <antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Acked-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
---
 drivers/net/ethernet/marvell/pxa168_eth.c | 32 +++++++++++++++++++++++++++++--
 1 file changed, 30 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 6917904409b8..24de41231593 100644
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
