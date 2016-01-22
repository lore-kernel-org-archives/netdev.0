From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH] drivers: net: xgene: fix extra IRQ issue
Date: Thu, 21 Jan 2016 16:07:41 -0800
Message-ID: <1453421261-4295-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	toanle@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:32947 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbcAVAHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 19:07:50 -0500
Received: by mail-pa0-f47.google.com with SMTP id cy9so31270972pac.0
        for <netdev@vger.kernel.org>; Thu, 21 Jan 2016 16:07:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For interrupt controller that doesn't support irq_disable and hardware
with level interrupt, an extra interrupt may be pending. This patch fixes
the issue by setting IRQ_DISABLE_UNLAZY flag for the interrupt line,
as suggested by,

'commit e9849777d0e2 ("genirq: Add flag to force mask in
		       disable_irq[_nosync]()")'

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Toan Le <toanle@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 12 +++++++++---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h |  1 +
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index a4799c1..5eb9b20 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -628,6 +628,7 @@ static int xgene_enet_register_irq(struct net_device *ndev)
 	int ret;
 
 	ring = pdata->rx_ring;
+	irq_set_status_flags(ring->irq, IRQ_DISABLE_UNLAZY);
 	ret = devm_request_irq(dev, ring->irq, xgene_enet_rx_irq,
 			       IRQF_SHARED, ring->irq_name, ring);
 	if (ret)
@@ -635,6 +636,7 @@ static int xgene_enet_register_irq(struct net_device *ndev)
 
 	if (pdata->cq_cnt) {
 		ring = pdata->tx_ring->cp_ring;
+		irq_set_status_flags(ring->irq, IRQ_DISABLE_UNLAZY);
 		ret = devm_request_irq(dev, ring->irq, xgene_enet_rx_irq,
 				       IRQF_SHARED, ring->irq_name, ring);
 		if (ret) {
@@ -649,15 +651,19 @@ static int xgene_enet_register_irq(struct net_device *ndev)
 static void xgene_enet_free_irq(struct net_device *ndev)
 {
 	struct xgene_enet_pdata *pdata;
+	struct xgene_enet_desc_ring *ring;
 	struct device *dev;
 
 	pdata = netdev_priv(ndev);
 	dev = ndev_to_dev(ndev);
-	devm_free_irq(dev, pdata->rx_ring->irq, pdata->rx_ring);
+	ring = pdata->rx_ring;
+	irq_clear_status_flags(ring->irq, IRQ_DISABLE_UNLAZY);
+	devm_free_irq(dev, ring->irq, ring);
 
 	if (pdata->cq_cnt) {
-		devm_free_irq(dev, pdata->tx_ring->cp_ring->irq,
-			      pdata->tx_ring->cp_ring);
+		ring = pdata->tx_ring->cp_ring;
+		irq_clear_status_flags(ring->irq, IRQ_DISABLE_UNLAZY);
+		devm_free_irq(dev, ring->irq, ring);
 	}
 }
 
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index 70d5b62..248dfc4 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -25,6 +25,7 @@
 #include <linux/acpi.h>
 #include <linux/clk.h>
 #include <linux/efi.h>
+#include <linux/irq.h>
 #include <linux/io.h>
 #include <linux/of_platform.h>
 #include <linux/of_net.h>
-- 
1.9.1
