From: Arun Easi <arun.easi@cavium.com>
Subject: Re: [Open-FCoE] [PATCH RFC net-next 1/5] qed: Add support for hardware
 offloaded FCoE.
Date: Tue, 10 Jan 2017 08:49:14 -0800
Message-ID: <alpine.LRH.2.00.1701031428270.19208@mvluser05.qlc.com>
References: <1482520628-24207-1-git-send-email-chad.dupuis@cavium.com> <1482520628-24207-2-git-send-email-chad.dupuis@cavium.com> <371bc2ac-c630-0e95-29aa-3fa16fe0c764@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "Dupuis, Chad" <chad.dupuis@cavium.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        <fcoe-devel@open-fcoe.org>, <netdev@vger.kernel.org>,
        <QLogic-Storage-Upstream@cavium.com>, <linux-scsi@vger.kernel.org>,
        Yuval Mintz <yuval.mintz@cavium.com>
To: Hannes Reinecke <hare@suse.de>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <371bc2ac-c630-0e95-29aa-3fa16fe0c764@suse.de>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Hannes,

Thank you for the review. Please see my comment inline..

On Wed, 28 Dec 2016, 12:41am, Hannes Reinecke wrote:

> On 12/23/2016 08:17 PM, Dupuis, Chad wrote:
> > From: Arun Easi <arun.easi@qlogic.com>
> > 
> > This adds the backbone required for the various HW initalizations
> > which are necessary for the FCoE driver (qedf) for QLogic FastLinQ
> > 4xxxx line of adapters - FW notification, resource initializations, etc.
> > 
> > Signed-off-by: Arun Easi <arun.easi@cavium.com>
> > Signed-off-by: Yuval Mintz <yuval.mintz@cavium.com>
> > ---

--8<-- snipped --

> > diff --git a/include/linux/qed/qed_fcoe_if.h b/include/linux/qed/qed_fcoe_if.h
> > new file mode 100644
> > index 0000000..bd6bcb8
> > --- /dev/null
> > +++ b/include/linux/qed/qed_fcoe_if.h
> > @@ -0,0 +1,145 @@
> > +#ifndef _QED_FCOE_IF_H
> > +#define _QED_FCOE_IF_H
> > +#include <linux/types.h>
> > +#include <linux/qed/qed_if.h>
> > +struct qed_fcoe_stats {
> > +	u64 fcoe_rx_byte_cnt;
> > +	u64 fcoe_rx_data_pkt_cnt;
> > +	u64 fcoe_rx_xfer_pkt_cnt;
> > +	u64 fcoe_rx_other_pkt_cnt;
> > +	u32 fcoe_silent_drop_pkt_cmdq_full_cnt;
> > +	u32 fcoe_silent_drop_pkt_rq_full_cnt;
> > +	u32 fcoe_silent_drop_pkt_crc_error_cnt;
> > +	u32 fcoe_silent_drop_pkt_task_invalid_cnt;
> > +	u32 fcoe_silent_drop_total_pkt_cnt;
> > +
> > +	u64 fcoe_tx_byte_cnt;
> > +	u64 fcoe_tx_data_pkt_cnt;
> > +	u64 fcoe_tx_xfer_pkt_cnt;
> > +	u64 fcoe_tx_other_pkt_cnt;
> > +};
> > +
> > +struct qed_dev_fcoe_info {
> > +	struct qed_dev_info common;
> > +
> > +	void __iomem *primary_dbq_rq_addr;
> > +	void __iomem *secondary_bdq_rq_addr;
> > +};
> > +
> > +struct qed_fcoe_params_offload {
> > +	dma_addr_t sq_pbl_addr;
> > +	dma_addr_t sq_curr_page_addr;
> > +	dma_addr_t sq_next_page_addr;
> > +
> > +	u8 src_mac[ETH_ALEN];
> > +	u8 dst_mac[ETH_ALEN];
> > +
> > +	u16 tx_max_fc_pay_len;
> > +	u16 e_d_tov_timer_val;
> > +	u16 rec_tov_timer_val;
> > +	u16 rx_max_fc_pay_len;
> > +	u16 vlan_tag;
> > +
> > +	struct fc_addr_nw s_id;
> > +	u8 max_conc_seqs_c3;
> > +	struct fc_addr_nw d_id;
> > +	u8 flags;
> > +	u8 def_q_idx;
> > +};
> > +
> > +#define MAX_TID_BLOCKS_FCOE (512)
> > +struct qed_fcoe_tid {
> > +	u32 size;		/* In bytes per task */
> > +	u32 num_tids_per_block;
> > +	u8 *blocks[MAX_TID_BLOCKS_FCOE];
> > +};
> > +
> > +struct qed_fcoe_cb_ops {
> > +	struct qed_common_cb_ops common;
> > +	 u32 (*get_login_failures)(void *cookie);
> > +};
> > +
> > +void qed_fcoe_set_pf_params(struct qed_dev *cdev,
> > +			    struct qed_fcoe_pf_params *params);
> > +
> > +/**
> > + * struct qed_fcoe_ops - qed FCoE operations.
> > + * @common:		common operations pointer
> > + * @fill_dev_info:	fills FCoE specific information
> > + *			@param cdev
> > + *			@param info
> > + *			@return 0 on sucesss, otherwise error value.
> > + * @register_ops:	register FCoE operations
> > + *			@param cdev
> > + *			@param ops - specified using qed_iscsi_cb_ops
> > + *			@param cookie - driver private
> > + * @ll2:		light L2 operations pointer
> > + * @start:		fcoe in FW
> > + *			@param cdev
> > + *			@param tasks - qed will fill information about tasks
> > + *			return 0 on success, otherwise error value.
> > + * @stop:		stops fcoe in FW
> > + *			@param cdev
> > + *			return 0 on success, otherwise error value.
> > + * @acquire_conn:	acquire a new fcoe connection
> > + *			@param cdev
> > + *			@param handle - qed will fill handle that should be
> > + *				used henceforth as identifier of the
> > + *				connection.
> > + *			@param p_doorbell - qed will fill the address of the
> > + *				doorbell.
> > + *			return 0 on sucesss, otherwise error value.
> > + * @release_conn:	release a previously acquired fcoe connection
> > + *			@param cdev
> > + *			@param handle - the connection handle.
> > + *			return 0 on success, otherwise error value.
> > + * @offload_conn:	configures an offloaded connection
> > + *			@param cdev
> > + *			@param handle - the connection handle.
> > + *			@param conn_info - the configuration to use for the
> > + *				offload.
> > + *			return 0 on success, otherwise error value.
> > + * @destroy_conn:	stops an offloaded connection
> > + *			@param cdev
> > + *			@param handle - the connection handle.
> > + *			@param terminate_params
> > + *			return 0 on success, otherwise error value.
> > + * @get_stats:		gets FCoE related statistics
> > + *			@param cdev
> > + *			@param stats - pointer to struck that would be filled
> > + *				we stats
> > + *			return 0 on success, error otherwise.
> > + */
> > +struct qed_fcoe_ops {
> > +	const struct qed_common_ops *common;
> > +
> > +	int (*fill_dev_info)(struct qed_dev *cdev,
> > +			     struct qed_dev_fcoe_info *info);
> > +
> > +	void (*register_ops)(struct qed_dev *cdev,
> > +			     struct qed_fcoe_cb_ops *ops, void *cookie);
> > +
> > +	const struct qed_ll2_ops *ll2;
> > +
> > +	int (*start)(struct qed_dev *cdev, struct qed_fcoe_tid *tasks);
> > +
> > +	int (*stop)(struct qed_dev *cdev);
> > +
> > +	int (*acquire_conn)(struct qed_dev *cdev,
> > +			    u32 *handle,
> > +			    u32 *fw_cid, void __iomem **p_doorbell);
> > +
> > +	int (*release_conn)(struct qed_dev *cdev, u32 handle);
> > +
> > +	int (*offload_conn)(struct qed_dev *cdev,
> > +			    u32 handle,
> > +			    struct qed_fcoe_params_offload *conn_info);
> > +	int (*destroy_conn)(struct qed_dev *cdev,
> > +			    u32 handle, dma_addr_t terminate_params);
> > +
> > +	int (*get_stats)(struct qed_dev *cdev, struct qed_fcoe_stats *stats);
> > +};
> > +
> I prefer to have to comments directly above the function prototypes;
> that is easier to read and requires editing in one place only; this way
> there's a higher likelyhood of both getting out of sync.
> 
> But that may be personal preference only.
> 

I too prefer the same, but when I posted the iSCSI qed part sometime ago, 
which had comment style like you said, I got a comment to follow 
kernel-doc style. So, for the FCoE series, I moved to kernel-doc style 
from the get go.

Regards,
-Arun

> > +const struct qed_fcoe_ops *qed_get_fcoe_ops(void);
> > +void qed_put_fcoe_ops(void);
> > +#endif

--8<-- snipped --

