From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 8/9] cxgb4: update FW definitions
Date: Wed, 16 Jun 2010 15:01:15 -0700
Message-ID: <1276725676-31514-9-git-send-email-dm@chelsio.com>
References: <1276725676-31514-1-git-send-email-dm@chelsio.com>
 <1276725676-31514-2-git-send-email-dm@chelsio.com>
 <1276725676-31514-3-git-send-email-dm@chelsio.com>
 <1276725676-31514-4-git-send-email-dm@chelsio.com>
 <1276725676-31514-5-git-send-email-dm@chelsio.com>
 <1276725676-31514-6-git-send-email-dm@chelsio.com>
 <1276725676-31514-7-git-send-email-dm@chelsio.com>
 <1276725676-31514-8-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:1748 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759780Ab0FPWBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 18:01:18 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o5GM1JEC032136
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 15:01:19 -0700
In-Reply-To: <1276725676-31514-8-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update to latest FW API.  Most changes here pertain to port types and
querying FW for parameter values.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |   55 ++++++++++++++++++++++++++++++---------
 drivers/net/cxgb4/cxgb4_uld.h  |    2 +
 drivers/net/cxgb4/t4_hw.c      |    6 ++--
 drivers/net/cxgb4/t4fw_api.h   |   36 +++++++++++++++++++------
 4 files changed, 74 insertions(+), 25 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index eb1492f..352c770 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -216,7 +216,7 @@ void t4_os_link_changed(struct adapter *adapter, int port_id, int link_stat)
 void t4_os_portmod_changed(const struct adapter *adap, int port_id)
 {
 	static const char *mod_str[] = {
-		NULL, "LR", "SR", "ER", "passive DA", "active DA"
+		NULL, "LR", "SR", "ER", "passive DA", "active DA", "LRM"
 	};
 
 	const struct net_device *dev = adap->port[port_id];
@@ -224,7 +224,7 @@ void t4_os_portmod_changed(const struct adapter *adap, int port_id)
 
 	if (pi->mod_type == FW_PORT_MOD_TYPE_NONE)
 		netdev_info(dev, "port module unplugged\n");
-	else
+	else if (pi->mod_type < ARRAY_SIZE(mod_str))
 		netdev_info(dev, "%s module inserted\n", mod_str[pi->mod_type]);
 }
 
@@ -1234,7 +1234,8 @@ static unsigned int from_fw_linkcaps(unsigned int type, unsigned int caps)
 {
 	unsigned int v = 0;
 
-	if (type == FW_PORT_TYPE_BT_SGMII || type == FW_PORT_TYPE_BT_XAUI) {
+	if (type == FW_PORT_TYPE_BT_SGMII || type == FW_PORT_TYPE_BT_XFI ||
+	    type == FW_PORT_TYPE_BT_XAUI) {
 		v |= SUPPORTED_TP;
 		if (caps & FW_PORT_CAP_SPEED_100M)
 			v |= SUPPORTED_100baseT_Full;
@@ -1250,7 +1251,10 @@ static unsigned int from_fw_linkcaps(unsigned int type, unsigned int caps)
 			v |= SUPPORTED_10000baseKX4_Full;
 	} else if (type == FW_PORT_TYPE_KR)
 		v |= SUPPORTED_Backplane | SUPPORTED_10000baseKR_Full;
-	else if (type == FW_PORT_TYPE_FIBER)
+	else if (type == FW_PORT_TYPE_BP_AP)
+		v |= SUPPORTED_Backplane | SUPPORTED_10000baseR_FEC;
+	else if (type == FW_PORT_TYPE_FIBER_XFI ||
+		 type == FW_PORT_TYPE_FIBER_XAUI || type == FW_PORT_TYPE_SFP)
 		v |= SUPPORTED_FIBRE;
 
 	if (caps & FW_PORT_CAP_ANEG)
@@ -1276,13 +1280,19 @@ static int get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	const struct port_info *p = netdev_priv(dev);
 
 	if (p->port_type == FW_PORT_TYPE_BT_SGMII ||
+	    p->port_type == FW_PORT_TYPE_BT_XFI ||
 	    p->port_type == FW_PORT_TYPE_BT_XAUI)
 		cmd->port = PORT_TP;
-	else if (p->port_type == FW_PORT_TYPE_FIBER)
+	else if (p->port_type == FW_PORT_TYPE_FIBER_XFI ||
+		 p->port_type == FW_PORT_TYPE_FIBER_XAUI)
 		cmd->port = PORT_FIBRE;
-	else if (p->port_type == FW_PORT_TYPE_TWINAX)
-		cmd->port = PORT_DA;
-	else
+	else if (p->port_type == FW_PORT_TYPE_SFP) {
+		if (p->mod_type == FW_PORT_MOD_TYPE_TWINAX_PASSIVE ||
+		    p->mod_type == FW_PORT_MOD_TYPE_TWINAX_ACTIVE)
+			cmd->port = PORT_DA;
+		else
+			cmd->port = PORT_FIBRE;
+	} else
 		cmd->port = PORT_OTHER;
 
 	if (p->mdio_addr >= 0) {
@@ -2814,14 +2824,20 @@ static int adap_init0(struct adapter *adap)
 	for (v = 1; v < SGE_NCOUNTERS; v++)
 		adap->sge.counter_val[v] = min(intr_cnt[v - 1],
 					       THRESHOLD_3_MASK);
-	ret = adap_init1(adap, &c);
-	if (ret < 0)
-		goto bye;
-
 #define FW_PARAM_DEV(param) \
 	(FW_PARAMS_MNEM(FW_PARAMS_MNEM_DEV) | \
 	 FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_DEV_##param))
 
+	params[0] = FW_PARAM_DEV(CCLK);
+	ret = t4_query_params(adap, 0, 0, 0, 1, params, val);
+	if (ret < 0)
+		goto bye;
+	adap->params.vpd.cclk = val[0];
+
+	ret = adap_init1(adap, &c);
+	if (ret < 0)
+		goto bye;
+
 #define FW_PARAM_PFVF(param) \
 	(FW_PARAMS_MNEM(FW_PARAMS_MNEM_PFVF) | \
 	 FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_PFVF_##param))
@@ -2874,6 +2890,18 @@ static int adap_init0(struct adapter *adap)
 		adap->vres.rq.size = val[3] - val[2] + 1;
 		adap->vres.pbl.start = val[4];
 		adap->vres.pbl.size = val[5] - val[4] + 1;
+
+		params[0] = FW_PARAM_PFVF(SQRQ_START);
+		params[1] = FW_PARAM_PFVF(SQRQ_END);
+		params[2] = FW_PARAM_PFVF(CQ_START);
+		params[3] = FW_PARAM_PFVF(CQ_END);
+		ret = t4_query_params(adap, 0, 0, 0, 4, params, val);
+		if (ret < 0)
+			goto bye;
+		adap->vres.qp.start = val[0];
+		adap->vres.qp.size = val[1] - val[0] + 1;
+		adap->vres.cq.start = val[2];
+		adap->vres.cq.size = val[3] - val[2] + 1;
 	}
 	if (c.iscsicaps) {
 		params[0] = FW_PARAM_PFVF(ISCSI_START);
@@ -3194,7 +3222,8 @@ static int __devinit enable_msix(struct adapter *adap)
 static void __devinit print_port_info(struct adapter *adap)
 {
 	static const char *base[] = {
-		"R", "KX4", "T", "KX", "T", "KR", "CX4"
+		"R XFI", "R XAUI", "T SGMII", "T XFI", "T XAUI", "KX4", "CX4",
+		"KX", "KR", "KR SFP+", "KR FEC"
 	};
 
 	int i;
diff --git a/drivers/net/cxgb4/cxgb4_uld.h b/drivers/net/cxgb4/cxgb4_uld.h
index 5b98546..0dc0866 100644
--- a/drivers/net/cxgb4/cxgb4_uld.h
+++ b/drivers/net/cxgb4/cxgb4_uld.h
@@ -185,6 +185,8 @@ struct cxgb4_virt_res {                      /* virtualized HW resources */
 	struct cxgb4_range stag;
 	struct cxgb4_range rq;
 	struct cxgb4_range pbl;
+	struct cxgb4_range qp;
+	struct cxgb4_range cq;
 };
 
 /*
diff --git a/drivers/net/cxgb4/t4_hw.c b/drivers/net/cxgb4/t4_hw.c
index 5c058ea..d92129b 100644
--- a/drivers/net/cxgb4/t4_hw.c
+++ b/drivers/net/cxgb4/t4_hw.c
@@ -2580,7 +2580,7 @@ int t4_alloc_vi(struct adapter *adap, unsigned int mbox, unsigned int port,
 	}
 	if (rss_size)
 		*rss_size = FW_VI_CMD_RSSSIZE_GET(ntohs(c.rsssize_pkd));
-	return ntohs(c.viid_pkd);
+	return FW_VI_CMD_VIID_GET(ntohs(c.type_viid));
 }
 
 /**
@@ -2603,7 +2603,7 @@ int t4_free_vi(struct adapter *adap, unsigned int mbox, unsigned int pf,
 			    FW_CMD_EXEC | FW_VI_CMD_PFN(pf) |
 			    FW_VI_CMD_VFN(vf));
 	c.alloc_to_len16 = htonl(FW_VI_CMD_FREE | FW_LEN16(c));
-	c.viid_pkd = htons(FW_VI_CMD_VIID(viid));
+	c.type_viid = htons(FW_VI_CMD_VIID(viid));
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), &c);
 }
 
@@ -3169,7 +3169,7 @@ int __devinit t4_port_init(struct adapter *adap, int mbox, int pf, int vf)
 		p->mdio_addr = (ret & FW_PORT_CMD_MDIOCAP) ?
 			FW_PORT_CMD_MDIOADDR_GET(ret) : -1;
 		p->port_type = FW_PORT_CMD_PTYPE_GET(ret);
-		p->mod_type = FW_PORT_CMD_MODTYPE_GET(ret);
+		p->mod_type = FW_PORT_MOD_TYPE_NA;
 
 		init_link_config(&p->link_cfg, ntohs(c.u.info.pcap));
 		j++;
diff --git a/drivers/net/cxgb4/t4fw_api.h b/drivers/net/cxgb4/t4fw_api.h
index 63991d6..a6643c6 100644
--- a/drivers/net/cxgb4/t4fw_api.h
+++ b/drivers/net/cxgb4/t4fw_api.h
@@ -51,7 +51,6 @@ enum fw_wr_opcodes {
 	FW_CMD_WR                      = 0x10,
 	FW_ETH_TX_PKT_VM_WR            = 0x11,
 	FW_RI_RES_WR                   = 0x0c,
-	FW_RI_INIT_WR                  = 0x0d,
 	FW_RI_RDMA_WRITE_WR            = 0x14,
 	FW_RI_SEND_WR                  = 0x15,
 	FW_RI_RDMA_READ_WR             = 0x16,
@@ -59,6 +58,7 @@ enum fw_wr_opcodes {
 	FW_RI_BIND_MW_WR               = 0x18,
 	FW_RI_FR_NSMR_WR               = 0x19,
 	FW_RI_INV_LSTAG_WR             = 0x1a,
+	FW_RI_WR                       = 0x0d,
 	FW_LASTC2E_WR                  = 0x40
 };
 
@@ -475,7 +475,13 @@ enum fw_params_param_pfvf {
 	FW_PARAMS_PARAM_PFVF_PBL_END	= 0x12,
 	FW_PARAMS_PARAM_PFVF_L2T_START = 0x13,
 	FW_PARAMS_PARAM_PFVF_L2T_END = 0x14,
+	FW_PARAMS_PARAM_PFVF_SQRQ_START = 0x15,
+	FW_PARAMS_PARAM_PFVF_SQRQ_END	= 0x16,
+	FW_PARAMS_PARAM_PFVF_CQ_START	= 0x17,
+	FW_PARAMS_PARAM_PFVF_CQ_END	= 0x18,
 	FW_PARAMS_PARAM_PFVF_SCHEDCLASS_ETH = 0x20,
+	FW_PARAMS_PARAM_PFVF_VIID       = 0x24,
+	FW_PARAMS_PARAM_PFVF_CPMASK     = 0x25,
 };
 
 /*
@@ -804,16 +810,16 @@ struct fw_eq_ofld_cmd {
 struct fw_vi_cmd {
 	__be32 op_to_vfn;
 	__be32 alloc_to_len16;
-	__be16 viid_pkd;
+	__be16 type_viid;
 	u8 mac[6];
 	u8 portid_pkd;
 	u8 nmac;
 	u8 nmac0[6];
 	__be16 rsssize_pkd;
 	u8 nmac1[6];
-	__be16 r7;
+	__be16 idsiiq_pkd;
 	u8 nmac2[6];
-	__be16 r8;
+	__be16 idseiq_pkd;
 	u8 nmac3[6];
 	__be64 r9;
 	__be64 r10;
@@ -824,6 +830,7 @@ struct fw_vi_cmd {
 #define FW_VI_CMD_ALLOC (1U << 31)
 #define FW_VI_CMD_FREE (1U << 30)
 #define FW_VI_CMD_VIID(x) ((x) << 0)
+#define FW_VI_CMD_VIID_GET(x) ((x) & 0xfff)
 #define FW_VI_CMD_PORTID(x) ((x) << 4)
 #define FW_VI_CMD_RSSSIZE_GET(x) (((x) >> 0) & 0x7ff)
 
@@ -1136,6 +1143,11 @@ struct fw_port_cmd {
 			__be32 lstatus_to_modtype;
 			__be16 pcap;
 			__be16 acap;
+			__be16 mtu;
+			__u8   cbllen;
+			__u8   r9;
+			__be32 r10;
+			__be64 r11;
 		} info;
 		struct fw_port_ppp {
 			__be32 pppen_to_ncsich;
@@ -1196,14 +1208,17 @@ struct fw_port_cmd {
 #define FW_PORT_CMD_NCSICH(x) ((x) << 4)
 
 enum fw_port_type {
-	FW_PORT_TYPE_FIBER,
-	FW_PORT_TYPE_KX4,
+	FW_PORT_TYPE_FIBER_XFI,
+	FW_PORT_TYPE_FIBER_XAUI,
 	FW_PORT_TYPE_BT_SGMII,
-	FW_PORT_TYPE_KX,
+	FW_PORT_TYPE_BT_XFI,
 	FW_PORT_TYPE_BT_XAUI,
-	FW_PORT_TYPE_KR,
+	FW_PORT_TYPE_KX4,
 	FW_PORT_TYPE_CX4,
-	FW_PORT_TYPE_TWINAX,
+	FW_PORT_TYPE_KX,
+	FW_PORT_TYPE_KR,
+	FW_PORT_TYPE_SFP,
+	FW_PORT_TYPE_BP_AP,
 
 	FW_PORT_TYPE_NONE = FW_PORT_CMD_PTYPE_MASK
 };
@@ -1213,6 +1228,9 @@ enum fw_port_module_type {
 	FW_PORT_MOD_TYPE_LR,
 	FW_PORT_MOD_TYPE_SR,
 	FW_PORT_MOD_TYPE_ER,
+	FW_PORT_MOD_TYPE_TWINAX_PASSIVE,
+	FW_PORT_MOD_TYPE_TWINAX_ACTIVE,
+	FW_PORT_MOD_TYPE_LRM,
 
 	FW_PORT_MOD_TYPE_NONE = FW_PORT_CMD_MODTYPE_MASK
 };
-- 
1.5.4

