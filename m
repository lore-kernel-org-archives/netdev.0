From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [openib-general] [PATCH 3/9] NetEffect 10Gb RNIC Driver:
	openfabrics connection manager c file
Date: Fri, 27 Oct 2006 10:12:31 -0500
Message-ID: <1161961951.2748.22.camel@trinity.ogc.int>
References: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9EB8@venom2>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: openib-general@openib.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-218-104.sw.biz.rr.com ([24.153.218.104]:61925 "EHLO
	smtp.opengridcomputing.com") by vger.kernel.org with ESMTP
	id S1752262AbWJ0PMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Oct 2006 11:12:25 -0400
To: Glenn Grundstrom <ggrundstrom@NetEffect.com>
In-Reply-To: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9EB8@venom2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[...snip...]
> +extern void set_interface(
> +				   UINT32    ip_addr,

These should probably be the standard linux types u32, or uint32

> +				   UINT32    mask,
> +				   UINT32    bcastaddr,
> +				   UINT32    type
> +				  );

[...snip...]

> +	struct NES_sockaddr_in  inet_addr;
> +	struct sockaddr_in  kinet_addr;

Is there some reason why you need your own sockaddr and sockaddr_in
structures? 

[...snip...]
> +
> +/**
> + * nes_disconnect
> + * 
> + * @param cm_id
> + * @param abrupt
> + * 
> + * @return int
> + */
> +int nes_disconnect(struct iw_cm_id *cm_id, int abrupt)
> +{
> +	struct ib_qp_attr attr;
> +	struct ib_qp *ibqp;
> +	struct nes_qp *nesqp;
> +	struct nes_dev *nesdev = to_nesdev(cm_id->device);
> +	int err = 0;
> +	u8 u8temp;
> +
> +	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +	dprintk("%s: netdev refcnt = %u.\n", __FUNCTION__,
> atomic_read(&nesdev->netdev->refcnt));
> +
> +	/* If the qp was already destroyed, then there's no QP */
> +	if (cm_id->provider_data == 0)
> +		return 0;
> +
> +	nesqp = (struct nes_qp *)cm_id->provider_data;
> +	ibqp = &nesqp->ibqp;
> +
> +	/* Disassociate the QP from this cm_id */
> +	cm_id->provider_data = 0;
> +	cm_id->rem_ref(cm_id);
> +	nesqp->cm_id = 0;
> +
> +	stack_ops_p->decelerate_socket(nesqp->socket, 
> +                                (struct nes_uploaded_qp_context *)
> +                                nesqp->nesqp_context);
> +  
> +	if (nesqp->active_conn) {
> +	  u8temp = 1 << (ntohs(cm_id->local_addr.sin_port)&7);
> +	  nesdev->apbv_table[ntohs(cm_id->local_addr.sin_port)>>3] &=
> ~(u8temp);
> +	} else {
> +		dev_put(nesdev->netdev);
> +        /* Need to free the Last Streaming Mode Message */
> +        pci_free_consistent(nesdev->pcidev, 
> +
> nesqp->private_data_len+sizeof(*nesqp->ietf_frame), 
> +                            nesqp->ietf_frame,
> +                            nesqp->ietf_frame_pbase);

This is mailer perversion. You need to turn off wrapping in your mailer.
It makes it hard to review the patch never mind apply it.

> +    }
> +
> +	if (nesqp->ksock) sock_release(nesqp->ksock);
> +	stack_ops_p->sock_ops_p->close( nesqp->socket );
> +	nesqp->ksock = 0;
> +	nesqp->socket = 0;
> +	if (nesqp->wq) {
> +		destroy_workqueue(nesqp->wq);

This will deadlock if this function is called from a workqueue thread
and CONFIG_HOTPLUG_CPU is enabled. 

> +		nesqp->wq = NULL;
> +	}
> +
> +	memset(&attr, 0, sizeof(struct ib_qp_attr));
> +	if (abrupt)
> +		attr.qp_state = IB_QPS_ERR;
> +	else
> +		attr.qp_state = IB_QPS_SQD;
> +
> +	return err;
> +}
> +
> +
> +/**
> + * nes_accept
> + * 
> + * @param cm_id
> + * @param conn_param
> + * 
> + * @return int
> + */
> +int nes_accept(struct iw_cm_id *cm_id, struct iw_cm_conn_param
> *conn_param)
> +{
> +	struct nes_qp *nesqp;
> +	struct nes_dev *nesdev;
> +	struct nes_adapter *nesadapter;
> +	struct ib_qp *ibqp;
> +    struct nes_hw_qp_wqe *wqe;
> +	struct nes_v4_quad nes_quad;
> +	struct ib_qp_attr attr;
> +    struct iw_cm_event cm_event;
> +
> +	dprintk("%s:%s:%u: data len = %u\n", 
> +			__FILE__, __FUNCTION__, __LINE__,
> conn_param->private_data_len);
> +
> +	ibqp = nes_get_qp(cm_id->device, conn_param->qpn);
> +	if (!ibqp)
> +		return -EINVAL;
> +	nesqp = to_nesqp(ibqp);
> +	nesdev = to_nesdev(nesqp->ibqp.device);
> +	nesadapter = nesdev->nesadapter;
> +	dprintk("%s: netdev refcnt = %u.\n", __FUNCTION__,
> atomic_read(&nesdev->netdev->refcnt));
> +
> +    nesqp->ietf_frame = pci_alloc_consistent(nesdev->pcidev, 
> +
> sizeof(*nesqp->ietf_frame)+conn_param->private_data_len,
> +                                             &nesqp->ietf_frame_pbase);
> +    if (!nesqp->ietf_frame) {
> +        dprintk(KERN_ERR PFX "%s: Unable to allocate memory for private
> data\n", __FUNCTION__);
> +        return -ENOMEM;
> +    }
> +    dprintk(PFX "%s: PCI consistent memory for "
> +            "private data located @ %p (pa = 0x%08lX.) size = %u.\n", 
> +            __FUNCTION__, nesqp->ietf_frame, (unsigned
> long)nesqp->ietf_frame_pbase,
> +            conn_param->private_data_len+sizeof(*nesqp->ietf_frame));
> +    nesqp->private_data_len = conn_param->private_data_len;
> +
> +    strcpy(&nesqp->ietf_frame->key[0], IEFT_MPA_KEY_REP);
> +    memcpy(&nesqp->ietf_frame->private_data, conn_param->private_data,
> conn_param->private_data_len);
> +    nesqp->ietf_frame->private_data_size =
> cpu_to_be16(conn_param->private_data_len);
> +    nesqp->ietf_frame->rev = mpa_version;
> +    nesqp->ietf_frame->flags = IETF_MPA_FLAGS_CRC;
> +
> +    wqe = &nesqp->hwqp.sq_vbase[0];
> +    *((struct nes_qp
> **)&wqe->wqe_words[NES_IWARP_SQ_WQE_COMP_CTX_LOW_IDX]) = nesqp;
> +	*((u64 *)&wqe->wqe_words[NES_IWARP_SQ_WQE_COMP_CTX_LOW_IDX]) |=
> NES_SW_CONTEXT_ALIGN>>1;
> +    wqe->wqe_words[NES_IWARP_SQ_WQE_MISC_IDX] =
> cpu_to_le32(NES_IWARP_SQ_WQE_STREAMING); 
> +    wqe->wqe_words[NES_IWARP_SQ_WQE_TOTAL_PAYLOAD_IDX] =
> cpu_to_le32(conn_param->private_data_len+sizeof(*nesqp->ietf_frame));
> +    wqe->wqe_words[NES_IWARP_SQ_WQE_FRAG0_LOW_IDX] =
> cpu_to_le32((u32)nesqp->ietf_frame_pbase);
> +    wqe->wqe_words[NES_IWARP_SQ_WQE_FRAG0_HIGH_IDX] =
> cpu_to_le32((u32)((u64)nesqp->ietf_frame_pbase>>32));
> +    wqe->wqe_words[NES_IWARP_SQ_WQE_LENGTH0_IDX] =
> cpu_to_le32(conn_param->private_data_len+sizeof(*nesqp->ietf_frame));

These are way over 80 columns wide.

> +    wqe->wqe_words[NES_IWARP_SQ_WQE_STAG0_IDX] = 0;
> +
> +	nesqp->nesqp_context->ird_ord_sizes |=
> NES_QPCONTEXT_ORDIRD_LSMM_PRESENT | NES_QPCONTEXT_ORDIRD_WRPDU;
> +    nesqp->skip_lsmm = 1;
> +
> +	/* Cache the cm_id in the qp */
> +	nesqp->cm_id = cm_id;

This should all be reformatted with standard 8 character wide tabs. I
think these were formatted with ts=4

> +	nesqp->socket = (u32)cm_id->provider_data;

[...snip...]


