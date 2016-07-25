From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 2/3] bnxt_en: Log a message, if enabling NTUPLE filtering fails.
Date: Sun, 24 Jul 2016 23:21:56 -0400
Message-ID: <1469416917-29659-3-git-send-email-michael.chan@broadcom.com>
References: <1469416917-29659-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36798 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752628AbcGYDWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jul 2016 23:22:08 -0400
Received: by mail-pa0-f52.google.com with SMTP id pp5so56516559pac.3
        for <netdev@vger.kernel.org>; Sun, 24 Jul 2016 20:22:07 -0700 (PDT)
In-Reply-To: <1469416917-29659-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara-v.volam@broadcom.com>

If there are not enough resources to enable ntuple filtering,
log a warning message.

Signed-off-by: Vasundhara Volam <vasundhara-v.volam@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 7de7d7a..398ecba 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5790,8 +5790,14 @@ static bool bnxt_rfs_capable(struct bnxt *bp)
 		return false;
 
 	vnics = 1 + bp->rx_nr_rings;
-	if (vnics > pf->max_rsscos_ctxs || vnics > pf->max_vnics)
+	if (vnics > pf->max_rsscos_ctxs || vnics > pf->max_vnics) {
+		netdev_warn(bp->dev,
+			    "Not enough resources to support NTUPLE filters");
+		netdev_warn(bp->dev,
+			    "Enough NTUPLE resources for up to %d rx rings",
+			    min(pf->max_rsscos_ctxs - 1, pf->max_vnics - 1));
 		return false;
+	}
 
 	return true;
 #else
@@ -5804,7 +5810,7 @@ static netdev_features_t bnxt_fix_features(struct net_device *dev,
 {
 	struct bnxt *bp = netdev_priv(dev);
 
-	if (!bnxt_rfs_capable(bp))
+	if ((features & NETIF_F_NTUPLE) && !bnxt_rfs_capable(bp))
 		features &= ~NETIF_F_NTUPLE;
 
 	/* Both CTAG and STAG VLAN accelaration on the RX side have to be
-- 
1.8.3.1
