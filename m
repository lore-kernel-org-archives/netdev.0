From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 1/20 V2] drivers/net/ethernet/dec/tulip/dmfe.c: fix error return code
Date: Fri,  5 Oct 2012 22:41:03 +0200
Message-ID: <1349469667-6137-1-git-send-email-peter.senna@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Peter Senna Tschudin <peter.senna@gmail.com>
To: grundler@parisc-linux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:60237 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757275Ab2JEUlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 16:41:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Senna Tschudin <peter.senna@gmail.com>

The function dmfe_init_one() return 0 for success and negative value
for most of its internal tests failures. There are three exceptions
that are error cases going to err_out_*:. Fore this three cases the
function abort its success execution path, but returns non negative 
value, making it dificult for a caller function to notice the error.

This patch fixes the error cases that do not return negative values.

This was found by Coccinelle, but the code change was made by hand.
This patch is not robot generated.

A simplified version of the semantic match that finds this problem is
as follows: (http://coccinelle.lip6.fr/)

// <smpl>
(
if@p1 (\(ret < 0\|ret != 0\))
 { ... return ret; }
|
ret@p1 = 0
)
... when != ret = e1
    when != &ret
*if(...)
{
  ... when != ret = e2
      when forall
 return ret;
}
// </smpl>

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

---
Changes from V1:
	Updated commit message. See:
	http://www.kernelhub.org/?p=2&msg=139319

 drivers/net/ethernet/dec/tulip/dmfe.c |   12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethernet/dec/tulip/dmfe.c
index 4d6fe60..d23755e 100644
--- a/drivers/net/ethernet/dec/tulip/dmfe.c
+++ b/drivers/net/ethernet/dec/tulip/dmfe.c
@@ -446,13 +446,17 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 	/* Allocate Tx/Rx descriptor memory */
 	db->desc_pool_ptr = pci_alloc_consistent(pdev, sizeof(struct tx_desc) *
 			DESC_ALL_CNT + 0x20, &db->desc_pool_dma_ptr);
-	if (!db->desc_pool_ptr)
+	if (!db->desc_pool_ptr) {
+		err = -ENOMEM;
 		goto err_out_res;
+	}
 
 	db->buf_pool_ptr = pci_alloc_consistent(pdev, TX_BUF_ALLOC *
 			TX_DESC_CNT + 4, &db->buf_pool_dma_ptr);
-	if (!db->buf_pool_ptr)
+	if (!db->buf_pool_ptr) {
+		err = -ENOMEM;
 		goto err_out_free_desc;
+	}
 
 	db->first_tx_desc = (struct tx_desc *) db->desc_pool_ptr;
 	db->first_tx_desc_dma = db->desc_pool_dma_ptr;
@@ -462,8 +466,10 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 	db->chip_id = ent->driver_data;
 	/* IO type range. */
 	db->ioaddr = pci_iomap(pdev, 0, 0);
-	if (!db->ioaddr)
+	if (!db->ioaddr) {
+		err = -ENOMEM;
 		goto err_out_free_buf;
+	}
 
 	db->chip_revision = pdev->revision;
 	db->wol_mode = 0;
