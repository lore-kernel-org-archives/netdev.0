From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: [PATCH net-next] tg3: Fix advertisement handling
Date: Mon, 21 Nov 2011 08:07:20 +0900
Message-ID: <20111121080720.0e68f096.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, mcarlson@broadcom.com, mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:65132 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754164Ab1KTXHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2011 18:07:24 -0500
Received: by iage36 with SMTP id e36so6490447iag.19
        for <netdev@vger.kernel.org>; Sun, 20 Nov 2011 15:07:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 28011cf19b (net: Add ethtool to mii advertisment conversion
helpers) added a helper function ethtool_adv_to_mii_100bt() and
tg3_copper_is_advertising_all(), tg3_phy_autoneg_cfg() were
modified to use this.
Before that commit, ethtool to mii advertisement conversion was
done wrt speed, but now pause operation is also taken account.
So, in tg3_copper_is_advertising_all(), below condition becomes
true and this makes link up fails.

	if ((adv_reg & ADVERTISE_ALL) != all_mask)
		return 0;

To fix this add ADVERTISE_ALL bit and operation to cap speed.

Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 024ca1d..c00e648 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -3594,7 +3594,7 @@ static int tg3_phy_autoneg_cfg(struct tg3 *tp, u32 advertise, u32 flowctrl)
 	u32 val, new_adv;
 
 	new_adv = ADVERTISE_CSMA;
-	new_adv |= ethtool_adv_to_mii_100bt(advertise);
+	new_adv |= ethtool_adv_to_mii_100bt(advertise) & ADVERTISE_ALL;
 	new_adv |= tg3_advert_flowctrl_1000T(flowctrl);
 
 	err = tg3_writephy(tp, MII_ADVERTISE, new_adv);
@@ -3783,7 +3783,7 @@ static int tg3_copper_is_advertising_all(struct tg3 *tp, u32 mask)
 	if (tg3_readphy(tp, MII_ADVERTISE, &adv_reg))
 		return 0;
 
-	if ((adv_reg & ADVERTISE_ALL) != all_mask)
+	if ((adv_reg & ADVERTISE_ALL) != (all_mask & ADVERTISE_ALL))
 		return 0;
 
 	if (!(tp->phy_flags & TG3_PHYFLG_10_100_ONLY)) {
