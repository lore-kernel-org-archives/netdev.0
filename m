From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
	gc_elasticity is exceeded
Date: Mon, 6 Oct 2008 08:43:27 -0400
Message-ID: <20081006124327.GB16939@hmsreliant.think-freely.org>
References: <20080930.070804.26007839.davem@davemloft.net> <E1KmKGd-000393-UD@gondolin.me.apana.org.au> <c3ca0c0f0810042145q35a451a7u706bc64fb43723fa@mail.gmail.com> <20081005.103454.247312994.davem@davemloft.net> <20081006042108.GA19398@gondor.apana.org.au> <20081006105022.GA16939@hmsreliant.think-freely.org> <20081006110249.GA22613@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, whydna@whydna.net,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47125 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752434AbYJFMpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 08:45:42 -0400
Content-Disposition: inline
In-Reply-To: <20081006110249.GA22613@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 06, 2008 at 07:02:49PM +0800, Herbert Xu wrote:
> On Mon, Oct 06, 2008 at 06:50:22AM -0400, Neil Horman wrote:
> >
> > > 1) The way we count the chain length is wrong.  There are keys
> > > which do not form part of the hash computation.  Entries that
> > > only differ by them will always end up in the same bucket.
> >
> > I'm not sure I follow what your saying here.  I understand that some keys will
> > wind up hashing to the same bucket, but from what I see a change to the saddr
> > and daddr parameters to rt_hash, will change what bucket you hash too.  What am
> > I missing?
> 
> We've got keys other than saddr/daddr, for example, all route
> entries that differ only by TOS hash to the same bucket.  There
> are quite a few possible TOS values.
> 
> Have a look at ip r l c.
Ok, that makes a bit more sense.  Thank you.   I agree that in that case we
probably do need to bias our chain length accounting such that entries that
differ only by TOS or other fields that do not affect the hash value only get
counted once.

> 
> > > 2) What do we do when we get a long chain just after a rehash.
> > > 
> > > This is an indication that the attacker has more knowledge about
> > > us than we expected.  Continuing to rehash is probably no going
> > > to help.
> >
> > Seems like it might be ambiguous to me.  perhaps we just got a series of
> > collisions in the firs few entries after a  rebuild?  I dont know, Im just
> > playing devils advocate.
> 
> Have you computed the probability of that? If the limit is sensible
> this should be extremely unlikely.  Note that I'm also assuming
> that you've got 1) solved as otherwise all bets are off.
> 
> Assuming that we are counting it correctly, and that the length
> limit is set to a sensible value, then the probability of the
> attacker reaching that limit soon after a rehash is very small.
> 
> Therefore we can deduce that if it does happen then chances are
> that our RNG has been compromised and as such rehashing again
> will not help.
> 
Like I said, I'm just playing devils advocate on this.  Clearly the hash
function should be such that an early data set hashes to the same chain is very
low.

> > Why don't we just add a count to the number of times we call
> > rt_emergency_hash_rebuild?  If we cross a threshold on that count (or perhaps a
> > rate determined by jiffies since the last emergency rebuild), we can set a flag
> > to not always return a failed lookup in the cache, so as to force routing into
> > the slow path.
> 
> Really, if we're hitting this when nobody is attacking us then
> something is screwed up, notably 1) as it stands.
> 

Thats rather the point though.  If we're not being attacked, then we'll never
hit this (ideally).

I'll post a new patch when I figure out how best to handle entries which differ
by a field irrelevant to the hash function.

Neil

> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> 

-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
