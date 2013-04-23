From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next] bnx2x, bnx2fc: Use per port max exchange
 resources
Date: Tue, 23 Apr 2013 08:22:30 +0300
Message-ID: <1366694550-2894-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Bhanu Prakash Gollapudi" <bprakash@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2341 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754996Ab3DWGX5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Apr 2013 02:23:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bhanu Prakash Gollapudi <bprakash@broadcom.com>

The firmware supports a maximum of 4K FCoE exchanges. In 4-port devices,
or when working in multi-function mode, this resource needs to be distributed
between the various possible FCoE functions.

This information needs to be calculated by bnx2x and propagated into bnx2fc
via cnic. bnx2fc can then use this value to calculate corresponding xid
resources instead of using global constants.

Signed-off-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
---
Hi Dave,

Please consider applying this to `net-next'.

Thank,
Yuval
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h    |  4 +++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |  6 ++++
 drivers/net/ethernet/broadcom/cnic.c               |  4 ++-
 drivers/net/ethernet/broadcom/cnic_if.h            |  3 ++
 drivers/scsi/bnx2fc/bnx2fc.h                       | 23 +++++++-------
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c                  | 35 ++++++++++++----------
 drivers/scsi/bnx2fc/bnx2fc_hwi.c                   | 22 ++++++++------
 drivers/scsi/bnx2fc/bnx2fc_io.c                    |  9 +++---
 8 files changed, 64 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
index 40f22c6..84aecdf 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
@@ -386,4 +386,8 @@
 
 #define UNDEF_IRO 0x80000000
 
+/* used for defining the amount of FCoE tasks supported for PF */
+#define MAX_FCOE_FUNCS_PER_ENGINE 2
+#define MAX_NUM_FCOE_TASKS_PER_ENGINE 4096
+
 #endif /* BNX2X_FW_DEFS_H */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 1e60c5d..0a77782 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10783,6 +10783,12 @@ static void bnx2x_get_fcoe_info(struct bnx2x *bp)
 		(max_fcoe_conn & BNX2X_MAX_FCOE_INIT_CONN_MASK) >>
 		BNX2X_MAX_FCOE_INIT_CONN_SHIFT;
 
+	/* Calculate the number of maximum allowed FCoE tasks */
+	bp->cnic_eth_dev.max_fcoe_exchanges = MAX_NUM_FCOE_TASKS_PER_ENGINE;
+	if (IS_MF(bp) || CHIP_MODE_IS_4_PORT(bp))
+		bp->cnic_eth_dev.max_fcoe_exchanges /=
+						MAX_FCOE_FUNCS_PER_ENGINE;
+
 	/* Read the WWN: */
 	if (!IS_MF(bp)) {
 		/* Port info */
diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 149a3a0..40649a8 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -5544,8 +5544,10 @@ static struct cnic_dev *init_bnx2x_cnic(struct net_device *dev)
 
 	if (!(ethdev->drv_state & CNIC_DRV_STATE_NO_ISCSI))
 		cdev->max_iscsi_conn = ethdev->max_iscsi_conn;
-	if (CNIC_SUPPORTS_FCOE(cp))
+	if (CNIC_SUPPORTS_FCOE(cp)) {
 		cdev->max_fcoe_conn = ethdev->max_fcoe_conn;
+		cdev->max_fcoe_exchanges = ethdev->max_fcoe_exchanges;
+	}
 
 	if (cdev->max_fcoe_conn > BNX2X_FCOE_NUM_CONNECTIONS)
 		cdev->max_fcoe_conn = BNX2X_FCOE_NUM_CONNECTIONS;
diff --git a/drivers/net/ethernet/broadcom/cnic_if.h b/drivers/net/ethernet/broadcom/cnic_if.h
index 0c9367a..ec9bb9a 100644
--- a/drivers/net/ethernet/broadcom/cnic_if.h
+++ b/drivers/net/ethernet/broadcom/cnic_if.h
@@ -195,6 +195,7 @@ struct cnic_eth_dev {
 	u32		max_fcoe_conn;
 	u32		max_rdma_conn;
 	u32		fcoe_init_cid;
+	u32		max_fcoe_exchanges;
 	u32		fcoe_wwn_port_name_hi;
 	u32		fcoe_wwn_port_name_lo;
 	u32		fcoe_wwn_node_name_hi;
@@ -313,6 +314,8 @@ struct cnic_dev {
 	int		max_fcoe_conn;
 	int		max_rdma_conn;
 
+	int		max_fcoe_exchanges;
+
 	union drv_info_to_mcp	*stats_addr;
 	struct fcoe_capabilities	*fcoe_cap;
 
diff --git a/drivers/scsi/bnx2fc/bnx2fc.h b/drivers/scsi/bnx2fc/bnx2fc.h
index 50fcd01..11596b2 100644
--- a/drivers/scsi/bnx2fc/bnx2fc.h
+++ b/drivers/scsi/bnx2fc/bnx2fc.h
@@ -88,9 +88,6 @@
 
 #define BNX2FC_MAX_NPIV		256
 
-#define BNX2FC_MAX_OUTSTANDING_CMNDS	2048
-#define BNX2FC_CAN_QUEUE		BNX2FC_MAX_OUTSTANDING_CMNDS
-#define BNX2FC_ELSTM_XIDS		BNX2FC_CAN_QUEUE
 #define BNX2FC_MIN_PAYLOAD		256
 #define BNX2FC_MAX_PAYLOAD		2048
 #define BNX2FC_MFS			\
@@ -108,11 +105,8 @@
 #define BNX2FC_CONFQ_WQE_SIZE		(sizeof(struct fcoe_confqe))
 #define BNX2FC_5771X_DB_PAGE_SIZE	128
 
-#define BNX2FC_MAX_TASKS		\
-			     (BNX2FC_MAX_OUTSTANDING_CMNDS + BNX2FC_ELSTM_XIDS)
 #define BNX2FC_TASK_SIZE		128
 #define	BNX2FC_TASKS_PER_PAGE		(PAGE_SIZE/BNX2FC_TASK_SIZE)
-#define BNX2FC_TASK_CTX_ARR_SZ		(BNX2FC_MAX_TASKS/BNX2FC_TASKS_PER_PAGE)
 
 #define BNX2FC_MAX_ROWS_IN_HASH_TBL	8
 #define BNX2FC_HASH_TBL_CHUNK_SIZE	(16 * 1024)
@@ -125,12 +119,9 @@
 #define BNX2FC_WRITE			(1 << 0)
 
 #define BNX2FC_MIN_XID			0
-#define BNX2FC_MAX_XID			\
-			(BNX2FC_MAX_OUTSTANDING_CMNDS + BNX2FC_ELSTM_XIDS - 1)
 #define FCOE_MAX_NUM_XIDS		0x2000
-#define FCOE_MIN_XID			(BNX2FC_MAX_XID + 1)
-#define FCOE_MAX_XID			(FCOE_MIN_XID + FCOE_MAX_NUM_XIDS - 1)
-#define FCOE_XIDS_PER_CPU		(FCOE_MIN_XID + (512 * nr_cpu_ids) - 1)
+#define FCOE_MAX_XID_OFFSET		(FCOE_MAX_NUM_XIDS - 1)
+#define FCOE_XIDS_PER_CPU_OFFSET	((512 * nr_cpu_ids) - 1)
 #define BNX2FC_MAX_LUN			0xFFFF
 #define BNX2FC_MAX_FCP_TGT		256
 #define BNX2FC_MAX_CMD_LEN		16
@@ -206,6 +197,13 @@ struct bnx2fc_hba {
 		#define BNX2FC_FLAG_FW_INIT_DONE	0
 		#define BNX2FC_FLAG_DESTROY_CMPL	1
 	u32 next_conn_id;
+
+	/* xid resources */
+	u16 max_xid;
+	u32 max_tasks;
+	u32 max_outstanding_cmds;
+	u32 elstm_xids;
+
 	struct fcoe_task_ctx_entry **task_ctx;
 	dma_addr_t *task_ctx_dma;
 	struct regpair *task_ctx_bd_tbl;
@@ -504,8 +502,7 @@ int bnx2fc_setup_task_ctx(struct bnx2fc_hba *hba);
 void bnx2fc_free_task_ctx(struct bnx2fc_hba *hba);
 int bnx2fc_setup_fw_resc(struct bnx2fc_hba *hba);
 void bnx2fc_free_fw_resc(struct bnx2fc_hba *hba);
-struct bnx2fc_cmd_mgr *bnx2fc_cmd_mgr_alloc(struct bnx2fc_hba *hba,
-						u16 min_xid, u16 max_xid);
+struct bnx2fc_cmd_mgr *bnx2fc_cmd_mgr_alloc(struct bnx2fc_hba *hba);
 void bnx2fc_cmd_mgr_free(struct bnx2fc_cmd_mgr *cmgr);
 void bnx2fc_get_link_state(struct bnx2fc_hba *hba);
 char *bnx2fc_get_next_rqe(struct bnx2fc_rport *tgt, u8 num_items);
diff --git a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
index 90bc7bd..7dffec1 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
@@ -71,7 +71,7 @@ static void bnx2fc_recv_frame(struct sk_buff *skb);
 static void bnx2fc_start_disc(struct bnx2fc_interface *interface);
 static int bnx2fc_shost_config(struct fc_lport *lport, struct device *dev);
 static int bnx2fc_lport_config(struct fc_lport *lport);
-static int bnx2fc_em_config(struct fc_lport *lport);
+static int bnx2fc_em_config(struct fc_lport *lport, struct bnx2fc_hba *hba);
 static int bnx2fc_bind_adapter_devices(struct bnx2fc_hba *hba);
 static void bnx2fc_unbind_adapter_devices(struct bnx2fc_hba *hba);
 static int bnx2fc_bind_pcidev(struct bnx2fc_hba *hba);
@@ -944,16 +944,17 @@ static int bnx2fc_libfc_config(struct fc_lport *lport)
 	return 0;
 }
 
-static int bnx2fc_em_config(struct fc_lport *lport)
+static int bnx2fc_em_config(struct fc_lport *lport, struct bnx2fc_hba *hba)
 {
-	int max_xid;
+	int fcoe_min_xid, fcoe_max_xid;
 
+	fcoe_min_xid = hba->max_xid + 1;
 	if (nr_cpu_ids <= 2)
-		max_xid = FCOE_XIDS_PER_CPU;
+		fcoe_max_xid = hba->max_xid + FCOE_XIDS_PER_CPU_OFFSET;
 	else
-		max_xid = FCOE_MAX_XID;
-	if (!fc_exch_mgr_alloc(lport, FC_CLASS_3, FCOE_MIN_XID,
-				max_xid, NULL)) {
+		fcoe_max_xid = hba->max_xid + FCOE_MAX_XID_OFFSET;
+	if (!fc_exch_mgr_alloc(lport, FC_CLASS_3, fcoe_min_xid,
+			       fcoe_max_xid, NULL)) {
 		printk(KERN_ERR PFX "em_config:fc_exch_mgr_alloc failed\n");
 		return -ENOMEM;
 	}
@@ -1300,6 +1301,12 @@ static struct bnx2fc_hba *bnx2fc_hba_create(struct cnic_dev *cnic)
 	mutex_init(&hba->hba_mutex);
 
 	hba->cnic = cnic;
+
+	hba->max_tasks = cnic->max_fcoe_exchanges;
+	hba->elstm_xids = (hba->max_tasks / 2);
+	hba->max_outstanding_cmds = hba->elstm_xids;
+	hba->max_xid = (hba->max_tasks - 1);
+
 	rc = bnx2fc_bind_pcidev(hba);
 	if (rc) {
 		printk(KERN_ERR PFX "create_adapter:  bind error\n");
@@ -1318,8 +1325,7 @@ static struct bnx2fc_hba *bnx2fc_hba_create(struct cnic_dev *cnic)
 
 	hba->num_ofld_sess = 0;
 
-	hba->cmd_mgr = bnx2fc_cmd_mgr_alloc(hba, BNX2FC_MIN_XID,
-						BNX2FC_MAX_XID);
+	hba->cmd_mgr = bnx2fc_cmd_mgr_alloc(hba);
 	if (!hba->cmd_mgr) {
 		printk(KERN_ERR PFX "em_config:bnx2fc_cmd_mgr_alloc failed\n");
 		goto cmgr_err;
@@ -1330,13 +1336,13 @@ static struct bnx2fc_hba *bnx2fc_hba_create(struct cnic_dev *cnic)
 					FCOE_IOS_PER_CONNECTION_SHIFT;
 	fcoe_cap->capability1 |= BNX2FC_NUM_MAX_SESS <<
 					FCOE_LOGINS_PER_PORT_SHIFT;
-	fcoe_cap->capability2 = BNX2FC_MAX_OUTSTANDING_CMNDS <<
+	fcoe_cap->capability2 = hba->max_outstanding_cmds <<
 					FCOE_NUMBER_OF_EXCHANGES_SHIFT;
 	fcoe_cap->capability2 |= BNX2FC_MAX_NPIV <<
 					FCOE_NPIV_WWN_PER_PORT_SHIFT;
 	fcoe_cap->capability3 = BNX2FC_NUM_MAX_SESS <<
 					FCOE_TARGETS_SUPPORTED_SHIFT;
-	fcoe_cap->capability3 |= BNX2FC_MAX_OUTSTANDING_CMNDS <<
+	fcoe_cap->capability3 |= hba->max_outstanding_cmds <<
 					FCOE_OUTSTANDING_COMMANDS_SHIFT;
 	fcoe_cap->capability4 = FCOE_CAPABILITY4_STATEFUL;
 
@@ -1416,7 +1422,7 @@ static struct fc_lport *bnx2fc_if_create(struct bnx2fc_interface *interface,
 	struct Scsi_Host	*shost;
 	struct fc_vport		*vport = dev_to_vport(parent);
 	struct bnx2fc_lport	*blport;
-	struct bnx2fc_hba	*hba;
+	struct bnx2fc_hba	*hba = interface->hba;
 	int			rc = 0;
 
 	blport = kzalloc(sizeof(struct bnx2fc_lport), GFP_KERNEL);
@@ -1426,6 +1432,7 @@ static struct fc_lport *bnx2fc_if_create(struct bnx2fc_interface *interface,
 	}
 
 	/* Allocate Scsi_Host structure */
+	bnx2fc_shost_template.can_queue = hba->max_outstanding_cmds;
 	if (!npiv)
 		lport = libfc_host_alloc(&bnx2fc_shost_template, sizeof(*port));
 	else
@@ -1477,7 +1484,7 @@ static struct fc_lport *bnx2fc_if_create(struct bnx2fc_interface *interface,
 
 	/* Allocate exchange manager */
 	if (!npiv)
-		rc = bnx2fc_em_config(lport);
+		rc = bnx2fc_em_config(lport, hba);
 	else {
 		shost = vport_to_shost(vport);
 		n_port = shost_priv(shost);
@@ -1491,7 +1498,6 @@ static struct fc_lport *bnx2fc_if_create(struct bnx2fc_interface *interface,
 
 	bnx2fc_interface_get(interface);
 
-	hba = interface->hba;
 	spin_lock_bh(&hba->hba_lock);
 	blport->lport = lport;
 	list_add_tail(&blport->list, &hba->vports);
@@ -2706,7 +2712,6 @@ static struct scsi_host_template bnx2fc_shost_template = {
 	.change_queue_type	= fc_change_queue_type,
 	.this_id		= -1,
 	.cmd_per_lun		= 3,
-	.can_queue		= BNX2FC_CAN_QUEUE,
 	.use_clustering		= ENABLE_CLUSTERING,
 	.sg_tablesize		= BNX2FC_MAX_BDS_PER_CMD,
 	.max_sectors		= 1024,
diff --git a/drivers/scsi/bnx2fc/bnx2fc_hwi.c b/drivers/scsi/bnx2fc/bnx2fc_hwi.c
index 85ea98a..50510ff 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_hwi.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_hwi.c
@@ -77,7 +77,7 @@ int bnx2fc_send_fw_fcoe_init_msg(struct bnx2fc_hba *hba)
 	fcoe_init1.hdr.flags = (FCOE_KWQE_LAYER_CODE <<
 					FCOE_KWQE_HEADER_LAYER_CODE_SHIFT);
 
-	fcoe_init1.num_tasks = BNX2FC_MAX_TASKS;
+	fcoe_init1.num_tasks = hba->max_tasks;
 	fcoe_init1.sq_num_wqes = BNX2FC_SQ_WQES_MAX;
 	fcoe_init1.rq_num_wqes = BNX2FC_RQ_WQES_MAX;
 	fcoe_init1.rq_buffer_log_size = BNX2FC_RQ_BUF_LOG_SZ;
@@ -697,7 +697,7 @@ static void bnx2fc_process_unsol_compl(struct bnx2fc_rport *tgt, u16 wqe)
 			err_entry->data.tx_buf_off, err_entry->data.rx_buf_off);
 
 
-		if (xid > BNX2FC_MAX_XID) {
+		if (xid > hba->max_xid) {
 			BNX2FC_TGT_DBG(tgt, "xid(0x%x) out of FW range\n",
 				   xid);
 			goto ret_err_rqe;
@@ -815,7 +815,7 @@ ret_err_rqe:
 		BNX2FC_TGT_DBG(tgt, "buf_offsets - tx = 0x%x, rx = 0x%x",
 			err_entry->data.tx_buf_off, err_entry->data.rx_buf_off);
 
-		if (xid > BNX2FC_MAX_XID) {
+		if (xid > hba->max_xid) {
 			BNX2FC_TGT_DBG(tgt, "xid(0x%x) out of FW range\n", xid);
 			goto ret_warn_rqe;
 		}
@@ -880,7 +880,7 @@ void bnx2fc_process_cq_compl(struct bnx2fc_rport *tgt, u16 wqe)
 
 	spin_lock_bh(&tgt->tgt_lock);
 	xid = wqe & FCOE_PEND_WQ_CQE_TASK_ID;
-	if (xid >= BNX2FC_MAX_TASKS) {
+	if (xid >= hba->max_tasks) {
 		printk(KERN_ERR PFX "ERROR:xid out of range\n");
 		spin_unlock_bh(&tgt->tgt_lock);
 		return;
@@ -1842,6 +1842,7 @@ int bnx2fc_setup_task_ctx(struct bnx2fc_hba *hba)
 	int rc = 0;
 	struct regpair *task_ctx_bdt;
 	dma_addr_t addr;
+	int task_ctx_arr_sz;
 	int i;
 
 	/*
@@ -1865,7 +1866,8 @@ int bnx2fc_setup_task_ctx(struct bnx2fc_hba *hba)
 	 * Allocate task_ctx which is an array of pointers pointing to
 	 * a page containing 32 task contexts
 	 */
-	hba->task_ctx = kzalloc((BNX2FC_TASK_CTX_ARR_SZ * sizeof(void *)),
+	task_ctx_arr_sz = (hba->max_tasks / BNX2FC_TASKS_PER_PAGE);
+	hba->task_ctx = kzalloc((task_ctx_arr_sz * sizeof(void *)),
 				 GFP_KERNEL);
 	if (!hba->task_ctx) {
 		printk(KERN_ERR PFX "unable to allocate task context array\n");
@@ -1876,7 +1878,7 @@ int bnx2fc_setup_task_ctx(struct bnx2fc_hba *hba)
 	/*
 	 * Allocate task_ctx_dma which is an array of dma addresses
 	 */
-	hba->task_ctx_dma = kmalloc((BNX2FC_TASK_CTX_ARR_SZ *
+	hba->task_ctx_dma = kmalloc((task_ctx_arr_sz *
 					sizeof(dma_addr_t)), GFP_KERNEL);
 	if (!hba->task_ctx_dma) {
 		printk(KERN_ERR PFX "unable to alloc context mapping array\n");
@@ -1885,7 +1887,7 @@ int bnx2fc_setup_task_ctx(struct bnx2fc_hba *hba)
 	}
 
 	task_ctx_bdt = (struct regpair *)hba->task_ctx_bd_tbl;
-	for (i = 0; i < BNX2FC_TASK_CTX_ARR_SZ; i++) {
+	for (i = 0; i < task_ctx_arr_sz; i++) {
 
 		hba->task_ctx[i] = dma_alloc_coherent(&hba->pcidev->dev,
 						      PAGE_SIZE,
@@ -1905,7 +1907,7 @@ int bnx2fc_setup_task_ctx(struct bnx2fc_hba *hba)
 	return 0;
 
 out3:
-	for (i = 0; i < BNX2FC_TASK_CTX_ARR_SZ; i++) {
+	for (i = 0; i < task_ctx_arr_sz; i++) {
 		if (hba->task_ctx[i]) {
 
 			dma_free_coherent(&hba->pcidev->dev, PAGE_SIZE,
@@ -1929,6 +1931,7 @@ out:
 
 void bnx2fc_free_task_ctx(struct bnx2fc_hba *hba)
 {
+	int task_ctx_arr_sz;
 	int i;
 
 	if (hba->task_ctx_bd_tbl) {
@@ -1938,8 +1941,9 @@ void bnx2fc_free_task_ctx(struct bnx2fc_hba *hba)
 		hba->task_ctx_bd_tbl = NULL;
 	}
 
+	task_ctx_arr_sz = (hba->max_tasks / BNX2FC_TASKS_PER_PAGE);
 	if (hba->task_ctx) {
-		for (i = 0; i < BNX2FC_TASK_CTX_ARR_SZ; i++) {
+		for (i = 0; i < task_ctx_arr_sz; i++) {
 			if (hba->task_ctx[i]) {
 				dma_free_coherent(&hba->pcidev->dev, PAGE_SIZE,
 						    hba->task_ctx[i],
diff --git a/drivers/scsi/bnx2fc/bnx2fc_io.c b/drivers/scsi/bnx2fc/bnx2fc_io.c
index 60798e8..723a9a8 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_io.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_io.c
@@ -239,8 +239,7 @@ static void bnx2fc_scsi_done(struct bnx2fc_cmd *io_req, int err_code)
 	sc_cmd->scsi_done(sc_cmd);
 }
 
-struct bnx2fc_cmd_mgr *bnx2fc_cmd_mgr_alloc(struct bnx2fc_hba *hba,
-						u16 min_xid, u16 max_xid)
+struct bnx2fc_cmd_mgr *bnx2fc_cmd_mgr_alloc(struct bnx2fc_hba *hba)
 {
 	struct bnx2fc_cmd_mgr *cmgr;
 	struct io_bdt *bdt_info;
@@ -252,6 +251,8 @@ struct bnx2fc_cmd_mgr *bnx2fc_cmd_mgr_alloc(struct bnx2fc_hba *hba,
 	int num_ios, num_pri_ios;
 	size_t bd_tbl_sz;
 	int arr_sz = num_possible_cpus() + 1;
+	u16 min_xid = BNX2FC_MIN_XID;
+	u16 max_xid = hba->max_xid;
 
 	if (max_xid <= min_xid || max_xid == FC_XID_UNKNOWN) {
 		printk(KERN_ERR PFX "cmd_mgr_alloc: Invalid min_xid 0x%x \
@@ -298,7 +299,7 @@ struct bnx2fc_cmd_mgr *bnx2fc_cmd_mgr_alloc(struct bnx2fc_hba *hba,
 	 * of slow path requests.
 	 */
 	xid = BNX2FC_MIN_XID;
-	num_pri_ios = num_ios - BNX2FC_ELSTM_XIDS;
+	num_pri_ios = num_ios - hba->elstm_xids;
 	for (i = 0; i < num_ios; i++) {
 		io_req = kzalloc(sizeof(*io_req), GFP_KERNEL);
 
@@ -367,7 +368,7 @@ void bnx2fc_cmd_mgr_free(struct bnx2fc_cmd_mgr *cmgr)
 	struct bnx2fc_hba *hba = cmgr->hba;
 	size_t bd_tbl_sz;
 	u16 min_xid = BNX2FC_MIN_XID;
-	u16 max_xid = BNX2FC_MAX_XID;
+	u16 max_xid = hba->max_xid;
 	int num_ios;
 	int i;
 
-- 
1.8.1.227.g44fe835
