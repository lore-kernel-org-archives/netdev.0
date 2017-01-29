From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH stable v1 03/13] net: ethernet: aquantia: Add ring support
 code
Date: Sun, 29 Jan 2017 14:32:24 +0100
Message-ID: <84e0a9bb-76a1-ef59-a422-3faa2737636a@gmx.de>
References: <cover.1485665881.git.vomlehn@texas.net>
 <52d034319a6de0b44f39cbdbb6b69605601786bf.1485665881.git.vomlehn@texas.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:63449 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750803AbdA2Nj7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 29 Jan 2017 08:39:59 -0500
In-Reply-To: <52d034319a6de0b44f39cbdbb6b69605601786bf.1485665881.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


On 29.01.2017 06:09, Alexander Loktionov wrote:

> +
> +void aq_ring_tx_append_buffs(struct aq_ring_s *self,
> +			     struct aq_ring_buff_s *buffer,
> +			     unsigned int buffers)
> +{
> +	if (likely(self->sw_tail + buffers < self->size)) {
> +		memcpy(&self->buff_ring[self->sw_tail], buffer,
> +		       sizeof(buffer[0]) * buffers);
> +	} else {
> +		unsigned int first_part = self->size - self->sw_tail;
> +		unsigned int second_part = buffers - first_part;
> +
> +		memcpy(&self->buff_ring[self->sw_tail], buffer,
> +		       sizeof(buffer[0]) * first_part);
> +
> +		memcpy(&self->buff_ring[0], &buffer[first_part],
> +		       sizeof(buffer[0]) * second_part);
> +	}
> +}

Do you really have to copy each single frame? Copying is an expensive 
operation that you normally want to avoid on the fast path.


> +#define AQ_SKB_ALIGN SKB_DATA_ALIGN(sizeof(struct skb_shared_info))
> +int aq_ring_rx_clean(struct aq_ring_s *self, int *work_done, int budget)
> +{
> +	struct net_device *ndev = aq_nic_get_ndev(self->aq_nic);
> +	int err = 0;
> +	bool is_rsc_completed = true;
> +
> +	for (; (self->sw_head != self->hw_head) && budget;
> +		self->sw_head = aq_ring_next_dx(self, self->sw_head),
> +		--budget, ++(*work_done)) {
> +		struct aq_ring_buff_s *buff = &self->buff_ring[self->sw_head];
> +		struct sk_buff *skb = NULL;
> +		unsigned int next_ = 0U;
> +		unsigned int i = 0U;
> +		struct aq_ring_buff_s *buff_ = NULL;
> +
> +		if (buff->is_error) {
> +			__free_pages(buff->page, 0);
> +			continue;
> +		}
> +
> +		if (buff->is_cleaned)
> +			continue;
> +
> +		if (!buff->is_eop) {
> +			for (next_ = buff->next,
> +			     buff_ = &self->buff_ring[next_]; true;
> +			     next_ = buff_->next,
> +			     buff_ = &self->buff_ring[next_]) {
> +				is_rsc_completed =
> +					aq_ring_dx_in_range(self->sw_head,
> +							    next_,
> +							    self->hw_head);
> +
> +				if (unlikely(!is_rsc_completed)) {
> +					is_rsc_completed = false;
> +					break;
> +				}
> +
> +				if (buff_->is_eop)
> +					break;
> +			}
> +
> +			if (!is_rsc_completed) {
> +				err = 0;
> +				goto err_exit;
> +			}
> +		}
> +
> +		/* for single fragment packets use build_skb() */
> +		if (buff->is_eop) {
> +			skb = build_skb(page_address(buff->page),
> +					buff->len + AQ_SKB_ALIGN);
> +			if (unlikely(!skb)) {
> +				err = -ENOMEM;
> +				goto err_exit;
> +			}
> +
> +			skb->dev = ndev;

This is already done by eth_type_trans() below (as I already mentioned 
in a review of a former version of this driver).


> +
> +void aq_ring_rx_deinit(struct aq_ring_s *self)
> +{
> +	if (!self)
> +		goto err_exit;

Why not return immediately?


> +void aq_ring_tx_deinit(struct aq_ring_s *self)
> +{
> +	if (!self)
> +		goto err_exit;

Same here.


> +
> +void aq_ring_free(struct aq_ring_s *self)
> +{
> +	if (!self)
> +		goto err_exit;

In which case can self be NULL?


> index 0000000..0ac3f9e
> --- /dev/null
> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.h
> @@ -0,0 +1,157 @@
> +/*
> + * aQuantia Corporation Network Driver
> + * Copyright (C) 2014-2017 aQuantia Corporation. All rights reserved
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + */
> +
> +/* File aq_ring.h: Declaration of functions for Rx/Tx rings. */
> +
> +#ifndef AQ_RING_H
> +#define AQ_RING_H
> +
> +#include "aq_common.h"
> +
> +struct page;
> +
> +/*           TxC       SOP        DX         EOP
> + *         +----------+----------+----------+-----------
> + *   8bytes|len l3,l4 | pa       | pa       | pa
> + *         +----------+----------+----------+-----------
> + * 4/8bytes|len pkt   |len pkt   |          | skb
> + *         +----------+----------+----------+-----------
> + * 4/8bytes|is_txc    |len,flags |len       |len,is_eop
> + *         +----------+----------+----------+-----------
> + *
> + *  This aq_ring_buff_s doesn't have endianness dependency.
> + *  It is __packed for cache line optimizations.
> + */
> +struct __packed aq_ring_buff_s {

__packed should be avoided if possible. There are macros like
__cacheline_aligned that can be used to ensure cacheline alignment.

Regard,
Lino
