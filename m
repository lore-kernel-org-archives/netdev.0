From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net] cxgb4 : dcb open-lldp interop fixes
Date: Tue, 11 Nov 2014 23:30:51 -0800
Message-ID: <1415777451-14144-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com, leedom@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:43646
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750895AbaKLHbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 02:31:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* In LLD_MANAGED mode, traffic classes were being returned in reverse order to
  lldp agent.
* Priotype of strict is no longer the default returned.
* Change behaviour of getdcbx() based on discussions on lldp-devel

These were missed as there was no working fetch interface for open-lldp when
running in LLD_MANAGED mode till now.

Fixes: 76bcb31efc06 ("cxgb4 : Add DCBx support codebase and dcbnl_ops")

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c | 28 +++++++++++++++++---------
 1 file changed, 19 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
index b6fdb14..cca6049 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
@@ -123,7 +123,11 @@ void cxgb4_dcb_state_fsm(struct net_device *dev,
 		case CXGB4_DCB_INPUT_FW_ENABLED: {
 			/* we're going to use Firmware DCB */
 			dcb->state = CXGB4_DCB_STATE_FW_INCOMPLETE;
-			dcb->supported = CXGB4_DCBX_FW_SUPPORT;
+			dcb->supported = DCB_CAP_DCBX_LLD_MANAGED;
+			if (dcb->dcb_version == FW_PORT_DCB_VER_IEEE)
+				dcb->supported |= DCB_CAP_DCBX_VER_IEEE;
+			else
+				dcb->supported |= DCB_CAP_DCBX_VER_CEE;
 			break;
 		}
 
@@ -437,14 +441,17 @@ static void cxgb4_getpgtccfg(struct net_device *dev, int tc,
 	*up_tc_map = (1 << tc);
 
 	/* prio_type is link strict */
-	*prio_type = 0x2;
+	if (*pgid != 0xF)
+		*prio_type = 0x2;
 }
 
 static void cxgb4_getpgtccfg_tx(struct net_device *dev, int tc,
 				u8 *prio_type, u8 *pgid, u8 *bw_per,
 				u8 *up_tc_map)
 {
-	return cxgb4_getpgtccfg(dev, tc, prio_type, pgid, bw_per, up_tc_map, 1);
+	/* tc 0 is written at MSB position */
+	return cxgb4_getpgtccfg(dev, (7 - tc), prio_type, pgid, bw_per,
+				up_tc_map, 1);
 }
 
 
@@ -452,7 +459,9 @@ static void cxgb4_getpgtccfg_rx(struct net_device *dev, int tc,
 				u8 *prio_type, u8 *pgid, u8 *bw_per,
 				u8 *up_tc_map)
 {
-	return cxgb4_getpgtccfg(dev, tc, prio_type, pgid, bw_per, up_tc_map, 0);
+	/* tc 0 is written at MSB position */
+	return cxgb4_getpgtccfg(dev, (7 - tc), prio_type, pgid, bw_per,
+				up_tc_map, 0);
 }
 
 static void cxgb4_setpgtccfg_tx(struct net_device *dev, int tc,
@@ -462,6 +471,7 @@ static void cxgb4_setpgtccfg_tx(struct net_device *dev, int tc,
 	struct fw_port_cmd pcmd;
 	struct port_info *pi = netdev2pinfo(dev);
 	struct adapter *adap = pi->adapter;
+	int fw_tc = 7 - tc;
 	u32 _pgid;
 	int err;
 
@@ -480,8 +490,8 @@ static void cxgb4_setpgtccfg_tx(struct net_device *dev, int tc,
 	}
 
 	_pgid = be32_to_cpu(pcmd.u.dcb.pgid.pgid);
-	_pgid &= ~(0xF << (tc * 4));
-	_pgid |= pgid << (tc * 4);
+	_pgid &= ~(0xF << (fw_tc * 4));
+	_pgid |= pgid << (fw_tc * 4);
 	pcmd.u.dcb.pgid.pgid = cpu_to_be32(_pgid);
 
 	INIT_PORT_DCB_WRITE_CMD(pcmd, pi->port_id);
@@ -594,7 +604,7 @@ static void cxgb4_getpfccfg(struct net_device *dev, int priority, u8 *pfccfg)
 	    priority >= CXGB4_MAX_PRIORITY)
 		*pfccfg = 0;
 	else
-		*pfccfg = (pi->dcb.pfcen >> priority) & 1;
+		*pfccfg = (pi->dcb.pfcen >> (7 - priority)) & 1;
 }
 
 /* Enable/disable Priority Pause Frames for the specified Traffic Class
@@ -619,9 +629,9 @@ static void cxgb4_setpfccfg(struct net_device *dev, int priority, u8 pfccfg)
 	pcmd.u.dcb.pfc.pfcen = pi->dcb.pfcen;
 
 	if (pfccfg)
-		pcmd.u.dcb.pfc.pfcen |= (1 << priority);
+		pcmd.u.dcb.pfc.pfcen |= (1 << (7 - priority));
 	else
-		pcmd.u.dcb.pfc.pfcen &= (~(1 << priority));
+		pcmd.u.dcb.pfc.pfcen &= (~(1 << (7 - priority)));
 
 	err = t4_wr_mbox(adap, adap->mbox, &pcmd, sizeof(pcmd), &pcmd);
 	if (err != FW_PORT_DCB_CFG_SUCCESS) {
-- 
2.1.3
