From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 09/21] ixgbe: DCB remove ixgbe_fcoe_getapp routine
Date: Sat, 12 Mar 2011 04:20:16 -0800
Message-ID: <1299932428-3114-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58767 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753848Ab1CLMUx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2011 07:20:53 -0500
In-Reply-To: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Remove ixgbe_fcoe_getapp() and use the generic kernel
routine instead. Also add application priority to the
kernel maintained list on setapp so applications and
stacks can query the value.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_dcb_nl.c |   28 +++++++++++++---------------
 drivers/net/ixgbe/ixgbe_fcoe.c   |   15 ---------------
 2 files changed, 13 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 8d139f7..d4b2914 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -542,24 +542,15 @@ static void ixgbe_dcbnl_setpfcstate(struct net_device *netdev, u8 state)
 static u8 ixgbe_dcbnl_getapp(struct net_device *netdev, u8 idtype, u16 id)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	u8 rval = 0;
+	struct dcb_app app = {
+				.selector = idtype,
+				.protocol = id,
+			     };
 
 	if (!(adapter->dcbx_cap & DCB_CAP_DCBX_VER_CEE))
-		return rval;
+		return 0;
 
-	switch (idtype) {
-	case DCB_APP_IDTYPE_ETHTYPE:
-#ifdef IXGBE_FCOE
-		if (id == ETH_P_FCOE)
-			rval = ixgbe_fcoe_getapp(adapter);
-#endif
-		break;
-	case DCB_APP_IDTYPE_PORTNUM:
-		break;
-	default:
-		break;
-	}
-	return rval;
+	return dcb_getapp(netdev, &app);
 }
 
 /**
@@ -576,10 +567,17 @@ static u8 ixgbe_dcbnl_setapp(struct net_device *netdev,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	u8 rval = 1;
+	struct dcb_app app = {
+			      .selector = idtype,
+			      .protocol = id,
+			      .priority = up
+			     };
 
 	if (!(adapter->dcbx_cap & DCB_CAP_DCBX_VER_CEE))
 		return rval;
 
+	rval = dcb_setapp(netdev, &app);
+
 	switch (idtype) {
 	case DCB_APP_IDTYPE_ETHTYPE:
 #ifdef IXGBE_FCOE
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index 00af15a..dba7d77 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -813,21 +813,6 @@ out_disable:
 
 #ifdef CONFIG_IXGBE_DCB
 /**
- * ixgbe_fcoe_getapp - retrieves current user priority bitmap for FCoE
- * @adapter : ixgbe adapter
- *
- * Finds out the corresponding user priority bitmap from the current
- * traffic class that FCoE belongs to. Returns 0 as the invalid user
- * priority bitmap to indicate an error.
- *
- * Returns : 802.1p user priority bitmap for FCoE
- */
-u8 ixgbe_fcoe_getapp(struct ixgbe_adapter *adapter)
-{
-	return 1 << adapter->fcoe.up;
-}
-
-/**
  * ixgbe_fcoe_setapp - sets the user priority bitmap for FCoE
  * @adapter : ixgbe adapter
  * @up : 802.1p user priority bitmap
-- 
1.7.4

