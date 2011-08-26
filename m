From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/3 net-next] cnic, bnx2fc: Increase maximum FCoE
 sessions.
Date: Fri, 26 Aug 2011 12:45:39 -0700
Message-ID: <1314387941-2126-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Bhanu Prakash Gollapudi" <bprakash@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2132 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754909Ab1HZUgp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Aug 2011 16:36:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Increase it to NVRAM configured limit or 1024 whichever is less.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c |   14 ++++++++------
 drivers/net/ethernet/broadcom/cnic.h |    2 +-
 drivers/scsi/bnx2fc/bnx2fc.h         |    2 +-
 3 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 7698161..73060f4 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -1177,7 +1177,7 @@ static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 	cp->fcoe_start_cid = start_cid + MAX_ISCSI_TBL_SZ;
 
 	if (BNX2X_CHIP_IS_E2_PLUS(cp->chip_id)) {
-		cp->max_cid_space += BNX2X_FCOE_NUM_CONNECTIONS;
+		cp->max_cid_space += dev->max_fcoe_conn;
 		cp->fcoe_init_cid = ethdev->fcoe_init_cid;
 		if (!cp->fcoe_init_cid)
 			cp->fcoe_init_cid = 0x10;
@@ -2280,7 +2280,7 @@ static int cnic_bnx2x_fcoe_ofld1(struct cnic_dev *dev, struct kwqe *wqes[],
 	*work = 4;
 
 	l5_cid = req1->fcoe_conn_id;
-	if (l5_cid >= BNX2X_FCOE_NUM_CONNECTIONS)
+	if (l5_cid >= dev->max_fcoe_conn)
 		goto err_reply;
 
 	l5_cid += BNX2X_FCOE_L5_CID_BASE;
@@ -2384,7 +2384,7 @@ static int cnic_bnx2x_fcoe_disable(struct cnic_dev *dev, struct kwqe *kwqe)
 	req = (struct fcoe_kwqe_conn_enable_disable *) kwqe;
 	cid = req->context_id;
 	l5_cid = req->conn_id;
-	if (l5_cid >= BNX2X_FCOE_NUM_CONNECTIONS)
+	if (l5_cid >= dev->max_fcoe_conn)
 		return -EINVAL;
 
 	l5_cid += BNX2X_FCOE_L5_CID_BASE;
@@ -2418,7 +2418,7 @@ static int cnic_bnx2x_fcoe_destroy(struct cnic_dev *dev, struct kwqe *kwqe)
 	req = (struct fcoe_kwqe_conn_destroy *) kwqe;
 	cid = req->context_id;
 	l5_cid = req->conn_id;
-	if (l5_cid >= BNX2X_FCOE_NUM_CONNECTIONS)
+	if (l5_cid >= dev->max_fcoe_conn)
 		return -EINVAL;
 
 	l5_cid += BNX2X_FCOE_L5_CID_BASE;
@@ -4850,8 +4850,7 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 		return -ENOMEM;
 
 	if (BNX2X_CHIP_IS_E2_PLUS(cp->chip_id)) {
-		ret = cnic_init_id_tbl(&cp->fcoe_cid_tbl,
-					BNX2X_FCOE_NUM_CONNECTIONS,
+		ret = cnic_init_id_tbl(&cp->fcoe_cid_tbl, dev->max_fcoe_conn,
 					cp->fcoe_start_cid, 0);
 
 		if (ret)
@@ -5292,6 +5291,9 @@ static struct cnic_dev *init_bnx2x_cnic(struct net_device *dev)
 	    !(ethdev->drv_state & CNIC_DRV_STATE_NO_FCOE))
 		cdev->max_fcoe_conn = ethdev->max_fcoe_conn;
 
+	if (cdev->max_fcoe_conn > BNX2X_FCOE_NUM_CONNECTIONS)
+		cdev->max_fcoe_conn = BNX2X_FCOE_NUM_CONNECTIONS;
+
 	memcpy(cdev->mac_addr, ethdev->iscsi_mac, 6);
 
 	cp->cnic_ops = &cnic_bnx2x_ops;
diff --git a/drivers/net/ethernet/broadcom/cnic.h b/drivers/net/ethernet/broadcom/cnic.h
index 7a2928f..15b1c09 100644
--- a/drivers/net/ethernet/broadcom/cnic.h
+++ b/drivers/net/ethernet/broadcom/cnic.h
@@ -373,7 +373,7 @@ struct bnx2x_bd_chain_next {
 #define BNX2X_ISCSI_PBL_NOT_CACHED	0xff
 #define BNX2X_ISCSI_PDU_HEADER_NOT_CACHED	0xff
 
-#define BNX2X_FCOE_NUM_CONNECTIONS	128
+#define BNX2X_FCOE_NUM_CONNECTIONS	1024
 
 #define BNX2X_FCOE_L5_CID_BASE		MAX_ISCSI_TBL_SZ
 
diff --git a/drivers/scsi/bnx2fc/bnx2fc.h b/drivers/scsi/bnx2fc/bnx2fc.h
index 5613e8a..dd335a2 100644
--- a/drivers/scsi/bnx2fc/bnx2fc.h
+++ b/drivers/scsi/bnx2fc/bnx2fc.h
@@ -81,7 +81,7 @@
 #define BNX2FC_RQ_WQES_MAX	16
 #define BNX2FC_CQ_WQES_MAX	(BNX2FC_SQ_WQES_MAX + BNX2FC_RQ_WQES_MAX)
 
-#define BNX2FC_NUM_MAX_SESS	128
+#define BNX2FC_NUM_MAX_SESS	1024
 #define BNX2FC_NUM_MAX_SESS_LOG	(ilog2(BNX2FC_NUM_MAX_SESS))
 
 #define BNX2FC_MAX_OUTSTANDING_CMNDS	2048
-- 
1.7.1
