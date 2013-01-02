From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH v2] p54pci: don't return zero on failure paths in p54p_probe()
Date: Thu,  3 Jan 2013 00:06:47 +0400
Message-ID: <1357157207-20626-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	Christian Lamparter <chunkeey@googlemail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ispras.ru ([83.149.199.43]:58024 "EHLO mail.ispras.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752636Ab3ABUHU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jan 2013 15:07:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If pci_set_dma_mask() or pci_set_consistent_dma_mask() fails in p54p_probe(),
it breaks off initialization, deallocates all resources, but returns zero.
Similar issue is if check for returned value of pci_resource_len() fails.

The patch implements proper error code propagation.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
Acked-by: Christian Lamparter <chunkeey@googlemail.com>
---
 drivers/net/wireless/p54/p54pci.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/p54/p54pci.c b/drivers/net/wireless/p54/p54pci.c
index 933e5d9..57e3af8 100644
--- a/drivers/net/wireless/p54/p54pci.c
+++ b/drivers/net/wireless/p54/p54pci.c
@@ -559,6 +559,7 @@ static int p54p_probe(struct pci_dev *pdev,
 	mem_len = pci_resource_len(pdev, 0);
 	if (mem_len < sizeof(struct p54p_csr)) {
 		dev_err(&pdev->dev, "Too short PCI resources\n");
+		err = -ENODEV;
 		goto err_disable_dev;
 	}
 
@@ -568,8 +569,10 @@ static int p54p_probe(struct pci_dev *pdev,
 		goto err_disable_dev;
 	}
 
-	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) ||
-	    pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32))) {
+	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
+	if (!err)
+		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
+	if (err) {
 		dev_err(&pdev->dev, "No suitable DMA available\n");
 		goto err_free_reg;
 	}
-- 
1.7.9.5
