From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: add wake-on-lan support via magic packet
Date: Mon, 12 Dec 2016 20:35:27 +0300
Message-ID: <cadc1263-fc92-175c-6492-b466623c669f@cogentembedded.com>
References: <20161207162843.4731-1-niklas.soderlund+renesas@ragnatech.se>
 <59a1f246-9062-20e1-3f85-a1c5f6fcfc29@cogentembedded.com>
 <20161208145635.GH21834@bigcity.dyn.berto.se>
 <b0bc6386-45ba-2205-6cd4-dce9a1529124@cogentembedded.com>
 <20161212154955.GA17342@bigcity.dyn.berto.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Simon Horman <horms+renesas@verge.net.au>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: =?UTF-8?Q?Niklas_S=c3=b6derlund?= <niklas.soderlund@ragnatech.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:38806 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753660AbcLLRfb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 12:35:31 -0500
Received: by mail-wm0-f43.google.com with SMTP id f82so79527064wmf.1
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2016 09:35:30 -0800 (PST)
In-Reply-To: <20161212154955.GA17342@bigcity.dyn.berto.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/12/2016 06:49 PM, Niklas Söderlund wrote:

> Thanks for your feedback.

    Not at all, it's my duty now. :-)
    I should probably have warned you not to post the new version to netdev -- 
DaveM has closed his net-next.git tree (ahead of the usual time, which would 
have been 4.9 release), so you posting would only upset him...

[...]
>>>>   You only enable the WOL support fo the R-Car gen2 chips but never say that
>>>> explicitly, neither in the subject nor here.
>>>>
>>>>> Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
>>>>> ---
>>>>>  drivers/net/ethernet/renesas/sh_eth.c | 120 +++++++++++++++++++++++++++++++---
>>>>>  drivers/net/ethernet/renesas/sh_eth.h |   4 ++
>>>>>  2 files changed, 116 insertions(+), 8 deletions(-)
>>>>
>>>>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
>>>>> index 05b0dc5..3974046 100644
>>>>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>>>>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
[...]
>>>> +		/* Handle MagicPacket interrupt */
>>>> +		if (sh_eth_read(ndev, ECSR) & ECSR_MPD)
>>
>>    What if it wasn't enabled ATM?
>
> Sorry I don't understand this comment.

    I'm trying to handle only the enabled interrupts but this hasn't been 
consistently done yet (only for EESR, not ECSR), so nevermind. :-)

[...]
>>>>> @@ -3150,15 +3193,71 @@ static int sh_eth_drv_remove(struct platform_device *pdev)
[...]

>>> This is how it's done in
>>> other parts of the driver when disabling interrupts.
>>
>>    Not in all parts of the driver that disable EESIPR interrupts... I must
>> confess that I never liked that 'mdp->irq_enabled' flag and still suspect we
>> can get things done without it... I need to look at this code again, sigh...

    Well, we can't most probably but I have a patch almost ready that turns 
the boolean flag into u32 field holding the EESIPR value to be written next. 
Would that help you?

>>> This is also why I only check for MagicPacket interrupts if irq_enabled
>>> is false.
>>
>>   I would have preferred that this was done with the other EMAC interrupts,
>> in sh_eth_error().
>
> I removed the check for Magic Packet in sh_eth_interrupt() and running
> without setting mdp->irq_enabled = false. sh_eth_error() will then clear
> any ECI interrupt so no need to add Magic Packet detection to it since
> all that is needed on Magic Packet is to clear the interrupt which
> already is done. This works and I can do multiple suspend/resume cycles,
> will be in v2 thanks for the suggestion.

    OK, let's see what you have when I have some more time. We have a lot of 
time for ironing things out till net-next is opened again -- which will happen 
after -rc1)...

[...]
>>>>> +
>>>>> +	/* Enable MagicPacket */
>>>>> +	sh_eth_modify(ndev, ECMR, 0, ECMR_PMDE);
>>>>> +
>>>>> +	/* Increased clock usage so device won't be suspended */
>>>>> +	clk_enable(mdp->clk);
>>>>
>>>>    Hum, intermixiggn runtime PM with clock API doesn't look good...
>>>
>>> I agree it looks weird but I need a way to increment the usage count for
>>> the clock otherwise the PM code will disable the module clock and WoL
>>> will not work.
>>
>>    How will it do it if you don't call sh_eth_close() in this case?
>>
>>> Note that this call will not enable the clock just
>>> increase the usage count so it won't be disabled when the PM code
>>> decrease it after the sh_eth suspend function is run.
>>
>>    You mean that the PM code calls RPM or clk API on its own? That's strange...
>
> Yes it calls clk API.

    Hum, will have to look into it as well...

[...]

MBR, Sergei
