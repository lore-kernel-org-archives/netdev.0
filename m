From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: RFC: IPSEC patch 0 for netlink events
Date: Wed, 30 Mar 2005 10:49:03 +1000
Message-ID: <20050330004903.GA3399@gondor.apana.org.au>
References: <1111864971.1092.904.camel@jzny.localdomain> <20050326194707.GA9872@gondor.apana.org.au> <1111867875.1089.915.camel@jzny.localdomain> <20050327081848.GA13428@gondor.apana.org.au> <1111950449.1089.938.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1111950449.1089.938.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jamal:

On Sun, Mar 27, 2005 at 02:07:29PM -0500, jamal wrote:
>
> to user space). Sample patch, still under construction, attached.
> pfkey already does adverts on its own after a response from the generic
> code. 

This looks good over all.  Just a few minor things.

> --- 26115/include/net/xfrm.h	2005-03-19 01:35:02.000000000 -0500
> +++ 26115-mod/include/net/xfrm.h	2005-03-27 09:00:03.000000000 -0500
> @@ -157,6 +157,36 @@
>  	XFRM_STATE_DEAD
>  };
>  
> +/* events that could be sent by kernel */
> +enum {
> +	XFRM_SA_INVALID,
> +	XFRM_SA_EXPIRED,
> +	XFRM_SA_ADDED,
> +	XFRM_SA_UPDATED,
> +	XFRM_SA_DELETED,
> +	XFRM_SA_FLUSHED,

What's the difference between DELETED and FLUSHED and why do we
need that distinction?

> +/* callback structure passed from either netlink or pfkey */
> +struct xfrm_sa_cb
> +{
> +	u32	type; /* the type of caller netlink/pfkey/other */
> +	u32	data; /* callee to caller */
> +	void *hdr;
> +	struct sk_buff *skb;

I don't think we need to carry the original hdr and skb around.
I see below that you're using it to fill in the pid/seq when
sending netlink messages.  Since these are multicast messages
resent by the kernel they should not inherit those values from
the original skb.

> +/* the types used in sa_cb */
> +enum {
> +	KM_SA_INVALID,
> +	KM_SA_NETLINK,
> +	KM_SA_PFKEY,
> +	__KM_SA_MAX
> +};
> +#define KM_SA_MAX (__KM_SA_MAX - 1)

If we got rid if hdr/skb above then we don't need this either.

This would reduce xfrm_sa_cb to just one u32.

> --- 26115/net/xfrm/xfrm_state.c	2005-03-19 01:35:00.000000000 -0500
> +++ 26115-mod/net/xfrm/xfrm_state.c	2005-03-27 09:14:09.000000000 -0500
> @@ -402,7 +402,19 @@
>  
>  static struct xfrm_state *__xfrm_find_acq_byseq(u32 seq);
>  
> -int xfrm_state_add(struct xfrm_state *x)
> +static struct list_head xfrm_km_list = LIST_HEAD_INIT(xfrm_km_list);
> +static DEFINE_RWLOCK(xfrm_km_lock);
> +
> +void xfrm_sa_notify(struct xfrm_state *x, struct xfrm_sa_cb *c, int event)
> +{
> +	struct xfrm_mgr *km;
> +	read_lock(&xfrm_km_lock);
> +	list_for_each_entry(km, &xfrm_km_list, list)
> +		km->notify(x, event, c);
> +	read_unlock(&xfrm_km_lock);
> +}

It would be more consistent to call this km_state_notify and put it
next to the other km functions below.

> +int xfrm_state_add(struct xfrm_state *x, struct xfrm_sa_cb *c)

We wouldn't need the cb argument here once you get rid of
everything there apart from data.
  
> -int xfrm_state_update(struct xfrm_state *x)
> +int xfrm_state_update(struct xfrm_state *x, struct xfrm_sa_cb *c)

Ditto.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
