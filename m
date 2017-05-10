From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH] net: ethernet: ti: netcp_core: return error while dma channel open issue
Date: Wed, 10 May 2017 10:28:05 -0700
Message-ID: <1494437285-13839-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: ssantosh@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: w-kwok2@ti.com, m-karicheri2@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:35650 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753895AbdEJR2J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 13:28:09 -0400
Received: by mail-pg0-f44.google.com with SMTP id o3so1094319pgn.2
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 10:28:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix error path while dma open channel issue. Also, no need to check output
on NULL if it's never returned.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
Based on net-next

 drivers/net/ethernet/ti/netcp_core.c | 6 ++++--
 drivers/soc/ti/knav_dma.c            | 2 +-
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 729a7da..e6222e5 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1353,9 +1353,10 @@ int netcp_txpipe_open(struct netcp_tx_pipe *tx_pipe)
 
 	tx_pipe->dma_channel = knav_dma_open_channel(dev,
 				tx_pipe->dma_chan_name, &config);
-	if (IS_ERR_OR_NULL(tx_pipe->dma_channel)) {
+	if (IS_ERR(tx_pipe->dma_channel)) {
 		dev_err(dev, "failed opening tx chan(%s)\n",
 			tx_pipe->dma_chan_name);
+		ret = PTR_ERR(tx_pipe->dma_channel);
 		goto err;
 	}
 
@@ -1673,9 +1674,10 @@ static int netcp_setup_navigator_resources(struct net_device *ndev)
 
 	netcp->rx_channel = knav_dma_open_channel(netcp->netcp_device->device,
 					netcp->dma_chan_name, &config);
-	if (IS_ERR_OR_NULL(netcp->rx_channel)) {
+	if (IS_ERR(netcp->rx_channel)) {
 		dev_err(netcp->ndev_dev, "failed opening rx chan(%s\n",
 			netcp->dma_chan_name);
+		ret = PTR_ERR(netcp->rx_channel);
 		goto fail;
 	}
 
diff --git a/drivers/soc/ti/knav_dma.c b/drivers/soc/ti/knav_dma.c
index ecebe2e..026182d 100644
--- a/drivers/soc/ti/knav_dma.c
+++ b/drivers/soc/ti/knav_dma.c
@@ -413,7 +413,7 @@ static int of_channel_match_helper(struct device_node *np, const char *name,
  * @name:	slave channel name
  * @config:	dma configuration parameters
  *
- * Returns pointer to appropriate DMA channel on success or NULL.
+ * Returns pointer to appropriate DMA channel on success or error.
  */
 void *knav_dma_open_channel(struct device *dev, const char *name,
 					struct knav_dma_cfg *config)
-- 
2.7.4
