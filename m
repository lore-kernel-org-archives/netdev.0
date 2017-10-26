From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next 6/8] cxgb4: collect PBT tables dump
Date: Thu, 26 Oct 2017 17:18:38 +0530
Message-ID: <24b79b8eada75c9cbddd96b130cfaceb230ffa0b.1509017929.git.rahul.lakkireddy@chelsio.com>
References: <cover.1509017929.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, ganeshgr@chelsio.com, nirranjan@chelsio.com,
        indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:53470 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751553AbdJZLuZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 07:50:25 -0400
In-Reply-To: <cover.1509017929.git.rahul.lakkireddy@chelsio.com>
In-Reply-To: <cover.1509017929.git.rahul.lakkireddy@chelsio.com>
References: <cover.1509017929.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cudbg_entity.h | 15 +++++
 drivers/net/ethernet/chelsio/cxgb4/cudbg_if.h     |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c    | 68 +++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h    |  3 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c  |  4 ++
 5 files changed, 91 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cudbg_entity.h b/drivers/net/ethernet/chelsio/cxgb4/cudbg_entity.h
index 1860cf2b5286..22853372abdf 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cudbg_entity.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cudbg_entity.h
@@ -145,6 +145,21 @@ struct cudbg_ulptx_la {
 	u32 rd_data[CUDBG_NUM_ULPTX][CUDBG_NUM_ULPTX_READ];
 };
 
+#define CUDBG_CHAC_PBT_ADDR 0x2800
+#define CUDBG_CHAC_PBT_LRF  0x3000
+#define CUDBG_CHAC_PBT_DATA 0x3800
+#define CUDBG_PBT_DYNAMIC_ENTRIES 8
+#define CUDBG_PBT_STATIC_ENTRIES 16
+#define CUDBG_LRF_ENTRIES 8
+#define CUDBG_PBT_DATA_ENTRIES 512
+
+struct cudbg_pbt_tables {
+	u32 pbt_dynamic[CUDBG_PBT_DYNAMIC_ENTRIES];
+	u32 pbt_static[CUDBG_PBT_STATIC_ENTRIES];
+	u32 lrf_table[CUDBG_LRF_ENTRIES];
+	u32 pbt_data[CUDBG_PBT_DATA_ENTRIES];
+};
+
 #define IREG_NUM_ELEM 4
 
 static const u32 t6_tp_pio_array[][IREG_NUM_ELEM] = {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cudbg_if.h b/drivers/net/ethernet/chelsio/cxgb4/cudbg_if.h
index ce7bb909b8fd..f672799cc8d3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cudbg_if.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cudbg_if.h
@@ -62,6 +62,7 @@ enum cudbg_dbg_entity_type {
 	CUDBG_MA_INDIRECT = 61,
 	CUDBG_ULPTX_LA = 62,
 	CUDBG_UP_CIM_INDIRECT = 64,
+	CUDBG_PBT_TABLE = 65,
 	CUDBG_MBOX_LOG = 66,
 	CUDBG_HMA_INDIRECT = 67,
 	CUDBG_MAX_ENTITY = 70,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c b/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c
index 03f1ec0c0160..c4096967c434 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c
@@ -1310,6 +1310,74 @@ int cudbg_collect_up_cim_indirect(struct cudbg_init *pdbg_init,
 	return rc;
 }
 
+int cudbg_collect_pbt_tables(struct cudbg_init *pdbg_init,
+			     struct cudbg_buffer *dbg_buff,
+			     struct cudbg_error *cudbg_err)
+{
+	struct adapter *padap = pdbg_init->adap;
+	struct cudbg_buffer temp_buff = { 0 };
+	struct cudbg_pbt_tables *pbt;
+	int i, rc;
+	u32 addr;
+
+	rc = cudbg_get_buff(dbg_buff, sizeof(struct cudbg_pbt_tables),
+			    &temp_buff);
+	if (rc)
+		return rc;
+
+	pbt = (struct cudbg_pbt_tables *)temp_buff.data;
+	/* PBT dynamic entries */
+	addr = CUDBG_CHAC_PBT_ADDR;
+	for (i = 0; i < CUDBG_PBT_DYNAMIC_ENTRIES; i++) {
+		rc = t4_cim_read(padap, addr + (i * 4), 1,
+				 &pbt->pbt_dynamic[i]);
+		if (rc) {
+			cudbg_err->sys_err = rc;
+			cudbg_put_buff(&temp_buff, dbg_buff);
+			return rc;
+		}
+	}
+
+	/* PBT static entries */
+	/* static entries start when bit 6 is set */
+	addr = CUDBG_CHAC_PBT_ADDR + (1 << 6);
+	for (i = 0; i < CUDBG_PBT_STATIC_ENTRIES; i++) {
+		rc = t4_cim_read(padap, addr + (i * 4), 1,
+				 &pbt->pbt_static[i]);
+		if (rc) {
+			cudbg_err->sys_err = rc;
+			cudbg_put_buff(&temp_buff, dbg_buff);
+			return rc;
+		}
+	}
+
+	/* LRF entries */
+	addr = CUDBG_CHAC_PBT_LRF;
+	for (i = 0; i < CUDBG_LRF_ENTRIES; i++) {
+		rc = t4_cim_read(padap, addr + (i * 4), 1,
+				 &pbt->lrf_table[i]);
+		if (rc) {
+			cudbg_err->sys_err = rc;
+			cudbg_put_buff(&temp_buff, dbg_buff);
+			return rc;
+		}
+	}
+
+	/* PBT data entries */
+	addr = CUDBG_CHAC_PBT_DATA;
+	for (i = 0; i < CUDBG_PBT_DATA_ENTRIES; i++) {
+		rc = t4_cim_read(padap, addr + (i * 4), 1,
+				 &pbt->pbt_data[i]);
+		if (rc) {
+			cudbg_err->sys_err = rc;
+			cudbg_put_buff(&temp_buff, dbg_buff);
+			return rc;
+		}
+	}
+	cudbg_write_and_release_buff(&temp_buff, dbg_buff);
+	return rc;
+}
+
 int cudbg_collect_mbox_log(struct cudbg_init *pdbg_init,
 			   struct cudbg_buffer *dbg_buff,
 			   struct cudbg_error *cudbg_err)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h b/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h
index 280423f9869d..311b330bc3b2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h
@@ -123,6 +123,9 @@ int cudbg_collect_ulptx_la(struct cudbg_init *pdbg_init,
 int cudbg_collect_up_cim_indirect(struct cudbg_init *pdbg_init,
 				  struct cudbg_buffer *dbg_buff,
 				  struct cudbg_error *cudbg_err);
+int cudbg_collect_pbt_tables(struct cudbg_init *pdbg_init,
+			     struct cudbg_buffer *dbg_buff,
+			     struct cudbg_error *cudbg_err);
 int cudbg_collect_mbox_log(struct cudbg_init *pdbg_init,
 			   struct cudbg_buffer *dbg_buff,
 			   struct cudbg_error *cudbg_err);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c
index f1a1ece45b97..003deb345ff2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c
@@ -60,6 +60,7 @@ static const struct cxgb4_collect_entity cxgb4_collect_hw_dump[] = {
 	{ CUDBG_MA_INDIRECT, cudbg_collect_ma_indirect },
 	{ CUDBG_ULPTX_LA, cudbg_collect_ulptx_la },
 	{ CUDBG_UP_CIM_INDIRECT, cudbg_collect_up_cim_indirect },
+	{ CUDBG_PBT_TABLE, cudbg_collect_pbt_tables },
 	{ CUDBG_HMA_INDIRECT, cudbg_collect_hma_indirect },
 };
 
@@ -215,6 +216,9 @@ static u32 cxgb4_get_entity_length(struct adapter *adap, u32 entity)
 		n = sizeof(t5_up_cim_reg_array) / (IREG_NUM_ELEM * sizeof(u32));
 		len = sizeof(struct ireg_buf) * n;
 		break;
+	case CUDBG_PBT_TABLE:
+		len = sizeof(struct cudbg_pbt_tables);
+		break;
 	case CUDBG_MBOX_LOG:
 		len = sizeof(struct cudbg_mbox_log) * adap->mbox_log->size;
 		break;
-- 
2.14.1
