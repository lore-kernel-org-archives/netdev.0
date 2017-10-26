From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next 3/8] cxgb4: collect RSS dumps
Date: Thu, 26 Oct 2017 17:18:35 +0530
Message-ID: <d99dc72eb9d44d7a3a11d29da30a474924f6f4d3.1509017929.git.rahul.lakkireddy@chelsio.com>
References: <cover.1509017929.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, ganeshgr@chelsio.com, nirranjan@chelsio.com,
        indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:36951 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752077AbdJZLuR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 07:50:17 -0400
In-Reply-To: <cover.1509017929.git.rahul.lakkireddy@chelsio.com>
In-Reply-To: <cover.1509017929.git.rahul.lakkireddy@chelsio.com>
References: <cover.1509017929.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Collect RSS table and RSS VF configuration dumps.

Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cudbg_entity.h |  5 +++
 drivers/net/ethernet/chelsio/cxgb4/cudbg_if.h     |  2 +
 drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c    | 46 +++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h    |  6 +++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c  |  9 +++++
 5 files changed, 68 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cudbg_entity.h b/drivers/net/ethernet/chelsio/cxgb4/cudbg_entity.h
index ab15c3dfa04e..b24175b2bb3c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cudbg_entity.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cudbg_entity.h
@@ -42,6 +42,11 @@ struct cudbg_cim_qcfg {
 	u32 stat[4 * (CIM_NUM_IBQ + CIM_NUM_OBQ_T5)];
 };
 
+struct cudbg_rss_vf_conf {
+	u32 rss_vf_vfl;
+	u32 rss_vf_vfh;
+};
+
 struct ireg_field {
 	u32 ireg_addr;
 	u32 ireg_data;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cudbg_if.h b/drivers/net/ethernet/chelsio/cxgb4/cudbg_if.h
index be031aba2706..34f241892fca 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cudbg_if.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cudbg_if.h
@@ -46,6 +46,8 @@ enum cudbg_dbg_entity_type {
 	CUDBG_CIM_OBQ_NCSI = 17,
 	CUDBG_EDC0 = 18,
 	CUDBG_EDC1 = 19,
+	CUDBG_RSS = 22,
+	CUDBG_RSS_VF_CONF = 25,
 	CUDBG_TP_INDIRECT = 36,
 	CUDBG_SGE_INDIRECT = 37,
 	CUDBG_ULPRX_LA = 41,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c b/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c
index 596f2b8e41cf..efab94465337 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c
@@ -528,6 +528,52 @@ int cudbg_collect_edc1_meminfo(struct cudbg_init *pdbg_init,
 					MEM_EDC1);
 }
 
+int cudbg_collect_rss(struct cudbg_init *pdbg_init,
+		      struct cudbg_buffer *dbg_buff,
+		      struct cudbg_error *cudbg_err)
+{
+	struct adapter *padap = pdbg_init->adap;
+	struct cudbg_buffer temp_buff = { 0 };
+	int rc;
+
+	rc = cudbg_get_buff(dbg_buff, RSS_NENTRIES * sizeof(u16), &temp_buff);
+	if (rc)
+		return rc;
+
+	rc = t4_read_rss(padap, (u16 *)temp_buff.data);
+	if (rc) {
+		cudbg_err->sys_err = rc;
+		cudbg_put_buff(&temp_buff, dbg_buff);
+		return rc;
+	}
+	cudbg_write_and_release_buff(&temp_buff, dbg_buff);
+	return rc;
+}
+
+int cudbg_collect_rss_vf_config(struct cudbg_init *pdbg_init,
+				struct cudbg_buffer *dbg_buff,
+				struct cudbg_error *cudbg_err)
+{
+	struct adapter *padap = pdbg_init->adap;
+	struct cudbg_buffer temp_buff = { 0 };
+	struct cudbg_rss_vf_conf *vfconf;
+	int vf, rc, vf_count;
+
+	vf_count = padap->params.arch.vfcount;
+	rc = cudbg_get_buff(dbg_buff,
+			    vf_count * sizeof(struct cudbg_rss_vf_conf),
+			    &temp_buff);
+	if (rc)
+		return rc;
+
+	vfconf = (struct cudbg_rss_vf_conf *)temp_buff.data;
+	for (vf = 0; vf < vf_count; vf++)
+		t4_read_rss_vf_config(padap, vf, &vfconf[vf].rss_vf_vfl,
+				      &vfconf[vf].rss_vf_vfh, true);
+	cudbg_write_and_release_buff(&temp_buff, dbg_buff);
+	return rc;
+}
+
 int cudbg_collect_tp_indirect(struct cudbg_init *pdbg_init,
 			      struct cudbg_buffer *dbg_buff,
 			      struct cudbg_error *cudbg_err)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h b/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h
index f42b7420ff09..634c643fdd39 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h
@@ -75,6 +75,12 @@ int cudbg_collect_edc0_meminfo(struct cudbg_init *pdbg_init,
 int cudbg_collect_edc1_meminfo(struct cudbg_init *pdbg_init,
 			       struct cudbg_buffer *dbg_buff,
 			       struct cudbg_error *cudbg_err);
+int cudbg_collect_rss(struct cudbg_init *pdbg_init,
+		      struct cudbg_buffer *dbg_buff,
+		      struct cudbg_error *cudbg_err);
+int cudbg_collect_rss_vf_config(struct cudbg_init *pdbg_init,
+				struct cudbg_buffer *dbg_buff,
+				struct cudbg_error *cudbg_err);
 int cudbg_collect_tp_indirect(struct cudbg_init *pdbg_init,
 			      struct cudbg_buffer *dbg_buff,
 			      struct cudbg_error *cudbg_err);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c
index 611ece7b7e5a..7996220db485 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c
@@ -44,6 +44,8 @@ static const struct cxgb4_collect_entity cxgb4_collect_hw_dump[] = {
 	{ CUDBG_CIM_OBQ_ULP3, cudbg_collect_cim_obq_ulp3 },
 	{ CUDBG_CIM_OBQ_SGE, cudbg_collect_cim_obq_sge },
 	{ CUDBG_CIM_OBQ_NCSI, cudbg_collect_cim_obq_ncsi },
+	{ CUDBG_RSS, cudbg_collect_rss },
+	{ CUDBG_RSS_VF_CONF, cudbg_collect_rss_vf_config },
 	{ CUDBG_TP_INDIRECT, cudbg_collect_tp_indirect },
 	{ CUDBG_SGE_INDIRECT, cudbg_collect_sge_indirect },
 	{ CUDBG_ULPRX_LA, cudbg_collect_ulprx_la },
@@ -144,6 +146,13 @@ static u32 cxgb4_get_entity_length(struct adapter *adap, u32 entity)
 		}
 		len = cudbg_mbytes_to_bytes(len);
 		break;
+	case CUDBG_RSS:
+		len = RSS_NENTRIES * sizeof(u16);
+		break;
+	case CUDBG_RSS_VF_CONF:
+		len = adap->params.arch.vfcount *
+		      sizeof(struct cudbg_rss_vf_conf);
+		break;
 	case CUDBG_TP_INDIRECT:
 		switch (CHELSIO_CHIP_VERSION(adap->params.chip)) {
 		case CHELSIO_T5:
-- 
2.14.1
