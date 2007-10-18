From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: Add napi_sycnhronize() to sync with napi poll
Date: Wed, 17 Oct 2007 20:02:03 -0500
Message-ID: <1192669323.13993.33.camel@localhost.localdomain>
References: <1192513792.19073.23.camel@pasglop>
	 <20071016115318.0fc36af3@freepuppy.rosehill>
	 <1192589522.11899.130.camel@pasglop> <47157EA4.1000500@garzik.org>
	 <1192591481.11899.134.camel@pasglop>
	 <20071017083107.6a1b1bd3@freepuppy.rosehill>
	 <1192658654.6783.43.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:45870 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760005AbXJRBPv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 21:15:51 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9I1Fo3A023196
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 21:15:50 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9I1FoIw046844
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 21:15:50 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9I1FdMm031720
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 21:15:40 -0400
In-Reply-To: <1192658654.6783.43.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-10-18 at 08:04 +1000, Benjamin Herrenschmidt wrote:
> net: Add __napi_synchronize() to sync with napi poll
> 
> The EMAC driver which needs to handle multiple devices with one
> NAPI instance implements its own per-channel disable bit. However,
> when setting such a bit, it needs to synchronize with the poller
> (that is make sure that any pending poller instance has completed,
> or is started late enough to see that disable bit).
> 
> This implements a low level __napi_synchronize() function to acheive
> that. The underscores are to emphasis the low level aspect of it and
> to discourage driver writers who don't know what they are doing to
> use it (to please DaveM :-)
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

Ok, trying again, leaving the actual patch below.  In the above patch
description, you still call it __napi_synchronize.  In the patch below,
it's napi_syncronize.

I was just trying to point out to whomever commits this patch that the
actual description should probably be fixed.

> ---
> 
> Back to msleep() since it fits my need well and that's what
> you used as well. Note that the smp_mb() will turn into barrier()
> on non-SMP.
> 
> I'll send a separate patch to fix EMAC to use the non __ version.
> 
> Index: linux-work/include/linux/netdevice.h
> ===================================================================
> --- linux-work.orig/include/linux/netdevice.h	2007-10-17 13:31:32.000000000 +1000
> +++ linux-work/include/linux/netdevice.h	2007-10-18 08:01:05.000000000 +1000
> @@ -394,6 +394,23 @@ static inline void napi_disable(struct n
>  }
> 
>  /**
> + *	napi_synchronize - synchronize with a concurrent poll
> + *	@n: napi context
> + *
> + * Synchronizes with a concurrent poll. Not to be used in normal
> + * drivers, mostly useful if you end up with multiple interfaces
> + * on one NAPI instance. This must be called from task context.
> + */
> +static inline void napi_synchronize(struct napi_struct *n)
> +{
> +	smp_mb();
> +#ifdef CONFIG_SMP
> +	while (test_bit(NAPI_STATE_SCHED, &n->state))
> +		msleep(1);
> +#endif /* CONFIG_SMP */
> +}
> +
> +/**
>   *	napi_enable - enable NAPI scheduling
>   *	@n: napi context
>   *
> 
> 
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@ozlabs.org
> https://ozlabs.org/mailman/listinfo/linuxppc-dev

