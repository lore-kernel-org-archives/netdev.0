From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] qlcnic: Fix a memory leak in error handling path
Date: Sun, 19 Feb 2017 10:35:05 +0100
Message-ID: <20170219093505.8620-1-christophe.jaillet@wanadoo.fr>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: harish.patil@cavium.com, manish.chopra@cavium.com,
        Dept-GELinuxNICDev@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp08.smtpout.orange.fr ([80.12.242.130]:37953 "EHLO
        smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750884AbdBSJfk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 04:35:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If 'dma_alloc_coherent()' fails, we should release resources allocated so
far, just as done in all other cases in this function.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
checkpatch.pl complains about '== NULL'. I have left it as-is because both
'== NULL' and '!' are already used in the file.
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index daf05155b732..d344e9d43832 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -573,8 +573,10 @@ int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
 		ptr = (__le32 *)dma_alloc_coherent(&pdev->dev, sizeof(u32),
 						   &tx_ring->hw_cons_phys_addr,
 						   GFP_KERNEL);
-		if (ptr == NULL)
-			return -ENOMEM;
+		if (ptr == NULL) {
+			err = -ENOMEM;
+			goto err_out_free;
+		}
 
 		tx_ring->hw_consumer = ptr;
 		/* cmd desc ring */
-- 
2.9.3
