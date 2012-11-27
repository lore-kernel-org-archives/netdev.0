From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 6/9] bnx2x: Always take PHY lock
Date: Tue, 27 Nov 2012 15:46:33 +0200
Message-ID: <1354023996-3512-7-git-send-email-yanivr@broadcom.com>
References: <1354023996-3512-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1906 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754812Ab2K0Lr1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2012 06:47:27 -0500
In-Reply-To: <1354023996-3512-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Taking PHY lock is not required on some older designs, but we are removing this
complication and always taking it since it is always required on newer designs
and does not worth the code complication on the older boards.

Taking PHY lock was initially required only on specific boards which had their
MDC/MDIO bus crossed, but since this lock is now always required, for example,
when NCSI is present, the PHY lock will always be taken.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |    1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |    6 +--
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    7 ++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c   |   32 ++------------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h   |    6 ----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |   11 -------
 6 files changed, 11 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 19517b3..641d884 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -936,7 +936,6 @@ struct bnx2x_port {
 
 	/* used to synchronize phy accesses */
 	struct mutex		phy_mutex;
-	int			need_hw_lock;
 
 	u32			port_stx;
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 2d30979..8779ac1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -948,14 +948,12 @@ void bnx2x_acquire_phy_lock(struct bnx2x *bp)
 {
 	mutex_lock(&bp->port.phy_mutex);
 
-	if (bp->port.need_hw_lock)
-		bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_MDIO);
+	bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_MDIO);
 }
 
 void bnx2x_release_phy_lock(struct bnx2x *bp)
 {
-	if (bp->port.need_hw_lock)
-		bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_MDIO);
+	bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_MDIO);
 
 	mutex_unlock(&bp->port.phy_mutex);
 }
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index c40c025..e05f981 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -2660,20 +2660,25 @@ static int bnx2x_set_phys_id(struct net_device *dev,
 		return 1;	/* cycle on/off once per second */
 
 	case ETHTOOL_ID_ON:
+		bnx2x_acquire_phy_lock(bp);
 		bnx2x_set_led(&bp->link_params, &bp->link_vars,
 			      LED_MODE_ON, SPEED_1000);
+		bnx2x_release_phy_lock(bp);
 		break;
 
 	case ETHTOOL_ID_OFF:
+		bnx2x_acquire_phy_lock(bp);
 		bnx2x_set_led(&bp->link_params, &bp->link_vars,
 			      LED_MODE_FRONT_PANEL_OFF, 0);
-
+		bnx2x_release_phy_lock(bp);
 		break;
 
 	case ETHTOOL_ID_INACTIVE:
+		bnx2x_acquire_phy_lock(bp);
 		bnx2x_set_led(&bp->link_params, &bp->link_vars,
 			      LED_MODE_OPER,
 			      bp->link_vars.line_speed);
+		bnx2x_release_phy_lock(bp);
 	}
 
 	return 0;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index f5a310e..a5d7003 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -11290,8 +11290,7 @@ static struct bnx2x_phy phy_warpcore = {
 	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT,
 	.addr		= 0xff,
 	.def_md_devad	= 0,
-	.flags		= (FLAGS_HW_LOCK_REQUIRED |
-			   FLAGS_TX_ERROR_CHECK),
+	.flags		= FLAGS_TX_ERROR_CHECK,
 	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.mdio_ctrl	= 0,
@@ -11358,7 +11357,7 @@ static struct bnx2x_phy phy_8073 = {
 	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
 	.addr		= 0xff,
 	.def_md_devad	= 0,
-	.flags		= FLAGS_HW_LOCK_REQUIRED,
+	.flags		= 0,
 	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.mdio_ctrl	= 0,
@@ -11447,8 +11446,7 @@ static struct bnx2x_phy phy_8726 = {
 	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726,
 	.addr		= 0xff,
 	.def_md_devad	= 0,
-	.flags		= (FLAGS_HW_LOCK_REQUIRED |
-			   FLAGS_INIT_XGXS_FIRST |
+	.flags		= (FLAGS_INIT_XGXS_FIRST |
 			   FLAGS_TX_ERROR_CHECK),
 	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
@@ -12001,12 +11999,6 @@ static int bnx2x_populate_ext_phy(struct bnx2x *bp,
 					    SUPPORTED_100baseT_Full);
 	}
 
-	/* In case mdc/mdio_access of the external phy is different than the
-	 * mdc/mdio access of the XGXS, a HW lock must be taken in each access
-	 * to prevent one port interfere with another port's CL45 operations.
-	 */
-	if (mdc_mdio_access != SHARED_HW_CFG_MDC_MDIO_ACCESS1_BOTH)
-		phy->flags |= FLAGS_HW_LOCK_REQUIRED;
 	DP(NETIF_MSG_LINK, "phy_type 0x%x port %d found in index %d\n",
 		   phy_type, port, phy_index);
 	DP(NETIF_MSG_LINK, "             addr=0x%x, mdio_ctl=0x%x\n",
@@ -13568,24 +13560,6 @@ void bnx2x_period_func(struct link_params *params, struct link_vars *vars)
 
 }
 
-u8 bnx2x_hw_lock_required(struct bnx2x *bp, u32 shmem_base, u32 shmem2_base)
-{
-	u8 phy_index;
-	struct bnx2x_phy phy;
-	for (phy_index = INT_PHY; phy_index < MAX_PHYS;
-	      phy_index++) {
-		if (bnx2x_populate_phy(bp, phy_index, shmem_base, shmem2_base,
-				       0, &phy) != 0) {
-			DP(NETIF_MSG_LINK, "populate phy failed\n");
-			return 0;
-		}
-
-		if (phy.flags & FLAGS_HW_LOCK_REQUIRED)
-			return 1;
-	}
-	return 0;
-}
-
 u8 bnx2x_fan_failure_det_req(struct bnx2x *bp,
 			     u32 shmem_base,
 			     u32 shmem2_base,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
index 24246b9..c43259e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
@@ -139,8 +139,6 @@ struct bnx2x_phy {
 	u8 addr;
 	u8 def_md_devad;
 	u16 flags;
-	/* Require HW lock */
-#define FLAGS_HW_LOCK_REQUIRED		(1<<0)
 	/* No Over-Current detection */
 #define FLAGS_NOC			(1<<1)
 	/* Fan failure detection required */
@@ -423,10 +421,6 @@ int bnx2x_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 
 void bnx2x_hw_reset_phy(struct link_params *params);
 
-/* Checks if HW lock is required for this phy/board type */
-u8 bnx2x_hw_lock_required(struct bnx2x *bp, u32 shmem_base,
-			  u32 shmem2_base);
-
 /* Check swap bit and adjust PHY order */
 u32 bnx2x_phy_selection(struct link_params *params);
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index c7303cd..f45642d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10374,17 +10374,6 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 		bp->mdio.prtad =
 			XGXS_EXT_PHY_ADDR(ext_phy_config);
 
-	/*
-	 * Check if hw lock is required to access MDC/MDIO bus to the PHY(s)
-	 * In MF mode, it is set to cover self test cases
-	 */
-	if (IS_MF(bp))
-		bp->port.need_hw_lock = 1;
-	else
-		bp->port.need_hw_lock = bnx2x_hw_lock_required(bp,
-							bp->common.shmem_base,
-							bp->common.shmem2_base);
-
 	/* Configure link feature according to nvram value */
 	eee_mode = (((SHMEM_RD(bp, dev_info.
 		      port_feature_config[port].eee_power_mode)) &
-- 
1.7.1
