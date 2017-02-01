From: Julian Anastasov <ja-FgGsKACvmQM@public.gmane.org>
Subject: Re: [PATCHv3 net-next 5/7] net: add confirm_neigh method to
 dst_ops
Date: Thu, 2 Feb 2017 01:04:34 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1702012326130.2580@ja.home.ssi.bg>
References: <1485899827-5212-1-git-send-email-ja@ssi.bg> <1485899827-5212-6-git-send-email-ja@ssi.bg> <20170201074402.GX30338@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, YueHaibing <yuehaibing-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: Steffen Klassert <steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170201074402.GX30338-QbcZoYm+z/4HCNZ7eMmnrgC/G2K4zDHf@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 1 Feb 2017, Steffen Klassert wrote:

> On Tue, Jan 31, 2017 at 11:57:05PM +0200, Julian Anastasov wrote:
> >  
> > +static void xfrm_confirm_neigh(const struct dst_entry *dst, const void *daddr)
> > +{
> > +	const struct dst_entry *path = dst->path;
> > +
> > +	if (path == dst) {
> 
> I think path can not be equal to dst here, otherwise we would
> have an infinite recursion.

	Yep, I know that, this place remained unfinished.

> > +		dst->ops->confirm_neigh(dst, daddr);
> > +	} else {
> > +		/* daddr can be from different family and we need the
> > +		 * tunnel address. How to get it?
> > +		 */
> 
> This is only called on a xfrm_dst, so you should have dst->xfrm set.
> You can get the daddr of this transform with:
> 
> xfrm_address_t *daddr = &xfrm->id.daddr;

	I hope so but see below...

> > +		path->ops->confirm_neigh(path, NULL);
> 
> I think here it is better to go through the whole chain
> of transformations with
> 
> child->ops->confirm_neigh(path, daddr);

	It may sounds good. But only dst->path->ops->confirm_neigh
points to real IPv4/IPv6 function. And also, I guess, the
family can change while walking the chain, so we should be
careful while providing the original daddr (which comes from
sendmsg). I had the idea to walk all xforms to get the latest
tunnel address but this can be slow. Something like this?:

static void xfrm_confirm_neigh(const struct dst_entry *dst, const void 
*daddr)
{
	const struct dst_entry *path = dst->path;

	/* By default, daddr is from sendmsg() if we have no tunnels */
	for (;dst != path; dst = dst->child) {
		const struct xfrm_state *xfrm = dst->xfrm;

		/* Use address from last tunnel	*/
		if (xfrm->props.mode != XFRM_MODE_TRANSPORT)
			daddr = &xfrm->id.daddr;
	}
	path->ops->confirm_neigh(path, daddr);
}

	This should work as long as path and last tunnel are
from same family. Also, after checking xfrm_dst_lookup() I'm not
sure using just &xfrm->id.daddr is enough. Should we consider
more places for daddr value?

> >  int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
> >  {
> >  	int err = 0;
> > @@ -2882,6 +2896,8 @@ int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
> >  			dst_ops->link_failure = xfrm_link_failure;
> >  		if (likely(dst_ops->neigh_lookup == NULL))
> >  			dst_ops->neigh_lookup = xfrm_neigh_lookup;
> > +		if (likely(!dst_ops->confirm_neigh))
> > +			dst_ops->confirm_neigh = xfrm_confirm_neigh;
> 
> We also have address family depended dst_ops, look for
> xfrm4_dst_ops_template/xfrm6_dst_ops_template.

	For now I installed common handler, just like
xfrm_neigh_lookup. BTW this function has problem from
commit f894cbf847c9, it looks like dst is wrongly provided,
first arg should be dst->path.

	But as dst_ops contains the family, I think, we can know
what kind of daddr is provided initially (dst->ops->family).
So far, the above logic does not need to compare the families.
But as I don't know the code well, I'm not sure, my assumptions are:

- transports do not change the family
- tunnels may change the family
- last tunnel gets dst0->path route from its family

Regards

--
Julian Anastasov <ja-FgGsKACvmQM@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
