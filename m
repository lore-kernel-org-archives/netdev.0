From: Veaceslav Falico <vfalico@redhat.com>
Subject: pch_gbe: set dma mask to only 32 bit
Date: Tue, 7 Feb 2012 20:23:54 +0100
Message-ID: <20120207192354.GA7770@darkmag.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19362 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752447Ab2BGTYD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Feb 2012 14:24:03 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because pch_gbe_rx_desc->buffer_addr is u32, we cannot set dma mask to 64
bit or otherwise we could end up loosing the higher 32 bit from the return
of dma_map_single(). Removing DMA_BIT_MASK(64) setting will solve it.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 3ead111..6c6713b 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -2397,17 +2397,13 @@ static int pch_gbe_probe(struct pci_dev *pdev,
 	if (ret)
 		return ret;
 
-	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(64))
-		|| pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64))) {
-		ret = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
+	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
+		ret = pci_set_consistent_dma_mask(pdev,
+						  DMA_BIT_MASK(32));
 		if (ret) {
-			ret = pci_set_consistent_dma_mask(pdev,
-							  DMA_BIT_MASK(32));
-			if (ret) {
-				dev_err(&pdev->dev, "ERR: No usable DMA "
-					"configuration, aborting\n");
-				goto err_disable_device;
-			}
+			dev_err(&pdev->dev, "ERR: No usable DMA "
+				"configuration, aborting\n");
+			goto err_disable_device;
 		}
 	}
 
