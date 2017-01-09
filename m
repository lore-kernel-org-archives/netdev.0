From: Chad Dupuis <chad.dupuis@cavium.com>
Subject: Re: [Open-FCoE] [PATCH RFC 2/5] qedf: Add QLogic FastLinQ offload
 FCoE driver framework.
Date: Mon, 9 Jan 2017 11:45:40 -0500
Message-ID: <alpine.OSX.2.00.1701091141550.1044@administrators-macbook-pro.local>
References: <1482520628-24207-1-git-send-email-chad.dupuis@cavium.com> <1482520628-24207-3-git-send-email-chad.dupuis@cavium.com> <7df11d77-df7b-af58-2646-e92cdbba2146@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: <martin.petersen@oracle.com>, <fcoe-devel@open-fcoe.org>,
        <netdev@vger.kernel.org>, <QLogic-Storage-Upstream@cavium.com>,
        <linux-scsi@vger.kernel.org>, <yuval.mintz@cavium.com>
To: Hannes Reinecke <hare@suse.de>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <7df11d77-df7b-af58-2646-e92cdbba2146@suse.de>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 28 Dec 2016, 9:00am -0000, Hannes Reinecke wrote:

> On 12/23/2016 08:17 PM, Dupuis, Chad wrote:
> > From: "Dupuis, Chad" <chad.dupuis@cavium.com>
> > 
> > The QLogic FastLinQ Driver for FCoE (qedf) is the FCoE specific module
> > for 41000 Series Converged Network Adapters by QLogic.
> > 
> > This patch consists of following changes:
> >   - MAINTAINERS Makefile and Kconfig changes for qedf
> >   - PCI driver registration
> >   - libfc/fcoe host level initialization
> >   - SCSI host template initialization and callbacks
> >   - Debugfs and log level infrastructure
> >   - Link handling
> >   - Firmware interface structures
> >   - QED core module initialization
> >   - Light L2 interface callbacks
> > 
> > Signed-off-by: Nilesh Javali <nilesh.javali@cavium.com>
> > Signed-off-by: Manish Rangankar <manish.rangankar@cavium.com>
> > Signed-off-by: Saurav Kashyap <saurav.kashyap@cavium.com>
> > Signed-off-by: Chad Dupuis <chad.dupuis@cavium.com>
> > ---
> >  MAINTAINERS                      |    6 +
> >  drivers/scsi/Kconfig             |    1 +
> >  drivers/scsi/qedf/Kconfig        |   11 +
> >  drivers/scsi/qedf/Makefile       |    5 +
> >  drivers/scsi/qedf/qedf.h         |  555 ++++++
> >  drivers/scsi/qedf/qedf_attr.c    |  165 ++
> >  drivers/scsi/qedf/qedf_dbg.c     |  192 +++
> >  drivers/scsi/qedf/qedf_dbg.h     |  153 ++
> >  drivers/scsi/qedf/qedf_debugfs.c |  472 +++++
> >  drivers/scsi/qedf/qedf_main.c    | 3519 ++++++++++++++++++++++++++++++++++++++
> >  drivers/scsi/qedf/qedf_version.h |   15 +
> >  11 files changed, 5094 insertions(+)
> >  create mode 100644 drivers/scsi/qedf/Kconfig
> >  create mode 100644 drivers/scsi/qedf/Makefile
> >  create mode 100644 drivers/scsi/qedf/qedf.h
> >  create mode 100644 drivers/scsi/qedf/qedf_attr.c
> >  create mode 100644 drivers/scsi/qedf/qedf_dbg.c
> >  create mode 100644 drivers/scsi/qedf/qedf_dbg.h
> >  create mode 100644 drivers/scsi/qedf/qedf_debugfs.c
> >  create mode 100644 drivers/scsi/qedf/qedf_main.c
> >  create mode 100644 drivers/scsi/qedf/qedf_version.h
> > 
> [ .. ]
> > +/* Returns true if we have a valid vlan, false otherwise */
> > +static bool qedf_initiate_fipvlan_req(struct qedf_ctx *qedf)
> > +{
> > +	int rc;
> > +
> > +	if (atomic_read(&qedf->link_state) != QEDF_LINK_UP) {
> > +		QEDF_ERR(&(qedf->dbg_ctx), "Link not up.\n");
> > +		return  false;
> > +	}
> > +
> > +	while (qedf->fipvlan_retries--) {
> > +		if (qedf->vlan_id > 0)
> > +			return true;
> Some weird FCoE bridges (most notably HP VirtualConnect) return a VLAN
> ID of '0'. Shouldn't you rather test for '>= 0' here?

Will look into this but isn't a VLAN ID of 0 not valid?

> 
> [ .. ]
> > +
> > +static void qedf_flogi_resp(struct fc_seq *seq, struct fc_frame *fp,
> > +	void *arg)
> > +{
> > +	struct fc_exch *exch = fc_seq_exch(seq);
> > +	struct fc_lport *lport = exch->lp;
> > +	struct qedf_ctx *qedf = lport_priv(lport);
> > +
> > +	if (!qedf) {
> > +		QEDF_ERR(NULL, "qedf is NULL.\n");
> > +		return;
> > +	}
> > +
> > +	/*
> > +	 * If ERR_PTR is set then don't try to stat anything as it will cause
> > +	 * a crash when we access fp.
> > +	 */
> > +	if (fp == ERR_PTR(-FC_EX_TIMEOUT) ||
> > +	    fp == ERR_PTR(-FC_EX_CLOSED)) {
> > +		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS,
> > +		    "fp has ERR_PTR() set.\n");
> > +		goto skip_stat;
> > +	}
> 
> Please use
> 
> if (IS_ERR(fp)) {
> 
> here instead of checking for individual error codes; if 'fp' has a
> different error value you'll continue with an invalid fp from here on.
>

Will fix up.
 
> [ .. ]
> 
> > +/**
> > + * qedf_xmit - qedf FCoE frame transmit function
> > + *
> > + */
> > +static int qedf_xmit(struct fc_lport *lport, struct fc_frame *fp)
> > +{
> > +	struct fc_lport		*base_lport;
> > +	struct qedf_ctx		*qedf;
> > +	struct ethhdr		*eh;
> > +	struct fcoe_crc_eof	*cp;
> > +	struct sk_buff		*skb;
> > +	struct fc_frame_header	*fh;
> > +	struct fcoe_hdr		*hp;
> > +	u8			sof, eof;
> > +	u32			crc;
> > +	unsigned int		hlen, tlen, elen;
> > +	int			wlen;
> > +	struct fc_stats		*stats;
> > +	struct fc_lport *tmp_lport;
> > +	struct fc_lport *vn_port = NULL;
> > +	struct qedf_rport *fcport;
> > +	int rc;
> > +	u16 vlan_tci = 0;
> > +	unsigned long flags;
> > +
> > +	qedf = (struct qedf_ctx *)lport_priv(lport);
> > +
> > +	fh = fc_frame_header_get(fp);
> > +	skb = fp_skb(fp);
> > +
> > +	/* Filter out traffic to other NPIV ports on the same host */
> > +	if (lport->vport)
> > +		base_lport = shost_priv(vport_to_shost(lport->vport));
> > +	else
> > +		base_lport = lport;
> > +
> > +	/* Flag if the destination is the base port */
> > +	if (base_lport->port_id == ntoh24(fh->fh_d_id)) {
> > +		vn_port = base_lport;
> > +	} else {
> > +		/* Got through the list of vports attached to the base_lport
> > +		 * and see if we have a match with the destination address.
> > +		 */
> > +		list_for_each_entry(tmp_lport, &base_lport->vports, list) {
> > +			if (tmp_lport->port_id == ntoh24(fh->fh_d_id)) {
> > +				vn_port = tmp_lport;
> > +				break;
> > +			}
> > +		}
> > +	}
> > +	if (vn_port && ntoh24(fh->fh_d_id) != FC_FID_FLOGI) {
> > +		struct fc_rport_priv *rdata = NULL;
> > +
> > +		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_LL2,
> > +		    "Dropping FCoE frame to %06x.\n", ntoh24(fh->fh_d_id));
> > +		kfree_skb(skb);
> > +		rdata = fc_rport_lookup(lport, ntoh24(fh->fh_d_id));
> > +		if (rdata)
> > +			rdata->retries = lport->max_rport_retry_count;
> > +		return -EINVAL;
> > +	}
> > +	/* End NPIV filtering */
> > +
> > +	if (!qedf->ctlr.sel_fcf) {
> > +		kfree_skb(skb);
> > +		return 0;
> > +	}
> > +
> > +	if (!test_bit(QEDF_LL2_STARTED, &qedf->flags)) {
> > +		QEDF_WARN(&(qedf->dbg_ctx), "LL2 not started\n");
> > +		kfree_skb(skb);
> > +		return 0;
> > +	}
> > +
> > +	if (atomic_read(&qedf->link_state) != QEDF_LINK_UP) {
> > +		QEDF_WARN(&(qedf->dbg_ctx), "qedf link down\n");
> > +		kfree_skb(skb);
> > +		return 0;
> > +	}
> > +
> > +	if (unlikely(fh->fh_r_ctl == FC_RCTL_ELS_REQ)) {
> > +		if (fcoe_ctlr_els_send(&qedf->ctlr, lport, skb))
> > +			return 0;
> > +	}
> > +
> > +	/* Check to see if this needs to be sent on an offloaded session */
> > +	spin_lock_irqsave(&qedf->hba_lock, flags);
> > +	fcport = qedf_fcport_lookup(qedf, ntoh24(fh->fh_d_id));
> > +	spin_unlock_irqrestore(&qedf->hba_lock, flags);
> > +
> Really sad, having to take a spinlock here to get to the session.
> Can't you use RCU for rport lookup?
> That would save you the spinlock here ...

Yes, will look into converting this to use RCU

> 
> > +	if (fcport && test_bit(QEDF_RPORT_SESSION_READY, &fcport->flags)) {
> > +		rc = qedf_xmit_l2_frame(fcport, fp);
> > +		/*
> > +		 * If the frame was successfully sent over the middle path
> > +		 * then do not try to also send it over the LL2 path
> > +		 */
> > +		if (rc)
> > +			return 0;
> > +	}
> > +
> > +	sof = fr_sof(fp);
> > +	eof = fr_eof(fp);
> > +
> > +	elen = sizeof(struct ethhdr);
> > +	hlen = sizeof(struct fcoe_hdr);
> > +	tlen = sizeof(struct fcoe_crc_eof);
> > +	wlen = (skb->len - tlen + sizeof(crc)) / FCOE_WORD_TO_BYTE;
> > +
> > +	skb->ip_summed = CHECKSUM_NONE;
> > +	crc = fcoe_fc_crc(fp);
> > +
> > +	/* copy port crc and eof to the skb buff */
> > +	if (skb_is_nonlinear(skb)) {
> > +		skb_frag_t *frag;
> > +
> > +		if (qedf_get_paged_crc_eof(skb, tlen)) {
> > +			kfree_skb(skb);
> > +			return -ENOMEM;
> > +		}
> > +		frag = &skb_shinfo(skb)->frags[skb_shinfo(skb)->nr_frags - 1];
> > +		cp = kmap_atomic(skb_frag_page(frag)) + frag->page_offset;
> > +	} else {
> > +		cp = (struct fcoe_crc_eof *)skb_put(skb, tlen);
> > +	}
> > +
> > +	memset(cp, 0, sizeof(*cp));
> > +	cp->fcoe_eof = eof;
> > +	cp->fcoe_crc32 = cpu_to_le32(~crc);
> > +	if (skb_is_nonlinear(skb)) {
> > +		kunmap_atomic(cp);
> > +		cp = NULL;
> > +	}
> > +
> > +
> > +	/* adjust skb network/transport offsets to match mac/fcoe/port */
> > +	skb_push(skb, elen + hlen);
> > +	skb_reset_mac_header(skb);
> > +	skb_reset_network_header(skb);
> > +	skb->mac_len = elen;
> > +	skb->protocol = htons(ETH_P_FCOE);
> > +
> > +	__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), qedf->vlan_id);
> > +
> > +	/* fill up mac and fcoe headers */
> > +	eh = eth_hdr(skb);
> > +	eh->h_proto = htons(ETH_P_FCOE);
> > +	if (qedf->ctlr.map_dest)
> > +		fc_fcoe_set_mac(eh->h_dest, fh->fh_d_id);
> > +	else
> > +		/* insert GW address */
> > +		ether_addr_copy(eh->h_dest, qedf->ctlr.dest_addr);
> > +
> > +	/* Set the source MAC address */
> > +	fc_fcoe_set_mac(eh->h_source, fh->fh_s_id);
> > +
> > +	hp = (struct fcoe_hdr *)(eh + 1);
> > +	memset(hp, 0, sizeof(*hp));
> > +	if (FC_FCOE_VER)
> > +		FC_FCOE_ENCAPS_VER(hp, FC_FCOE_VER);
> > +	hp->fcoe_sof = sof;
> > +
> > +	/*update tx stats */
> > +	stats = per_cpu_ptr(lport->stats, get_cpu());
> > +	stats->TxFrames++;
> > +	stats->TxWords += wlen;
> > +	put_cpu();
> > +
> > +	/* Get VLAN ID from skb for printing purposes */
> > +	__vlan_hwaccel_get_tag(skb, &vlan_tci);
> > +
> > +	/* send down to lld */
> > +	fr_dev(fp) = lport;
> > +	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_LL2, "FCoE frame send: "
> > +	    "src=%06x dest=%06x r_ctl=%x type=%x vlan=%04x.\n",
> > +	    ntoh24(fh->fh_s_id), ntoh24(fh->fh_d_id), fh->fh_r_ctl, fh->fh_type,
> > +	    vlan_tci);
> > +	if (qedf_dump_frames)
> > +		print_hex_dump(KERN_WARNING, "fcoe: ", DUMP_PREFIX_OFFSET, 16,
> > +		    1, skb->data, skb->len, false);
> > +	qed_ops->ll2->start_xmit(qedf->cdev, skb);
> > +
> > +	return 0;
> > +}
> > +
> > +static int qedf_alloc_sq(struct qedf_ctx *qedf, struct qedf_rport *fcport)
> > +{
> > +	int rval = 0;
> > +	u32 *pbl;
> > +	dma_addr_t page;
> > +	int num_pages;
> > +
> > +	/* Calculate appropriate queue and PBL sizes */
> > +	fcport->sq_mem_size = SQ_NUM_ENTRIES * sizeof(struct fcoe_wqe);
> > +	fcport->sq_mem_size = ALIGN(fcport->sq_mem_size, QEDF_PAGE_SIZE);
> > +	fcport->sq_pbl_size = (fcport->sq_mem_size / QEDF_PAGE_SIZE) *
> > +	    sizeof(void *);
> > +	fcport->sq_pbl_size = fcport->sq_pbl_size + QEDF_PAGE_SIZE;
> > +
> > +	fcport->sq = dma_alloc_coherent(&qedf->pdev->dev, fcport->sq_mem_size,
> > +	    &fcport->sq_dma, GFP_KERNEL);
> > +	if (!fcport->sq) {
> > +		QEDF_WARN(&(qedf->dbg_ctx), "Could not allocate send "
> > +			   "queue.\n");
> > +		rval = 1;
> > +		goto out;
> > +	}
> > +	memset(fcport->sq, 0, fcport->sq_mem_size);
> > +
> > +	fcport->sq_pbl = dma_alloc_coherent(&qedf->pdev->dev,
> > +	    fcport->sq_pbl_size, &fcport->sq_pbl_dma, GFP_KERNEL);
> > +	if (!fcport->sq_pbl) {
> > +		QEDF_WARN(&(qedf->dbg_ctx), "Could not allocate send "
> > +			   "queue PBL.\n");
> > +		rval = 1;
> > +		goto out_free_sq;
> > +	}
> > +	memset(fcport->sq_pbl, 0, fcport->sq_pbl_size);
> > +
> > +	/* Create PBL */
> > +	num_pages = fcport->sq_mem_size / QEDF_PAGE_SIZE;
> > +	page = fcport->sq_dma;
> > +	pbl = (u32 *)fcport->sq_pbl;
> > +
> > +	while (num_pages--) {
> > +		*pbl = U64_LO(page);
> > +		pbl++;
> > +		*pbl = U64_HI(page);
> > +		pbl++;
> > +		page += QEDF_PAGE_SIZE;
> > +	}
> > +
> > +	return rval;
> > +
> > +out_free_sq:
> > +	dma_free_coherent(&qedf->pdev->dev, fcport->sq_mem_size, fcport->sq,
> > +	    fcport->sq_dma);
> > +out:
> > +	return rval;
> > +}
> > +
> > +static void qedf_free_sq(struct qedf_ctx *qedf, struct qedf_rport *fcport)
> > +{
> > +	if (fcport->sq_pbl)
> > +		dma_free_coherent(&qedf->pdev->dev, fcport->sq_pbl_size,
> > +		    fcport->sq_pbl, fcport->sq_pbl_dma);
> > +	if (fcport->sq)
> > +		dma_free_coherent(&qedf->pdev->dev, fcport->sq_mem_size,
> > +		    fcport->sq, fcport->sq_dma);
> > +}
> > +
> > +/*
> > + * Allocate a cookie into the qedf_ctx rport list.  Assumes the hba lock
> > + * is held on entry.
> > + */
> > +static int qedf_alloc_conn_id(struct qedf_ctx *qedf, struct qedf_rport *fcport)
> > +{
> > +	int i;
> > +
> > +	for (i = 0; i < QEDF_MAX_SESSIONS; i++) {
> > +		qedf->curr_conn_id++;
> > +		if (qedf->curr_conn_id == QEDF_MAX_SESSIONS)
> > +			qedf->curr_conn_id = 0;
> > +		if (qedf->fcports[qedf->curr_conn_id] == NULL) {
> > +			qedf->fcports[qedf->curr_conn_id] = fcport;
> > +			fcport->conn_id = qedf->curr_conn_id;
> > +			break;
> > +		}
> > +	}
> > +	if (i == QEDF_MAX_SESSIONS)
> > +		return -1;
> > +	else
> > +		return 0;
> > +}
> > +
> Have you looked at the 'sbitmap' code for conn_id allocation?
> Should be giving you the same results, but you won't need to use a
> spinlock ...

I've not.  I'll look into sbitmap for V2.

> 
> 
> > +static int qedf_offload_connection(struct qedf_ctx *qedf,
> > +	struct qedf_rport *fcport)
> > +{
> > +	struct qed_fcoe_params_offload conn_info;
> > +	u32 port_id;
> > +	u8 lport_src_id[3];
> > +	int rval;
> > +	uint16_t total_sqe = (fcport->sq_mem_size / sizeof(struct fcoe_wqe));
> > +
> > +	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_CONN, "Offloading connection "
> > +		   "portid=%06x.\n", fcport->rdata->ids.port_id);
> > +	rval = qed_ops->acquire_conn(qedf->cdev, &fcport->handle,
> > +	    &fcport->fw_cid, &fcport->p_doorbell);
> > +	if (rval) {
> > +		QEDF_WARN(&(qedf->dbg_ctx), "Could not acquire connection "
> > +			   "for portid=%06x.\n", fcport->rdata->ids.port_id);
> > +		rval = 1; /* For some reason qed returns 0 on failure here */
> > +		goto out;
> > +	}
> > +
> > +	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_CONN, "portid=%06x "
> > +		   "fw_cid=%08x handle=%d.\n", fcport->rdata->ids.port_id,
> > +		   fcport->fw_cid, fcport->handle);
> > +
> > +	memset(&conn_info, 0, sizeof(struct qed_fcoe_params_offload));
> > +
> > +	/* Fill in the offload connection info */
> > +	conn_info.sq_pbl_addr = fcport->sq_pbl_dma;
> > +
> > +	conn_info.sq_curr_page_addr = (dma_addr_t)(*(u64 *)fcport->sq_pbl);
> > +	conn_info.sq_next_page_addr =
> > +	    (dma_addr_t)(*(u64 *)(fcport->sq_pbl + 8));
> > +
> > +	/* Need to use our FCoE MAC for the offload session */
> > +	port_id = fc_host_port_id(qedf->lport->host);
> > +	lport_src_id[2] = (port_id & 0x000000FF);
> > +	lport_src_id[1] = (port_id & 0x0000FF00) >> 8;
> > +	lport_src_id[0] = (port_id & 0x00FF0000) >> 16;
> > +	fc_fcoe_set_mac(conn_info.src_mac, lport_src_id);
> > +
> > +	ether_addr_copy(conn_info.dst_mac, qedf->ctlr.dest_addr);
> > +
> > +	conn_info.tx_max_fc_pay_len = fcport->rdata->maxframe_size;
> > +	conn_info.e_d_tov_timer_val = qedf->lport->e_d_tov / 20;
> > +	conn_info.rec_tov_timer_val = 3; /* I think this is what E3 was */
> > +	conn_info.rx_max_fc_pay_len = fcport->rdata->maxframe_size;
> > +
> > +	/* Set VLAN data */
> > +	conn_info.vlan_tag = qedf->vlan_id <<
> > +	    FCOE_CONN_OFFLOAD_RAMROD_DATA_VLAN_ID_SHIFT;
> > +	conn_info.vlan_tag |=
> > +	    qedf_default_prio << FCOE_CONN_OFFLOAD_RAMROD_DATA_PRIORITY_SHIFT;
> > +	conn_info.flags |= (FCOE_CONN_OFFLOAD_RAMROD_DATA_B_VLAN_FLAG_MASK <<
> > +	    FCOE_CONN_OFFLOAD_RAMROD_DATA_B_VLAN_FLAG_SHIFT);
> > +
> > +	/* Set host port source id */
> > +	port_id = fc_host_port_id(qedf->lport->host);
> > +	fcport->sid = port_id;
> > +	conn_info.s_id.addr_hi = (port_id & 0x000000FF);
> > +	conn_info.s_id.addr_mid = (port_id & 0x0000FF00) >> 8;
> > +	conn_info.s_id.addr_lo = (port_id & 0x00FF0000) >> 16;
> > +
> > +	conn_info.max_conc_seqs_c3 = fcport->rdata->max_seq;
> > +
> > +	/* Set remote port destination id */
> > +	port_id = fcport->rdata->rport->port_id;
> > +	conn_info.d_id.addr_hi = (port_id & 0x000000FF);
> > +	conn_info.d_id.addr_mid = (port_id & 0x0000FF00) >> 8;
> > +	conn_info.d_id.addr_lo = (port_id & 0x00FF0000) >> 16;
> > +
> > +	conn_info.def_q_idx = 0; /* Default index for send queue? */
> > +
> > +	/* Set FC-TAPE specific flags if needed */
> > +	if (fcport->dev_type == QEDF_RPORT_TYPE_TAPE) {
> > +		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_CONN,
> > +		    "Enable CONF, REC for portid=%06x.\n",
> > +		    fcport->rdata->ids.port_id);
> > +		conn_info.flags |= 1 <<
> > +		    FCOE_CONN_OFFLOAD_RAMROD_DATA_B_CONF_REQ_SHIFT;
> > +		conn_info.flags |=
> > +		    ((fcport->rdata->sp_features & FC_SP_FT_SEQC) ? 1 : 0) <<
> > +		    FCOE_CONN_OFFLOAD_RAMROD_DATA_B_REC_VALID_SHIFT;
> > +	}
> > +
> > +	rval = qed_ops->offload_conn(qedf->cdev, fcport->handle, &conn_info);
> > +	if (rval) {
> > +		QEDF_WARN(&(qedf->dbg_ctx), "Could not offload connection "
> > +			   "for portid=%06x.\n", fcport->rdata->ids.port_id);
> > +		goto out_free_conn;
> > +	} else
> > +		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_CONN, "Offload "
> > +			   "succeeded portid=%06x total_sqe=%d.\n",
> > +			   fcport->rdata->ids.port_id, total_sqe);
> > +
> > +	spin_lock_init(&fcport->rport_lock);
> > +	atomic_set(&fcport->free_sqes, total_sqe);
> > +	return 0;
> > +out_free_conn:
> > +	qed_ops->release_conn(qedf->cdev, fcport->handle);
> > +out:
> > +	return rval;
> > +}
> > +
> > +#define QEDF_TERM_BUFF_SIZE		10
> > +static void qedf_upload_connection(struct qedf_ctx *qedf,
> > +	struct qedf_rport *fcport)
> > +{
> > +	void *term_params;
> > +	dma_addr_t term_params_dma;
> > +
> > +	/* Term params needs to be a DMA coherent buffer as qed shared the
> > +	 * physical DMA address with the firmware. The buffer may be used in
> > +	 * the receive path so we may eventually have to move this.
> > +	 */
> > +	term_params = dma_alloc_coherent(&qedf->pdev->dev, QEDF_TERM_BUFF_SIZE,
> > +		&term_params_dma, GFP_KERNEL);
> > +
> > +	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_CONN, "Uploading connection "
> > +		   "port_id=%06x.\n", fcport->rdata->ids.port_id);
> > +
> > +	qed_ops->destroy_conn(qedf->cdev, fcport->handle, term_params_dma);
> > +	qed_ops->release_conn(qedf->cdev, fcport->handle);
> > +
> > +	dma_free_coherent(&qedf->pdev->dev, QEDF_TERM_BUFF_SIZE, term_params,
> > +	    term_params_dma);
> > +}
> > +
> > +static void qedf_cleanup_fcport(struct qedf_ctx *qedf,
> > +	struct qedf_rport *fcport)
> > +{
> > +	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_CONN, "Clearing conn_id=%u "
> > +		   "for portid=%06x.\n", fcport->conn_id,
> > +		   fcport->rdata->ids.port_id);
> > +
> > +	/* Flush any remaining i/o's before we upload the connection */
> > +	qedf_flush_active_ios(fcport, -1);
> > +
> > +	spin_lock(&qedf->hba_lock);
> > +	qedf->fcports[fcport->conn_id] = NULL;
> > +	fcport->conn_id = -1;
> > +	spin_unlock(&qedf->hba_lock);
> > +
> > +	if (test_and_clear_bit(QEDF_RPORT_SESSION_READY, &fcport->flags))
> > +		qedf_upload_connection(qedf, fcport);
> > +	qedf_free_sq(qedf, fcport);
> > +	fcport->rdata = NULL;
> > +	fcport->qedf = NULL;
> > +}
> > +
> > +/**
> > + * This event_callback is called after successful completion of libfc
> > + * initiated target login. qedf can proceed with initiating the session
> > + * establishment.
> > + */
> > +static void qedf_rport_event_handler(struct fc_lport *lport,
> > +				struct fc_rport_priv *rdata,
> > +				enum fc_rport_event event)
> > +{
> > +	struct qedf_ctx *qedf = lport_priv(lport);
> > +	struct fc_rport *rport = rdata->rport;
> > +	struct fc_rport_libfc_priv *rp;
> > +	struct qedf_rport *fcport;
> > +	u32 port_id;
> > +	int rval;
> > +
> > +	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC, "event = %d, "
> > +		   "port_id = 0x%x\n", event, rdata->ids.port_id);
> > +
> > +	switch (event) {
> > +	case RPORT_EV_READY:
> > +		if (!rport) {
> > +			QEDF_WARN(&(qedf->dbg_ctx), "rport is NULL.\n");
> > +			break;
> > +		}
> > +
> > +		rp = rport->dd_data;
> > +		fcport = (struct qedf_rport *)&rp[1];
> > +		fcport->qedf = qedf;
> > +
> > +		/*
> > +		 * Don't try to offload the session again. Can happen when we
> > +		 * get an ADISC
> > +		 */
> > +		if (test_bit(QEDF_RPORT_SESSION_READY, &fcport->flags)) {
> > +			QEDF_WARN(&(qedf->dbg_ctx), "Session already "
> > +				   "offloaded, portid=0x%x.\n",
> > +				   rdata->ids.port_id);
> > +			return;
> > +		}
> > +
> > +		/*
> > +		 * Set the connection id to -1 so we know if we ever assigned
> > +		 * one to the fcport.
> > +		 */
> > +		fcport->conn_id = -1;
> > +
> > +		if (rport->port_id == FC_FID_DIR_SERV) {
> > +			/*
> > +			 * qedf_rport structure doesn't exist for
> > +			 * directory server.
> > +			 * We should not come here, as lport will
> > +			 * take care of fabric login
> > +			 */
> > +			QEDF_WARN(&(qedf->dbg_ctx), "rport struct does not "
> > +			    "exist for dir server port_id=%x\n",
> > +			    rdata->ids.port_id);
> > +			break;
> > +		}
> > +
> > +		if (rdata->spp_type != FC_TYPE_FCP) {
> > +			QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
> > +			    "Not offlading since since spp type isn't FCP\n");
> > +			break;
> > +		}
> > +		if (!(rdata->ids.roles & FC_RPORT_ROLE_FCP_TARGET)) {
> > +			QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
> > +			    "Not FCP target so not offloading\n");
> > +			break;
> > +		}
> > +
> > +		spin_lock(&qedf->hba_lock);
> > +		rval = qedf_alloc_conn_id(qedf, fcport);
> > +		spin_unlock(&qedf->hba_lock);
> > +
> > +		if (rval) {
> > +			QEDF_WARN(&(qedf->dbg_ctx), "Could not allocate "
> > +				   "conn_id for port %06x.\n",
> > +				   rdata->ids.port_id);
> > +			break;
> > +		}
> > +
> > +		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
> > +			   "Assigned conn_id=%u to port_id=%06x.\n",
> > +			    fcport->conn_id, rdata->ids.port_id);
> > +
> > +		fcport->rdata = rdata;
> > +		fcport->rport = rport;
> > +
> > +		rval = qedf_alloc_sq(qedf, fcport);
> > +		if (rval) {
> > +			qedf_cleanup_fcport(qedf, fcport);
> > +			break;
> > +		}
> > +
> > +		/* Set device type */
> > +		if (rdata->flags & FC_RP_FLAGS_RETRY &&
> > +		    rdata->ids.roles & FC_RPORT_ROLE_FCP_TARGET &&
> > +		    !(rdata->ids.roles & FC_RPORT_ROLE_FCP_INITIATOR)) {
> > +			fcport->dev_type = QEDF_RPORT_TYPE_TAPE;
> > +			QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
> > +			    "portid=%06x is a TAPE device.\n",
> > +			    rdata->ids.port_id);
> > +		} else {
> > +			fcport->dev_type = QEDF_RPORT_TYPE_DISK;
> > +		}
> > +
> > +		rval = qedf_offload_connection(qedf, fcport);
> > +		if (rval) {
> > +			qedf_cleanup_fcport(qedf, fcport);
> > +			break;
> > +		}
> > +
> > +		/*
> > +		 * Set the session ready bit to let everyone know that this
> > +		 * connection is ready for I/O
> > +		 */
> > +		set_bit(QEDF_RPORT_SESSION_READY, &fcport->flags);
> > +		atomic_inc(&qedf->num_offloads);
> > +
> > +		break;
> > +	case RPORT_EV_LOGO:
> > +	case RPORT_EV_FAILED:
> > +	case RPORT_EV_STOP:
> > +		port_id = rdata->ids.port_id;
> > +		if (port_id == FC_FID_DIR_SERV)
> > +			break;
> > +
> > +		if (!rport) {
> > +			QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
> > +			    "port_id=%x - rport notcreated Yet!!\n", port_id);
> > +			break;
> > +		}
> > +		rp = rport->dd_data;
> > +		/*
> > +		 * Perform session upload. Note that rdata->peers is already
> > +		 * removed from disc->rports list before we get this event.
> > +		 */
> > +		fcport = (struct qedf_rport *)&rp[1];
> > +
> > +		/*
> > +		 * Only free the conn_id if this fcport was initialized with
> > +		 * one.
> > +		 */
> > +		if (fcport->conn_id > -1) {
> > +			set_bit(QEDF_RPORT_UPLOADING_CONNECTION, &fcport->flags);
> > +			qedf_cleanup_fcport(qedf, fcport);
> > +			clear_bit(QEDF_RPORT_UPLOADING_CONNECTION,
> > +			    &fcport->flags);
> > +			atomic_dec(&qedf->num_offloads);
> > +		}
> > +
> > +		break;
> > +
> > +	case RPORT_EV_NONE:
> > +		break;
> > +	}
> > +}
> > +
> > +static void qedf_abort_io(struct fc_lport *lport)
> > +{
> > +	/* NO-OP but need to fill in the template */
> > +}
> > +
> > +static void qedf_fcp_cleanup(struct fc_lport *lport)
> > +{
> > +	/*
> > +	 * NO-OP but need to fill in template to prevent a NULL
> > +	 * function pointer dereference during link down. I/Os
> > +	 * will be flushed when port is uploaded.
> > +	 */
> > +}
> > +
> > +static struct libfc_function_template qedf_lport_template = {
> > +	.frame_send		= qedf_xmit,
> > +	.fcp_abort_io		= qedf_abort_io,
> > +	.fcp_cleanup		= qedf_fcp_cleanup,
> > +	.rport_event_callback	= qedf_rport_event_handler,
> > +	.elsct_send		= qedf_elsct_send,
> > +};
> > +
> > +static void qedf_fcoe_ctlr_setup(struct qedf_ctx *qedf)
> > +{
> > +	fcoe_ctlr_init(&qedf->ctlr, FIP_ST_AUTO);
> > +
> > +	qedf->ctlr.send = qedf_fip_send;
> > +	qedf->ctlr.update_mac = qedf_update_src_mac;
> > +	qedf->ctlr.get_src_addr = qedf_get_src_mac;
> > +	ether_addr_copy(qedf->ctlr.ctl_src_addr, qedf->mac);
> > +}
> > +
> > +static int qedf_lport_setup(struct qedf_ctx *qedf)
> > +{
> > +	struct fc_lport *lport = qedf->lport;
> > +
> > +	lport->link_up = 0;
> > +	lport->max_retry_count = QEDF_FLOGI_RETRY_CNT;
> > +	lport->max_rport_retry_count = QEDF_RPORT_RETRY_CNT;
> > +	lport->service_params = (FCP_SPPF_INIT_FCN | FCP_SPPF_RD_XRDY_DIS |
> > +	    FCP_SPPF_RETRY | FCP_SPPF_CONF_COMPL);
> > +	lport->boot_time = jiffies;
> > +	lport->e_d_tov = 2 * 1000;
> > +	lport->r_a_tov = 10 * 1000;
> > +
> > +	/* Set NPIV support */
> > +	lport->does_npiv = 1;
> > +	fc_host_max_npiv_vports(lport->host) = QEDF_MAX_NPIV;
> > +
> > +	fc_set_wwnn(lport, qedf->wwnn);
> > +	fc_set_wwpn(lport, qedf->wwpn);
> > +
> > +	fcoe_libfc_config(lport, &qedf->ctlr, &qedf_lport_template, 0);
> > +
> > +	/* Allocate the exchange manager */
> > +	fc_exch_mgr_alloc(lport, FC_CLASS_3, qedf->max_scsi_xid + 1,
> > +	    qedf->max_els_xid, NULL);
> > +
> > +	if (fc_lport_init_stats(lport))
> > +		return -ENOMEM;
> > +
> > +	/* Finish lport config */
> > +	fc_lport_config(lport);
> > +
> > +	/* Set max frame size */
> > +	fc_set_mfs(lport, QEDF_MFS);
> > +	fc_host_maxframe_size(lport->host) = lport->mfs;
> > +
> > +	/* Set default dev_loss_tmo based on module parameter */
> > +	fc_host_dev_loss_tmo(lport->host) = qedf_dev_loss_tmo;
> > +
> > +	/* Set symbolic node name */
> > +	snprintf(fc_host_symbolic_name(lport->host), 256,
> > +	    "QLogic %s v%s", QEDF_MODULE_NAME, QEDF_VERSION);
> > +
> > +	return 0;
> > +}
> > +
> > +/*
> > + * NPIV functions
> > + */
> > +
> > +static int qedf_vport_libfc_config(struct fc_vport *vport,
> > +	struct fc_lport *lport)
> > +{
> > +	lport->link_up = 0;
> > +	lport->qfull = 0;
> > +	lport->max_retry_count = QEDF_FLOGI_RETRY_CNT;
> > +	lport->max_rport_retry_count = QEDF_RPORT_RETRY_CNT;
> > +	lport->service_params = (FCP_SPPF_INIT_FCN | FCP_SPPF_RD_XRDY_DIS |
> > +	    FCP_SPPF_RETRY | FCP_SPPF_CONF_COMPL);
> > +	lport->boot_time = jiffies;
> > +	lport->e_d_tov = 2 * 1000;
> > +	lport->r_a_tov = 10 * 1000;
> > +	lport->does_npiv = 1; /* Temporary until we add NPIV support */
> > +
> > +	/* Allocate stats for vport */
> > +	if (fc_lport_init_stats(lport))
> > +		return -ENOMEM;
> > +
> > +	/* Finish lport config */
> > +	fc_lport_config(lport);
> > +
> > +	/* offload related configuration */
> > +	lport->crc_offload = 0;
> > +	lport->seq_offload = 0;
> > +	lport->lro_enabled = 0;
> > +	lport->lro_xid = 0;
> > +	lport->lso_max = 0;
> > +
> > +	return 0;
> > +}
> > +
> > +static int qedf_vport_create(struct fc_vport *vport, bool disabled)
> > +{
> > +	struct Scsi_Host *shost = vport_to_shost(vport);
> > +	struct fc_lport *n_port = shost_priv(shost);
> > +	struct fc_lport *vn_port;
> > +	struct qedf_ctx *base_qedf = lport_priv(n_port);
> > +	struct qedf_ctx *vport_qedf;
> > +	int i;
> > +
> > +	char buf[32];
> > +	int rc = 0;
> > +
> > +	rc = fcoe_validate_vport_create(vport);
> > +	if (rc) {
> > +		fcoe_wwn_to_str(vport->port_name, buf, sizeof(buf));
> > +		QEDF_WARN(&(base_qedf->dbg_ctx), "Failed to create vport, "
> > +			   "WWPN (0x%s) already exists.\n", buf);
> > +		goto err1;
> > +	}
> > +
> > +	if (atomic_read(&base_qedf->link_state) != QEDF_LINK_UP) {
> > +		QEDF_WARN(&(base_qedf->dbg_ctx), "Cannot create vport "
> > +			   "because link is not up.\n");
> > +		rc = -EIO;
> > +		goto err1;
> > +	}
> > +
> > +	vn_port = libfc_vport_create(vport, sizeof(struct qedf_ctx));
> > +	if (!vn_port) {
> > +		QEDF_WARN(&(base_qedf->dbg_ctx), "Could not create lport "
> > +			   "for vport.\n");
> > +		rc = -ENOMEM;
> > +		goto err1;
> > +	}
> > +
> > +	fcoe_wwn_to_str(vport->port_name, buf, sizeof(buf));
> > +	QEDF_ERR(&(base_qedf->dbg_ctx), "Creating NPIV port, WWPN=%s.\n",
> > +	    buf);
> > +
> > +	/* Copy some fields from base_qedf */
> > +	vport_qedf = lport_priv(vn_port);
> > +	memcpy(vport_qedf, base_qedf, sizeof(struct qedf_ctx));
> > +
> > +	/* Set qedf data specific to this vport */
> > +	vport_qedf->lport = vn_port;
> > +	/* Use same hba_lock as base_qedf */
> > +	vport_qedf->hba_lock = base_qedf->hba_lock;
> > +	/* Purge any fcport info from base_qedf */
> > +	for (i = 0; i < QEDF_MAX_SESSIONS; i++)
> > +		vport_qedf->fcports[i] = NULL;
> > +	vport_qedf->pdev = base_qedf->pdev;
> > +	vport_qedf->cmd_mgr = base_qedf->cmd_mgr;
> > +	init_completion(&vport_qedf->flogi_compl);
> > +
> > +	rc = qedf_vport_libfc_config(vport, vn_port);
> > +	if (rc) {
> > +		QEDF_ERR(&(base_qedf->dbg_ctx), "Could not allocate memory "
> > +		    "for lport stats.\n");
> > +		goto err2;
> > +	}
> > +
> > +	fc_set_wwnn(vn_port, vport->node_name);
> > +	fc_set_wwpn(vn_port, vport->port_name);
> > +	vport_qedf->wwnn = vn_port->wwnn;
> > +	vport_qedf->wwpn = vn_port->wwpn;
> > +
> > +	vn_port->host->transportt = qedf_fc_vport_transport_template;
> > +	vn_port->host->can_queue = QEDF_MAX_ELS_XID;
> > +	vn_port->host->max_lun = qedf_max_lun;
> > +	vn_port->host->sg_tablesize = QEDF_MAX_BDS_PER_CMD;
> > +	vn_port->host->max_cmd_len = QEDF_MAX_CDB_LEN;
> > +
> > +	rc = scsi_add_host(vn_port->host, &vport->dev);
> > +	if (rc) {
> > +		QEDF_WARN(&(base_qedf->dbg_ctx), "Error adding Scsi_Host.\n");
> > +		goto err2;
> > +	}
> > +
> > +	/* Set default dev_loss_tmo based on module parameter */
> > +	fc_host_dev_loss_tmo(vn_port->host) = qedf_dev_loss_tmo;
> > +
> > +	/* Init libfc stuffs */
> > +	memcpy(&vn_port->tt, &qedf_lport_template,
> > +		sizeof(qedf_lport_template));
> > +	fc_exch_init(vn_port);
> > +	fc_elsct_init(vn_port);
> > +	fc_lport_init(vn_port);
> > +	fc_disc_init(vn_port);
> > +	fc_disc_config(vn_port, vn_port);
> > +
> > +
> > +	/* Allocate the exchange manager */
> > +	shost = vport_to_shost(vport);
> > +	n_port = shost_priv(shost);
> > +	fc_exch_mgr_list_clone(n_port, vn_port);
> > +
> > +	/* Set max frame size */
> > +	fc_set_mfs(vn_port, QEDF_MFS);
> > +
> > +	fc_host_port_type(vn_port->host) = FC_PORTTYPE_UNKNOWN;
> > +
> > +	if (disabled) {
> > +		fc_vport_set_state(vport, FC_VPORT_DISABLED);
> > +	} else {
> > +		vn_port->boot_time = jiffies;
> > +		fc_fabric_login(vn_port);
> > +		fc_vport_setlink(vn_port);
> > +	}
> > +
> > +	QEDF_INFO(&(base_qedf->dbg_ctx), QEDF_LOG_NPIV, "vn_port=%p.\n",
> > +		   vn_port);
> > +
> > +	/* Set up debug context for vport */
> > +	vport_qedf->dbg_ctx.host_no = vn_port->host->host_no;
> > +	vport_qedf->dbg_ctx.pdev = base_qedf->pdev;
> > +
> > +err2:
> > +	scsi_host_put(vn_port->host);
> > +err1:
> > +	return rc;
> > +}
> > +
> > +static int qedf_vport_destroy(struct fc_vport *vport)
> > +{
> > +	struct Scsi_Host *shost = vport_to_shost(vport);
> > +	struct fc_lport *n_port = shost_priv(shost);
> > +	struct fc_lport *vn_port = vport->dd_data;
> > +
> > +	mutex_lock(&n_port->lp_mutex);
> > +	list_del(&vn_port->list);
> > +	mutex_unlock(&n_port->lp_mutex);
> > +
> > +	fc_fabric_logoff(vn_port);
> > +	fc_lport_destroy(vn_port);
> > +
> > +	/* Detach from scsi-ml */
> > +	fc_remove_host(vn_port->host);
> > +	scsi_remove_host(vn_port->host);
> > +
> > +	/*
> > +	 * Only try to release the exchange manager if the vn_port
> > +	 * configuration is complete.
> > +	 */
> > +	if (vn_port->state == LPORT_ST_READY)
> > +		fc_exch_mgr_free(vn_port);
> > +
> > +	/* Free memory used by statistical counters */
> > +	fc_lport_free_stats(vn_port);
> > +
> > +	/* Release Scsi_Host */
> > +	if (vn_port->host)
> > +		scsi_host_put(vn_port->host);
> > +
> > +	return 0;
> > +}
> > +
> > +static int qedf_vport_disable(struct fc_vport *vport, bool disable)
> > +{
> > +	struct fc_lport *lport = vport->dd_data;
> > +
> > +	if (disable) {
> > +		fc_vport_set_state(vport, FC_VPORT_DISABLED);
> > +		fc_fabric_logoff(lport);
> > +	} else {
> > +		lport->boot_time = jiffies;
> > +		fc_fabric_login(lport);
> > +		fc_vport_setlink(lport);
> > +	}
> > +	return 0;
> > +}
> > +
> > +/*
> > + * During removal we need to wait for all the vports associated with a port
> > + * to be destroyed so we avoid a race condition where libfc is still trying
> > + * to reap vports while the driver remove function has already reaped the
> > + * driver contexts associated with the physical port.
> > + */
> > +static void qedf_wait_for_vport_destroy(struct qedf_ctx *qedf)
> > +{
> > +	struct fc_host_attrs *fc_host = shost_to_fc_host(qedf->lport->host);
> > +
> > +	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_NPIV,
> > +	    "Entered.\n");
> > +	while (fc_host->npiv_vports_inuse > 0) {
> > +		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_NPIV,
> > +		    "Waiting for all vports to be reaped.\n");
> > +		msleep(1000);
> > +	}
> > +}
> > +
> > +/**
> > + * qedf_fcoe_reset - Resets the fcoe
> > + *
> > + * @shost: shost the reset is from
> > + *
> > + * Returns: always 0
> > + */
> > +static int qedf_fcoe_reset(struct Scsi_Host *shost)
> > +{
> > +	struct fc_lport *lport = shost_priv(shost);
> > +
> > +	fc_fabric_logoff(lport);
> > +	fc_fabric_login(lport);
> > +	return 0;
> > +}
> > +
> > +static struct fc_host_statistics *qedf_fc_get_host_stats(struct Scsi_Host
> > +	*shost)
> > +{
> > +	struct fc_host_statistics *qedf_stats;
> > +	struct fc_lport *lport = shost_priv(shost);
> > +	struct qedf_ctx *qedf = lport_priv(lport);
> > +	struct qed_fcoe_stats *fw_fcoe_stats;
> > +
> > +	qedf_stats = fc_get_host_stats(shost);
> > +
> > +	/* We don't collect offload stats for specific NPIV ports */
> > +	if (lport->vport)
> > +		goto out;
> > +
> > +	fw_fcoe_stats = kmalloc(sizeof(struct qed_fcoe_stats), GFP_KERNEL);
> > +	if (!fw_fcoe_stats) {
> > +		QEDF_ERR(&(qedf->dbg_ctx), "Could not allocate memory for "
> > +		    "fw_fcoe_stats.\n");
> > +		goto out;
> > +	}
> > +
> > +	/* Query firmware for offload stats */
> > +	qed_ops->get_stats(qedf->cdev, fw_fcoe_stats);
> > +
> > +	/*
> > +	 * The expectation is that we add our offload stats to the stats
> > +	 * being maintained by libfc each time the fc_get_host_status callback
> > +	 * is invoked. The additions are not carried over for each call to
> > +	 * the fc_get_host_stats callback.
> > +	 */
> > +	qedf_stats->tx_frames += fw_fcoe_stats->fcoe_tx_data_pkt_cnt +
> > +	    fw_fcoe_stats->fcoe_tx_xfer_pkt_cnt +
> > +	    fw_fcoe_stats->fcoe_tx_other_pkt_cnt;
> > +	qedf_stats->rx_frames += fw_fcoe_stats->fcoe_rx_data_pkt_cnt +
> > +	    fw_fcoe_stats->fcoe_rx_xfer_pkt_cnt +
> > +	    fw_fcoe_stats->fcoe_rx_other_pkt_cnt;
> > +	qedf_stats->fcp_input_megabytes += fw_fcoe_stats->fcoe_rx_byte_cnt /
> > +	    1000000;
> > +	qedf_stats->fcp_output_megabytes += fw_fcoe_stats->fcoe_tx_byte_cnt /
> > +	    1000000;
> > +	qedf_stats->rx_words += fw_fcoe_stats->fcoe_rx_byte_cnt / 4;
> > +	qedf_stats->tx_words += fw_fcoe_stats->fcoe_tx_byte_cnt / 4;
> > +	qedf_stats->invalid_crc_count +=
> > +	    fw_fcoe_stats->fcoe_silent_drop_pkt_crc_error_cnt;
> > +	qedf_stats->dumped_frames =
> > +	    fw_fcoe_stats->fcoe_silent_drop_total_pkt_cnt;
> > +	qedf_stats->error_frames +=
> > +	    fw_fcoe_stats->fcoe_silent_drop_total_pkt_cnt;
> > +	qedf_stats->fcp_input_requests += qedf->input_requests;
> > +	qedf_stats->fcp_output_requests += qedf->output_requests;
> > +	qedf_stats->fcp_control_requests += qedf->control_requests;
> > +	qedf_stats->fcp_packet_aborts += qedf->packet_aborts;
> > +	qedf_stats->fcp_frame_alloc_failures += qedf->alloc_failures;
> > +
> > +	kfree(fw_fcoe_stats);
> > +out:
> > +	return qedf_stats;
> > +}
> > +
> > +static struct fc_function_template qedf_fc_transport_fn = {
> > +	.show_host_node_name = 1,
> > +	.show_host_port_name = 1,
> > +	.show_host_supported_classes = 1,
> > +	.show_host_supported_fc4s = 1,
> > +	.show_host_active_fc4s = 1,
> > +	.show_host_maxframe_size = 1,
> > +
> > +	.show_host_port_id = 1,
> > +	.show_host_supported_speeds = 1,
> > +	.get_host_speed = fc_get_host_speed,
> > +	.show_host_speed = 1,
> > +	.show_host_port_type = 1,
> > +	.get_host_port_state = fc_get_host_port_state,
> > +	.show_host_port_state = 1,
> > +	.show_host_symbolic_name = 1,
> > +
> > +	/*
> > +	 * Tell FC transport to allocate enough space to store the backpointer
> > +	 * for the associate qedf_rport struct.
> > +	 */
> > +	.dd_fcrport_size = (sizeof(struct fc_rport_libfc_priv) +
> > +				sizeof(struct qedf_rport)),
> > +	.show_rport_maxframe_size = 1,
> > +	.show_rport_supported_classes = 1,
> > +	.show_host_fabric_name = 1,
> > +	.show_starget_node_name = 1,
> > +	.show_starget_port_name = 1,
> > +	.show_starget_port_id = 1,
> > +	.set_rport_dev_loss_tmo = fc_set_rport_loss_tmo,
> > +	.show_rport_dev_loss_tmo = 1,
> > +	.get_fc_host_stats = qedf_fc_get_host_stats,
> > +	.issue_fc_host_lip = qedf_fcoe_reset,
> > +	.vport_create = qedf_vport_create,
> > +	.vport_delete = qedf_vport_destroy,
> > +	.vport_disable = qedf_vport_disable,
> > +	.bsg_request = fc_lport_bsg_request,
> > +};
> > +
> > +static struct fc_function_template qedf_fc_vport_transport_fn = {
> > +	.show_host_node_name = 1,
> > +	.show_host_port_name = 1,
> > +	.show_host_supported_classes = 1,
> > +	.show_host_supported_fc4s = 1,
> > +	.show_host_active_fc4s = 1,
> > +	.show_host_maxframe_size = 1,
> > +	.show_host_port_id = 1,
> > +	.show_host_supported_speeds = 1,
> > +	.get_host_speed = fc_get_host_speed,
> > +	.show_host_speed = 1,
> > +	.show_host_port_type = 1,
> > +	.get_host_port_state = fc_get_host_port_state,
> > +	.show_host_port_state = 1,
> > +	.show_host_symbolic_name = 1,
> > +	.dd_fcrport_size = (sizeof(struct fc_rport_libfc_priv) +
> > +				sizeof(struct qedf_rport)),
> > +	.show_rport_maxframe_size = 1,
> > +	.show_rport_supported_classes = 1,
> > +	.show_host_fabric_name = 1,
> > +	.show_starget_node_name = 1,
> > +	.show_starget_port_name = 1,
> > +	.show_starget_port_id = 1,
> > +	.set_rport_dev_loss_tmo = fc_set_rport_loss_tmo,
> > +	.show_rport_dev_loss_tmo = 1,
> > +	.get_fc_host_stats = fc_get_host_stats,
> > +	.issue_fc_host_lip = qedf_fcoe_reset,
> > +	.bsg_request = fc_lport_bsg_request,
> > +};
> > +
> > +static bool qedf_fp_has_work(struct qedf_fastpath *fp)
> > +{
> > +	struct qedf_ctx *qedf = fp->qedf;
> > +	struct global_queue *que;
> > +	struct qed_sb_info *sb_info = fp->sb_info;
> > +	struct status_block *sb = sb_info->sb_virt;
> > +	u16 prod_idx;
> > +
> > +	/* Get the pointer to the global CQ this completion is on */
> > +	que = qedf->global_queues[fp->sb_id];
> > +
> > +	rmb();
> > +
> > +	/* Get the current firmware producer index */
> > +	prod_idx = sb->pi_array[QEDF_FCOE_PARAMS_GL_RQ_PI];
> > +
> > +	return (que->cq_prod_idx != prod_idx);
> > +}
> > +
> > +/*
> > + * Interrupt handler code.
> > + */
> > +
> > +/* Process completion queue and copy CQE contents for deferred processesing
> > + *
> > + * Return true if we should wake the I/O thread, false if not.
> > + */
> > +static bool qedf_process_completions(struct qedf_fastpath *fp)
> > +{
> > +	struct qedf_ctx *qedf = fp->qedf;
> > +	struct qed_sb_info *sb_info = fp->sb_info;
> > +	struct status_block *sb = sb_info->sb_virt;
> > +	struct global_queue *que;
> > +	u16 prod_idx;
> > +	struct fcoe_cqe *cqe;
> > +	struct qedf_io_work *work;
> > +	unsigned long flags;
> > +	int num_handled = 0;
> > +	unsigned int cpu;
> > +	struct qedf_ioreq *io_req = NULL;
> > +	struct qedf_percpu_iothread_s *iothread;
> > +	u16 xid;
> > +	u16 new_cqes;
> > +	u32 comp_type;
> > +
> > +	/* Get the current firmware producer index */
> > +	prod_idx = sb->pi_array[QEDF_FCOE_PARAMS_GL_RQ_PI];
> > +
> > +	/* Get the pointer to the global CQ this completion is on */
> > +	que = qedf->global_queues[fp->sb_id];
> > +
> > +	/* Calculate the amount of new elements since last processing */
> > +	new_cqes = (prod_idx >= que->cq_prod_idx) ?
> > +	    (prod_idx - que->cq_prod_idx) :
> > +	    0x10000 - que->cq_prod_idx + prod_idx;
> > +
> > +	/* Save producer index */
> > +	que->cq_prod_idx = prod_idx;
> > +
> > +	while (new_cqes) {
> > +		fp->completions++;
> > +		num_handled++;
> > +		cqe = &que->cq[que->cq_cons_idx];
> > +
> > +		comp_type = (cqe->cqe_data >> FCOE_CQE_CQE_TYPE_SHIFT) &
> > +		    FCOE_CQE_CQE_TYPE_MASK;
> > +
> > +		/*
> > +		 * Process unsolicited CQEs directly in the interrupt handler
> > +		 * sine we need the fastpath ID
> > +		 */
> > +		if (comp_type == FCOE_UNSOLIC_CQE_TYPE) {
> > +			QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_UNSOL,
> > +			   "Unsolicated CQE.\n");
> > +			qedf_process_unsol_compl(qedf, fp->sb_id, cqe);
> > +			/*
> > +			 * Don't add a work list item.  Increment consumer
> > +			 * consumer index and move on.
> > +			 */
> > +			goto inc_idx;
> > +		}
> > +
> > +		xid = cqe->cqe_data & FCOE_CQE_TASK_ID_MASK;
> > +		io_req = &qedf->cmd_mgr->cmds[xid];
> > +
> > +		/*
> > +		 * Figure out which percpu thread we should queue this I/O
> > +		 * on.
> > +		 */
> > +		if (!io_req)
> > +			/* If there is not io_req assocated with this CQE
> > +			 * just queue it on CPU 0
> > +			 */
> > +			cpu = 0;
> > +		else {
> > +			cpu = io_req->cpu;
> > +			io_req->int_cpu = smp_processor_id();
> > +		}
> > +
> > +		work = mempool_alloc(qedf->io_mempool, GFP_ATOMIC);
> > +		if (!work) {
> > +			QEDF_WARN(&(qedf->dbg_ctx), "Could not allocate "
> > +				   "work for I/O completion.\n");
> > +			continue;
> > +		}
> > +		memset(work, 0, sizeof(struct qedf_io_work));
> > +
> > +		INIT_LIST_HEAD(&work->list);
> > +
> > +		/* Copy contents of CQE for deferred processing */
> > +		memcpy(&work->cqe, cqe, sizeof(struct fcoe_cqe));
> > +
> > +		work->qedf = fp->qedf;
> > +		work->fp = NULL; /* Only used for unsolicited frames */
> > +
> > +		iothread = &per_cpu(qedf_percpu_iothreads, cpu);
> > +		spin_lock_irqsave(&iothread->work_lock, flags);
> > +		list_add_tail(&work->list, &iothread->work_list);
> > +		spin_unlock_irqrestore(&iothread->work_lock, flags);
> > +		wake_up_process(iothread->iothread);
> > +
> > +inc_idx:
> > +		que->cq_cons_idx++;
> > +		if (que->cq_cons_idx == fp->cq_num_entries)
> > +			que->cq_cons_idx = 0;
> > +		new_cqes--;
> > +	}
> > +
> > +	return true;
> > +}
> > +
> > +
> > +/* MSI-X fastpath handler code */
> > +static irqreturn_t qedf_msix_handler(int irq, void *dev_id)
> > +{
> > +	struct qedf_fastpath *fp = dev_id;
> > +
> > +	if (!fp) {
> > +		QEDF_ERR(NULL, "fp is null.\n");
> > +		return IRQ_HANDLED;
> > +	}
> > +	if (!fp->sb_info) {
> > +		QEDF_ERR(NULL, "fp->sb_info in null.");
> > +		return IRQ_HANDLED;
> > +	}
> > +
> > +	/*
> > +	 * Disable interrupts for this status block while we process new
> > +	 * completions
> > +	 */
> > +	qed_sb_ack(fp->sb_info, IGU_INT_DISABLE, 0 /*do not update*/);
> > +
> > +	while (1) {
> > +		qedf_process_completions(fp);
> > +
> > +		if (qedf_fp_has_work(fp) == 0) {
> > +			/* Update the sb information */
> > +			qed_sb_update_sb_idx(fp->sb_info);
> > +			rmb();
> > +
> > +			if (qedf_fp_has_work(fp) == 0) {
> > +				/* Re-enable interrupts */
> > +				qed_sb_ack(fp->sb_info, IGU_INT_ENABLE, 1);
> > +				return IRQ_HANDLED;
> > +			}
> > +		}
> > +	}
> > +
> > +	/* Do we ever want to break out of above loop? */
> > +	return IRQ_HANDLED;
> > +}
> > +
> > +/* simd handler for MSI/INTa */
> > +static void qedf_simd_int_handler(void *cookie)
> > +{
> > +	/* Cookie is qedf_ctx struct */
> > +	struct qedf_ctx *qedf = (struct qedf_ctx *)cookie;
> > +
> > +	QEDF_WARN(&(qedf->dbg_ctx), "qedf=%p.\n", qedf);
> > +}
> > +
> > +#define QEDF_SIMD_HANDLER_NUM		0
> > +static void qedf_sync_free_irqs(struct qedf_ctx *qedf)
> > +{
> > +	int i;
> > +
> > +	if (qedf->int_info.msix_cnt) {
> > +		for (i = 0; i < qedf->int_info.used_cnt; i++) {
> > +			synchronize_irq(qedf->int_info.msix[i].vector);
> > +			irq_set_affinity_hint(qedf->int_info.msix[i].vector,
> > +			    NULL);
> > +			irq_set_affinity_notifier(qedf->int_info.msix[i].vector,
> > +			    NULL);
> > +			free_irq(qedf->int_info.msix[i].vector,
> > +			    &qedf->fp_array[i]);
> > +		}
> > +	} else
> > +		qed_ops->common->simd_handler_clean(qedf->cdev,
> > +		    QEDF_SIMD_HANDLER_NUM);
> > +
> > +	qedf->int_info.used_cnt = 0;
> > +	qed_ops->common->set_fp_int(qedf->cdev, 0);
> > +}
> > +
> > +static int qedf_request_msix_irq(struct qedf_ctx *qedf)
> > +{
> > +	int i, rc, cpu;
> > +
> > +	cpu = cpumask_first(cpu_online_mask);
> > +	for (i = 0; i < qedf->num_queues; i++) {
> > +		rc = request_irq(qedf->int_info.msix[i].vector,
> > +		    qedf_msix_handler, 0, "qedf", &qedf->fp_array[i]);
> > +
> > +		if (rc) {
> > +			QEDF_WARN(&(qedf->dbg_ctx), "request_irq failed.\n");
> > +			qedf_sync_free_irqs(qedf);
> > +			return rc;
> > +		}
> > +
> > +		qedf->int_info.used_cnt++;
> > +		rc = irq_set_affinity_hint(qedf->int_info.msix[i].vector,
> > +		    get_cpu_mask(cpu));
> > +		cpu = cpumask_next(cpu, cpu_online_mask);
> > +	 }
> > +
> > +	return 0;
> > +}
> > +
> Please use the irq allocation routines from hch here.

Will do.

> 
> 
> Cheers,
> 
> Hannes
> 
