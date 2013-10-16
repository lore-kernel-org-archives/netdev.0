From: Nikita Kiryanov <nikita@compulab.co.il>
Subject: [PATCH 4/4] dm9000: report the correct LPA
Date: Wed, 16 Oct 2013 11:41:34 +0300
Message-ID: <1381912894-4780-5-git-send-email-nikita@compulab.co.il>
References: <1381912894-4780-1-git-send-email-nikita@compulab.co.il>
Cc: Nikita Kiryanov <nikita@compulab.co.il>,
	"David S. Miller" <davem@davemloft.net>,
	Jingoo Han <jg1.han@samsung.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Igor Grinberg <grinberg@compulab.co.il>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from softlayer.compulab.co.il ([50.23.254.55]:52179 "EHLO
	compulab.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758281Ab3JPImK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 04:42:10 -0400
In-Reply-To: <1381912894-4780-1-git-send-email-nikita@compulab.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Report the LPA by checking mii_if_info, instead of just saying "no LPA" every
time.

Cc: David S. Miller <davem@davemloft.net>
Cc: Jingoo Han <jg1.han@samsung.com>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
Signed-off-by: Nikita Kiryanov <nikita@compulab.co.il>
Signed-off-by: Igor Grinberg <grinberg@compulab.co.il>
---
 drivers/net/ethernet/davicom/dm9000.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index a179f81..a7a941b 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -753,15 +753,20 @@ static const struct ethtool_ops dm9000_ethtool_ops = {
 static void dm9000_show_carrier(board_info_t *db,
 				unsigned carrier, unsigned nsr)
 {
+	int lpa;
 	struct net_device *ndev = db->ndev;
+	struct mii_if_info *mii = &db->mii;
 	unsigned ncr = dm9000_read_locked(db, DM9000_NCR);
 
-	if (carrier)
-		dev_info(db->dev, "%s: link up, %dMbps, %s-duplex, no LPA\n",
+	if (carrier) {
+		lpa = mii->mdio_read(mii->dev, mii->phy_id, MII_LPA);
+		dev_info(db->dev,
+			 "%s: link up, %dMbps, %s-duplex, lpa 0x%04X\n",
 			 ndev->name, (nsr & NSR_SPEED) ? 10 : 100,
-			 (ncr & NCR_FDX) ? "full" : "half");
-	else
+			 (ncr & NCR_FDX) ? "full" : "half", lpa);
+	} else {
 		dev_info(db->dev, "%s: link down\n", ndev->name);
+	}
 }
 
 static void
-- 
1.8.1.2
