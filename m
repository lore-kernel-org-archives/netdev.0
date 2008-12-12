From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/8] net: Add Generic Receive Offload infrastructure
Date: Sat, 13 Dec 2008 08:45:50 +1100
Message-ID: <20081212214550.GB11046@gondor.apana.org.au>
References: <20081212053116.GA2927@gondor.apana.org.au> <E1LB0cx-0000r3-N2@gondolin.me.apana.org.au> <20081212195130.GB27281@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45162 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753363AbYLLVpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 16:45:55 -0500
Content-Disposition: inline
In-Reply-To: <20081212195130.GB27281@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2008 at 10:51:30PM +0300, Evgeniy Polyakov wrote:
> On Fri, Dec 12, 2008 at 04:31:51PM +1100, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> > +static int napi_gro_complete(struct sk_buff *skb)
> > +{
> > +	struct packet_type *ptype;
> > +	__be16 type = skb->protocol;
> > +	struct list_head *head = &ptype_base[ntohs(type) & PTYPE_HASH_MASK];
> > +	int err = -ENOENT;
> > +
> > +	if (!skb_shinfo(skb)->frag_list)
> > +		goto out;
> > +
> > +	rcu_read_lock();
> > +	list_for_each_entry_rcu(ptype, head, list) {
> > +		if (ptype->type != type || ptype->dev || !ptype->gro_complete)
> > +			continue;
> > +
> > +		err = ptype->gro_complete(skb);
> > +		break;
> > +	}
> > +	rcu_read_unlock();
> > +
> > +	if (err) {
> > +		WARN_ON(&ptype->list == head);
> > +		kfree_skb(skb);
> > +		return NET_RX_SUCCESS;
> 
> Success after freeing skb on error? :)

These return values are for congestion control rather than errors.

> Why not WARN_ON_ONCE()?

If this ever gets run we're in big trouble :) And if you're hacking
protocols and trigger this then you want to see all the backtraces.

> > +	if (NAPI_GRO_CB(skb)->same_flow)
> > +		goto ok;
> 
> Should this set ->count?

Nope, same_flow == 1 means that the skb was merged into an existing
entry.  ->count is only set for the skb that consumed this one.

> > +
> > +	if (NAPI_GRO_CB(skb)->flush || count >= MAX_GRO_SKBS) {
> > +		__skb_push(skb, -skb_network_offset(skb));
> > +		goto normal;
> > +	}
> > +
> > +	NAPI_GRO_CB(skb)->count = 1;
> 
> Maybe this should be set to 'count', not 1?

No, ->count is for how many original skb's we have merged into
skb, whilc the local count is for how many held skb's we have
in total (used to limit the length of that list).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
