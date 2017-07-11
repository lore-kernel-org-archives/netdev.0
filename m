From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 2/3] bnxt_en: Fix bug in ethtool -L.
Date: Tue, 11 Jul 2017 13:05:35 -0400
Message-ID: <1499792736-28697-3-git-send-email-michael.chan@broadcom.com>
References: <1499792736-28697-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:34387 "EHLO
        mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753958AbdGKRFu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 13:05:50 -0400
Received: by mail-qk0-f177.google.com with SMTP id d78so9181358qkb.1
        for <netdev@vger.kernel.org>; Tue, 11 Jul 2017 10:05:49 -0700 (PDT)
In-Reply-To: <1499792736-28697-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When changing channels from combined to rx/tx or vice versa, the code
uses the wrong "sh" parameter to determine if we are reserving rings
for shared or non-shared mode.  It should be using the ethtool requested
"sh" parameter instead of the current "sh" parameter.

Fix it by passing the "sh" parameter to bnxt_reserve_rings().  For
ethtool, we will pass in the requested "sh" parameter.

Fixes: 391be5c27364 ("bnxt_en: Implement new scheme to reserve tx rings.")
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 9 +++------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         | 3 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 3 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c     | 2 +-
 4 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 415694d..d9830d0 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -6918,16 +6918,13 @@ static void bnxt_sp_task(struct work_struct *work)
 }
 
 /* Under rtnl_lock */
-int bnxt_reserve_rings(struct bnxt *bp, int tx, int rx, int tcs, int tx_xdp)
+int bnxt_reserve_rings(struct bnxt *bp, int tx, int rx, bool sh, int tcs,
+		       int tx_xdp)
 {
 	int max_rx, max_tx, tx_sets = 1;
 	int tx_rings_needed;
-	bool sh = true;
 	int rc;
 
-	if (!(bp->flags & BNXT_FLAG_SHARED_RINGS))
-		sh = false;
-
 	if (tcs)
 		tx_sets = tcs;
 
@@ -7135,7 +7132,7 @@ int bnxt_setup_mq_tc(struct net_device *dev, u8 tc)
 		sh = true;
 
 	rc = bnxt_reserve_rings(bp, bp->tx_nr_rings_per_tc, bp->rx_nr_rings,
-				tc, bp->tx_nr_rings_xdp);
+				sh, tc, bp->tx_nr_rings_xdp);
 	if (rc)
 		return rc;
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 3c9d484..f34691f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1301,7 +1301,8 @@ int bnxt_hwrm_func_rgtr_async_events(struct bnxt *bp, unsigned long *bmap,
 int bnxt_half_open_nic(struct bnxt *bp);
 void bnxt_half_close_nic(struct bnxt *bp);
 int bnxt_close_nic(struct bnxt *, bool, bool);
-int bnxt_reserve_rings(struct bnxt *bp, int tx, int rx, int tcs, int tx_xdp);
+int bnxt_reserve_rings(struct bnxt *bp, int tx, int rx, bool sh, int tcs,
+		       int tx_xdp);
 int bnxt_setup_mq_tc(struct net_device *dev, u8 tc);
 int bnxt_get_max_rings(struct bnxt *, int *, int *, bool);
 void bnxt_restore_pf_fw_resources(struct bnxt *bp);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index fd11815..be6acad 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -432,7 +432,8 @@ static int bnxt_set_channels(struct net_device *dev,
 		}
 		tx_xdp = req_rx_rings;
 	}
-	rc = bnxt_reserve_rings(bp, req_tx_rings, req_rx_rings, tcs, tx_xdp);
+	rc = bnxt_reserve_rings(bp, req_tx_rings, req_rx_rings, sh, tcs,
+				tx_xdp);
 	if (rc) {
 		netdev_warn(dev, "Unable to allocate the requested rings\n");
 		return rc;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
index 7d67552..3961a68 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
@@ -170,7 +170,7 @@ static int bnxt_xdp_set(struct bnxt *bp, struct bpf_prog *prog)
 	if (!tc)
 		tc = 1;
 	rc = bnxt_reserve_rings(bp, bp->tx_nr_rings_per_tc, bp->rx_nr_rings,
-				tc, tx_xdp);
+				true, tc, tx_xdp);
 	if (rc) {
 		netdev_warn(dev, "Unable to reserve enough TX rings to support XDP.\n");
 		return rc;
-- 
1.8.3.1
