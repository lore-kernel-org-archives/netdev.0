From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 4/6] bnxt_en: Fix VF resource checking.
Date: Fri, 13 Oct 2017 21:09:32 -0400
Message-ID: <1507943374-13308-5-git-send-email-michael.chan@broadcom.com>
References: <1507943374-13308-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f172.google.com ([209.85.216.172]:43744 "EHLO
        mail-qt0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753479AbdJNBJu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 21:09:50 -0400
Received: by mail-qt0-f172.google.com with SMTP id j58so11575613qtj.0
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 18:09:50 -0700 (PDT)
In-Reply-To: <1507943374-13308-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In bnxt_sriov_enable(), we calculate to see if we have enough hardware
resources to enable the requested number of VFs.  The logic to check
for minimum completion rings and statistics contexts is missing.  Add
the required checks so that VF configuration won't fail.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
index d37925a..5ee1866 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
@@ -502,6 +502,7 @@ static int bnxt_sriov_enable(struct bnxt *bp, int *num_vfs)
 	int rc = 0, vfs_supported;
 	int min_rx_rings, min_tx_rings, min_rss_ctxs;
 	int tx_ok = 0, rx_ok = 0, rss_ok = 0;
+	int avail_cp, avail_stat;
 
 	/* Check if we can enable requested num of vf's. At a mininum
 	 * we require 1 RX 1 TX rings for each VF. In this minimum conf
@@ -509,6 +510,10 @@ static int bnxt_sriov_enable(struct bnxt *bp, int *num_vfs)
 	 */
 	vfs_supported = *num_vfs;
 
+	avail_cp = bp->pf.max_cp_rings - bp->cp_nr_rings;
+	avail_stat = bp->pf.max_stat_ctxs - bp->num_stat_ctxs;
+	avail_cp = min_t(int, avail_cp, avail_stat);
+
 	while (vfs_supported) {
 		min_rx_rings = vfs_supported;
 		min_tx_rings = vfs_supported;
@@ -523,10 +528,12 @@ static int bnxt_sriov_enable(struct bnxt *bp, int *num_vfs)
 			    min_rx_rings)
 				rx_ok = 1;
 		}
-		if (bp->pf.max_vnics - bp->nr_vnics < min_rx_rings)
+		if (bp->pf.max_vnics - bp->nr_vnics < min_rx_rings ||
+		    avail_cp < min_rx_rings)
 			rx_ok = 0;
 
-		if (bp->pf.max_tx_rings - bp->tx_nr_rings >= min_tx_rings)
+		if (bp->pf.max_tx_rings - bp->tx_nr_rings >= min_tx_rings &&
+		    avail_cp >= min_tx_rings)
 			tx_ok = 1;
 
 		if (bp->pf.max_rsscos_ctxs - bp->rsscos_nr_ctxs >= min_rss_ctxs)
-- 
1.8.3.1
