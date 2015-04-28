From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH 1/3] bnx2x: mark LRO as a fixed disabled feature if disable_tpa is set
Date: Tue, 28 Apr 2015 11:34:21 +0200
Message-ID: <1430213663-5657-2-git-send-email-mschmidt@redhat.com>
References: <1430213663-5657-1-git-send-email-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46091 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753104AbbD1Jea (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2015 05:34:30 -0400
In-Reply-To: <1430213663-5657-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If disable_tpa is set, remove NETIF_F_LRO from hw_features, so ethtool sees
it as "off [fixed]".

Note that setting the NETIF_F_LRO bit in dev->features in the 'else'
branch is not needed, because the bit was already set by
bnx2x_init_dev().

Then the check for disable_tpa in in bnx2x_fix_features() becomes unnecessary.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  | 4 ----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 2 +-
 2 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 3558a36b1c..dcdbd00d02 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -4834,10 +4834,6 @@ netdev_features_t bnx2x_fix_features(struct net_device *dev,
 		features &= ~NETIF_F_GRO;
 	}
 
-	/* Note: do not disable SW GRO in kernel when HW GRO is off */
-	if (bp->disable_tpa)
-		features &= ~NETIF_F_LRO;
-
 	return features;
 }
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index b9f85fccb4..2d067c937b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12108,10 +12108,10 @@ static int bnx2x_init_bp(struct bnx2x *bp)
 	/* Set TPA flags */
 	if (bp->disable_tpa) {
 		bp->flags &= ~(TPA_ENABLE_FLAG | GRO_ENABLE_FLAG);
+		bp->dev->hw_features &= ~NETIF_F_LRO;
 		bp->dev->features &= ~NETIF_F_LRO;
 	} else {
 		bp->flags |= (TPA_ENABLE_FLAG | GRO_ENABLE_FLAG);
-		bp->dev->features |= NETIF_F_LRO;
 	}
 
 	if (CHIP_IS_E1(bp))
-- 
2.1.0
