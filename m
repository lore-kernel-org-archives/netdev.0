From: Andrew Lunn <andrew@lunn.ch>
Subject: [Patch v2 RFT net-next 9/9] net: phy: fixed_phy: Set phy capabilities even when link down.
Date: Mon, 31 Aug 2015 15:56:54 +0200
Message-ID: <1441029414-20062-10-git-send-email-andrew@lunn.ch>
References: <1441029414-20062-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>, Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42619 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753260AbbHaOFE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Aug 2015 10:05:04 -0400
In-Reply-To: <1441029414-20062-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What features a phy supports is masked in genphy_config_init() by
looking at the PHYs BMSR register.

If the link is down, fixed_phy_update_regs() will only set the auto-
negotiation capable bit in BMSR. Thus genphy_config_init() comes to
the conclusion the PHY can only perform 10/Half, and masks out the
higher speed features. If however the link it up, BMSR is set to
indicate the speed the PHY is capable of auto-negotiating, and
genphy_config_init() does not mask out the high speed features.

To fix this, when the link is down, have fixed_phy_update_regs() leave
the link status, auto-negotiation complete, and link partner
capabilities unset, but set all the local capabilities depending on
the fixed phy speed.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/fixed_phy.c | 73 +++++++++++++++++++++++++++++----------------
 1 file changed, 48 insertions(+), 25 deletions(-)

diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index 1bb70e3cc03e..12c7eb2c604e 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -57,61 +57,84 @@ static int fixed_phy_update_regs(struct fixed_phy *fp)
 	if (gpio_is_valid(fp->link_gpio))
 		fp->status.link = !!gpio_get_value_cansleep(fp->link_gpio);
 
-	if (!fp->status.link)
-		goto done;
-	bmsr |= BMSR_LSTATUS | BMSR_ANEGCOMPLETE;
-
 	if (fp->status.duplex) {
-		bmcr |= BMCR_FULLDPLX;
-
 		switch (fp->status.speed) {
 		case 1000:
 			bmsr |= BMSR_ESTATEN;
-			bmcr |= BMCR_SPEED1000;
-			lpagb |= LPA_1000FULL;
 			break;
 		case 100:
 			bmsr |= BMSR_100FULL;
-			bmcr |= BMCR_SPEED100;
-			lpa |= LPA_100FULL;
 			break;
 		case 10:
 			bmsr |= BMSR_10FULL;
-			lpa |= LPA_10FULL;
 			break;
 		default:
-			pr_warn("fixed phy: unknown speed\n");
-			return -EINVAL;
+			break;
 		}
 	} else {
 		switch (fp->status.speed) {
 		case 1000:
 			bmsr |= BMSR_ESTATEN;
-			bmcr |= BMCR_SPEED1000;
-			lpagb |= LPA_1000HALF;
 			break;
 		case 100:
 			bmsr |= BMSR_100HALF;
-			bmcr |= BMCR_SPEED100;
-			lpa |= LPA_100HALF;
 			break;
 		case 10:
 			bmsr |= BMSR_10HALF;
-			lpa |= LPA_10HALF;
 			break;
 		default:
-			pr_warn("fixed phy: unknown speed\n");
-			return -EINVAL;
+			break;
 		}
 	}
 
-	if (fp->status.pause)
-		lpa |= LPA_PAUSE_CAP;
+	if (fp->status.link) {
+		bmsr |= BMSR_LSTATUS | BMSR_ANEGCOMPLETE;
+
+		if (fp->status.duplex) {
+			bmcr |= BMCR_FULLDPLX;
+
+			switch (fp->status.speed) {
+			case 1000:
+				bmcr |= BMCR_SPEED1000;
+				lpagb |= LPA_1000FULL;
+				break;
+			case 100:
+				bmcr |= BMCR_SPEED100;
+				lpa |= LPA_100FULL;
+				break;
+			case 10:
+				lpa |= LPA_10FULL;
+				break;
+			default:
+				pr_warn("fixed phy: unknown speed\n");
+				return -EINVAL;
+			}
+		} else {
+			switch (fp->status.speed) {
+			case 1000:
+				bmcr |= BMCR_SPEED1000;
+				lpagb |= LPA_1000HALF;
+				break;
+			case 100:
+				bmcr |= BMCR_SPEED100;
+				lpa |= LPA_100HALF;
+				break;
+			case 10:
+				lpa |= LPA_10HALF;
+				break;
+			default:
+				pr_warn("fixed phy: unknown speed\n");
+			return -EINVAL;
+			}
+		}
+
+		if (fp->status.pause)
+			lpa |= LPA_PAUSE_CAP;
 
-	if (fp->status.asym_pause)
-		lpa |= LPA_PAUSE_ASYM;
+		if (fp->status.asym_pause)
+			lpa |= LPA_PAUSE_ASYM;
+	}
 
-done:
 	fp->regs[MII_PHYSID1] = 0;
 	fp->regs[MII_PHYSID2] = 0;
 
-- 
2.5.0
