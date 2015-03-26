From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net-next 3/7] net: bcmgenet: simplify bcmgenet_init_dma()
Date: Thu, 26 Mar 2015 10:56:17 -0700
Message-ID: <CAGXr9JH8UFoOs1btdvtbr_ed6_pjY7Fp48okhioKkA2NwdjF_w@mail.gmail.com>
References: <20150325193511.F0B1E2201FB@puck.mtv.corp.google.com>
	<C72C3DD6-8BD6-4204-8085-8DE4AA9DAF71@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Jaedon Shin <jaedon.shin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:33398 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752473AbbCZR4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 13:56:52 -0400
Received: by qgfa8 with SMTP id a8so103180438qgf.0
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 10:56:52 -0700 (PDT)
In-Reply-To: <C72C3DD6-8BD6-4204-8085-8DE4AA9DAF71@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jaedon,

On Wed, Mar 25, 2015 at 7:34 PM, Jaedon Shin <jaedon.shin@gmail.com> wrote:
>
>> On Mar 26, 2015, at 4:35 AM, Petri Gynther <pgynther@google.com> wrote:
>>
>> Do the two kcalloc() calls first, before proceeding into Rx/Tx DMA init.
>> Makes the error case handling much simpler.
>>
>> Signed-off-by: Petri Gynther <pgynther@google.com>
>> ---
>> drivers/net/ethernet/broadcom/genet/bcmgenet.c | 33 +++++++++++++-------------
>> 1 file changed, 17 insertions(+), 16 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> index 550bf98..1c9f9b4 100644
>> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> @@ -2050,9 +2050,6 @@ static int bcmgenet_init_dma(struct bcmgenet_priv *priv)
>>
>>       netif_dbg(priv, hw, priv->dev, "%s\n", __func__);
>>
>> -     /* Init rDma */
>> -     bcmgenet_rdma_writel(priv, DMA_MAX_BURST_LENGTH, DMA_SCB_BURST_SIZE);
>> -
>>       /* Initialize common Rx ring structures */
>>       priv->rx_bds = priv->base + priv->hw_params->rdma_offset;
>>       priv->num_rx_bds = TOTAL_DESC;
>> @@ -2066,25 +2063,13 @@ static int bcmgenet_init_dma(struct bcmgenet_priv *priv)
>>               cb->bd_addr = priv->rx_bds + i * DMA_DESC_SIZE;
>>       }
>>
>> -     /* Initialize Rx queues */
>> -     ret = bcmgenet_init_rx_queues(priv->dev);
>> -     if (ret) {
>> -             netdev_err(priv->dev, "failed to initialize Rx queues\n");
>> -             bcmgenet_free_rx_buffers(priv);
>> -             kfree(priv->rx_cbs);
>> -             return ret;
>> -     }
>> -
>> -     /* Init tDma */
>> -     bcmgenet_tdma_writel(priv, DMA_MAX_BURST_LENGTH, DMA_SCB_BURST_SIZE);
>> -
>>       /* Initialize common TX ring structures */
>>       priv->tx_bds = priv->base + priv->hw_params->tdma_offset;
>>       priv->num_tx_bds = TOTAL_DESC;
>>       priv->tx_cbs = kcalloc(priv->num_tx_bds, sizeof(struct enet_cb),
>>                              GFP_KERNEL);
>>       if (!priv->tx_cbs) {
>> -             __bcmgenet_fini_dma(priv);
>
> __bcmgenet_fini_dma that may be integrated with bcmgenet_fini_dma not used in bcmgenet_init_dma.
>

I'll remove __bcmgenet_fini_dma() after this patch set has been applied.

> Reviewed-by: Jaedon Shin <jaedon.shin@gmail.com>
>
>> +             kfree(priv->rx_cbs);
>>               return -ENOMEM;
>>       }
>>
>> @@ -2093,6 +2078,22 @@ static int bcmgenet_init_dma(struct bcmgenet_priv *priv)
>>               cb->bd_addr = priv->tx_bds + i * DMA_DESC_SIZE;
>>       }
>>
>> +     /* Init rDma */
>> +     bcmgenet_rdma_writel(priv, DMA_MAX_BURST_LENGTH, DMA_SCB_BURST_SIZE);
>> +
>> +     /* Initialize Rx queues */
>> +     ret = bcmgenet_init_rx_queues(priv->dev);
>> +     if (ret) {
>> +             netdev_err(priv->dev, "failed to initialize Rx queues\n");
>> +             bcmgenet_free_rx_buffers(priv);
>> +             kfree(priv->rx_cbs);
>> +             kfree(priv->tx_cbs);
>> +             return ret;
>> +     }
>> +
>> +     /* Init tDma */
>> +     bcmgenet_tdma_writel(priv, DMA_MAX_BURST_LENGTH, DMA_SCB_BURST_SIZE);
>> +
>>       /* Initialize Tx queues */
>>       bcmgenet_init_tx_queues(priv->dev);
>>
>> --
>> 2.2.0.rc0.207.ga3a616c
>>
>
