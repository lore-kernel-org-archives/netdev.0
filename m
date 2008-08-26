From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC][PATCH 3/3] enic: add h/w interfaces
Date: Mon, 25 Aug 2008 19:18:50 -0700
Message-ID: <ada63poldrp.fsf@cisco.com>
References: <Pine.LNX.4.64.0808251124230.3972@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:53458 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753837AbYHZCSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 22:18:52 -0400
In-Reply-To: <Pine.LNX.4.64.0808251124230.3972@palito_client100.nuovasystems.com>
	(Scott Feldman's message of "Mon, 25 Aug 2008 11:27:13 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > +	for (delay = 0; delay < wait; delay++) {
 > +
 > +		udelay(100);

spinning for 100 usecs is pretty nasty... can this be changed to
usleep()?

 > +static inline void cq_desc_dec(const struct cq_desc *desc_arg,
 > +	u8 *type, u8 *color, u16 *q_number, u16 *completed_index)
 > +{
 > +	volatile const struct cq_desc *desc = desc_arg;

not sure why you're making this volatile here... I suspect it doesn't do
what you really want on architectures with a weak memory ordering model,
so it would be better to make things explicit with a memory barrier plus
a comment explaining what you're doing.

 > +	const u8 type_color = desc->type_color;
 > +
 > +	*color = (type_color >> CQ_DESC_TYPE_BITS) & CQ_DESC_COLOR_MASK;
 > +	*type = type_color & CQ_DESC_TYPE_MASK;
 > +	*q_number = desc->q_number & CQ_DESC_Q_NUM_MASK;
 > +	*completed_index = desc->completed_index & CQ_DESC_COMP_NDX_MASK;
 > +}
 > +
 > +static inline void cq_color_dec(const struct cq_desc *desc_arg, u8 *color)
 > +{
 > +	volatile const struct cq_desc *desc = desc_arg;

same here but this function doesn't appear to have any callers.

 > +
 > +	*color = (desc->type_color >> CQ_DESC_TYPE_BITS) & CQ_DESC_COLOR_MASK;
 > +}

 > +int vnic_cq_mem_size(struct vnic_cq *cq, unsigned int desc_count,
 > +	unsigned int desc_size)

I don't see any callers of this (or vnic_dev_get_pdev,
vnic_dev_get_size, vnic_dev_init_done, vnic_rq_error_status,
vnic_rq_mem_size, vnic_wq_error_status or vnic_wq_mem_size).

 > +static inline unsigned int vnic_cq_service(struct vnic_cq *cq,
 > +	unsigned int work_to_do,
 > +	int (*q_service)(struct vnic_dev *vdev, struct cq_desc *cq_desc,
 > +	u8 type, u16 q_number, u16 completed_index, void *opaque),
 > +	void *opaque)
 > +{
 > +	struct cq_desc *cq_desc;
 > +	unsigned int work_done = 0;
 > +	u16 q_number, completed_index;
 > +	u8 type, color;
 > +
 > +	cq_desc = (struct cq_desc *)((u8 *)cq->ring.descs +
 > +		cq->ring.desc_size * cq->to_clean);
 > +	cq_desc_dec(cq_desc, &type, &color,
 > +		&q_number, &completed_index);
 > +
 > +	while (color != cq->last_color) {
 > +
 > +		if ((*q_service)(cq->vdev, cq_desc, type,
 > +			le16_to_cpu(q_number),
 > +			le16_to_cpu(completed_index),
 > +			opaque))
 > +			break;
 > +
 > +		cq->to_clean++;
 > +		if (cq->to_clean == cq->ring.desc_count) {
 > +			cq->to_clean = 0;
 > +			cq->last_color = cq->last_color ? 0 : 1;
 > +		}
 > +
 > +		cq_desc = (struct cq_desc *)((u8 *)cq->ring.descs +
 > +			cq->ring.desc_size * cq->to_clean);
 > +		cq_desc_dec(cq_desc, &type, &color,
 > +			&q_number, &completed_index);
 > +
 > +		work_done++;
 > +		if (work_done >= work_to_do)
 > +			break;
 > +	}
 > +
 > +	return work_done;
 > +}

This looks way too big to inline.
