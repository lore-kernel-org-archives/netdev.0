From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [openib-general] [PATCH 8/9] NetEffect 10Gb RNIC Driver:
	openfabrics verbs interface c file
Date: Fri, 27 Oct 2006 10:27:04 -0500
Message-ID: <1161962824.14333.33.camel@stevo-desktop>
References: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9EC3@venom2>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: openib-general@openib.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-218-104.sw.biz.rr.com ([24.153.218.104]:56450 "EHLO
	smtp.opengridcomputing.com") by vger.kernel.org with ESMTP
	id S1752304AbWJ0P1K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Oct 2006 11:27:10 -0400
To: Glenn Grundstrom <ggrundstrom@NetEffect.com>
In-Reply-To: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9EC3@venom2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

General comments:  

The patches are all messed up due to your mailer wrapping.  It makes it
hard to review.

There are lots of comments saying "Catch the error cases".  You'll need
to address these.

Formatting: read the linux kernel coding guidelines. 

More below...


...

> +static struct ib_ucontext *nes_alloc_ucontext(struct ib_device *ibdev,
> +
> struct ib_udata *udata) {
> +	struct nes_dev *nesdev = to_nesdev(ibdev);
> +	struct nes_alloc_ucontext_resp uresp;
> +	struct nes_ucontext *nes_ucontext;
> +
> +	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +	memset(&uresp, 0, sizeof uresp);
> +
> +	uresp.max_qps = nesdev->nesadapter->max_qp;
> +	uresp.max_pds = nesdev->nesadapter->max_pd;
> +	uresp.wq_size = nesdev->nesadapter->max_qp_wr*2;
> +
> +	nes_ucontext = kmalloc(sizeof *nes_ucontext, GFP_KERNEL);
> +	if (!nes_ucontext)
> +		return ERR_PTR(-ENOMEM);
> +
> +	memset(nes_ucontext, 0, sizeof(*nes_ucontext));
> +

kzalloc() will kmalloc and initialize the memory to zeros.

> +	nes_ucontext->nesdev = nesdev;
> +	/* TODO: much better ways to manage this area */
> +	/* TODO: cqs should be user buffers */
> +	nes_ucontext->mmap_wq_offset = ((uresp.max_pds *
> 4096)+PAGE_SIZE-1)/PAGE_SIZE;
> +	nes_ucontext->mmap_cq_offset = nes_ucontext->mmap_wq_offset + 
> +
> ((sizeof(struct nes_hw_qp_wqe) * uresp.max_qps *
> 2)+PAGE_SIZE-1)/PAGE_SIZE;
> +

I think you can use PAGE_ALIGN() here...

> +	if (ib_copy_to_udata(udata, &uresp, sizeof uresp)) {
> +		kfree(nes_ucontext);
> +		return ERR_PTR(-EFAULT);
> +	}
> +
> +	INIT_LIST_HEAD(&nes_ucontext->cq_reg_mem_list);
> +	return &nes_ucontext->ibucontext;
> +}
> +
> +
> +/**
> + * nes_dealloc_ucontext
> + * 
> + * @param context
> + * 
> + * @return int
> + */
> +static int nes_dealloc_ucontext(struct ib_ucontext *context)
> +{
> +//	struct nes_dev *nesdev = to_nesdev(context->device);
> +	struct nes_ucontext *nes_ucontext = to_nesucontext(context);
> +	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +
> +	kfree(nes_ucontext);
> +	return 0;
> +}
> +
> +
> +/**
> + * nes_mmap
> + * 
> + * @param context
> + * @param vma
> + * 
> + * @return int
> + */
> +static int nes_mmap(struct ib_ucontext *context, struct vm_area_struct
> *vma)
> +{
> +	unsigned long index;
> +	struct nes_dev *nesdev = to_nesdev(context->device);
> +//	struct nes_adapter *nesadapter = nesdev->nesadapter;
> +	struct nes_ucontext *nes_ucontext;
> +	struct nes_qp *nesqp;
> +
> +	nes_ucontext = to_nesucontext(context);
> +
> +	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +
> +
> +	if (vma->vm_pgoff >= nes_ucontext->mmap_wq_offset) {
> +		index = (vma->vm_pgoff - nes_ucontext->mmap_wq_offset) *
> PAGE_SIZE;
> +		index /= ((sizeof(struct nes_hw_qp_wqe) *
> nesdev->nesadapter->max_qp_wr * 2)+PAGE_SIZE-1)&(~(PAGE_SIZE-1));


Is there a way to do this without division?

> 		if (!test_bit(index, nes_ucontext->allocated_wqs)) {
> +			dprintk("%s: wq %lu not
> allocated\n",__FUNCTION__, index);
> +			return -EFAULT;
> +		}
> +		nesqp = nes_ucontext->mmap_nesqp[index];
> +		if (NULL == nesqp) {
> +			dprintk("%s: wq %lu has a NULL QP
> base.\n",__FUNCTION__, index);
> +			return -EFAULT;
> +		}
> +		if (remap_pfn_range(vma, vma->vm_start, 
> +
> nesqp->hwqp.sq_pbase>>PAGE_SHIFT, 
> +
> vma->vm_end-vma->vm_start,	
> +
> vma->vm_page_prot)) {
> +			return(-EAGAIN);
> +		}
> +		vma->vm_private_data = nesqp;
> +		return 0;
> +	} else {
> +		index = vma->vm_pgoff;
> +		if (!test_bit(index, nes_ucontext->allocated_doorbells))
> +			return -EFAULT;
> +
> +		vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
> +		if ( io_remap_pfn_range(vma, vma->vm_start,
> +
> (nesdev->nesadapter->doorbell_start+
> +
> ((nes_ucontext->mmap_db_index[index]-nesdev->base_doorbell_index)*4096))
> +								>>
> PAGE_SHIFT, PAGE_SIZE, vma->vm_page_prot))
> +			return -EAGAIN;
> +		vma->vm_private_data = nes_ucontext;
> +		return 0;
> +	}
> +
> +	return -ENOSYS;
> +	return 0;
> +}
> +
> +
> +/**
> + * nes_alloc_pd
> + * 
> + * @param ibdev
> + * @param context
> + * @param udata
> + * 
> + * @return struct ib_pd*
> + */
> +static struct ib_pd *nes_alloc_pd(struct ib_device *ibdev,
> +								  struct
> ib_ucontext *context,
> +								  struct
> ib_udata *udata) {
> +	struct nes_pd *nespd;
> +	struct nes_dev *nesdev = to_nesdev(ibdev);
> +	struct nes_adapter *nesadapter = nesdev->nesadapter;
> +	struct nes_ucontext *nes_ucontext;
> +	struct nes_alloc_pd_resp uresp;
> +	u32 pd_num = 0;
> +	int err;
> +
> +	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +	dprintk("%s: netdev refcnt = %u.\n", __FUNCTION__,
> atomic_read(&nesdev->netdev->refcnt));
> +
> +	err = nes_alloc_resource(nesadapter, nesadapter->allocated_pds, 
> +
> nesadapter->max_pd, &pd_num, &nesadapter->next_pd);
> +	if (err) {
> +		return ERR_PTR(err);
> +	}
> +
> +	nespd = kmalloc(sizeof *nespd, GFP_KERNEL);
> +	if (!nespd) {
> +		nes_free_resource(nesadapter, nesadapter->allocated_pds,
> pd_num);
> +		return ERR_PTR(-ENOMEM);
> +	}
> +	dprintk("Allocating PD (%p) for ib device %s\n", nespd,
> nesdev->ibdev.name);
> +
> +	memset(nespd, 0, sizeof(*nespd));
> +

kzalloc()...

> +	/* TODO: consider per function considerations */
> +	nespd->pd_id = pd_num+nesadapter->base_pd;
> +	err = 0;
> +	if (err) {
> +		nes_free_resource(nesadapter, nesadapter->allocated_pds,
> pd_num);
> +		kfree(nespd);
> +		return ERR_PTR(err);
> +	}
> +
> +	if (context) {
> +		nes_ucontext = to_nesucontext(context);
> +		nespd->mmap_db_index =
> find_next_zero_bit(nes_ucontext->allocated_doorbells, 
> +
> NES_MAX_USER_DB_REGIONS, nes_ucontext->first_free_db );
> +		dprintk("find_first_zero_biton doorbells returned %u,
> mapping pd_id %u.\n", nespd->mmap_db_index, nespd->pd_id);
> +		if (nespd->mmap_db_index > NES_MAX_USER_DB_REGIONS) {
> +			nes_free_resource(nesadapter,
> nesadapter->allocated_pds, pd_num);
> +			kfree(nespd);
> +			return ERR_PTR(-ENOMEM);
> +		}
> +
> +		uresp.pd_id = nespd->pd_id;
> +		uresp.mmap_db_index = nespd->mmap_db_index;
> +		if (ib_copy_to_udata(udata, &uresp, sizeof uresp)) {
> +			nes_free_resource(nesadapter,
> nesadapter->allocated_pds, pd_num);
> +			kfree(nespd);
> +			return ERR_PTR(-EFAULT);
> +		}
> +		set_bit(nespd->mmap_db_index,
> nes_ucontext->allocated_doorbells);
> +		nes_ucontext->mmap_db_index[nespd->mmap_db_index] =
> nespd->pd_id;
> +		nes_ucontext->first_free_db = nespd->mmap_db_index + 1;
> +	}
> +
> +	dprintk("%s: PD%u structure located @%p.\n", __FUNCTION__,
> nespd->pd_id,  nespd);
> +	dprintk("%s: netdev refcnt = %u.\n", __FUNCTION__,
> atomic_read(&nesdev->netdev->refcnt));
> +	return (&nespd->ibpd);
> +}
> +
> +
> +/**
> + * nes_dealloc_pd
> + * 
> + * @param ibpd
> + * 
> + * @return int
> + */
> +static int nes_dealloc_pd(struct ib_pd *ibpd)
> +{
> +	struct nes_ucontext *nes_ucontext;
> +	struct nes_pd *nespd = to_nespd(ibpd);
> +	struct nes_dev *nesdev = to_nesdev(ibpd->device);
> +	struct nes_adapter *nesadapter = nesdev->nesadapter;
> +
> +	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +	// TODO: Do work here.


What work?

> +	if ((ibpd->uobject)&&(ibpd->uobject->context)) {
> +		nes_ucontext = to_nesucontext(ibpd->uobject->context);
> +		dprintk("%s: Clearing bit %u from allocated
> doorbells\n", __FUNCTION__, nespd->mmap_db_index);
> +		clear_bit(nespd->mmap_db_index,
> nes_ucontext->allocated_doorbells);
> +		nes_ucontext->mmap_db_index[nespd->mmap_db_index] = 0;
> +		if (nes_ucontext->first_free_db > nespd->mmap_db_index)
> {
> +			nes_ucontext->first_free_db =
> nespd->mmap_db_index;
> +		}
> +	}
> +
> +	dprintk("%s: Deallocating PD%u structure located @%p.\n",
> __FUNCTION__, nespd->pd_id,  nespd);
> +	nes_free_resource(nesadapter, nesadapter->allocated_pds,
> nespd->pd_id-nesadapter->base_pd);
> +	kfree(nespd);
> +
> +	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +	return 0;
> +}
> +
> +
> +/**
> + * nes_create_ah
> + * 
> + * @param pd
> + * @param ah_attr
> + * 
> + * @return struct ib_ah*
> + */
> +static struct ib_ah *nes_create_ah(struct ib_pd *pd, struct ib_ah_attr
> *ah_attr) 
> +{
> +	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +
> +	return ERR_PTR(-ENOSYS);
> +}
> +
> +
> +/**
> + * nes_destroy_ah
> + * 
> + * @param ah
> + * 
> + * @return int
> + */
> +static int nes_destroy_ah(struct ib_ah *ah)
> +{
> +	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +	return -ENOSYS;
> +}
> +
> +
> +/**
> + * nes_create_qp
> + * 
> + * @param ib_pd
> + * @param init_attr
> + * @param udata
> + * 
> + * @return struct ib_qp*
> + */
> +static struct ib_qp *nes_create_qp(struct ib_pd *ib_pd,
> +
> struct ib_qp_init_attr *init_attr,
> +
> struct ib_udata *udata) {
> +	u64 u64temp= 0, u64nesqp = 0;
> +	struct nes_pd *nespd = to_nespd(ib_pd);
> +	struct nes_dev *nesdev = to_nesdev(ib_pd->device);
> +	struct nes_adapter *nesadapter = nesdev->nesadapter;
> +	struct nes_qp *nesqp;
> +	struct nes_cq *nescq;
> +	struct nes_ucontext *nes_ucontext;
> +	struct nes_hw_cqp_wqe *cqp_wqe;
> +	struct nes_create_qp_resp uresp;
> +	u32 cqp_head = 0;
> +	u32 qp_num = 0;
> +//	u32 counter = 0;
> +	void *mem;
> +
> +    unsigned long flags;
> +    int ret;
> +	int err;
> +	int sq_size;
> +	int rq_size;
> +	u8 sq_encoded_size;
> +	u8 rq_encoded_size;
> +
> +	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +	dprintk("%s: netdev refcnt = %u.\n", __FUNCTION__,
> atomic_read(&nesdev->netdev->refcnt));
> +
> +	switch (init_attr->qp_type) {
> +	case IB_QPT_RC:
> +		/* TODO: */
> +		init_attr->cap.max_inline_data = 0;
> +
> +		if (init_attr->cap.max_send_wr < 32) {
> +			sq_size = 32;
> +			sq_encoded_size = 1;
> +		} else if (init_attr->cap.max_send_wr < 128) {
> +			sq_size = 128;
> +			sq_encoded_size = 2;
> +		} else if (init_attr->cap.max_send_wr < 512) {
> +			sq_size = 512;
> +			sq_encoded_size = 3;
> +		} else {
> +			printk(KERN_ERR PFX "%s: SQ size (%u) too
> large.\n", __FUNCTION__, init_attr->cap.max_send_wr);
> +			return ERR_PTR(-EINVAL);
> +		}
> +		init_attr->cap.max_send_wr = sq_size - 2;      
> +		if (init_attr->cap.max_recv_wr < 32) {
> +			rq_size = 32;
> +			rq_encoded_size = 1;
> +		} else if (init_attr->cap.max_recv_wr < 128) {
> +			rq_size = 128;
> +			rq_encoded_size = 2;
> +		} else if (init_attr->cap.max_recv_wr < 512) {
> +			rq_size = 512;
> +			rq_encoded_size = 3;
> +		} else {
> +			printk(KERN_ERR PFX "%s: RQ size (%u) too
> large.\n", __FUNCTION__, init_attr->cap.max_recv_wr);
> +			return ERR_PTR(-EINVAL);
> +		}      
> +		init_attr->cap.max_recv_wr = rq_size -1;
> +		dprintk("%s: RQ size = %u, SQ Size = %u.\n",
> __FUNCTION__, rq_size, sq_size);
> +
> +		ret = nes_alloc_resource(nesadapter,
> nesadapter->allocated_qps, nesadapter->max_qp, &qp_num,
> &nesadapter->next_qp);
> +		if (ret) {
> +			return ERR_PTR(ret);
> +		}
> +
> +		/* Need 512 (actually now 1024) byte alignment on this
> structure */
> +		mem = kzalloc(sizeof(*nesqp)+NES_SW_CONTEXT_ALIGN-1,
> GFP_KERNEL);
> +		if (!mem) {
> +			nes_free_resource(nesadapter,
> nesadapter->allocated_qps, qp_num);
> +			dprintk("%s: Unable to allocate QP\n",
> __FUNCTION__);
> +			return ERR_PTR(-ENOMEM);
> +		}
> +		u64nesqp = (u64)mem;   //u64nesqp = (u64)((uint)mem); 
> +		u64nesqp += ((u64)NES_SW_CONTEXT_ALIGN) - 1;
> +		u64temp = ((u64)NES_SW_CONTEXT_ALIGN) - 1;
> +		u64nesqp &= ~u64temp;
> +		nesqp = (struct nes_qp *)u64nesqp;
> +		dprintk("nesqp = %p, allocated buffer = %p.  Rounded to
> closest %u\n", nesqp, mem, NES_SW_CONTEXT_ALIGN);
> +		nesqp->allocated_buffer = mem;
> +
> +		if (udata) {
> +			if ((ib_pd->uobject)&&(ib_pd->uobject->context))
> {
> +				nesqp->user_mode = 1;
> +				nes_ucontext =
> to_nesucontext(ib_pd->uobject->context);
> +				nesqp->mmap_sq_db_index =
> find_next_zero_bit(nes_ucontext->allocated_wqs, 
> +
> NES_MAX_USER_WQ_REGIONS, nes_ucontext->first_free_wq);
> +				dprintk("find_first_zero_biton wqs
> returned %u\n", nespd->mmap_db_index);
> +				if
> (nesqp->mmap_sq_db_index>NES_MAX_USER_WQ_REGIONS) {
> +					dprintk("%s: db index is greater
> than max user reqions, failing create QP\n", __FUNCTION__);
> +					nes_free_resource(nesadapter,
> nesadapter->allocated_qps, qp_num);
> +					kfree(nesqp->allocated_buffer);
> +					return ERR_PTR(-ENOMEM);
> +				}
> +				set_bit(nesqp->mmap_sq_db_index,
> nes_ucontext->allocated_wqs);
> +
> nes_ucontext->mmap_nesqp[nesqp->mmap_sq_db_index] = nesqp;
> +				nes_ucontext->first_free_wq =
> nesqp->mmap_sq_db_index + 1;
> +			} else {
> +				nes_free_resource(nesadapter,
> nesadapter->allocated_qps, qp_num);
> +				kfree(nesqp->allocated_buffer);
> +				return ERR_PTR(-EFAULT);
> +			}
> +		}
> +
> +		// Allocate Memory
> +		nesqp->qp_mem_size =  (sizeof(struct
> nes_hw_qp_wqe)*sq_size) +	  /* needs 512 byte alignment */
> +							  (sizeof(struct
> nes_hw_qp_wqe)*rq_size) +				/* needs 512
> byte alignment */
> +
> max((u32)sizeof(struct nes_qp_context),((u32)256))  +		/* needs
> 8 byte alignment */
> +							  256;
> /* this is Q2 */
> +		/* Round up to a multiple of a page */
> +		nesqp->qp_mem_size += PAGE_SIZE - 1;
> +		nesqp->qp_mem_size &= ~(PAGE_SIZE - 1);
> +
> +		/* TODO: Need to separate out nesqp_context at that
> point too!!!! */
> +		mem = pci_alloc_consistent(nesdev->pcidev,
> nesqp->qp_mem_size,
> +
> &nesqp->hwqp.sq_pbase);
> +		if (!mem) {
> +			nes_free_resource(nesadapter,
> nesadapter->allocated_qps, qp_num);
> +			dprintk(KERN_ERR PFX "Unable to allocate memory
> for host descriptor rings\n");
> +			kfree(nesqp->allocated_buffer);
> +			return ERR_PTR(-ENOMEM);
> +		}
> +		dprintk(PFX "%s: PCI consistent memory for "
> +				"host descriptor rings located @ %p (pa
> = 0x%08lX.) size = %u.\n", 
> +				__FUNCTION__, mem, (unsigned
> long)nesqp->hwqp.sq_pbase,
> +				nesqp->qp_mem_size);
> +        memset(mem,0, nesqp->qp_mem_size);
> +
> +        nesqp->hwqp.sq_vbase = mem;
> +		nesqp->hwqp.sq_size = sq_size;
> +		nesqp->hwqp.sq_encoded_size = sq_encoded_size;
> +        nesqp->hwqp.sq_head = 1;
> +		mem += sizeof(struct nes_hw_qp_wqe)*sq_size;
> +
> +		nesqp->hwqp.rq_vbase = mem;
> +		nesqp->hwqp.rq_size = rq_size;
> +		nesqp->hwqp.rq_encoded_size = rq_encoded_size;
> +		nesqp->hwqp.rq_pbase = nesqp->hwqp.sq_pbase +
> sizeof(struct nes_hw_qp_wqe)*sq_size;
> +		mem += sizeof(struct nes_hw_qp_wqe)*rq_size;
> +
> +		nesqp->hwqp.q2_vbase = mem;
> +		nesqp->hwqp.q2_pbase = nesqp->hwqp.rq_pbase +
> sizeof(struct nes_hw_qp_wqe)*rq_size;
> +		mem += 256;
> +		memset(nesqp->hwqp.q2_vbase, 0, 256);
> +
> +		nesqp->nesqp_context = mem;
> +		nesqp->nesqp_context_pbase = nesqp->hwqp.q2_pbase + 256;
> +		memset(nesqp->nesqp_context, 0,
> sizeof(*nesqp->nesqp_context));
> +
> +		nesqp->hwqp.qp_id = qp_num;
> +		nesqp->ibqp.qp_num = nesqp->hwqp.qp_id;
> +		nesqp->nespd = nespd;
> +
> +		nescq = to_nescq(init_attr->send_cq);
> +		nesqp->nesscq = nescq;
> +		nescq = to_nescq(init_attr->recv_cq);
> +		nesqp->nesrcq = nescq;
> +
> +		/* TODO: account for these things already being filled
> in over in the CM code */
> +		nesqp->nesqp_context->misc |=
> (u32)PCI_FUNC(nesdev->pcidev->devfn) <<
> NES_QPCONTEXT_MISC_PCI_FCN_SHIFT;
> +		nesqp->nesqp_context->misc |=
> (u32)nesqp->hwqp.rq_encoded_size << NES_QPCONTEXT_MISC_RQ_SIZE_SHIFT;
> +		nesqp->nesqp_context->misc |=
> (u32)nesqp->hwqp.sq_encoded_size << NES_QPCONTEXT_MISC_SQ_SIZE_SHIFT;
> +		if (!udata) {
> +			nesqp->nesqp_context->misc |=
> NES_QPCONTEXT_MISC_PRIV_EN;
> +		}
> +		//NES_QPCONTEXT_MISC_IWARP_VER_SHIFT
> +		nesqp->nesqp_context->cqs =
> nesqp->nesscq->hw_cq.cq_number + ((u32)nesqp->nesrcq->hw_cq.cq_number <<
> 16);
> +		u64temp = (u64)nesqp->hwqp.sq_pbase;
> +		nesqp->nesqp_context->sq_addr_low = (u32)u64temp;
> +		nesqp->nesqp_context->sq_addr_high = (u32)(u64temp>>32);
> +		u64temp = (u64)nesqp->hwqp.rq_pbase;
> +		nesqp->nesqp_context->rq_addr_low = (u32)u64temp;
> +		nesqp->nesqp_context->rq_addr_high = (u32)(u64temp>>32);
> +		/* TODO: create a nic index value and a ip index in
> nes_dev */
> +		if (qp_num & 1) {
> +			nesqp->nesqp_context->misc2 |=
> (u32)PCI_FUNC(nesdev->pcidev->devfn+1) <<
> NES_QPCONTEXT_MISC2_NIC_INDEX_SHIFT;
> +		} else {
> +			nesqp->nesqp_context->misc2 |=
> (u32)PCI_FUNC(nesdev->pcidev->devfn) <<
> NES_QPCONTEXT_MISC2_NIC_INDEX_SHIFT;
> +		}
> +		nesqp->nesqp_context->pd_index_wscale |=
> (u32)nesqp->nespd->pd_id << 16;
> +		u64temp = (u64)nesqp->hwqp.q2_pbase;
> +		nesqp->nesqp_context->q2_addr_low = (u32)u64temp;
> +		nesqp->nesqp_context->q2_addr_high = (u32)(u64temp>>32);
> +		*((struct nes_qp
> **)&nesqp->nesqp_context->aeq_token_low) = nesqp;
> +        nesqp->nesqp_context->ird_ord_sizes =
> NES_QPCONTEXT_ORDIRD_ALSMM | 
> +
> ((((u32)nesadapter->max_irrq_wr)<<NES_QPCONTEXT_ORDIRD_IRDSIZE_SHIFT)&NE
> S_QPCONTEXT_ORDIRD_IRDSIZE_MASK);
> +		if (disable_mpa_crc) {
> +			dprintk("%s Disabling MPA crc checking due to
> module option.\n", __FUNCTION__);
> +	        nesqp->nesqp_context->ird_ord_sizes |=
> NES_QPCONTEXT_ORDIRD_RNMC;
> +		}
> +
> +		/* Create the QP */
> +        spin_lock_irqsave(&nesdev->cqp.lock, flags);
> +		cqp_head = nesdev->cqp.sq_head++;
> +		nesdev->cqp.sq_head &= nesdev->cqp.sq_size-1;
> +		cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
> +		cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
> NES_CQP_CREATE_QP | NES_CQP_QP_TYPE_IWARP | NES_CQP_QP_IWARP_STATE_IDLE;
> +		cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] |=
> NES_CQP_QP_CQS_VALID;
> +		cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX] =
> nesqp->hwqp.qp_id;
> +		cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] =  0;
> +		*((struct nes_hw_cqp
> **)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) =  &nesdev->cqp;
> +		cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] =
> cqp_head;
> +		cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] =
> 0;
> +		u64temp = (u64)nesqp->nesqp_context_pbase;
> +		cqp_wqe->wqe_words[NES_CQP_QP_WQE_CONTEXT_LOW_IDX] =
> (u32)u64temp;
> +		cqp_wqe->wqe_words[NES_CQP_QP_WQE_CONTEXT_HIGH_IDX] =
> (u32)(u64temp>>32);
> +
> +		barrier();
> +		// Ring doorbell (1 WQEs)
> +		nes_write32(nesdev->regs+NES_WQE_ALLOC, 0x01800000 |
> nesdev->cqp.qp_id );
> +
> +		/* Wait for CQP */
> +        spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
> +        dprintk("Waiting for create iWARP QP%u to complete.\n",
> nesqp->hwqp.qp_id);
> +        cqp_head = (cqp_head+1)&(nesdev->cqp.sq_size-1);
> +        ret =
> wait_event_timeout(nesdev->cqp.waitq,(nesdev->cqp.sq_tail==cqp_head),
> 2);
> +		dprintk("Create iwarp QP completed, wait_event_timeout
> ret = %u.\n", ret);
> +        /* TODO: Catch error code... */
> +

Catch the error code.

> +		if (ib_pd->uobject) {
> +			uresp.mmap_sq_db_index =
> nesqp->mmap_sq_db_index;
> +			uresp.actual_sq_size = sq_size;
> +			uresp.actual_rq_size = rq_size;
> +			uresp.qp_id = nesqp->hwqp.qp_id;
> +			if (ib_copy_to_udata(udata, &uresp, sizeof
> uresp)) {
> +				/* TODO: Much more clean up to do here
> */
> +	

Do the cleanup.

> 			nes_free_resource(nesadapter,
> nesadapter->allocated_qps, qp_num);
> +				kfree(nesqp->allocated_buffer);
> +				return ERR_PTR(-EFAULT);
> +			}
> +		}
> +
> +
> +		dprintk("%s: QP%u structure located @%p.Size = %u.\n",
> __FUNCTION__, nesqp->hwqp.qp_id,  nesqp, (u32)sizeof(*nesqp));
> +        spin_lock_init(&nesqp->lock);
> +		init_waitqueue_head( &nesqp->state_waitq );
> +		nes_add_ref(&nesqp->ibqp);
> +		nesqp->aewq =
> create_singlethread_workqueue("NesDisconnectWQ");
> +		break;
> +	default:
> +		dprintk("%s: Invalid QP type: %d\n", __FUNCTION__,
> +				init_attr->qp_type);
> +		return ERR_PTR(-EINVAL);
> +		break;
> +	}
> +
> +	/* update the QP table */
> +	nesdev->nesadapter->qp_table[nesqp->hwqp.qp_id-NES_FIRST_QPN] =
> nesqp;
> +	dprintk("%s: netdev refcnt = %u.\n", __FUNCTION__,
> atomic_read(&nesdev->netdev->refcnt));
> +
> +	return &nesqp->ibqp;
> +}
> +
> +
> +/**
> + * nes_destroy_qp
> + * 
> + * @param ib_qp
> + * 
> + * @return int
> + */
> +static int nes_destroy_qp(struct ib_qp *ib_qp)
> +{
> +	u64 u64temp;
> +	struct nes_qp *nesqp = to_nesqp(ib_qp);
> +	struct nes_dev *nesdev = to_nesdev(ib_qp->device);
> +	struct nes_adapter *nesadapter = nesdev->nesadapter;
> +	struct nes_hw_cqp_wqe *cqp_wqe;
> +	struct nes_ucontext *nes_ucontext;
> +	struct ib_qp_attr attr;
> +	unsigned long flags;
> +	int ret;
> +	u32 cqp_head;
> +
> +	dprintk("%s:%s:%u: Destroying QP%u\n", __FILE__, __FUNCTION__,
> __LINE__, nesqp->hwqp.qp_id);
> +	dprintk("%s: netdev refcnt = %u.\n", __FUNCTION__,
> atomic_read(&nesdev->netdev->refcnt));
> +
> +	/* Blow away the connection if it exists. */
> +	if (nesqp->cm_id && nesqp->cm_id->provider_data) {
> +		/* TODO: Probably want to use error as the state */
> +		attr.qp_state = IB_QPS_SQD;
> +		nes_modify_qp(&nesqp->ibqp, &attr, IB_QP_STATE );
> +	}
> +
> +	destroy_workqueue(nesqp->aewq);
> +	/* TODO: Add checks... MW bound count, others ? */
> +
> +	/* Destroy the QP */
> +    spin_lock_irqsave(&nesdev->cqp.lock, flags);
> +	cqp_head = nesdev->cqp.sq_head++;
> +	nesdev->cqp.sq_head &= nesdev->cqp.sq_size-1;
> +	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
> +	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
> cpu_to_le32(NES_CQP_DESTROY_QP | NES_CQP_QP_TYPE_IWARP);
> +	cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX] =
> cpu_to_le32(nesqp->hwqp.qp_id);
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] =  0;
> +	*((struct nes_hw_cqp
> **)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) =  &nesdev->cqp;
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] =
> cqp_head;
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] =  0;
> +	u64temp = (u64)nesqp->nesqp_context_pbase;
> +	cqp_wqe->wqe_words[NES_CQP_QP_WQE_CONTEXT_LOW_IDX] =
> cpu_to_le32((u32)u64temp);
> +	cqp_wqe->wqe_words[NES_CQP_QP_WQE_CONTEXT_HIGH_IDX] =
> cpu_to_le32((u32)(u64temp>>32));
> +
> +	barrier();
> +	// Ring doorbell (1 WQEs)
> +    nes_write32(nesdev->regs+NES_WQE_ALLOC, 0x01800000 |
> nesdev->cqp.qp_id );
> +    spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
> +
> +	/* Wait for CQP */
> +	dprintk("Waiting for destroy iWARP QP%u to complete.\n",
> nesqp->hwqp.qp_id);
> +    cqp_head = (cqp_head+1)&(nesdev->cqp.sq_size-1);
> +    ret =
> wait_event_timeout(nesdev->cqp.waitq,(nesdev->cqp.sq_tail==cqp_head),
> 2);
> +	dprintk("Destroy iwarp QP completed, wait_event_timeout ret =
> %u.\n", ret);
> +
> +    /* TODO: Catch error cases */
> +

Catch error cases.

> +	if (nesqp->user_mode) {
> +		if ((ib_qp->uobject)&&(ib_qp->uobject->context)) {
> +			nes_ucontext =
> to_nesucontext(ib_qp->uobject->context);
> +			clear_bit(nesqp->mmap_sq_db_index,
> nes_ucontext->allocated_wqs);
> +
> nes_ucontext->mmap_nesqp[nesqp->mmap_sq_db_index] = NULL;
> +			if (nes_ucontext->first_free_wq >
> nesqp->mmap_sq_db_index) {
> +				nes_ucontext->first_free_wq =
> nesqp->mmap_sq_db_index;
> +			}
> +		}
> +	}
> +	// Free the control structures
> +	pci_free_consistent(nesdev->pcidev, nesqp->qp_mem_size,
> nesqp->hwqp.sq_vbase,
> +						nesqp->hwqp.sq_pbase);
> +
> +	nesadapter->qp_table[nesqp->hwqp.qp_id-NES_FIRST_QPN] = NULL;
> +	nes_free_resource(nesadapter, nesadapter->allocated_qps,
> nesqp->hwqp.qp_id);
> +
> +	nes_rem_ref(&nesqp->ibqp);
> +	dprintk("%s: netdev refcnt = %u.\n", __FUNCTION__,
> atomic_read(&nesdev->netdev->refcnt));
> +	return 0;
> +}
> +
> +
> +/**
> + * nes_create_cq
> + * 
> + * @param ibdev
> + * @param entries
> + * @param context
> + * @param udata
> + * 
> + * @return struct ib_cq*
> + */
> +static struct ib_cq *nes_create_cq(struct ib_device *ibdev, int
> entries,
> +
> struct ib_ucontext *context,
> +
> struct ib_udata *udata) {
> +	u64 u64temp;
> +	struct nes_dev *nesdev = to_nesdev(ibdev);
> +	struct nes_adapter *nesadapter = nesdev->nesadapter;
> +	struct nes_cq *nescq;
> +	struct nes_ucontext *nes_ucontext = NULL;
> +	void *mem;
> +	struct nes_hw_cqp_wqe *cqp_wqe;
> +	struct nes_pbl *nespbl = NULL;
> +	struct nes_create_cq_req req;
> +	struct nes_create_cq_resp resp;
> +	u32 cqp_head;
> +	u32 cq_num= 0;
> +	u32 pbl_entries = 1;
> +	int err = -ENOSYS;
> +    unsigned long flags;
> +    int ret;
> +
> +    dprintk("%s:%s:%u: entries = %u\n", __FILE__, __FUNCTION__,
> __LINE__, entries);
> +	dprintk("%s: netdev refcnt = %u.\n", __FUNCTION__,
> atomic_read(&nesdev->netdev->refcnt));
> +
> +	err = nes_alloc_resource(nesadapter, nesadapter->allocated_cqs,
> nesadapter->max_cq, &cq_num, &nesadapter->next_cq);
> +	if (err) {
> +		return ERR_PTR(err);
> +	}
> +
> +	nescq = kmalloc(sizeof(*nescq), GFP_KERNEL);
> +	if (!nescq) {
> +		dprintk("%s: Unable to allocate CQ\n", __FUNCTION__);
> +		return ERR_PTR(-ENOMEM);
> +	}
> +
> +	memset(nescq, 0, sizeof *nescq);

kzalloc()

> +	nescq->hw_cq.cq_size = max(entries+1,5);  /* four usable entries
> seems like a reasonable min */
> +	nescq->hw_cq.cq_number = cq_num;
> +    nescq->ibcq.cqe = nescq->hw_cq.cq_size - 1;
> +
> +	if (context) {
> +		nes_ucontext = to_nesucontext(context);
> +		if (ib_copy_from_udata(&req, udata, sizeof(req)))
> +			return ERR_PTR(-EFAULT);
> +		dprintk("%s: CQ Virtual Address = %08lX, size = %u.\n", 
> +				__FUNCTION__, (unsigned
> long)req.user_cq_buffer, entries);
> +		list_for_each_entry(nespbl,
> &nes_ucontext->cq_reg_mem_list, list) {
> +			if (nespbl->user_base == (unsigned long
> )req.user_cq_buffer) {
> +				list_del(&nespbl->list);
> +				err = 0;
> +				dprintk("%s: Found PBL for virtual CQ.
> nespbl=%p.\n", __FUNCTION__, nespbl);
> +				break;
> +			}
> +		}
> +		if (err) {
> +			nes_free_resource(nesadapter,
> nesadapter->allocated_cqs, cq_num);
> +			kfree(nescq);
> +			return ERR_PTR(err);
> +		}
> +		pbl_entries = nespbl->pbl_size >> 3;
> +		nescq->cq_mem_size = 0;
> +	} else {
> +		nescq->cq_mem_size = nescq->hw_cq.cq_size *
> sizeof(struct nes_hw_cqe);
> +		dprintk("%s: Attempting to allocate pci memory (%u
> entries, %u bytes) for CQ%u.\n", 
> +				__FUNCTION__, entries,
> nescq->cq_mem_size, nescq->hw_cq.cq_number);
> +
> +		/* allocate the physical buffer space */
> +		/* TODO: look into how to allocate this memory to be
> used for user space */
> +		mem = pci_alloc_consistent(nesdev->pcidev,
> nescq->cq_mem_size,
> +
> &nescq->hw_cq.cq_pbase);
> +		if (!mem) {
> +			nes_free_resource(nesadapter,
> nesadapter->allocated_cqs, cq_num);
> +			dprintk(KERN_ERR PFX "Unable to allocate pci
> memory for cq\n");
> +			return ERR_PTR(-ENOMEM);
> +		}
> +
> +		memset(mem, 0, nescq->cq_mem_size);
> +		nescq->hw_cq.cq_vbase = mem;
> +		nescq->hw_cq.cq_head = 0;
> +		dprintk("%s: CQ%u virtual address @ %p, phys = 0x%08X
> .\n", 
> +				__FUNCTION__, nescq->hw_cq.cq_number,
> nescq->hw_cq.cq_vbase, (u32)nescq->hw_cq.cq_pbase);
> +	}
> +
> +	nescq->hw_cq.ce_handler = iwarp_ce_handler;
> +	spin_lock_init(&nescq->lock);
> +
> +	/* Send CreateCQ request to CQP */
> +    spin_lock_irqsave(&nesdev->cqp.lock, flags);
> +	cqp_head = nesdev->cqp.sq_head++;
> +	nesdev->cqp.sq_head &= nesdev->cqp.sq_size-1;
> +	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
> +
> +	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =  NES_CQP_CREATE_CQ
> | NES_CQP_CQ_CEQ_VALID | 
> +
> NES_CQP_CQ_CEQE_MASK |(nescq->hw_cq.cq_size<<16);
> +	if (1 != pbl_entries) {
> +		if (0 == nesadapter->free_256pbl) {
> +			/* TODO: need to backout */
> +			spin_unlock_irqrestore(&nesdev->cqp.lock,
> flags);
> +			nes_free_resource(nesadapter,
> nesadapter->allocated_cqs, cq_num);
> +			kfree(nescq);
> +			return ERR_PTR(-ENOMEM);
> +		} else {
> +			cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] |=
> NES_CQP_CQ_VIRT;
> +			nescq->virtual_cq = 1;
> +			nesadapter->free_256pbl--;
> +		}
> +	}
> +
> +	/* TODO: Separate iWARP from to its own CEQ? */
> +	cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX] =  nescq->hw_cq.cq_number
> | ((u32)PCI_FUNC(nesdev->pcidev->devfn)<<16);
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] =  0;
> +	*((struct nes_hw_cqp
> **)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) =  &nesdev->cqp;
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] =
> cqp_head;
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] =  0;
> +	if (context) {
> +		if (1 != pbl_entries)
> +			u64temp = (u64)nespbl->pbl_pbase;
> +		else
> +			u64temp	= nespbl->pbl_vbase[0];
> +
> cqp_wqe->wqe_words[NES_CQP_CQ_WQE_DOORBELL_INDEX_HIGH_IDX] =
> nes_ucontext->mmap_db_index[0];
> +	} else {
> +		u64temp = (u64)nescq->hw_cq.cq_pbase;
> +
> cqp_wqe->wqe_words[NES_CQP_CQ_WQE_DOORBELL_INDEX_HIGH_IDX] =  0;
> +	}
> +	cqp_wqe->wqe_words[NES_CQP_CQ_WQE_PBL_LOW_IDX] = (u32)u64temp;
> +	cqp_wqe->wqe_words[NES_CQP_CQ_WQE_PBL_HIGH_IDX] =
> (u32)(u64temp>>32);
> +	cqp_wqe->wqe_words[NES_CQP_CQ_WQE_CQ_CONTEXT_HIGH_IDX] =  0;
> +	*((struct nes_hw_cq
> **)&cqp_wqe->wqe_words[NES_CQP_CQ_WQE_CQ_CONTEXT_LOW_IDX]) =
> &nescq->hw_cq;
> +	*((u64 *)&cqp_wqe->wqe_words[NES_CQP_CQ_WQE_CQ_CONTEXT_LOW_IDX])
> >>= 1;
> +
> +	barrier();
> +	dprintk("%s: CQ%u context = 0x%08X:0x%08X.\n", __FUNCTION__,
> nescq->hw_cq.cq_number, 
> +		cqp_wqe->wqe_words[NES_CQP_CQ_WQE_CQ_CONTEXT_HIGH_IDX], 
> +		cqp_wqe->wqe_words[NES_CQP_CQ_WQE_CQ_CONTEXT_LOW_IDX]);
> +
> +	// Ring doorbell (1 WQEs)
> +	nes_write32(nesdev->regs+NES_WQE_ALLOC, 0x01800000 |
> nesdev->cqp.qp_id );
> +
> +	/* Wait for CQP */
> +    spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
> +    dprintk("Waiting for create iWARP CQ%u to complete.\n",
> nescq->hw_cq.cq_number);
> +    cqp_head = (cqp_head+1)&(nesdev->cqp.sq_size-1);
> +    ret =
> wait_event_timeout(nesdev->cqp.waitq,(nesdev->cqp.sq_tail==cqp_head),
> 2);
> +	dprintk("Create iwarp CQ completed, wait_event_timeout ret =
> %d.\n", ret);
> +    /* TODO: Catch error cases */
> +

Catch error cases.

> +	if (context) {
> +		/* free the nespbl */
> +		pci_free_consistent(nesdev->pcidev, nespbl->pbl_size, 
> +
> nespbl->pbl_vbase, nespbl->pbl_pbase);
> +		kfree(nespbl);
> +		/* write back the parameters */
> +		resp.cq_id = nescq->hw_cq.cq_number;
> +		resp.cq_size = nescq->hw_cq.cq_size;
> +		resp.mmap_db_index = 0;
> +		if (ib_copy_to_udata(udata, &resp, sizeof resp)) {
> +			nes_free_resource(nesadapter,
> nesadapter->allocated_cqs, cq_num);
> +			kfree(nescq);
> +			return ERR_PTR(-EFAULT);
> +		}
> +	}
> +
> +	dprintk("%s: netdev refcnt = %u.\n", __FUNCTION__,
> atomic_read(&nesdev->netdev->refcnt));
> +	return &nescq->ibcq;
> +}
> +
> +
> +/**
> + * nes_destroy_cq
> + * 
> + * @param ib_cq
> + * 
> + * @return int
> + */
> +static int nes_destroy_cq(struct ib_cq *ib_cq)
> +{
> +	struct nes_cq *nescq;
> +	struct nes_dev *nesdev;
> +	struct nes_adapter *nesadapter;
> +	struct nes_hw_cqp_wqe *cqp_wqe;
> +	u32 cqp_head;
> +    unsigned long flags;
> +    int ret;
> +
> +	dprintk("%s:%s:%u: %p.\n", __FILE__, __FUNCTION__, __LINE__,
> ib_cq);
> +
> +	if (ib_cq  == NULL)
> +		return 0;
> +
> +	nescq = to_nescq(ib_cq);
> +	nesdev = to_nesdev(ib_cq->device);
> +	nesadapter = nesdev->nesadapter;
> +	dprintk("%s: netdev refcnt = %u.\n", __FUNCTION__,
> atomic_read(&nesdev->netdev->refcnt));
> +
> +	/* Send DestroyCQ request to CQP */
> +    spin_lock_irqsave(&nesdev->cqp.lock, flags);
> +	if (nescq->virtual_cq) {
> +		nesadapter->free_256pbl++;
> +		if (nesadapter->free_256pbl > nesadapter->max_256pbl) {
> +			printk(KERN_ERR PFX "%s: free 256B PBLs(%u) has
> exceeded the max(%u)\n", 
> +				   __FUNCTION__,
> nesadapter->free_256pbl, nesadapter->max_256pbl);
> +		}
> +	}
> +	cqp_head = nesdev->cqp.sq_head++;
> +	nesdev->cqp.sq_head &= nesdev->cqp.sq_size-1;
> +	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
> +
> +	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =  NES_CQP_DESTROY_CQ
> | (nescq->hw_cq.cq_size<<16);
> +	cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX] =  nescq->hw_cq.cq_number
> | ((u32)PCI_FUNC(nesdev->pcidev->devfn)<<16);
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] =  0;
> +	*((struct nes_hw_cqp
> **)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) =  &nesdev->cqp;
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] =
> cqp_head;
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] =  0;
> +
> +	barrier();
> +	// Ring doorbell (1 WQEs)
> +	nes_write32(nesdev->regs+NES_WQE_ALLOC, 0x01800000 |
> nesdev->cqp.qp_id );
> +
> +	/* Wait for CQP */
> +    spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
> +    dprintk("Waiting for destroy iWARP CQ%u to complete.\n",
> nescq->hw_cq.cq_number);
> +    cqp_head = (cqp_head+1)&(nesdev->cqp.sq_size-1);
> +    ret =
> wait_event_timeout(nesdev->cqp.waitq,(nesdev->cqp.sq_tail==cqp_head),
> 2);
> +	dprintk("Destroy iwarp CQ completed, wait_event_timeout ret =
> %u.\n", ret);
> +    /* TODO: catch CQP error cases */
> +

Catch error cases.

> +	if (nescq->cq_mem_size)
> +		pci_free_consistent(nesdev->pcidev, nescq->cq_mem_size,
> (void *)nescq->hw_cq.cq_vbase,
> +
> nescq->hw_cq.cq_pbase);
> +	nes_free_resource(nesadapter, nesadapter->allocated_cqs,
> nescq->hw_cq.cq_number);
> +	kfree(nescq);
> +
> +	dprintk("%s: netdev refcnt = %u.\n", __FUNCTION__,
> atomic_read(&nesdev->netdev->refcnt));
> +	return 0;
> +}
> +
> +
> +/**
> + * nes_reg_mr
> + * 
> + * @param nesdev
> + * @param nespd
> + * @param stag
> + * @param region_length
> + * @param root_vpbl
> + * @param single_buffer
> + * @param pbl_count
> + * @param residual_page_count
> + * @param acc
> + * @param iova_start
> + * 
> + * @return int
> + */
> +static int nes_reg_mr(struct nes_dev *nesdev,
> +					   struct nes_pd *nespd, 
> +					   u32 stag,
> +					   u64 region_length,
> +					   struct nes_root_vpbl
> *root_vpbl,
> +					   dma_addr_t single_buffer,
> +					   u16 pbl_count,
> +					   u16 residual_page_count,
> +					   int acc,
> +					   u64 * iova_start) 
> +{
> +	struct nes_hw_cqp_wqe *cqp_wqe;
> +	unsigned long flags;
> +	u32 cqp_head;
> +	int ret;
> +	struct nes_adapter *nesadapter = nesdev->nesadapter;
> +//	int count;
> +
> +	/* Register the region with the adapter */
> +	spin_lock_irqsave(&nesdev->cqp.lock, flags);
> +
> +	/* track PBL resources */
> +	if (pbl_count != 0) {
> +		if (pbl_count > 1) {
> +			/* Two level PBL */
> +			if ((pbl_count+1) > nesadapter->free_4kpbl) {
> +
> spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
> +				return (-ENOMEM);
> +			} else {
> +				nesadapter->free_4kpbl -= pbl_count+1;
> +			}
> +		} else if (residual_page_count > 32) {
> +			if (pbl_count > nesadapter->free_4kpbl) {
> +
> spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
> +				return -ENOMEM;
> +			} else {
> +				nesadapter->free_4kpbl -= pbl_count;
> +			}
> +		} else {
> +			if (pbl_count > nesadapter->free_256pbl) {
> +
> spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
> +				return -ENOMEM;
> +			} else {
> +				nesadapter->free_256pbl -= pbl_count;
> +			}
> +		}
> +	}
> +	cqp_head = nesdev->cqp.sq_head++;
> +	nesdev->cqp.sq_head &= nesdev->cqp.sq_size-1;
> +	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
> +	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
> NES_CQP_REGISTER_STAG | NES_CQP_STAG_RIGHTS_LOCAL_READ;
> +	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] |=
> NES_CQP_STAG_VA_TO | NES_CQP_STAG_MR;
> +	if (acc & IB_ACCESS_LOCAL_WRITE) {
> +		cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] |=
> NES_CQP_STAG_RIGHTS_LOCAL_WRITE;
> +	}
> +	if (acc & IB_ACCESS_REMOTE_WRITE) {
> +		cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] |=
> NES_CQP_STAG_RIGHTS_REMOTE_WRITE | NES_CQP_STAG_REM_ACC_EN;
> +	}
> +	if (acc & IB_ACCESS_REMOTE_READ) {
> +		cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] |=
> NES_CQP_STAG_RIGHTS_REMOTE_READ | NES_CQP_STAG_REM_ACC_EN;
> +	}
> +	if (acc & IB_ACCESS_MW_BIND) {
> +		cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] |=
> NES_CQP_STAG_RIGHTS_WINDOW_BIND | NES_CQP_STAG_REM_ACC_EN;
> +	}
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] =  0;
> +	*((struct nes_hw_cqp
> **)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) =  &nesdev->cqp;
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] =
> cqp_head;
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] =  0;
> +	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_VA_LOW_IDX] =
> cpu_to_le32((u32)*iova_start);
> +	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_VA_HIGH_IDX] =
> cpu_to_le32((u32)((((u64)*iova_start)>>32)));
> +	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_LEN_LOW_IDX] =
> cpu_to_le32((u32)region_length);
> +	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_LEN_HIGH_PD_IDX] =
> cpu_to_le32((u32)(region_length>>8)&0xff000000);
> +	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_LEN_HIGH_PD_IDX] |=
> cpu_to_le32(nespd->pd_id&0x00007fff);
> +	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_STAG_IDX] =
> cpu_to_le32(stag);
> +
> +	if (pbl_count == 0) {
> +		cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PA_LOW_IDX] =
> cpu_to_le32((u32)single_buffer);
> +		cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PA_HIGH_IDX] =
> cpu_to_le32((u32)((((u64)single_buffer)>>32)));
> +		cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PBL_BLK_COUNT_IDX] =
> 0;
> +		cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PBL_LEN_IDX] =  0;
> +	} else {
> +		cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PA_LOW_IDX] =
> cpu_to_le32((u32)root_vpbl->pbl_pbase);
> +		cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PA_HIGH_IDX] =
> cpu_to_le32((u32)((((u64)root_vpbl->pbl_pbase)>>32)));
> +		cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PBL_BLK_COUNT_IDX] =
> cpu_to_le32(pbl_count);
> +		cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PBL_LEN_IDX] =
> cpu_to_le32(((pbl_count-1)*4096)+(residual_page_count*8));
> +		if ((pbl_count > 1)||(residual_page_count > 32)) {
> +			cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] |=
> NES_CQP_STAG_PBL_BLK_SIZE;
> +		}
> +	}
> +	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
> cpu_to_le32(cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX]);
> +
> +	barrier();
> +
> +	// Ring doorbell (1 WQEs)
> +	nes_write32(nesdev->regs+NES_WQE_ALLOC, 0x01800000 |
> nesdev->cqp.qp_id );
> +
> +	/* Wait for CQP */
> +	spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
> +
> +	cqp_head = (cqp_head+1)&(nesdev->cqp.sq_size-1);
> +	ret =
> wait_event_timeout(nesdev->cqp.waitq,(nesdev->cqp.sq_tail==cqp_head),
> 2);
> +	dprintk("%s: Register STag 0x%08X completed, wait_event_timeout
> ret = %u.\n", __FUNCTION__, stag, ret);
> +	/* TODO: Catch error code... */
> +
> +	return 0;
> +}
> +
> +
> +/**
> + * nes_reg_phys_mr
> + * 
> + * @param ib_pd
> + * @param buffer_list
> + * @param num_phys_buf
> + * @param acc
> + * @param iova_start
> + * 
> + * @return struct ib_mr*
> + */
> +static struct ib_mr *nes_reg_phys_mr(struct ib_pd *ib_pd,
> +
> struct ib_phys_buf *buffer_list,
> +
> int num_phys_buf, int acc, u64 * iova_start) {
> +	u64 region_length;
> +	struct nes_pd *nespd = to_nespd(ib_pd);
> +	struct nes_dev *nesdev = to_nesdev(ib_pd->device);
> +	struct nes_adapter *nesadapter = nesdev->nesadapter;
> +	struct nes_mr *nesmr;
> +	struct ib_mr *ibmr;
> +	struct nes_vpbl vpbl;
> +	struct nes_root_vpbl root_vpbl;
> +	u32 stag;
> +	u32 i; 
> +	u32 stag_index = 0;
> +	u32 next_stag_index = 0;
> +	u32 driver_key = 0;
> +	u32 root_pbl_index = 0;
> +	u32 cur_pbl_index = 0;
> +	int err = 0, pbl_depth = 0;
> +    int ret = 0;
> +	u16 pbl_count = 0;
> +	u8 single_page = 1;
> +	u8 stag_key = 0;
> +
> +	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +
> +	pbl_depth = 0;
> +	region_length = 0;
> +	vpbl.pbl_vbase = NULL;
> +	root_vpbl.pbl_vbase = NULL;
> +	root_vpbl.pbl_pbase = 0;
> +
> +	get_random_bytes(&next_stag_index, sizeof(next_stag_index));
> +	stag_key = (u8)next_stag_index;
> +
> +	driver_key = 0;
> +
> +	next_stag_index >>= 8;
> +	next_stag_index %= nesadapter->max_mr;
> +	if (num_phys_buf > (1024*512)){
> +		return ERR_PTR(-E2BIG);
> +	}
> +
> +	err = nes_alloc_resource(nesadapter, nesadapter->allocated_mrs,
> nesadapter->max_mr, &stag_index, &next_stag_index);
> +	if (err) {
> +		return ERR_PTR(err);
> +	}
> +
> +	nesmr = kmalloc(sizeof(*nesmr), GFP_KERNEL);
> +	if (!nesmr) {
> +		nes_free_resource(nesadapter, nesadapter->allocated_mrs,
> stag_index);
> +		return ERR_PTR(-ENOMEM);
> +	}
> +
> +	for (i = 0; i < num_phys_buf; i++) {
> +
> +		if ((i & 0x01FF) == 0)  {
> +			if (1 == root_pbl_index) {
> +				/* Allocate the root PBL */
> +				root_vpbl.pbl_vbase =
> pci_alloc_consistent(nesdev->pcidev, 8192,
> +
> &root_vpbl.pbl_pbase);
> +				dprintk("%s: Allocating root PBL, va =
> %p, pa = 0x%08X\n", 
> +						__FUNCTION__,
> root_vpbl.pbl_vbase, (unsigned int)root_vpbl.pbl_pbase);
> +				if (!root_vpbl.pbl_vbase) {
> +
> pci_free_consistent(nesdev->pcidev, 4096, vpbl.pbl_vbase,
> +
> vpbl.pbl_pbase);
> +					nes_free_resource(nesadapter,
> nesadapter->allocated_mrs, stag_index);
> +					kfree(nesmr);
> +					return ERR_PTR(-ENOMEM);
> +				}
> +				root_vpbl.leaf_vpbl =
> kmalloc(sizeof(*root_vpbl.leaf_vpbl)*1024, GFP_KERNEL);
> +				if (!root_vpbl.leaf_vpbl) {
> +
> pci_free_consistent(nesdev->pcidev, 8192, root_vpbl.pbl_vbase,
> +
> root_vpbl.pbl_pbase);
> +
> pci_free_consistent(nesdev->pcidev, 4096, vpbl.pbl_vbase,
> +
> vpbl.pbl_pbase);
> +					nes_free_resource(nesadapter,
> nesadapter->allocated_mrs, stag_index);
> +					kfree(nesmr);
> +					return ERR_PTR(-ENOMEM);
> +				}
> +				root_vpbl.pbl_vbase[0].pa_low =
> cpu_to_le32((u32)vpbl.pbl_pbase);
> +				root_vpbl.pbl_vbase[0].pa_high =
> cpu_to_le32((u32)((((u64)vpbl.pbl_pbase)>>32)));
> +				root_vpbl.leaf_vpbl[0] = vpbl;
> +			}
> +			/* Allocate a 4K buffer for the PBL */
> +			vpbl.pbl_vbase =
> pci_alloc_consistent(nesdev->pcidev, 4096,
> +
> &vpbl.pbl_pbase);
> +			dprintk("%s: Allocating leaf PBL, va = %p, pa =
> 0x%016lX\n", 
> +					__FUNCTION__, vpbl.pbl_vbase,
> (unsigned long)vpbl.pbl_pbase);
> +			if (!vpbl.pbl_vbase) {
> +				/* TODO: Unwind allocated buffers */
> +				nes_free_resource(nesadapter,
> nesadapter->allocated_mrs, stag_index);
> +				ibmr = ERR_PTR(-ENOMEM);
> +				kfree(nesmr);
> +				goto reg_phys_err;
> +			}
> +			/* Fill in the root table */
> +			if (1 <= root_pbl_index) {
> +
> root_vpbl.pbl_vbase[root_pbl_index].pa_low =
> cpu_to_le32((u32)vpbl.pbl_pbase);
> +
> root_vpbl.pbl_vbase[root_pbl_index].pa_high =
> cpu_to_le32((u32)((((u64)vpbl.pbl_pbase)>>32)));
> +				root_vpbl.leaf_vpbl[root_pbl_index] =
> vpbl;
> +			}
> +			root_pbl_index++;
> +			cur_pbl_index = 0;
> +		}
> +		if (buffer_list[i].addr & ~PAGE_MASK) {
> +			/* TODO: Unwind allocated buffers */
> +			nes_free_resource(nesadapter,
> nesadapter->allocated_mrs, stag_index);
> +			dprintk("Unaligned Memory Buffer: 0x%x\n",
> +					(unsigned int)
> buffer_list[i].addr);
> +			ibmr = ERR_PTR(-EINVAL);
> +			kfree(nesmr);
> +			goto reg_phys_err;
> +		}
> +
> +		if (!buffer_list[i].size) {
> +			/* TODO: Unwind allocated buffers */
> +			nes_free_resource(nesadapter,
> nesadapter->allocated_mrs, stag_index);
> +			dprintk("Invalid Buffer Size\n");
> +			ibmr = ERR_PTR(-EINVAL);
> +			kfree(nesmr);
> +			goto reg_phys_err;
> +		}
> +
> +		region_length += buffer_list[i].size;
> +		if ((i != 0) && (single_page)) {
> +			if ((buffer_list[i-1].addr+PAGE_SIZE) !=
> buffer_list[i].addr)
> +				single_page = 0;
> +		}
> +		vpbl.pbl_vbase[cur_pbl_index].pa_low =
> cpu_to_le32((u32)buffer_list[i].addr);
> +		vpbl.pbl_vbase[cur_pbl_index++].pa_high =
> cpu_to_le32((u32)((((u64)buffer_list[i].addr)>>32)));
> +	}
> +
> +	stag = stag_index<<8;
> +	stag |= driver_key;
> +	/* TODO: key should come from consumer */
> +	stag += (u32)stag_key;
> +
> +	dprintk("%s: Registering STag 0x%08X, VA = 0x%016lX, length =
> 0x%016lX, index = 0x%08X\n", 
> +			__FUNCTION__, stag, (unsigned long)*iova_start,
> (unsigned long)region_length, stag_index);
> +
> +	/* TODO: Should the region length be reduced by iova_start
> &PAGE_MASK, think so */
> +	region_length -= (*iova_start)&PAGE_MASK;
> +
> +	/* Make the leaf PBL the root if only one PBL */
> +	if (root_pbl_index == 1) {
> +		root_vpbl.pbl_pbase = vpbl.pbl_pbase;
> +	}
> +
> +	if (single_page) {
> +		pbl_count = 0;
> +	} else {
> +		pbl_count = root_pbl_index;
> +	}
> +	ret = nes_reg_mr( nesdev, nespd, stag, region_length,
> &root_vpbl, 
> +					  buffer_list[0].addr,
> pbl_count, (u16)cur_pbl_index, 
> +					  acc, iova_start);
> +
> +	if (ret == 0) {
> +		nesmr->ibmr.rkey = stag;
> +		nesmr->ibmr.lkey = stag;
> +		nesmr->mode = IWNES_MEMREG_TYPE_MEM;
> +		ibmr = &nesmr->ibmr;
> +		nesmr->pbl_4k = ((pbl_count>1)||(cur_pbl_index>32)) ? 1
> : 0;
> +		nesmr->pbls_used = pbl_count;
> +		if (pbl_count > 1) {
> +			nesmr->pbls_used++;
> +		}
> +	} else {
> +		kfree(nesmr);
> +		ibmr = ERR_PTR(-ENOMEM);
> +	}
> +
> +reg_phys_err:
> +	/* free the resources */
> +	if (root_pbl_index == 1) {
> +		/* single PBL case */
> +		pci_free_consistent(nesdev->pcidev, 4096,
> vpbl.pbl_vbase,
> +							vpbl.pbl_pbase);
> +	} else {
> +		for (i=0; i<root_pbl_index; i++) {
> +			pci_free_consistent(nesdev->pcidev, 4096,
> root_vpbl.leaf_vpbl[i].pbl_vbase,
> +
> root_vpbl.leaf_vpbl[i].pbl_pbase);
> +		}
> +		kfree(root_vpbl.leaf_vpbl);
> +		pci_free_consistent(nesdev->pcidev, 8192,
> root_vpbl.pbl_vbase,
> +
> root_vpbl.pbl_pbase);
> +	}
> +
> +	return ibmr;
> +}
> +
> +
> +/**
> + * nes_get_dma_mr
> + * 
> + * @param pd
> + * @param acc
> + * 
> + * @return struct ib_mr*
> + */
> +static struct ib_mr *nes_get_dma_mr(struct ib_pd *pd, int acc) {
> +	struct ib_phys_buf bl;
> +	u64 kva = 0;
> +
> +	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +
> +	bl.size = 0xffffffffff;
> +	bl.addr = 0;
> +	return nes_reg_phys_mr(pd, &bl, 1, acc, &kva);

This doesn't support high addresses.  Chelsio has a similar issue.  I
don't really know what to do about this...


> +}
> +
> +
> +/**
> + * nes_reg_user_mr
> + * 
> + * @param pd
> + * @param region
> + * @param acc
> + * @param udata
> + * 
> + * @return struct ib_mr*
> + */
> +static struct ib_mr *nes_reg_user_mr(struct ib_pd *pd, struct ib_umem
> *region,
> +
> int acc, struct ib_udata *udata)
> +{
> +	u64 iova_start;
> +	u64 *pbl;
> +	u64 region_length;
> +	dma_addr_t last_dma_addr = 0;
> +	dma_addr_t first_dma_addr = 0;
> +	struct nes_pd *nespd = to_nespd(pd);
> +	struct nes_dev *nesdev = to_nesdev(pd->device);
> +	struct nes_adapter *nesadapter = nesdev->nesadapter;
> +	struct ib_mr *ibmr;
> +	struct ib_umem_chunk *chunk;
> +	struct nes_ucontext *nes_ucontext;
> +	struct nes_pbl *nespbl;
> +	struct nes_mr *nesmr;
> +	struct nes_mem_reg_req req;
> +	struct nes_vpbl vpbl;
> +	struct nes_root_vpbl root_vpbl;
> +	int j;
> +	int page_count = 0;
> +	int err, pbl_depth = 0;
> +	int ret;
> +	u32 stag;
> +	u32 stag_index = 0;
> +	u32 next_stag_index;
> +	u32 driver_key;
> +	u32 root_pbl_index = 0;
> +	u32 cur_pbl_index = 0;
> +	u16 pbl_count;
> +	u8 single_page = 1;
> +	u8 stag_key;
> +
> +	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +
> +	dprintk("%s: User base = 0x%lX, Virt base = 0x%lX, length = %u,
> offset = %u, page size = %u.\n",  
> +			__FUNCTION__, region->user_base,
> region->virt_base, (u32)region->length, region->offset,
> region->page_size);
> +
> +	if (ib_copy_from_udata(&req, udata, sizeof(req)))
> +		return ERR_PTR(-EFAULT);
> +	dprintk("%s: Memory Registration type = %08X.\n", __FUNCTION__,
> req.reg_type);
> +
> +	switch (req.reg_type) {
> +		case IWNES_MEMREG_TYPE_MEM:
> +			pbl_depth = 0;
> +			region_length = 0;
> +			vpbl.pbl_vbase = NULL;
> +			root_vpbl.pbl_vbase = NULL;
> +			root_vpbl.pbl_pbase = 0;
> +
> +			get_random_bytes(&next_stag_index,
> sizeof(next_stag_index));
> +			stag_key = (u8)next_stag_index;
> +
> +			driver_key = 0;
> +
> +			next_stag_index >>= 8;
> +			next_stag_index %= nesadapter->max_mr;
> +
> +			err = nes_alloc_resource(nesadapter,
> nesadapter->allocated_mrs, nesadapter->max_mr, &stag_index,
> &next_stag_index);
> +			if (err) {
> +				return ERR_PTR(err);
> +			}
> +
> +			nesmr = kmalloc(sizeof(*nesmr), GFP_KERNEL);
> +			if (!nesmr) {
> +				nes_free_resource(nesadapter,
> nesadapter->allocated_mrs, stag_index);
> +				return ERR_PTR(-ENOMEM);
> +			}
> +
> +			/* todo: make this code and reg_phy_mr loop more
> common!!! */
> +			list_for_each_entry(chunk, &region->chunk_list,
> list) {
> +				dprintk("%s: Chunk: nents = %u, nmap =
> %u .\n", __FUNCTION__, chunk->nents, chunk->nmap );
> +				for (j = 0; j < chunk->nmap; ++j) {
> +					dprintk("%s: \tsg_dma_addr =
> 0x%08lx, length = %u.\n", 
> +							__FUNCTION__,
> (unsigned long)sg_dma_address(&chunk->page_list[j]),
> sg_dma_len(&chunk->page_list[j]) );
> +
> +					if ((page_count&0x01FF) == 0) {
> +						if
> (page_count>(1024*512)) {
> +
> pci_free_consistent(nesdev->pcidev, 4096, vpbl.pbl_vbase,
> +
> vpbl.pbl_pbase);
> +
> nes_free_resource(nesadapter, nesadapter->allocated_mrs, stag_index);
> +							kfree(nesmr);
> +							return
> ERR_PTR(-E2BIG);
> +						}
> +						if (1 == root_pbl_index)
> {
> +
> root_vpbl.pbl_vbase = pci_alloc_consistent(nesdev->pcidev, 8192,
> +
> &root_vpbl.pbl_pbase);
> +							dprintk("%s:
> Allocating root PBL, va = %p, pa = 0x%08X\n", 
> +
> __FUNCTION__, root_vpbl.pbl_vbase, (unsigned int)root_vpbl.pbl_pbase);
> +							if
> (!root_vpbl.pbl_vbase) {
> +
> pci_free_consistent(nesdev->pcidev, 4096, vpbl.pbl_vbase,
> +
> vpbl.pbl_pbase);
> +
> nes_free_resource(nesadapter, nesadapter->allocated_mrs, stag_index);
> +
> kfree(nesmr);
> +								return
> ERR_PTR(-ENOMEM);
> +							}
> +
> root_vpbl.leaf_vpbl = kmalloc(sizeof(*root_vpbl.leaf_vpbl)*1024,
> GFP_KERNEL);
> +							if
> (!root_vpbl.leaf_vpbl) {
> +
> pci_free_consistent(nesdev->pcidev, 8192, root_vpbl.pbl_vbase,
> +
> root_vpbl.pbl_pbase);
> +
> pci_free_consistent(nesdev->pcidev, 4096, vpbl.pbl_vbase,
> +
> vpbl.pbl_pbase);
> +
> nes_free_resource(nesadapter, nesadapter->allocated_mrs, stag_index);
> +
> kfree(nesmr);
> +								return
> ERR_PTR(-ENOMEM);
> +							}
> +
> root_vpbl.pbl_vbase[0].pa_low = cpu_to_le32((u32)vpbl.pbl_pbase);
> +
> root_vpbl.pbl_vbase[0].pa_high =
> cpu_to_le32((u32)((((u64)vpbl.pbl_pbase)>>32)));
> +
> root_vpbl.leaf_vpbl[0] = vpbl;
> +						}
> +						vpbl.pbl_vbase =
> pci_alloc_consistent(nesdev->pcidev, 4096,
> +
> &vpbl.pbl_pbase);
> +						dprintk("%s: Allocating
> leaf PBL, va = %p, pa = 0x%08X\n", 
> +
> __FUNCTION__, vpbl.pbl_vbase, (unsigned int)vpbl.pbl_pbase);
> +						if (!vpbl.pbl_vbase) {
> +
> nes_free_resource(nesadapter, nesadapter->allocated_mrs, stag_index);
> +							ibmr =
> ERR_PTR(-ENOMEM);
> +							kfree(nesmr);
> +							goto
> reg_user_mr_err;
> +						}
> +						if (1 <= root_pbl_index)
> {
> +
> root_vpbl.pbl_vbase[root_pbl_index].pa_low =
> cpu_to_le32((u32)vpbl.pbl_pbase);
> +
> root_vpbl.pbl_vbase[root_pbl_index].pa_high =
> cpu_to_le32((u32)((((u64)vpbl.pbl_pbase)>>32)));
> +
> root_vpbl.leaf_vpbl[root_pbl_index] = vpbl;
> +						}
> +						root_pbl_index++;
> +						cur_pbl_index = 0;
> +					}
> +					if
> (sg_dma_address(&chunk->page_list[j]) & ~PAGE_MASK) {
> +
> nes_free_resource(nesadapter, nesadapter->allocated_mrs, stag_index);
> +						dprintk("%s: Unaligned
> Memory Buffer: 0x%x\n", __FUNCTION__,
> +
> (unsigned int) sg_dma_address(&chunk->page_list[j]));
> +						ibmr = ERR_PTR(-EINVAL);
> +						kfree(nesmr);
> +						goto reg_user_mr_err;
> +					}
> +
> +					if
> (!sg_dma_len(&chunk->page_list[j])) {
> +
> nes_free_resource(nesadapter, nesadapter->allocated_mrs, stag_index);
> +						dprintk("%s: Invalid
> Buffer Size\n", __FUNCTION__);
> +						ibmr = ERR_PTR(-EINVAL);
> +						kfree(nesmr);
> +						goto reg_user_mr_err;
> +					}
> +
> +					region_length +=
> sg_dma_len(&chunk->page_list[j]);
> +					if (single_page) {
> +						if (page_count != 0) {
> +							if
> ((last_dma_addr+PAGE_SIZE) != sg_dma_address(&chunk->page_list[j]))
> +
> single_page = 0;
> +							last_dma_addr =
> sg_dma_address(&chunk->page_list[j]);
> +						} else {
> +							first_dma_addr =
> sg_dma_address(&chunk->page_list[j]);
> +							last_dma_addr =
> first_dma_addr;
> +						}
> +					}
> +
> +
> vpbl.pbl_vbase[cur_pbl_index].pa_low =
> cpu_to_le32((u32)sg_dma_address(&chunk->page_list[j]));
> +
> vpbl.pbl_vbase[cur_pbl_index].pa_high =
> cpu_to_le32((u32)((((u64)sg_dma_address(&chunk->page_list[j]))>>32)));
> +					dprintk("%s: PBL %u (@%p) =
> 0x%08X:%08X\n", __FUNCTION__, cur_pbl_index, 
> +
> &vpbl.pbl_vbase[cur_pbl_index], vpbl.pbl_vbase[cur_pbl_index].pa_high, 
> +
> vpbl.pbl_vbase[cur_pbl_index].pa_low);
> +					cur_pbl_index++;
> +					page_count++;
> +				}
> +			}
> +			stag = stag_index<<8;
> +			stag |= driver_key;
> +			/* TODO: key should come from consumer */
> +			stag += (u32)stag_key;
> +
> +			iova_start = (u64)region->virt_base;
> +			dprintk("%s: Registering STag 0x%08X, VA =
> 0x%08X, length = 0x%08X, index = 0x%08X, region->length=0x%08x\n", 
> +					__FUNCTION__, stag, (unsigned
> int)iova_start, (unsigned int)region_length, stag_index,
> region->length);
> +
> +
> +			/* Make the leaf PBL the root if only one PBL */
> +			if (root_pbl_index == 1) {
> +				root_vpbl.pbl_pbase = vpbl.pbl_pbase;
> +			}
> +
> +			if (single_page) {
> +				pbl_count = 0;
> +			} else {
> +				pbl_count = root_pbl_index;
> +				first_dma_addr = 0;
> +			}
> +			ret = nes_reg_mr( nesdev, nespd, stag,
> region->length, &root_vpbl, 
> +
> first_dma_addr, pbl_count, (u16)cur_pbl_index, 
> +							  acc,
> &iova_start);
> +	
> +			if (ret == 0) {
> +				nesmr->ibmr.rkey = stag;
> +				nesmr->ibmr.lkey = stag;
> +				nesmr->mode = IWNES_MEMREG_TYPE_MEM;
> +				ibmr = &nesmr->ibmr;
> +				nesmr->pbl_4k =
> ((pbl_count>1)||(cur_pbl_index>32)) ? 1 : 0;
> +				nesmr->pbls_used = pbl_count;
> +				if (pbl_count > 1) {
> +					nesmr->pbls_used++;
> +				}
> +			} else {
> +				kfree(nesmr);
> +				ibmr = ERR_PTR(-ENOMEM);
> +			}
> +
> +reg_user_mr_err:
> +			/* free the resources */
> +			if (root_pbl_index == 1) {
> +				pci_free_consistent(nesdev->pcidev,
> 4096, vpbl.pbl_vbase,
> +
> vpbl.pbl_pbase);
> +			} else {
> +				for (j=0; j<root_pbl_index; j++) {
> +
> pci_free_consistent(nesdev->pcidev, 4096,
> root_vpbl.leaf_vpbl[j].pbl_vbase,
> +
> root_vpbl.leaf_vpbl[j].pbl_pbase);
> +				}
> +				kfree(root_vpbl.leaf_vpbl);
> +				pci_free_consistent(nesdev->pcidev,
> 8192, root_vpbl.pbl_vbase,
> +
> root_vpbl.pbl_pbase);
> +			}
> +
> +			return ibmr;
> +			break;
> +		case IWNES_MEMREG_TYPE_QP:
> +			return ERR_PTR(-ENOSYS);
> +			break;
> +		case IWNES_MEMREG_TYPE_CQ:
> +			nespbl = kmalloc(sizeof(*nespbl), GFP_KERNEL);
> +			if (!nespbl) {
> +				dprintk("%s: Unable to allocate PBL\n",
> __FUNCTION__);
> +				return ERR_PTR(-ENOMEM);
> +			}
> +			memset(nespbl, 0, sizeof(*nespbl));
> +			nesmr = kmalloc(sizeof(*nesmr), GFP_KERNEL);
> +			if (!nesmr) {
> +				kfree(nespbl);
> +				dprintk("%s: Unable to allocate
> nesmr\n", __FUNCTION__);
> +				return ERR_PTR(-ENOMEM);
> +			}
> +			memset(nesmr, 0, sizeof(*nesmr));
> +			nes_ucontext =
> to_nesucontext(pd->uobject->context);
> +			pbl_depth = region->length >> PAGE_SHIFT;
> +			pbl_depth += (region->length & ~PAGE_MASK) ? 1 :
> 0;
> +			nespbl->pbl_size = pbl_depth*sizeof(u64);
> +			dprintk("%s: Attempting to allocate CQ PBL
> memory, %u bytes, %u entries.\n", __FUNCTION__, nespbl->pbl_size,
> pbl_depth );
> +			pbl = pci_alloc_consistent(nesdev->pcidev,
> nespbl->pbl_size,
> +
> &nespbl->pbl_pbase);
> +			if (!pbl) {
> +				kfree(nesmr);
> +				kfree(nespbl);
> +				dprintk("%s: Unable to allocate cq PBL
> memory\n", __FUNCTION__);
> +				return ERR_PTR(-ENOMEM);
> +			}
> +	
> +			nespbl->pbl_vbase = pbl;
> +			nespbl->user_base = region->user_base;
> +	
> +			list_for_each_entry(chunk, &region->chunk_list,
> list) {
> +				for (j = 0; j < chunk->nmap; ++j) {
> +					*pbl++ =
> cpu_to_le64((u64)sg_dma_address(&chunk->page_list[j]));
> +				}
> +			}
> +			list_add_tail(&nespbl->list,
> &nes_ucontext->cq_reg_mem_list);
> +			nesmr->ibmr.rkey = -1;
> +			nesmr->ibmr.lkey = -1;
> +			nesmr->mode = IWNES_MEMREG_TYPE_CQ;
> +			return  &nesmr->ibmr;
> +			break;
> +	}
> +
> +	return ERR_PTR(-ENOSYS);
> +}
> +
> +
> +/**
> + * nes_dereg_mr
> + * 
> + * @param ib_mr
> + * 
> + * @return int
> + */
> +static int nes_dereg_mr(struct ib_mr *ib_mr)
> +{
> +	struct nes_mr *nesmr = to_nesmr(ib_mr);
> +	struct nes_dev *nesdev = to_nesdev(ib_mr->device);
> +	struct nes_adapter *nesadapter = nesdev->nesadapter;
> +	struct nes_hw_cqp_wqe *cqp_wqe;
> +	u32 cqp_head;
> +	int err;
> +    unsigned long flags;
> +    int ret;
> +
> +	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +
> +	if (nesmr->mode != IWNES_MEMREG_TYPE_MEM) {
> +		/* TODO: Any cross checking with CQ/QP that owned? */
> +		kfree(nesmr);
> +		return 0;
> +	}
> +
> +	/* Deallocate the region with the adapter */
> +    spin_lock_irqsave(&nesdev->cqp.lock, flags);
> +
> +	if (0 != nesmr->pbls_used) {
> +		if (nesmr->pbl_4k) {
> +			nesadapter->free_4kpbl += nesmr->pbls_used;
> +			if (nesadapter->free_4kpbl >
> nesadapter->max_4kpbl) {
> +				printk(KERN_ERR PFX "free 4KB PBLs(%u)
> has exceeded the max(%u)\n", 
> +					   nesadapter->free_4kpbl,
> nesadapter->max_4kpbl);
> +			}
> +		} else {
> +			nesadapter->free_256pbl += nesmr->pbls_used;
> +			if (nesadapter->free_256pbl >
> nesadapter->max_256pbl) {
> +				printk(KERN_ERR PFX "free 256B PBLs(%u)
> has exceeded the max(%u)\n", 
> +					   nesadapter->free_256pbl,
> nesadapter->max_256pbl);
> +			}
> +		}
> +	}
> +
> +	cqp_head = nesdev->cqp.sq_head++;
> +	nesdev->cqp.sq_head &= nesdev->cqp.sq_size-1;
> +	cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
> +	cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
> NES_CQP_DEALLOCATE_STAG | NES_CQP_STAG_VA_TO |
> +					 NES_CQP_STAG_DEALLOC_PBLS |
> NES_CQP_STAG_MR;
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] = 0;
> +	*((struct nes_hw_cqp
> **)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) =  &nesdev->cqp;
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] =
> cqp_head;
> +	cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] = 0;
> +	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PBL_BLK_COUNT_IDX] = 0;
> +	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_PBL_LEN_IDX] = 0;
> +	cqp_wqe->wqe_words[NES_CQP_STAG_WQE_STAG_IDX] = ib_mr->rkey;
> +
> +	barrier();
> +
> +	// Ring doorbell (1 WQEs)
> +	nes_write32(nesdev->regs+NES_WQE_ALLOC, 0x01800000 |
> nesdev->cqp.qp_id);
> +
> +	/* Wait for CQP */
> +    spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
> +    dprintk("Waiting for deallocate STag 0x%08X to complete.\n",
> ib_mr->rkey);
> +    cqp_head = (cqp_head+1)&(nesdev->cqp.sq_size-1);
> +    ret =
> wait_event_timeout(nesdev->cqp.waitq,(nesdev->cqp.sq_tail==cqp_head),
> 2);
> +	dprintk("Deallocate STag completed, wait_event_timeout ret =
> %u.\n", ret);
> +    /* TODO: Catch error code... */
> +
> +	nes_free_resource(nesadapter, nesadapter->allocated_mrs,
> (ib_mr->rkey&0x0fffff00)>>8);
> +
> +	err = 0;
> +	if (err)
> +		dprintk("nes_stag_dealloc failed: %d\n", err);
> +	else
> +		kfree(nesmr);
> +
> +	return err;
> +}
> +
> +
> +/**
> + * show_rev
> + * 
> + * @param cdev
> + * @param buf
> + * 
> + * @return ssize_t
> + */
> +static ssize_t show_rev(struct class_device *cdev, char *buf)
> +{
> +	struct nes_dev *nesdev = container_of(cdev, struct nes_dev,
> ibdev.class_dev);
> +	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +	return sprintf(buf, "%x\n", nesdev->nesadapter->hw_rev);
> +}
> +
> +
> +/**
> + * show_fw_ver
> + * 
> + * @param cdev
> + * @param buf
> + * 
> + * @return ssize_t
> + */
> +static ssize_t show_fw_ver(struct class_device *cdev, char *buf)
> +{
> +	struct nes_dev *nesdev = container_of(cdev, struct nes_dev,
> ibdev.class_dev);
> +	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +	return sprintf(buf, "%x.%x.%x\n",
> +				   (int) (nesdev->nesadapter->fw_ver >>
> 32),
> +				   (int) (nesdev->nesadapter->fw_ver >>
> 16) & 0xffff,
> +				   (int) (nesdev->nesadapter->fw_ver &
> 0xffff));
> +}
> +
> +
> +/**
> + * show_hca
> + * 
> + * @param cdev
> + * @param buf
> + * 
> + * @return ssize_t
> + */
> +static ssize_t show_hca(struct class_device *cdev, char *buf)
> +{
> +	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +	return sprintf(buf, "NES010\n");
> +}
> +
> +
> +/**
> + * show_board
> + * 
> + * @param cdev
> + * @param buf
> + * 
> + * @return ssize_t
> + */
> +static ssize_t show_board(struct class_device *cdev, char *buf)
> +{
> +	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +	return sprintf(buf, "%.*s\n", 32, "NES010 Board ID");
> +}
> +
> +static CLASS_DEVICE_ATTR(hw_rev, S_IRUGO, show_rev, NULL);
> +static CLASS_DEVICE_ATTR(fw_ver, S_IRUGO, show_fw_ver, NULL);
> +static CLASS_DEVICE_ATTR(hca_type, S_IRUGO, show_hca, NULL);
> +static CLASS_DEVICE_ATTR(board_id, S_IRUGO, show_board, NULL);
> +
> +static struct class_device_attribute *nes_class_attributes[] = {
> +	&class_device_attr_hw_rev,
> +	&class_device_attr_fw_ver,
> +	&class_device_attr_hca_type,
> +	&class_device_attr_board_id
> +};
> +
> +
> +/**
> + * nes_query_qp
> + * 
> + * @param qp
> + * @param qp_attr
> + * @param qp_attr_mask
> + * @param qp_init_attr
> + * 
> + * @return int
> + */
> +static int nes_query_qp(struct ib_qp *qp,
> +						struct ib_qp_attr
> *qp_attr,
> +						int qp_attr_mask,
> +						struct ib_qp_init_attr
> *qp_init_attr)
> +{
> +	int err;
> +
> +	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +
> +	// TODO: Do work here
> +	err = 0;
> +
> +	return err;
> +}
> +
> +
> +/**
> + * nes_modify_qp
> + * 
> + * @param ibqp
> + * @param attr
> + * @param attr_mask
> + * 
> + * @return int
> + */
> +int nes_modify_qp(struct ib_qp *ibqp, struct ib_qp_attr *attr,
> +				  int attr_mask)
> +{
> +	u64 u64temp;
> +	struct nes_qp *nesqp = to_nesqp(ibqp);
> +	struct nes_dev *nesdev = to_nesdev(ibqp->device);
> +	struct nes_hw_cqp_wqe *cqp_wqe;
> +	struct iw_cm_id *cm_id = nesqp->cm_id;
> +	struct iw_cm_event cm_event;
> +	u8 abrupt_disconnect = 0;
> +	u32 cqp_head;
> +//	u32 counter;
> +    u32 next_iwarp_state = 0;
> +	int err;
> +	/* TODO: don't need both of these!!! */
> +    unsigned long flags;
> +    unsigned long qplockflags;
> +    int ret;
> +	u8 issue_modify_qp = 0;
> +    u8 issue_disconnect = 0;
> +
> +    spin_lock_irqsave(&nesqp->lock, qplockflags);
> +//	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +	dprintk("%s:QP%u: QP State = %u, cur QP State = %u, iwarp_state
> = 0x%X. \n", 
> +			__FUNCTION__, nesqp->hwqp.qp_id, attr->qp_state,
> nesqp->ibqp_state, nesqp->iwarp_state);
> +	dprintk("%s:QP%u: QP Access Flags = 0x%X, attr_mask = 0x%0x.
> \n", 
> +			__FUNCTION__, nesqp->hwqp.qp_id,
> attr->qp_access_flags, attr_mask );
> +
> +
> +	if (attr_mask & IB_QP_STATE) {
> +		switch (attr->qp_state) {
> +		case IB_QPS_INIT:
> +			dprintk("%s:QP%u: new state = init. \n",
> +					__FUNCTION__, nesqp->hwqp.qp_id
> ); 
> +            if (nesqp->iwarp_state>(u32)NES_CQP_QP_IWARP_STATE_IDLE) {
> +				/* TODO: Need to add code to handle back
> from error or closing */
> +				spin_unlock_irqrestore(&nesqp->lock,
> qplockflags);
> +                return -EINVAL;
> +            }
> +			next_iwarp_state = NES_CQP_QP_IWARP_STATE_IDLE;
> +            issue_modify_qp = 1;
> +			break;
> +		case IB_QPS_RTR:
> +			dprintk("%s:QP%u: new state = rtr. \n",
> +					__FUNCTION__, nesqp->hwqp.qp_id
> ); 
> +            if (nesqp->iwarp_state>(u32)NES_CQP_QP_IWARP_STATE_IDLE) {
> +				spin_unlock_irqrestore(&nesqp->lock,
> qplockflags);
> +                return -EINVAL;
> +            }
> +			next_iwarp_state = NES_CQP_QP_IWARP_STATE_IDLE;
> +            issue_modify_qp = 1;
> +			break;
> +		case IB_QPS_RTS:
> +			dprintk("%s:QP%u: new state = rts. \n",
> +					__FUNCTION__, nesqp->hwqp.qp_id
> ); 
> +            if (nesqp->iwarp_state>(u32)NES_CQP_QP_IWARP_STATE_RTS) {
> +				spin_unlock_irqrestore(&nesqp->lock,
> qplockflags);
> +                return -EINVAL;
> +            }
> +			next_iwarp_state = NES_CQP_QP_IWARP_STATE_RTS;
> +			if (nesqp->iwarp_state !=
> NES_CQP_QP_IWARP_STATE_RTS)
> +				next_iwarp_state |=
> NES_CQP_QP_CONTEXT_VALID | NES_CQP_QP_ARP_VALID | NES_CQP_QP_ORD_VALID;
> +            issue_modify_qp = 1;
> +			break;
> +		case IB_QPS_SQD:
> +            dprintk("%s:QP%u: new state = closing. SQ head = %u, SQ
> tail = %u. \n",
> +                    __FUNCTION__, nesqp->hwqp.qp_id,
> nesqp->hwqp.sq_head, nesqp->hwqp.sq_tail ); 
> +            if
> (nesqp->iwarp_state==(u32)NES_CQP_QP_IWARP_STATE_CLOSING) {
> +				spin_unlock_irqrestore(&nesqp->lock,
> qplockflags);
> +                return 0;
> +            } else if
> (nesqp->iwarp_state>(u32)NES_CQP_QP_IWARP_STATE_CLOSING) {
> +	            dprintk("%s:QP%u: State change to closing ignored
> due to current iWARP state. \n", 
> +				__FUNCTION__, nesqp->hwqp.qp_id ); 
> +				spin_unlock_irqrestore(&nesqp->lock,
> qplockflags);
> +                return -EINVAL;
> +            }
> +            next_iwarp_state = NES_CQP_QP_IWARP_STATE_CLOSING;
> +            if (nesqp->iwarp_state == NES_CQP_QP_IWARP_STATE_RTS){
> +    	        issue_disconnect = 1;
> +			} else 
> +			if (nesqp->iwarp_state ==
> NES_CQP_QP_IWARP_STATE_IDLE) {
> +				/* Free up the connect_worker thread if
> needed */
> +				if (nesqp->ksock) {
> +					nes_sock_release( nesqp,
> &qplockflags );
> +				}
> +			}
> +            break;
> +		case IB_QPS_SQE:
> +            dprintk("%s:QP%u: new state = terminate. \n",
> +                    __FUNCTION__, nesqp->hwqp.qp_id ); 
> +            if
> (nesqp->iwarp_state>=(u32)NES_CQP_QP_IWARP_STATE_TERMINATE) {
> +				spin_unlock_irqrestore(&nesqp->lock,
> qplockflags);
> +                return -EINVAL;
> +            }
> +            if (nesqp->iwarp_state == NES_CQP_QP_IWARP_STATE_RTS){
> +                issue_disconnect = 1;
> +				abrupt_disconnect = 1;
> +            }
> +            next_iwarp_state = NES_CQP_QP_IWARP_STATE_TERMINATE;
> +            issue_modify_qp = 1;
> +            break;
> +		case IB_QPS_ERR:
> +		case IB_QPS_RESET:
> +            if (nesqp->iwarp_state==(u32)NES_CQP_QP_IWARP_STATE_ERROR)
> {
> +				spin_unlock_irqrestore(&nesqp->lock,
> qplockflags);
> +                return -EINVAL;
> +            }
> +			dprintk("%s:QP%u: new state = error. \n",
> +					__FUNCTION__, nesqp->hwqp.qp_id
> ); 
> +			next_iwarp_state = NES_CQP_QP_IWARP_STATE_ERROR;
> +            if (nesqp->iwarp_state == NES_CQP_QP_IWARP_STATE_RTS){
> +                issue_disconnect = 1;
> +            }
> +            issue_modify_qp = 1;
> +			break;
> +		default:
> +			spin_unlock_irqrestore(&nesqp->lock,
> qplockflags);
> +			return -EINVAL;
> +			break;
> +		}
> +
> +		/* TODO: Do state checks */
> +
> +        nesqp->ibqp_state = attr->qp_state;
> +        if ( ((nesqp->iwarp_state & NES_CQP_QP_IWARP_STATE_MASK) ==
> (u32)NES_CQP_QP_IWARP_STATE_RTS) && 
> +             ((next_iwarp_state & NES_CQP_QP_IWARP_STATE_MASK) >
> (u32)NES_CQP_QP_IWARP_STATE_RTS)) {
> +            nesqp->iwarp_state = next_iwarp_state &
> NES_CQP_QP_IWARP_STATE_MASK;
> +            issue_disconnect = 1;
> +        } else
> +            nesqp->iwarp_state = next_iwarp_state &
> NES_CQP_QP_IWARP_STATE_MASK;
> +		/* TODO: nesqp->iwarp_state vs.next_iwarp_state */
> +	}
> +
> +	if (attr_mask & IB_QP_ACCESS_FLAGS) {
> +		if (attr->qp_access_flags & IB_ACCESS_LOCAL_WRITE) {
> +            /* TODO: had to add rdma read here for user mode access,
> doesn't seem quite correct */
> +            /*       actually, might need to remove rdma write here too
> */
> +            nesqp->nesqp_context->misc |=
> NES_QPCONTEXT_MISC_RDMA_WRITE_EN | NES_QPCONTEXT_MISC_RDMA_READ_EN;
> +			issue_modify_qp = 1;
> +		}
> +		if (attr->qp_access_flags & IB_ACCESS_REMOTE_WRITE) {
> +			nesqp->nesqp_context->misc |=
> NES_QPCONTEXT_MISC_RDMA_WRITE_EN;
> +			issue_modify_qp = 1;
> +		}
> +		if (attr->qp_access_flags & IB_ACCESS_REMOTE_READ) {
> +			nesqp->nesqp_context->misc |=
> NES_QPCONTEXT_MISC_RDMA_READ_EN;
> +			issue_modify_qp = 1;
> +		}
> +		if (attr->qp_access_flags & IB_ACCESS_MW_BIND) {
> +			nesqp->nesqp_context->misc |=
> NES_QPCONTEXT_MISC_WBIND_EN;
> +			issue_modify_qp = 1;
> +		}
> +	}
> +
> +	if (issue_disconnect)
> +	{
> +		dprintk("%s:QP%u: Issuing Disconnect.\n", __FUNCTION__,
> nesqp->hwqp.qp_id ); 
> +	}
> +	spin_unlock_irqrestore(&nesqp->lock, qplockflags);
> +	if (issue_disconnect)
> +	{
> +		spin_lock_irqsave(&nesdev->cqp.lock, flags);
> +		cqp_head = nesdev->cqp.sq_head++;
> +		nesdev->cqp.sq_head &= nesdev->cqp.sq_size-1;
> +		cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
> +		cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
> cpu_to_le32(NES_CQP_UPLOAD_CONTEXT | NES_CQP_QP_TYPE_IWARP);
> +		cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX] =
> cpu_to_le32(nesqp->hwqp.qp_id);
> +		cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] =  0;
> +		*((struct nes_hw_cqp
> **)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) =  &nesdev->cqp;
> +		cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] =
> cqp_head;
> +		cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] =
> 0;
> +		u64temp = (u64)nesqp->nesqp_context_pbase;
> +		cqp_wqe->wqe_words[NES_CQP_UPLOAD_WQE_CTXT_LOW_IDX] =
> cpu_to_le32((u32)u64temp);
> +		cqp_wqe->wqe_words[NES_CQP_UPLOAD_WQE_CTXT_HIGH_IDX] =
> cpu_to_le32((u32)(u64temp>>32));
> +		/* TODO: this value should already be swapped? */
> +		cqp_wqe->wqe_words[NES_CQP_UPLOAD_WQE_HTE_IDX] =
> nesqp->nesqp_context->hte_index;
> +
> +		barrier();
> +		// Ring doorbell (1 WQEs)
> +		nes_write32(nesdev->regs+NES_WQE_ALLOC, 0x01800000 |
> nesdev->cqp.qp_id );
> +
> +		/* Wait for CQP */
> +		spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
> +//		dprintk("Waiting for modify iWARP QP%u to complete.\n",
> nesqp->hwqp.qp_id);
> +		cqp_head = (cqp_head+1)&(nesdev->cqp.sq_size-1);
> +		ret =
> wait_event_timeout(nesdev->cqp.waitq,(nesdev->cqp.sq_tail==cqp_head),
> 2);
> +
> +		/* TODO: Catch error code... */
> +		nes_disconnect(nesqp->cm_id, abrupt_disconnect);
> +
> +		dprintk("%s:Generating a Close Complete Event (reset)
> for QP%u \n", 
> +				__FUNCTION__, nesqp->hwqp.qp_id);
> +		/* Send up the close complete event */
> +		cm_event.event = IW_CM_EVENT_CLOSE;
> +		cm_event.status = IW_CM_EVENT_STATUS_OK;
> +		cm_event.provider_data = cm_id->provider_data;
> +		cm_event.local_addr = cm_id->local_addr;
> +		cm_event.remote_addr = cm_id->remote_addr;
> +		cm_event.private_data = NULL;
> +		cm_event.private_data_len = 0;
> +
> +		cm_id->event_handler(cm_id, &cm_event);   
> +
> +	}
> +
> +	if (issue_modify_qp) {
> +        spin_lock_irqsave(&nesdev->cqp.lock, flags);
> +
> +        cqp_head = nesdev->cqp.sq_head++;
> +		nesdev->cqp.sq_head &= nesdev->cqp.sq_size-1;
> +		cqp_wqe = &nesdev->cqp.sq_vbase[cqp_head];
> +		cqp_wqe->wqe_words[NES_CQP_WQE_OPCODE_IDX] =
> NES_CQP_MODIFY_QP | NES_CQP_QP_TYPE_IWARP | next_iwarp_state;
> +		cqp_wqe->wqe_words[NES_CQP_WQE_ID_IDX] =
> nesqp->hwqp.qp_id;
> +		cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_HIGH_IDX] =  0;
> +		*((struct nes_hw_cqp
> **)&cqp_wqe->wqe_words[NES_CQP_WQE_COMP_CTX_LOW_IDX]) =  &nesdev->cqp;
> +		cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_LOW_IDX] =
> cqp_head;
> +		cqp_wqe->wqe_words[NES_CQP_WQE_COMP_SCRATCH_HIGH_IDX] =
> 0;
> +		u64temp = (u64)nesqp->nesqp_context_pbase;
> +		cqp_wqe->wqe_words[NES_CQP_QP_WQE_CONTEXT_LOW_IDX] =
> (u32)u64temp;
> +		cqp_wqe->wqe_words[NES_CQP_QP_WQE_CONTEXT_HIGH_IDX] =
> (u32)(u64temp>>32);
> +
> +		barrier();
> +		// Ring doorbell (1 WQEs)
> +		nes_write32(nesdev->regs+NES_WQE_ALLOC, 0x01800000 |
> nesdev->cqp.qp_id );
> +
> +		/* Wait for CQP */
> +        spin_unlock_irqrestore(&nesdev->cqp.lock, flags);
> +//        dprintk("Waiting for modify iWARP QP%u to complete.\n",
> nesqp->hwqp.qp_id);
> +        cqp_head = (cqp_head+1)&(nesdev->cqp.sq_size-1);
> +        ret =
> wait_event_timeout(nesdev->cqp.waitq,(nesdev->cqp.sq_tail==cqp_head),
> 2);
> +		dprintk("Modify iwarp QP%u completed, wait_event_timeout
> ret = %u, nesdev->cqp.sq_head = %u nesdev->cqp.sq_tail = %u.\n", 
> +				nesqp->hwqp.qp_id, ret,
> nesdev->cqp.sq_head, nesdev->cqp.sq_tail);
> +        /* TODO: Catch error code... */
> +	}
> +
> +    err = 0;
> +
> +	return err;
> +}
> +
> +
> +/**
> + * nes_muticast_attach
> + * 
> + * @param ibqp
> + * @param gid
> + * @param lid
> + * 
> + * @return int
> + */
> +static int nes_multicast_attach(struct ib_qp *ibqp, union ib_gid *gid,
> u16 lid)
> +{
> +	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +	return -ENOSYS;
> +}
> +
> +
> +/**
> + * nes_multicast_detach
> + * 
> + * @param ibqp
> + * @param gid
> + * @param lid
> + * 
> + * @return int
> + */
> +static int nes_multicast_detach(struct ib_qp *ibqp, union ib_gid *gid,
> u16 lid)
> +{
> +	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +	return -ENOSYS;
> +}
> +
> +
> +/**
> + * nes_process_mad
> + * 
> + * @param ibdev
> + * @param mad_flags
> + * @param port_num
> + * @param in_wc
> + * @param in_grh
> + * @param in_mad
> + * @param out_mad
> + * 
> + * @return int
> + */
> +static int nes_process_mad(struct ib_device *ibdev,
> +						   int mad_flags,
> +						   u8 port_num,
> +						   struct ib_wc *in_wc,
> +						   struct ib_grh
> *in_grh,
> +						   struct ib_mad
> *in_mad, struct ib_mad *out_mad)
> +{
> +	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +	return -ENOSYS;
> +}
> +
> +
> +/**
> + * nes_post_send
> + * 
> + * @param ibqp
> + * @param ib_wr
> + * @param bad_wr
> + * 
> + * @return int
> + */
> +static int nes_post_send(struct ib_qp *ibqp, struct ib_send_wr *ib_wr,
> +				  struct ib_send_wr **bad_wr)
> +{
> +	struct nes_dev *nesdev = to_nesdev(ibqp->device);
> +	struct nes_qp *nesqp = to_nesqp(ibqp);
> +	u32 qsize = nesqp->hwqp.sq_size;
> +	struct nes_hw_qp_wqe *wqe;
> +	unsigned long flags = 0;
> +	u32 head;
> +	int err = 0;
> +	u32 wqe_count = 0;
> +	u32 counter;
> +	int sge_index;
> +	u32 total_payload_length;
> +
> +//	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +	if (nesqp->ibqp_state > IB_QPS_RTS)
> +		return -EINVAL;
> +
> +		spin_lock_irqsave(&nesqp->lock, flags);
> +
> +	head = nesqp->hwqp.sq_head;
> +
> +	while (ib_wr) {
> +		/* Check for SQ overflow */
> +		if (((head + (2 * qsize) - nesqp->hwqp.sq_tail) % qsize)
> == (qsize - 1)) {
> +			err = -EINVAL;
> +			break;
> +		}
> +
> +		wqe = &nesqp->hwqp.sq_vbase[head];
> +//		dprintk("%s:processing sq wqe at %p, head = %u.\n",
> __FUNCTION__, wqe, head);
> +		*((u64
> *)&wqe->wqe_words[NES_IWARP_SQ_WQE_COMP_SCRATCH_LOW_IDX]) =
> ib_wr->wr_id;
> +		*((struct nes_qp
> **)&wqe->wqe_words[NES_IWARP_SQ_WQE_COMP_CTX_LOW_IDX]) = nesqp;
> +		wqe->wqe_words[NES_IWARP_SQ_WQE_COMP_CTX_LOW_IDX] |=
> head;
> +
> +		switch (ib_wr->opcode) {
> +		case IB_WR_SEND:
> +			if (ib_wr->send_flags & IB_SEND_SOLICITED) {
> +
> wqe->wqe_words[NES_IWARP_SQ_WQE_MISC_IDX] = NES_IWARP_SQ_OP_SENDSE; 
> +			} else {
> +
> wqe->wqe_words[NES_IWARP_SQ_WQE_MISC_IDX] = NES_IWARP_SQ_OP_SEND; 
> +			}
> +			if (ib_wr->num_sge >
> nesdev->nesadapter->max_sge) {
> +				err = -EINVAL;
> +				break;
> +			}
> +			if (ib_wr->send_flags & IB_SEND_FENCE) {
> +				/* TODO: is IB Send Fence local or RDMA
> read? */
> +
> wqe->wqe_words[NES_IWARP_SQ_WQE_MISC_IDX] |=
> NES_IWARP_SQ_WQE_LOCAL_FENCE; 
> +			}
> +			total_payload_length = 0;
> +			for (sge_index=0; sge_index < ib_wr->num_sge;
> sge_index++) {
> +
> wqe->wqe_words[NES_IWARP_SQ_WQE_FRAG0_LOW_IDX+(sge_index*4)] =
> cpu_to_le32((u32)ib_wr->sg_list[sge_index].addr);
> +
> wqe->wqe_words[NES_IWARP_SQ_WQE_FRAG0_HIGH_IDX+(sge_index*4)] =
> cpu_to_le32((u32)(ib_wr->sg_list[sge_index].addr>>32));
> +
> wqe->wqe_words[NES_IWARP_SQ_WQE_LENGTH0_IDX+(sge_index*4)] =
> cpu_to_le32(ib_wr->sg_list[sge_index].length);
> +
> wqe->wqe_words[NES_IWARP_SQ_WQE_STAG0_IDX+(sge_index*4)] =
> cpu_to_le32(ib_wr->sg_list[sge_index].lkey);
> +				total_payload_length +=
> ib_wr->sg_list[sge_index].length;
> +			}
> +
> wqe->wqe_words[NES_IWARP_SQ_WQE_TOTAL_PAYLOAD_IDX] =
> cpu_to_le32(total_payload_length);
> +			nesqp->bytes_sent += total_payload_length;
> +			if (nesqp->bytes_sent > NES_MAX_SQ_PAYLOAD_SIZE)
> {
> +
> wqe->wqe_words[NES_IWARP_SQ_WQE_MISC_IDX] |=
> NES_IWARP_SQ_WQE_READ_FENCE;
> +				nesqp->bytes_sent = 0;
> +			}
> +			break;
> +		case IB_WR_RDMA_WRITE:
> +			wqe->wqe_words[NES_IWARP_SQ_WQE_MISC_IDX] =
> NES_IWARP_SQ_OP_RDMAW; 
> +			if (ib_wr->num_sge >
> nesdev->nesadapter->max_sge) {
> +				err = -EINVAL;
> +				break;
> +			}
> +			if (ib_wr->send_flags & IB_SEND_FENCE) {
> +				/* TODO: is IB Send Fence local or RDMA
> read? */
> +
> wqe->wqe_words[NES_IWARP_SQ_WQE_MISC_IDX] |=
> NES_IWARP_SQ_WQE_LOCAL_FENCE; 
> +			}
> +			wqe->wqe_words[NES_IWARP_SQ_WQE_RDMA_STAG_IDX] =
> cpu_to_le32(ib_wr->wr.rdma.rkey);
> +			wqe->wqe_words[NES_IWARP_SQ_WQE_RDMA_TO_LOW_IDX]
> = cpu_to_le32(ib_wr->wr.rdma.remote_addr);
> +
> wqe->wqe_words[NES_IWARP_SQ_WQE_RDMA_TO_HIGH_IDX] =
> cpu_to_le32((u32)(ib_wr->wr.rdma.remote_addr>>32));
> +			total_payload_length = 0;
> +			for (sge_index=0; sge_index < ib_wr->num_sge;
> sge_index++) {
> +
> wqe->wqe_words[NES_IWARP_SQ_WQE_FRAG0_LOW_IDX+(sge_index*4)] =
> cpu_to_le32((u32)ib_wr->sg_list[sge_index].addr);
> +
> wqe->wqe_words[NES_IWARP_SQ_WQE_FRAG0_HIGH_IDX+(sge_index*4)] =
> cpu_to_le32((u32)(ib_wr->sg_list[sge_index].addr>>32));
> +
> wqe->wqe_words[NES_IWARP_SQ_WQE_LENGTH0_IDX+(sge_index*4)] =
> cpu_to_le32(ib_wr->sg_list[sge_index].length);
> +
> wqe->wqe_words[NES_IWARP_SQ_WQE_STAG0_IDX+(sge_index*4)] =
> cpu_to_le32(ib_wr->sg_list[sge_index].lkey);
> +				total_payload_length +=
> ib_wr->sg_list[sge_index].length;
> +			}
> +			/* TODO: handle multiple fragments, switch to
> loop on structure */
> +
> wqe->wqe_words[NES_IWARP_SQ_WQE_TOTAL_PAYLOAD_IDX] =
> cpu_to_le32(total_payload_length);
> +			wqe->wqe_words[NES_IWARP_SQ_WQE_RDMA_LENGTH_IDX]
> = wqe->wqe_words[NES_IWARP_SQ_WQE_TOTAL_PAYLOAD_IDX];
> +			nesqp->bytes_sent += total_payload_length;
> +			if (nesqp->bytes_sent > NES_MAX_SQ_PAYLOAD_SIZE)
> {
> +
> wqe->wqe_words[NES_IWARP_SQ_WQE_MISC_IDX] |=
> NES_IWARP_SQ_WQE_READ_FENCE;
> +				nesqp->bytes_sent = 0;
> +			}
> +			break;
> +		case IB_WR_RDMA_READ:
> +			/* IWarp only supports 1 sge for RDMA reads */
> +			if (ib_wr->num_sge > 1) {
> +				err = -EINVAL;
> +				break;
> +			}
> +			/* TODO: what about fences... */
> +			wqe->wqe_words[NES_IWARP_SQ_WQE_MISC_IDX] =
> NES_IWARP_SQ_OP_RDMAR;
> +
> +			wqe->wqe_words[NES_IWARP_SQ_WQE_RDMA_TO_LOW_IDX]
> = cpu_to_le32(ib_wr->wr.rdma.remote_addr);
> +
> wqe->wqe_words[NES_IWARP_SQ_WQE_RDMA_TO_HIGH_IDX] =
> cpu_to_le32((u32)(ib_wr->wr.rdma.remote_addr>>32));
> +			wqe->wqe_words[NES_IWARP_SQ_WQE_RDMA_STAG_IDX] =
> cpu_to_le32(ib_wr->wr.rdma.rkey); 
> +			wqe->wqe_words[NES_IWARP_SQ_WQE_RDMA_LENGTH_IDX]
> = cpu_to_le32(ib_wr->sg_list->length); 
> +			wqe->wqe_words[NES_IWARP_SQ_WQE_FRAG0_LOW_IDX] =
> cpu_to_le32(ib_wr->sg_list->addr);
> +			wqe->wqe_words[NES_IWARP_SQ_WQE_FRAG0_HIGH_IDX]
> = cpu_to_le32((u32)(ib_wr->sg_list->addr>>32));
> +			wqe->wqe_words[NES_IWARP_SQ_WQE_STAG0_IDX] =
> cpu_to_le32(ib_wr->sg_list->lkey); 
> +			break;
> +		default:
> +			/* error */
> +			err = -EINVAL;
> +			break;
> +		}
> +
> +		if (ib_wr->send_flags & IB_SEND_SIGNALED) {
> +			wqe->wqe_words[NES_IWARP_SQ_WQE_MISC_IDX] |=
> NES_IWARP_SQ_WQE_SIGNALED_COMPL;
> +		}
> +		wqe->wqe_words[NES_IWARP_SQ_WQE_MISC_IDX] =
> cpu_to_le32(wqe->wqe_words[NES_IWARP_SQ_WQE_MISC_IDX]);
> +
> +		ib_wr = ib_wr->next;
> +		head++;
> +		wqe_count++;
> +		if (head >= qsize)
> +			head = 0;
> +
> +	}
> +
> +	nesqp->hwqp.sq_head = head;
> +	barrier();
> +	while (wqe_count) {
> +		counter = min(wqe_count, ((u32)255));
> +		wqe_count -= counter;
> +		/* TODO: switch to using doorbell region */
> +		nes_write32(nesdev->regs + NES_WQE_ALLOC, (counter <<
> 24) | 0x00800000 | nesqp->hwqp.qp_id);
> +	}
> +
> +		spin_unlock_irqrestore(&nesqp->lock, flags);
> +
> +	if (err)
> +		*bad_wr = ib_wr;
> +	return (err);
> +}
> +
> +
> +/**
> + * nes_post_recv
> + * 
> + * @param ibqp
> + * @param ib_wr
> + * @param bad_wr
> + * 
> + * @return int
> + */
> +static int nes_post_recv(struct ib_qp *ibqp, struct ib_recv_wr *ib_wr,
> +				  struct ib_recv_wr **bad_wr)
> +{
> +	struct nes_dev *nesdev = to_nesdev(ibqp->device);
> +	struct nes_qp *nesqp = to_nesqp(ibqp);
> +	u32 qsize = nesqp->hwqp.rq_size;
> +	struct nes_hw_qp_wqe *wqe;
> +	unsigned long flags = 0;
> +	u32 head;
> +	int err = 0;
> +	u32 wqe_count = 0;
> +	u32 counter;
> +	int sge_index;
> +	u32 total_payload_length;
> +
> +	//	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +	if (nesqp->ibqp_state > IB_QPS_RTS)
> +		return -EINVAL;
> +
> +		spin_lock_irqsave(&nesqp->lock, flags);
> +
> +	head = nesqp->hwqp.rq_head;
> +
> +	while (ib_wr) {
> +		if (ib_wr->num_sge > nesdev->nesadapter->max_sge) {
> +			err = -EINVAL;
> +			break;
> +		}
> +		/* Check for RQ overflow */
> +		if (((head + (2 * qsize) - nesqp->hwqp.rq_tail) % qsize)
> == (qsize - 1)) {
> +			err = -EINVAL;
> +			break;
> +		}
> +
> +//		dprintk("%s: ibwr sge count = %u.\n", __FUNCTION__,
> ib_wr->num_sge);
> +		wqe = &nesqp->hwqp.rq_vbase[head];
> +//		dprintk("%s:QP%u:processing rq wqe at %p, head = %u.\n",
> __FUNCTION__, nesqp->hwqp.qp_id, wqe, head);
> +		*((u64
> *)&wqe->wqe_words[NES_IWARP_RQ_WQE_COMP_SCRATCH_LOW_IDX]) =
> ib_wr->wr_id;
> +		*((struct nes_qp
> **)&wqe->wqe_words[NES_IWARP_RQ_WQE_COMP_CTX_LOW_IDX]) = nesqp;
> +		wqe->wqe_words[NES_IWARP_RQ_WQE_COMP_CTX_LOW_IDX] |=
> head;
> +
> +		total_payload_length = 0;
> +		for (sge_index=0; sge_index < ib_wr->num_sge;
> sge_index++) {
> +
> wqe->wqe_words[NES_IWARP_RQ_WQE_FRAG0_LOW_IDX+(sge_index*4)] =
> cpu_to_le32((u32)ib_wr->sg_list[sge_index].addr);
> +
> wqe->wqe_words[NES_IWARP_RQ_WQE_FRAG0_HIGH_IDX+(sge_index*4)] =
> cpu_to_le32((u32)(ib_wr->sg_list[sge_index].addr>>32));
> +
> wqe->wqe_words[NES_IWARP_RQ_WQE_LENGTH0_IDX+(sge_index*4)] =
> cpu_to_le32(ib_wr->sg_list[sge_index].length);
> +
> wqe->wqe_words[NES_IWARP_RQ_WQE_STAG0_IDX+(sge_index*4)] =
> cpu_to_le32(ib_wr->sg_list[sge_index].lkey);
> +			total_payload_length += ib_wr->sg_list->length;
> +		}
> +		wqe->wqe_words[NES_IWARP_RQ_WQE_TOTAL_PAYLOAD_IDX] =
> cpu_to_le32(total_payload_length);
> +
> +		ib_wr = ib_wr->next;
> +		head++;
> +		wqe_count++;
> +		if (head >= qsize)
> +			head = 0;
> +	}
> +
> +	nesqp->hwqp.rq_head = head;
> +	barrier();
> +	while (wqe_count) {
> +		counter = min(wqe_count, ((u32)255));
> +		wqe_count -= counter;
> +		/* TODO: switch to using doorbell region */
> +		nes_write32(nesdev->regs+NES_WQE_ALLOC, (counter<<24) |
> nesqp->hwqp.qp_id );
> +	}
> +
> +		spin_unlock_irqrestore(&nesqp->lock, flags);
> +
> +	if (err)
> +		*bad_wr = ib_wr;
> +	return err;
> +}
> +
> +
> +/**
> + * nes_poll_cq
> + * 
> + * @param ibcq
> + * @param num_entries
> + * @param entry
> + * 
> + * @return int
> + */
> +static int nes_poll_cq(struct ib_cq *ibcq, int num_entries, struct
> ib_wc *entry)
> +{
> +    u64 wrid;
> +//    u64 u64temp;
> +	struct nes_dev *nesdev = to_nesdev(ibcq->device);
> +	struct nes_cq *nescq = to_nescq(ibcq);
> +	struct nes_qp *nesqp;
> +	struct nes_hw_cqe cqe;
> +	unsigned long flags = 0;
> +	u32 head;
> +	u32 wq_tail;
> +	u32 cq_size;
> +	u32 cqe_count=0;
> +	u32 wqe_index;
> +//   u32 counter;
> + 
> +//	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +
> +		spin_lock_irqsave(&nescq->lock, flags);
> +
> +	head = nescq->hw_cq.cq_head;
> +	cq_size = nescq->hw_cq.cq_size;
> +//    dprintk("%s: Polling CQ%u (head = %u, size = %u).\n",
> __FUNCTION__, 
> +//            nescq->hw_cq.cq_number, head, cq_size);
> +
> +    while (cqe_count<num_entries) {
> +		if
> (nescq->hw_cq.cq_vbase[head].cqe_words[NES_CQE_OPCODE_IDX] &
> NES_CQE_VALID) {
> +			/* TODO: determine if this copy of the cqe
> actually helps since cq is volatile */
> +			cqe = nescq->hw_cq.cq_vbase[head];
> +
> nescq->hw_cq.cq_vbase[head].cqe_words[NES_CQE_OPCODE_IDX] = 0;
> +			/* TODO: need to add code to check for magic bit
> (0x200) and ignore */
> +			wqe_index =
> cqe.cqe_words[NES_CQE_COMP_COMP_CTX_LOW_IDX]&(nesdev->nesadapter->max_qp
> _wr - 1);
> +			cqe.cqe_words[NES_CQE_COMP_COMP_CTX_LOW_IDX] &=
> ~(NES_SW_CONTEXT_ALIGN-1);
> +			barrier();
> +			/* parse CQE, get completion context from WQE
> (either rq or sq */
> +			nesqp = *((struct nes_qp
> **)&cqe.cqe_words[NES_CQE_COMP_COMP_CTX_LOW_IDX]);
> +			memset(entry, 0, sizeof *entry);
> +			entry->status = IB_WC_SUCCESS;
> +			entry->qp_num = nesqp->hwqp.qp_id;
> +			entry->src_qp = nesqp->hwqp.qp_id;
> +
> +			if (cqe.cqe_words[NES_CQE_OPCODE_IDX] &
> NES_CQE_SQ) {
> +                if (nesqp->skip_lsmm)
> +                {
> +                    nesqp->skip_lsmm = 0;
> +                    wq_tail = nesqp->hwqp.sq_tail++;
> +                }
> +
> +				/* Working on a SQ Completion*/
> +				/* TODO: get the wr head from the
> completion after proper alignment of nesqp */
> +				wq_tail = wqe_index;
> +				nesqp->hwqp.sq_tail =
> (wqe_index+1)&(nesqp->hwqp.sq_size - 1);
> +                wrid = *((u64
> *)&nesqp->hwqp.sq_vbase[wq_tail].wqe_words[NES_IWARP_SQ_WQE_COMP_SCRATCH
> _LOW_IDX]);
> +				entry->byte_len =
> nesqp->hwqp.sq_vbase[wq_tail].wqe_words[NES_IWARP_SQ_WQE_TOTAL_PAYLOAD_I
> DX];
> +
> +				switch
> (nesqp->hwqp.sq_vbase[wq_tail].wqe_words[NES_IWARP_SQ_WQE_MISC_IDX]&0x3f
> ) {
> +				case NES_IWARP_SQ_OP_RDMAW:
> +//					dprintk("%s: Operation = RDMA
> WRITE.\n", __FUNCTION__ );
> +					entry->opcode =
> IB_WC_RDMA_WRITE;
> +					break;
> +				case NES_IWARP_SQ_OP_RDMAR:
> +//					dprintk("%s: Operation = RDMA
> READ.\n", __FUNCTION__ );
> +					entry->opcode = IB_WC_RDMA_READ;
> +					entry->byte_len =
> nesqp->hwqp.sq_vbase[wq_tail].wqe_words[NES_IWARP_SQ_WQE_RDMA_LENGTH_IDX
> ];
> +					break;
> +				case NES_IWARP_SQ_OP_SENDINV:
> +				case NES_IWARP_SQ_OP_SENDSEINV:
> +				case NES_IWARP_SQ_OP_SEND:
> +				case NES_IWARP_SQ_OP_SENDSE:
> +//					dprintk("%s: Operation =
> Send.\n", __FUNCTION__ );
> +					entry->opcode = IB_WC_SEND;
> +					break;
> +				}
> +			} else {
> +				/* Working on a RQ Completion*/
> +				wq_tail = wqe_index;
> +				nesqp->hwqp.rq_tail =
> (wqe_index+1)&(nesqp->hwqp.rq_size - 1);
> +				entry->byte_len =
> le32_to_cpu(cqe.cqe_words[NES_CQE_PAYLOAD_LENGTH_IDX]);
> +				entry->byte_len =
> le32_to_cpu(cqe.cqe_words[NES_CQE_PAYLOAD_LENGTH_IDX]);
> +				wrid = *((u64
> *)&nesqp->hwqp.rq_vbase[wq_tail].wqe_words[NES_IWARP_RQ_WQE_COMP_SCRATCH
> _LOW_IDX]);
> +				entry->opcode = IB_WC_RECV;
> +			}
> +			/* TODO: report errors */
> +			entry->wr_id = wrid;
> +
> +			if (++head >= cq_size)
> +				head = 0;
> +			cqe_count++;
> +			nescq->polled_completions++;
> +			/* TODO: find a better number...if there is one
> */
> +			if ((nescq->polled_completions>(cq_size/2)) ||
> (nescq->polled_completions==255)) {
> +				dprintk("%s: CQ%u Issuing CQE Allocate
> since more than half of cqes are pending %u of %u.\n", 
> +						__FUNCTION__,
> nescq->hw_cq.cq_number ,nescq->polled_completions, cq_size);
> +				nes_write32(nesdev->regs+NES_CQE_ALLOC,
> nescq->hw_cq.cq_number | (nescq->polled_completions << 16) );
> +				nescq->polled_completions = 0;
> +			}
> +			entry++;
> +		} else
> +			break;
> +	}
> +
> +	if (nescq->polled_completions) {
> +//		dprintk("%s: CQ%u Issuing CQE Allocate for %u cqes.\n", 
> +//				__FUNCTION__, nescq->hw_cq.cq_number
> ,nescq->polled_completions);
> +		nes_write32(nesdev->regs+NES_CQE_ALLOC,
> nescq->hw_cq.cq_number | (nescq->polled_completions << 16) );
> +		nescq->polled_completions = 0;
> +	}
> +
> +	/* TODO: Add code to check if overflow checking is on, if so
> write CQE_ALLOC with remaining CQEs here or overflow
> +	         could occur */
> +
> +	nescq->hw_cq.cq_head = head;
> +//	dprintk("%s: Reporting %u completions for CQ%u.\n",
> __FUNCTION__, cqe_count, nescq->hw_cq.cq_number);
> +
> +		spin_unlock_irqrestore(&nescq->lock, flags);
> +
> +	return cqe_count;
> +}
> +
> +
> +/**
> + * nes_req_notify_cq
> + * 
> + * @param ibcq
> + * @param notify
> + * 
> + * @return int
> + */
> +static int nes_req_notify_cq(struct ib_cq *ibcq, enum ib_cq_notify
> notify)
> +{
> +	struct nes_dev *nesdev = to_nesdev(ibcq->device);
> +	struct nes_cq *nescq = to_nescq(ibcq);
> +	u32 cq_arm;
> +
> +//	dprintk("%s: Requesting notification for CQ%u.\n", __FUNCTION__,
> nescq->hw_cq.cq_number);
> +	cq_arm = nescq->hw_cq.cq_number;
> +	if (notify == IB_CQ_NEXT_COMP)
> +		cq_arm |= NES_CQE_ALLOC_NOTIFY_NEXT;
> +	else if (notify == IB_CQ_SOLICITED)
> +		cq_arm |= NES_CQE_ALLOC_NOTIFY_SE;
> +	else
> +		return -EINVAL;
> +
> +//	dprintk("%s: Arming CQ%u, command = 0x%08X.\n", __FUNCTION__,
> nescq->hw_cq.cq_number, cq_arm);
> +	nes_write32(nesdev->regs+NES_CQE_ALLOC, cq_arm );
> +
> +	return 0;
> +}
> +
> +
> +/**
> + * nes_register_device
> + * 
> + * @param nesdev
> + * 
> + * @return int
> + */
> +int nes_register_device(struct nes_dev *nesdev)
> +{
> +	int ret;
> +	int i;
> +
> +	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +	strlcpy(nesdev->ibdev.name, "nes%d", IB_DEVICE_NAME_MAX);
> +	nesdev->ibdev.owner = THIS_MODULE;
> +
> +	nesdev->ibdev.node_type = RDMA_NODE_RNIC;
> +	memset(&nesdev->ibdev.node_guid, 0,
> sizeof(nesdev->ibdev.node_guid));
> +	memcpy(&nesdev->ibdev.node_guid, nesdev->netdev->dev_addr, 6);
> +	nesdev->nesadapter->device_cap_flags =
> +				(IB_DEVICE_ZERO_STAG |
> IB_DEVICE_SEND_W_INV | IB_DEVICE_MEM_WINDOW);
> +
> +	nesdev->ibdev.uverbs_cmd_mask =
> +				(1ull << IB_USER_VERBS_CMD_GET_CONTEXT)
> |
> +				(1ull << IB_USER_VERBS_CMD_QUERY_DEVICE)
> |
> +				(1ull << IB_USER_VERBS_CMD_QUERY_PORT) |
> +				(1ull << IB_USER_VERBS_CMD_ALLOC_PD) |
> +				(1ull << IB_USER_VERBS_CMD_DEALLOC_PD) |
> +				(1ull << IB_USER_VERBS_CMD_REG_MR) |
> +				(1ull << IB_USER_VERBS_CMD_DEREG_MR) |
> +				(1ull <<
> IB_USER_VERBS_CMD_CREATE_COMP_CHANNEL) |
> +				(1ull << IB_USER_VERBS_CMD_CREATE_CQ) |
> +				(1ull << IB_USER_VERBS_CMD_DESTROY_CQ) |
> +				(1ull << IB_USER_VERBS_CMD_CREATE_AH) |
> +				(1ull << IB_USER_VERBS_CMD_DESTROY_AH) |
> +				(1ull <<
> IB_USER_VERBS_CMD_REQ_NOTIFY_CQ) |
> +				(1ull << IB_USER_VERBS_CMD_CREATE_QP) |
> +				(1ull << IB_USER_VERBS_CMD_MODIFY_QP) |
> +				(1ull << IB_USER_VERBS_CMD_POLL_CQ) |
> +				(1ull << IB_USER_VERBS_CMD_DESTROY_QP) |
> +				(1ull << IB_USER_VERBS_CMD_POST_SEND) |
> +				(1ull << IB_USER_VERBS_CMD_POST_RECV);
> +
> +	nesdev->ibdev.phys_port_cnt = 1;
> +	nesdev->ibdev.dma_device = &nesdev->pcidev->dev;
> +	nesdev->ibdev.class_dev.dev = &nesdev->pcidev->dev;
> +	nesdev->ibdev.query_device = nes_query_device;
> +	nesdev->ibdev.query_port = nes_query_port;
> +	nesdev->ibdev.modify_port = nes_modify_port;
> +	nesdev->ibdev.query_pkey = nes_query_pkey;
> +	nesdev->ibdev.query_gid = nes_query_gid;
> +	nesdev->ibdev.alloc_ucontext = nes_alloc_ucontext;
> +	nesdev->ibdev.dealloc_ucontext = nes_dealloc_ucontext;
> +	nesdev->ibdev.mmap = nes_mmap;
> +	nesdev->ibdev.alloc_pd = nes_alloc_pd;
> +	nesdev->ibdev.dealloc_pd = nes_dealloc_pd;
> +	nesdev->ibdev.create_ah = nes_create_ah;
> +	nesdev->ibdev.destroy_ah = nes_destroy_ah;
> +	nesdev->ibdev.create_qp = nes_create_qp;
> +	nesdev->ibdev.modify_qp = nes_modify_qp;
> +	nesdev->ibdev.query_qp = nes_query_qp;
> +	nesdev->ibdev.destroy_qp = nes_destroy_qp;
> +	nesdev->ibdev.create_cq = nes_create_cq;
> +	nesdev->ibdev.destroy_cq = nes_destroy_cq;
> +	nesdev->ibdev.poll_cq = nes_poll_cq;
> +	nesdev->ibdev.get_dma_mr = nes_get_dma_mr;
> +	nesdev->ibdev.reg_phys_mr = nes_reg_phys_mr;
> +	nesdev->ibdev.reg_user_mr = nes_reg_user_mr;
> +	nesdev->ibdev.dereg_mr = nes_dereg_mr;
> +
> +	nesdev->ibdev.alloc_fmr = 0;
> +	nesdev->ibdev.unmap_fmr = 0;
> +	nesdev->ibdev.dealloc_fmr = 0;
> +	nesdev->ibdev.map_phys_fmr = 0;
> +
> +	nesdev->ibdev.attach_mcast = nes_multicast_attach;
> +	nesdev->ibdev.detach_mcast = nes_multicast_detach;
> +	nesdev->ibdev.process_mad = nes_process_mad;
> +
> +	nesdev->ibdev.req_notify_cq = nes_req_notify_cq;
> +	nesdev->ibdev.post_send = nes_post_send;
> +	nesdev->ibdev.post_recv = nes_post_recv;
> +
> +	nesdev->ibdev.iwcm = kmalloc(sizeof(*nesdev->ibdev.iwcm),
> GFP_KERNEL);
> +	if (nesdev->ibdev.iwcm == NULL) {
> +		return (-ENOMEM);
> +	}
> +	nesdev->ibdev.iwcm->add_ref = nes_add_ref;
> +	nesdev->ibdev.iwcm->rem_ref = nes_rem_ref;
> +	nesdev->ibdev.iwcm->get_qp = nes_get_qp;
> +	nesdev->ibdev.iwcm->connect = nes_connect;
> +	nesdev->ibdev.iwcm->accept = nes_accept;
> +	nesdev->ibdev.iwcm->reject = nes_reject;
> +	nesdev->ibdev.iwcm->create_listen = nes_create_listen;
> +	nesdev->ibdev.iwcm->destroy_listen = nes_destroy_listen;
> +
> +	dprintk("&nes_dev=0x%p : &nes->ibdev = 0x%p: %s : %u\n", nesdev,
> &nesdev->ibdev,
> +				__FUNCTION__, __LINE__);
> +
> +	ret = ib_register_device(&nesdev->ibdev);
> +	if (ret) {
> +		dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +
> +		return ret;
> +	}
> +
> +	for (i = 0; i < ARRAY_SIZE(nes_class_attributes); ++i) {
> +		ret = class_device_create_file(&nesdev->ibdev.class_dev,
> nes_class_attributes[i]);
> +		if (ret) {
> +			dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__,
> __LINE__);
> +			ib_unregister_device(&nesdev->ibdev);
> +			return ret;
> +		}
> +	}
> +
> +	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +	return 0;
> +}
> +
> +
> +/**
> + * nes_unregister_device
> + * 
> + * @param nesdev
> + */
> +void nes_unregister_device(struct nes_dev *nesdev)
> +{
> +	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
> +	ib_unregister_device(&nesdev->ibdev);
> +}
> 
> 
> 
> 
> _______________________________________________
> openib-general mailing list
> openib-general@openib.org
> http://openib.org/mailman/listinfo/openib-general
> 
> To unsubscribe, please visit http://openib.org/mailman/listinfo/openib-general
> 

