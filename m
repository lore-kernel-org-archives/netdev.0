From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: take 2  WAS(Re: PATCH: IPSEC xfrm events
Date: Mon, 4 Apr 2005 10:58:05 +1000
Message-ID: <20050404005805.GA16543@gondor.apana.org.au>
References: <1112353398.1096.116.camel@jzny.localdomain> <20050401114258.GA2932@gondor.apana.org.au> <1112358278.1096.160.camel@jzny.localdomain> <20050401123554.GA3468@gondor.apana.org.au> <1112403845.1088.14.camel@jzny.localdomain> <20050402012813.GA24575@gondor.apana.org.au> <1112406164.1088.54.camel@jzny.localdomain> <20050402014619.GB24861@gondor.apana.org.au> <1112469601.1088.173.camel@jzny.localdomain> <1112538718.1096.394.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112538718.1096.394.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jamal:

On Sun, Apr 03, 2005 at 10:31:58AM -0400, jamal wrote:
> 
> Small change after some testing.
> Herbert havent heard back from you - this looks very palatable in my
> opinion with comments below still in effect.

It's definitely looking better all the time.
  
> -void xfrm_state_delete(struct xfrm_state *x)
> +static DEFINE_RWLOCK(xfrm_km_lock);
> +static struct list_head xfrm_km_list = LIST_HEAD_INIT(xfrm_km_list);
> +
> +void km_policy_notify(struct xfrm_policy *xp, int dir, struct km_event *c)
>  {
> +	struct xfrm_mgr *km;
> +
> +	read_lock(&xfrm_km_lock);
> +	list_for_each_entry(km, &xfrm_km_list, list)
> +		if (km->notify_policy)
> +			km->notify_policy(xp, dir, c);
> +	read_unlock(&xfrm_km_lock);
> +}
> +
> +void km_state_notify(struct xfrm_state *x, struct km_event *c)
> +{
> +	struct xfrm_mgr *km;
> +	read_lock(&xfrm_km_lock);
> +	list_for_each_entry(km, &xfrm_km_list, list)
> +		km->notify(x, c);
> +	read_unlock(&xfrm_km_lock);
> +}
> +
> +EXPORT_SYMBOL(km_policy_notify);
> +EXPORT_SYMBOL(km_state_notify);

Can we perhaps move these lines next to the other km functions
further down? They look rather lonely here.

> +	/* XXX: Do we wanna do this right at the top??
> +	 * if the state is dead we dont want to announce 
> +	 * the expire - a delete may already have announced
> +	 * it 
> +	*/

Please code this check differently so that it isn't racy.

One way to do it is to change xfrm_timer_handler to do:

	if (__xfrm_state_delete(x) && x->id.spi)
		km_state_expired(x, 1);

> +	/* XXX: Do we still wanna wakeup km_waitq?
> +	 * if the policy is dead we dont want to announce 
> +	 * the expire - a delete may already have announced
> +	 * it 
> +	*/

Ditto.

> --- a/net/xfrm/xfrm_policy.c	2005-03-25 22:28:21.000000000 -0500
> +++ b/net/xfrm/xfrm_policy.c	2005-04-02 12:16:30.000000000 -0500
> @@ -298,7 +298,7 @@
>   * entry dead. The rule must be unlinked from lists to the moment.
>   */
>  
> -static void xfrm_policy_kill(struct xfrm_policy *policy)
> +static void xfrm_policy_kill(struct xfrm_policy *policy, int dir)

What's this for?
  
> +	c.seq = nlh->nlmsg_seq;
> +	c.pid = nlh->nlmsg_pid;
> +	if (nlh->nlmsg_type == XFRM_MSG_NEWSA)
> +		c.event = XFRM_SAP_ADDED;
> +	else
> +		c.event = XFRM_SAP_UPDATED;
> +
> +	km_state_notify(x, &c);

You need to hold onto x here.  So do a hold before you call xfrm_state_*
and then drop the reference after km_state_notify.
  
>  static int xfrm_del_sa(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
  
> -	xfrm_state_delete(x);
> +	err = xfrm_state_delete(x);
> +	if (err < 0) {
> +		x->km.state = XFRM_STATE_DEAD;
> +		xfrm_state_put(x);
> +		return err;

If the xfrm_state_delete fails then it's already dead.  So kill
the line that modifies its state.

> +static int xfrm_notify_sa( struct xfrm_state *x, struct km_event *c)

Extra space after the paren.

> +	int len = NLMSG_LENGTH(sizeof(struct xfrm_usersa_info));

Please add the additional payloads for NAT-T and the keys.

> +static int xfrm_notify_policy( struct xfrm_policy *xp, int dir, struct km_event *c)
> +{
> +	struct xfrm_userpolicy_info *p;
> +	struct nlmsghdr *nlh;
> +	struct sk_buff *skb;
> +	u32 nlt = 0 ;
> +	unsigned char *b;
> +	int len = NLMSG_LENGTH(sizeof(struct xfrm_userpolicy_info));

Please attach the templates.

> @@ -1256,7 +1328,7 @@
>  
>  	if (hdr->sadb_msg_type == SADB_ADD)
>  		err = xfrm_state_add(x);
> -	else
> +	else 

A better editor that doesn't leave trailing spaces is needed here :)
  	
> -	xfrm_state_delete(x);
> -	xfrm_state_put(x);
> +	err = xfrm_state_delete(x);
> +	if (err < 0) {
> +		x->km.state = XFRM_STATE_DEAD;

Please remove this line as it's already dead if the delete fails.
  
> +static int key_notify_sa_flush(struct km_event *c)
> +{
> +	struct sk_buff *skb;
> +	struct sadb_msg *hdr;
> +
> +	skb = alloc_skb(sizeof(struct sadb_msg) + 16, GFP_ATOMIC);
> +	if (!skb)
> +		return -ENOBUFS;
> +	hdr = (struct sadb_msg *) skb_put(skb, sizeof(struct sadb_msg));
> +	// XXX:do we have to pass proto as well?

I think so.  A flush of all IPCOMP states is certainly quite different
from a flush of all states.  It's just a matter of calling satype2proto.

> +	/* 
> +	 * XXX: previous get was doing a broadcast-all _always_
> +	 * which didnt seem right for non-deletion case - JHS
> +	 * This is like the way netlink behaves ..
> +	 * Shall i restore original behavior?
> +	*/

You're right.  The original behaviour was broken.

> -	pfkey_xfrm_policy2msg(out_skb, xp, pol->sadb_x_policy_dir-1);
> -
> -	out_hdr = (struct sadb_msg *) out_skb->data;
> -	out_hdr->sadb_msg_version = hdr->sadb_msg_version;
> -	out_hdr->sadb_msg_type = hdr->sadb_msg_type;
> -	out_hdr->sadb_msg_satype = 0;
> -	out_hdr->sadb_msg_errno = 0;
> -	out_hdr->sadb_msg_seq = hdr->sadb_msg_seq;
> -	out_hdr->sadb_msg_pid = hdr->sadb_msg_pid;
> -	pfkey_broadcast(out_skb, GFP_ATOMIC, BROADCAST_ALL, sk);
> -	err = 0;

However, you do need to keep this code for the real GET case.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
