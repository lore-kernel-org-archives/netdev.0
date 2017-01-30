From: Hannes Reinecke <hare-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH V2 2/2] qedf: Add QLogic FastLinQ offload
 FCoE driver framework.
Date: Mon, 30 Jan 2017 11:34:07 +0100
Message-ID: <28df9087-4eaf-d72c-ccee-89408d3a1b32@suse.de>
References: <1485376423-18737-1-git-send-email-chad.dupuis@cavium.com>
 <1485376423-18737-3-git-send-email-chad.dupuis@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 QLogic-Storage-Upstream-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 yuval.mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
To: "Dupuis, Chad" <chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
In-Reply-To: <1485376423-18737-3-git-send-email-chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
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

On 01/25/2017 09:33 PM, Dupuis, Chad wrote:
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
> +#define QEDF_IO_WORK_MIN		64
> +	mempool_t *io_mempool;
> +	struct workqueue_struct *dpc_wq;
> +
> +	u32 slow_sge_ios;
> +	u32 fast_sge_ios;
> +	u32 single_sge_ios;
> +
> +	uint8_t	*grcdump;
> +	uint32_t grcdump_size;
> +
> +	struct qedf_io_log io_trace_buf[QEDF_IO_TRACE_SIZE];
> +	spinlock_t io_trace_lock;
> +	uint16_t io_trace_idx;
> +
> +	bool stop_io_on_error;
> +
> +	u32 flogi_cnt;
> +	u32 flogi_failed;
> +
> +	/* Used for fc statistics */
> +	u64 input_requests;
> +	u64 output_requests;
> +	u64 control_requests;
> +	u64 packet_aborts;
> +	u64 alloc_failures;
> +};
> +
> +/*
> + * 4 regs size $$KEEP_ENDIANNESS$$
> + */
> +
What is this supposed to mean?
Does it refer to the next structure?

> +struct io_bdt {
> +	struct qedf_ioreq *io_req;
> +	struct fcoe_sge *bd_tbl;
> +	dma_addr_t bd_tbl_dma;
> +	u16 bd_valid;
> +};
> +
[ .. ]

> +
> +static inline void qedf_stop_all_io(struct qedf_ctx *qedf)
> +{
> +	set_bit(QEDF_UNLOADING, &qedf->flags);
> +}
> +
This looks like a misnomer.
Why is 'UNLOADING' equivalent to stopping all I/O?
I could imagine quite some situations where I would want to stop I/O
without unloading the driver.

Please use better naming here; either name the bit 'QEDF_STOP_IO' or
something or call the function 'qedf_is_unloading'.


[ .. ]
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
> +		mutex_lock(&lport->disc.disc_mutex);
> +		fc_rport_logoff(rdata);
> +		/* Recreate the rport and log back in */
> +		rdata =3D fc_rport_create(lport, port_id);
> +		if (rdata)
> +			fc_rport_login(rdata);
> +		mutex_unlock(&lport->disc.disc_mutex);
> +	}
> +}
> +
Please don't hold the discovery mutex when calling fc_rport_logoff().
Calling rport_logoff might call into exch_mgr_reset() which in turn
might need to take the discover mutex.

[ .. ]
> +	if (opcode =3D=3D ELS_LS_RJT) {
> +		rjt =3D fc_frame_payload_get(fp, sizeof(*rjt));
> +		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS,
> +		    "Received LS_RJT for REC: er_reason=3D0x%x, "
> +		    "er_explan=3D0x%x.\n", rjt->er_reason, rjt->er_explan);
> +		/*
> +		 * The following response(s) mean that we need to reissue the
> +		 * request on another exchange.  We need to do this without
> +		 * informing the upper layers lest it cause an application
> +		 * error.
> +		 */
> +		if ((rjt->er_reason =3D=3D ELS_RJT_LOGIC ||
> +		    rjt->er_reason =3D=3D ELS_RJT_UNAB) &&
> +		    rjt->er_explan =3D=3D ELS_EXPL_OXID_RXID) {
> +			QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS,
> +			    "Handle CMD LOST case.\n");
> +			qedf_requeue_io_req(orig_io_req);
> +		}

Care to explain this?
I found requeing within the driver without notifying the upper layers
deeply troubling.
I've came across this (or a similar issue) during implementing
FCoE over virtio; there it turned out to be an issue with the target not
handling frames in the correct order.
So it looks you are attempting to solve the problem of a REC being sent
for a command which is not know at the target.
Meaning it's either lost in the fabric, hasn't been seen by the target
(yet), or having already been processed by the target.

The above code would only solve the second problem; however, that would
indicate a command ordering issue as the REC would have arrived at the
target _before_ the originating command.
So doing a resend would only help for _that_ specific case, not for the
others.
And it's not quite clear why resending with a different OXID would help
here; typically it's the _RXID_ which isn't found ...

[ .. ]
> +static void qedf_fcoe_process_vlan_resp(struct qedf_ctx *qedf,
> +	struct sk_buff *skb)
> +{
> +	struct fip_header *fiph;
> +	struct fip_desc *desc;
> +	u16 vid =3D 0;
> +	ssize_t rlen;
> +	size_t dlen;
> +
> +	fiph =3D (struct fip_header *)(((void *)skb->data) + 2 * ETH_ALEN + 2);
> +
> +	rlen =3D ntohs(fiph->fip_dl_len) * 4;
> +	desc =3D (struct fip_desc *)(fiph + 1);
> +	while (rlen > 0) {
> +		dlen =3D desc->fip_dlen * FIP_BPW;
> +		switch (desc->fip_dtype) {
> +		case FIP_DT_VLAN:
> +			vid =3D ntohs(((struct fip_vlan_desc *)desc)->fd_vlan);
> +			break;
> +		}
> +		desc =3D (struct fip_desc *)((char *)desc + dlen);
> +		rlen -=3D dlen;
> +	}
> +
> +	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC, "VLAN response, "
> +		   "vid=3D0x%x.\n", vid);
> +
> +	if (vid > 0 && qedf->vlan_id !=3D vid) {
> +		qedf_set_vlan_id(qedf, vid);
> +
> +		/* Inform waiter that it's ok to call fcoe_ctlr_link up() */
> +		complete(&qedf->fipvlan_compl);
> +	}
> +}
> +
As mentioned, this will fail for HP VirtualConnect, which return a vid
of '0', indicating that the FCoE link should run on the interface itself.
And this is actually a valid response, I would think that you should be
calling complete() for any response ...

[ .. ]
> +/*
> + * FCoE CQ element
> + */
> +struct fcoe_cqe {
> +	__le32 cqe_data;
> +	/* The task identifier (OX_ID) to be completed */
> +#define FCOE_CQE_TASK_ID_MASK    0xFFFF
> +#define FCOE_CQE_TASK_ID_SHIFT   0
> +	/*
> +	 * The CQE type: 0x0 Indicating on a pending work request completion.
> +	 * 0x1 - Indicating on an unsolicited event notification. use enum
> +	 * fcoe_cqe_type  (use enum fcoe_cqe_type)
> +	 */
> +#define FCOE_CQE_CQE_TYPE_MASK   0xF
> +#define FCOE_CQE_CQE_TYPE_SHIFT  16
> +#define FCOE_CQE_RESERVED0_MASK  0xFFF
> +#define FCOE_CQE_RESERVED0_SHIFT 20
> +	__le16 reserved1;
> +	__le16 fw_cq_prod;
> +	union fcoe_cqe_info cqe_info;
> +};
> +
> +
> +
> +
> +
> +
These lines intentionally left blank?

[ .. ]
> +static int qedf_request_msix_irq(struct qedf_ctx *qedf)
> +{
> +	int i, rc, cpu;
> +
> +	cpu =3D cpumask_first(cpu_online_mask);
> +	for (i =3D 0; i < qedf->num_queues; i++) {
> +		rc =3D request_irq(qedf->int_info.msix[i].vector,
> +		    qedf_msix_handler, 0, "qedf", &qedf->fp_array[i]);
> +
> +		if (rc) {
> +			QEDF_WARN(&(qedf->dbg_ctx), "request_irq failed.\n");
> +			qedf_sync_free_irqs(qedf);
> +			return rc;
> +		}
> +
> +		qedf->int_info.used_cnt++;
> +		rc =3D irq_set_affinity_hint(qedf->int_info.msix[i].vector,
> +		    get_cpu_mask(cpu));
> +		cpu =3D cpumask_next(cpu, cpu_online_mask);
> +	}
> +
> +	return 0;
> +}
> +
Please use pci_alloc_irq_vectors() here; that avoid you having to do SMP
affinity setting yourself.

Cheers,

Hannes
-- =

Dr. Hannes Reinecke		   Teamlead Storage & Networking
hare-l3A5Bk7waGM@public.gmane.org			               +49 911 74053 688
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 N=FCrnberg
GF: F. Imend=F6rffer, J. Smithard, J. Guild, D. Upmanyu, G. Norton
HRB 21284 (AG N=FCrnberg)
