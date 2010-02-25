From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 1/6] cnic: Finetune iSCSI connection set up.
Date: Wed, 24 Feb 2010 16:42:04 -0800
Message-ID: <1267058529-18454-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2830 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758669Ab0BYAcn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2010 19:32:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eddie Wai <waie@broadcom.com>

Initialize IP ID and handle some additional connection errors.

Signed-off-by: Eddie Wai <waie@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/cnic.c |   17 ++++++++++++++++-
 drivers/net/cnic.h |    2 +-
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 6aecef9..0fe8371 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -2507,7 +2507,7 @@ static int cnic_cm_offload_pg(struct cnic_sock *csk)
 	l4kwqe->sa5 = dev->mac_addr[5];
 
 	l4kwqe->etype = ETH_P_IP;
-	l4kwqe->ipid_count = DEF_IPID_COUNT;
+	l4kwqe->ipid_start = DEF_IPID_START;
 	l4kwqe->host_opaque = csk->l5_cid;
 
 	if (csk->vlan_id) {
@@ -3046,6 +3046,14 @@ static void cnic_cm_process_offld_pg(struct cnic_dev *dev, struct l4_kcq *kcqe)
 		clear_bit(SK_F_OFFLD_SCHED, &csk->flags);
 		goto done;
 	}
+	/* Possible PG kcqe status:  SUCCESS, OFFLOADED_PG, or CTX_ALLOC_FAIL */
+	if (kcqe->status == L4_KCQE_COMPLETION_STATUS_CTX_ALLOC_FAIL) {
+		clear_bit(SK_F_OFFLD_SCHED, &csk->flags);
+		cnic_cm_upcall(cp, csk,
+			       L4_KCQE_OPCODE_VALUE_CONNECT_COMPLETE);
+		goto done;
+	}
+
 	csk->pg_cid = kcqe->pg_cid;
 	set_bit(SK_F_PG_OFFLD_COMPLETE, &csk->flags);
 	cnic_cm_conn_req(csk);
@@ -3083,6 +3091,13 @@ static void cnic_cm_process_kcqe(struct cnic_dev *dev, struct kcqe *kcqe)
 	}
 
 	switch (opcode) {
+	case L5CM_RAMROD_CMD_ID_TCP_CONNECT:
+		if (l4kcqe->status != 0) {
+			clear_bit(SK_F_OFFLD_SCHED, &csk->flags);
+			cnic_cm_upcall(cp, csk,
+				       L4_KCQE_OPCODE_VALUE_CONNECT_COMPLETE);
+		}
+		break;
 	case L4_KCQE_OPCODE_VALUE_CONNECT_COMPLETE:
 		if (l4kcqe->status == 0)
 			set_bit(SK_F_OFFLD_COMPLETE, &csk->flags);
diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
index 241d09a..1921597 100644
--- a/drivers/net/cnic.h
+++ b/drivers/net/cnic.h
@@ -101,7 +101,7 @@ struct cnic_redirect_entry {
 #define BNX2X_KWQ_DATA(cp, x)						\
 	&(cp)->kwq_16_data[BNX2X_KWQ_DATA_PG(cp, x)][BNX2X_KWQ_DATA_IDX(cp, x)]
 
-#define DEF_IPID_COUNT		0xc001
+#define DEF_IPID_START		0x8000
 
 #define DEF_KA_TIMEOUT		10000
 #define DEF_KA_INTERVAL		300000
-- 
1.6.4.GIT


