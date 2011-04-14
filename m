From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 10/24] ixgbe: DCB, further cleanups to app configuration
Date: Wed, 13 Apr 2011 18:02:06 -0700
Message-ID: <1302742940-22141-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:14497 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758073Ab1DNBCc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 21:02:32 -0400
In-Reply-To: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

With the app data on the kernel dcb_app list we no longer
need to specifically handle them in ixgbe for the CEE case.
So now we can remove app handling logic and check when the
hw is configured if the app data matches the hardware
configuration in set_hw_all().

If it does not match then we can reconfigure.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_dcb_nl.c |  107 +++++++++-----------------------------
 1 files changed, 24 insertions(+), 83 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 327c861..7b59f64 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -347,18 +347,28 @@ static void ixgbe_dcbnl_get_pfc_cfg(struct net_device *netdev, int priority,
 static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct dcb_app app = {
+			      .selector = DCB_APP_IDTYPE_ETHTYPE,
+			      .protocol = ETH_P_FCOE,
+			     };
+	u8 up = dcb_getapp(netdev, &app);
 	int ret;
 
-	if (!adapter->dcb_set_bitmap ||
-	    !(adapter->dcbx_cap & DCB_CAP_DCBX_VER_CEE))
-		return DCB_NO_HW_CHG;
-
 	ret = ixgbe_copy_dcb_cfg(&adapter->temp_dcb_cfg, &adapter->dcb_cfg,
 				 MAX_TRAFFIC_CLASS);
-
 	if (ret)
 		return DCB_NO_HW_CHG;
 
+	/* In IEEE mode app data must be parsed into DCBX format for
+	 * hardware routines.
+	 */
+	if (adapter->dcbx_cap & DCB_CAP_DCBX_VER_IEEE)
+		up = (1 << up);
+
+#ifdef IXGBE_FCOE
+	if (up && (up != (1 << adapter->fcoe.up)))
+		adapter->dcb_set_bitmap |= BIT_APP_UPCHG;
+
 	/*
 	 * Only take down the adapter if an app change occurred. FCoE
 	 * may shuffle tx rings in this case and this can not be done
@@ -368,10 +378,13 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 		while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
 			msleep(1);
 
+		ixgbe_fcoe_setapp(adapter, up);
+
 		if (netif_running(netdev))
 			netdev->netdev_ops->ndo_stop(netdev);
 		ixgbe_clear_interrupt_scheme(adapter);
 	}
+#endif
 
 	if (adapter->dcb_cfg.pfc_mode_enable) {
 		switch (adapter->hw.mac.type) {
@@ -399,12 +412,14 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 		}
 	}
 
+#ifdef IXGBE_FCOE
 	if (adapter->dcb_set_bitmap & BIT_APP_UPCHG) {
 		ixgbe_init_interrupt_scheme(adapter);
 		if (netif_running(netdev))
 			netdev->netdev_ops->ndo_open(netdev);
 		ret = DCB_HW_CHG_RST;
 	}
+#endif
 
 	if (adapter->dcb_set_bitmap & BIT_PFC) {
 		u8 pfc_en;
@@ -558,68 +573,6 @@ static u8 ixgbe_dcbnl_getapp(struct net_device *netdev, u8 idtype, u16 id)
 	return dcb_getapp(netdev, &app);
 }
 
-/**
- * ixgbe_dcbnl_setapp - set the DCBX application user priority
- * @netdev : the corresponding netdev
- * @idtype : identifies the id as ether type or TCP/UDP port number
- * @id: id is either ether type or TCP/UDP port number
- * @up: the 802.1p user priority bitmap
- *
- * Returns : 0 on success or 1 on error
- */
-static u8 ixgbe_dcbnl_setapp(struct net_device *netdev,
-                             u8 idtype, u16 id, u8 up)
-{
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	u8 rval = 1;
-	struct dcb_app app = {
-			      .selector = idtype,
-			      .protocol = id,
-			      .priority = up
-			     };
-
-	if (!(adapter->dcbx_cap & DCB_CAP_DCBX_VER_CEE))
-		return rval;
-
-	rval = dcb_setapp(netdev, &app);
-
-	switch (idtype) {
-	case DCB_APP_IDTYPE_ETHTYPE:
-#ifdef IXGBE_FCOE
-		if (id == ETH_P_FCOE) {
-			u8 old_tc;
-
-			/* Get current programmed tc */
-			old_tc = adapter->fcoe.tc;
-			rval = ixgbe_fcoe_setapp(adapter, up);
-
-			if (rval ||
-			   !(adapter->flags & IXGBE_FLAG_DCB_ENABLED) ||
-			   !(adapter->flags & IXGBE_FLAG_FCOE_ENABLED))
-				break;
-
-			/* The FCoE application priority may be changed multiple
-			 * times in quick succession with switches that build up
-			 * TLVs. To avoid creating uneeded device resets this
-			 * checks the actual HW configuration and clears
-			 * BIT_APP_UPCHG if a HW configuration change is not
-			 * need
-			 */
-			if (old_tc == adapter->fcoe.tc)
-				adapter->dcb_set_bitmap &= ~BIT_APP_UPCHG;
-			else
-				adapter->dcb_set_bitmap |= BIT_APP_UPCHG;
-		}
-#endif
-		break;
-	case DCB_APP_IDTYPE_PORTNUM:
-		break;
-	default:
-		break;
-	}
-	return rval;
-}
-
 static int ixgbe_dcbnl_ieee_getets(struct net_device *dev,
 				   struct ieee_ets *ets)
 {
@@ -745,25 +698,14 @@ static int ixgbe_dcbnl_ieee_setapp(struct net_device *dev,
 
 	if (!(adapter->dcbx_cap & DCB_CAP_DCBX_VER_IEEE))
 		return -EINVAL;
-#ifdef IXGBE_FCOE
-	if (app->selector == 1 && app->protocol == ETH_P_FCOE) {
-		if (adapter->fcoe.tc == app->priority)
-			goto setapp;
 
-		/* In IEEE mode map up to tc 1:1 */
-		adapter->fcoe.tc = app->priority;
-		adapter->fcoe.up = app->priority;
+	dcb_setapp(dev, app);
 
-		/* Force hardware reset required to push FCoE
-		 * setup on {tx|rx}_rings
-		 */
-		adapter->dcb_set_bitmap |= BIT_APP_UPCHG;
+#ifdef IXGBE_FCOE
+	if (app->selector == 1 && app->protocol == ETH_P_FCOE &&
+	    adapter->fcoe.tc == app->priority)
 		ixgbe_dcbnl_set_all(dev);
-	}
-
-setapp:
 #endif
-	dcb_setapp(dev, app);
 	return 0;
 }
 
@@ -838,7 +780,6 @@ const struct dcbnl_rtnl_ops dcbnl_ops = {
 	.getpfcstate	= ixgbe_dcbnl_getpfcstate,
 	.setpfcstate	= ixgbe_dcbnl_setpfcstate,
 	.getapp		= ixgbe_dcbnl_getapp,
-	.setapp		= ixgbe_dcbnl_setapp,
 	.getdcbx	= ixgbe_dcbnl_getdcbx,
 	.setdcbx	= ixgbe_dcbnl_setdcbx,
 };
-- 
1.7.4.2

