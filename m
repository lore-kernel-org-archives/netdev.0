From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next-2.6 4/4] be2net: Making die temperature ioctl call async
Date: Fri, 30 Sep 2011 22:55:05 +0530
Message-ID: <9e212ebe-e6ae-4789-8251-392486fd0f2d@exht2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:10146 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755750Ab1I3MAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 08:00:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also changing it's frequency to once every 64s instead of existing 32s as
it was shown to affect performance

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    5 +++
 drivers/net/ethernet/emulex/benet/be_cmds.c |   40 +++++++++++++++++----------
 2 files changed, 30 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 894f1a9..644e8fe 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -137,6 +137,11 @@ static inline void *queue_tail_node(struct be_queue_info *q)
 	return q->dma_mem.va + q->tail * q->entry_size;
 }
 
+static inline void *queue_index_node(struct be_queue_info *q, u16 index)
+{
+	return q->dma_mem.va + index * q->entry_size;
+}
+
 static inline void queue_head_inc(struct be_queue_info *q)
 {
 	index_inc(&q->head, q->len);
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 15949b9..38c9222 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -19,7 +19,12 @@
 #include "be_cmds.h"
 
 /* Must be a power of 2 or else MODULO will BUG_ON */
-static int be_get_temp_freq = 32;
+static int be_get_temp_freq = 64;
+
+static inline void *embedded_payload(struct be_mcc_wrb *wrb)
+{
+	return wrb->payload.embedded_payload;
+}
 
 static void be_mcc_notify(struct be_adapter *adapter)
 {
@@ -85,7 +90,20 @@ static int be_mcc_compl_process(struct be_adapter *adapter,
 			be_parse_stats(adapter);
 			adapter->stats_cmd_sent = false;
 		}
+		if (compl->tag0 ==
+				OPCODE_COMMON_GET_CNTL_ADDITIONAL_ATTRIBUTES) {
+			struct be_mcc_wrb *mcc_wrb =
+				queue_index_node(&adapter->mcc_obj.q,
+						compl->tag1);
+			struct be_cmd_resp_get_cntl_addnl_attribs *resp =
+				embedded_payload(mcc_wrb);
+			adapter->drv_stats.be_on_die_temperature =
+				resp->on_die_temperature;
+		}
 	} else {
+		if (compl->tag0 == OPCODE_COMMON_GET_CNTL_ADDITIONAL_ATTRIBUTES)
+			be_get_temp_freq = 0;
+
 		if (compl_status == MCC_STATUS_NOT_SUPPORTED ||
 			compl_status == MCC_STATUS_ILLEGAL_REQUEST)
 			goto done;
@@ -404,10 +422,6 @@ int be_cmd_POST(struct be_adapter *adapter)
 	return -1;
 }
 
-static inline void *embedded_payload(struct be_mcc_wrb *wrb)
-{
-	return wrb->payload.embedded_payload;
-}
 
 static inline struct be_sge *nonembedded_sgl(struct be_mcc_wrb *wrb)
 {
@@ -1301,10 +1315,13 @@ int be_cmd_get_die_temperature(struct be_adapter *adapter)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_get_cntl_addnl_attribs *req;
+	u16 mccq_index;
 	int status;
 
 	spin_lock_bh(&adapter->mcc_lock);
 
+	mccq_index = adapter->mcc_obj.q.head;
+
 	wrb = wrb_from_mccq(adapter);
 	if (!wrb) {
 		status = -EBUSY;
@@ -1318,16 +1335,9 @@ int be_cmd_get_die_temperature(struct be_adapter *adapter)
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_GET_CNTL_ADDITIONAL_ATTRIBUTES, sizeof(*req));
 
-	status = be_mcc_notify_wait(adapter);
-	if (!status) {
-		struct be_cmd_resp_get_cntl_addnl_attribs *resp =
-						embedded_payload(wrb);
-		adapter->drv_stats.be_on_die_temperature =
-						resp->on_die_temperature;
-	}
-	/* If IOCTL fails once, do not bother issuing it again */
-	else
-		be_get_temp_freq = 0;
+	wrb->tag1 = mccq_index;
+
+	be_mcc_notify(adapter);
 
 err:
 	spin_unlock_bh(&adapter->mcc_lock);
-- 
1.5.6.1
