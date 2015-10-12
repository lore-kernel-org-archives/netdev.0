From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next v5 01/10] qed: Add module with basic common
 support
Date: Tue, 13 Oct 2015 01:07:50 +0200
Message-ID: <20151012230750.GA7378@electric-eye.fr.zoreil.com>
References: <1444674622-13059-1-git-send-email-Yuval.Mintz@qlogic.com>
 <1444674622-13059-2-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43365 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777AbbJLXI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 19:08:26 -0400
Content-Disposition: inline
In-Reply-To: <1444674622-13059-2-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yuval Mintz <Yuval.Mintz@qlogic.com> :
> The Qlogic Everest Driver is the backend module for the 579xx ethernet
> products by Qlogic.
> 
> This module serves two main purposes:
>  1. It's responsible to contain all the common code that will be shared
>     between the various drivers that would be used with said line of
>     products. Flows such as chip initialization and de-initialization
>     fall under this category.
> 
>  2. It would abstract the protocol-specific HW & FW components, allowing
>     the protocol drivers to have a clean APIs which is detached in its
>     slowpath configuration from the actual HSI.
> 
> This adds a very basic module without any protocol-specific bits.
> I.e., this adds a basic implementation that almost entirely falls under
> the first category.

500 ko of a basic something is mildly reviewable for mere mortals.

[...]
> diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
> new file mode 100644
> index 0000000..f9f01bb
> --- /dev/null
> +++ b/drivers/net/ethernet/qlogic/qed/qed.h
[...]
> +/* helpers */
> +static inline u32 DB_ADDR(u32	cid,
> +			  u32	DEMS)

static inline u32 DB_ADDR(u32 cid, u32 DEMS)

[...]
> +/* forward */
> +struct qed_ptt_pool;
> +struct qed_spq;
> +struct qed_sb_info;
> +struct qed_sb_attn_info;
> +struct qed_cxt_mngr;
> +struct qed_sb_sp_info;
> +struct qed_mcp_info;

Many forward. Dependencies hell ?

[...]
> +struct qed_simd_fp_handler {
> +	void	*token;
> +	void	(*func)(void *);
> +};

Use union * ?

[...]
> diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.c b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
> new file mode 100644
> index 0000000..4acc053
> --- /dev/null
> +++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
[...]
> +	qed_ilt_cli_blk_fill(p_cli,
> +			     p_blk,
> +			     curr_line,
> +			     total,
> +			     CONN_CXT_SIZE(p_hwfn));

	qed_ilt_cli_blk_fill(p_cli, p_blk, curr_line, total, CONN_CXT_SIZE(p_hwfn));

s/p_// and it fits in 80 cols.

[...]
> +static int qed_ilt_shadow_alloc(struct qed_hwfn *p_hwfn)
> +{
> +	struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
> +	struct qed_ilt_client_cfg *clients = p_mngr->clients;
> +	struct qed_ilt_cli_blk *p_blk;
> +	u32 size, i, j;
> +	int rc;
> +
> +	size = qed_cxt_ilt_shadow_size(clients);
> +	p_mngr->ilt_shadow = kcalloc(size, sizeof(struct qed_dma_mem),
> +				     GFP_KERNEL);
> +	if (!p_mngr->ilt_shadow) {
> +		DP_NOTICE(p_hwfn, "Failed to allocate ilt shadow table\n");
> +		rc = -ENOMEM;
> +		goto ilt_shadow_fail;
> +	} else {
> +		DP_VERBOSE(p_hwfn, QED_MSG_ILT,
> +			   "Allocated 0x%x bytes for ilt shadow\n",
> +			   (u32)(size * sizeof(struct qed_dma_mem)));
> +	}

The "else" branch after the "goto" isn't idiomatic.

[...]
> diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
> new file mode 100644
> index 0000000..14366af
> --- /dev/null
> +++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
[...]
> +void qed_init_struct(struct qed_dev *cdev)
> +{
> +	u8 i;
> +
> +	for (i = 0; i < MAX_HWFNS_PER_DEVICE; i++) {
> +		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
> +
> +		p_hwfn->cdev		= cdev;
> +		p_hwfn->my_id		= i;
> +		p_hwfn->b_active	= false;
> +
> +		;

; ?


[...]
> +static int qed_init_qm_info(struct qed_hwfn *p_hwfn)
> +{
> +	struct qed_qm_info *qm_info = &p_hwfn->qm_info;
> +	struct init_qm_port_params *p_qm_port;
> +	u8 num_vports, i, vport_id, num_ports;
> +	u16 num_pqs, multi_cos_tcs = 1;
> +
> +	memset(qm_info, 0, sizeof(*qm_info));
> +
> +	num_pqs = multi_cos_tcs + 1; /* The '1' is for pure-LB */
> +	num_vports = (u8)RESC_NUM(p_hwfn, QED_VPORT);
> +
> +	/* Sanity checking that setup requires legal number of resources */
> +	if (num_pqs > RESC_NUM(p_hwfn, QED_PQ)) {
> +		DP_ERR(p_hwfn,
> +		       "Need too many Physical queues - 0x%04x when only %04x are available\n",
> +		       num_pqs, RESC_NUM(p_hwfn, QED_PQ));
> +		return -EINVAL;
> +	}
> +
> +	/* PQs will be arranged as follows: First per-TC PQ then pure-LB quete.
> +	 */
> +	qm_info->qm_pq_params = kzalloc(sizeof(*qm_info->qm_pq_params) *
> +					num_pqs, GFP_ATOMIC);


qed_init_qm_info is only used in qed_resc_alloc. qed_resc_alloc performs
GFP_KERNEL alloc and qed_resc_alloc does not use qed_init_qm_info in
a spinlocked section. I would thus expect both to use the same allocation
flag.

[...]
> +int qed_resc_alloc(struct qed_dev *cdev)
> +{
> +	struct qed_consq *p_consq;
> +	struct qed_eq *p_eq;
> +	int i, rc = 0;
> +
> +	cdev->fw_data = kzalloc(sizeof(*cdev->fw_data), GFP_KERNEL);
> +	if (!cdev->fw_data)
> +		return -ENOMEM;
> +
[...]
> +	cdev->reset_stats = kzalloc(sizeof(*cdev->reset_stats), GFP_ATOMIC);

GFP_{KERNEL / ATOMIC} but the context is the same.

[...]
> +++ b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
> diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
> new file mode 100644
> index 0000000..cbb0c1c
> --- /dev/null
> +++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
> @@ -0,0 +1,5040 @@
> +/* QLogic qed NIC Driver
> + * Copyright (c) 2015 QLogic Corporation
> + *
> + * This software is available under the terms of the GNU General Public License
> + * (GPL) Version 2, available from the file COPYING in the main directory of
> + * this source tree.
> + */
[...]
> +/****************************************************************************
> +* Copyright(c) 2015 Qlogic Corporation, all rights reserved
> +* Proprietary and Confidential Information.
> +*
> +* This source file is the property of Qlogic Corporation, and
> +* may not be copied or distributed in any isomorphic form without
> +* the prior written consent of Qlogic Corporation.

Oops.

[...]
> diff --git a/drivers/net/ethernet/qlogic/qed/qed_hw.c b/drivers/net/ethernet/qlogic/qed/qed_hw.c
> new file mode 100644
> index 0000000..1512b72
> --- /dev/null
> +++ b/drivers/net/ethernet/qlogic/qed/qed_hw.c
[...]
> +int qed_dmae_info_alloc(struct qed_hwfn *p_hwfn)
> +{
> +	dma_addr_t *p_addr = &p_hwfn->dmae_info.completion_word_phys_addr;
> +	struct dmae_cmd **p_cmd	= &p_hwfn->dmae_info.p_dmae_cmd;
> +	u32 **p_buff = &p_hwfn->dmae_info.p_intermediate_buffer;
> +	u32 **p_comp = &p_hwfn->dmae_info.p_completion_word;
> +
> +	*p_comp = dma_alloc_coherent(&p_hwfn->cdev->pdev->dev,
> +				     sizeof(u32),
> +				     p_addr,
> +				     GFP_KERNEL);
> +	if (!*p_comp) {
> +		DP_NOTICE(p_hwfn, "Failed to allocate `p_completion_word'\n");
> +		qed_dmae_info_free(p_hwfn);
> +		return -ENOMEM;
> +	}
> +
> +	p_addr = &p_hwfn->dmae_info.dmae_cmd_phys_addr;
> +	*p_cmd = dma_alloc_coherent(&p_hwfn->cdev->pdev->dev,
> +				    sizeof(struct dmae_cmd),
> +				    p_addr, GFP_KERNEL);
> +	if (!*p_cmd) {
> +		DP_NOTICE(p_hwfn, "Failed to allocate `struct dmae_cmd'\n");
> +		qed_dmae_info_free(p_hwfn);
> +		return -ENOMEM;
> +	}
> +
> +	p_addr	= &p_hwfn->dmae_info.intermediate_buffer_phys_addr;
> +	*p_buff = dma_alloc_coherent(&p_hwfn->cdev->pdev->dev,
> +				     sizeof(u32) * DMAE_MAX_RW_SIZE,
> +				     p_addr, GFP_KERNEL);
> +	if (!*p_buff) {
> +		DP_NOTICE(p_hwfn, "Failed to allocate `intermediate_buffer'\n");
> +		qed_dmae_info_free(p_hwfn);
> +		return -ENOMEM;
> +	}

"qed_dmae_info_free(p_hwfn); ... return -ENOMEM;" is repeated three times.

[...]
> diff --git a/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c b/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
> new file mode 100644
> index 0000000..c622ffb
> --- /dev/null
> +++ b/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
[...]
> +/* Prepare Tx PQ mapping runtime init values for the specified PF */
> +static void qed_tx_pq_map_rt_init(
> +	struct qed_hwfn			*p_hwfn,
> +	struct qed_ptt			*p_ptt,
> +	u8				port_id,
> +	u8				pf_id,
> +	u8
> +	max_phys_tcs_per_port,
> +	bool				is_first_pf,
> +	u32				num_pf_cids,
> +	u32				num_vf_cids,
> +	u16				start_pq,
> +	u16				num_pf_pqs,
> +	u16				num_vf_pqs,
> +	u8				start_vport,
> +	u32
> +	base_mem_addr_4kb,
> +	struct init_qm_pq_params	*pq_params,
> +	struct init_qm_vport_params	*vport_params)
> +{
> +	u16	i, pq_id, pq_group;
> +	u16	num_pqs		= num_pf_pqs + num_vf_pqs;
> +	u16	first_pq_group	= start_pq / QM_PF_QUEUE_GROUP_SIZE;
> +	u16	last_pq_group	=
> +		(start_pq + num_pqs - 1) / QM_PF_QUEUE_GROUP_SIZE;
> +	bool	is_bb_a0 = QED_IS_BB_A0(p_hwfn->cdev);
> +
> +	/* a bit per Tx PQ indicating if the PQ is associated with a VF */
> +	u32	tx_pq_vf_mask[MAX_QM_TX_QUEUES /
> +			      QM_PF_QUEUE_GROUP_SIZE] = { 0 };
> +	u32	tx_pq_vf_mask_width
> +		= is_bb_a0 ? 32 : QM_PF_QUEUE_GROUP_SIZE;
> +	u32	num_tx_pq_vf_masks
> +		= MAX_QM_TX_QUEUES / tx_pq_vf_mask_width;
> +	u32	pq_mem_4kb
> +		= QM_PQ_MEM_4KB(num_pf_cids);
> +	u32	vport_pq_mem_4kb
> +		= QM_PQ_MEM_4KB(num_vf_cids);
> +	u32	mem_addr_4kb
> +		= base_mem_addr_4kb;

Broken style.

> +
> +	/* set mapping from PQ group to PF */
> +	for (pq_group = first_pq_group; pq_group <= last_pq_group; pq_group++)
> +		STORE_RT_REG(p_hwfn, QM_REG_PQTX2PF_0_RT_OFFSET + pq_group,
> +			     (u32)(pf_id));
> +	/* set PQ sizes */
> +	STORE_RT_REG(p_hwfn, QM_REG_MAXPQSIZE_0_RT_OFFSET,
> +		     QM_PQ_SIZE_256B(num_pf_cids));
> +	STORE_RT_REG(p_hwfn, QM_REG_MAXPQSIZE_1_RT_OFFSET,
> +		     QM_PQ_SIZE_256B(num_vf_cids));
> +	/* go over all Tx PQs */
> +	for (i = 0, pq_id = start_pq; i < num_pqs; i++, pq_id++) {
> +		struct qm_rf_pq_map	tx_pq_map;
> +		u8			voq	= VOQ(port_id,
> +						      pq_params[i].tc_id,
> +						      max_phys_tcs_per_port);
> +		bool	is_vf_pq		= (i >= num_pf_pqs);
> +
> +		/* update first Tx PQ of VPORT/TC */
> +		u8	vport_id_in_pf =
> +			pq_params[i].vport_id - start_vport;
> +		u16	first_tx_pq_id =
> +			vport_params[vport_id_in_pf].first_tx_pq_id[pq_params[i]
> +								    .tc_id];
> +		if (first_tx_pq_id == QM_INVALID_PQ_ID) {
> +			/* create new VP PQ */
> +			vport_params[vport_id_in_pf].first_tx_pq_id[pq_params[i]
> +								    .tc_id] =
> +				pq_id;

Imho you won't avoid moving the body of the "for" loop in its own helper.

[...]
> diff --git a/drivers/net/ethernet/qlogic/qed/qed_spq.c b/drivers/net/ethernet/qlogic/qed/qed_spq.c
> new file mode 100644
> index 0000000..9dcc02f
> --- /dev/null
> +++ b/drivers/net/ethernet/qlogic/qed/qed_spq.c
[...]
> +int
> +qed_spq_get_entry(struct qed_hwfn	*p_hwfn,
> +		  struct qed_spq_entry	**pp_ent)
> +{
> +	struct qed_spq		*p_spq	= p_hwfn->p_spq;
> +	struct qed_spq_entry	*p_ent	= NULL;
> +
> +	spin_lock_bh(&p_spq->lock);
> +
> +	if (list_empty(&p_spq->free_pool)) {
> +		p_ent = kzalloc(sizeof(*p_ent), GFP_ATOMIC);
> +		if (!p_ent) {
> +			spin_unlock_bh(&p_spq->lock);
> +			return -ENOMEM;

Nit:
			rc = -ENOMEM;
			goto out_unlock;

-- 
Ueimor
