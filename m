From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPV4/IPV6] Keep wmem accounting separate in ip*_push_pending_frames
Date: Sun, 15 May 2005 21:41:21 +1000
Message-ID: <20050515114121.GA4830@gondor.apana.org.au>
References: <20050514134834.GA2698@uganda.factory.vocord.ru> <E1DXE3h-0002jR-00@gondolin.me.apana.org.au> <20050515104016.GA24344@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20050515104016.GA24344@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, May 15, 2005 at 08:40:16PM +1000, herbert wrote:

Please discard this patch.

> Since frag_list skb's constructed by ip*_push_pending_frames are
> usually going to be fragmented in ip*_fragment and sent separately,
> it makes no sense to account them all in the head skb.  Doing so
> means that ip*_fragment would have to undo it all in order to keep
> the correct wmem accounting.

Unfortunately this leads to nightmares with partially cloned frag skb's.
The reason is that once you unleash a skb with a frag_list that has
individual sk ownerships into the stack you can never undo those
ownerships safely as they may have been cloned by things like netfilter.
Since we have to undo them in order to make skb_linearize happy this
approach leads to a dead-end.

So let's go the other way and make this an invariant:

	For any skb on a frag_list, skb->sk must be NULL.

That is, the socket ownership always belongs to the head skb.
It turns out that the implementation is actually pretty simple.

> On the slow path it double-charges the skb's which may unnecssarily
> delay new data from being sent.

Especially because I was wrong about this.  The slow paths in ip*_fragment
is actually correct since it frees the original skb after constructing
the new fragments.

I'll post a new patch soon.  However, since this is a pretty major change
and the bugs it fixes aren't that important it should probably be delayed
until 2.6.13.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
