From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [IPV4/IPV6] Ensure all frag_list members have NULL sk
Date: Sun, 15 May 2005 21:33:41 +0400
Message-ID: <20050515213341.4011c00e@zanzibar.2ka.mipt.ru>
References: <20050514134834.GA2698@uganda.factory.vocord.ru>
	<E1DXE3h-0002jR-00@gondolin.me.apana.org.au>
	<20050515104016.GA24344@gondor.apana.org.au>
	<20050515114121.GA4830@gondor.apana.org.au>
	<20050515122256.GA22251@gondor.apana.org.au>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050515122256.GA22251@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 15 May 2005 22:22:56 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Sun, May 15, 2005 at 09:41:21PM +1000, herbert wrote:
> > 
> > I'll post a new patch soon.  However, since this is a pretty major change
> > and the bugs it fixes aren't that important it should probably be delayed
> > until 2.6.13.
> 
> Here it is:
> 
> 
> Having frag_list members which holds wmem of an sk leads to nightmares
> with partially cloned frag skb's.  The reason is that once you unleash
> a skb with a frag_list that has individual sk ownerships into the stack
> you can never undo those ownerships safely as they may have been cloned
> by things like netfilter.  Since we have to undo them in order to make
> skb_linearize happy this approach leads to a dead-end.
> 
> So let's go the other way and make this an invariant:
> 
> 	For any skb on a frag_list, skb->sk must be NULL.

This requires skb_set_owner_* to check if it is called
for head skb or one from fragment and does nothing if
it is from frag_list.
Or to check the whole tree for ownering calls...

> That is, the socket ownership always belongs to the head skb.
> It turns out that the implementation is actually pretty simple.
> 
> The above invariant is actually violated in the following patch
> for a short duration inside ip_fragment.  This is OK because the
> offending frag_list member is either destroyed at the end of the
> slow path without being sent anywhere, or it is detached from
> the frag_list before being sent.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt


	Evgeniy Polyakov

Only failure makes us experts. -- Theo de Raadt
