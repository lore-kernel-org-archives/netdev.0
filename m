From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
	gc_elasticity is exceeded
Date: Mon, 6 Oct 2008 12:21:08 +0800
Message-ID: <20081006042108.GA19398@gondor.apana.org.au>
References: <20080930.070804.26007839.davem@davemloft.net> <E1KmKGd-000393-UD@gondolin.me.apana.org.au> <c3ca0c0f0810042145q35a451a7u706bc64fb43723fa@mail.gmail.com> <20081005.103454.247312994.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: whydna@whydna.net, nhorman@tuxdriver.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55623 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750854AbYJFEVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 00:21:25 -0400
Content-Disposition: inline
In-Reply-To: <20081005.103454.247312994.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 05, 2008 at 10:34:54AM -0700, David Miller wrote:
>
> Eric showed clearly that on a completely normal well loaded
> system, the chain lengths exceed the elasticity all the time
> and it's not like these are entries we can get rid of because
> their refcounts are all > 1

I think there are two orthogonal issues here.

1) The way we count the chain length is wrong.  There are keys
which do not form part of the hash computation.  Entries that
only differ by them will always end up in the same bucket.

We should count all entries that only differ by those keys as
a single entry for the purposes of detecting an attack.

FWIW we could even reorganise the storage inside a bucket such
that it is a 2-level list where the first level only contained
entries that differ by saddr/daddr.

2) What do we do when we get a long chain just after a rehash.

This is an indication that the attacker has more knowledge about
us than we expected.  Continuing to rehash is probably no going
to help.

We need to decide whether we care about this scenario.

If yes, then we'll need to come up with a way to bypass the
route cache, or at least act as if it was bypassed.

If not, then we can just kill the rehash interval altogether.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
