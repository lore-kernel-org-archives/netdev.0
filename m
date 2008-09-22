From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Mon, 22 Sep 2008 16:01:14 +0300
Message-ID: <48D7971A.5050107@iki.fi>
References: <48BE329C.2010209@iki.fi> <20080902.234723.163403187.davem@davemloft.net> <20080905115506.GA26179@gondor.apana.org.au> <20080908.172513.162820960.davem@davemloft.net> <20080909143312.GA29952@gondor.apana.org.au> <48D63E3A.90301@iki.fi> <48D66677.2040309@iki.fi> <20080922114256.GA27055@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:53122 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752048AbYIVNBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 09:01:25 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1360227fgg.17
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 06:01:23 -0700 (PDT)
In-Reply-To: <20080922114256.GA27055@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Sun, Sep 21, 2008 at 06:21:27PM +0300, Timo Ter=E4s wrote:
>> So if we do list_del_rcu() on delete, could we also xfrm_state_hold(=
)
>> the entry pointed to by that list entry. And then on GC we could
>> xfrm_state_put() the next entry.
>=20
> Unfortunately it's not that simple since we'll be in the same
> bind if the entry after the next entry gets deleted as well as
> the next entry.

Well, I was thinking that we hold the next pointer. And when
continuing the dump, we can first skip all entries that are marked
as dead (each next pointer is valid since each of the next pointers
are held once). When we find the first valid entry to dump we
_put() the originally held entry. That would recursively _put() all
the next entries which were held.

> The only other solution is to go back to the original scheme
> where we keep the list intact until GC.  However, nobody has
> come up with a way of doing that that allows the SA creation
> path to run locklessly with respect to the dumping path.
>=20
> So I think we'll have to stick with the quasi-RCU solution for
> now.  Here's a patch to fix the flaw that you discovered.

But yes, this would work as well.

Not sure which one would be faster. I guess the holding of
individual entries would be at least more memory efficient.

Cheers,
  Timo
