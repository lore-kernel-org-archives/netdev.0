From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] dmfe: check pci_alloc_consistent errors
Date: Thu, 23 Oct 2008 18:01:13 +0900
Message-ID: <20081023180005A.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:50696 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751572AbYJWJBP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Oct 2008 05:01:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to check the address that pci_alloc_consistent() returns since
it might fail.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 drivers/net/tulip/dmfe.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index 8e46a51..c91852f 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -420,9 +420,13 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 	/* Allocate Tx/Rx descriptor memory */
 	db->desc_pool_ptr = pci_alloc_consistent(pdev, sizeof(struct tx_desc) *
 			DESC_ALL_CNT + 0x20, &db->desc_pool_dma_ptr);
+	if (!db->desc_pool_ptr)
+		goto err_out_res;
 
 	db->buf_pool_ptr = pci_alloc_consistent(pdev, TX_BUF_ALLOC *
 			TX_DESC_CNT + 4, &db->buf_pool_dma_ptr);
+	if (!db->buf_pool_ptr)
+		goto err_out_free_desc;
 
 	db->first_tx_desc = (struct tx_desc *) db->desc_pool_ptr;
 	db->first_tx_desc_dma = db->desc_pool_dma_ptr;
@@ -469,7 +473,7 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 
 	err = register_netdev (dev);
 	if (err)
-		goto err_out_res;
+		goto err_out_free_buf;
 
 	printk(KERN_INFO "%s: Davicom DM%04lx at pci%s, "
 	       "%s, irq %d.\n",
@@ -483,6 +487,12 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 
 	return 0;
 
+err_out_free_buf:
+	pci_free_consistent(pdev, TX_BUF_ALLOC * TX_DESC_CNT + 4,
+			    db->buf_pool_ptr, db->buf_pool_dma_ptr);
+err_out_free_desc:
+	pci_free_consistent(pdev, sizeof(struct tx_desc) * DESC_ALL_CNT + 0x20,
+			    db->desc_pool_ptr, db->desc_pool_dma_ptr);
 err_out_res:
 	pci_release_regions(pdev);
 err_out_disable:
-- 
1.5.5.GIT

