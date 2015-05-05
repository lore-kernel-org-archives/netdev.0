From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 10/12] net: axienet: Use of_property_* calls
Date: Tue,  5 May 2015 11:26:03 +0200
Message-ID: <6643d1ef102bff1d8294ba12ccdca59eeba0b73b.1430817941.git.michal.simek@xilinx.com>
References: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
Cc: Srikanth Thokala <srikanth.thokala@xilinx.com>,
	=?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
	monstr@monstr.eu, John Linn <John.Linn@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:38799 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031466AbbEEJ0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 05:26:37 -0400
Received: by wiun10 with SMTP id n10so138466733wiu.1
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 02:26:35 -0700 (PDT)
In-Reply-To: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
In-Reply-To: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
References: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srikanth Thokala <srikanth.thokala@xilinx.com>

Use of_property_* calls

Signed-off-by: Srikanth Thokala <sthokal@xilinx.com>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 35 ++++++++++-------------
 1 file changed, 15 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 49ae4d50774d..dec7e9918db4 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -1493,13 +1493,13 @@ static void axienet_dma_err_handler(unsigned long data)
  */
 static int axienet_of_probe(struct platform_device *pdev)
 {
-	__be32 *p;
-	int size, ret = 0;
+	int ret;
 	struct device_node *np;
 	struct axienet_local *lp;
 	struct net_device *ndev;
-	const void *addr;
+	u8 mac_addr[6];
 	struct resource *ethres, dmares;
+	u32 value;
 
 	ndev = alloc_etherdev(sizeof(*lp));
 	if (!ndev)
@@ -1529,9 +1529,9 @@ static int axienet_of_probe(struct platform_device *pdev)
 	/* Setup checksum offload, but default to off if not specified */
 	lp->features = 0;
 
-	p = (__be32 *)of_get_property(pdev->dev.of_node, "xlnx,txcsum", NULL);
-	if (p) {
-		switch (be32_to_cpup(p)) {
+	ret = of_property_read_u32(pdev->dev.of_node, "xlnx,txcsum", &value);
+	if (!ret) {
+		switch (value) {
 		case 1:
 			lp->csum_offload_on_tx_path =
 				XAE_FEATURE_PARTIAL_TX_CSUM;
@@ -1550,9 +1550,9 @@ static int axienet_of_probe(struct platform_device *pdev)
 			lp->csum_offload_on_tx_path = XAE_NO_CSUM_OFFLOAD;
 		}
 	}
-	p = (__be32 *)of_get_property(pdev->dev.of_node, "xlnx,rxcsum", NULL);
-	if (p) {
-		switch (be32_to_cpup(p)) {
+	ret = of_property_read_u32(pdev->dev.of_node, "xlnx,rxcsum", &value);
+	if (!ret) {
+		switch (value) {
 		case 1:
 			lp->csum_offload_on_rx_path =
 				XAE_FEATURE_PARTIAL_RX_CSUM;
@@ -1573,13 +1573,8 @@ static int axienet_of_probe(struct platform_device *pdev)
 	 * Here we check for memory allocated for Rx/Tx in the hardware from
 	 * the device-tree and accordingly set flags.
 	 */
-	p = (__be32 *)of_get_property(pdev->dev.of_node, "xlnx,rxmem", NULL);
-	if (p)
-		lp->rxmem = be32_to_cpup(p);
-	p = (__be32 *)of_get_property(pdev->dev.of_node,
-				      "xlnx,phy-type", NULL);
-	if (p)
-		lp->phy_type = be32_to_cpup(p);
+	of_property_read_u32(pdev->dev.of_node, "xlnx,rxmem", &lp->rxmem);
+	of_property_read_u32(pdev->dev.of_node, "xlnx,phy-type", &lp->phy_type);
 
 	/* Find the DMA node, map the DMA registers, and decode the DMA IRQs */
 	np = of_parse_phandle(pdev->dev.of_node, "axistream-connected", 0);
@@ -1609,13 +1604,13 @@ static int axienet_of_probe(struct platform_device *pdev)
 	}
 
 	/* Retrieve the MAC address */
-	addr = of_get_property(pdev->dev.of_node, "local-mac-address", &size);
-	if ((!addr) || (size != 6)) {
+	ret = of_property_read_u8_array(pdev->dev.of_node,
+					"local-mac-address", mac_addr, 6);
+	if (ret) {
 		dev_err(&pdev->dev, "could not find MAC address\n");
-		ret = -ENODEV;
 		goto free_netdev;
 	}
-	axienet_set_mac_address(ndev, (void *) addr);
+	axienet_set_mac_address(ndev, (void *)mac_addr);
 
 	lp->coalesce_count_rx = XAXIDMA_DFT_RX_THRESHOLD;
 	lp->coalesce_count_tx = XAXIDMA_DFT_TX_THRESHOLD;
-- 
2.3.5
