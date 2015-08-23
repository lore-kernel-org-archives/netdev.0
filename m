From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 9/9] phy: fixed_phy: Set phy capabilities even when link is down
Date: Sun, 23 Aug 2015 11:47:00 +0200
Message-ID: <1440323220-20438-10-git-send-email-andrew@lunn.ch>
References: <1440323220-20438-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38106 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752345AbbHWJzt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Aug 2015 05:55:49 -0400
In-Reply-To: <1440323220-20438-1-git-send-email-andrew@lunn.ch>
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
the link status and auto-negotiation complete bit unset, but set all
the other bits depending on the fixed phy speed.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/fixed_phy.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index 14ab80899e77..ff4869222c27 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -57,9 +57,8 @@ static int fixed_phy_update_regs(struct fixed_phy *fp)
 	if (gpio_is_valid(fp->link_gpio))
 		fp->status.link = !!gpio_get_value_cansleep(fp->link_gpio);
 
-	if (!fp->status.link)
-		goto done;
-	bmsr |= BMSR_LSTATUS | BMSR_ANEGCOMPLETE;
+	if (fp->status.link)
+		bmsr |= BMSR_LSTATUS | BMSR_ANEGCOMPLETE;
 
 	if (fp->status.duplex) {
 		bmcr |= BMCR_FULLDPLX;
@@ -111,7 +110,6 @@ static int fixed_phy_update_regs(struct fixed_phy *fp)
 	if (fp->status.asym_pause)
 		lpa |= LPA_PAUSE_ASYM;
 
-done:
 	fp->regs[MII_PHYSID1] = 0;
 	fp->regs[MII_PHYSID2] = 0;
 
-- 
2.5.0
