From: Arun Easi <arun.easi@cavium.com>
Subject: Re: [RFC 1/6] qed: Add support for hardware offloaded iSCSI.
Date: Wed, 19 Oct 2016 15:28:32 -0700
Message-ID: <alpine.LRH.2.00.1610191449231.25712@mvluser05.qlc.com>
References: <1476853273-22960-1-git-send-email-manish.rangankar@cavium.com> <1476853273-22960-2-git-send-email-manish.rangankar@cavium.com> <263515de-e1d4-ea86-644b-3f214bcff5ac@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: <manish.rangankar@cavium.com>, <lduncan@suse.com>,
        <cleech@redhat.com>, <martin.petersen@oracle.com>,
        <jejb@linux.vnet.ibm.com>, <linux-scsi@vger.kernel.org>,
        <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>,
        <QLogic-Storage-Upstream@cavium.com>,
        Yuval Mintz <Yuval.Mintz@qlogic.com>
To: Hannes Reinecke <hare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0062.outbound.protection.outlook.com ([104.47.33.62]:62623
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753299AbcJSXDD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Oct 2016 19:03:03 -0400
In-Reply-To: <263515de-e1d4-ea86-644b-3f214bcff5ac@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Hannes for the review. Please see my comments inline..

On Wed, 19 Oct 2016, 12:31am, Hannes Reinecke wrote:

> On 10/19/2016 07:01 AM, manish.rangankar@cavium.com wrote:
> > From: Yuval Mintz <Yuval.Mintz@qlogic.com>
> > 
> > This adds the backbone required for the various HW initalizations
> > which are necessary for the iSCSI driver (qedi) for QLogic FastLinQ
> > 4xxxx line of adapters - FW notification, resource initializations, etc.
> > 
> > Signed-off-by: Arun Easi <arun.easi@cavium.com>
> > Signed-off-by: Yuval Mintz <yuval.mintz@cavium.com>
> > ---
> >  drivers/net/ethernet/qlogic/Kconfig            |   15 +
> >  drivers/net/ethernet/qlogic/qed/Makefile       |    1 +
> >  drivers/net/ethernet/qlogic/qed/qed.h          |    8 +-
> >  drivers/net/ethernet/qlogic/qed/qed_dev.c      |   15 +
> >  drivers/net/ethernet/qlogic/qed/qed_int.h      |    1 -
> >  drivers/net/ethernet/qlogic/qed/qed_iscsi.c    | 1310 ++++++++++++++++++++++++
> >  drivers/net/ethernet/qlogic/qed/qed_iscsi.h    |   52 +
> >  drivers/net/ethernet/qlogic/qed/qed_l2.c       |    1 -
> >  drivers/net/ethernet/qlogic/qed/qed_ll2.c      |   35 +-
> >  drivers/net/ethernet/qlogic/qed/qed_main.c     |    2 -
> >  drivers/net/ethernet/qlogic/qed/qed_mcp.h      |    6 -
> >  drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |    2 +
> >  drivers/net/ethernet/qlogic/qed/qed_spq.c      |   15 +
> >  include/linux/qed/qed_if.h                     |    2 +
> >  include/linux/qed/qed_iscsi_if.h               |  249 +++++
> >  15 files changed, 1692 insertions(+), 22 deletions(-)
> >  create mode 100644 drivers/net/ethernet/qlogic/qed/qed_iscsi.c
> >  create mode 100644 drivers/net/ethernet/qlogic/qed/qed_iscsi.h
> >  create mode 100644 include/linux/qed/qed_iscsi_if.h
> > 

-- snipped --

> > diff --git a/drivers/net/ethernet/qlogic/qed/qed_iscsi.c b/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
> > new file mode 100644
> > index 0000000..cb22dad
> > --- /dev/null
> > +++ b/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
> > @@ -0,0 +1,1310 @@
> > +/* QLogic qed NIC Driver
> 
> Shouldn't that be qedi iSCSI Driver?

Actually, this is the common module under drivers/net/, which was 
submitted along with the NIC driver, qede, so the comment stayed.

In this driver architecture, for all protocols, there is this
common module, qed, as well as a protocol module (qede, qedr, qedi
etc.).

This comment needs to be changed in all files under qed/. We will submit 
another patch to do that.

> > +static int qed_sp_iscsi_conn_offload(struct qed_hwfn *p_hwfn,
> > +				     struct qed_iscsi_conn *p_conn,
> > +				     enum spq_mode comp_mode,
> > +				     struct qed_spq_comp_cb *p_comp_addr)
> > +{
> > +	struct iscsi_spe_conn_offload *p_ramrod = NULL;
> > +	struct tcp_offload_params_opt2 *p_tcp2 = NULL;
> > +	struct tcp_offload_params *p_tcp = NULL;
> > +	struct qed_spq_entry *p_ent = NULL;
> > +	struct qed_sp_init_data init_data;
> > +	union qed_qm_pq_params pq_params;
> > +	u16 pq0_id = 0, pq1_id = 0;
> > +	dma_addr_t r2tq_pbl_addr;
> > +	dma_addr_t xhq_pbl_addr;
> > +	dma_addr_t uhq_pbl_addr;
> > +	int rc = 0;
> > +	u32 dval;
> > +	u16 wval;
> > +	u8 ucval;
> > +	u8 i;
> > +
> > +	/* Get SPQ entry */
> > +	memset(&init_data, 0, sizeof(init_data));
> > +	init_data.cid = p_conn->icid;
> > +	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
> > +	init_data.comp_mode = comp_mode;
> > +	init_data.p_comp_data = p_comp_addr;
> > +
> > +	rc = qed_sp_init_request(p_hwfn, &p_ent,
> > +				 ISCSI_RAMROD_CMD_ID_OFFLOAD_CONN,
> > +				 PROTOCOLID_ISCSI, &init_data);
> > +	if (rc)
> > +		return rc;
> > +
> > +	p_ramrod = &p_ent->ramrod.iscsi_conn_offload;
> > +
> > +	/* Transmission PQ is the first of the PF */
> > +	memset(&pq_params, 0, sizeof(pq_params));
> > +	pq0_id = qed_get_qm_pq(p_hwfn, PROTOCOLID_ISCSI, &pq_params);
> > +	p_conn->physical_q0 = cpu_to_le16(pq0_id);
> > +	p_ramrod->iscsi.physical_q0 = cpu_to_le16(pq0_id);
> > +
> > +	/* iSCSI Pure-ACK PQ */
> > +	pq_params.iscsi.q_idx = 1;
> > +	pq1_id = qed_get_qm_pq(p_hwfn, PROTOCOLID_ISCSI, &pq_params);
> > +	p_conn->physical_q1 = cpu_to_le16(pq1_id);
> > +	p_ramrod->iscsi.physical_q1 = cpu_to_le16(pq1_id);
> > +
> > +	p_ramrod->hdr.op_code = ISCSI_RAMROD_CMD_ID_OFFLOAD_CONN;
> > +	SET_FIELD(p_ramrod->hdr.flags, ISCSI_SLOW_PATH_HDR_LAYER_CODE,
> > +		  p_conn->layer_code);
> > +
> > +	p_ramrod->conn_id = cpu_to_le16(p_conn->conn_id);
> > +	p_ramrod->fw_cid = cpu_to_le32(p_conn->icid);
> > +
> > +	DMA_REGPAIR_LE(p_ramrod->iscsi.sq_pbl_addr, p_conn->sq_pbl_addr);
> > +
> > +	r2tq_pbl_addr = qed_chain_get_pbl_phys(&p_conn->r2tq);
> > +	DMA_REGPAIR_LE(p_ramrod->iscsi.r2tq_pbl_addr, r2tq_pbl_addr);
> > +
> > +	xhq_pbl_addr = qed_chain_get_pbl_phys(&p_conn->xhq);
> > +	DMA_REGPAIR_LE(p_ramrod->iscsi.xhq_pbl_addr, xhq_pbl_addr);
> > +
> > +	uhq_pbl_addr = qed_chain_get_pbl_phys(&p_conn->uhq);
> > +	DMA_REGPAIR_LE(p_ramrod->iscsi.uhq_pbl_addr, uhq_pbl_addr);
> > +
> > +	p_ramrod->iscsi.initial_ack = cpu_to_le32(p_conn->initial_ack);
> > +	p_ramrod->iscsi.flags = p_conn->offl_flags;
> > +	p_ramrod->iscsi.default_cq = p_conn->default_cq;
> > +	p_ramrod->iscsi.stat_sn = cpu_to_le32(p_conn->stat_sn);
> > +
> > +	if (!GET_FIELD(p_ramrod->iscsi.flags,
> > +		       ISCSI_CONN_OFFLOAD_PARAMS_TCP_ON_CHIP_1B)) {
> > +		p_tcp = &p_ramrod->tcp;
> > +		ucval = p_conn->local_mac[1];
> > +		((u8 *)(&p_tcp->local_mac_addr_hi))[0] = ucval;
> > +		ucval = p_conn->local_mac[0];
> > +		((u8 *)(&p_tcp->local_mac_addr_hi))[1] = ucval;
> > +		ucval = p_conn->local_mac[3];
> > +		((u8 *)(&p_tcp->local_mac_addr_mid))[0] = ucval;
> > +		ucval = p_conn->local_mac[2];
> > +		((u8 *)(&p_tcp->local_mac_addr_mid))[1] = ucval;
> > +		ucval = p_conn->local_mac[5];
> > +		((u8 *)(&p_tcp->local_mac_addr_lo))[0] = ucval;
> > +		ucval = p_conn->local_mac[4];
> > +		((u8 *)(&p_tcp->local_mac_addr_lo))[1] = ucval;
> > +		ucval = p_conn->remote_mac[1];
> > +		((u8 *)(&p_tcp->remote_mac_addr_hi))[0] = ucval;
> > +		ucval = p_conn->remote_mac[0];
> > +		((u8 *)(&p_tcp->remote_mac_addr_hi))[1] = ucval;
> > +		ucval = p_conn->remote_mac[3];
> > +		((u8 *)(&p_tcp->remote_mac_addr_mid))[0] = ucval;
> > +		ucval = p_conn->remote_mac[2];
> > +		((u8 *)(&p_tcp->remote_mac_addr_mid))[1] = ucval;
> > +		ucval = p_conn->remote_mac[5];
> > +		((u8 *)(&p_tcp->remote_mac_addr_lo))[0] = ucval;
> > +		ucval = p_conn->remote_mac[4];
> > +		((u8 *)(&p_tcp->remote_mac_addr_lo))[1] = ucval;
> > +
> This looks terribly like endianness swapping. You sure this is
> applicable for all architecture and endianness settings?
> And wouldn't it be better to use one of the get_unaligned_XXX functions
> here?

The mac address in the p_tcp structure takes mac in the reverse order as 
in p_conn. A for loop, or 3 swab16p for each copy would also do, will make 
that change.

> 
> > +		p_tcp->vlan_id = cpu_to_le16(p_conn->vlan_id);
> > +
> > +		p_tcp->flags = p_conn->tcp_flags;
> > +		p_tcp->ip_version = p_conn->ip_version;
> > +		for (i = 0; i < 4; i++) {
> > +			dval = p_conn->remote_ip[i];
> > +			p_tcp->remote_ip[i] = cpu_to_le32(dval);
> > +			dval = p_conn->local_ip[i];
> > +			p_tcp->local_ip[i] = cpu_to_le32(dval);
> > +		}
> > +		p_tcp->ka_max_probe_cnt = p_conn->ka_max_probe_cnt;
> > +		p_tcp->dup_ack_theshold = p_conn->dup_ack_theshold;
> > +
> > +		p_tcp->rcv_next = cpu_to_le32(p_conn->rcv_next);
> > +		p_tcp->snd_una = cpu_to_le32(p_conn->snd_una);
> > +		p_tcp->snd_next = cpu_to_le32(p_conn->snd_next);
> > +		p_tcp->snd_max = cpu_to_le32(p_conn->snd_max);
> > +		p_tcp->snd_wnd = cpu_to_le32(p_conn->snd_wnd);
> > +		p_tcp->rcv_wnd = cpu_to_le32(p_conn->rcv_wnd);
> > +		p_tcp->snd_wl1 = cpu_to_le32(p_conn->snd_wl1);
> > +		p_tcp->cwnd = cpu_to_le32(p_conn->cwnd);
> > +		p_tcp->ss_thresh = cpu_to_le32(p_conn->ss_thresh);
> > +		p_tcp->srtt = cpu_to_le16(p_conn->srtt);
> > +		p_tcp->rtt_var = cpu_to_le16(p_conn->rtt_var);
> > +		p_tcp->ts_time = cpu_to_le32(p_conn->ts_time);
> > +		p_tcp->ts_recent = cpu_to_le32(p_conn->ts_recent);
> > +		p_tcp->ts_recent_age = cpu_to_le32(p_conn->ts_recent_age);
> > +		p_tcp->total_rt = cpu_to_le32(p_conn->total_rt);
> > +		dval = p_conn->ka_timeout_delta;
> > +		p_tcp->ka_timeout_delta = cpu_to_le32(dval);
> > +		dval = p_conn->rt_timeout_delta;
> > +		p_tcp->rt_timeout_delta = cpu_to_le32(dval);
> > +		p_tcp->dup_ack_cnt = p_conn->dup_ack_cnt;
> > +		p_tcp->snd_wnd_probe_cnt = p_conn->snd_wnd_probe_cnt;
> > +		p_tcp->ka_probe_cnt = p_conn->ka_probe_cnt;
> > +		p_tcp->rt_cnt = p_conn->rt_cnt;
> > +		p_tcp->flow_label = cpu_to_le32(p_conn->flow_label);
> > +		p_tcp->ka_timeout = cpu_to_le32(p_conn->ka_timeout);
> > +		p_tcp->ka_interval = cpu_to_le32(p_conn->ka_interval);
> > +		p_tcp->max_rt_time = cpu_to_le32(p_conn->max_rt_time);
> > +		dval = p_conn->initial_rcv_wnd;
> > +		p_tcp->initial_rcv_wnd = cpu_to_le32(dval);
> > +		p_tcp->ttl = p_conn->ttl;
> > +		p_tcp->tos_or_tc = p_conn->tos_or_tc;
> > +		p_tcp->remote_port = cpu_to_le16(p_conn->remote_port);
> > +		p_tcp->local_port = cpu_to_le16(p_conn->local_port);
> > +		p_tcp->mss = cpu_to_le16(p_conn->mss);
> > +		p_tcp->snd_wnd_scale = p_conn->snd_wnd_scale;
> > +		p_tcp->rcv_wnd_scale = p_conn->rcv_wnd_scale;
> > +		dval = p_conn->ts_ticks_per_second;
> > +		p_tcp->ts_ticks_per_second = cpu_to_le32(dval);
> > +		wval = p_conn->da_timeout_value;
> > +		p_tcp->da_timeout_value = cpu_to_le16(wval);
> > +		p_tcp->ack_frequency = p_conn->ack_frequency;
> > +		p_tcp->connect_mode = p_conn->connect_mode;
> > +	} else {
> > +		p_tcp2 =
> > +		    &((struct iscsi_spe_conn_offload_option2 *)p_ramrod)->tcp;
> > +		ucval = p_conn->local_mac[1];
> > +		((u8 *)(&p_tcp2->local_mac_addr_hi))[0] = ucval;
> > +		ucval = p_conn->local_mac[0];
> > +		((u8 *)(&p_tcp2->local_mac_addr_hi))[1] = ucval;
> > +		ucval = p_conn->local_mac[3];
> > +		((u8 *)(&p_tcp2->local_mac_addr_mid))[0] = ucval;
> > +		ucval = p_conn->local_mac[2];
> > +		((u8 *)(&p_tcp2->local_mac_addr_mid))[1] = ucval;
> > +		ucval = p_conn->local_mac[5];
> > +		((u8 *)(&p_tcp2->local_mac_addr_lo))[0] = ucval;
> > +		ucval = p_conn->local_mac[4];
> > +		((u8 *)(&p_tcp2->local_mac_addr_lo))[1] = ucval;
> > +
> > +		ucval = p_conn->remote_mac[1];
> > +		((u8 *)(&p_tcp2->remote_mac_addr_hi))[0] = ucval;
> > +		ucval = p_conn->remote_mac[0];
> > +		((u8 *)(&p_tcp2->remote_mac_addr_hi))[1] = ucval;
> > +		ucval = p_conn->remote_mac[3];
> > +		((u8 *)(&p_tcp2->remote_mac_addr_mid))[0] = ucval;
> > +		ucval = p_conn->remote_mac[2];
> > +		((u8 *)(&p_tcp2->remote_mac_addr_mid))[1] = ucval;
> > +		ucval = p_conn->remote_mac[5];
> > +		((u8 *)(&p_tcp2->remote_mac_addr_lo))[0] = ucval;
> > +		ucval = p_conn->remote_mac[4];
> > +		((u8 *)(&p_tcp2->remote_mac_addr_lo))[1] = ucval;
> > +
> Same here.

Noted.

> 
> > +		p_tcp2->vlan_id = cpu_to_le16(p_conn->vlan_id);

-- snip --

> > diff --git a/drivers/net/ethernet/qlogic/qed/qed_iscsi.h b/drivers/net/ethernet/qlogic/qed/qed_iscsi.h
> > new file mode 100644
> > index 0000000..269848c
> > --- /dev/null
> > +++ b/drivers/net/ethernet/qlogic/qed/qed_iscsi.h
> > @@ -0,0 +1,52 @@
> > +/* QLogic qed NIC Driver
> > + * Copyright (c) 2015 QLogic Corporation
> > + *
> > + * This software is available under the terms of the GNU General Public License
> > + * (GPL) Version 2, available from the file COPYING in the main directory of
> > + * this source tree.
> > + */
> > +
> > +#ifndef _QED_ISCSI_H
> > +#define _QED_ISCSI_H
> > +#include <linux/types.h>
> > +#include <linux/list.h>
> > +#include <linux/slab.h>
> > +#include <linux/spinlock.h>
> > +#include <linux/qed/tcp_common.h>
> > +#include <linux/qed/qed_iscsi_if.h>
> > +#include <linux/qed/qed_chain.h>
> > +#include "qed.h"
> > +#include "qed_hsi.h"
> > +#include "qed_mcp.h"
> > +#include "qed_sp.h"
> > +
> > +struct qed_iscsi_info {
> > +	spinlock_t lock;
> > +	struct list_head free_list;
> > +	u16 max_num_outstanding_tasks;
> > +	void *event_context;
> > +	iscsi_event_cb_t event_cb;
> > +};
> > +
> > +#ifdef CONFIG_QED_LL2
> > +extern const struct qed_ll2_ops qed_ll2_ops_pass;
> > +#endif
> > +
> > +#if IS_ENABLED(CONFIG_QEDI)
> > +struct qed_iscsi_info *qed_iscsi_alloc(struct qed_hwfn *p_hwfn);
> > +
> > +void qed_iscsi_setup(struct qed_hwfn *p_hwfn,
> > +		     struct qed_iscsi_info *p_iscsi_info);
> > +
> > +void qed_iscsi_free(struct qed_hwfn *p_hwfn,
> > +		    struct qed_iscsi_info *p_iscsi_info);
> > +#else /* IS_ENABLED(CONFIG_QEDI) */
> > +static inline struct qed_iscsi_info *qed_iscsi_alloc(
> > +		struct qed_hwfn *p_hwfn) { return NULL; }
> > +static inline void qed_iscsi_setup(struct qed_hwfn *p_hwfn,
> > +		struct qed_iscsi_info *p_iscsi_info) {}
> > +static inline void qed_iscsi_free(struct qed_hwfn *p_hwfn,
> > +		struct qed_iscsi_info *p_iscsi_info) {}
> > +#endif /* IS_ENABLED(CONFIG_QEDI) */
> > +
> > +#endif
> > diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
> > index ddd410a..07e2f77 100644
> > --- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
> > +++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
> > @@ -2187,6 +2187,5 @@ const struct qed_eth_ops *qed_get_eth_ops(void)
> >  
> >  void qed_put_eth_ops(void)
> >  {
> > -	/* TODO - reference count for module? */
> >  }
> >  EXPORT_SYMBOL(qed_put_eth_ops);
> >
> > diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
> > index a6db107..e67f3c9 100644
> > --- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
> > +++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
> > @@ -299,6 +299,7 @@ static void qed_ll2_txq_flush(struct qed_hwfn *p_hwfn, u8 connection_handle)
> >  		p_tx->cur_completing_bd_idx = 1;
> >  		b_last_frag = p_tx->cur_completing_bd_idx == p_pkt->bd_used;
> >  		tx_frag = p_pkt->bds_set[0].tx_frag;
> > +#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
> >  		if (p_ll2_conn->gsi_enable)
> >  			qed_ll2b_release_tx_gsi_packet(p_hwfn,
> >  						       p_ll2_conn->my_id,
> > @@ -307,6 +308,7 @@ static void qed_ll2_txq_flush(struct qed_hwfn *p_hwfn, u8 connection_handle)
> >  						       b_last_frag,
> >  						       b_last_packet);
> >  		else
> > +#endif
> >  			qed_ll2b_complete_tx_packet(p_hwfn,
> >  						    p_ll2_conn->my_id,
> >  						    p_pkt->cookie,
> Huh? What is that doing here?
> 

This is the infiniband part of the common module. The "#if" was to
prevent a compile error when infiniband part was not used (like
for this, iSCSI).

BTW, there is another patch that was submitted by Yuval M. to fix
that, this RFC just came in between. We will be pulling in that
change for the next series.

> > @@ -367,6 +369,7 @@ static int qed_ll2_txq_completion(struct qed_hwfn *p_hwfn, void *p_cookie)
> >  
> >  		spin_unlock_irqrestore(&p_tx->lock, flags);
> >  		tx_frag = p_pkt->bds_set[0].tx_frag;
> > +#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
> >  		if (p_ll2_conn->gsi_enable)
> >  			qed_ll2b_complete_tx_gsi_packet(p_hwfn,
> >  							p_ll2_conn->my_id,
> > @@ -374,6 +377,7 @@ static int qed_ll2_txq_completion(struct qed_hwfn *p_hwfn, void *p_cookie)
> >  							tx_frag,
> >  							b_last_frag, !num_bds);
> >  		else
> > +#endif
> >  			qed_ll2b_complete_tx_packet(p_hwfn,
> >  						    p_ll2_conn->my_id,
> >  						    p_pkt->cookie,
> > @@ -421,6 +425,7 @@ static int qed_ll2_txq_completion(struct qed_hwfn *p_hwfn, void *p_cookie)
> >  			  "Mismatch between active_descq and the LL2 Rx chain\n");
> >  	list_add_tail(&p_pkt->list_entry, &p_rx->free_descq);
> >  
> > +#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
> >  	spin_unlock_irqrestore(&p_rx->lock, lock_flags);
> >  	qed_ll2b_complete_rx_gsi_packet(p_hwfn,
> >  					p_ll2_info->my_id,
> > @@ -433,6 +438,7 @@ static int qed_ll2_txq_completion(struct qed_hwfn *p_hwfn, void *p_cookie)
> >  					src_mac_addrhi,
> >  					src_mac_addrlo, b_last_cqe);
> >  	spin_lock_irqsave(&p_rx->lock, lock_flags);
> > +#endif
> >  
> >  	return 0;
> >  }
> > @@ -1516,11 +1522,12 @@ static void qed_ll2_register_cb_ops(struct qed_dev *cdev,
> >  
> >  static int qed_ll2_start(struct qed_dev *cdev, struct qed_ll2_params *params)
> >  {
> > -	struct qed_ll2_info ll2_info;
> > +	struct qed_ll2_info *ll2_info;
> >  	struct qed_ll2_buffer *buffer;
> >  	enum qed_ll2_conn_type conn_type;
> >  	struct qed_ptt *p_ptt;
> >  	int rc, i;
> > +	u8 gsi_enable = 1;
> >  
> >  	/* Initialize LL2 locks & lists */
> >  	INIT_LIST_HEAD(&cdev->ll2->list);
> > @@ -1552,6 +1559,7 @@ static int qed_ll2_start(struct qed_dev *cdev, struct qed_ll2_params *params)
> >  	switch (QED_LEADING_HWFN(cdev)->hw_info.personality) {
> >  	case QED_PCI_ISCSI:
> >  		conn_type = QED_LL2_TYPE_ISCSI;
> > +		gsi_enable = 0;
> >  		break;
> >  	case QED_PCI_ETH_ROCE:
> >  		conn_type = QED_LL2_TYPE_ROCE;
> > @@ -1561,18 +1569,23 @@ static int qed_ll2_start(struct qed_dev *cdev, struct qed_ll2_params *params)
> >  	}
> >  
> >  	/* Prepare the temporary ll2 information */
> > -	memset(&ll2_info, 0, sizeof(ll2_info));
> > -	ll2_info.conn_type = conn_type;
> > -	ll2_info.mtu = params->mtu;
> > -	ll2_info.rx_drop_ttl0_flg = params->drop_ttl0_packets;
> > -	ll2_info.rx_vlan_removal_en = params->rx_vlan_stripping;
> > -	ll2_info.tx_tc = 0;
> > -	ll2_info.tx_dest = CORE_TX_DEST_NW;
> > -	ll2_info.gsi_enable = 1;
> > -
> > -	rc = qed_ll2_acquire_connection(QED_LEADING_HWFN(cdev), &ll2_info,
> > +	ll2_info = kzalloc(sizeof(*ll2_info), GFP_KERNEL);
> > +	if (!ll2_info) {
> > +		DP_INFO(cdev, "Failed to allocate LL2 info buffer\n");
> > +		goto fail;
> > +	}
> > +	ll2_info->conn_type = conn_type;
> > +	ll2_info->mtu = params->mtu;
> > +	ll2_info->rx_drop_ttl0_flg = params->drop_ttl0_packets;
> > +	ll2_info->rx_vlan_removal_en = params->rx_vlan_stripping;
> > +	ll2_info->tx_tc = 0;
> > +	ll2_info->tx_dest = CORE_TX_DEST_NW;
> > +	ll2_info->gsi_enable = gsi_enable;
> > +
> > +	rc = qed_ll2_acquire_connection(QED_LEADING_HWFN(cdev), ll2_info,
> >  					QED_LL2_RX_SIZE, QED_LL2_TX_SIZE,
> >  					&cdev->ll2->handle);
> > +	kfree(ll2_info);
> >  	if (rc) {
> >  		DP_INFO(cdev, "Failed to acquire LL2 connection\n");
> >  		goto fail;
> Where is the benefit of this hunk? And is it related to iSCSI?

This hunk was to prevent a large stack warning (was present with
gcc 4.8.3). This is a common function applicable to iSCSI as well.

> 
> > diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
> > index 4ee3151..a01ad9d 100644
> > --- a/drivers/net/ethernet/qlogic/qed/qed_main.c
> > +++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
> > @@ -1239,7 +1239,6 @@ static void qed_fill_link(struct qed_hwfn *hwfn,
> >  	if (link.link_up)
> >  		if_link->link_up = true;
> >  
> > -	/* TODO - at the moment assume supported and advertised speed equal */
> >  	if_link->supported_caps = QED_LM_FIBRE_BIT;
> >  	if (params.speed.autoneg)
> >  		if_link->supported_caps |= QED_LM_Autoneg_BIT;
> > @@ -1294,7 +1293,6 @@ static void qed_fill_link(struct qed_hwfn *hwfn,
> >  	if (link.link_up)
> >  		if_link->speed = link.speed;
> >  
> > -	/* TODO - fill duplex properly */
> >  	if_link->duplex = DUPLEX_FULL;
> >  	qed_mcp_get_media_type(hwfn->cdev, &media_type);
> >  	if_link->port = qed_get_port_type(media_type);
> > diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
> > index dff520e..2e5f51b 100644
> > --- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
> > +++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
> > @@ -314,9 +314,6 @@ int qed_mcp_bist_clock_test(struct qed_hwfn *p_hwfn,
> >  
> >  /* Using hwfn number (and not pf_num) is required since in CMT mode,
> >   * same pf_num may be used by two different hwfn
> > - * TODO - this shouldn't really be in .h file, but until all fields
> > - * required during hw-init will be placed in their correct place in shmem
> > - * we need it in qed_dev.c [for readin the nvram reflection in shmem].
> >   */
> >  #define MCP_PF_ID_BY_REL(p_hwfn, rel_pfid) (QED_IS_BB((p_hwfn)->cdev) ?	       \
> >  					    ((rel_pfid) |		       \
> > @@ -324,9 +321,6 @@ int qed_mcp_bist_clock_test(struct qed_hwfn *p_hwfn,
> >  					    rel_pfid)
> >  #define MCP_PF_ID(p_hwfn) MCP_PF_ID_BY_REL(p_hwfn, (p_hwfn)->rel_pf_id)
> >  
> > -/* TODO - this is only correct as long as only BB is supported, and
> > - * no port-swapping is implemented; Afterwards we'll need to fix it.
> > - */
> >  #define MFW_PORT(_p_hwfn)       ((_p_hwfn)->abs_pf_id %	\
> >  				 ((_p_hwfn)->cdev->num_ports_in_engines * 2))
> >  struct qed_mcp_info {
> Please split off the patch and use a separate one to remove all the TODO
> entries. They do not relate to the iSCSI offload bit.
> 

Will do.

> > diff --git a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
> > index b414a05..9754420 100644
> > --- a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
> > +++ b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
> > @@ -82,6 +82,8 @@
> >  	0x1c80000UL
> >  #define BAR0_MAP_REG_XSDM_RAM \
> >  	0x1e00000UL
> > +#define BAR0_MAP_REG_YSDM_RAM \
> > +	0x1e80000UL
> >  #define  NIG_REG_RX_LLH_BRB_GATE_DNTFWD_PERPF \
> >  	0x5011f4UL
> >  #define  PRS_REG_SEARCH_TCP \
> > diff --git a/drivers/net/ethernet/qlogic/qed/qed_spq.c b/drivers/net/ethernet/qlogic/qed/qed_spq.c
> > index caff415..d3fa578 100644
> > --- a/drivers/net/ethernet/qlogic/qed/qed_spq.c
> > +++ b/drivers/net/ethernet/qlogic/qed/qed_spq.c
> > @@ -24,6 +24,7 @@
> >  #include "qed_hsi.h"
> >  #include "qed_hw.h"
> >  #include "qed_int.h"
> > +#include "qed_iscsi.h"
> >  #include "qed_mcp.h"
> >  #include "qed_reg_addr.h"
> >  #include "qed_sp.h"
> > @@ -249,6 +250,20 @@ static int qed_spq_hw_post(struct qed_hwfn *p_hwfn,
> >  		return qed_sriov_eqe_event(p_hwfn,
> >  					   p_eqe->opcode,
> >  					   p_eqe->echo, &p_eqe->data);
> > +	case PROTOCOLID_ISCSI:
> > +		if (!IS_ENABLED(CONFIG_QEDI))
> > +			return -EINVAL;
> > +
> > +		if (p_hwfn->p_iscsi_info->event_cb) {
> > +			struct qed_iscsi_info *p_iscsi = p_hwfn->p_iscsi_info;
> > +
> > +			return p_iscsi->event_cb(p_iscsi->event_context,
> > +						 p_eqe->opcode, &p_eqe->data);
> > +		} else {
> > +			DP_NOTICE(p_hwfn,
> > +				  "iSCSI async completion is not set\n");
> > +			return -EINVAL;
> > +		}
> >  	default:
> >  		DP_NOTICE(p_hwfn,
> >  			  "Unknown Async completion for protocol: %d\n",
> > diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
> > index f9ae903..c0c9fa8 100644
> > --- a/include/linux/qed/qed_if.h
> > +++ b/include/linux/qed/qed_if.h
> > @@ -165,6 +165,7 @@ struct qed_iscsi_pf_params {
> >  	u32 max_cwnd;
> >  	u16 cq_num_entries;
> >  	u16 cmdq_num_entries;
> > +	u32 two_msl_timer;
> >  	u16 dup_ack_threshold;
> >  	u16 tx_sws_timer;
> >  	u16 min_rto;
> > @@ -271,6 +272,7 @@ struct qed_dev_info {
> >  enum qed_sb_type {
> >  	QED_SB_TYPE_L2_QUEUE,
> >  	QED_SB_TYPE_CNQ,
> > +	QED_SB_TYPE_STORAGE,
> >  };
> >  
> >  enum qed_protocol {
> > diff --git a/include/linux/qed/qed_iscsi_if.h b/include/linux/qed/qed_iscsi_if.h
> > new file mode 100644
> > index 0000000..6735ee5
> > --- /dev/null
> > +++ b/include/linux/qed/qed_iscsi_if.h
> > @@ -0,0 +1,249 @@
> > +/* QLogic qed NIC Driver
> Again, this is the iSCSI driver, is it not?
> 
> > + * Copyright (c) 2015 QLogic Corporation
> > + *
> And you _might_ want to check the copyright, seeing that it's being
> posted from the cavium.com domain ...
> 

Yes, rest of the files (already existing) for qed has the same
copyright, so this patch did not modify it. qedi, OTOH, has all
new files and are using the updated ones. A new patch will be
posted to update the qed files.

Regards,
-Arun
