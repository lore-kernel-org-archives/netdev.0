From: "Anil Veerabhadrappa" <anilgv@broadcom.com>
Subject: Re: [RFC Resend 3/3][BNX2]: Add iSCSI support to BNX2 devices.
Date: Sun, 05 Aug 2007 17:04:25 -0700
Message-ID: <1186358665.11820.29.camel@localhost.localdomain>
References: <1186200229.18322.97.camel@dell>
 <46B43D2D.2090800@garzik.org> <1186273141.4806.4.camel@dell>
 <20070805022858.GG2469@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>,
	"Jeff Garzik" <jeff@garzik.org>,
	"David Miller" <davem@davemloft.net>, mchristi@redhat.com,
	"netdev" <netdev@vger.kernel.org>, open-iscsi@googlegroups.com,
	talm@broadcom.com, lusinsky@broadcom.com, uri@broadcom.com
To: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4322 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750846AbXHFABh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Aug 2007 20:01:37 -0400
In-Reply-To: <20070805022858.GG2469@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-08-04 at 23:28 -0300, Arnaldo Carvalho de Melo wrote:
> There is at least one bug, please check it and the other suggestions,
> 
> Thanks,
> 
> - Arnaldo
> 
> Em Sat, Aug 04, 2007 at 05:19:01PM -0700, Michael Chan escreveu:
> > diff --git a/drivers/scsi/bnx2i/bnx2i_iscsi.c b/drivers/scsi/bnx2i/bnx2i_iscsi.c
> > new file mode 100644
> > index 0000000..0576e1b
> > --- /dev/null
> > +++ b/drivers/scsi/bnx2i/bnx2i_iscsi.c
> > @@ -0,0 +1,3718 @@
> > +/* bnx2i_iscsi.c: Broadcom NetXtreme II iSCSI driver.
> > +
> > + *
> > + * Copyright (c) 2004, 2005, 2006 Broadcom Corporation
> > + *
> > + * This program is free software; you can redistribute it and/or modify
> > + * it under the terms of the GNU General Public License as published by
> > + * the Free Software Foundation.
> > + *
> > + * Written by: Anil Veerabhadrappa (anilgv@broadcom.com)
> > + */
> > +
> > +#include "bnx2i.h"
> > +
> > +struct scsi_host_template bnx2i_host_template;
> > +struct iscsi_transport bnx2i_iscsi_transport;
> > +
> > +/*
> > + * Global endpoint resource info
> > + */
> > +void *bnx2i_ep_pages[MAX_PAGES_PER_CTRL_STRUCT_POOL];
> > +struct list_head bnx2i_free_ep_list;
> > +struct list_head bnx2i_unbound_ep;
> > +u32 bnx2i_num_free_ep;
> > +u32 bnx2i_max_free_ep;
> > +spinlock_t bnx2i_resc_lock;
> 
> static DEFINE_SPINLOCK(bnx2i_resc_lock);
> 
> I guess the other variables can also be marked static
> 
> > +struct tcp_port_mngt bnx2i_tcp_port_tbl;
> > +static u16 bnx2i_local_tcp_port = 63000;
> > +
> > +
> > +static struct io_bdt *bnx2i_alloc_bd_table(struct bnx2i_sess *sess,
> > +					   struct bnx2i_cmd *);
> > +static void bnx2i_free_tcp_port(u16 port);
> > +static u16 bnx2i_alloc_tcp_port(void);
> > +
> > +
> > +static int bnx2i_adapter_ready(struct bnx2i_hba *hba)
> > +{
> > +	int retval = 0;
> > +
> > +	if (!hba || !test_bit(ADAPTER_STATE_UP, &hba->adapter_state) ||
> > +	    test_bit(ADAPTER_STATE_GOING_DOWN, &hba->adapter_state))
> > +		retval = -EPERM;
> > +	return retval;
> > +}
> > +
> > +/*
> > + * identifies & marks various bd info for imm data, unsolicited data
> > + *	and the first solicited data seq.
> > + */
> > +static void bnx2i_get_write_cmd_bd_idx(struct bnx2i_cmd *cmd, u32 buf_off,
> > +				       u32 *start_bd_off, u32 *start_bd_idx)
> > +{
> > +	u32 cur_offset = 0;
> > +	u32 cur_bd_idx = 0;
> > +	struct iscsi_bd *bd_tbl = cmd->bd_tbl->bd_tbl;
> > +
> > +	if (buf_off) {
> > +		while (buf_off >= (cur_offset + bd_tbl->buffer_length)) {
> > +			cur_offset += bd_tbl->buffer_length;
> > +			cur_bd_idx++;
> > +			bd_tbl++;
> > +		}
> > +	}
> > +
> > +	*start_bd_off = buf_off - cur_offset;
> > +	*start_bd_idx = cur_bd_idx;
> > +}
> > +
> > +/*
> > + * identifies & marks various bd info for immediate data,
> > + *	unsolicited data and first solicited data seq.
> > + */
> > +static void bnx2i_setup_write_cmd_bd_info(struct bnx2i_cmd *cmd)
> > +{
> > +	struct bnx2i_conn *conn = NULL;
> > +	struct bnx2i_sess *sess = NULL;
> > +	u32 start_bd_offset = 0;
> > +	u32 start_bd_idx = 0;
> > +	u32 buffer_offset = 0;
> > +	u32 seq_len = 0;
> > +	u32 fbl = 0, mrdsl = 0;
> > +	u32 cmd_len = cmd->req.total_data_transfer_length;
> > +
> > +	if (cmd)
> > +		conn = cmd->conn;
> > +	if (conn->sess)
> > +		sess = conn->sess;
> > +
> > +	/* if ImmediateData is turned off & IntialR2T is turned on,
> > +	 * there will be no immediate or unsolicited data, just return.
> > +	 */
> > +	if (sess->initial_r2t && !sess->imm_data) {
> > +		return;
> > +	}
> > +	fbl = sess->first_burst_len;
> > +	mrdsl = conn->max_data_seg_len_xmit;
> > +
> > +	/* Immediate data */
> > +	if (sess->imm_data) {
> > +		seq_len = min(mrdsl, fbl);
> > +		seq_len = min(cmd_len, seq_len);
> > +		buffer_offset += seq_len;
> > +	}
> > +	if (seq_len == cmd_len) {
> > +		return;
> > +	}
> > +
> > +	if (!sess->initial_r2t) {
> > +		if (seq_len >= fbl)
> > +			goto r2t_data;
> > +		seq_len = min(fbl, cmd_len) - seq_len;
> > +		bnx2i_get_write_cmd_bd_idx(cmd, buffer_offset,
> > +					   &start_bd_offset, &start_bd_idx);
> > +		cmd->req.ud_buffer_offset = start_bd_offset;
> > +		cmd->req.ud_start_bd_index = start_bd_idx;
> > +		buffer_offset += seq_len;
> > +	}
> > +r2t_data:
> > +	if (buffer_offset != cmd_len) {
> > +		bnx2i_get_write_cmd_bd_idx(cmd, buffer_offset,
> > +					   &start_bd_offset, &start_bd_idx);
> > +		if ((start_bd_offset > fbl) ||
> > +		    (start_bd_idx > cmd->scsi_cmd->use_sg)) {
> > +			int i = 0;
> > +
> > +			printk(KERN_ALERT "bnx2i- error, buf offset 0x%x "
> > +					  "bd_valid %d use_sg %d\n",
> > +					  buffer_offset, cmd->bd_tbl->bd_valid,
> > +					  cmd->scsi_cmd->use_sg);
> > +			for (i = 0; i < cmd->bd_tbl->bd_valid; i++)
> > +				printk(KERN_ALERT "bnx2i err, bd[%d]: len %x\n",
> > +						  i, cmd->bd_tbl->bd_tbl[i].\
> > +						  buffer_length);
> > +		}
> > +		cmd->req.sd_buffer_offset = start_bd_offset;
> > +		cmd->req.sd_start_bd_index = start_bd_idx;
> > +	}
> > +}
> > +
> > +
> > +/*
> > + */
> > +static int bnx2i_split_bd(struct bnx2i_cmd *cmd, u64 addr, int sg_len,
> > +			  int bd_index)
> > +{
> > +	struct iscsi_bd *bd = cmd->bd_tbl->bd_tbl;
> > +	int frag_size = 0, sg_frags = 0;
> > +
> > +	while (sg_len) {
> > +		if (sg_len >= BD_SPLIT_SIZE)
> > +			frag_size = BD_SPLIT_SIZE;
> > +		else
> > +			frag_size = sg_len;
> > +		bd[bd_index + sg_frags].buffer_addr_lo = (u32) addr;
> > +		bd[bd_index + sg_frags].buffer_addr_hi = addr >> 32;
> > +		bd[bd_index + sg_frags].buffer_length = frag_size;
> > +		bd[bd_index + sg_frags].flags = 0;
> > +		if ((bd_index + sg_frags) == 0)
> > +			bd[0].flags = ISCSI_BD_FIRST_IN_BD_CHAIN;
> > +		addr += (u64) frag_size;
> > +		sg_frags++;
> > +		sg_len -= frag_size;
> > +	}
> > +	return sg_frags;
> > +}
> > +
> > +
> > +/*
> > + * map single buffer
> > + */
> > +static int bnx2i_map_single_buf(struct bnx2i_hba *hba,
> > +				       struct bnx2i_cmd *cmd)
> > +{
> > +	struct scsi_cmnd *sc = cmd->scsi_cmd;
> > +	struct iscsi_bd *bd = cmd->bd_tbl->bd_tbl;
> > +	int byte_count = 0;
> 
> Why set byte_count to 0...
yes, not necessary

> 
> > +	int bd_count = 0;
> > +	u64 addr;
> > +
> > +	byte_count = sc->request_bufflen;
> 
> ... when you imediately set it to something else?
right

> 
> > +	sc->SCp.dma_handle =
> > +		pci_map_single(hba->pci_dev, sc->request_buffer,
> > +			       sc->request_bufflen, sc->sc_data_direction);
> > +	addr = sc->SCp.dma_handle;
> > +
> > +	if (byte_count > MAX_BD_LENGTH) {
> > +		bd_count = bnx2i_split_bd(cmd, addr, byte_count, 0);
> > +	} else {
> > +		bd_count = 1;
> Ditto for bd_count
yes, initialization is not necessary

> 
> > +		bd[0].buffer_addr_lo = addr & 0xffffffff;
> > +		bd[0].buffer_addr_hi = addr >> 32;
> > +		bd[0].buffer_length = sc->request_bufflen;
> > +		bd[0].flags = ISCSI_BD_FIRST_IN_BD_CHAIN |
> > +			      ISCSI_BD_LAST_IN_BD_CHAIN;
> > +	}
> > +	bd[bd_count - 1].flags |= ISCSI_BD_LAST_IN_BD_CHAIN;
> > +
> > +	return bd_count;
> > +}
> > +
> > +
> > +/*
> > + * map SG list
> > + */
> > +static int bnx2i_map_sg(struct bnx2i_hba *hba, struct bnx2i_cmd *cmd)
> > +{
> > +	struct scsi_cmnd *sc = cmd->scsi_cmd;
> > +	struct iscsi_bd *bd = cmd->bd_tbl->bd_tbl;
> > +	struct scatterlist *sg;
> > +	int byte_count = 0;
> > +	int sg_frags = 0;
> > +	int bd_count = 0;
> > +	int sg_count = 0;
> > +	int sg_len;
> > +	u64 addr;
> > +	int i;
> > +
> > +	sg = (struct scatterlist *) sc->request_buffer;
> Needless cast, scsi_cmnd->request_buffer is a void pointer.
ok

> 
> > +
> > +	sg_count = pci_map_sg(hba->pci_dev, sg, sc->use_sg,
> > +			      sc->sc_data_direction);
> > +
> > +	for (i = 0; i < sg_count; i++) {
> > +		sg_len = sg_dma_len(sg);
> > +		addr = sg_dma_address(sg);
> > +		if (sg_len > MAX_BD_LENGTH) {
> > +			sg_frags = bnx2i_split_bd(cmd, addr, sg_len,
> > +						  bd_count);
> > +		} else {
> > +			sg_frags = 1;
> > +			bd[bd_count].buffer_addr_lo = addr & 0xffffffff;
> > +			bd[bd_count].buffer_addr_hi = addr >> 32;
> > +			bd[bd_count].buffer_length = sg_len;
> > +			bd[bd_count].flags = 0;
> > +			if (bd_count == 0)
> > +				bd[bd_count].flags =
> > +					ISCSI_BD_FIRST_IN_BD_CHAIN;
> > +		}
> > +		byte_count += sg_len;
> > +		sg++;
> > +		bd_count += sg_frags;
> > +	}
> > +	bd[bd_count - 1].flags |= ISCSI_BD_LAST_IN_BD_CHAIN;
> > +
> > +	BUG_ON(byte_count != sc->request_bufflen);
> > +	return bd_count;
> > +}
> > +
> > +/*
> > + * creates BD list table for the command
> > + */
> > +static int bnx2i_iscsi_map_sg_list(struct bnx2i_cmd *cmd)
> > +{
> > +	struct bnx2i_hba *hba = cmd->conn->sess->hba;
> > +	struct scsi_cmnd *sc = cmd->scsi_cmd;
> > +	int bd_count = 0;
> > +
> > +	if (sc->use_sg)
> > +		bd_count = bnx2i_map_sg(hba, cmd);
> > +	else if (sc->request_bufflen)
> > +		bd_count = bnx2i_map_single_buf(hba, cmd);
> > +	else {
> > +		struct iscsi_bd *bd = cmd->bd_tbl->bd_tbl;
> > +		bd_count  = 0;
> 
> No need to set bd_count to zero, you already did it when declaring,
> remove this one or the one at declaration time, above.
ok

> 
> > +		bd[0].buffer_addr_lo = bd[0].buffer_addr_hi = 0;
> > +		bd[0].buffer_length = bd[0].flags = 0;
> > +	}
> > +	cmd->bd_tbl->bd_valid = bd_count;
> > +	return 0;
> > +}
> > +
> > +
> > +/*
> > + * create BD list table for the command
> > + */
> > +int bnx2i_iscsi_unmap_sg_list(struct bnx2i_cmd *cmd)
> > +{
> > +	struct bnx2i_hba *hba = cmd->conn->sess->hba;
> > +	struct scsi_cmnd *sc = cmd->scsi_cmd;
> > +	struct pci_dev *pdev = hba->pci_dev;
> 
> Why do you declare pdev, and initialize it, here? It is only needed
> if...
was trying to avoid multiple pointer referencing in fast path. you are
right, irrespective of code path taken there will be only one reference
to 'hba->pci_dev'. will be removed!!

> 
> > +	struct scatterlist *sg;
> > +
> > +	if (cmd->bd_tbl->bd_valid && sc) {
> 
> ... this condition is true, so it should be declared/initialized here
> 
> > +		if (sc->use_sg) {
> 
> and the sg variable should be declared here, where it is needed.
> 
> > +			sg = (struct scatterlist *) sc->request_buffer;
> 
> No need for the cast
ok

> 
> > +			pci_unmap_sg(pdev, sg, sc->use_sg,
> > +				     sc->sc_data_direction);
> > +		} else {
> > +			pci_unmap_single(pdev, sc->SCp.dma_handle,
> > +					 sc->request_bufflen,
> > +					 sc->sc_data_direction);
> > +		}
> > +		cmd->bd_tbl->bd_valid = 0;
> > +	}
> > +	return 0;
> > +}
> > +
> > +
> > +
> > +static void bnx2i_setup_cmd_wqe_template(struct bnx2i_cmd *cmd)
> > +{
> > +	memset(&cmd->req, 0x00, sizeof(cmd->req));
> > +	cmd->req.op_code = ISCSI_OPCODE_SCSI_CMD;
> > +	cmd->req.bd_list_addr_lo = (u32) cmd->bd_tbl->bd_tbl_dma;
> > +	cmd->req.bd_list_addr_hi =
> > +		(u32) ((u64) cmd->bd_tbl->bd_tbl_dma >> 32);
> > +
> > +}
> > +
> > +
> > +/*
> > + * update iscsi cid table entry with connection pointer
> > + */
> > +static void bnx2i_bind_conn_to_iscsi_cid(struct bnx2i_conn *conn,
> > +					 u32 iscsi_cid)
> > +{
> > +	struct bnx2i_hba *hba = NULL;
> 
> needless initialization...
ok

> 
> > +
> > +	if (!conn || !conn->sess)
> > +		return;
> > +
> > +	hba = conn->sess->hba;
> 
> as it is initialized here
> 
> > +
> > +	if (hba->cid_que.conn_cid_tbl[iscsi_cid])
> > +		printk(KERN_ERR "bnx2i: conn bind - entry #%d not free\n",
> > +				iscsi_cid);
> 
> Strange, what to do with the old value? is it OK just to print this
> _error_ message? Haven't checked, just feels suspicious to just use
> printk, BUG_ON or WARN_ON case?
should not happen as table entry is cleared before 'iscsi_cid' is
returned to free pool. Any case will return error status if this
condition is detected

> 
> > +	hba->cid_que.conn_cid_tbl[iscsi_cid] = conn;
> > +}
> > +
> > +
> > +/*
> > + * maps an iscsi cid to corresponding conn ptr
> > + */
> > +struct bnx2i_conn *bnx2i_get_conn_from_id(struct bnx2i_hba *hba,
> > +						 u16 iscsi_cid)
> > +{
> > +	if (!hba->cid_que.conn_cid_tbl) {
> > +		printk(KERN_ERR "bnx2i: ERROR - missing conn<->cid table\n");
> > +		return NULL;
> > +
> > +	} else if (iscsi_cid >= hba->max_active_conns) {
> > +		printk(KERN_ERR "bnx2i: wrong cid #%d\n", iscsi_cid);
> > +		return NULL;
> > +	}
> > +	return(hba->cid_que.conn_cid_tbl[iscsi_cid]);
> > +}
> > +
> > +
> > +
> > +/*
> > + * allocates a iscsi_cid from free pool
> > + */
> > +static u32 bnx2i_alloc_iscsi_cid(struct bnx2i_hba *hba)
> > +{
> > +	int idx = 0;
> 
> Another needless initialization
ok

> 
> > +
> > +	if (!hba->cid_que.cid_free_cnt)
> > +		return (ISCSI_RESERVED_TAG);
> > +
> > +	idx = hba->cid_que.cid_q_cons_idx;
> > +	hba->cid_que.cid_q_cons_idx++;
> > +	if (hba->cid_que.cid_q_cons_idx == hba->cid_que.cid_q_max_idx) {
> > +		hba->cid_que.cid_q_cons_idx = 0;
> > +	}
> 
> No need for { }, there is just one line in this if
will remove

> 
> > +
> > +	hba->cid_que.cid_free_cnt--;
> > +	return hba->cid_que.cid_que[idx];
> > +}
> > +
> > +
> > +/*
> > + * return iscsi_cid back to free pool
> > + */
> > +static void bnx2i_free_iscsi_cid(struct bnx2i_hba *hba, u16 iscsi_cid)
> > +{
> > +	int idx = 0;
> 
> Needless initialization
ok

> 
> > +
> > +	if (iscsi_cid == (u16)ISCSI_RESERVED_TAG)
> > +		return;
> > +
> > +	hba->cid_que.cid_free_cnt++;
> > +
> > +	idx = hba->cid_que.cid_q_prod_idx;
> > +	hba->cid_que.cid_que[idx] = iscsi_cid;
> > +	hba->cid_que.conn_cid_tbl[iscsi_cid] = NULL;
> > +	hba->cid_que.cid_q_prod_idx++;
> > +	if (hba->cid_que.cid_q_prod_idx == hba->cid_que.cid_q_max_idx) {
> 
> Ditto wrt {}
will be removed

> 
> > +		hba->cid_que.cid_q_prod_idx = 0;
> > +	}
> > +}
> > +
> > +
> > +
> > +/*
> > + * setup iscsi_cid queue, 'iscsi_cid' value ranges from 0 to (MAX_CONNS -1)
> > + */
> > +static int bnx2i_setup_free_cid_que(struct bnx2i_hba *hba)
> > +{
> > +	int mem_size;
> > +	int i = 0;
> > +
> > +	mem_size = hba->max_active_conns * sizeof(u16);
> > +	mem_size = (mem_size + (PAGE_SIZE - 1)) & PAGE_MASK;
> > +
> > +	hba->cid_que.cid_que_base = kmalloc(mem_size, GFP_KERNEL);
> 
> good, the value returned by kmalloc is a void pointer, so no need to
> cast it...
> 
> > +	if (!hba->cid_que.cid_que_base)
> > +		return -ENOMEM;
> > +
> > +	mem_size = hba->max_active_conns * sizeof(struct bnx2i_conn *);
> > +	mem_size = (mem_size + (PAGE_SIZE - 1)) & PAGE_MASK;
> > +	hba->cid_que.conn_cid_tbl =
> > +			(struct bnx2i_conn **)kmalloc(mem_size, GFP_KERNEL);
> 
> ... so why do you use a cast here? :-)
not required, will change.

> 
> > +	if (!hba->cid_que.conn_cid_tbl) {
> 
> Hey, here you test if this was not allocated...
> 
> > +		kfree(hba->cid_que.cid_que_base);
> > +		hba->cid_que.cid_que_base = NULL;
> 
> But don't return -ENOMEM here and...
oh, missing return statement is a bug


> 
> > +	}
> > +
> > +	hba->cid_que.cid_que = (u32 *)hba->cid_que.cid_que_base;
> > +	hba->cid_que.cid_q_prod_idx = 0;
> > +	hba->cid_que.cid_q_cons_idx = 0;
> > +	hba->cid_que.cid_q_max_idx = hba->max_active_conns;
> > +	hba->cid_que.cid_free_cnt = hba->max_active_conns;
> > +
> > +	for (i = 0; i < hba->max_active_conns; i++) {
> > +		hba->cid_que.cid_que[i] = i;
> > +		hba->cid_que.conn_cid_tbl[i] = NULL;
> 
> ... potentially dereference NULL here? Bzzt :)
previously mentioned return statement should take care of this bug.
 


> 
> > +	}
> > +	return 0;
> > +}
> > +
> > +
> > +/*
> > + * Releases resources held by free 'iscsi_cid' queue
> > + */
> > +static void bnx2i_release_free_cid_que(struct bnx2i_hba *hba)
> > +{
> > +	if (hba->cid_que.cid_que_base) {
> 
> kfree handles receiving a NULL pointer, so no need to duplicate the test
> against NULL, just call kfree and set the pointer to NULL
ok

> 
> > +		kfree(hba->cid_que.cid_que_base);
> > +		hba->cid_que.cid_que_base = NULL;
> > +	}
> > +
> > +	if (hba->cid_que.conn_cid_tbl) {
> 
> Ditto
ok

> 
> > +		kfree(hba->cid_que.conn_cid_tbl);
> > +		hba->cid_que.conn_cid_tbl = NULL;
> > +	}
> > +}
> > +
> > +
> > +/*
> > + * routine allocates a free endpoint structure from the global pool
> > + */
> > +struct bnx2i_endpoint *bnx2i_alloc_ep(void)
> > +{
> > +	struct bnx2i_endpoint *endpoint = NULL;
> > +	struct list_head *listp;
> > +	u16 tcp_port;
> > +
> > +	spin_lock_bh(&bnx2i_resc_lock);
> > +
> > +	tcp_port = bnx2i_alloc_tcp_port();
> > +	if (!tcp_port) {
> > +		spin_unlock_bh(&bnx2i_resc_lock);
> > +		return NULL;
> > +	}
> > +	if (list_empty(&bnx2i_free_ep_list)) {
> > +		spin_unlock_bh(&bnx2i_resc_lock);
> > +		printk(KERN_ERR "alloc_ep: unable to alloc ep struct\n");
> > +		return endpoint;
> 
> Why not return NULL here as you did in the previous test? 
> 
> Well, since you initialized endpoint to NULL you could, in both cases
> just do a goto out_unlock that would be defined...
done

> 
> > +	}
> > +	listp = (struct list_head *)bnx2i_free_ep_list.next;
> > +	list_del_init(listp);
> > +	bnx2i_num_free_ep--;
> > +
> > +	endpoint = (struct bnx2i_endpoint *)listp;
> > +	endpoint->in_use = 1;
> > +	endpoint->tcp_port = tcp_port;
> > +	init_waitqueue_head(&endpoint->ofld_wait);
> 
> ... here:
> 
> out_unlock:
> 
> I'll stop reviewing here, please consider checking the rest of the patch
> for the kinds of things I pointed out,
Thanks a lot for your feedback, will make necessary changes and repost
the code soon.

Regards,
Anil Veerabhadrappa

> 
> Best Regards,
> 
> - Arnaldo
> 
> > +
> > +	spin_unlock_bh(&bnx2i_resc_lock);
> > +	return endpoint;
> > +}
> > +
> > +
> > +/*
> > + * free endpoint structure to global free pool
> > + */
> > +void bnx2i_free_ep(struct bnx2i_endpoint *endpoint)
> > +{
> > +	if (!endpoint)
> > +		return;
> > +
> > +	spin_lock_bh(&bnx2i_resc_lock);
> > +	endpoint->state = EP_STATE_IDLE;
> > +	endpoint->in_use = 0;
> > +	bnx2i_free_iscsi_cid(endpoint->hba, endpoint->ep_iscsi_cid);
> > +	if (endpoint->conn) {
> > +		endpoint->conn->ep = NULL;
> > +		endpoint->conn = NULL;
> > +	}
> > +	endpoint->sess = NULL;
> > +
> > +	if (endpoint->tcp_port) {
> > +		bnx2i_free_tcp_port(endpoint->tcp_port);
> > +	}
> > +	endpoint->hba = NULL;
> > +	list_add_tail(&endpoint->link, &bnx2i_free_ep_list);
> > +	bnx2i_num_free_ep++;
> > +	spin_unlock_bh(&bnx2i_resc_lock);
> > +}
> > +
> > +
> > +/*
> > + * allocates free pool of endpoint structurres, endpoint structures
> > + *	are used to store QP related control and PT info
> > + */
> > +int bnx2i_alloc_ep_pool(void)
> > +{
> > +	struct bnx2i_endpoint *endpoint = NULL;
> > +	int index = 0, count = 0;
> > +	int ret_val = 1;
> > +	int total_endpoints = 0;
> > +	int page_count = 0;
> > +	int num_endpoints_per_page = 0;
> > +	void *mem_ptr = NULL;
> > +
> > +	spin_lock_init(&bnx2i_resc_lock);
> > +	INIT_LIST_HEAD(&bnx2i_free_ep_list);
> > +	INIT_LIST_HEAD(&bnx2i_unbound_ep);
> > +
> > +	for (index = 0; index < MAX_PAGES_PER_CTRL_STRUCT_POOL; index++) {
> > +		bnx2i_ep_pages[index] = NULL;
> > +	}
> > +
> > +	num_endpoints_per_page =
> > +		PAGE_SIZE / sizeof(struct bnx2i_endpoint);
> > +
> > +	total_endpoints = ISCSI_MAX_CONNS_PER_HBA;
> > +	if (total_endpoints >
> > +	    (num_endpoints_per_page * MAX_PAGES_PER_CTRL_STRUCT_POOL)) {
> > +		total_endpoints = (num_endpoints_per_page *
> > +				   MAX_PAGES_PER_CTRL_STRUCT_POOL);
> > +	}
> > +
> > +	bnx2i_num_free_ep = 0;
> > +	for (index = 0; index < total_endpoints;) {
> > +		mem_ptr = (void *)kmalloc(PAGE_SIZE, GFP_KERNEL);
> > +		if (mem_ptr == NULL) {
> > +			printk(KERN_ERR "ep_pool: mem alloc failed\n");
> > +			break;
> > +		}
> > +		bnx2i_ep_pages[page_count++] = (void *)mem_ptr;
> > +
> > +		memset(mem_ptr, 0, PAGE_SIZE);
> > +
> > +		endpoint = (struct bnx2i_endpoint *)mem_ptr;
> > +		for (count = 0; count < num_endpoints_per_page; count++) {
> > +			endpoint->in_use = 0;
> > +			list_add_tail(&endpoint->link, &bnx2i_free_ep_list);
> > +			endpoint++;
> > +		}
> > +
> > +		bnx2i_num_free_ep += num_endpoints_per_page;
> > +		index += num_endpoints_per_page;
> > +	}
> > +	if (bnx2i_num_free_ep == 0)
> > +		ret_val = 0;
> > +	bnx2i_max_free_ep = bnx2i_num_free_ep;
> > +
> > +	return(ret_val);
> > +}
> > +
> > +
> > +/*
> > + * Free memory resources held by global endpoint pool
> > + */
> > +void bnx2i_release_ep_pool(void)
> > +{
> > +	int index = 0;
> > +	void *mem_ptr = NULL;
> > +
> > +	for (index = 0; index < MAX_PAGES_PER_CTRL_STRUCT_POOL; index++) {
> > +		mem_ptr = bnx2i_ep_pages[index];
> > +		if (mem_ptr) {
> > +			kfree((void *) mem_ptr);
> > +			break;
> > +		}
> > +		bnx2i_ep_pages[index] = NULL;
> > +	}
> > +	bnx2i_num_free_ep = 0;
> > +	return;
> > +}
> > +
> > +
> > +/*
> > + * iSCSI Session ITT queue management code
> > + */
> > +static u32 bnx2i_alloc_itt(struct bnx2i_sess *sess, struct bnx2i_cmd *cmd)
> > +{
> > +	u32 itt_val = ITT_INVALID_SIGNATURE;
> > +
> > +	if (sess->itt_q.itt_q_count) {
> > +		itt_val = sess->itt_q.itt_que[sess->itt_q.itt_q_cons_idx++];
> > +		sess->itt_q.itt_q_cons_idx %= sess->itt_q.itt_q_max_idx;
> > +		sess->itt_q.itt_cmd[itt_val] = cmd;
> > +		sess->itt_q.itt_q_count--;
> > +	}
> > +	return itt_val;
> > +}
> > +
> > +
> > +static void bnx2i_free_itt(struct bnx2i_sess *sess, struct bnx2i_cmd *cmd)
> > +{
> > +	if (cmd->req.itt == ITT_INVALID_SIGNATURE) {
> > +		printk(KERN_ALERT "free_itt: RSVD ITT - sess 0x%p\n", sess);
> > +	}
> > +	sess->itt_q.itt_que[sess->itt_q.itt_q_prod_idx++] = cmd->req.itt;
> > +	sess->itt_q.itt_q_prod_idx %= sess->itt_q.itt_q_max_idx;
> > +	sess->itt_q.itt_cmd[cmd->req.itt] = NULL;
> > +	sess->itt_q.itt_q_count++;
> > +	cmd->req.itt = ITT_INVALID_SIGNATURE;
> > +}
> > +
> > +
> > +/*
> > + * setup ITT queue during iSCSI session creation. ITT queue is a
> > + *	circular array of ITTs [range 0 - (SQ SIZE - 1)] managed by
> > + *	producer and consumer index
> > + */
> > +static int bnx2i_setup_free_itt_queue(struct bnx2i_sess *sess)
> > +{
> > +	u16 itt_q_size = (u16)sess->sq_size;
> > +	u32 itt_value = 0;
> > +	int unit_size = sizeof(u16);
> > +	int mem_size = PAGE_SIZE;
> > +
> > +	if ((itt_q_size * unit_size) > mem_size)
> > +		mem_size = (itt_q_size * unit_size);
> > +
> > +	mem_size = (mem_size + (PAGE_SIZE - 1)) & PAGE_MASK;
> > +	sess->itt_q.itt_que_base = kmalloc(mem_size, GFP_KERNEL);
> > +	if (!sess->itt_q.itt_que_base) {
> > +		return -ENOMEM;
> > +	}
> > +
> > +	mem_size = (itt_q_size * sizeof(struct bnx2i_cmd *));
> > +	mem_size = (mem_size + (PAGE_SIZE - 1)) & PAGE_MASK;
> > +	sess->itt_q.itt_cmd =
> > +		(struct bnx2i_cmd **) kmalloc(mem_size, GFP_KERNEL);
> > +	if (!sess->itt_q.itt_cmd) {
> > +		kfree(sess->itt_q.itt_que_base);
> > +		sess->itt_q.itt_que_base = NULL;
> > +		return -1;
> > +	}
> > +	memset(sess->itt_q.itt_cmd, 0x00, mem_size);
> > +
> > +	sess->itt_q.itt_que = (u32 *)sess->itt_q.itt_que_base;
> > +	sess->itt_q.itt_q_prod_idx = 0;
> > +	sess->itt_q.itt_q_cons_idx = 0;
> > +	sess->itt_q.itt_q_max_idx = itt_q_size;
> > +	sess->itt_q.itt_q_count = itt_q_size;
> > +
> > +	itt_value = 0;
> > +	while (itt_value < itt_q_size) {
> > +		sess->itt_q.itt_cmd[itt_value] = (struct bnx2i_cmd *)NULL;
> > +		sess->itt_q.itt_que[sess->itt_q.itt_q_prod_idx++] =
> > +			itt_value++;
> > +		if (sess->itt_q.itt_q_prod_idx >= sess->itt_q.itt_q_max_idx) {
> > +			sess->itt_q.itt_q_prod_idx = 0;
> > +		}
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +
> > +/*
> > + * free resources held by free ITT queue
> > + */
> > +static void bnx2i_release_free_itt_queue(struct bnx2i_sess *sess)
> > +{
> > +	sess->itt_q.itt_q_count = 0;
> > +	if (sess->itt_q.itt_que_base) {
> > +		kfree (sess->itt_q.itt_que_base);
> > +		sess->itt_q.itt_que_base = NULL;
> > +	}
> > +
> > +	if (sess->itt_q.itt_cmd) {
> > +		kfree (sess->itt_q.itt_cmd);
> > +		sess->itt_q.itt_cmd = NULL;
> > +	}
> > +	return;
> > +}
> > +
> > +
> > +/*
> > + * allocates a command structures from free poll
> > + */
> > +struct bnx2i_cmd *bnx2i_alloc_cmd(struct bnx2i_sess *sess)
> > +{
> > +	struct bnx2i_cmd *cmd = NULL;
> > +	struct list_head *listp;
> > +
> > +	if (unlikely(!sess || (sess->num_free_cmds == 0))) {
> > +		return cmd;
> > +	}
> > +
> > +	listp = (struct list_head *) sess->free_cmds.next;
> > +	list_del_init(listp);
> > +	sess->num_free_cmds--;
> > +	cmd = (struct bnx2i_cmd *)listp;
> > +	cmd->in_use = 1;
> > +	cmd->scsi_status_rcvd = cmd->resi_len = 0;
> > +	cmd->scsi_uflow = cmd->scsi_oflow = 0;
> > +
> > +	bnx2i_setup_cmd_wqe_template(cmd);
> > +
> > +	cmd->req.itt = bnx2i_alloc_itt(sess, cmd);
> > +
> > +	return cmd;
> > +}
> > +
> > +
> > +/*
> > + * return command structure and ITT back to free pool.
> > + */
> > +void bnx2i_free_cmd(struct bnx2i_sess *sess, struct bnx2i_cmd *cmd)
> > +{
> > +	if (!sess || !cmd)
> > +		return;
> > +
> > +	cmd->in_use = 0;
> > +	bnx2i_free_itt(sess, cmd);
> > +	list_add_tail(&cmd->link, &sess->free_cmds);
> > +	sess->num_free_cmds++;
> > +}
> > +
> > +
> > +/*
> > + * Allocate command structure pool for a given iSCSI session
> > + */
> > +int bnx2i_alloc_cmd_pool(struct bnx2i_sess *sess)
> > +{
> > +	struct bnx2i_cmd *cmdp = NULL;
> > +	int index = 0, count = 0;
> > +	int ret_val = 0;
> > +	int total_cmds = 0;
> > +	int num_cmds = 0;
> > +	int page_count = 0;
> > +	int num_cmds_per_page = 0;
> > +	void *mem_ptr = NULL;
> > +
> > +	if (!sess)
> > +		return -EINVAL;
> > +
> > +	INIT_LIST_HEAD(&sess->free_cmds);
> > +	for (index = 0; index < MAX_PAGES_PER_CTRL_STRUCT_POOL; index++) {
> > +		sess->cmd_pages[index] = NULL;
> > +	}
> > +
> > +	num_cmds_per_page = PAGE_SIZE / sizeof(struct bnx2i_cmd);
> > +	total_cmds = sess->hba->scsi_template->can_queue + 1;
> > +	if (total_cmds >
> > +	    (num_cmds_per_page * MAX_PAGES_PER_CTRL_STRUCT_POOL)) {
> > +		total_cmds = num_cmds_per_page *
> > +			     MAX_PAGES_PER_CTRL_STRUCT_POOL;
> > +	}
> > +
> > +	for (index = 0; index < total_cmds;) {
> > +		mem_ptr = (void *) kmalloc(PAGE_SIZE, GFP_KERNEL);
> > +		if (mem_ptr == NULL) {
> > +			break;
> > +		}
> > +		sess->cmd_pages[page_count++] = (void *)mem_ptr;
> > +
> > +		num_cmds = num_cmds_per_page;
> > +		if ((total_cmds - index) < num_cmds_per_page)
> > +			num_cmds = (total_cmds - index);
> > +
> > +		memset(mem_ptr, 0, PAGE_SIZE);
> > +		cmdp = (struct bnx2i_cmd *) mem_ptr;
> > +		for (count = 0; count < num_cmds; count++) {
> > +			cmdp->in_use = 0;
> > +			cmdp->req.itt = ITT_INVALID_SIGNATURE;
> > +
> > +			/* Allocate BD table */
> > +			cmdp->bd_tbl = bnx2i_alloc_bd_table(sess, cmdp);
> > +			if (!cmdp->bd_tbl) {
> > +				/* should never fail, as it's guaranteed to have
> > +				 * (ISCSI_MAX_CMDS_PER_SESS + 1) BD tables
> > +				 * allocated before calling this function.
> > +				 */
> > +				printk(KERN_ERR "no BD table cmd %p\n", cmdp);
> > +				goto bd_table_failed;
> > +			}
> > +			list_add_tail(&cmdp->link, &sess->free_cmds);
> > +			cmdp++;
> > +		}
> > +
> > +		sess->num_free_cmds += num_cmds;
> > +		index += num_cmds;
> > +	}
> > +	sess->allocated_cmds = sess->num_free_cmds;
> > +
> > +	if (sess->num_free_cmds == 0)
> > +		ret_val = -ENOMEM;
> > +	return(ret_val);
> > +
> > +bd_table_failed:
> > +	return(-ENOMEM);
> > +}
> > +
> > +
> > +/*
> > + * Release memory held by command struct pool.
> > + */
> > +void bnx2i_free_cmd_pool(struct bnx2i_sess *sess)
> > +{
> > +	int index = 0;
> > +	void *mem_ptr = NULL;
> > +
> > +	if (unlikely(!sess))
> > +		return;
> > +
> > +	if (sess->num_free_cmds != sess->allocated_cmds) {
> > +		/*
> > +		 * WARN: either there is some command struct leak or
> > +		 * still some SCSI commands are pending.
> > +		 * TODO: post mortem required...
> > +		 */
> > +	}
> > +	for (index = 0; index < MAX_PAGES_PER_CTRL_STRUCT_POOL; index++) {
> > +		mem_ptr = sess->cmd_pages[index];
> > +		if (mem_ptr) {
> > +			kfree((void *) mem_ptr);
> > +			break;
> > +		}
> > +		sess->cmd_pages[index] = NULL;
> > +	}
> > +	sess->num_free_cmds = sess->allocated_cmds = 0;
> > +	return;
> > +}
> > +
> > +
> > +/*
> > + * Allocate a BD table
> > + */
> > +static struct io_bdt *bnx2i_alloc_bd_table(struct bnx2i_sess *sess,
> > +					   struct bnx2i_cmd *cmd)
> > +{
> > +	struct io_bdt *bd_tbl = NULL;
> > +
> > +	if (list_empty(&sess->bd_tbl_list)) {
> > +		return NULL;
> > +	}
> > +	bd_tbl = (struct io_bdt *)sess->bd_tbl_list.next;
> > +	list_del(&bd_tbl->link);
> > +	list_add_tail(&bd_tbl->link, &sess->bd_tbl_active);
> > +	bd_tbl->bd_valid = 0;
> > +	if (!bd_tbl->cmdp) {
> > +		bd_tbl->cmdp = cmd;
> > +	}
> > +	return bd_tbl;
> > +}
> > +
> > +
> > +/*
> > + * Free up memory pages allocated held by BD resources
> > + */
> > +static void bnx2i_free_all_bdt_resc_pages(struct bnx2i_sess *sess)
> > +{
> > +	int i = 0;
> > +	struct bd_resc_page *resc_page = NULL;
> > +
> > +	spin_lock_bh(&sess->lock);
> > +	while (!list_empty(&sess->bd_resc_page)) {
> > +		resc_page = (struct bd_resc_page *)sess->bd_resc_page.prev;
> > +		list_del(sess->bd_resc_page.prev);
> > +		for(i = 0; i < resc_page->num_valid; i++) {
> > +			kfree(resc_page->page[i]);
> > +		}
> > +		kfree(resc_page);
> > +	}
> > +	spin_unlock_bh(&sess->lock);
> > +}
> > +
> > +
> > +
> > +/*
> > + * allocated 4K page to track BD table memory
> > + */
> > +struct bd_resc_page *bnx2i_alloc_bdt_resc_page(struct bnx2i_sess *sess)
> > +{
> > +	void *mem_ptr;
> > +	struct bd_resc_page *resc_page = NULL;
> > +
> > +	mem_ptr = (void *) kmalloc(PAGE_SIZE, GFP_KERNEL);
> > +	if (!mem_ptr)
> > +		return NULL;
> > +
> > +	resc_page = (struct bd_resc_page *) mem_ptr;
> > +	list_add_tail(&resc_page->link, &sess->bd_resc_page);
> > +	resc_page->max_ptrs = (PAGE_SIZE -
> > +		(u32)&((struct bd_resc_page *) 0)->page[0]) / sizeof(void *);
> > +	resc_page->num_valid = 0;
> > +
> > +	return resc_page;
> > +}
> > +
> > +
> > +/*
> > + * link newly allocated memory page to the list
> > + */
> > +int bnx2i_add_bdt_resc_page(struct bnx2i_sess *sess, void *bd_page)
> > +{
> > +	struct bd_resc_page *resc_page = NULL;
> > +
> > +#define is_resc_page_full(_resc_pg) (_resc_pg->num_valid == _resc_pg->max_ptrs)
> > +#define active_resc_page(_resc_list) 	\
> > +			(list_empty(_resc_list) ? NULL : (_resc_list)->prev)
> > +	if (list_empty(&sess->bd_resc_page)) {
> > +		resc_page = bnx2i_alloc_bdt_resc_page(sess);
> > +	} else {
> > +		resc_page = (struct bd_resc_page *)
> > +					active_resc_page(&sess->bd_resc_page);
> > +	}
> > +
> > +	if (!resc_page)
> > +		return -ENOMEM;
> > +
> > +	resc_page->page[resc_page->num_valid++] = bd_page;
> > +	if (is_resc_page_full(resc_page)) {
> > +		resc_page = bnx2i_alloc_bdt_resc_page(sess);
> > +	}
> > +	return 0;
> > +}
> > +
> > +
> > +/*
> > + * Allocate BD table pool, DMA'able memory for a given session.
> > + */
> > +int bnx2i_alloc_bd_table_pool(struct bnx2i_sess *sess)
> > +{
> > +	int index = 0, count = 0;
> > +	int ret_val = 0;
> > +	int num_elem_per_page;
> > +	struct io_bdt *bdt_info;
> > +	char *mem_ptr = NULL;
> > +	u32 bd_tbl_size = 0;
> > +	u32 mem_size = 0;
> > +	int total_bd_tbl = 0;
> > +
> > +	INIT_LIST_HEAD(&sess->bd_resc_page);
> > +	INIT_LIST_HEAD(&sess->bd_tbl_list);
> > +	INIT_LIST_HEAD(&sess->bd_tbl_active);
> > +	total_bd_tbl = sess->hba->scsi_template->can_queue + 1;
> > +	mem_size = total_bd_tbl * sizeof(struct io_bdt);
> > +	num_elem_per_page = PAGE_SIZE / sizeof(struct io_bdt);
> > +	for (index = 0; index < total_bd_tbl; index += num_elem_per_page) {
> > +		if (((total_bd_tbl - index) * sizeof(struct io_bdt))
> > +				>= PAGE_SIZE) {
> > +			mem_size = PAGE_SIZE;
> > +			num_elem_per_page = PAGE_SIZE / sizeof(struct io_bdt);
> > +		} else {
> > +			mem_size =
> > +				(total_bd_tbl - index) * sizeof(struct io_bdt);
> > +			num_elem_per_page = (total_bd_tbl - index);
> > +		}
> > +		mem_ptr = (void *)kmalloc(mem_size, GFP_KERNEL);
> > +		if (mem_ptr == NULL) {
> > +			printk(KERN_ERR "alloc_bd_tbl: mem alloc failed\n");
> > +			ret_val = -ENOMEM;
> > +			goto resc_alloc_failed;
> > +		}
> > +		bnx2i_add_bdt_resc_page(sess, mem_ptr);
> > +
> > +		memset(mem_ptr, 0, mem_size);
> > +		bdt_info = (struct io_bdt *)mem_ptr;
> > +		for (count = 0; count < num_elem_per_page; count++) {
> > +			list_add_tail(&bdt_info->link, &sess->bd_tbl_list);
> > +			bdt_info++;
> > +		}
> > +	}
> > +
> > +	bd_tbl_size = ISCSI_MAX_BDS_PER_CMD * sizeof(struct iscsi_bd);
> > +	bdt_info = (struct io_bdt *)sess->bd_tbl_list.next;
> > +	while (bdt_info && (bdt_info != (struct io_bdt *)&sess->bd_tbl_list)) {
> > +		mem_ptr = (char *)pci_alloc_consistent(sess->hba->pci_dev,
> > +						       bd_tbl_size,
> > +						       &bdt_info->bd_tbl_dma);
> > +		if (!mem_ptr) {
> > +			printk(KERN_ERR "bd_tbl: DMA mem alloc failed\n");
> > +			ret_val = -ENOMEM;
> > +			goto dma_alloc_failed;
> > +		}
> > +		bdt_info->bd_tbl = (struct iscsi_bd *)mem_ptr;
> > +		bdt_info->max_bd_cnt = ISCSI_MAX_BDS_PER_CMD;
> > +		bdt_info->bd_valid = 0;
> > +		bdt_info->cmdp = NULL;
> > +
> > +		bdt_info = (struct io_bdt *)bdt_info->link.next;
> > +	}
> > +	return(ret_val);
> > +
> > +resc_alloc_failed:
> > +dma_alloc_failed:
> > +	return(ret_val);
> > +}
> > +
> > +
> > +/*
> > + * releases BD table pool memory
> > + */
> > +void bnx2i_free_bd_table_pool(struct bnx2i_sess *sess)
> > +{
> > +	struct list_head *list;
> > +	struct io_bdt *bdt_info;
> > +	u32 bd_tbl_size = 0;
> > +
> > +	bd_tbl_size = ISCSI_MAX_BDS_PER_CMD * sizeof(struct iscsi_bd);
> > +	list_for_each(list, &sess->bd_tbl_list) {
> > +		bdt_info = list_entry(list, struct io_bdt, link);
> > +		pci_free_consistent(sess->hba->pci_dev, bd_tbl_size,
> > +				    (void *)bdt_info->bd_tbl,
> > +				    bdt_info->bd_tbl_dma);
> > +		bdt_info->bd_tbl = NULL;
> > +		if (bdt_info->cmdp) {
> > +			bdt_info->cmdp->bd_tbl = NULL;
> > +			bdt_info->cmdp = NULL;
> > +		}
> > +	}
> > +
> > +	list_for_each(list, &sess->bd_tbl_active) {
> > +		bdt_info = list_entry(list, struct io_bdt, link);
> > +		pci_free_consistent(sess->hba->pci_dev, bd_tbl_size,
> > +				    (void *)bdt_info->bd_tbl,
> > +				    bdt_info->bd_tbl_dma);
> > +		bdt_info->bd_tbl = NULL;
> > +		if (bdt_info->cmdp) {
> > +			bdt_info->cmdp->bd_tbl = NULL;
> > +			bdt_info->cmdp = NULL;
> > +		}
> > +	}
> > +}
> > +
> > +
> > +/*
> > + * allocate memory for dummy buffer and associated BD table
> > + *	to be used by middle path (MP) requests
> > + */
> > +static int bnx2i_setup_mp_bdt(struct bnx2i_hba *hba)
> > +{
> > +	int rc = 0;
> > +	struct iscsi_bd *mp_bdt;
> > +	u64 addr;
> > +	hba->mp_bd_tbl = NULL;
> > +	if (hba->cnic_dev_type == CNIC_10GIG_GEN1)
> > +		return rc;
> > +
> > +	hba->mp_bd_tbl = pci_alloc_consistent(hba->pci_dev,
> > +					      PAGE_SIZE, &hba->mp_bd_dma);
> > +	if (!hba->mp_bd_tbl) {
> > +		printk(KERN_ERR "unable to allocate Middle Path BDT\n");
> > +		rc = -1;
> > +		goto out;
> > +	}
> > +
> > +	hba->dummy_buffer =
> > +		pci_alloc_consistent(hba->pci_dev,
> > +				     PAGE_SIZE, &hba->dummy_buf_dma);
> > +	if (!hba->dummy_buffer) {
> > +		printk(KERN_ERR "unable to alloc Middle Path Dummy Buffer\n");
> > +		pci_free_consistent(hba->pci_dev, PAGE_SIZE,
> > +				    hba->mp_bd_tbl, hba->mp_bd_dma);
> > +		hba->mp_bd_tbl = NULL;
> > +		rc = -1;
> > +		goto out;
> > +	}
> > +
> > +	mp_bdt = (struct iscsi_bd *)hba->mp_bd_tbl;
> > +	addr = (unsigned long)hba->dummy_buf_dma;
> > +	mp_bdt->buffer_addr_lo = addr & 0xffffffff;
> > +	mp_bdt->buffer_addr_hi = addr >> 32;
> > +	mp_bdt->buffer_length = PAGE_SIZE;
> > +	mp_bdt->flags = ISCSI_BD_LAST_IN_BD_CHAIN |
> > +			ISCSI_BD_FIRST_IN_BD_CHAIN;
> > +
> > +out:
> > +	return rc;
> > +}
> > +
> > +
> > +/*
> > + * free MP dummy buffer and associated BD table
> > + */
> > +static void bnx2i_free_mp_bdt(struct bnx2i_hba *hba)
> > +{
> > +
> > +	if (hba->mp_bd_tbl) {
> > +		pci_free_consistent(hba->pci_dev, PAGE_SIZE,
> > +				    hba->mp_bd_tbl, hba->mp_bd_dma);
> > +		hba->mp_bd_tbl = NULL;
> > +	}
> > +	if (hba->dummy_buffer) {
> > +		pci_free_consistent(hba->pci_dev, PAGE_SIZE,
> > +				    hba->dummy_buffer, hba->dummy_buf_dma);
> > +		hba->dummy_buffer = NULL;
> > +	}
> > +		return;
> > +}
> > +
> > +
> > +static u16 bnx2i_alloc_tcp_port()
> > +{
> > +	return bnx2i_local_tcp_port++;
> > +}
> > +
> > +
> > +/*
> > + * Function : bnx2i_free_tcp_port
> > + * Description:
> > + */
> > +static void bnx2i_free_tcp_port(u16 port)
> > +{
> > +	if (!bnx2i_tcp_port_tbl.free_q)
> > +		return;
> > +
> > +	bnx2i_tcp_port_tbl.free_q[bnx2i_tcp_port_tbl.prod_idx] = port;
> > +	bnx2i_tcp_port_tbl.prod_idx++;
> > +	bnx2i_tcp_port_tbl.prod_idx %= bnx2i_tcp_port_tbl.max_idx;
> > +	bnx2i_tcp_port_tbl.num_free_ports++;
> > +}
> > +
> > +void bnx2i_tcp_port_new_entry(u16 tcp_port)
> > +{
> > +	u32 idx = bnx2i_tcp_port_tbl.prod_idx;
> > +
> > +	spin_lock(&bnx2i_resc_lock);
> > +	bnx2i_tcp_port_tbl.free_q[idx] = (u16)tcp_port;
> > +	bnx2i_tcp_port_tbl.prod_idx++;
> > +	bnx2i_tcp_port_tbl.prod_idx %= bnx2i_tcp_port_tbl.max_idx;
> > +	bnx2i_tcp_port_tbl.num_free_ports++;
> > +	bnx2i_tcp_port_tbl.num_required--;
> > +	spin_unlock(&bnx2i_resc_lock);
> > +}
> > +
> > +/*
> > + * Function : bnx2i_init_tcp_port_mngr
> > + * Description:
> > + */
> > +void bnx2i_init_tcp_port_mngr(void)
> > +{
> > +	int mem_size = 0;
> > +
> > +	bnx2i_tcp_port_tbl.num_free_ports = 0;
> > +	bnx2i_tcp_port_tbl.prod_idx = 0;
> > +	bnx2i_tcp_port_tbl.cons_idx = 0;
> > +	bnx2i_tcp_port_tbl.max_idx = 0;
> > +	bnx2i_tcp_port_tbl.num_required = 0;
> > +
> > +#define BNX2I_MAX_TCP_PORTS	1024
> > +
> > +	bnx2i_tcp_port_tbl.port_tbl_size = BNX2I_MAX_TCP_PORTS;
> > +
> > +	mem_size = sizeof(u16) * bnx2i_tcp_port_tbl.port_tbl_size;
> > +	if (bnx2i_tcp_port_tbl.port_tbl_size) {
> > +		bnx2i_tcp_port_tbl.free_q =
> > +			(u16 *)kmalloc(mem_size, GFP_KERNEL);
> > +
> > +		if (bnx2i_tcp_port_tbl.free_q)
> > +			bnx2i_tcp_port_tbl.max_idx =
> > +				bnx2i_tcp_port_tbl.port_tbl_size;
> > +	}
> > +}
> > +
> > +
> > +/*
> > + * Function : bnx2i_cleanup_tcp_port_mngr
> > + * Description:
> > + */
> > +void bnx2i_cleanup_tcp_port_mngr(void)
> > +{
> > +	if (bnx2i_tcp_port_tbl.free_q) {
> > +		kfree(bnx2i_tcp_port_tbl.free_q);
> > +		bnx2i_tcp_port_tbl.free_q = NULL;
> > +	}
> > +	bnx2i_tcp_port_tbl.num_free_ports = 0;
> > +}
> > +
> > +
> > +
> > +/*
> > + *  interface was brought down by the user, fail all iSCSI sessions
> > + *	on this adapter,
> > + */
> > +void bnx2i_start_iscsi_hba_shutdown(struct bnx2i_hba *hba)
> > +{
> > +	struct list_head *list = NULL;
> > +	struct list_head *tmp = NULL;
> > +	struct bnx2i_sess *sess;
> > +
> > +	list_for_each_safe(list, tmp, &hba->active_sess) {
> > +		sess = (struct bnx2i_sess *)list;
> > +		bnx2i_do_iscsi_sess_recovery(sess, DID_NO_CONNECT);
> > +	}
> > +}
> > +
> > +
> > +/*
> > + * IP address change indication, fail all iSCSI sessions on this adapter
> > + */
> > +void bnx2i_iscsi_handle_ip_event(struct bnx2i_hba *hba)
> > +{
> > +	struct list_head *list = NULL;
> > +	struct list_head *tmp = NULL;
> > +	struct bnx2i_sess *sess;
> > +
> > +	spin_lock(&hba->lock);
> > +	list_for_each_safe(list, tmp, &hba->active_sess) {
> > +		sess = (struct bnx2i_sess *)list;
> > +		spin_unlock(&hba->lock);
> > +		bnx2i_do_iscsi_sess_recovery(sess, DID_RESET);
> > +		spin_lock(&hba->lock);
> > +	}
> > +	spin_unlock(&hba->lock);
> > +}
> > +
> > +
> > +
> > +static void
> > +conn_err_recovery_task(struct work_struct *work)
> > +{
> > +	struct bnx2i_hba *hba = container_of(work, struct bnx2i_hba,
> > +					     err_rec_task);
> > +	struct bnx2i_sess *sess;
> > +	int cons_idx = hba->sess_recov_cons_idx;
> > +
> > +	while (hba->sess_recov_prod_idx != cons_idx) {
> > +		sess = hba->sess_recov_list[cons_idx];
> > +		bnx2i_do_iscsi_sess_recovery(sess, DID_RESET);
> > +		if (cons_idx == hba->sess_recov_max_idx)
> > +			cons_idx = 0;
> > +		else
> > +			cons_idx++;
> > +	}
> > +	hba->sess_recov_cons_idx = cons_idx;
> > +}
> > +
> > +
> > +
> > +
> > +/*
> > + * allocate memory buffer to extract conn context
> > + */
> > +static void bnx2i_init_ctx_dump_mem(struct bnx2i_hba *hba)
> > +{
> > +	if (hba->ctx_addr)
> > +		return;
> > +
> > +	hba->ictx_poll_mode = 0;
> > +	hba->ctx_size = 0;
> > +	hba->ctx_read_cnt = 0xffffffff;
> > +	hba->ctx_addr = pci_alloc_consistent(hba->pci_dev,
> > +					     BNX2I_CONN_CTX_BUF_SIZE,
> > +					     &hba->ctx_dma_hndl);
> > +	if (!hba->ctx_addr)
> > +		return;
> > +	hba->ctx_size = BNX2I_CONN_CTX_BUF_SIZE;
> > +}
> > +
> > +
> > +/*
> > + * free context memory buffer
> > + */
> > +static void bnx2i_free_ctx_dump_mem(struct bnx2i_hba *hba)
> > +{
> > +	if (!hba->ctx_addr || (hba->ctx_size == 0))
> > +		return;
> > +
> > +	pci_free_consistent(hba->pci_dev, hba->ctx_size,
> > +			    hba->ctx_addr, hba->ctx_dma_hndl);
> > +	hba->ctx_dma_hndl = 0;
> > +	hba->ctx_addr = NULL;
> > +	hba->ctx_size = 0;
> > +}
> > +
> > +
> > +static int bnx2i_ep_destroy_list_add(struct bnx2i_hba *hba,
> > +				  struct bnx2i_endpoint *ep)
> > +{
> > +	int cur_idx;
> > +
> > +	write_lock(&hba->ep_rdwr_lock);
> > +	cur_idx = hba->ep_destroy_prod_idx++;
> > +	hba->ep_destroy_list[cur_idx] = ep;
> > +	hba->ep_destroy_prod_idx %= hba->ep_destroy_max_idx;
> > +	write_unlock(&hba->ep_rdwr_lock);
> > +	return 0;
> > +}
> > +
> > +struct bnx2i_endpoint *bnx2i_ep_destroy_list_next(struct bnx2i_hba *hba)
> > +{
> > +	int cur_idx;
> > +
> > +	read_lock(&hba->ep_rdwr_lock);
> > +	if (hba->ep_destroy_prod_idx == hba->ep_destroy_cons_idx) {
> > +		read_unlock(&hba->ep_rdwr_lock);
> > +		return NULL;
> > +	}
> > +	cur_idx = hba->ep_destroy_cons_idx++;
> > +	hba->ep_destroy_cons_idx %= hba->ep_destroy_max_idx;
> > +	read_unlock(&hba->ep_rdwr_lock);
> > +
> > +	return (hba->ep_destroy_list[cur_idx]);
> > +}
> > +
> > +static int bnx2i_ep_ofld_list_add(struct bnx2i_hba *hba,
> > +				  struct bnx2i_endpoint *ep)
> > +{
> > +	int cur_idx;
> > +
> > +	write_lock(&hba->ep_rdwr_lock);
> > +	cur_idx = hba->ep_ofld_prod_idx++;
> > +	hba->ep_ofld_list[cur_idx] = ep;
> > +	hba->ep_ofld_prod_idx %= hba->ep_ofld_max_idx;
> > +	write_unlock(&hba->ep_rdwr_lock);
> > +	return 0;
> > +}
> > +
> > +struct bnx2i_endpoint *bnx2i_ep_ofld_list_next(struct bnx2i_hba *hba)
> > +{
> > +	int cur_idx;
> > +
> > +	read_lock(&hba->ep_rdwr_lock);
> > +	if (hba->ep_ofld_prod_idx == hba->ep_ofld_cons_idx) {
> > +		read_unlock(&hba->ep_rdwr_lock);
> > +		return NULL;
> > +	}
> > +	cur_idx = hba->ep_ofld_cons_idx++;
> > +	hba->ep_ofld_cons_idx %= hba->ep_ofld_max_idx;
> > +	read_unlock(&hba->ep_rdwr_lock);
> > +
> > +	return (hba->ep_ofld_list[cur_idx]);
> > +}
> > +
> > +static int bnx2i_init_ep_ofld_destroy_que(struct bnx2i_hba *hba)
> > +{
> > +	rwlock_init(&hba->ep_rdwr_lock);
> > +	hba->ep_ofld_list = (struct bnx2i_endpoint **)
> > +			    kmalloc(PAGE_SIZE, GFP_KERNEL);
> > +	if (!hba->ep_ofld_list)
> > +		return -ENOMEM;
> > +
> > +	hba->ep_ofld_prod_idx = 0;
> > +	hba->ep_ofld_cons_idx = 0;
> > +	hba->ep_ofld_max_idx =
> > +		PAGE_SIZE / sizeof(struct bnx2i_endpoint *) - 1;
> > +
> > +	hba->ep_destroy_list = (struct bnx2i_endpoint **)
> > +			       kmalloc(PAGE_SIZE, GFP_KERNEL);
> > +	if (!hba->ep_destroy_list) {
> > +		kfree(hba->ep_ofld_list);
> > +		hba->ep_ofld_list = NULL;
> > +		return -ENOMEM;
> > +	}
> > +
> > +	hba->ep_destroy_prod_idx = 0;
> > +	hba->ep_destroy_cons_idx = 0;
> > +	hba->ep_destroy_max_idx =
> > +		PAGE_SIZE / sizeof(struct bnx2i_endpoint *) - 1;
> > +	return 0;
> > +}
> > +
> > +
> > +static void bnx2i_free_ep_ofld_destroy_que(struct bnx2i_hba *hba)
> > +{
> > +	if (hba->ep_ofld_list) {
> > +		kfree(hba->ep_ofld_list);
> > +		hba->ep_ofld_list = NULL;
> > +	}
> > +	if (hba->ep_destroy_list) {
> > +		kfree(hba->ep_destroy_list);
> > +		hba->ep_destroy_list = NULL;
> > +	}
> > +}
> > +
> > +/*
> > + * allocate & initialize adapter structure and call other
> > + *	support routines to do per adapter initialization
> > + */
> > +struct bnx2i_hba *bnx2i_alloc_hba(struct cnic_dev *cnic)
> > +{
> > +	struct bnx2i_hba *hba = NULL;
> > +
> > +	hba = kmalloc(sizeof(struct bnx2i_hba), GFP_KERNEL);
> > +
> > +	if (hba == NULL)
> > +		return NULL;
> > +
> > +	memset((void *) hba, 0, sizeof(struct bnx2i_hba));
> > +
> > +	/* Get PCI related information and update hba struct members */
> > +	hba->pci_dev = cnic->pcidev;
> > +	if (hba->pci_dev) {
> > +		hba->pci_did = hba->pci_dev->device;
> > +		hba->pci_vid = hba->pci_dev->vendor;
> > +		hba->pci_sdid = hba->pci_dev->subsystem_device;
> > +		hba->pci_svid = hba->pci_dev->subsystem_vendor;
> > +		hba->pci_func = PCI_FUNC(hba->pci_dev->devfn);
> > +		hba->pci_devno = PCI_SLOT(hba->pci_dev->devfn);
> > +		hba->pci_intr_num = hba->pci_dev->irq;
> > +	}
> > +
> > +	INIT_LIST_HEAD(&hba->active_sess);
> > +	if (bnx2i_init_ep_ofld_destroy_que(hba))
> > +		goto ep_ofld_que_err;
> > +
> > +	hba->mtu_supported = BNX2I_MAX_MTU_SUPPORTED;
> > +
> > +	/* TODO: different values for Teton/Xinan/Everest */
> > +	hba->max_active_conns = ISCSI_MAX_CONNS_PER_HBA;
> > +
> > +	if (bnx2i_setup_free_cid_que(hba))
> > +		goto cid_que_err;
> > +
> > +	/* SQ/RQ/CQ size can be changed via sysfx interface */
> > +	hba->max_sqes = BNX2I_SQ_WQES_DEFAULT;
> > +	hba->max_rqes = BNX2I_RQ_WQES_DEFAULT;
> > +	hba->max_cqes = BNX2I_CQ_WQES_DEFAULT;
> > +	hba->num_ccell = BNX2I_CCELLS_DEFAULT;
> > +
> > +	if (bnx2i_setup_mp_bdt(hba)) {
> > +		goto mp_bdt_err;
> > +	}
> > +
> > +	spin_lock_init(&hba->lock);
> > +	/* initialize timer and wait queue used for resource cleanup when
> > +	 * interface is brought down */
> > +	init_timer(&hba->hba_timer);
> > +	init_waitqueue_head(&hba->eh_wait);
> > +
> > +	INIT_WORK(&hba->err_rec_task, conn_err_recovery_task);
> > +	hba->sess_recov_prod_idx = 0;
> > +	hba->sess_recov_cons_idx = 0;
> > +	hba->sess_recov_max_idx = 0;
> > +	hba->sess_recov_list =
> > +		(struct bnx2i_sess **)kmalloc(PAGE_SIZE, GFP_KERNEL);
> > +	if (!hba->sess_recov_list)
> > +		goto rec_que_err;
> > +	hba->sess_recov_max_idx = PAGE_SIZE / sizeof (struct bnx2i_sess *) - 1;
> > +
> > +	bnx2i_init_ctx_dump_mem(hba);
> > +
> > +	return hba;
> > +
> > +rec_que_err:
> > +	bnx2i_free_mp_bdt(hba);
> > +mp_bdt_err:
> > +	bnx2i_release_free_cid_que(hba);
> > +cid_que_err:
> > +	bnx2i_free_ep_ofld_destroy_que(hba);
> > +ep_ofld_que_err:
> > +	bnx2i_free_hba(hba);
> > +
> > +	return NULL;
> > +}
> > +
> > +
> > +/*
> > + * free adapter structure and call various cleanup routines.
> > + */
> > +void bnx2i_free_hba(struct bnx2i_hba *hba)
> > +{
> > +	if (hba == NULL)
> > +		return;
> > +
> > +	bnx2i_free_ctx_dump_mem(hba);
> > +
> > +	bnx2i_free_mp_bdt(hba);
> > +	bnx2i_release_free_cid_que(hba);
> > +	bnx2i_free_ep_ofld_destroy_que(hba);
> > +
> > +	INIT_LIST_HEAD(&hba->active_sess);
> > +	/* Free memory held by hba structure */
> > +	kfree((void *)hba);
> > +}
> > +
> > +
> > +
> > +
> > +/*
> > + * return all commands in active queue which should already have been
> > + * 	cleaned up by the cnic device.
> > + */
> > +static void bnx2i_flush_active_cmd_queue(struct bnx2i_sess *sess, int err_code)
> > +{
> > +	struct list_head *list;
> > +	struct list_head *tmp;
> > +	struct bnx2i_cmd *cmd;
> > +	unsigned long flags;
> > +	if (!sess->num_active_cmds)
> > +		return;
> > +
> > +	spin_lock_irqsave(sess->host->host_lock, flags);
> > +	list_for_each_safe(list, tmp, &sess->active_cmds) {
> > +		cmd = (struct bnx2i_cmd *) list;
> > +		cmd->req.itt &= ISCSI_CMD_RESPONSE_INDEX;
> > +		bnx2i_iscsi_unmap_sg_list(cmd);
> > +		cmd->cmd_state = ISCSI_CMD_STATE_COMPLETED;
> > +		list_del_init(&cmd->link);
> > +		bnx2i_return_failed_command(sess, cmd, err_code);
> > +		bnx2i_free_cmd(sess, cmd);
> > +	}
> > +	spin_unlock_irqrestore(sess->host->host_lock, flags);
> > +}
> > +
> > +
> > +/*
> > + * initiate cleanup of outstanding commands for sess recovery
> > + */
> > +static int bnx2i_session_recovery_start(struct bnx2i_sess *sess, int err_code)
> > +{
> > +	if (unlikely(!sess)) {
> > +		printk(KERN_ALERT "sess_recov_start: sess not active\n");
> > +		return FAILED;
> > +	}
> > +
> > +	if (!is_sess_active(sess)) {
> > +		wait_event_interruptible_timeout(sess->er_wait,
> > +						 (sess->state ==
> > +						  BNX2I_SESS_IN_FFP), HZ);
> > +		if (signal_pending(current))
> > +			flush_signals(current);
> > +		if (!is_sess_active(sess)) {
> > +			printk(KERN_ALERT "sess_reco: sess still not active\n");
> > +			sess->lead_conn->state = CONN_STATE_XPORT_FREEZE;
> > +			return FAILED;
> > +		}
> > +	}
> > +
> > +	return SUCCESS;
> > +}
> > +
> > +
> > +/*
> > + * SCSI host reset handler, which is translates to iSCSI session
> > + *	recovery
> > + */
> > +int bnx2i_do_iscsi_sess_recovery(struct bnx2i_sess *sess, int err_code)
> > +{
> > +	struct bnx2i_hba *hba = NULL;
> > +	struct bnx2i_conn *conn = sess->lead_conn;
> > +
> > +	if (bnx2i_session_recovery_start(sess, err_code) != SUCCESS) {
> > +		printk(KERN_INFO "bnx2i: sess rec start returned error\n");
> > +		return FAILED;
> > +	}
> > +	hba = sess->hba;
> > +
> > +	sess->recovery_state = ISCSI_SESS_RECOVERY_OPEN_ISCSI;
> > +	iscsi_conn_error(conn->cls_conn, ISCSI_ERR_CONN_FAILED);
> > +
> > +	/* if session teardown is because of net interface down,
> > +	 * no need to wait for complete recovery */
> > +	if (err_code == DID_NO_CONNECT) {
> > +		wait_event_interruptible_timeout(sess->er_wait,
> > +						 !conn->ep,
> > +						 msecs_to_jiffies(1000));
> > +	} else {
> > +		wait_event_interruptible(sess->er_wait,
> > +					 ((sess->recovery_state &
> > +					   ISCSI_SESS_RECOVERY_COMPLETE) ||
> > +					  (sess->recovery_state &
> > +					   ISCSI_SESS_RECOVERY_FAILED)));
> > +	}
> > +
> > +	if (signal_pending(current))
> > +		flush_signals(current);
> > +
> > +	if (err_code == DID_NO_CONNECT)
> > +		return SUCCESS;
> > +
> > +	if (sess->recovery_state & ISCSI_SESS_RECOVERY_COMPLETE) {
> > +		printk(KERN_INFO "bnx2i: host #%d reset succeeded\n",
> > +				  sess->host->host_no);
> > +		sess->state = BNX2I_SESS_IN_FFP;
> > +	} else {
> > +		return FAILED;
> > +	}
> > +	sess->recovery_state = 0;
> > +	return SUCCESS;
> > +}
> > +
> > +
> > +/*
> > + * free up resources held by this session
> > + */
> > +int bnx2i_iscsi_sess_release(struct bnx2i_hba *hba, struct bnx2i_sess *sess)
> > +{
> > +	if (!sess)
> > +		return 0;
> > +
> > +	bnx2i_release_free_itt_queue(sess);
> > +	bnx2i_free_cmd_pool(sess);
> > +	bnx2i_free_bd_table_pool(sess);
> > +	bnx2i_free_all_bdt_resc_pages(sess);
> > +
> > +	list_del_init(&sess->link);
> > +	hba->num_active_sess--;
> > +
> > +	return 0;
> > +}
> > +
> > +
> > +/*
> > + * initialize various per session statistic counters
> > + */
> > +static void bnx2i_init_iscsi_sess_stats(struct bnx2i_sess *sess)
> > +{
> > +	if (!sess)
> > +		return;
> > +
> > +	sess->violation_notified = 0;
> > +
> > +	sess->total_data_octets_sent = 0;
> > +	sess->total_data_octets_rcvd = 0;
> > +	sess->conn_login_ok = 0;
> > +	sess->conn_login_failed = 0;
> > +	sess->num_login_req_pdus = 0;
> > +	sess->num_login_resp_pdus = 0;
> > +	sess->num_scsi_cmd_pdus = 0;
> > +	sess->num_scsi_resp_pdus = 0;
> > +	sess->num_nopout_pdus = 0;
> > +	sess->num_nopin_pdus = 0;
> > +	sess->num_reject_pdus = 0;
> > +	sess->num_async_pdus = 0;
> > +	sess->num_dataout_pdus = 0;
> > +	sess->num_r2t_pdus = 0;
> > +	sess->num_datain_pdus = 0;
> > +	sess->num_snack_pdus = 0;
> > +	sess->num_text_req_pdus = 0;
> > +	sess->num_text_resp_pdus = 0;
> > +	sess->num_tmf_req_pdus = 0;
> > +	sess->num_tmf_resp_pdus = 0;
> > +	sess->num_logout_req_pdus = 0;
> > +	sess->num_logout_resp_pdus = 0;
> > +}
> > +
> > +
> > +/*
> > + * set iSCSI parameter values to defaults, as defined in rfc3720
> > + */
> > +static void bnx2i_sess_set_param_defaults(struct bnx2i_sess *sess)
> > +{
> > +	sess->initial_r2t = ISCSI_DEFAULT_INITIAL_R2T;
> > +	sess->max_r2t = ISCSI_DEFAULT_MAX_OUTSTANDING_R2T;
> > +	sess->imm_data = ISCSI_DEFAULT_IMMEDIATE_DATA;
> > +	sess->first_burst_len = ISCSI_DEFAULT_FIRST_BURST_LENGTH;
> > +	sess->max_burst_len = ISCSI_DEFAULT_MAX_BURST_LENGTH;
> > +	sess->time2wait = 2;
> > +	sess->time2retain = 20;
> > +}
> > +
> > +
> > +/*
> > + * initialize session structure elements and allocate per sess resources
> > + */
> > +int bnx2i_iscsi_sess_new(struct bnx2i_hba *hba, struct bnx2i_sess *sess)
> > +{
> > +	int rc;
> > +
> > +	spin_lock(&hba->lock);
> > +	list_add_tail(&sess->link, &hba->active_sess);
> > +	hba->num_active_sess++;
> > +	spin_unlock(&hba->lock);
> > +
> > +	sess->sq_size = hba->max_sqes;
> > +	sess->tsih = 0;
> > +	sess->lead_conn = NULL;
> > +
> > +	spin_lock_init(&sess->lock);
> > +
> > +	/* initialize active connection list */
> > +	INIT_LIST_HEAD(&sess->conn_list);
> > +	INIT_LIST_HEAD(&sess->free_cmds);
> > +
> > +	INIT_LIST_HEAD(&sess->active_cmds);
> > +	sess->num_active_cmds = 0;
> > +
> > +	sess->num_active_conn = 0;
> > +	sess->max_conns = 1;
> > +	sess->conn_id = 0;
> > +	sess->target_name = NULL;
> > +
> > +	sess->state = BNX2I_SESS_INITIAL;
> > +	sess->recovery_state = 0;
> > +
> > +	if (bnx2i_alloc_bd_table_pool(sess) != 0) {
> > +		printk(KERN_ERR "sess_new: unable to alloc bd table pool\n");
> > +		rc = -ENOMEM;
> > +		goto err_bd_pool;
> > +	}
> > +
> > +	if (bnx2i_alloc_cmd_pool(sess) != 0) {
> > +		printk(KERN_ERR "sess_new: alloc cmd pool failed\n");
> > +		rc = -ENOMEM;
> > +		goto err_cmd_pool;
> > +	}
> > +
> > +	rc = bnx2i_setup_free_itt_queue(sess);
> > +	if (rc) {
> > +		rc = -ENOMEM;
> > +		goto err_itt_que;
> > +	}
> > +
> > +	init_timer(&sess->abort_timer);
> > +	init_waitqueue_head(&sess->er_wait);
> > +	init_timer(&sess->poll_timer);
> > +
> > +	bnx2i_init_iscsi_sess_stats(sess);
> > +	bnx2i_sess_set_param_defaults(sess);
> > +
> > +	return 0;
> > +
> > +err_itt_que:
> > +	bnx2i_free_cmd_pool(sess);
> > +err_cmd_pool:
> > +	bnx2i_free_bd_table_pool(sess);
> > +err_bd_pool:
> > +	return rc;
> > +}
> > +
> > +
> > +/*
> > + * Login related resources is freed in this routine.
> > + */
> > +void bnx2i_conn_free_login_resources(struct bnx2i_hba *hba,
> > +				     struct bnx2i_conn *conn)
> > +{
> > +	if (conn->gen_pdu.resp_bd_tbl) {
> > +		pci_free_consistent(hba->pci_dev, PAGE_SIZE,
> > +				    conn->gen_pdu.resp_bd_tbl,
> > +				    conn->gen_pdu.resp_bd_dma);
> > +		conn->gen_pdu.resp_bd_tbl = NULL;
> > +	}
> > +
> > +	if (conn->gen_pdu.req_bd_tbl) {
> > +		pci_free_consistent(hba->pci_dev, PAGE_SIZE,
> > +				    conn->gen_pdu.req_bd_tbl,
> > +				    conn->gen_pdu.req_bd_dma);
> > +		conn->gen_pdu.req_bd_tbl = NULL;
> > +	}
> > +
> > +	if (conn->gen_pdu.resp_buf) {
> > +		pci_free_consistent(hba->pci_dev, ISCSI_CONN_LOGIN_BUF_SIZE,
> > +				    conn->gen_pdu.resp_buf,
> > +				    conn->gen_pdu.resp_dma_addr);
> > +		conn->gen_pdu.resp_buf = NULL;
> > +	}
> > +
> > +	if (conn->gen_pdu.req_buf) {
> > +		pci_free_consistent(hba->pci_dev, ISCSI_CONN_LOGIN_BUF_SIZE,
> > +				    conn->gen_pdu.req_buf,
> > +				    conn->gen_pdu.req_dma_addr);
> > +		conn->gen_pdu.req_buf = NULL;
> > +	}
> > +}
> > +
> > +
> > +/*
> > + * Login & nop-in related resources is allocated in this routine.
> > + */
> > +static int bnx2i_conn_alloc_login_resources(struct bnx2i_hba *hba,
> > +					    struct bnx2i_conn *conn)
> > +{
> > +	/* Allocate memory for login request/response buffers */
> > +	conn->gen_pdu.req_buf =
> > +		(char *) pci_alloc_consistent(hba->pci_dev,
> > +					      ISCSI_CONN_LOGIN_BUF_SIZE,
> > +					      &conn->gen_pdu.req_dma_addr);
> > +	if (conn->gen_pdu.req_buf == NULL)
> > +		goto login_req_buf_failure;
> > +
> > +	conn->gen_pdu.req_buf_size = 0;
> > +	conn->gen_pdu.req_wr_ptr = conn->gen_pdu.req_buf;
> > +
> > +	conn->gen_pdu.resp_buf =
> > +		(char *) pci_alloc_consistent(hba->pci_dev,
> > +					      ISCSI_CONN_LOGIN_BUF_SIZE,
> > +					      &conn->gen_pdu.resp_dma_addr);
> > +	if (conn->gen_pdu.resp_buf == NULL)
> > +		goto login_resp_buf_failure;
> > +
> > +	conn->gen_pdu.resp_buf_size = ISCSI_CONN_LOGIN_BUF_SIZE;
> > +	conn->gen_pdu.resp_wr_ptr = conn->gen_pdu.resp_buf;
> > +	
> > +	conn->gen_pdu.req_bd_tbl =
> > +		(char *) pci_alloc_consistent(hba->pci_dev, PAGE_SIZE,
> > +					      &conn->gen_pdu.req_bd_dma);
> > +	if (conn->gen_pdu.req_bd_tbl == NULL)
> > +		goto login_req_bd_tbl_failure;
> > +
> > +	conn->gen_pdu.resp_bd_tbl =
> > +		(char *) pci_alloc_consistent(hba->pci_dev, PAGE_SIZE,
> > +					      &conn->gen_pdu.resp_bd_dma);
> > +	if (conn->gen_pdu.resp_bd_tbl == NULL)
> > +		goto login_resp_bd_tbl_failure;
> > +
> > +	return 0;
> > +
> > +login_resp_bd_tbl_failure:
> > +	pci_free_consistent(hba->pci_dev, PAGE_SIZE, conn->gen_pdu.req_bd_tbl,
> > +			    conn->gen_pdu.req_bd_dma);
> > +	conn->gen_pdu.req_bd_tbl = NULL;
> > +
> > +login_req_bd_tbl_failure:
> > +	pci_free_consistent(hba->pci_dev, ISCSI_CONN_LOGIN_BUF_SIZE,
> > +			    conn->gen_pdu.resp_buf,
> > +			    conn->gen_pdu.resp_dma_addr);
> > +	conn->gen_pdu.resp_buf = NULL;
> > +login_resp_buf_failure:
> > +	pci_free_consistent(hba->pci_dev, ISCSI_CONN_LOGIN_BUF_SIZE,
> > +			    conn->gen_pdu.req_buf, conn->gen_pdu.req_dma_addr);
> > +	conn->gen_pdu.req_buf = NULL;
> > +login_req_buf_failure:
> > +	printk(KERN_ERR "bnx2i:a conn login resource alloc failed!!\n");
> > +	return -ENOMEM;
> > +
> > +}
> > +
> > +
> > +/*
> > + * connection structure is initialized in this routine.
> > + */
> > +int bnx2i_iscsi_conn_new(struct bnx2i_sess *sess, struct bnx2i_conn *conn)
> > +{
> > +	int ret_code = 0;
> > +	struct bnx2i_hba *hba = sess->hba;
> > +
> > +	if (!sess || !conn || !hba)
> > +		return -EINVAL;
> > +
> > +	conn->sess = sess;
> > +	conn->header_digest_en = 0;
> > +	conn->data_digest_en = 0;
> > +
> > +	spin_lock_init(&conn->lock);
> > +
> > +	init_timer(&conn->poll_timer);
> > +	conn->gen_pdu.cmd = NULL;
> > +
> > +	/* 'ep' ptr will be assigned in bind() call */
> > +	conn->ep = NULL;
> > +
> > +	ret_code = bnx2i_conn_alloc_login_resources(hba, conn);
> > +	if (ret_code != 0) {
> > +		printk(KERN_ALERT "conn_new: login resc alloc failed!!\n");
> > +		return -ENOMEM;
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +
> > +/*
> > + * extract & update SN counters from login response
> > + */
> > +static int bnx2i_login_resp_update_cmdsn(struct bnx2i_conn *conn)
> > +{
> > +	u32 max_cmdsn;
> > +	u32 exp_cmdsn;
> > +	u32 stat_sn;
> > +	struct bnx2i_sess *sess = conn->sess;
> > +	struct iscsi_nopin *hdr = NULL;
> > +
> > +	hdr = (struct iscsi_nopin *) &conn->gen_pdu.resp_hdr;
> > +
> > +	max_cmdsn = ntohl(hdr->max_cmdsn);
> > +	exp_cmdsn = ntohl(hdr->exp_cmdsn);
> > +	stat_sn = ntohl(hdr->statsn);
> > +#define SN_DELTA_ISLAND		0xffff
> > +	if (max_cmdsn < exp_cmdsn -1 &&
> > +	    max_cmdsn > exp_cmdsn - SN_DELTA_ISLAND)
> > +		return -EINVAL;
> > +
> > +	if (max_cmdsn > sess->max_cmdsn ||
> > +	    max_cmdsn < sess->max_cmdsn - SN_DELTA_ISLAND)
> > +		sess->max_cmdsn = max_cmdsn;
> > +
> > +	if (exp_cmdsn > sess->exp_cmdsn ||
> > +	    exp_cmdsn < sess->exp_cmdsn - SN_DELTA_ISLAND) {
> > +		sess->exp_cmdsn = exp_cmdsn;
> > +	}
> > +	if (stat_sn == conn->exp_statsn)
> > +		conn->exp_statsn++;
> > +
> > +	return 0;
> > +}
> > +
> > +
> > +/*
> > + * update iSCSI SN counters for the given session
> > + */
> > +void bnx2i_update_cmd_sequence(struct bnx2i_sess *sess,
> > +			       u32 exp_sn, u32 max_sn)
> > +{
> > +	u32 exp_cmdsn = exp_sn;
> > +	u32 max_cmdsn = max_sn;
> > +
> > +	if (max_cmdsn < exp_cmdsn -1 &&
> > +	    max_cmdsn > exp_cmdsn - SN_DELTA_ISLAND) {
> > +		printk(KERN_ALERT "cmd_sequence: error, exp 0x%x, max 0x%x\n",
> > +				   exp_cmdsn, max_cmdsn);
> > +		BUG_ON(1);
> > +	}
> > +	if (max_cmdsn > sess->max_cmdsn ||
> > +	    max_cmdsn < sess->max_cmdsn - SN_DELTA_ISLAND)
> > +		sess->max_cmdsn = max_cmdsn;
> > +	if (exp_cmdsn > sess->exp_cmdsn ||
> > +	    exp_cmdsn < sess->exp_cmdsn - SN_DELTA_ISLAND) {
> > +		sess->exp_cmdsn = exp_cmdsn;
> > +	}
> > +
> > +	return;
> > +}
> > +
> > +
> > +/*
> > + * This function propogates SCSI response to SCSI-ML by calling
> > + *	scsi_done() and also returns command struct back to free pool
> > + */
> > +int bnx2i_process_scsi_resp(struct bnx2i_cmd *cmd)
> > +{
> > +	int ret = 0;
> > +	struct scsi_cmnd *sc = cmd->scsi_cmd;
> > +	struct Scsi_Host *host;
> > +	int res_count = 0;
> > +
> > +	if (!sc)
> > +		return 0;
> > +
> > +	host = cmd->conn->sess->host;
> > +	sc->result = (DID_OK << 16) | cmd->scsi_status;
> > +
> > +	if (cmd->iscsi_resp != ISCSI_STATUS_CMD_COMPLETED) {
> > +		sc->result = (DID_ERROR << 16);
> > +		goto call_scsi_done;
> > +	}
> > +
> > +	if (sc->sc_data_direction == DMA_TO_DEVICE) {
> > +		goto call_scsi_done;
> > +	}
> > +	
> > +	if (cmd->scsi_uflow) {
> > +		res_count = cmd->resi_len;
> > +		if (res_count > 0 && res_count <= sc->request_bufflen)
> > +			sc->resid = res_count;
> > +		else
> > +			sc->result = (DID_BAD_TARGET << 16) |
> > +				     cmd->scsi_status;
> > +	} else if (cmd->scsi_oflow) {
> > +		sc->resid = res_count;
> > +	}
> > +
> > +call_scsi_done:
> > +	if ((cmd->cmd_state == ISCSI_CMD_STATE_ABORT_PEND) ||
> > +	    (cmd->cmd_state == ISCSI_CMD_STATE_CLEANUP_PEND)) {
> > +		printk(KERN_ALERT "scsi_resp: command is being aborted\n");
> > +		return -1;
> > +	}
> > +
> > +	spin_lock(host->host_lock);
> > +	cmd->scsi_cmd = NULL;
> > +	cmd->conn->sess->num_active_cmds--;
> > +	sc->scsi_done(sc);
> > +	bnx2i_free_cmd(cmd->conn->sess, cmd);
> > +	spin_unlock(host->host_lock);
> > +	return ret;
> > +}
> > +
> > +
> > +
> > +/*
> > + * login response PDU is pushed to application daemon by
> > + *		calling iscsi_recv_pdu()
> > + */
> > +int bnx2i_indicate_login_resp(struct bnx2i_conn *conn)
> > +{
> > +	int ret = 0;
> > +	int data_len = 0;
> > +	struct iscsi_login_rsp *login_resp =
> > +		(struct iscsi_login_rsp *) &conn->gen_pdu.resp_hdr;
> > +
> > +	/* check if this is the first login response for this connection.
> > +	 * If yes, we need to copy initial StatSN to connection structure.
> > +	 */
> > +	if (conn->exp_statsn == STATSN_UPDATE_SIGNATURE) {
> > +		conn->exp_statsn = ntohl(login_resp->statsn) + 1;
> > +	}
> > +
> > +	ret = bnx2i_login_resp_update_cmdsn(conn);
> > +	if (ret != 0) {
> > +		return -EINVAL;
> > +	}
> > +
> > +	data_len = conn->gen_pdu.resp_wr_ptr - conn->gen_pdu.resp_buf;
> > +	iscsi_recv_pdu(conn->cls_conn, (struct iscsi_hdr *) login_resp,
> > +		       (char *) conn->gen_pdu.resp_buf, data_len);
> > +
> > +	return 0;
> > +}
> > +
> > +
> > +/*
> > + * deliver logout response PDU to application daemon
> > + */
> > +int bnx2i_indicate_logout_resp(struct bnx2i_conn *conn)
> > +{
> > +	struct iscsi_logout_rsp *logout_resp =
> > +		(struct iscsi_logout_rsp *) &conn->gen_pdu.resp_hdr;
> > +
> > +	iscsi_recv_pdu(conn->cls_conn, (struct iscsi_hdr *) logout_resp,
> > +		       (char *) NULL, 0);
> > +
> > +	return 0;
> > +}
> > +
> > +
> > +/*
> > + * deliver iSCSI async PDU to user daemon
> > + */
> > +int bnx2i_indicate_async_mesg(struct bnx2i_conn *conn)
> > +{
> > +	struct iscsi_async *async_msg =
> > +		(struct iscsi_async *) &conn->gen_pdu.resp_hdr;
> > +
> > +	iscsi_recv_pdu(conn->cls_conn, (struct iscsi_hdr *) async_msg,
> > +		       (char *) NULL, 0);
> > +
> > +	return 0;
> > +}
> > +
> > +
> > +
> > +/*
> > + * Function : bnx2i_process_nopin
> > + */
> > +int bnx2i_process_nopin(struct bnx2i_conn *conn, struct bnx2i_cmd *cmd,
> > +			char *data_buf, int data_len)
> > +{
> > +	struct iscsi_nopin *nopin_msg =
> > +		(struct iscsi_nopin *) &conn->gen_pdu.resp_hdr;
> > +
> > +	iscsi_recv_pdu(conn->cls_conn, (struct iscsi_hdr *) nopin_msg,
> > +		       (char *) data_buf, data_len);
> > +
> > +	spin_lock(conn->sess->host->host_lock);
> > +	list_del_init(&cmd->link);
> > +	bnx2i_free_cmd(cmd->conn->sess, cmd);
> > +	spin_unlock(conn->sess->host->host_lock);
> > +
> > +	return 0;
> > +}
> > +
> > +
> > +
> > +/*
> > + * Allocates buffers and BD tables before shipping requests to cnic
> > + *	for PDUs prepared by 'iscsid' daemon
> > + */
> > +static void bnx2i_iscsi_prep_generic_pdu_bd(struct bnx2i_conn *conn)
> > +{
> > +	struct iscsi_bd *bd_tbl = NULL;
> > +
> > +	bd_tbl = (struct iscsi_bd *) conn->gen_pdu.req_bd_tbl;
> > +
> > +	bd_tbl->buffer_addr_hi =
> > +		(u32) ((u64) conn->gen_pdu.req_dma_addr >> 32);
> > +	bd_tbl->buffer_addr_lo = (u32) conn->gen_pdu.req_dma_addr;
> > +	bd_tbl->buffer_length = conn->gen_pdu.req_wr_ptr -
> > +				conn->gen_pdu.req_buf;
> > +	bd_tbl->reserved0 = 0;
> > +	bd_tbl->flags = ISCSI_BD_LAST_IN_BD_CHAIN |
> > +			ISCSI_BD_FIRST_IN_BD_CHAIN;
> > +
> > +	bd_tbl = (struct iscsi_bd  *) conn->gen_pdu.resp_bd_tbl;
> > +	bd_tbl->buffer_addr_hi = (u64) conn->gen_pdu.resp_dma_addr >> 32;
> > +	bd_tbl->buffer_addr_lo = (u32) conn->gen_pdu.resp_dma_addr;
> > +	bd_tbl->buffer_length = ISCSI_CONN_LOGIN_BUF_SIZE;
> > +	bd_tbl->reserved0 = 0;
> > +	bd_tbl->flags = ISCSI_BD_LAST_IN_BD_CHAIN |
> > +			ISCSI_BD_FIRST_IN_BD_CHAIN;
> > +}
> > +
> > +
> > +
> > +/*
> > + * called to transmit PDUs prepared by the 'iscsid' daemon. iSCSI login,
> > + *	Nop-out and Logout requests flow through this path.
> > + */
> > +static int bnx2i_iscsi_send_generic_request(struct bnx2i_cmd *cmnd)
> > +{
> > +	int rc = 0;
> > +	char *buf = NULL;
> > +	int data_len = 0;
> > +	struct bnx2i_conn *conn = cmnd->conn;
> > +
> > +	bnx2i_iscsi_prep_generic_pdu_bd(conn);
> > +	switch (cmnd->iscsi_opcode & ISCSI_OPCODE_MASK) {
> > +	case ISCSI_OP_LOGIN:
> > +		bnx2i_send_iscsi_login(conn, cmnd);
> > +		break;
> > +
> > +	case ISCSI_OP_NOOP_OUT:
> > +		data_len = conn->gen_pdu.req_buf_size;
> > +		buf = conn->gen_pdu.req_buf;
> > +		if (data_len)
> > +			rc = bnx2i_send_iscsi_nopout(conn, cmnd,
> > +						     ISCSI_RESERVED_TAG,
> > +						     buf, data_len, 1);
> > +		else
> > +			rc = bnx2i_send_iscsi_nopout(conn, cmnd,
> > +						     ISCSI_RESERVED_TAG,
> > +						     NULL, 0, 1);
> > +		break;
> > +
> > +	case ISCSI_OP_LOGOUT:
> > +		rc = bnx2i_send_iscsi_logout(conn, cmnd);
> > +		break;
> > +
> > +	default:
> > +		printk(KERN_ALERT "send_gen: unsupported op 0x%x\n",
> > +				   cmnd->iscsi_opcode);
> > +	}
> > +	return rc;
> > +}
> > +
> > +
> > +/**********************************************************************
> > + *		SCSI-ML Interface
> > + **********************************************************************/
> > +
> > +static void bnx2i_cpy_scsi_cdb(struct scsi_cmnd *sc,
> > +				      struct bnx2i_cmd *cmd)
> > +{
> > +	u32 dword;
> > +	int lpcnt = 0;
> > +	u8 *srcp = NULL;
> > +	u32 *dstp = NULL;
> > +	u32 scsi_lun[2];
> > +
> > +	int_to_scsilun(sc->device->lun, (struct scsi_lun *) scsi_lun);
> > +	cmd->req.lun[0] = ntohl(scsi_lun[0]);
> > +	cmd->req.lun[1] = ntohl(scsi_lun[1]);
> > +
> > +	lpcnt = cmd->scsi_cmd->cmd_len / sizeof(dword);
> > +	srcp = (u8 *) sc->cmnd;
> > +	dstp = (u32 *) cmd->req.cdb;
> > +	while (lpcnt--) {
> > +		memcpy(&dword, srcp, 4);
> > +		*dstp = cpu_to_be32(dword);
> > +		srcp += 4;
> > +		dstp++;
> > +	}
> > +	if (sc->cmd_len & 0x3) {
> > +		dword = (u32) srcp[0] | ((u32) srcp[1] << 8);
> > +		*dstp = cpu_to_be32(dword);
> > +	}
> > +}
> > +
> > +
> > +
> > +/*
> > + * handles SCSI command queued by SCSI-ML, allocates a command structure,
> > + *	assigning CMDSN, mapping SG buffers and handing over request to CNIC.
> > + */
> > +int bnx2i_queuecommand(struct scsi_cmnd *sc,
> > +		       void (*done) (struct scsi_cmnd *))
> > +{
> > +	struct Scsi_Host *shost;
> > +	struct bnx2i_sess *sess = NULL;
> > +	struct bnx2i_conn *conn = NULL;
> > +	struct bnx2i_cmd *cmd = NULL;
> > +	struct bnx2i_hba *hba = NULL;
> > +	static int old_recovery_state = 0;
> > +
> > +	sc->scsi_done = done;
> > +	sc->result = 0;
> > +	shost = sc->device->host;
> > +	sess = iscsi_hostdata(shost->hostdata);
> > +	BUG_ON(shost != sess->host);
> > +
> > +	if (sess) {
> > +		hba = sess->hba;
> > +	} else {
> > +		printk(KERN_ALERT "bnx2i: quecmd: Error dev not found \n");
> > +		goto dev_not_found;
> > +	}
> > +
> > +#define iscsi_cmd_win_closed(_sess)	\
> > +	((int) (_sess->max_cmdsn - _sess->cmdsn) < 0)
> > +
> > +	if (iscsi_cmd_win_closed(sess)) {
> > +		goto iscsi_win_closed;
> > +	}
> > +
> > +	if ((sess->state & BNX2I_SESS_IN_SHUTDOWN) ||
> > +		(sess->state & BNX2I_SESS_IN_LOGOUT)) {
> > +		goto dev_not_found;
> > +	}
> > +
> > +	if (sess->recovery_state) {
> > +		if (old_recovery_state != sess->recovery_state) {
> > +			old_recovery_state = sess->recovery_state;
> > +		}
> > +
> > +		if (sess->recovery_state & ISCSI_SESS_RECOVERY_FAILED)
> > +			goto dev_not_found;
> > +		else if (!(sess->recovery_state & ISCSI_SESS_RECOVERY_COMPLETE))
> > +			goto iscsi_win_closed;
> > +		else
> > +			sess->recovery_state = 0;
> > +	}
> > +
> > +	cmd = bnx2i_alloc_cmd(sess);
> > +	if (cmd == NULL) {
> > +		/* This should never happen as cmd list size == SHT->can_queue
> > +		 */
> > +		goto cmd_not_accepted;
> > +	}
> > +
> > +	cmd->conn = conn = sess->lead_conn;
> > +	cmd->scsi_cmd = sc;
> > +	cmd->req.total_data_transfer_length = sc->request_bufflen;
> > +	cmd->iscsi_opcode = ISCSI_OPCODE_SCSI_CMD;
> > +	cmd->req.cmd_sn = sess->cmdsn++;
> > +
> > +	bnx2i_iscsi_map_sg_list(cmd);
> > +	bnx2i_cpy_scsi_cdb(sc, cmd);
> > +
> > +	if (sc->sc_data_direction == DMA_TO_DEVICE) {
> > +		cmd->req.op_attr = ISCSI_CMD_REQUEST_WRITE;
> > +		cmd->req.itt |= (ISCSI_TASK_TYPE_WRITE <<
> > +				 ISCSI_CMD_REQUEST_TYPE_SHIFT);
> > +		bnx2i_setup_write_cmd_bd_info(cmd);
> > +	} else {
> > +		cmd->req.op_attr = ISCSI_CMD_REQUEST_READ;
> > +		cmd->req.itt |= (ISCSI_TASK_TYPE_READ <<
> > +				 ISCSI_CMD_REQUEST_TYPE_SHIFT);
> > +	}
> > +	cmd->req.num_bds = cmd->bd_tbl->bd_valid;
> > +	if (!cmd->bd_tbl->bd_valid) {
> > +		cmd->req.bd_list_addr_lo = (u32) hba->mp_bd_dma;
> > +		cmd->req.bd_list_addr_hi =
> > +			(u32) ((u64) hba->mp_bd_dma >> 32);
> > +		cmd->req.num_bds = 1;
> > +	}
> > +
> > +	cmd->cmd_state = ISCSI_CMD_STATE_INITIATED;
> > +	sc->SCp.ptr = (char *) cmd;
> > +
> > +	if (cmd->req.itt != ITT_INVALID_SIGNATURE) {
> > +		bnx2i_send_iscsi_scsicmd(conn, cmd);
> > +		list_add_tail(&cmd->link, &sess->active_cmds);
> > +		sess->num_active_cmds++;
> > +	}
> > +	return 0;
> > +
> > +iscsi_win_closed:
> > +cmd_not_accepted:
> > +	return SCSI_MLQUEUE_HOST_BUSY;
> > +
> > +dev_not_found:
> > +	sc->sense_buffer[0] = 0x70;
> > +	sc->sense_buffer[2] = NOT_READY;
> > +	sc->sense_buffer[7] = 0x6;
> > +	sc->sense_buffer[12] = 0x08;
> > +	sc->sense_buffer[13] = 0x00;
> > +	sc->result = (DID_NO_CONNECT << 16);
> > +	sc->resid = sc->request_bufflen;
> > +	sc->scsi_done(sc);
> > +	return 0;
> > +}
> > +
> > +
> > +
> > +/*
> > + * TMF request timeout handler
> > + */
> > +static void bnx2i_iscsi_tmf_timer(unsigned long data)
> > +{
> > +	struct bnx2i_cmd *cmd = (struct bnx2i_cmd *) data;
> > +
> > +	printk(KERN_ALERT "TMF timer: abort failed, cmd 0x%p\n", cmd);
> > +	cmd->cmd_state = ISCSI_CMD_STATE_FAILED;
> > +	wake_up(&cmd->conn->sess->er_wait);
> > +}
> > +
> > +
> > +/*
> > + * initiate command abort process by requesting CNIC to send
> > + *	an iSCSI TMF request to target
> > + */
> > +static int bnx2i_initiate_abort_cmd(struct scsi_cmnd *sc)
> > +{
> > +	struct bnx2i_cmd *cmd = (struct bnx2i_cmd *) sc->SCp.ptr;
> > +	struct bnx2i_cmd *tmf_cmd = NULL;
> > +	struct Scsi_Host *shost = cmd->scsi_cmd->device->host;
> > +	struct bnx2i_conn *conn = cmd->conn;
> > +	struct bnx2i_sess *sess = NULL;
> > +	struct bnx2i_hba *hba = NULL;
> > +
> > +	shost = cmd->scsi_cmd->device->host;
> > +	sess = iscsi_hostdata(shost->hostdata);
> > +	BUG_ON(shost != sess->host);
> > +
> > +	if (sess && (is_sess_active(sess))) {
> > +		hba = sess->hba;
> > +	} else {
> > +		return FAILED;
> > +	}
> > +
> > +	bnx2i_setup_ictx_dump(hba, conn);
> > +
> > +	if (cmd->scsi_cmd != sc) {
> > +		/* command already completed to scsi mid-layer */
> > +		goto cmd_not_active;
> > +	}
> > +
> > +	tmf_cmd = bnx2i_alloc_cmd(sess);
> > +	if (cmd == NULL) {
> > +		goto lack_of_resc;
> > +	}
> > +
> > +	tmf_cmd->conn = conn = sess->lead_conn;
> > +	tmf_cmd->scsi_cmd = NULL;
> > +	tmf_cmd->iscsi_opcode = ISCSI_OPCODE_TMF_REQUEST;
> > +	tmf_cmd->req.cmd_sn = sess->cmdsn;
> > +	tmf_cmd->tmf_ref_itt = cmd->req.itt;
> > +	tmf_cmd->tmf_ref_cmd = cmd;
> > +	tmf_cmd->tmf_ref_sc = cmd->scsi_cmd;
> > +	cmd->cmd_state = ISCSI_CMD_STATE_ABORT_PEND;
> > +	tmf_cmd->cmd_state = ISCSI_CMD_STATE_INITIATED;
> > +
> > +	sess->abort_timer.expires = 10*HZ + jiffies;
> > +	sess->abort_timer.function = bnx2i_iscsi_tmf_timer;
> > +	sess->abort_timer.data = (unsigned long)tmf_cmd;
> > +	add_timer(&sess->abort_timer);
> > +
> > +	bnx2i_send_iscsi_tmf(conn, tmf_cmd);
> > +
> > +	/* update iSCSI context for this conn, wait for CNIC to complete */
> > +	wait_event_interruptible(sess->er_wait,
> > +		 tmf_cmd->cmd_state != ISCSI_CMD_STATE_INITIATED);
> > +
> > +	if (signal_pending(current))
> > +		flush_signals(current);
> > +
> > +	del_timer_sync(&sess->abort_timer);
> > +
> > +	if (tmf_cmd->cmd_state == ISCSI_CMD_STATE_FAILED) {
> > +		printk(KERN_ALERT "abort: abort failed, cmd 0x%p\n", tmf_cmd);
> > +		/* TMF timed out, return error status and let SCSI-ML do
> > +		 * session recovery.
> > +		 */
> > +		list_del_init(&tmf_cmd->link);
> > +		bnx2i_free_cmd(sess, tmf_cmd);
> > +		return FAILED;
> > +	}
> > +
> > +	list_del_init(&tmf_cmd->link);
> > +	bnx2i_free_cmd(sess, tmf_cmd);
> > +
> > +	if ((cmd->scsi_cmd->result & 0xFF0000) == (DID_ABORT << 16)) {
> > +		cmd->cmd_state = ISCSI_CMD_STATE_CLEANUP_PEND;
> > +		bnx2i_send_cmd_cleanup_req(hba, cmd);
> > +		wait_event_interruptible_timeout(sess->er_wait,
> > +						 (cmd->cmd_state ==
> > +						  ISCSI_CMD_STATE_CLEANUP_CMPL),
> > +						 msecs_to_jiffies(
> > +						  ISCSI_CMD_CLEANUP_TIMEOUT));
> > +
> > +		if (signal_pending(current))
> > +			flush_signals(current);
> > +	} else {
> > +		cmd->scsi_cmd->result = (DID_ABORT << 16);
> > +	}
> > +	cmd->conn->sess->num_active_cmds--;
> > +	list_del_init(&cmd->link);
> > +	cmd->scsi_cmd = NULL;
> > +	bnx2i_free_cmd(cmd->conn->sess, cmd);
> > +
> > +cmd_not_active:
> > +	return SUCCESS;
> > +
> > +lack_of_resc:
> > +	return FAILED;
> > +}
> > +
> > +
> > +/*
> > + * SCSI abort request handler.
> > + */
> > +int bnx2i_abort(struct scsi_cmnd *sc)
> > +{
> > +	int reason;
> > +	struct bnx2i_cmd *cmd = (struct bnx2i_cmd *) sc->SCp.ptr;
> > +
> > +	if (unlikely(!cmd)) {
> > +		/* command already completed to scsi mid-layer */
> > +		printk(KERN_INFO "bnx2i_abort: sc 0x%p, not active\n", sc);
> > +		return SUCCESS;
> > +	}
> > +
> > +	reason = bnx2i_initiate_abort_cmd(sc);
> > +	return reason;
> > +}
> > +
> > +
> > +
> > +/*
> > + * hardware reset
> > + */
> > +int bnx2i_reset(struct scsi_cmnd *sc)
> > +{
> > +	return 0;
> > +}
> > +
> > +
> > +void bnx2i_return_failed_command(struct bnx2i_sess *sess,
> > +				 struct bnx2i_cmd *cmd, int err_code)
> > +{
> > +	struct scsi_cmnd *sc = cmd->scsi_cmd;
> > +	sc->result = err_code << 16;
> > +	sc->resid = cmd->scsi_cmd->request_bufflen;
> > +	cmd->scsi_cmd = NULL;
> > +	sess->num_active_cmds--;
> > +	sc->scsi_done(sc);
> > +}
> > +
> > +
> > +
> > +/*
> > + * SCSI host reset handler - iSCSI session recovery
> > + */
> > +int bnx2i_host_reset(struct scsi_cmnd *sc)
> > +{
> > +	struct Scsi_Host *shost = sc->device->host;
> > +	struct bnx2i_sess *sess = NULL;
> > +	int rc = 0;
> > +
> > +	shost = sc->device->host;
> > +	sess = iscsi_hostdata(shost->hostdata);
> > +	printk(KERN_INFO "bnx2i: attempting to reset host, #%d\n",
> > +			  sess->host->host_no);
> > +
> > +	BUG_ON(shost != sess->host);
> > +	rc = bnx2i_do_iscsi_sess_recovery(sess, DID_RESET);
> > +
> > +	return rc;
> > +}
> > +
> > +
> > +
> > +/**********************************************************************
> > + *		open-iscsi interface
> > + **********************************************************************/
> > +
> > +
> > +#define get_bnx2_device(_hba, _devc) 	do {				\
> > +		if ((_hba->pci_did == PCI_DEVICE_ID_NX2_5706) || 	\
> > +			(_hba->pci_did == PCI_DEVICE_ID_NX2_5706S)) {	\
> > +			_devc = '6';					\
> > +		} else if ((_hba->pci_did == PCI_DEVICE_ID_NX2_5708) ||	\
> > +			(_hba->pci_did == PCI_DEVICE_ID_NX2_5708S)) {	\
> > +			_devc = '8';					\
> > +		} else if ((_hba->pci_did == PCI_DEVICE_ID_NX2_5709) ||	\
> > +			(_hba->pci_did == PCI_DEVICE_ID_NX2_5709S)) {	\
> > +			_devc = '9';					\
> > +		}							\
> > +	} while (0)
> > +
> > +/* from open-iscsi project */
> > +/*
> > + * iSCSI Session's hostdata organization:
> > + *
> > + *    *------------------* <== hostdata_session(host->hostdata)
> > + *    | ptr to class sess|
> > + *    |------------------| <== iscsi_hostdata(host->hostdata)
> > + *    | iscsi_session    |
> > + *    *------------------*
> > + */
> > +
> > +#define hostdata_privsize(_sz)	(sizeof(unsigned long) + _sz + \
> > +				 _sz % sizeof(unsigned long))
> > +
> > +#define hostdata_session(_hostdata) (iscsi_ptr(*(unsigned long *)_hostdata))
> > +
> > +#define session_to_cls(_sess) 	hostdata_session(_sess->host->hostdata)
> > +
> > +
> > +
> > +
> > +/*
> > + * Function: bnx2i_register_xport
> > + * Description: this routine will allocate memory for SCSI host template,
> > + * 		iSCSI template and registers one instance of NX2 device with
> > + *		iSCSI Transport Kernel module.
> > + */
> > +int bnx2i_register_xport(struct bnx2i_hba *hba)
> > +{
> > +	void *mem_ptr = NULL;
> > +	char dev_id = '8';
> > +
> > +	if (!hba)
> > +		return -EINVAL;
> > +
> > +	get_bnx2_device(hba, dev_id);
> > +
> > +	mem_ptr = kmalloc(sizeof(struct scsi_host_template), GFP_KERNEL);
> > +	hba->scsi_template = (struct scsi_host_template *) mem_ptr;
> > +	if (hba->scsi_template == NULL) {
> > +		printk(KERN_ALERT "bnx2i: failed to alloc memory for sht\n");
> > +		return -ENOMEM;
> > +	}
> > +
> > +	mem_ptr = kmalloc(sizeof(struct iscsi_transport), GFP_KERNEL);
> > +	hba->iscsi_transport = (struct iscsi_transport *) mem_ptr;
> > +	if (hba->iscsi_transport == NULL) {
> > +		printk(KERN_ALERT "mem error for iscsi_transport template\n");
> > +		goto iscsi_xport_err;
> > +	}
> > +
> > +	mem_ptr = kmalloc(BRCM_ISCSI_XPORT_NAME_SIZE_MAX, GFP_KERNEL);
> > +	if (mem_ptr == NULL) {
> > +		printk(KERN_ALERT "failed to alloc memory for xport name\n");
> > +		goto scsi_name_mem_err;
> > +	}
> > +
> > +	memcpy((void *) hba->scsi_template,
> > +	       (const void *) &bnx2i_host_template,
> > +	       sizeof(struct scsi_host_template));
> > +	hba->scsi_template->name = mem_ptr;
> > +	memcpy((void *) hba->scsi_template->name,
> > +	       (const void *) bnx2i_host_template.name,
> > +	       strlen(bnx2i_host_template.name) + 1);
> > +
> > +	mem_ptr = kmalloc(BRCM_ISCSI_XPORT_NAME_SIZE_MAX, GFP_KERNEL);
> > +	if (mem_ptr == NULL) {
> > +		printk(KERN_ALERT "failed to alloc proc name mem\n");
> > +		goto scsi_proc_name_mem_err;
> > +	}
> > +	hba->scsi_template->proc_name = mem_ptr;
> > +
> > +	memcpy((void *) hba->iscsi_transport,
> > +	       (const void *) &bnx2i_iscsi_transport,
> > +	       sizeof(struct iscsi_transport));
> > +
> > +	hba->iscsi_transport->host_template = hba->scsi_template;
> > +
> > +	mem_ptr = kmalloc(BRCM_ISCSI_XPORT_NAME_SIZE_MAX, GFP_KERNEL);
> > +	if (mem_ptr == NULL) {
> > +		printk(KERN_ALERT "mem alloc error, iscsi xport name\n");
> > +		goto xport_name_mem_err;
> > +	}
> > +	hba->iscsi_transport->name = mem_ptr;
> > +	sprintf(mem_ptr, "%s%c-%.2x%.2x%.2x", BRCM_ISCSI_XPORT_NAME_PREFIX,
> > +			 dev_id, (u8)hba->pci_dev->bus->number,
> > +			 hba->pci_devno, (u8)hba->pci_func);
> > +
> > +	memcpy((void *)hba->scsi_template->proc_name,
> > +	       (const void *)mem_ptr, strlen(mem_ptr) + 1);
> > +
> > +	hba->shost_template = iscsi_register_transport(hba->iscsi_transport);
> > +	if (!hba->shost_template) {
> > +		printk(KERN_ALERT "bnx2i: xport reg failed, hba 0x%p\n", hba);
> > +		goto failed_registration;
> > +	}
> > +	printk(KERN_ALERT "bnx2i: netif=%s, iscsi=%s\n",
> > +			  hba->netdev->name, hba->scsi_template->proc_name);
> > +	return 0;
> > +
> > +failed_registration:
> > +	kfree(hba->iscsi_transport->name);
> > +xport_name_mem_err:
> > +	kfree(hba->scsi_template->proc_name);
> > +scsi_proc_name_mem_err:
> > +	kfree(hba->scsi_template->name);
> > +scsi_name_mem_err:
> > +	kfree(hba->iscsi_transport);
> > +iscsi_xport_err:
> > +	kfree(hba->scsi_template);
> > +	printk(KERN_ALERT "register iscsi xport failed, hba 0x%p\n", hba);
> > +	return -ENOMEM;
> > +}
> > +
> > +
> > +/*
> > + * Function: bnx2i_deregister_xport
> > + * Description: this routine will de-allocate memory for SCSI host template,
> > + * 		iSCSI template and de-registers a NX2 device instance
> > + */
> > +int bnx2i_deregister_xport(struct bnx2i_hba *hba)
> > +{
> > +	if (!hba)
> > +		return -EINVAL;
> > +
> > +	iscsi_unregister_transport(hba->iscsi_transport);
> > +	hba->shost_template = NULL;
> > +
> > +	if (hba->scsi_template->name) {
> > +		kfree(hba->scsi_template->name);
> > +		hba->scsi_template->name = NULL;
> > +	}
> > +	if (hba->scsi_template) {
> > +		kfree(hba->scsi_template);
> > +		hba->scsi_template = NULL;
> > +	}
> > +	if (hba->iscsi_transport->name) {
> > +		kfree(hba->iscsi_transport->name);
> > +		hba->iscsi_transport->name = NULL;
> > +	}
> > +	if (hba->iscsi_transport) {
> > +		kfree(hba->iscsi_transport);
> > +		hba->iscsi_transport = NULL;
> > +	}
> > +	return 0;
> > +}
> > +
> > +
> > +/*
> > + * Function: bnx2i_session_create
> > + * Description: Creates a new iSCSI session instance on given device.
> > + */
> > +struct iscsi_cls_session *
> > +	bnx2i_session_create(struct iscsi_transport *it,
> > +			     struct scsi_transport_template *scsit,
> > +			     uint16_t cmds_max, uint16_t qdepth,
> > +			     uint32_t initial_cmdsn, uint32_t *host_no)
> > +{
> > +	struct bnx2i_hba *hba = NULL;
> > +	struct bnx2i_sess *sess = NULL;
> > +	struct Scsi_Host *shost;
> > +	struct iscsi_cls_session *cls_session;
> > +	int ret_code = 0;
> > +
> > +	hba = bnx2i_get_hba_from_template(scsit);
> > +	if (bnx2i_adapter_ready(hba))
> > +		return NULL;
> > +
> > +	shost = scsi_host_alloc(hba->iscsi_transport->host_template,
> > +				hostdata_privsize(sizeof(struct bnx2i_sess)));
> > +	if (!shost)
> > +		return NULL;
> > +
> > +	shost->max_id = 1;
> > +	shost->max_channel = 1;
> > +	shost->max_lun = hba->iscsi_transport->max_lun;
> > +	shost->max_cmd_len = hba->iscsi_transport->max_cmd_len;
> > +	if (cmds_max)
> > +		shost->can_queue = cmds_max;
> > +	if (qdepth)
> > +		shost->cmd_per_lun = qdepth;
> > +	shost->transportt = scsit;
> > +	*host_no = shost->host_no;
> > +	sess = iscsi_hostdata(shost->hostdata);
> > +
> > +	if (!sess)
> > +		goto sess_resc_fail;
> > +
> > +	memset(sess, 0, sizeof(struct bnx2i_sess));
> > +	sess->hba = hba;
> > +	sess->host = shost;
> > +
> > +	/*
> > +	 * For Open-iSCSI, only normal sessions go through bnx2i.
> > +	 * Discovery session goes through host stack TCP/IP stack.
> > +	 */
> > +	ret_code = bnx2i_iscsi_sess_new(hba, sess);
> > +	if (ret_code) {
> > +		/*
> > +		 * failed to allocate memory
> > +		 */
> > +		printk(KERN_ALERT "bnx2i_sess_create: unable to alloc sess\n");
> > +		goto sess_resc_fail;
> > +	}
> > +
> > +	/*
> > +	 * Update CmdSN related parameters
> > +	 */
> > +	sess->cmdsn = initial_cmdsn;
> > +	sess->exp_cmdsn = initial_cmdsn + 1;
> > +	sess->max_cmdsn = initial_cmdsn + 1;
> > +
> > +	if (scsi_add_host(shost, NULL))
> > +		goto add_sh_fail;
> > +
> > +	if (!try_module_get(it->owner))
> > +		goto cls_sess_falied;
> > +
> > +	cls_session = iscsi_create_session(shost, it, 0);
> > +	if (!cls_session)
> > +		goto module_put;
> > +	*(unsigned long *)shost->hostdata = (unsigned long)cls_session;
> > +
> > +	return hostdata_session(shost->hostdata);
> > +
> > +module_put:
> > +	module_put(it->owner);
> > +cls_sess_falied:
> > +	scsi_remove_host(shost);
> > +add_sh_fail:
> > +	bnx2i_iscsi_sess_release(hba, sess);
> > +sess_resc_fail:
> > +	scsi_host_put(shost);
> > +	return NULL;
> > +}
> > +
> > +
> > +/*
> > + * Function: bnx2i_session_destroy
> > + * Description: Destroys previously created iSCSI session instance.
> > + */
> > +void bnx2i_session_destroy(struct iscsi_cls_session *cls_session)
> > +{
> > +	struct Scsi_Host *shost = iscsi_session_to_shost(cls_session);
> > +	struct bnx2i_sess *sess = iscsi_hostdata(shost->hostdata);
> > +	struct module *owner = cls_session->transport->owner;
> > +
> > +	if (sess) {
> > +		bnx2i_iscsi_sess_release(sess->hba, sess);
> > +	}
> > +
> > +	if (sess->target_name) {
> > +		kfree(sess->target_name);
> > +		sess->target_name = NULL;
> > +	}
> > +
> > +	scsi_remove_host(shost);
> > +	iscsi_destroy_session(cls_session);
> > +	scsi_host_put(shost);
> > +        module_put(owner);
> > +}
> > +
> > +
> > +/*
> > + * Function: bnx2i_sess_recovery_timeo
> > + * Description: session recovery timeout handling routine
> > + */
> > +void bnx2i_sess_recovery_timeo(struct iscsi_cls_session *cls_session)
> > +{
> > +	struct Scsi_Host *shost = iscsi_session_to_shost(cls_session);
> > +	struct bnx2i_sess *sess = iscsi_hostdata(shost->hostdata);
> > +
> > +	sess->recovery_state |= ISCSI_SESS_RECOVERY_FAILED;
> > +	if (sess->state != BNX2I_SESS_IN_FFP) {
> > +	}
> > +	wake_up(&sess->er_wait);
> > +}
> > +
> > +
> > +/*
> > + * Function: bnx2i_conn_create
> > + * Description: Creates a new iSCSI connection instance for a given session
> > + */
> > +struct iscsi_cls_conn *bnx2i_conn_create(struct iscsi_cls_session *cls_session,
> > +					 uint32_t cid)
> > +{
> > +	struct Scsi_Host *shost = iscsi_session_to_shost(cls_session);
> > +	struct bnx2i_sess *sess = iscsi_hostdata(shost->hostdata);
> > +	struct bnx2i_conn *conn;
> > +	struct iscsi_cls_conn *cls_conn;
> > +
> > +	cls_conn = iscsi_create_conn(cls_session, cid);
> > +	if (!cls_conn)
> > +		return NULL;
> > +
> > +	conn = cls_conn->dd_data;
> > +	memset(conn, 0, sizeof(struct bnx2i_conn));
> > +	conn->cls_conn = cls_conn;
> > +	conn->exp_statsn = STATSN_UPDATE_SIGNATURE;
> > +	conn->iscsi_conn_cid = conn->fw_cid = 0;
> > +	conn->header_digest_en = 0;
> > +	conn->data_digest_en = 0;
> > +	conn->persist_address = NULL;
> > +	conn->state = CONN_STATE_IDLE;
> > +	/*
> > +	 * Initialize the connection structure
> > +	 */
> > +	bnx2i_iscsi_conn_new(sess, conn);
> > +	conn->conn_cid = cid;
> > +	return cls_conn;
> > +}
> > +
> > +
> > +
> > +/*
> > + * Function: bnx2i_conn_bind
> > + * Description: Binds together iSCSI session instance, iSCSI connection
> > + *	instance and the TCP connection. If TCP connection does not belong
> > + *	on the device iSCSI sess/conn is bound, return failure to user.
> > + */
> > +int bnx2i_conn_bind(struct iscsi_cls_session *cls_session,
> > +		    struct iscsi_cls_conn *cls_conn,
> > +		    uint64_t transport_fd, int is_leading)
> > +{
> > +	struct Scsi_Host *shost = iscsi_session_to_shost(cls_session);
> > +	struct bnx2i_sess *sess = iscsi_hostdata(shost->hostdata);
> > +	struct bnx2i_conn *tmp = ERR_PTR(-EEXIST);
> > +	struct bnx2i_conn *conn = cls_conn->dd_data;
> > +	int ret_code = 0;
> > +	struct bnx2i_endpoint *ep;
> > +
> > +	ep = (struct bnx2i_endpoint *) (unsigned long) transport_fd;
> > +
> > +	if (ep->state == EP_STATE_PEER_DISCONN) {
> > +		/* Peer disconnect via' FIN or RST */
> > +		return -EINVAL;
> > +	}
> > +
> > +	if (ep->hba != sess->hba) {
> > +		/* Error - TCP connection does not belong to this device
> > +		 */
> > +		printk(KERN_ALERT "bnx2i: conn bind, ep=0x%p (0x%p) does not",
> > +				  ep, ep->hba);
> > +		printk(KERN_ALERT "belong to hba 0x%p\n", sess->hba);
> > +		return -EEXIST;
> > +	}
> > +	if (!conn->gen_pdu.cmd)
> > +		conn->gen_pdu.cmd = bnx2i_alloc_cmd(sess);
> > +
> > +	/* look-up for existing connection, MC/S is not currently supported */
> > +	spin_lock_bh(&sess->lock);
> > +	tmp = NULL;
> > +	if (!list_empty(&sess->conn_list)) {
> > +		list_for_each_entry(tmp, &sess->conn_list, link) {
> > +			if (tmp == conn) {
> > +				break;
> > +			}
> > +		}
> > +	}
> > +	if ((tmp != conn) && (conn->sess == sess)) {
> > +		/* bind iSCSI connection to this session */
> > +		list_add(&conn->link, &sess->conn_list);
> > +		if (is_leading) {
> > +			sess->lead_conn = conn;
> > +		}
> > +	}
> > +
> > +	conn->ep = (struct bnx2i_endpoint *) (unsigned long) transport_fd;
> > +	conn->ep->conn = conn;
> > +	conn->ep->sess = sess;
> > +	conn->state = CONN_STATE_XPORT_READY;
> > +	conn->iscsi_conn_cid = conn->ep->ep_iscsi_cid;
> > +	conn->fw_cid = conn->ep->ep_cid;
> > +
> > +	bnx2i_bind_conn_to_iscsi_cid(conn, ep->ep_iscsi_cid);
> > +
> > +	spin_unlock_bh(&sess->lock);
> > +	return ret_code;
> > +}
> > +
> > +
> > +/*
> > + * Function: bnx2i_conn_destroy
> > + * Description: Destroys a iSCSI connection instance.
> > + */
> > +void bnx2i_conn_destroy(struct iscsi_cls_conn *cls_conn)
> > +{
> > +	struct bnx2i_conn *conn = cls_conn->dd_data;
> > +
> > +	bnx2i_conn_free_login_resources(conn->sess->hba, conn);
> > +
> > +	if (conn->persist_address) {
> > +		kfree(conn->persist_address);
> > +		conn->persist_address = NULL;
> > +	}
> > +	iscsi_destroy_conn(cls_conn);
> > +}
> > +
> > +
> > +/*
> > + * Function: bnx2i_conn_set_param
> > + * Description: During FFP migration, user daemon will issue this call to
> > + *	update negotiated iSCSI parameters to driver.
> > + */
> > +int bnx2i_conn_set_param(struct iscsi_cls_conn *cls_conn,
> > +			 enum iscsi_param param, char *buf, int buflen)
> > +{
> > +	struct bnx2i_conn *conn = cls_conn->dd_data;
> > +	struct bnx2i_sess *sess = conn->sess;
> > +
> > +	spin_lock_bh(&sess->lock);
> > +	if (conn->state != CONN_STATE_IN_LOGIN) {
> > +		printk(KERN_ERR "bnx2i: can't change param [%d]\n", param);
> > +		spin_unlock_bh(&sess->lock);
> > +		return 0;
> > +	}
> > +	spin_unlock_bh(&sess->lock);
> > +	switch (param) {
> > +	case ISCSI_PARAM_MAX_RECV_DLENGTH:
> > +		sscanf(buf, "%d", &conn->max_data_seg_len_recv);
> > +		break;
> > +	case ISCSI_PARAM_MAX_XMIT_DLENGTH:
> > +		sscanf(buf, "%d", &conn->max_data_seg_len_xmit);
> > +		break;
> > +	case ISCSI_PARAM_HDRDGST_EN:
> > +		sscanf(buf, "%d", &conn->header_digest_en);
> > +		break;
> > +	case ISCSI_PARAM_DATADGST_EN:
> > +		sscanf(buf, "%d", &conn->data_digest_en);
> > +		break;
> > +	case ISCSI_PARAM_INITIAL_R2T_EN:
> > +		if (conn == sess->lead_conn) {
> > +			sscanf(buf, "%d", &sess->initial_r2t);
> > +		}
> > +		break;
> > +	case ISCSI_PARAM_MAX_R2T:
> > +		if (conn == sess->lead_conn) {
> > +			sscanf(buf, "%d", &sess->max_r2t);
> > +		}
> > +		break;
> > +	case ISCSI_PARAM_IMM_DATA_EN:
> > +		if (conn == sess->lead_conn) {
> > +			sscanf(buf, "%d", &sess->imm_data);
> > +		}
> > +		break;
> > +	case ISCSI_PARAM_FIRST_BURST:
> > +		if (conn == sess->lead_conn) {
> > +			sscanf(buf, "%d", &sess->first_burst_len);
> > +		}
> > +		break;
> > +	case ISCSI_PARAM_MAX_BURST:
> > +		if (conn == sess->lead_conn) {
> > +			sscanf(buf, "%d", &sess->max_burst_len);
> > +		}
> > +		break;
> > +	case ISCSI_PARAM_PDU_INORDER_EN:
> > +		if (conn == sess->lead_conn) {
> > +			sscanf(buf, "%d", &sess->pdu_inorder);
> > +		}
> > +		break;
> > +	case ISCSI_PARAM_DATASEQ_INORDER_EN:
> > +		if (conn == sess->lead_conn) {
> > +			sscanf(buf, "%d", &sess->dataseq_inorder);
> > +		}
> > +		break;
> > +	case ISCSI_PARAM_ERL:
> > +		if (conn == sess->lead_conn) {
> > +			sscanf(buf, "%d", &sess->erl);
> > +		}
> > +		break;
> > +	case ISCSI_PARAM_IFMARKER_EN:
> > +		sscanf(buf, "%d", &conn->ifmarker_enable);
> > +		BUG_ON(conn->ifmarker_enable);
> > +		break;
> > +	case ISCSI_PARAM_OFMARKER_EN:
> > +		sscanf(buf, "%d", &conn->ofmarker_enable);
> > +		BUG_ON(conn->ofmarker_enable);
> > +		break;
> > +	case ISCSI_PARAM_EXP_STATSN:
> > +		sscanf(buf, "%u", &conn->exp_statsn);
> > +		break;
> > +	case ISCSI_PARAM_TARGET_NAME:
> > +		if (sess->target_name)
> > +			break;
> > +		sess->target_name = kstrdup(buf, GFP_KERNEL);
> > +		if (!sess->target_name)
> > +			return -ENOMEM;
> > +		break;
> > +	case ISCSI_PARAM_TPGT:
> > +		sscanf(buf, "%d", &sess->tgt_prtl_grp);
> > +		break;
> > +	case ISCSI_PARAM_PERSISTENT_PORT:
> > +		{
> > +		sscanf(buf, "%d", &conn->persist_port);
> > +		}
> > +		break;
> > +	case ISCSI_PARAM_PERSISTENT_ADDRESS:
> > +		if (conn->persist_address)
> > +			break;
> > +		conn->persist_address = kstrdup(buf, GFP_KERNEL);
> > +		if (!conn->persist_address)
> > +			return -ENOMEM;
> > +		break;
> > +	default:
> > +		printk(KERN_ALERT "PARAM_UNKNOWN: 0x%x\n", param);
> > +		break;
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +
> > +/*
> > + * Function: bnx2i_conn_get_param
> > + * Description: Call to retrieve iSCSI connection parameters
> > + */
> > +int bnx2i_conn_get_param(struct iscsi_cls_conn *cls_conn,
> > +			 enum iscsi_param param, char *buf)
> > +{
> > +	struct bnx2i_conn *conn;
> > +	int len = 0;
> > +
> > +	if (!cls_conn)
> > +		return -EINVAL;
> > +	conn = (struct bnx2i_conn *)cls_conn->dd_data;
> > +	if (!conn || !conn->ep ||
> > +	    (conn->ep->state != EP_STATE_ULP_UPDATE_COMPL))
> > +		return -EINVAL;
> > +
> > +	switch (param) {
> > +	case ISCSI_PARAM_MAX_RECV_DLENGTH:
> > +		len = sprintf(buf, "%u\n", conn->max_data_seg_len_recv);
> > +		break;
> > +	case ISCSI_PARAM_MAX_XMIT_DLENGTH:
> > +		len = sprintf(buf, "%u\n", conn->max_data_seg_len_xmit);
> > +		break;
> > +	case ISCSI_PARAM_HDRDGST_EN:
> > +		len = sprintf(buf, "%d\n", conn->header_digest_en);
> > +		break;
> > +	case ISCSI_PARAM_DATADGST_EN:
> > +		len = sprintf(buf, "%d\n", conn->data_digest_en);
> > +		break;
> > +	case ISCSI_PARAM_IFMARKER_EN:
> > +		len = sprintf(buf, "%u\n", conn->ifmarker_enable);
> > +		break;
> > +	case ISCSI_PARAM_OFMARKER_EN:
> > +		len = sprintf(buf, "%u\n", conn->ofmarker_enable);
> > +		break;
> > +	case ISCSI_PARAM_EXP_STATSN:
> > +		len = sprintf(buf, "%u\n", conn->exp_statsn);
> > +		break;
> > +	case ISCSI_PARAM_PERSISTENT_PORT:
> > +		len = sprintf(buf, "%d\n", conn->persist_port);
> > +		break;
> > +	case ISCSI_PARAM_PERSISTENT_ADDRESS:
> > +		if (conn->persist_address) {
> > +			len = sprintf(buf, "%s\n", conn->persist_address);
> > +		}
> > +		break;
> > +	case ISCSI_PARAM_CONN_PORT:
> > +		len = sprintf(buf, "%hu\n", conn->ep->cm_sk->dst_port);
> > +		break;
> > +	case ISCSI_PARAM_CONN_ADDRESS:
> > +		len = sprintf(buf, NIPQUAD_FMT "\n",
> > +			      NIPQUAD(conn->ep->cm_sk->dst_ip));
> > +		break;
> > +	default:
> > +		printk(KERN_ALERT "get_param: conn 0x%p param %d not found\n",
> > +				  conn, (u32)param);
> > +		return -ENOSYS;
> > +	}
> > +
> > +	return len;
> > +}
> > +
> > +
> > +/*
> > + * Function: bnx2i_session_get_param
> > + * Description: Call to obtain iSCSI session parameters
> > + */
> > +int bnx2i_session_get_param(struct iscsi_cls_session *cls_session,
> > +			    enum iscsi_param param, char *buf)
> > +{
> > +	struct Scsi_Host *shost = NULL;
> > +	struct bnx2i_sess *sess = NULL;
> > +	int len = 0;
> > +
> > +	if (!cls_session)
> > +		return -EINVAL;
> > +
> > +	shost = iscsi_session_to_shost(cls_session);
> > +	sess = iscsi_hostdata(shost->hostdata);
> > +	if (!sess || !sess->lead_conn)
> > +		return -EINVAL;
> > +
> > +	switch (param) {
> > +	case ISCSI_PARAM_INITIAL_R2T_EN:
> > +		len = sprintf(buf, "%d\n", sess->initial_r2t);
> > +		break;
> > +	case ISCSI_PARAM_MAX_R2T:
> > +		len = sprintf(buf, "%hu\n", sess->max_r2t);
> > +		break;
> > +	case ISCSI_PARAM_IMM_DATA_EN:
> > +		len = sprintf(buf, "%d\n", sess->imm_data);
> > +		break;
> > +	case ISCSI_PARAM_FIRST_BURST:
> > +		len = sprintf(buf, "%u\n", sess->first_burst_len);
> > +		break;
> > +	case ISCSI_PARAM_MAX_BURST:
> > +		len = sprintf(buf, "%u\n", sess->max_burst_len);
> > +		break;
> > +	case ISCSI_PARAM_PDU_INORDER_EN:
> > +		len = sprintf(buf, "%d\n", sess->pdu_inorder);
> > +		break;
> > +	case ISCSI_PARAM_DATASEQ_INORDER_EN:
> > +		len = sprintf(buf, "%d\n", sess->dataseq_inorder);
> > +		break;
> > +	case ISCSI_PARAM_ERL:
> > +		len = sprintf(buf, "%d\n", sess->erl);
> > +		break;
> > +	case ISCSI_PARAM_TARGET_NAME:
> > +		if (sess->target_name) {
> > +			len = sprintf(buf, "%s\n", sess->target_name);
> > +		}
> > +		break;
> > +	case ISCSI_PARAM_TPGT:
> > +		len = sprintf(buf, "%d\n", sess->tgt_prtl_grp);
> > +		break;
> > +	default:
> > +		printk(KERN_ALERT "sess_get_param: sess 0x%p", sess);
> > +		printk(KERN_ALERT  "param (0x%x) not found\n", (u32) param);
> > +		return -ENOSYS;
> > +	}
> > +
> > +	return len;
> > +}
> > +
> > +
> > +/*
> > + * Function: bnx2i_conn_start
> > + * Description: last call in FFP migration to handover iscsi conn to the driver
> > + */
> > +int bnx2i_conn_start(struct iscsi_cls_conn *cls_conn)
> > +{
> > +	struct bnx2i_conn *conn = (struct bnx2i_conn *) cls_conn->dd_data;
> > +	struct bnx2i_sess *sess = conn->sess;
> > +
> > +	if (conn->state != CONN_STATE_IN_LOGIN) {
> > +		printk(KERN_ALERT "conn_start: conn 0x%p state 0x%x err!!\n",
> > +				  conn, conn->state);
> > +		return -EINVAL;
> > +	}
> > +
> > +	if (!sess->initial_r2t) {
> > +		if (sess->first_burst_len > sess->max_burst_len)
> > +			return -EINVAL;
> > +	} else if (conn->max_data_seg_len_xmit > sess->max_burst_len) {
> > +		if (sess->first_burst_len > sess->max_burst_len)
> > +			return -EINVAL;
> > +		/* don't bother if only immediate data is supported and
> > +		 * FBL & MBL are greater than MRDSL. In that case initiator
> > +		 * will always send MRDSL worth of immediate data
> > +		 */
> > +	}
> > +
> > +	conn->state = CONN_STATE_FFP_STATE;
> > +	if (conn->sess->lead_conn == conn) {
> > +		conn->sess->state = BNX2I_SESS_IN_FFP;
> > +	}
> > +
> > +	conn->ep->state = EP_STATE_ULP_UPDATE_START;
> > +	bnx2i_update_iscsi_conn(conn);
> > +
> > +	conn->ep->ofld_timer.expires = 10*HZ + jiffies;
> > +	conn->ep->ofld_timer.function = bnx2i_ep_ofld_timer;
> > +	conn->ep->ofld_timer.data = (unsigned long)conn->ep;
> > +	add_timer(&conn->ep->ofld_timer);
> > +	/* update iSCSI context for this conn, wait for CNIC to complete */
> > +	wait_event_interruptible(conn->ep->ofld_wait,
> > +				 conn->ep->state != EP_STATE_ULP_UPDATE_START);
> > +
> > +	if (signal_pending(current))
> > +		flush_signals(current);
> > +	del_timer_sync(&conn->ep->ofld_timer);
> > +	if (conn->ep->state != EP_STATE_ULP_UPDATE_COMPL) {
> > +		/* should never happen */
> > +	}
> > +	/* Free login ITT, not required anymore */
> > +	if (conn->gen_pdu.cmd) {
> > +		bnx2i_free_cmd(conn->sess, conn->gen_pdu.cmd);
> > +		conn->gen_pdu.cmd = NULL;
> > +	}
> > +
> > +	switch (conn->stop_state) {
> > +	case STOP_CONN_RECOVER:
> > +		sess->recovery_state = ISCSI_SESS_RECOVERY_COMPLETE;
> > +		conn->sess->state = BNX2I_SESS_IN_FFP;
> > +		iscsi_unblock_session(session_to_cls(sess));
> > +		wake_up(&sess->er_wait);
> > +		break;
> > +	case STOP_CONN_TERM:
> > +		break;
> > +	default:
> > +		;
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +
> > +/*
> > + * Function: bnx2i_conn_stop
> > + * Description: call to take control of iscsi conn from the driver.
> > + *	Could be called when login failed, when recovery is to be
> > + *	attempted or during connection teardown
> > + */
> > +void bnx2i_conn_stop(struct iscsi_cls_conn *cls_conn, int flag)
> > +{
> > +	struct bnx2i_conn *conn = (struct bnx2i_conn *)cls_conn->dd_data;
> > +
> > +	conn->stop_state = flag;
> > +	iscsi_block_session(session_to_cls(conn->sess));
> > +
> > +	switch (flag) {
> > +	case STOP_CONN_RECOVER:
> > +		conn->sess->state = BNX2I_SESS_IN_RECOVERY;
> > +		break;
> > +	case STOP_CONN_TERM:
> > +		if (conn->sess && (conn->sess->state & BNX2I_SESS_IN_FFP)) {
> > +			conn->sess->state = BNX2I_SESS_IN_SHUTDOWN;
> > +		}
> > +		break;
> > +	default:
> > +		printk(KERN_ERR "bnx2i: invalid conn stop req %d\n", flag);
> > +	}
> > +
> > +	return;
> > +}
> > +
> > +
> > +/*
> > + * Function: bnx2i_conn_send_pdu
> > + * Description: To send iSCSI PDUs prepared by user daemon, only login, logout,
> > + *	nop-out pdu's should flow this path.
> > + */
> > +int bnx2i_conn_send_pdu(struct iscsi_cls_conn *cls_conn,
> > +			struct iscsi_hdr *hdr, char *data,
> > +			uint32_t data_size)
> > +{
> > +	struct bnx2i_conn *conn = NULL;
> > +	struct iscsi_hdr *iscsi_hdr = (struct iscsi_hdr *) hdr;
> > +	struct bnx2i_cmd *cmnd = NULL;
> > +	uint32_t payload_size = 0;
> > +	int rc;
> > +	unsigned long flags;
> > +
> > +	if (!cls_conn) {
> > +		printk(KERN_ALERT "bnx2i_conn_send_pdu: NULL conn ptr. \n");
> > +		return -EIO;
> > +	}
> > +	conn = (struct bnx2i_conn *)cls_conn->dd_data;
> > +	if (!conn->gen_pdu.req_buf) {
> > +		printk(KERN_ALERT "send_pdu: login buf not allocated\n");
> > +		/* ERR - buffer not allocated, should not happen */
> > +		return -EIO;
> > +	}
> > +
> > +	if (conn->gen_pdu.cmd) {
> > +		if ((conn->state != CONN_STATE_XPORT_READY) &&
> > +		    (conn->state != CONN_STATE_IN_LOGIN)) {
> > +			printk(KERN_ALERT "send_pdu: %d != XPORT_READY\n",
> > +					  conn->state);
> > +			return -EPERM;
> > +		}
> > +		cmnd = conn->gen_pdu.cmd;
> > +	} else {	/* could be NOPOUT or the LOGOUT request */
> > +		spin_lock_irqsave(conn->sess->host->host_lock, flags);
> > +		cmnd = bnx2i_alloc_cmd(conn->sess);
> > +		spin_unlock_irqrestore(conn->sess->host->host_lock, flags);
> > +
> > +		if (!cmnd) {
> > +			printk(KERN_ALERT "bnx2i: Error - cmd not allocated\n");
> > +			return -EIO;
> > +		}
> > +	}
> > +	memset(conn->gen_pdu.req_buf, 0, ISCSI_CONN_LOGIN_BUF_SIZE);
> > +	/* Login request, copy hdr & data to buffer in conn struct */
> > +	memcpy((void *) &conn->gen_pdu.pdu_hdr, (const void *) hdr,
> > +	       sizeof(struct iscsi_hdr));
> > +
> > +	cmnd->iscsi_opcode = iscsi_hdr->opcode;
> > +	switch (iscsi_hdr->opcode & ISCSI_OPCODE_MASK) {
> > +	case ISCSI_OP_LOGIN:
> > +		if (conn->state == CONN_STATE_XPORT_READY)
> > +			conn->state = CONN_STATE_IN_LOGIN;
> > +		break;
> > +	case ISCSI_OP_LOGOUT:
> > +		conn->state = CONN_STATE_IN_LOGOUT;
> > +		conn->sess->state = BNX2I_SESS_IN_LOGOUT;
> > +		break;
> > +	case ISCSI_OP_NOOP_OUT:
> > +		break;
> > +	default:
> > +		;
> > +	}
> > +
> > +	conn->gen_pdu.req_buf_size = data_size;
> > +	payload_size = (hdr->dlength[0] << 16) | (hdr->dlength[1] << 8) |
> > +		       hdr->dlength[2];
> > +
> > +	if (data_size) {
> > +		memcpy((void *)conn->gen_pdu.req_buf, (const void *)data,
> > +		       data_size);
> > +		conn->gen_pdu.req_wr_ptr =
> > +			conn->gen_pdu.req_buf + payload_size;
> > +	}
> > +	cmnd->conn = conn;
> > +	cmnd->scsi_cmd = NULL;
> > +	rc = bnx2i_iscsi_send_generic_request(cmnd);
> > +	return rc;
> > +}
> > +
> > +
> > +/*
> > + * Function : bnx2i_conn_get_stats
> > + * Description: Returns iSCSI stats
> > + */
> > +void bnx2i_conn_get_stats(struct iscsi_cls_conn *cls_conn,
> > +			  struct iscsi_stats *stats)
> > +{
> > +	struct bnx2i_conn *conn = (struct bnx2i_conn *) cls_conn->dd_data;
> > +
> > +	stats->txdata_octets = conn->total_data_octets_sent;
> > +	stats->rxdata_octets = conn->total_data_octets_rcvd;
> > +
> > +	stats->noptx_pdus = conn->num_nopin_pdus;
> > +	stats->scsicmd_pdus = conn->num_scsi_cmd_pdus;
> > +	stats->tmfcmd_pdus = conn->num_tmf_req_pdus;
> > +	stats->login_pdus = conn->num_login_req_pdus;
> > +	stats->text_pdus = 0;
> > +	stats->dataout_pdus = conn->num_dataout_pdus;
> > +	stats->logout_pdus = conn->num_logout_req_pdus;
> > +	stats->snack_pdus = 0;
> > +
> > +	stats->noprx_pdus = conn->num_nopout_pdus;
> > +	stats->scsirsp_pdus = conn->num_scsi_resp_pdus;
> > +	stats->tmfrsp_pdus = conn->num_tmf_resp_pdus;
> > +	stats->textrsp_pdus = 0;
> > +	stats->datain_pdus = conn->num_datain_pdus;
> > +	stats->logoutrsp_pdus = conn->num_logout_resp_pdus;
> > +	stats->r2t_pdus = conn->num_r2t_pdus;
> > +	stats->async_pdus = conn->num_async_pdus;
> > +	stats->rjt_pdus = conn->num_reject_pdus;
> > +
> > +	stats->digest_err = 0;
> > +	stats->timeout_err = 0;
> > +	stats->custom_length = 0;
> > +}
> > +
> > +
> > +
> > +/*
> > + * Function : bnx2i_check_nx2_dev_busy
> > + * Description: this routine unregister devices if there are no active conns
> > + */
> > +static void bnx2i_check_nx2_dev_busy(void)
> > +{
> > +	if (bnx2i_num_free_ep == bnx2i_max_free_ep) {
> > +		bnx2i_unreg_dev_all();
> > +		msleep(2);
> > +	}
> > +}
> > +
> > +
> > +/*
> > + * Function : bnx2i_ep_connect
> > + * Description: this routine initiates the TCP/IP connection by invoking
> > + *	Option-2 interface with l5_core and the CNIC
> > + */
> > +int bnx2i_ep_connect(struct sockaddr *dst_addr, int non_blocking,
> > +		     uint64_t *ep_handle)
> > +{
> > +	u32 iscsi_cid = BNX2I_CID_RESERVED;
> > +	struct sockaddr_in *desti = (struct sockaddr_in *) dst_addr;
> > +	struct bnx2i_endpoint *endpoint;
> > +	struct bnx2i_hba *hba = NULL;
> > +	struct cnic_dev *cnic = NULL;
> > +	struct cnic_dev *tmp_cnic = NULL;
> > +	struct bnx2i_hba *tmp_hba = NULL;
> > +	struct cnic_sockaddr saddr;
> > +	int rc = 0;
> > +	extern int bnx2i_reg_device;
> > +	extern struct bnx2i_hba *get_adapter_list_head(void);
> > +
> > +	/*
> > +	 * check if the given destination can be reached through NX2 device
> > +	 */
> > +
> > +	if ((!bnx2i_reg_device) &&
> > +	    (bnx2i_num_free_ep == bnx2i_max_free_ep)) {
> > +		bnx2i_reg_dev_all();
> > +	}
> > +	tmp_hba = get_adapter_list_head();
> > +	if (tmp_hba && tmp_hba->cnic) {
> > +		tmp_cnic = tmp_hba->cnic;
> > +		cnic = tmp_cnic->cm_select_dev(desti, CNIC_ULP_ISCSI);
> > +	}
> > +	if (!cnic) {
> > +		printk(KERN_ALERT "bnx2i: ep_conn, can't connect using cnic\n");
> > +		rc = 0;
> > +		goto check_busy;
> > +	}
> > +	hba = bnx2i_find_hba_for_cnic(cnic);
> > +
> > +	if (bnx2i_adapter_ready(hba)) {
> > +		printk(KERN_ALERT "bnx2i: ep_conn, adapter not found\n");
> > +		rc = 0;
> > +		goto check_busy;
> > +	}
> > +	if (hba->netdev->mtu > hba->mtu_supported) {
> > +		printk(KERN_ALERT "bnx2i: %s network i/f mtu is set to %d\n",
> > +				  hba->netdev->name, hba->netdev->mtu);
> > +		printk(KERN_ALERT "bnx2i: iSCSI HBA can support mtu of %d\n",
> > +				  hba->mtu_supported);
> > +		rc = 0;
> > +		goto check_busy;
> > +	}
> > +	endpoint = bnx2i_alloc_ep();
> > +	if (!endpoint) {
> > +		printk(KERN_ALERT "bnx2i: ep_conn, unable to alloc ep\n");
> > +		*ep_handle = (uint64_t) 0;
> > +		rc = -ENOMEM;
> > +		goto check_busy;
> > +	}
> > +
> > +	endpoint->ep_iscsi_cid = (u16)ISCSI_RESERVED_TAG;
> > +	iscsi_cid = bnx2i_alloc_iscsi_cid(hba);
> > +	if (iscsi_cid == (u16) ISCSI_RESERVED_TAG) {
> > +		printk(KERN_ALERT "alloc_ep: unable to allocate iscsi cid\n");
> > +		rc = -ENOMEM;
> > +		goto iscsi_cid_err;
> > +	}
> > +	endpoint->hba = hba;
> > +	endpoint->hba_age = hba->age;
> > +
> > +	rc = bnx2i_alloc_qp_resc(hba, endpoint);
> > +	if (rc != 0) {
> > +		printk(KERN_ALERT "bnx2i: ep_conn, alloc QP resc error\n");
> > +		rc = -ENOMEM;
> > +		goto qp_resc_err;
> > +	}
> > +
> > +	endpoint->ep_iscsi_cid = iscsi_cid;
> > +	endpoint->state = EP_STATE_OFLD_START;
> > +	bnx2i_ep_ofld_list_add(hba, endpoint);
> > +
> > +	bnx2i_send_conn_ofld_req(hba, endpoint);
> > +
> > +	init_timer(&endpoint->ofld_timer);
> > +	endpoint->ofld_timer.expires = 2 * HZ + jiffies;
> > +	endpoint->ofld_timer.function = bnx2i_ep_ofld_timer;
> > +	endpoint->ofld_timer.data = (unsigned long) endpoint;
> > +	add_timer(&endpoint->ofld_timer);
> > +	/* Wait for CNIC hardware to setup conn context and return 'cid' */
> > +	wait_event_interruptible(endpoint->ofld_wait,
> > +				 endpoint->state != EP_STATE_OFLD_START);
> > +
> > +	if (signal_pending(current))
> > +		flush_signals(current);
> > +	del_timer_sync(&endpoint->ofld_timer);
> > +	list_del_init(&endpoint->link);
> > +	
> > +	if (endpoint->state != EP_STATE_OFLD_COMPL) {
> > +		rc = -ENOSPC;
> > +		goto conn_failed;
> > +	}
> > +
> > +	rc = -EINVAL;
> > +	if (hba->reg_with_cnic)
> > +		rc = cnic->cm_create(cnic, CNIC_ULP_ISCSI, endpoint->ep_cid,
> > +				     iscsi_cid, &endpoint->cm_sk, endpoint);
> > +	if (rc)
> > +		goto conn_failed;
> > +
> > +	memset(&saddr, 0, sizeof(saddr));
> > +	saddr.remote_addr.sin_addr.s_addr = desti->sin_addr.s_addr;
> > +	saddr.remote_addr.sin_port = desti->sin_port;
> > +	saddr.local_addr.sin_port = htons(endpoint->tcp_port);
> > +	endpoint->state = EP_STATE_CONNECT_START;
> > +	rc = -EINVAL;
> > +	if (hba->reg_with_cnic)
> > +		rc = cnic->cm_connect(endpoint->cm_sk, &saddr);
> > +	else
> > +		goto conn_failed;
> > +
> > +	if (rc)
> > +		goto release_ep;
> > +
> > +	bnx2i_map_ep_dbell_regs(endpoint);
> > +
> > +	*ep_handle = (uint64_t) (unsigned long) endpoint;
> > +	return 0;
> > +
> > +release_ep:
> > +	cnic->cm_destroy(endpoint->cm_sk);
> > +conn_failed:
> > +iscsi_cid_err:
> > +	bnx2i_free_qp_resc(hba, endpoint);
> > +qp_resc_err:
> > +	bnx2i_free_ep(endpoint);
> > +check_busy:
> > +	*ep_handle = (uint64_t) 0;
> > +	bnx2i_check_nx2_dev_busy();
> > +	return rc;
> > +}
> > +
> > +
> > +
> > +/*
> > + * Function : bnx2i_ep_poll
> > + * Description: polls for TCP connect request to complete
> > + */
> > +int bnx2i_ep_poll(uint64_t ep_handle, int timeout_ms)
> > +{
> > +	struct bnx2i_endpoint *ep;
> > +	int rc = 0;
> > +	ep = (struct bnx2i_endpoint *) (unsigned long) ep_handle;
> > +
> > +	if (!ep) {
> > +		return -EINVAL;
> > +	}
> > +	if (ep->state == EP_STATE_IDLE) {
> > +		return -1;
> > +	}
> > +	if (ep->state == EP_STATE_CONNECT_COMPL) {
> > +		return 1;
> > +	}
> > +
> > +	rc = wait_event_interruptible_timeout(ep->ofld_wait,
> > +					      (ep->state ==
> > +					       EP_STATE_CONNECT_COMPL),
> > +					      msecs_to_jiffies(timeout_ms));
> > +	if (!rc || (ep->state == EP_STATE_OFLD_FAILED)) {
> > +		rc = -1;
> > +	}
> > +
> > +	if (rc > 0) {
> > +		return 1;
> > +	} else if (!rc) {
> > +		return 0;	/* timeout */
> > +	} else {
> > +		return rc;
> > +	}
> > +}
> > +
> > +
> > +/*
> > + * Function : bnx2i_ep_disconnect
> > + * Description: initiates TCP/IP connection teardown process
> > + */
> > +void bnx2i_ep_disconnect(uint64_t ep_handle)
> > +{
> > +	struct bnx2i_endpoint *ep;
> > +	struct cnic_dev *cnic = NULL;
> > +	struct bnx2i_sess *sess = NULL;
> > +	int rc = 0;
> > +
> > +	ep = (struct bnx2i_endpoint *) (unsigned long) ep_handle;
> > +	if (!ep || (ep_handle == -1)) {
> > +		return;
> > +	}
> > +	if (ep->state == EP_STATE_IDLE) {
> > +		goto return_ep;
> > +	}
> > +	cnic = ep->hba->cnic;
> > +
> > +	if (ep->state == EP_STATE_PEER_DISCONN) {
> > +		ep->state = EP_STATE_DISCONN_COMPL;
> > +		goto peer_discon;
> > +	}
> > +
> > +	if (test_bit(ADAPTER_STATE_DOWN, &ep->hba->adapter_state)) {
> > +		goto free_resc;
> > +	}
> > +	if (ep->hba_age != ep->hba->age) {
> > +		goto dev_reset;
> > +	}
> > +
> > +	ep->state = EP_STATE_DISCONN_START;
> > +
> > +	init_timer(&ep->ofld_timer);
> > +	ep->ofld_timer.expires = 10*HZ + jiffies;
> > +	ep->ofld_timer.function = bnx2i_ep_ofld_timer;
> > +	ep->ofld_timer.data = (unsigned long) ep;
> > +	add_timer(&ep->ofld_timer);
> > +
> > +	if (ep->hba->reg_with_cnic)
> > +		cnic->cm_close(ep->cm_sk);
> > +	else
> > +		goto free_resc;
> > +
> > +	/* wait for option-2 conn teardown */
> > +	wait_event_interruptible(ep->ofld_wait,
> > +				 ep->state != EP_STATE_DISCONN_START);
> > +
> > +	if (signal_pending(current))
> > +		flush_signals(current);
> > +	del_timer_sync(&ep->ofld_timer);
> > +
> > +peer_discon:
> > +	if (!ep->hba->reg_with_cnic)
> > +		goto free_resc;
> > +
> > +	rc = cnic->cm_destroy(ep->cm_sk);
> > +	ep->state = EP_STATE_CLEANUP_START;
> > +	init_timer(&ep->ofld_timer);
> > +	ep->ofld_timer.expires = 10*HZ + jiffies;
> > +	ep->ofld_timer.function = bnx2i_ep_ofld_timer;
> > +	ep->ofld_timer.data = (unsigned long) ep;
> > +	add_timer(&ep->ofld_timer);
> > +
> > +	bnx2i_ep_destroy_list_add(ep->hba, ep);
> > +
> > +	/* destroy iSCSI context, wait for it to complete */
> > +	bnx2i_send_conn_destroy(ep->hba, ep);
> > +	wait_event_interruptible(ep->ofld_wait,
> > +				 (ep->state != EP_STATE_CLEANUP_START));
> > +
> > +	if (signal_pending(current))
> > +		flush_signals(current);
> > +	del_timer_sync(&ep->ofld_timer);
> > +	if (ep->state != EP_STATE_CLEANUP_CMPL) {
> > +		/* should never happen */
> > +		printk(KERN_ALERT "bnx2i - conn destroy failed\n");
> > +	}
> > +
> > +dev_reset:
> > +	bnx2i_flush_active_cmd_queue(ep->sess, DID_NO_CONNECT);
> > +
> > +free_resc:
> > +	bnx2i_free_qp_resc(ep->hba, ep);
> > +return_ep:
> > +	if (ep->conn && ep->conn->sess)
> > +		/* session recovery in progress */
> > +		sess = ep->conn->sess;
> > +	if (sess && (sess->state != BNX2I_SESS_IN_RECOVERY))
> > +		/* session logged out */
> > +		sess = NULL;
> > +
> > +	bnx2i_free_ep(ep);
> > +	if (sess) {
> > +		wake_up(&sess->er_wait);
> > +	}
> > +
> > +	bnx2i_check_nx2_dev_busy();
> > +	return;
> > +}
> > +
> > +
> > +
> > +
> > +/*
> > + * 'Scsi_Host_Template' structure and 'iscsi_tranport' structure template
> > + * used while registering with the iSCSI trnaport module.
> > + */
> > +struct scsi_host_template bnx2i_host_template = {
> > +	.module				= THIS_MODULE,
> > +	.name				= "Broadcom Offload iSCSI Initiator",
> > +	.queuecommand			= bnx2i_queuecommand,
> > +	.eh_abort_handler		= bnx2i_abort,
> > +	.eh_host_reset_handler		= bnx2i_host_reset,
> > +	.bios_param			= NULL,
> > +	.can_queue			= 128,
> > +	.max_sectors			= 256,
> > +	.this_id			= -1,
> > +	.cmd_per_lun			= 64,
> > +	.use_clustering			= ENABLE_CLUSTERING,
> > +	.sg_tablesize			= ISCSI_MAX_BDS_PER_CMD,
> > +	.proc_name			= NULL
> > +	};
> > +
> > +
> > +
> > +struct iscsi_transport bnx2i_iscsi_transport = {
> > +	.owner			= THIS_MODULE,
> > +	.name			= "bnx2i",
> > +	.caps			= CAP_RECOVERY_L0 | CAP_HDRDGST | CAP_MULTI_R2T
> > +				  | CAP_DATADGST,
> > +	.param_mask		= ISCSI_MAX_RECV_DLENGTH |
> > +				  ISCSI_MAX_XMIT_DLENGTH |
> > +				  ISCSI_HDRDGST_EN |
> > +				  ISCSI_DATADGST_EN |
> > +				  ISCSI_INITIAL_R2T_EN |
> > +				  ISCSI_MAX_R2T |
> > +				  ISCSI_IMM_DATA_EN |
> > +				  ISCSI_FIRST_BURST |
> > +				  ISCSI_MAX_BURST |
> > +				  ISCSI_PDU_INORDER_EN |
> > +				  ISCSI_DATASEQ_INORDER_EN |
> > +				  ISCSI_ERL |
> > +				  ISCSI_CONN_PORT |
> > +				  ISCSI_CONN_ADDRESS |
> > +				  ISCSI_EXP_STATSN |
> > +				  ISCSI_PERSISTENT_PORT |
> > +				  ISCSI_PERSISTENT_ADDRESS |
> > +				  ISCSI_TARGET_NAME |
> > +				  ISCSI_TPGT,
> > +	.host_param_mask	= 0,
> > +	.host_template		= &bnx2i_host_template,
> > +	.sessiondata_size	= sizeof(struct bnx2i_sess),
> > +	.conndata_size		= sizeof(struct bnx2i_conn),
> > +	.max_conn		= 1,
> > +	.max_cmd_len		= 16,
> > +	.max_lun		= 512,
> > +	.create_session		= bnx2i_session_create,
> > +	.destroy_session	= bnx2i_session_destroy,
> > +	.create_conn		= bnx2i_conn_create,
> > +	.bind_conn		= bnx2i_conn_bind,
> > +	.destroy_conn		= bnx2i_conn_destroy,
> > +	.set_param		= bnx2i_conn_set_param,
> > +	.get_conn_param		= bnx2i_conn_get_param,
> > +	.get_session_param	= bnx2i_session_get_param,
> > +	.start_conn		= bnx2i_conn_start,
> > +	.stop_conn		= bnx2i_conn_stop,
> > +	.send_pdu		= bnx2i_conn_send_pdu,
> > +	.get_stats		= bnx2i_conn_get_stats,
> > +	/* iscsi host params */
> > +	.get_host_param		= NULL,
> > +	.set_host_param		= NULL,
> > +	/* TCP connect - disconnect - option-2 interface calls */
> > +	.ep_connect		= bnx2i_ep_connect,
> > +	.ep_poll		= bnx2i_ep_poll,
> > +	.ep_disconnect		= bnx2i_ep_disconnect,
> > +	/* Error recovery timeout call */
> > +	.session_recovery_timedout = bnx2i_sess_recovery_timeo
> > +};
> > diff --git a/drivers/scsi/bnx2i/bnx2i_sysfs.c b/drivers/scsi/bnx2i/bnx2i_sysfs.c
> > new file mode 100644
> > index 0000000..6bd6eba
> > --- /dev/null
> > +++ b/drivers/scsi/bnx2i/bnx2i_sysfs.c
> > @@ -0,0 +1,616 @@
> > +/* bnx2i_sysfs.c: Broadcom NetXtreme II iSCSI driver.
> > + *
> > + * Copyright (c) 2004, 2005, 2006 Broadcom Corporation
> > + *
> > + * This program is free software; you can redistribute it and/or modify
> > + * it under the terms of the GNU General Public License as published by
> > + * the Free Software Foundation.
> > + *
> > + * Written by: Anil Veerabhadrappa (anilgv@broadcom.com)
> > + */
> > +
> > +#include "bnx2i.h"
> > +
> > +#define BNX2I_SYSFS_VERSION	0x2
> > +
> > +static ssize_t bnx2i_show_mips_status(struct class_device *cdev, char *buf)
> > +{
> > +	struct bnx2i_hba *hba =
> > +		container_of(cdev, struct bnx2i_hba, class_dev);
> > +	ssize_t len = 0;
> > +
> > +	bnx2i_read_mips_idle_counters(hba);
> > +
> > +	len = sprintf(buf, "%d\n%lu\n%d\n%llu\n%llu\n"
> > +			   "%llu\n%llu\n%llu\n%llu\n%llu\n%llu\n",
> > +			   BNX2I_SYSFS_VERSION, jiffies, HZ,
> > +			   hba->mips_idle.cp_idle_count,
> > +			   hba->mips_idle.txp_idle_count,
> > +			   hba->mips_idle.txp_tdma_count,
> > +			   hba->mips_idle.txp_ctx_count,
> > +			   hba->mips_idle.txp_hdrq_count,
> > +			   hba->mips_idle.tpat_idle_count,
> > +			   hba->mips_idle.rxp_idle_count,
> > +			   hba->mips_idle.com_idle_count);
> > +	return (len);
> > +}
> > +
> > +static ssize_t bnx2i_show_net_if_name(struct class_device *cdev, char *buf)
> > +{
> > +	struct bnx2i_hba *hba =
> > +		container_of(cdev, struct bnx2i_hba, class_dev);
> > +
> > +	return sprintf(buf, "%s\n", hba->netdev->name);
> > +}
> > +
> > +static ssize_t bnx2i_show_pci_bar(struct class_device *cdev, char *buf)
> > +{
> > +	struct bnx2i_hba *hba =
> > +		container_of(cdev, struct bnx2i_hba, class_dev);
> > +
> > +	return sprintf(buf, "0x%.8x\n",
> > +		       (u32) pci_resource_start(hba->pci_dev, 0));
> > +}
> > +
> > +static ssize_t bnx2i_show_sq_info(struct class_device *cdev, char *buf)
> > +{
> > +	struct bnx2i_hba *hba =
> > +		container_of(cdev, struct bnx2i_hba, class_dev);
> > +
> > +	return sprintf(buf, "0x%x\n", hba->max_sqes);
> > +}
> > +
> > +static ssize_t bnx2i_set_sq_info(struct class_device *cdev,
> > +				 const char *buf, size_t count)
> > +{
> > +	struct bnx2i_hba *hba =
> > +		container_of(cdev, struct bnx2i_hba, class_dev);
> > +	u32 val;
> > +
> > +	if (sscanf(buf, " 0x%x ", &val) > 0) {
> > +		if ((val >= BNX2I_SQ_WQES_MIN) &&
> > +		    (val <= BNX2I_SQ_WQES_MAX)) {
> > +			hba->max_sqes = val;
> > +		}
> > +	}
> > +	return count;
> > +}
> > +
> > +static ssize_t bnx2i_show_cq_info(struct class_device *cdev, char *buf)
> > +{
> > +	struct bnx2i_hba *hba =
> > +		container_of(cdev, struct bnx2i_hba, class_dev);
> > +
> > +	return sprintf(buf, "0x%x\n", hba->max_cqes);
> > +}
> > +
> > +static ssize_t bnx2i_set_cq_info(struct class_device *cdev,
> > +				 const char *buf, size_t count)
> > +{
> > +	u32 val;
> > +	struct bnx2i_hba *hba =
> > +		container_of(cdev, struct bnx2i_hba, class_dev);
> > +
> > +	if (sscanf(buf, " 0x%x ", &val) > 0) {
> > +		if ((val >= BNX2I_CQ_WQES_MIN) &&
> > +		    (val <= BNX2I_CQ_WQES_MAX)) {
> > +			hba->max_cqes = val;
> > +		}
> > +	}
> > +	return count;
> > +}
> > +
> > +static ssize_t bnx2i_show_rq_info(struct class_device *cdev, char *buf)
> > +{
> > +	struct bnx2i_hba *hba =
> > +		container_of(cdev, struct bnx2i_hba, class_dev);
> > +
> > +	return sprintf(buf, "0x%x\n", hba->max_rqes);
> > +}
> > +
> > +static ssize_t bnx2i_set_rq_info(struct class_device *cdev, const char *buf,
> > +							size_t count)
> > +{
> > +	u32 val;
> > +	struct bnx2i_hba *hba =
> > +		container_of(cdev, struct bnx2i_hba, class_dev);
> > +
> > +	if (sscanf(buf, " 0x%x ", &val) > 0) {
> > +		if ((val >= BNX2I_RQ_WQES_MIN) &&
> > +		    (val <= BNX2I_RQ_WQES_MAX)) {
> > +			hba->max_rqes = val;
> > +		}
> > +	}
> > +	return count;
> > +}
> > +
> > +
> > +static ssize_t bnx2i_show_ccell_info(struct class_device *cdev, char *buf)
> > +{
> > +	struct bnx2i_hba *hba =
> > +		container_of(cdev, struct bnx2i_hba, class_dev);
> > +
> > +	return sprintf(buf, "0x%x\n", hba->num_ccell);
> > +}
> > +
> > +static ssize_t bnx2i_set_ccell_info(struct class_device *cdev,
> > +				    const char *buf, size_t count)
> > +{
> > +	u32 val;
> > +	struct bnx2i_hba *hba =
> > +		container_of(cdev, struct bnx2i_hba, class_dev);
> > +
> > +	if (sscanf(buf, " 0x%x ", &val) > 0) {
> > +		if ((val >= BNX2I_CCELLS_MIN) &&
> > +		    (val <= BNX2I_CCELLS_MAX)) {
> > +			hba->num_ccell = val;
> > +		}
> > +	}
> > +	return count;
> > +}
> > +
> > +
> > +static ssize_t bnx2i_read_pci_trigger_reg(struct class_device *cdev,
> > +					  char *buf)
> > +{
> > +	u32 reg_val = 0;
> > +	struct bnx2i_hba *hba =
> > +		container_of(cdev, struct bnx2i_hba, class_dev);
> > +#define PCI_EVENT_TRIGGER_REG	0xCAC	/* DMA WCHAN STAT10 REG */
> > +	reg_val = readl(hba->cnic->regview + PCI_EVENT_TRIGGER_REG);
> > +	return sprintf(buf, "0x%x\n", reg_val);
> > +}
> > +
> > +
> > +static ssize_t bnx2i_get_iscsi_cntx_dump(struct class_device *cdev, char *buf)
> > +{
> > +	struct bnx2i_hba *hba =
> > +		container_of(cdev, struct bnx2i_hba, class_dev);
> > +	unsigned int *ptr = (unsigned int *) hba->ctx_addr;
> > +	unsigned int *dst_ptr = (unsigned int *) buf;
> > +	int unit_sz = sizeof(unsigned int);
> > +#define SYSFS_BUF_SIZE			4096
> > +#define NUM_SYSFS_BUFS_PER_CTX		4
> > +
> > +	if (hba->ctx_read_cnt == NUM_SYSFS_BUFS_PER_CTX)
> > +		return 0;
> > +
> > +	ptr += (((hba->ctx_read_cnt % NUM_SYSFS_BUFS_PER_CTX) *
> > +		 SYSFS_BUF_SIZE) / unit_sz);
> > +	hba->ctx_read_cnt++;
> > +	memcpy(dst_ptr, ptr, SYSFS_BUF_SIZE);
> > +
> > +	return SYSFS_BUF_SIZE;
> > +}
> > +
> > +static ssize_t bnx2i_select_iscsi_cntx_dump(struct class_device *cdev,
> > +					    const char *buf, size_t count)
> > +{
> > +	u32 iscsi_cid;
> > +	int ret = 0;
> > +	struct bnx2i_hba *hba =
> > +		container_of(cdev, struct bnx2i_hba, class_dev);
> > +
> > +	if (sscanf(buf, " 0x%x ", &iscsi_cid) > 0) {
> > +		ret = bnx2i_select_ctx_dump_cid(hba, iscsi_cid);
> > +	}
> > +	if (!ret)
> > +		ret = count;
> > +	return ret;
> > +}
> > +
> > +static ssize_t bnx2i_get_active_iscsi_cid_list(struct class_device *cdev,
> > +					       char *buf)
> > +{
> > +	u32 active_iscsi_cid[32];
> > +	u32 active_cid[32];
> > +	int num_cid = 0;
> > +	ssize_t total_len = 0;
> > +	char *cur_ptr = buf;
> > +	int i = 0;
> > +	struct bnx2i_hba *hba =
> > +		container_of(cdev, struct bnx2i_hba, class_dev);
> > +	u32 num_ccell = hba->ctx_ccell_tasks & 0xFFFF;
> > +	u32 num_tasks_per_conn = hba->ctx_ccell_tasks >> 16;
> > +
> > +	if (!hba->ictx_poll_mode) {
> > +		num_cid = bnx2i_list_iscsi_cid(hba, active_iscsi_cid,
> > +					       active_cid);
> > +	}
> > +	total_len += sprintf(cur_ptr, "0x%x\n", BNX2I_SYSFS_VERSION);
> > +	cur_ptr = buf + total_len;
> > +	total_len += sprintf(cur_ptr, "0x%x\n", num_ccell);
> > +	cur_ptr = buf + total_len;
> > +	total_len += sprintf(cur_ptr, "0x%x\n", num_tasks_per_conn);
> > +	if (hba->ictx_poll_mode) {
> > +		if (hba->ictx_poll_cid) {
> > +			cur_ptr = buf + total_len;
> > +			total_len += sprintf(cur_ptr, "0x%x, 0x%x\n",
> > +					     hba->ictx_poll_iscsi_cid,
> > +					     hba->ictx_poll_cid);
> > +			hba->ictx_poll_cid = hba->ictx_poll_iscsi_cid = 0;
> > +		}
> > +	} else {
> > +		for (i = 0; i < num_cid; i++) {
> > +			cur_ptr = buf + total_len;
> > +			total_len += sprintf(cur_ptr, "0x%x, 0x%x\n",
> > +					     active_iscsi_cid[i],
> > +					     active_cid[i]);
> > +		}
> > +	}
> > +	return total_len;
> > +}
> > +
> > +
> > +static ssize_t bnx2i_set_iscsi_cid_err_poll_mode(struct class_device *cdev,
> > +						 const char *buf, size_t count)
> > +{
> > +	u32 poll_mode;
> > +	struct bnx2i_hba *hba =
> > +		container_of(cdev, struct bnx2i_hba, class_dev);
> > +
> > +	if (sscanf(buf, "0x%x", &poll_mode) > 0) {
> > +		if (poll_mode)
> > +			hba->ictx_poll_mode = 1;
> > +		else
> > +			hba->ictx_poll_mode = 0;
> > +	}
> > +	return count;
> > +}
> > +
> > +
> > +static ssize_t bnx2i_get_qp_shmem_dump(struct class_device *cdev, char *buf)
> > +{
> > +	struct bnx2i_hba *hba =
> > +		container_of(cdev, struct bnx2i_hba, class_dev);
> > +	int resi_len = hba->sq_cq_size -
> > +		       (hba->sq_cq_rdp - hba->sq_cq_dump);
> > +
> > +	if (!hba->sq_cq_dump || !hba->sq_cq_rdp) {
> > +		return -EINVAL;
> > +	} else if ((hba->sq_cq_dump + hba->sq_cq_size) ==
> > +		   hba->sq_cq_rdp) {
> > +		kfree(hba->sq_cq_dump);
> > +		hba->sq_cq_dump = hba->sq_cq_rdp = NULL;
> > +		return 0;
> > +	}
> > +
> > +	if (resi_len > SYSFS_BUF_SIZE) {
> > +		resi_len = SYSFS_BUF_SIZE;
> > +	}
> > +	memcpy(buf, hba->sq_cq_rdp, resi_len);
> > +	hba->sq_cq_rdp += resi_len;
> > +
> > +	return resi_len;
> > +}
> > +
> > +
> > +
> > +
> > +static void bnx2i_dup_cq_mem(struct bnx2i_hba *hba,
> > +			     struct bnx2i_conn *conn, int count)
> > +{
> > +	struct cqe *cqe_s;
> > +	struct cqe *cqe_d;
> > +	int total_cnt = count;
> > +
> > +	if (conn->ep->qp.cq_cons_qe == conn->ep->qp.cq_virt)
> > +		cqe_s = conn->ep->qp.cq_last_qe;
> > +	else
> > +		cqe_s = conn->ep->qp.cq_cons_qe - 1;
> > +	cqe_d = (struct cqe *)hba->sq_cq_rdp;
> > +	while (count--) {
> > +		memcpy(cqe_d, cqe_s, sizeof(struct cqe));
> > +		if (cqe_s == conn->ep->qp.cq_virt) {
> > +			cqe_s = conn->ep->qp.cq_last_qe;
> > +		} else {
> > +			cqe_s--;
> > +		}
> > +		cqe_d++;
> > +		if ((cqe_d - (struct cqe *)hba->sq_cq_rdp) > total_cnt) {
> > +			printk(KERN_ALERT "bnx2i - SQ Dump: mem overflow\n");
> > +			break;
> > +		}
> > +	}
> > +}
> > +
> > +
> > +static int bnx2i_init_cq_dump(struct bnx2i_hba *hba, u32 iscsi_cid,
> > +			      u32 count)
> > +{
> > +	struct bnx2i_conn *conn = NULL;
> > +	int cq_size = 0;
> > +
> > +	conn = bnx2i_get_conn_from_id(hba, iscsi_cid);
> > +
> > +	if (!conn) {
> > +		printk(KERN_ALERT "CQ dump: cid #%x not valid\n",
> > +				  iscsi_cid);
> > +		return -EPERM;
> > +	}
> > +
> > +	if (hba->sq_cq_dump)
> > +		return -EPERM;
> > +
> > +	cq_size = (conn->ep->qp.cq_last_qe - conn->ep->qp.cq_virt) + 1;
> > +
> > +	if (!count || (count > cq_size))
> > +		count = cq_size;
> > +
> > +	hba->sq_cq_size = count * sizeof(struct cqe);
> > +
> > +	if (!hba->sq_cq_size)
> > +		return -EINVAL;
> > +
> > +	hba->sq_cq_dump = kmalloc(hba->sq_cq_size, GFP_KERNEL);
> > +	if (!hba->sq_cq_dump)
> > +		return -ENOMEM;
> > +	hba->sq_cq_rdp = hba->sq_cq_dump;
> > +
> > +	bnx2i_dup_cq_mem(hba, conn, count);
> > +	return 0;
> > +}
> > +
> > +
> > +
> > +static void bnx2i_dup_sq_mem(struct bnx2i_hba *hba,
> > +			     struct bnx2i_conn *conn, int count)
> > +{
> > +	struct sqe *sqe_s;
> > +	struct sqe *sqe_d;
> > +	int total_cnt = count;
> > +
> > +	if (conn->ep->qp.sq_prod_qe == conn->ep->qp.sq_virt)
> > +		sqe_s = conn->ep->qp.sq_last_qe;
> > +	else
> > +		sqe_s = conn->ep->qp.sq_prod_qe - 1;
> > +	sqe_d = (struct sqe *)hba->sq_cq_rdp;
> > +	while (count--) {
> > +		memcpy(sqe_d, sqe_s, sizeof(struct sqe));
> > +		if (sqe_s == conn->ep->qp.sq_virt) {
> > +			sqe_s = conn->ep->qp.sq_last_qe;
> > +		} else {
> > +			sqe_s--;
> > +		}
> > +		sqe_d++;
> > +		if ((sqe_d - (struct sqe *) hba->sq_cq_rdp) >
> > +		    total_cnt) {
> > +			printk(KERN_ALERT "bnx2i - SQ Dump: mem overflow\n");
> > +			break;
> > +		}
> > +	}
> > +}
> > +
> > +
> > +static int bnx2i_init_sq_dump(struct bnx2i_hba *hba,
> > +			      u32 iscsi_cid, u32 count)
> > +{
> > +	struct bnx2i_conn *conn = NULL;
> > +	int sq_size = 0;
> > +
> > +	conn = bnx2i_get_conn_from_id(hba, iscsi_cid);
> > +
> > +	if (!conn) {
> > +		printk(KERN_ALERT "SQ dump: cid #%x not valid\n",
> > +				  iscsi_cid);
> > +		return -EINVAL;
> > +	}
> > +
> > +	if (hba->sq_cq_dump)
> > +		return -EINVAL;
> > +
> > +	sq_size = (conn->ep->qp.sq_last_qe - conn->ep->qp.sq_virt) + 1;
> > +
> > +	if (!count || (count > sq_size))
> > +		count = sq_size;
> > +
> > +	hba->sq_cq_size = count * sizeof(struct sqe);
> > +
> > +	if (!hba->sq_cq_size)
> > +		return -EINVAL;
> > +
> > +	hba->sq_cq_dump = kmalloc(hba->sq_cq_size, GFP_KERNEL);
> > +	if (!hba->sq_cq_dump)
> > +		return -ENOMEM;
> > +	hba->sq_cq_rdp = hba->sq_cq_dump;
> > +
> > +	bnx2i_dup_sq_mem(hba, conn, count);
> > +	return 0;
> > +}
> > +
> > +static ssize_t bnx2i_setup_qp_shmem_dump(struct class_device *cdev,
> > +					 const char *buf, size_t count)
> > +{
> > +	struct bnx2i_hba *hba =
> > +		container_of(cdev, struct bnx2i_hba, class_dev);
> > +	u32 iscsi_cid;
> > +	char queue[32];
> > +	ssize_t ret = count;
> > +	u32 num_count;
> > +
> > +
> > +	if (sscanf(buf, "%c%c,%d,%d", &queue[0], &queue[1],
> > +		   &iscsi_cid, &num_count) > 0) {
> > +		if (!strncmp(queue, "SQ", 2)) {
> > +			ret = bnx2i_init_sq_dump(hba, iscsi_cid, num_count);
> > +		} else if (!strncmp(queue, "CQ", 2)) {
> > +			ret = bnx2i_init_cq_dump(hba, iscsi_cid, num_count);
> > +		} else {
> > +			ret = -EINVAL;
> > +		}
> > +	}
> > +	return ret;
> > +}
> > +
> > +
> > +static ssize_t bnx2i_read_tcp_portd_options(struct class_device *cdev,
> > +					    char *buf)
> > +{
> > +	extern struct tcp_port_mngt bnx2i_tcp_port_tbl;
> > +	return sprintf(buf, "0x%x\n", bnx2i_tcp_port_tbl.num_required);
> > +}
> > +
> > +static ssize_t bnx2i_write_tcp_portd_results(struct class_device *cdev,
> > +					     const char *buf, size_t count)
> > +{
> > +	extern struct tcp_port_mngt bnx2i_tcp_port_tbl;
> > +	u32 tcp_port, bind_stat;
> > +
> > +	if (!bnx2i_tcp_port_tbl.free_q)
> > +		return count;
> > +
> > +	if (sscanf(buf, "%d,%d", &tcp_port, &bind_stat) > 0) {
> > +		if (bind_stat && tcp_port) {
> > +			bnx2i_tcp_port_new_entry(tcp_port);
> > +		}
> > +	}
> > +	return count;
> > +}
> > +
> > +
> > +static CLASS_DEVICE_ATTR (mips_info, S_IRUGO,
> > +			 bnx2i_show_mips_status, NULL);
> > +static CLASS_DEVICE_ATTR (net_if_name, S_IRUGO,
> > +			 bnx2i_show_net_if_name, NULL);
> > +static CLASS_DEVICE_ATTR (pci_bar, S_IRUGO,
> > +			 bnx2i_show_pci_bar, NULL);
> > +static CLASS_DEVICE_ATTR (sq_size, S_IRUGO | S_IWUSR,
> > +			 bnx2i_show_sq_info, bnx2i_set_sq_info);
> > +static CLASS_DEVICE_ATTR (cq_size, S_IRUGO | S_IWUSR,
> > +			 bnx2i_show_cq_info, bnx2i_set_cq_info);
> > +static CLASS_DEVICE_ATTR (rq_size, S_IRUGO | S_IWUSR,
> > +			 bnx2i_show_rq_info, bnx2i_set_rq_info);
> > +static CLASS_DEVICE_ATTR (num_ccell, S_IRUGO | S_IWUSR,
> > +			 bnx2i_show_ccell_info, bnx2i_set_ccell_info);
> > +static CLASS_DEVICE_ATTR (pci_trigger, S_IRUGO,
> > +			 bnx2i_read_pci_trigger_reg, NULL);
> > +static CLASS_DEVICE_ATTR (ctx_dump, S_IRUGO | S_IWUSR,
> > +			 bnx2i_get_iscsi_cntx_dump,
> > +			 bnx2i_select_iscsi_cntx_dump);
> > +static CLASS_DEVICE_ATTR (cid_list, S_IRUGO | S_IWUSR,
> > +			 bnx2i_get_active_iscsi_cid_list,
> > +			 bnx2i_set_iscsi_cid_err_poll_mode);
> > +static CLASS_DEVICE_ATTR (qp_shmem_dump, S_IRUGO | S_IWUSR,
> > +			 bnx2i_get_qp_shmem_dump,
> > +			 bnx2i_setup_qp_shmem_dump);
> > +static CLASS_DEVICE_ATTR (port_bind, S_IRUGO | S_IWUSR,
> > +			 bnx2i_read_tcp_portd_options,
> > +			 bnx2i_write_tcp_portd_results);
> > +
> > +
> > +static struct class_device_attribute *bnx2i_class_attributes[] = {
> > +	&class_device_attr_mips_info,
> > +	&class_device_attr_net_if_name,
> > +	&class_device_attr_pci_bar,
> > +	&class_device_attr_sq_size,
> > +	&class_device_attr_cq_size,
> > +	&class_device_attr_rq_size,
> > +	&class_device_attr_num_ccell,
> > +	&class_device_attr_pci_trigger,
> > +	&class_device_attr_ctx_dump,
> > +	&class_device_attr_cid_list,
> > +	&class_device_attr_qp_shmem_dump,
> > +};
> > +
> > +static struct class_device_attribute *tcp_port_class_attributes[] = {
> > +	&class_device_attr_port_bind
> > +};
> > +
> > +static void bnx2i_sysfs_release(struct class_device *class_dev)
> > +{
> > +}
> > +
> > +struct class_device port_class_dev;
> > +
> > +
> > +static struct class bnx2i_class = {
> > +	.name	= "bnx2i",
> > +	.release = bnx2i_sysfs_release,
> > +};
> > +
> > +
> > +
> > +static int bnx2i_register_port_class_dev(struct class_device *class_dev)
> > +{
> > +	char dev_name[BUS_ID_SIZE];
> > +	int ret;
> > +	int i;
> > +
> > +	class_dev->class = &bnx2i_class;
> > +	class_dev->class_data = class_dev;
> > +	snprintf(dev_name, BUS_ID_SIZE, "%s", "tcp_portd");
> > +	strlcpy(class_dev->class_id, dev_name, BUS_ID_SIZE);
> > +
> > +	ret = class_device_register(class_dev);
> > +	if (ret)
> > +		goto err;
> > +
> > +	for (i = 0; i < ARRAY_SIZE(tcp_port_class_attributes); ++i) {
> > +		ret = class_device_create_file(class_dev,
> > +					       tcp_port_class_attributes[i]);
> > +		if (ret)
> > +			goto err_unregister;
> > +	}
> > +
> > +	return 0;
> > +
> > +err_unregister:
> > +	class_device_unregister(class_dev);
> > +err:
> > +	return ret;
> > +}
> > +
> > +
> > +int bnx2i_register_sysfs(struct bnx2i_hba *hba)
> > +{
> > +	struct class_device *class_dev = &hba->class_dev;
> > +	char dev_name[BUS_ID_SIZE];
> > +	int ret;
> > +	int i;
> > +
> > +	class_dev->class = &bnx2i_class;
> > +	class_dev->class_data = hba;
> > +	snprintf(dev_name, BUS_ID_SIZE, "%.2x:%.2x.%.1x",
> > +		 hba->pci_dev->bus->number,
> > +		 PCI_SLOT(hba->pci_dev->devfn),
> > +		 PCI_FUNC(hba->pci_dev->devfn));
> > +	strlcpy(class_dev->class_id, dev_name, BUS_ID_SIZE);
> > +
> > +	ret = class_device_register(class_dev);
> > +	if (ret)
> > +		goto err;
> > +
> > +	for (i = 0; i < ARRAY_SIZE(bnx2i_class_attributes); ++i) {
> > +		ret = class_device_create_file(class_dev,
> > +					       bnx2i_class_attributes[i]);
> > +		if (ret)
> > +			goto err_unregister;
> > +	}
> > +
> > +	return 0;
> > +
> > +err_unregister:
> > +	class_device_unregister(class_dev);
> > +err:
> > +	return ret;
> > +}
> > +
> > +void bnx2i_unregister_sysfs(struct bnx2i_hba *hba)
> > +{
> > +	class_device_unregister(&hba->class_dev);
> > +}
> > +
> > +int bnx2i_sysfs_setup(void)
> > +{
> > +	int ret;
> > +	ret = class_register(&bnx2i_class);
> > +
> > +	bnx2i_register_port_class_dev(&port_class_dev);
> > +	return ret;
> > +}
> > +
> > +void bnx2i_sysfs_cleanup(void)
> > +{
> > +	class_device_unregister(&port_class_dev);
> > +	class_unregister(&bnx2i_class);
> > +}
> > 
> > 
> > -
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

