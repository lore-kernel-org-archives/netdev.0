From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH net-next v2 2/3] net: ethernet: bgmac: unify code of the same family
Date: Wed,  8 Feb 2017 16:24:25 -0500
Message-ID: <1486589066-8302-3-git-send-email-jon.mason@broadcom.com>
References: <1486589066-8302-1-git-send-email-jon.mason@broadcom.com>
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:35939 "EHLO
        mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751045AbdBHVYx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 16:24:53 -0500
Received: by mail-qk0-f172.google.com with SMTP id 11so136912766qkl.3
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 13:24:48 -0800 (PST)
In-Reply-To: <1486589066-8302-1-git-send-email-jon.mason@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BCM471X and BCM535X are of the same family (from what I can derive from
internal documents).  Group them into the case statement together, which
results in more code reuse.

Also, use existing helper variables to make the code a little more
readable too.

Signed-off-by: Jon Mason <jon.mason@broadcom.com>
---
 drivers/net/ethernet/broadcom/bgmac-bcma.c | 64 +++++++++++++-----------------
 1 file changed, 28 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac-bcma.c b/drivers/net/ethernet/broadcom/bgmac-bcma.c
index 5ef60d4..f5c27f4 100644
--- a/drivers/net/ethernet/broadcom/bgmac-bcma.c
+++ b/drivers/net/ethernet/broadcom/bgmac-bcma.c
@@ -192,36 +192,50 @@ static int bgmac_probe(struct bcma_device *core)
 		goto err1;
 	}
 
-	bgmac->has_robosw = !!(core->bus->sprom.boardflags_lo &
-			       BGMAC_BFL_ENETROBO);
+	bgmac->has_robosw = !!(sprom->boardflags_lo & BGMAC_BFL_ENETROBO);
 	if (bgmac->has_robosw)
 		dev_warn(bgmac->dev, "Support for Roboswitch not implemented\n");
 
-	if (core->bus->sprom.boardflags_lo & BGMAC_BFL_ENETADM)
+	if (sprom->boardflags_lo & BGMAC_BFL_ENETADM)
 		dev_warn(bgmac->dev, "Support for ADMtek ethernet switch not implemented\n");
 
 	/* Feature Flags */
-	switch (core->bus->chipinfo.id) {
+	switch (ci->id) {
+	/* BCM 471X/535X family */
+	case BCMA_CHIP_ID_BCM4716:
+		bgmac->feature_flags |= BGMAC_FEAT_CLKCTLST;
+		/* fallthrough */
+	case BCMA_CHIP_ID_BCM47162:
+		bgmac->feature_flags |= BGMAC_FEAT_FLW_CTRL2;
+		bgmac->feature_flags |= BGMAC_FEAT_SET_RXQ_CLK;
+		break;
 	case BCMA_CHIP_ID_BCM5357:
+	case BCMA_CHIP_ID_BCM53572:
 		bgmac->feature_flags |= BGMAC_FEAT_SET_RXQ_CLK;
 		bgmac->feature_flags |= BGMAC_FEAT_CLKCTLST;
 		bgmac->feature_flags |= BGMAC_FEAT_FLW_CTRL1;
 		bgmac->feature_flags |= BGMAC_FEAT_SW_TYPE_PHY;
-		if (core->bus->chipinfo.pkg == BCMA_PKG_ID_BCM47186) {
-			bgmac->feature_flags |= BGMAC_FEAT_IOST_ATTACHED;
+		if (ci->pkg == BCMA_PKG_ID_BCM47188 ||
+		    ci->pkg == BCMA_PKG_ID_BCM47186) {
 			bgmac->feature_flags |= BGMAC_FEAT_SW_TYPE_RGMII;
+			bgmac->feature_flags |= BGMAC_FEAT_IOST_ATTACHED;
 		}
-		if (core->bus->chipinfo.pkg == BCMA_PKG_ID_BCM5358)
+		if (ci->pkg == BCMA_PKG_ID_BCM5358)
 			bgmac->feature_flags |= BGMAC_FEAT_SW_TYPE_EPHYRMII;
 		break;
-	case BCMA_CHIP_ID_BCM53572:
-		bgmac->feature_flags |= BGMAC_FEAT_SET_RXQ_CLK;
+	case BCMA_CHIP_ID_BCM53573:
 		bgmac->feature_flags |= BGMAC_FEAT_CLKCTLST;
-		bgmac->feature_flags |= BGMAC_FEAT_FLW_CTRL1;
-		bgmac->feature_flags |= BGMAC_FEAT_SW_TYPE_PHY;
-		if (core->bus->chipinfo.pkg == BCMA_PKG_ID_BCM47188) {
-			bgmac->feature_flags |= BGMAC_FEAT_SW_TYPE_RGMII;
+		bgmac->feature_flags |= BGMAC_FEAT_SET_RXQ_CLK;
+		if (ci->pkg == BCMA_PKG_ID_BCM47189)
 			bgmac->feature_flags |= BGMAC_FEAT_IOST_ATTACHED;
+		if (core->core_unit == 0) {
+			bgmac->feature_flags |= BGMAC_FEAT_CC4_IF_SW_TYPE;
+			if (ci->pkg == BCMA_PKG_ID_BCM47189)
+				bgmac->feature_flags |=
+					BGMAC_FEAT_CC4_IF_SW_TYPE_RGMII;
+		} else if (core->core_unit == 1) {
+			bgmac->feature_flags |= BGMAC_FEAT_IRQ_ID_OOB_6;
+			bgmac->feature_flags |= BGMAC_FEAT_CC7_IF_TYPE_RGMII;
 		}
 		break;
 	case BCMA_CHIP_ID_BCM4749:
@@ -229,18 +243,11 @@ static int bgmac_probe(struct bcma_device *core)
 		bgmac->feature_flags |= BGMAC_FEAT_CLKCTLST;
 		bgmac->feature_flags |= BGMAC_FEAT_FLW_CTRL1;
 		bgmac->feature_flags |= BGMAC_FEAT_SW_TYPE_PHY;
-		if (core->bus->chipinfo.pkg == 10) {
+		if (ci->pkg == 10) {
 			bgmac->feature_flags |= BGMAC_FEAT_SW_TYPE_RGMII;
 			bgmac->feature_flags |= BGMAC_FEAT_IOST_ATTACHED;
 		}
 		break;
-	case BCMA_CHIP_ID_BCM4716:
-		bgmac->feature_flags |= BGMAC_FEAT_CLKCTLST;
-		/* fallthrough */
-	case BCMA_CHIP_ID_BCM47162:
-		bgmac->feature_flags |= BGMAC_FEAT_FLW_CTRL2;
-		bgmac->feature_flags |= BGMAC_FEAT_SET_RXQ_CLK;
-		break;
 	/* bcm4707_family */
 	case BCMA_CHIP_ID_BCM4707:
 	case BCMA_CHIP_ID_BCM47094:
@@ -249,21 +256,6 @@ static int bgmac_probe(struct bcma_device *core)
 		bgmac->feature_flags |= BGMAC_FEAT_NO_RESET;
 		bgmac->feature_flags |= BGMAC_FEAT_FORCE_SPEED_2500;
 		break;
-	case BCMA_CHIP_ID_BCM53573:
-		bgmac->feature_flags |= BGMAC_FEAT_CLKCTLST;
-		bgmac->feature_flags |= BGMAC_FEAT_SET_RXQ_CLK;
-		if (ci->pkg == BCMA_PKG_ID_BCM47189)
-			bgmac->feature_flags |= BGMAC_FEAT_IOST_ATTACHED;
-		if (core->core_unit == 0) {
-			bgmac->feature_flags |= BGMAC_FEAT_CC4_IF_SW_TYPE;
-			if (ci->pkg == BCMA_PKG_ID_BCM47189)
-				bgmac->feature_flags |=
-					BGMAC_FEAT_CC4_IF_SW_TYPE_RGMII;
-		} else if (core->core_unit == 1) {
-			bgmac->feature_flags |= BGMAC_FEAT_IRQ_ID_OOB_6;
-			bgmac->feature_flags |= BGMAC_FEAT_CC7_IF_TYPE_RGMII;
-		}
-		break;
 	default:
 		bgmac->feature_flags |= BGMAC_FEAT_CLKCTLST;
 		bgmac->feature_flags |= BGMAC_FEAT_SET_RXQ_CLK;
-- 
2.7.4
