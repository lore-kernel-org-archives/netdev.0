From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 4/4] drivers: net: xgene-v2: misc fixes
Date: Tue, 21 Mar 2017 12:24:43 -0700
Message-ID: <1490124283-10371-5-git-send-email-isubramanian@apm.com>
References: <1490124283-10371-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        kchudgar@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org, andrew@lunn.ch,
        f.fainelli@gmail.com, David.Laight@aculab.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:36280 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933378AbdCUTYe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 15:24:34 -0400
Received: by mail-pg0-f50.google.com with SMTP id g2so97556095pge.3
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 12:23:31 -0700 (PDT)
In-Reply-To: <1490124283-10371-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed review comments from the previous patch-set.

- changed return value check of platform_get_irq() to < 0
- replaced devm_request(free)_irq() calls by request(free)_irq() since
  they are called from open() and close()
- changed sizeof(struct mystruct) to sizeof(*mystruct)
- reduced indentation on tx_timeout()

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene-v2/main.c | 55 +++++++++++++++-----------------
 1 file changed, 26 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene-v2/main.c b/drivers/net/ethernet/apm/xgene-v2/main.c
index 9a5a5ec..ce31c47 100644
--- a/drivers/net/ethernet/apm/xgene-v2/main.c
+++ b/drivers/net/ethernet/apm/xgene-v2/main.c
@@ -66,9 +66,8 @@ static int xge_get_resources(struct xge_pdata *pdata)
 	}
 
 	ret = platform_get_irq(pdev, 0);
-	if (ret <= 0) {
-		dev_err(dev, "Unable to get ENET IRQ\n");
-		ret = ret ? : -ENXIO;
+	if (ret < 0) {
+		dev_err(dev, "Unable to get irq\n");
 		return ret;
 	}
 	pdata->resources.irq = ret;
@@ -156,13 +155,12 @@ static irqreturn_t xge_irq(const int irq, void *data)
 static int xge_request_irq(struct net_device *ndev)
 {
 	struct xge_pdata *pdata = netdev_priv(ndev);
-	struct device *dev = &pdata->pdev->dev;
 	int ret;
 
 	snprintf(pdata->irq_name, IRQ_ID_SIZE, "%s", ndev->name);
 
-	ret = devm_request_irq(dev, pdata->resources.irq, xge_irq,
-			       0, pdata->irq_name, pdata);
+	ret = request_irq(pdata->resources.irq, xge_irq, 0, pdata->irq_name,
+			  pdata);
 	if (ret)
 		netdev_err(ndev, "Failed to request irq %s\n", pdata->irq_name);
 
@@ -172,9 +170,8 @@ static int xge_request_irq(struct net_device *ndev)
 static void xge_free_irq(struct net_device *ndev)
 {
 	struct xge_pdata *pdata = netdev_priv(ndev);
-	struct device *dev = &pdata->pdev->dev;
 
-	devm_free_irq(dev, pdata->resources.irq, pdata);
+	free_irq(pdata->resources.irq, pdata);
 }
 
 static bool is_tx_slot_available(struct xge_raw_desc *raw_desc)
@@ -424,7 +421,7 @@ static struct xge_desc_ring *xge_create_desc_ring(struct net_device *ndev)
 	struct xge_desc_ring *ring;
 	u16 size;
 
-	ring = kzalloc(sizeof(struct xge_desc_ring), GFP_KERNEL);
+	ring = kzalloc(sizeof(*ring), GFP_KERNEL);
 	if (!ring)
 		return NULL;
 
@@ -436,7 +433,7 @@ static struct xge_desc_ring *xge_create_desc_ring(struct net_device *ndev)
 	if (!ring->desc_addr)
 		goto err;
 
-	ring->pkt_info = kcalloc(XGENE_ENET_NUM_DESC, sizeof(struct pkt_info),
+	ring->pkt_info = kcalloc(XGENE_ENET_NUM_DESC, sizeof(*ring->pkt_info),
 				 GFP_KERNEL);
 	if (!ring->pkt_info)
 		goto err;
@@ -598,28 +595,28 @@ static void xge_timeout(struct net_device *ndev)
 
 	rtnl_lock();
 
-	if (netif_running(ndev)) {
-		netif_carrier_off(ndev);
-		netif_stop_queue(ndev);
-		xge_intr_disable(pdata);
-		napi_disable(&pdata->napi);
+	if (!netif_running(ndev))
+		goto out;
 
-		xge_wr_csr(pdata, DMATXCTRL, 0);
-		xge_txc_poll(ndev);
-		xge_free_pending_skb(ndev);
-		xge_wr_csr(pdata, DMATXSTATUS, ~0U);
+	netif_stop_queue(ndev);
+	xge_intr_disable(pdata);
+	napi_disable(&pdata->napi);
 
-		xge_setup_desc(pdata->tx_ring);
-		xge_update_tx_desc_addr(pdata);
-		xge_mac_init(pdata);
+	xge_wr_csr(pdata, DMATXCTRL, 0);
+	xge_txc_poll(ndev);
+	xge_free_pending_skb(ndev);
+	xge_wr_csr(pdata, DMATXSTATUS, ~0U);
 
-		napi_enable(&pdata->napi);
-		xge_intr_enable(pdata);
-		xge_mac_enable(pdata);
-		netif_start_queue(ndev);
-		netif_carrier_on(ndev);
-	}
+	xge_setup_desc(pdata->tx_ring);
+	xge_update_tx_desc_addr(pdata);
+	xge_mac_init(pdata);
+
+	napi_enable(&pdata->napi);
+	xge_intr_enable(pdata);
+	xge_mac_enable(pdata);
+	netif_start_queue(ndev);
 
+out:
 	rtnl_unlock();
 }
 
@@ -653,7 +650,7 @@ static int xge_probe(struct platform_device *pdev)
 	struct xge_pdata *pdata;
 	int ret;
 
-	ndev = alloc_etherdev(sizeof(struct xge_pdata));
+	ndev = alloc_etherdev(sizeof(*pdata));
 	if (!ndev)
 		return -ENOMEM;
 
-- 
1.9.1
