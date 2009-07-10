From: Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: sk_lock: inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W}
	usage
Date: Fri, 10 Jul 2009 16:00:17 +0800
Message-ID: <20090710080017.GA24168@localhost>
References: <20090608023757.GA6244@localhost> <20090706105216.GA19124@gondor.apana.org.au> <20090709131746.GA27965@localhost> <20090709.171355.09466097.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org" <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090709.171355.09466097.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 10, 2009 at 08:13:55AM +0800, David Miller wrote:
> From: Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Date: Thu, 9 Jul 2009 21:17:46 +0800
> 
> > @@ -2100,7 +2100,8 @@ void tcp_send_fin(struct sock *sk)
> >  	} else {
> >  		/* Socket is locked, keep trying until memory is available. */
> >  		for (;;) {
> > -			skb = alloc_skb_fclone(MAX_TCP_HEADER, GFP_KERNEL);
> > +			skb = alloc_skb_fclone(MAX_TCP_HEADER,
> > +					       sk->sk_allocation);
> >  			if (skb)
> >  				break;
> >  			yield();
> 
> I think this specific case needs more thinking.
> 
> If the allocation fails, and it's GFP_ATOMIC, we are going to yield()
> (which sleeps) and loop endlessly waiting for the allocation to
> succeed.

The _retried_ GFP_ATOMIC won't be much worse than GFP_KERNEL.

GFP_KERNEL can directly reclaim FS pages; GFP_ATOMIC will wake up
kswapd to do that. So after yield(), GFP_ATOMIC have good opportunity
to succeed if GFP_KERNEL could succeed.

The original GFP_KERNEL does have _a bit_ better chance to succeed,
but there are no guarantee. It could loop endlessly whether it be
GFP_KERNEL or GFP_ATOMIC.

btw, generally speaking, it would be more robust that NFS set
sk_allocation to GFP_NOIO, and let the networking code choose
whether to use plain sk_allocation or (sk_allocation & ~__GFP_WAIT).

The (sk_allocation & ~__GFP_WAIT) cases should be rare, but I guess
the networking code shall do it anyway, because sk_allocation defaults
to GFP_KERNEL. It seems that currently the networking code simply uses
a lot of GFP_ATOMIC, do they really mean "I cannot sleep"?

Thanks,
Fengguang
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
