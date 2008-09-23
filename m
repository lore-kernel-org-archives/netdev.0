From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Tue, 23 Sep 2008 16:01:29 +0300
Message-ID: <48D8E8A9.8050100@iki.fi>
References: <20080923045951.GA26048@gondor.apana.org.au> <48D87BDA.8040804@iki.fi> <20080923052239.GA26233@gondor.apana.org.au> <48D88BCC.5030806@iki.fi> <20080923064707.GA26836@gondor.apana.org.au> <48D8B967.8000107@iki.fi> <20080923112416.GA28946@gondor.apana.org.au> <48D8DC28.1020001@iki.fi> <20080923121414.GB29257@gondor.apana.org.au> <48D8E045.8040508@iki.fi> <20080923125615.GC29524@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.185]:52019 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbYIWNBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 09:01:34 -0400
Received: by mu-out-0910.google.com with SMTP id g7so1754429muf.1
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 06:01:32 -0700 (PDT)
In-Reply-To: <20080923125615.GC29524@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Tue, Sep 23, 2008 at 03:25:41PM +0300, Timo Ter=E4s wrote:
>> There can be a lot of xfrm_state structs. As in thousands. So it
>> will take more memory then. hlist would be enough, so it'd be a
>> 4/8 bytes addition. Single pointer would not be enough as we can
>> have multiple walks on the same entry.
>=20
> Right, we need doubly linked lists in the walkers to ease unlinking.
> But only a single pointer (i.e., an hlist) is needed in xfrm_state.

Right.
=20
>> I was thinking about the same. That's why I wasn't so sure if this i=
s
>> better. In practice there aren't many walks active. Maybe we limit
>> the maximum simultaneous walks?
>=20
> That sounds like a hack :)

Yes :)
=20
>> But in real life, there is only a one or two walkers if any active.
>> So I would not consider a global update too expensive. But if you th=
ink
>> it might become a problem, I'd add an hlist to xfrm_state of walkers
>> referencing that entry.
>=20
> Well in real life dumps don't tend to get suspended either :)
> In any case, a suspended dump is only going to pin down some
> memory, while a very long list walk may kill the box.

So, what to do?
1. Go back to: list_del_rcu, xfrm_state_hold(all.next) on delete and
   xfrm_state_put(all.next) on destruct.
2. Add per-entry hlist of walkers currently referencing it.
3. Use the global walker list.

1 can keep memory allocated until userland wakes up. 2 & 3 can make
the delete of that entry slow if there's many walkers suspended.

Btw. the current stuff in net-next is broken. There's no locking
for xfrm_state_walkers list handling.

Cheers,
  Timo
