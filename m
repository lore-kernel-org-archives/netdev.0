From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH RFC 1/2] flow: virtualize get and entry deletion methods
Date: Mon, 29 Mar 2010 14:39:36 +0300
Message-ID: <4BB09178.8050501@iki.fi>
References: <1269509091-6440-2-git-send-email-timo.teras@iki.fi> <20100325.122611.267401605.davem@davemloft.net> <20100329084018.GA22547@gondor.apana.org.au> <4BB06C36.9060105@iki.fi> <20100329090927.GA22899@gondor.apana.org.au> <4BB07BF6.6000505@iki.fi> <20100329102639.GA23414@gondor.apana.org.au> <4BB082B8.9030400@iki.fi> <20100329111025.GA23927@gondor.apana.org.au> <4BB08D96.8090909@iki.fi> <20100329113225.GA24159@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:57955 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925Ab0C2Ljk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 07:39:40 -0400
Received: by ey-out-2122.google.com with SMTP id d26so1116407eyd.19
        for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 04:39:38 -0700 (PDT)
In-Reply-To: <20100329113225.GA24159@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Mon, Mar 29, 2010 at 02:23:02PM +0300, Timo Ter=E4s wrote:
>>> I don't see the point.  As long as the data paths do not take
>>> the lock changing this doesn't buy us much.  You're still making
>>> that cacheline exclusive.
>> To my understanding declaring an atomic_t, or reading it with
>> atomic_read does not make cache line exclusive. Only the atomic_*
>> writing to it take the cache line. And since this is done exactly
>> once for policy (or it's a bug/warn thingy) it does not impose
>> significant performance issue.
>=20
> I was talking about the lock vs. atomic_xchg in xfrm_policy_kill.
> There is practically no difference for that case.
>=20
> Yes, on the read side the lock is a completely different beast
> compared to atomic_read, but I don't see how you can safely
> replace
>=20
> 	lock
> 	if (!dead)
> 		take ref
> 	unlock
>=20
> without making other changes.

Because the lock is not needed to take ref.

You can take ref as long as someone else is also holding a
valid reference.

The flow cache keeps a reference to each object it is holding,
thus we can always take a reference if we find an object there.
This is what is being done in the current code, and can be
still done in the new code.

The only reason my patch had the lock, was for the dead check.
Since it can be checked without locks, the locking can be
just removed.

The dead check is still an improvement: we find outdated cache
entries without doing a full flush and we find them faster than
using a full flush.

The old code would use policy entries with dead flag set, and
happily return and use them until the policy gc had an
opportunity to run.
