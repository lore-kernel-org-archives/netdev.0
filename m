From: Michele Baldessari <michele@acksyn.org>
Subject: Re: Bug - regression - Via velocity interface coming up freezes
 kernel
Date: Mon, 11 Nov 2013 23:46:56 +0000
Message-ID: <20131111234656.GA4846@marquez.int.rhx>
References: <CAFES+i+OYq_dDtEqAqkW7qYDrtdzkqc9hBGBDODQuqgvFJE7zg@mail.gmail.com>
 <20130922221109.GA14246@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dirk Kraft <dirk.kraft@gmail.com>, netdev@vger.kernel.org,
	Julia Lawall <Julia.Lawall@lip6.fr>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palahniuk.acksyn.org ([5.9.7.26]:45553 "EHLO
	palahniuk.acksyn.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753583Ab3KKX5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 18:57:23 -0500
Content-Disposition: inline
In-Reply-To: <20130922221109.GA14246@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Francois,

On Mon, Sep 23, 2013 at 12:11:09AM +0200, Francois Romieu wrote:
> Dirk Kraft <dirk.kraft@gmail.com> :
> [...]
> > I observe problems with my machine freezing when bringing up the
> > network interface (via velocity based). Detailed report below.
> > 
> > First message was rejected because of html. Julia Lawall, sorry about
> > sending multiple copies.
> > 
> > [1.] One line summary of the problem:
> > Via_velocity interface coming up freezes kernel - WARNING: CPU: 0 PID:
> > 1529 at /build/buildd/linux-3.11.0/kernel/softirq.c:159
> > local_bh_enable+0x60/0x90()
> 
> netif_receive_skb with irq disabled ?
> 
> You can try this one as a wild guess before I have more time to analyze.
> 
> diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
> index d022bf9..64c42be 100644
> --- a/drivers/net/ethernet/via/via-velocity.c
> +++ b/drivers/net/ethernet/via/via-velocity.c
> @@ -2172,16 +2172,13 @@ static int velocity_poll(struct napi_struct *napi, int budget)
>  	unsigned int rx_done;
>  	unsigned long flags;
>  
> -	spin_lock_irqsave(&vptr->lock, flags);
>  	/*
>  	 * Do rx and tx twice for performance (taken from the VIA
>  	 * out-of-tree driver).
>  	 */
> -	rx_done = velocity_rx_srv(vptr, budget / 2);
> -	velocity_tx_srv(vptr);
> -	rx_done += velocity_rx_srv(vptr, budget - rx_done);
> +	rx_done = velocity_rx_srv(vptr, budget);
> +	spin_lock_irqsave(&vptr->lock, flags);
>  	velocity_tx_srv(vptr);
> -
>  	/* If budget not fully consumed, exit the polling mode */
>  	if (rx_done < budget) {
>  		napi_complete(napi);

any chance you can submit this officially? Or does this patch need some
more work?

Two people confirmed it fixed the issue for them on netdev and one
on Fedora's bugzilla so far.

Thanks,
Michele
-- 
Michele Baldessari            <michele@acksyn.org>
C2A5 9DA3 9961 4FFB E01B  D0BC DDD4 DCCB 7515 5C6D
