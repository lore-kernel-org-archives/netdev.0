From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH v3 8/8] b44: use fixed PHY device if we do not find any
Date: Fri, 20 Dec 2013 02:16:13 +0100
Message-ID: <1387502173-21743-9-git-send-email-hauke@hauke-m.de>
References: <1387502173-21743-1-git-send-email-hauke@hauke-m.de>
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	f.fainelli@gmail.com, Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:53984 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932116Ab3LTBQw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 20:16:52 -0500
In-Reply-To: <1387502173-21743-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ADM6996L switch and some Broadcom switches with two MII interfaces
like the BCM5325F connected to two MACs on the SoC, used on some
routers do not return a valid value when reading the PHY id register
and Linux thinks there is no PHY at all, but that is wrong.
This patch registers a fixed phy in the arch code and then searches it
when there is no other phy in the Ethernet driver code.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 arch/mips/bcm47xx/setup.c           |   10 ++++++++++
 drivers/net/ethernet/broadcom/b44.c |   16 +++++++++++++++-
 drivers/net/ethernet/broadcom/b44.h |    3 +++
 3 files changed, 28 insertions(+), 1 deletion(-)

diff --git a/arch/mips/bcm47xx/setup.c b/arch/mips/bcm47xx/setup.c
index 1f30571..9057728 100644
--- a/arch/mips/bcm47xx/setup.c
+++ b/arch/mips/bcm47xx/setup.c
@@ -28,6 +28,9 @@
 
 #include <linux/export.h>
 #include <linux/types.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+#include <linux/phy_fixed.h>
 #include <linux/ssb/ssb.h>
 #include <linux/ssb/ssb_embedded.h>
 #include <linux/bcma/bcma_soc.h>
@@ -225,6 +228,12 @@ void __init plat_mem_setup(void)
 	bcm47xx_board_detect();
 }
 
+static struct fixed_phy_status bcm47xx_fixed_phy_status __initdata = {
+	.link	= 1,
+	.speed	= SPEED_100,
+	.duplex	= DUPLEX_FULL,
+};
+
 static int __init bcm47xx_register_bus_complete(void)
 {
 	switch (bcm47xx_bus_type) {
@@ -239,6 +248,7 @@ static int __init bcm47xx_register_bus_complete(void)
 		break;
 #endif
 	}
+	fixed_phy_add(PHY_POLL, 0, &bcm47xx_fixed_phy_status);
 	return 0;
 }
 device_initcall(bcm47xx_register_bus_complete);
diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 839dd90..1f7b5aa 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -2233,6 +2233,7 @@ static int b44_register_phy_one(struct b44 *bp)
 	struct ssb_device *sdev = bp->sdev;
 	struct phy_device *phydev;
 	char bus_id[MII_BUS_ID_SIZE + 3];
+	struct ssb_sprom *sprom = &sdev->bus->sprom;
 	int err;
 
 	mii_bus = mdiobus_alloc();
@@ -2266,7 +2267,20 @@ static int b44_register_phy_one(struct b44 *bp)
 		goto err_out_mdiobus_irq;
 	}
 
-	snprintf(bus_id, sizeof(bus_id), PHY_ID_FMT, mii_bus->id, bp->phy_addr);
+	if (!bp->mii_bus->phy_map[bp->phy_addr] &&
+	    (sprom->boardflags_lo & (B44_BOARDFLAG_ROBO | B44_BOARDFLAG_ADM))) {
+
+		dev_info(sdev->dev,
+			 "could not find PHY at %i, use fixed one\n",
+			 bp->phy_addr);
+
+		bp->phy_addr = 0;
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
