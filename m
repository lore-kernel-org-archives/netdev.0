From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC v5 net-next] ravb: Add dma queue interrupt support
Date: Wed, 2 Mar 2016 21:42:13 +0300
Message-ID: <56D73405.2060806@cogentembedded.com>
References: <1455478769-16084-1-git-send-email-ykaneko0929@gmail.com>
 <56CA0A68.2020709@cogentembedded.com>
 <CAH1o70+=4s6wueSWpCcMfx+D-CMpU2p5fYVM_CoO2h2_G7bCHA@mail.gmail.com>
 <56D4B02F.7030803@cogentembedded.com>
 <CAH1o70+pr_KGg43TpOf80nraZXC+DGuXE-W5Lo-xLE3CasKe_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	linux-renesas-soc@vger.kernel.org,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:33996 "EHLO
	mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752839AbcCBSmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 13:42:17 -0500
Received: by mail-lf0-f43.google.com with SMTP id l13so29016299lfb.1
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 10:42:16 -0800 (PST)
In-Reply-To: <CAH1o70+pr_KGg43TpOf80nraZXC+DGuXE-W5Lo-xLE3CasKe_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/02/2016 09:32 PM, Yoshihiro Kaneko wrote:

>>>>> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>>>>
>>>>> This patch supports the following interrupts.
>>>>>
>>>>> - One interrupt for multiple (error, gPTP)
>>>>> - One interrupt for emac
>>>>> - Four interrupts for dma queue (best effort rx/tx, network control
>>>>> rx/tx)
>>>>>
>>>>> This patch improve efficiency of the interrupt handler by adding the
>>>>> interrupt handler corresponding to each interrupt source described
>>>>> above. Additionally, it reduces the number of times of the access to
>>>>> EthernetAVB IF.
>>>>> Also this patch prevent this driver depends on the whim of a boot
>>>>> loader.
>>>>>
>>>>> [ykaneko0929@gmail.com: define bit names of registers]
>>>>> [ykaneko0929@gmail.com: add comment for gen3 only registers]
>>>>> [ykaneko0929@gmail.com: fix coding style]
>>>>> [ykaneko0929@gmail.com: update changelog]
>>>>> [ykaneko0929@gmail.com: gen3: fix initialization of interrupts]
>>>>> [ykaneko0929@gmail.com: gen3: fix clearing interrupts]
>>>>> [ykaneko0929@gmail.com: gen3: add helper function for request_irq()]
>>>>> [ykaneko0929@gmail.com: revert ravb_close() and ravb_ptp_stop()]
>>>>> [ykaneko0929@gmail.com: avoid calling free_irq() to non-hooked
>>>>> interrupts]
>>>>> [ykaneko0929@gmail.com: make NC/BE interrupt handler a function]
>>>>> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>>>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
[...]
>>>>> diff --git a/drivers/net/ethernet/renesas/ravb_main.c
>>>>> b/drivers/net/ethernet/renesas/ravb_main.c
>>>>> index c936682..1bec71e 100644
>>>>> --- a/drivers/net/ethernet/renesas/ravb_main.c
>>>>> +++ b/drivers/net/ethernet/renesas/ravb_main.c
[...]
>>>>> @@ -725,31 +787,15 @@ static irqreturn_t ravb_interrupt(int irq, void
>>>>> *dev_id)
>>>>>
>>>>>                   /* Network control and best effort queue RX/TX */
>>>>>                   for (q = RAVB_NC; q >= RAVB_BE; q--) {
>>>>> -                       if (((ris0 & ric0) & BIT(q)) ||
>>>>> -                           ((tis  & tic)  & BIT(q))) {
>>>>> -                               if (napi_schedule_prep(&priv->napi[q]))
>>>>> {
>>>>> -                                       /* Mask RX and TX interrupts */
>>>>> -                                       ric0 &= ~BIT(q);
>>>>> -                                       tic &= ~BIT(q);
>>>>> -                                       ravb_write(ndev, ric0, RIC0);
>>>>> -                                       ravb_write(ndev, tic, TIC);
>>>>> -                                       __napi_schedule(&priv->napi[q]);
>>>>> -                               } else {
>>>>> -                                       netdev_warn(ndev,
>>>>> -                                                   "ignoring interrupt,
>>>>> rx status 0x%08x, rx mask 0x%08x,\n",
>>>>> -                                                   ris0, ric0);
>>>>> -                                       netdev_warn(ndev,
>>>>> -                                                   "
>>>>> tx status 0x%08x, tx mask 0x%08x.\n",
>>>>> -                                                   tis, tic);
>>>>> -                               }
>>>>> +                       if (ravb_nc_be_interrupt(ndev, q, ris0, &ric0,
>>>>> tis,
>>>>> +                                                &tic))
>>>>>                                   result = IRQ_HANDLED;
>>>>> -                       }
>>>>>                   }
>>>>
>>>>      Unroll this *for* loop please...
>>>
>>> OK.
>>
>>     It was a bad idea actually, sorry...
>
> OK, I will revert this part.
> (But I think it is not that bad...)

    I think the loop will scale better if we ever support the AVB queues...

[...]
>>>>> @@ -767,6 +813,73 @@ static irqreturn_t ravb_interrupt(int irq, void
[...]
>>>>> +static irqreturn_t ravb_dmaq_interrupt(int irq, void *dev_id, int
>>>>> ravb_queue)
>>>>
>>>>      Perhaps, ravb_rx_tx_interrupt()?
>>>
>>> Agreed.
>>
>>     And we still have ravb_dma_interrupt() unused, right?
>
> Do you mean that there is an unused "ravb_dma_interrupt()" in this version?
> I probably be misunderstanding something.

    No, I meant that this name isn't used yet.

>> [...]

> Thanks,
> kaneko

MBR, Sergei
