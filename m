From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 08/11] bnxt_en: fix clearing devlink ptr from bnxt struct
Date: Mon, 28 Aug 2017 13:40:32 -0400
Message-ID: <1503942035-24924-9-git-send-email-michael.chan@broadcom.com>
References: <1503942035-24924-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org, Sathya Perla <sathya.perla@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:36292 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751493AbdH1Rk7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 13:40:59 -0400
Received: by mail-qt0-f175.google.com with SMTP id v29so5266456qtv.3
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 10:40:59 -0700 (PDT)
In-Reply-To: <1503942035-24924-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@broadcom.com>

The routine bnxt_link_bp_to_dl() is used to set the devlink ptr
in bnxt struct (bp) and also to set the bnxt back ptr in
the devlink struct.  If devlink_register() fails, bp->dl must
be cleared which is not happening currently. This patch fixes
bnxt_link_bp_to_dl() to clear bp->dl by passing  a NULL dl ptr.

Fixes: 4ab0c6a8ffd7 ("bnxt_en: add support to enable VF-representors")
Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c |  4 ++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h | 14 +++++++++-----
 2 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
index 86cce6f..c365d3c 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
@@ -468,11 +468,11 @@ int bnxt_dl_register(struct bnxt *bp)
 		return -ENOMEM;
 	}
 
-	bnxt_link_bp_to_dl(dl, bp);
+	bnxt_link_bp_to_dl(bp, dl);
 	bp->eswitch_mode = DEVLINK_ESWITCH_MODE_LEGACY;
 	rc = devlink_register(dl, &bp->pdev->dev);
 	if (rc) {
-		bnxt_link_bp_to_dl(dl, NULL);
+		bnxt_link_bp_to_dl(bp, NULL);
 		devlink_free(dl);
 		netdev_warn(bp->dev, "devlink_register failed. rc=%d", rc);
 		return rc;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h
index e55a3b6..3e997c9 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h
@@ -24,13 +24,17 @@ static inline struct bnxt *bnxt_get_bp_from_dl(struct devlink *dl)
 	return ((struct bnxt_dl *)devlink_priv(dl))->bp;
 }
 
-static inline void bnxt_link_bp_to_dl(struct devlink *dl, struct bnxt *bp)
+/* To clear devlink pointer from bp, pass NULL dl */
+static inline void bnxt_link_bp_to_dl(struct bnxt *bp, struct devlink *dl)
 {
-	struct bnxt_dl *bp_dl = devlink_priv(dl);
+	bp->dl = dl;
 
-	bp_dl->bp = bp;
-	if (bp)
-		bp->dl = dl;
+	/* add a back pointer in dl to bp */
+	if (dl) {
+		struct bnxt_dl *bp_dl = devlink_priv(dl);
+
+		bp_dl->bp = bp;
+	}
 }
 
 int bnxt_dl_register(struct bnxt *bp);
-- 
1.8.3.1
