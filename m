From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Fri, 8 Apr 2005 07:25:04 +1000
Message-ID: <20050407212504.GA4939@gondor.apana.org.au>
References: <Pine.LNX.4.58.0504051925250.21486@graphe.net> <E1DJ5y2-0003rF-00@gondolin.me.apana.org.au> <20050406111721.3ac67605.davem@davemloft.net> <20050407110724.GA8760@gondor.apana.org.au> <Pine.LNX.4.58.0504070842420.29731@graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        pravins@calsoftinc.com, shai@scalesx86.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Lameter <christoph@lameter.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0504070842420.29731@graphe.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Apr 07, 2005 at 09:00:51AM -0700, Christoph Lameter wrote:
> 
> In an earlier email you said that there was a slight chance that child
> entries (typically NOHASH from what I can see in the code) could be on the
> gc list.

Only child entries with NOHASH unset can be on the GC list.

> If its not on the hash table and not on the gc list then how could the
> refcnt be > 1 ? Doesnt the refcnt > 1 imply that multiple concurrent
> accesses are possible?

For NOHASH entries refcnt can be greater than one due to dst_pop.
Of course concurrent access is possible.  However, the important
thing is that only the "owner" of an entry can call dst_destroy.

In the case of NOHASH entries, we are the owner.

> Also if this is as you say then both types of entries better be
> treated in a distinct way for clarity in the code. This also avoids
> having a nohash variable:

I never said that it is better to treat them differently.  I wrote
it like this earlier because I still had atomic_dec_and_test.

> if ((dst->flags & DST_NOHASH)) {
> 	/* dst not on hash and also not on gc list */
> 	atomic_dec(&dst->__refcnt);
> 	if (!atomic_read(&dst->refcnt))
> 		/* We were the only reference kill child */
> 		goto again;
> 	/* return child to put it on the gc list */
> 	return dst;
> }

BTW this patch is missing a barrier.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
