From: David Miller <davem@davemloft.net>
Subject: Re: Small glitch in neptune ethernet driver
Date: Thu, 01 Dec 2011 22:00:03 -0500 (EST)
Message-ID: <20111201.220003.905428158537118068.davem@davemloft.net>
References: <4EA845CF.6070401@intra2net.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.jarosch@intra2net.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756485Ab1LBDAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 22:00:11 -0500
In-Reply-To: <4EA845CF.6070401@intra2net.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Date: Wed, 26 Oct 2011 19:39:27 +0200

> 	if (type == PHY_TYPE_PMA_PMD || type == PHY_TYPE_PCS) {
> 		if (((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_BCM8704) &&
> 		    ((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_MRVL88X2011) &&
> 		    ((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_BCM8706))
> 			return 0;
> 	}
> ...
> }
> 
> Here are the defines from sun/niu.h:
> 
> #define NIU_PHY_ID_MASK         0xfffff0f0
> #define NIU_PHY_ID_BCM8704      0x00206030
> #define NIU_PHY_ID_BCM8706      0x00206035
> 
> There's a zero at the end of the ID_MASK,
> so the NIU_PHY_ID_BCM8706 will never match (ends on 5).
> 
> Report from cppcheck:
> [sun/niu.c:8594]: (style) Mismatching comparison, the result is always true
> 
> The code will probably still work as the id for BCM8706
> should match on NIU_PHY_ID_BCM8704, too.

Thanks for pointing this out, I'll remove the extra test but add a
comment explaining the situation nearby, as follows:

--------------------
niu: Remove redundant PHY ID test.

Reported-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/sun/niu.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 680b107..56d106e 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -8579,9 +8579,11 @@ static int __devinit phy_record(struct niu_parent *parent,
 	if (dev_id_1 < 0 || dev_id_2 < 0)
 		return 0;
 	if (type == PHY_TYPE_PMA_PMD || type == PHY_TYPE_PCS) {
+		/* Becuase of the NIU_PHY_ID_MASK being applied, the 8704
+		 * test covers the 8706 as well.
+		 */
 		if (((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_BCM8704) &&
-		    ((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_MRVL88X2011) &&
-		    ((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_BCM8706))
+		    ((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_MRVL88X2011))
 			return 0;
 	} else {
 		if ((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_BCM5464R)
-- 
1.7.7.3
