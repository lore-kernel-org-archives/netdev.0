From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
	gc_elasticity is exceeded
Date: Mon, 6 Oct 2008 19:02:49 +0800
Message-ID: <20081006110249.GA22613@gondor.apana.org.au>
References: <20080930.070804.26007839.davem@davemloft.net> <E1KmKGd-000393-UD@gondolin.me.apana.org.au> <c3ca0c0f0810042145q35a451a7u706bc64fb43723fa@mail.gmail.com> <20081005.103454.247312994.davem@davemloft.net> <20081006042108.GA19398@gondor.apana.org.au> <20081006105022.GA16939@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, whydna@whydna.net,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49113 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752812AbYJFLDE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 07:03:04 -0400
Content-Disposition: inline
In-Reply-To: <20081006105022.GA16939@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 06, 2008 at 06:50:22AM -0400, Neil Horman wrote:
>
> > 1) The way we count the chain length is wrong.  There are keys
> > which do not form part of the hash computation.  Entries that
> > only differ by them will always end up in the same bucket.
>
> I'm not sure I follow what your saying here.  I understand that some keys will
> wind up hashing to the same bucket, but from what I see a change to the saddr
> and daddr parameters to rt_hash, will change what bucket you hash too.  What am
> I missing?

We've got keys other than saddr/daddr, for example, all route
entries that differ only by TOS hash to the same bucket.  There
are quite a few possible TOS values.

Have a look at ip r l c.

> > 2) What do we do when we get a long chain just after a rehash.
> > 
> > This is an indication that the attacker has more knowledge about
> > us than we expected.  Continuing to rehash is probably no going
> > to help.
>
> Seems like it might be ambiguous to me.  perhaps we just got a series of
> collisions in the firs few entries after a  rebuild?  I dont know, Im just
> playing devils advocate.

Have you computed the probability of that? If the limit is sensible
this should be extremely unlikely.  Note that I'm also assuming
that you've got 1) solved as otherwise all bets are off.

Assuming that we are counting it correctly, and that the length
limit is set to a sensible value, then the probability of the
attacker reaching that limit soon after a rehash is very small.

Therefore we can deduce that if it does happen then chances are
that our RNG has been compromised and as such rehashing again
will not help.

> Why don't we just add a count to the number of times we call
> rt_emergency_hash_rebuild?  If we cross a threshold on that count (or perhaps a
> rate determined by jiffies since the last emergency rebuild), we can set a flag
> to not always return a failed lookup in the cache, so as to force routing into
> the slow path.

Really, if we're hitting this when nobody is attacking us then
something is screwed up, notably 1) as it stands.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
