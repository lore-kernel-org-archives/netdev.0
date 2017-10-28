From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] netcp_core: Use common error handling code in
 netcp_create_interface()
Date: Sat, 28 Oct 2017 20:20:08 +0200
Message-ID: <b60510b7-3b1c-bb20-64d6-75b211df500e@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 28 Oct 2017 20:11:02 +0200

Add a jump target so that a specific error code assignment is stored
only once at the end of this function implementation.
Replace five assignments by goto statements.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/ti/netcp_core.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 437d36289786..8fb17df6daa8 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -2009,8 +2009,7 @@ static int netcp_create_interface(struct netcp_device *netcp_device,
 	if (efuse_mac) {
 		if (of_address_to_resource(node, NETCP_EFUSE_REG_INDEX, &res)) {
 			dev_err(dev, "could not find efuse-mac reg resource\n");
-			ret = -ENODEV;
-			goto quit;
+			goto failure_indication;
 		}
 		size = resource_size(&res);
 
@@ -2049,8 +2048,7 @@ static int netcp_create_interface(struct netcp_device *netcp_device,
 				      &netcp->dma_chan_name);
 	if (ret < 0) {
 		dev_err(dev, "missing \"rx-channel\" parameter\n");
-		ret = -ENODEV;
-		goto quit;
+		goto failure_indication;
 	}
 
 	ret = of_property_read_u32(node_interface, "rx-queue",
@@ -2071,8 +2069,7 @@ static int netcp_create_interface(struct netcp_device *netcp_device,
 	ret = of_property_read_u32_array(node_interface, "rx-pool", temp, 2);
 	if (ret < 0) {
 		dev_err(dev, "missing \"rx-pool\" parameter\n");
-		ret = -ENODEV;
-		goto quit;
+		goto failure_indication;
 	}
 	netcp->rx_pool_size = temp[0];
 	netcp->rx_pool_region_id = temp[1];
@@ -2080,8 +2077,7 @@ static int netcp_create_interface(struct netcp_device *netcp_device,
 	ret = of_property_read_u32_array(node_interface, "tx-pool", temp, 2);
 	if (ret < 0) {
 		dev_err(dev, "missing \"tx-pool\" parameter\n");
-		ret = -ENODEV;
-		goto quit;
+		goto failure_indication;
 	}
 	netcp->tx_pool_size = temp[0];
 	netcp->tx_pool_region_id = temp[1];
@@ -2089,8 +2085,7 @@ static int netcp_create_interface(struct netcp_device *netcp_device,
 	if (netcp->tx_pool_size < MAX_SKB_FRAGS) {
 		dev_err(dev, "tx-pool size too small, must be atleast(%ld)\n",
 			MAX_SKB_FRAGS);
-		ret = -ENODEV;
-		goto quit;
+		goto failure_indication;
 	}
 
 	ret = of_property_read_u32(node_interface, "tx-completion-queue",
@@ -2113,6 +2108,8 @@ static int netcp_create_interface(struct netcp_device *netcp_device,
 	list_add_tail(&netcp->interface_list, &netcp_device->interface_head);
 	return 0;
 
+failure_indication:
+	ret = -ENODEV;
 quit:
 	free_netdev(ndev);
 	return ret;
-- 
2.14.3
