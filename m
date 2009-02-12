From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 15/41]bnx2x: PHY lock list
Date: Thu, 12 Feb 2009 20:36:58 +0200
Message-ID: <1234463818.1863.147.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2499 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758250AbZBLSpI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:45:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 15/41]bnx2x: PHY lock list
Some dual port PHY require HW lock since they are used by both interfaces
(different driver instances). Since this list is getting longer, update a
parameter at load time instead of calculating it on runtime

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    1 +
 drivers/net/bnx2x_main.c |   20 ++++++++++----------
 drivers/net/bnx2x_reg.h  |    2 +-
 3 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index d66be72..12d2d0b 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -570,6 +570,7 @@ struct bnx2x_port {
 
 	/* used to synchronize phy accesses */
 	struct mutex		phy_mutex;
+	int			need_hw_lock;
 
 	u32			port_stx;
 
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 5acbd98..2ee480b 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1816,22 +1816,16 @@ static int bnx2x_release_hw_lock(struct bnx2x *bp, u32 resource)
 /* HW Lock for shared dual port PHYs */
 static void bnx2x_acquire_phy_lock(struct bnx2x *bp)
 {
-	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config);
-
 	mutex_lock(&bp->port.phy_mutex);
 
-	if ((ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072) ||
-	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073))
-		bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_8072_MDIO);
+	if (bp->port.need_hw_lock)
+		bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_MDIO);
 }
 
 static void bnx2x_release_phy_lock(struct bnx2x *bp)
 {
-	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config);
-
-	if ((ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072) ||
-	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073))
-		bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_8072_MDIO);
+	if (bp->port.need_hw_lock)
+		bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_MDIO);
 
 	mutex_unlock(&bp->port.phy_mutex);
 }
@@ -5705,6 +5699,12 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	}
 
 	switch (XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config)) {
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
+		bp->port.need_hw_lock = 1;
+		break;
+
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
 		/* Fan failure is indicated by SPIO 5 */
 		bnx2x_set_spio(bp, MISC_REGISTERS_SPIO_5,
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index 520bf69..5cfeac9 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -5228,8 +5228,8 @@
 #define MISC_REGISTERS_SPIO_OUTPUT_LOW				 0
 #define MISC_REGISTERS_SPIO_SET_POS				 8
 #define HW_LOCK_MAX_RESOURCE_VALUE				 31
-#define HW_LOCK_RESOURCE_8072_MDIO				 0
 #define HW_LOCK_RESOURCE_GPIO					 1
+#define HW_LOCK_RESOURCE_MDIO					 0
 #define HW_LOCK_RESOURCE_PORT0_ATT_MASK 			 3
 #define HW_LOCK_RESOURCE_SPIO					 2
 #define HW_LOCK_RESOURCE_UNDI					 5
-- 
1.5.4.3




