From: Manish Chopra <manish.chopra@cavium.com>
Subject: [PATCH net-next 1/6] qed: refactor tunnelling - API/Structs
Date: Mon, 24 Apr 2017 10:00:44 -0700
Message-ID: <20170424170049.16027-2-manish.chopra@cavium.com>
References: <20170424170049.16027-1-manish.chopra@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0054.outbound.protection.outlook.com ([104.47.34.54]:26880
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S975228AbdDXRBX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 13:01:23 -0400
In-Reply-To: <20170424170049.16027-1-manish.chopra@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the tunnel APIs to use per tunnel
info instead of using bitmasks for all tunnels and also
uses single struct to hold the data to prepare multiple
variant of tunnel configuration ramrods to be sent to the hardware.

Signed-off-by: Manish Chopra <manish.chopra@cavium.com>
Signed-off-by: Yuval Mintz <yuval.mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h             |  30 +-
 drivers/net/ethernet/qlogic/qed/qed_dev.c         |   2 +-
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h     |   2 +-
 drivers/net/ethernet/qlogic/qed/qed_l2.c          |  15 +-
 drivers/net/ethernet/qlogic/qed/qed_main.c        |  24 +-
 drivers/net/ethernet/qlogic/qed/qed_sp.h          |   4 +-
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c | 327 +++++++++++-----------
 7 files changed, 207 insertions(+), 197 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index c539ba1..8b7b1dd 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -149,9 +149,35 @@ enum qed_tunn_clss {
 	QED_TUNN_CLSS_MAC_VNI,
 	QED_TUNN_CLSS_INNER_MAC_VLAN,
 	QED_TUNN_CLSS_INNER_MAC_VNI,
+	QED_TUNN_CLSS_MAC_VLAN_DUAL_STAGE,
 	MAX_QED_TUNN_CLSS,
 };
 
+struct qed_tunn_update_type {
+	bool b_update_mode;
+	bool b_mode_enabled;
+	enum qed_tunn_clss tun_cls;
+};
+
+struct qed_tunn_update_udp_port {
+	bool b_update_port;
+	u16 port;
+};
+
+struct qed_tunnel_info {
+	struct qed_tunn_update_type vxlan;
+	struct qed_tunn_update_type l2_geneve;
+	struct qed_tunn_update_type ip_geneve;
+	struct qed_tunn_update_type l2_gre;
+	struct qed_tunn_update_type ip_gre;
+
+	struct qed_tunn_update_udp_port vxlan_port;
+	struct qed_tunn_update_udp_port geneve_port;
+
+	bool b_update_rx_cls;
+	bool b_update_tx_cls;
+};
+
 struct qed_tunn_start_params {
 	unsigned long	tunn_mode;
 	u16		vxlan_udp_port;
@@ -648,9 +674,7 @@ struct qed_dev {
 	/* SRIOV */
 	struct qed_hw_sriov_info *p_iov_info;
 #define IS_QED_SRIOV(cdev)              (!!(cdev)->p_iov_info)
-
-	unsigned long			tunn_mode;
-
+	struct qed_tunnel_info		tunnel;
 	bool				b_is_vf;
 	u32				drv_type;
 	struct qed_eth_stats		*reset_stats;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 6d24308..13817cc 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -1453,7 +1453,7 @@ static int qed_hw_init_port(struct qed_hwfn *p_hwfn,
 
 static int qed_hw_init_pf(struct qed_hwfn *p_hwfn,
 			  struct qed_ptt *p_ptt,
-			  struct qed_tunn_start_params *p_tunn,
+			  struct qed_tunnel_info *p_tunn,
 			  int hw_mode,
 			  bool b_hw_start,
 			  enum qed_int_mode int_mode,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
index 341636d..cefe3ee 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
@@ -113,7 +113,7 @@ struct qed_drv_load_params {
 
 struct qed_hw_init_params {
 	/* Tunneling parameters */
-	struct qed_tunn_start_params *p_tunn;
+	struct qed_tunnel_info *p_tunn;
 
 	bool b_hw_start;
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index eb5e280..03216ba 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -2285,21 +2285,21 @@ static int qed_stop_txq(struct qed_dev *cdev, u8 rss_id, void *handle)
 static int qed_tunn_configure(struct qed_dev *cdev,
 			      struct qed_tunn_params *tunn_params)
 {
-	struct qed_tunn_update_params tunn_info;
+	struct qed_tunnel_info tunn_info;
 	int i, rc;
 
 	if (IS_VF(cdev))
 		return 0;
 
 	memset(&tunn_info, 0, sizeof(tunn_info));
-	if (tunn_params->update_vxlan_port == 1) {
-		tunn_info.update_vxlan_udp_port = 1;
-		tunn_info.vxlan_udp_port = tunn_params->vxlan_port;
+	if (tunn_params->update_vxlan_port) {
+		tunn_info.vxlan_port.b_update_port = true;
+		tunn_info.vxlan_port.port = tunn_params->vxlan_port;
 	}
 
-	if (tunn_params->update_geneve_port == 1) {
-		tunn_info.update_geneve_udp_port = 1;
-		tunn_info.geneve_udp_port = tunn_params->geneve_port;
+	if (tunn_params->update_geneve_port) {
+		tunn_info.geneve_port.b_update_port = true;
+		tunn_info.geneve_port.port = tunn_params->geneve_port;
 	}
 
 	for_each_hwfn(cdev, i) {
@@ -2307,7 +2307,6 @@ static int qed_tunn_configure(struct qed_dev *cdev,
 
 		rc = qed_sp_pf_update_tunn_cfg(hwfn, &tunn_info,
 					       QED_SPQ_MODE_EBLOCK, NULL);
-
 		if (rc)
 			return rc;
 	}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index da562cf..a622d75 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -909,8 +909,8 @@ static int qed_slowpath_start(struct qed_dev *cdev,
 {
 	struct qed_drv_load_params drv_load_params;
 	struct qed_hw_init_params hw_init_params;
-	struct qed_tunn_start_params tunn_info;
 	struct qed_mcp_drv_version drv_version;
+	struct qed_tunnel_info tunn_info;
 	const u8 *data = NULL;
 	struct qed_hwfn *hwfn;
 	struct qed_ptt *p_ptt;
@@ -974,19 +974,19 @@ static int qed_slowpath_start(struct qed_dev *cdev,
 		qed_dbg_pf_init(cdev);
 	}
 
-	memset(&tunn_info, 0, sizeof(tunn_info));
-	tunn_info.tunn_mode |=  1 << QED_MODE_VXLAN_TUNN |
-				1 << QED_MODE_L2GRE_TUNN |
-				1 << QED_MODE_IPGRE_TUNN |
-				1 << QED_MODE_L2GENEVE_TUNN |
-				1 << QED_MODE_IPGENEVE_TUNN;
-
-	tunn_info.tunn_clss_vxlan = QED_TUNN_CLSS_MAC_VLAN;
-	tunn_info.tunn_clss_l2gre = QED_TUNN_CLSS_MAC_VLAN;
-	tunn_info.tunn_clss_ipgre = QED_TUNN_CLSS_MAC_VLAN;
-
 	/* Start the slowpath */
 	memset(&hw_init_params, 0, sizeof(hw_init_params));
+	memset(&tunn_info, 0, sizeof(tunn_info));
+	tunn_info.vxlan.b_mode_enabled = true;
+	tunn_info.l2_gre.b_mode_enabled = true;
+	tunn_info.ip_gre.b_mode_enabled = true;
+	tunn_info.l2_geneve.b_mode_enabled = true;
+	tunn_info.ip_geneve.b_mode_enabled = true;
+	tunn_info.vxlan.tun_cls = QED_TUNN_CLSS_MAC_VLAN;
+	tunn_info.l2_gre.tun_cls = QED_TUNN_CLSS_MAC_VLAN;
+	tunn_info.ip_gre.tun_cls = QED_TUNN_CLSS_MAC_VLAN;
+	tunn_info.l2_geneve.tun_cls = QED_TUNN_CLSS_MAC_VLAN;
+	tunn_info.ip_geneve.tun_cls = QED_TUNN_CLSS_MAC_VLAN;
 	hw_init_params.p_tunn = &tunn_info;
 	hw_init_params.b_hw_start = true;
 	hw_init_params.int_mode = cdev->int_params.out.int_mode;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp.h b/drivers/net/ethernet/qlogic/qed/qed_sp.h
index 583c8d3..3357bbe 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp.h
@@ -409,7 +409,7 @@ int qed_sp_init_request(struct qed_hwfn *p_hwfn,
  */
 
 int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
-		    struct qed_tunn_start_params *p_tunn,
+		    struct qed_tunnel_info *p_tunn,
 		    enum qed_mf_mode mode, bool allow_npar_tx_switch);
 
 /**
@@ -442,7 +442,7 @@ int qed_sp_pf_update(struct qed_hwfn *p_hwfn);
 int qed_sp_pf_stop(struct qed_hwfn *p_hwfn);
 
 int qed_sp_pf_update_tunn_cfg(struct qed_hwfn *p_hwfn,
-			      struct qed_tunn_update_params *p_tunn,
+			      struct qed_tunnel_info *p_tunn,
 			      enum spq_mode comp_mode,
 			      struct qed_spq_comp_cb *p_comp_data);
 /**
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
index 6fb80f9..96c6fda 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
@@ -111,7 +111,7 @@ int qed_sp_init_request(struct qed_hwfn *p_hwfn,
 	return 0;
 }
 
-static enum tunnel_clss qed_tunn_get_clss_type(u8 type)
+static enum tunnel_clss qed_tunn_clss_to_fw_clss(u8 type)
 {
 	switch (type) {
 	case QED_TUNN_CLSS_MAC_VLAN:
@@ -122,206 +122,201 @@ static enum tunnel_clss qed_tunn_get_clss_type(u8 type)
 		return TUNNEL_CLSS_INNER_MAC_VLAN;
 	case QED_TUNN_CLSS_INNER_MAC_VNI:
 		return TUNNEL_CLSS_INNER_MAC_VNI;
+	case QED_TUNN_CLSS_MAC_VLAN_DUAL_STAGE:
+		return TUNNEL_CLSS_MAC_VLAN_DUAL_STAGE;
 	default:
 		return TUNNEL_CLSS_MAC_VLAN;
 	}
 }
 
 static void
-qed_tunn_set_pf_fix_tunn_mode(struct qed_hwfn *p_hwfn,
-			      struct qed_tunn_update_params *p_src,
-			      struct pf_update_tunnel_config *p_tunn_cfg)
+qed_set_pf_update_tunn_mode(struct qed_tunnel_info *p_tun,
+			    struct qed_tunnel_info *p_src, bool b_pf_start)
 {
-	unsigned long cached_tunn_mode = p_hwfn->cdev->tunn_mode;
-	unsigned long update_mask = p_src->tunn_mode_update_mask;
-	unsigned long tunn_mode = p_src->tunn_mode;
-	unsigned long new_tunn_mode = 0;
-
-	if (test_bit(QED_MODE_L2GRE_TUNN, &update_mask)) {
-		if (test_bit(QED_MODE_L2GRE_TUNN, &tunn_mode))
-			__set_bit(QED_MODE_L2GRE_TUNN, &new_tunn_mode);
-	} else {
-		if (test_bit(QED_MODE_L2GRE_TUNN, &cached_tunn_mode))
-			__set_bit(QED_MODE_L2GRE_TUNN, &new_tunn_mode);
-	}
-
-	if (test_bit(QED_MODE_IPGRE_TUNN, &update_mask)) {
-		if (test_bit(QED_MODE_IPGRE_TUNN, &tunn_mode))
-			__set_bit(QED_MODE_IPGRE_TUNN, &new_tunn_mode);
-	} else {
-		if (test_bit(QED_MODE_IPGRE_TUNN, &cached_tunn_mode))
-			__set_bit(QED_MODE_IPGRE_TUNN, &new_tunn_mode);
-	}
+	if (p_src->vxlan.b_update_mode || b_pf_start)
+		p_tun->vxlan.b_mode_enabled = p_src->vxlan.b_mode_enabled;
 
-	if (test_bit(QED_MODE_VXLAN_TUNN, &update_mask)) {
-		if (test_bit(QED_MODE_VXLAN_TUNN, &tunn_mode))
-			__set_bit(QED_MODE_VXLAN_TUNN, &new_tunn_mode);
-	} else {
-		if (test_bit(QED_MODE_VXLAN_TUNN, &cached_tunn_mode))
-			__set_bit(QED_MODE_VXLAN_TUNN, &new_tunn_mode);
-	}
-
-	if (p_src->update_geneve_udp_port) {
-		p_tunn_cfg->set_geneve_udp_port_flg = 1;
-		p_tunn_cfg->geneve_udp_port =
-				cpu_to_le16(p_src->geneve_udp_port);
-	}
+	if (p_src->l2_gre.b_update_mode || b_pf_start)
+		p_tun->l2_gre.b_mode_enabled = p_src->l2_gre.b_mode_enabled;
 
-	if (test_bit(QED_MODE_L2GENEVE_TUNN, &update_mask)) {
-		if (test_bit(QED_MODE_L2GENEVE_TUNN, &tunn_mode))
-			__set_bit(QED_MODE_L2GENEVE_TUNN, &new_tunn_mode);
-	} else {
-		if (test_bit(QED_MODE_L2GENEVE_TUNN, &cached_tunn_mode))
-			__set_bit(QED_MODE_L2GENEVE_TUNN, &new_tunn_mode);
-	}
+	if (p_src->ip_gre.b_update_mode || b_pf_start)
+		p_tun->ip_gre.b_mode_enabled = p_src->ip_gre.b_mode_enabled;
 
-	if (test_bit(QED_MODE_IPGENEVE_TUNN, &update_mask)) {
-		if (test_bit(QED_MODE_IPGENEVE_TUNN, &tunn_mode))
-			__set_bit(QED_MODE_IPGENEVE_TUNN, &new_tunn_mode);
-	} else {
-		if (test_bit(QED_MODE_IPGENEVE_TUNN, &cached_tunn_mode))
-			__set_bit(QED_MODE_IPGENEVE_TUNN, &new_tunn_mode);
-	}
+	if (p_src->l2_geneve.b_update_mode || b_pf_start)
+		p_tun->l2_geneve.b_mode_enabled =
+		    p_src->l2_geneve.b_mode_enabled;
 
-	p_src->tunn_mode = new_tunn_mode;
+	if (p_src->ip_geneve.b_update_mode || b_pf_start)
+		p_tun->ip_geneve.b_mode_enabled =
+		    p_src->ip_geneve.b_mode_enabled;
 }
 
-static void
-qed_tunn_set_pf_update_params(struct qed_hwfn *p_hwfn,
-			      struct qed_tunn_update_params *p_src,
-			      struct pf_update_tunnel_config *p_tunn_cfg)
+static void qed_set_tunn_cls_info(struct qed_tunnel_info *p_tun,
+				  struct qed_tunnel_info *p_src)
 {
-	unsigned long tunn_mode = p_src->tunn_mode;
 	enum tunnel_clss type;
 
-	qed_tunn_set_pf_fix_tunn_mode(p_hwfn, p_src, p_tunn_cfg);
-	p_tunn_cfg->update_rx_pf_clss = p_src->update_rx_pf_clss;
-	p_tunn_cfg->update_tx_pf_clss = p_src->update_tx_pf_clss;
-
-	type = qed_tunn_get_clss_type(p_src->tunn_clss_vxlan);
-	p_tunn_cfg->tunnel_clss_vxlan  = type;
-
-	type = qed_tunn_get_clss_type(p_src->tunn_clss_l2gre);
-	p_tunn_cfg->tunnel_clss_l2gre = type;
+	p_tun->b_update_rx_cls = p_src->b_update_rx_cls;
+	p_tun->b_update_tx_cls = p_src->b_update_tx_cls;
+
+	type = qed_tunn_clss_to_fw_clss(p_src->vxlan.tun_cls);
+	p_tun->vxlan.tun_cls = type;
+	type = qed_tunn_clss_to_fw_clss(p_src->l2_gre.tun_cls);
+	p_tun->l2_gre.tun_cls = type;
+	type = qed_tunn_clss_to_fw_clss(p_src->ip_gre.tun_cls);
+	p_tun->ip_gre.tun_cls = type;
+	type = qed_tunn_clss_to_fw_clss(p_src->l2_geneve.tun_cls);
+	p_tun->l2_geneve.tun_cls = type;
+	type = qed_tunn_clss_to_fw_clss(p_src->ip_geneve.tun_cls);
+	p_tun->ip_geneve.tun_cls = type;
+}
 
-	type = qed_tunn_get_clss_type(p_src->tunn_clss_ipgre);
-	p_tunn_cfg->tunnel_clss_ipgre = type;
+static void qed_set_tunn_ports(struct qed_tunnel_info *p_tun,
+			       struct qed_tunnel_info *p_src)
+{
+	p_tun->geneve_port.b_update_port = p_src->geneve_port.b_update_port;
+	p_tun->vxlan_port.b_update_port = p_src->vxlan_port.b_update_port;
 
-	if (p_src->update_vxlan_udp_port) {
-		p_tunn_cfg->set_vxlan_udp_port_flg = 1;
-		p_tunn_cfg->vxlan_udp_port = cpu_to_le16(p_src->vxlan_udp_port);
-	}
+	if (p_src->geneve_port.b_update_port)
+		p_tun->geneve_port.port = p_src->geneve_port.port;
 
-	if (test_bit(QED_MODE_L2GRE_TUNN, &tunn_mode))
-		p_tunn_cfg->tx_enable_l2gre = 1;
+	if (p_src->vxlan_port.b_update_port)
+		p_tun->vxlan_port.port = p_src->vxlan_port.port;
+}
 
-	if (test_bit(QED_MODE_IPGRE_TUNN, &tunn_mode))
-		p_tunn_cfg->tx_enable_ipgre = 1;
+static void
+__qed_set_ramrod_tunnel_param(u8 *p_tunn_cls, u8 *p_enable_tx_clas,
+			      struct qed_tunn_update_type *tun_type)
+{
+	*p_tunn_cls = tun_type->tun_cls;
 
-	if (test_bit(QED_MODE_VXLAN_TUNN, &tunn_mode))
-		p_tunn_cfg->tx_enable_vxlan = 1;
+	if (tun_type->b_mode_enabled)
+		*p_enable_tx_clas = 1;
+}
 
-	if (p_src->update_geneve_udp_port) {
-		p_tunn_cfg->set_geneve_udp_port_flg = 1;
-		p_tunn_cfg->geneve_udp_port =
-				cpu_to_le16(p_src->geneve_udp_port);
+static void
+qed_set_ramrod_tunnel_param(u8 *p_tunn_cls, u8 *p_enable_tx_clas,
+			    struct qed_tunn_update_type *tun_type,
+			    u8 *p_update_port, __le16 *p_port,
+			    struct qed_tunn_update_udp_port *p_udp_port)
+{
+	__qed_set_ramrod_tunnel_param(p_tunn_cls, p_enable_tx_clas, tun_type);
+	if (p_udp_port->b_update_port) {
+		*p_update_port = 1;
+		*p_port = cpu_to_le16(p_udp_port->port);
 	}
+}
 
-	if (test_bit(QED_MODE_L2GENEVE_TUNN, &tunn_mode))
-		p_tunn_cfg->tx_enable_l2geneve = 1;
-
-	if (test_bit(QED_MODE_IPGENEVE_TUNN, &tunn_mode))
-		p_tunn_cfg->tx_enable_ipgeneve = 1;
-
-	type = qed_tunn_get_clss_type(p_src->tunn_clss_l2geneve);
-	p_tunn_cfg->tunnel_clss_l2geneve = type;
-
-	type = qed_tunn_get_clss_type(p_src->tunn_clss_ipgeneve);
-	p_tunn_cfg->tunnel_clss_ipgeneve = type;
+static void
+qed_tunn_set_pf_update_params(struct qed_hwfn *p_hwfn,
+			      struct qed_tunnel_info *p_src,
+			      struct pf_update_tunnel_config *p_tunn_cfg)
+{
+	struct qed_tunnel_info *p_tun = &p_hwfn->cdev->tunnel;
+
+	qed_set_pf_update_tunn_mode(p_tun, p_src, false);
+	qed_set_tunn_cls_info(p_tun, p_src);
+	qed_set_tunn_ports(p_tun, p_src);
+
+	qed_set_ramrod_tunnel_param(&p_tunn_cfg->tunnel_clss_vxlan,
+				    &p_tunn_cfg->tx_enable_vxlan,
+				    &p_tun->vxlan,
+				    &p_tunn_cfg->set_vxlan_udp_port_flg,
+				    &p_tunn_cfg->vxlan_udp_port,
+				    &p_tun->vxlan_port);
+
+	qed_set_ramrod_tunnel_param(&p_tunn_cfg->tunnel_clss_l2geneve,
+				    &p_tunn_cfg->tx_enable_l2geneve,
+				    &p_tun->l2_geneve,
+				    &p_tunn_cfg->set_geneve_udp_port_flg,
+				    &p_tunn_cfg->geneve_udp_port,
+				    &p_tun->geneve_port);
+
+	__qed_set_ramrod_tunnel_param(&p_tunn_cfg->tunnel_clss_ipgeneve,
+				      &p_tunn_cfg->tx_enable_ipgeneve,
+				      &p_tun->ip_geneve);
+
+	__qed_set_ramrod_tunnel_param(&p_tunn_cfg->tunnel_clss_l2gre,
+				      &p_tunn_cfg->tx_enable_l2gre,
+				      &p_tun->l2_gre);
+
+	__qed_set_ramrod_tunnel_param(&p_tunn_cfg->tunnel_clss_ipgre,
+				      &p_tunn_cfg->tx_enable_ipgre,
+				      &p_tun->ip_gre);
+
+	p_tunn_cfg->update_rx_pf_clss = p_tun->b_update_rx_cls;
+	p_tunn_cfg->update_tx_pf_clss = p_tun->b_update_tx_cls;
 }
 
 static void qed_set_hw_tunn_mode(struct qed_hwfn *p_hwfn,
 				 struct qed_ptt *p_ptt,
-				 unsigned long tunn_mode)
+				 struct qed_tunnel_info *p_tun)
 {
-	u8 l2gre_enable = 0, ipgre_enable = 0, vxlan_enable = 0;
-	u8 l2geneve_enable = 0, ipgeneve_enable = 0;
-
-	if (test_bit(QED_MODE_L2GRE_TUNN, &tunn_mode))
-		l2gre_enable = 1;
-
-	if (test_bit(QED_MODE_IPGRE_TUNN, &tunn_mode))
-		ipgre_enable = 1;
-
-	if (test_bit(QED_MODE_VXLAN_TUNN, &tunn_mode))
-		vxlan_enable = 1;
+	qed_set_gre_enable(p_hwfn, p_ptt, p_tun->l2_gre.b_mode_enabled,
+			   p_tun->ip_gre.b_mode_enabled);
+	qed_set_vxlan_enable(p_hwfn, p_ptt, p_tun->vxlan.b_mode_enabled);
 
-	qed_set_gre_enable(p_hwfn, p_ptt, l2gre_enable, ipgre_enable);
-	qed_set_vxlan_enable(p_hwfn, p_ptt, vxlan_enable);
+	qed_set_geneve_enable(p_hwfn, p_ptt, p_tun->l2_geneve.b_mode_enabled,
+			      p_tun->ip_geneve.b_mode_enabled);
+}
 
-	if (test_bit(QED_MODE_L2GENEVE_TUNN, &tunn_mode))
-		l2geneve_enable = 1;
+static void qed_set_hw_tunn_mode_port(struct qed_hwfn *p_hwfn,
+				      struct qed_tunnel_info *p_tunn)
+{
+	if (p_tunn->vxlan_port.b_update_port)
+		qed_set_vxlan_dest_port(p_hwfn, p_hwfn->p_main_ptt,
+					p_tunn->vxlan_port.port);
 
-	if (test_bit(QED_MODE_IPGENEVE_TUNN, &tunn_mode))
-		ipgeneve_enable = 1;
+	if (p_tunn->geneve_port.b_update_port)
+		qed_set_geneve_dest_port(p_hwfn, p_hwfn->p_main_ptt,
+					 p_tunn->geneve_port.port);
 
-	qed_set_geneve_enable(p_hwfn, p_ptt, l2geneve_enable,
-			      ipgeneve_enable);
+	qed_set_hw_tunn_mode(p_hwfn, p_hwfn->p_main_ptt, p_tunn);
 }
 
 static void
 qed_tunn_set_pf_start_params(struct qed_hwfn *p_hwfn,
-			     struct qed_tunn_start_params *p_src,
+			     struct qed_tunnel_info *p_src,
 			     struct pf_start_tunnel_config *p_tunn_cfg)
 {
-	unsigned long tunn_mode;
-	enum tunnel_clss type;
+	struct qed_tunnel_info *p_tun = &p_hwfn->cdev->tunnel;
 
 	if (!p_src)
 		return;
 
-	tunn_mode = p_src->tunn_mode;
-	type = qed_tunn_get_clss_type(p_src->tunn_clss_vxlan);
-	p_tunn_cfg->tunnel_clss_vxlan = type;
-	type = qed_tunn_get_clss_type(p_src->tunn_clss_l2gre);
-	p_tunn_cfg->tunnel_clss_l2gre = type;
-	type = qed_tunn_get_clss_type(p_src->tunn_clss_ipgre);
-	p_tunn_cfg->tunnel_clss_ipgre = type;
-
-	if (p_src->update_vxlan_udp_port) {
-		p_tunn_cfg->set_vxlan_udp_port_flg = 1;
-		p_tunn_cfg->vxlan_udp_port = cpu_to_le16(p_src->vxlan_udp_port);
-	}
-
-	if (test_bit(QED_MODE_L2GRE_TUNN, &tunn_mode))
-		p_tunn_cfg->tx_enable_l2gre = 1;
-
-	if (test_bit(QED_MODE_IPGRE_TUNN, &tunn_mode))
-		p_tunn_cfg->tx_enable_ipgre = 1;
-
-	if (test_bit(QED_MODE_VXLAN_TUNN, &tunn_mode))
-		p_tunn_cfg->tx_enable_vxlan = 1;
-
-	if (p_src->update_geneve_udp_port) {
-		p_tunn_cfg->set_geneve_udp_port_flg = 1;
-		p_tunn_cfg->geneve_udp_port =
-				cpu_to_le16(p_src->geneve_udp_port);
-	}
-
-	if (test_bit(QED_MODE_L2GENEVE_TUNN, &tunn_mode))
-		p_tunn_cfg->tx_enable_l2geneve = 1;
-
-	if (test_bit(QED_MODE_IPGENEVE_TUNN, &tunn_mode))
-		p_tunn_cfg->tx_enable_ipgeneve = 1;
-
-	type = qed_tunn_get_clss_type(p_src->tunn_clss_l2geneve);
-	p_tunn_cfg->tunnel_clss_l2geneve = type;
-	type = qed_tunn_get_clss_type(p_src->tunn_clss_ipgeneve);
-	p_tunn_cfg->tunnel_clss_ipgeneve = type;
+	qed_set_pf_update_tunn_mode(p_tun, p_src, true);
+	qed_set_tunn_cls_info(p_tun, p_src);
+	qed_set_tunn_ports(p_tun, p_src);
+
+	qed_set_ramrod_tunnel_param(&p_tunn_cfg->tunnel_clss_vxlan,
+				    &p_tunn_cfg->tx_enable_vxlan,
+				    &p_tun->vxlan,
+				    &p_tunn_cfg->set_vxlan_udp_port_flg,
+				    &p_tunn_cfg->vxlan_udp_port,
+				    &p_tun->vxlan_port);
+
+	qed_set_ramrod_tunnel_param(&p_tunn_cfg->tunnel_clss_l2geneve,
+				    &p_tunn_cfg->tx_enable_l2geneve,
+				    &p_tun->l2_geneve,
+				    &p_tunn_cfg->set_geneve_udp_port_flg,
+				    &p_tunn_cfg->geneve_udp_port,
+				    &p_tun->geneve_port);
+
+	__qed_set_ramrod_tunnel_param(&p_tunn_cfg->tunnel_clss_ipgeneve,
+				      &p_tunn_cfg->tx_enable_ipgeneve,
+				      &p_tun->ip_geneve);
+
+	__qed_set_ramrod_tunnel_param(&p_tunn_cfg->tunnel_clss_l2gre,
+				      &p_tunn_cfg->tx_enable_l2gre,
+				      &p_tun->l2_gre);
+
+	__qed_set_ramrod_tunnel_param(&p_tunn_cfg->tunnel_clss_ipgre,
+				      &p_tunn_cfg->tx_enable_ipgre,
+				      &p_tun->ip_gre);
 }
 
 int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
-		    struct qed_tunn_start_params *p_tunn,
+		    struct qed_tunnel_info *p_tunn,
 		    enum qed_mf_mode mode, bool allow_npar_tx_switch)
 {
 	struct pf_start_ramrod_data *p_ramrod = NULL;
@@ -416,11 +411,8 @@ int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 
 	rc = qed_spq_post(p_hwfn, p_ent, NULL);
 
-	if (p_tunn) {
-		qed_set_hw_tunn_mode(p_hwfn, p_hwfn->p_main_ptt,
-				     p_tunn->tunn_mode);
-		p_hwfn->cdev->tunn_mode = p_tunn->tunn_mode;
-	}
+	if (p_tunn)
+		qed_set_hw_tunn_mode_port(p_hwfn, &p_hwfn->cdev->tunnel);
 
 	return rc;
 }
@@ -451,7 +443,7 @@ int qed_sp_pf_update(struct qed_hwfn *p_hwfn)
 
 /* Set pf update ramrod command params */
 int qed_sp_pf_update_tunn_cfg(struct qed_hwfn *p_hwfn,
-			      struct qed_tunn_update_params *p_tunn,
+			      struct qed_tunnel_info *p_tunn,
 			      enum spq_mode comp_mode,
 			      struct qed_spq_comp_cb *p_comp_data)
 {
@@ -459,6 +451,9 @@ int qed_sp_pf_update_tunn_cfg(struct qed_hwfn *p_hwfn,
 	struct qed_sp_init_data init_data;
 	int rc = -EINVAL;
 
+	if (!p_tunn)
+		return -EINVAL;
+
 	/* Get SPQ entry */
 	memset(&init_data, 0, sizeof(init_data));
 	init_data.cid = qed_spq_get_cid(p_hwfn);
@@ -479,15 +474,7 @@ int qed_sp_pf_update_tunn_cfg(struct qed_hwfn *p_hwfn,
 	if (rc)
 		return rc;
 
-	if (p_tunn->update_vxlan_udp_port)
-		qed_set_vxlan_dest_port(p_hwfn, p_hwfn->p_main_ptt,
-					p_tunn->vxlan_udp_port);
-	if (p_tunn->update_geneve_udp_port)
-		qed_set_geneve_dest_port(p_hwfn, p_hwfn->p_main_ptt,
-					 p_tunn->geneve_udp_port);
-
-	qed_set_hw_tunn_mode(p_hwfn, p_hwfn->p_main_ptt, p_tunn->tunn_mode);
-	p_hwfn->cdev->tunn_mode = p_tunn->tunn_mode;
+	qed_set_hw_tunn_mode_port(p_hwfn, &p_hwfn->cdev->tunnel);
 
 	return rc;
 }
-- 
2.7.2
