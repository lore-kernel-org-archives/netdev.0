From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: take 2-2  WAS(Re: PATCH: IPSEC xfrm events
Date: Mon, 4 Apr 2005 22:16:41 +1000
Message-ID: <20050404121641.GA12103@gondor.apana.org.au>
References: <1112358278.1096.160.camel@jzny.localdomain> <20050401123554.GA3468@gondor.apana.org.au> <1112403845.1088.14.camel@jzny.localdomain> <20050402012813.GA24575@gondor.apana.org.au> <1112406164.1088.54.camel@jzny.localdomain> <20050402014619.GB24861@gondor.apana.org.au> <1112469601.1088.173.camel@jzny.localdomain> <1112538718.1096.394.camel@jzny.localdomain> <20050404005805.GA16543@gondor.apana.org.au> <1112614706.1096.439.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112614706.1096.439.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jamal:

On Mon, Apr 04, 2005 at 07:38:26AM -0400, jamal wrote:
> Ok, heres an update.

Great! White space comments only this time, almost :)

> @@ -48,13 +50,15 @@
>  static struct list_head xfrm_state_gc_list = LIST_HEAD_INIT(xfrm_state_gc_list);
>  static DEFINE_SPINLOCK(xfrm_state_gc_lock);
>  
> -static void __xfrm_state_delete(struct xfrm_state *x);
> +static int __xfrm_state_delete(struct xfrm_state *x);
>  
>  static struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned short family);
>  static void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo);
>  
>  static int km_query(struct xfrm_state *x, struct xfrm_tmpl *t, struct xfrm_policy *pol);
>  static void km_state_expired(struct xfrm_state *x, int hard);
> +void km_policy_notify(struct xfrm_policy *xp, int dir, struct km_event *c);
> +void km_state_notify(struct xfrm_state *x, struct km_event *c);

No need for these prototypes since they're already in xfrm.h.
 
> @@ -764,37 +778,60 @@
>  }
>  EXPORT_SYMBOL(xfrm_replay_advance);
>  
> -static struct list_head xfrm_km_list = LIST_HEAD_INIT(xfrm_km_list);
> -static DEFINE_RWLOCK(xfrm_km_lock);

How about letting these guys stay where they are? The move was
necessary before because the km_*_notify functions had to be called
in this file but that's no longer the case.

> --- a/net/xfrm/xfrm_user.c	2005-03-25 22:28:22.000000000 -0500
> +++ b/net/xfrm/xfrm_user.c	2005-04-04 07:23:31.000000000 -0400
> @@ -268,6 +268,7 @@
>  	struct xfrm_usersa_info *p = NLMSG_DATA(nlh);
>  	struct xfrm_state *x;
>  	int err;
> +	struct km_event c;
>  
>  	err = verify_newsa_info(p, (struct rtattr **) xfrma);
>  	if (err)
> @@ -285,14 +286,28 @@
>  	if (err < 0) {
>  		x->km.state = XFRM_STATE_DEAD;
>  		xfrm_state_put(x);
> +		return err;
>  	}
>  
> +	xfrm_state_hold(x);

Sorry, you need to hold x before the call to
xfrm_state_add/xfrm_state_update as otherwise
they can cause x to be freed.

In general hold/put is only useful if

1) When you call hold you already have a reference to the object.
2) In between the hold/put you may free the object.

>  static int pfkey_add(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr, void **ext_hdrs)
>  {
> -	struct sk_buff *out_skb;
> -	struct sadb_msg *out_hdr;
>  	struct xfrm_state *x;
>  	int err;
> +	struct km_event c;
>  
>  	xfrm_probe_algs();

...

> -	pfkey_broadcast(out_skb, GFP_ATOMIC, BROADCAST_ALL, sk);
> +	xfrm_state_hold(x);

Same problem as xfrm_user.  We need the hold to occur before the
add/update for it to be effective.  In fact the original code was
buggy too since it didn't hold a reference at all.

Of course this is very unlikely to crash since it requires a
small life time and some bad luck in getting preempted.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
