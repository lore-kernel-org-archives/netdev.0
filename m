From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Tue, 23 Sep 2008 08:17:14 +0300
Message-ID: <48D87BDA.8040804@iki.fi>
References: <20080902.234723.163403187.davem@davemloft.net> <20080905115506.GA26179@gondor.apana.org.au> <20080908.172513.162820960.davem@davemloft.net> <20080909143312.GA29952@gondor.apana.org.au> <48D63E3A.90301@iki.fi> <48D66677.2040309@iki.fi> <20080922114256.GA27055@gondor.apana.org.au> <48D7971A.5050107@iki.fi> <20080922235012.GA23658@gondor.apana.org.au> <48D8763E.4030607@iki.fi> <20080923045951.GA26048@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.180]:62258 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404AbYIWFRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 01:17:19 -0400
Received: by ik-out-1112.google.com with SMTP id c30so1079557ika.5
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 22:17:17 -0700 (PDT)
In-Reply-To: <20080923045951.GA26048@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Tue, Sep 23, 2008 at 07:53:18AM +0300, Timo Ter=E4s wrote:
>> So the idea was to hold X->next from deletion function, not from
>> the walking function. That would be, we always hold deleted->next wh=
en
>> there are ongoing walks. And on final _put() we _put() the ->next
>> entry.
>>
>> I think that would work.
>=20
> Right, this would work.
>=20
> However, now you're again slowing down the relatively fast path of
> state deletion by moving extra work there from the non-critical
> dump path.

The extra step there wold be a hold call. The recursive _put on a
_put of some entry can happen only on dump path. As otherwise the
->next entry is first held in state delete, but would be immediately
_put on the _put as the final step of _delete().

So basically one additional atomic_inc() and one atomic_dec() on the
normal _delete() path.

> When we optimise code for time, we don't necessarily try to minimise
> the work overall.  We instead try to minimise the amount of work on
> the critical paths.  It's OK to let the other paths such as dumping
> do a bit more work if it improves the fast paths.

Not sure about the overall penalty, but yes I know it would have some
penalty. But at least there would be no locking.

Particularly the thing that can happen on your approach is that if
there is a user land process that gets suspended during a dump
processing, it would prevent the garbage collection of all entries
for all eternity until that process is continued or killed.

So this would allow deletion and GC of entries even during walking.
But this was just a thought. Maybe it's not worth trying.

Cheers,
  Timo
