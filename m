From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net-next] cxgb4 : Improve handling of DCB negotiation or loss thereof
Date: Wed, 15 Oct 2014 19:08:15 -0700
Message-ID: <1413425295-22824-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com, leedom@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:46151
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751342AbaJPCIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 22:08:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clear out any DCB apps we might have added to kernel table when we lose DCB
sync (or IEEE equivalent event). IEEE allows individual components to work
independently, so improve check for IEEE completion by specifying individual
components.

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c | 48 ++++++++++++++++++++++++--
 1 file changed, 45 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
index 8edf0f5bd679..ee819fd12bd2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
@@ -60,6 +60,42 @@ void cxgb4_dcb_version_init(struct net_device *dev)
 	dcb->dcb_version = FW_PORT_DCB_VER_AUTO;
 }
 
+static void cxgb4_dcb_cleanup_apps(struct net_device *dev)
+{
+	struct port_info *pi = netdev2pinfo(dev);
+	struct adapter *adap = pi->adapter;
+	struct port_dcb_info *dcb = &pi->dcb;
+	struct dcb_app app;
+	int i, err;
+
+	/* zero priority implies remove */
+	app.priority = 0;
+
+	for (i = 0; i < CXGB4_MAX_DCBX_APP_SUPPORTED; i++) {
+		/* Check if app list is exhausted */
+		if (!dcb->app_priority[i].protocolid)
+			break;
+
+		app.protocol = dcb->app_priority[i].protocolid;
+
+		if (dcb->dcb_version == FW_PORT_DCB_VER_IEEE) {
+			app.selector = dcb->app_priority[i].sel_field + 1;
+			err = dcb_ieee_setapp(dev, &app);
+		} else {
+			app.selector = !!(dcb->app_priority[i].sel_field);
+			err = dcb_setapp(dev, &app);
+		}
+
+		if (err) {
+			dev_err(adap->pdev_dev,
+				"Failed DCB Clear %s Application Priority: sel=%d, prot=%d, , err=%d\n",
+				dcb_ver_array[dcb->dcb_version], app.selector,
+				app.protocol, -err);
+			break;
+		}
+	}
+}
+
 /* Finite State machine for Data Center Bridging.
  */
 void cxgb4_dcb_state_fsm(struct net_device *dev,
@@ -145,6 +181,7 @@ void cxgb4_dcb_state_fsm(struct net_device *dev,
 			 * state.  We need to reset back to a ground state
 			 * of incomplete.
 			 */
+			cxgb4_dcb_cleanup_apps(dev);
 			cxgb4_dcb_state_init(dev);
 			dcb->state = CXGB4_DCB_STATE_FW_INCOMPLETE;
 			dcb->supported = CXGB4_DCBX_FW_SUPPORT;
@@ -833,11 +870,16 @@ static int cxgb4_setapp(struct net_device *dev, u8 app_idtype, u16 app_id,
 
 /* Return whether IEEE Data Center Bridging has been negotiated.
  */
-static inline int cxgb4_ieee_negotiation_complete(struct net_device *dev)
+static inline int
+cxgb4_ieee_negotiation_complete(struct net_device *dev,
+				enum cxgb4_dcb_fw_msgs dcb_subtype)
 {
 	struct port_info *pi = netdev2pinfo(dev);
 	struct port_dcb_info *dcb = &pi->dcb;
 
+	if (dcb_subtype && !(dcb->msgs & dcb_subtype))
+		return 0;
+
 	return (dcb->state == CXGB4_DCB_STATE_FW_ALLSYNCED &&
 		(dcb->supported & DCB_CAP_DCBX_VER_IEEE));
 }
@@ -850,7 +892,7 @@ static int cxgb4_ieee_getapp(struct net_device *dev, struct dcb_app *app)
 {
 	int prio;
 
-	if (!cxgb4_ieee_negotiation_complete(dev))
+	if (!cxgb4_ieee_negotiation_complete(dev, CXGB4_DCB_FW_APP_ID))
 		return -EINVAL;
 	if (!(app->selector && app->protocol))
 		return -EINVAL;
@@ -872,7 +914,7 @@ static int cxgb4_ieee_setapp(struct net_device *dev, struct dcb_app *app)
 {
 	int ret;
 
-	if (!cxgb4_ieee_negotiation_complete(dev))
+	if (!cxgb4_ieee_negotiation_complete(dev, CXGB4_DCB_FW_APP_ID))
 		return -EINVAL;
 	if (!(app->selector && app->protocol))
 		return -EINVAL;
-- 
2.1.2
