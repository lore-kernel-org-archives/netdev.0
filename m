From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next] cxgb4: fix overflow in collecting IBQ and OBQ dump
Date: Tue, 24 Oct 2017 19:28:26 +0530
Message-ID: <8b225c39b59b637a53c05d53d563d38fe989cbcd.1508853300.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, ganeshgr@chelsio.com, nirranjan@chelsio.com,
        indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:23161 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751486AbdJXN7t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 09:59:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Destination buffer already has offset added.  So, don't add offset
again.

Fetch actual size of configured OBQ from hardware, instead of using
hardcoded value.

Fixes: 7c075ce221cf ("cxgb4: collect IBQ and OBQ dumps")
Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c   | 20 ++++++++++++++------
 drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h   |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c | 16 +++++++++++++++-
 3 files changed, 30 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c b/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c
index c451b2e42a6c..19da54f83e52 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.c
@@ -146,8 +146,7 @@ static int cudbg_read_cim_ibq(struct cudbg_init *pdbg_init,
 
 	/* t4_read_cim_ibq will return no. of read words or error */
 	no_of_read_words = t4_read_cim_ibq(padap, qid,
-					   (u32 *)((u32 *)temp_buff.data +
-					   temp_buff.offset), qsize);
+					   (u32 *)temp_buff.data, qsize);
 	/* no_of_read_words is less than or equal to 0 means error */
 	if (no_of_read_words <= 0) {
 		if (!no_of_read_words)
@@ -204,6 +203,17 @@ int cudbg_collect_cim_ibq_ncsi(struct cudbg_init *pdbg_init,
 	return cudbg_read_cim_ibq(pdbg_init, dbg_buff, cudbg_err, 5);
 }
 
+u32 cudbg_cim_obq_size(struct adapter *padap, int qid)
+{
+	u32 value;
+
+	t4_write_reg(padap, CIM_QUEUE_CONFIG_REF_A, OBQSELECT_F |
+		     QUENUMSELECT_V(qid));
+	value = t4_read_reg(padap, CIM_QUEUE_CONFIG_CTRL_A);
+	value = CIMQSIZE_G(value) * 64; /* size in number of words */
+	return value * sizeof(u32);
+}
+
 static int cudbg_read_cim_obq(struct cudbg_init *pdbg_init,
 			      struct cudbg_buffer *dbg_buff,
 			      struct cudbg_error *cudbg_err, int qid)
@@ -214,15 +224,14 @@ static int cudbg_read_cim_obq(struct cudbg_init *pdbg_init,
 	u32 qsize;
 
 	/* collect CIM OBQ */
-	qsize =  6 * CIM_OBQ_SIZE * 4 *  sizeof(u32);
+	qsize =  cudbg_cim_obq_size(padap, qid);
 	rc = cudbg_get_buff(dbg_buff, qsize, &temp_buff);
 	if (rc)
 		return rc;
 
 	/* t4_read_cim_obq will return no. of read words or error */
 	no_of_read_words = t4_read_cim_obq(padap, qid,
-					   (u32 *)((u32 *)temp_buff.data +
-					   temp_buff.offset), qsize);
+					   (u32 *)temp_buff.data, qsize);
 	/* no_of_read_words is less than or equal to 0 means error */
 	if (no_of_read_words <= 0) {
 		if (!no_of_read_words)
@@ -233,7 +242,6 @@ static int cudbg_read_cim_obq(struct cudbg_init *pdbg_init,
 		cudbg_put_buff(&temp_buff, dbg_buff);
 		return rc;
 	}
-	temp_buff.size = no_of_read_words * 4;
 	cudbg_write_and_release_buff(&temp_buff, dbg_buff);
 	return rc;
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h b/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h
index c4440c1d0142..df24c409c82f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cudbg_lib.h
@@ -100,4 +100,5 @@ int cudbg_collect_hma_indirect(struct cudbg_init *pdbg_init,
 struct cudbg_entity_hdr *cudbg_get_entity_hdr(void *outbuf, int i);
 void cudbg_align_debug_buffer(struct cudbg_buffer *dbg_buff,
 			      struct cudbg_entity_hdr *entity_hdr);
+u32 cudbg_cim_obq_size(struct adapter *padap, int qid);
 #endif /* __CUDBG_LIB_H__ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c
index 9d97080a9d17..59740ac7e46e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_cudbg.c
@@ -82,14 +82,28 @@ static u32 cxgb4_get_entity_length(struct adapter *adap, u32 entity)
 		len = CIM_IBQ_SIZE * 4 * sizeof(u32);
 		break;
 	case CUDBG_CIM_OBQ_ULP0:
+		len = cudbg_cim_obq_size(adap, 0);
+		break;
 	case CUDBG_CIM_OBQ_ULP1:
+		len = cudbg_cim_obq_size(adap, 1);
+		break;
 	case CUDBG_CIM_OBQ_ULP2:
+		len = cudbg_cim_obq_size(adap, 2);
+		break;
 	case CUDBG_CIM_OBQ_ULP3:
+		len = cudbg_cim_obq_size(adap, 3);
+		break;
 	case CUDBG_CIM_OBQ_SGE:
+		len = cudbg_cim_obq_size(adap, 4);
+		break;
 	case CUDBG_CIM_OBQ_NCSI:
+		len = cudbg_cim_obq_size(adap, 5);
+		break;
 	case CUDBG_CIM_OBQ_RXQ0:
+		len = cudbg_cim_obq_size(adap, 6);
+		break;
 	case CUDBG_CIM_OBQ_RXQ1:
-		len = 6 * CIM_OBQ_SIZE * 4 * sizeof(u32);
+		len = cudbg_cim_obq_size(adap, 7);
 		break;
 	case CUDBG_EDC0:
 		value = t4_read_reg(adap, MA_TARGET_MEM_ENABLE_A);
-- 
2.14.1
