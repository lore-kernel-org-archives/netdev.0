From: Patrick McHardy <kaber@trash.net>
Subject: Re: Problem with VLANs and via-velocity driver
Date: Thu, 11 Feb 2010 17:59:23 +0100
Message-ID: <4B74376B.2090400@trash.net>
References: <20091113033217.GQ838@cubit> <4AFCFF67.3060802@trash.net>	 <20091116005750.GR838@cubit> <loom.20100210T171704-457@post.gmane.org>	 <4B72E2FC.1060003@trash.net> <2ab8a3251002110850k2def5137qb791b100145a3bd2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tiago Pierezan Camargo <tcamargo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46044 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753075Ab0BKQ7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 11:59:25 -0500
In-Reply-To: <2ab8a3251002110850k2def5137qb791b100145a3bd2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tiago Pierezan Camargo wrote:
> Patrick McHardy <kaber <at> trash.net> writes:
>>> ...
>>>
>>> Any suggestions?
>> This should be fixed in the driver as discussed previously.
> 
> Well, the following patch completely disables hw vlan filtering
> (against 2.6.31).

You should CC the maintainer(s).

> --- ../via_kernel_org/via-velocity.c	2010-02-10 11:45:14.000000000 -0200
> +++ via-velocity.c	2010-02-11 11:24:37.000000000 -0200
> @@ -607,9 +607,10 @@
>  {
>  	struct mac_regs __iomem * regs = vptr->mac_regs;
> 
> -	/* Turn on MCFG_PQEN, turn off MCFG_RTGOPT */
> -	WORD_REG_BITS_SET(MCFG_PQEN, MCFG_RTGOPT, &regs->MCFG);
> -	WORD_REG_BITS_ON(MCFG_VIDFR, &regs->MCFG);
> +	/* Completely disable vlan filtering */
> +	WORD_REG_BITS_OFF(MCFG_PQEN, &regs->MCFG);
> +	WORD_REG_BITS_OFF(MCFG_VIDFR, &regs->MCFG);
> +	WORD_REG_BITS_OFF(MCFG_RTGOPT, &regs->MCFG);
> 
>  	/* Disable all CAMs */
>  	memset(vptr->vCAMmask, 0, sizeof(u8) * 8);
> @@ -1406,7 +1407,7 @@
>  		/*
>  		 *	Don't drop CE or RL error frame although RXOK is off
>  		 */
> -		if (rd->rdesc0.RSR & (RSR_RXOK | RSR_CE | RSR_RL)) {
> +		if (rd->rdesc0.RSR & (RSR_RXOK | RSR_CE | RSR_RL | RSR_VIDM)) {
>  			if (velocity_receive_frame(vptr, rd_curr) < 0)
>  				stats->rx_dropped++;
> 
> I know it's not the best solution. I can come up with a better patch
> but I'm a bit confused about the expected behavior.
> 
> - Should we only disable vlan filtering when promiscuous mode is
> enabled? (should we care about hw tag stripping?)

Filtering should be disabled in promiscous mode, stripping can
stay enabled.

> - Should we disable vlan filtering entirely and let the software deal
> with it? (this seems to be the semantics implemented in the freebsd
> driver)

That doesn't seem like a good idea. Basically what it should do
is:

- when no VLANs are configured locally and promiscous mode is
  disabled, all VLANs can be filtered

- when local VLANs are configured, these specific VLANs should be
  accepted

- in promiscous mode, all filters should be disabled
