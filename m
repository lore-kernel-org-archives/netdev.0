From: <netanel@amazon.com>
Subject: [PATCH net 5/9] net: ena: add missing unmap bars on device removal
Date: Sun, 11 Jun 2017 15:42:47 +0300
Message-ID: <1497184971-28178-6-git-send-email-netanel@amazon.com>
References: <1497184971-28178-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-9101.amazon.com ([207.171.184.25]:6266 "EHLO
        smtp-fw-9101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751850AbdFKMyP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 08:54:15 -0400
In-Reply-To: <1497184971-28178-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

This patch also change the mapping functions to devm_ functions

Fixes: 1738cd3ed342 ("Add a driver for Amazon Elastic Network Adapters (ENA)")
Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index 1e71e89e1e18..4e9fbddd3b47 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -2853,6 +2853,11 @@ static void ena_release_bars(struct ena_com_dev *ena_dev, struct pci_dev *pdev)
 {
 	int release_bars;
 
+	if (ena_dev->mem_bar)
+		devm_iounmap(&pdev->dev, ena_dev->mem_bar);
+
+	devm_iounmap(&pdev->dev, ena_dev->reg_bar);
+
 	release_bars = pci_select_bars(pdev, IORESOURCE_MEM) & ENA_BAR_MASK;
 	pci_release_selected_regions(pdev, release_bars);
 }
@@ -2940,8 +2945,9 @@ static int ena_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_free_ena_dev;
 	}
 
-	ena_dev->reg_bar = ioremap(pci_resource_start(pdev, ENA_REG_BAR),
-				   pci_resource_len(pdev, ENA_REG_BAR));
+	ena_dev->reg_bar = devm_ioremap(&pdev->dev,
+					pci_resource_start(pdev, ENA_REG_BAR),
+					pci_resource_len(pdev, ENA_REG_BAR));
 	if (!ena_dev->reg_bar) {
 		dev_err(&pdev->dev, "failed to remap regs bar\n");
 		rc = -EFAULT;
@@ -2961,8 +2967,9 @@ static int ena_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	ena_set_push_mode(pdev, ena_dev, &get_feat_ctx);
 
 	if (ena_dev->tx_mem_queue_type == ENA_ADMIN_PLACEMENT_POLICY_DEV) {
-		ena_dev->mem_bar = ioremap_wc(pci_resource_start(pdev, ENA_MEM_BAR),
-					      pci_resource_len(pdev, ENA_MEM_BAR));
+		ena_dev->mem_bar = devm_ioremap_wc(&pdev->dev,
+						   pci_resource_start(pdev, ENA_MEM_BAR),
+						   pci_resource_len(pdev, ENA_MEM_BAR));
 		if (!ena_dev->mem_bar) {
 			rc = -EFAULT;
 			goto err_device_destroy;
-- 
2.7.4
