From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 4/7] libfc: add support of large receive offload by ddp in
	fc_fcp
Date: Thu, 19 Feb 2009 12:50:06 -0700
Message-ID: <20090219195006.22270.80819.stgit.yi.zou@intel.com>
References: <20090219194734.22270.8445.stgit@zychengdu.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: linux-scsi@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090219194734.22270.8445.stgit@zychengdu.jf.intel.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When LLD supports direct data placement (ddp) for large receive of an scsi
i/o coming into fc_fcp, we call into libfc_function_template's ddp_setup()
to prepare for a ddp of large receive for this read I/O. When I/O is complete,
we call the corresponding ddp_done() to get the length of data ddped as well
as to let LLD do clean up.

Summary of changes:
1. Added ddp_setup()/ddp_done() to libfc_function_template and they are
expected to be impleted by fcoe layer
2. Added exch_send() to seperate exch_alloc() from exch_seq_send in
fc_fcp_cmd_send() since that's where we call ddp_setup() and we have to have
know the exchange xid.
3. Added calling lp->tt.ddp_setup() for read I/O if lro_enabled is set.
When ddp_setup is successful, xfer_ddp stores the corresponding exchange xid.
4. Added calling lp->tt.ddp_done() to fc_fcp_resp() to update the xfer_len
for the case of a normal complete ddp and let the LLD release ddp resource.
5. Added calling lp->tt.ddp_done() to fc_fcp_recv_data() to update the
xfer_len for the case of an incomplete ddp
6. Added calling lp->tt.ddp_done() to fc_io_compl() for an ddped I/O to make
sure ddp resource is released in case of abort
7. Also removed clearing of lro_enabled flag in fc_exch_mgr_alloc() since
that is taken care of by fcoe_sw_netdev_config() now.

Signed-off-by: Yi Zou <yi.zou@intel.com>
---

 drivers/scsi/libfc/fc_exch.c |   46 +++++++++++++++++++++++++++---------------
 drivers/scsi/libfc/fc_fcp.c  |   36 +++++++++++++++++++++++++++++++--
 include/scsi/libfc.h         |   46 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 110 insertions(+), 18 deletions(-)

diff --git a/drivers/scsi/libfc/fc_exch.c b/drivers/scsi/libfc/fc_exch.c
index 2fb2282..8faf5e8 100644
--- a/drivers/scsi/libfc/fc_exch.c
+++ b/drivers/scsi/libfc/fc_exch.c
@@ -1753,9 +1753,6 @@ struct fc_exch_mgr *fc_exch_mgr_alloc(struct fc_lport *lp,
 		mp->max_read = lp->lro_xid;
 		mp->last_read = min_xid - 1;
 		mp->last_xid = mp->max_read;
-	} else {
-		/* disable lro if no xid control over read */
-		lp->lro_enabled = 0;
 	}
 
 	INIT_LIST_HEAD(&mp->ex_list);
@@ -1795,24 +1792,19 @@ struct fc_exch *fc_exch_get(struct fc_lport *lp, struct fc_frame *fp)
 }
 EXPORT_SYMBOL(fc_exch_get);
 
-struct fc_seq *fc_exch_seq_send(struct fc_lport *lp,
-				struct fc_frame *fp,
-				void (*resp)(struct fc_seq *,
-					     struct fc_frame *fp,
-					     void *arg),
-				void (*destructor)(struct fc_seq *, void *),
-				void *arg, u32 timer_msec)
+struct fc_seq *fc_exch_send(struct fc_lport *lp,
+			    struct fc_exch *ep,
+			    struct fc_frame *fp,
+			    void (*resp)(struct fc_seq *,
+					struct fc_frame *fp,
+					void *arg),
+			    void (*destructor)(struct fc_seq *, void *),
+			    void *arg, u32 timer_msec)
 {
-	struct fc_exch *ep;
 	struct fc_seq *sp = NULL;
 	struct fc_frame_header *fh;
 	int rc = 1;
 
-	ep = lp->tt.exch_get(lp, fp);
-	if (!ep) {
-		fc_frame_free(fp);
-		return NULL;
-	}
 	ep->esb_stat |= ESB_ST_SEQ_INIT;
 	fh = fc_frame_header_get(fp);
 	fc_exch_set_addr(ep, ntoh24(fh->fh_s_id), ntoh24(fh->fh_d_id));
@@ -1846,6 +1838,25 @@ err:
 		fc_exch_mgr_delete_ep(ep);
 	return NULL;
 }
+EXPORT_SYMBOL(fc_exch_send);
+
+struct fc_seq *fc_exch_seq_send(struct fc_lport *lp,
+				struct fc_frame *fp,
+				void (*resp)(struct fc_seq *,
+					     struct fc_frame *fp,
+					     void *arg),
+				void (*destructor)(struct fc_seq *, void *),
+				void *arg, u32 timer_msec)
+{
+	struct fc_exch *ep;
+
+	ep = lp->tt.exch_get(lp, fp);
+	if (!ep) {
+		fc_frame_free(fp);
+		return NULL;
+	}
+	return	fc_exch_send(lp, ep, fp, resp, destructor, arg, timer_msec);
+}
 EXPORT_SYMBOL(fc_exch_seq_send);
 
 /*
@@ -1906,6 +1917,9 @@ int fc_exch_init(struct fc_lport *lp)
 	if (!lp->tt.seq_start_next)
 		lp->tt.seq_start_next = fc_seq_start_next;
 
+	if (!lp->tt.exch_send)
+		lp->tt.exch_send = fc_exch_send;
+
 	if (!lp->tt.exch_seq_send)
 		lp->tt.exch_seq_send = fc_exch_seq_send;
 
diff --git a/drivers/scsi/libfc/fc_fcp.c b/drivers/scsi/libfc/fc_fcp.c
index 92a72c7..c6ef7fe 100644
--- a/drivers/scsi/libfc/fc_fcp.c
+++ b/drivers/scsi/libfc/fc_fcp.c
@@ -285,6 +285,11 @@ static void fc_fcp_recv_data(struct fc_fcp_pkt *fsp, struct fc_frame *fp)
 	len = fr_len(fp) - sizeof(*fh);
 	buf = fc_frame_payload_get(fp, 0);
 
+	/* if this I/O is ddped, update xfer len */
+	if (fsp->xfer_ddp && lp->tt.ddp_done) {
+		fsp->xfer_len = lp->tt.ddp_done(lp, fsp->xfer_ddp);
+		fsp->xfer_ddp = 0;
+	}
 	if (offset + len > fsp->data_len) {
 		/* this should never happen */
 		if ((fr_flags(fp) & FCPHF_CRC_UNCHECKED) &&
@@ -740,6 +745,12 @@ static void fc_fcp_resp(struct fc_fcp_pkt *fsp, struct fc_frame *fp)
 	fsp->scsi_comp_flags = flags;
 	expected_len = fsp->data_len;
 
+	/* if ddp, update xfer len */
+	if (fsp->xfer_ddp && fsp->lp->tt.ddp_done) {
+		fsp->xfer_len = fsp->lp->tt.ddp_done(fsp->lp, fsp->xfer_ddp);
+		fsp->xfer_ddp = 0;
+	}
+
 	if (unlikely((flags & ~FCP_CONF_REQ) || fc_rp->fr_status)) {
 		rp_ex = (void *)(fc_rp + 1);
 		if (flags & (FCP_RSP_LEN_VAL | FCP_SNS_LEN_VAL)) {
@@ -987,6 +998,7 @@ static int fc_fcp_cmd_send(struct fc_lport *lp, struct fc_fcp_pkt *fsp,
 {
 	struct fc_frame *fp;
 	struct fc_seq *seq;
+	struct fc_exch *ep;
 	struct fc_rport *rport;
 	struct fc_rport_libfc_priv *rp;
 	const size_t len = sizeof(fsp->cdb_cmd);
@@ -1011,7 +1023,21 @@ static int fc_fcp_cmd_send(struct fc_lport *lp, struct fc_fcp_pkt *fsp,
 		       fc_host_port_id(rp->local_port->host), FC_TYPE_FCP,
 		       FC_FC_FIRST_SEQ | FC_FC_END_SEQ | FC_FC_SEQ_INIT, 0);
 
-	seq = lp->tt.exch_seq_send(lp, fp, resp, fc_fcp_pkt_destroy, fsp, 0);
+	ep = lp->tt.exch_get(lp, fp);
+	if (!ep) {
+		fc_frame_free(fp);
+		goto unlock;
+		rc = -1;
+	}
+
+	if ((fsp->req_flags & FC_SRB_READ) &&
+	    (lp->lro_enabled) && (lp->tt.ddp_setup)) {
+		if (lp->tt.ddp_setup(lp, ep->xid, scsi_sglist(fsp->cmd),
+				     scsi_sg_count(fsp->cmd)))
+			fsp->xfer_ddp = ep->xid;
+	}
+
+	seq = lp->tt.exch_send(lp, ep, fp, resp, fc_fcp_pkt_destroy, fsp, 0);
 	if (!seq) {
 		fc_frame_free(fp);
 		rc = -1;
@@ -1736,6 +1762,13 @@ static void fc_io_compl(struct fc_fcp_pkt *fsp)
 	struct fc_lport *lp;
 	unsigned long flags;
 
+	/* release outstanding ddp context */
+	lp = fsp->lp;
+	if (fsp->xfer_ddp && lp->tt.ddp_done) {
+		lp->tt.ddp_done(lp, fsp->xfer_ddp);
+		fsp->xfer_ddp = 0;
+	}
+
 	fsp->state |= FC_SRB_COMPL;
 	if (!(fsp->state & FC_SRB_FCP_PROCESSING_TMO)) {
 		spin_unlock_bh(&fsp->scsi_pkt_lock);
@@ -1743,7 +1776,6 @@ static void fc_io_compl(struct fc_fcp_pkt *fsp)
 		spin_lock_bh(&fsp->scsi_pkt_lock);
 	}
 
-	lp = fsp->lp;
 	si = fc_get_scsi_internal(lp);
 	spin_lock_irqsave(lp->host->host_lock, flags);
 	if (!fsp->cmd) {
diff --git a/include/scsi/libfc.h b/include/scsi/libfc.h
index a4c6050..c7fc122 100644
--- a/include/scsi/libfc.h
+++ b/include/scsi/libfc.h
@@ -274,6 +274,7 @@ struct fc_fcp_pkt {
 	 */
 	struct fcp_cmnd cdb_cmd;
 	size_t		xfer_len;
+	u16		xfer_ddp;	/* this xfer is ddped */
 	u32		xfer_contig_end; /* offset of end of contiguous xfer */
 	u16		max_payload;	/* max payload size in bytes */
 
@@ -429,6 +430,37 @@ struct libfc_function_template {
 					void *arg, unsigned int timer_msec);
 
 	/*
+	 * This does the same job like exch_seq_send() except that the caller
+	 * must allocate the exchange itself and pass it to exch_send()
+	 *
+	 * STATUS: OPTIONAL
+	 */
+	struct fc_seq *(*exch_send)(struct fc_lport *lp,
+				    struct fc_exch *ep,
+				    struct fc_frame *fp,
+				    void (*resp)(struct fc_seq *sp,
+						 struct fc_frame *fp,
+						 void *arg),
+				    void (*destructor)(struct fc_seq *sp,
+						       void *arg),
+				    void *arg, unsigned int timer_msec);
+
+	/*
+	 * Sets up the DDP context for a given exchange id on the given
+	 * scatterlist if LLD supports DDP for large receive.
+	 *
+	 * STATUS: OPTIONAL
+	 */
+	int (*ddp_setup)(struct fc_lport *lp, u16 xid,
+			 struct scatterlist *sgl, unsigned int sgc);
+	/*
+	 * Completes the DDP transfer and returns the length of data DDPed
+	 * for the given exchange id.
+	 *
+	 * STATUS: OPTIONAL
+	 */
+	int (*ddp_done)(struct fc_lport *lp, u16 xid);
+	/*
 	 * Send a frame using an existing sequence and exchange.
 	 *
 	 * STATUS: OPTIONAL
@@ -917,6 +949,20 @@ struct fc_seq *fc_exch_seq_send(struct fc_lport *lp,
 				void (*destructor)(struct fc_seq *sp,
 						   void *arg),
 				void *arg, u32 timer_msec);
+/*
+ * This function is for exch_send function pointer in
+ * struct libfc_function_template, see comment block on
+ * exch_send for description of this function.
+ */
+struct fc_seq *fc_exch_send(struct fc_lport *lp,
+			    struct fc_exch *ep,
+			    struct fc_frame *fp,
+			    void (*resp)(struct fc_seq *sp,
+					 struct fc_frame *fp,
+					 void *arg),
+			    void (*destructor)(struct fc_seq *sp,
+					       void *arg),
+			    void *arg, u32 timer_msec);
 
 /*
  * send a frame using existing sequence and exchange.

