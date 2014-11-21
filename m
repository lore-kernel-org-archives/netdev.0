From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 4/5] cxgb4/cxgb4vf/csiostor: Cleanup macros/register defines related to port and VI
Date: Fri, 21 Nov 2014 12:52:04 +0530
Message-ID: <1416554525-11844-5-git-send-email-hariprasad@chelsio.com>
References: <1416554525-11844-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com,
	JBottomley@parallels.com, hch@infradead.org,
	swise@opengridcomputing.com, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, praveen@chelsio.com,
	varun@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1416554525-11844-1-git-send-email-hariprasad@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch cleanups all port and VI related macros/register defines that are
defined in t4fw_api.h and the affected files.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c  |   14 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h  |    4 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    8 +-
 drivers/net/ethernet/chelsio/cxgb4/l2t.c        |    4 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |  106 ++++----
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |  350 ++++++++++++++++-------
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c  |  100 ++++----
 drivers/scsi/csiostor/csio_mb.c                 |   20 +-
 8 files changed, 374 insertions(+), 232 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
index cca6049..6c1c5dc 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
@@ -243,7 +243,7 @@ void cxgb4_dcb_handle_fw_update(struct adapter *adap,
 				const struct fw_port_cmd *pcmd)
 {
 	const union fw_port_dcb *fwdcb = &pcmd->u.dcb;
-	int port = FW_PORT_CMD_PORTID_GET(be32_to_cpu(pcmd->op_to_portid));
+	int port = FW_PORT_CMD_PORTID_G(be32_to_cpu(pcmd->op_to_portid));
 	struct net_device *dev = adap->port[port];
 	struct port_info *pi = netdev_priv(dev);
 	struct port_dcb_info *dcb = &pi->dcb;
@@ -256,12 +256,12 @@ void cxgb4_dcb_handle_fw_update(struct adapter *adap,
 	if (dcb_type == FW_PORT_DCB_TYPE_CONTROL) {
 		enum cxgb4_dcb_state_input input =
 			((pcmd->u.dcb.control.all_syncd_pkd &
-			  FW_PORT_CMD_ALL_SYNCD)
+			  FW_PORT_CMD_ALL_SYNCD_F)
 			 ? CXGB4_DCB_STATE_FW_ALLSYNCED
 			 : CXGB4_DCB_STATE_FW_INCOMPLETE);
 
 		if (dcb->dcb_version != FW_PORT_DCB_VER_UNKNOWN) {
-			dcb_running_version = FW_PORT_CMD_DCB_VERSION_GET(
+			dcb_running_version = FW_PORT_CMD_DCB_VERSION_G(
 				be16_to_cpu(
 				pcmd->u.dcb.control.dcb_version_to_app_state));
 			if (dcb_running_version == FW_PORT_DCB_VER_CEE1D01 ||
@@ -519,7 +519,7 @@ static void cxgb4_setpgtccfg_tx(struct net_device *dev, int tc,
 
 	INIT_PORT_DCB_WRITE_CMD(pcmd, pi->port_id);
 	if (pi->dcb.state == CXGB4_DCB_STATE_HOST)
-		pcmd.op_to_portid |= cpu_to_be32(FW_PORT_CMD_APPLY);
+		pcmd.op_to_portid |= cpu_to_be32(FW_PORT_CMD_APPLY_F);
 
 	err = t4_wr_mbox(adap, adap->mbox, &pcmd, sizeof(pcmd), &pcmd);
 	if (err != FW_PORT_DCB_CFG_SUCCESS)
@@ -583,7 +583,7 @@ static void cxgb4_setpgbwgcfg_tx(struct net_device *dev, int pgid,
 
 	INIT_PORT_DCB_WRITE_CMD(pcmd, pi->port_id);
 	if (pi->dcb.state == CXGB4_DCB_STATE_HOST)
-		pcmd.op_to_portid |= cpu_to_be32(FW_PORT_CMD_APPLY);
+		pcmd.op_to_portid |= cpu_to_be32(FW_PORT_CMD_APPLY_F);
 
 	err = t4_wr_mbox(adap, adap->mbox, &pcmd, sizeof(pcmd), &pcmd);
 
@@ -623,7 +623,7 @@ static void cxgb4_setpfccfg(struct net_device *dev, int priority, u8 pfccfg)
 
 	INIT_PORT_DCB_WRITE_CMD(pcmd, pi->port_id);
 	if (pi->dcb.state == CXGB4_DCB_STATE_HOST)
-		pcmd.op_to_portid |= cpu_to_be32(FW_PORT_CMD_APPLY);
+		pcmd.op_to_portid |= cpu_to_be32(FW_PORT_CMD_APPLY_F);
 
 	pcmd.u.dcb.pfc.type = FW_PORT_DCB_TYPE_PFC;
 	pcmd.u.dcb.pfc.pfcen = pi->dcb.pfcen;
@@ -842,7 +842,7 @@ static int __cxgb4_setapp(struct net_device *dev, u8 app_idtype, u16 app_id,
 	/* write out new app table entry */
 	INIT_PORT_DCB_WRITE_CMD(pcmd, pi->port_id);
 	if (pi->dcb.state == CXGB4_DCB_STATE_HOST)
-		pcmd.op_to_portid |= cpu_to_be32(FW_PORT_CMD_APPLY);
+		pcmd.op_to_portid |= cpu_to_be32(FW_PORT_CMD_APPLY_F);
 
 	pcmd.u.dcb.app_priority.type = FW_PORT_DCB_TYPE_APP_ID;
 	pcmd.u.dcb.app_priority.protocolid = cpu_to_be16(app_id);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h
index c0724a5..31ce425 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h
@@ -45,9 +45,9 @@
 			cpu_to_be32(FW_CMD_OP_V(FW_PORT_CMD) | \
 				    FW_CMD_REQUEST_F | \
 				    FW_CMD_##__op##_F | \
-				    FW_PORT_CMD_PORTID(__port)); \
+				    FW_PORT_CMD_PORTID_V(__port)); \
 		(__pcmd).action_to_len16 = \
-			cpu_to_be32(FW_PORT_CMD_ACTION(__action) | \
+			cpu_to_be32(FW_PORT_CMD_ACTION_V(__action) | \
 				    FW_LEN16(pcmd)); \
 	} while (0)
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 4caec41..4c663cc 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -710,7 +710,7 @@ EXPORT_SYMBOL(cxgb4_dcb_enabled);
 /* Handle a Data Center Bridging update message from the firmware. */
 static void dcb_rpl(struct adapter *adap, const struct fw_port_cmd *pcmd)
 {
-	int port = FW_PORT_CMD_PORTID_GET(ntohl(pcmd->op_to_portid));
+	int port = FW_PORT_CMD_PORTID_G(ntohl(pcmd->op_to_portid));
 	struct net_device *dev = adap->port[port];
 	int old_dcb_enabled = cxgb4_dcb_enabled(dev);
 	int new_dcb_enabled;
@@ -835,15 +835,15 @@ static int fwevtq_handler(struct sge_rspq *q, const __be64 *rsp,
 		const struct fw_port_cmd *pcmd = (const void *)p->data;
 		unsigned int cmd = FW_CMD_OP_G(ntohl(pcmd->op_to_portid));
 		unsigned int action =
-			FW_PORT_CMD_ACTION_GET(ntohl(pcmd->action_to_len16));
+			FW_PORT_CMD_ACTION_G(ntohl(pcmd->action_to_len16));
 
 		if (cmd == FW_PORT_CMD &&
 		    action == FW_PORT_ACTION_GET_PORT_INFO) {
-			int port = FW_PORT_CMD_PORTID_GET(
+			int port = FW_PORT_CMD_PORTID_G(
 					be32_to_cpu(pcmd->op_to_portid));
 			struct net_device *dev = q->adap->port[port];
 			int state_input = ((pcmd->u.info.dcbxdis_pkd &
-					    FW_PORT_CMD_DCBXDIS)
+					    FW_PORT_CMD_DCBXDIS_F)
 					   ? CXGB4_DCB_INPUT_FW_DISABLED
 					   : CXGB4_DCB_INPUT_FW_ENABLED);
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/l2t.c b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
index 1eca0e2..a047baa 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/l2t.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
@@ -435,9 +435,9 @@ u64 cxgb4_select_ntuple(struct net_device *dev,
 
 	if (tp->vnic_shift >= 0) {
 		u32 viid = cxgb4_port_viid(dev);
-		u32 vf = FW_VIID_VIN_GET(viid);
+		u32 vf = FW_VIID_VIN_G(viid);
 		u32 pf = FW_VIID_PFN_G(viid);
-		u32 vld = FW_VIID_VIVLD_GET(viid);
+		u32 vld = FW_VIID_VIVLD_G(viid);
 
 		ntuple |= (u64)(V_FT_VNID_ID_VF(vf) |
 				V_FT_VNID_ID_PF(pf) |
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index da72814..20432e2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -1237,7 +1237,7 @@ int t4_link_start(struct adapter *adap, unsigned int mbox, unsigned int port,
 		  struct link_config *lc)
 {
 	struct fw_port_cmd c;
-	unsigned int fc = 0, mdi = FW_PORT_MDI(FW_PORT_MDI_AUTO);
+	unsigned int fc = 0, mdi = FW_PORT_CAP_MDI_V(FW_PORT_CAP_MDI_AUTO);
 
 	lc->link_ok = 0;
 	if (lc->requested_fc & PAUSE_RX)
@@ -1247,8 +1247,8 @@ int t4_link_start(struct adapter *adap, unsigned int mbox, unsigned int port,
 
 	memset(&c, 0, sizeof(c));
 	c.op_to_portid = htonl(FW_CMD_OP_V(FW_PORT_CMD) | FW_CMD_REQUEST_F |
-			       FW_CMD_EXEC_F | FW_PORT_CMD_PORTID(port));
-	c.action_to_len16 = htonl(FW_PORT_CMD_ACTION(FW_PORT_ACTION_L1_CFG) |
+			       FW_CMD_EXEC_F | FW_PORT_CMD_PORTID_V(port));
+	c.action_to_len16 = htonl(FW_PORT_CMD_ACTION_V(FW_PORT_ACTION_L1_CFG) |
 				  FW_LEN16(c));
 
 	if (!(lc->supported & FW_PORT_CAP_ANEG)) {
@@ -1277,8 +1277,8 @@ int t4_restart_aneg(struct adapter *adap, unsigned int mbox, unsigned int port)
 
 	memset(&c, 0, sizeof(c));
 	c.op_to_portid = htonl(FW_CMD_OP_V(FW_PORT_CMD) | FW_CMD_REQUEST_F |
-			       FW_CMD_EXEC_F | FW_PORT_CMD_PORTID(port));
-	c.action_to_len16 = htonl(FW_PORT_CMD_ACTION(FW_PORT_ACTION_L1_CFG) |
+			       FW_CMD_EXEC_F | FW_PORT_CMD_PORTID_V(port));
+	c.action_to_len16 = htonl(FW_PORT_CMD_ACTION_V(FW_PORT_ACTION_L1_CFG) |
 				  FW_LEN16(c));
 	c.u.l1cfg.rcap = htonl(FW_PORT_CAP_ANEG);
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
@@ -3415,9 +3415,9 @@ int t4_alloc_vi(struct adapter *adap, unsigned int mbox, unsigned int port,
 	memset(&c, 0, sizeof(c));
 	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_VI_CMD) | FW_CMD_REQUEST_F |
 			    FW_CMD_WRITE_F | FW_CMD_EXEC_F |
-			    FW_VI_CMD_PFN(pf) | FW_VI_CMD_VFN(vf));
-	c.alloc_to_len16 = htonl(FW_VI_CMD_ALLOC | FW_LEN16(c));
-	c.portid_pkd = FW_VI_CMD_PORTID(port);
+			    FW_VI_CMD_PFN_V(pf) | FW_VI_CMD_VFN_V(vf));
+	c.alloc_to_len16 = htonl(FW_VI_CMD_ALLOC_F | FW_LEN16(c));
+	c.portid_pkd = FW_VI_CMD_PORTID_V(port);
 	c.nmac = nmac - 1;
 
 	ret = t4_wr_mbox(adap, mbox, &c, sizeof(c), &c);
@@ -3438,8 +3438,8 @@ int t4_alloc_vi(struct adapter *adap, unsigned int mbox, unsigned int port,
 		}
 	}
 	if (rss_size)
-		*rss_size = FW_VI_CMD_RSSSIZE_GET(ntohs(c.rsssize_pkd));
-	return FW_VI_CMD_VIID_GET(ntohs(c.type_viid));
+		*rss_size = FW_VI_CMD_RSSSIZE_G(ntohs(c.rsssize_pkd));
+	return FW_VI_CMD_VIID_G(ntohs(c.type_viid));
 }
 
 /**
@@ -3466,23 +3466,23 @@ int t4_set_rxmode(struct adapter *adap, unsigned int mbox, unsigned int viid,
 	if (mtu < 0)
 		mtu = FW_RXMODE_MTU_NO_CHG;
 	if (promisc < 0)
-		promisc = FW_VI_RXMODE_CMD_PROMISCEN_MASK;
+		promisc = FW_VI_RXMODE_CMD_PROMISCEN_M;
 	if (all_multi < 0)
-		all_multi = FW_VI_RXMODE_CMD_ALLMULTIEN_MASK;
+		all_multi = FW_VI_RXMODE_CMD_ALLMULTIEN_M;
 	if (bcast < 0)
-		bcast = FW_VI_RXMODE_CMD_BROADCASTEN_MASK;
+		bcast = FW_VI_RXMODE_CMD_BROADCASTEN_M;
 	if (vlanex < 0)
-		vlanex = FW_VI_RXMODE_CMD_VLANEXEN_MASK;
+		vlanex = FW_VI_RXMODE_CMD_VLANEXEN_M;
 
 	memset(&c, 0, sizeof(c));
 	c.op_to_viid = htonl(FW_CMD_OP_V(FW_VI_RXMODE_CMD) | FW_CMD_REQUEST_F |
-			     FW_CMD_WRITE_F | FW_VI_RXMODE_CMD_VIID(viid));
+			     FW_CMD_WRITE_F | FW_VI_RXMODE_CMD_VIID_V(viid));
 	c.retval_len16 = htonl(FW_LEN16(c));
-	c.mtu_to_vlanexen = htonl(FW_VI_RXMODE_CMD_MTU(mtu) |
-				  FW_VI_RXMODE_CMD_PROMISCEN(promisc) |
-				  FW_VI_RXMODE_CMD_ALLMULTIEN(all_multi) |
-				  FW_VI_RXMODE_CMD_BROADCASTEN(bcast) |
-				  FW_VI_RXMODE_CMD_VLANEXEN(vlanex));
+	c.mtu_to_vlanexen = htonl(FW_VI_RXMODE_CMD_MTU_V(mtu) |
+				  FW_VI_RXMODE_CMD_PROMISCEN_V(promisc) |
+				  FW_VI_RXMODE_CMD_ALLMULTIEN_V(all_multi) |
+				  FW_VI_RXMODE_CMD_BROADCASTEN_V(bcast) |
+				  FW_VI_RXMODE_CMD_VLANEXEN_V(vlanex));
 	return t4_wr_mbox_meat(adap, mbox, &c, sizeof(c), NULL, sleep_ok);
 }
 
@@ -3525,13 +3525,13 @@ int t4_alloc_mac_filt(struct adapter *adap, unsigned int mbox,
 	memset(&c, 0, sizeof(c));
 	c.op_to_viid = htonl(FW_CMD_OP_V(FW_VI_MAC_CMD) | FW_CMD_REQUEST_F |
 			     FW_CMD_WRITE_F | (free ? FW_CMD_EXEC_F : 0) |
-			     FW_VI_MAC_CMD_VIID(viid));
-	c.freemacs_to_len16 = htonl(FW_VI_MAC_CMD_FREEMACS(free) |
+			     FW_VI_MAC_CMD_VIID_V(viid));
+	c.freemacs_to_len16 = htonl(FW_VI_MAC_CMD_FREEMACS_V(free) |
 				    FW_CMD_LEN16_V((naddr + 2) / 2));
 
 	for (i = 0, p = c.u.exact; i < naddr; i++, p++) {
-		p->valid_to_idx = htons(FW_VI_MAC_CMD_VALID |
-				      FW_VI_MAC_CMD_IDX(FW_VI_MAC_ADD_MAC));
+		p->valid_to_idx = htons(FW_VI_MAC_CMD_VALID_F |
+				      FW_VI_MAC_CMD_IDX_V(FW_VI_MAC_ADD_MAC));
 		memcpy(p->macaddr, addr[i], sizeof(p->macaddr));
 	}
 
@@ -3540,7 +3540,7 @@ int t4_alloc_mac_filt(struct adapter *adap, unsigned int mbox,
 		return ret;
 
 	for (i = 0, p = c.u.exact; i < naddr; i++, p++) {
-		u16 index = FW_VI_MAC_CMD_IDX_GET(ntohs(p->valid_to_idx));
+		u16 index = FW_VI_MAC_CMD_IDX_G(ntohs(p->valid_to_idx));
 
 		if (idx)
 			idx[i] = index >= max_naddr ? 0xffff : index;
@@ -3587,16 +3587,16 @@ int t4_change_mac(struct adapter *adap, unsigned int mbox, unsigned int viid,
 
 	memset(&c, 0, sizeof(c));
 	c.op_to_viid = htonl(FW_CMD_OP_V(FW_VI_MAC_CMD) | FW_CMD_REQUEST_F |
-			     FW_CMD_WRITE_F | FW_VI_MAC_CMD_VIID(viid));
+			     FW_CMD_WRITE_F | FW_VI_MAC_CMD_VIID_V(viid));
 	c.freemacs_to_len16 = htonl(FW_CMD_LEN16_V(1));
-	p->valid_to_idx = htons(FW_VI_MAC_CMD_VALID |
-				FW_VI_MAC_CMD_SMAC_RESULT(mode) |
-				FW_VI_MAC_CMD_IDX(idx));
+	p->valid_to_idx = htons(FW_VI_MAC_CMD_VALID_F |
+				FW_VI_MAC_CMD_SMAC_RESULT_V(mode) |
+				FW_VI_MAC_CMD_IDX_V(idx));
 	memcpy(p->macaddr, addr, sizeof(p->macaddr));
 
 	ret = t4_wr_mbox(adap, mbox, &c, sizeof(c), &c);
 	if (ret == 0) {
-		ret = FW_VI_MAC_CMD_IDX_GET(ntohs(p->valid_to_idx));
+		ret = FW_VI_MAC_CMD_IDX_G(ntohs(p->valid_to_idx));
 		if (ret >= max_mac_addr)
 			ret = -ENOMEM;
 	}
@@ -3621,9 +3621,9 @@ int t4_set_addr_hash(struct adapter *adap, unsigned int mbox, unsigned int viid,
 
 	memset(&c, 0, sizeof(c));
 	c.op_to_viid = htonl(FW_CMD_OP_V(FW_VI_MAC_CMD) | FW_CMD_REQUEST_F |
-			     FW_CMD_WRITE_F | FW_VI_ENABLE_CMD_VIID(viid));
-	c.freemacs_to_len16 = htonl(FW_VI_MAC_CMD_HASHVECEN |
-				    FW_VI_MAC_CMD_HASHUNIEN(ucast) |
+			     FW_CMD_WRITE_F | FW_VI_ENABLE_CMD_VIID_V(viid));
+	c.freemacs_to_len16 = htonl(FW_VI_MAC_CMD_HASHVECEN_F |
+				    FW_VI_MAC_CMD_HASHUNIEN_V(ucast) |
 				    FW_CMD_LEN16_V(1));
 	c.u.hash.hashvec = cpu_to_be64(vec);
 	return t4_wr_mbox_meat(adap, mbox, &c, sizeof(c), NULL, sleep_ok);
@@ -3648,11 +3648,11 @@ int t4_enable_vi_params(struct adapter *adap, unsigned int mbox,
 
 	memset(&c, 0, sizeof(c));
 	c.op_to_viid = htonl(FW_CMD_OP_V(FW_VI_ENABLE_CMD) | FW_CMD_REQUEST_F |
-			     FW_CMD_EXEC_F | FW_VI_ENABLE_CMD_VIID(viid));
+			     FW_CMD_EXEC_F | FW_VI_ENABLE_CMD_VIID_V(viid));
 
-	c.ien_to_len16 = htonl(FW_VI_ENABLE_CMD_IEN(rx_en) |
-			       FW_VI_ENABLE_CMD_EEN(tx_en) | FW_LEN16(c) |
-			       FW_VI_ENABLE_CMD_DCB_INFO(dcb_en));
+	c.ien_to_len16 = htonl(FW_VI_ENABLE_CMD_IEN_V(rx_en) |
+			       FW_VI_ENABLE_CMD_EEN_V(tx_en) | FW_LEN16(c) |
+			       FW_VI_ENABLE_CMD_DCB_INFO_V(dcb_en));
 	return t4_wr_mbox_ns(adap, mbox, &c, sizeof(c), NULL);
 }
 
@@ -3688,8 +3688,8 @@ int t4_identify_port(struct adapter *adap, unsigned int mbox, unsigned int viid,
 
 	memset(&c, 0, sizeof(c));
 	c.op_to_viid = htonl(FW_CMD_OP_V(FW_VI_ENABLE_CMD) | FW_CMD_REQUEST_F |
-			     FW_CMD_EXEC_F | FW_VI_ENABLE_CMD_VIID(viid));
-	c.ien_to_len16 = htonl(FW_VI_ENABLE_CMD_LED | FW_LEN16(c));
+			     FW_CMD_EXEC_F | FW_VI_ENABLE_CMD_VIID_V(viid));
+	c.ien_to_len16 = htonl(FW_VI_ENABLE_CMD_LED_F | FW_LEN16(c));
 	c.blinkdur = htons(nblinks);
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
 }
@@ -3811,25 +3811,25 @@ int t4_handle_fw_rpl(struct adapter *adap, const __be64 *rpl)
 	if (opcode == FW_PORT_CMD) {    /* link/module state change message */
 		int speed = 0, fc = 0;
 		const struct fw_port_cmd *p = (void *)rpl;
-		int chan = FW_PORT_CMD_PORTID_GET(ntohl(p->op_to_portid));
+		int chan = FW_PORT_CMD_PORTID_G(ntohl(p->op_to_portid));
 		int port = adap->chan_map[chan];
 		struct port_info *pi = adap2pinfo(adap, port);
 		struct link_config *lc = &pi->link_cfg;
 		u32 stat = ntohl(p->u.info.lstatus_to_modtype);
-		int link_ok = (stat & FW_PORT_CMD_LSTATUS) != 0;
-		u32 mod = FW_PORT_CMD_MODTYPE_GET(stat);
+		int link_ok = (stat & FW_PORT_CMD_LSTATUS_F) != 0;
+		u32 mod = FW_PORT_CMD_MODTYPE_G(stat);
 
-		if (stat & FW_PORT_CMD_RXPAUSE)
+		if (stat & FW_PORT_CMD_RXPAUSE_F)
 			fc |= PAUSE_RX;
-		if (stat & FW_PORT_CMD_TXPAUSE)
+		if (stat & FW_PORT_CMD_TXPAUSE_F)
 			fc |= PAUSE_TX;
-		if (stat & FW_PORT_CMD_LSPEED(FW_PORT_CAP_SPEED_100M))
+		if (stat & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_100M))
 			speed = 100;
-		else if (stat & FW_PORT_CMD_LSPEED(FW_PORT_CAP_SPEED_1G))
+		else if (stat & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_1G))
 			speed = 1000;
-		else if (stat & FW_PORT_CMD_LSPEED(FW_PORT_CAP_SPEED_10G))
+		else if (stat & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_10G))
 			speed = 10000;
-		else if (stat & FW_PORT_CMD_LSPEED(FW_PORT_CAP_SPEED_40G))
+		else if (stat & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_40G))
 			speed = 40000;
 
 		if (link_ok != lc->link_ok || speed != lc->speed ||
@@ -4124,9 +4124,9 @@ int t4_port_init(struct adapter *adap, int mbox, int pf, int vf)
 
 		c.op_to_portid = htonl(FW_CMD_OP_V(FW_PORT_CMD) |
 				       FW_CMD_REQUEST_F | FW_CMD_READ_F |
-				       FW_PORT_CMD_PORTID(j));
+				       FW_PORT_CMD_PORTID_V(j));
 		c.action_to_len16 = htonl(
-			FW_PORT_CMD_ACTION(FW_PORT_ACTION_GET_PORT_INFO) |
+			FW_PORT_CMD_ACTION_V(FW_PORT_ACTION_GET_PORT_INFO) |
 			FW_LEN16(c));
 		ret = t4_wr_mbox(adap, mbox, &c, sizeof(c), &c);
 		if (ret)
@@ -4144,9 +4144,9 @@ int t4_port_init(struct adapter *adap, int mbox, int pf, int vf)
 		adap->port[i]->dev_port = j;
 
 		ret = ntohl(c.u.info.lstatus_to_modtype);
-		p->mdio_addr = (ret & FW_PORT_CMD_MDIOCAP) ?
-			FW_PORT_CMD_MDIOADDR_GET(ret) : -1;
-		p->port_type = FW_PORT_CMD_PTYPE_GET(ret);
+		p->mdio_addr = (ret & FW_PORT_CMD_MDIOCAP_F) ?
+			FW_PORT_CMD_MDIOADDR_G(ret) : -1;
+		p->port_type = FW_PORT_CMD_PTYPE_G(ret);
 		p->mod_type = FW_PORT_MOD_TYPE_NA;
 
 		rvc.op_to_viid = htonl(FW_CMD_OP_V(FW_RSS_VI_CONFIG_CMD) |
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index 92a0df5..4c8eb87 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -1834,8 +1834,13 @@ struct fw_eq_ofld_cmd {
 #define FW_VIID_PFN_M           0x7
 #define FW_VIID_PFN_G(x)        (((x) >> FW_VIID_PFN_S) & FW_VIID_PFN_M)
 
-#define FW_VIID_VIVLD_GET(x) (((x) >> 7) & 0x1)
-#define FW_VIID_VIN_GET(x) (((x) >> 0) & 0x7F)
+#define FW_VIID_VIVLD_S		7
+#define FW_VIID_VIVLD_M		0x1
+#define FW_VIID_VIVLD_G(x)	(((x) >> FW_VIID_VIVLD_S) & FW_VIID_VIVLD_M)
+
+#define FW_VIID_VIN_S		0
+#define FW_VIID_VIN_M		0x7F
+#define FW_VIID_VIN_G(x)	(((x) >> FW_VIID_VIN_S) & FW_VIID_VIN_M)
 
 struct fw_vi_cmd {
 	__be32 op_to_vfn;
@@ -1855,15 +1860,35 @@ struct fw_vi_cmd {
 	__be64 r10;
 };
 
-#define FW_VI_CMD_PFN(x) ((x) << 8)
-#define FW_VI_CMD_VFN(x) ((x) << 0)
-#define FW_VI_CMD_ALLOC (1U << 31)
-#define FW_VI_CMD_FREE (1U << 30)
-#define FW_VI_CMD_VIID(x) ((x) << 0)
-#define FW_VI_CMD_VIID_GET(x) ((x) & 0xfff)
-#define FW_VI_CMD_PORTID(x) ((x) << 4)
-#define FW_VI_CMD_PORTID_GET(x) (((x) >> 4) & 0xf)
-#define FW_VI_CMD_RSSSIZE_GET(x) (((x) >> 0) & 0x7ff)
+#define FW_VI_CMD_PFN_S		8
+#define FW_VI_CMD_PFN_V(x)	((x) << FW_VI_CMD_PFN_S)
+
+#define FW_VI_CMD_VFN_S		0
+#define FW_VI_CMD_VFN_V(x)	((x) << FW_VI_CMD_VFN_S)
+
+#define FW_VI_CMD_ALLOC_S	31
+#define FW_VI_CMD_ALLOC_V(x)	((x) << FW_VI_CMD_ALLOC_S)
+#define FW_VI_CMD_ALLOC_F	FW_VI_CMD_ALLOC_V(1U)
+
+#define FW_VI_CMD_FREE_S	30
+#define FW_VI_CMD_FREE_V(x)	((x) << FW_VI_CMD_FREE_S)
+#define FW_VI_CMD_FREE_F	FW_VI_CMD_FREE_V(1U)
+
+#define FW_VI_CMD_VIID_S	0
+#define FW_VI_CMD_VIID_M	0xfff
+#define FW_VI_CMD_VIID_V(x)	((x) << FW_VI_CMD_VIID_S)
+#define FW_VI_CMD_VIID_G(x)	(((x) >> FW_VI_CMD_VIID_S) & FW_VI_CMD_VIID_M)
+
+#define FW_VI_CMD_PORTID_S	4
+#define FW_VI_CMD_PORTID_M	0xf
+#define FW_VI_CMD_PORTID_V(x)	((x) << FW_VI_CMD_PORTID_S)
+#define FW_VI_CMD_PORTID_G(x)	\
+	(((x) >> FW_VI_CMD_PORTID_S) & FW_VI_CMD_PORTID_M)
+
+#define FW_VI_CMD_RSSSIZE_S	0
+#define FW_VI_CMD_RSSSIZE_M	0x7ff
+#define FW_VI_CMD_RSSSIZE_G(x)	\
+	(((x) >> FW_VI_CMD_RSSSIZE_S) & FW_VI_CMD_RSSSIZE_M)
 
 /* Special VI_MAC command index ids */
 #define FW_VI_MAC_ADD_MAC		0x3FF
@@ -1899,16 +1924,37 @@ struct fw_vi_mac_cmd {
 	} u;
 };
 
-#define FW_VI_MAC_CMD_VIID(x) ((x) << 0)
-#define FW_VI_MAC_CMD_FREEMACS(x) ((x) << 31)
-#define FW_VI_MAC_CMD_HASHVECEN (1U << 23)
-#define FW_VI_MAC_CMD_HASHUNIEN(x) ((x) << 22)
-#define FW_VI_MAC_CMD_VALID (1U << 15)
-#define FW_VI_MAC_CMD_PRIO(x) ((x) << 12)
-#define FW_VI_MAC_CMD_SMAC_RESULT(x) ((x) << 10)
-#define FW_VI_MAC_CMD_SMAC_RESULT_GET(x) (((x) >> 10) & 0x3)
-#define FW_VI_MAC_CMD_IDX(x) ((x) << 0)
-#define FW_VI_MAC_CMD_IDX_GET(x) (((x) >> 0) & 0x3ff)
+#define FW_VI_MAC_CMD_VIID_S	0
+#define FW_VI_MAC_CMD_VIID_V(x)	((x) << FW_VI_MAC_CMD_VIID_S)
+
+#define FW_VI_MAC_CMD_FREEMACS_S	31
+#define FW_VI_MAC_CMD_FREEMACS_V(x)	((x) << FW_VI_MAC_CMD_FREEMACS_S)
+
+#define FW_VI_MAC_CMD_HASHVECEN_S	23
+#define FW_VI_MAC_CMD_HASHVECEN_V(x)	((x) << FW_VI_MAC_CMD_HASHVECEN_S)
+#define FW_VI_MAC_CMD_HASHVECEN_F	FW_VI_MAC_CMD_HASHVECEN_V(1U)
+
+#define FW_VI_MAC_CMD_HASHUNIEN_S	22
+#define FW_VI_MAC_CMD_HASHUNIEN_V(x)	((x) << FW_VI_MAC_CMD_HASHUNIEN_S)
+
+#define FW_VI_MAC_CMD_VALID_S		15
+#define FW_VI_MAC_CMD_VALID_V(x)	((x) << FW_VI_MAC_CMD_VALID_S)
+#define FW_VI_MAC_CMD_VALID_F	FW_VI_MAC_CMD_VALID_V(1U)
+
+#define FW_VI_MAC_CMD_PRIO_S	12
+#define FW_VI_MAC_CMD_PRIO_V(x)	((x) << FW_VI_MAC_CMD_PRIO_S)
+
+#define FW_VI_MAC_CMD_SMAC_RESULT_S	10
+#define FW_VI_MAC_CMD_SMAC_RESULT_M	0x3
+#define FW_VI_MAC_CMD_SMAC_RESULT_V(x)	((x) << FW_VI_MAC_CMD_SMAC_RESULT_S)
+#define FW_VI_MAC_CMD_SMAC_RESULT_G(x)	\
+	(((x) >> FW_VI_MAC_CMD_SMAC_RESULT_S) & FW_VI_MAC_CMD_SMAC_RESULT_M)
+
+#define FW_VI_MAC_CMD_IDX_S	0
+#define FW_VI_MAC_CMD_IDX_M	0x3ff
+#define FW_VI_MAC_CMD_IDX_V(x)	((x) << FW_VI_MAC_CMD_IDX_S)
+#define FW_VI_MAC_CMD_IDX_G(x)	\
+	(((x) >> FW_VI_MAC_CMD_IDX_S) & FW_VI_MAC_CMD_IDX_M)
 
 #define FW_RXMODE_MTU_NO_CHG	65535
 
@@ -1919,17 +1965,30 @@ struct fw_vi_rxmode_cmd {
 	__be32 r4_lo;
 };
 
-#define FW_VI_RXMODE_CMD_VIID(x) ((x) << 0)
-#define FW_VI_RXMODE_CMD_MTU_MASK 0xffff
-#define FW_VI_RXMODE_CMD_MTU(x) ((x) << 16)
-#define FW_VI_RXMODE_CMD_PROMISCEN_MASK 0x3
-#define FW_VI_RXMODE_CMD_PROMISCEN(x) ((x) << 14)
-#define FW_VI_RXMODE_CMD_ALLMULTIEN_MASK 0x3
-#define FW_VI_RXMODE_CMD_ALLMULTIEN(x) ((x) << 12)
-#define FW_VI_RXMODE_CMD_BROADCASTEN_MASK 0x3
-#define FW_VI_RXMODE_CMD_BROADCASTEN(x) ((x) << 10)
-#define FW_VI_RXMODE_CMD_VLANEXEN_MASK 0x3
-#define FW_VI_RXMODE_CMD_VLANEXEN(x) ((x) << 8)
+#define FW_VI_RXMODE_CMD_VIID_S		0
+#define FW_VI_RXMODE_CMD_VIID_V(x)	((x) << FW_VI_RXMODE_CMD_VIID_S)
+
+#define FW_VI_RXMODE_CMD_MTU_S		16
+#define FW_VI_RXMODE_CMD_MTU_M		0xffff
+#define FW_VI_RXMODE_CMD_MTU_V(x)	((x) << FW_VI_RXMODE_CMD_MTU_S)
+
+#define FW_VI_RXMODE_CMD_PROMISCEN_S	14
+#define FW_VI_RXMODE_CMD_PROMISCEN_M	0x3
+#define FW_VI_RXMODE_CMD_PROMISCEN_V(x)	((x) << FW_VI_RXMODE_CMD_PROMISCEN_S)
+
+#define FW_VI_RXMODE_CMD_ALLMULTIEN_S		12
+#define FW_VI_RXMODE_CMD_ALLMULTIEN_M		0x3
+#define FW_VI_RXMODE_CMD_ALLMULTIEN_V(x)	\
+	((x) << FW_VI_RXMODE_CMD_ALLMULTIEN_S)
+
+#define FW_VI_RXMODE_CMD_BROADCASTEN_S		10
+#define FW_VI_RXMODE_CMD_BROADCASTEN_M		0x3
+#define FW_VI_RXMODE_CMD_BROADCASTEN_V(x)	\
+	((x) << FW_VI_RXMODE_CMD_BROADCASTEN_S)
+
+#define FW_VI_RXMODE_CMD_VLANEXEN_S	8
+#define FW_VI_RXMODE_CMD_VLANEXEN_M	0x3
+#define FW_VI_RXMODE_CMD_VLANEXEN_V(x)	((x) << FW_VI_RXMODE_CMD_VLANEXEN_S)
 
 struct fw_vi_enable_cmd {
 	__be32 op_to_viid;
@@ -1939,11 +1998,21 @@ struct fw_vi_enable_cmd {
 	__be32 r4;
 };
 
-#define FW_VI_ENABLE_CMD_VIID(x) ((x) << 0)
-#define FW_VI_ENABLE_CMD_IEN(x) ((x) << 31)
-#define FW_VI_ENABLE_CMD_EEN(x) ((x) << 30)
-#define FW_VI_ENABLE_CMD_DCB_INFO(x) ((x) << 28)
-#define FW_VI_ENABLE_CMD_LED (1U << 29)
+#define FW_VI_ENABLE_CMD_VIID_S         0
+#define FW_VI_ENABLE_CMD_VIID_V(x)      ((x) << FW_VI_ENABLE_CMD_VIID_S)
+
+#define FW_VI_ENABLE_CMD_IEN_S		31
+#define FW_VI_ENABLE_CMD_IEN_V(x)	((x) << FW_VI_ENABLE_CMD_IEN_S)
+
+#define FW_VI_ENABLE_CMD_EEN_S		30
+#define FW_VI_ENABLE_CMD_EEN_V(x)	((x) << FW_VI_ENABLE_CMD_EEN_S)
+
+#define FW_VI_ENABLE_CMD_LED_S		29
+#define FW_VI_ENABLE_CMD_LED_V(x)	((x) << FW_VI_ENABLE_CMD_LED_S)
+#define FW_VI_ENABLE_CMD_LED_F	FW_VI_ENABLE_CMD_LED_V(1U)
+
+#define FW_VI_ENABLE_CMD_DCB_INFO_S	28
+#define FW_VI_ENABLE_CMD_DCB_INFO_V(x)	((x) << FW_VI_ENABLE_CMD_DCB_INFO_S)
 
 /* VI VF stats offset definitions */
 #define VI_VF_NUM_STATS	16
@@ -2043,9 +2112,14 @@ struct fw_vi_stats_cmd {
 	} u;
 };
 
-#define FW_VI_STATS_CMD_VIID(x) ((x) << 0)
-#define FW_VI_STATS_CMD_NSTATS(x) ((x) << 12)
-#define FW_VI_STATS_CMD_IX(x) ((x) << 0)
+#define FW_VI_STATS_CMD_VIID_S		0
+#define FW_VI_STATS_CMD_VIID_V(x)	((x) << FW_VI_STATS_CMD_VIID_S)
+
+#define FW_VI_STATS_CMD_NSTATS_S	12
+#define FW_VI_STATS_CMD_NSTATS_V(x)	((x) << FW_VI_STATS_CMD_NSTATS_S)
+
+#define FW_VI_STATS_CMD_IX_S	0
+#define FW_VI_STATS_CMD_IX_V(x)	((x) << FW_VI_STATS_CMD_IX_S)
 
 struct fw_acl_mac_cmd {
 	__be32 op_to_vfn;
@@ -2062,9 +2136,14 @@ struct fw_acl_mac_cmd {
 	u8 macaddr3[6];
 };
 
-#define FW_ACL_MAC_CMD_PFN(x) ((x) << 8)
-#define FW_ACL_MAC_CMD_VFN(x) ((x) << 0)
-#define FW_ACL_MAC_CMD_EN(x) ((x) << 31)
+#define FW_ACL_MAC_CMD_PFN_S	8
+#define FW_ACL_MAC_CMD_PFN_V(x)	((x) << FW_ACL_MAC_CMD_PFN_S)
+
+#define FW_ACL_MAC_CMD_VFN_S	0
+#define FW_ACL_MAC_CMD_VFN_V(x)	((x) << FW_ACL_MAC_CMD_VFN_S)
+
+#define FW_ACL_MAC_CMD_EN_S	31
+#define FW_ACL_MAC_CMD_EN_V(x)	((x) << FW_ACL_MAC_CMD_EN_S)
 
 struct fw_acl_vlan_cmd {
 	__be32 op_to_vfn;
@@ -2075,11 +2154,20 @@ struct fw_acl_vlan_cmd {
 	__be16 vlanid[16];
 };
 
-#define FW_ACL_VLAN_CMD_PFN(x) ((x) << 8)
-#define FW_ACL_VLAN_CMD_VFN(x) ((x) << 0)
-#define FW_ACL_VLAN_CMD_EN(x) ((x) << 31)
-#define FW_ACL_VLAN_CMD_DROPNOVLAN(x) ((x) << 7)
-#define FW_ACL_VLAN_CMD_FM(x) ((x) << 6)
+#define FW_ACL_VLAN_CMD_PFN_S		8
+#define FW_ACL_VLAN_CMD_PFN_V(x)	((x) << FW_ACL_VLAN_CMD_PFN_S)
+
+#define FW_ACL_VLAN_CMD_VFN_S		0
+#define FW_ACL_VLAN_CMD_VFN_V(x)	((x) << FW_ACL_VLAN_CMD_VFN_S)
+
+#define FW_ACL_VLAN_CMD_EN_S	31
+#define FW_ACL_VLAN_CMD_EN_V(x)	((x) << FW_ACL_VLAN_CMD_EN_S)
+
+#define FW_ACL_VLAN_CMD_DROPNOVLAN_S	7
+#define FW_ACL_VLAN_CMD_DROPNOVLAN_V(x)	((x) << FW_ACL_VLAN_CMD_DROPNOVLAN_S)
+
+#define FW_ACL_VLAN_CMD_FM_S	6
+#define FW_ACL_VLAN_CMD_FM_V(x)	((x) << FW_ACL_VLAN_CMD_FM_S)
 
 enum fw_port_cap {
 	FW_PORT_CAP_SPEED_100M		= 0x0001,
@@ -2101,13 +2189,14 @@ enum fw_port_cap {
 };
 
 enum fw_port_mdi {
-	FW_PORT_MDI_UNCHANGED,
-	FW_PORT_MDI_AUTO,
-	FW_PORT_MDI_F_STRAIGHT,
-	FW_PORT_MDI_F_CROSSOVER
+	FW_PORT_CAP_MDI_UNCHANGED,
+	FW_PORT_CAP_MDI_AUTO,
+	FW_PORT_CAP_MDI_F_STRAIGHT,
+	FW_PORT_CAP_MDI_F_CROSSOVER
 };
 
-#define FW_PORT_MDI(x) ((x) << 9)
+#define FW_PORT_CAP_MDI_S 9
+#define FW_PORT_CAP_MDI_V(x) ((x) << FW_PORT_CAP_MDI_S)
 
 enum fw_port_action {
 	FW_PORT_ACTION_L1_CFG		= 0x0001,
@@ -2267,52 +2356,105 @@ struct fw_port_cmd {
 	} u;
 };
 
-#define FW_PORT_CMD_READ (1U << 22)
-
-#define FW_PORT_CMD_PORTID(x) ((x) << 0)
-#define FW_PORT_CMD_PORTID_GET(x) (((x) >> 0) & 0xf)
-
-#define FW_PORT_CMD_ACTION(x) ((x) << 16)
-#define FW_PORT_CMD_ACTION_GET(x) (((x) >> 16) & 0xffff)
-
-#define FW_PORT_CMD_CTLBF(x) ((x) << 10)
-#define FW_PORT_CMD_OVLAN3(x) ((x) << 7)
-#define FW_PORT_CMD_OVLAN2(x) ((x) << 6)
-#define FW_PORT_CMD_OVLAN1(x) ((x) << 5)
-#define FW_PORT_CMD_OVLAN0(x) ((x) << 4)
-#define FW_PORT_CMD_IVLAN0(x) ((x) << 3)
-
-#define FW_PORT_CMD_TXIPG(x) ((x) << 19)
-
-#define FW_PORT_CMD_LSTATUS (1U << 31)
-#define FW_PORT_CMD_LSTATUS_GET(x) (((x) >> 31) & 0x1)
-#define FW_PORT_CMD_LSPEED(x) ((x) << 24)
-#define FW_PORT_CMD_LSPEED_GET(x) (((x) >> 24) & 0x3f)
-#define FW_PORT_CMD_TXPAUSE (1U << 23)
-#define FW_PORT_CMD_RXPAUSE (1U << 22)
-#define FW_PORT_CMD_MDIOCAP (1U << 21)
-#define FW_PORT_CMD_MDIOADDR_GET(x) (((x) >> 16) & 0x1f)
-#define FW_PORT_CMD_LPTXPAUSE (1U << 15)
-#define FW_PORT_CMD_LPRXPAUSE (1U << 14)
-#define FW_PORT_CMD_PTYPE_MASK 0x1f
-#define FW_PORT_CMD_PTYPE_GET(x) (((x) >> 8) & FW_PORT_CMD_PTYPE_MASK)
-#define FW_PORT_CMD_MODTYPE_MASK 0x1f
-#define FW_PORT_CMD_MODTYPE_GET(x) (((x) >> 0) & FW_PORT_CMD_MODTYPE_MASK)
-
-#define FW_PORT_CMD_DCBXDIS (1U << 7)
-#define FW_PORT_CMD_APPLY (1U <<  7)
-#define FW_PORT_CMD_ALL_SYNCD (1U << 7)
-#define FW_PORT_CMD_DCB_VERSION_GET(x) (((x) >> 8) & 0xf)
-
-#define FW_PORT_CMD_PPPEN(x) ((x) << 31)
-#define FW_PORT_CMD_TPSRC(x) ((x) << 28)
-#define FW_PORT_CMD_NCSISRC(x) ((x) << 24)
-
-#define FW_PORT_CMD_CH0(x) ((x) << 20)
-#define FW_PORT_CMD_CH1(x) ((x) << 16)
-#define FW_PORT_CMD_CH2(x) ((x) << 12)
-#define FW_PORT_CMD_CH3(x) ((x) << 8)
-#define FW_PORT_CMD_NCSICH(x) ((x) << 4)
+#define FW_PORT_CMD_READ_S	22
+#define FW_PORT_CMD_READ_V(x)	((x) << FW_PORT_CMD_READ_S)
+#define FW_PORT_CMD_READ_F	FW_PORT_CMD_READ_V(1U)
+
+#define FW_PORT_CMD_PORTID_S	0
+#define FW_PORT_CMD_PORTID_M	0xf
+#define FW_PORT_CMD_PORTID_V(x)	((x) << FW_PORT_CMD_PORTID_S)
+#define FW_PORT_CMD_PORTID_G(x)	\
+	(((x) >> FW_PORT_CMD_PORTID_S) & FW_PORT_CMD_PORTID_M)
+
+#define FW_PORT_CMD_ACTION_S	16
+#define FW_PORT_CMD_ACTION_M	0xffff
+#define FW_PORT_CMD_ACTION_V(x)	((x) << FW_PORT_CMD_ACTION_S)
+#define FW_PORT_CMD_ACTION_G(x)	\
+	(((x) >> FW_PORT_CMD_ACTION_S) & FW_PORT_CMD_ACTION_M)
+
+#define FW_PORT_CMD_OVLAN3_S	7
+#define FW_PORT_CMD_OVLAN3_V(x)	((x) << FW_PORT_CMD_OVLAN3_S)
+
+#define FW_PORT_CMD_OVLAN2_S	6
+#define FW_PORT_CMD_OVLAN2_V(x)	((x) << FW_PORT_CMD_OVLAN2_S)
+
+#define FW_PORT_CMD_OVLAN1_S	5
+#define FW_PORT_CMD_OVLAN1_V(x)	((x) << FW_PORT_CMD_OVLAN1_S)
+
+#define FW_PORT_CMD_OVLAN0_S	4
+#define FW_PORT_CMD_OVLAN0_V(x)	((x) << FW_PORT_CMD_OVLAN0_S)
+
+#define FW_PORT_CMD_IVLAN0_S	3
+#define FW_PORT_CMD_IVLAN0_V(x)	((x) << FW_PORT_CMD_IVLAN0_S)
+
+#define FW_PORT_CMD_TXIPG_S	3
+#define FW_PORT_CMD_TXIPG_V(x)	((x) << FW_PORT_CMD_TXIPG_S)
+
+#define FW_PORT_CMD_LSTATUS_S           31
+#define FW_PORT_CMD_LSTATUS_M           0x1
+#define FW_PORT_CMD_LSTATUS_V(x)        ((x) << FW_PORT_CMD_LSTATUS_S)
+#define FW_PORT_CMD_LSTATUS_G(x)        \
+	(((x) >> FW_PORT_CMD_LSTATUS_S) & FW_PORT_CMD_LSTATUS_M)
+#define FW_PORT_CMD_LSTATUS_F   FW_PORT_CMD_LSTATUS_V(1U)
+
+#define FW_PORT_CMD_LSPEED_S	24
+#define FW_PORT_CMD_LSPEED_M	0x3f
+#define FW_PORT_CMD_LSPEED_V(x)	((x) << FW_PORT_CMD_LSPEED_S)
+#define FW_PORT_CMD_LSPEED_G(x)	\
+	(((x) >> FW_PORT_CMD_LSPEED_S) & FW_PORT_CMD_LSPEED_M)
+
+#define FW_PORT_CMD_TXPAUSE_S		23
+#define FW_PORT_CMD_TXPAUSE_V(x)	((x) << FW_PORT_CMD_TXPAUSE_S)
+#define FW_PORT_CMD_TXPAUSE_F	FW_PORT_CMD_TXPAUSE_V(1U)
+
+#define FW_PORT_CMD_RXPAUSE_S		22
+#define FW_PORT_CMD_RXPAUSE_V(x)	((x) << FW_PORT_CMD_RXPAUSE_S)
+#define FW_PORT_CMD_RXPAUSE_F	FW_PORT_CMD_RXPAUSE_V(1U)
+
+#define FW_PORT_CMD_MDIOCAP_S		21
+#define FW_PORT_CMD_MDIOCAP_V(x)	((x) << FW_PORT_CMD_MDIOCAP_S)
+#define FW_PORT_CMD_MDIOCAP_F	FW_PORT_CMD_MDIOCAP_V(1U)
+
+#define FW_PORT_CMD_MDIOADDR_S		16
+#define FW_PORT_CMD_MDIOADDR_M		0x1f
+#define FW_PORT_CMD_MDIOADDR_G(x)	\
+	(((x) >> FW_PORT_CMD_MDIOADDR_S) & FW_PORT_CMD_MDIOADDR_M)
+
+#define FW_PORT_CMD_LPTXPAUSE_S		15
+#define FW_PORT_CMD_LPTXPAUSE_V(x)	((x) << FW_PORT_CMD_LPTXPAUSE_S)
+#define FW_PORT_CMD_LPTXPAUSE_F	FW_PORT_CMD_LPTXPAUSE_V(1U)
+
+#define FW_PORT_CMD_LPRXPAUSE_S		14
+#define FW_PORT_CMD_LPRXPAUSE_V(x)	((x) << FW_PORT_CMD_LPRXPAUSE_S)
+#define FW_PORT_CMD_LPRXPAUSE_F	FW_PORT_CMD_LPRXPAUSE_V(1U)
+
+#define FW_PORT_CMD_PTYPE_S	8
+#define FW_PORT_CMD_PTYPE_M	0x1f
+#define FW_PORT_CMD_PTYPE_G(x)	\
+	(((x) >> FW_PORT_CMD_PTYPE_S) & FW_PORT_CMD_PTYPE_M)
+
+#define FW_PORT_CMD_MODTYPE_S		0
+#define FW_PORT_CMD_MODTYPE_M		0x1f
+#define FW_PORT_CMD_MODTYPE_V(x)	((x) << FW_PORT_CMD_MODTYPE_S)
+#define FW_PORT_CMD_MODTYPE_G(x)	\
+	(((x) >> FW_PORT_CMD_MODTYPE_S) & FW_PORT_CMD_MODTYPE_M)
+
+#define FW_PORT_CMD_DCBXDIS_S		7
+#define FW_PORT_CMD_DCBXDIS_V(x)	((x) << FW_PORT_CMD_DCBXDIS_S)
+#define FW_PORT_CMD_DCBXDIS_F	FW_PORT_CMD_DCBXDIS_V(1U)
+
+#define FW_PORT_CMD_APPLY_S	7
+#define FW_PORT_CMD_APPLY_V(x)	((x) << FW_PORT_CMD_APPLY_S)
+#define FW_PORT_CMD_APPLY_F	FW_PORT_CMD_APPLY_V(1U)
+
+#define FW_PORT_CMD_ALL_SYNCD_S		7
+#define FW_PORT_CMD_ALL_SYNCD_V(x)	((x) << FW_PORT_CMD_ALL_SYNCD_S)
+#define FW_PORT_CMD_ALL_SYNCD_F	FW_PORT_CMD_ALL_SYNCD_V(1U)
+
+#define FW_PORT_CMD_DCB_VERSION_S	12
+#define FW_PORT_CMD_DCB_VERSION_M	0x7
+#define FW_PORT_CMD_DCB_VERSION_G(x)	\
+	(((x) >> FW_PORT_CMD_DCB_VERSION_S) & FW_PORT_CMD_DCB_VERSION_M)
 
 enum fw_port_type {
 	FW_PORT_TYPE_FIBER_XFI,
@@ -2331,7 +2473,7 @@ enum fw_port_type {
 	FW_PORT_TYPE_QSFP,
 	FW_PORT_TYPE_BP40_BA,
 
-	FW_PORT_TYPE_NONE = FW_PORT_CMD_PTYPE_MASK
+	FW_PORT_TYPE_NONE = FW_PORT_CMD_PTYPE_M
 };
 
 enum fw_port_module_type {
@@ -2342,11 +2484,11 @@ enum fw_port_module_type {
 	FW_PORT_MOD_TYPE_TWINAX_PASSIVE,
 	FW_PORT_MOD_TYPE_TWINAX_ACTIVE,
 	FW_PORT_MOD_TYPE_LRM,
-	FW_PORT_MOD_TYPE_ERROR		= FW_PORT_CMD_MODTYPE_MASK - 3,
-	FW_PORT_MOD_TYPE_UNKNOWN	= FW_PORT_CMD_MODTYPE_MASK - 2,
-	FW_PORT_MOD_TYPE_NOTSUPPORTED	= FW_PORT_CMD_MODTYPE_MASK - 1,
+	FW_PORT_MOD_TYPE_ERROR		= FW_PORT_CMD_MODTYPE_M - 3,
+	FW_PORT_MOD_TYPE_UNKNOWN	= FW_PORT_CMD_MODTYPE_M - 2,
+	FW_PORT_MOD_TYPE_NOTSUPPORTED	= FW_PORT_CMD_MODTYPE_M - 1,
 
-	FW_PORT_MOD_TYPE_NONE = FW_PORT_CMD_MODTYPE_MASK
+	FW_PORT_MOD_TYPE_NONE = FW_PORT_CMD_MODTYPE_M
 };
 
 enum fw_port_mod_sub_type {
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index 5d3bd8d..960d35c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -291,13 +291,13 @@ int t4vf_port_init(struct adapter *adapter, int pidx)
 				       FW_CMD_REQUEST_F |
 				       FW_CMD_READ_F);
 	vi_cmd.alloc_to_len16 = cpu_to_be32(FW_LEN16(vi_cmd));
-	vi_cmd.type_viid = cpu_to_be16(FW_VI_CMD_VIID(pi->viid));
+	vi_cmd.type_viid = cpu_to_be16(FW_VI_CMD_VIID_V(pi->viid));
 	v = t4vf_wr_mbox(adapter, &vi_cmd, sizeof(vi_cmd), &vi_rpl);
 	if (v)
 		return v;
 
-	BUG_ON(pi->port_id != FW_VI_CMD_PORTID_GET(vi_rpl.portid_pkd));
-	pi->rss_size = FW_VI_CMD_RSSSIZE_GET(be16_to_cpu(vi_rpl.rsssize_pkd));
+	BUG_ON(pi->port_id != FW_VI_CMD_PORTID_G(vi_rpl.portid_pkd));
+	pi->rss_size = FW_VI_CMD_RSSSIZE_G(be16_to_cpu(vi_rpl.rsssize_pkd));
 	t4_os_set_hw_addr(adapter, pidx, vi_rpl.mac);
 
 	/*
@@ -311,9 +311,9 @@ int t4vf_port_init(struct adapter *adapter, int pidx)
 	port_cmd.op_to_portid = cpu_to_be32(FW_CMD_OP_V(FW_PORT_CMD) |
 					    FW_CMD_REQUEST_F |
 					    FW_CMD_READ_F |
-					    FW_PORT_CMD_PORTID(pi->port_id));
+					    FW_PORT_CMD_PORTID_V(pi->port_id));
 	port_cmd.action_to_len16 =
-		cpu_to_be32(FW_PORT_CMD_ACTION(FW_PORT_ACTION_GET_PORT_INFO) |
+		cpu_to_be32(FW_PORT_CMD_ACTION_V(FW_PORT_ACTION_GET_PORT_INFO) |
 			    FW_LEN16(port_cmd));
 	v = t4vf_wr_mbox(adapter, &port_cmd, sizeof(port_cmd), &port_rpl);
 	if (v)
@@ -897,13 +897,13 @@ int t4vf_alloc_vi(struct adapter *adapter, int port_id)
 				    FW_CMD_WRITE_F |
 				    FW_CMD_EXEC_F);
 	cmd.alloc_to_len16 = cpu_to_be32(FW_LEN16(cmd) |
-					 FW_VI_CMD_ALLOC);
-	cmd.portid_pkd = FW_VI_CMD_PORTID(port_id);
+					 FW_VI_CMD_ALLOC_F);
+	cmd.portid_pkd = FW_VI_CMD_PORTID_V(port_id);
 	v = t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), &rpl);
 	if (v)
 		return v;
 
-	return FW_VI_CMD_VIID_GET(be16_to_cpu(rpl.type_viid));
+	return FW_VI_CMD_VIID_G(be16_to_cpu(rpl.type_viid));
 }
 
 /**
@@ -926,8 +926,8 @@ int t4vf_free_vi(struct adapter *adapter, int viid)
 				    FW_CMD_REQUEST_F |
 				    FW_CMD_EXEC_F);
 	cmd.alloc_to_len16 = cpu_to_be32(FW_LEN16(cmd) |
-					 FW_VI_CMD_FREE);
-	cmd.type_viid = cpu_to_be16(FW_VI_CMD_VIID(viid));
+					 FW_VI_CMD_FREE_F);
+	cmd.type_viid = cpu_to_be16(FW_VI_CMD_VIID_V(viid));
 	return t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), NULL);
 }
 
@@ -949,9 +949,9 @@ int t4vf_enable_vi(struct adapter *adapter, unsigned int viid,
 	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_VI_ENABLE_CMD) |
 				     FW_CMD_REQUEST_F |
 				     FW_CMD_EXEC_F |
-				     FW_VI_ENABLE_CMD_VIID(viid));
-	cmd.ien_to_len16 = cpu_to_be32(FW_VI_ENABLE_CMD_IEN(rx_en) |
-				       FW_VI_ENABLE_CMD_EEN(tx_en) |
+				     FW_VI_ENABLE_CMD_VIID_V(viid));
+	cmd.ien_to_len16 = cpu_to_be32(FW_VI_ENABLE_CMD_IEN_V(rx_en) |
+				       FW_VI_ENABLE_CMD_EEN_V(tx_en) |
 				       FW_LEN16(cmd));
 	return t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), NULL);
 }
@@ -973,8 +973,8 @@ int t4vf_identify_port(struct adapter *adapter, unsigned int viid,
 	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_VI_ENABLE_CMD) |
 				     FW_CMD_REQUEST_F |
 				     FW_CMD_EXEC_F |
-				     FW_VI_ENABLE_CMD_VIID(viid));
-	cmd.ien_to_len16 = cpu_to_be32(FW_VI_ENABLE_CMD_LED |
+				     FW_VI_ENABLE_CMD_VIID_V(viid));
+	cmd.ien_to_len16 = cpu_to_be32(FW_VI_ENABLE_CMD_LED_F |
 				       FW_LEN16(cmd));
 	cmd.blinkdur = cpu_to_be16(nblinks);
 	return t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), NULL);
@@ -1001,28 +1001,28 @@ int t4vf_set_rxmode(struct adapter *adapter, unsigned int viid,
 
 	/* convert to FW values */
 	if (mtu < 0)
-		mtu = FW_VI_RXMODE_CMD_MTU_MASK;
+		mtu = FW_VI_RXMODE_CMD_MTU_M;
 	if (promisc < 0)
-		promisc = FW_VI_RXMODE_CMD_PROMISCEN_MASK;
+		promisc = FW_VI_RXMODE_CMD_PROMISCEN_M;
 	if (all_multi < 0)
-		all_multi = FW_VI_RXMODE_CMD_ALLMULTIEN_MASK;
+		all_multi = FW_VI_RXMODE_CMD_ALLMULTIEN_M;
 	if (bcast < 0)
-		bcast = FW_VI_RXMODE_CMD_BROADCASTEN_MASK;
+		bcast = FW_VI_RXMODE_CMD_BROADCASTEN_M;
 	if (vlanex < 0)
-		vlanex = FW_VI_RXMODE_CMD_VLANEXEN_MASK;
+		vlanex = FW_VI_RXMODE_CMD_VLANEXEN_M;
 
 	memset(&cmd, 0, sizeof(cmd));
 	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_VI_RXMODE_CMD) |
 				     FW_CMD_REQUEST_F |
 				     FW_CMD_WRITE_F |
-				     FW_VI_RXMODE_CMD_VIID(viid));
+				     FW_VI_RXMODE_CMD_VIID_V(viid));
 	cmd.retval_len16 = cpu_to_be32(FW_LEN16(cmd));
 	cmd.mtu_to_vlanexen =
-		cpu_to_be32(FW_VI_RXMODE_CMD_MTU(mtu) |
-			    FW_VI_RXMODE_CMD_PROMISCEN(promisc) |
-			    FW_VI_RXMODE_CMD_ALLMULTIEN(all_multi) |
-			    FW_VI_RXMODE_CMD_BROADCASTEN(bcast) |
-			    FW_VI_RXMODE_CMD_VLANEXEN(vlanex));
+		cpu_to_be32(FW_VI_RXMODE_CMD_MTU_V(mtu) |
+			    FW_VI_RXMODE_CMD_PROMISCEN_V(promisc) |
+			    FW_VI_RXMODE_CMD_ALLMULTIEN_V(all_multi) |
+			    FW_VI_RXMODE_CMD_BROADCASTEN_V(bcast) |
+			    FW_VI_RXMODE_CMD_VLANEXEN_V(vlanex));
 	return t4vf_wr_mbox_core(adapter, &cmd, sizeof(cmd), NULL, sleep_ok);
 }
 
@@ -1076,15 +1076,15 @@ int t4vf_alloc_mac_filt(struct adapter *adapter, unsigned int viid, bool free,
 					     FW_CMD_REQUEST_F |
 					     FW_CMD_WRITE_F |
 					     (free ? FW_CMD_EXEC_F : 0) |
-					     FW_VI_MAC_CMD_VIID(viid));
+					     FW_VI_MAC_CMD_VIID_V(viid));
 		cmd.freemacs_to_len16 =
-			cpu_to_be32(FW_VI_MAC_CMD_FREEMACS(free) |
+			cpu_to_be32(FW_VI_MAC_CMD_FREEMACS_V(free) |
 				    FW_CMD_LEN16_V(len16));
 
 		for (i = 0, p = cmd.u.exact; i < fw_naddr; i++, p++) {
 			p->valid_to_idx = cpu_to_be16(
-				FW_VI_MAC_CMD_VALID |
-				FW_VI_MAC_CMD_IDX(FW_VI_MAC_ADD_MAC));
+				FW_VI_MAC_CMD_VALID_F |
+				FW_VI_MAC_CMD_IDX_V(FW_VI_MAC_ADD_MAC));
 			memcpy(p->macaddr, addr[offset+i], sizeof(p->macaddr));
 		}
 
@@ -1095,7 +1095,7 @@ int t4vf_alloc_mac_filt(struct adapter *adapter, unsigned int viid, bool free,
 			break;
 
 		for (i = 0, p = rpl.u.exact; i < fw_naddr; i++, p++) {
-			u16 index = FW_VI_MAC_CMD_IDX_GET(
+			u16 index = FW_VI_MAC_CMD_IDX_G(
 				be16_to_cpu(p->valid_to_idx));
 
 			if (idx)
@@ -1164,16 +1164,16 @@ int t4vf_change_mac(struct adapter *adapter, unsigned int viid,
 	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_VI_MAC_CMD) |
 				     FW_CMD_REQUEST_F |
 				     FW_CMD_WRITE_F |
-				     FW_VI_MAC_CMD_VIID(viid));
+				     FW_VI_MAC_CMD_VIID_V(viid));
 	cmd.freemacs_to_len16 = cpu_to_be32(FW_CMD_LEN16_V(len16));
-	p->valid_to_idx = cpu_to_be16(FW_VI_MAC_CMD_VALID |
-				      FW_VI_MAC_CMD_IDX(idx));
+	p->valid_to_idx = cpu_to_be16(FW_VI_MAC_CMD_VALID_F |
+				      FW_VI_MAC_CMD_IDX_V(idx));
 	memcpy(p->macaddr, addr, sizeof(p->macaddr));
 
 	ret = t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), &rpl);
 	if (ret == 0) {
 		p = &rpl.u.exact[0];
-		ret = FW_VI_MAC_CMD_IDX_GET(be16_to_cpu(p->valid_to_idx));
+		ret = FW_VI_MAC_CMD_IDX_G(be16_to_cpu(p->valid_to_idx));
 		if (ret >= max_naddr)
 			ret = -ENOMEM;
 	}
@@ -1201,9 +1201,9 @@ int t4vf_set_addr_hash(struct adapter *adapter, unsigned int viid,
 	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_VI_MAC_CMD) |
 				     FW_CMD_REQUEST_F |
 				     FW_CMD_WRITE_F |
-				     FW_VI_ENABLE_CMD_VIID(viid));
-	cmd.freemacs_to_len16 = cpu_to_be32(FW_VI_MAC_CMD_HASHVECEN |
-					    FW_VI_MAC_CMD_HASHUNIEN(ucast) |
+				     FW_VI_ENABLE_CMD_VIID_V(viid));
+	cmd.freemacs_to_len16 = cpu_to_be32(FW_VI_MAC_CMD_HASHVECEN_F |
+					    FW_VI_MAC_CMD_HASHUNIEN_V(ucast) |
 					    FW_CMD_LEN16_V(len16));
 	cmd.u.hash.hashvec = cpu_to_be64(vec);
 	return t4vf_wr_mbox_core(adapter, &cmd, sizeof(cmd), NULL, sleep_ok);
@@ -1241,13 +1241,13 @@ int t4vf_get_port_stats(struct adapter *adapter, int pidx,
 
 		memset(&cmd, 0, sizeof(cmd));
 		cmd.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_VI_STATS_CMD) |
-					     FW_VI_STATS_CMD_VIID(pi->viid) |
+					     FW_VI_STATS_CMD_VIID_V(pi->viid) |
 					     FW_CMD_REQUEST_F |
 					     FW_CMD_READ_F);
 		cmd.retval_len16 = cpu_to_be32(FW_CMD_LEN16_V(len16));
 		cmd.u.ctl.nstats_ix =
-			cpu_to_be16(FW_VI_STATS_CMD_IX(ix) |
-				    FW_VI_STATS_CMD_NSTATS(nstats));
+			cpu_to_be16(FW_VI_STATS_CMD_IX_V(ix) |
+				    FW_VI_STATS_CMD_NSTATS_V(nstats));
 		ret = t4vf_wr_mbox_ns(adapter, &cmd, len, &rpl);
 		if (ret)
 			return ret;
@@ -1359,7 +1359,7 @@ int t4vf_handle_fw_rpl(struct adapter *adapter, const __be64 *rpl)
 		/*
 		 * Extract various fields from port status change message.
 		 */
-		action = FW_PORT_CMD_ACTION_GET(
+		action = FW_PORT_CMD_ACTION_G(
 			be32_to_cpu(port_cmd->action_to_len16));
 		if (action != FW_PORT_ACTION_GET_PORT_INFO) {
 			dev_err(adapter->pdev_dev,
@@ -1368,24 +1368,24 @@ int t4vf_handle_fw_rpl(struct adapter *adapter, const __be64 *rpl)
 			break;
 		}
 
-		port_id = FW_PORT_CMD_PORTID_GET(
+		port_id = FW_PORT_CMD_PORTID_G(
 			be32_to_cpu(port_cmd->op_to_portid));
 
 		word = be32_to_cpu(port_cmd->u.info.lstatus_to_modtype);
-		link_ok = (word & FW_PORT_CMD_LSTATUS) != 0;
+		link_ok = (word & FW_PORT_CMD_LSTATUS_F) != 0;
 		speed = 0;
 		fc = 0;
-		if (word & FW_PORT_CMD_RXPAUSE)
+		if (word & FW_PORT_CMD_RXPAUSE_F)
 			fc |= PAUSE_RX;
-		if (word & FW_PORT_CMD_TXPAUSE)
+		if (word & FW_PORT_CMD_TXPAUSE_F)
 			fc |= PAUSE_TX;
-		if (word & FW_PORT_CMD_LSPEED(FW_PORT_CAP_SPEED_100M))
+		if (word & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_100M))
 			speed = 100;
-		else if (word & FW_PORT_CMD_LSPEED(FW_PORT_CAP_SPEED_1G))
+		else if (word & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_1G))
 			speed = 1000;
-		else if (word & FW_PORT_CMD_LSPEED(FW_PORT_CAP_SPEED_10G))
+		else if (word & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_10G))
 			speed = 10000;
-		else if (word & FW_PORT_CMD_LSPEED(FW_PORT_CAP_SPEED_40G))
+		else if (word & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_40G))
 			speed = 40000;
 
 		/*
diff --git a/drivers/scsi/csiostor/csio_mb.c b/drivers/scsi/csiostor/csio_mb.c
index 5a514b6..8298878 100644
--- a/drivers/scsi/csiostor/csio_mb.c
+++ b/drivers/scsi/csiostor/csio_mb.c
@@ -347,24 +347,24 @@ csio_mb_port(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo,
 	     void (*cbfn) (struct csio_hw *, struct csio_mb *))
 {
 	struct fw_port_cmd *cmdp = (struct fw_port_cmd *)(mbp->mb);
-	unsigned int lfc = 0, mdi = FW_PORT_MDI(FW_PORT_MDI_AUTO);
+	unsigned int lfc = 0, mdi = FW_PORT_CAP_MDI_V(FW_PORT_CAP_MDI_AUTO);
 
 	CSIO_INIT_MBP(mbp, cmdp, tmo, hw, cbfn,  1);
 
 	cmdp->op_to_portid = htonl(FW_CMD_OP_V(FW_PORT_CMD)		|
 				   FW_CMD_REQUEST_F			|
 				   (wr ? FW_CMD_EXEC_F : FW_CMD_READ_F)	|
-				   FW_PORT_CMD_PORTID(portid));
+				   FW_PORT_CMD_PORTID_V(portid));
 	if (!wr) {
 		cmdp->action_to_len16 = htonl(
-			FW_PORT_CMD_ACTION(FW_PORT_ACTION_GET_PORT_INFO) |
+			FW_PORT_CMD_ACTION_V(FW_PORT_ACTION_GET_PORT_INFO) |
 			FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 		return;
 	}
 
 	/* Set port */
 	cmdp->action_to_len16 = htonl(
-			FW_PORT_CMD_ACTION(FW_PORT_ACTION_L1_CFG) |
+			FW_PORT_CMD_ACTION_V(FW_PORT_ACTION_L1_CFG) |
 			FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 
 	if (fc & PAUSE_RX)
@@ -1407,9 +1407,9 @@ csio_mb_fwevt_handler(struct csio_hw *hw, __be64 *cmd)
 
 	if (opcode == FW_PORT_CMD) {
 		pcmd = (struct fw_port_cmd *)cmd;
-		port_id = FW_PORT_CMD_PORTID_GET(
+		port_id = FW_PORT_CMD_PORTID_G(
 				ntohl(pcmd->op_to_portid));
-		action = FW_PORT_CMD_ACTION_GET(
+		action = FW_PORT_CMD_ACTION_G(
 				ntohl(pcmd->action_to_len16));
 		if (action != FW_PORT_ACTION_GET_PORT_INFO) {
 			csio_err(hw, "Unhandled FW_PORT_CMD action: %u\n",
@@ -1418,15 +1418,15 @@ csio_mb_fwevt_handler(struct csio_hw *hw, __be64 *cmd)
 		}
 
 		link_status = ntohl(pcmd->u.info.lstatus_to_modtype);
-		mod_type = FW_PORT_CMD_MODTYPE_GET(link_status);
+		mod_type = FW_PORT_CMD_MODTYPE_G(link_status);
 
 		hw->pport[port_id].link_status =
-			FW_PORT_CMD_LSTATUS_GET(link_status);
+			FW_PORT_CMD_LSTATUS_G(link_status);
 		hw->pport[port_id].link_speed =
-			FW_PORT_CMD_LSPEED_GET(link_status);
+			FW_PORT_CMD_LSPEED_G(link_status);
 
 		csio_info(hw, "Port:%x - LINK %s\n", port_id,
-			FW_PORT_CMD_LSTATUS_GET(link_status) ? "UP" : "DOWN");
+			FW_PORT_CMD_LSTATUS_G(link_status) ? "UP" : "DOWN");
 
 		if (mod_type != hw->pport[port_id].mod_type) {
 			hw->pport[port_id].mod_type = mod_type;
-- 
1.7.1

