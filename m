From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: Re: [PATCH/RFC v6 net-next] ravb: Add dma queue interrupt support
Date: Thu, 3 Mar 2016 03:16:01 +0900
Message-ID: <CAH1o70JpRZAKSSPGe6MYfw0OGSaC9d7jDd9D71mn9bxLSy3qtQ@mail.gmail.com>
References: <1456674078-1316-1-git-send-email-ykaneko0929@gmail.com>
	<56D4AA63.6030203@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	linux-renesas-soc@vger.kernel.org,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:35204 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230AbcCBSQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 13:16:03 -0500
In-Reply-To: <56D4AA63.6030203@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-03-01 5:30 GMT+09:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> Hello.
>
>
> On 02/28/2016 06:41 PM, Yoshihiro Kaneko wrote:
>
>> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>
>> This patch supports the following interrupts.
>>
>> - One interrupt for multiple (timestamp, error, gPTP)
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
>> [ykaneko0929@gmail.com: gen3: remove IRQF_SHARED flag for request_irq()]
>> [ykaneko0929@gmail.com: revert ravb_close() and ravb_ptp_stop()]
>> [ykaneko0929@gmail.com: avoid calling free_irq() to non-hooked interrupts]
>> [ykaneko0929@gmail.com: make NC/BE interrupt handler a function]
>> [ykaneko0929@gmail.com: make timestamp interrupt handler a function]
>> [ykaneko0929@gmail.com: timestamp interrupt is handled in multiple
>>   interrupt handler instead of dma queue interrupt handler]
>> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>
>
>    OK, you are very close now! Just a few comments...
>
> [...]
>>
>> diff --git a/drivers/net/ethernet/renesas/ravb_main.c
>> b/drivers/net/ethernet/renesas/ravb_main.c
>> index c936682..22ef65d 100644
>> --- a/drivers/net/ethernet/renesas/ravb_main.c
>> +++ b/drivers/net/ethernet/renesas/ravb_main.c
>
> [...]
>>
>> @@ -697,6 +726,47 @@ static void ravb_error_interrupt(struct net_device
>> *ndev)
>>         }
>>   }
>>
>> +static bool ravb_queue_interrupt(struct net_device *ndev, int q,
>> +                                u32 ris0, u32 *ric0, u32 tis, u32 *tic)
>> +{
>> +       struct ravb_private *priv = netdev_priv(ndev);
>> +
>
>
>    Perhaps it makes sense to read the RI[CS]0/TI[CS] here instead of passing
> them (by reference)?

OK, I will do.

>
> [...]
>
>> @@ -714,42 +784,21 @@ static irqreturn_t ravb_interrupt(int irq, void
>> *dev_id)
>>                 u32 ric0 = ravb_read(ndev, RIC0);
>>                 u32 tis  = ravb_read(ndev, TIS);
>>                 u32 tic  = ravb_read(ndev, TIC);
>> -               int q;
>>
>>                 /* Timestamp updated */
>> -               if (tis & TIS_TFUF) {
>> -                       ravb_write(ndev, ~TIS_TFUF, TIS);
>> -                       ravb_get_tx_tstamp(ndev);
>> +               if (ravb_timestamp_interrupt(ndev, tis))
>>                         result = IRQ_HANDLED;
>> -               }
>>
>>                 /* Network control and best effort queue RX/TX */
>> -               for (q = RAVB_NC; q >= RAVB_BE; q--) {
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
>> -                               result = IRQ_HANDLED;
>> -                       }
>> -               }
>> +               if (ravb_queue_interrupt(ndev, RAVB_NC, ris0, &ric0, tis,
>> &tic))
>> +                       result = IRQ_HANDLED;
>> +               if (ravb_queue_interrupt(ndev, RAVB_BE, ris0, &ric0, tis,
>> &tic))
>> +                       result = IRQ_HANDLED;
>
>
>    Hmm, perhaps unrolling wasn't such a great idea... we can't use || here
> as it would be short-circuited. :-(
>
> [...]
>>
>> +static irqreturn_t ravb_rx_tx_interrupt(int irq, void *dev_id, int
>> ravb_queue)
>
>
>    Please, please shorten this 'ravb_queue'...

I will fix it.

>    Also, would make sense to rename it to ravb_dma_interrupt()...

I have renamed it from ravb_dmaq_interrupt() in this version as you
suggested in the previous review. Did you not mean it?

>
> [...]
>
>    Unfortunately, I still can't do a full gen2 regression testing as both
> Alt and Porter boards don't work with the recent kernel due to AVB_MDIO
> stuck at 1... But perhaps such testing isn't even necessary.
>
> MBR, Sergei
>

Thanks,
kaneko
