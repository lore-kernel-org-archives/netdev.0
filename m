From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [RFC][PATCH 3/3] enic: add h/w interfaces
Date: Fri, 29 Aug 2008 11:17:20 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0808291052470.9391@palito_client100.nuovasystems.com>
References: <ada63poldrp.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuova-ex1.nuovasystems.com ([67.91.200.196]:48969 "EHLO
	nuova-ex1.nuovasystems.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755935AbYH2SSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 14:18:03 -0400
In-Reply-To: <ada63poldrp.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Aug 2008, Roland Dreier wrote:

> > +	for (delay = 0; delay < wait; delay++) {
> > +
> > +		udelay(100);
>
> spinning for 100 usecs is pretty nasty... can this be changed to
> usleep()?

No because we can't sleep in some of the calling contexts.

> > +static inline void cq_desc_dec(const struct cq_desc *desc_arg,
> > +	u8 *type, u8 *color, u16 *q_number, u16 *completed_index)
> > +{
> > +	volatile const struct cq_desc *desc = desc_arg;
>
> not sure why you're making this volatile here... I suspect it doesn't do
> what you really want on architectures with a weak memory ordering model,
> so it would be better to make things explicit with a memory barrier plus
> a comment explaining what you're doing.

We're using volatile here to make the color bit in the descriptor is read 
first before the any of the other desc fields.  The hardware guarantees 
the color bit is the last byte (bit) written on the descriptor.  I'll put 
in a comment explaining what we're doing.

> > +	const u8 type_color = desc->type_color;
> > +
> > +	*color = (type_color >> CQ_DESC_TYPE_BITS) & CQ_DESC_COLOR_MASK;
> > +	*type = type_color & CQ_DESC_TYPE_MASK;
> > +	*q_number = desc->q_number & CQ_DESC_Q_NUM_MASK;
> > +	*completed_index = desc->completed_index & CQ_DESC_COMP_NDX_MASK;
> > +}
> > +
> > +static inline void cq_color_dec(const struct cq_desc *desc_arg, u8 *color)
> > +{
> > +	volatile const struct cq_desc *desc = desc_arg;
>
> same here but this function doesn't appear to have any callers.

removed

> > +int vnic_cq_mem_size(struct vnic_cq *cq, unsigned int desc_count,
> > +	unsigned int desc_size)
>
> I don't see any callers of this (or vnic_dev_get_pdev,
> vnic_dev_get_size, vnic_dev_init_done, vnic_rq_error_status,
> vnic_rq_mem_size, vnic_wq_error_status or vnic_wq_mem_size).

fixed

> > +static inline unsigned int vnic_cq_service(struct vnic_cq *cq,
> > +	unsigned int work_to_do,
> > +	int (*q_service)(struct vnic_dev *vdev, struct cq_desc *cq_desc,
> > +	u8 type, u16 q_number, u16 completed_index, void *opaque),
> > +	void *opaque)
> > +{
> > +	struct cq_desc *cq_desc;
> > +	unsigned int work_done = 0;
> > +	u16 q_number, completed_index;
> > +	u8 type, color;
> > +
> > +	cq_desc = (struct cq_desc *)((u8 *)cq->ring.descs +
> > +		cq->ring.desc_size * cq->to_clean);
> > +	cq_desc_dec(cq_desc, &type, &color,
> > +		&q_number, &completed_index);
> > +
> > +	while (color != cq->last_color) {
> > +
> > +		if ((*q_service)(cq->vdev, cq_desc, type,
> > +			le16_to_cpu(q_number),
> > +			le16_to_cpu(completed_index),
> > +			opaque))
> > +			break;
> > +
> > +		cq->to_clean++;
> > +		if (cq->to_clean == cq->ring.desc_count) {
> > +			cq->to_clean = 0;
> > +			cq->last_color = cq->last_color ? 0 : 1;
> > +		}
> > +
> > +		cq_desc = (struct cq_desc *)((u8 *)cq->ring.descs +
> > +			cq->ring.desc_size * cq->to_clean);
> > +		cq_desc_dec(cq_desc, &type, &color,
> > +			&q_number, &completed_index);
> > +
> > +		work_done++;
> > +		if (work_done >= work_to_do)
> > +			break;
> > +	}
> > +
> > +	return work_done;
> > +}
>
> This looks way too big to inline.

It's called in the performance path in several places.

-scott
