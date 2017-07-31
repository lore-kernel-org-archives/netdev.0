From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [RFC PATCH v1] net: ethernet: nb8800: Reset HW block in ndo_open
Date: Mon, 31 Jul 2017 16:18:42 +0100
Message-ID: <yw1xshhciqi5.fsf@mansr.com>
References: <823b1540-b528-bbd7-7f99-5dc39a08868a@sigmadesigns.com>
        <yw1xk22slemx.fsf@mansr.com>
        <c1bf54ee-8634-23a1-abda-55bc3fafe2a8@sigmadesigns.com>
        <yw1xfudgl7am.fsf@mansr.com>
        <446e3a95-80c3-0742-9cb1-69a8dfc9b1ae@free.fr>
        <yw1x7eyrlc3s.fsf@mansr.com>
        <f04a0cba-6c09-e9e4-f2d1-d8b2a7e276c9@free.fr>
        <4ff343de-41c7-c309-04dc-983b5fe3e066@gmail.com>
        <a5ef2294-2adf-743b-f877-144a8f3958b4@free.fr>
        <yw1x60e8kebc.fsf@mansr.com>
        <31792688-7720-1d1e-4fd4-a0f96ac8af59@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:56200 "EHLO unicorn.mansr.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752156AbdGaPSp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Jul 2017 11:18:45 -0400
In-Reply-To: <31792688-7720-1d1e-4fd4-a0f96ac8af59@free.fr> (Mason's message
        of "Mon, 31 Jul 2017 16:08:31 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mason <slash.tmp@free.fr> writes:

> On 31/07/2017 13:59, Måns Rullgård wrote:
>
>> Mason writes:
>> 
>>> On 29/07/2017 17:18, Florian Fainelli wrote:
>>>
>>>> On 07/29/2017 05:02 AM, Mason wrote:
>>>>
>>>>> I have identified a 100% reproducible flaw.
>>>>> I have proposed a work-around that brings this down to 0
>>>>> (tested 1000 cycles of link up / ping / link down).
>>>>
>>>> Can you also try to get help from your HW resources to eventually help
>>>> you find out what is going on here?
>>>
>>> The patch I proposed /is/ based on the feedback from the HW team :-(
>>> "Just reset the HW block, and everything will work as expected."
>> 
>> Nobody is saying a reset won't recover the lockup.  The problem is that
>> we don't know what caused it to lock up in the first place.  How do we
>> know it can't happen during normal operation?  If we knew the cause, it
>> might also be possible to avoid the situation entirely.
>
> How does one prove that something "can't happen during normal operation"?

One figures out what conditions cause the something and ensures they
never arise.

> The "put adapter in loop-back mode so we can send ourselves fake packets"
> shenanigans seems completely insane, if you ask me.

Blame the hardware designers.  The *only* way to stop the rx dma is to
have it receive a packet into a descriptor with the end of chain flag
set.  Thankfully the loopback mode means this can be made to happen at
will rather than waiting for actual network traffic.

> Other things make no sense to me, for example in nb8800_dma_stop()
> there is a polling loop:
>
> 	do {
> 		mdelay(100);
> 		nb8800_writel(priv, NB8800_TX_DESC_ADDR, txb->dma_desc);
> 		wmb();
> 		mdelay(100);
> 		nb8800_writel(priv, NB8800_TXC_CR, txcr | TCR_EN);
>
> 		mdelay(5500);
>
> 		err = readl_poll_timeout_atomic(priv->base + NB8800_RXC_CR,
> 						rxcr, !(rxcr & RCR_EN),
> 						1000, 100000);
> 		printk("err=%d retry=%d\n", err, retry);
> 	} while (err && --retry);
>
> (It was me who added the delays.)
>
> *Whatever* delays I insert, it always goes 3 times through the loop.
>
> [   29.654492] ++ETH++ gw32 reg=f002610c val=9ecc8000
> [   29.759320] ++ETH++ gw32 reg=f0026100 val=005c0aff
> [   35.364705] err=-110 retry=5
> [   35.467609] ++ETH++ gw32 reg=f002610c val=9ecc8000
> [   35.572436] ++ETH++ gw32 reg=f0026100 val=005c0aff
> [   41.177822] err=-110 retry=4
> [   41.280726] ++ETH++ gw32 reg=f002610c val=9ecc8000
> [   41.385553] ++ETH++ gw32 reg=f0026100 val=005c0aff
> [   46.890907] err=0 retry=3
>
> How is that possible?

One possibility is that the hardware loads three descriptors in advance
and doesn't see the newly set end of chain flag until its internal queue
has been used up.

> I've tried using spinlocks and delays to get parallel execution
> down to a minimum, and have the same logs on both boards.
>
> Regards.

-- 
Måns Rullgård
