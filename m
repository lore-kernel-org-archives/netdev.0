From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] net: via-velocity.c fix sleep-with-spinlock bug during
 MTU change
Date: Tue, 3 Jun 2008 13:40:19 -0700
Message-ID: <20080603134019.df2f51d4.akpm@linux-foundation.org>
References: <20080531184615.350bac00@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alan@redhat.com, romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54934 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759392AbYFCUlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 16:41:22 -0400
In-Reply-To: <20080531184615.350bac00@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 31 May 2008 18:46:15 -0700
Arjan van de Ven <arjan@infradead.org> wrote:

> 
> From: Arjan van de Ven <arjan@linux.intel.com>
> Subject: [PATCH] net: via-velocity.c fix sleep-with-spinlock bug during MTU change
> 
> The via-velocity.c driver reinitializes (frees/allocates) several
> metadata structures during an MTU change. Unfortunately the allocations
> of the new versions of the metadata is done with GFP_KERNEL, even
> though this change of datastructures is (and needs to be) done while
> holding a spinlock (with irqs off).
> 
> Clearly that isn't a good thing, and kerneloops.org has trapped a large
> deal of the resulting warnings. The fix is to use GFP_ATOMIC.
> While not elegant, avoiding the lock is going to be extremely complex.
> In addition, this is a "static", long lived allocation (after all, how
> often do you actually change your mtu) and not something that happens
> on an ongoing basis.
> 
> ...
>
> diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
> index 6b8d882..4bf08fd 100644
> --- a/drivers/net/via-velocity.c
> +++ b/drivers/net/via-velocity.c
> @@ -1,4 +1,4 @@
> -/*
> +;/*

Cat sat on your keyboard?

>   * This code is derived from the VIA reference driver (copyright message
>   * below) provided to Red Hat by VIA Networking Technologies, Inc. for
>   * addition to the Linux kernel.
> @@ -1241,6 +1241,9 @@ static int velocity_rx_refill(struct velocity_info *vptr)
>   *
>   *	Allocate and set up the receive buffers for each ring slot and
>   *	assign them to the network adapter.
> + *
> + *	Note: This function gets called with irqs off/lock held
> + *	from velocity_change_mtu()
>   */
>  
>  static int velocity_init_rd_ring(struct velocity_info *vptr)
> @@ -1251,7 +1254,7 @@ static int velocity_init_rd_ring(struct velocity_info *vptr)
>  	vptr->rx_buf_sz = (mtu <= ETH_DATA_LEN) ? PKT_BUF_SZ : mtu + 32;
>  
>  	vptr->rd_info = kcalloc(vptr->options.numrx,
> -				sizeof(struct velocity_rd_info), GFP_KERNEL);
> +				sizeof(struct velocity_rd_info), GFP_ATOMIC);

What happens if this allocation fails?  I think the driver is dead?

We've gone and freed the rd_ring and the td_ring and we _might_ have
allocated a new rd_ring and not a new td_ring.

And we've set vptr->rx_buf_sz, which may or may not be a problem.

And we've gone and left the interface in a downed state.

So hrm.  It could all be a lot better.  Just looking quickly at the
code I _think_ we might be able to do all the needed allocations
outside the lock and then swizzle them into place after taking the
lock. ie, something as simple as:

	struct velocity_info *temp_vptr;

	...

	velocity_init_rd_ring(temp_vptr);	/* Can use GFP_KERNEL! */

	spin_lock_irqsave(&vptr->lock, flags);

	velocity_free_td_ring(vptr);
	velocity_free_rd_ring(vptr);

	vptr->foo = temp_vptr->foo;
	vptr->bar = temp_vptr->bar;
	...

	spin_unlock_irqrestore(&vptr->lock, flags);

?

