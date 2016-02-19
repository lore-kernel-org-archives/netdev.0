From: Andrew Lunn <andrew@lunn.ch>
Subject: [Patch net-next] phy: marvell/micrel: Fix Unpossible condition
Date: Sat, 20 Feb 2016 00:35:29 +0100
Message-ID: <1455924929-12462-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53729 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030337AbcBSXfr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 18:35:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 2b2427d06426 ("phy: micrel: Add ethtool statistics counters")
from Dec 30, 2015, leads to the following static checker
warning:

        drivers/net/phy/micrel.c:609 kszphy_get_stat()
        warn: unsigned 'val' is never less than zero.

drivers/net/phy/micrel.c
   602  static u64 kszphy_get_stat(struct phy_device *phydev, int i)
   603  {
   604          struct kszphy_hw_stat stat = kszphy_hw_stats[i];
   605          struct kszphy_priv *priv = phydev->priv;
   606          u64 val;
   607
   608          val = phy_read(phydev, stat.reg);
   609          if (val < 0) {
                    ^^^^^^^
Unpossible!

   610                  val = UINT64_MAX;
   611          } else {
   612                  val = val & ((1 << stat.bits) - 1);
   613                  priv->stats[i] += val;
   614                  val = priv->stats[i];
   615          }
   616
   617          return val;
   618  }

The same problem exists in the Marvell driver. Fix both.

Fixes: 2b2427d06426 ("phy: micrel: Add ethtool statistics counters")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Reported-by: Julia.Lawall <julia.lawall@lip6.fr>
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/marvell.c | 10 +++++-----
 drivers/net/phy/micrel.c  |  9 +++++----
 2 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 1dcbd3ff9e38..d0168f1a1bf0 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -1065,8 +1065,8 @@ static u64 marvell_get_stat(struct phy_device *phydev, int i)
 {
 	struct marvell_hw_stat stat = marvell_hw_stats[i];
 	struct marvell_priv *priv = phydev->priv;
-	int err, oldpage;
-	u64 val;
+	int err, oldpage, val;
+	u64 ret;
 
 	oldpage = phy_read(phydev, MII_MARVELL_PHY_PAGE);
 	err = phy_write(phydev, MII_MARVELL_PHY_PAGE,
@@ -1076,16 +1076,16 @@ static u64 marvell_get_stat(struct phy_device *phydev, int i)
 
 	val = phy_read(phydev, stat.reg);
 	if (val < 0) {
-		val = UINT64_MAX;
+		ret = UINT64_MAX;
 	} else {
 		val = val & ((1 << stat.bits) - 1);
 		priv->stats[i] += val;
-		val = priv->stats[i];
+		ret = priv->stats[i];
 	}
 
 	phy_write(phydev, MII_MARVELL_PHY_PAGE, oldpage);
 
-	return val;
+	return ret;
 }
 
 static void marvell_get_stats(struct phy_device *phydev,
diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 03833dbfca67..48219c83fb00 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -612,18 +612,19 @@ static u64 kszphy_get_stat(struct phy_device *phydev, int i)
 {
 	struct kszphy_hw_stat stat = kszphy_hw_stats[i];
 	struct kszphy_priv *priv = phydev->priv;
-	u64 val;
+	int val;
+	u64 ret;
 
 	val = phy_read(phydev, stat.reg);
 	if (val < 0) {
-		val = UINT64_MAX;
+		ret = UINT64_MAX;
 	} else {
 		val = val & ((1 << stat.bits) - 1);
 		priv->stats[i] += val;
-		val = priv->stats[i];
+		ret = priv->stats[i];
 	}
 
-	return val;
+	return ret;
 }
 
 static void kszphy_get_stats(struct phy_device *phydev,
-- 
2.7.0
