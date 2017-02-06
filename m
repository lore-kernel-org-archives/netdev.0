From: Hannes Reinecke <hare-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH V3 2/2] qedf: Add QLogic FastLinQ offload
 FCoE driver framework.
Date: Mon, 6 Feb 2017 16:56:42 +0100
Message-ID: <fc01015d-7f49-40a9-4fe8-bdd300fcb514@suse.de>
References: <1486149429-30095-1-git-send-email-chad.dupuis@cavium.com>
 <1486149429-30095-3-git-send-email-chad.dupuis@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 QLogic-Storage-Upstream-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 yuval.mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
To: "Dupuis, Chad" <chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
In-Reply-To: <1486149429-30095-3-git-send-email-chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://lists.open-fcoe.org/mailman/options/fcoe-devel>,
 <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-fcoe.org/pipermail/fcoe-devel/>
List-Post: <mailto:fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <http://lists.open-fcoe.org/mailman/listinfo/fcoe-devel>,
 <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Errors-To: fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Sender: "fcoe-devel" <fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 02/03/2017 08:17 PM, Dupuis, Chad wrote:
> From: "Dupuis, Chad" <chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> =

> The QLogic FastLinQ Driver for FCoE (qedf) is the FCoE specific module fo=
r 41000
> Series Converged Network Adapters by QLogic. This patch consists of follo=
wing
> changes:
> =

> - MAINTAINERS Makefile and Kconfig changes for qedf
> - PCI driver registration
> - libfc/fcoe host level initialization
> - SCSI host template initialization and callbacks
> - Debugfs and log level infrastructure
> - Link handling
> - Firmware interface structures
> - QED core module initialization
> - Light L2 interface callbacks
> - I/O request initialization
> - Firmware I/O completion handling
> - Firmware ELS request/response handling
> - FIP request/response handled by the driver itself
> =

> Signed-off-by: Nilesh Javali <nilesh.javali-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Manish Rangankar <manish.rangankar-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Saurav Kashyap <saurav.kashyap-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Arun Easi <arun.easi-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Chad Dupuis <chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> ---
[ .. ]
> +static void qedf_process_l2_frame_compl(struct qedf_rport *fcport,
> +					unsigned char *buf,
> +					u32 frame_len, u16 l2_oxid)
> +{
> +	struct fc_lport *lport =3D fcport->qedf->lport;
> +	struct fc_frame_header *fh;
> +	struct fc_frame *fp;
> +	u32 payload_len;
> +	u32 crc;
> +
> +	payload_len =3D frame_len - sizeof(struct fc_frame_header);
> +
> +	fp =3D fc_frame_alloc(lport, payload_len);
> +	if (!fp) {
> +		QEDF_ERR(&(fcport->qedf->dbg_ctx),
> +		    "fc_frame_alloc failure.\n");
> +		return;
> +	}
> +
> +	/* Copy FC Frame header and payload into the frame */
> +	fh =3D (struct fc_frame_header *)fc_frame_header_get(fp);
> +	memcpy(fh, buf, frame_len);
> +
> +	/* Set the OXID we return to what libfc used */
> +	if (l2_oxid !=3D FC_XID_UNKNOWN)
> +		fh->fh_ox_id =3D htons(l2_oxid);
> +
> +	/* Setup header fields */
> +	fh->fh_r_ctl =3D FC_RCTL_ELS_REP;
> +	fh->fh_type =3D FC_TYPE_ELS;
> +	/* Last sequence, end sequence */
> +	fh->fh_f_ctl[0] =3D 0x98;
> +	hton24(fh->fh_d_id, lport->port_id);
> +	hton24(fh->fh_s_id, fcport->rdata->ids.port_id);
> +	fh->fh_rx_id =3D 0xffff;
> +
> +	/* Set frame attributes */
> +	crc =3D fcoe_fc_crc(fp);
> +	fc_frame_init(fp);
> +	fr_dev(fp) =3D lport;
> +	fr_sof(fp) =3D FC_SOF_I3;
> +	fr_eof(fp) =3D FC_EOF_T;
> +	fr_crc(fp) =3D cpu_to_le32(~crc);
> +
> +	/* Send completed request to libfc */
> +	fc_exch_recv(lport, fp);
> +}
> +
> +/*
> + * In instances where an ELS command times out we may need to restart the
> + * rport by logging out and then logging back in.
> + */
> +void qedf_restart_rport(struct qedf_rport *fcport)
> +{
> +	struct fc_lport *lport;
> +	struct fc_rport_priv *rdata;
> +	u32 port_id;
> +
> +	if (!fcport)
> +		return;
> +
> +	rdata =3D fcport->rdata;
> +	if (rdata) {
> +		lport =3D fcport->qedf->lport;
> +		port_id =3D rdata->ids.port_id;
> +		QEDF_ERR(&(fcport->qedf->dbg_ctx),
> +		    "LOGO port_id=3D%x.\n", port_id);
> +		fc_rport_logoff(rdata);
> +		/* Recreate the rport and log back in */
> +		rdata =3D fc_rport_create(lport, port_id);
> +		if (rdata)
> +			fc_rport_login(rdata);
> +	}
> +}
> +
> +static void qedf_l2_els_compl(struct qedf_els_cb_arg *cb_arg)
> +{
> +	struct qedf_ioreq *els_req;
> +	struct qedf_rport *fcport;
> +	struct qedf_mp_req *mp_req;
> +	struct fc_frame_header *fc_hdr;
> +	unsigned char *buf;
> +	void *resp_buf;
> +	u32 resp_len, hdr_len;
> +	u16 l2_oxid;
> +	int frame_len;
> +
> +	l2_oxid =3D cb_arg->l2_oxid;
> +	els_req =3D cb_arg->io_req;
> +
> +	if (!els_req) {
> +		QEDF_ERR(NULL, "els_req is NULL.\n");
> +		goto free_arg;
> +	}
> +
> +	/*
> +	 * If we are flushing the command just free the cb_arg as none of the
> +	 * response data will be valid.
> +	 */
> +	if (els_req->event =3D=3D QEDF_IOREQ_EV_ELS_FLUSH)
> +		goto free_arg;
> +
> +	fcport =3D els_req->fcport;
> +	mp_req =3D &(els_req->mp_req);
> +	fc_hdr =3D &(mp_req->resp_fc_hdr);
> +	resp_len =3D mp_req->resp_len;
> +	resp_buf =3D mp_req->resp_buf;
> +
> +	/*
> +	 * If a middle path ELS command times out, don't try to return
> +	 * the command but rather do any internal cleanup and then libfc
> +	 * timeout the command and clean up its internal resources.
> +	 */
> +	if (els_req->event =3D=3D QEDF_IOREQ_EV_ELS_TMO) {
> +		/*
> +		 * If ADISC times out, libfc will timeout the exchange and then
> +		 * try to send a PLOGI which will timeout since the session is
> +		 * still offloaded.  Force libfc to logout the session which
> +		 * will offload the connection and allow the PLOGI response to
> +		 * flow over the LL2 path.
> +		 */
> +		if (cb_arg->op =3D=3D ELS_ADISC)
> +			qedf_restart_rport(fcport);
> +		return;
> +	}
> +
> +	buf =3D kzalloc(QEDF_PAGE_SIZE, GFP_ATOMIC);
> +	if (!buf) {
> +		QEDF_ERR(&(fcport->qedf->dbg_ctx),
> +		    "Unable to alloc mp buf.\n");
> +		goto free_arg;
> +	}
> +	hdr_len =3D sizeof(*fc_hdr);
> +	if (hdr_len + resp_len > QEDF_PAGE_SIZE) {
> +		QEDF_ERR(&(fcport->qedf->dbg_ctx), "resp_len is "
> +		   "beyond page size.\n");
> +		goto free_buf;
> +	}
> +	memcpy(buf, fc_hdr, hdr_len);
> +	memcpy(buf + hdr_len, resp_buf, resp_len);
> +	frame_len =3D hdr_len + resp_len;
> +
> +	QEDF_INFO(&(fcport->qedf->dbg_ctx), QEDF_LOG_ELS,
> +	    "Completing OX_ID 0x%x back to libfc.\n", l2_oxid);
> +	qedf_process_l2_frame_compl(fcport, buf, frame_len, l2_oxid);
> +
> +free_buf:
> +	kfree(buf);
> +free_arg:
> +	kfree(cb_arg);
> +}
> +
That looks a bit convoluted; you're allocating a buffer, copying the
frame header and the response into it, and then call 'XX_frame_compl()'
which has to extract the buffer again and discard the response.
Why not pass in the frame header directly?

> +int qedf_send_adisc(struct qedf_rport *fcport, struct fc_frame *fp)
> +{
> +	struct fc_els_adisc *adisc;
> +	struct fc_frame_header *fh;
> +	struct fc_lport *lport =3D fcport->qedf->lport;
> +	struct qedf_els_cb_arg *cb_arg =3D NULL;
> +	struct qedf_ctx *qedf;
> +	uint32_t r_a_tov =3D lport->r_a_tov;
> +	int rc;
> +
> +	qedf =3D fcport->qedf;
> +	fh =3D fc_frame_header_get(fp);
> +
> +	cb_arg =3D kzalloc(sizeof(struct qedf_els_cb_arg), GFP_NOIO);
> +	if (!cb_arg) {
> +		QEDF_ERR(&(qedf->dbg_ctx), "Unable to allocate cb_arg for "
> +			  "ADISC\n");
> +		rc =3D -ENOMEM;
> +		goto adisc_err;
> +	}
> +	cb_arg->l2_oxid =3D ntohs(fh->fh_ox_id);
> +
> +	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS,
> +	    "Sending ADISC ox_id=3D0x%x.\n", cb_arg->l2_oxid);
> +
> +	adisc =3D fc_frame_payload_get(fp, sizeof(*adisc));
> +
> +	rc =3D qedf_initiate_els(fcport, ELS_ADISC, adisc, sizeof(*adisc),
> +	    qedf_l2_els_compl, cb_arg, r_a_tov);
> +
> +adisc_err:
> +	if (rc) {
> +		QEDF_ERR(&(qedf->dbg_ctx), "ADISC failed.\n");
> +		kfree(cb_arg);
> +	}
> +	return rc;
> +}
> +
> +static void qedf_srr_compl(struct qedf_els_cb_arg *cb_arg)
> +{
> +	struct qedf_ioreq *orig_io_req;
> +	struct qedf_ioreq *srr_req;
> +	struct qedf_mp_req *mp_req;
> +	struct fc_frame_header *fc_hdr, *fh;
> +	struct fc_frame *fp;
> +	unsigned char *buf;
> +	void *resp_buf;
> +	u32 resp_len, hdr_len;
> +	struct fc_lport *lport;
> +	struct qedf_ctx *qedf;
> +	int refcount;
> +	u8 opcode;
> +
> +	srr_req =3D cb_arg->io_req;
> +	qedf =3D srr_req->fcport->qedf;
> +	lport =3D qedf->lport;
> +
> +	orig_io_req =3D cb_arg->aborted_io_req;
> +
> +	if (!orig_io_req)
> +		goto out_free;
> +
> +	clear_bit(QEDF_CMD_SRR_SENT, &orig_io_req->flags);
> +
> +	if (srr_req->event !=3D QEDF_IOREQ_EV_ELS_TMO &&
> +	    srr_req->event !=3D QEDF_IOREQ_EV_ELS_ERR_DETECT)
> +		cancel_delayed_work_sync(&orig_io_req->timeout_work);
> +
> +	refcount =3D atomic_read(&orig_io_req->refcount.refcount);
> +	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS, "Entered: orig_io=3D%p,"
> +		   " orig_io_xid=3D0x%x, rec_xid=3D0x%x, refcount=3D%d\n",
> +		   orig_io_req, orig_io_req->xid, srr_req->xid, refcount);
> +
> +	/* If a SRR times out, simply free resources */
> +	if (srr_req->event =3D=3D QEDF_IOREQ_EV_ELS_TMO)
> +		goto out_free;
> +
> +	/* Normalize response data into struct fc_frame */
> +	mp_req =3D &(srr_req->mp_req);
> +	fc_hdr =3D &(mp_req->resp_fc_hdr);
> +	resp_len =3D mp_req->resp_len;
> +	resp_buf =3D mp_req->resp_buf;
> +	hdr_len =3D sizeof(*fc_hdr);
> +
> +	buf =3D kzalloc(QEDF_PAGE_SIZE, GFP_ATOMIC);
> +	if (!buf) {
> +		QEDF_ERR(&(qedf->dbg_ctx),
> +		    "Unable to alloc mp buf.\n");
> +		goto out_free;
> +	}
> +
> +	memcpy(buf, fc_hdr, hdr_len);
> +	memcpy(buf + hdr_len, resp_buf, resp_len);
> +
> +	fp =3D fc_frame_alloc(lport, resp_len);
> +	if (!fp) {
> +		QEDF_ERR(&(qedf->dbg_ctx),
> +		    "fc_frame_alloc failure.\n");
> +		goto out_buf;
> +	}
> +
> +	/* Copy FC Frame header and payload into the frame */
> +	fh =3D (struct fc_frame_header *)fc_frame_header_get(fp);
> +	memcpy(fh, buf, hdr_len + resp_len);
> +
Same here: why do you allocate a buffer, just so that you can copy
things out of the buffer again?

[ .. ]
> +static void qedf_rec_compl(struct qedf_els_cb_arg *cb_arg)
> +{
> +	struct qedf_ioreq *orig_io_req;
> +	struct qedf_ioreq *rec_req;
> +	struct qedf_mp_req *mp_req;
> +	struct fc_frame_header *fc_hdr, *fh;
> +	struct fc_frame *fp;
> +	unsigned char *buf;
> +	void *resp_buf;
> +	u32 resp_len, hdr_len;
> +	struct fc_lport *lport;
> +	struct qedf_ctx *qedf;
> +	int refcount;
> +	enum fc_rctl r_ctl;
> +	struct fc_els_ls_rjt *rjt;
> +	struct fc_els_rec_acc *acc;
> +	u8 opcode;
> +	u32 offset, e_stat;
> +	struct scsi_cmnd *sc_cmd;
> +	bool srr_needed =3D false;
> +
> +	rec_req =3D cb_arg->io_req;
> +	qedf =3D rec_req->fcport->qedf;
> +	lport =3D qedf->lport;
> +
> +	orig_io_req =3D cb_arg->aborted_io_req;
> +
> +	if (!orig_io_req)
> +		goto out_free;
> +
> +	if (rec_req->event !=3D QEDF_IOREQ_EV_ELS_TMO &&
> +	    rec_req->event !=3D QEDF_IOREQ_EV_ELS_ERR_DETECT)
> +		cancel_delayed_work_sync(&orig_io_req->timeout_work);
> +
> +	refcount =3D atomic_read(&orig_io_req->refcount.refcount);
> +	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS, "Entered: orig_io=3D%p,"
> +		   " orig_io_xid=3D0x%x, rec_xid=3D0x%x, refcount=3D%d\n",
> +		   orig_io_req, orig_io_req->xid, rec_req->xid, refcount);
> +
> +	/* If a REC times out, free resources */
> +	if (rec_req->event =3D=3D QEDF_IOREQ_EV_ELS_TMO)
> +		goto out_free;
> +
> +	/* Normalize response data into struct fc_frame */
> +	mp_req =3D &(rec_req->mp_req);
> +	fc_hdr =3D &(mp_req->resp_fc_hdr);
> +	resp_len =3D mp_req->resp_len;
> +	acc =3D resp_buf =3D mp_req->resp_buf;
> +	hdr_len =3D sizeof(*fc_hdr);
> +
> +	buf =3D kzalloc(QEDF_PAGE_SIZE, GFP_ATOMIC);
> +	if (!buf) {
> +		QEDF_ERR(&(qedf->dbg_ctx),
> +		    "Unable to alloc mp buf.\n");
> +		goto out_free;
> +	}
> +
> +	memcpy(buf, fc_hdr, hdr_len);
> +	memcpy(buf + hdr_len, resp_buf, resp_len);
> +
> +	fp =3D fc_frame_alloc(lport, resp_len);
> +	if (!fp) {
> +		QEDF_ERR(&(qedf->dbg_ctx),
> +		    "fc_frame_alloc failure.\n");
> +		goto out_buf;
> +	}
> +
> +	/* Copy FC Frame header and payload into the frame */
> +	fh =3D (struct fc_frame_header *)fc_frame_header_get(fp);
> +	memcpy(fh, buf, hdr_len + resp_len);
> +
Again, same story.

Cheers,

Hannes
-- =

Dr. Hannes Reinecke		   Teamlead Storage & Networking
hare-l3A5Bk7waGM@public.gmane.org			               +49 911 74053 688
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 N=FCrnberg
GF: F. Imend=F6rffer, J. Smithard, J. Guild, D. Upmanyu, G. Norton
HRB 21284 (AG N=FCrnberg)
