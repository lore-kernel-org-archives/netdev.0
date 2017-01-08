From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: [PATCH v2 03/12] net: ethernet: aquantia: Add ring support code
Date: Mon, 9 Jan 2017 01:18:00 +0200
Message-ID: <CAKoUArkJfuvTh2o3cjV5CQ603P3wvtMjFW_XoOR0v1BWL5MXVA@mail.gmail.com>
References: <904a500ca838983102268d3c15d732cb138a5dd1.1483689029.git.vomlehn@texas.net>
 <41e24066f2a87cad644a902658846e109a6b406f.1483689029.git.vomlehn@texas.net>
 <cover.1483689029.git.vomlehn@texas.net> <7d0b8bdb9c3ec1d2cbfb136796dbfc66e0ab535d.1483689029.git.vomlehn@texas.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, David VomLehn <vomlehn@texas.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34039 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934140AbdAHXSC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 18:18:02 -0500
Received: by mail-io0-f194.google.com with SMTP id c80so5083871iod.1
        for <netdev@vger.kernel.org>; Sun, 08 Jan 2017 15:18:02 -0800 (PST)
In-Reply-To: <7d0b8bdb9c3ec1d2cbfb136796dbfc66e0ab535d.1483689029.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Alexander,

After a brief review, I have the following minor comments:
...
...
> diff --git a/drivers/net/ethernet/aquantia/aq_ring.c b/drivers/net/ethernet/aquantia/aq_ring.c
> new file mode 100644
> index 0000000..a7ef6aa
> --- /dev/null
> +++ b/drivers/net/ethernet/aquantia/aq_ring.c
> @@ -0,0 +1,380 @@

Should be aq_ring.c and not aq_pci_ring.c

> +
> +/* File aq_pci_ring.c: Definition of functions for Rx/Tx rings. */
> +

The aq_nic_cfg parameter is not used, it should be removed:

> +struct aq_ring_s *aq_ring_tx_alloc(struct aq_ring_s *self,
> +                                  struct aq_nic_s *aq_nic,
> +                                  unsigned int idx,
> +                                  struct aq_nic_cfg_s *aq_nic_cfg)
> +{
> +       int err = 0;
> +
> +       if (!self) {
> +               err = -ENOMEM;
> +               goto err_exit;
> +       }
> +       self->aq_nic = aq_nic;
> +       self->idx = idx;
> +       self->size = aq_nic_cfg->txds;
> +       self->dx_size = aq_nic_cfg->aq_hw_caps->txd_size;
> +
> +       self = aq_ring_alloc(self, aq_nic, aq_nic_cfg);
> +       if (!self) {
> +               err = -ENOMEM;
> +               goto err_exit;
> +       }
> +
> +err_exit:
> +       if (err < 0) {
> +               aq_ring_free(self);
> +               self = NULL;
> +       }
> +       return self;
> +}
> +

Shouldn't the return type be void for next 2 methods?

> +int aq_ring_init(struct aq_ring_s *self)
> +{
> +       self->hw_head = 0;
> +       self->sw_head = 0;
> +       self->sw_tail = 0;
> +       return 0;
> +}
> +
> +int aq_ring_deinit(struct aq_ring_s *self)
> +{
> +       return 0;
> +}
> +
> +void aq_ring_free(struct aq_ring_s *self)
> +{
> +       if (!self)

I would prefer here simply "return" and remove altogether the err_exit
label, but it is up to you:

> +               goto err_exit;
> +
> +       kfree(self->buff_ring);
> +
> +       if (self->dx_ring)
> +               dma_free_coherent(aq_nic_get_dev(self->aq_nic),
> +                                 self->size * self->dx_size, self->dx_ring,
> +                                 self->dx_ring_pa);
> +
> +err_exit:;
> +}
> +

Shouldn't the following method return type be void ?
> +
> +int aq_ring_tx_clean(struct aq_ring_s *self)
> +{
> +       struct device *dev = aq_nic_get_dev(self->aq_nic);
> +       struct net_device *ndev = aq_nic_get_ndev(self->aq_nic);
> +
> +       for (; self->sw_head != self->hw_head;
> +               self->sw_head = aq_ring_next_dx(self, self->sw_head)) {
> +               struct aq_ring_buff_s *buff = &self->buff_ring[self->sw_head];
> +
> +               ++self->stats.tx_packets;
> +               ++ndev->stats.tx_packets;
> +               ndev->stats.tx_bytes += buff->len;
> +
> +               if (likely(buff->is_mapped)) {
> +                       if (unlikely(buff->is_sop))
> +                               dma_unmap_single(dev, buff->pa, buff->len,
> +                                                DMA_TO_DEVICE);
> +                       else
> +                               dma_unmap_page(dev, buff->pa, buff->len,
> +                                              DMA_TO_DEVICE);
> +               }
> +
> +               if (unlikely(buff->is_eop))
> +                       dev_kfree_skb_any(buff->skb);
> +       }
> +
> +       if (aq_ring_avail_dx(self) > AQ_CFG_SKB_FRAGS_MAX)
> +               aq_nic_ndev_queue_start(self->aq_nic, self->idx);
> +
> +       return 0;
> +}
> +

The "err" variable in aq_ring_rx_clean() is meaningless and according to
current implementation of this method it should be removed. You set it
at the beginning to
0, then later on you also assign 0 to it under certain conditions, and
that's it, no other assignment. Maybe the second assignment should
have been to some other value than 0, but as it is it, the "err"
variable has no meaning.

> +int aq_ring_rx_clean(struct aq_ring_s *self, int *work_done, int budget)
> +{
> +       struct net_device *ndev = aq_nic_get_ndev(self->aq_nic);
> +       int err = 0;
> +       bool is_rsc_completed = true;
> +
> +       for (; (self->sw_head != self->hw_head) && budget;
> +               self->sw_head = aq_ring_next_dx(self, self->sw_head),
> +               --budget, ++(*work_done)) {
> +               struct aq_ring_buff_s *buff = &self->buff_ring[self->sw_head];
> +               struct sk_buff *skb = NULL;
> +               unsigned int next_ = 0U;
> +               unsigned int i = 0U;
> +               struct aq_ring_buff_s *buff_ = NULL;
> +
> +               if (buff->is_error) {
> +                       __free_pages(buff->page, 0);
> +                       continue;
> +               }
> +
> +               if (buff->is_cleaned)
> +                       continue;
> +
> +               ++self->stats.rx_packets;
> +               ++ndev->stats.rx_packets;
> +               ndev->stats.rx_bytes += buff->len;
> +
> +               if (!buff->is_eop) {
> +                       for (next_ = buff->next,
> +                            buff_ = &self->buff_ring[next_]; true;
> +                            next_ = buff_->next,
> +                            buff_ = &self->buff_ring[next_]) {
> +                               is_rsc_completed =
> +                                       aq_ring_dx_in_range(self->sw_head,
> +                                                           next_,
> +                                                           self->hw_head);
> +
> +                               if (unlikely(!is_rsc_completed)) {
> +                                       is_rsc_completed = false;
> +                                       break;
> +                               }
> +
> +                               if (buff_->is_eop)
> +                                       break;
> +                       }
> +
> +                       if (!is_rsc_completed) {
> +                               err = 0;
> +                               goto err_exit;
> +                       }
> +               }
> +
> +               skb = netdev_alloc_skb(ndev, ETH_HLEN + AQ_CFG_IP_ALIGN);
> +
> +               skb_reserve(skb, AQ_CFG_IP_ALIGN);
> +               skb_put(skb, ETH_HLEN);
> +               memcpy(skb->data, page_address(buff->page), ETH_HLEN);
> +
> +               skb_add_rx_frag(skb, 0, buff->page, ETH_HLEN,
> +                               buff->len - ETH_HLEN,
> +                               SKB_TRUESIZE(buff->len - ETH_HLEN));
> +               if (!buff->is_eop) {
> +                       for (i = 1U, next_ = buff->next,
> +                            buff_ = &self->buff_ring[next_]; true;
> +                            next_ = buff_->next,
> +                            buff_ = &self->buff_ring[next_], ++i) {
> +                               skb_add_rx_frag(skb, i, buff_->page, 0,
> +                                               buff_->len,
> +                                               SKB_TRUESIZE(buff->len -
> +                                               ETH_HLEN));
> +                               buff_->is_cleaned = 1;
> +
> +                               if (buff_->is_eop)
> +                                       break;
> +                       }
> +               }
> +
> +               skb->dev = ndev;
> +
> +               skb->protocol = eth_type_trans(skb, ndev);
> +               if (unlikely(buff->is_cso_err)) {
> +                       ++self->stats.rx_errors;
> +                       __skb_mark_checksum_bad(skb);
> +               } else {
> +                       if (buff->is_ip_cso) {
> +                               __skb_incr_checksum_unnecessary(skb);
> +                               if (buff->is_udp_cso || buff->is_tcp_cso)
> +                                       __skb_incr_checksum_unnecessary(skb);
> +                       } else {
> +                               skb->ip_summed = CHECKSUM_NONE;
> +                       }
> +               }
> +
> +               skb_set_hash(skb, buff->rss_hash,
> +                            buff->is_hash_l4 ? PKT_HASH_TYPE_L4 :
> +                            PKT_HASH_TYPE_NONE);
> +
> +               skb_record_rx_queue(skb, self->idx);
> +
> +               netif_receive_skb(skb);
> +       }
> +
> +err_exit:
> +       return err;
> +}

Should the following two methods be void ?
> +
> +int aq_ring_tx_drop(struct aq_ring_s *self)
> +{
> +       for (; self->sw_head != self->sw_tail;
> +               self->sw_head = aq_ring_next_dx(self, self->sw_head)) {
> +               struct aq_ring_buff_s *buff = &self->buff_ring[self->sw_head];
> +               struct device *ndev = aq_nic_get_dev(self->aq_nic);
> +
> +               if (likely(buff->is_mapped)) {
> +                       if (unlikely(buff->is_sop))
> +                               dma_unmap_single(ndev, buff->pa, buff->len,
> +                                                DMA_TO_DEVICE);
> +                       else
> +                               dma_unmap_page(ndev, buff->pa, buff->len,
> +                                              DMA_TO_DEVICE);
> +               }
> +
> +               if (unlikely(buff->is_eop))
> +                       dev_kfree_skb_any(buff->skb);
> +       }
> +
> +       return 0;
> +}
> +
> +int aq_ring_rx_drop(struct aq_ring_s *self)
> +{
> +       for (; self->sw_head != self->sw_tail;
> +               self->sw_head = aq_ring_next_dx(self, self->sw_head)) {
> +               struct aq_ring_buff_s *buff = &self->buff_ring[self->sw_head];
> +
> +               dma_unmap_page(aq_nic_get_dev(self->aq_nic), buff->pa,
> +                              AQ_CFG_RX_FRAME_MAX, DMA_FROM_DEVICE);
> +
> +               __free_pages(buff->page, 0);
> +       }
> +
> +       return 0;
> +}
> +
> diff --git a/drivers/net/ethernet/aquantia/aq_ring.h b/drivers/net/ethernet/aquantia/aq_ring.h
> new file mode 100644
> index 0000000..8f7e16e
> --- /dev/null
> +++ b/drivers/net/ethernet/aquantia/aq_ring.h
> @@ -0,0 +1,147 @@
> +/*
> + * aQuantia Corporation Network Driver
> + * Copyright (C) 2014-2016 aQuantia Corporation. All rights reserved
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + */
> +

File name should be aq_ring.h:

> +/* File aq_pci_ring.h: Declaration of functions for Rx/Tx rings. */
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

Typo: chache->cache
> + *  It is __packed for chache line optimisations.

Regards,
Rami Rosen
