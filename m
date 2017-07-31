From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [RFC PATCH v1] net: ethernet: nb8800: Reset HW block in ndo_open
Date: Mon, 31 Jul 2017 16:28:14 +0100
Message-ID: <yw1xo9s0iq29.fsf@mansr.com>
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
        <b1a6cd1d-ce02-708f-6c8e-defe0d8f3cd8@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:56252 "EHLO unicorn.mansr.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752096AbdGaP2P (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Jul 2017 11:28:15 -0400
In-Reply-To: <b1a6cd1d-ce02-708f-6c8e-defe0d8f3cd8@free.fr> (Mason's message
        of "Mon, 31 Jul 2017 17:18:02 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mason <slash.tmp@free.fr> writes:

> On 31/07/2017 16:08, Mason wrote:
>
>> Other things make no sense to me, for example in nb8800_dma_stop()
>> there is a polling loop:
>> 
>> 	do {
>> 		mdelay(100);
>> 		nb8800_writel(priv, NB8800_TX_DESC_ADDR, txb->dma_desc);
>> 		wmb();
>> 		mdelay(100);
>> 		nb8800_writel(priv, NB8800_TXC_CR, txcr | TCR_EN);
>> 
>> 		mdelay(5500);
>> 
>> 		err = readl_poll_timeout_atomic(priv->base + NB8800_RXC_CR,
>> 						rxcr, !(rxcr & RCR_EN),
>> 						1000, 100000);
>> 		printk("err=%d retry=%d\n", err, retry);
>> 	} while (err && --retry);
>> 
>> 
>> (It was me who added the delays.)
>> 
>> *Whatever* delays I insert, it always goes 3 times through the loop.
>> 
>> [   29.654492] ++ETH++ gw32 reg=f002610c val=9ecc8000
>> [   29.759320] ++ETH++ gw32 reg=f0026100 val=005c0aff
>> [   35.364705] err=-110 retry=5
>> [   35.467609] ++ETH++ gw32 reg=f002610c val=9ecc8000
>> [   35.572436] ++ETH++ gw32 reg=f0026100 val=005c0aff
>> [   41.177822] err=-110 retry=4
>> [   41.280726] ++ETH++ gw32 reg=f002610c val=9ecc8000
>> [   41.385553] ++ETH++ gw32 reg=f0026100 val=005c0aff
>> [   46.890907] err=0 retry=3
>> 
>> How is that possible?
>
> First time through the loop, it doesn't matter how long we poll,
> it *always* times out. Second time as well (only on BOARD B).
>
> Third time, it succeeds quickly (first or second poll).
> (This explains why various delays had no impact.)
>
> In fact, requesting the transfer 3 times *before* polling
> makes the polling succeed quickly:
>
> 	nb8800_writel(priv, NB8800_TX_DESC_ADDR, txb->dma_desc);
> 	wmb();
> 	nb8800_writel(priv, NB8800_TXC_CR, txcr | TCR_EN);
>
> [   16.464596] ++ETH++ gw32 reg=f002610c val=9ef28000
> [   16.469414] ++ETH++ gw32 reg=f0026100 val=005c0aff
> [   16.474231] ++ETH++ gw32 reg=f002610c val=9ef28000
> [   16.479048] ++ETH++ gw32 reg=f0026100 val=005c0aff
> [   16.483865] ++ETH++ gw32 reg=f002610c val=9ef28000
> [   16.488682] ++ETH++ gw32 reg=f0026100 val=005c0aff
> [   16.493500] ++ETH++ POLL reg=f0026200 val=06100a8f
> [   16.499317] ++ETH++ POLL reg=f0026200 val=06100a8e
> [   16.504134] err=0 retry=5

That strengthens my theory that the hardware has an internal queue of
three descriptors that are pre-loaded from memory.  Your hardware people
should be able to confirm this.

> With my changes, I get *exactly* the same logs on BOARD A
> and BOARD B (modulo the descriptors addresses).
>
> Yet BOARD A stays functional, but BOARD B is hosed...

What's the difference between board A and board B?

> Depressing. I've run out of ideas.

Get your hardware people involved.  Perhaps they can run some test in a
simulator.

-- 
Måns Rullgård
