From: David VomLehn <vomlehn@texas.net>
Subject: Re: [PATCH 05/12] Support for NIC-specific code
Date: Thu, 29 Dec 2016 01:35:24 -0800
Message-ID: <103ada6d-1e7f-49bb-de87-61f8df423a98@texas.net>
References: <67f8be9c3f6a4fede2eefaa4a3c45f9dbaf9b411.1482844668.git.vomlehn@texas.net>
 <8aac6eaf6d90651f279392f301de85e6ab72a3cb.1482844668.git.vomlehn@texas.net>
 <206766987286d2c30b7f674dec4aafe1ed70a21b.1482844668.git.vomlehn@texas.net>
 <9cc1565a3a398b4f70248ca98d12991071142682.1482844668.git.vomlehn@texas.net>
 <122d7e0633e8a8ddfbb0c233d6896254b2fa3eef.1482844668.git.vomlehn@texas.net>
 <CAKoUArn+zfeU16SgJbPxh1f0ud+M8ERi2j6c34cqeO=+LGjuCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: Rami Rosen <roszenrami@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda1.aus1.datafoundry.com ([209.99.124.132]:59348 "EHLO
        milter.aus.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752718AbcL2Jf1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 04:35:27 -0500
In-Reply-To: <CAKoUArn+zfeU16SgJbPxh1f0ud+M8ERi2j6c34cqeO=+LGjuCw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Responses inline.

On 12/27/2016 09:21 PM, Rami Rosen wrote:
> Hi, David,
>
> Several nitpicks and comments, from a brief overview:
>
> The commented label //err_exit:  should be removed
>> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
>> @@ -0,0 +1,993 @@
>> +//err_exit:
>> +//err_exit:
> Shouldn't aq_nic_rss_init() be static? isn't it called only from
> aq_nic_cfg_init_defaults()?
> and it always returns 0, shouldn't it be void as well ? (+ remove
> checking the return code when invoking it in
> aq_nic_cfg_init_defaults())
Yes, thanks.

>> +int aq_nic_rss_init(struct aq_nic_s *self, unsigned int num_rss_queues)
>> +{
>> +       struct aq_nic_cfg_s *cfg = &self->aq_nic_cfg;
>> +       struct aq_receive_scale_parameters *rss_params = &cfg->aq_rss;
>> +       int i = 0;
>> +
> ...
>> +       return 0;
>> +}
>
> Shouldn't aq_nic_ndev_alloc() be static ? Isn't it invoked only from
> aq_nic_alloc_cold()?
Yes.
>
>> +struct net_device *aq_nic_ndev_alloc(void)
>> +{
> ...
>> +}
>
>
>> +
>> +static unsigned int aq_nic_map_skb_lso(struct aq_nic_s *self,
>> +                                      struct sk_buff *skb,
>> +                                      struct aq_ring_buff_s *dx)
>> +{
>> +       unsigned int ret = 0U;
>> +
>> +       dx->flags = 0U;
>> +       dx->len_pkt = skb->len;
>> +       dx->len_l2 = ETH_HLEN;
>> +       dx->len_l3 = ip_hdrlen(skb);
>> +       dx->len_l4 = tcp_hdrlen(skb);
>> +       dx->mss = skb_shinfo(skb)->gso_size;
>> +       dx->is_txc = 1U;
>> +       ret = 1U;
>> +
> Why not remove this "ret" variable, and simply return 1 ? the method
> always returns 1:
>
>> +       return ret;
>> +}
>> +
Yes, better.
>> +int aq_nic_xmit(struct aq_nic_s *self, struct sk_buff *skb)
>> +{
>> +       struct aq_ring_s *ring = NULL;
>> +       unsigned int frags = 0U;
>> +       unsigned int vec = skb->queue_mapping % self->aq_nic_cfg.vecs;
>> +       unsigned int tc = 0U;
>> +       int err = 0;
>> +       bool is_nic_in_bad_state;
>> +       bool is_locked = false;
>> +       bool is_busy = false;
>> +       struct aq_ring_buff_s buffers[AQ_CFG_SKB_FRAGS_MAX];
>> +
>> +       frags = skb_shinfo(skb)->nr_frags + 1;
>> +
>> +       ring = self->aq_ring_tx[AQ_NIC_TCVEC2RING(self, tc, vec)];
>> +
>> +       atomic_inc(&self->busy_count);
>> +       is_busy = true;
>> +
>> +       if (frags > AQ_CFG_SKB_FRAGS_MAX) {
>> +               dev_kfree_skb_any(skb);
>> +               goto err_exit;
>> +       }
>> +
>> +       is_nic_in_bad_state = AQ_OBJ_TST(self, AQ_NIC_FLAGS_IS_NOT_TX_READY) ||
>> +                               (aq_ring_avail_dx(ring) < AQ_CFG_SKB_FRAGS_MAX);
>> +
>> +       if (is_nic_in_bad_state) {
>> +               aq_nic_ndev_queue_stop(self, ring->idx);
>> +               err = NETDEV_TX_BUSY;
>> +               goto err_exit;
>> +       }
>> +
> Usage of this internal block is not common (unless it is under #ifdef,
> and also not very common also in that case). I suggest move "unsigned
> int trys" to the variables definitions in the beginning of the method
> and remove the opening and closing brackets of the following block:
>> +       {
>> +               unsigned int trys = AQ_CFG_LOCK_TRYS;
>> +
>> +               frags = aq_nic_map_skb(self, skb, &buffers[0]);
>> +
>> +               do {
>> +                       is_locked = spin_trylock(&ring->lock);
>> +               } while (--trys && !is_locked);
>> +               if (!(is_locked)) {
>> +                       err = NETDEV_TX_BUSY;
>> +                       goto err_exit;
>> +               }
>> +
Yes, this is better.
> Usually you don't let the mtu be less than 68, for example:
> http://lxr.free-electrons.com/source/drivers/net/ethernet/intel/i40e/i40e_main.c#L2246
> See also RFV 791:
> https://tools.ietf.org/html/rfc791
>
>
>> +int aq_nic_set_mtu(struct aq_nic_s *self, int new_mtu)
>> +{
>> +       int err = 0;
>> +
>> +       if (new_mtu > self->aq_hw_caps.mtu) {
>> +               err = 0;
>> +               goto err_exit;
>> +       }
>> +       self->aq_nic_cfg.mtu = new_mtu;
>> +
>> +err_exit:
>> +       return err;
>> +}
Clearly a must--thanks!
>> +
>> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.h b/drivers/net/ethernet/aquantia/atlantic/aq_nic.h
>> new file mode 100644
>> index 0000000..89958e7
>> --- /dev/null
>> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.h
>> @@ -0,0 +1,111 @@
>> +/*
>> + * Aquantia Corporation Network Driver
>> + * Copyright (C) 2014-2016 Aquantia Corporation. All rights reserved
>> + *
>> + * This program is free software; you can redistribute it and/or modify it
>> + * under the terms and conditions of the GNU General Public License,
>> + * version 2, as published by the Free Software Foundation.
>> + */
>> +
>> +/*
> Should be, of course, aq_nic.h:
>
>> + * File aq_nic.c: Declaration of common code for NIC.
>> + */
>> +
Good point. Better still, including the name of the file has little 
value and makes the comment incorrect if it gets renamed. So, thanks!
> Regards,
> Rami Rosen


-- 
David VL
