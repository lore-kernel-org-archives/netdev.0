From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 1/6] cnic: Fine-tune CID memory space
 calculation.
Date: Thu, 24 Jun 2010 17:58:37 -0700
Message-ID: <1277427522-17306-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3198 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753988Ab0FYA4T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jun 2010 20:56:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code makes assumptions about the CID (context ID) memory
space and starting CID that may not be always correct when firmware
changes.  In particular, BNX2_ISCSI_START_CID may not always be fixed.
We now calculate cp->max_cid_space and cp->iscsi_start_cid dynamically
instead of using fixed constants.  The unused cp->max_iscsi_conn is also
eliminated.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   32 ++++++++++++++++++--------------
 drivers/net/cnic.h |    4 +++-
 2 files changed, 21 insertions(+), 15 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index e5539f0..23395fa 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -257,7 +257,7 @@ static int cnic_get_l5_cid(struct cnic_local *cp, u32 cid, u32 *l5_cid)
 {
 	u32 i;
 
-	for (i = 0; i < MAX_ISCSI_TBL_SZ; i++) {
+	for (i = 0; i < cp->max_cid_space; i++) {
 		if (cp->ctx_tbl[i].cid == cid) {
 			*l5_cid = i;
 			return 0;
@@ -981,17 +981,10 @@ error:
 static int cnic_alloc_bnx2x_context(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
-	struct cnic_eth_dev *ethdev = cp->ethdev;
 	int ctx_blk_size = cp->ethdev->ctx_blk_size;
-	int total_mem, blks, i, cid_space;
-
-	if (BNX2X_ISCSI_START_CID < ethdev->starting_cid)
-		return -EINVAL;
-
-	cid_space = MAX_ISCSI_TBL_SZ +
-		    (BNX2X_ISCSI_START_CID - ethdev->starting_cid);
+	int total_mem, blks, i;
 
-	total_mem = BNX2X_CONTEXT_MEM_SIZE * cid_space;
+	total_mem = BNX2X_CONTEXT_MEM_SIZE * cp->max_cid_space;
 	blks = total_mem / ctx_blk_size;
 	if (total_mem % ctx_blk_size)
 		blks++;
@@ -1035,16 +1028,27 @@ static int cnic_alloc_bnx2x_context(struct cnic_dev *dev)
 static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_eth_dev *ethdev = cp->ethdev;
+	u32 start_cid = ethdev->starting_cid;
 	int i, j, n, ret, pages;
 	struct cnic_dma *kwq_16_dma = &cp->kwq_16_data_info;
 
+	cp->max_cid_space = MAX_ISCSI_TBL_SZ;
+	cp->iscsi_start_cid = start_cid;
+	if (start_cid < BNX2X_ISCSI_START_CID) {
+		u32 delta = BNX2X_ISCSI_START_CID - start_cid;
+
+		cp->iscsi_start_cid = BNX2X_ISCSI_START_CID;
+		cp->max_cid_space += delta;
+	}
+
 	cp->iscsi_tbl = kzalloc(sizeof(struct cnic_iscsi) * MAX_ISCSI_TBL_SZ,
 				GFP_KERNEL);
 	if (!cp->iscsi_tbl)
 		goto error;
 
 	cp->ctx_tbl = kzalloc(sizeof(struct cnic_context) *
-				  MAX_CNIC_L5_CONTEXT, GFP_KERNEL);
+				cp->max_cid_space, GFP_KERNEL);
 	if (!cp->ctx_tbl)
 		goto error;
 
@@ -1053,7 +1057,7 @@ static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 		cp->ctx_tbl[i].ulp_proto_id = CNIC_ULP_ISCSI;
 	}
 
-	pages = PAGE_ALIGN(MAX_CNIC_L5_CONTEXT * CNIC_KWQ16_DATA_SIZE) /
+	pages = PAGE_ALIGN(cp->max_cid_space * CNIC_KWQ16_DATA_SIZE) /
 		PAGE_SIZE;
 
 	ret = cnic_alloc_dma(dev, kwq_16_dma, pages, 0);
@@ -1061,7 +1065,7 @@ static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 		return -ENOMEM;
 
 	n = PAGE_SIZE / CNIC_KWQ16_DATA_SIZE;
-	for (i = 0, j = 0; i < MAX_ISCSI_TBL_SZ; i++) {
+	for (i = 0, j = 0; i < cp->max_cid_space; i++) {
 		long off = CNIC_KWQ16_DATA_SIZE * (i % n);
 
 		cp->ctx_tbl[i].kwqe_data = kwq_16_dma->pg_arr[j] + off;
@@ -4116,7 +4120,7 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 	u8 sb_id = cp->status_blk_num;
 
 	ret = cnic_init_id_tbl(&cp->cid_tbl, MAX_ISCSI_TBL_SZ,
-			       BNX2X_ISCSI_START_CID);
+			       cp->iscsi_start_cid);
 
 	if (ret)
 		return -ENOMEM;
diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
index 08b1235..b7e2f7f 100644
--- a/drivers/net/cnic.h
+++ b/drivers/net/cnic.h
@@ -248,8 +248,10 @@ struct cnic_local {
 	struct cnic_iscsi	*iscsi_tbl;
 	struct cnic_context	*ctx_tbl;
 	struct cnic_id_tbl	cid_tbl;
-	int			max_iscsi_conn;
 	atomic_t		iscsi_conn;
+	u32			iscsi_start_cid;
+
+	u32			max_cid_space;
 
 	/* per connection parameters */
 	int			num_iscsi_tasks;
-- 
1.6.4.GIT


