From: Andi Kleen <ak@suse.de>
Subject: Re: Route cache performance under stress
Date: Mon, 9 Jun 2003 11:47:34 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030609094734.GD2728@wotan.suse.de>
References: <20030609065211.GB20613@netnation.com> <20030608.235622.38700262.davem@redhat.com> <20030609081803.GF20613@netnation.com> <20030609.020116.10308258.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sim@netnation.com, xerox@foonet.net, fw@deneb.enyo.de,
	netdev@oss.sgi.com, linux-net@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, Robert.Olsson@data.slu.se
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030609.020116.10308258.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Mon, Jun 09, 2003 at 02:01:16AM -0700, David S. Miller wrote:
>    From: Simon Kirby <sim@netnation.com>
>    Date: Mon, 9 Jun 2003 01:18:03 -0700
> 
>     10516 dst_alloc                                 73.0278
> 
> Gross, we effectively initialize a new dst multiple times :(
> In fact, we modify the same cache lines at least 3 times.
> 
> There's a lot more we can do in this area.  But this patch below kills
> some of it.  Again, patch is against 2.5.x-current.
> 
> Actually, it is a relatively good sign, it means this is a relatively
> unexplored area of the networking :-)))
> 
> --- net/core/dst.c.~1~	Mon Jun  9 01:47:26 2003
> +++ net/core/dst.c	Mon Jun  9 01:53:41 2003
> @@ -122,13 +122,31 @@ void * dst_alloc(struct dst_ops * ops)
>  	dst = kmem_cache_alloc(ops->kmem_cachep, SLAB_ATOMIC);
>  	if (!dst)
>  		return NULL;
> -	memset(dst, 0, ops->entry_size);
> +	dst->next = NULL;
>  	atomic_set(&dst->__refcnt, 0);
> -	dst->ops = ops;
> +	dst->__use = 0;
> +	dst->child = NULL;
> +	dst->dev = NULL;
> +	dst->obsolete = 0;
> +	dst->flags = 0;
>  	dst->lastuse = jiffies;
> +	dst->expires = 0;
> +	dst->header_len = 0;
> +	dst->trailer_len = 0;
> +	memset(dst->metrics, 0, sizeof(dst->metrics));

gcc will generate a lot better code for the memsets if you can tell
it somehow they are long aligned and a multiple of 8 bytes.
e.g. redeclare them as long instead of char.  If it cannot figure out 
the alignment it often (or least on x86) calls to the external memset
function.

>  	dst->path = dst;
> +	dst->rate_last = 0;
> +	dst->rate_tokens = 0;
> +	dst->error = 0;
> +	dst->neighbour = NULL;
> +	dst->hh = NULL;
> +	dst->xfrm = NULL;
>  	dst->input = dst_discard;
>  	dst->output = dst_blackhole;
> +	dst->ops = ops;
> +	INIT_RCU_HEAD(&dst->rcu_head);
> +	memset(dst->info, 0,
> +	       ops->entry_size - offsetof(struct dst_entry, info));

Same here.

-Andi
