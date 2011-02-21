From: "Shmulik Ravid" <shmulikr@broadcom.com>
Subject: [PATCH net-next] bnx2x: use dcb_setapp to manage negotiated
 application tlvs
Date: Mon, 21 Feb 2011 20:38:01 +0200
Message-ID: <1298313481.24633.15.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1029 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756105Ab1BUQtU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Feb 2011 11:49:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this patch the bnx2x uses the generic dcbnl application tlv list
instead of implementing its own get-app handler. When the driver is
alerted to a change in the DCB negotiated parameters, it calls
dcb_setapp to update the dcbnl application tlvs list making it available
to user mode applications and registered notifiers.   

Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h      |    2 +-
 drivers/net/bnx2x/bnx2x_dcb.c  |  137 ++++++++++++++++++++++++----------------
 drivers/net/bnx2x/bnx2x_dcb.h  |    5 +-
 drivers/net/bnx2x/bnx2x_main.c |    7 ++-
 4 files changed, 92 insertions(+), 59 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index c0dd30d..1914026 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -31,7 +31,7 @@
 #define BNX2X_NEW_NAPI
 
 #if defined(CONFIG_DCB)
-#define BCM_DCB
+#define BCM_DCBNL
 #endif
 #if defined(CONFIG_CNIC) || defined(CONFIG_CNIC_MODULE)
 #define BCM_CNIC 1
diff --git a/drivers/net/bnx2x/bnx2x_dcb.c b/drivers/net/bnx2x/bnx2x_dcb.c
index fb60021..9a24d79 100644
--- a/drivers/net/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/bnx2x/bnx2x_dcb.c
@@ -19,6 +19,9 @@
 #include <linux/netdevice.h>
 #include <linux/types.h>
 #include <linux/errno.h>
+#ifdef BCM_DCBNL
+#include <linux/dcbnl.h>
+#endif
 
 #include "bnx2x.h"
 #include "bnx2x_cmn.h"
@@ -508,13 +511,75 @@ static int bnx2x_dcbx_read_shmem_neg_results(struct bnx2x *bp)
 	return 0;
 }
 
+
+#ifdef BCM_DCBNL
+static inline
+u8 bnx2x_dcbx_dcbnl_app_up(struct dcbx_app_priority_entry *ent)
+{
+	u8 pri;
+
+	/* Choose the highest priority */
+	for (pri = MAX_PFC_PRIORITIES - 1; pri > 0; pri--)
+		if (ent->pri_bitmap & (1 << pri))
+			break;
+	return pri;
+}
+
+static inline
+u8 bnx2x_dcbx_dcbnl_app_idtype(struct dcbx_app_priority_entry *ent)
+{
+	return ((ent->appBitfield & DCBX_APP_ENTRY_SF_MASK) ==
+		DCBX_APP_SF_PORT) ? DCB_APP_IDTYPE_PORTNUM :
+		DCB_APP_IDTYPE_ETHTYPE;
+}
+
+static inline
+void bnx2x_dcbx_invalidate_local_apps(struct bnx2x *bp)
+{
+	int i;
+	for (i = 0; i < DCBX_MAX_APP_PROTOCOL; i++)
+		bp->dcbx_local_feat.app.app_pri_tbl[i].appBitfield &=
+							~DCBX_APP_ENTRY_VALID;
+}
+
+int bnx2x_dcbnl_update_applist(struct bnx2x *bp, bool delall)
+{
+	int i, err = 0;
+
+	for (i = 0; i < DCBX_MAX_APP_PROTOCOL && err == 0; i++) {
+		struct dcbx_app_priority_entry *ent =
+			&bp->dcbx_local_feat.app.app_pri_tbl[i];
+
+		if (ent->appBitfield & DCBX_APP_ENTRY_VALID) {
+			u8 up = bnx2x_dcbx_dcbnl_app_up(ent);
+
+			/* avoid invalid user-priority */
+			if (up) {
+				struct dcb_app app;
+				app.selector = bnx2x_dcbx_dcbnl_app_idtype(ent);
+				app.protocol = ent->app_id;
+				app.priority = delall ? 0 : up;
+				err = dcb_setapp(bp->dev, &app);
+			}
+		}
+	}
+	return err;
+}
+#endif
+
 void bnx2x_dcbx_set_params(struct bnx2x *bp, u32 state)
 {
 	switch (state) {
 	case BNX2X_DCBX_STATE_NEG_RECEIVED:
 		{
 			DP(NETIF_MSG_LINK, "BNX2X_DCBX_STATE_NEG_RECEIVED\n");
-
+#ifdef BCM_DCBNL
+			/**
+			 * Delete app tlvs from dcbnl before reading new
+			 * negotiation results
+			 */
+			bnx2x_dcbnl_update_applist(bp, true);
+#endif
 			/* Read neg results if dcbx is in the FW */
 			if (bnx2x_dcbx_read_shmem_neg_results(bp))
 				return;
@@ -526,10 +591,24 @@ void bnx2x_dcbx_set_params(struct bnx2x *bp, u32 state)
 						 bp->dcbx_error);
 
 			if (bp->state != BNX2X_STATE_OPENING_WAIT4_LOAD) {
+#ifdef BCM_DCBNL
+				/**
+				 * Add new app tlvs to dcbnl
+				 */
+				bnx2x_dcbnl_update_applist(bp, false);
+#endif
 				bnx2x_dcbx_stop_hw_tx(bp);
 				return;
 			}
 			/* fall through */
+#ifdef BCM_DCBNL
+			/**
+			 * Invalidate the local app tlvs if they are not added
+			 * to the dcbnl app list to avoid deleting them from
+			 * the list later on
+			 */
+			bnx2x_dcbx_invalidate_local_apps(bp);
+#endif
 		}
 	case BNX2X_DCBX_STATE_TX_PAUSED:
 		DP(NETIF_MSG_LINK, "BNX2X_DCBX_STATE_TX_PAUSED\n");
@@ -1505,8 +1584,7 @@ static void bnx2x_pfc_fw_struct_e2(struct bnx2x *bp)
 	bnx2x_dcbx_print_cos_params(bp,	pfc_fw_cfg);
 }
 /* DCB netlink */
-#ifdef BCM_DCB
-#include <linux/dcbnl.h>
+#ifdef BCM_DCBNL
 
 #define BNX2X_DCBX_CAPS		(DCB_CAP_DCBX_LLD_MANAGED | \
 				DCB_CAP_DCBX_VER_CEE | DCB_CAP_DCBX_STATIC)
@@ -1816,32 +1894,6 @@ static void bnx2x_dcbnl_set_pfc_state(struct net_device *netdev, u8 state)
 	bp->dcbx_config_params.admin_pfc_enable = (state ? 1 : 0);
 }
 
-static bool bnx2x_app_is_equal(struct dcbx_app_priority_entry *app_ent,
-			       u8 idtype, u16 idval)
-{
-	if (!(app_ent->appBitfield & DCBX_APP_ENTRY_VALID))
-		return false;
-
-	switch (idtype) {
-	case DCB_APP_IDTYPE_ETHTYPE:
-		if ((app_ent->appBitfield & DCBX_APP_ENTRY_SF_MASK) !=
-			DCBX_APP_SF_ETH_TYPE)
-			return false;
-		break;
-	case DCB_APP_IDTYPE_PORTNUM:
-		if ((app_ent->appBitfield & DCBX_APP_ENTRY_SF_MASK) !=
-			DCBX_APP_SF_PORT)
-			return false;
-		break;
-	default:
-		return false;
-	}
-	if (app_ent->app_id != idval)
-		return false;
-
-	return true;
-}
-
 static void bnx2x_admin_app_set_ent(
 	struct bnx2x_admin_priority_app_table *app_ent,
 	u8 idtype, u16 idval, u8 up)
@@ -1943,30 +1995,6 @@ static u8 bnx2x_dcbnl_set_app_up(struct net_device *netdev, u8 idtype,
 	return bnx2x_set_admin_app_up(bp, idtype, idval, up);
 }
 
-static u8 bnx2x_dcbnl_get_app_up(struct net_device *netdev, u8 idtype,
-				 u16 idval)
-{
-	int i;
-	u8 up = 0;
-
-	struct bnx2x *bp = netdev_priv(netdev);
-	DP(NETIF_MSG_LINK, "app_type %d, app_id 0x%x\n", idtype, idval);
-
-	/* iterate over the app entries looking for idtype and idval */
-	for (i = 0; i < DCBX_MAX_APP_PROTOCOL; i++)
-		if (bnx2x_app_is_equal(&bp->dcbx_local_feat.app.app_pri_tbl[i],
-				       idtype, idval))
-			break;
-
-	if (i < DCBX_MAX_APP_PROTOCOL)
-		/* if found return up */
-		up = bp->dcbx_local_feat.app.app_pri_tbl[i].pri_bitmap;
-	else
-		DP(NETIF_MSG_LINK, "app not found\n");
-
-	return up;
-}
-
 static u8 bnx2x_dcbnl_get_dcbx(struct net_device *netdev)
 {
 	struct bnx2x *bp = netdev_priv(netdev);
@@ -2107,7 +2135,6 @@ const struct dcbnl_rtnl_ops bnx2x_dcbnl_ops = {
 	.setnumtcs      = bnx2x_dcbnl_set_numtcs,
 	.getpfcstate    = bnx2x_dcbnl_get_pfc_state,
 	.setpfcstate    = bnx2x_dcbnl_set_pfc_state,
-	.getapp         = bnx2x_dcbnl_get_app_up,
 	.setapp         = bnx2x_dcbnl_set_app_up,
 	.getdcbx        = bnx2x_dcbnl_get_dcbx,
 	.setdcbx        = bnx2x_dcbnl_set_dcbx,
@@ -2115,4 +2142,4 @@ const struct dcbnl_rtnl_ops bnx2x_dcbnl_ops = {
 	.setfeatcfg     = bnx2x_dcbnl_set_featcfg,
 };
 
-#endif /* BCM_DCB */
+#endif /* BCM_DCBNL */
diff --git a/drivers/net/bnx2x/bnx2x_dcb.h b/drivers/net/bnx2x/bnx2x_dcb.h
index f650f98..71b8eda 100644
--- a/drivers/net/bnx2x/bnx2x_dcb.h
+++ b/drivers/net/bnx2x/bnx2x_dcb.h
@@ -189,8 +189,9 @@ enum {
 void bnx2x_dcbx_set_params(struct bnx2x *bp, u32 state);
 
 /* DCB netlink */
-#ifdef BCM_DCB
+#ifdef BCM_DCBNL
 extern const struct dcbnl_rtnl_ops bnx2x_dcbnl_ops;
-#endif /* BCM_DCB */
+int bnx2x_dcbnl_update_applist(struct bnx2x *bp, bool delall);
+#endif /* BCM_DCBNL */
 
 #endif /* BNX2X_DCB_H */
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 6c7745e..061733e 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -9441,7 +9441,7 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 	dev->vlan_features |= (NETIF_F_TSO | NETIF_F_TSO_ECN);
 	dev->vlan_features |= NETIF_F_TSO6;
 
-#ifdef BCM_DCB
+#ifdef BCM_DCBNL
 	dev->dcbnl_ops = &bnx2x_dcbnl_ops;
 #endif
 
@@ -9848,6 +9848,11 @@ static void __devexit bnx2x_remove_one(struct pci_dev *pdev)
 	}
 #endif
 
+#ifdef BCM_DCBNL
+	/* Delete app tlvs from dcbnl */
+	bnx2x_dcbnl_update_applist(bp, true);
+#endif
+
 	unregister_netdev(dev);
 
 	/* Delete all NAPI objects */
-- 
1.7.3.5




