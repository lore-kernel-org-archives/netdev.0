From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: IPSEC patch 0 for netlink events
Date: 30 Mar 2005 07:09:32 -0500
Message-ID: <1112184572.1089.80.camel@jzny.localdomain>
References: <1111864971.1092.904.camel@jzny.localdomain>
	 <20050326194707.GA9872@gondor.apana.org.au>
	 <1111867875.1089.915.camel@jzny.localdomain>
	 <20050327081848.GA13428@gondor.apana.org.au>
	 <1111950449.1089.938.camel@jzny.localdomain>
	 <20050330004903.GA3399@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050330004903.GA3399@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-03-29 at 19:49, Herbert Xu wrote:

> >  
> > +/* events that could be sent by kernel */
> > +enum {
> > +	XFRM_SA_INVALID,
> > +	XFRM_SA_EXPIRED,
> > +	XFRM_SA_ADDED,
> > +	XFRM_SA_UPDATED,
> > +	XFRM_SA_DELETED,
> > +	XFRM_SA_FLUSHED,
> 
> What's the difference between DELETED and FLUSHED and why do we
> need that distinction?
> 

In the case you flush you dont wanna send multiple DELETEs. Just one 
FLUSH at the end when flushing is done. At least this is behavior
of PFKEY (at least on the RFC). I think its a good thing.

> > +/* callback structure passed from either netlink or pfkey */
> > +struct xfrm_sa_cb
> > +{
> > +	u32	type; /* the type of caller netlink/pfkey/other */
> > +	u32	data; /* callee to caller */
> > +	void *hdr;
> > +	struct sk_buff *skb;
> 
> I don't think we need to carry the original hdr and skb around.
> I see below that you're using it to fill in the pid/seq when
> sending netlink messages.  Since these are multicast messages
> resent by the kernel they should not inherit those values from
> the original skb.
> 

Thinking ... thinking .. Good point.

I defineteley need at least:
a) case original message sent via netlink: pid of the original process
so when i multicast in netlink i dont echo back to it.
b) case original message sent via pfkey: 
When netlink side manager is invoked i ignore the pid and multicast to
every listener of that mcast group.

I may have gotten lazy while coding and shotgunned with both
the skb and the header thinking as i keep coding i may need more off
the originators message.

> > +/* the types used in sa_cb */
> > +enum {
> > +	KM_SA_INVALID,
> > +	KM_SA_NETLINK,
> > +	KM_SA_PFKEY,
> > +	__KM_SA_MAX
> > +};
> > +#define KM_SA_MAX (__KM_SA_MAX - 1)
> 
> If we got rid if hdr/skb above then we don't need this either.
> 

refer to b) above; i use these to figure the originator km.

> This would reduce xfrm_sa_cb to just one u32.
> 
> > --- 26115/net/xfrm/xfrm_state.c	2005-03-19 01:35:00.000000000 -0500
> > +++ 26115-mod/net/xfrm/xfrm_state.c	2005-03-27 09:14:09.000000000 -0500
> > @@ -402,7 +402,19 @@
> >  
> >  static struct xfrm_state *__xfrm_find_acq_byseq(u32 seq);
> >  
> > -int xfrm_state_add(struct xfrm_state *x)
> > +static struct list_head xfrm_km_list = LIST_HEAD_INIT(xfrm_km_list);
> > +static DEFINE_RWLOCK(xfrm_km_lock);
> > +
> > +void xfrm_sa_notify(struct xfrm_state *x, struct xfrm_sa_cb *c, int event)
> > +{
> > +	struct xfrm_mgr *km;
> > +	read_lock(&xfrm_km_lock);
> > +	list_for_each_entry(km, &xfrm_km_list, list)
> > +		km->notify(x, event, c);
> > +	read_unlock(&xfrm_km_lock);
> > +}
> 
> It would be more consistent to call this km_state_notify and put it
> next to the other km functions below.
> 

I will make the change.

> > +int xfrm_state_add(struct xfrm_state *x, struct xfrm_sa_cb *c)
> 
> We wouldn't need the cb argument here once you get rid of
> everything there apart from data.

We would need at least those two variables. 

>   
> > -int xfrm_state_update(struct xfrm_state *x)
> > +int xfrm_state_update(struct xfrm_state *x, struct xfrm_sa_cb *c)
> 
> Ditto.
> 

Ditto.
It is safer to maintain the cb structure incase we need to add more
variables in the future. Let me complete this - If it turns out that
i only need one 32 bit variable then its not worth it. Note: I plan to
use the same structure for the SPD side; so i will change its name to
xfrm_sap_cb

cheers,
jamal 
