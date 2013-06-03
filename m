From: Yijing Wang <wangyijing@huawei.com>
Subject: [PATCH] tg3: remove redundant pm init code
Date: Mon, 3 Jun 2013 15:36:21 +0800
Message-ID: <1370244981-11716-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Hanjun Guo <guohanjun@huawei.com>,
	Jiang Liu <liuj97@gmail.com>,
	Yijing Wang <wangyijing@huawei.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:26891 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818Ab3FCHhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 03:37:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pci_enable_device() will set device pm state to D0, so
it's no need to do it again in tg3_init_one().

Acked-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   24 +++---------------------
 1 files changed, 3 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 728d42a..ca5bc7e 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -17020,7 +17020,7 @@ static int tg3_init_one(struct pci_dev *pdev,
 {
 	struct net_device *dev;
 	struct tg3 *tp;
-	int i, err, pm_cap;
+	int i, err;
 	u32 sndmbx, rcvmbx, intmbx;
 	char str[40];
 	u64 dma_mask, persist_dma_mask;
@@ -17042,25 +17042,10 @@ static int tg3_init_one(struct pci_dev *pdev,
 
 	pci_set_master(pdev);
 
-	/* Find power-management capability. */
-	pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
-	if (pm_cap == 0) {
-		dev_err(&pdev->dev,
-			"Cannot find Power Management capability, aborting\n");
-		err = -EIO;
-		goto err_out_free_res;
-	}
-
-	err = pci_set_power_state(pdev, PCI_D0);
-	if (err) {
-		dev_err(&pdev->dev, "Transition to D0 failed, aborting\n");
-		goto err_out_free_res;
-	}
-
 	dev = alloc_etherdev_mq(sizeof(*tp), TG3_IRQ_MAX_VECS);
 	if (!dev) {
 		err = -ENOMEM;
-		goto err_out_power_down;
+		goto err_out_free_res;
 	}
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
@@ -17068,7 +17053,7 @@ static int tg3_init_one(struct pci_dev *pdev,
 	tp = netdev_priv(dev);
 	tp->pdev = pdev;
 	tp->dev = dev;
-	tp->pm_cap = pm_cap;
+	tp->pm_cap = pdev->pm_cap;
 	tp->rx_mode = TG3_DEF_RX_MODE;
 	tp->tx_mode = TG3_DEF_TX_MODE;
 	tp->irq_sync = 1;
@@ -17406,9 +17391,6 @@ err_out_iounmap:
 err_out_free_dev:
 	free_netdev(dev);
 
-err_out_power_down:
-	pci_set_power_state(pdev, PCI_D3hot);
-
 err_out_free_res:
 	pci_release_regions(pdev);
 
-- 
1.7.1
