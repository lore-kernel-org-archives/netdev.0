From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net-next 2/4] cxgb4 : Allow firmware DCB info to be queried in host state
Date: Fri, 17 Jul 2015 13:12:31 -0700
Message-ID: <1437163953-15447-3-git-send-email-anish@chelsio.com>
References: <1437163953-15447-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:15436 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753460AbbGQUMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 16:12:41 -0400
In-Reply-To: <1437163953-15447-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since finally DCB traffic management is still handled by firmware,
allow firmware to be fully programmed and queried even in host
managed state for the cases where this was previously rejected.

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c | 32 +++++++++++++++++---------
 1 file changed, 21 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
index 7f7c4ba0d4f4..56a81b8f7c54 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
@@ -31,6 +31,15 @@ static const char * const dcb_ver_array[] = {
 	"Auto Negotiated"
 };
 
+static inline bool cxgb4_dcb_state_synced(enum cxgb4_dcb_state state)
+{
+	if (state == CXGB4_DCB_STATE_FW_ALLSYNCED ||
+	    state == CXGB4_DCB_STATE_HOST)
+		return true;
+	else
+		return false;
+}
+
 /* Initialize a port's Data Center Bridging state.  Typically used after a
  * Link Down event.
  */
@@ -603,7 +612,7 @@ static void cxgb4_getpfccfg(struct net_device *dev, int priority, u8 *pfccfg)
 	struct port_info *pi = netdev2pinfo(dev);
 	struct port_dcb_info *dcb = &pi->dcb;
 
-	if (dcb->state != CXGB4_DCB_STATE_FW_ALLSYNCED ||
+	if (!cxgb4_dcb_state_synced(dcb->state) ||
 	    priority >= CXGB4_MAX_PRIORITY)
 		*pfccfg = 0;
 	else
@@ -620,7 +629,7 @@ static void cxgb4_setpfccfg(struct net_device *dev, int priority, u8 pfccfg)
 	struct adapter *adap = pi->adapter;
 	int err;
 
-	if (pi->dcb.state != CXGB4_DCB_STATE_FW_ALLSYNCED ||
+	if (!cxgb4_dcb_state_synced(pi->dcb.state) ||
 	    priority >= CXGB4_MAX_PRIORITY)
 		return;
 
@@ -732,7 +741,7 @@ static u8 cxgb4_getpfcstate(struct net_device *dev)
 {
 	struct port_info *pi = netdev2pinfo(dev);
 
-	if (pi->dcb.state != CXGB4_DCB_STATE_FW_ALLSYNCED)
+	if (!cxgb4_dcb_state_synced(pi->dcb.state))
 		return false;
 
 	return pi->dcb.pfcen != 0;
@@ -756,7 +765,7 @@ static int __cxgb4_getapp(struct net_device *dev, u8 app_idtype, u16 app_id,
 	struct adapter *adap = pi->adapter;
 	int i;
 
-	if (pi->dcb.state != CXGB4_DCB_STATE_FW_ALLSYNCED)
+	if (!cxgb4_dcb_state_synced(pi->dcb.state))
 		return 0;
 
 	for (i = 0; i < CXGB4_MAX_DCBX_APP_SUPPORTED; i++) {
@@ -810,7 +819,7 @@ static int __cxgb4_setapp(struct net_device *dev, u8 app_idtype, u16 app_id,
 	int i, err;
 
 
-	if (pi->dcb.state != CXGB4_DCB_STATE_FW_ALLSYNCED)
+	if (!cxgb4_dcb_state_synced(pi->dcb.state))
 		return -EINVAL;
 
 	/* DCB info gets thrown away on link up */
@@ -898,10 +907,11 @@ cxgb4_ieee_negotiation_complete(struct net_device *dev,
 	struct port_info *pi = netdev2pinfo(dev);
 	struct port_dcb_info *dcb = &pi->dcb;
 
-	if (dcb_subtype && !(dcb->msgs & dcb_subtype))
-		return 0;
+	if (dcb->state == CXGB4_DCB_STATE_FW_ALLSYNCED)
+		if (dcb_subtype && !(dcb->msgs & dcb_subtype))
+			return 0;
 
-	return (dcb->state == CXGB4_DCB_STATE_FW_ALLSYNCED &&
+	return (cxgb4_dcb_state_synced(dcb->state) &&
 		(dcb->supported & DCB_CAP_DCBX_VER_IEEE));
 }
 
@@ -1059,7 +1069,7 @@ static u8 cxgb4_setdcbx(struct net_device *dev, u8 dcb_request)
 
 	/* Can't enable DCB if we haven't successfully negotiated it.
 	 */
-	if (pi->dcb.state != CXGB4_DCB_STATE_FW_ALLSYNCED)
+	if (!cxgb4_dcb_state_synced(pi->dcb.state))
 		return 1;
 
 	/* There's currently no mechanism to allow for the firmware DCBX
@@ -1082,7 +1092,7 @@ static int cxgb4_getpeer_app(struct net_device *dev,
 	struct adapter *adap = pi->adapter;
 	int i, err = 0;
 
-	if (pi->dcb.state != CXGB4_DCB_STATE_FW_ALLSYNCED)
+	if (!cxgb4_dcb_state_synced(pi->dcb.state))
 		return 1;
 
 	info->willing = 0;
@@ -1116,7 +1126,7 @@ static int cxgb4_getpeerapp_tbl(struct net_device *dev, struct dcb_app *table)
 	struct adapter *adap = pi->adapter;
 	int i, err = 0;
 
-	if (pi->dcb.state != CXGB4_DCB_STATE_FW_ALLSYNCED)
+	if (!cxgb4_dcb_state_synced(pi->dcb.state))
 		return 1;
 
 	for (i = 0; i < CXGB4_MAX_DCBX_APP_SUPPORTED; i++) {
-- 
2.4.6
