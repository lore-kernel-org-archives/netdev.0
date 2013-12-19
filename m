From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH v2 9/9] b44: use fixed PHY device if we do not find any
Date: Thu, 19 Dec 2013 02:28:46 +0100
Message-ID: <1387416526-7394-10-git-send-email-hauke@hauke-m.de>
References: <1387416526-7394-1-git-send-email-hauke@hauke-m.de>
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	f.fainelli@gmail.com, Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:44368 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752515Ab3LSBaW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 20:30:22 -0500
In-Reply-To: <1387416526-7394-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ADM6996L switch and some Broadcom switches with two MII interfaces
like the BCM5325F connected to two MACs on the SoC, used on some
routers do not return a valid value when reading the PHY id register
and Linux thinks there is no PHY at all, but that is wrong.
This patch registers a fixed phy in such a case and make b44 use that
instead.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/b44.c |   42 ++++++++++++++++++++++++++++++++++-
 drivers/net/ethernet/broadcom/b44.h |    3 +++
 2 files changed, 44 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 839dd90..ea540cd 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -31,6 +31,7 @@
 #include <linux/ssb/ssb.h>
 #include <linux/slab.h>
 #include <linux/phy.h>
+#include <linux/phy_fixed.h>
 
 #include <asm/uaccess.h>
 #include <asm/io.h>
@@ -2233,6 +2234,11 @@ static int b44_register_phy_one(struct b44 *bp)
 	struct ssb_device *sdev = bp->sdev;
 	struct phy_device *phydev;
 	char bus_id[MII_BUS_ID_SIZE + 3];
+	struct ssb_sprom *sprom = &sdev->bus->sprom;
+	struct platform_device *pdev;
+	struct pdata_fixed_phy *pdata;
+	size_t pdata_size = sizeof(struct pdata_fixed_phy) +
+			    1 * sizeof(struct fixed_phy_conf);
 	int err;
 
 	mii_bus = mdiobus_alloc();
@@ -2266,7 +2272,41 @@ static int b44_register_phy_one(struct b44 *bp)
 		goto err_out_mdiobus_irq;
 	}
 
-	snprintf(bus_id, sizeof(bus_id), PHY_ID_FMT, mii_bus->id, bp->phy_addr);
+	if (!bp->mii_bus->phy_map[bp->phy_addr] &&
+	    (sprom->boardflags_lo & (B44_BOARDFLAG_ROBO | B44_BOARDFLAG_ADM))) {
+
+		dev_info(sdev->dev,
+			 "could not find PHY at %i, create fixed one\n",
+			 bp->phy_addr);
+
+		pdata = kzalloc(pdata_size, GFP_KERNEL);
+		if (!pdata) {
+			dev_err(sdev->dev, "fixed phy allocation failed\n");
+			err = -ENOMEM;
+			goto err_out_mdiobus_unregister;
+		}
+		pdata->phys_num = 1;
+		pdata->name = "fixed-0";
+		pdata->phys[0].phy_id = bp->phy_addr;
+		pdata->phys[0].status.duplex = DUPLEX_FULL;
+		pdata->phys[0].status.speed = SPEED_100;
+		pdata->phys[0].status.link = 1;
+		
+		pdev = platform_device_register_data(bp->sdev->dev, "fixed-phy", 0,
+						     pdata, pdata_size);
+		kfree(pdata);
+		if (IS_ERR(pdev)) {
+			err = PTR_ERR(pdev);
+			dev_err(sdev->dev,
+			        "fixed phy registration failed with %i\n", err);
+			goto err_out_mdiobus_unregister;
+		}
+		snprintf(bus_id, sizeof(bus_id), PHY_ID_FMT, "fixed-0",
+			 bp->phy_addr);
+	} else {
+		snprintf(bus_id, sizeof(bus_id), PHY_ID_FMT, mii_bus->id,
+			 bp->phy_addr);
+	}
 
 	phydev = phy_connect(bp->dev, bus_id, &b44_adjust_link,
 			     PHY_INTERFACE_MODE_MII);
diff --git a/drivers/net/ethernet/broadcom/b44.h b/drivers/net/ethernet/broadcom/b44.h
index de81639..3e9c3fc 100644
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
