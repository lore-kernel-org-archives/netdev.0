From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Sun, 21 Sep 2008 18:21:27 +0300
Message-ID: <48D66677.2040309@iki.fi>
References: <48BE329C.2010209@iki.fi> <20080902.234723.163403187.davem@davemloft.net> <20080905115506.GA26179@gondor.apana.org.au> <20080908.172513.162820960.davem@davemloft.net> <20080909143312.GA29952@gondor.apana.org.au> <48D63E3A.90301@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:52778 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877AbYIUPVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2008 11:21:32 -0400
Received: by ey-out-2122.google.com with SMTP id 6so325905eyi.37
        for <netdev@vger.kernel.org>; Sun, 21 Sep 2008 08:21:30 -0700 (PDT)
In-Reply-To: <48D63E3A.90301@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=E4s wrote:
> Herbert Xu wrote:
>> On Mon, Sep 08, 2008 at 05:25:13PM -0700, David Miller wrote:
>> I've avoided the memory barrier by simply extending the mutexed
>> section in the GC to cover the list splicing.  Here's the updated
>> patch:
>>
>> ipsec: Use RCU-like construct for saved state within a walk
>>
>> Now that we save states within a walk we need synchronisation
>> so that the list the saved state is on doesn't disappear from
>> under us.
>>
>> As it stands this is done by keeping the state on the list which
>> is bad because it gets in the way of the management of the state
>> life-cycle.
>>
>> An alternative is to make our own pseudo-RCU system where we use
>> counters to indicate which state can't be freed immediately as
>> it may be referenced by an ongoing walk when that resumes.
>=20
> Does not this logic fail if:
> 1. completed =3D ongoing
> 2. 1st walk started and iterator kept (a->lastused =3D ongoing, ongoi=
ng++)
> 3. 2nd walk started and iterator kept (b->lastused =3D ongoing, ongoi=
ng++)
> 4. 2nd walk finished (completed++)
> 5. gc triggered: a gets deleted since a->lastused =3D=3D completed
> 6. 1st walk continued but freed memory accessed as a was deleted
>=20
> Though currently it does not affect, since xfrm_state_hold/_put
> are still called when keeping the iterator, so the entries won't
> actually get garbage collected anyway. So the completed/ongoing
> counting is basically useless. Or am I missing something?

Obviously I missed the fact that it prevents deletion of the entries
which the iterator held list node might still point to.

But the flaw still exists: the entries which interator->next points
can be deleted if there is a walking that takes a long time and
meanwhile we get walks that complete fast.

> Wouldn't it be enough to do the list_del_rcu on delete? And
> just keep reference as previously?

So if we do list_del_rcu() on delete, could we also xfrm_state_hold()
the entry pointed to by that list entry. And then on GC we could
xfrm_state_put() the next entry.

- Timo
