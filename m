From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Wed, 03 Sep 2008 09:45:48 +0300
Message-ID: <48BE329C.2010209@iki.fi>
References: <20080903055041.GA8547@gondor.apana.org.au>	<20080902.231420.255718595.davem@davemloft.net>	<48BE2E63.8000707@iki.fi> <20080902.233538.200370430.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:26374 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbYICGpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 02:45:41 -0400
Received: by ey-out-2122.google.com with SMTP id 6so1337246eyi.37
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2008 23:45:39 -0700 (PDT)
In-Reply-To: <20080902.233538.200370430.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Timo Ter=E4s <timo.teras@iki.fi>
> Date: Wed, 03 Sep 2008 09:27:47 +0300
>=20
>> Well, it's just another list keeping a reference like ->bydst,
>> ->bysrc and ->byspi. The actual amount of external references is
>> still correct (the walking code calls _hold() when it returns while
>> keeping an external pointer).
>=20
> ->bydst, ->bysrc, and ->byspi are counted as a single external
> reference because:
>=20
> 1) They are controlled as a group
>=20
> 2) Doing 3 atomic operations is more expensive than one
>=20
> I know because I did that conversion from 3 refcount operations down
> to 1 and I timed it with stress tests, which showed that it made a
> huge performance difference for the control path of our IPSEC stack.

I was a bit confused what you meant by "external reference". But
yes, in this sense it's adding a new external reference.

>> The difference is that node should not be unlinked from ->all until
>> all other references are gone. For other lists the unlinking can be
>> done earlier since they are used only for lookups.
>=20
> Once there are no list references, there cannot be any other referenc=
es.
> So in fact it seems to me that unlinking when the xfrm_state is remov=
ed
> from those other lists makes perfect sense.
>=20
> If __xfrm_state_delete sets the state to DEAD, and you skip xfrm_stat=
e
> objects marked DEAD, why does the ->all list reference have to surviv=
e
> past __xfrm_state_delete()?
>=20
> It seems the perfect place to do the ->all removal.

1. xfrm_state_walk() called, it returns but holds an entry since
   the walking was interrupted temporarily (e.g. full netlink buffer).

2. xfrm_state_delete() called to the entry that xfrm_state_walk()
   is keeping a pointer to and it is unlinked.

3. xfrm_state_walk() called again, it tries to resume list walking
   but whoops, the entry was unlinked and kaboom.

>> Any good other ways to enumerate to list entries while allowing
>> to keep a temporary "iterator"? The previous method was crap too.
>=20
> At least the old stuff was self-consistent and only needed one centra=
l
> lock grab to destoy an object.

Yes, but the dumping code produced crap. It could dump same entry
multiple times, miss entries and was dog slow. With it there was
no possibility to keep userland in sync with kernel SPD/SAD because
entries were lost.

- Timo
