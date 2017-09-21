From: Brandon Streiff <brandon.streiff@ni.com>
Subject: Re: net: macb: fail when there's no PHY
Date: Thu, 21 Sep 2017 16:35:51 -0500
Message-ID: <1506029751-25249-1-git-send-email-brandon.streiff@ni.com>
References: <20170921203608.GB30148@grante>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Brandon Streiff <brandon.streiff@ni.com>
To: Grant Edwards <grant.b.edwards@gmail.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00010702.pphosted.com ([148.163.156.75]:42132 "EHLO
        mx0b-00010702.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751697AbdIUVgq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 17:36:46 -0400
In-Reply-To: <20170921203608.GB30148@grante>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Thu, Sep 21, 2017 at 01:05:57PM -0700, Florian Fainelli wrote:
>
>>> It looks like the macb driver still can't handle boards that don't
>>> have a PHY.  Is that correct?
>> 
>> Not since:
>> 
>> dacdbb4dfc1a1a1378df8ebc914d4fe82259ed46 ("net: macb: add fixed-link
>> node support")
>
> Yep, it's obvious now that I've got the diff in front of me.
>
> Thanks!
>
> [I just started working with device tree for the first time yesterday,
> and I must say it's way better than the "old days" which required all
> sorts of ugly to produce a kernel that could work on two slightly
> different boards.]
>
> -- 
> Grant

I have a board that's in a similar boat. My workaround was to undo
portions of dacdbb4dfc1a with the following patch; this lets me still
use fixed-link and have MDIO (to configure a switch), but not require
a PHY.

There was a patch set last year by Harini Katakam ("net: macb: Add MDIO
driver for accessing multiple PHY devices") that might ultimately be a
better approach to tackling this problem, although I haven't seen any
further chatter on it.

---
 drivers/net/ethernet/cadence/macb_main.c | 38 +++++++++++++++-----------------
 1 file changed, 18 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb_main.c b/drivers/net/ethernet/cadence/macb_main.c
index 1741cda..a45848e 100644
--- a/drivers/net/ethernet/cadence/macb_main.c
+++ b/drivers/net/ethernet/cadence/macb_main.c
@@ -564,30 +564,28 @@ static int macb_mii_init(struct macb *bp)
 				goto err_out_unregister_bus;
 			}
 			bp->phy_node = of_node_get(np);
+		}
 
-			err = mdiobus_register(bp->mii_bus);
-		} else {
-			/* try dt phy registration */
-			err = of_mdiobus_register(bp->mii_bus, np);
+		/* try dt phy registration */
+		err = of_mdiobus_register(bp->mii_bus, np);
 
-			/* fallback to standard phy registration if no phy were
-			 * found during dt phy registration
-			 */
-			if (!err && !phy_find_first(bp->mii_bus)) {
-				for (i = 0; i < PHY_MAX_ADDR; i++) {
-					struct phy_device *phydev;
-
-					phydev = mdiobus_scan(bp->mii_bus, i);
-					if (IS_ERR(phydev) &&
-					    PTR_ERR(phydev) != -ENODEV) {
-						err = PTR_ERR(phydev);
-						break;
-					}
+		/* fallback to standard phy registration if no phy were
+		 * found during dt phy registration
+		 */
+		if (!err && !phy_find_first(bp->mii_bus)) {
+			for (i = 0; i < PHY_MAX_ADDR; i++) {
+				struct phy_device *phydev;
+
+				phydev = mdiobus_scan(bp->mii_bus, i);
+				if (IS_ERR(phydev) &&
+				    PTR_ERR(phydev) != -ENODEV) {
+					err = PTR_ERR(phydev);
+					break;
 				}
-
-				if (err)
-					goto err_out_unregister_bus;
 			}
+
+			if (err)
+				goto err_out_unregister_bus;
 		}
 	} else {
 		for (i = 0; i < PHY_MAX_ADDR; i++)
-- 
2.1.4
