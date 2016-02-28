From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: Re: [PATCH/RFC v5 net-next] ravb: Add dma queue interrupt support
Date: Sun, 28 Feb 2016 23:13:34 +0900
Message-ID: <CAH1o70+=4s6wueSWpCcMfx+D-CMpU2p5fYVM_CoO2h2_G7bCHA@mail.gmail.com>
References: <1455478769-16084-1-git-send-email-ykaneko0929@gmail.com>
	<56CA0A68.2020709@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	linux-renesas-soc@vger.kernel.org,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:33433 "EHLO
	mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757489AbcB1ONf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2016 09:13:35 -0500
In-Reply-To: <56CA0A68.2020709@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-02-22 4:05 GMT+09:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> On 02/14/2016 10:39 PM, Yoshihiro Kaneko wrote:
>
>> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>
>> This patch supports the following interrupts.
>>
>> - One interrupt for multiple (error, gPTP)
>> - One interrupt for emac
>> - Four interrupts for dma queue (best effort rx/tx, network control rx/tx)
>>
>> This patch improve efficiency of the interrupt handler by adding the
>> interrupt handler corresponding to each interrupt source described
>> above. Additionally, it reduces the number of times of the access to
>> EthernetAVB IF.
>> Also this patch prevent this driver depends on the whim of a boot loader.
>>
>> [ykaneko0929@gmail.com: define bit names of registers]
>> [ykaneko0929@gmail.com: add comment for gen3 only registers]
>> [ykaneko0929@gmail.com: fix coding style]
>> [ykaneko0929@gmail.com: update changelog]
>> [ykaneko0929@gmail.com: gen3: fix initialization of interrupts]
>> [ykaneko0929@gmail.com: gen3: fix clearing interrupts]
>> [ykaneko0929@gmail.com: gen3: add helper function for request_irq()]
>> [ykaneko0929@gmail.com: revert ravb_close() and ravb_ptp_stop()]
>> [ykaneko0929@gmail.com: avoid calling free_irq() to non-hooked interrupts]
>> [ykaneko0929@gmail.com: make NC/BE interrupt handler a function]
>> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>
>
> [...]
>
>> diff --git a/drivers/net/ethernet/renesas/ravb_main.c
>> b/drivers/net/ethernet/renesas/ravb_main.c
>> index c936682..1bec71e 100644
>> --- a/drivers/net/ethernet/renesas/ravb_main.c
>> +++ b/drivers/net/ethernet/renesas/ravb_main.c
>
> [...]
>>
>> @@ -697,6 +726,39 @@ static void ravb_error_interrupt(struct net_device
>> *ndev)
>>         }
>>   }
>>
>> +static int ravb_nc_be_interrupt(struct net_device *ndev, int ravb_queue,
>
>
>    I'd call this function e.g. ravb_queue_interrupt(). And make it return
> 'bool' or even 'irqreturn_t' directly. And I'd suggest a shorter name for
> the 'ravb_queue' parameter, like 'queue' or even 'q'...

Agreed.

>
>> +                               u32 ris0, u32 *ric0, u32 tis, u32 *tic)
>
>
>    You don't seem to need 'ric0' and 'tic' past the call sites, so no real
> need to pass them by reference.

When Rx/Tx interrupt for NC and BE is issued at the same time,
this function is called twice (for NC, BE) from ravb_interrupt.
The interrupt mask of NC set in the first call will be reset in the next
call for BE. So it is necessary to keep the modified value of "ric0" and
"tic".

>
> [...]
>>
>> @@ -725,31 +787,15 @@ static irqreturn_t ravb_interrupt(int irq, void
>> *dev_id)
>>
>>                 /* Network control and best effort queue RX/TX */
>>                 for (q = RAVB_NC; q >= RAVB_BE; q--) {
>> -                       if (((ris0 & ric0) & BIT(q)) ||
>> -                           ((tis  & tic)  & BIT(q))) {
>> -                               if (napi_schedule_prep(&priv->napi[q])) {
>> -                                       /* Mask RX and TX interrupts */
>> -                                       ric0 &= ~BIT(q);
>> -                                       tic &= ~BIT(q);
>> -                                       ravb_write(ndev, ric0, RIC0);
>> -                                       ravb_write(ndev, tic, TIC);
>> -                                       __napi_schedule(&priv->napi[q]);
>> -                               } else {
>> -                                       netdev_warn(ndev,
>> -                                                   "ignoring interrupt,
>> rx status 0x%08x, rx mask 0x%08x,\n",
>> -                                                   ris0, ric0);
>> -                                       netdev_warn(ndev,
>> -                                                   "
>> tx status 0x%08x, tx mask 0x%08x.\n",
>> -                                                   tis, tic);
>> -                               }
>> +                       if (ravb_nc_be_interrupt(ndev, q, ris0, &ric0,
>> tis,
>> +                                                &tic))
>>                                 result = IRQ_HANDLED;
>> -                       }
>>                 }
>
>
>    Unroll this *for* loop please...

OK.

>
>>         }
>
> [...]
>>
>> @@ -767,6 +813,73 @@ static irqreturn_t ravb_interrupt(int irq, void
>> *dev_id)
>>         return result;
>>   }
>>
>> +/* Descriptor IRQ/Error/Management interrupt handler */
>
>
>    You don't handle the descriptor interrupt, do you?

Oops. I will fix this.

>
>> +static irqreturn_t ravb_multi_interrupt(int irq, void *dev_id)
>
> [...]
>>
>> +static irqreturn_t ravb_dmaq_interrupt(int irq, void *dev_id, int
>> ravb_queue)
>
>
>    Perhaps, ravb_rx_tx_interrupt()?

Agreed.

>
>> +{
>> +       struct net_device *ndev = dev_id;
>> +       struct ravb_private *priv = netdev_priv(ndev);
>> +       irqreturn_t result = IRQ_NONE;
>> +       u32 ris0, ric0, tis, tic;
>> +
>> +       spin_lock(&priv->lock);
>> +
>> +       ris0 = ravb_read(ndev, RIS0);
>> +       ric0 = ravb_read(ndev, RIC0);
>> +       tis  = ravb_read(ndev, TIS);
>> +       tic  = ravb_read(ndev, TIC);
>> +
>> +       /* Timestamp updated */
>> +       if (tis & TIS_TFUF) {
>> +               ravb_write(ndev, ~TIS_TFUF, TIS);
>> +               ravb_get_tx_tstamp(ndev);
>> +               result = IRQ_HANDLED;
>> +       }
>
>
>    Hm, why this interrupt is handled here? It has no relation to the TX
> queues; the manual says it belongs to group 2 (management related
> interrupts), and should probably be routed to ch22. Sorry for not noticing
> this before...

Nice catch.
I will move this handler into ravb_multi_interrupt().
And I will make the handler a function.

>
> [...]
>>
>> @@ -1208,29 +1326,66 @@ static const struct ethtool_ops ravb_ethtool_ops =
>> {
>
> [...]
>>
>> @@ -1257,8 +1412,17 @@ out_ptp_stop:
>>         if (priv->chip_id == RCAR_GEN2)
>>                 ravb_ptp_stop(ndev);
>>   out_free_irq2:
>
>
>    Rename to 'out_free_irq_nc_tx' please.

Sure, will do.

>
>> -       if (priv->chip_id == RCAR_GEN3)
>> -               free_irq(priv->emac_irq, ndev);
>> +       if (priv->chip_id == RCAR_GEN2)
>> +               goto out_free_irq;
>
>
>
>
>> +       free_irq(priv->tx_irqs[RAVB_NC], ndev);
>> +out_free_irq_nc_rx:
>> +       free_irq(priv->rx_irqs[RAVB_NC], ndev);
>> +out_free_irq_be_tx:
>> +       free_irq(priv->tx_irqs[RAVB_BE], ndev);
>> +out_free_irq_be_rx:
>> +       free_irq(priv->rx_irqs[RAVB_BE], ndev);
>> +out_free_irq_emac:
>> +       free_irq(priv->emac_irq, ndev);
>>   out_free_irq:
>>         free_irq(ndev->irq, ndev);
>>   out_napi_off:
>
>
>    Seems correct now, thanks.
>
> [...]
>>
>> diff --git a/drivers/net/ethernet/renesas/ravb_ptp.c
>> b/drivers/net/ethernet/renesas/ravb_ptp.c
>> index 57992cc..7cb1cc4 100644
>> --- a/drivers/net/ethernet/renesas/ravb_ptp.c
>> +++ b/drivers/net/ethernet/renesas/ravb_ptp.c
>> @@ -194,7 +194,14 @@ static int ravb_ptp_extts(struct ptp_clock_info *ptp,
>>         priv->ptp.extts[req->index] = on;
>>
>>         spin_lock_irqsave(&priv->lock, flags);
>> -       ravb_modify(ndev, GIC, GIC_PTCE, on ? GIC_PTCE : 0);
>> +       if (priv->chip_id == RCAR_GEN2) {
>> +               ravb_modify(ndev, GIC, GIC_PTCE, on ? GIC_PTCE : 0);
>> +       } else {
>> +               if (on)
>
>
>    Could be folded into one line with one less tab for the indentation below
> and no {} whatsoever...

OK.

>
>> +                       ravb_write(ndev, GIE_PTCS, GIE);
>> +               else
>> +                       ravb_write(ndev, GID_PTCD, GID);
>> +       }
>>         mmiowb();
>>         spin_unlock_irqrestore(&priv->lock, flags);
>>
> [...]
>
> MBR, Sergei
>

Thanks,
kaneko
