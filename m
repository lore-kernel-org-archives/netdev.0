From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH] net: mvpp2: fix dma unmapping of TX buffers for fragments
Date: Tue, 13 Dec 2016 18:03:33 +0100
Message-ID: <CAPv3WKfAwe+yonZuZptaRjnJy9dMRUdXvnAJdRpvvvHqNBznLA@mail.gmail.com>
References: <1481647995-7213-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Raphael G <raphael.glon@corp.ovh.com>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:34726 "EHLO
        mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932904AbcLMRDf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 12:03:35 -0500
Received: by mail-io0-f177.google.com with SMTP id p42so67216775ioo.1
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2016 09:03:34 -0800 (PST)
In-Reply-To: <1481647995-7213-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

Reviewed-by: Marcin Wojtas <mw@semihalf.com>

Best regards,
Marcin

2016-12-13 17:53 GMT+01:00 Thomas Petazzoni
<thomas.petazzoni@free-electrons.com>:
> Since commit 71ce391dfb784 ("net: mvpp2: enable proper per-CPU TX
> buffers unmapping"), we are not correctly DMA unmapping TX buffers for
> fragments.
>
> Indeed, the mvpp2_txq_inc_put() function only stores in the
> txq_cpu->tx_buffs[] array the physical address of the buffer to be
> DMA-unmapped when skb != NULL. In addition, when DMA-unmapping, we use
> skb_headlen(skb) to get the size to be unmapped. Both of this works fine
> for TX descriptors that are associated directly to a SKB, but not the
> ones that are used for fragments, with a NULL pointer as skb:
>
>  - We have a NULL physical address when calling DMA unmap
>  - skb_headlen(skb) crashes because skb is NULL
>
> This causes random crashes when fragments are used.
>
> To solve this problem, this commit:
>
>  - Stores the physical address of the buffer to be unmapped
>    unconditionally, regardless of whether it is tied to a SKB or not.
>
>  - Adds a txq_cpu->tx_data_size[] array to store the size of the DMA
>    buffer to be unmapped upon TX completion.
>
> Fixes: 71ce391dfb784 ("net: mvpp2: enable proper per-CPU TX buffers unmapping")
> Reported-by: Raphael G <raphael.glon@corp.ovh.com>
> Cc: Raphael G <raphael.glon@corp.ovh.com>
> Cc: stable@vger.kernel.org
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> ---
>  drivers/net/ethernet/marvell/mvpp2.c | 20 ++++++++++++++++----
>  1 file changed, 16 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
> index 1026c45..d168b13 100644
> --- a/drivers/net/ethernet/marvell/mvpp2.c
> +++ b/drivers/net/ethernet/marvell/mvpp2.c
> @@ -791,6 +791,8 @@ struct mvpp2_txq_pcpu {
>         /* Array of transmitted buffers' physical addresses */
>         dma_addr_t *tx_buffs;
>
> +       size_t *tx_data_size;
> +
>         /* Index of last TX DMA descriptor that was inserted */
>         int txq_put_index;
>
> @@ -980,9 +982,10 @@ static void mvpp2_txq_inc_put(struct mvpp2_txq_pcpu *txq_pcpu,
>                               struct mvpp2_tx_desc *tx_desc)
>  {
>         txq_pcpu->tx_skb[txq_pcpu->txq_put_index] = skb;
> -       if (skb)
> -               txq_pcpu->tx_buffs[txq_pcpu->txq_put_index] =
> -                                                        tx_desc->buf_phys_addr;
> +       txq_pcpu->tx_data_size[txq_pcpu->txq_put_index] =
> +               tx_desc->data_size;
> +       txq_pcpu->tx_buffs[txq_pcpu->txq_put_index] =
> +               tx_desc->buf_phys_addr;
>         txq_pcpu->txq_put_index++;
>         if (txq_pcpu->txq_put_index == txq_pcpu->size)
>                 txq_pcpu->txq_put_index = 0;
> @@ -4404,11 +4407,13 @@ static void mvpp2_txq_bufs_free(struct mvpp2_port *port,
>                 dma_addr_t buf_phys_addr =
>                                     txq_pcpu->tx_buffs[txq_pcpu->txq_get_index];
>                 struct sk_buff *skb = txq_pcpu->tx_skb[txq_pcpu->txq_get_index];
> +               size_t data_size =
> +                       txq_pcpu->tx_data_size[txq_pcpu->txq_get_index];
>
>                 mvpp2_txq_inc_get(txq_pcpu);
>
>                 dma_unmap_single(port->dev->dev.parent, buf_phys_addr,
> -                                skb_headlen(skb), DMA_TO_DEVICE);
> +                                data_size, DMA_TO_DEVICE);
>                 if (!skb)
>                         continue;
>                 dev_kfree_skb_any(skb);
> @@ -4662,6 +4667,11 @@ static int mvpp2_txq_init(struct mvpp2_port *port,
>                 if (!txq_pcpu->tx_buffs)
>                         goto error;
>
> +               txq_pcpu->tx_data_size = kmalloc(txq_pcpu->size *
> +                                                sizeof(size_t), GFP_KERNEL);
> +               if (!txq_pcpu->tx_data_size)
> +                       goto error;
> +
>                 txq_pcpu->count = 0;
>                 txq_pcpu->reserved_num = 0;
>                 txq_pcpu->txq_put_index = 0;
> @@ -4675,6 +4685,7 @@ static int mvpp2_txq_init(struct mvpp2_port *port,
>                 txq_pcpu = per_cpu_ptr(txq->pcpu, cpu);
>                 kfree(txq_pcpu->tx_skb);
>                 kfree(txq_pcpu->tx_buffs);
> +               kfree(txq_pcpu->tx_data_size);
>         }
>
>         dma_free_coherent(port->dev->dev.parent,
> @@ -4695,6 +4706,7 @@ static void mvpp2_txq_deinit(struct mvpp2_port *port,
>                 txq_pcpu = per_cpu_ptr(txq->pcpu, cpu);
>                 kfree(txq_pcpu->tx_skb);
>                 kfree(txq_pcpu->tx_buffs);
> +               kfree(txq_pcpu->tx_data_size);
>         }
>
>         if (txq->descs)
> --
> 2.7.4
>
