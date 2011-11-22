From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: [PATCH net-next V2] tg3: Fix advertisement handling
Date: Tue, 22 Nov 2011 23:05:41 +0900
Message-ID: <20111122230541.f2f96c9e.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: davem@davemloft.net, mcarlson@broadcom.com, mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:41296 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753189Ab1KVOFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 09:05:46 -0500
Received: by vcbfk1 with SMTP id fk1so234088vcb.19
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 06:05:46 -0800 (PST)
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

To fix this add ADVERTISE_ALL bit and operation to cap speed,
and change default advertisement not including ADVERTISED_Pause.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
---
V2: change default advertisement not including ADVERTISED_Pause

 drivers/net/ethernet/broadcom/tg3.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index d9e9c8c..ff3c48a 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -3594,7 +3594,7 @@ static int tg3_phy_autoneg_cfg(struct tg3 *tp, u32 advertise, u32 flowctrl)
 	u32 val, new_adv;
 
 	new_adv = ADVERTISE_CSMA;
-	new_adv |= ethtool_adv_to_mii_adv_t(advertise);
+	new_adv |= ethtool_adv_to_mii_adv_t(advertise) & ADVERTISE_ALL;
 	new_adv |= tg3_advert_flowctrl_1000T(flowctrl);
 
 	err = tg3_writephy(tp, MII_ADVERTISE, new_adv);
@@ -3778,7 +3778,7 @@ static int tg3_copper_is_advertising_all(struct tg3 *tp, u32 mask)
 {
 	u32 adv_reg, all_mask = 0;
 
-	all_mask = ethtool_adv_to_mii_adv_t(mask);
+	all_mask = ethtool_adv_to_mii_adv_t(mask) & ADVERTISE_ALL;
 
 	if (tg3_readphy(tp, MII_ADVERTISE, &adv_reg))
 		return 0;
@@ -13199,8 +13199,7 @@ static u32 __devinit tg3_read_otp_phycfg(struct tg3 *tp)
 
 static void __devinit tg3_phy_init_link_config(struct tg3 *tp)
 {
-	u32 adv = ADVERTISED_Autoneg |
-		  ADVERTISED_Pause;
+	u32 adv = ADVERTISED_Autoneg;
 
 	if (!(tp->phy_flags & TG3_PHYFLG_10_100_ONLY))
 		adv |= ADVERTISED_1000baseT_Half |
