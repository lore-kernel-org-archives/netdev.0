From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net-next] cxgb4 : Improve IEEE DCBx support, other minor open-lldp fixes
Date: Fri, 30 Jan 2015 17:20:17 -0800
Message-ID: <1422667217-2610-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:7083 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757268AbbAaBUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 20:20:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Add support for IEEE ets & pfc api.
* Fix bug that resulted in incorrect bandwidth percentage being returned for
  CEE peers
* Convert pfc enabled info from firmware format to what dcbnl expects before
  returning

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c | 98 +++++++++++++++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h | 11 +++
 2 files changed, 107 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
index a35d1ec6950e..b65a5bda3195 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
@@ -428,7 +428,10 @@ static void cxgb4_getpgtccfg(struct net_device *dev, int tc,
 	}
 	*pgid = (be32_to_cpu(pcmd.u.dcb.pgid.pgid) >> (tc * 4)) & 0xf;
 
-	INIT_PORT_DCB_READ_PEER_CMD(pcmd, pi->port_id);
+	if (local)
+		INIT_PORT_DCB_READ_LOCAL_CMD(pcmd, pi->port_id);
+	else
+		INIT_PORT_DCB_READ_PEER_CMD(pcmd, pi->port_id);
 	pcmd.u.dcb.pgrate.type = FW_PORT_DCB_TYPE_PGRATE;
 	err = t4_wr_mbox(adap, adap->mbox, &pcmd, sizeof(pcmd), &pcmd);
 	if (err != FW_PORT_DCB_CFG_SUCCESS) {
@@ -900,6 +903,88 @@ cxgb4_ieee_negotiation_complete(struct net_device *dev,
 		(dcb->supported & DCB_CAP_DCBX_VER_IEEE));
 }
 
+static int cxgb4_ieee_read_ets(struct net_device *dev, struct ieee_ets *ets,
+			       int local)
+{
+	struct port_info *pi = netdev2pinfo(dev);
+	struct port_dcb_info *dcb = &pi->dcb;
+	struct adapter *adap = pi->adapter;
+	uint32_t tc_info;
+	struct fw_port_cmd pcmd;
+	int i, bwg, err;
+
+	if (!(dcb->msgs & (CXGB4_DCB_FW_PGID | CXGB4_DCB_FW_PGRATE)))
+		return 0;
+
+	ets->ets_cap =  dcb->pg_num_tcs_supported;
+
+	if (local) {
+		ets->willing = 1;
+		INIT_PORT_DCB_READ_LOCAL_CMD(pcmd, pi->port_id);
+	} else {
+		INIT_PORT_DCB_READ_PEER_CMD(pcmd, pi->port_id);
+	}
+
+	pcmd.u.dcb.pgid.type = FW_PORT_DCB_TYPE_PGID;
+	err = t4_wr_mbox(adap, adap->mbox, &pcmd, sizeof(pcmd), &pcmd);
+	if (err != FW_PORT_DCB_CFG_SUCCESS) {
+		dev_err(adap->pdev_dev, "DCB read PGID failed with %d\n", -err);
+		return err;
+	}
+
+	tc_info = be32_to_cpu(pcmd.u.dcb.pgid.pgid);
+
+	if (local)
+		INIT_PORT_DCB_READ_LOCAL_CMD(pcmd, pi->port_id);
+	else
+		INIT_PORT_DCB_READ_PEER_CMD(pcmd, pi->port_id);
+
+	pcmd.u.dcb.pgrate.type = FW_PORT_DCB_TYPE_PGRATE;
+	err = t4_wr_mbox(adap, adap->mbox, &pcmd, sizeof(pcmd), &pcmd);
+	if (err != FW_PORT_DCB_CFG_SUCCESS) {
+		dev_err(adap->pdev_dev, "DCB read PGRATE failed with %d\n",
+			-err);
+		return err;
+	}
+
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		bwg = (tc_info >> ((7 - i) * 4)) & 0xF;
+		ets->prio_tc[i] = bwg;
+		ets->tc_tx_bw[i] = pcmd.u.dcb.pgrate.pgrate[i];
+		ets->tc_rx_bw[i] = ets->tc_tx_bw[i];
+		ets->tc_tsa[i] = pcmd.u.dcb.pgrate.tsa[i];
+	}
+
+	return 0;
+}
+
+static int cxgb4_ieee_get_ets(struct net_device *dev, struct ieee_ets *ets)
+{
+	return cxgb4_ieee_read_ets(dev, ets, 1);
+}
+
+/* We reuse this for peer PFC as well, as we can't have it enabled one way */
+static int cxgb4_ieee_get_pfc(struct net_device *dev, struct ieee_pfc *pfc)
+{
+	struct port_info *pi = netdev2pinfo(dev);
+	struct port_dcb_info *dcb = &pi->dcb;
+
+	memset(pfc, 0, sizeof(struct ieee_pfc));
+
+	if (!(dcb->msgs & CXGB4_DCB_FW_PFC))
+		return 0;
+
+	pfc->pfc_cap = dcb->pfc_num_tcs_supported;
+	pfc->pfc_en = bitswap_1(dcb->pfcen);
+
+	return 0;
+}
+
+static int cxgb4_ieee_peer_ets(struct net_device *dev, struct ieee_ets *ets)
+{
+	return cxgb4_ieee_read_ets(dev, ets, 0);
+}
+
 /* Fill in the Application User Priority Map associated with the
  * specified Application.
  * Priority for IEEE dcb_app is an integer, with 0 being a valid value
@@ -1106,14 +1191,23 @@ static int cxgb4_cee_peer_getpfc(struct net_device *dev, struct cee_pfc *pfc)
 	struct port_info *pi = netdev2pinfo(dev);
 
 	cxgb4_getnumtcs(dev, DCB_NUMTCS_ATTR_PFC, &(pfc->tcs_supported));
-	pfc->pfc_en = pi->dcb.pfcen;
+
+	/* Firmware sends this to us in a formwat that is a bit flipped version
+	 * of spec, correct it before we send it to host. This is taken care of
+	 * by bit shifting in other uses of pfcen
+	 */
+	pfc->pfc_en = bitswap_1(pi->dcb.pfcen);
 
 	return 0;
 }
 
 const struct dcbnl_rtnl_ops cxgb4_dcb_ops = {
+	.ieee_getets		= cxgb4_ieee_get_ets,
+	.ieee_getpfc		= cxgb4_ieee_get_pfc,
 	.ieee_getapp		= cxgb4_ieee_getapp,
 	.ieee_setapp		= cxgb4_ieee_setapp,
+	.ieee_peer_getets	= cxgb4_ieee_peer_ets,
+	.ieee_peer_getpfc	= cxgb4_ieee_get_pfc,
 
 	/* CEE std */
 	.getstate		= cxgb4_getstate,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h
index 31ce425616c9..ccf24d3dc982 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h
@@ -136,6 +136,17 @@ void cxgb4_dcb_handle_fw_update(struct adapter *, const struct fw_port_cmd *);
 void cxgb4_dcb_set_caps(struct adapter *, const struct fw_port_cmd *);
 extern const struct dcbnl_rtnl_ops cxgb4_dcb_ops;
 
+static inline __u8 bitswap_1(unsigned char val)
+{
+	return ((val & 0x80) >> 7) |
+	       ((val & 0x40) >> 5) |
+	       ((val & 0x20) >> 3) |
+	       ((val & 0x10) >> 1) |
+	       ((val & 0x08) << 1) |
+	       ((val & 0x04) << 3) |
+	       ((val & 0x02) << 5) |
+	       ((val & 0x01) << 7);
+}
 #define CXGB4_DCB_ENABLED true
 
 #else /* !CONFIG_CHELSIO_T4_DCB */
-- 
2.2.2
