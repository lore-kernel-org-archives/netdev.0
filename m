From: Patrick McHardy <kaber@trash.net>
Subject: Re: [4/4] [IPSEC] Store MTU at each xfrm_dst
Date: Mon, 28 Mar 2005 22:10:54 +0200
Message-ID: <424864CE.5060802@trash.net>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@redhat.com>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050214221607.GC18465@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Herbert,

Herbert Xu wrote:
> Finally this is the patch that sets the MTU values of each xfrm_dst
> and keeps it up-to-date.

while looking for ways to exchange the xfrm pointer of a live
dst_entry I noticed what looks like an ABBA deadlock introduced
by the call to xfrm_state_mtu() in xfrm_bundle_ok().

spin_lock x->lock			(xfrm_state_delete)
	read_lock xfrm_policy_lock	(xfrm_prune_bundles)
		write_lock policy->lock	(xfrm_prune_bundles)

read/write_lock policy->lock		(__xfrm46_find_acq/xfrm_lookup)
	spin_lock x->lock		(xfrm_state_mtu)

I haven't though of a way to avoid this yet. It would be nice though
if we could keep the rule that xfrm_policy_lock and policy->lock nest
with x->lock.

Something unrelated I was also wondering about, from xfrm_find_state():

         list_for_each_entry(x, xfrm_state_bydst+h, bydst) {
                 if (x->props.family == family &&
                     x->props.reqid == tmpl->reqid &&
                     xfrm_state_addr_check(x, daddr, saddr, family) &&
                     tmpl->mode == x->props.mode &&
                     tmpl->id.proto == x->id.proto) {

Shouldn't we check for (tmpl->id.spi == x->id.spi || !tmpl->id.spi) ?

Regards
Patrick

>   
> -int xfrm_bundle_ok(struct xfrm_dst *xdst, struct flowi *fl, int family)
> +int xfrm_bundle_ok(struct xfrm_dst *first, struct flowi *fl, int family)
>  {
> -	struct dst_entry *dst = &xdst->u.dst;
> +	struct dst_entry *dst = &first->u.dst;
> +	struct xfrm_dst *last;
> +	u32 mtu;
>  
>  	if (dst->path->obsolete > 0 ||
>  	    (dst->dev && !netif_running(dst->dev)))
>  		return 0;
>  
> +	last = NULL;
> +
>  	do {
> +		struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
> +
>  		if (fl && !xfrm_selector_match(&dst->xfrm->sel, fl, family))
>  			return 0;
>  		if (dst->xfrm->km.state != XFRM_STATE_VALID)
>  			return 0;
> +
> +		mtu = dst_pmtu(dst->child);
> +		if (xdst->child_mtu_cached != mtu) {
> +			last = xdst;
> +			xdst->child_mtu_cached = mtu;
> +		}
> +
> +		mtu = dst_pmtu(xdst->route);
> +		if (xdst->child_mtu_cached != mtu) {
> +			last = xdst;
> +			xdst->route_mtu_cached = mtu;
> +		}
> +
>  		dst = dst->child;
>  	} while (dst->xfrm);
> +
> +	if (likely(!last))
> +		return 1;
> +
> +	mtu = last->child_mtu_cached;
> +	for (;;) {
> +		dst = &last->u.dst;
> +
> +		mtu = xfrm_state_mtu(dst->xfrm, mtu);
> +		if (mtu > last->route_mtu_cached)
> +			mtu = last->route_mtu_cached;
> +		dst->metrics[RTAX_MTU-1] = mtu;
> +
> +		if (last == first)
> +			break;
> +
> +		last = last->u.next;
> +		last->child_mtu_cached = mtu;
> +	}
>  
>  	return 1;
>  }
