From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 09/11] libfc: add support of large receive offload by ddp in
	fc_fcp
Date: Fri, 27 Feb 2009 14:07:21 -0800
Message-ID: <20090227220721.4987.31988.stgit.yi.zou@intel.com>
References: <20090227220034.4987.50755.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: yi.zou@intel.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:27097 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758855AbZB0XO5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2009 18:14:57 -0500
In-Reply-To: <20090227220034.4987.50755.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When LLD supports direct data placement (ddp) for large receive of an scsi
i/o coming into fc_fcp, we call into libfc_function_template's ddp_setup()
to prepare for a ddp of large receive for this read I/O. When I/O is complete,
we call the corresponding ddp_done() to get the length of data ddped as well
as to let LLD do clean up.

fc_fcp_ddp_setup()/fc_fcp_ddp_done() are added to setup and complete a ddped
read I/O described by the given fc_fcp_pkt. They would call into corresponding
ddp_setup/ddp_done implemented by the fcoe layer. Eventually, fcoe layer calls
into LLD's ddp_setup/ddp_done provided through net_device

Signed-off-by: Yi Zou <yi.zou@intel.com>
---

 drivers/scsi/libfc/fc_exch.c |    4 ++-
 drivers/scsi/libfc/fc_fcp.c  |   61 +++++++++++++++++++++++++++++++++++++++++-
 include/scsi/fc_frame.h      |   19 +------------
 include/scsi/libfc.h         |   30 +++++++++++++++++++++
 include/scsi/libfcoe.h       |   18 ------------
 5 files changed, 95 insertions(+), 37 deletions(-)

diff --git a/drivers/scsi/libfc/fc_exch.c b/drivers/scsi/libfc/fc_exch.c
index 505825b..d9d01e7 100644
--- a/drivers/scsi/libfc/fc_exch.c
+++ b/drivers/scsi/libfc/fc_exch.c
@@ -489,7 +489,7 @@ static u16 fc_em_alloc_xid(struct fc_exch_mgr *mp, const struct fc_frame *fp)
 	struct fc_exch *ep = NULL;
 
 	if (mp->max_read) {
-		if (fc_frame_is_read(fp)) {
+		if (fc_fcp_is_read(fr_fsp(fp))) {
 			min = mp->min_xid;
 			max = mp->max_read;
 			plast = &mp->last_read;
@@ -1841,6 +1841,8 @@ struct fc_seq *fc_exch_seq_send(struct fc_lport *lp,
 	fc_exch_setup_hdr(ep, fp, ep->f_ctl);
 	sp->cnt++;
 
+	fc_fcp_ddp_setup(fr_fsp(fp), ep->xid);
+
 	if (unlikely(lp->tt.frame_send(lp, fp)))
 		goto err;
 
diff --git a/drivers/scsi/libfc/fc_fcp.c b/drivers/scsi/libfc/fc_fcp.c
index 80e8491..379d299 100644
--- a/drivers/scsi/libfc/fc_fcp.c
+++ b/drivers/scsi/libfc/fc_fcp.c
@@ -265,6 +265,56 @@ static void fc_fcp_retry_cmd(struct fc_fcp_pkt *fsp)
 }
 
 /*
+ * fc_fcp_ddp_setup - calls to LLD's ddp_setup to set up DDP
+ * transfer for a read I/O indicated by the fc_fcp_pkt.
+ * @fsp: ptr to the fc_fcp_pkt
+ *
+ * This is called in exch_seq_send() when we have a newly allocated
+ * exchange with a valid exchange id to setup ddp.
+ *
+ * returns: none
+ */
+void fc_fcp_ddp_setup(struct fc_fcp_pkt *fsp, u16 xid)
+{
+	struct fc_lport *lp;
+
+	if (!fsp)
+		return;
+
+	lp = fsp->lp;
+	if ((fsp->req_flags & FC_SRB_READ) &&
+	    (lp->lro_enabled) && (lp->tt.ddp_setup)) {
+		if (lp->tt.ddp_setup(lp, xid, scsi_sglist(fsp->cmd),
+				     scsi_sg_count(fsp->cmd)))
+			fsp->xfer_ddp = xid;
+	}
+}
+EXPORT_SYMBOL(fc_fcp_ddp_setup);
+
+/*
+ * fc_fcp_ddp_done - calls to LLD's ddp_done to release any
+ * DDP related resources for this I/O if it is initialized
+ * as a ddp transfer
+ * @fsp: ptr to the fc_fcp_pkt
+ *
+ * returns: none
+ */
+static void fc_fcp_ddp_done(struct fc_fcp_pkt *fsp)
+{
+	struct fc_lport *lp;
+
+	if (!fsp)
+		return;
+
+	lp = fsp->lp;
+	if (fsp->xfer_ddp && lp->tt.ddp_done) {
+		fsp->xfer_len = lp->tt.ddp_done(lp, fsp->xfer_ddp);
+		fsp->xfer_ddp = 0;
+	}
+}
+
+
+/*
  * Receive SCSI data from target.
  * Called after receiving solicited data.
  */
@@ -289,6 +339,9 @@ static void fc_fcp_recv_data(struct fc_fcp_pkt *fsp, struct fc_frame *fp)
 	len = fr_len(fp) - sizeof(*fh);
 	buf = fc_frame_payload_get(fp, 0);
 
+	/* if this I/O is ddped, update xfer len */
+	fc_fcp_ddp_done(fsp);
+
 	if (offset + len > fsp->data_len) {
 		/* this should never happen */
 		if ((fr_flags(fp) & FCPHF_CRC_UNCHECKED) &&
@@ -750,6 +803,9 @@ static void fc_fcp_resp(struct fc_fcp_pkt *fsp, struct fc_frame *fp)
 	fsp->scsi_comp_flags = flags;
 	expected_len = fsp->data_len;
 
+	/* if ddp, update xfer len */
+	fc_fcp_ddp_done(fsp);
+
 	if (unlikely((flags & ~FCP_CONF_REQ) || fc_rp->fr_status)) {
 		rp_ex = (void *)(fc_rp + 1);
 		if (flags & (FCP_RSP_LEN_VAL | FCP_SNS_LEN_VAL)) {
@@ -1012,7 +1068,7 @@ static int fc_fcp_cmd_send(struct fc_lport *lp, struct fc_fcp_pkt *fsp,
 	}
 
 	memcpy(fc_frame_payload_get(fp, len), &fsp->cdb_cmd, len);
-	fr_cmd(fp) = fsp->cmd;
+	fr_fsp(fp) = fsp;
 	rport = fsp->rport;
 	fsp->max_payload = rport->maxframe_size;
 	rp = rport->dd_data;
@@ -1746,6 +1802,9 @@ static void fc_io_compl(struct fc_fcp_pkt *fsp)
 	struct fc_lport *lp;
 	unsigned long flags;
 
+	/* release outstanding ddp context */
+	fc_fcp_ddp_done(fsp);
+
 	fsp->state |= FC_SRB_COMPL;
 	if (!(fsp->state & FC_SRB_FCP_PROCESSING_TMO)) {
 		spin_unlock_bh(&fsp->scsi_pkt_lock);
diff --git a/include/scsi/fc_frame.h b/include/scsi/fc_frame.h
index 04d34a7..5951105 100644
--- a/include/scsi/fc_frame.h
+++ b/include/scsi/fc_frame.h
@@ -54,8 +54,7 @@
 #define fr_eof(fp)	(fr_cb(fp)->fr_eof)
 #define fr_flags(fp)	(fr_cb(fp)->fr_flags)
 #define fr_max_payload(fp)	(fr_cb(fp)->fr_max_payload)
-#define fr_cmd(fp)	(fr_cb(fp)->fr_cmd)
-#define fr_dir(fp)	(fr_cmd(fp)->sc_data_direction)
+#define fr_fsp(fp)	(fr_cb(fp)->fr_fsp)
 #define fr_crc(fp)	(fr_cb(fp)->fr_crc)
 
 struct fc_frame {
@@ -66,7 +65,7 @@ struct fcoe_rcv_info {
 	struct packet_type  *ptype;
 	struct fc_lport	*fr_dev;	/* transport layer private pointer */
 	struct fc_seq	*fr_seq;	/* for use with exchange manager */
-	struct scsi_cmnd *fr_cmd;	/* for use of scsi command */
+	struct fc_fcp_pkt *fr_fsp;	/* for the corresponding fcp I/O */
 	u32		fr_crc;
 	u16		fr_max_payload;	/* max FC payload */
 	enum fc_sof	fr_sof;		/* start of frame delimiter */
@@ -218,20 +217,6 @@ static inline bool fc_frame_is_cmd(const struct fc_frame *fp)
 	return fc_frame_rctl(fp) == FC_RCTL_DD_UNSOL_CMD;
 }
 
-static inline bool fc_frame_is_read(const struct fc_frame *fp)
-{
-	if (fc_frame_is_cmd(fp) && fr_cmd(fp))
-		return fr_dir(fp) == DMA_FROM_DEVICE;
-	return false;
-}
-
-static inline bool fc_frame_is_write(const struct fc_frame *fp)
-{
-	if (fc_frame_is_cmd(fp) && fr_cmd(fp))
-		return fr_dir(fp) == DMA_TO_DEVICE;
-	return false;
-}
-
 /*
  * Check for leaks.
  * Print the frame header of any currently allocated frame, assuming there
diff --git a/include/scsi/libfc.h b/include/scsi/libfc.h
index 61c746c..a70eafa 100644
--- a/include/scsi/libfc.h
+++ b/include/scsi/libfc.h
@@ -245,6 +245,7 @@ struct fc_fcp_pkt {
 	 */
 	struct fcp_cmnd cdb_cmd;
 	size_t		xfer_len;
+	u16		xfer_ddp;	/* this xfer is ddped */
 	u32		xfer_contig_end; /* offset of end of contiguous xfer */
 	u16		max_payload;	/* max payload size in bytes */
 
@@ -267,6 +268,15 @@ struct fc_fcp_pkt {
 	u8		recov_retry;	/* count of recovery retries */
 	struct fc_seq	*recov_seq;	/* sequence for REC or SRR */
 };
+/*
+ * FC_FCP HELPER FUNCTIONS
+ *****************************/
+static inline bool fc_fcp_is_read(const struct fc_fcp_pkt *fsp)
+{
+	if (fsp && fsp->cmd)
+		return fsp->cmd->sc_data_direction == DMA_FROM_DEVICE;
+	return false;
+}
 
 /*
  * Structure and function definitions for managing Fibre Channel Exchanges
@@ -400,6 +410,21 @@ struct libfc_function_template {
 					void *arg, unsigned int timer_msec);
 
 	/*
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
@@ -822,6 +847,11 @@ int fc_change_queue_type(struct scsi_device *sdev, int tag_type);
 void fc_fcp_destroy(struct fc_lport *);
 
 /*
+ * Set up direct-data placement for this I/O request
+ */
+void fc_fcp_ddp_setup(struct fc_fcp_pkt *fsp, u16 xid);
+
+/*
  * ELS/CT interface
  *****************************/
 /*
diff --git a/include/scsi/libfcoe.h b/include/scsi/libfcoe.h
index 941818f..c41f7d0 100644
--- a/include/scsi/libfcoe.h
+++ b/include/scsi/libfcoe.h
@@ -124,24 +124,6 @@ static inline u16 skb_fc_rxid(const struct sk_buff *skb)
 	return be16_to_cpu(skb_fc_header(skb)->fh_rx_id);
 }
 
-/* FIXME - DMA_BIDIRECTIONAL ? */
-#define skb_cb(skb)	((struct fcoe_rcv_info *)&((skb)->cb[0]))
-#define skb_cmd(skb)	(skb_cb(skb)->fr_cmd)
-#define skb_dir(skb)	(skb_cmd(skb)->sc_data_direction)
-static inline bool skb_fc_is_read(const struct sk_buff *skb)
-{
-	if (skb_fc_is_cmd(skb) && skb_cmd(skb))
-		return skb_dir(skb) == DMA_FROM_DEVICE;
-	return false;
-}
-
-static inline bool skb_fc_is_write(const struct sk_buff *skb)
-{
-	if (skb_fc_is_cmd(skb) && skb_cmd(skb))
-		return skb_dir(skb) == DMA_TO_DEVICE;
-	return false;
-}
-
 /* libfcoe funcs */
 int fcoe_reset(struct Scsi_Host *shost);
 u64 fcoe_wwn_from_mac(unsigned char mac[MAX_ADDR_LEN],

