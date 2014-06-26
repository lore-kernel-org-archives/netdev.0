From: Andy Green <andy.green@linaro.org>
Subject: Re: [net-next PATCH v4] net: ethernet driver: Fujitsu OGMA
Date: Thu, 26 Jun 2014 16:13:44 +0800
Message-ID: <CAAfg0W6Bs=Ln7DK-VuPjoTyz9EGoArznvCOnDnoYYq0HR=T13Q@mail.gmail.com>
References: <20140620070921.25956.13507.stgit@localhost.localdomain>
	<20140622.212539.527240518214265501.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Joe Perches <joe@perches.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Patch Tracking <patches@linaro.org>,
	Francois Romieu <romieu@fr.zoreil.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:41517 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753887AbaFZINo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 04:13:44 -0400
Received: by mail-qc0-f181.google.com with SMTP id x13so2769927qcv.26
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2014 01:13:44 -0700 (PDT)
In-Reply-To: <20140622.212539.527240518214265501.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23 June 2014 12:25, David Miller <davem@davemloft.net> wrote:
> From: Andy Green <andy.green@linaro.org>
> Date: Fri, 20 Jun 2014 15:09:21 +0800

Thanks for taking the time to review it.

>> +     u8 running:1;
>> +     u8 full:1;
>
> Please use bool and true/false.
>
>> +     u8 rx_cksum_offload_flag:1;
>> +     u8 actual_duplex:1;
>> +     u8 irq_registered:1;
>
> Likewise.

I got rid of all the non-register parsing bitfields and replaced by
bool, and checked they're set by true / false.

>> +};
>> +
>> +
>> +static inline void ogma_writel(struct ogma_priv *priv, u32 reg_addr, u32 val)
>
> Please no more than one empty line between top level declarations.

OK

>> +static inline void ogma_mark_skb_type(void *skb, bool recv_buf_flag)
>> +{
>> +     struct sk_buff *skb_p = skb;
>
> There is zero reason to declar 'skb' as a void pointer, "struct sk_buff *"
> is fine and all callers pass the proper type.
>
> Furthermore, it is much cleaner to define an explicit skb control block
> structure to cast skb->cb to and from.

You're right it's just noise from the original implementation.  I
added a struct to contain the bool we actually use.

>> +static const u32 ads_irq_set[] = {
>> +     OGMA_REG_NRM_TX_INTEN_SET,
>> +     OGMA_REG_NRM_RX_INTEN_SET,
>> +};
>> +static const u32 desc_ring_irq_inten_clr_reg_addr[] = {
>
> One empty line between top-level object declarations.
>
>> +     OGMA_REG_NRM_TX_INTEN_CLR,
>> +     OGMA_REG_NRM_RX_INTEN_CLR,
>> +};
>> +static const u32 int_tmr_reg_addr[] = {
>
> Likewise.
>
>> +     OGMA_REG_NRM_TX_TXINT_TMR,
>> +     OGMA_REG_NRM_RX_RXINT_TMR,
>> +};
>> +static const u32 rx_pkt_cnt_reg_addr[] = {
>
> Likewise.
>
>> +     0,
>> +     OGMA_REG_NRM_RX_PKTCNT,
>> +};
>> +static const u32 tx_pkt_cnt_reg_addr[] = {
>
> Likewise.  etc. there are more such cases, please audit your entire
> driver submission for this.

It seemed that was the only place where there's a bunch all together,
I spaced them out.

>> +int ogma_ring_irq_enable(struct ogma_priv *priv, enum ogma_rings id, u32 irqf)
>> +{
>> +     struct ogma_desc_ring *desc = &priv->desc_ring[id];
>> +     int ret = 0;
>> +
>> +     spin_lock(&desc->spinlock_desc);
>> +
>> +     if (!desc->running) {
>> +             netif_err(priv, drv, priv->net_device,
>> +                       "desc ring not running\n");
>> +             ret = -ENODEV;
>> +             goto err;
>> +     }
>> +
>> +     ogma_writel(priv, ads_irq_set[id], irqf);
>> +
>> +err:
>> +     spin_unlock(&desc->spinlock_desc);
>> +
>> +     return ret;
>> +}
>
> Taking this lock just for this sanity check is _WAY_ overkill.  Just do the single
> atomic register write and that's it.
>
> A 21 line function when a 1 line statement would do... :-/

OK, thanks for pointing it out.

>> +static int alloc_rx_pkt_buf(struct ogma_priv *priv, struct ogma_frag_info *info,
>> +                         struct sk_buff **skb)
>> +{
>> +     *skb = netdev_alloc_skb_ip_align(priv->net_device, info->len);
>> +     if (!*skb)
>> +             return -ENOMEM;
>> +
>> +     ogma_mark_skb_type(*skb, OGMA_RING_RX);
>> +     info->addr = (*skb)->data;
>> +     info->dma_addr = dma_map_single(priv->dev, info->addr, info->len,
>> +                                     DMA_FROM_DEVICE);
>> +     if (dma_mapping_error(priv->dev, info->dma_addr)) {
>> +             dev_kfree_skb(*skb);
>> +             return -ENOMEM;
>> +     }
>> +
>> +     return 0;
>> +}
>
> Do not pass pointers to pointers unless absolutely necessary, and here it is
> not.  *skb never changes, so just pass plain "struct sk_buff *" and avoid all
> of these excess address-of and dereference operations.

No the code is allocating an skb, so he has a use for ** here to set
the pointer in the caller; *skb does change, it's set on the first
line.

But I agree it's not necessary to do it like that, I changed it to
return the skb pointer and removed the skb arg.

>> +void ogma_free_desc_ring(struct ogma_priv *priv, struct ogma_desc_ring *desc)
>> +{
>> +     if (desc->ring_vaddr && desc->frag && desc->priv)
>> +             ogma_uninit_pkt_desc_ring(priv, desc);
>> +
>> +     if (desc->ring_vaddr)
>> +             dma_free_coherent(priv->dev, desc->len * DESC_NUM,
>> +                               desc->ring_vaddr, desc->desc_phys);
>> +     kfree(desc->frag);
>> +     kfree(desc->priv);
>> +
>> +     memset(desc, 0, sizeof(*desc));
>> +}
>
> This memset makes no sense, especially as "zero" is not an appropriate initial
> state for desc->spinlock_desc.
>
> Just NULL out the items explicitly, one by one, as you free the resources they
> point to.
>
> That's much easier to audit than this sledgehammer memset().

OK.

>> +     de->data_buf_addr = info->dma_addr;
>> +     de->buf_len_info = info->len;
>> +     de->reserved = 0;
>> +     smp_wmb(); /* make sure descriptor body is written */
>> +     de->attr = attr; /* write this last */
>
> You need a larger and more detailed comment than this.
>
> Memory barriers must describe exactly what must be seen, in what order,
> and by _who_.

I explained in the comment now the reasoning.

Thanks again for your comments.

Jassi Brar will send the v5 patch shortly as part of a series
including mailbox and the arch support patches for the SoCs that use
the ogma driver.

-Andy
