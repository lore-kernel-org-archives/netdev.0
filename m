From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH v2 03/12] net: ethernet: aquantia: Add ring support code
Date: Sat, 7 Jan 2017 02:05:29 +0100
Message-ID: <710cc306-7957-18ea-7a59-442f7e80a37e@gmx.de>
References: <cover.1483689029.git.vomlehn@texas.net>
 <7d0b8bdb9c3ec1d2cbfb136796dbfc66e0ab535d.1483689029.git.vomlehn@texas.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:53483 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934554AbdAGBFm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 20:05:42 -0500
In-Reply-To: <7d0b8bdb9c3ec1d2cbfb136796dbfc66e0ab535d.1483689029.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06.01.2017 09:06, Alexander Loktionov wrote:
> From: David VomLehn <vomlehn@texas.net>
>
> Add code to support the transmit and receive ring buffers.
>
> Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
> Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
> Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
> Signed-off-by: David M. VomLehn <vomlehn@texas.net>
> ---
>   drivers/net/ethernet/aquantia/aq_ring.c | 380 ++++++++++++++++++++++++++++++++
>   drivers/net/ethernet/aquantia/aq_ring.h | 147 ++++++++++++
>   2 files changed, 527 insertions(+)
>   create mode 100644 drivers/net/ethernet/aquantia/aq_ring.c
>   create mode 100644 drivers/net/ethernet/aquantia/aq_ring.h
>
> diff --git a/drivers/net/ethernet/aquantia/aq_ring.c b/drivers/net/ethernet/aquantia/aq_ring.c
> new file mode 100644
> index 0000000..a7ef6aa
> --- /dev/null
> +++ b/drivers/net/ethernet/aquantia/aq_ring.c
> @@ -0,0 +1,380 @@
> +/*
> + * aQuantia Corporation Network Driver
> + * Copyright (C) 2014-2016 aQuantia Corporation. All rights reserved
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + */
> +
> +/* File aq_pci_ring.c: Definition of functions for Rx/Tx rings. */
> +
> +#include "aq_ring.h"
> +#include "aq_nic.h"
> +#include "aq_hw.h"
> +
> +#include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
> +
> +static struct aq_ring_s *aq_ring_alloc(struct aq_ring_s *self,
> +				       struct aq_nic_s *aq_nic,
> +				       struct aq_nic_cfg_s *aq_nic_cfg)
> +{
> +	int err = 0;
> +
> +	if (!self) {
> +		err = -ENOMEM;
> +		goto err_exit;
> +	}

Why do you check this parameter but not the others?
Beside this since the function is static the only caller is your own 
code, so why is a check
needed at all? Can self ever be NULL? Same pattern occurs in several 
other functions.
> +
> +struct aq_ring_s *aq_ring_tx_alloc(struct aq_ring_s *self,
> +				   struct aq_nic_s *aq_nic,
> +				   unsigned int idx,
> +				   struct aq_nic_cfg_s *aq_nic_cfg)
>
> +
> +struct aq_ring_s *aq_ring_rx_alloc(struct aq_ring_s *self,
> +				   struct aq_nic_s *aq_nic,
> +				   unsigned int idx,
> +				   struct aq_nic_cfg_s *aq_nic_cfg)
> +{
> +	int err = 0;
> +
> +	if (!self) {
> +		err = -ENOMEM;
> +		goto err_exit;
>
> +
> +void aq_ring_free(struct aq_ring_s *self)
> +{
> +	if (!self)
> +		goto err_exit;
> +
> +	kfree(self->buff_ring);
> +
> +	if (self->dx_ring)
> +		dma_free_coherent(aq_nic_get_dev(self->aq_nic),
> +				  self->size * self->dx_size, self->dx_ring,
> +				  self->dx_ring_pa);
> +
> +err_exit:;
> +}

This does not make sense. Just return immediately if "self" is NULL (and 
if you really have to make
  this check).
> +
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
> +		++self->stats.rx_packets;
> +		++ndev->stats.rx_packets;
> +		ndev->stats.rx_bytes += buff->len;
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
> +		skb = netdev_alloc_skb(ndev, ETH_HLEN + AQ_CFG_IP_ALIGN);
> +
> +		skb_reserve(skb, AQ_CFG_IP_ALIGN);

netdev_alloc_skb_ip_align() will do the proper alignment for you (BTW. 
AQ_CFG_IP_ALIGN is defined as 0 in aq_cfg.h.
Is this on purpose?)

> +		skb_put(skb, ETH_HLEN);
> +		memcpy(skb->data, page_address(buff->page), ETH_HLEN);
> +
> +		skb_add_rx_frag(skb, 0, buff->page, ETH_HLEN,
> +				buff->len - ETH_HLEN,
> +				SKB_TRUESIZE(buff->len - ETH_HLEN));
> +		if (!buff->is_eop) {
> +			for (i = 1U, next_ = buff->next,
> +			     buff_ = &self->buff_ring[next_]; true;
> +			     next_ = buff_->next,
> +			     buff_ = &self->buff_ring[next_], ++i) {
> +				skb_add_rx_frag(skb, i, buff_->page, 0,
> +						buff_->len,
> +						SKB_TRUESIZE(buff->len -
> +						ETH_HLEN));
> +				buff_->is_cleaned = 1;
> +
> +				if (buff_->is_eop)
> +					break;
> +			}
> +		}
> +
> +		skb->dev = ndev;
   This is unnecessary. The following call of eth_type_trans() will do 
this already.

Regards,
Lino
