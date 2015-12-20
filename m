From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: Re: [PATCH/RFC net-next] ravb: Add dma queue interrupt support
Date: Sun, 20 Dec 2015 18:10:35 +0900
Message-ID: <CAH1o70K87cCy9qyWDjLy=otzhVg7V=znfZNbLV2XcTYyW6didQ@mail.gmail.com>
References: <1450182181-12575-1-git-send-email-ykaneko0929@gmail.com>
	<56706330.2060803@cogentembedded.com>
	<CAH1o70LnEEu3iYos8wsaEZ=T67N+Tex_XHZgE9P93n6X6Bzz4A@mail.gmail.com>
	<5672F423.6010807@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:34313 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754262AbbLTJKg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Dec 2015 04:10:36 -0500
In-Reply-To: <5672F423.6010807@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2015-12-18 2:42 GMT+09:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> Hello.
>
> On 12/17/2015 07:29 PM, Yoshihiro Kaneko wrote:
>
>>>> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>>>
>>>> This patch supports the following interrupts.
>>>>
>>>> - One interrupt for multiple (descriptor, error, management)
>>>> - One interrupt for emac
>>>> - Four interrupts for dma queue (best effort rx/tx, network control
>>>> rx/tx)
>>>
>>>
>>>
>>>     You don't say why the current 2-interrupt scheme (implemented by
>>> Simon's
>>> patch) isn't enpough...
>>>
>>>> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>>>
>>>
>>> [...]
>>>
>>>> diff --git a/drivers/net/ethernet/renesas/ravb.h
>>>> b/drivers/net/ethernet/renesas/ravb.h
>>>> index 9fbe92a..eada5a1 100644
>>>> --- a/drivers/net/ethernet/renesas/ravb.h
>>>> +++ b/drivers/net/ethernet/renesas/ravb.h
>>>> @@ -157,6 +157,7 @@ enum ravb_reg {
>
> [...]
>>>>
>>>> +#define RAVB_RIx2_ALL  0x8003ffff
>>>
>>>
>>>     No prefix. And there's bit 31 in this register, according to my gen3
>>> manual. So, your _ALL isn't really "all bits". I'd rather call it
>>> RIx2_QFx.
>>> Or even RIE2_QFS and RID2_QFD.
>>
>>
>> I think that bit 31 is included in the value 0x8003ffff. Or I'm
>> missing something?
>
>
>    Sorry, I misread the code.
>
>>>> +
>>>> +/* TIx */
>>>
>>>
>>>     TIE/TID.
>>>
>>>> +#define RAVB_TIx_ALL   0x000fffff
>>>
>>>
>>>     No prefix. And there's bit 31 in this register, according to my gen3
>>> manual.
>
>
>    Oops, no bit 31 in these regs.
>
>> So, your _ALL isn't really "all bits".
>>
>> I think the correct value is 0x000f0f0f.
>
>
>    Indeed, please fix.
>
>>> [...]
>>>>
>>>>
>>>> diff --git a/drivers/net/ethernet/renesas/ravb_main.c
>>>> b/drivers/net/ethernet/renesas/ravb_main.c
>>>> index 120cc25..753b67d 100644
>>>> --- a/drivers/net/ethernet/renesas/ravb_main.c
>>>> +++ b/drivers/net/ethernet/renesas/ravb_main.c
>
> [...]
>>>>
>>>> @@ -654,7 +679,7 @@ static int ravb_stop_dma(struct net_device *ndev)
>>>>    }
>>>>
>>>>    /* E-MAC interrupt handler */
>>>> -static void ravb_emac_interrupt(struct net_device *ndev)
>>>> +static void _ravb_emac_interrupt(struct net_device *ndev)
>>>
>>>
>>>
>>>     ravb_emac_interrupt_[un]locked() perhaps? Not sure which is more
>>> correct... :-)
>>
>>
>> How about ravb_process_emac_interrupt() ?
>
>
>    I've made up my mind -- I'd prefer ravb_emac_interrupt_unlocked().

Got it.

>
> [...]
>>>>
>>>> +static irqreturn_t ravb_multi_interrupt(int irq, void *dev_id)
>>>> +{
>>>> +       struct net_device *ndev = dev_id;
>>>> +       struct ravb_private *priv = netdev_priv(ndev);
>>>> +       irqreturn_t result = IRQ_NONE;
>>>> +       u32 iss;
>>>> +
>>>> +       spin_lock(&priv->lock);
>>>> +       /* Get interrupt status */
>>>> +       iss = ravb_read(ndev, ISS);
>>>> +
>>>>          /* Error status summary */
>>>>          if (iss & ISS_ES) {
>>>>                  ravb_error_interrupt(ndev);
>>>>                  result = IRQ_HANDLED;
>>>>          }
>>>>
>>>> +       /* Management */
>>>
>>>
>>>
>>>     Really? I thought that's gPTP Interrupt...
>>
>>
>> gPTP seems to be a part of Management related interrupts.
>
>
>    ISS.CGIM is still described as gPTP interrupt mirror in my gen3 manual.

It is true.
And also gPTP interrupt belongs to the interrupt Group 2, Management
related interrupt.

>
>>>>          if (iss & ISS_CGIS)
>>>>                  result = ravb_ptp_interrupt(ndev);
>>>>
>>>> @@ -776,6 +843,55 @@ static irqreturn_t ravb_interrupt(int irq, void
>>>> *dev_id)
>
> [...]
>
>> Thanks,
>> kaneko
>
>
> MBR, Sergei
>

Thanks,
kaneko
