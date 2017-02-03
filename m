From: Steffen Klassert <steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCHv3 net-next 5/7] net: add confirm_neigh method to dst_ops
Date: Fri, 3 Feb 2017 11:08:53 +0100
Message-ID: <20170203100853.GB30338@gauss.secunet.com>
References: <1485899827-5212-1-git-send-email-ja@ssi.bg>
 <1485899827-5212-6-git-send-email-ja@ssi.bg>
 <20170201074402.GX30338@gauss.secunet.com>
 <alpine.LFD.2.11.1702012326130.2580@ja.home.ssi.bg>
 <20170203074609.GA30338@gauss.secunet.com>
 <alpine.LFD.2.11.1702031101550.2584@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, YueHaibing <yuehaibing-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: Julian Anastasov <ja-FgGsKACvmQM@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1702031101550.2584-c1lBKlETG9EWAawoAK+ZAw@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 03, 2017 at 11:16:16AM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 3 Feb 2017, Steffen Klassert wrote:
> > 
> > I thought about this (completely untested) one:
> > 
> > static void xfrm_confirm_neigh(const struct dst_entry *dst, const void
> > *daddr)
> > 
> > {
> > 	const struct dst_entry *dst = dst->child;
> 
> 	When starting and dst arg is first xform, the above
> assignment skips it. May be both lines should be swapped.

Yes, that's better :)

> 
> > 	const struct xfrm_state *xfrm = dst->xfrm;
> > 
> > 	if (xfrm)
> > 		daddr = &xfrm->id.daddr;
> > 
> > 	dst->ops->confirm_neigh(dst, daddr);
> > }
> > 
> > Only the last dst_entry in this call chain (path) sould
> > not have dst->xfrm set. So it finally calls path->ops->confirm_neigh
> > with the daddr of the last transformation. But your version
> > should do the same.
> 
> 	Above can be fixed but it is risky for the stack
> usage when using recursion. In practice, there should not be
> many xforms, though. Also, is id.daddr valid for transports?

Yes, it is needed for the lookup. But id.daddr ist the same
as daddr of the packet on transport mode.

> 
> > > 	This should work as long as path and last tunnel are
> > > from same family.
> > 
> > Yes, the outer mode of the last transformation has the same
> > family as path.
> > 
> > > Also, after checking xfrm_dst_lookup() I'm not
> > > sure using just &xfrm->id.daddr is enough. Should we consider
> > > more places for daddr value?
> > 
> > Yes, indeed. We should do it like xfrm_dst_lookup() does it.
> 
> 	OK, I'll get logic from there. Should I use loop or
> recursion?

I don't have a strong opinion on that. Both should work,
choose whatever you prefer.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
