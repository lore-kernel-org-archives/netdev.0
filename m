From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH] [bnx2]: Fix problem of using wrong IRQ handler.
Date: Wed, 18 Mar 2009 15:52:57 -0800
Message-ID: <1237420377-4444-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2317 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752603AbZCRXnW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2009 19:43:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MSI-X handler was chosen before the call to pci_enable_msix().
If MSI-X was not available, the wrong MSI-X handler would be used in
INTA mode.  This would cause a screaming interrupt problem because
INTA would not be cleared by the MSI-X handler.

Fixed by assigning MSI-X handler after pci_enable_msix() returns
successfully.  Also update version to 1.9.3.

Thomas Chenault <thomas_chenault@dell.com> helped us find this problem.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 6500b7c..6b6530f 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -57,8 +57,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.9.2"
-#define DRV_MODULE_RELDATE	"Feb 11, 2009"
+#define DRV_MODULE_VERSION	"1.9.3"
+#define DRV_MODULE_RELDATE	"March 17, 2009"
 
 #define RUN_AT(x) (jiffies + (x))
 
@@ -5843,9 +5843,6 @@ bnx2_enable_msix(struct bnx2 *bp, int msix_vecs)
 	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++) {
 		msix_ent[i].entry = i;
 		msix_ent[i].vector = 0;
-
-		snprintf(bp->irq_tbl[i].name, len, "%s-%d", dev->name, i);
-		bp->irq_tbl[i].handler = bnx2_msi_1shot;
 	}
 
 	rc = pci_enable_msix(bp->pdev, msix_ent, BNX2_MAX_MSIX_VEC);
@@ -5854,8 +5851,11 @@ bnx2_enable_msix(struct bnx2 *bp, int msix_vecs)
 
 	bp->irq_nvecs = msix_vecs;
 	bp->flags |= BNX2_FLAG_USING_MSIX | BNX2_FLAG_ONE_SHOT_MSI;
-	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++)
+	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++) {
 		bp->irq_tbl[i].vector = msix_ent[i].vector;
+		snprintf(bp->irq_tbl[i].name, len, "%s-%d", dev->name, i);
+		bp->irq_tbl[i].handler = bnx2_msi_1shot;
+	}
 }
 
 static void
-- 
1.5.6.GIT


