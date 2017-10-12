From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next 8/8] cxgb4: collect IBQ and OBQ dumps
Date: Thu, 12 Oct 2017 13:54:45 +0530
Message-ID: <86be7ff73523672346cd19f7dd24e4e1472cb91b.1507795407.git.rahul.lakkireddy@chelsio.com>
References: <cover.1507795407.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, ganeshgr@chelsio.com, nirranjan@chelsio.com,
        indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:16382 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755044AbdJLI0U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 04:26:20 -0400
In-Reply-To: <cover.1507795407.git.rahul.lakkireddy@chelsio.com>
In-Reply-To: <cover.1507795407.git.rahul.lakkireddy@chelsio.com>
References: <cover.1507795407.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cudbg_if.h    |  14 ++
 drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c   | 165 +++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h   |  42 ++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c |  32 +++++
 4 files changed, 253 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cudbg_if.h b/drivers/net/ethernet/chelsio/cxgb4/cudbg_if.h
index 5c5f5339d917..ccdf5a54fec5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cudbg_if.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cudbg_if.h
@@ -29,10 +29,24 @@
 enum cudbg_dbg_entity_type {
 	CUDBG_REG_DUMP = 1,
 	CUDBG_DEV_LOG = 2,
+	CUDBG_CIM_IBQ_TP0 = 6,
+	CUDBG_CIM_IBQ_TP1 = 7,
+	CUDBG_CIM_IBQ_ULP = 8,
+	CUDBG_CIM_IBQ_SGE0 = 9,
+	CUDBG_CIM_IBQ_SGE1 = 10,
+	CUDBG_CIM_IBQ_NCSI = 11,
+	CUDBG_CIM_OBQ_ULP0 = 12,
+	CUDBG_CIM_OBQ_ULP1 = 13,
+	CUDBG_CIM_OBQ_ULP2 = 14,
+	CUDBG_CIM_OBQ_ULP3 = 15,
+	CUDBG_CIM_OBQ_SGE = 16,
+	CUDBG_CIM_OBQ_NCSI = 17,
 	CUDBG_EDC0 = 18,
 	CUDBG_EDC1 = 19,
 	CUDBG_TP_INDIRECT = 36,
 	CUDBG_SGE_INDIRECT = 37,
+	CUDBG_CIM_OBQ_RXQ0 = 47,
+	CUDBG_CIM_OBQ_RXQ1 = 48,
 	CUDBG_PCIE_INDIRECT = 50,
 	CUDBG_PM_INDIRECT = 51,
 	CUDBG_MA_INDIRECT = 61,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c b/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c
index 536d4eecbdd7..cc412b4439ab 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c
@@ -129,6 +129,171 @@ int collect_fw_devlog(struct cudbg_init *pdbg_init,
 	return rc;
 }
 
+static int read_cim_ibq(struct cudbg_init *pdbg_init,
+			struct cudbg_buffer *dbg_buff,
+			struct cudbg_error *cudbg_err, int qid)
+{
+	struct adapter *padap = pdbg_init->adap;
+	struct cudbg_buffer temp_buff = { 0 };
+	int no_of_read_words, rc = 0;
+	u32 qsize;
+
+	/* collect CIM IBQ */
+	qsize = CIM_IBQ_SIZE * 4 * sizeof(u32);
+	rc = get_cudbg_buff(dbg_buff, qsize, &temp_buff);
+	if (rc)
+		return rc;
+
+	/* t4_read_cim_ibq will return no. of read words or error */
+	no_of_read_words = t4_read_cim_ibq(padap, qid,
+					   (u32 *)((u32 *)temp_buff.data +
+					   temp_buff.offset), qsize);
+	/* no_of_read_words is less than or equal to 0 means error */
+	if (no_of_read_words <= 0) {
+		if (!no_of_read_words)
+			rc = CUDBG_SYSTEM_ERROR;
+		else
+			rc = no_of_read_words;
+		cudbg_err->sys_err = rc;
+		put_cudbg_buff(&temp_buff, dbg_buff);
+		return rc;
+	}
+	write_and_release_buff(&temp_buff, dbg_buff);
+	return rc;
+}
+
+int collect_cim_ibq_tp0(struct cudbg_init *pdbg_init,
+			struct cudbg_buffer *dbg_buff,
+			struct cudbg_error *cudbg_err)
+{
+	return read_cim_ibq(pdbg_init, dbg_buff, cudbg_err, 0);
+}
+
+int collect_cim_ibq_tp1(struct cudbg_init *pdbg_init,
+			struct cudbg_buffer *dbg_buff,
+			struct cudbg_error *cudbg_err)
+{
+	return read_cim_ibq(pdbg_init, dbg_buff, cudbg_err, 1);
+}
+
+int collect_cim_ibq_ulp(struct cudbg_init *pdbg_init,
+			struct cudbg_buffer *dbg_buff,
+			struct cudbg_error *cudbg_err)
+{
+	return read_cim_ibq(pdbg_init, dbg_buff, cudbg_err, 2);
+}
+
+int collect_cim_ibq_sge0(struct cudbg_init *pdbg_init,
+			 struct cudbg_buffer *dbg_buff,
+			 struct cudbg_error *cudbg_err)
+{
+	return read_cim_ibq(pdbg_init, dbg_buff, cudbg_err, 3);
+}
+
+int collect_cim_ibq_sge1(struct cudbg_init *pdbg_init,
+			 struct cudbg_buffer *dbg_buff,
+			 struct cudbg_error *cudbg_err)
+{
+	return read_cim_ibq(pdbg_init, dbg_buff, cudbg_err, 4);
+}
+
+int collect_cim_ibq_ncsi(struct cudbg_init *pdbg_init,
+			 struct cudbg_buffer *dbg_buff,
+			 struct cudbg_error *cudbg_err)
+{
+	return read_cim_ibq(pdbg_init, dbg_buff, cudbg_err, 5);
+}
+
+static int read_cim_obq(struct cudbg_init *pdbg_init,
+			struct cudbg_buffer *dbg_buff,
+			struct cudbg_error *cudbg_err, int qid)
+{
+	struct adapter *padap = pdbg_init->adap;
+	struct cudbg_buffer temp_buff = { 0 };
+	int no_of_read_words, rc = 0;
+	u32 qsize;
+
+	/* collect CIM OBQ */
+	qsize =  6 * CIM_OBQ_SIZE * 4 *  sizeof(u32);
+	rc = get_cudbg_buff(dbg_buff, qsize, &temp_buff);
+	if (rc)
+		return rc;
+
+	/* t4_read_cim_obq will return no. of read words or error */
+	no_of_read_words = t4_read_cim_obq(padap, qid,
+					   (u32 *)((u32 *)temp_buff.data +
+					   temp_buff.offset), qsize);
+	/* no_of_read_words is less than or equal to 0 means error */
+	if (no_of_read_words <= 0) {
+		if (!no_of_read_words)
+			rc = CUDBG_SYSTEM_ERROR;
+		else
+			rc = no_of_read_words;
+		cudbg_err->sys_err = rc;
+		put_cudbg_buff(&temp_buff, dbg_buff);
+		return rc;
+	}
+	temp_buff.size = no_of_read_words * 4;
+	write_and_release_buff(&temp_buff, dbg_buff);
+	return rc;
+}
+
+int collect_cim_obq_ulp0(struct cudbg_init *pdbg_init,
+			 struct cudbg_buffer *dbg_buff,
+			 struct cudbg_error *cudbg_err)
+{
+	return read_cim_obq(pdbg_init, dbg_buff, cudbg_err, 0);
+}
+
+int collect_cim_obq_ulp1(struct cudbg_init *pdbg_init,
+			 struct cudbg_buffer *dbg_buff,
+			 struct cudbg_error *cudbg_err)
+{
+	return read_cim_obq(pdbg_init, dbg_buff, cudbg_err, 1);
+}
+
+int collect_cim_obq_ulp2(struct cudbg_init *pdbg_init,
+			 struct cudbg_buffer *dbg_buff,
+			 struct cudbg_error *cudbg_err)
+{
+	return read_cim_obq(pdbg_init, dbg_buff, cudbg_err, 2);
+}
+
+int collect_cim_obq_ulp3(struct cudbg_init *pdbg_init,
+			 struct cudbg_buffer *dbg_buff,
+			 struct cudbg_error *cudbg_err)
+{
+	return read_cim_obq(pdbg_init, dbg_buff, cudbg_err, 3);
+}
+
+int collect_cim_obq_sge(struct cudbg_init *pdbg_init,
+			struct cudbg_buffer *dbg_buff,
+			struct cudbg_error *cudbg_err)
+{
+	return read_cim_obq(pdbg_init, dbg_buff, cudbg_err, 4);
+}
+
+int collect_cim_obq_ncsi(struct cudbg_init *pdbg_init,
+			 struct cudbg_buffer *dbg_buff,
+			 struct cudbg_error *cudbg_err)
+{
+	return read_cim_obq(pdbg_init, dbg_buff, cudbg_err, 5);
+}
+
+int collect_obq_sge_rx_q0(struct cudbg_init *pdbg_init,
+			  struct cudbg_buffer *dbg_buff,
+			  struct cudbg_error *cudbg_err)
+{
+	return read_cim_obq(pdbg_init, dbg_buff, cudbg_err, 6);
+}
+
+int collect_obq_sge_rx_q1(struct cudbg_init *pdbg_init,
+			  struct cudbg_buffer *dbg_buff,
+			  struct cudbg_error *cudbg_err)
+{
+	return read_cim_obq(pdbg_init, dbg_buff, cudbg_err, 7);
+}
+
 static int read_fw_mem(struct cudbg_init *pdbg_init,
 		       struct cudbg_buffer *dbg_buff, u8 mem_type,
 		       unsigned long tot_len, struct cudbg_error *cudbg_err)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h b/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h
index d9260bdaf9dc..508e81c78bce 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h
@@ -24,6 +24,42 @@ int collect_reg_dump(struct cudbg_init *pdbg_init,
 int collect_fw_devlog(struct cudbg_init *pdbg_init,
 		      struct cudbg_buffer *dbg_buff,
 		      struct cudbg_error *cudbg_err);
+int collect_cim_ibq_tp0(struct cudbg_init *pdbg_init,
+			struct cudbg_buffer *dbg_buff,
+			struct cudbg_error *cudbg_err);
+int collect_cim_ibq_tp1(struct cudbg_init *pdbg_init,
+			struct cudbg_buffer *dbg_buff,
+			struct cudbg_error *cudbg_err);
+int collect_cim_ibq_ulp(struct cudbg_init *pdbg_init,
+			struct cudbg_buffer *dbg_buff,
+			struct cudbg_error *cudbg_err);
+int collect_cim_ibq_sge0(struct cudbg_init *pdbg_init,
+			 struct cudbg_buffer *dbg_buff,
+			 struct cudbg_error *cudbg_err);
+int collect_cim_ibq_sge1(struct cudbg_init *pdbg_init,
+			 struct cudbg_buffer *dbg_buff,
+			 struct cudbg_error *cudbg_err);
+int collect_cim_ibq_ncsi(struct cudbg_init *pdbg_init,
+			 struct cudbg_buffer *dbg_buff,
+			 struct cudbg_error *cudbg_err);
+int collect_cim_obq_ulp0(struct cudbg_init *pdbg_init,
+			 struct cudbg_buffer *dbg_buff,
+			 struct cudbg_error *cudbg_err);
+int collect_cim_obq_ulp1(struct cudbg_init *pdbg_init,
+			 struct cudbg_buffer *dbg_buff,
+			 struct cudbg_error *cudbg_err);
+int collect_cim_obq_ulp2(struct cudbg_init *pdbg_init,
+			 struct cudbg_buffer *dbg_buff,
+			 struct cudbg_error *cudbg_err);
+int collect_cim_obq_ulp3(struct cudbg_init *pdbg_init,
+			 struct cudbg_buffer *dbg_buff,
+			 struct cudbg_error *cudbg_err);
+int collect_cim_obq_sge(struct cudbg_init *pdbg_init,
+			struct cudbg_buffer *dbg_buff,
+			struct cudbg_error *cudbg_err);
+int collect_cim_obq_ncsi(struct cudbg_init *pdbg_init,
+			 struct cudbg_buffer *dbg_buff,
+			 struct cudbg_error *cudbg_err);
 int collect_edc0_meminfo(struct cudbg_init *pdbg_init,
 			 struct cudbg_buffer *dbg_buff,
 			 struct cudbg_error *cudbg_err);
@@ -36,6 +72,12 @@ int collect_tp_indirect(struct cudbg_init *pdbg_init,
 int collect_sge_indirect(struct cudbg_init *pdbg_init,
 			 struct cudbg_buffer *dbg_buff,
 			 struct cudbg_error *cudbg_err);
+int collect_obq_sge_rx_q0(struct cudbg_init *pdbg_init,
+			  struct cudbg_buffer *dbg_buff,
+			  struct cudbg_error *cudbg_err);
+int collect_obq_sge_rx_q1(struct cudbg_init *pdbg_init,
+			  struct cudbg_buffer *dbg_buff,
+			  struct cudbg_error *cudbg_err);
 int collect_pcie_indirect(struct cudbg_init *pdbg_init,
 			  struct cudbg_buffer *dbg_buff,
 			  struct cudbg_error *cudbg_err);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c
index 5b24799da469..c4d02eebab51 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c
@@ -29,8 +29,22 @@ static const struct cudbg_collect_entity collect_hw_dump[] = {
 	{ CUDBG_MBOX_LOG, collect_mbox_log },
 	{ CUDBG_DEV_LOG, collect_fw_devlog },
 	{ CUDBG_REG_DUMP, collect_reg_dump },
+	{ CUDBG_CIM_IBQ_TP0, collect_cim_ibq_tp0 },
+	{ CUDBG_CIM_IBQ_TP1, collect_cim_ibq_tp1 },
+	{ CUDBG_CIM_IBQ_ULP, collect_cim_ibq_ulp },
+	{ CUDBG_CIM_IBQ_SGE0, collect_cim_ibq_sge0 },
+	{ CUDBG_CIM_IBQ_SGE1, collect_cim_ibq_sge1 },
+	{ CUDBG_CIM_IBQ_NCSI, collect_cim_ibq_ncsi },
+	{ CUDBG_CIM_OBQ_ULP0, collect_cim_obq_ulp0 },
+	{ CUDBG_CIM_OBQ_ULP1, collect_cim_obq_ulp1 },
+	{ CUDBG_CIM_OBQ_ULP2, collect_cim_obq_ulp2 },
+	{ CUDBG_CIM_OBQ_ULP3, collect_cim_obq_ulp3 },
+	{ CUDBG_CIM_OBQ_SGE, collect_cim_obq_sge },
+	{ CUDBG_CIM_OBQ_NCSI, collect_cim_obq_ncsi },
 	{ CUDBG_TP_INDIRECT, collect_tp_indirect },
 	{ CUDBG_SGE_INDIRECT, collect_sge_indirect },
+	{ CUDBG_CIM_OBQ_RXQ0, collect_obq_sge_rx_q0 },
+	{ CUDBG_CIM_OBQ_RXQ1, collect_obq_sge_rx_q1 },
 	{ CUDBG_PCIE_INDIRECT, collect_pcie_indirect },
 	{ CUDBG_PM_INDIRECT, collect_pm_indirect },
 	{ CUDBG_MA_INDIRECT, collect_ma_indirect },
@@ -59,6 +73,24 @@ static u32 cxgb4_get_entity_length(struct adapter *adap, u32 entity)
 	case CUDBG_DEV_LOG:
 		len = adap->params.devlog.size;
 		break;
+	case CUDBG_CIM_IBQ_TP0:
+	case CUDBG_CIM_IBQ_TP1:
+	case CUDBG_CIM_IBQ_ULP:
+	case CUDBG_CIM_IBQ_SGE0:
+	case CUDBG_CIM_IBQ_SGE1:
+	case CUDBG_CIM_IBQ_NCSI:
+		len = CIM_IBQ_SIZE * 4 * sizeof(u32);
+		break;
+	case CUDBG_CIM_OBQ_ULP0:
+	case CUDBG_CIM_OBQ_ULP1:
+	case CUDBG_CIM_OBQ_ULP2:
+	case CUDBG_CIM_OBQ_ULP3:
+	case CUDBG_CIM_OBQ_SGE:
+	case CUDBG_CIM_OBQ_NCSI:
+	case CUDBG_CIM_OBQ_RXQ0:
+	case CUDBG_CIM_OBQ_RXQ1:
+		len = 6 * CIM_OBQ_SIZE * 4 * sizeof(u32);
+		break;
 	case CUDBG_EDC0:
 		value = t4_read_reg(adap, MA_TARGET_MEM_ENABLE_A);
 		if (value & EDRAM0_ENABLE_F) {
-- 
2.14.1
