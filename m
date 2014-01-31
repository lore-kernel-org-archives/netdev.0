From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH 01/34] bnx2: Use pci_enable_msix_range()
Date: Fri, 31 Jan 2014 16:08:20 +0100
Message-ID: <434a34e01c353441131204edef36126a95e8928a.1391172839.git.agordeev@redhat.com>
References: <cover.1391172839.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
	Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36435 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753976AbaAaPHA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Jan 2014 10:07:00 -0500
In-Reply-To: <cover.1391172839.git.agordeev@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As result of deprecation of MSI-X/MSI enablement functions
pci_enable_msix() and pci_enable_msi_block() all drivers
using these two interfaces need to be updated to use the
new pci_enable_msi_range() and pci_enable_msix_range()
interfaces.

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |   15 ++++-----------
 1 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 9d2deda..3df63b2 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -6206,7 +6206,7 @@ bnx2_free_irq(struct bnx2 *bp)
 static void
 bnx2_enable_msix(struct bnx2 *bp, int msix_vecs)
 {
-	int i, total_vecs, rc;
+	int i, total_vecs;
 	struct msix_entry msix_ent[BNX2_MAX_MSIX_VEC];
 	struct net_device *dev = bp->dev;
 	const int len = sizeof(bp->irq_tbl[0].name);
@@ -6229,16 +6229,9 @@ bnx2_enable_msix(struct bnx2 *bp, int msix_vecs)
 #ifdef BCM_CNIC
 	total_vecs++;
 #endif
-	rc = -ENOSPC;
-	while (total_vecs >= BNX2_MIN_MSIX_VEC) {
-		rc = pci_enable_msix(bp->pdev, msix_ent, total_vecs);
-		if (rc <= 0)
-			break;
-		if (rc > 0)
-			total_vecs = rc;
-	}
-
-	if (rc != 0)
+	total_vecs = pci_enable_msix_range(bp->pdev, msix_ent,
+					   BNX2_MIN_MSIX_VEC, total_vecs);
+	if (total_vecs < 0)
 		return;
 
 	msix_vecs = total_vecs;
-- 
1.7.7.6
