From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 8/8] b44: add dummy PHY device if we do not find any
Date: Sun, 15 Dec 2013 19:42:05 +0100
Message-ID: <1387132925-18651-9-git-send-email-hauke@hauke-m.de>
References: <1387132925-18651-1-git-send-email-hauke@hauke-m.de>
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:50629 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752000Ab3LOSmd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Dec 2013 13:42:33 -0500
In-Reply-To: <1387132925-18651-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ADM6996L switches used on some routers do not return a valid value
when reading the PHY id register and Linux thinks there is not PHY at
all, but that is wrong. This created a dummy PHY and uses that instead.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/b44.c |   23 +++++++++++++++++++----
 drivers/net/ethernet/broadcom/b44.h |    3 +++
 2 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index b65a463..07e58c2 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -2233,6 +2233,8 @@ static int b44_register_phy_one(struct b44 *bp)
 	struct ssb_device *sdev = bp->sdev;
 	struct phy_device *phydev;
 	int err;
+	struct phy_c45_device_ids c45_ids = {0};
+	struct ssb_sprom *sprom = &sdev->bus->sprom;
 
 	mii_bus = mdiobus_alloc();
 	if (!mii_bus) {
@@ -2266,10 +2268,23 @@ static int b44_register_phy_one(struct b44 *bp)
 	}
 
 	phydev = bp->mii_bus->phy_map[bp->phy_addr];
-	if (!phydev) {
-		dev_err(sdev->dev, "could not find PHY at %i\n", bp->phy_addr);
-		err = -ENODEV;
-		goto err_out_mdiobus_unregister;
+	if (!phydev &&
+	    (sprom->boardflags_lo & (B44_BOARDFLAG_ROBO | B44_BOARDFLAG_ADM))) {
+		dev_info(sdev->dev, "could not find PHY at %i, create dummy one\n",
+			 bp->phy_addr);
+
+		phydev = phy_device_create(bp->mii_bus, bp->phy_addr, 0x0,
+					   false, &c45_ids);
+		if (IS_ERR(phydev)) {
+			err = PTR_ERR(phydev);
+			dev_err(sdev->dev, "Can not create dummy PHY\n");
+			goto err_out_mdiobus_unregister;
+		}
+		err = phy_device_register(phydev);
+		if (err) {
+			dev_err(sdev->dev, "failed to register MII bus\n");
+			goto err_out_mdiobus_unregister;
+		}
 	}
 
 	err = phy_connect_direct(bp->dev, phydev, &b44_adjust_link,
diff --git a/drivers/net/ethernet/broadcom/b44.h b/drivers/net/ethernet/broadcom/b44.h
index c5ec9b4..e6780fe 100644
--- a/drivers/net/ethernet/broadcom/b44.h
+++ b/drivers/net/ethernet/broadcom/b44.h
@@ -345,6 +345,9 @@ B44_STAT_REG_DECLARE
 	struct u64_stats_sync	syncp;
 };
 
+#define	B44_BOARDFLAG_ROBO		0x0010  /* Board has robo switch */
+#define	B44_BOARDFLAG_ADM		0x0080  /* Board has ADMtek switch */
+
 struct ssb_device;
 
 struct b44 {
-- 
1.7.10.4
