From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net-next v2] Update setapp/getapp prototypes in dcbnl_rtnl_ops to return int instead of u8
Date: Wed, 16 Jul 2014 22:32:39 -0700
Message-ID: <1405575159-24136-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, dan.carpenter@oracle.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:53961
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751630AbaGQFcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 01:32:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2: fixed issue with checking return of dcbnl_rtnl_ops->getapp()

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c |  4 ++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c  | 21 ++++++---------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |  6 +++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c |  4 ++--
 include/net/dcbnl.h                             |  4 ++--
 net/dcb/dcbnl.c                                 |  8 +++++++-
 6 files changed, 22 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index 51a952c51cb1..fb26bc4c42a1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -2303,8 +2303,8 @@ static int bnx2x_set_admin_app_up(struct bnx2x *bp, u8 idtype, u16 idval, u8 up)
 	return 0;
 }
 
-static u8 bnx2x_dcbnl_set_app_up(struct net_device *netdev, u8 idtype,
-				 u16 idval, u8 up)
+static int bnx2x_dcbnl_set_app_up(struct net_device *netdev, u8 idtype,
+				  u16 idval, u8 up)
 {
 	struct bnx2x *bp = netdev_priv(netdev);
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
index a8b1073e6373..0d3a9df5be36 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
@@ -648,26 +648,17 @@ static int __cxgb4_getapp(struct net_device *dev, u8 app_idtype, u16 app_id,
 }
 
 /* Return the Application User Priority Map associated with the specified
- * Application ID.  Since this routine is prototyped to return "u8" we can't
- * return errors ...
+ * Application ID.
  */
-static u8 cxgb4_getapp(struct net_device *dev, u8 app_idtype, u16 app_id)
+static int cxgb4_getapp(struct net_device *dev, u8 app_idtype, u16 app_id)
 {
-	int result = __cxgb4_getapp(dev, app_idtype, app_id, 0);
-
-	if (result < 0)
-		result = 0;
-
-	return result;
+	return __cxgb4_getapp(dev, app_idtype, app_id, 0);
 }
 
-/* Write a new Application User Priority Map for the specified Application ID.
- * This routine is prototyped to return "u8" but other instantiations of the
- * DCB NetLink Operations "setapp" routines return negative errnos for errors.
- * We follow their lead.
+/* Write a new Application User Priority Map for the specified Application ID
  */
-static u8 cxgb4_setapp(struct net_device *dev, u8 app_idtype, u16 app_id,
-		       u8 app_prio)
+static int cxgb4_setapp(struct net_device *dev, u8 app_idtype, u16 app_id,
+			u8 app_prio)
 {
 	struct fw_port_cmd pcmd;
 	struct port_info *pi = netdev2pinfo(dev);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
index 5172b6b12c09..ea1c1ab926e2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
@@ -495,10 +495,10 @@ static void ixgbe_dcbnl_setpfcstate(struct net_device *netdev, u8 state)
  * @id: id is either ether type or TCP/UDP port number
  *
  * Returns : on success, returns a non-zero 802.1p user priority bitmap
- * otherwise returns 0 as the invalid user priority bitmap to indicate an
+ * otherwise returns -EINVAL as the invalid user priority bitmap to indicate an
  * error.
  */
-static u8 ixgbe_dcbnl_getapp(struct net_device *netdev, u8 idtype, u16 id)
+static int ixgbe_dcbnl_getapp(struct net_device *netdev, u8 idtype, u16 id)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct dcb_app app = {
@@ -507,7 +507,7 @@ static u8 ixgbe_dcbnl_getapp(struct net_device *netdev, u8 idtype, u16 id)
 			     };
 
 	if (!(adapter->dcbx_cap & DCB_CAP_DCBX_VER_CEE))
-		return 0;
+		return -EINVAL;
 
 	return dcb_getapp(netdev, &app);
 }
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
index 561cb11ca58c..a72bcddf160a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
@@ -926,7 +926,7 @@ static int qlcnic_dcb_get_num_tcs(struct net_device *netdev, int attr, u8 *num)
 	}
 }
 
-static u8 qlcnic_dcb_get_app(struct net_device *netdev, u8 idtype, u16 id)
+static int qlcnic_dcb_get_app(struct net_device *netdev, u8 idtype, u16 id)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct dcb_app app = {
@@ -935,7 +935,7 @@ static u8 qlcnic_dcb_get_app(struct net_device *netdev, u8 idtype, u16 id)
 			     };
 
 	if (!test_bit(QLCNIC_DCB_STATE, &adapter->dcb->state))
-		return 0;
+		return -EINVAL;
 
 	return dcb_getapp(netdev, &app);
 }
diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
index a975edf21b22..597b88a94332 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -81,8 +81,8 @@ struct dcbnl_rtnl_ops {
 	void (*setbcncfg)(struct net_device *, int, u32);
 	void (*getbcnrp)(struct net_device *, int, u8 *);
 	void (*setbcnrp)(struct net_device *, int, u8);
-	u8   (*setapp)(struct net_device *, u8, u16, u8);
-	u8   (*getapp)(struct net_device *, u8, u16);
+	int  (*setapp)(struct net_device *, u8, u16, u8);
+	int  (*getapp)(struct net_device *, u8, u16);
 	u8   (*getfeatcfg)(struct net_device *, int, u8 *);
 	u8   (*setfeatcfg)(struct net_device *, int, u8);
 
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index f8b98d89c285..c34af7a1d2d4 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -471,7 +471,11 @@ static int dcbnl_getapp(struct net_device *netdev, struct nlmsghdr *nlh,
 	id = nla_get_u16(app_tb[DCB_APP_ATTR_ID]);
 
 	if (netdev->dcbnl_ops->getapp) {
-		up = netdev->dcbnl_ops->getapp(netdev, idtype, id);
+		ret = netdev->dcbnl_ops->getapp(netdev, idtype, id);
+		if (ret < 0)
+			return ret;
+		else
+			up = ret;
 	} else {
 		struct dcb_app app = {
 					.selector = idtype,
@@ -538,6 +542,8 @@ static int dcbnl_setapp(struct net_device *netdev, struct nlmsghdr *nlh,
 
 	if (netdev->dcbnl_ops->setapp) {
 		ret = netdev->dcbnl_ops->setapp(netdev, idtype, id, up);
+		if (ret < 0)
+			return ret;
 	} else {
 		struct dcb_app app;
 		app.selector = idtype;
-- 
2.0.1
